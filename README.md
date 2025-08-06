# Claude Terminal Bridge

**Web-based terminal for Claude Code with real-time updates, ANSI color support, iPhone PWA optimization, and self-building app ecosystem capabilities.**

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Python](https://img.shields.io/badge/python-3.8+-green.svg)
![PWA](https://img.shields.io/badge/PWA-iOS%20Compatible-orange.svg)
![VS Code Theme](https://img.shields.io/badge/Theme-VS%20Code%20Light-blue.svg)

## 🚨 Important Prerequisites Notice

**Before diving into the code**, understand that this project has several key requirements:

### Essential Dependencies
- **Claude Code CLI** - The heart of this system
- **tmux** - Session management and persistence  
- **Python 3.8+** - Backend framework
- **Modern web browser** - Chrome, Safari, Firefox, Edge

### ⚡ Quick Start Alternative

**Don't want to wrestle with setup?** Here's the smart approach:

1. **Point Claude Code at this repository** and say: *"Use this codebase to create a terminal environment that works for my workflow and development style"*

2. **Or even simpler** - just use the included `CLAUDE_TERMINAL_BRIDGE_SPECIFICATION.md` and tell your coding agent: *"Build this entire application for me based on this specification"*

3. **The magic happens** - Claude Code will analyze the architecture and build a customized version that fits your exact needs

## 🎯 Recent Major Updates (August 2025)

This codebase has been completely updated to match the latest specification. Here's what changed:

### 🎨 VS Code Default Light Modern Theme
- **Complete visual overhaul** from dark to light theme
- **CSS variables system** for easy theme customization
- **Professional appearance** matching VS Code's design language
- **Optimized ANSI colors** for light background readability
- **White background, black text** with proper contrast ratios

### ⚡ Advanced Typing Detection
- **Smart polling pause** during active typing (1.5s timeout)
- **Zero lag typing** with 200ms debounce before resume
- **Control key filtering** - ignores function keys, navigation keys
- **Natural feel** that respects typing patterns and pauses
- **Performance boost** by reducing unnecessary API calls

### 🔧 Enhanced Technical Features
- **256-color ANSI support** with full palette
- **Improved parsing** of complex ANSI escape sequences  
- **Better mobile optimization** for PWA experience
- **Accessibility improvements** with proper ARIA labels
- **Code quality upgrades** removing inline styles

## 🌟 The Self-Building App Ecosystem

Here's where this gets really interesting and perhaps revolutionary:

### The Scenario
Imagine you have a **Raspberry Pi running Claude Code** in your home network, connected via **Tailscale** for secure access. You build this terminal bridge as your **first Flask app** - essentially the "main menu" of your development environment.

### The Magic Loop
1. **From your iPhone**, anywhere in the world, you connect through Tailscale to your Pi
2. **Open this terminal interface** and tell Claude Code: *"Build me a Python Flask app that does X, and make it work on iPhone exactly like this terminal app"*
3. **Claude Code builds the app around itself** - creating new features and interfaces
4. **Walking down the street**, you decide to add a feature and **speak directly to your phone** using iOS speech-to-text - no typing required
5. **The feature magically appears** in your app ecosystem

### The Speech-to-Text Reality
What makes this particularly interesting is that you can literally **develop by talking**. Using iPhone's speech-to-text, you can:
- Walk down the street and say "Add a weather widget to the home screen"
- Dictate complex code requirements while commuting
- Debug issues by describing what you're seeing verbally
- Refine features through natural conversation with Claude Code

No keyboard, no laptop - just your voice and your phone creating real applications.

### Why This Is Revolutionary
- **Self-modifying system** - The AI agent builds and modifies its own environment
- **Secure & private** - Closed loop under Tailscale, not exposed to internet
- **Instant deployment** - Changes appear immediately in your personal app ecosystem  
- **Mobile-first development** - Code from anywhere using just your phone
- **Zero setup friction** - Each new app inherits the mobile optimization automatically

### Security & Privacy
Since you're **not opening to the internet** but using a **closed Tailscale network**, you have:
- End-to-end encrypted connections
- No public attack surface
- Complete control over your development environment
- AI agent contained within your private network

This creates a fascinating scenario where **the AI builds the platform it runs on**, and you can direct its development from anywhere with just a mobile browser.

## Overview

The Claude Terminal Bridge is a web-based terminal interface that provides real-time interaction with Claude Code running in a tmux session. Originally designed to solve iOS Progressive Web App (PWA) iframe restrictions, it is cross-platform solution for mobile coding with Claude Code.

**Perfect for:** Live coding on iPhone, Raspberry Pi development, and anywhere you need terminal access to Claude Code from a mobile device.

## ✨ Core Features

- **🍎 iPhone PWA Optimized**: Native-like experience, works around iOS iframe restrictions
- **🎨 VS Code Light Theme**: Professional light theme with CSS variables for easy customization
- **⚡ Smart Typing Detection**: Advanced input detection prevents polling lag during typing
- **� Full ANSI Color Support**: Complete 256-color terminal emulation optimized for light backgrounds
- **📱 Touch-Optimized Interface**: Mobile-friendly with adjustable font size and momentum scrolling
- **✂️ Protected Text Selection**: Smart selection that pauses updates during copy/paste operations
- **🔄 Session Persistence**: Uses tmux for reliable session management across disconnects
- **🚀 Zero-Lag Input**: Real-time command execution with 1.5s typing timeout and 200ms debounce
- **🌊 Scroll Position Memory**: Maintains scroll position during live updates
- **🎯 ESC Key Support**: Dedicated escape button for terminal control sequences
- **📊 Real-time Status**: Visual connection monitoring with theme-consistent indicators
- **🏗️ Self-Building Capable**: AI agent can modify and extend its own environment

## 🚀 Quick Setup (< 5 minutes)

### Prerequisites

- Python 3.8+ with Flask
- tmux installed
- Claude Code CLI tool
- Git (for cloning)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/claude-terminal-bridge.git
cd claude-terminal-bridge

# 2. Install Python dependencies
pip install -r requirements.txt

# 3. Configure tmux (add to ~/.tmux.conf)
echo "set-option -g history-limit 50000" >> ~/.tmux.conf
tmux source-file ~/.tmux.conf

# 4. Make scripts executable
chmod +x scripts/*.sh

# 5. Start the Flask backend
python backend/app.py

# 6. Open in browser or add to iPhone home screen
# Desktop: http://localhost:5000/terminal
# iPhone PWA: Add to home screen for full-screen experience
```

### iPhone PWA Setup

1. Open `http://your-server-ip:5000/terminal` in Safari
2. Tap the Share button
3. Select "Add to Home Screen"
4. Launch from home screen for full PWA experience

## 🏗️ Architecture

### The Self-Building Loop

```
+===============================================================+
|                   Your Secure Network (Tailscale)            |
|  +=========================================================+  |
|  |                 Raspberry Pi / Server                  |  |
|  |                                                         |  |
|  |  +-----------------------------------------------------+  |  |
|  |  |            Claude Code CLI                          |  |  |
|  |  |        (AI Development Agent)                       |  |  |
|  |  +-----------------------------------------------------+  |  |
|  |                            |                            |  |
|  |  +-----------------------------------------------------+  |  |
|  |  |         Terminal Bridge Web App                     |  |  |
|  |  |           (This Repository)                         |  |  |
|  |  +-----------------------------------------------------+  |  |
|  |                            |                            |  |
|  |  +-----------------------------------------------------+  |  |
|  |  |           Auto-Generated Apps                       |  |  |
|  |  |   • App 1 (built by Claude)                         |  |  |
|  |  |   • App 2 (built by Claude)                         |  |  |
|  |  |   • App N (built by Claude)                         |  |  |
|  |  +-----------------------------------------------------+  |  |
|  +=========================================================+  |
+===============================================================+
                              |
                 +------------+------------+
                 |                         |
                 v                         v
+---------------------------+    +---------------------------+
|       iPhone (You)        |    |   Any Browser Anywhere    |
|    Via Tailscale VPN     |    |    Via Tailscale VPN     |
|                           |    |                           |
| +---------------------+   |    | +---------------------+   |
| |   Terminal Bridge   |   |    | |   Auto-built Apps   |   |
| |     (PWA Mode)      |   |    | |   (All Responsive)  |   |
| +---------------------+   |    | +---------------------+   |
+---------------------------+    +---------------------------+
```

### Traditional Backend Architecture

```
+---------------------------------------------------------------+
|                    Flask Server (Backend)                    |
|  +-------------------------------------------------------+    |
|  |                claude_terminal_api.py               |    |
|  |                                                     |    |
|  |  +---------------+    +---------------------+       |    |
|  |  |/api/terminal/ |    |tmux Session Manager |       |    |
|  |  |claude/send    | <> |- Auto-creation     |       |    |
|  |  |claude/output  |    |- 5K line capture   |       |    |
|  |  +---------------+    +---------------------+       |    |
|  +-------------------------------------------------------+    |
+---------------------------------------------------------------+
                              |
                              v
+---------------------------------------------------------------+
|                        tmux Session                          |
|                                                               |
|  +---------------+    +-------------------------------+       |
|  |claude-session |    |       Claude Code CLI         |       |
|  |50K history    | <> |claude -c --dangerously-skip- |       |
|  |ANSI colors    |    |permissions                    |       |
|  +---------------+    +-------------------------------+       |
+---------------------------------------------------------------+
```

### Frontend Architecture (VS Code Light Theme)

```
+---------------------------------------------------------------+
|              iPhone PWA Interface (Light Theme)              |
|                                                               |
|  +-------------------------------------------------------+    |
|  |                 Header (Light Gray)                |    |
|  | [≡] Claude Terminal   [A-][A+] [●Connected]        |    |
|  +-------------------------------------------------------+    |
|                                                               |
|  +-------------------------------------------------------+    |
|  |            Terminal Output (White BG)              |    |
|  |                                                     |    |
|  | • 256-Color ANSI Parsing (Light Optimized)         |    |
|  | • Smart Typing Detection (1.5s timeout)            |    |
|  | • Protected Touch Selection                        |    |
|  | • Zero-Lag Input Processing                        |    |
|  | • CSS Variables Theme System                       |    |
|  +-------------------------------------------------------+    |
|                                                               |
|  +-------------------------------------------------------+    |
|  | [Message Claude...        ] [ESC] [Send]           |    |
|  +-------------------------------------------------------+    |
+---------------------------------------------------------------+
```

### Enhanced Data Flow (with Typing Detection)

1. **Output Path**: tmux session → capture-pane → Flask API → JavaScript → Enhanced ANSI Parser → HTML Display
2. **Smart Input Path**: User Input → Typing Detection → Polling Pause → Flask API → tmux send-keys → Claude Code
3. **Update Cycle**: 500ms polling → Typing Check → Content comparison → DOM updates → Scroll preservation
4. **Theme System**: CSS Variables → Dynamic Styling → Light/Dark Mode Ready

## 📱 Usage Guide

### Basic Commands

- **Send Message**: Type in the input field and press Enter or tap Send
- **ESC Sequence**: Red ESC button sends escape character for terminal control
- **Font Size**: A+/A- buttons adjust font size (persistent across sessions)
- **Scroll Navigation**: Touch and drag to scroll, auto-scrolls when at bottom

### Advanced Features

- **Text Selection**: Long-press to select text (pauses updates automatically)
- **Copy/Paste**: Standard iOS/browser copy/paste functionality
- **Background Updates**: Content updates while app is backgrounded
- **Session Recovery**: Reconnects automatically after network interruptions

### Mobile Optimizations

- **PWA Mode**: Add to home screen for native app experience
- **Viewport Optimized**: No zoom conflicts, proper viewport handling
- **Touch Friendly**: Large touch targets, momentum scrolling
- **Battery Efficient**: Optimized polling and DOM updates

## 🛡️ Security Considerations

- **Command Sanitization**: All commands are literal-sent to prevent injection
- **ANSI Parsing**: HTML is properly escaped before ANSI processing
- **No Code Execution**: No eval() or dynamic code execution in browser
- **Process Isolation**: tmux provides process-level isolation
- **Authentication**: Inherits authentication from main Flask application

## 🔧 Configuration

### VS Code Light Theme Variables

```css
/* New CSS Variables System */
:root {
    /* Terminal Colors (Light Theme) */
    --terminal-background: #ffffff;
    --terminal-foreground: #000000;
    --terminal-ansi-black: #000000;
    --terminal-ansi-white: #ffffff;
    
    /* UI Colors (VS Code Light) */
    --background: #ffffff;
    --foreground: #000000;
    --secondary-foreground: #616161;
    --border: #e5e5e5;
    --selection: #0078d4;
    
    /* Status Colors */
    --success: #16a085;
    --warning: #f39c12;
    --error: #e74c3c;
}
```

### Typing Detection Configuration

```javascript
// Enhanced frontend/js/config.js
const CONFIG = {
  pollInterval: 500,           // Terminal update frequency
  typingTimeout: 1500,         // Typing detection timeout (ms)
  typingDebounce: 200,        // Debounce before resume (ms)
  maxFontSize: 32,            // Maximum font size
  minFontSize: 8,             // Minimum font size
  defaultFontSize: 14,        // Default font size (light theme)
  scrollThreshold: 10,        // Auto-scroll threshold
};
```

### tmux Configuration (`~/.tmux.conf`)

```bash
# Increase history for Claude Terminal Bridge
set-option -g history-limit 50000

# Optional: Custom Claude session settings
bind-key C new-session -d -s claude-session 'claude -c --dangerously-skip-permissions'
```

### Flask Configuration

```python
# backend/config.py
TMUX_SESSION_NAME = "claude-session"
TMUX_CAPTURE_LINES = 5000
POLLING_INTERVAL = 500  # milliseconds
CLAUDE_COMMAND = "claude -c --dangerously-skip-permissions"
```

## 📁 Project Structure

```
claude-terminal-bridge/
├── 📖 README.md                              # This comprehensive guide
├── 📋 requirements.txt                       # Python dependencies  
├── 📄 CLAUDE_TERMINAL_BRIDGE_SPECIFICATION.md  # Technical specification
├── 🚫 .gitignore                            # Git ignore rules
├── 📜 LICENSE                               # MIT license
│
├── 🐍 backend/
│   ├── app.py                            # Main Flask application
│   ├── claude_terminal_api.py            # Terminal API endpoints
│   ├── config.py                         # Configuration settings
│   └── utils.py                          # Utility functions
│
├── 🌐 frontend/
│   ├── index.html                        # Main PWA interface (updated)
│   ├── 🎨 css/
│   │   └── style.css                     # Complete VS Code light theme
│   ├── ⚙️ js/
│   │   ├── app.js                        # Enhanced app logic with typing detection
│   │   ├── ansi-parser.js                # 256-color ANSI parsing
│   │   └── config.js                     # Frontend configuration
│   └── manifest.json                     # PWA manifest (light theme)
│
├── 🔧 scripts/
│   ├── install.sh                        # Installation script
│   ├── ttyd-tmux-simple.sh              # New: tmux session manager
│   └── deploy.sh                         # Deployment script
│
└── 📚 docs/
    ├── ARCHITECTURE.md                   # Detailed architecture
    ├── API.md                            # API documentation
    └── MOBILE_GUIDE.md                   # Mobile usage guide
```

## 🔗 API Endpoints

### Send Command

```http
POST /api/terminal/claude/send
Content-Type: application/json

{
  "command": "Hello Claude, how are you?"
}
```

### Get Terminal Output

```http
GET /api/terminal/claude/output

Response:
{
  "status": "success",
  "output": "Terminal content with ANSI codes...",
  "timestamp": 1234567890.123
}
```

## 🏷️ Use Cases & The Future of AI Development

### Traditional Use Cases
- **🚢 Marine IoT Development**: Perfect for boat automation and Raspberry Pi projects
- **📱 Mobile Coding**: Live coding with Claude on iPhone anywhere
- **🏠 Home Assistant**: Remote development for home automation
- **☁️ Cloud Development**: SSH-like experience through web browser
- **🎓 Learning**: Interactive coding sessions on mobile devices
- **⚡ Quick Fixes**: Rapid development and debugging on the go

### Revolutionary Self-Building Ecosystem
- **🤖 AI Agent Platform**: Claude Code builds and modifies its own environment
- **📱 Mobile-First AI Development**: Code complex applications from your phone
- **🔐 Private AI Network**: Secure, contained development environment via Tailscale
- **⚡ Instant Feature Addition**: Walking down the street? Add a feature instantly
- **🏗️ Self-Modifying Architecture**: The AI agent continuously improves its own tools
- **🌐 Distributed Development**: Your personal AI development team, accessible anywhere

### The Meta-Development Loop
This project enables a fascinating recursive development pattern:
1. **AI builds tools** for its own development
2. **Mobile interface** allows real-time direction from anywhere  
3. **Secure private network** contains the entire ecosystem
4. **Each new app** inherits mobile optimization automatically
5. **Developer becomes conductor** rather than coder

This represents a fundamental shift from **writing code** to **directing intelligent agents** in a self-improving development ecosystem.

## 🗣️ A Practical Example: Building Your First App

Here's how you might actually use this in practice:

### Day 1: Setup
1. Install this terminal bridge on your Raspberry Pi
2. Add it to your iPhone home screen as a PWA
3. Test the connection through Tailscale

### Day 2: Voice-Driven Development
**Walking to the coffee shop**, you open the terminal and speak to your phone:

*"Claude, I want to build a simple todo app. Create a new Flask route at /todo that shows a list of tasks. Make it look good on iPhone like this terminal interface."*

Claude Code builds the foundation. You now have:
- Terminal Bridge (Menu item 1)
- Todo App (Menu item 2)

### Day 3: Adding Features
**On your lunch break**, you switch to the terminal tab and say:

*"Add the ability to mark tasks as complete with a checkbox. Also add a way to delete tasks."*

You refresh your todo app tab - the features are there.

### Day 4: Polish
**While waiting for the bus**:

*"Make the todo app use the same VS Code light theme colors as this terminal. Also add a due date field to each task."*

### The Result
In a few days of casual conversation with your phone, you've built a fully functional web app that runs on your private network, accessible from anywhere via Tailscale. No traditional coding required - just describing what you want while going about your day.

### The Broader Insight
This isn't just about avoiding typing. It's about **removing the friction** between having an idea and seeing it implemented. When development becomes as easy as talking to your phone, the barrier between thought and creation essentially disappears.

The interesting observation is that you're not really "programming" anymore - you're **collaborating with an AI** that understands your intent and handles the technical implementation. Your role shifts from coder to product owner, having conversations about features rather than debugging syntax errors.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Credits & Evolution

Originally designed for the NjordViam Marine IoT project to solve iOS PWA iframe restrictions. **August 2025 major update** implements:

- **VS Code Default Light Modern Theme** with complete CSS variables system
- **Advanced typing detection** with smart polling control  
- **256-color ANSI support** optimized for light backgrounds
- **Self-building app ecosystem** architecture and documentation

The project has evolved from a simple terminal interface to a **revolutionary platform for AI-directed development**, where the agent builds and modifies its own environment through a mobile-optimized interface.

**Special thanks** to the insight that this creates a **self-modifying AI development loop** - where walking down the street with your phone becomes a legitimate way to add features to complex applications running on your private network.

**Keywords**: Claude Code, iPhone terminal, mobile development, PWA, tmux integration, ANSI colors, real-time terminal, touch interface, Raspberry Pi, boat automation, marine IoT, live coding, self-building apps, AI development ecosystem, VS Code light theme, typing detection

---

**Star this repo** ⭐ if you're excited about the future of AI-directed mobile development!
