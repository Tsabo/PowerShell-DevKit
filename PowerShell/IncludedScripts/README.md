# 📜 Bundled PowerShell Scripts

This directory contains **bundled PowerShell scripts** that are shipped with the PowerShell DevKit repository and automatically added to your PATH.

## 📦 Bundled vs Custom Scripts

- **`IncludedScripts/`** (this directory) - Bundled with repo, tracked in git, deployed during setup
- **`CustomScripts/`** - User-specific scripts, NOT in git, for your personal utilities

## 🔧 For Contributors: Adding Bundled Scripts

If you're contributing a utility script to ship with the DevKit:

### 📝 How It Works

1. **Create a `.ps1` script** in this directory
2. **Make it executable** - Add proper parameter blocks and help
3. **Submit a PR** with your changes

These scripts are automatically added to PATH during profile loading, so they're available from any PowerShell session.

## 🚀 Quick Start

### Creating a New Bundled Script

```powershell
# Example: PowerShell/IncludedScripts/Get-SystemInfo.ps1

<#
.SYNOPSIS
    Display comprehensive system information
.DESCRIPTION
    Gathers and displays system information including OS, hardware, and PowerShell details
.EXAMPLE
    Get-SystemInfo
    Displays all system information
#>
[CmdletBinding()]
param()

Write-Host "=== System Information ===" -ForegroundColor Cyan
Write-Host "OS: $([System.Environment]::OSVersion.VersionString)"
Write-Host "PowerShell: $($PSVersionTable.PSVersion)"
Write-Host "Computer: $env:COMPUTERNAME"
Write-Host "User: $env:USERNAME"
```

### Best Practices

1. **Use approved PowerShell verbs** - `Get-Verb` for list
2. **Add comprehensive help** - Comment-based help with examples
3. **Include parameter validation** - Use `[CmdletBinding()]` and parameter attributes
4. **Handle errors gracefully** - Use try/catch and meaningful error messages
5. **Test cross-platform** - If intended for cross-platform use

## 📋 Bundled Scripts

- **`Update-AllPowerShellModules.ps1`** - Updates all installed PowerShell modules from PSGallery

## 🎯 For End Users

**Don't modify this directory directly!** These are bundled scripts maintained by the DevKit.

For your own custom scripts, use the **`CustomScripts/`** directory instead:

```powershell
# Create your own custom script
@'
<#
.SYNOPSIS
    My custom utility script
#>
[CmdletBinding()]
param([string]$Message = "Hello")

Write-Host $Message -ForegroundColor Green
'@ | Out-File -FilePath "$HOME\Documents\PowerShell\CustomScripts\Say-Hello.ps1" -Encoding UTF8

# Make it available immediately (it's already in PATH via profile)
# Just restart PowerShell or reload your profile:
. $PROFILE

# Now you can run it from anywhere:
Say-Hello -Message "Custom script works!"
```

## 🔗 Related Documentation

- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Contribution guidelines
- [CustomScripts/README.md](../CustomScripts/README.md) - User custom scripts guide
- [PSScriptAnalyzerSettings.psd1](../../PSScriptAnalyzerSettings.psd1) - Code quality rules

## 💡 Pro Tips for Contributors

### Test Your Script

```powershell
# Validate with PSScriptAnalyzer
Invoke-ScriptAnalyzer -Path .\PowerShell\IncludedScripts\Your-Script.ps1 -Settings .\PSScriptAnalyzerSettings.psd1

# Test syntax
Get-Command .\PowerShell\IncludedScripts\Your-Script.ps1 -Syntax

# Run validation
.\Scripts\Validate-Code.ps1
```

### Make Scripts Discoverable

```powershell
# Users can find your bundled script by name once deployed
Get-Command Update-AllPowerShellModules

# Or see all bundled scripts
Get-ChildItem "$PSHOME\..\..\IncludedScripts"
```

---

**Contributing Scripts!** 🚀

*Scripts in this directory are deployed to user systems during setup and available in PATH for all PowerShell sessions.*
