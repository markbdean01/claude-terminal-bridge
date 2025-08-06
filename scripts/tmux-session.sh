#!/bin/bash

# Claude Terminal Bridge - tmux Session Manager
# Manages Claude Code tmux sessions for the terminal bridge

set -e

# Configuration
SESSION_NAME="${TMUX_SESSION_NAME:-claude-session}"
CLAUDE_COMMAND="${CLAUDE_COMMAND:-claude -c --dangerously-skip-permissions}"
WINDOW_NAME="claude"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

log_success() {
    echo -e "${GREEN}✅ ${1}${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  ${1}${NC}"
}

log_error() {
    echo -e "${RED}❌ ${1}${NC}"
}

# Check if tmux is installed
check_tmux() {
    if ! command -v tmux &> /dev/null; then
        log_error "tmux is not installed"
        exit 1
    fi
}

# Check if session exists
session_exists() {
    tmux has-session -t "$SESSION_NAME" 2>/dev/null
}

# Create new Claude session
create_session() {
    log_info "Creating new Claude session: $SESSION_NAME"
    
    # Create session with Claude command
    tmux new-session -d -s "$SESSION_NAME" -n "$WINDOW_NAME" "$CLAUDE_COMMAND"
    
    if session_exists; then
        log_success "Claude session created successfully"
        return 0
    else
        log_error "Failed to create Claude session"
        return 1
    fi
}

# Attach to existing session
attach_session() {
    log_info "Attaching to existing Claude session: $SESSION_NAME"
    exec tmux attach-session -t "$SESSION_NAME"
}

# Kill existing session
kill_session() {
    if session_exists; then
        log_info "Killing Claude session: $SESSION_NAME"
        tmux kill-session -t "$SESSION_NAME"
        log_success "Claude session killed"
    else
        log_warning "No session to kill: $SESSION_NAME"
    fi
}

# Get session status
get_status() {
    if session_exists; then
        echo -e "${GREEN}Session Status: ACTIVE${NC}"
        echo
        echo "Session Details:"
        tmux display-message -t "$SESSION_NAME" -p "  Session: #{session_name}"
        tmux display-message -t "$SESSION_NAME" -p "  Window: #{window_name}"
        tmux display-message -t "$SESSION_NAME" -p "  Pane: #{pane_pid}"
        tmux display-message -t "$SESSION_NAME" -p "  Created: #{session_created}"
        echo
        echo "Windows:"
        tmux list-windows -t "$SESSION_NAME" -F "  #{window_index}: #{window_name} (#{window_panes} panes)"
        echo
        echo "To attach: tmux attach-session -t $SESSION_NAME"
    else
        echo -e "${RED}Session Status: INACTIVE${NC}"
        echo
        echo "No Claude session found with name: $SESSION_NAME"
        echo "To create: $0 start"
    fi
}

# List all tmux sessions
list_sessions() {
    echo "All tmux sessions:"
    if tmux list-sessions 2>/dev/null; then
        echo
        if session_exists; then
            echo -e "${GREEN}✅ Claude session ($SESSION_NAME) is active${NC}"
        else
            echo -e "${YELLOW}⚠️  Claude session ($SESSION_NAME) not found${NC}"
        fi
    else
        echo "No tmux sessions running"
    fi
}

# Send command to session
send_command() {
    local command="$1"
    
    if ! session_exists; then
        log_error "No active Claude session found"
        return 1
    fi
    
    log_info "Sending command to Claude session"
    tmux send-keys -t "$SESSION_NAME" -l "$command"
    tmux send-keys -t "$SESSION_NAME" "C-m"
    log_success "Command sent"
}

# Capture session output
capture_output() {
    local lines="${1:-1000}"
    
    if ! session_exists; then
        log_error "No active Claude session found"
        return 1
    fi
    
    log_info "Capturing last $lines lines from Claude session"
    tmux capture-pane -t "$SESSION_NAME" -p -e -S "-$lines"
}

# Monitor session (live view)
monitor_session() {
    if ! session_exists; then
        log_error "No active Claude session found"
        return 1
    fi
    
    log_info "Monitoring Claude session (Ctrl+C to exit)"
    echo
    
    # Function to capture and display output
    while true; do
        clear
        echo "=== Claude Session Monitor ($(date)) ==="
        echo
        tmux capture-pane -t "$SESSION_NAME" -p -e -S -50
        echo
        echo "=== Press Ctrl+C to exit ===" 
        sleep 2
    done
}

# Restart session
restart_session() {
    log_info "Restarting Claude session"
    
    kill_session
    sleep 1
    
    if create_session; then
        log_success "Claude session restarted successfully"
    else
        log_error "Failed to restart Claude session"
        return 1
    fi
}

# Show help
show_help() {
    echo "Claude Terminal Bridge - tmux Session Manager"
    echo
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo
    echo "Commands:"
    echo "  start, create         Create new Claude session"
    echo "  attach, connect       Attach to existing session"
    echo "  stop, kill            Kill Claude session"
    echo "  restart               Restart Claude session"
    echo "  status                Show session status"
    echo "  list                  List all tmux sessions"
    echo "  send <command>        Send command to session"
    echo "  capture [lines]       Capture session output"
    echo "  monitor               Monitor session in real-time"
    echo "  help                  Show this help message"
    echo
    echo "Environment Variables:"
    echo "  TMUX_SESSION_NAME     Session name (default: claude-session)"
    echo "  CLAUDE_COMMAND        Claude command (default: claude -c --dangerously-skip-permissions)"
    echo
    echo "Examples:"
    echo "  $0 start              # Create new Claude session"
    echo "  $0 send \"Hello\"       # Send message to Claude"
    echo "  $0 capture 500        # Capture last 500 lines"
    echo "  $0 monitor            # Monitor session output"
    echo
}

# Main function
main() {
    check_tmux
    
    case "${1:-help}" in
        start|create)
            if session_exists; then
                log_warning "Session already exists: $SESSION_NAME"
                echo "Use '$0 attach' to connect or '$0 restart' to recreate"
            else
                create_session
            fi
            ;;
        attach|connect)
            if session_exists; then
                attach_session
            else
                log_warning "No session found: $SESSION_NAME"
                echo "Use '$0 start' to create a new session"
            fi
            ;;
        stop|kill)
            kill_session
            ;;
        restart)
            restart_session
            ;;
        status)
            get_status
            ;;
        list)
            list_sessions
            ;;
        send)
            if [[ -n "$2" ]]; then
                send_command "$2"
            else
                log_error "No command provided"
                echo "Usage: $0 send <command>"
            fi
            ;;
        capture)
            capture_output "$2"
            ;;
        monitor)
            monitor_session
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $1"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Handle Ctrl+C gracefully in monitor mode
trap 'echo -e "\n${BLUE}ℹ Monitoring stopped${NC}"; exit 0' INT

# Run main function
main "$@"
