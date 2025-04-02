"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import ParticleBackground from "../../components/ParticleBackground";

export default function LandingPage() {
  return (
    <main className="min-h-screen flex items-center justify-center px-6 relative border border-red-600" style={{ backgroundColor: 'var(--color-background)' }}>
      <motion.div
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, ease: "easeOut" }}
        className="max-w-2xl text-center z-10"
      >
        <motion.h1
          className="text-5xl sm:text-6xl font-bold mb-6"
          style={{ color: 'var(--color-text-base)', fontFamily: 'var(--font-sans)' }}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
        >
          YieldForge
        </motion.h1>

        <motion.p
          className="text-lg sm:text-xl mb-8"
          style={{ color: 'var(--color-text-muted)', fontFamily: 'var(--font-sans)' }}
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
        >
          Simplify DeFi yield. Permissionless vaults, strategy optimization, and user-defined automation — all in one modular protocol.
        </motion.p>

        <motion.div
          initial={{ scale: 0.95, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ delay: 0.6 }}
        >
          <Link href="/vaults">
            <div 
              className="inline-block px-6 py-3 font-medium text-lg rounded-xl transition cursor-pointer"
              style={{ 
                backgroundColor: 'var(--color-primary)', 
                color: 'var(--color-background)',
                fontFamily: 'var(--font-sans)'
              }}
            >
              🚀 Launch App
            </div>
          </Link>
        </motion.div>
      </motion.div>
      <ParticleBackground />
    </main>
  );
}
