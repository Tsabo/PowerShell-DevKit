# PowerShell Environment Automation Scripts

This directory contains streamlined automation scripts for setting up, validating, and maintaining your PowerShell development environment on **Windows** and **macOS**.

> **📖 For Contributors**: See [DEVELOPER-REFERENCE.md](../DEVELOPER-REFERENCE.md) for validation, testing, and contribution guidelines.

## 🖥️ Platform Support

| Script | Windows | macOS | Description |
|--------|---------|-------|-------------|
| `Setup.ps1` | ✅ | ❌ | Windows setup using winget |
| `Setup-macOS.ps1` | ❌ | ✅ | macOS setup using Homebrew |
| `Test.ps1` | ✅ | ❌ | Windows environment validation |
| `Test-macOS.ps1` | ❌ | ✅ | macOS environment validation |
| `Update.ps1` | ✅ | ❌ | Update Windows packages/modules |
| `Update-macOS.ps1` | ❌ | ✅ | Update macOS packages/modules |
| `Deploy-Terminal.ps1` | ✅ | ❌ | Windows Terminal configuration |
| `Validate-Code.ps1` | ✅ | ✅ | PSScriptAnalyzer validation |
| `Components.psm1` | ✅ | ✅ | Shared cross-platform functions |

## 📁 Scripts Overview

### 🚀 Setup.ps1 (Windows)
**Windows setup script** - Complete PowerShell environment installation using winget.

#### Features:
- Installs all required tools (oh-my-posh, fzf, zoxide, Microsoft Edit)
- Installs PowerShell modules (PSFzf, Terminal-Icons, F7History, posh-git)
- Deploys PowerShell profile and custom modules
- Configures Windows Terminal settings with Nerd Font
- Deploys Yazi file manager configuration
- Installs optional components (gsudo, PowerColorLS)
- Provides detailed installation summary

#### Usage:
```powershell
# Complete setup (recommended for new machines)
.\Setup.ps1

# Skip optional components
.\Setup.ps1 -SkipOptional

# Use different font
.\Setup.ps1 -FontName "MesloLGM NF"
```

---

### 🍎 Setup-macOS.ps1 (macOS)
**macOS setup script** - Complete PowerShell environment installation using Homebrew.

#### Features:
- Auto-installs Homebrew if needed
- Installs core tools via Homebrew (oh-my-posh, fzf, zoxide, Microsoft Edit, glow)
- Installs CaskaydiaCove Nerd Font via Homebrew cask
- Installs PowerShell modules from PSGallery
- Deploys Yazi file manager with configuration
- Installs Yazi optional dependencies (ffmpeg, jq, fd, ripgrep, etc.)
- Cross-platform PowerShell profile deployment

#### Usage:
```powershell
# Complete macOS setup
./Setup-macOS.ps1

# Skip optional components
./Setup-macOS.ps1 -SkipOptional

# Show previous setup failures
./Setup-macOS.ps1 -ShowDetails
```

---

### ✅ Test.ps1 (Windows)
**Windows environment validator** - Comprehensive check of your PowerShell environment.

#### Features:
- Validates all tools and modules
- Checks PowerShell profile configuration
- Validates Windows Terminal font settings
- Shows version information
- Provides actionable error messages
- Exit codes for CI/CD integration

#### Usage:
```powershell
.\Test.ps1
```

#### Output Example:
```
═══ PowerShell ═══
  ✓ PowerShell (7.4.0)

═══ Winget Packages ═══
  ✓ oh-my-posh (21.0.0)
  ✓ fzf (0.46.0)
  ⊘ gsudo (optional - not installed)
  ...

Required Components: 9 / 9 installed
🎉 All required components are installed!
```

---

### 🔄 Update.ps1
**Update script** - Keeps all components current.

#### Features:
- Updates winget packages (oh-my-posh, fzf, zoxide, Microsoft Edit, etc.)
- Updates PowerShell modules
- Shows detailed update results
- Selective update options

#### Usage:
```powershell
# Update everything
.\Update.ps1

# Update only winget packages
.\Update.ps1 -WingetOnly

# Update only PowerShell modules
.\Update.ps1 -ModulesOnly
```

---

### 🍎 Test-macOS.ps1 (macOS)
**macOS environment validator** - Comprehensive check of your PowerShell environment on macOS.

#### Features:
- Validates Homebrew and all installed packages
- Checks PowerShell modules
- Validates CaskaydiaCove Nerd Font installation
- Checks PowerShell profile configuration
- Validates Yazi configuration and plugins
- Shows version information and success rate

#### Usage:
```powershell
./Test-macOS.ps1
```

#### Output Example:
```
━━━ Package Manager ━━━
  ✓ Homebrew (Homebrew 4.2.0)

━━━ Core Tools (Homebrew) ━━━
  ✓ oh-my-posh (21.0.0)
  ✓ fzf (0.46.0)
  ✓ Microsoft Edit (1.2.0)
  ...

Success Rate: 100%
🎉 All checks passed!
```

---

### 🍎 Update-macOS.ps1 (macOS)
**macOS update script** - Keeps all Homebrew packages and modules current.

#### Features:
- Updates Homebrew and all installed packages
- Updates PowerShell modules from PSGallery
- Updates Yazi plugins via `ya pkg`
- Updates Yazi configuration from git
- Selective update options
- Automatic cleanup of old versions

#### Usage:
```powershell
# Update everything
./Update-macOS.ps1

# Update only Homebrew packages
./Update-macOS.ps1 -BrewOnly

# Update only PowerShell modules
./Update-macOS.ps1 -ModulesOnly

# Update only Yazi components
./Update-macOS.ps1 -YaziOnly
```

---

### 🖥️ Deploy-Terminal.ps1 (Windows Only)
**Windows Terminal configurator** - Applies your preferred terminal settings.

#### Features:
- Sets CaskaydiaCove Nerd Font as default
- Configures initial window width (135 columns)
- Preserves all existing profiles and settings
- Creates automatic backups
- Non-destructive merging

#### Usage:
```powershell
# Deploy with backup (safe)
.\Deploy-Terminal.ps1

# Deploy without backup
.\Deploy-Terminal.ps1 -NoBackup

# Force complete replacement
.\Deploy-Terminal.ps1 -Force -NoBackup
```

---

## 📋 Components Managed

### Required Components:
1. **PowerShell 7+** - Modern PowerShell
2. **oh-my-posh** - Prompt theme engine
3. **CascadiaCode Font** - Nerd Font for icons
4. **fzf** - Fuzzy finder
5. **PSFzf** - PowerShell wrapper for fzf
6. **Terminal-Icons** - File/folder icons in terminal
7. **F7History** - Enhanced history search
8. **zoxide** - Smart directory jumper
9. **posh-git** - Git integration for PowerShell

### Optional Components:
1. **gsudo** - Sudo for Windows
2. **PowerColorLS** - Colorized ls alternative

---

## 🎯 Quick Start Guide

### First Time Setup:
```powershell
# 1. Navigate to your repository
cd "path\to\your\repository"

# 2. Run the main setup script
.\Scripts\Setup.ps1

# 3. Restart PowerShell

# 4. Validate the setup
.\Scripts\Test.ps1
```

### Regular Maintenance:
```powershell
# Update all components
.\Scripts\Update.ps1

# Validate environment health
.\Scripts\Test.ps1

# Deploy Windows Terminal settings
.\Scripts\Deploy-Terminal.ps1
```

---

## 🔧 Post-Installation Steps

After running the setup script, you'll need to:

1. **Restart PowerShell** - New PATH entries require a restart
2. **Configure Terminal Font**:
   - Windows Terminal: Settings → Profiles → Defaults → Appearance → Font face → "CaskaydiaCove Nerd Font"
   - VS Code Terminal: Settings → Terminal → Integrated: Font Family → "CaskaydiaCove Nerd Font"

3. **Configure oh-my-posh theme** (if not already in profile):
   ```powershell
   # Add to your profile
   oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/jandedobbeleer.omp.json' | Invoke-Expression
   ```

4. **Import modules in profile** (if not already configured):
   ```powershell
   # Your profile already has these, but for reference:
   Import-Module Terminal-Icons
   Import-Module posh-git
   Import-Module F7History
   Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
   Invoke-Expression (& { (zoxide init powershell | Out-String) })
   ```

---

## 📊 Comparison: Your Current Setup vs. Guide

### ✅ Already Configured:
- [x] PowerShell 7+
- [x] oh-my-posh
- [x] PSFzf (versions 2.6.1 and 2.7.2)
- [x] Terminal-Icons (version 0.11.0)
- [x] F7History (version 1.4.7)
- [x] zoxide
- [x] posh-git (version 1.1.0)
- [x] PowerColorLS

### ℹ️ Additional Components in Your Setup:
- EmojiTools
- git-aliases
- Microsoft.PowerShell.ConsoleGuiTools
- Microsoft.PowerToys.Configure
- Microsoft.WinGet.Client
- Pester
- PSScriptAnalyzer
- WslCompact
- DotNetVersionLister

Your setup is actually **more comprehensive** than your OneNote guide! The automation scripts will help you maintain and replicate this environment on new machines.

---

## 🚨 Troubleshooting

### Script Execution Policy
If you get an error about script execution:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Winget Not Found
Install App Installer from Microsoft Store or:
```powershell
# Windows 10/11 with Windows Package Manager
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
```

### Module Installation Fails
Ensure you have PSGallery registered:
```powershell
Register-PSRepository -Default -InstallationPolicy Trusted
```

### Path Not Updated
After installing winget packages, you may need to:
```powershell
# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

---

## 📝 Notes

- **Admin Rights**: Some operations (like font installation) may require admin rights
- **Nerd Fonts**: CascadiaCode font from winget includes Nerd Font glyphs
- **Profile Location**: Your profile is at `$PROFILE` (typically `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`)
- **Backup**: These scripts check for existing installations and skip them, so they're safe to run multiple times

---

## 🔗 Useful Links

- [Oh My Posh Documentation](https://ohmyposh.dev/)
- [PSFzf GitHub](https://github.com/kelleyma49/PSFzf)
- [Terminal-Icons GitHub](https://github.com/devblackops/Terminal-Icons)
- [posh-git GitHub](https://github.com/dahlbyk/posh-git)
- [zoxide GitHub](https://github.com/ajeetdsouza/zoxide)
- [Nerd Fonts](https://www.nerdfonts.com/)

---

## 📄 License

These scripts are provided as-is for your personal use. Feel free to modify them to suit your needs!
