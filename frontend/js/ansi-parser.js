/**
 * ANSI Escape Sequence Parser for Terminal Output
 * Converts ANSI codes to HTML with proper color and formatting
 */

class ANSIParser {
    constructor() {
        // ANSI color mappings
        this.colors = {
            // Standard colors (30-37, 40-47)
            '30': 'ansi-black',       '40': 'ansi-bg-black',
            '31': 'ansi-red',         '41': 'ansi-bg-red',
            '32': 'ansi-green',       '42': 'ansi-bg-green',
            '33': 'ansi-yellow',      '43': 'ansi-bg-yellow',
            '34': 'ansi-blue',        '44': 'ansi-bg-blue',
            '35': 'ansi-magenta',     '45': 'ansi-bg-magenta',
            '36': 'ansi-cyan',        '46': 'ansi-bg-cyan',
            '37': 'ansi-white',       '47': 'ansi-bg-white',
            
            // Bright colors (90-97, 100-107)
            '90': 'ansi-bright-black',   '100': 'ansi-bg-bright-black',
            '91': 'ansi-bright-red',     '101': 'ansi-bg-bright-red',
            '92': 'ansi-bright-green',   '102': 'ansi-bg-bright-green',
            '93': 'ansi-bright-yellow',  '103': 'ansi-bg-bright-yellow',
            '94': 'ansi-bright-blue',    '104': 'ansi-bg-bright-blue',
            '95': 'ansi-bright-magenta', '105': 'ansi-bg-bright-magenta',
            '96': 'ansi-bright-cyan',    '106': 'ansi-bg-bright-cyan',
            '97': 'ansi-bright-white',   '107': 'ansi-bg-bright-white'
        };
        
        // Text formatting codes
        this.formatting = {
            '1': 'ansi-bold',
            '2': 'ansi-dim',
            '3': 'ansi-italic',
            '4': 'ansi-underline'
        };
        
        // Current state
        this.currentClasses = [];
        this.openSpans = 0;
    }
    
    /**
     * Parse ANSI escape sequences and convert to HTML
     * @param {string} text - Raw text with ANSI codes
     * @returns {string} HTML with ANSI codes converted to CSS classes
     */
    parse(text) {
        if (!text) return '';
        
        // Reset state
        this.currentClasses = [];
        this.openSpans = 0;
        
        // Escape HTML first
        let html = this.escapeHtml(text);
        
        // Parse ANSI escape sequences
        html = this.parseAnsiCodes(html);
        
        // Close any remaining open spans
        html += '</span>'.repeat(this.openSpans);
        
        // Ensure black text is visible
        html = this.fixBlackText(html);
        
        return html;
    }
    
    /**
     * Escape HTML characters
     * @param {string} text - Raw text
     * @returns {string} HTML-escaped text
     */
    escapeHtml(text) {
        const htmlEscapes = {
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#39;'
        };
        
        return text.replace(/[&<>"']/g, char => htmlEscapes[char]);
    }
    
    /**
     * Parse ANSI escape sequences
     * @param {string} html - HTML-escaped text
     * @returns {string} HTML with ANSI codes converted
     */
    parseAnsiCodes(html) {
        // ANSI escape sequence regex: \x1b[...m
        const ansiRegex = /\x1b\[([0-9;]+)m/g;
        
        return html.replace(ansiRegex, (match, codes) => {
            return this.processAnsiCodes(codes);
        });
    }
    
    /**
     * Process ANSI codes and return appropriate HTML
     * @param {string} codes - Semicolon-separated ANSI codes
     * @returns {string} HTML span tags with classes
     */
    processAnsiCodes(codes) {
        const codeList = codes.split(';').map(Number);
        let html = '';
        
        for (const code of codeList) {
            if (code === 0) {
                // Reset all formatting
                html += this.resetFormatting();
            } else if (this.colors[code]) {
                // Color code
                this.currentClasses.push(this.colors[code]);
            } else if (this.formatting[code]) {
                // Formatting code
                this.currentClasses.push(this.formatting[code]);
            } else if (code === 38 || code === 48) {
                // 256-color or RGB color (simplified handling)
                // For now, we'll just ignore these advanced color codes
                continue;
            }
        }
        
        // Create span with current classes
        if (this.currentClasses.length > 0) {
            const classString = this.currentClasses.join(' ');
            html += `<span class="${classString}">`;
            this.openSpans++;
        }
        
        return html;
    }
    
    /**
     * Reset all formatting
     * @returns {string} HTML to close current spans
     */
    resetFormatting() {
        const html = '</span>'.repeat(this.openSpans);
        this.currentClasses = [];
        this.openSpans = 0;
        return html;
    }
    
    /**
     * Fix black text to be visible on dark background
     * @param {string} html - HTML content
     * @returns {string} HTML with black text fixed
     */
    fixBlackText(html) {
        // Replace pure black with a visible gray
        html = html.replace(/color:\s*#000000/gi, 'color: #999999');
        html = html.replace(/color:\s*rgb\(0,\s*0,\s*0\)/gi, 'color: #999999');
        html = html.replace(/background-color:\s*#ffffff/gi, 'background-color: #333333');
        
        return html;
    }
    
    /**
     * Strip all ANSI codes from text (for logging/debugging)
     * @param {string} text - Text with ANSI codes
     * @returns {string} Plain text without ANSI codes
     */
    stripAnsi(text) {
        if (!text) return '';
        
        // Remove all ANSI escape sequences
        return text.replace(/\x1b\[[0-?]*[ -/]*[@-~]/g, '');
    }
    
    /**
     * Get color name from ANSI code
     * @param {number} code - ANSI color code
     * @returns {string} Color name or empty string
     */
    getColorName(code) {
        const colorNames = [
            'black', 'red', 'green', 'yellow',
            'blue', 'magenta', 'cyan', 'white'
        ];
        
        if (code >= 0 && code <= 7) {
            return colorNames[code];
        } else if (code >= 8 && code <= 15) {
            return 'bright-' + colorNames[code - 8];
        }
        
        return '';
    }
}

// Create global instance
const ansiParser = new ANSIParser();

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { ANSIParser, ansiParser };
}
