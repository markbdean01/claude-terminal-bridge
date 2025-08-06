#!/usr/bin/env python3
"""
Claude Terminal Bridge - Main Flask Application
Web-based terminal interface for Claude Code with mobile PWA support
"""

import os
import sys
import logging
from flask import Flask, render_template, send_from_directory
from flask_cors import CORS

# Add backend directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from claude_terminal_api import claude_terminal_bp

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


def create_app():
    """Create and configure the Flask application"""
    app = Flask(__name__, template_folder="../frontend", static_folder="../frontend")

    # Enable CORS for development
    CORS(app)

    # Configuration
    app.config["SECRET_KEY"] = os.environ.get(
        "SECRET_KEY", "dev-secret-key-change-in-production"
    )
    app.config["DEBUG"] = os.environ.get("FLASK_DEBUG", "False").lower() == "true"

    # Register blueprints
    app.register_blueprint(claude_terminal_bp)

    @app.route("/")
    def index():
        """Redirect to terminal interface"""
        return send_from_directory("../frontend", "index.html")

    @app.route("/terminal")
    def terminal():
        """Terminal interface route"""
        return send_from_directory("../frontend", "index.html")

    @app.route("/manifest.json")
    def manifest():
        """PWA manifest"""
        return send_from_directory("../frontend", "manifest.json")

    # Static file handlers
    @app.route("/css/<path:filename>")
    def css_files(filename):
        return send_from_directory("../frontend/css", filename)

    @app.route("/js/<path:filename>")
    def js_files(filename):
        return send_from_directory("../frontend/js", filename)

    @app.route("/icons/<path:filename>")
    def icon_files(filename):
        return send_from_directory("../frontend/icons", filename)

    @app.errorhandler(404)
    def not_found(error):
        return {"error": "Not found"}, 404

    @app.errorhandler(500)
    def internal_error(error):
        logger.error(f"Internal server error: {error}")
        return {"error": "Internal server error"}, 500

    return app


def main():
    """Main entry point"""
    app = create_app()

    # Get configuration from environment
    host = os.environ.get("FLASK_HOST", "0.0.0.0")
    port = int(os.environ.get("FLASK_PORT", 5000))
    debug = os.environ.get("FLASK_DEBUG", "False").lower() == "true"

    logger.info(f"Starting Claude Terminal Bridge on {host}:{port}")
    logger.info(f"Debug mode: {debug}")
    logger.info(f"Terminal interface: http://{host}:{port}/terminal")

    try:
        app.run(host=host, port=port, debug=debug)
    except KeyboardInterrupt:
        logger.info("Shutting down Claude Terminal Bridge")
    except Exception as e:
        logger.error(f"Failed to start server: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
