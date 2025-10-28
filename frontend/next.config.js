/** @type {import('next').NextConfig} */
const nextConfig = {
  webpack: (config) => {
    config.resolve.fallback = { 
      fs: false, 
      net: false, 
      tls: false,
      '@react-native-async-storage/async-storage': false,
      'react-native-url-polyfill': false,
    };
    config.externals.push('pino-pretty', 'lokijs', 'encoding');
    
    // Add alias for React Native modules
    config.resolve.alias = {
      ...config.resolve.alias,
      '@react-native-async-storage/async-storage': false,
      'react-native-url-polyfill': false,
    };
    
    return config;
  },
};

module.exports = nextConfig;