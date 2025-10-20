// Polyfills for MetaMask SDK compatibility
if (typeof global === 'undefined') {
  (globalThis as any).global = globalThis
}

// Mock AsyncStorage for web environment
if (typeof window !== 'undefined') {
  (window as any).AsyncStorage = {
    getItem: (key: string) => Promise.resolve(localStorage.getItem(key)),
    setItem: (key: string, value: string) => Promise.resolve(localStorage.setItem(key, value)),
    removeItem: (key: string) => Promise.resolve(localStorage.removeItem(key)),
    clear: () => Promise.resolve(localStorage.clear()),
  }
}