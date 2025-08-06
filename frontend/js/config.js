/**
 * Configuration settings for Claude Terminal Bridge
 */

const CONFIG = {
    // Terminal update frequency (milliseconds)
    pollInterval: 500,
    
    // Font size settings
    maxFontSize: 32,
    minFontSize: 8,
    defaultFontSize: 14,
    
    // Scrolling behavior
    scrollThreshold: 10,        // Pixels from bottom to trigger auto-scroll
    
    // Performance settings
    maxOutputSize: 1048576,     // 1MB max terminal output
    updateDebounce: 50,         // Debounce DOM updates
    
    // Connection settings
    connectionTimeout: 10000,   // 10 second timeout for API calls
    retryDelay: 2000,          // Delay between connection retries
    maxRetries: 3,             // Maximum connection retry attempts
    
    // UI settings
    toastDuration: 3000,       // Duration to show toast messages
    menuAnimationDuration: 300, // Menu slide animation duration
    
    // ANSI parsing settings
    maxAnsiColors: 256,        // Support for 256-color ANSI
    preserveFormatting: true,  // Preserve ANSI formatting
    
    // Mobile detection
    isMobile: /iPhone|iPad|iPod|Android/i.test(navigator.userAgent),
    isIOS: /iPhone|iPad|iPod/i.test(navigator.userAgent),
    isPWA: window.navigator.standalone || 
           window.matchMedia('(display-mode: standalone)').matches ||
           window.matchMedia('(display-mode: fullscreen)').matches,
    
    // Storage keys
    storageKeys: {
        fontSize: 'claude-terminal-font-size',
        autoScroll: 'claude-terminal-auto-scroll',
        soundEnabled: 'claude-terminal-sound-enabled'
    },
    
    // API endpoints
    endpoints: {
        send: '/api/terminal/claude/send',
        output: '/api/terminal/claude/output',
        status: '/api/terminal/claude/status',
        restart: '/api/terminal/claude/restart'
    }
};

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = CONFIG;
}
