import type { Metadata } from "next";
import { Space_Grotesk } from "next/font/google";
import "./globals.css";
import BodyWrapper from "../../components/BodyWrapper";

const spaceGrotesk = Space_Grotesk({
  subsets: ["latin"],
  variable: "--font-sans",
});

export const metadata: Metadata = {
  title: "YieldForge",
  description: "Simplify DeFi yield with permissionless vaults and strategy optimization",
};


export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${spaceGrotesk.variable} antialiased`}>
        <BodyWrapper>{children}</BodyWrapper>
      </body>
    </html>
  );
}
