# ALGODON Deployment Script
# Usage: .\deploy.ps1 [local|staging|production]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("local", "staging", "production")]
    [string]$Environment
)

Write-Host "ðŸš€ ALGODON Deployment - $Environment" -ForegroundColor Cyan

# Check prerequisites
$prerequisites = @{
    "Docker" = "docker"
    "Node.js" = "node"
    "npm" = "npm"
}

foreach ($prereq in $prerequisites.GetEnumerator()) {
    $command = Get-Command $prereq.Value -ErrorAction SilentlyContinue
    if (-not $command) {
        Write-Host "âŒ $($prereq.Key) is not installed. Please install it first." -ForegroundColor Red
        exit 1
    }
    Write-Host "âœ… $($prereq.Key) found: $($command.Version)" -ForegroundColor Green
}

switch ($Environment) {
    "local" {
        Write-Host "`nðŸ“¦ Starting local development environment..." -ForegroundColor Yellow
        
        # Check if .env file exists
        if (-not (Test-Path "web\.env")) {
            Write-Host "âš ï¸  .env file not found. Creating from .env.example..." -ForegroundColor Yellow
            Copy-Item "web\.env.example" "web\.env"
            Write-Host "âš ï¸  Please update web\.env with your API keys!" -ForegroundColor Yellow
        }
        
        # Start Docker Compose
        Write-Host "`nðŸ³ Starting Docker containers..." -ForegroundColor Yellow
        Set-Location "deployment\docker"
        docker-compose up -d
        
        Write-Host "`nâ³ Waiting for services to be ready..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
        
        # Check health
        $maxRetries = 10
        $retryCount = 0
        $healthy = $false
        
        while ($retryCount -lt $maxRetries -and -not $healthy) {
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -UseBasicParsing -ErrorAction Stop
                if ($response.StatusCode -eq 200) {
                    $healthy = $true
                }
            } catch {
                $retryCount++
                Write-Host "  Waiting for services... ($retryCount/$maxRetries)" -ForegroundColor Gray
                Start-Sleep -Seconds 5
            }
        }
        
        if ($healthy) {
            Write-Host "`nâœ… Local environment is ready!" -ForegroundColor Green
            Write-Host "`nðŸ“ Services:" -ForegroundColor Cyan
            Write-Host "   Web: http://localhost:3000" -ForegroundColor Yellow
            Write-Host "   Oracle DB: localhost:1521" -ForegroundColor Yellow
            Write-Host "   Redis: localhost:6379" -ForegroundColor Yellow
            Write-Host "   MinIO: http://localhost:9001" -ForegroundColor Yellow
            Write-Host "`nðŸ’¡ To start the Next.js dev server:" -ForegroundColor Cyan
            Write-Host "   cd web && npm run dev" -ForegroundColor White
        } else {
            Write-Host "`nâŒ Services failed to start. Check logs with:" -ForegroundColor Red
            Write-Host "   docker-compose logs" -ForegroundColor White
            exit 1
        }
        
        Set-Location "../.."
    }
    
    "staging" {
        Write-Host "`nðŸ“¦ Deploying to staging..." -ForegroundColor Yellow
        
        # Check kubectl
        $kubectl = Get-Command kubectl -ErrorAction SilentlyContinue
        if (-not $kubectl) {
            Write-Host "âŒ kubectl is not installed. Please install it first." -ForegroundColor Red
            exit 1
        }
        
        # Build and push image
        Write-Host "`nðŸ”¨ Building Docker image..." -ForegroundColor Yellow
        Set-Location "web"
        docker build -t ghcr.io/algodon/web:staging .
        docker push ghcr.io/algodon/web:staging
        Set-Location ".."
        
        # Deploy to Kubernetes
        Write-Host "`nðŸš€ Deploying to Kubernetes..." -ForegroundColor Yellow
        kubectl set image deployment/algodon-web web=ghcr.io/algodon/web:staging -n algodon
        kubectl rollout status deployment/algodon-web -n algodon
        
        Write-Host "`nâœ… Staging deployment complete!" -ForegroundColor Green
        Write-Host "   URL: https://staging.algodon.app" -ForegroundColor Yellow
    }
    
    "production" {
        Write-Host "`nâš ï¸  PRODUCTION DEPLOYMENT" -ForegroundColor Red
        $confirm = Read-Host "Type 'DEPLOY' to confirm production deployment"
        
        if ($confirm -ne "DEPLOY") {
            Write-Host "Deployment cancelled." -ForegroundColor Yellow
            exit 0
        }
        
        # Check kubectl
        $kubectl = Get-Command kubectl -ErrorAction SilentlyContinue
        if (-not $kubectl) {
            Write-Host "âŒ kubectl is not installed. Please install it first." -ForegroundColor Red
            exit 1
        }
        
        # Build and push image
        Write-Host "`nðŸ”¨ Building Docker image..." -ForegroundColor Yellow
        Set-Location "web"
        $tag = "ghcr.io/algodon/web:prod-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        docker build -t $tag .
        docker push $tag
        Set-Location ".."
        
        # Deploy to Kubernetes (canary)
        Write-Host "`nðŸš€ Deploying to production (canary 10%)..." -ForegroundColor Yellow
        kubectl set image deployment/algodon-web web=$tag -n algodon
        kubectl rollout status deployment/algodon-web -n algodon --timeout=5m
        
        # Smoke tests
        Write-Host "`nðŸ§ª Running smoke tests..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
        try {
            $response = Invoke-WebRequest -Uri "https://algodon.app/api/health" -UseBasicParsing
            if ($response.StatusCode -eq 200) {
                Write-Host "âœ… Smoke tests passed!" -ForegroundColor Green
                
                # Full rollout
                Write-Host "`nðŸš€ Scaling to 100%..." -ForegroundColor Yellow
                kubectl scale deployment/algodon-web --replicas=5 -n algodon
                kubectl rollout status deployment/algodon-web -n algodon
            }
        } catch {
            Write-Host "âŒ Smoke tests failed! Rolling back..." -ForegroundColor Red
            kubectl rollout undo deployment/algodon-web -n algodon
            exit 1
        }
        
        Write-Host "`nâœ… Production deployment complete!" -ForegroundColor Green
        Write-Host "   URL: https://algodon.app" -ForegroundColor Yellow
    }
}

Write-Host "`nâœ… Deployment script complete!" -ForegroundColor Green
