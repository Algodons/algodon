# ALGODON Deployment Guide

## Quick Start

### Local Development

```powershell
.\deployment\scripts\deploy.ps1 local
```

This will:
- Start Docker Compose with all services (Oracle, Redis, PostgreSQL, MinIO)
- Wait for services to be healthy
- Provide URLs for accessing services

Then start the Next.js dev server:
```bash
cd web
npm install
npm run dev
```

### Staging Deployment

```powershell
.\deployment\scripts\deploy.ps1 staging
```

### Production Deployment

```powershell
.\deployment\scripts\deploy.ps1 production
```

## Prerequisites

- Docker Desktop
- Node.js 20+
- kubectl (for staging/production)
- AWS CLI (for Terraform)

## Environment Variables

Copy `web/.env.example` to `web/.env` and fill in:
- Database connection strings
- API keys (Stripe, OpenAI, etc.)
- AWS credentials

## Database Setup

1. Run Oracle schema migration:
```sql
@database/oracle/schemas/01_schema.sql
```

2. Seed initial data:
```sql
@database/oracle/seeds/01_seed.sql
```

## Monitoring

- Health check: `http://localhost:3000/api/health`
- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3001`

## Troubleshooting

### Services not starting
```bash
docker-compose logs
```

### Database connection issues
```bash
docker-compose exec oracle-db sqlplus algodon/password@localhost:1521/XE
```

### Reset everything
```bash
docker-compose down -v
docker-compose up -d
```
