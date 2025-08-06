/**
 * Claude Terminal Bridge - Main Application Logic
 * Handles terminal communication, UI updates, and mobile optimizations
 */

class ClaudeTerminal {
    constructor() {
        // Core elements
        this.output = document.getElementById('terminal-output');
        this.input = document.getElementById('command-input');
        this.status = document.getElementById('status');
        this.container = document.getElementById('terminal-container');
        this.loadingIndicator = document.getElementById('loading-indicator');
        
        // State management
        this.lastContent = '';
        this.isPolling = false;
        this.currentFontSize = CONFIG.defaultFontSize;
        this.connectionAttempts = 0;
        this.isConnected = false;
        
        // Typing detection state
        this.isTyping = false;
        this.typingTimer = null;
        
        // Settings
        this.autoScroll = true;
        this.soundEnabled = false;
        
        // Initialize
        this.init();
    }
    
    /**
     * Initialize the application
     */
    init() {
        this.loadSettings();
        this.setupEventListeners();
        this.setupPolling();
        this.checkSystemCompatibility();
        
        // Initial status
        this.updateStatus('Connecting...', false);
        
        // Focus input
        this.focusInput();
        
        // Start polling for output
        this.startPolling();
        
        console.log('Claude Terminal initialized');
        console.log('Platform:', {
            isMobile: CONFIG.isMobile,
            isIOS: CONFIG.isIOS,
            isPWA: CONFIG.isPWA
        });
    }
    
    /**
     * Load settings from localStorage
     */
    loadSettings() {
        // Font size
        const savedFontSize = localStorage.getItem(CONFIG.storageKeys.fontSize);
        if (savedFontSize) {
            this.currentFontSize = parseInt(savedFontSize);
            this.output.style.fontSize = this.currentFontSize + 'px';
        }
        
        // Auto-scroll
        const savedAutoScroll = localStorage.getItem(CONFIG.storageKeys.autoScroll);
        if (savedAutoScroll !== null) {
            this.autoScroll = savedAutoScroll === 'true';
            const checkbox = document.getElementById('auto-scroll');
            if (checkbox) checkbox.checked = this.autoScroll;
        }
        
        // Sound
        const savedSound = localStorage.getItem(CONFIG.storageKeys.soundEnabled);
        if (savedSound !== null) {
            this.soundEnabled = savedSound === 'true';
            const checkbox = document.getElementById('sound-enabled');
            if (checkbox) checkbox.checked = this.soundEnabled;
        }
    }
    
    /**
     * Save settings to localStorage
     */
    saveSettings() {
        localStorage.setItem(CONFIG.storageKeys.fontSize, this.currentFontSize);
        localStorage.setItem(CONFIG.storageKeys.autoScroll, this.autoScroll);
        localStorage.setItem(CONFIG.storageKeys.soundEnabled, this.soundEnabled);
    }
    
    /**
     * Setup event listeners
     */
    setupEventListeners() {
        // Input handling with typing detection
        this.input.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                this.sendCommand();
                return;
            }
            
            // Don't mark as typing for certain keys
            if (e.key === 'Tab' || e.key === 'Escape' || e.key === 'F1' || 
                e.key === 'F2' || e.key === 'F3' || e.key === 'F4' || 
                e.key === 'F5' || e.key === 'F6' || e.key === 'F7' || 
                e.key === 'F8' || e.key === 'F9' || e.key === 'F10' || 
                e.key === 'F11' || e.key === 'F12' || e.ctrlKey || e.metaKey || e.altKey) {
                return;
            }
            
            // Mark as typing for other keys
            this.setTyping(true);
        });
        
        // Typing detection for input events (captures paste, etc.)
        this.input.addEventListener('input', () => {
            this.setTyping(true);
        });
        
        // When input loses focus, ensure typing flag is cleared
        this.input.addEventListener('blur', () => {
            this.setTyping(false);
            // Force an immediate poll to catch up
            setTimeout(() => this.pollOutput(), 100);
        });
        
        // Settings checkboxes
        const autoScrollCheckbox = document.getElementById('auto-scroll');
        if (autoScrollCheckbox) {
            autoScrollCheckbox.addEventListener('change', (e) => {
                this.autoScroll = e.target.checked;
                this.saveSettings();
            });
        }
        
        const soundCheckbox = document.getElementById('sound-enabled');
        if (soundCheckbox) {
            soundCheckbox.addEventListener('change', (e) => {
                this.soundEnabled = e.target.checked;
                this.saveSettings();
            });
        }
        
        // Selection change handling
        document.addEventListener('selectionchange', () => {
            this.handleSelectionChange();
        });
        
        // Mobile-specific optimizations
        if (CONFIG.isMobile) {
            this.setupMobileOptimizations();
        }
        
        // Visibility change (for PWA background handling)
        document.addEventListener('visibilitychange', () => {
            if (document.hidden) {
                this.pausePolling();
            } else {
                this.resumePolling();
            }
        });
        
        // Window focus/blur
        window.addEventListener('focus', () => this.resumePolling());
        window.addEventListener('blur', () => this.pausePolling());
    }
    
    /**
     * Setup mobile-specific optimizations
     */
    setupMobileOptimizations() {
        // Disable mouse wheel on mobile to prevent conflicts
        if (!CONFIG.isIOS) {
            this.container.addEventListener('wheel', function(e) {
                e.preventDefault();
                return false;
            }, { passive: false });
        }
        
        // Handle viewport changes
        if (CONFIG.isIOS) {
            window.addEventListener('orientationchange', () => {
                setTimeout(() => this.scrollToBottom(), 100);
            });
        }
        
        // Touch optimizations
        this.container.style.touchAction = 'pan-y';
        this.output.style.webkitUserSelect = 'text';
        this.output.style.webkitTouchCallout = 'default';
    }
    
    /**
     * Check system compatibility
     */
    checkSystemCompatibility() {
        const features = {
            fetch: typeof fetch !== 'undefined',
            localStorage: typeof localStorage !== 'undefined',
            requestAnimationFrame: typeof requestAnimationFrame !== 'undefined'
        };
        
        for (const [feature, supported] of Object.entries(features)) {
            if (!supported) {
                console.warn(`${feature} not supported`);
            }
        }
    }
    
    /**
     * Setup polling mechanism
     */
    setupPolling() {
        this.pollInterval = setInterval(() => {
            if (!this.isPolling && document.visibilityState === 'visible') {
                this.pollOutput();
            }
        }, CONFIG.pollInterval);
    }
    
    /**
     * Start polling for terminal output
     */
    startPolling() {
        this.pollOutput();
    }
    
    /**
     * Pause polling
     */
    pausePolling() {
        // Reduce polling frequency when not focused
        if (this.pollInterval) {
            clearInterval(this.pollInterval);
            this.pollInterval = setInterval(() => {
                if (!this.isPolling) {
                    this.pollOutput();
                }
            }, CONFIG.pollInterval * 4); // 4x slower when not focused
        }
    }
    
    /**
     * Resume normal polling
     */
    resumePolling() {
        if (this.pollInterval) {
            clearInterval(this.pollInterval);
            this.setupPolling();
        }
    }
    
    /**
     * Set typing state with timer management
     */
    setTyping(typing) {
        this.isTyping = typing;
        
        // Clear existing timer
        if (this.typingTimer) {
            clearTimeout(this.typingTimer);
            this.typingTimer = null;
        }
        
        if (typing) {
            // Set timer to reset typing flag after 1500ms of inactivity
            this.typingTimer = setTimeout(() => {
                this.isTyping = false;
                // Add small delay before resuming polling
                setTimeout(() => this.pollOutput(), 200);
            }, 1500);
        }
    }
    
    /**
     * Poll for terminal output with typing detection
     */
    async pollOutput() {
        if (this.isPolling) return;
        
        // Skip polling only if actively typing
        if (this.isTyping) {
            return;
        }
        
        this.isPolling = true;
        
        try {
            const response = await fetch(CONFIG.endpoints.output, {
                method: 'GET',
                timeout: CONFIG.connectionTimeout
            });
            
            if (response.ok) {
                const data = await response.json();
                
                if (data.output && data.output !== this.lastContent) {
                    this.updateTerminalOutput(data.output);
                }
                
                this.updateStatus('Connected', true);
                this.connectionAttempts = 0;
                this.isConnected = true;
            } else {
                throw new Error(`HTTP ${response.status}`);
            }
        } catch (error) {
            console.error('Poll error:', error);
            this.handleConnectionError(error);
        } finally {
            this.isPolling = false;
        }
    }
    
    /**
     * Update terminal output
     */
    updateTerminalOutput(rawOutput) {
        // Check if user is selecting text
        const selection = window.getSelection();
        const hasSelection = selection && selection.toString().length > 0;
        
        // Save scroll position
        const wasAtBottom = this.isScrolledToBottom();
        const currentScroll = this.container.scrollTop;
        
        // Filter Claude UI elements
        let filteredOutput = this.filterClaudeUI(rawOutput);
        
        // Parse ANSI codes
        let parsedContent = ansiParser.parse(filteredOutput);
        
        // Only update if not selecting text
        if (!hasSelection) {
            requestAnimationFrame(() => {
                this.output.innerHTML = parsedContent;
                this.lastContent = rawOutput;
                
                // Restore scroll position
                if (this.autoScroll && wasAtBottom) {
                    this.scrollToBottom();
                } else {
                    this.container.scrollTop = currentScroll;
                }
            });
        } else {
            // Just update the stored content
            this.lastContent = rawOutput;
        }
    }
    
    /**
     * Filter out Claude's UI elements
     */
    filterClaudeUI(output) {
        if (!output) return output;
        
        // Remove Claude's input box UI
        let filtered = output.replace(/╭─+╮\s*\n│[^│]*│\s*\n╰─+╯/g, '');
        filtered = filtered.replace(/^│\s*>\s*│$/gm, '');
        
        return filtered;
    }
    
    /**
     * Check if scrolled to bottom
     */
    isScrolledToBottom() {
        const threshold = CONFIG.scrollThreshold;
        return this.container.scrollTop + this.container.clientHeight >= 
               this.container.scrollHeight - threshold;
    }
    
    /**
     * Scroll to bottom of terminal
     */
    scrollToBottom() {
        this.container.scrollTop = this.container.scrollHeight;
    }
    
    /**
     * Handle selection changes
     */
    handleSelectionChange() {
        const selection = window.getSelection();
        if (!selection || selection.toString().length === 0) {
            // Selection cleared, resume updates if needed
            this.lastContent = '';
        }
    }
    
    /**
     * Send command to terminal
     */
    async sendCommand() {
        const command = this.input.value.trim();
        if (!command) return;
        
        try {
            this.showLoading(true);
            
            const response = await fetch(CONFIG.endpoints.send, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ command }),
                timeout: CONFIG.connectionTimeout
            });
            
            if (response.ok) {
                this.input.value = '';
                this.focusInput();
                console.log('Command sent:', command.substring(0, 50) + '...');
            } else {
                throw new Error(`HTTP ${response.status}`);
            }
        } catch (error) {
            console.error('Send error:', error);
            this.showToast('Failed to send command', 'error');
        } finally {
            this.showLoading(false);
        }
    }
    
    /**
     * Send ESC key
     */
    async sendEscape() {
        try {
            const response = await fetch(CONFIG.endpoints.send, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ command: '\x1b' }),
                timeout: CONFIG.connectionTimeout
            });
            
            if (response.ok) {
                // Visual feedback
                const escButton = document.querySelector('.escape-btn');
                if (escButton) {
                    escButton.style.background = '#a02030';
                    setTimeout(() => {
                        escButton.style.background = '#dc3545';
                    }, 200);
                }
                console.log('ESC sent');
            }
        } catch (error) {
            console.error('Send escape error:', error);
        }
    }
    
    /**
     * Adjust font size
     */
    adjustFontSize(delta) {
        const newSize = Math.max(
            CONFIG.minFontSize, 
            Math.min(CONFIG.maxFontSize, this.currentFontSize + delta)
        );
        
        if (newSize !== this.currentFontSize) {
            this.currentFontSize = newSize;
            this.output.style.fontSize = this.currentFontSize + 'px';
            this.saveSettings();
            
            console.log('Font size changed to:', this.currentFontSize);
        }
    }
    
    /**
     * Update connection status
     */
    updateStatus(message, connected) {
        this.status.textContent = message;
        this.status.classList.toggle('connected', connected);
        this.status.classList.toggle('error', !connected);
        this.isConnected = connected;
    }
    
    /**
     * Handle connection errors
     */
    handleConnectionError(error) {
        this.connectionAttempts++;
        
        if (this.connectionAttempts <= CONFIG.maxRetries) {
            this.updateStatus('Reconnecting...', false);
            this.showToast('Connection lost, retrying...', 'warning');
        } else {
            this.updateStatus('Disconnected', false);
            this.showToast('Failed to connect to server', 'error');
        }
        
        this.isConnected = false;
    }
    
    /**
     * Show loading indicator
     */
    showLoading(show) {
        if (this.loadingIndicator) {
            this.loadingIndicator.classList.toggle('hidden', !show);
        }
    }
    
    /**
     * Show toast message
     */
    showToast(message, type = 'info') {
        const toast = document.getElementById('connection-toast');
        const messageEl = document.getElementById('toast-message');
        
        if (toast && messageEl) {
            messageEl.textContent = message;
            toast.className = `toast-${type}`;
            toast.classList.remove('hidden');
            
            setTimeout(() => {
                toast.classList.add('hidden');
            }, CONFIG.toastDuration);
        }
        
        console.log(`Toast (${type}):`, message);
    }
    
    /**
     * Focus input field
     */
    focusInput() {
        // Small delay to ensure proper focus on mobile
        setTimeout(() => {
            this.input.focus();
        }, 100);
    }
    
    /**
     * Restart Claude session
     */
    async restartSession() {
        try {
            this.showLoading(true);
            this.updateStatus('Restarting...', false);
            
            const response = await fetch(CONFIG.endpoints.restart, {
                method: 'POST',
                timeout: CONFIG.connectionTimeout
            });
            
            if (response.ok) {
                this.showToast('Session restarted successfully', 'success');
                this.lastContent = '';
                this.connectionAttempts = 0;
            } else {
                throw new Error(`HTTP ${response.status}`);
            }
        } catch (error) {
            console.error('Restart error:', error);
            this.showToast('Failed to restart session', 'error');
        } finally {
            this.showLoading(false);
        }
    }
    
    /**
     * Clear terminal display (local only)
     */
    clearTerminal() {
        this.output.innerHTML = '';
        this.lastContent = '';
        this.showToast('Terminal cleared', 'info');
    }
    
    /**
     * Get session status
     */
    async getSessionStatus() {
        try {
            const response = await fetch(CONFIG.endpoints.status);
            
            if (response.ok) {
                const data = await response.json();
                const status = data.session_exists ? 'Active' : 'Inactive';
                this.showToast(`Session status: ${status}`, 'info');
                console.log('Session status:', data);
            }
        } catch (error) {
            console.error('Status error:', error);
            this.showToast('Failed to get session status', 'error');
        }
    }
}

// Menu functions (global scope for HTML onclick handlers)
function openMenu() {
    const overlay = document.getElementById('menu-overlay');
    const menu = document.getElementById('side-menu');
    
    overlay.classList.add('active');
    menu.classList.add('active');
}

function closeMenu() {
    const overlay = document.getElementById('menu-overlay');
    const menu = document.getElementById('side-menu');
    
    overlay.classList.remove('active');
    menu.classList.remove('active');
}

// Global function handlers for HTML
function sendCommand() {
    terminal.sendCommand();
}

function sendEscape() {
    terminal.sendEscape();
}

function adjustFontSize(delta) {
    terminal.adjustFontSize(delta);
}

function restartSession() {
    terminal.restartSession();
    closeMenu();
}

function clearTerminal() {
    terminal.clearTerminal();
    closeMenu();
}

function getSessionStatus() {
    terminal.getSessionStatus();
    closeMenu();
}

// Initialize application when DOM is ready
let terminal;

document.addEventListener('DOMContentLoaded', function() {
    terminal = new ClaudeTerminal();
});

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { ClaudeTerminal };
}
