"use client";

import Link from "next/link";
import { useState } from "react";
import { useAccount, useConnect, useDisconnect } from "wagmi";
import { injected } from 'wagmi/connectors'
import { Menu } from "lucide-react";

export default function Navbar() {
  const { address, isConnected } = useAccount();
  const { connect } = useConnect();
  const { disconnect } = useDisconnect();
  const [open, setOpen] = useState(false);

  const shorten = (addr: string) =>
    addr.slice(0, 6) + "..." + addr.slice(-4);

  const tabs = [
    { name: "Vaults", href: "/vaults" },
    { name: "Backtest", href: "/backtest" },
    { name: "Create Vault", href: "/create-vault" },
    { name: "Create Strategy", href: "/create-strategy" },
  ];

  return (
    <nav className="w-full bg-background text-white px-4 py-3 font-sans">
      <div className="max-w-7xl mx-auto flex justify-between items-center">
        <Link href="/" className="text-xl font-bold text-white">YieldForge</Link>

        {/* Desktop Tabs */}
        <div className="hidden sm:flex gap-6 items-center">
          {tabs.map(tab => (
            <Link key={tab.name} href={tab.href} className="hover:text-primary text-sm">
              {tab.name}
            </Link>
          ))}
          <button
            onClick={() => (isConnected ? disconnect() : connect({ connector: injected()}))}
            className="bg-primary text-black px-4 py-1.5 rounded-xl text-sm"
          >
            {isConnected ? shorten(address!) : "Connect Wallet"}
          </button>
        </div>

        {/* Mobile Menu Icon */}
        <button
          className="sm:hidden text-gray-400"
          onClick={() => setOpen(!open)}
        >
          <Menu size={24}/>
        </button>
      </div>

      {/* Mobile Dropdown */}
      {open && (
        <div className="md:hidden mt-2 flex flex-col gap-3 px-2 border">
          {tabs.map(tab => (
            <Link key={tab.name} href={tab.href} className="text-sm text-white hover:text-primary">
              {tab.name}
            </Link>
          ))}
          <button
            onClick={() => (isConnected ? disconnect() : connect({connector: injected()}))}
            className="bg-primary text-black px-4 py-1.5 rounded-xl text-sm w-fit"
          >
            {isConnected ? shorten(address!) : "Connect Wallet"}
          </button>
        </div>
      )}
    </nav>
  );
}
