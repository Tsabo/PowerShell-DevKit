# 📜 Custom PowerShell Scripts (User-Specific)

This directory is for **your personal PowerShell scripts** that you want available in your PATH. Any `.ps1` file here is automatically accessible from any PowerShell session.

## ✨ Automatic PATH Integration

Scripts in this directory are **automatically added to your PATH** via the PowerShell profile. No configuration needed!

## 📦 Custom vs Bundled Scripts

- **`CustomScripts/`** (this directory) - Your personal scripts, NOT tracked in git, auto-added to PATH
- **`IncludedScripts/`** - Bundled with DevKit repo, tracked in git, deployed during setup

## 🚀 Quick Start

### 📝 How It Works

1. **Drop a `.ps1` script** into this directory
2. **Restart PowerShell** (or reload profile with `. $PROFILE`)
3. **Run your script** from anywhere by name!

The profile adds this directory to PATH, so all scripts here are immediately available.

### Creating Your First Custom Script

```powershell
# Create a simple script
@'
<#
.SYNOPSIS
    Quick note taker
.DESCRIPTION
    Appends a timestamped note to your daily notes file
.PARAMETER Note
    The note text to append
.EXAMPLE
    Quick-Note "Remember to review PR #123"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Note
)

$notesFile = "$HOME\Documents\daily-notes.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
"[$timestamp] $Note" | Add-Content $notesFile
Write-Host "✓ Note added!" -ForegroundColor Green
'@ | Out-File -FilePath ".\PowerShell\CustomScripts\Quick-Note.ps1" -Encoding UTF8

# Reload your profile
. $PROFILE

# Now use it from anywhere!
Quick-Note "This is so convenient!"
```

## 💡 Best Practices

### 1. **Use PowerShell Naming Conventions**
```powershell
# ✅ Good - Verb-Noun pattern
# Quick-Note.ps1
# Get-MyData.ps1
# Update-LocalCache.ps1

# ❌ Avoid - Non-standard names
# note.ps1
# mydata.ps1
# update_cache.ps1
```

### 2. **Add Comment-Based Help**
```powershell
<#
.SYNOPSIS
    Brief one-line description
.DESCRIPTION
    Detailed description of what the script does
.PARAMETER ParamName
    Description of the parameter
.EXAMPLE
    Your-Script -ParamName "value"
    Description of what this example does
.NOTES
    Any additional notes or requirements
#>
```

### 3. **Use Proper Parameter Blocks**
```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$RequiredParam,

    [Parameter()]
    [ValidateSet("Option1", "Option2")]
    [string]$OptionalParam = "Option1"
)
```

### 4. **Handle Errors Gracefully**
```powershell
try {
    # Your code here
}
catch {
    Write-Error "Script failed: $_"
    exit 1
}
```

## 📋 Example Use Cases

### Personal Productivity Scripts
- Daily standup note generator
- Git shortcuts for your workflow
- Custom build/deploy scripts
- Environment switchers

### Work-Specific Utilities
- Company VPN connectors
- Internal tool wrappers
- Database query helpers
- Report generators

### Development Helpers
- Project template creators
- Code snippet generators
- Test data makers
- Log analyzers

## 🔗 Related Documentation

- [CONTRIBUTING.md](../../CONTRIBUTING.md) - If you want to contribute a script to the DevKit
- [IncludedScripts/README.md](../IncludedScripts/README.md) - Bundled scripts guide
- [PSScriptAnalyzerSettings.psd1](../../PSScriptAnalyzerSettings.psd1) - Code quality rules

## 🎯 Pro Tips

### Check What's in Your PATH

```powershell
# See all directories in your PATH
$env:PATH -split ';'

# Find your CustomScripts directory
$env:PATH -split ';' | Where-Object { $_ -like "*CustomScripts*" }
```

### List Your Custom Scripts

```powershell
# See all your custom scripts
Get-ChildItem "$HOME\Documents\PowerShell\CustomScripts\*.ps1"

# Make an alias to list them quickly
function Get-MyScripts { Get-ChildItem "$HOME\Documents\PowerShell\CustomScripts\*.ps1" }
```

### Test Before Using

```powershell
# Validate your script
Invoke-ScriptAnalyzer -Path .\PowerShell\CustomScripts\Your-Script.ps1

# Check syntax
Get-Command .\PowerShell\CustomScripts\Your-Script.ps1 -Syntax

# Test run with -WhatIf if supported
Your-Script -WhatIf
```

### Example: Git Helper Script

```powershell
# PowerShell/CustomScripts/Git-QuickCommit.ps1

<#
.SYNOPSIS
    Quick git add, commit, and push
.EXAMPLE
    Git-QuickCommit "Fixed bug in login"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Message
)

try {
    git add .
    git commit -m $Message
    git push
    Write-Host "✓ Changes committed and pushed!" -ForegroundColor Green
}
catch {
    Write-Error "Git operation failed: $_"
}
```

### Example: Environment Switcher

```powershell
# PowerShell/CustomScripts/Switch-DevEnv.ps1

<#
.SYNOPSIS
    Switch between development environments
.EXAMPLE
    Switch-DevEnv -Environment Production
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet("Dev", "Staging", "Production")]
    [string]$Environment
)

$envFiles = @{
    "Dev" = "$HOME\.env.dev"
    "Staging" = "$HOME\.env.staging"
    "Production" = "$HOME\.env.production"
}

Copy-Item $envFiles[$Environment] "$HOME\.env" -Force
Write-Host "✓ Switched to $Environment environment" -ForegroundColor Cyan
```

## 🆚 When to Use CustomScripts vs IncludedScripts

| Scenario | Directory to Use |
|----------|-----------------|
| Personal productivity scripts | `CustomScripts/` |
| Company/work-specific tools | `CustomScripts/` |
| Quick automation helpers | `CustomScripts/` |
| Experimental/learning scripts | `CustomScripts/` |
| Want to contribute to DevKit | `IncludedScripts/` (submit PR) |
| Useful for all DevKit users | `IncludedScripts/` (submit PR) |

---

**Happy Scripting!** 🚀

*This directory is git-ignored. Your custom scripts stay on your machine and won't be overwritten by DevKit updates.*
