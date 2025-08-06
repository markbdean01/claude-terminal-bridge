#!/bin/bash

# Claude Terminal Bridge Installation Script
# Installs dependencies and configures the system

set -e

echo "🚀 Claude Terminal Bridge Installation"
echo "======================================"

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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    log_error "This script should not be run as root"
    exit 1
fi

# Check system requirements
check_requirements() {
    log_info "Checking system requirements..."
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 is required but not installed"
        exit 1
    fi
    
    python_version=$(python3 --version | cut -d' ' -f2)
    log_success "Python ${python_version} found"
    
    # Check pip
    if ! command -v pip3 &> /dev/null; then
        log_error "pip3 is required but not installed"
        exit 1
    fi
    
    # Check tmux
    if ! command -v tmux &> /dev/null; then
        log_warning "tmux not found, attempting to install..."
        
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y tmux
        elif command -v yum &> /dev/null; then
            sudo yum install -y tmux
        elif command -v brew &> /dev/null; then
            brew install tmux
        else
            log_error "Could not install tmux automatically. Please install manually."
            exit 1
        fi
    fi
    
    tmux_version=$(tmux -V)
    log_success "${tmux_version} found"
    
    # Check Claude CLI
    if ! command -v claude &> /dev/null; then
        log_warning "Claude CLI not found. Please install it manually:"
        echo "  pip install claude-cli"
        echo "  or visit: https://github.com/anthropics/claude-cli"
    else
        claude_version=$(claude --version 2>/dev/null || echo "Claude CLI")
        log_success "${claude_version} found"
    fi
}

# Install Python dependencies
install_dependencies() {
    log_info "Installing Python dependencies..."
    
    if [[ -f "requirements.txt" ]]; then
        pip3 install -r requirements.txt
        log_success "Python dependencies installed"
    else
        log_info "Installing essential dependencies..."
        pip3 install flask flask-cors
        log_success "Essential dependencies installed"
    fi
}

# Configure tmux
configure_tmux() {
    log_info "Configuring tmux..."
    
    tmux_conf="$HOME/.tmux.conf"
    
    # Backup existing config
    if [[ -f "$tmux_conf" ]]; then
        cp "$tmux_conf" "$tmux_conf.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backed up existing tmux configuration"
    fi
    
    # Add Claude Terminal Bridge configuration
    if ! grep -q "Claude Terminal Bridge" "$tmux_conf" 2>/dev/null; then
        cat >> "$tmux_conf" << 'EOF'

# Claude Terminal Bridge Configuration
set-option -g history-limit 50000
set-option -g default-terminal "screen-256color"

# Key bindings for Claude session
bind-key C new-session -d -s claude-session 'claude -c --dangerously-skip-permissions'
bind-key A attach-session -t claude-session

EOF
        log_success "tmux configuration updated"
    else
        log_info "tmux already configured for Claude Terminal Bridge"
    fi
    
    # Reload tmux configuration if tmux is running
    if tmux list-sessions &> /dev/null; then
        tmux source-file "$tmux_conf"
        log_success "tmux configuration reloaded"
    fi
}

# Create systemd service (optional)
create_service() {
    if [[ "$1" == "--service" ]]; then
        log_info "Creating systemd service..."
        
        service_file="/etc/systemd/system/claude-terminal-bridge.service"
        current_dir=$(pwd)
        current_user=$(whoami)
        
        sudo tee "$service_file" > /dev/null << EOF
[Unit]
Description=Claude Terminal Bridge
After=network.target

[Service]
Type=simple
User=$current_user
WorkingDirectory=$current_dir
ExecStart=$(which python3) $current_dir/backend/app.py
Restart=always
RestartSec=10
Environment=FLASK_HOST=0.0.0.0
Environment=FLASK_PORT=5000

[Install]
WantedBy=multi-user.target
EOF
        
        sudo systemctl daemon-reload
        sudo systemctl enable claude-terminal-bridge
        
        log_success "Systemd service created and enabled"
        log_info "Start with: sudo systemctl start claude-terminal-bridge"
    fi
}

# Create desktop launcher (Linux)
create_launcher() {
    if command -v xdg-desktop-menu &> /dev/null; then
        log_info "Creating desktop launcher..."
        
        launcher_dir="$HOME/.local/share/applications"
        mkdir -p "$launcher_dir"
        
        cat > "$launcher_dir/claude-terminal-bridge.desktop" << EOF
[Desktop Entry]
Name=Claude Terminal Bridge
Comment=Web-based terminal for Claude Code
Exec=xdg-open http://localhost:5000/terminal
Icon=terminal
Type=Application
Categories=Development;
StartupNotify=true
EOF
        
        log_success "Desktop launcher created"
    fi
}

# Run tests
run_tests() {
    if [[ "$1" == "--test" ]]; then
        log_info "Running basic tests..."
        
        # Test Python imports
        python3 -c "import flask, subprocess, json" 2>/dev/null
        log_success "Python imports test passed"
        
        # Test tmux
        tmux new-session -d -s test-session echo "test" 2>/dev/null
        tmux kill-session -t test-session 2>/dev/null
        log_success "tmux test passed"
        
        log_success "All tests passed"
    fi
}

# Main installation process
main() {
    echo
    log_info "Starting installation process..."
    
    check_requirements
    install_dependencies
    configure_tmux
    create_service "$@"
    create_launcher
    run_tests "$@"
    
    echo
    log_success "Installation completed successfully!"
    echo
    echo "🎉 Claude Terminal Bridge is ready to use!"
    echo
    echo "Next steps:"
    echo "1. Start the server: python3 backend/app.py"
    echo "2. Open browser: http://localhost:5000/terminal"
    echo "3. Add to iPhone home screen for PWA experience"
    echo
    echo "Configuration files:"
    echo "  - tmux: ~/.tmux.conf"
    echo "  - Service: /etc/systemd/system/claude-terminal-bridge.service (if --service used)"
    echo
    echo "For help and documentation, visit:"
    echo "  https://github.com/yourusername/claude-terminal-bridge"
    echo
}

# Parse command line arguments
case "$1" in
    --help|-h)
        echo "Claude Terminal Bridge Installation Script"
        echo
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  --service    Create systemd service"
        echo "  --test       Run tests after installation"
        echo "  --help       Show this help message"
        echo
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
