# ALGODON Part 3: User Panel with Request Tracking
# This script creates the complete user dashboard, request tracking system, and upgrade flows

Write-Host "🚀 ALGODON Part 3: User Panel" -ForegroundColor Cyan

Set-Location "ALGODON"

# Generate dashboard layout
$dashboardLayout = @'
import { ClerkProvider } from '@clerk/nextjs';
import { DashboardSidebar } from '@/components/dashboard/DashboardSidebar';
import { DashboardHeader } from '@/components/dashboard/DashboardHeader';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <ClerkProvider>
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
        <DashboardSidebar />
        <div className="lg:pl-64">
          <DashboardHeader />
          <main className="py-8">
            {children}
          </main>
        </div>
      </div>
    </ClerkProvider>
  );
}
'@

$dashboardLayout | Out-File -FilePath "web/app/(dashboard)/layout.tsx" -Encoding UTF8
Write-Host "✅ Created dashboard layout" -ForegroundColor Green

# Generate dashboard sidebar
$dashboardSidebar = @'
'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import {
  LayoutDashboard,
  FolderCode,
  Code,
  MessageSquare,
  BarChart3,
  CreditCard,
  Settings,
} from 'lucide-react';

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
  { name: 'Projects', href: '/dashboard/projects', icon: FolderCode },
  { name: 'Editor', href: '/dashboard/editor', icon: Code },
  { name: 'AI Chat', href: '/dashboard/ai-chat', icon: MessageSquare },
  { name: 'Usage', href: '/dashboard/usage', icon: BarChart3 },
  { name: 'Billing', href: '/dashboard/billing', icon: CreditCard },
  { name: 'Settings', href: '/dashboard/settings', icon: Settings },
];

export function DashboardSidebar() {
  const pathname = usePathname();

  return (
    <div className="hidden lg:fixed lg:inset-y-0 lg:flex lg:w-64 lg:flex-col">
      <div className="flex flex-col flex-grow bg-white dark:bg-gray-900 border-r border-gray-200 dark:border-gray-800">
        <div className="flex flex-col flex-grow pt-8 pb-4 overflow-y-auto">
          <div className="flex items-center flex-shrink-0 px-6 mb-8">
            <div className="w-8 h-8 bg-gradient-to-br from-primary-500 to-secondary-500 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold text-lg">A</span>
            </div>
            <span className="ml-2 text-xl font-bold bg-gradient-to-r from-primary-600 to-secondary-600 bg-clip-text text-transparent">
              ALGODON
            </span>
          </div>
          <nav className="flex-1 px-4 space-y-1">
            {navigation.map((item) => {
              const Icon = item.icon;
              const isActive = pathname === item.href || pathname?.startsWith(item.href + '/');
              return (
                <Link
                  key={item.name}
                  href={item.href}
                  className={cn(
                    'group flex items-center px-3 py-2 text-sm font-medium rounded-md transition',
                    isActive
                      ? 'bg-primary-50 text-primary-700 dark:bg-primary-900/30 dark:text-primary-400'
                      : 'text-gray-700 hover:bg-gray-50 hover:text-gray-900 dark:text-gray-300 dark:hover:bg-gray-800 dark:hover:text-white'
                  )}
                >
                  <Icon
                    className={cn(
                      'mr-3 flex-shrink-0 h-5 w-5',
                      isActive
                        ? 'text-primary-500 dark:text-primary-400'
                        : 'text-gray-400 group-hover:text-gray-500 dark:group-hover:text-gray-300'
                    )}
                  />
                  {item.name}
                </Link>
              );
            })}
          </nav>
        </div>
      </div>
    </div>
  );
}
'@

$dashboardSidebar | Out-File -FilePath "web/components/dashboard/DashboardSidebar.tsx" -Encoding UTF8

# Generate dashboard header with request counter
$dashboardHeader = @'
'use client';

import { useUser } from '@clerk/nextjs';
import { RequestCounter } from '@/components/dashboard/RequestCounter';
import { UserButton } from '@clerk/nextjs';

export function DashboardHeader() {
  const { user } = useUser();

  return (
    <header className="sticky top-0 z-40 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800">
      <div className="flex h-16 items-center justify-between px-4 sm:px-6 lg:px-8">
        <div className="flex items-center space-x-4">
          <RequestCounter />
        </div>
        <div className="flex items-center space-x-4">
          <UserButton afterSignOutUrl="/" />
        </div>
      </div>
    </header>
  );
}
'@

$dashboardHeader | Out-File -FilePath "web/components/dashboard/DashboardHeader.tsx" -Encoding UTF8

# Generate request counter component
$requestCounter = @'
'use client';

import { useEffect, useState } from 'react';
import { useUser } from '@clerk/nextjs';
import { AlertCircle } from 'lucide-react';
import { UpgradeModal } from '@/components/dashboard/UpgradeModal';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';

interface Subscription {
  tier: 'free' | 'trial' | 'pro';
  requestsUsed: number;
  requestsLimit: number;
  status: 'active' | 'cancelled' | 'expired';
  trialEndDate: string | null;
}

export function RequestCounter() {
  const { user } = useUser();
  const [subscription, setSubscription] = useState<Subscription | null>(null);
  const [showUpgrade, setShowUpgrade] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) return;

    const fetchSubscription = async () => {
      try {
        const response = await fetch('/api/subscription');
        if (response.ok) {
          const data = await response.json();
          setSubscription(data);
          
          // Show upgrade modal if free tier and limit reached
          if (data.tier === 'free' && data.requestsUsed >= data.requestsLimit) {
            setShowUpgrade(true);
          }
          
          // Show upgrade modal if trial expired
          if (data.tier === 'trial' && data.trialEndDate) {
            const trialEnd = new Date(data.trialEndDate);
            if (trialEnd < new Date() && data.status === 'expired') {
              setShowUpgrade(true);
            }
          }
        }
      } catch (error) {
        console.error('Failed to fetch subscription:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchSubscription();
    
    // Poll for updates every 30 seconds
    const interval = setInterval(fetchSubscription, 30000);
    return () => clearInterval(interval);
  }, [user]);

  if (loading || !subscription) {
    return (
      <div className="h-8 w-32 bg-gray-200 dark:bg-gray-700 rounded animate-pulse" />
    );
  }

  const percentage = (subscription.requestsUsed / subscription.requestsLimit) * 100;
  const isNearLimit = percentage >= 80;
  const isAtLimit = subscription.requestsUsed >= subscription.requestsLimit;

  return (
    <>
      <div
        className={cn(
          'flex items-center space-x-3 px-4 py-2 rounded-lg border',
          isAtLimit
            ? 'border-red-300 bg-red-50 dark:border-red-800 dark:bg-red-900/20'
            : isNearLimit
            ? 'border-yellow-300 bg-yellow-50 dark:border-yellow-800 dark:bg-yellow-900/20'
            : 'border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-800'
        )}
      >
        {isAtLimit && <AlertCircle className="w-4 h-4 text-red-600 dark:text-red-400" />}
        <div className="flex flex-col">
          <span className="text-xs text-gray-500 dark:text-gray-400">
            {subscription.tier === 'free' ? 'Free Requests' : 'Requests'}
          </span>
          <span
            className={cn(
              'text-sm font-semibold',
              isAtLimit
                ? 'text-red-600 dark:text-red-400'
                : isNearLimit
                ? 'text-yellow-600 dark:text-yellow-400'
                : 'text-gray-900 dark:text-white'
            )}
          >
            {subscription.requestsUsed} / {subscription.requestsLimit === Infinity ? '∞' : subscription.requestsLimit}
          </span>
        </div>
        {subscription.tier === 'free' && (
          <div className="w-24 h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
            <div
              className={cn(
                'h-full transition-all',
                isAtLimit
                  ? 'bg-red-500'
                  : isNearLimit
                  ? 'bg-yellow-500'
                  : 'bg-primary-500'
              )}
              style={{ width: `${Math.min(percentage, 100)}%` }}
            />
          </div>
        )}
        {isAtLimit && subscription.tier === 'free' && (
          <Button
            size="sm"
            onClick={() => setShowUpgrade(true)}
            className="ml-2"
          >
            Upgrade
          </Button>
        )}
      </div>

      {showUpgrade && (
        <UpgradeModal
          isOpen={showUpgrade}
          onClose={() => setShowUpgrade(false)}
          reason={isAtLimit ? 'limit_reached' : 'trial_expired'}
        />
      )}
    </>
  );
}
'@

$requestCounter | Out-File -FilePath "web/components/dashboard/RequestCounter.tsx" -Encoding UTF8

# Generate upgrade modal
$upgradeModal = @'
'use client';

import { useState } from 'react';
import { X, Check, Zap } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { PaymentModal } from '@/components/payments/PaymentModal';

interface UpgradeModalProps {
  isOpen: boolean;
  onClose: () => void;
  reason: 'limit_reached' | 'trial_expired';
}

export function UpgradeModal({ isOpen, onClose, reason }: UpgradeModalProps) {
  const [showPayment, setShowPayment] = useState(false);

  if (!isOpen) return null;

  const features = [
    'Unlimited code executions',
    'Unlimited AI assistance',
    'Priority support',
    'Advanced collaboration tools',
    'Private projects',
    'Custom domains',
    '100GB storage',
    'Git integration',
    'API access',
    'Advanced analytics',
  ];

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex min-h-screen items-center justify-center p-4">
        <div
          className="fixed inset-0 bg-black/50 transition-opacity"
          onClick={onClose}
        />
        <div className="relative bg-white dark:bg-gray-900 rounded-2xl shadow-xl max-w-2xl w-full p-8">
          <button
            onClick={onClose}
            className="absolute top-4 right-4 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
          >
            <X className="w-6 h-6" />
          </button>

          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary-100 dark:bg-primary-900/30 mb-4">
              <Zap className="w-8 h-8 text-primary-600 dark:text-primary-400" />
            </div>
            <h2 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
              {reason === 'limit_reached'
                ? "You've Used All 22 Free Requests! 🚀"
                : 'Your Trial Has Expired'}
            </h2>
            <p className="text-lg text-gray-600 dark:text-gray-300">
              {reason === 'limit_reached'
                ? 'Unlock unlimited coding power with ALGODON Pro'
                : 'Continue enjoying unlimited access with ALGODON Pro'}
            </p>
          </div>

          <div className="bg-gradient-to-br from-primary-50 to-secondary-50 dark:from-primary-900/20 dark:to-secondary-900/20 rounded-xl p-6 mb-6">
            <div className="text-center mb-4">
              <div className="text-4xl font-bold text-gray-900 dark:text-white mb-1">
                $19<span className="text-xl text-gray-600 dark:text-gray-400">/month</span>
              </div>
              <div className="text-sm text-gray-600 dark:text-gray-400">
                30-Day Trial • Cancel Anytime
              </div>
            </div>

            <ul className="space-y-3 mb-6">
              {features.map((feature) => (
                <li key={feature} className="flex items-start">
                  <Check className="w-5 h-5 text-primary-600 dark:text-primary-400 mr-3 flex-shrink-0 mt-0.5" />
                  <span className="text-gray-700 dark:text-gray-300">{feature}</span>
                </li>
              ))}
            </ul>

            <Button
              onClick={() => setShowPayment(true)}
              className="w-full"
              size="lg"
            >
              Start 30-Day Trial ($19/mo)
            </Button>
            <p className="text-center text-sm text-gray-500 dark:text-gray-400 mt-4">
              No long-term commitment. Cancel anytime.
            </p>
          </div>

          <div className="text-center">
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-2">
              We accept multiple payment methods:
            </p>
            <div className="flex items-center justify-center space-x-4 text-xs text-gray-500 dark:text-gray-500">
              <span>💳 Credit/Debit</span>
              <span>📱 Square</span>
              <span>💰 Cash App</span>
              <span>₿ Crypto</span>
              <span>🔷 Web3</span>
            </div>
          </div>
        </div>
      </div>

      {showPayment && (
        <PaymentModal
          isOpen={showPayment}
          onClose={() => setShowPayment(false)}
          plan="pro"
        />
      )}
    </div>
  );
}
'@

$upgradeModal | Out-File -FilePath "web/components/dashboard/UpgradeModal.tsx" -Encoding UTF8
Write-Host "✅ Created dashboard components" -ForegroundColor Green

# Generate dashboard home page
$dashboardPage = @'
'use client';

import { useEffect, useState } from 'react';
import { useUser } from '@clerk/nextjs';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Plus, FolderCode, Code, MessageSquare, ArrowRight } from 'lucide-react';
import { ProjectCard } from '@/components/dashboard/ProjectCard';

interface Project {
  id: string;
  name: string;
  language: string;
  updatedAt: string;
}

export default function DashboardPage() {
  const { user } = useUser();
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchProjects = async () => {
      try {
        const response = await fetch('/api/projects');
        if (response.ok) {
          const data = await response.json();
          setProjects(data.slice(0, 6)); // Show latest 6
        }
      } catch (error) {
        console.error('Failed to fetch projects:', error);
      } finally {
        setLoading(false);
      }
    };

    if (user) {
      fetchProjects();
    }
  }, [user]);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
          Welcome back{user?.firstName ? `, ${user.firstName}` : ''}!
        </h1>
        <p className="text-gray-600 dark:text-gray-300">
          Continue coding where you left off
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <Link href="/dashboard/projects">
          <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6 hover:border-primary-300 dark:hover:border-primary-700 transition cursor-pointer">
            <FolderCode className="w-8 h-8 text-primary-600 dark:text-primary-400 mb-3" />
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-1">
              My Projects
            </h3>
            <p className="text-sm text-gray-600 dark:text-gray-300">
              {loading ? 'Loading...' : `${projects.length} project${projects.length !== 1 ? 's' : ''}`}
            </p>
          </div>
        </Link>

        <Link href="/dashboard/editor">
          <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6 hover:border-primary-300 dark:hover:border-primary-700 transition cursor-pointer">
            <Code className="w-8 h-8 text-primary-600 dark:text-primary-400 mb-3" />
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-1">
              Code Editor
            </h3>
            <p className="text-sm text-gray-600 dark:text-gray-300">
              Start coding instantly
            </p>
          </div>
        </Link>

        <Link href="/dashboard/ai-chat">
          <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6 hover:border-primary-300 dark:hover:border-primary-700 transition cursor-pointer">
            <MessageSquare className="w-8 h-8 text-primary-600 dark:text-primary-400 mb-3" />
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-1">
              AI Assistant
            </h3>
            <p className="text-sm text-gray-600 dark:text-gray-300">
              Get help with your code
            </p>
          </div>
        </Link>
      </div>

      <div className="mb-6 flex items-center justify-between">
        <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
          Recent Projects
        </h2>
        <Link href="/dashboard/projects">
          <Button variant="outline">
            View All
            <ArrowRight className="ml-2 w-4 h-4" />
          </Button>
        </Link>
      </div>

      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {[1, 2, 3].map((i) => (
            <div
              key={i}
              className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6 animate-pulse"
            >
              <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-3/4 mb-2" />
              <div className="h-3 bg-gray-200 dark:bg-gray-700 rounded w-1/2" />
            </div>
          ))}
        </div>
      ) : projects.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {projects.map((project) => (
            <ProjectCard key={project.id} project={project} />
          ))}
        </div>
      ) : (
        <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-12 text-center">
          <FolderCode className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
            No projects yet
          </h3>
          <p className="text-gray-600 dark:text-gray-300 mb-6">
            Create your first project to get started
          </p>
          <Link href="/dashboard/projects/new">
            <Button>
              <Plus className="mr-2 w-4 h-4" />
              Create Project
            </Button>
          </Link>
        </div>
      )}
    </div>
  );
}
'@

$dashboardPage | Out-File -FilePath "web/app/(dashboard)/page.tsx" -Encoding UTF8

# Generate project card component
$projectCard = @'
import Link from 'next/link';
import { formatDate } from '@/lib/utils';
import { FolderCode } from 'lucide-react';

interface ProjectCardProps {
  project: {
    id: string;
    name: string;
    language: string;
    updatedAt: string;
  };
}

export function ProjectCard({ project }: ProjectCardProps) {
  return (
    <Link href={`/dashboard/projects/${project.id}`}>
      <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6 hover:border-primary-300 dark:hover:border-primary-700 transition cursor-pointer">
        <div className="flex items-start justify-between mb-4">
          <FolderCode className="w-8 h-8 text-primary-600 dark:text-primary-400" />
          <span className="text-xs px-2 py-1 rounded bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300">
            {project.language}
          </span>
        </div>
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
          {project.name}
        </h3>
        <p className="text-sm text-gray-500 dark:text-gray-400">
          Updated {formatDate(project.updatedAt)}
        </p>
      </div>
    </Link>
  );
}
'@

$projectCard | Out-File -FilePath "web/components/dashboard/ProjectCard.tsx" -Encoding UTF8

# Generate usage page
$usagePage = @'
'use client';

import { useEffect, useState } from 'react';
import { useUser } from '@clerk/nextjs';
import { RequestCounter } from '@/components/dashboard/RequestCounter';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, LineChart, Line } from 'recharts';
import { formatDate } from '@/lib/utils';

interface Request {
  id: string;
  type: string;
  timestamp: string;
  status: 'success' | 'failed';
}

interface UsageStats {
  total: number;
  byType: Record<string, number>;
  byDay: Array<{ date: string; count: number }>;
  recent: Request[];
}

export default function UsagePage() {
  const { user } = useUser();
  const [stats, setStats] = useState<UsageStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const response = await fetch('/api/usage/stats');
        if (response.ok) {
          const data = await response.json();
          setStats(data);
        }
      } catch (error) {
        console.error('Failed to fetch usage stats:', error);
      } finally {
        setLoading(false);
      }
    };

    if (user) {
      fetchStats();
    }
  }, [user]);

  if (loading) {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="animate-pulse space-y-4">
          <div className="h-8 bg-gray-200 dark:bg-gray-700 rounded w-1/4" />
          <div className="h-64 bg-gray-200 dark:bg-gray-700 rounded" />
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
          Usage & Analytics
        </h1>
        <p className="text-gray-600 dark:text-gray-300">
          Track your API usage and request history
        </p>
      </div>

      <div className="mb-8">
        <RequestCounter />
      </div>

      {stats && (
        <>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
              <h3 className="text-sm font-medium text-gray-500 dark:text-gray-400 mb-2">
                Total Requests
              </h3>
              <p className="text-3xl font-bold text-gray-900 dark:text-white">
                {stats.total}
              </p>
            </div>

            <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
              <h3 className="text-sm font-medium text-gray-500 dark:text-gray-400 mb-2">
                This Month
              </h3>
              <p className="text-3xl font-bold text-gray-900 dark:text-white">
                {stats.byDay.reduce((sum, day) => sum + day.count, 0)}
              </p>
            </div>

            <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
              <h3 className="text-sm font-medium text-gray-500 dark:text-gray-400 mb-2">
                Success Rate
              </h3>
              <p className="text-3xl font-bold text-gray-900 dark:text-white">
                {stats.recent.filter((r) => r.status === 'success').length > 0
                  ? Math.round(
                      (stats.recent.filter((r) => r.status === 'success').length /
                        stats.recent.length) *
                        100
                    )
                  : 0}
                %
              </p>
            </div>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
            <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                Requests by Type
              </h3>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={Object.entries(stats.byType).map(([type, count]) => ({ type, count }))}>
                  <XAxis dataKey="type" />
                  <YAxis />
                  <Tooltip />
                  <Bar dataKey="count" fill="#0ea5e9" />
                </BarChart>
              </ResponsiveContainer>
            </div>

            <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                Requests Over Time
              </h3>
              <ResponsiveContainer width="100%" height={300}>
                <LineChart data={stats.byDay}>
                  <XAxis dataKey="date" />
                  <YAxis />
                  <Tooltip />
                  <Line type="monotone" dataKey="count" stroke="#0ea5e9" strokeWidth={2} />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </div>

          <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
              Recent Requests
            </h3>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-gray-200 dark:border-gray-700">
                    <th className="text-left py-3 px-4 text-sm font-medium text-gray-500 dark:text-gray-400">
                      Type
                    </th>
                    <th className="text-left py-3 px-4 text-sm font-medium text-gray-500 dark:text-gray-400">
                      Date
                    </th>
                    <th className="text-left py-3 px-4 text-sm font-medium text-gray-500 dark:text-gray-400">
                      Status
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {stats.recent.map((request) => (
                    <tr
                      key={request.id}
                      className="border-b border-gray-100 dark:border-gray-800"
                    >
                      <td className="py-3 px-4 text-sm text-gray-900 dark:text-white">
                        {request.type}
                      </td>
                      <td className="py-3 px-4 text-sm text-gray-600 dark:text-gray-300">
                        {formatDate(request.timestamp)}
                      </td>
                      <td className="py-3 px-4">
                        <span
                          className={`inline-flex items-center px-2 py-1 rounded text-xs font-medium ${
                            request.status === 'success'
                              ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400'
                              : 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400'
                          }`}
                        >
                          {request.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
'@

$usagePage | Out-File -FilePath "web/app/(dashboard)/usage/page.tsx" -Encoding UTF8
Write-Host "✅ Created usage page" -ForegroundColor Green

# Generate subscription API route
$subscriptionApi = @'
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import { getDbConnection } from '@/lib/db/oracle';

export async function GET(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const connection = await getDbConnection();
    
    const result = await connection.execute(
      `SELECT 
        tier,
        status,
        requests_used,
        requests_limit,
        trial_end_date,
        subscription_end_date
      FROM subscriptions
      WHERE user_id = :userId`,
      { userId }
    );

    await connection.close();

    if (result.rows && result.rows.length > 0) {
      const row = result.rows[0] as any[];
      return NextResponse.json({
        tier: row[0],
        status: row[1],
        requestsUsed: row[2],
        requestsLimit: row[3] === -1 ? Infinity : row[3],
        trialEndDate: row[4]?.toISOString() || null,
        subscriptionEndDate: row[5]?.toISOString() || null,
      });
    }

    // Default free tier
    return NextResponse.json({
      tier: 'free',
      status: 'active',
      requestsUsed: 0,
      requestsLimit: 22,
      trialEndDate: null,
      subscriptionEndDate: null,
    });
  } catch (error) {
    console.error('Failed to fetch subscription:', error);
    return NextResponse.json(
      { error: 'Failed to fetch subscription' },
      { status: 500 }
    );
  }
}
'@

$subscriptionApi | Out-File -FilePath "web/app/api/subscription/route.ts" -Encoding UTF8

# Generate usage stats API route
$usageStatsApi = @'
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import { getDbConnection } from '@/lib/db/oracle';

export async function GET(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const connection = await getDbConnection();
    
    // Get total requests
    const totalResult = await connection.execute(
      `SELECT COUNT(*) as total FROM user_requests WHERE user_id = :userId`,
      { userId }
    );
    const total = (totalResult.rows?.[0] as any[])?.[0] || 0;

    // Get requests by type
    const byTypeResult = await connection.execute(
      `SELECT request_type, COUNT(*) as count 
       FROM user_requests 
       WHERE user_id = :userId 
       GROUP BY request_type`,
      { userId }
    );
    const byType: Record<string, number> = {};
    if (byTypeResult.rows) {
      for (const row of byTypeResult.rows) {
        const [type, count] = row as any[];
        byType[type] = count;
      }
    }

    // Get requests by day (last 30 days)
    const byDayResult = await connection.execute(
      `SELECT 
        TO_CHAR(timestamp, 'YYYY-MM-DD') as date,
        COUNT(*) as count
      FROM user_requests
      WHERE user_id = :userId 
        AND timestamp >= SYSDATE - 30
      GROUP BY TO_CHAR(timestamp, 'YYYY-MM-DD')
      ORDER BY date`,
      { userId }
    );
    const byDay = (byDayResult.rows || []).map((row: any[]) => ({
      date: row[0],
      count: row[1],
    }));

    // Get recent requests
    const recentResult = await connection.execute(
      `SELECT id, request_type, timestamp, status
       FROM user_requests
       WHERE user_id = :userId
       ORDER BY timestamp DESC
       FETCH FIRST 20 ROWS ONLY`,
      { userId }
    );
    const recent = (recentResult.rows || []).map((row: any[]) => ({
      id: row[0],
      type: row[1],
      timestamp: row[2]?.toISOString() || new Date().toISOString(),
      status: row[3] || 'success',
    }));

    await connection.close();

    return NextResponse.json({
      total,
      byType,
      byDay,
      recent,
    });
  } catch (error) {
    console.error('Failed to fetch usage stats:', error);
    return NextResponse.json(
      { error: 'Failed to fetch usage stats' },
      { status: 500 }
    );
  }
}
'@

$usageStatsApi | Out-File -FilePath "web/app/api/usage/stats/route.ts" -Encoding UTF8
Write-Host "✅ Created API routes" -ForegroundColor Green

Write-Host "`n✅ Part 3: User Panel Complete!" -ForegroundColor Green
Write-Host "Next: Run .\part4-payments.ps1" -ForegroundColor Yellow

