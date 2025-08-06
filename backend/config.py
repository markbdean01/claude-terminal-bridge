"""
Configuration settings for Claude Terminal Bridge
"""

import os

# tmux Configuration
TMUX_SESSION_NAME = os.environ.get("TMUX_SESSION_NAME", "claude-session")
TMUX_CAPTURE_LINES = int(os.environ.get("TMUX_CAPTURE_LINES", "5000"))
TMUX_HISTORY_LIMIT = int(os.environ.get("TMUX_HISTORY_LIMIT", "50000"))

# Claude Configuration
CLAUDE_COMMAND = os.environ.get(
    "CLAUDE_COMMAND", "claude -c --dangerously-skip-permissions"
)

# Flask Configuration
SECRET_KEY = os.environ.get("SECRET_KEY", "dev-secret-key-change-in-production")
DEBUG = os.environ.get("FLASK_DEBUG", "False").lower() == "true"
HOST = os.environ.get("FLASK_HOST", "0.0.0.0")
PORT = int(os.environ.get("FLASK_PORT", "5000"))

# Terminal Configuration
POLLING_INTERVAL = int(os.environ.get("POLLING_INTERVAL", "500"))  # milliseconds
MAX_OUTPUT_SIZE = int(os.environ.get("MAX_OUTPUT_SIZE", "1048576"))  # 1MB

# Logging Configuration
LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO")
LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
