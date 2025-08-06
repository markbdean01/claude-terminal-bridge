"""
Claude Terminal Bridge API
Flask blueprint for terminal communication with tmux sessions
"""

import subprocess
import json
import logging
import time
import os
from flask import Blueprint, request, jsonify

logger = logging.getLogger(__name__)

# Create blueprint
claude_terminal_bp = Blueprint('claude_terminal', __name__)

# Configuration
TMUX_SESSION_NAME = "claude-session"
TMUX_CAPTURE_LINES = 5000
CLAUDE_COMMAND = "claude -c --dangerously-skip-permissions"

def ensure_tmux_session():
    """Ensure the Claude tmux session exists"""
    try:
        # Check if session exists
        result = subprocess.run(
            ["tmux", "has-session", "-t", TMUX_SESSION_NAME],
            capture_output=True,
            text=True,
            timeout=5
        )
        
        if result.returncode != 0:
            # Session doesn't exist, create it
            logger.info(f"Creating tmux session: {TMUX_SESSION_NAME}")
            create_result = subprocess.run(
                ["tmux", "new-session", "-d", "-s", TMUX_SESSION_NAME, CLAUDE_COMMAND],
                capture_output=True,
                text=True,
                timeout=10
            )
            
            if create_result.returncode != 0:
                raise Exception(f"Failed to create tmux session: {create_result.stderr}")
            
            # Wait a moment for Claude to initialize
            time.sleep(2)
            
        return True
        
    except subprocess.TimeoutExpired:
        raise Exception("Timeout while checking/creating tmux session")
    except Exception as e:
        logger.error(f"Error ensuring tmux session: {e}")
        raise

@claude_terminal_bp.route("/api/terminal/claude/send", methods=["POST"])
def claude_terminal_send():
    """Send command to Claude Code tmux session"""
    try:
        data = request.get_json()
        if not data or 'command' not in data:
            return jsonify({"error": "No command provided"}), 400
        
        command = data['command']
        
        # Ensure tmux session exists
        ensure_tmux_session()
        
        # Handle special ESC character
        if command == '\x1b':
            # Send ESC key to tmux
            subprocess.run(
                ["tmux", "send-keys", "-t", TMUX_SESSION_NAME, "Escape"],
                capture_output=True,
                text=True,
                timeout=5
            )
            logger.info("Sent ESC key to Claude session")
        else:
            # Send command with literal flag to preserve formatting
            subprocess.run(
                ["tmux", "send-keys", "-t", TMUX_SESSION_NAME, "-l", command],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            # Send Enter key
            subprocess.run(
                ["tmux", "send-keys", "-t", TMUX_SESSION_NAME, "C-m"],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            logger.info(f"Sent command to Claude session: {command[:50]}...")
        
        return jsonify({
            "status": "success",
            "message": "Command sent successfully",
            "timestamp": time.time()
        })
        
    except subprocess.TimeoutExpired:
        logger.error("Timeout while sending command to tmux")
        return jsonify({"error": "Command timeout"}), 500
    except Exception as e:
        logger.error(f"Error sending command: {e}")
        return jsonify({"error": str(e)}), 500

@claude_terminal_bp.route("/api/terminal/claude/output", methods=["GET"])
def claude_terminal_output():
    """Get output from Claude Code tmux session"""
    try:
        # Ensure tmux session exists
        ensure_tmux_session()
        
        # Capture terminal output with ANSI codes preserved
        result = subprocess.run(
            ["tmux", "capture-pane", "-t", TMUX_SESSION_NAME, "-p", "-e", "-S", f"-{TMUX_CAPTURE_LINES}"],
            capture_output=True,
            text=True,
            timeout=5
        )
        
        if result.returncode == 0:
            return jsonify({
                "status": "success",
                "output": result.stdout,
                "timestamp": time.time()
            })
        else:
            logger.error(f"Failed to capture tmux output: {result.stderr}")
            return jsonify({
                "error": f"Failed to capture output: {result.stderr}",
                "status": "error"
            }), 500
            
    except subprocess.TimeoutExpired:
        logger.error("Timeout while capturing tmux output")
        return jsonify({
            "error": "Output capture timeout",
            "status": "timeout"
        }), 500
    except Exception as e:
        logger.error(f"Error getting Claude output: {e}")
        return jsonify({
            "error": str(e),
            "status": "error"
        }), 500

@claude_terminal_bp.route("/api/terminal/claude/status", methods=["GET"])
def claude_terminal_status():
    """Get status of Claude tmux session"""
    try:
        # Check if session exists
        result = subprocess.run(
            ["tmux", "has-session", "-t", TMUX_SESSION_NAME],
            capture_output=True,
            text=True,
            timeout=5
        )
        
        session_exists = result.returncode == 0
        
        # Get session info if it exists
        session_info = {}
        if session_exists:
            info_result = subprocess.run(
                ["tmux", "display-message", "-t", TMUX_SESSION_NAME, "-p", "#{session_name}:#{window_name}:#{pane_pid}"],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            if info_result.returncode == 0:
                parts = info_result.stdout.strip().split(':')
                if len(parts) >= 3:
                    session_info = {
                        "session_name": parts[0],
                        "window_name": parts[1],
                        "pane_pid": parts[2]
                    }
        
        return jsonify({
            "status": "success",
            "session_exists": session_exists,
            "session_name": TMUX_SESSION_NAME,
            "session_info": session_info,
            "timestamp": time.time()
        })
        
    except subprocess.TimeoutExpired:
        logger.error("Timeout while checking tmux status")
        return jsonify({
            "error": "Status check timeout",
            "status": "timeout"
        }), 500
    except Exception as e:
        logger.error(f"Error checking Claude status: {e}")
        return jsonify({
            "error": str(e),
            "status": "error"
        }), 500

@claude_terminal_bp.route("/api/terminal/claude/restart", methods=["POST"])
def claude_terminal_restart():
    """Restart Claude tmux session"""
    try:
        # Kill existing session if it exists
        subprocess.run(
            ["tmux", "kill-session", "-t", TMUX_SESSION_NAME],
            capture_output=True,
            text=True,
            timeout=5
        )
        
        # Wait a moment
        time.sleep(1)
        
        # Create new session
        ensure_tmux_session()
        
        return jsonify({
            "status": "success",
            "message": "Claude session restarted successfully",
            "timestamp": time.time()
        })
        
    except Exception as e:
        logger.error(f"Error restarting Claude session: {e}")
        return jsonify({
            "error": str(e),
            "status": "error"
        }), 500
