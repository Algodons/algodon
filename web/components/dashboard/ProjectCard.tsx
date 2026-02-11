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
