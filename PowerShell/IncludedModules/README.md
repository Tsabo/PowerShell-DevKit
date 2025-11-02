# 🧩 Bundled PowerShell Modules

This directory contains **bundled PowerShell modules** that are shipped with the PowerShell DevKit repository. These modules are **statically loaded** via the profile's `Import-CustomModules` function.

## 📦 Bundled vs Custom Modules

- **`IncludedModules/`** (this directory) - Bundled with repo, tracked in git, statically loaded
- **`CustomModules/`** - User-specific modules, NOT in git, auto-discovered and loaded

## 🔧 For Contributors: Adding Bundled Modules

If you're contributing a new module to ship with the DevKit:

### 📝 How It Works

1. **Create a `.psm1` file** in this directory
2. **Add it to the static list** in `Microsoft.PowerShell_profile.ps1` (see `$includedModules` array)
3. **Submit a PR** with your changes

These modules are loaded statically (explicitly listed in profile) and shipped with the repository.

## 🚀 Quick Start

### Creating a New Bundled Module

```powershell
# 1. Create a new module file in this directory
@'
function Get-MyTool {
    [CmdletBinding()]
    param([string]$Name)

    Write-Host "Hello from $Name!"
}

Export-ModuleMember -Function Get-MyTool
'@ | Out-File -FilePath ".\PowerShell\IncludedModules\my-tools.psm1" -Encoding UTF8

# 2. Add it to the $includedModules array in Microsoft.PowerShell_profile.ps1:
# @{ Type = "CustomModule"; Name = "IncludedModules\my-tools.psm1"; Options = @{ WarningAction = "SilentlyContinue" } }

# 3. Test by restarting PowerShell or reloading the profile
```

## 📋 Module Loading Rules

- ✅ **Static Loading**: Modules explicitly listed in `$includedModules` array in profile
- ✅ **Bundled with Repo**: These modules are tracked in git and deployed during setup
- ✅ **Deferred Loading**: Modules load during idle time (fast startup)
- ✅ **Error Handling**: Failed modules are silently skipped (won't break profile)
- ✅ **Type = "CustomModule"**: Uses same loading mechanism as CustomModules but from this directory

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
function Get-PublicFunction { }
function privateHelper { }

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
    #>
    [CmdletBinding()]
    param([string]$Name)

    # Function logic
}
```

### 4. **Use PSScriptAnalyzer**
```powershell
# Validate your module before committing
Invoke-ScriptAnalyzer -Path .\your-module.psm1 -Settings ..\..\PSScriptAnalyzerSettings.psd1
```

## 📦 Included Modules

- **`build_funtions.psm1`** - Build automation utilities
- **`utilities.psm1`** - General helper functions
- **`example-module.psm1.template`** - Template for creating new modules

## 🔗 Related Documentation

- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Contribution guidelines for adding bundled modules
- [Microsoft.PowerShell_profile.ps1](../Microsoft.PowerShell_profile.ps1) - Profile implementation with `$includedModules` array
- [PSScriptAnalyzerSettings.psd1](../../PSScriptAnalyzerSettings.psd1) - Code quality rules

## 🎯 For End Users

**Don't modify this directory directly!** These are bundled modules maintained by the DevKit.

For your own custom modules, use the **`CustomModules/`** directory instead:

```powershell
# Create your own custom module (auto-discovered)
New-Item -Path ".\PowerShell\CustomModules\my-utilities.psm1" -ItemType File

# Edit and add your functions
code .\PowerShell\CustomModules\my-utilities.psm1

# It will be automatically loaded on next PowerShell startup!
# No need to modify the profile - CustomModules are auto-discovered.
```

## 🎯 Pro Tips for Contributors

### Reload Bundled Modules Without Restarting

```powershell
# Remove and reimport a bundled module after changes
Remove-Module utilities
Import-Module $PROFILE\..\IncludedModules\utilities.psm1 -Force
```

### Test Module in Isolation

```powershell
# Import just one module for testing
Import-Module .\PowerShell\IncludedModules\my-module.psm1 -Force

# Check what functions are exported
Get-Command -Module my-module
```

### Debug Module Loading

```powershell
# See what modules are loaded
Get-Module

# Check if bundled modules loaded
Get-Module utilities, build_funtions
```

---

**Happy Scripting!** 🚀
