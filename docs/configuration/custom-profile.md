# Custom Profile

The CustomProfile.ps1 file provides a safe way to add personal customizations without modifying the main profile.

## Overview

**Location:** `PowerShell/CustomProfile.ps1`

**Template:** `PowerShell/CustomProfile.ps1.template`

**Status:** Git-ignored (update-safe)

## Creating Your Custom Profile

```powershell
# Copy template
Copy-Item "PowerShell\CustomProfile.ps1.template" "PowerShell\CustomProfile.ps1"

# Edit
code PowerShell\CustomProfile.ps1
```

## What to Add

### Personal Aliases

```powershell
# Git shortcuts
Set-Alias -Name g -Value git
Set-Alias -Name ga -Value 'git add'
Set-Alias -Name gc -Value 'git commit'
Set-Alias -Name gp -Value 'git push'

# Navigation
Set-Alias -Name dev -Value 'Set-Location C:\Dev'
Set-Alias -Name docs -Value 'Set-Location ~\Documents'
```

### Environment Variables

```powershell
# Development paths
$env:DEV_ROOT = "C:\Dev"
$env:PROJECTS = "$env:DEV_ROOT\Projects"

# Editor
$env:EDITOR = "code"
$env:VISUAL = "code"

# API keys (use secure storage for sensitive data)
$env:MY_API_KEY = "your-key-here"
```

### Custom Functions

```powershell
function Start-MyWorkflow {
    <#
    .SYNOPSIS
        Starts my daily workflow
    #>
    Set-Location C:\Dev\CurrentProject
    code .
    Start-Process chrome "http://localhost:3000"
}

function Get-MyProjects {
    <#
    .SYNOPSIS
        Lists all my projects
    #>
    Get-ChildItem C:\Dev -Directory
}
```

### Additional Modules

```powershell
# Company-specific modules
if (Get-Module -ListAvailable CompanyModule) {
    Import-Module CompanyModule
}

# Personal favorite modules
Import-Module YourFavoriteModule -ErrorAction SilentlyContinue
```

### PSReadLine Customizations

```powershell
# Custom key bindings
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteChar
Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardDeleteWord

# Custom colors
Set-PSReadLineOption -Colors @{
    Command = 'Yellow'
    Parameter = 'Green'
    String = 'Cyan'
}
```

## Example CustomProfile.ps1

```powershell
<#
.SYNOPSIS
    Personal PowerShell customizations
.DESCRIPTION
    My personal aliases, functions, and environment variables
#>

# ============================================================================
# ALIASES
# ============================================================================

Set-Alias -Name g -Value git
Set-Alias -Name k -Value kubectl
Set-Alias -Name d -Value docker
Set-Alias -Name v -Value code

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

$env:DEV_ROOT = "C:\Dev"
$env:EDITOR = "code"

# ============================================================================
# FUNCTIONS
# ============================================================================

function Start-DevDay {
    <#
    .SYNOPSIS
        Starts my development day
    #>
    Set-Location $env:DEV_ROOT
    code .
    Start-Process chrome
    Write-Host "Development day started!" -ForegroundColor Green
}

function Get-DevStatus {
    <#
    .SYNOPSIS
        Shows status of all dev projects
    #>
    Get-ChildItem $env:DEV_ROOT -Directory | ForEach-Object {
        if (Test-Path (Join-Path $_.FullName ".git")) {
            Write-Host "`n$($_.Name):" -ForegroundColor Cyan
            Push-Location $_.FullName
            git status -s
            Pop-Location
        }
    }
}

function Update-AllProjects {
    <#
    .SYNOPSIS
        Updates all git repositories in dev folder
    #>
    Get-ChildItem $env:DEV_ROOT -Directory | ForEach-Object {
        if (Test-Path (Join-Path $_.FullName ".git")) {
            Write-Host "Updating $($_.Name)..." -ForegroundColor Yellow
            Push-Location $_.FullName
            git pull
            Pop-Location
        }
    }
}

# ============================================================================
# ADDITIONAL MODULES
# ============================================================================

# Company-specific tools
if (Get-Module -ListAvailable CompanyTools) {
    Import-Module CompanyTools
}

# ============================================================================
# PSREADLINE CUSTOMIZATION
# ============================================================================

Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteChar
Set-PSReadLineKeyHandler -Key Alt+d -Function DeleteWord

# ============================================================================
# STARTUP ACTIONS
# ============================================================================

# Show reminder
Write-Host "CustomProfile loaded. Type " -NoNewline
Write-Host "Start-DevDay" -ForegroundColor Cyan -NoNewline
Write-Host " to begin working."
```

## Loading Sequence

1. Main profile (`Microsoft.PowerShell_profile.ps1`) loads
2. Core modules and configurations load
3. CustomProfile.ps1 loads (if exists)
4. Your customizations applied

## Best Practices

### 1. Document Your Code

Add comments explaining why:

```powershell
# Workaround for company VPN disconnecting
$env:NETWORK_TIMEOUT = "300"
```

### 2. Error Handling

Use `-ErrorAction SilentlyContinue` for optional dependencies:

```powershell
Import-Module OptionalModule -ErrorAction SilentlyContinue
```

### 3. Conditional Loading

Check before loading company-specific tools:

```powershell
if ($env:COMPUTERNAME -match "WORK") {
    # Work-specific configuration
}
```

### 4. Performance

Keep it lean for fast startup:

```powershell
# Good: Lightweight alias
Set-Alias -Name g -Value git

# Avoid: Expensive operations at startup
# Get-AllProjects | Export-Csv  # Don't do this
```

## Backup

CustomProfile.ps1 is git-ignored, so backup separately:

```powershell
# Manual backup
Copy-Item PowerShell\CustomProfile.ps1 "$env:OneDrive\Backups\CustomProfile-$(Get-Date -Format 'yyyyMMdd').ps1"

# Automated backup function
function Backup-CustomProfile {
    $backup = "$env:OneDrive\Backups\CustomProfile-$(Get-Date -Format 'yyyyMMdd').ps1"
    Copy-Item PowerShell\CustomProfile.ps1 $backup
    Write-Host "Backed up to: $backup" -ForegroundColor Green
}
```

## Troubleshooting

### CustomProfile Not Loading

Check that:

- File is named exactly `CustomProfile.ps1`
- File is in `PowerShell/` directory
- Main profile loads successfully
- No syntax errors: `. .\PowerShell\CustomProfile.ps1`

### Errors on Startup

```powershell
# Test custom profile independently
. .\PowerShell\CustomProfile.ps1

# Fix errors, then reload main profile
. $PROFILE
```

## See Also

- [Customization Guide](customization.md)
- [Custom Modules](custom-modules.md)
- [PowerShell Profile](../components/powershell.md)
