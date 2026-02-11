'use client';

import { Code, Zap, Users, Globe, Shield, GitBranch } from 'lucide-react';
import { motion } from 'framer-motion';

const features = [
  {
    icon: Code,
    title: '50+ Languages',
    description: 'Full support for Python, JavaScript, TypeScript, Go, Rust, Java, C++, and more with syntax highlighting and IntelliSense.',
  },
  {
    icon: Zap,
    title: 'AI-Powered',
    description: 'Get intelligent code completion, explanations, and suggestions powered by GPT-4, Claude, and Gemini.',
  },
  {
    icon: Users,
    title: 'Real-time Collaboration',
    description: 'Code together with your team in real-time. See cursors, selections, and changes as they happen.',
  },
  {
    icon: Globe,
    title: 'Run Anywhere',
    description: 'Access your projects from web, mobile, or desktop. Your code syncs across all devices.',
  },
  {
    icon: Shield,
    title: 'Secure & Private',
    description: 'Enterprise-grade security with encrypted storage, private projects, and role-based access control.',
  },
  {
    icon: GitBranch,
    title: 'Git Integration',
    description: 'Connect to GitHub, GitLab, or Bitbucket. Commit, push, and pull without leaving the editor.',
  },
];

export function FeaturesGrid() {
  return (
    <section className="py-24 bg-white dark:bg-gray-900">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
            Everything You Need to Code
          </h2>
          <p className="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
            Powerful features designed for modern developers
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, index) => {
            const Icon = feature.icon;
            return (
              <motion.div
                key={feature.title}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className="p-6 rounded-xl border border-gray-200 dark:border-gray-800 bg-gray-50 dark:bg-gray-800/50 hover:border-primary-300 dark:hover:border-primary-700 transition"
              >
                <div className="w-12 h-12 rounded-lg bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center mb-4">
                  <Icon className="w-6 h-6 text-primary-600 dark:text-primary-400" />
                </div>
                <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                  {feature.title}
                </h3>
                <p className="text-gray-600 dark:text-gray-300">
                  {feature.description}
                </p>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
