"""
Utility functions for Claude Terminal Bridge
"""

import subprocess
import logging
import time
import re

logger = logging.getLogger(__name__)


def check_tmux_installed():
    """Check if tmux is installed and available"""
    try:
        result = subprocess.run(
            ["tmux", "-V"],
            capture_output=True,
            text=True,
            timeout=5
        )
        return result.returncode == 0
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return False


def check_claude_installed():
    """Check if Claude CLI is installed and available"""
    try:
        result = subprocess.run(
            ["claude", "--version"],
            capture_output=True,
            text=True,
            timeout=5
        )
        return result.returncode == 0
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return False


def filter_claude_ui_elements(output):
    """Filter out Claude's input box UI elements from terminal output"""
    if not output:
        return output
    
    # Remove Claude's input box UI
    filtered = re.sub(r'╭─+╮\s*\n│[^│]*│\s*\n╰─+╯', '', output)
    filtered = re.sub(r'^│\s*>\s*│$', '', filtered, flags=re.MULTILINE)
    
    return filtered


def parse_ansi_codes(text):
    """Basic ANSI code parsing for logging purposes"""
    if not text:
        return ""
    
    # Remove ANSI escape sequences for clean logging
    ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
    return ansi_escape.sub('', text)


def validate_command(command):
    """Validate command input"""
    if not command:
        return False, "Empty command"
    
    if len(command) > 10000:  # Reasonable limit
        return False, "Command too long"
    
    return True, "Valid"


def get_system_info():
    """Get system information for debugging"""
    info = {
        "tmux_available": check_tmux_installed(),
        "claude_available": check_claude_installed(),
        "timestamp": time.time()
    }
    
    try:
        # Get tmux version
        result = subprocess.run(
            ["tmux", "-V"],
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0:
            info["tmux_version"] = result.stdout.strip()
    except Exception:
        pass
    
    try:
        # Get Claude version
        result = subprocess.run(
            ["claude", "--version"],
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0:
            info["claude_version"] = result.stdout.strip()
    except Exception:
        pass
    
    return info
