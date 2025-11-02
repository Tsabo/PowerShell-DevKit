# 🧩 Custom PowerShell Modules

This directory contains **auto-discovered** custom PowerShell modules that extend your PowerShell environment.

## ✨ Auto-Discovery Feature

Any `.psm1` file placed in this directory will be **automatically loaded** when PowerShell starts. No need to modify the profile!

### 📝 How It Works

1. **Drop a `.psm1` file** into this directory
2. **Restart PowerShell** (or reload profile)
3. **Your functions are available** immediately!

The profile scans this directory during deferred startup and loads all modules alphabetically.

## 🚀 Quick Start

### Option 1: Use the Template

```powershell
# Copy the template
Copy-Item example-module.psm1.template my-tools.psm1

# Edit and customize
code my-tools.psm1

# Restart PowerShell - your module is loaded!
```

### Option 2: Create From Scratch

```powershell
# Create a new module file
@'
function Get-MyTool {
    [CmdletBinding()]
    param([string]$Name)

    Write-Host "Hello from $Name!"
}

Export-ModuleMember -Function Get-MyTool
'@ | Out-File -FilePath ".\my-tools.psm1" -Encoding UTF8

# Restart PowerShell
```

## 📋 Module Loading Rules

- ✅ **Auto-Discovery**: All `.psm1` files in this directory
- ✅ **Alphabetical Order**: Modules load alphabetically by filename
- ✅ **Load Order Control**: Use prefixes like `01-core.psm1`, `02-tools.psm1` if order matters
- ✅ **Deferred Loading**: Modules load during idle time (fast startup)
- ✅ **Error Handling**: Failed modules are silently skipped (won't break profile)

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

- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Contribution guidelines
- [Microsoft.PowerShell_profile.ps1](../Microsoft.PowerShell_profile.ps1) - Profile implementation
- [PSScriptAnalyzerSettings.psd1](../../PSScriptAnalyzerSettings.psd1) - Code quality rules

## 🎯 Pro Tips

### Reload Modules Without Restarting

```powershell
# Remove and reimport a module after changes
Remove-Module utilities
Import-Module $PROFILE\..\CustomModules\utilities.psm1 -Force
```

### Test Module in Isolation

```powershell
# Import just one module for testing
Import-Module .\my-module.psm1 -Force

# Check what functions are exported
Get-Command -Module my-module
```

### Debug Module Loading

```powershell
# See what modules are loaded
Get-Module

# Check if your custom module loaded
Get-Module utilities, build_funtions
```

---

**Happy Scripting!** 🚀
