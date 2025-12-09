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
