
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import React, { ReactNode } from 'react';
import Head from 'next/head';

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Dermi Mirror",
};

const RootLayout: React.FC<{children: ReactNode}> = ({ children }) => (
  <html>
    <Head>
      <meta charSet="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <title>{ metadata.title?.toString() ?? 'Dermi Mirror' }</title>
    </Head>
    <body className="bg-black">
      {children}
    </body>
  </html>
);

export default RootLayout;
