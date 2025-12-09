'use client';

import { Play } from 'lucide-react';
import { useState } from 'react';

export function DemoVideo() {
  const [playing, setPlaying] = useState(false);

  return (
    <section className="py-24 bg-white dark:bg-gray-900">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-12">
          <h2 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
            See ALGODON in Action
          </h2>
          <p className="text-xl text-gray-600 dark:text-gray-300">
            Watch how easy it is to code, collaborate, and deploy
          </p>
        </div>

        <div className="relative aspect-video rounded-2xl overflow-hidden shadow-2xl bg-gray-900">
          {!playing ? (
            <div className="absolute inset-0 flex items-center justify-center">
              <button
                onClick={() => setPlaying(true)}
                className="w-20 h-20 rounded-full bg-primary-600 hover:bg-primary-700 flex items-center justify-center transition"
                aria-label="Play video"
              >
                <Play className="w-10 h-10 text-white ml-1" fill="white" />
              </button>
            </div>
          ) : (
            <iframe
              className="w-full h-full"
              src="https://www.youtube.com/embed/dQw4w9WgXcQ?autoplay=1"
              title="ALGODON Demo"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowFullScreen
            />
          )}
        </div>
      </div>
    </section>
  );
}
