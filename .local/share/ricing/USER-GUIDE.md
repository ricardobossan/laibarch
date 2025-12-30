# Laibarch User Guide

Quick reference for using your Laibarch system.

## Essential Keyboard Shortcuts

**MODKEY** = Super/Windows key

### Applications
- `Super+Enter` - Terminal
- `Super+Shift+D` - Application launcher
- `Super+V` - Clipboard history
- `Super+W` - Web browser
- `Super+Shift+M` - Music player

### Window Management
- `Super+Q` - Close window
- `Super+J/K` - Navigate windows
- `Super+H/L` - Resize windows
- `Super+E` - Fullscreen
- `Super+Tab` - Last workspace

### Workspaces
- `Super+[1-9]` - Switch workspace
- `Super+Shift+[1-9]` - Move window to workspace

### Media Controls
- `Super+P` - Play/pause music
- `Super+[` - Previous track
- `Super+]` - Next track
- `Super+=/-` - Volume up/down
- `Super+Shift++/_` - Brightness up/down

### Screenshots
- `Super+Shift+S` - Select area (saved + clipboard)
- `Super+Shift+P` - Fullscreen (saved)

### Power
- `Super+Shift+Escape` - Turn off displays
- `Super+Shift+O` - Turn on displays
- `Super+Shift+Q` - Logout

## Music Player (ncmpcpp)

Navigate with vim keys: `h/j/k/l`
- `/` - Search forward
- `?` - Search backward
- `Space` - Play/pause
- `d` - Delete from playlist

## System Configuration

Config locations:
- DWL keybindings: `~/.local/src/dwl/config.def.h`
- Shell: `~/.config/zsh/.zshrc`
- Terminal: `~/.config/alacritty/alacritty.toml`
- Music: `~/.config/ncmpcpp/config`

After editing DWL config, rebuild:
```bash
cd ~/.local/src/dwl
yes | rm config.h && sudo make install
```
Then logout and login.
