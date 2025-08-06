#!/bin/bash

# Claude Terminal Bridge - Deployment Script
# Deploys the application with production configurations

set -e

# Configuration
PROJECT_NAME="claude-terminal-bridge"
DEPLOY_USER="${DEPLOY_USER:-$(whoami)}"
DEPLOY_HOST="${DEPLOY_HOST:-localhost}"
DEPLOY_PATH="${DEPLOY_PATH:-/opt/$PROJECT_NAME}"
SERVICE_NAME="claude-terminal-bridge"
BACKUP_DIR="/opt/backups"

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

# Check if running with correct permissions
check_permissions() {
    if [[ "$DEPLOY_PATH" == /opt/* ]] && [[ $EUID -ne 0 ]]; then
        log_error "Deployment to /opt requires root privileges"
        echo "Run with sudo or set DEPLOY_PATH to a user directory"
        exit 1
    fi
}

# Create backup of existing deployment
create_backup() {
    if [[ -d "$DEPLOY_PATH" ]]; then
        log_info "Creating backup of existing deployment..."
        
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local backup_path="$BACKUP_DIR/${PROJECT_NAME}_${timestamp}"
        
        mkdir -p "$BACKUP_DIR"
        cp -r "$DEPLOY_PATH" "$backup_path"
        
        log_success "Backup created: $backup_path"
    fi
}

# Stop existing service
stop_service() {
    if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        log_info "Stopping existing service..."
        systemctl stop "$SERVICE_NAME"
        log_success "Service stopped"
    fi
}

# Deploy application files
deploy_files() {
    log_info "Deploying application files..."
    
    # Create deployment directory
    mkdir -p "$DEPLOY_PATH"
    
    # Copy application files
    cp -r backend/ "$DEPLOY_PATH/"
    cp -r frontend/ "$DEPLOY_PATH/"
    cp -r scripts/ "$DEPLOY_PATH/"
    cp requirements.txt "$DEPLOY_PATH/"
    cp README.md "$DEPLOY_PATH/"
    
    # Set permissions
    chown -R "$DEPLOY_USER:$DEPLOY_USER" "$DEPLOY_PATH"
    chmod +x "$DEPLOY_PATH/scripts/"*.sh
    
    log_success "Application files deployed"
}

# Install Python dependencies
install_dependencies() {
    log_info "Installing Python dependencies..."
    
    cd "$DEPLOY_PATH"
    
    # Create virtual environment if it doesn't exist
    if [[ ! -d "venv" ]]; then
        python3 -m venv venv
        log_success "Virtual environment created"
    fi
    
    # Activate virtual environment and install dependencies
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    
    log_success "Dependencies installed"
}

# Configure tmux for deploy user
configure_tmux() {
    log_info "Configuring tmux..."
    
    local tmux_conf="/home/$DEPLOY_USER/.tmux.conf"
    
    # Create tmux configuration if it doesn't exist
    if [[ ! -f "$tmux_conf" ]]; then
        sudo -u "$DEPLOY_USER" bash << 'EOF'
cat > ~/.tmux.conf << 'TMUX_EOF'
# Claude Terminal Bridge Configuration
set-option -g history-limit 50000
set-option -g default-terminal "screen-256color"

# Key bindings for Claude session
bind-key C new-session -d -s claude-session 'claude -c --dangerously-skip-permissions'
bind-key A attach-session -t claude-session
TMUX_EOF
EOF
        log_success "tmux configured"
    else
        log_info "tmux already configured"
    fi
}

# Create systemd service
create_service() {
    log_info "Creating systemd service..."
    
    cat > "/etc/systemd/system/$SERVICE_NAME.service" << EOF
[Unit]
Description=Claude Terminal Bridge
Documentation=https://github.com/yourusername/claude-terminal-bridge
After=network.target

[Service]
Type=simple
User=$DEPLOY_USER
Group=$DEPLOY_USER
WorkingDirectory=$DEPLOY_PATH
ExecStart=$DEPLOY_PATH/venv/bin/python $DEPLOY_PATH/backend/app.py
ExecReload=/bin/kill -s HUP \$MAINPID
Restart=always
RestartSec=10
TimeoutStopSec=30

# Environment variables
Environment=FLASK_HOST=0.0.0.0
Environment=FLASK_PORT=5000
Environment=FLASK_DEBUG=false
Environment=TMUX_SESSION_NAME=claude-session

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$DEPLOY_PATH

# Resource limits
LimitNOFILE=65536
MemoryMax=1G

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME"
    
    log_success "Systemd service created and enabled"
}

# Configure firewall (if ufw is available)
configure_firewall() {
    if command -v ufw &> /dev/null; then
        log_info "Configuring firewall..."
        
        # Allow port 5000
        ufw allow 5000/tcp comment "Claude Terminal Bridge"
        
        log_success "Firewall configured"
    fi
}

# Configure nginx (optional)
configure_nginx() {
    if [[ "$1" == "--nginx" ]] && command -v nginx &> /dev/null; then
        log_info "Configuring nginx reverse proxy..."
        
        local domain="${2:-localhost}"
        
        cat > "/etc/nginx/sites-available/$PROJECT_NAME" << EOF
server {
    listen 80;
    server_name $domain;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF
        
        # Enable site
        ln -sf "/etc/nginx/sites-available/$PROJECT_NAME" "/etc/nginx/sites-enabled/"
        nginx -t && systemctl reload nginx
        
        log_success "Nginx configured for domain: $domain"
    fi
}

# Start service
start_service() {
    log_info "Starting service..."
    
    systemctl start "$SERVICE_NAME"
    
    # Wait for service to start
    sleep 3
    
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        log_success "Service started successfully"
    else
        log_error "Service failed to start"
        systemctl status "$SERVICE_NAME" --no-pager
        return 1
    fi
}

# Run health check
health_check() {
    log_info "Running health check..."
    
    local url="http://localhost:5000/api/terminal/claude/status"
    local max_attempts=10
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -sf "$url" >/dev/null 2>&1; then
            log_success "Health check passed"
            return 0
        fi
        
        log_info "Health check attempt $attempt/$max_attempts..."
        sleep 2
        ((attempt++))
    done
    
    log_error "Health check failed"
    return 1
}

# Show deployment status
show_status() {
    echo
    log_info "Deployment Status"
    echo "=================="
    echo
    
    # Service status
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "Service: ${GREEN}RUNNING${NC}"
    else
        echo -e "Service: ${RED}STOPPED${NC}"
    fi
    
    # Port status
    if netstat -ln | grep -q ":5000 "; then
        echo -e "Port 5000: ${GREEN}LISTENING${NC}"
    else
        echo -e "Port 5000: ${RED}NOT LISTENING${NC}"
    fi
    
    # tmux session
    if sudo -u "$DEPLOY_USER" tmux has-session -t claude-session 2>/dev/null; then
        echo -e "Claude Session: ${GREEN}ACTIVE${NC}"
    else
        echo -e "Claude Session: ${YELLOW}INACTIVE${NC}"
    fi
    
    echo
    echo "URLs:"
    echo "  Local: http://localhost:5000/terminal"
    echo "  Network: http://$(hostname -I | awk '{print $1}'):5000/terminal"
    echo
    echo "Logs:"
    echo "  Service: journalctl -fu $SERVICE_NAME"
    echo "  tmux: sudo -u $DEPLOY_USER $DEPLOY_PATH/scripts/tmux-session.sh monitor"
    echo
    echo "Management:"
    echo "  Start: systemctl start $SERVICE_NAME"
    echo "  Stop: systemctl stop $SERVICE_NAME"
    echo "  Restart: systemctl restart $SERVICE_NAME"
    echo
}

# Show help
show_help() {
    echo "Claude Terminal Bridge - Deployment Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --nginx [domain]     Configure nginx reverse proxy"
    echo "  --backup            Create backup before deployment"
    echo "  --no-service        Skip systemd service creation"
    echo "  --status            Show deployment status only"
    echo "  --help              Show this help message"
    echo
    echo "Environment Variables:"
    echo "  DEPLOY_USER         User to run the service (default: current user)"
    echo "  DEPLOY_HOST         Target host (default: localhost)"
    echo "  DEPLOY_PATH         Deployment path (default: /opt/claude-terminal-bridge)"
    echo
    echo "Examples:"
    echo "  $0                  # Basic deployment"
    echo "  $0 --nginx example.com  # Deploy with nginx"
    echo "  $0 --status         # Show status only"
    echo
}

# Main deployment function
main() {
    echo
    log_info "Claude Terminal Bridge Deployment"
    echo "=================================="
    echo
    
    # Parse arguments
    local create_nginx=false
    local nginx_domain=""
    local create_backup=false
    local create_service_flag=true
    local status_only=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --nginx)
                create_nginx=true
                nginx_domain="${2:-localhost}"
                shift 2
                ;;
            --backup)
                create_backup=true
                shift
                ;;
            --no-service)
                create_service_flag=false
                shift
                ;;
            --status)
                status_only=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Show status only
    if [[ "$status_only" == true ]]; then
        show_status
        exit 0
    fi
    
    # Main deployment process
    check_permissions
    
    if [[ "$create_backup" == true ]]; then
        create_backup
    fi
    
    stop_service
    deploy_files
    install_dependencies
    configure_tmux
    
    if [[ "$create_service_flag" == true ]]; then
        create_service
    fi
    
    configure_firewall
    
    if [[ "$create_nginx" == true ]]; then
        configure_nginx --nginx "$nginx_domain"
    fi
    
    start_service
    health_check
    show_status
    
    log_success "Deployment completed successfully!"
}

# Run main function
main "$@"
