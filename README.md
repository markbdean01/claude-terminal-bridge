# Claude Terminal Bridge

**Web-based terminal for Claude Code with real-time updates, ANSI color support, iPhone PWA optimization, and Raspberry Pi compatibility.**

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Python](https://img.shields.io/badge/python-3.8+-green.svg)
![PWA](https://img.shields.io/badge/PWA-iOS%20Compatible-orange.svg)

## Overview

The Claude Terminal Bridge is a revolutionary web-based terminal interface that provides real-time interaction with Claude Code running in a tmux session. Originally designed to solve iOS Progressive Web App (PWA) iframe restrictions, it now serves as a powerful, cross-platform solution for mobile coding with Claude Code.

**Perfect for:** Live coding on iPhone, Raspberry Pi development, boat automation, IoT projects, and anywhere you need terminal access to Claude Code from a mobile device.

## ✨ Key Features

- **🍎 iPhone PWA Optimized**: Works around iOS iframe restrictions with native-like experience
- **⚡ Real-time Terminal Updates**: 500ms polling with 5,000 line scrollback history
- **🎨 Full ANSI Color Support**: Complete 256-color terminal emulation with proper parsing
- **📱 Touch-Optimized Interface**: Mobile-friendly with adjustable font size and momentum scrolling
- **✂️ Smart Text Selection**: Protected text selection that pauses updates during copy/paste
- **🔄 Session Persistence**: Uses tmux for reliable session management across disconnects
- **🚀 Instant Command Execution**: Direct integration with Claude Code's message system
- **🌊 Scroll Position Memory**: Maintains scroll position during live updates
- **🎯 ESC Key Support**: Dedicated escape button for terminal control sequences
- **📊 Connection Status**: Real-time connection monitoring with visual indicators

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

### Backend Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                Flask Server (Backend)                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           claude_terminal_api.py                    │   │
│  │  ┌─────────────────┐  ┌─────────────────────────┐   │   │
│  │  │ /api/terminal/  │  │  tmux Session Manager   │   │   │
│  │  │ claude/send     │  │  - Auto-creation        │   │   │
│  │  │ claude/output   │  │  - 5K line capture      │   │   │
│  │  └─────────────────┘  └─────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    tmux Session                             │
│  ┌─────────────────┐  ┌─────────────────────────────────┐  │
│  │   claude-session│  │    Claude Code CLI               │  │
│  │   50K history   │  │  claude -c --dangerously-skip-  │  │
│  │   ANSI colors   │  │  permissions                    │  │
│  └─────────────────┘  └─────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Frontend Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                iPhone PWA Interface                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                  Header                             │   │
│  │  [☰] Claude Terminal    [A-][A+] [●Connected]      │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                Terminal Output                      │   │
│  │  • ANSI Color Parsing                              │   │
│  │  • Touch Selection                                 │   │
│  │  • Momentum Scrolling                              │   │
│  │  • Real-time Updates                               │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  [Message Claude...        ] [ESC] [Send]          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Output Path**: tmux session → capture-pane → Flask API → JavaScript → ANSI Parser → HTML Display
2. **Input Path**: User Input → Flask API → tmux send-keys → Claude Code session
3. **Update Cycle**: 500ms polling → Content comparison → Selective DOM updates → Scroll preservation

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

### Frontend Configuration

```javascript
// frontend/js/config.js
const CONFIG = {
  pollInterval: 500, // Terminal update frequency
  maxFontSize: 32, // Maximum font size
  minFontSize: 8, // Minimum font size
  defaultFontSize: 12, // Default font size
  scrollThreshold: 10, // Auto-scroll threshold
};
```

## 📁 Project Structure

```
claude-terminal-bridge/
├── README.md                   # This file
├── requirements.txt            # Python dependencies
├── .gitignore                 # Git ignore rules
├── LICENSE                    # MIT license
├── backend/
│   ├── app.py                 # Main Flask application
│   ├── claude_terminal_api.py # Terminal API endpoints
│   ├── config.py              # Configuration settings
│   └── utils.py               # Utility functions
├── frontend/
│   ├── index.html             # Main PWA interface
│   ├── css/
│   │   └── style.css          # Complete styling
│   ├── js/
│   │   ├── app.js             # Main application logic
│   │   ├── ansi-parser.js     # ANSI color parsing
│   │   └── config.js          # Frontend configuration
│   └── manifest.json          # PWA manifest
├── scripts/
│   ├── install.sh             # Installation script
│   ├── tmux-session.sh        # tmux session manager
│   └── deploy.sh              # Deployment script
└── docs/
    ├── ARCHITECTURE.md        # Detailed architecture
    ├── API.md                 # API documentation
    └── MOBILE_GUIDE.md        # Mobile usage guide
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

## 🏷️ Use Cases

- **🚢 Marine IoT Development**: Perfect for boat automation and Raspberry Pi projects
- **📱 Mobile Coding**: Live coding with Claude on iPhone anywhere
- **🏠 Home Assistant**: Remote development for home automation
- **☁️ Cloud Development**: SSH-like experience through web browser
- **🎓 Learning**: Interactive coding sessions on mobile devices
- **⚡ Quick Fixes**: Rapid development and debugging on the go

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Credits

Based on the feature specification and architecture designed for the NjordViam Marine IoT project. Originally developed to solve iOS PWA iframe restrictions for terminal access.

**Keywords**: Claude Code, iPhone terminal, mobile development, PWA, tmux integration, ANSI colors, real-time terminal, touch interface, Raspberry Pi, boat automation, marine IoT, live coding

---

**Star this repo** ⭐ if you find it useful for mobile development with Claude Code!
