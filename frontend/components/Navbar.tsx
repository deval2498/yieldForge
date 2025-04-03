"use client";

import Link from "next/link";
import { useState } from "react";
import { useAccount, useConnect, useDisconnect } from "wagmi";
import { injected } from "wagmi/connectors";
import { Menu, Clipboard, CheckCircle2 } from "lucide-react";
import { AnimatePresence, motion } from "framer-motion";

export default function Navbar() {
  const { address, isConnected } = useAccount();
  const { connect } = useConnect();
  const { disconnect } = useDisconnect();
  const [open, setOpen] = useState(false);
  const [copied, setCopied] = useState(false);

  const shorten = (addr: string) => addr.slice(0, 6) + "..." + addr.slice(-4);

  const tabs = [
    { name: "Vaults", href: "/vaults" },
    { name: "Backtest", href: "/backtest" },
    { name: "Create Vault", href: "/create-vault" },
    { name: "Create Strategy", href: "/create-strategy" },
  ];

  const handleCopy = () => {
    if (!address) return;
    navigator.clipboard.writeText(address);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000); // Hide after 2 seconds
  };

  return (
    <nav className="w-full bg-background text-white px-4 py-3 font-sans relative z-50">
      <div className="max-w-7xl mx-auto flex justify-between items-center md:justify-between">
        {/* 👇 Mobile Layout Header */}
        <div className="flex w-full items-center justify-between md:hidden">
          {/* Menu Button on left */}
          <button className="text-gray-400" onClick={() => setOpen(!open)}>
            <Menu size={24} />
          </button>

          {/* Title in center */}
          <Link href="/" className="text-lg font-bold text-white">
            YieldForge
          </Link>

          {/* Connect Button on right */}
          <div className="flex gap-6 items-center text-xs">
            {isConnected && (
              <span
                onClick={handleCopy}
                className="cursor-pointer hover:text-primary"
              >
                {shorten(address!)}
              </span>
            )}
            <button
              onClick={() => {
                if (isConnected) disconnect();
                else connect({ connector: injected() });
              }}
              className="bg-primary text-black px-3 py-1 rounded-lg text-sm"
            >
              {isConnected ? "Disconnect" : "Connect"}
            </button>
          </div>
          {copied && (
            <AnimatePresence>
              {copied && (
                <motion.div
                  initial={{ opacity: 0, y: 30 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: 30 }}
                  transition={{ duration: 0.2, ease: "easeInOut" }}
                  className="fixed bottom-4 left-1/2 transform -translate-x-1/2 px-4 py-2 bg-surface text-white text-sm rounded-lg shadow-md z-50"
                >
                  Copied!
                </motion.div>
              )}
            </AnimatePresence>
          )}
        </div>

        {/* 👇 Desktop Tabs */}
        <div className="hidden md:flex gap-6 items-center w-full justify-between">
          <Link href="/" className="text-xl font-bold text-white">
            YieldForge
          </Link>

          <div className="flex gap-6 items-center">
            {tabs.map((tab) => (
              <Link
                key={tab.name}
                href={tab.href}
                className="hover:text-primary lg:text-sm md:text-xs"
              >
                {tab.name}
              </Link>
            ))}
          </div>
          <div className="flex gap-6 items-center lg:text-sm md:text-xs">
            {isConnected && (
              <div
                className="relative group cursor-pointer text-sm flex items-center gap-1 text-white"
                onClick={() => {
                  navigator.clipboard.writeText(address!);
                  setCopied(true);
                  setTimeout(() => setCopied(false), 2000);
                }}
              >
                <span className="hover:text-primary">{shorten(address!)}</span>

                {/* Icon container */}
                <span className="relative inline-block w-0 h-0">
                  {/* Clipboard icon on hover */}
                  {!copied && (
                    <Clipboard
                      size={16}
                      className="absolute -top-1 -left-1 transition-opacity duration-200 opacity-0 group-hover:opacity-100 text-[color:var(--color-text-muted)]"
                    />
                  )}

                  {/* Tick icon after copy */}
                  {copied && (
                    <CheckCircle2
                      size={16}
                      className="absolute -top-1 -left-1 text-primary"
                    />
                  )}
                </span>
              </div>
            )}
            <button
              onClick={() => {
                if (isConnected) disconnect();
                else connect({ connector: injected() });
              }}
              className="bg-primary text-black px-4 py-1.5 rounded-xl"
            >
              {isConnected ? "Disconnect Wallet" : "Connect Wallet"}
            </button>
          </div>
        </div>
      </div>

      {/* Backdrop */}
      {open && (
        <div
          className="fixed inset-0 bg-black/40 backdrop-blur z-40"
          onClick={() => setOpen(false)}
        />
      )}

      {/* Sliding Mobile Menu */}
      <div
        className={`fixed top-0 left-0 h-full w-1/2 bg-surface border-r border-border p-4 z-50 transition-transform duration-300 ease-in-out ${
          open ? "translate-x-0" : "-translate-x-full"
        } md:hidden`}
      >
        <div className="flex flex-col gap-4">
          {tabs.map((tab) => (
            <Link
              key={tab.name}
              href={tab.href}
              className="text-sm text-white hover:text-primary"
              onClick={() => setOpen(false)}
            >
              {tab.name}
            </Link>
          ))}
        </div>
      </div>
    </nav>
  );
}
