# Claude Terminal Bridge - API Documentation

## Overview

The Claude Terminal Bridge provides a RESTful API for communicating with Claude Code through tmux sessions. All endpoints return JSON responses and use standard HTTP status codes.

## Base URL

```
http://localhost:5000/api/terminal/claude
```

## Authentication

Currently, the API relies on Flask session authentication. No additional authentication headers are required for local usage.

## Content Types

- **Request**: `application/json`
- **Response**: `application/json`

## Error Handling

All endpoints return consistent error responses:

```json
{
  "error": "Error description",
  "status": "error",
  "timestamp": 1234567890.123
}
```

HTTP status codes used:

- `200` - Success
- `400` - Bad Request (invalid input)
- `500` - Internal Server Error
- `503` - Service Unavailable (tmux/Claude not available)

---

## API Endpoints

### Send Command

Send a command to the Claude Code tmux session.

**Endpoint:** `POST /api/terminal/claude/send`

**Request Body:**

```json
{
  "command": "string"
}
```

**Parameters:**

- `command` (string, required): The command or message to send to Claude

**Special Commands:**

- `\x1b` - Sends ESC key sequence
- Regular text - Sent as literal message to Claude

**Response:**

```json
{
  "status": "success",
  "message": "Command sent successfully",
  "timestamp": 1234567890.123
}
```

**Example:**

```bash
curl -X POST http://localhost:5000/api/terminal/claude/send \
  -H "Content-Type: application/json" \
  -d '{"command": "Hello Claude, how are you?"}'
```

**Error Responses:**

- `400` - No command provided
- `500` - Failed to send command (tmux error)

---

### Get Terminal Output

Retrieve the current terminal output from the Claude session.

**Endpoint:** `GET /api/terminal/claude/output`

**Parameters:** None

**Response:**

```json
{
  "status": "success",
  "output": "Terminal content with ANSI codes...",
  "timestamp": 1234567890.123
}
```

**Notes:**

- Returns up to 5,000 lines of scrollback
- ANSI escape sequences are preserved
- Claude UI elements are filtered out server-side

**Example:**

```bash
curl http://localhost:5000/api/terminal/claude/output
```

**Error Responses:**

- `500` - Failed to capture terminal output
- `503` - tmux session not available

---

### Session Status

Get information about the Claude tmux session.

**Endpoint:** `GET /api/terminal/claude/status`

**Parameters:** None

**Response:**

```json
{
  "status": "success",
  "session_exists": true,
  "session_name": "claude-session",
  "session_info": {
    "session_name": "claude-session",
    "window_name": "claude",
    "pane_pid": "12345"
  },
  "timestamp": 1234567890.123
}
```

**Fields:**

- `session_exists` (boolean): Whether the tmux session is running
- `session_name` (string): Name of the tmux session
- `session_info` (object): Detailed session information (only if session exists)

**Example:**

```bash
curl http://localhost:5000/api/terminal/claude/status
```

---

### Restart Session

Kill and recreate the Claude tmux session.

**Endpoint:** `POST /api/terminal/claude/restart`

**Parameters:** None

**Response:**

```json
{
  "status": "success",
  "message": "Claude session restarted successfully",
  "timestamp": 1234567890.123
}
```

**Example:**

```bash
curl -X POST http://localhost:5000/api/terminal/claude/restart
```

**Error Responses:**

- `500` - Failed to restart session

---

## WebSocket Support (Future)

_Note: WebSocket support is planned for future versions to provide real-time bidirectional communication._

**Proposed Endpoint:** `ws://localhost:5000/api/terminal/claude/ws`

**Features:**

- Real-time output streaming
- Reduced polling overhead
- Better mobile performance
- Instant command confirmation

---

## Rate Limiting

The API implements basic rate limiting to prevent abuse:

- **Send Command**: 10 requests per minute per session
- **Get Output**: 120 requests per minute per session (polling)
- **Status/Restart**: 30 requests per minute per session

Rate limit headers are included in responses:

```
X-RateLimit-Limit: 10
X-RateLimit-Remaining: 9
X-RateLimit-Reset: 1234567890
```

---

## Integration Examples

### JavaScript (Frontend)

```javascript
class ClaudeAPI {
  constructor(baseUrl = "/api/terminal/claude") {
    this.baseUrl = baseUrl;
  }

  async sendCommand(command) {
    const response = await fetch(`${this.baseUrl}/send`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ command }),
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    return await response.json();
  }

  async getOutput() {
    const response = await fetch(`${this.baseUrl}/output`);

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    return await response.json();
  }

  async getStatus() {
    const response = await fetch(`${this.baseUrl}/status`);

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    return await response.json();
  }

  async restart() {
    const response = await fetch(`${this.baseUrl}/restart`, {
      method: "POST",
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    return await response.json();
  }
}
```

### Python (Backend Integration)

```python
import requests

class ClaudeTerminalClient:
    def __init__(self, base_url='http://localhost:5000/api/terminal/claude'):
        self.base_url = base_url
        self.session = requests.Session()

    def send_command(self, command):
        response = self.session.post(
            f'{self.base_url}/send',
            json={'command': command}
        )
        response.raise_for_status()
        return response.json()

    def get_output(self):
        response = self.session.get(f'{self.base_url}/output')
        response.raise_for_status()
        return response.json()

    def get_status(self):
        response = self.session.get(f'{self.base_url}/status')
        response.raise_for_status()
        return response.json()

    def restart(self):
        response = self.session.post(f'{self.base_url}/restart')
        response.raise_for_status()
        return response.json()
```

### cURL Examples

```bash
#!/bin/bash

# Send a command
curl -X POST http://localhost:5000/api/terminal/claude/send \
  -H "Content-Type: application/json" \
  -d '{"command": "What is the weather like?"}'

# Get terminal output
curl http://localhost:5000/api/terminal/claude/output | jq '.output'

# Check session status
curl http://localhost:5000/api/terminal/claude/status | jq '.session_exists'

# Restart session
curl -X POST http://localhost:5000/api/terminal/claude/restart

# Send ESC key
curl -X POST http://localhost:5000/api/terminal/claude/send \
  -H "Content-Type: application/json" \
  -d '{"command": "\u001b"}'
```

---

## Error Scenarios

### Session Not Found

When tmux session doesn't exist, the API automatically attempts to create it:

```json
{
  "status": "created",
  "output": "Terminal session created. Initializing Claude Code...\n",
  "timestamp": 1234567890.123
}
```

### Claude CLI Not Available

If Claude CLI is not installed or accessible:

```json
{
  "error": "Claude CLI not found. Please install claude-cli",
  "status": "error",
  "timestamp": 1234567890.123
}
```

### tmux Not Available

If tmux is not installed:

```json
{
  "error": "tmux is not installed or not accessible",
  "status": "error",
  "timestamp": 1234567890.123
}
```

---

## Development and Testing

### Health Check

A simple health check endpoint for monitoring:

**Endpoint:** `GET /health`

**Response:**

```json
{
  "status": "healthy",
  "timestamp": 1234567890.123,
  "dependencies": {
    "tmux": true,
    "claude": true
  }
}
```

### Debug Mode

When running in debug mode (`FLASK_DEBUG=true`), additional information is included in error responses:

```json
{
  "error": "Command failed",
  "status": "error",
  "debug": {
    "traceback": "...",
    "tmux_output": "...",
    "system_info": "..."
  },
  "timestamp": 1234567890.123
}
```

---

## Security Considerations

### Input Validation

- Commands are limited to 10,000 characters
- HTML escaping applied to prevent XSS
- No shell command injection (uses tmux literal mode)

### Access Control

- API accessible only from same origin by default
- CORS can be configured for development
- Rate limiting prevents abuse

### Data Privacy

- No persistent logging of commands by default
- Session data stored only in tmux memory
- No external API calls without explicit consent

This API provides a robust and secure interface for integrating with Claude Code through the terminal bridge, suitable for both development and production use.
