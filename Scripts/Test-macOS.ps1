<#
.SYNOPSIS
    Validates PowerShell environment setup on macOS
.DESCRIPTION
    Checks that all required tools and modules are properly installed and configured
    for a complete PowerShell development environment on macOS.
.EXAMPLE
    ./Test-macOS.ps1
#>
[CmdletBinding()]
param()

# Requires PowerShell 7+
#Requires -Version 7.0

# Import shared component definitions
Import-Module (Join-Path $PSScriptRoot "Components.psm1") -Force

# Output formatting functions
function Write-CheckHeader {
    param([string]$Message)
    Write-Host "`n━━━ $Message ━━━" -ForegroundColor Cyan
}

function Write-CheckResult {
    param(
        [string]$Component,
        [bool]$IsInstalled,
        [string]$Version = "",
        [string]$Note = ""
    )

    $status = if ($IsInstalled) { "✓" } else { "✗" }
    $color = if ($IsInstalled) { "Green" } else { "Red" }

    $output = "  $status $Component"
    if ($Version -and $IsInstalled) {
        $output += " ($Version)"
    }
    if ($Note) {
        $output += " - $Note"
    }

    Write-Host $output -ForegroundColor $color
}

function Write-Info {
    param([string]$Message)
    Write-Host "    ℹ $Message" -ForegroundColor Gray
}

# Check if running on macOS
if (-not $IsMacOS) {
    Write-Host "❌ This script is for macOS only. Use Test.ps1 for Windows." -ForegroundColor Red
    exit 1
}

Write-Host @"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║     PowerShell Environment Validation (macOS)              ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

$totalChecks = 0
$passedChecks = 0
$failedChecks = 0

# Check Homebrew
Write-CheckHeader "Package Manager"
$brewInstalled = Test-CommandExists "brew"
Write-CheckResult -Component "Homebrew" -IsInstalled $brewInstalled -Version $(if ($brewInstalled) { (brew --version).Split("`n")[0] })
if ($brewInstalled) { $passedChecks++ } else { $failedChecks++ }
$totalChecks++

if (-not $brewInstalled) {
    Write-Info "Install with: /bin/bash -c `"`$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)`""
}

# Check Homebrew packages
Write-CheckHeader "Core Tools (Homebrew)"

$brewPackages = @(
    @{Name = "oh-my-posh"; Command = "oh-my-posh"; VersionCmd = { oh-my-posh version } }
    @{Name = "fzf"; Command = "fzf"; VersionCmd = { (fzf --version).Split(' ')[0] } }
    @{Name = "zoxide"; Command = "zoxide"; VersionCmd = { (zoxide --version).Split(' ')[1] } }
    @{Name = "Microsoft Edit"; Command = "edit"; VersionCmd = { (edit --version 2>&1 | Select-Object -First 1) } }
    @{Name = "glow"; Command = "glow"; VersionCmd = { (glow --version).Split(' ')[-1] } }
    @{Name = "yazi"; Command = "yazi"; VersionCmd = { (yazi --version).Split(' ')[1] } }
)

foreach ($pkg in $brewPackages) {
    $totalChecks++
    $isInstalled = Test-CommandExists $pkg.Command

    $version = if ($isInstalled -and $pkg.VersionCmd) {
        try { & $pkg.VersionCmd } catch { "unknown" }
    } else { "" }

    Write-CheckResult -Component $pkg.Name -IsInstalled $isInstalled -Version $version

    if ($isInstalled) { $passedChecks++ } else {
        $failedChecks++
        Write-Info "Install with: brew install $($pkg.Name.ToLower())"
    }
}

# Check PowerShell modules
Write-CheckHeader "PowerShell Modules"

$modules = @("PSFzf", "Terminal-Icons", "F7History", "posh-git", "PowerColorLS")

foreach ($moduleName in $modules) {
    $totalChecks++
    $module = Get-Module -ListAvailable -Name $moduleName | Select-Object -First 1
    $isInstalled = $null -ne $module

    Write-CheckResult -Component $moduleName -IsInstalled $isInstalled -Version $(if ($module) { $module.Version })

    if ($isInstalled) { $passedChecks++ } else {
        $failedChecks++
        Write-Info "Install with: Install-Module $moduleName -Scope CurrentUser"
    }
}

# Check CascadiaCode font
Write-CheckHeader "Fonts"

$totalChecks++
$fontDir = "$HOME/Library/Fonts"
$cascadiaFontFiles = @(Get-ChildItem -Path $fontDir -Filter "*Caskaydia*" -ErrorAction SilentlyContinue)

$fontInstalled = $cascadiaFontFiles.Count -gt 0
Write-CheckResult -Component "CaskaydiaCove Nerd Font" -IsInstalled $fontInstalled -Note $(if ($fontInstalled) { "$($cascadiaFontFiles.Count) font files found" })

if ($fontInstalled) { $passedChecks++ } else {
    $failedChecks++
    Write-Info "Install with: brew install --cask font-caskaydia-cove-nerd-font"
}

# Check PowerShell profile
Write-CheckHeader "PowerShell Configuration"

$totalChecks++
$profileExists = Test-Path $PROFILE

Write-CheckResult -Component "PowerShell Profile" -IsInstalled $profileExists

if ($profileExists) {
    $passedChecks++

    # Check profile content
    $profileContent = Get-Content $PROFILE -Raw
    $checks = @{
        "oh-my-posh initialization" = $profileContent -match "oh-my-posh.*--init"
        "Terminal-Icons import" = $profileContent -match "Terminal-Icons"
        "posh-git import" = $profileContent -match "posh-git"
        "zoxide initialization" = $profileContent -match "zoxide init"
        "PSReadLine configuration" = $profileContent -match "PSReadLine"
    }

    $configIssues = @()
    foreach ($check in $checks.GetEnumerator()) {
        if (-not $check.Value) {
            $configIssues += $check.Key
        }
    }

    if ($configIssues.Count -gt 0) {
        Write-Info "Profile missing configurations:"
        foreach ($issue in $configIssues) {
            Write-Host "      • $issue" -ForegroundColor Yellow
        }
    }
    else {
        Write-Info "All expected configurations present"
    }
}
else {
    $failedChecks++
    Write-Info "Run: ./Setup-macOS.ps1 to deploy profile"
}

# Check Yazi configuration
$totalChecks++
$yaziConfigPath = "$HOME/.config/yazi"
$yaziConfigExists = Test-Path $yaziConfigPath

Write-CheckResult -Component "Yazi Configuration" -IsInstalled $yaziConfigExists

if ($yaziConfigExists) {
    $passedChecks++

    # Check if it's a git repo
    $isGitRepo = Test-Path "$yaziConfigPath/.git"
    if ($isGitRepo) {
        Write-Info "Configuration is git-managed (can be updated)"
    }

    # Check for plugins
    $pluginsPath = "$yaziConfigPath/plugins"
    if (Test-Path $pluginsPath) {
        $pluginCount = (Get-ChildItem $pluginsPath -Directory -ErrorAction SilentlyContinue).Count
        Write-Info "$pluginCount plugins installed"
    }
} else {
    $failedChecks++
    Write-Info "Will be created by Setup-macOS.ps1"
}

# Check oh-my-posh themes
$totalChecks++
$ompThemePath = "$HOME/.config/powershell/Posh"
$ompThemesExist = Test-Path $ompThemePath

Write-CheckResult -Component "oh-my-posh Themes" -IsInstalled $ompThemesExist

if ($ompThemesExist) {
    $passedChecks++
    $themeCount = (Get-ChildItem $ompThemePath -Filter "*.json" -ErrorAction SilentlyContinue).Count
    if ($themeCount -gt 0) {
        Write-Info "$themeCount custom theme(s) deployed"
    }
} else {
    $failedChecks++
    Write-Info "Run Setup-macOS.ps1 to deploy themes"
}

# Summary
Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                       SUMMARY                              ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$passRate = [math]::Round(($passedChecks / $totalChecks) * 100, 1)
Write-Host "`nTotal Checks: $totalChecks" -ForegroundColor White
Write-Host "Passed: $passedChecks" -ForegroundColor Green
Write-Host "Failed: $failedChecks" -ForegroundColor $(if ($failedChecks -gt 0) { "Red" } else { "Green" })
Write-Host "Success Rate: $passRate%" -ForegroundColor $(if ($passRate -ge 90) { "Green" } elseif ($passRate -ge 70) { "Yellow" } else { "Red" })

if ($failedChecks -eq 0) {
    Write-Host "`n🎉 All checks passed! Your PowerShell environment is properly configured." -ForegroundColor Green
}
elseif ($failedChecks -le 3) {
    Write-Host "`n⚠️  Almost there! A few components need attention." -ForegroundColor Yellow
    Write-Host "Run ./Setup-macOS.ps1 to install missing components." -ForegroundColor White
}
else {
    Write-Host "`n❌ Several components are missing or misconfigured." -ForegroundColor Red
    Write-Host "Run ./Setup-macOS.ps1 to set up your environment." -ForegroundColor White
}

Write-Host ""
