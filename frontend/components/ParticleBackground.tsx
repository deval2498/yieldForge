"use client";

import { motion } from "framer-motion";
import { useState, useEffect } from "react";

export default function ParticleBackground() {
  const [particles, setParticles] = useState<Array<{
    size: number;
    x: number;
    y: number;
    delay: number;
    duration: number;
  }>>([]);

  // Generate particles only on the client side
  useEffect(() => {
    const particleCount = 50;
    const newParticles = Array.from({ length: particleCount }, () => ({
      size: Math.random() * 6 + 2,
      x: Math.random() * 100,
      y: Math.random() * 100,
      delay: Math.random() * 5,
      duration: Math.random() * 10 + 8,
    }));
    
    setParticles(newParticles);
  }, []);

  // Don't render anything until particles are generated on the client
  if (particles.length === 0) {
    return null;
  }

  return (
    <div className="absolute inset-0 z-0 overflow-hidden border border-blue-600">
      {particles.map((particle, i) => (
        <motion.div
          key={i}
          className="absolute bg-white rounded-full"
          style={{
            width: particle.size,
            height: particle.size,
            top: `${particle.y}%`,
            left: `${particle.x}%`,
            zIndex: 0,
          }}
          animate={{
            y: [-10, -200],
            opacity: [0, 0.4, 0],
          }}
          transition={{
            repeat: Infinity,
            duration: particle.duration,
            delay: particle.delay,
            ease: "easeInOut",
          }}
        />
      ))}
    </div>
  );
}
