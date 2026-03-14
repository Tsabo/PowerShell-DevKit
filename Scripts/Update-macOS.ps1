<#
.SYNOPSIS
    Updates all components in your PowerShell environment on macOS
.DESCRIPTION
    Updates Homebrew packages, PowerShell modules, Yazi plugins, and
    git-managed configurations in your PowerShell development environment.
.PARAMETER BrewOnly
    Only update Homebrew packages
.PARAMETER ModulesOnly
    Only update PowerShell modules
.PARAMETER YaziOnly
    Only update Yazi plugins and configuration
.EXAMPLE
    ./Update-macOS.ps1
    Updates all components
.EXAMPLE
    ./Update-macOS.ps1 -BrewOnly
    Only updates Homebrew packages
#>
[CmdletBinding()]
param(
    [switch]$BrewOnly,
    [switch]$ModulesOnly,
    [switch]$YaziOnly
)

# Requires PowerShell 7+
#Requires -Version 7.0

$ErrorActionPreference = "Stop"

# Import shared component definitions
Import-Module (Join-Path $PSScriptRoot "Components.psm1") -Force

# Output formatting functions
function Write-Step {
    param([string]$Message)
    Write-Host "`n🔹 $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

function Write-UpdateResult {
    param([string]$Component, [bool]$Success)

    if ($Success) {
        Write-Host "  ✓ $Component" -ForegroundColor Green
    }
    else {
        Write-Host "  ✗ $Component" -ForegroundColor Red
    }
}

# Check if running on macOS
if (-not $IsMacOS) {
    Write-Host "❌ This script is for macOS only. Use Update.ps1 for Windows." -ForegroundColor Red
    exit 1
}

Write-Host @"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║     PowerShell Environment Update (macOS)                  ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

$results = @{
    BrewSuccess = @()
    BrewFailed = @()
    ModulesSuccess = @()
    ModulesFailed = @()
    YaziSuccess = $false
    ConfigSuccess = $false
}

# Determine what to update based on switches
$updateBrew = (-not $ModulesOnly -and -not $YaziOnly) -or $BrewOnly
$updateModules = (-not $BrewOnly -and -not $YaziOnly) -or $ModulesOnly
$updateYazi = (-not $BrewOnly -and -not $ModulesOnly) -or $YaziOnly

# Update Homebrew packages
if ($updateBrew) {
    Write-Step "Updating Homebrew packages..."

    if (-not (Test-CommandExists "brew")) {
        Write-Host "  ⚠ Homebrew not installed, skipping" -ForegroundColor Yellow
    }
    else {
        try {
            Write-Host "  → Updating Homebrew..." -ForegroundColor Gray
            brew update 2>&1 | Out-Null

            Write-Host "  → Checking for outdated packages..." -ForegroundColor Gray
            $outdated = brew outdated 2>$null

            if (-not $outdated) {
                Write-Success "All Homebrew packages are up to date"
            }
            else {
                $outdatedList = $outdated -split "`n" | Where-Object { $_ }
                Write-Host "  → Found $($outdatedList.Count) outdated package(s)" -ForegroundColor Gray

                Write-Host "  → Upgrading packages..." -ForegroundColor Gray
                $upgradeOutput = brew upgrade 2>&1

                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Homebrew packages updated successfully"
                    $results.BrewSuccess += "Homebrew packages"
                }
                else {
                    Write-Host "  ⚠ Some packages may have failed to update" -ForegroundColor Yellow
                    $results.BrewFailed += "Some Homebrew packages"
                }
            }

            # Cleanup old versions
            Write-Host "  → Cleaning up old versions..." -ForegroundColor Gray
            brew cleanup 2>&1 | Out-Null
            Write-Success "Cleanup completed"
        }
        catch {
            Write-Host "  ✗ Error updating Homebrew: $_" -ForegroundColor Red
            $results.BrewFailed += "Homebrew"
        }
    }
}

# Update PowerShell modules
if ($updateModules) {
    Write-Step "Updating PowerShell modules..."

    $modules = @("PSFzf", "Terminal-Icons", "F7History", "posh-git", "PowerColorLS")
    $installedModules = $modules | Where-Object { Get-Module -ListAvailable -Name $_ }

    if ($installedModules.Count -eq 0) {
        Write-Host "  ⚠ No tracked modules installed" -ForegroundColor Yellow
    }
    else {
        foreach ($moduleName in $installedModules) {
            try {
                Write-Host "  → Checking $moduleName..." -ForegroundColor Gray

                $currentModule = Get-Module -ListAvailable -Name $moduleName |
                    Sort-Object Version -Descending |
                    Select-Object -First 1

                $availableModule = Find-Module -Name $moduleName -Repository PSGallery -ErrorAction SilentlyContinue

                if ($availableModule -and $availableModule.Version -gt $currentModule.Version) {
                    Write-Host "    → Updating from $($currentModule.Version) to $($availableModule.Version)..." -ForegroundColor Gray
                    Update-Module -Name $moduleName -Force -ErrorAction Stop
                    Write-UpdateResult -Component "$moduleName (updated to $($availableModule.Version))" -Success $true
                    $results.ModulesSuccess += $moduleName
                }
                else {
                    Write-Host "    ✓ $moduleName is up to date ($($currentModule.Version))" -ForegroundColor Green
                    $results.ModulesSuccess += $moduleName
                }
            }
            catch {
                Write-Host "    ✗ Failed to update $moduleName : $_" -ForegroundColor Red
                $results.ModulesFailed += $moduleName
            }
        }
    }
}

# Update Yazi and its components
if ($updateYazi) {
    Write-Step "Updating Yazi components..."

    # Update Yazi plugins
    if (Test-CommandExists "ya") {
        try {
            Write-Host "  → Updating Yazi plugins..." -ForegroundColor Gray
            $output = ya pkg update 2>&1
            $outputString = $output | Out-String

            if ($LASTEXITCODE -eq 0) {
                if ($outputString -match "Already up to date|Nothing to update") {
                    Write-Success "Yazi plugins are up to date"
                }
                else {
                    Write-Success "Yazi plugins updated successfully"
                }
                $results.YaziSuccess = $true
            }
            else {
                Write-Host "  ⚠ Yazi plugin update had issues" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "  ✗ Error updating Yazi plugins: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "  ⚠ Yazi (ya) command not found, skipping plugin updates" -ForegroundColor Yellow
    }

    # Update Yazi configuration from git
    $yaziConfigPath = "$HOME/.config/yazi"
    if (Test-Path $yaziConfigPath) {
        $isGitRepo = Test-Path "$yaziConfigPath/.git"

        if ($isGitRepo) {
            Write-Host "  → Updating Yazi configuration repository..." -ForegroundColor Gray

            Push-Location $yaziConfigPath
            try {
                # Check for uncommitted changes
                $gitStatus = git status --porcelain 2>$null
                $hasChanges = $gitStatus -and $gitStatus.Trim()

                if ($hasChanges) {
                    Write-Host "    ⚠ Local modifications detected - skipping update" -ForegroundColor Yellow
                    Write-Host "      To update manually: cd $yaziConfigPath && git stash && git pull && git stash pop" -ForegroundColor DarkGray
                }
                else {
                    $pullOutput = git pull origin main 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        if ($pullOutput -match "Already up to date") {
                            Write-Success "Yazi configuration already up to date"
                        }
                        else {
                            Write-Success "Yazi configuration updated"
                        }
                        $results.ConfigSuccess = $true
                    }
                    else {
                        Write-Host "    ⚠ Could not update configuration" -ForegroundColor Yellow
                    }
                }
            }
            finally {
                Pop-Location
            }
        }
        else {
            Write-Host "  ℹ Yazi config exists but is not git-managed" -ForegroundColor Cyan
        }
    }
}

# Summary
Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    UPDATE SUMMARY                          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$totalSuccess = $results.BrewSuccess.Count + $results.ModulesSuccess.Count +
                $(if ($results.YaziSuccess) { 1 } else { 0 }) +
                $(if ($results.ConfigSuccess) { 1 } else { 0 })

$totalFailed = $results.BrewFailed.Count + $results.ModulesFailed.Count

if ($results.BrewSuccess.Count -gt 0) {
    Write-Host "`n✅ Homebrew Updates:" -ForegroundColor Green
    $results.BrewSuccess | ForEach-Object { Write-Host "   • $_" -ForegroundColor Green }
}

if ($results.ModulesSuccess.Count -gt 0) {
    Write-Host "`n✅ PowerShell Modules:" -ForegroundColor Green
    $results.ModulesSuccess | ForEach-Object { Write-Host "   • $_" -ForegroundColor Green }
}

if ($results.YaziSuccess) {
    Write-Host "`n✅ Yazi Components:" -ForegroundColor Green
    Write-Host "   • Yazi plugins" -ForegroundColor Green
}

if ($results.ConfigSuccess) {
    Write-Host "   • Yazi configuration" -ForegroundColor Green
}

if ($totalFailed -gt 0) {
    Write-Host "`n❌ Failed Updates:" -ForegroundColor Red
    $results.BrewFailed | ForEach-Object { Write-Host "   • $_" -ForegroundColor Red }
    $results.ModulesFailed | ForEach-Object { Write-Host "   • $_" -ForegroundColor Red }
}

Write-Host "`n📊 Results: $totalSuccess successful, $totalFailed failed" -ForegroundColor White

if ($totalFailed -eq 0) {
    Write-Host "`n🎉 All updates completed successfully!" -ForegroundColor Green
}
else {
    Write-Host "`n⚠️  Some updates failed. Check the output above for details." -ForegroundColor Yellow
}

# Suggest profile reload if modules updated
if ($results.ModulesSuccess.Count -gt 0) {
    Write-Host "`n💡 Tip: Restart your PowerShell session or run: " -NoNewline
    Write-Host ". `$PROFILE" -ForegroundColor Yellow
}

Write-Host ""
