# ALGODON Part 1: Base Structure
# This script creates the complete folder structure, package.json files, and base configurations

Write-Host "🚀 ALGODON Part 1: Base Structure" -ForegroundColor Cyan

# Create root directory
$rootDir = "ALGODON"
if (Test-Path $rootDir) {
    Write-Host "⚠️  ALGODON directory already exists. Continuing..." -ForegroundColor Yellow
} else {
    New-Item -ItemType Directory -Force -Path $rootDir | Out-Null
    Write-Host "✅ Created root directory: $rootDir" -ForegroundColor Green
}

Set-Location $rootDir

# Create complete folder structure
$folders = @(
    # Web App Structure
    "web/app/(marketing)",
    "web/app/(marketing)/features",
    "web/app/(marketing)/pricing",
    "web/app/(marketing)/blog",
    "web/app/(marketing)/blog/[slug]",
    "web/app/(marketing)/docs",
    "web/app/(dashboard)/projects",
    "web/app/(dashboard)/projects/[id]",
    "web/app/(dashboard)/editor/[projectId]",
    "web/app/(dashboard)/ai-chat",
    "web/app/(dashboard)/usage",
    "web/app/(dashboard)/billing",
    "web/app/(dashboard)/settings",
    "web/app/(admin)/users",
    "web/app/(admin)/billing",
    "web/app/(admin)/ai-models",
    "web/app/(admin)/database",
    "web/app/(admin)/api-keys",
    "web/app/(admin)/analytics",
    "web/app/(admin)/system",
    "web/app/api/admin",
    "web/app/api/admin/users",
    "web/app/api/admin/billing",
    "web/app/api/admin/ai",
    "web/app/api/admin/oracle",
    "web/app/api/admin/api-keys",
    "web/app/api/projects",
    "web/app/api/execute",
    "web/app/api/ai",
    "web/app/api/ai/complete",
    "web/app/api/ai/chat",
    "web/app/api/payments/stripe",
    "web/app/api/payments/square",
    "web/app/api/payments/cashapp",
    "web/app/api/payments/crypto",
    "web/app/api/payments/web3",
    "web/app/api/webhooks/stripe",
    "web/app/api/webhooks/square",
    "web/app/api/webhooks/cashapp",
    "web/app/api/webhooks/coinbase",
    "web/components/marketing",
    "web/components/dashboard",
    "web/components/admin",
    "web/components/payments",
    "web/components/seo",
    "web/components/ui",
    "web/components/editor",
    "web/lib/db",
    "web/lib/ai",
    "web/lib/payments",
    "web/lib/utils",
    "web/config",
    "web/types",
    "web/public/icons",
    "web/public/images",
    "web/styles",
    
    # Mobile App Structure
    "mobile/src/screens/auth",
    "mobile/src/screens/projects",
    "mobile/src/screens/editor",
    "mobile/src/screens/ai",
    "mobile/src/screens/settings",
    "mobile/src/components",
    "mobile/src/navigation",
    "mobile/src/services/api",
    "mobile/src/services/storage",
    "mobile/src/store",
    "mobile/src/types",
    "mobile/src/utils",
    "mobile/src/config",
    "mobile/assets/fonts",
    "mobile/assets/images",
    
    # Desktop App Structure
    "desktop/src/main",
    "desktop/src/preload",
    "desktop/src/renderer",
    "desktop/build",
    
    # Backend Services
    "backend-services/auth-service/src/controllers",
    "backend-services/auth-service/src/models",
    "backend-services/auth-service/src/routes",
    "backend-services/auth-service/src/middleware",
    "backend-services/payment-service/src/providers",
    "backend-services/payment-service/src/controllers",
    "backend-services/payment-service/src/models",
    "backend-services/ai-service/src/agents",
    "backend-services/ai-service/src/models",
    "backend-services/ai-service/src/orchestrator",
    "backend-services/execution-service/src/sandbox",
    "backend-services/execution-service/src/runners",
    "backend-services/execution-service/src/containers",
    "backend-services/notification-service/src/providers",
    "backend-services/notification-service/src/queues",
    
    # Database
    "database/oracle/migrations",
    "database/oracle/schemas",
    "database/oracle/seeds",
    "database/redis",
    
    # Admin Panel
    "admin-panel/src/components",
    "admin-panel/src/pages",
    "admin-panel/src/services",
    "admin-panel/src/store",
    "admin-panel/src/utils",
    
    # Shared
    "shared/types",
    "shared/utils",
    "shared/constants",
    
    # Deployment
    "deployment/docker",
    "deployment/kubernetes",
    "deployment/ci-cd",
    "deployment/scripts",
    "deployment/terraform"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Force -Path $folder | Out-Null
        Write-Host "✅ Created $folder" -ForegroundColor Green
    }
}

# Generate root package.json
$rootPackageJson = @'
{
  "name": "algodon",
  "version": "1.0.0",
  "description": "ALGODON - Production-ready Replit clone with AI assistance",
  "private": true,
  "workspaces": [
    "web",
    "mobile",
    "desktop",
    "backend-services/*",
    "admin-panel",
    "shared"
  ],
  "scripts": {
    "dev": "concurrently \"npm run dev:web\" \"npm run dev:mobile\"",
    "dev:web": "cd web && npm run dev",
    "dev:mobile": "cd mobile && expo start",
    "dev:desktop": "cd desktop && npm run electron",
    "build": "npm run build:web && npm run build:mobile && npm run build:desktop",
    "build:web": "cd web && npm run build",
    "build:mobile": "cd mobile && expo build:all",
    "build:desktop": "cd desktop && npm run build",
    "test": "npm run test:web && npm run test:mobile",
    "test:web": "cd web && npm test",
    "test:mobile": "cd mobile && npm test",
    "lint": "eslint . --ext .ts,.tsx,.js,.jsx",
    "format": "prettier --write \"**/*.{ts,tsx,js,jsx,json,css,md}\""
  },
  "devDependencies": {
    "@types/node": "^20.10.0",
    "@typescript-eslint/eslint-plugin": "^6.13.0",
    "@typescript-eslint/parser": "^6.13.0",
    "concurrently": "^8.2.2",
    "eslint": "^8.54.0",
    "eslint-config-next": "^14.0.0",
    "prettier": "^3.1.0",
    "typescript": "^5.3.2"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
'@

$rootPackageJson | Out-File -FilePath "package.json" -Encoding UTF8
Write-Host "✅ Created root package.json" -ForegroundColor Green

# Generate web package.json
$webPackageJson = @'
{
  "name": "algodon-web",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "next": "^14.2.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@clerk/nextjs": "^5.0.0",
    "@privy-io/react-auth": "^1.0.0",
    "stripe": "^14.0.0",
    "square": "^35.0.0",
    "coinbase-commerce-node": "^1.0.4",
    "oracledb": "^6.3.0",
    "redis": "^4.6.0",
    "zod": "^3.22.4",
    "axios": "^1.6.2",
    "socket.io-client": "^4.5.4",
    "monaco-editor": "^0.45.0",
    "@monaco-editor/react": "^4.6.0",
    "recharts": "^2.10.3",
    "date-fns": "^3.0.0",
    "react-hook-form": "^7.48.2",
    "@hookform/resolvers": "^3.3.2",
    "zustand": "^4.4.7",
    "react-hot-toast": "^2.4.1",
    "framer-motion": "^10.16.16",
    "lucide-react": "^0.294.0",
    "clsx": "^2.0.0",
    "tailwind-merge": "^2.1.0",
    "next-themes": "^0.2.1",
    "@radix-ui/react-dialog": "^1.0.5",
    "@radix-ui/react-dropdown-menu": "^2.0.6",
    "@radix-ui/react-select": "^2.0.0",
    "@radix-ui/react-tabs": "^1.0.4",
    "@radix-ui/react-toast": "^1.1.5",
    "@radix-ui/react-tooltip": "^1.0.7",
    "winston": "^3.11.0",
    "express-rate-limit": "^7.1.5",
    "helmet": "^7.1.0",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "mdx": "^2.3.0",
    "@next/mdx": "^14.0.0",
    "gray-matter": "^4.0.3",
    "reading-time": "^1.5.0"
  },
  "devDependencies": {
    "@types/node": "^20.10.0",
    "@types/react": "^18.2.42",
    "@types/react-dom": "^18.2.17",
    "@types/express": "^4.17.21",
    "@types/cors": "^2.8.17",
    "typescript": "^5.3.2",
    "tailwindcss": "^3.3.6",
    "postcss": "^8.4.32",
    "autoprefixer": "^10.4.16",
    "eslint": "^8.54.0",
    "eslint-config-next": "^14.0.0"
  }
}
'@

$webPackageJson | Out-File -FilePath "web/package.json" -Encoding UTF8
Write-Host "✅ Created web/package.json" -ForegroundColor Green

# Generate mobile package.json
$mobilePackageJson = @'
{
  "name": "algodon-mobile",
  "version": "1.0.0",
  "main": "expo-router/entry",
  "scripts": {
    "start": "expo start",
    "android": "expo start --android",
    "ios": "expo start --ios",
    "web": "expo start --web",
    "build:ios": "eas build --platform ios",
    "build:android": "eas build --platform android",
    "build:all": "eas build --platform all",
    "submit:ios": "eas submit --platform ios",
    "submit:android": "eas submit --platform android"
  },
  "dependencies": {
    "expo": "~50.0.0",
    "expo-router": "~3.4.0",
    "react": "18.2.0",
    "react-native": "0.73.0",
    "react-native-screens": "~3.29.0",
    "react-native-safe-area-context": "4.8.2",
    "@react-navigation/native": "^6.1.9",
    "@react-navigation/stack": "^6.3.20",
    "@react-navigation/bottom-tabs": "^6.5.11",
    "@react-navigation/drawer": "^6.6.6",
    "zustand": "^4.4.7",
    "axios": "^1.6.2",
    "socket.io-client": "^4.5.4",
    "react-syntax-highlighter": "^15.5.0",
    "@react-native-async-storage/async-storage": "1.21.0",
    "@nozbe/watermelondb": "^0.27.1",
    "@nozbe/with-observables": "^1.4.0",
    "expo-document-picker": "~11.10.0",
    "expo-file-system": "~16.0.6",
    "expo-sharing": "~11.10.0",
    "expo-notifications": "~0.27.0",
    "expo-local-authentication": "~13.8.0",
    "expo-background-fetch": "~12.0.1",
    "expo-camera": "~14.0.1",
    "react-native-fast-image": "^8.6.3",
    "nativewind": "^2.0.11",
    "react-native-reanimated": "~3.6.0",
    "react-native-gesture-handler": "~2.14.0",
    "@clerk/clerk-expo": "^1.0.0",
    "date-fns": "^3.0.0"
  },
  "devDependencies": {
    "@babel/core": "^7.23.5",
    "@types/react": "~18.2.45",
    "typescript": "^5.3.2",
    "tailwindcss": "^3.3.6"
  },
  "private": true
}
'@

$mobilePackageJson | Out-File -FilePath "mobile/package.json" -Encoding UTF8
Write-Host "✅ Created mobile/package.json" -ForegroundColor Green

# Generate desktop package.json
$desktopPackageJson = @'
{
  "name": "algodon-desktop",
  "version": "1.0.0",
  "description": "ALGODON Desktop Application",
  "main": "dist/main/index.js",
  "scripts": {
    "dev": "concurrently \"npm run dev:renderer\" \"npm run dev:main\"",
    "dev:renderer": "cd src/renderer && next dev",
    "dev:main": "tsc -w -p tsconfig.main.json",
    "build": "npm run build:renderer && npm run build:main && electron-builder",
    "build:renderer": "cd src/renderer && next build",
    "build:main": "tsc -p tsconfig.main.json",
    "electron": "electron dist/main/index.js",
    "electron:dev": "electron dist/main/index.js --dev",
    "pack": "electron-builder --dir",
    "dist": "electron-builder"
  },
  "dependencies": {
    "electron": "^28.0.0",
    "electron-updater": "^6.1.7"
  },
  "devDependencies": {
    "@types/node": "^20.10.0",
    "concurrently": "^8.2.2",
    "electron-builder": "^24.9.1",
    "typescript": "^5.3.2"
  },
  "build": {
    "appId": "com.algodon.desktop",
    "productName": "ALGODON",
    "directories": {
      "output": "dist-electron"
    },
    "files": [
      "dist/**/*",
      "src/renderer/.next/**/*"
    ],
    "mac": {
      "category": "public.app-category.developer-tools",
      "target": "dmg"
    },
    "win": {
      "target": "nsis"
    },
    "linux": {
      "target": "AppImage"
    }
  }
}
'@

$desktopPackageJson | Out-File -FilePath "desktop/package.json" -Encoding UTF8
Write-Host "✅ Created desktop/package.json" -ForegroundColor Green

# Generate TypeScript configs
$webTsConfig = @'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./*"],
      "@/components/*": ["./components/*"],
      "@/lib/*": ["./lib/*"],
      "@/types/*": ["./types/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
'@

$webTsConfig | Out-File -FilePath "web/tsconfig.json" -Encoding UTF8
Write-Host "✅ Created web/tsconfig.json" -ForegroundColor Green

# Generate Next.js config
$nextConfig = @'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  images: {
    domains: ['localhost', 'algodon.app', 'cdn.algodon.app'],
    formats: ['image/avif', 'image/webp'],
  },
  experimental: {
    serverActions: {
      bodySizeLimit: '10mb',
    },
  },
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
        ],
      },
    ];
  },
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: '/api/:path*',
      },
    ];
  },
};

module.exports = nextConfig;
'@

$nextConfig | Out-File -FilePath "web/next.config.js" -Encoding UTF8
Write-Host "✅ Created web/next.config.js" -ForegroundColor Green

# Generate Tailwind config
$tailwindConfig = @'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
        },
        secondary: {
          50: '#faf5ff',
          100: '#f3e8ff',
          200: '#e9d5ff',
          300: '#d8b4fe',
          400: '#c084fc',
          500: '#a855f7',
          600: '#9333ea',
          700: '#7e22ce',
          800: '#6b21a8',
          900: '#581c87',
        },
      },
      fontFamily: {
        sans: ['var(--font-inter)', 'system-ui', 'sans-serif'],
        mono: ['var(--font-mono)', 'monospace'],
      },
      animation: {
        'gradient': 'gradient 8s linear infinite',
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
      keyframes: {
        gradient: {
          '0%, 100%': {
            'background-size': '200% 200%',
            'background-position': 'left center'
          },
          '50%': {
            'background-size': '200% 200%',
            'background-position': 'right center'
          },
        },
      },
    },
  },
  plugins: [],
  darkMode: 'class',
};
'@

$tailwindConfig | Out-File -FilePath "web/tailwind.config.js" -Encoding UTF8
Write-Host "✅ Created web/tailwind.config.js" -ForegroundColor Green

# Generate PostCSS config
$postcssConfig = @'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
'@

$postcssConfig | Out-File -FilePath "web/postcss.config.js" -Encoding UTF8
Write-Host "✅ Created web/postcss.config.js" -ForegroundColor Green

# Generate .env.example
$envExample = @'
# Database
ORACLE_CONNECTION_STRING=oracle://user:password@localhost:1521/XE
REDIS_URL=redis://localhost:6379
POSTGRES_URL=postgresql://user:password@localhost:5432/algodon_analytics

# Authentication
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_...
CLERK_SECRET_KEY=sk_test_...
NEXT_PUBLIC_PRIVY_APP_ID=cl_...

# Payments
STRIPE_SECRET_KEY=sk_test_...
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
SQUARE_ACCESS_TOKEN=EAAA...
SQUARE_LOCATION_ID=...
SQUARE_APPLICATION_ID=...
CASHAPP_API_KEY=...
CASHAPP_CLIENT_ID=...
COINBASE_COMMERCE_API_KEY=...
COINBASE_COMMERCE_WEBHOOK_SECRET=...

# AI Services
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GOOGLE_GEMINI_API_KEY=...
HUGGINGFACE_API_KEY=hf_...

# AWS
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-1
AWS_S3_BUCKET=algodon-storage
AWS_CLOUDFRONT_URL=https://cdn.algodon.app

# Web3
ETH_RPC_URL=https://mainnet.infura.io/v3/...
POLYGON_RPC_URL=https://polygon-rpc.com

# App URLs
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_API_URL=http://localhost:3000/api

# Security
JWT_SECRET=your-super-secret-jwt-key-change-in-production
ENCRYPTION_KEY=your-32-character-encryption-key

# Monitoring
SENTRY_DSN=...
PROMETHEUS_ENDPOINT=http://localhost:9090

# Email
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=...
SMTP_FROM=noreply@algodon.app

# Feature Flags
ENABLE_CRYPTO_PAYMENTS=true
ENABLE_WEB3_AUTH=true
ENABLE_AI_FEATURES=true
'@

$envExample | Out-File -FilePath "web/.env.example" -Encoding UTF8
Write-Host "✅ Created web/.env.example" -ForegroundColor Green

# Generate mobile app.json
$mobileAppJson = @'
{
  "expo": {
    "name": "ALGODON",
    "slug": "algodon-mobile",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/images/icon.png",
    "userInterfaceStyle": "automatic",
    "splash": {
      "image": "./assets/images/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#0ea5e9"
    },
    "assetBundlePatterns": [
      "**/*"
    ],
    "ios": {
      "supportsTablet": true,
      "bundleIdentifier": "com.algodon.mobile",
      "buildNumber": "1.0.0",
      "infoPlist": {
        "NSCameraUsageDescription": "ALGODON needs camera access to scan code from whiteboards and books.",
        "NSPhotoLibraryUsageDescription": "ALGODON needs photo library access to import code files."
      }
    },
    "android": {
      "adaptiveIcon": {
        "foregroundImage": "./assets/images/adaptive-icon.png",
        "backgroundColor": "#0ea5e9"
      },
      "package": "com.algodon.mobile",
      "versionCode": 1,
      "permissions": [
        "CAMERA",
        "READ_EXTERNAL_STORAGE",
        "WRITE_EXTERNAL_STORAGE"
      ]
    },
    "web": {
      "favicon": "./assets/images/favicon.png"
    },
    "plugins": [
      "expo-router",
      [
        "expo-notifications",
        {
          "icon": "./assets/images/notification-icon.png",
          "color": "#0ea5e9"
        }
      ],
      "expo-local-authentication",
      "expo-camera"
    ],
    "scheme": "algodon",
    "extra": {
      "eas": {
        "projectId": "your-project-id-here"
      }
    }
  }
}
'@

$mobileAppJson | Out-File -FilePath "mobile/app.json" -Encoding UTF8
Write-Host "✅ Created mobile/app.json" -ForegroundColor Green

# Generate mobile eas.json
$mobileEasJson = @'
{
  "cli": {
    "version": ">= 5.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "android": {
        "buildType": "apk"
      }
    },
    "production": {
      "autoIncrement": true
    }
  },
  "submit": {
    "production": {}
  }
}
'@

$mobileEasJson | Out-File -FilePath "mobile/eas.json" -Encoding UTF8
Write-Host "✅ Created mobile/eas.json" -ForegroundColor Green

# Generate shared types
$sharedTypesIndex = @'
export * from './user';
export * from './project';
export * from './subscription';
export * from './payment';
export * from './ai';
export * from './execution';
'@

$sharedTypesIndex | Out-File -FilePath "shared/types/index.ts" -Encoding UTF8

$sharedUserType = @'
export interface User {
  id: string;
  email: string;
  name: string | null;
  image: string | null;
  createdAt: Date;
  updatedAt: Date;
  role: 'user' | 'admin';
  subscriptionTier: 'free' | 'trial' | 'pro';
  subscriptionStatus: 'active' | 'cancelled' | 'expired';
  requestsUsed: number;
  requestsLimit: number;
  trialEndDate: Date | null;
}
'@

$sharedUserType | Out-File -FilePath "shared/types/user.ts" -Encoding UTF8

$sharedProjectType = @'
export interface Project {
  id: string;
  userId: string;
  name: string;
  description: string | null;
  language: string;
  isPublic: boolean;
  createdAt: Date;
  updatedAt: Date;
  lastExecutedAt: Date | null;
}

export interface ProjectFile {
  id: string;
  projectId: string;
  path: string;
  content: string;
  language: string;
  createdAt: Date;
  updatedAt: Date;
}
'@

$sharedProjectType | Out-File -FilePath "shared/types/project.ts" -Encoding UTF8

$sharedSubscriptionType = @'
export interface Subscription {
  id: string;
  userId: string;
  tier: 'free' | 'trial' | 'pro';
  status: 'active' | 'cancelled' | 'expired';
  trialStartDate: Date | null;
  trialEndDate: Date | null;
  subscriptionStartDate: Date | null;
  subscriptionEndDate: Date | null;
  paymentMethod: 'stripe' | 'square' | 'cashapp' | 'crypto' | 'web3' | null;
  stripeSubscriptionId: string | null;
  squareSubscriptionId: string | null;
  requestsUsed: number;
  requestsLimit: number;
  autoRenew: boolean;
  createdAt: Date;
  updatedAt: Date;
}
'@

$sharedSubscriptionType | Out-File -FilePath "shared/types/subscription.ts" -Encoding UTF8

$sharedPaymentType = @'
export interface Payment {
  id: string;
  userId: string;
  amount: number;
  currency: string;
  provider: 'stripe' | 'square' | 'cashapp' | 'crypto' | 'web3';
  status: 'pending' | 'completed' | 'failed' | 'refunded';
  transactionId: string | null;
  metadata: Record<string, any>;
  createdAt: Date;
  updatedAt: Date;
}
'@

$sharedPaymentType | Out-File -FilePath "shared/types/payment.ts" -Encoding UTF8

Write-Host "✅ Created shared types" -ForegroundColor Green

# Generate .gitignore
$gitignore = @'
# Dependencies
node_modules/
.pnp
.pnp.js

# Testing
coverage/
.nyc_output

# Next.js
.next/
out/
build/
dist/

# Production
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Mobile
.expo/
.expo-shared/
*.jks
*.p8
*.p12
*.key
*.mobileprovision
*.orig.*
web-build/

# Desktop
dist-electron/
*.dmg
*.exe
*.AppImage

# Database
*.db
*.sqlite

# Docker
.dockerignore

# Terraform
.terraform/
*.tfstate
*.tfstate.*

# Secrets
secrets/
*.pem
*.key
'@

$gitignore | Out-File -FilePath ".gitignore" -Encoding UTF8
Write-Host "✅ Created .gitignore" -ForegroundColor Green

# Generate README
$readme = @'
# ALGODON - Production-Ready Replit Clone

A comprehensive online code editor with AI assistance, real-time collaboration, and multi-platform support.

## 🚀 Features

- **50+ Programming Languages** - Full syntax highlighting and IntelliSense
- **AI-Powered Assistance** - GPT-4, Claude, Gemini integration
- **Real-time Collaboration** - Live code editing with multiple users
- **Multi-Platform** - Web, Mobile (iOS/Android), Desktop (Electron)
- **Payment Integration** - Stripe, Square, CashApp, Crypto, Web3
- **Enterprise Ready** - Oracle DB, Redis, Docker, Kubernetes

## 📦 Installation

1. Run the PowerShell setup scripts:
```powershell
.\part1-base-structure.ps1
.\part2-seo-marketing.ps1
.\part3-user-panel.ps1
.\part4-payments.ps1
.\part5-backend-ai.ps1
.\part6-deployment.ps1
```

2. Install dependencies:
```bash
npm install
cd web && npm install
cd ../mobile && npm install
cd ../desktop && npm install
```

3. Set up environment variables:
```bash
cp web/.env.example web/.env
# Edit web/.env with your API keys
```

4. Start development servers:
```bash
npm run dev
```

## 🏗️ Architecture

- **Web**: Next.js 14 (App Router) + TypeScript + Tailwind CSS
- **Mobile**: React Native + Expo SDK 50
- **Desktop**: Electron + Next.js
- **Backend**: Node.js/Express microservices
- **Database**: Oracle 21c (primary), Redis (cache), PostgreSQL (analytics)
- **Storage**: AWS S3 + CloudFront CDN

## 📝 License

Proprietary - All rights reserved
'@

$readme | Out-File -FilePath "README.md" -Encoding UTF8
Write-Host "✅ Created README.md" -ForegroundColor Green

Write-Host "`n✅ Part 1: Base Structure Complete!" -ForegroundColor Green
Write-Host "Next: Run .\part2-seo-marketing.ps1" -ForegroundColor Yellow

