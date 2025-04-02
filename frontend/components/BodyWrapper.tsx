"use client"
import { usePathname } from "next/navigation"
import Navbar from "./Navbar"
import { WagmiProvider } from 'wagmi'
import { config } from "../configs/wagmiConfig"
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

export default function BodyWrapper({children} : {children: React.ReactNode}) {
    const pathname = usePathname()
    const showNavbar = pathname !== "/"
    return (
        <>
            <WagmiProvider config={config}>
                <QueryClientProvider client={new QueryClient()}>
                    {showNavbar && <Navbar />}
                    {children}
                </QueryClientProvider>
            </WagmiProvider>
        </>
    )
}