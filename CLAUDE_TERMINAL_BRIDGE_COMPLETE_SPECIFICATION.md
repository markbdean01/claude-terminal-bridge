# Claude Terminal Bridge - Complete Feature Specification

## Overview

The Claude Terminal Bridge is a web-based terminal interface that provides real-time interaction with Claude Code running in a tmux session. It's designed to work seamlessly across desktop browsers and mobile devices (especially iPhone PWA), offering a native terminal-like experience with modern web conveniences.

## Recent Updates (2025-08-06)

### VS Code Default Light Modern Theme Implementation
- Full light theme support with CSS variables
- Custom terminal colors (white background, black text)
- Professional UI matching VS Code's design language

### Typing Performance Optimization
- Advanced typing detection to prevent polling lag
- 1.5 second timeout for natural typing pauses
- 200ms debounce delay before polling resumes
- Separate handling for control keys and special characters

## Architecture

### Backend Components

#### 1. Tmux Session Management
- **Session Name**: `claude-session`
- **Auto-creation**: If the session doesn't exist, it's automatically created
- **Claude Command**: `claude -c --dangerously-skip-permissions`
- **History Limit**: 50,000 lines configured in tmux
- **Scrollback Capture**: 5,000 lines retrieved per API call

#### 2. Flask API Endpoints

**Send Command Endpoint**
- **Route**: `/api/terminal/claude/send`
- **Method**: POST
- **Payload**: `{ "command": "string" }`
- **Special Handling**:
  - ESC character (`\x1b`) sends tmux "Escape" command
  - Regular commands are sent with `-l` flag to preserve literals
  - Automatically appends Enter key after command

**Get Output Endpoint**
- **Route**: `/api/terminal/claude/output`
- **Method**: GET
- **Response**: 
  ```json
  {
    "status": "success",
    "output": "terminal content with ANSI codes",
    "timestamp": 1234567890.123
  }
  ```
- **tmux Command**: `tmux capture-pane -t claude-session -p -e -S -5000`
  - `-p`: Print to stdout
  - `-e`: Preserve ANSI escape sequences
  - `-S -5000`: Capture 5000 lines of scrollback

#### 3. Script for Session Creation

Create a script at `/home/njord/njordviam/scripts/ttyd-tmux-simple.sh`:

```bash
#!/bin/bash
SESSION_NAME="claude-session"

# Check if session exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    # Attach to existing session
    exec tmux attach-session -t "$SESSION_NAME"
else
    # Create new session and start claude with skip permissions flag
    exec tmux new-session -s "$SESSION_NAME" -n "claude" "claude -c --dangerously-skip-permissions"
fi
```

### Frontend Components

#### 1. CSS Variables for Theme Support

```css
/* VS Code Default Light Modern Theme Colors */
:root {
    /* Terminal Colors (Custom Settings) */
    --terminal-background: #ffffff; /* White background */
    --terminal-foreground: #000000; /* Black text */
    --terminal-ansi-black: #000000; /* Pure black */
    --terminal-ansi-white: #ffffff; /* Pure white */
    --terminal-ansi-bright-black: #666666; /* Dark gray */
    --terminal-ansi-bright-white: #cccccc; /* Light gray */

    /* Default Light Modern Theme Colors */
    --background: #ffffff; /* Main background */
    --foreground: #000000; /* Primary text */
    --secondary-foreground: #616161; /* Secondary text */
    --border: #e5e5e5; /* Borders */
    --hover: #f3f3f3; /* Hover states */
    --selection: #0078d4; /* Selection blue */
    --selection-background: #e3f2fd; /* Selection background */

    /* Status Colors */
    --success: #16a085; /* Success green */
    --warning: #f39c12; /* Warning orange */
    --error: #e74c3c; /* Error red */
    --info: #3498db; /* Info blue */

    /* UI Elements */
    --button-primary: #0078d4; /* Primary button */
    --button-primary-hover: #106ebe; /* Primary button hover */
    --button-secondary: #f3f3f3; /* Secondary button */
    --input-background: #ffffff; /* Input fields */
    --input-border: #cccccc; /* Input borders */
    --scrollbar: #c1c1c1; /* Scrollbars */
}
```

#### 2. HTML Structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <title>Claude Code Terminal</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <!-- Header with menu button, title, font controls, and status -->
    <div id="header">
        <div style="display: flex; align-items: center; gap: 10px;">
            <button class="menu-btn" onclick="openMenu()">
                <i class="fas fa-bars"></i>
            </button>
            <div>Claude Code Terminal</div>
        </div>
        <div style="display: flex; gap: 10px; align-items: center;">
            <button onclick="adjustFontSize(-1)">A-</button>
            <button onclick="adjustFontSize(1)">A+</button>
            <div class="status" id="status">Connecting...</div>
        </div>
    </div>
    
    <!-- Terminal output container -->
    <div id="terminal-container">
        <div id="terminal-output"></div>
    </div>
    
    <!-- Input controls -->
    <div id="input-container">
        <input type="text" id="command-input" placeholder="Message Claude..." 
               autocomplete="off" autocorrect="off" autocapitalize="off" 
               spellcheck="false" enterkeyhint="send">
        <button onclick="sendEscape()" style="background: #dc3545;">ESC</button>
        <button onclick="sendCommand()">Send</button>
    </div>
    
    <!-- Side drawer menu (hidden by default) -->
    <div id="menu-overlay" onclick="closeMenu()"></div>
    <nav id="side-menu">
        <!-- Navigation links here -->
    </nav>
</body>
</html>
```

#### 2. CSS Styling with Theme Support

```css
/* Core layout using CSS variables */
body {
    background: var(--background);
    color: var(--foreground);
    font-family: 'Consolas', 'Courier New', monospace;
    height: 100vh;
    height: -webkit-fill-available; /* PWA fix for iPhone */
    max-height: -webkit-fill-available;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    position: fixed; /* PWA fix */
    width: 100%;
    top: 0;
    left: 0;
}

/* Header styling with theme variables */
#header {
    background: var(--hover);
    padding: 8px 16px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid var(--border);
    font-size: 12px;
    color: var(--secondary-foreground);
    gap: 10px;
}

/* Terminal container with proper scrolling */
#terminal-container {
    flex: 1;
    background: var(--terminal-background);
    position: relative;
    overflow-y: scroll;
    overflow-x: hidden;
    -webkit-overflow-scrolling: touch;
    min-height: 0;
    border-left: 1px solid var(--border);
    border-right: 1px solid var(--border);
}

/* VS Code style scrollbars */
#terminal-container::-webkit-scrollbar {
    width: 12px;
    background: var(--background);
}

#terminal-container::-webkit-scrollbar-thumb {
    background: var(--scrollbar);
    border-radius: 6px;
}

#terminal-container::-webkit-scrollbar-thumb:hover {
    background: #999999;
}

/* Terminal output with theme colors */
#terminal-output {
    padding: 16px;
    font-family: 'Consolas', 'Courier New', monospace;
    font-size: 14px;
    line-height: 1.4;
    -webkit-user-select: text !important;
    user-select: text !important;
    -webkit-touch-callout: default !important;
    white-space: pre-wrap;
    word-wrap: break-word;
    background: var(--terminal-background);
    color: var(--terminal-foreground);
}

/* Input container with theme styling */
#input-container {
    background: var(--background);
    padding: 12px 16px;
    padding-bottom: calc(12px + env(safe-area-inset-bottom, 0));
    display: flex;
    gap: 8px;
    border-top: 1px solid var(--border);
    align-items: center;
    min-height: 56px;
}

/* Input field styling */
input {
    flex: 1;
    background: var(--input-background);
    color: var(--terminal-foreground);
    border: 1px solid var(--input-border);
    padding: 8px 12px;
    border-radius: 4px;
    font-family: 'Consolas', 'Courier New', monospace;
    font-size: 14px;
    height: 36px;
    line-height: 1;
    transition: border-color 0.2s;
}

input:focus {
    outline: none;
    border-color: var(--selection);
}

/* Button styling */
button {
    background: var(--button-primary);
    color: #ffffff;
    border: none;
    padding: 8px 16px;
    border-radius: 4px;
    font-weight: 500;
    cursor: pointer;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    font-size: 14px;
    transition: background-color 0.2s;
}

button:hover {
    background: var(--button-primary-hover);
}

/* ANSI color classes for light theme */
.ansi-black { color: var(--terminal-ansi-black); }
.ansi-red { color: #cd3131; }
.ansi-green { color: #00bc00; }
.ansi-yellow { color: #949800; }
.ansi-blue { color: #0451a5; }
.ansi-magenta { color: #bc05bc; }
.ansi-cyan { color: #0598bc; }
.ansi-white { color: var(--terminal-ansi-white); }
.ansi-bright-black { color: var(--terminal-ansi-bright-black); }
.ansi-bright-red { color: #f14c4c; }
.ansi-bright-green { color: #00c900; }
.ansi-bright-yellow { color: #a8a800; }
.ansi-bright-blue { color: #0067c7; }
.ansi-bright-magenta { color: #d670d6; }
.ansi-bright-cyan { color: #06b6d4; }
.ansi-bright-white { color: var(--terminal-ansi-bright-white); }
```

#### 3. JavaScript Implementation with Typing Detection

```javascript
// Core variables
const output = document.getElementById('terminal-output');
const input = document.getElementById('command-input');
const status = document.getElementById('status');
let lastContent = '';
let isPolling = false;
let currentFontSize = 12;
let isTyping = false;
let typingTimer = null;

// Browser detection
const isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
const isIOS = /iPhone|iPad|iPod/i.test(navigator.userAgent);
const isPWA = window.navigator.standalone || window.matchMedia('(display-mode: standalone)').matches;

// Font size management
function adjustFontSize(delta) {
    currentFontSize = Math.max(8, Math.min(32, currentFontSize + delta));
    output.style.fontSize = currentFontSize + 'px';
    localStorage.setItem('terminal-font-size', currentFontSize);
}

// Load saved font size
const savedFontSize = localStorage.getItem('terminal-font-size');
if (savedFontSize) {
    currentFontSize = parseInt(savedFontSize);
    output.style.fontSize = currentFontSize + 'px';
}

// Enhanced ANSI parser with 256 color support
function get256Color(num) {
    // Basic 16 colors - optimized for light theme
    if (num < 16) {
        const basicColors = [
            '#000000', '#cd3131', '#00bc00', '#949800',  // Light theme colors
            '#0451a5', '#bc05bc', '#0598bc', '#ffffff',
            '#666666', '#f14c4c', '#00c900', '#a8a800',  // Bright variants
            '#0067c7', '#d670d6', '#06b6d4', '#cccccc'
        ];
        return basicColors[num];
    }
    // 216 color cube
    else if (num < 232) {
        const i = num - 16;
        let r = Math.floor(i / 36) * 51;
        let g = Math.floor((i % 36) / 6) * 51;
        let b = (i % 6) * 51;
        return `rgb(${r},${g},${b})`;
    }
    // Grayscale
    else {
        const gray = (num - 232) * 10 + 8;
        return `rgb(${gray},${gray},${gray})`;
    }
}

// ANSI escape code parser with better support
function parseANSI(text) {
    let html = text;
    
    // Convert special characters first
    html = html.replace(/&/g, '&amp;');
    html = html.replace(/</g, '&lt;');
    html = html.replace(/>/g, '&gt;');
    
    // Stack to track open spans
    let openSpans = 0;
    
    // Replace ANSI codes with HTML
    html = html.replace(/\x1b\[([0-9;]+)m/g, (match, codes) => {
        const codeArray = codes.split(';');
        let result = '';
        
        for (let i = 0; i < codeArray.length; i++) {
            const code = parseInt(codeArray[i]);
            
            // Close any open spans on reset
            if (code === 0) {
                while (openSpans > 0) {
                    result += '</span>';
                    openSpans--;
                }
                continue;
            }
            
            // Text attributes
            if (code === 1) { result += '<span class="ansi-bold">'; openSpans++; }
            else if (code === 4) { result += '<span class="ansi-underline">'; openSpans++; }
            
            // 256-color support
            else if (code === 38 && codeArray[i+1] === '5') {
                // Foreground 256 color
                const colorNum = parseInt(codeArray[i+2]);
                const color = get256Color(colorNum);
                result += `<span style="color: ${color}">`;
                openSpans++;
                i += 2; // Skip the next two codes
            }
            else if (code === 48 && codeArray[i+1] === '5') {
                // Background 256 color - DISABLED for readability
                i += 2; // Skip but don't apply
            }
            
            // Standard colors 30-37
            else if (code >= 30 && code <= 37) {
                const colors = ['black', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white'];
                result += `<span class="ansi-${colors[code - 30]}">`;
                openSpans++;
            }
            
            // Bright foreground colors 90-97
            else if (code >= 90 && code <= 97) {
                const colors = ['black', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white'];
                result += `<span class="ansi-bright-${colors[code - 90]}">`;
                openSpans++;
            }
        }
        
        return result;
    });
    
    // Remove other ANSI codes we don't handle
    html = html.replace(/\x1b\[[0-9;]*[A-HJKSTfmsu]/g, '');
    html = html.replace(/\x1b\[?[0-9;]*[hl]/g, '');
    html = html.replace(/\x1b\][0-9];[^\x07\x1b]*(\x07|\x1b\\)/g, ''); // OSC sequences
    
    // Close any remaining open spans
    while (openSpans > 0) {
        html += '</span>';
        openSpans--;
    }
    
    return html;
}

// Send command to terminal
async function sendCommand() {
    const command = input.value.trim();
    if (!command) return;
    
    try {
        const response = await fetch('/api/terminal/claude/send', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ command })
        });
        
        if (response.ok) {
            input.value = '';
        }
    } catch (error) {
        console.error('Send error:', error);
        status.textContent = 'Error sending command';
        status.classList.remove('connected');
    }
}

// Send ESC key
async function sendEscape() {
    try {
        const response = await fetch('/api/terminal/claude/send', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ command: '\x1b' })
        });
        
        if (response.ok) {
            // Visual feedback
            const escButton = document.querySelector('button[onclick="sendEscape()"]');
            if (escButton) {
                escButton.style.background = '#a02030';
                setTimeout(() => {
                    escButton.style.background = '#dc3545';
                }, 200);
            }
        }
    } catch (error) {
        console.error('Send escape error:', error);
    }
}

// Poll for terminal output with typing detection
async function pollOutput() {
    if (isPolling) return;
    
    // Skip polling only if actively typing
    if (isTyping) {
        return;
    }
    
    isPolling = true;
    
    try {
        const response = await fetch('/api/terminal/claude/output');
        
        if (response.ok) {
            const data = await response.json();
            
            if (data.output && data.output !== lastContent) {
                // Check if user is selecting text
                const selection = window.getSelection();
                const hasSelection = selection && selection.toString().length > 0;
                
                // Save scroll position
                const container = document.getElementById('terminal-container');
                const wasAtBottom = container.scrollTop + container.clientHeight >= container.scrollHeight - 10;
                const currentScroll = container.scrollTop;
                
                // Filter Claude input box
                let filteredOutput = data.output;
                filteredOutput = filteredOutput.replace(/╭─+╮\s*\n│[^│]*│\s*\n╰─+╯/g, '');
                filteredOutput = filteredOutput.replace(/^│\s*>\s*│$/gm, '');
                
                // Parse ANSI codes
                let parsedContent = parseANSI(filteredOutput);
                
                // Only update if not selecting text
                if (!hasSelection) {
                    requestAnimationFrame(() => {
                        output.innerHTML = parsedContent;
                        lastContent = data.output;
                        
                        // Restore scroll position
                        if (wasAtBottom) {
                            container.scrollTop = container.scrollHeight;
                        } else {
                            container.scrollTop = currentScroll;
                        }
                    });
                } else {
                    lastContent = data.output;
                }
            }
            
            status.textContent = 'Connected';
            status.classList.add('connected');
        }
    } catch (error) {
        console.error('Poll error:', error);
        status.textContent = 'Disconnected';
        status.classList.remove('connected');
    } finally {
        isPolling = false;
    }
}

// Resume updates when selection is cleared
document.addEventListener('selectionchange', () => {
    const selection = window.getSelection();
    if (!selection || selection.toString().length === 0) {
        lastContent = '';
    }
});

// Keyboard event handling with typing detection
input.addEventListener('keydown', (e) => {
    // Handle Enter key
    if (e.key === 'Enter') {
        e.preventDefault();
        sendCommand();
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
    isTyping = true;
    
    // Clear existing timer
    if (typingTimer) {
        clearTimeout(typingTimer);
    }
    
    // Set timer to reset typing flag
    typingTimer = setTimeout(() => {
        isTyping = false;
        // Add small delay before resuming polling
        setTimeout(pollOutput, 200);
    }, 1500);
});

// Typing detection for input events (captures paste, etc.)
input.addEventListener('input', () => {
    // Mark as typing
    isTyping = true;
    
    // Clear existing timer
    if (typingTimer) {
        clearTimeout(typingTimer);
    }
    
    // Set timer to reset typing flag after 1500ms of inactivity
    typingTimer = setTimeout(() => {
        isTyping = false;
        // Add small delay before resuming polling
        setTimeout(pollOutput, 200);
    }, 1500);
});

// When input loses focus, ensure typing flag is cleared
input.addEventListener('blur', () => {
    // Clear typing flag and timer
    isTyping = false;
    if (typingTimer) {
        clearTimeout(typingTimer);
    }
    // Force an immediate poll to catch up
    setTimeout(pollOutput, 100);
});

// Mouse wheel handling for PC browsers
if (!isMobile && !isPWA) {
    console.log('PC browser detected - mouse wheel scrolling enabled');
} else {
    // Disable wheel scrolling on mobile to prevent conflicts
    document.getElementById('terminal-container').addEventListener('wheel', function(e) {
        if (!isIOS) {
            e.preventDefault();
            return false;
        }
    }, { passive: false });
}

// Start polling every 500ms
setInterval(pollOutput, 500);
pollOutput();
input.focus();
```

## Key Features

### 1. Real-time Terminal Updates
- Polls every 500ms for new terminal content
- Preserves ANSI color codes and formatting
- Filters out Claude's input box UI elements
- Maintains scroll position during updates
- **NEW**: Typing detection prevents polling lag during input

### 2. Text Selection Protection
- Pauses content updates while user is selecting text
- Automatically resumes when selection is cleared
- Touch-optimized for iOS devices
- Preserves selection during long-press

### 3. Scrollback History
- Captures up to 5,000 lines of terminal history
- Smooth scrolling on both mobile and desktop
- Preserves scroll position during updates
- Auto-scrolls only when at bottom

### 4. Cross-Platform Support
- **Desktop Browsers**: Full mouse wheel scrolling support
- **iPhone PWA**: Touch-optimized with momentum scrolling
- **Android**: Basic touch support with fallbacks
- Browser detection for platform-specific optimizations

### 5. UI Features
- **Font Size Control**: A+/A- buttons with localStorage persistence
- **ESC Button**: Red button for sending escape sequences
- **Burger Menu**: Collapsible side drawer for navigation
- **Status Indicator**: Real-time connection status
- **VS Code Light Theme**: Professional light theme with CSS variables
- **Theme System**: Fully customizable colors via CSS variables

### 6. Mobile Optimizations
- PWA support with viewport meta tags
- No user scaling to prevent zoom issues
- Touch-callout enabled for text selection
- Momentum scrolling with `-webkit-overflow-scrolling: touch`
- 16px minimum font size for iOS input fields

## Implementation Notes

### Critical Configuration
1. **tmux history-limit**: Must be set to at least 50,000 in `.tmux.conf`
2. **Flask app**: Must register the blueprint with API routes
3. **Session persistence**: tmux session survives Flask restarts
4. **ANSI parsing**: Essential for proper terminal display
5. **Theme Support**: Use CSS variables for easy theme switching
6. **Typing Detection**: 1.5s timeout + 200ms debounce for smooth typing

### Mobile-Specific Considerations
- Disable mouse wheel events on mobile to prevent conflicts
- Use `requestAnimationFrame` for smooth updates
- Check for active text selection before updating content
- Preserve `-webkit-touch-callout: default` for iOS

### Performance Optimizations
- Only update DOM when content changes
- Use innerHTML for bulk updates (faster than incremental)
- Debounce selection change events
- Limit capture to 5,000 lines to prevent memory issues

## Testing Checklist
- [ ] Terminal displays ANSI colors correctly
- [ ] ESC button sends escape sequence
- [ ] Text selection works on iPhone
- [ ] Scrolling preserves position during updates
- [ ] Mouse wheel works on desktop browsers
- [ ] Font size persistence across sessions
- [ ] Auto-scroll when at bottom
- [ ] Connection status updates properly
- [ ] Side menu opens/closes correctly
- [ ] Input field focuses appropriately

## Security Considerations
- Commands are sent as literals to prevent injection
- No eval() or dynamic code execution
- ANSI codes are parsed, not executed
- HTML is properly escaped before display

This specification provides everything needed to recreate the Claude Terminal Bridge feature from scratch, with all the nuances and platform-specific optimizations included.