"use client";

import Link from "next/link";

const mockVaults = [
  {
    id: "1",
    token: "USDC",
    strategy: "MockStrategy",
    tvl: "120,500",
    apy: "6.2%",
    creator: "0x98...a21f",
    platforms: ["Aave", "Compound"],
    address: "0xVault123...",
  },
  {
    id: "2",
    token: "DAI",
    strategy: "AutoCompounder",
    tvl: "82,300",
    apy: "4.9%",
    creator: "0x73...c19e",
    platforms: ["Lido", "Yearn"],
    address: "0xVault456...",
  },
];

export default function VaultsPage() {
  return (
    <div className="min-h-screen bg-background text-text-base px-4 py-8 font-sans">
      <div className="max-w-6xl mx-auto">
        <h1 className="text-3xl font-semibold text-white mb-6">
          Available Vaults
        </h1>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {mockVaults.map((vault) => (
            <div
              key={vault.id}
              className="bg-surface border border-border rounded-2xl p-5 shadow-card hover:shadow-lg transition"
            >
              <div className="text-xl font-medium text-white mb-2">
                {vault.token} Vault
              </div>
              <p className="text-sm text-text-muted">
                Strategy: {vault.strategy}
              </p>
              <p className="text-sm text-text-muted">APY: {vault.apy}</p>
              <p className="text-sm text-text-muted">TVL: ${vault.tvl}</p>
              <p className="text-sm text-text-muted">
                Creator: {vault.creator}
              </p>
              <p className="text-sm text-text-muted mb-4">
                Platforms:{" "}
                <span className="text-white">{vault.platforms.join(", ")}</span>
              </p>

              <Link
                href={`/vaults/${vault.id}`}
                className="inline-block px-4 py-2 rounded-xl text-sm font-medium bg-primary text-black hover:bg-emerald-400 transition"
              >
                View Vault
              </Link>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
