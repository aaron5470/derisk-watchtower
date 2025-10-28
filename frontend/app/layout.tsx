import type { Metadata, Viewport } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import '@/lib/polyfills'
import { Providers } from '@/lib/providers'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'DeRisk Watchtower',
  description: 'Real-time monitoring and protection for DeFi lending positions',
  keywords: ['DeFi', 'lending', 'liquidation', 'protection', 'monitoring'],
  authors: [{ name: 'DeRisk Team' }],
}

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <Providers>
          {children}
        </Providers>
      </body>
    </html>
  )
}