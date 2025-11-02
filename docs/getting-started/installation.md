# Installation Guide

Complete step-by-step guide to installing PowerShell DevKit.

## Before You Begin

1. Review the [Requirements](requirements.md)
2. Close all PowerShell windows (setup will reload profile automatically)
3. Ensure you have internet connectivity

## Installation Methods

### Method 1: Automated Setup (Recommended)

This is the easiest way to get started.

#### Step 1: Clone the Repository

```powershell
# Navigate to where you want to install
cd C:\Dev  # or your preferred location

# Clone the repository
git clone https://github.com/Tsabo/PowerShell-DevKit.git
cd PowerShell-DevKit
```

#### Step 2: Run Setup Script

=== "As Administrator (Recommended)"

    ```powershell
    # Right-click PowerShell and "Run as Administrator"
    cd C:\Dev\PowerShell-DevKit
    .\Scripts\Setup.ps1
    ```

    **Benefits:**
    - All components install successfully
    - Windows Terminal configured automatically
    - No UAC prompts during installation

=== "As Standard User"

    ```powershell
    .\Scripts\Setup.ps1
    ```

    **Limitations:**
    - Some components may be skipped
    - May require manual UAC approval
    - Windows Terminal config might need manual copy

#### Step 3: Verify Installation

```powershell
# Run the test script
.\Scripts\Test.ps1
```

Expected output shows all components installed with ✓ marks.

### Method 2: Manual Installation

If you prefer to install components individually:

#### 1. Install Core Tools

```powershell
# Install oh-my-posh
winget install JanDeDobbeleer.OhMyPosh

# Install Yazi
winget install sxyazi.yazi

# Install fzf
winget install junegunn.fzf

# Install zoxide
winget install ajeetdsouza.zoxide
```

#### 2. Install PowerShell Modules

```powershell
Install-Module -Name PSFzf -Scope CurrentUser
Install-Module -Name Terminal-Icons -Scope CurrentUser
Install-Module -Name F7History -Scope CurrentUser
Install-Module -Name posh-git -Scope CurrentUser
```

#### 3. Deploy Configuration

```powershell
# Run deployment scripts individually
.\Scripts\Deploy-Terminal.ps1
.\Scripts\Deploy-PowerShellProfile.ps1
```

## Post-Installation

### Reload Your Profile

```powershell
# Apply the new configuration
. $PROFILE
```

### Verify Installation

Run the test script to ensure everything is working:

```powershell
.\Scripts\Test.ps1
```

### Install Optional Components

```powershell
# Install Yazi optional dependencies
Install-YaziOptionals

# Install just plugins
Install-YaziOptionals -PluginsOnly

# Install just dependencies
Install-YaziOptionals -DependenciesOnly
```

## Setup Process Details

### What the Setup Script Does

1. **Prerequisites Check**
   - Validates PowerShell version
   - Checks for winget availability
   - Verifies internet connectivity

2. **Core Installation**
   - Installs oh-my-posh with CascadiaCode font
   - Installs Yazi file manager
   - Installs fzf, zoxide, and other tools
   - Installs PowerShell modules from Gallery

3. **Configuration Deployment**
   - Copies Windows Terminal settings
   - Deploys PowerShell profile
   - Deploys oh-my-posh themes
   - Clones Yazi configuration

4. **Yazi Ecosystem**
   - Installs optional dependencies (FFmpeg, 7-Zip, etc.)
   - Installs Yazi plugins (git, githead)
   - Sets up themes (flexoki-light, vscode-dark-plus)

5. **Verification**
   - Runs component tests
   - Displays installation summary
   - Shows any issues that need attention

### Progress Indicators

During installation, you'll see:

```
🔹 Installing oh-my-posh...
  → Checking if already installed...
  ✓ oh-my-posh installed successfully

🔹 Installing Yazi...
  → Installing Yazi...
  ✓ Yazi binary installed
  → Installing optional dependencies for enhanced functionality...
    → [1/7] Checking FFmpeg (for video thumbnails)...
      ✓ FFmpeg installed
```

### Timeout Protection

All package installations have built-in timeouts:
- **15 seconds** for checking if already installed
- **60 seconds** for package installation
- **30 seconds** for git operations

If any operation times out, it's skipped and installation continues.

## Troubleshooting Installation

### Common Issues

!!! warning "Execution Policy Error"
    **Error:** `cannot be loaded because running scripts is disabled`

    **Solution:**
    ```powershell
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```

!!! warning "winget Not Found"
    **Error:** `winget: The term 'winget' is not recognized`

    **Solution:**
    - Update Windows to latest version
    - Install [App Installer](https://www.microsoft.com/p/app-installer/9nblggh4nns1) from Microsoft Store

!!! warning "Module Installation Failed"
    **Error:** `Unable to install module from PSGallery`

    **Solution:**
    ```powershell
    # Trust PSGallery
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    ```

### Checking Logs

Setup logs are saved to `.\Scripts\Logs\Setup_YYYYMMDD_HHMMSS.log`

```powershell
# View the most recent log
Get-Content .\Scripts\Logs\Setup_*.log | Select-Object -Last 50
```

### Getting Help

- Check the [Troubleshooting](../troubleshooting.md) page
- Review [FAQ](../faq.md)
- Open an issue on [GitHub](https://github.com/Tsabo/PowerShell-DevKit/issues)

## Next Steps

- [Quick Start Guide](quick-start.md) - Get started using your new environment
<!-- - [Customization](../configuration/customization.md) - Personalize your setup *(Coming soon)* -->
- [Component Overview](../components/overview.md) - Learn about installed tools

## Updating

After initial installation, keep everything up to date:

```powershell
# Run the update script
.\Scripts\Update.ps1
```

This updates:
- All winget packages
- PowerShell modules
- Yazi configuration
- Yazi plugins and themes
