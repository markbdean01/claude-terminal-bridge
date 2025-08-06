# Claude Terminal Bridge - Architecture Documentation

## System Overview

The Claude Terminal Bridge is a web-based terminal interface that provides seamless communication with Claude Code through tmux sessions. The architecture is designed for cross-platform compatibility with special optimizations for mobile devices and Progressive Web App (PWA) functionality.

## Core Architecture

### High-Level Components

```
┌─────────────────────────────────────────────────────────────┐
│                     Client Layer                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Desktop       │  │   Mobile        │  │   iPhone    │ │
│  │   Browser       │  │   Browser       │  │   PWA       │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ HTTP/WebSocket
┌─────────────────────────────────────────────────────────────┐
│                   Flask Web Server                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │               API Layer                             │   │
│  │  ┌─────────────────┐  ┌─────────────────────────┐   │   │
│  │  │ Terminal API    │  │  Session Management     │   │   │
│  │  │ /send           │  │  - Create/Kill          │   │   │
│  │  │ /output         │  │  - Status Check         │   │   │
│  │  │ /status         │  │  - Health Monitor       │   │   │
│  │  └─────────────────┘  └─────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ Subprocess/tmux commands
┌─────────────────────────────────────────────────────────────┐
│                    System Layer                             │
│  ┌─────────────────┐  ┌─────────────────────────────────┐  │
│  │   tmux session  │  │    Claude Code CLI               │  │
│  │  "claude-session"│  │  - Interactive mode             │  │
│  │  - 50K history  │  │  - Skip permissions              │  │
│  │  - ANSI support │  │  - Message processing           │  │
│  └─────────────────┘  └─────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow Architecture

### Request Flow (User Input)

1. **User Input**: User types command in web interface
2. **Frontend Processing**: JavaScript validates and formats the command
3. **HTTP Request**: POST to `/api/terminal/claude/send`
4. **Flask Processing**: API endpoint receives and validates command
5. **tmux Integration**: Command sent via `tmux send-keys`
6. **Claude Processing**: Claude Code processes the command
7. **Response**: HTTP 200 with status confirmation

### Response Flow (Terminal Output)

1. **Polling**: Frontend polls `/api/terminal/claude/output` every 500ms
2. **tmux Capture**: `tmux capture-pane` retrieves terminal content
3. **Processing**: Filter Claude UI elements, preserve ANSI codes
4. **HTTP Response**: JSON with terminal content and timestamp
5. **Frontend Rendering**: ANSI parsing and DOM update
6. **User Display**: Formatted terminal output with colors

### Real-time Update Flow

```
Frontend Timer (500ms)
    ↓
API Call (/output)
    ↓
tmux capture-pane -t claude-session -p -e -S -5000
    ↓
Filter Claude UI elements
    ↓
Return JSON response
    ↓
Parse ANSI codes to HTML
    ↓
Update DOM (if no text selection)
    ↓
Preserve scroll position
```

## Component Details

### Backend Components

#### Flask Application (`backend/app.py`)

- **Framework**: Flask with CORS support
- **Static Files**: Serves frontend assets
- **Route Registration**: API blueprint integration
- **Error Handling**: Centralized error responses
- **Configuration**: Environment-based settings

#### Terminal API (`backend/claude_terminal_api.py`)

- **Session Management**: tmux session lifecycle
- **Command Processing**: Safe command transmission
- **Output Capture**: Terminal content retrieval
- **Status Monitoring**: Health and session checks
- **Error Recovery**: Automatic session recreation

#### Configuration (`backend/config.py`)

- **Environment Variables**: Flexible configuration
- **Default Values**: Sensible fallbacks
- **Session Settings**: tmux and Claude parameters
- **Security Settings**: Production-ready defaults

#### Utilities (`backend/utils.py`)

- **System Checks**: Dependency validation
- **Content Filtering**: Claude UI element removal
- **ANSI Processing**: Color code handling
- **Validation**: Input sanitization

### Frontend Components

#### HTML Structure (`frontend/index.html`)

- **PWA Manifest**: Mobile app integration
- **Responsive Design**: Cross-device compatibility
- **Accessibility**: ARIA labels and focus management
- **SEO Optimization**: Meta tags and structured data

#### Styling (`frontend/css/style.css`)

- **Mobile-First**: Touch-optimized interface
- **ANSI Colors**: Complete 256-color support
- **Dark Theme**: Terminal-appropriate aesthetics
- **Responsive Grid**: Flexible layout system
- **iOS Optimizations**: PWA-specific enhancements

#### JavaScript Logic (`frontend/js/app.js`)

- **Terminal Class**: Main application logic
- **Event Handling**: User interaction management
- **Polling System**: Real-time update mechanism
- **State Management**: Connection and UI state
- **Mobile Detection**: Platform-specific optimizations

#### ANSI Parser (`frontend/js/ansi-parser.js`)

- **Color Mapping**: ANSI code to CSS classes
- **HTML Escaping**: Security and safety
- **Format Preservation**: Bold, italic, underline
- **Performance**: Efficient parsing algorithms

#### Configuration (`frontend/js/config.js`)

- **Settings**: Configurable parameters
- **Platform Detection**: Mobile/desktop/PWA
- **Storage Keys**: LocalStorage management
- **API Endpoints**: URL configuration

## Security Architecture

### Input Validation

- **Command Sanitization**: Length and content limits
- **HTML Escaping**: XSS prevention in terminal output
- **ANSI Safety**: Safe parsing without code execution
- **Rate Limiting**: Protection against abuse

### Process Isolation

- **tmux Sessions**: Separate process space
- **User Permissions**: Non-root execution
- **File System**: Restricted access patterns
- **Network**: Localhost-only by default

### Authentication

- **Session Management**: Flask session handling
- **CSRF Protection**: Token-based validation
- **API Security**: Request validation
- **Transport Security**: HTTPS in production

## Performance Architecture

### Frontend Optimizations

- **Polling Strategy**: Adaptive frequency
- **DOM Updates**: Minimal and batched changes
- **Memory Management**: Garbage collection awareness
- **Mobile Performance**: Touch and scroll optimization

### Backend Optimizations

- **Process Reuse**: tmux session persistence
- **Caching**: Content comparison for updates
- **Resource Limits**: Memory and CPU bounds
- **Connection Pooling**: Efficient resource usage

### Network Optimizations

- **Compression**: gzip content encoding
- **Caching Headers**: Browser cache control
- **Minimal Payloads**: JSON optimization
- **CDN Support**: Static asset delivery

## Deployment Architecture

### Development

- **Local Server**: Flask development server
- **Hot Reload**: Automatic code updates
- **Debug Mode**: Enhanced error information
- **CORS**: Cross-origin development support

### Production

- **WSGI Server**: Gunicorn or similar
- **Reverse Proxy**: Nginx configuration
- **SSL/TLS**: HTTPS encryption
- **Process Management**: Systemd service

### Container Deployment

- **Docker**: Containerized deployment
- **Multi-stage**: Optimized image builds
- **Health Checks**: Container monitoring
- **Volume Management**: Persistent data

## Mobile Architecture

### Progressive Web App (PWA)

- **Manifest**: App installation metadata
- **Service Worker**: Offline functionality
- **App Shell**: Fast initial loading
- **Background Sync**: Offline command queuing

### iOS Optimizations

- **Viewport Handling**: Proper scaling
- **Touch Events**: Native-like interactions
- **Status Bar**: Seamless integration
- **Home Screen**: App icon and launch

### Android Optimizations

- **Material Design**: Platform consistency
- **Notification**: System integration
- **Intent Handling**: Deep linking
- **Back Button**: Navigation handling

## Scalability Considerations

### Horizontal Scaling

- **Load Balancing**: Multiple Flask instances
- **Session Affinity**: Sticky sessions for tmux
- **Database**: Optional session storage
- **Caching**: Redis for shared state

### Vertical Scaling

- **Resource Monitoring**: CPU and memory tracking
- **Auto-scaling**: Dynamic resource allocation
- **Performance Tuning**: Optimization strategies
- **Capacity Planning**: Growth projections

## Monitoring and Observability

### Logging

- **Structured Logs**: JSON formatting
- **Log Levels**: Appropriate verbosity
- **Log Rotation**: Size and time-based
- **Centralized**: Log aggregation systems

### Metrics

- **Performance**: Response times and throughput
- **Errors**: Error rates and types
- **Usage**: User behavior and patterns
- **Resources**: System utilization

### Health Checks

- **Endpoint**: `/health` status check
- **Dependencies**: tmux and Claude availability
- **Database**: Connection validation
- **External Services**: Third-party integrations

This architecture provides a robust, scalable, and maintainable foundation for the Claude Terminal Bridge while ensuring excellent user experience across all platforms.
