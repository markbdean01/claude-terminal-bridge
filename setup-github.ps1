# GitHub Repository Setup Script for Claude Terminal Bridge
# This script automates as much as possible for GitHub Desktop upload

Write-Host "🚀 Claude Terminal Bridge - GitHub Setup Assistant" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""

# Check if GitHub Desktop is installed
$githubDesktopPath = "$env:LOCALAPPDATA\GitHubDesktop\GitHubDesktop.exe"
if (Test-Path $githubDesktopPath) {
    Write-Host "✅ GitHub Desktop found!" -ForegroundColor Green
} else {
    Write-Host "❌ GitHub Desktop not found. Please install it first:" -ForegroundColor Red
    Write-Host "   https://desktop.github.com/" -ForegroundColor Yellow
    exit 1
}

# Get current directory
$repoPath = Get-Location
Write-Host "📁 Repository path: $repoPath" -ForegroundColor Cyan

# Check if we're in the correct directory
if (!(Test-Path "README.md") -or !(Test-Path "backend") -or !(Test-Path "frontend")) {
    Write-Host "❌ Not in Claude Terminal Bridge directory!" -ForegroundColor Red
    Write-Host "   Please navigate to the claude-terminal-bridge folder first" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Repository files found!" -ForegroundColor Green

# Launch GitHub Desktop with specific folder
Write-Host ""
Write-Host "🚀 Launching GitHub Desktop..." -ForegroundColor Blue
Start-Process $githubDesktopPath -ArgumentList $repoPath

Write-Host ""
Write-Host "📋 NEXT STEPS IN GITHUB DESKTOP:" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. 📂 ADD REPOSITORY:" -ForegroundColor White
Write-Host "   - File → Add Local Repository" -ForegroundColor Gray
Write-Host "   - Choose this folder: $repoPath" -ForegroundColor Gray
Write-Host ""
Write-Host "2. 📝 COMMIT FILES:" -ForegroundColor White
Write-Host "   - Summary: 'Initial release of Claude Terminal Bridge'" -ForegroundColor Gray
Write-Host "   - Click 'Commit to main'" -ForegroundColor Gray
Write-Host ""
Write-Host "3. 🌐 PUBLISH TO GITHUB:" -ForegroundColor White
Write-Host "   - Click 'Publish repository'" -ForegroundColor Gray
Write-Host "   - Name: 'claude-terminal-bridge'" -ForegroundColor Gray
Write-Host "   - Make sure 'Keep this code private' is UNCHECKED" -ForegroundColor Gray
Write-Host "   - Click 'Publish Repository'" -ForegroundColor Gray
Write-Host ""
Write-Host "4. 🏷️ ADD TOPICS (on GitHub.com):" -ForegroundColor White
Write-Host "   - claude-code, terminal, iphone, pwa, tmux" -ForegroundColor Gray
Write-Host "   - raspberry-pi, boat-automation, marine-iot" -ForegroundColor Gray
Write-Host ""
Write-Host "🎉 Your repository will be live at:" -ForegroundColor Green
Write-Host "   https://github.com/yourusername/claude-terminal-bridge" -ForegroundColor Cyan
Write-Host ""

# Open GitHub in browser for topics
Write-Host "🌐 Opening GitHub.com for you..." -ForegroundColor Blue
Start-Process "https://github.com/new"

Write-Host "✨ Setup complete! Follow the steps above in GitHub Desktop." -ForegroundColor Green
