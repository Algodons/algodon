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
