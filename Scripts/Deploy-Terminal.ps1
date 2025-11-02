<#
.SYNOPSIS
    Deploys Windows Terminal settings template
.DESCRIPTION
    Applies minimal Windows Terminal settings (font and window width) to existing configuration.
    Preserves all existing profiles, shortcuts, themes, and other user customizations.
.PARAMETER Force
    Overwrite existing settings without backup
.PARAMETER NoBackup
    Skip creating backup of existing settings
.EXAMPLE
    .\Deploy-WindowsTerminalSettings.ps1
.EXAMPLE
    .\Deploy-WindowsTerminalSettings.ps1 -Force -NoBackup
#>
[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$NoBackup
)

$ErrorActionPreference = "Stop"

# Color output functions
function Write-Step {
    param([string]$Message)
    Write-Host "`n🔹 $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

function Write-Skip {
    param([string]$Message)
    Write-Host "  ⊘ $Message" -ForegroundColor Yellow
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "  ✗ $Message" -ForegroundColor Red
}

function Get-WindowsTerminalPath {
    # Find Windows Terminal installation
    $terminalPaths = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState",
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState"
    )
    
    foreach ($path in $terminalPaths) {
        if (Test-Path $path) {
            return $path
        }
    }
    
    return $null
}

function Apply-MinimalSettings {
    param(
        [PSCustomObject]$Template,
        [PSCustomObject]$Existing
    )
    
    # Start with existing settings as base
    $updated = $Existing | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    
    # Apply initial column width if specified in template
    if ($Template.initialCols) {
        $updated.initialCols = $Template.initialCols
    }
    
    # Ensure profiles structure exists
    if (-not $updated.profiles) {
        $updated | Add-Member -NotePropertyName "profiles" -NotePropertyValue @{}
    }
    
    # Apply font to defaults if specified in template
    if ($Template.profiles -and $Template.profiles.defaults -and $Template.profiles.defaults.font) {
        if (-not $updated.profiles.defaults) {
            $updated.profiles | Add-Member -NotePropertyName "defaults" -NotePropertyValue @{}
        }
        if (-not $updated.profiles.defaults.font) {
            $updated.profiles.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue @{}
        }
        $updated.profiles.defaults.font.face = $Template.profiles.defaults.font.face
    }
    
    return $updated
}

# Main deployment function
function Deploy-WindowsTerminalSettings {
    Write-Host @"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║        Windows Terminal Settings Deployment                ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

    # Find Windows Terminal
    Write-Step "Locating Windows Terminal installation..."
    $terminalPath = Get-WindowsTerminalPath
    
    if (-not $terminalPath) {
        Write-ErrorMsg "Windows Terminal not found. Please install Windows Terminal from Microsoft Store."
        return $false
    }
    
    Write-Success "Found Windows Terminal at: $terminalPath"
    
    # Locate settings template
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $repoRoot = Split-Path -Parent $scriptDir
    $templatePath = Join-Path $repoRoot "Config\WindowsTerminal\settings.json"
    
    if (-not (Test-Path $templatePath)) {
        Write-ErrorMsg "Settings template not found at: $templatePath"
        return $false
    }
    
    Write-Success "Found settings template"
    
    # Read template
    Write-Step "Loading settings template..."
    try {
        $template = Get-Content $templatePath -Raw | ConvertFrom-Json
        Write-Success "Template loaded successfully"
    }
    catch {
        Write-ErrorMsg "Failed to parse template: $_"
        return $false
    }
    
    # Check existing settings
    $settingsPath = Join-Path $terminalPath "settings.json"
    $existing = $null
    
    if (Test-Path $settingsPath) {
        Write-Step "Reading existing settings..."
        try {
            $existing = Get-Content $settingsPath -Raw | ConvertFrom-Json
            Write-Success "Existing settings loaded"
            
            # Create backup unless disabled
            if (-not $NoBackup -and -not $Force) {
                $backupPath = "$settingsPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                Copy-Item $settingsPath $backupPath
                Write-Success "Backup created: $backupPath"
            }
        }
        catch {
            Write-ErrorMsg "Failed to read existing settings: $_"
            if (-not $Force) {
                return $false
            }
        }
    }
    
    # Merge or replace settings
    Write-Step "Applying terminal settings..."
    try {
        if ($existing -and -not $Force) {
            Write-Host "  → Applying minimal settings to existing configuration..." -ForegroundColor Yellow
            $finalSettings = Apply-MinimalSettings -Template $template -Existing $existing
        } else {
            Write-Host "  → Creating new settings (no existing configuration found)..." -ForegroundColor Yellow
            # For new installations, create a basic settings file with our essentials
            $finalSettings = @{
                '$schema' = 'https://aka.ms/terminal-profiles-schema'
                initialCols = $template.initialCols
                profiles = @{
                    defaults = $template.profiles.defaults
                    list = @()
                }
            }
        }
        
        # Write settings
        $finalSettings | ConvertTo-Json -Depth 20 | Set-Content $settingsPath -Encoding UTF8
        Write-Success "Windows Terminal settings applied successfully"
        
        return $true
    }
    catch {
        Write-ErrorMsg "Failed to apply settings: $_"
        return $false
    }
}

# Run deployment
try {
    $success = Deploy-WindowsTerminalSettings
    
    if ($success) {
        Write-Host "`n🎉 " -NoNewline -ForegroundColor Green
        Write-Host "Windows Terminal settings deployed successfully!" -ForegroundColor Green
        Write-Host "`n📝 Next Steps:" -ForegroundColor Yellow
        Write-Host "   1. Restart Windows Terminal to see changes" -ForegroundColor White
        Write-Host "   2. Font should automatically be set to 'CaskaydiaCove Nerd Font Mono'" -ForegroundColor White
        Write-Host "   3. Verify that oh-my-posh themes display correctly" -ForegroundColor White
    } else {
        Write-Host "`n❌ Deployment failed. Please check the errors above." -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "`n❌ Deployment failed with error: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}