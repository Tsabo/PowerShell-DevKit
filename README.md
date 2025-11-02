# 🚀 PowerShell DevKit

A complete, enterprise-grade PowerShell development environment automation suite with advanced Yazi integration, intelligent failure recovery, and component-based architecture.

[![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Architecture](https://img.shields.io/badge/Architecture-Component--Based-green.svg)](#-architecture)

## ✨ Features

### 🏗️ **Enterprise Architecture**
- **Component-Based Design** - Modular, maintainable, and extensible
- **Intelligent Failure Recovery** - Detailed logging with smart suggestions
- **Shared Component Library** - Single source of truth for all scripts
- **Comprehensive Testing** - Built-in validation and diagnostics

### 🎯 **Smart Automation**
- **One-Command Setup** - Complete environment in minutes
- **Automatic Updates** - Keep everything current with `Update.ps1`
- **Dependency Management** - Intelligent package manager integration
- **Failure Diagnostics** - Advanced troubleshooting with actionable suggestions

### 🗂️ **Modern Yazi Integration** ⭐ **NEW!**
- **Native Package Management** - Uses Yazi's built-in `ya pkg` system
- **Custom Plugin Fork** - Includes bug-fixed githead plugin
- **Git-Based Configuration** - Separate repository for easy sharing
- **SVG Support** - Optional resvg integration via Scoop
- **Automatic Updates** - Plugins and configuration stay current

### 🎨 **Rich Terminal Experience**
- **oh-my-posh Themes** - Beautiful, informative prompts
- **Git Integration** - Visual git status and branch information
- **Smart Navigation** - zoxide for intelligent directory jumping
- **Fuzzy Finding** - Advanced file and history search

## 📦 What Gets Installed

### 🎯 **Core Tools**
| Component | Purpose | Source | Status |
|-----------|---------|---------|---------|
| **oh-my-posh** | Prompt theme engine | winget | Required |
| **Yazi** | Modern terminal file manager | winget | Required |
| **fzf** | Fuzzy finder | winget | Required |
| **zoxide** | Smart directory navigation | winget | Required |
| **Microsoft Edit** | Modern text editor | winget | Required |

### 📚 **PowerShell Modules**
| Module | Purpose | Repository | Status |
|--------|---------|------------|---------|
| **PSFzf** | Fuzzy finding integration | PSGallery | Required |
| **Terminal-Icons** | File/folder icons | PSGallery | Required |
| **F7History** | Enhanced history search | PSGallery | Required |
| **posh-git** | Git status in prompt | PSGallery | Required |
| **PowerColorLS** | Colorized listings | PSGallery | Optional |

### 🎨 **Enhanced Yazi Ecosystem** ⭐ **NEW!**

#### **Core Yazi Setup**
- **Base Installation**: Latest Yazi via winget
- **Configuration Source**: [yazi_config repository](https://github.com/Tsabo/yazi_config)
- **Auto-Deploy**: Git-based configuration management
- **Update Integration**: Native `ya pkg` updates in Update.ps1

#### **Optional Dependencies**
| Tool | Purpose | Package Manager | Enhancement |
|------|---------|-----------------|-------------|
| **FFmpeg** | Video thumbnails | winget | Media previews |
| **7-Zip** | Archive support | winget | Archive extraction |
| **jq** | JSON processing | winget | JSON previews |
| **Poppler** | PDF support | winget | PDF thumbnails |
| **fd** | Fast file finding | winget | Enhanced search |
| **ripgrep** | Text search | winget | Content search |
| **ImageMagick** | Image processing | winget | Image previews |
| **Scoop** | Package manager | Web installer | Optional |
| **resvg** | SVG rendering | scoop | SVG previews |

#### **Yazi Plugins** (Auto-installed via `ya pkg`)
- **git** - Git repository status display
- **githead** - Enhanced git info (custom fork with bug fixes)

#### **Yazi Themes** (Auto-installed via `ya pkg`)
- **flexoki-light** - Light theme option
- **vscode-dark-plus** - Dark theme matching VS Code

### 🔧 **Configuration Management**
- ✅ **Windows Terminal** - Font and window settings
- ✅ **PowerShell Profile** - Custom modules and functions
- ✅ **oh-my-posh Theme** - Custom prompt configuration
- ✅ **Yazi Configuration** - Git-managed setup with plugins

### ⚙️ **Optional Components**
- **gsudo** - Elevated permissions helper (Optional)
- **PowerColorLS** - Enhanced directory listings (Optional)
- **Scoop + resvg** - SVG support for Yazi (Optional)

## 🚀 Quick Start

### Prerequisites
- ✅ **Windows 10/11** - Modern Windows version
- ✅ **PowerShell 7+** - Will be installed automatically if missing
- ✅ **Git** - Required for cloning repositories
- ✅ **Internet Connection** - For downloading packages

### 🎯 **3-Step Setup**

```powershell
# 1️⃣ Clone the repository
git clone https://github.com/Tsabo/PowerShell-DevKit.git
cd PowerShell-DevKit

# 2️⃣ Run the intelligent setup
.\Scripts\Setup.ps1

# 3️⃣ Test and validate (new PowerShell window)
.\Scripts\Test.ps1
```

### 📋 **Setup Options**

```powershell
# 🎯 Full setup (recommended)
.\Scripts\Setup.ps1

# ⚡ Skip optional components (faster)
.\Scripts\Setup.ps1 -SkipOptional

# 📊 View previous failure details
.\Scripts\Setup.ps1 -ShowDetails

# 🧹 Clear failure logs
.\Scripts\Setup.ps1 -ClearLogs
```

### 📥 **Alternative Setup (Without Git)**

1. **Download** the repository as ZIP from GitHub
2. **Extract** to any directory (e.g., `F:\_brownie\Terminal`)
3. **Run** the setup:
   ```powershell
   cd "F:\_brownie\PowerShell-DevKit"
   .\Scripts\Setup.ps1
   ```

## 📁 Repository Structure

```
PowerShell-DevKit/               # 🏠 Main repository
├── 📁 Config/                   # Configuration templates
│   ├── 🗂️ yazi/                # Yazi configuration (LEGACY)
│   │   ├── yazi.toml           # ⚠️  Now managed via git repo
│   │   ├── keymap.toml         # ⚠️  Use yazi_config instead
│   │   ├── theme.toml          # ⚠️  Will be removed
│   │   ├── package.toml        # ⚠️  Superseded by ya pkg
│   │   └── init.lua            # ⚠️  Legacy configuration
│   └── 🎨 oh-my-posh/          # oh-my-posh themes
│       ├── iterm2.omp.json     # Custom theme
│       └── paradox.omp.json    # Alternative theme
├── 📁 PowerShell/               # PowerShell environment
│   ├── 🧩 CustomModules/        # 🆕 Auto-discovered custom modules
│   │   ├── build_funtions.psm1 # Build utilities
│   │   ├── utilities.psm1      # Helper functions
│   │   └── example-module.psm1.template  # Template for new modules
│   ├── 📁 IncludedModules/      # Reserved for bundled modules (optional)
│   ├── � Microsoft.PowerShell_profile.ps1  # Profile with auto-discovery
│   └── ⚙️ powershell.config.json            # PowerShell config
├── 📁 Scripts/                  # 🤖 Automation Suite
│   ├── 🏗️ Components.psm1      # 🆕 Shared component library
│   ├── 🚀 Setup.ps1            # 🆕 Intelligent setup engine
│   ├── 🧪 Test.ps1             # 🆕 Comprehensive validation
│   ├── 🔄 Update.ps1           # 🆕 Multi-source updater
│   ├── 🖥️ Deploy-Terminal.ps1  # Windows Terminal deployment
│   ├── 📊 Logs/                # 🆕 Failure diagnostics (git-ignored)
│   │   ├── setup-details.json  # Setup failure logs
│   │   └── update-details.json # Update failure logs
│   └── 📖 README.md
├── .gitignore                   # 🆕 Enhanced with logs exclusion
├── LICENSE
└── README.md                    # 🆕 This comprehensive guide
```

### 🆕 **Modern Yazi Configuration**
The Yazi setup now uses a **separate git repository** for better management:

```
~\AppData\Roaming\yazi/          # 🎯 Live Yazi configuration
├── config/                      # Auto-cloned from yazi_config repo
│   ├── yazi.toml               # Main configuration
│   ├── keymap.toml             # Custom keybindings
│   ├── theme.toml              # Theme selection
│   └── init.lua                # Lua initialization
├── flavors/                     # 🎨 Auto-installed themes
│   ├── flexoki-light.yazi/     # Light theme (ya pkg)
│   └── vscode-dark-plus.yazi/  # Dark theme (ya pkg)
└── plugins/                     # 🔌 Auto-installed plugins
    ├── git.yazi/               # Git integration (ya pkg)
    └── githead.yazi/           # Enhanced git info (custom fork)
```

## 🛠️ Management Scripts

### 🚀 **Setup.ps1** - Intelligent Installation Engine

**Enterprise-grade setup with comprehensive failure recovery**

```powershell
# 🎯 Full setup (recommended)
.\Scripts\Setup.ps1

# ⚡ Skip optional components (gsudo, PowerColorLS, Scoop, resvg)
.\Scripts\Setup.ps1 -SkipOptional

# 📊 Show detailed failure information from previous runs
.\Scripts\Setup.ps1 -ShowDetails

# 🧹 Clear stored failure logs
.\Scripts\Setup.ps1 -ClearLogs

# 🎨 Install with custom font
.\Scripts\Setup.ps1 -FontName "JetBrainsMono"
```

**🆕 What's New:**
- ✨ **Component-Based Architecture** - Modular, maintainable design
- 🔍 **Intelligent Failure Logging** - JSON-based diagnostics with suggestions
- 🎯 **Modern Yazi Integration** - Git repo + native package management
- 🛠️ **Scoop Support** - Optional SVG rendering via resvg
- 🚀 **Performance Optimized** - Parallel installation where possible

### 🧪 **Test.ps1** - Comprehensive Environment Validation

**Smart diagnostics with component grouping and version reporting**

```powershell
# 🔍 Full environment validation
.\Scripts\Test.ps1

# 📊 Shows status of all components:
# ✅ Winget Packages (with versions)
# ✅ PowerShell Modules (with versions)
# ✅ Scoop Packages (with versions)
# ✅ Custom Components (Yazi, oh-my-posh, etc.)
```

### 🔄 **Update.ps1** - Multi-Source Package Manager

**Unified update system across all package managers**

```powershell
# 🔄 Update everything (recommended)
.\Scripts\Update.ps1

# 📦 Update only winget packages
.\Scripts\Update.ps1 -WingetOnly

# 📚 Update only PowerShell modules
.\Scripts\Update.ps1 -ModulesOnly

# 📊 Show detailed failure information
.\Scripts\Update.ps1 -ShowDetails

# 🧹 Clear stored failure logs
.\Scripts\Update.ps1 -ClearLogs
```

**🆕 Update Sources:**
- 📦 **Winget Packages** - Windows Package Manager
- 📚 **PowerShell Modules** - PowerShell Gallery
- 🗂️ **Scoop Packages** - Scoop package manager (if installed)
- 🎯 **Yazi Ecosystem** - Native `ya pkg` updates + git config sync
- 🎨 **Configuration Repos** - Git-based config updates

### 🖥️ **Deploy-Terminal.ps1** - Windows Terminal Configuration

```powershell
# 🛡️ Deploy with backup (safe)
.\Scripts\Deploy-Terminal.ps1

# ⚡ Deploy without backup
.\Scripts\Deploy-Terminal.ps1 -NoBackup
```

## �️ Architecture

### 🧩 **Component-Based Design**

The system uses a **shared component library** (`Components.psm1`) that provides:

```powershell
# 🎯 Single source of truth for all components
class SetupComponent {
    [string]$Name           # Component name
    [string]$Type          # winget, module, custom
    [hashtable]$Properties # Package IDs, module names, etc.
    [bool]$IsOptional      # Skip with -SkipOptional
    [scriptblock]$CustomInstaller    # For complex setups
    [scriptblock]$CustomValidator    # For testing
}
```

**Benefits:**
- ✅ **DRY Principle** - No duplication between Setup/Test/Update scripts
- ✅ **Maintainability** - Single place to modify component definitions
- ✅ **Consistency** - Same component logic across all scripts
- ✅ **Extensibility** - Easy to add new components

### 🔍 **Intelligent Failure Recovery**

Advanced logging system with actionable suggestions:

```powershell
# 📊 Detailed JSON logs stored in Scripts/Logs/
{
  "Timestamp": "2025-11-01 10:30:15",
  "Component": "Yazi",
  "Type": "winget",
  "Operation": "winget install sxyazi.yazi",
  "ErrorMessage": "Network timeout",
  "FullOutput": "...",
  "ExitCode": 1,
  "IsAdmin": false
}
```

**Smart Suggestions Engine:**
- 🔐 **Permission Issues** → "Run as Administrator"
- 🌐 **Network Problems** → "Check internet connection"
- 📦 **Package Conflicts** → Specific resolution steps
- 🎯 **Component-Specific** → Tailored troubleshooting

## 🎨 Customization

### 🎯 **Modern Yazi Configuration** ⭐ **NEW!**

Yazi now uses **git-based configuration management**:

```powershell
# 🔄 Configuration is auto-managed via git
# Location: ~/.yazi/ (cloned from yazi_config repo)

# 🔄 Update Yazi configuration and packages
.\Scripts\Update.ps1  # Automatically updates both

# 🎨 Manual package management
ya pkg add <plugin>     # Add new plugins
ya pkg update          # Update all packages
ya pkg list            # List installed packages

# 🎯 Current auto-installed packages:
# Plugins: git, githead (custom fork)
# Themes: flexoki-light, vscode-dark-plus
```

**Key Configuration Files:**
- `yazi.toml` - Main configuration
- `keymap.toml` - Custom keybindings
- `theme.toml` - Theme selection
- `init.lua` - Lua initialization

### 🎨 **oh-my-posh Themes**

```powershell
# 🧪 Test themes
oh-my-posh init pwsh --config "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/jandedobbeleer.omp.json" | Invoke-Expression

# 💾 Export your current theme
oh-my-posh config export --output Config/oh-my-posh/mytheme.omp.json

# 🎯 Available local themes
# - iterm2.omp.json (default)
# - paradox.omp.json (alternative)
```

### 🧩 **Custom PowerShell Modules**

Add your own functions to `PowerShell/CustomModules/`:

```powershell
# 🛠️ utilities.psm1 - General utilities
function My-CustomFunction {
    # Your code here
}

# 🏗️ build_functions.psm1 - Build-related functions
function Build-Solution {
    # Your build logic
}
```

**Module Loading:**
- ✅ **Auto-Discovery** - Custom modules in `CustomModules/` loaded automatically
- ✅ **Alphabetical Order** - Modules loaded in sorted order for predictability
- ✅ **Deferred Loading** - Fast PowerShell startup via `OnIdle` event
- ✅ **Export Control** - Only export what you need
- ✅ **Extensible** - Just drop new `.psm1` files in `CustomModules/` folder

## 📝 Components Deep Dive

### 🎯 **Modern Yazi Setup** ⭐ **ENHANCED!**

**Revolutionary file manager experience with enterprise-grade configuration:**

#### **🏗️ Architecture**
- **Base Installation**: `winget install sxyazi.yazi`
- **Configuration Source**: Git repository (`yazi_config`)
- **Package Management**: Native Yazi `ya pkg` system
- **Update Integration**: Unified with `Update.ps1`

#### **🔌 Auto-Installed Plugins**
```powershell
# 🔄 git.yazi - Git repository integration
ya pkg add yazi-rs/plugins:git

# 🔄 githead.yazi - Enhanced git information (custom fork with fixes)
ya pkg add Tsabo/githead.yazi#feature/guards_save_sync_block_with_pcall
```

#### **🎨 Auto-Installed Themes**
```powershell
# 🌙 Dark theme matching VS Code
ya pkg add 956MB/vscode-dark-plus

# ☀️ Light theme option
ya pkg add gosxrgxx/flexoki-light
```

#### **🔧 Optional Enhancements**
```powershell
# 🖼️ Media & Document Support (auto-installed)
winget install Gyan.FFmpeg          # Video thumbnails
winget install 7zip.7zip            # Archive support
winget install oschwartz10612.Poppler  # PDF support
winget install ImageMagick.ImageMagick  # Image processing

# 🔍 Search & Processing (auto-installed)
winget install jqlang.jq            # JSON processing
winget install sharkdp.fd           # Fast file search
winget install BurntSushi.ripgrep.MSVC  # Text search

# 🎨 SVG Support (optional via Scoop)
scoop install resvg                 # SVG rendering
```

### 🚀 **PowerShell Profile Features**

**Enterprise-grade PowerShell experience:**

```powershell
# ⚡ Performance Optimizations
- Deferred module loading for instant startup
- Smart auto-loading of custom modules
- Optimized PATH management

# 🎯 Enhanced Functionality
- PSReadLine with predictive IntelliSense
- Argument completers (winget, dotnet, git)
- UTF-8 encoding by default
- zoxide integration for smart navigation

# 🛠️ Custom Functions (auto-loaded)
clean          # Remove bin/obj directories recursively
y              # Yazi with directory change on exit
Open-Solution  # Open .sln files in Visual Studio
```

### 🔄 **Update System Architecture**

**Unified package management across multiple sources:**

```powershell
# 📦 Winget Packages - Windows Package Manager
winget upgrade --all

# 📚 PowerShell Modules - PSGallery
Update-Module -Name <module> -Force

# 🗂️ Scoop Packages - Scoop Package Manager (if installed)
scoop update --all

# 🎯 Yazi Ecosystem - Native + Git
ya pkg update                    # Update plugins/themes
git pull origin main            # Update configuration

# 🎨 Configuration Repositories - Git-based
# Yazi config repo auto-synced during updates
```

## 🔧 Post-Installation

### 1️⃣ **Restart PowerShell**
```powershell
# Restart to load new profile and environment
exit
# Open new PowerShell window
```

### 2️⃣ **Verify Installation**
```powershell
# 🧪 Run comprehensive validation
.\Scripts\Test.ps1

# Should show ✅ for all components
```

### 3️⃣ **Configure Terminal Font**

**Windows Terminal:**
- Settings → Profiles → Defaults → Appearance → Font face
- Set to: `CaskaydiaCove Nerd Font Mono`

**VS Code:**
- Settings → Terminal → Integrated: Font Family
- Set to: `'CaskaydiaCove Nerd Font Mono'`

### 4️⃣ **Test Core Features**

```powershell
# 🗂️ Test Yazi integration
y                    # Opens Yazi with directory change
yazi                 # Standard Yazi (no directory change)

# 🔍 Test fuzzy finding
Ctrl+R              # Fuzzy search command history
Ctrl+F              # Fuzzy find files

# 🎯 Test smart navigation
z docs              # Jump to most-used "docs" directory
z -                 # Go to previous directory

# 🎨 Test oh-my-posh
# Should show beautiful prompt with git status
```

## 🔄 Keeping Everything Updated

### 🎯 **Automated Updates**

```powershell
# 🔄 Update everything (recommended weekly)
.\Scripts\Update.ps1

# 📊 View update history and troubleshoot
.\Scripts\Update.ps1 -ShowDetails
```

### 🔄 **Manual Configuration Updates**

```powershell
# 🆕 Pull latest Terminal environment changes
git pull origin main

# 🔧 Re-run setup to apply new features
.\Scripts\Setup.ps1
```

**What Gets Updated:**
- ✅ All winget packages (Yazi, fzf, oh-my-posh, etc.)
- ✅ All PowerShell modules (PSFzf, Terminal-Icons, etc.)
- ✅ All Yazi plugins and themes (`ya pkg update`)
- ✅ Yazi configuration repository (git sync)
- ✅ Scoop packages (if installed)

## 🌟 Usage Examples

### Yazi Navigation
```powershell
y           # Open Yazi (changes directory on exit)
yazi        # Open Yazi (standard mode)
```

### Fuzzy Finding
```powershell
Ctrl+R      # Fuzzy search command history
Ctrl+F      # Fuzzy find files in current directory
```

### Smart Navigation
```powershell
z docs      # Jump to most used directory matching "docs"
z -          # Go to previous directory
```

### Git Integration
Your prompt automatically shows:
- Current branch
- Dirty/clean state
- Ahead/behind status

## 🐛 Troubleshooting

### 🔍 **Intelligent Diagnostics** ⭐ **NEW!**

The system now includes **advanced failure recovery** with actionable suggestions:

```powershell
# 📊 View detailed failure information
.\Scripts\Setup.ps1 -ShowDetails     # Setup failures
.\Scripts\Update.ps1 -ShowDetails    # Update failures

# 🧹 Clear failure logs
.\Scripts\Setup.ps1 -ClearLogs       # Clear setup logs
.\Scripts\Update.ps1 -ClearLogs      # Clear update logs
```

**Example Intelligent Suggestion:**
```
🔸 Yazi (winget)
   Last failure: 2025-11-01 10:30:15
   Operation: winget install sxyazi.yazi
   Admin Rights: False
   Error: Network timeout during download
   💡 Suggestion: Network issue. Check internet connection and try again
```

### 🚨 **Common Issues & Solutions**

#### **🔐 Execution Policy Errors**
```powershell
# ❌ Error: "Scripts cannot be run on this system"
# ✅ Solution:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# For Scoop installation specifically:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# (Scoop requires this setting)
```

#### **📦 Winget Issues**
```powershell
# ❌ Error: "winget command not found"
# ✅ Solution 1: Install from Microsoft Store
# Search "App Installer" in Microsoft Store

# ✅ Solution 2: Install via PowerShell
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe

# ✅ Solution 3: Download manually
# https://github.com/microsoft/winget-cli/releases
```

#### **📚 PowerShell Gallery Access**
```powershell
# ❌ Error: "Unable to resolve package source 'PSGallery'"
# ✅ Solution:
Register-PSRepository -Default -InstallationPolicy Trusted

# Alternative:
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Test connectivity:
Test-NetConnection powershellgallery.com -Port 443
```

#### **🎨 Font and Display Issues**
```powershell
# ❌ Issue: Icons not displaying, prompt looks broken
# ✅ Solution: Install and configure Nerd Font

# Install font:
winget install Microsoft.CascadiaCode

# Configure in Windows Terminal:
# Settings → Profiles → Defaults → Appearance → Font face
# Set to: "CaskaydiaCove Nerd Font Mono"

# Configure in VS Code:
# Settings → Terminal → Integrated: Font Family
# Set to: 'CaskaydiaCove Nerd Font Mono'
```

#### **🗂️ Yazi Configuration Issues** ⭐ **NEW!**
```powershell
# ❌ Issue: Yazi plugins not working
# ✅ Modern Solution:
ya pkg update           # Update all packages
ya pkg list            # List installed packages

# ❌ Issue: Configuration not updating
# ✅ Solution: Check git repository
cd ~\AppData\Roaming\yazi
git status             # Check for local changes
git pull origin main   # Update configuration

# ❌ Issue: Custom githead plugin not working
# ✅ Solution: Reinstall custom fork
ya pkg remove llanosrocas/githead
ya pkg add Tsabo/githead.yazi#feature/guards_save_sync_block_with_pcall
```

#### **🔧 Profile Loading Issues**
```powershell
# ❌ Issue: PowerShell profile not loading
# ✅ Diagnosis:
$PROFILE                                    # Check profile location
Test-Path $PROFILE                         # Check if exists
powershell -NoProfile -Command "& '$PROFILE'"  # Test for errors

# ✅ Recovery:
Remove-Item $PROFILE -Force                # Remove corrupted profile
.\Scripts\Setup.ps1                       # Re-run setup
```

#### **🔄 Scoop Issues** ⭐ **NEW!**
```powershell
# ❌ Issue: Scoop installation fails
# ✅ Solution: Check execution policy and permissions
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Manual installation:
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# ❌ Issue: resvg not installing
# ✅ Solution: Ensure Scoop is installed first
scoop install resvg
```

### 🧪 **Validation & Testing**

```powershell
# 🔍 Comprehensive environment validation
.\Scripts\Test.ps1

# Shows detailed status of all components:
# ✅ Component installed and working
# ⚠️  Component installed but issues detected
# ❌ Component missing or broken
# ℹ️  Component skipped (optional)
```

**Example Test Output:**
```
🔹 Winget Packages:
  ✅ oh-my-posh (v19.14.2)
  ✅ Yazi (v0.2.4)
  ✅ fzf (v0.44.1)

🔹 PowerShell Modules:
  ✅ PSFzf (v2.5.22)
  ✅ Terminal-Icons (v0.11.0)

🔹 Scoop Packages:
  ✅ resvg (v0.35.0)

🔹 Custom Components:
  ✅ Yazi Configuration
  ✅ oh-my-posh Theme
```

### 🆘 **Getting Help**

1. **📊 Check Detailed Logs**: Use `-ShowDetails` parameters
2. **🧪 Run Validation**: Use `Test.ps1` for status overview
3. **🔄 Try Updates**: Use `Update.ps1` to refresh everything
4. **🧹 Clean Start**: Use `-ClearLogs` then re-run setup
5. **📚 Check Dependencies**: Ensure internet, winget, PowerShell 7+ available

## 🌟 Usage Examples

### 🗂️ **Yazi File Manager**
```powershell
y                    # 🎯 Open Yazi with directory change integration
yazi                 # 🗂️ Standard Yazi (no directory change)

# Within Yazi:
j/k                  # Navigate up/down
Enter               # Enter directory or open file
q                   # Quit (y command changes to last directory)
<Space>             # Select files
c                   # Copy selected files
x                   # Cut selected files
p                   # Paste files
d                   # Delete selected files
/                   # Search in current directory
```

### 🔍 **Fuzzy Finding**
```powershell
Ctrl+R              # 🔍 Fuzzy search command history (PSFzf)
Ctrl+F              # 📁 Fuzzy find files in current directory
fzf                 # 🔍 Direct fuzzy finder
```

### 🎯 **Smart Navigation**
```powershell
z docs              # 🎯 Jump to most-used directory matching "docs"
z project           # 🎯 Smart jump to project directories
z -                 # ↩️  Go to previous directory
zoxide query docs   # 🔍 Query zoxide database
```

### 🎨 **Git Integration**
```powershell
# Your oh-my-posh prompt automatically shows:
# � Current directory
# 🌿 Git branch (if in git repo)
# ✅ Clean working directory
# ❌ Dirty working directory
# ↑2 ↓1 Ahead/behind remote
```

## �📚 Resources & Documentation

### 🎯 **Core Tools**
- [**Yazi Documentation**](https://yazi-rs.github.io/) - Modern terminal file manager
- [**oh-my-posh Documentation**](https://ohmyposh.dev/) - Prompt theme engine
- [**PowerShell 7+ Documentation**](https://docs.microsoft.com/en-us/powershell/) - Modern PowerShell

### 🔌 **PowerShell Modules**
- [**PSFzf**](https://github.com/kelleyma49/PSFzf) - Fuzzy finder integration
- [**posh-git**](https://github.com/dahlbyk/posh-git) - Git status in prompt
- [**Terminal-Icons**](https://github.com/devblackops/Terminal-Icons) - File icons
- [**zoxide**](https://github.com/ajeetdsouza/zoxide) - Smart directory navigation

### 🎨 **Yazi Ecosystem**
- [**Yazi Plugins**](https://github.com/yazi-rs/plugins) - Official plugin collection
- [**Yazi Flavors**](https://github.com/yazi-rs/flavors) - Theme collection
- [**Custom githead Fork**](https://github.com/Tsabo/githead.yazi/tree/feature/guards_save_sync_block_with_pcall) - Bug-fixed version

### 🛠️ **Package Managers**
- [**winget**](https://docs.microsoft.com/en-us/windows/package-manager/winget/) - Windows Package Manager
- [**Scoop**](https://scoop.sh/) - Command-line installer for Windows
- [**PowerShell Gallery**](https://www.powershellgallery.com/) - PowerShell module repository

## 🤝 Contributing

### 🆕 **What's New in This Version**
This setup represents a **major architectural upgrade** with:
- ✅ **Component-based design** for maximum maintainability
- ✅ **Intelligent failure recovery** with detailed diagnostics
- ✅ **Modern Yazi integration** using native package management
- ✅ **Multi-source update system** (winget + modules + scoop + yazi)
- ✅ **Enterprise-grade logging** with actionable suggestions

### 🔄 **Contributing Guidelines**
1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Test** your changes with `.\Scripts\Test.ps1`
4. **Commit** your changes (`git commit -m 'Add amazing feature'`)
5. **Push** to the branch (`git push origin feature/amazing-feature`)
6. **Open** a Pull Request

### 💡 **Ideas for Contributions**
- Additional component integrations
- Enhanced failure recovery suggestions
- New custom PowerShell modules
- Improved Yazi configurations
- Theme customizations

## 📄 License

**MIT License** - Feel free to use, modify, and distribute!

## ⭐ Acknowledgments

### 🎯 **Core Tools**
- [**Yazi**](https://github.com/sxyazi/yazi) by sxyazi - Revolutionary terminal file manager
- [**oh-my-posh**](https://github.com/JanDeDobbeleer/oh-my-posh) by Jan De Dobbeleer - Beautiful prompt engine

### 🔌 **PowerShell Ecosystem**
- [**PSFzf**](https://github.com/kelleyma49/PSFzf) by kelleyma49 - Fuzzy finder integration
- [**posh-git**](https://github.com/dahlbyk/posh-git) by Keith Dahlby - Git integration
- [**Terminal-Icons**](https://github.com/devblackops/Terminal-Icons) by devblackops - Beautiful file icons
- [**zoxide**](https://github.com/ajeetdsouza/zoxide) by ajeetdsouza - Smart navigation

### 🛠️ **Development Tools**
- [**Microsoft Edit**](https://github.com/microsoft/edit) by Microsoft - Modern text editor
- [**fzf**](https://github.com/junegunn/fzf) by junegunn - Fuzzy finder
- [**PowerShell**](https://github.com/PowerShell/PowerShell) by Microsoft - Modern shell

---

## 🎉 **Ready to Transform Your Terminal?**

```powershell
# 🚀 Get started in 3 commands:
git clone https://github.com/Tsabo/PowerShell-DevKit.git
cd PowerShell-DevKit
.\Scripts\Setup.ps1

# 🎯 Your modern, intelligent PowerShell development environment awaits!
```

**Made with ❤️ for PowerShell developers and terminal excellence**

