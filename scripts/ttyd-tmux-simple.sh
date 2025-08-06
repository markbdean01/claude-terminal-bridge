#!/bin/bash
# Claude Terminal Bridge - Tmux Session Management Script
# Creates or attaches to a persistent Claude Code session

SESSION_NAME="claude-session"

# Check if session exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    # Attach to existing session
    echo "Attaching to existing Claude session..."
    exec tmux attach-session -t "$SESSION_NAME"
else
    # Create new session and start claude with skip permissions flag
    echo "Creating new Claude session..."
    exec tmux new-session -s "$SESSION_NAME" -n "claude" "claude -c --dangerously-skip-permissions"
fi
