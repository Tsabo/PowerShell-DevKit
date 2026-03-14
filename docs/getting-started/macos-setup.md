# macOS Setup Guide

This guide will help you set up PowerShell DevKit on your MacBook, bringing the same powerful PowerShell development experience you have on Windows.

## Prerequisites

### Required
- **macOS 10.15 (Catalina) or later**
- **PowerShell 7.0+** - [Install from Homebrew](#install-powershell-7)
- **Internet connection** - For downloading packages

### Install PowerShell 7

If you don't have PowerShell 7 installed yet:

```bash
# Install Homebrew if needed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install PowerShell 7
brew install --cask powershell

# Launch PowerShell
pwsh
```

## Quick Start

Once PowerShell 7 is installed:

```powershell
# 1. Clone the repository
git clone https://github.com/Tsabo/PowerShell-DevKit.git
cd PowerShell-DevKit

# 2. Run macOS setup
./Scripts/Setup-macOS.ps1

# 3. Validate installation
./Scripts/Test-macOS.ps1

# 4. Keep everything updated
./Scripts/Update-macOS.ps1
```

## What Gets Installed

### Package Manager
- **Homebrew** - The missing package manager for macOS (auto-installed if needed)

### Core Tools
All installed via Homebrew:
- **oh-my-posh** - Beautiful, informative prompt themes
- **CaskaydiaCove Nerd Font** - Font with icon support
- **fzf** - Fuzzy finder for files and command history
- **zoxide** - Smart directory navigation
- **Microsoft Edit** - Modern text editor from Microsoft
- **glow** - Markdown renderer for terminal
- **yazi** - Terminal file manager with git integration

### PowerShell Modules
Installed from PowerShell Gallery:
- **PSFzf** - PowerShell integration for fzf
- **Terminal-Icons** - File and folder icons in terminal
- **F7History** - Enhanced command history
- **posh-git** - Git integration for PowerShell
- **PowerColorLS** (optional) - Colorful directory listings

### Yazi Optional Dependencies
Automatically installed for enhanced functionality:
- **ffmpeg** - Video thumbnails
- **7zip** - Archive previews
- **jq** - JSON processing
- **poppler** - PDF support
- **fd** - Fast file search
- **ripgrep** - Text search
- **imagemagick** - Image processing

## Configuration

### Terminal Font Setup

After installation, configure your terminal to use the CaskaydiaCove Nerd Font:

#### iTerm2
1. Open Preferences (⌘,)
2. Go to Profiles → Text
3. Change Font to: **CaskaydiaCove Nerd Font Mono**
4. Set size to 12-14pt

#### Terminal.app
1. Open Preferences (⌘,)
2. Select your profile
3. Click Font → Change
4. Select **CaskaydiaCove Nerd Font Mono**
5. Set size to 12-14pt

#### VS Code Terminal
Add to your `settings.json`:
```json
{
  "terminal.integrated.fontFamily": "CaskaydiaCove Nerd Font Mono",
  "terminal.integrated.fontSize": 13
}
```

### PowerShell Profile

The setup automatically deploys your PowerShell profile to:
- `~/.config/powershell/Microsoft.PowerShell_profile.ps1`

Or on some systems:
- `~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`

You can check your profile location with:
```powershell
$PROFILE
```

### oh-my-posh Themes

Custom themes are deployed to:
- `~/.config/powershell/Posh/`

To change your theme, edit your profile and modify the oh-my-posh initialization line.

### Yazi Configuration

Yazi configuration is cloned to:
- `~/.config/yazi/`

This includes custom themes, plugins, and keybindings.

## Differences from Windows

### What Works the Same
✅ PowerShell profile and scripts
✅ All PowerShell modules (PSFzf, Terminal-Icons, posh-git, etc.)
✅ oh-my-posh themes and configuration
✅ Yazi file manager with plugins
✅ Command-line tools (fzf, zoxide, glow)
✅ Git integration

### What's Different
- **Package Manager**: Uses Homebrew instead of winget
- **Terminal**: Uses iTerm2/Terminal.app instead of Windows Terminal
- **Font Installation**: Via Homebrew cask instead of oh-my-posh font installer
- **Config Paths**:
  - Windows: `$env:APPDATA` and `$env:LOCALAPPDATA`
  - macOS: `~/.config` and `~/Library`

### Not Available on macOS
❌ **Windows Terminal** - Use iTerm2 or Terminal.app instead
❌ **gsudo** - Native `sudo` works on macOS
❌ **Scoop package manager** - Not needed on macOS

## Maintenance

### Update Everything
```powershell
./Scripts/Update-macOS.ps1
```

### Update Specific Components
```powershell
# Only Homebrew packages
./Scripts/Update-macOS.ps1 -BrewOnly

# Only PowerShell modules
./Scripts/Update-macOS.ps1 -ModulesOnly

# Only Yazi components
./Scripts/Update-macOS.ps1 -YaziOnly
```

### Validate Environment
```powershell
./Scripts/Test-macOS.ps1
```

## Synchronization Between Windows and macOS

Since most of the PowerShell configuration is cross-platform, you can:

1. **Keep scripts in sync** via the git repository
2. **Share PowerShell modules** - they work on both platforms
3. **Sync oh-my-posh themes** - compatible across platforms
4. **Share Yazi configurations** - works on both

### Using OneDrive or iCloud

The profile deployment automatically detects OneDrive on Windows. For macOS with iCloud:

```powershell
# Link your profile location to iCloud Drive
ln -s ~/Library/Mobile\ Documents/com~apple~CloudDocs/PowerShell ~/.config/powershell
```

This keeps your custom profile in sync across devices.

## Troubleshooting

### Homebrew Installation Issues

If Homebrew installation fails:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation, add Homebrew to your PATH:
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### PowerShell Module Errors

If module installation fails:
```powershell
# Update PowerShellGet
Install-Module PowerShellGet -Force -AllowClobber -Scope CurrentUser

# Check PowerShell Gallery connectivity
Test-NetConnection powershellgallery.com -Port 443
```

### Font Not Showing Up

After installing the font:
1. Restart your terminal application completely
2. Verify font installation: Check `~/Library/Fonts` for CaskaydiaCove files
3. Select the font manually in terminal preferences

### oh-my-posh Not Working

```powershell
# Verify oh-my-posh is in PATH
which oh-my-posh

# If not found, restart PowerShell or add Homebrew to PATH:
eval "$(/opt/homebrew/bin/brew shellenv)"

# Check version
oh-my-posh version
```

### Yazi Configuration Issues

```powershell
# Check if configuration exists
Test-Path ~/.config/yazi

# Re-clone if needed
rm -rf ~/.config/yazi
git clone https://github.com/Tsabo/yazi_config.git ~/.config/yazi

# Update plugins
ya pkg update
```

## Getting Help

- **View setup failures**: `./Scripts/Setup-macOS.ps1 -ShowDetails`
- **Clear failure logs**: `./Scripts/Setup-macOS.ps1 -ClearLogs`
- **Validate environment**: `./Scripts/Test-macOS.ps1`

## Tips for macOS Users

### Recommended Terminal: iTerm2

iTerm2 is a powerful terminal replacement for macOS:
```bash
brew install --cask iterm2
```

**Why iTerm2?**
- Better font rendering
- Split panes and tabs
- Hotkey window (like Quake console)
- Extensive customization
- Better color support

### Keyboard Shortcuts

macOS uses different modifier keys:
- **⌘ (Command)** instead of Ctrl for most shortcuts
- **⌥ (Option)** for Alt-based shortcuts
- **⌃ (Control)** for terminal control sequences

### Performance Tips

1. **Exclude terminal from Spotlight**: System Preferences → Spotlight → Privacy
2. **Disable PowerShell telemetry**:
   ```powershell
   $env:POWERSHELL_TELEMETRY_OPTOUT = 1
   ```
3. **Use native commands when available**: macOS has native `ls`, `grep`, etc.

## Next Steps

Once your environment is set up:

1. **Customize your profile**: Edit `CustomProfile.ps1`
2. **Add custom modules**: Place them in `CustomModules/`
3. **Create custom scripts**: Place them in `CustomScripts/`
4. **Choose an oh-my-posh theme**: Browse themes at [ohmyposh.dev](https://ohmyposh.dev/docs/themes)
5. **Learn Yazi**: Try `yazi` in any directory to start the file manager

## Cross-Platform Development

Now that you have PowerShell DevKit on both Windows and macOS:

- Write scripts that work on both platforms using `$IsWindows`, `$IsMacOS`, `$IsLinux`
- Test your scripts on both platforms
- Share your configuration via git
- Use platform-specific logic when needed:

```powershell
if ($IsMacOS) {
    # macOS-specific code
    open $filePath
}
elseif ($IsWindows) {
    # Windows-specific code
    Start-Process $filePath
}
```

Happy cross-platform PowerShell development! 🎉
