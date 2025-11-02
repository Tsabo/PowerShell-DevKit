# 🧩 Custom PowerShell Modules (User-Specific)

This directory is for **your personal custom PowerShell modules** that extend your PowerShell environment. These modules are **auto-discovered** and loaded automatically.

## ✨ Auto-Discovery Feature

Any `.psm1` file you place in this directory will be **automatically loaded** when PowerShell starts. No need to modify the profile!

## 📦 Custom vs Bundled Modules

- **`CustomModules/`** (this directory) - Your personal modules, NOT tracked in git, auto-discovered
- **`IncludedModules/`** - Bundled with DevKit repo, tracked in git, statically loaded

## 🚀 Quick Start

### 📝 How It Works

1. **Drop a `.psm1` file** into this directory
2. **Restart PowerShell** (or reload profile)
3. **Your functions are available** immediately!

The profile scans this directory during deferred startup and loads all modules alphabetically.

### Creating Your First Custom Module

```powershell
# Create a new custom module
@'
<#
.SYNOPSIS
    My custom PowerShell utilities
#>

function Get-MyCustomTool {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    Write-Host "Running custom tool: $Name" -ForegroundColor Cyan
}

# Export only the functions you want to be public
Export-ModuleMember -Function Get-MyCustomTool
'@ | Out-File -FilePath ".\PowerShell\CustomModules\my-utilities.psm1" -Encoding UTF8

# Restart PowerShell - your module is automatically loaded!
# No need to modify the profile!
```

## 📋 Module Loading Rules

- ✅ **Auto-Discovery**: All `.psm1` files in this directory are automatically found and loaded
- ✅ **Alphabetical Order**: Modules load alphabetically by filename
- ✅ **Load Order Control**: Use prefixes like `01-core.psm1`, `02-tools.psm1` if order matters
- ✅ **Deferred Loading**: Modules load during idle time (fast PowerShell startup)
- ✅ **Error Handling**: Failed modules are silently skipped (won't break your profile)
- ✅ **Git Ignored**: Your custom modules stay private (not tracked in git)

## 💡 Best Practices

### 1. **Use Proper Function Names**
```powershell
# ✅ Good - Uses approved verb
function Get-MyData { }

# ❌ Bad - Invalid verb
function Fetch-MyData { }

# Check approved verbs
Get-Verb
```

### 2. **Export Only Public Functions**
```powershell
function Get-PublicFunction {
    # Public function
}

function privateHelper {
    # Internal helper
}

# Only export public functions
Export-ModuleMember -Function Get-PublicFunction
```

### 3. **Add Comment-Based Help**
```powershell
function Get-MyTool {
    <#
    .SYNOPSIS
        Brief description
    .DESCRIPTION
        Detailed description
    .PARAMETER Name
        Parameter description
    .EXAMPLE
        Get-MyTool -Name "Test"
        Description of what this example does
    #>
    [CmdletBinding()]
    param([string]$Name)

    # Function logic here
}
```

### 4. **Use PSScriptAnalyzer**
```powershell
# Validate your module for best practices
Invoke-ScriptAnalyzer -Path .\PowerShell\CustomModules\my-utilities.psm1 -Settings .\PSScriptAnalyzerSettings.psd1
```

## 🔗 Related Documentation

- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Guidelines if you want to contribute to the DevKit
- [Microsoft.PowerShell_profile.ps1](../Microsoft.PowerShell_profile.ps1) - Profile with auto-discovery implementation
- [PSScriptAnalyzerSettings.psd1](../../PSScriptAnalyzerSettings.psd1) - Code quality rules

## 🎯 Pro Tips

### Reload Module Without Restarting

```powershell
# Remove and reimport after making changes
Remove-Module my-utilities
Import-Module $PROFILE\..\CustomModules\my-utilities.psm1 -Force
```

### Test Module in Isolation

```powershell
# Import just your module for testing
Import-Module .\PowerShell\CustomModules\my-utilities.psm1 -Force

# Check what functions are exported
Get-Command -Module my-utilities
```

### Debug Module Loading

```powershell
# See all loaded modules
Get-Module

# Check if your custom module loaded
Get-Module my-utilities
```

### Example: Simple Utility Module

```powershell
# PowerShell/CustomModules/quick-tools.psm1

function Quick-Note {
    <#
    .SYNOPSIS
        Quickly append a note to your daily notes file
    .EXAMPLE
        Quick-Note "Remember to check that PR"
    #>
    param([string]$Note)

    $notesFile = "$HOME\Documents\notes.txt"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    "$timestamp - $Note" | Add-Content $notesFile
    Write-Host "✓ Note added!" -ForegroundColor Green
}

function Open-Notes {
    <#
    .SYNOPSIS
        Open your notes file in the default editor
    #>
    $notesFile = "$HOME\Documents\notes.txt"
    if (Test-Path $notesFile) {
        Start-Process $notesFile
    } else {
        Write-Warning "No notes file found. Creating one..."
        New-Item $notesFile -ItemType File
        Start-Process $notesFile
    }
}

Export-ModuleMember -Function Quick-Note, Open-Notes
```

## 🆚 When to Use CustomModules vs IncludedModules

| Scenario | Directory to Use |
|----------|-----------------|
| Personal utilities just for you | `CustomModules/` |
| Company-specific tools (not public) | `CustomModules/` |
| Experimenting with new functions | `CustomModules/` |
| Want to contribute to the DevKit | `IncludedModules/` (submit PR) |
| Creating a feature for everyone | `IncludedModules/` (submit PR) |

---

**Happy Scripting!** 🚀

*This directory is git-ignored. Your custom modules stay on your machine and won't be overwritten by DevKit updates.*
