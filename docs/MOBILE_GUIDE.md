# Claude Terminal Bridge - Mobile Usage Guide

## iPhone PWA Setup and Usage

### Installation on iPhone

1. **Open Safari** and navigate to your Claude Terminal Bridge URL:
   ```
   http://your-server-ip:5000/terminal
   ```

2. **Add to Home Screen**:
   - Tap the Share button (square with arrow up)
   - Scroll down and tap "Add to Home Screen"
   - Edit the name if desired (default: "Claude Terminal")
   - Tap "Add"

3. **Launch PWA**:
   - Find the Claude Terminal icon on your home screen
   - Tap to launch in full-screen mode
   - The app will load with native-like experience

### iPhone Interface Features

#### Header Controls
- **☰ Menu Button**: Opens side navigation drawer
- **Title**: Shows "Claude Code Terminal"
- **A- / A+ Buttons**: Adjust font size (8-32px range)
- **Status Indicator**: Shows connection status with colored dot

#### Terminal Area
- **Touch Scrolling**: Natural iOS momentum scrolling
- **Text Selection**: Long-press to select text
- **Copy/Paste**: Standard iOS text selection gestures
- **Auto-scroll**: Automatically scrolls to bottom with new content

#### Input Controls
- **Message Field**: Type commands and messages to Claude
- **ESC Button**: Red button sends escape sequences
- **Send Button**: Blue paper plane icon sends commands
- **Enter Key**: Alternative to Send button

### iPhone-Specific Optimizations

#### Text Input Enhancements
- **16px Font Size**: Prevents iOS zoom on input focus
- **Disabled Autocorrect**: No unwanted text corrections
- **Disabled Autocapitalize**: Preserves command case
- **Custom Keyboard**: "Send" button on iOS keyboard

#### Touch and Gesture Support
- **Text Selection Protection**: Updates pause during text selection
- **Touch Callout Enabled**: Allows text copying and pasting
- **Momentum Scrolling**: Smooth native-like scrolling behavior
- **Viewport Fixed**: No unwanted zooming or scaling

#### Performance Optimizations
- **Efficient DOM Updates**: Minimal reflows and repaints
- **Background Processing**: Continues polling when backgrounded
- **Memory Management**: Automatic cleanup of old content
- **Battery Optimization**: Reduced polling when not visible

---

## Android Usage

### PWA Installation on Android

1. **Open Chrome** and visit the terminal URL
2. **Install Prompt**: Chrome may show "Add to Home Screen" banner
3. **Manual Installation**:
   - Tap the three dots menu (⋮)
   - Select "Add to Home Screen"
   - Confirm installation
4. **Launch**: Tap the icon from home screen or app drawer

### Android Interface Adaptations

#### Material Design Elements
- **Navigation**: Follows Android navigation patterns
- **Touch Targets**: 48dp minimum touch target size
- **Ripple Effects**: Visual feedback on button presses
- **Status Bar**: Integrates with Android status bar theming

#### System Integration
- **Back Button**: Properly handles Android back navigation
- **Notifications**: Can display system notifications (if enabled)
- **Share Target**: Can receive shared text from other apps
- **Intent Handling**: Supports claude:// URL scheme

---

## Desktop Browser Usage

### Keyboard Shortcuts

#### Global Shortcuts
- **Enter**: Send command
- **Escape**: Send ESC sequence to terminal
- **Ctrl + Plus**: Increase font size
- **Ctrl + Minus**: Decrease font size
- **Ctrl + 0**: Reset font size to default

#### Navigation
- **Tab**: Move between UI elements
- **Shift + Tab**: Reverse tab navigation
- **Space**: Activate focused button
- **Arrow Keys**: Scroll terminal (when focused)

### Mouse Support
- **Scroll Wheel**: Scroll terminal output
- **Text Selection**: Click and drag to select text
- **Right Click**: Context menu for copy/paste
- **Double Click**: Select word
- **Triple Click**: Select line

### Browser-Specific Features

#### Chrome/Edge
- **PWA Installation**: Install as desktop app
- **Notifications**: Desktop notification support
- **Fullscreen**: F11 for immersive experience
- **Developer Tools**: F12 for debugging

#### Firefox
- **Enhanced Privacy**: Tracking protection
- **Custom Themes**: Supports browser themes
- **Accessibility**: Enhanced screen reader support
- **Security**: Advanced security features

#### Safari
- **Privacy**: Intelligent tracking prevention
- **Performance**: Optimized JavaScript engine
- **Touch Bar**: MacBook Pro touch bar integration
- **Handoff**: Continuity with iPhone/iPad

---

## Common Usage Patterns

### Daily Development Workflow

1. **Morning Setup**:
   ```
   Open Claude Terminal PWA → Check session status → Start coding
   ```

2. **Code Review**:
   ```
   Ask Claude to review code → Copy/paste code blocks → Get feedback
   ```

3. **Debugging**:
   ```
   Share error messages → Get debugging suggestions → Implement fixes
   ```

4. **Documentation**:
   ```
   Generate documentation → Format output → Copy to external tools
   ```

### Mobile-Specific Workflows

#### Commute Coding
- **Quick Questions**: Ask Claude short development questions
- **Code Snippets**: Get small code examples
- **Error Solutions**: Debug issues on the go
- **Learning**: Explore new concepts and technologies

#### Emergency Fixes
- **Remote Debugging**: Debug production issues
- **Quick Patches**: Write small fixes
- **Team Communication**: Get help and share solutions
- **Documentation**: Update docs and comments

---

## Troubleshooting

### Common Issues on Mobile

#### Text Input Problems
**Issue**: Input field doesn't focus properly
**Solution**: 
- Tap directly on the input area
- Ensure browser is updated
- Try refreshing the page

**Issue**: Autocorrect interfering with commands
**Solution**: 
- Text autocorrect is disabled by default
- If still occurring, check browser settings
- Use the ESC button for terminal commands

#### Scrolling Issues
**Issue**: Can't scroll terminal output
**Solution**:
- Try two-finger scroll
- Ensure you're not selecting text
- Check if content is actually scrollable

**Issue**: Auto-scroll not working
**Solution**:
- Check auto-scroll setting in menu
- Manually scroll to bottom
- Refresh if problem persists

#### Connection Problems
**Issue**: "Disconnected" status
**Solution**:
- Check network connection
- Verify server is running
- Try refreshing the page
- Check server URL is correct

### Performance Issues

#### Slow Response Times
**Causes**: 
- Network latency
- Server overload
- Large terminal output

**Solutions**:
- Check network signal strength
- Clear terminal output (menu option)
- Restart Claude session
- Reduce font size for better performance

#### Memory Usage
**Symptoms**:
- Browser slowing down
- App crashes or reloads
- Laggy scrolling

**Solutions**:
- Refresh the page periodically
- Close other browser tabs
- Clear terminal output regularly
- Restart the PWA

---

## Advanced Mobile Features

### Offline Capability

The PWA includes basic offline support:
- **Cached Interface**: UI loads without internet
- **Command Queuing**: Commands saved until connection restored
- **Status Indication**: Clear offline/online status
- **Automatic Sync**: Reconnects when network available

### Shortcuts and Quick Actions

#### iOS Shortcuts App Integration
Create custom shortcuts for common tasks:
- **Quick Questions**: Pre-filled common questions
- **Code Review**: Automated code submission
- **Status Check**: Session health monitoring
- **Emergency Commands**: Critical system commands

#### Android App Shortcuts
Long-press the app icon for quick actions:
- **New Session**: Start fresh Claude session
- **Recent Commands**: Access command history
- **Settings**: Quick access to preferences
- **Help**: Direct link to documentation

### Multi-Device Synchronization

While the terminal session is server-based, settings sync across devices:
- **Font Size**: Preserved across installations
- **Auto-scroll**: Setting synced via localStorage
- **Theme Preferences**: Dark/light mode preferences
- **Shortcuts**: Custom shortcuts backed up

---

## Accessibility Features

### Screen Reader Support
- **ARIA Labels**: All interactive elements labeled
- **Semantic HTML**: Proper heading and landmark structure
- **Focus Management**: Logical tab order
- **Live Regions**: Terminal updates announced

### Visual Accessibility
- **High Contrast**: Supports high contrast mode
- **Font Scaling**: Respects system font size
- **Color Coding**: Not relied upon alone for information
- **Focus Indicators**: Clear focus outlines

### Motor Accessibility
- **Large Touch Targets**: Minimum 44px touch areas
- **Voice Control**: Compatible with voice navigation
- **Switch Control**: Supports iOS/Android switch control
- **Reduced Motion**: Respects motion preference settings

This comprehensive mobile guide ensures users can effectively use Claude Terminal Bridge across all devices and platforms, with optimizations for each specific environment.
