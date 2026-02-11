'use client';

import { motion } from 'framer-motion';

const stats = [
  { value: '100,000+', label: 'Active Developers' },
  { value: '1M+', label: 'Projects Created' },
  { value: '50+', label: 'Languages Supported' },
  { value: '99.9%', label: 'Uptime' },
];

const logos = [
  'TechCorp', 'StartupXYZ', 'DevStudio', 'CodeLab', 'BuildCo',
];

export function SocialProof() {
  return (
    <section className="py-16 bg-gray-50 dark:bg-gray-800/50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-12">
          <p className="text-sm font-semibold text-primary-600 dark:text-primary-400 uppercase tracking-wide mb-2">
            Trusted by Developers Worldwide
          </p>
          <h2 className="text-3xl font-bold text-gray-900 dark:text-white">
            Join 100,000+ developers building with ALGODON
          </h2>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-8 mb-16">
          {stats.map((stat, index) => (
            <motion.div
              key={stat.label}
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              className="text-center"
            >
              <div className="text-4xl md:text-5xl font-bold text-primary-600 dark:text-primary-400 mb-2">
                {stat.value}
              </div>
              <div className="text-gray-600 dark:text-gray-300">{stat.label}</div>
            </motion.div>
          ))}
        </div>

        <div className="flex flex-wrap items-center justify-center gap-8 opacity-60">
          {logos.map((logo) => (
            <div
              key={logo}
              className="text-2xl font-bold text-gray-400 dark:text-gray-600"
            >
              {logo}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
