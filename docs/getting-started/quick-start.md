# Quick Start

Get your PowerShell development environment set up in under 5 minutes!

## Prerequisites

=== "Windows"
    - ✅ **Windows 10/11** - Modern Windows version
    - ✅ **PowerShell 7+** - Installed automatically if missing
    - ✅ **Internet Connection** - For downloading packages
    - ⚠️ **Administrator Rights** - Recommended for best results

=== "macOS"
    - ✅ **macOS 10.15+** - Catalina or later
    - ✅ **PowerShell 7+** - `brew install --cask powershell`
    - ✅ **Homebrew** - Installed automatically if missing
    - ✅ **Internet Connection** - For downloading packages

=== "Linux / WSL"
    - ✅ **Ubuntu 22.04 LTS+** (or compatible Debian-based distro)
    - ✅ **PowerShell 7+** - [Microsoft install guide](https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu)
    - ✅ **curl, git, unzip** - `sudo apt-get install curl git unzip`
    - ✅ **Internet Connection** - For downloading packages
    - ℹ️ **WSL2** recommended when running under Windows

!!! tip "New to PowerShell?"
    Don't worry! The setup script handles everything automatically, including installing PowerShell 7 if you don't have it.

## Installation

### Step 1: Clone the Repository

```powershell
# Clone to your preferred location
git clone https://github.com/Tsabo/PowerShell-DevKit.git
cd PowerShell-DevKit
```

### Step 2: Run Setup

=== "Recommended (Administrator)"

    ```powershell
    # Run as Administrator for full installation
    .\Scripts\Setup.ps1
    ```

=== "Standard User"

    ```powershell
    # Most components will install, some may be skipped
    .\Scripts\Setup.ps1
    ```

!!! warning "Execution Policy"
    If you get an execution policy error, run:
    ```powershell
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```

### Step 3: Reload Your Profile

```powershell
# Apply the new configuration
. $PROFILE
```

## What Happens During Setup?

The setup script will:

1. ✅ **Check Prerequisites** - Verify system requirements
2. ✅ **Install Core Tools** - oh-my-posh, Yazi, fzf, zoxide, etc.
3. ✅ **Install PowerShell Modules** - PSFzf, Terminal-Icons, posh-git, etc.
4. ✅ **Configure Environment** - Deploy profiles, themes, and settings
5. ✅ **Install Yazi Ecosystem** - Optional dependencies, plugins, and themes
6. ✅ **Verify Installation** - Run tests and show results

!!! success "Progress Feedback"
    The setup provides detailed progress information at every step, so you always know what's happening.

## First Steps After Installation

### Try Yazi File Manager

```powershell
# Launch Yazi
yazi
```

Navigate with arrow keys, press `q` to quit.

### Test Fuzzy Finding

```powershell
# Fuzzy find files
Ctrl+T

# Fuzzy find in history
Ctrl+R
```

### Use Smart Navigation

```powershell
# Add a directory bookmark
z Projects

# Later, jump back from anywhere
z Proj
```

### Explore oh-my-posh Theme

Your prompt now shows:
- Current directory
- Git branch and status
- Execution time for commands
- Error indicators

## Next Steps

- 📖 [Explore all components](../components/overview.md)
<!-- - ⚙️ [Customize your setup](../configuration/customization.md) *(Coming soon)* -->
<!-- - 🔧 [Learn about scripts](../scripts/setup.md) *(Coming soon)* -->
- ❓ [Troubleshooting guide](../troubleshooting.md)

## Need Help?

- Check the [FAQ](../faq.md)
- Review [Troubleshooting](../troubleshooting.md)
- Open an issue on [GitHub](https://github.com/Tsabo/PowerShell-DevKit/issues)
