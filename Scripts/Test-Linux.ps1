<#
.SYNOPSIS
    Validates PowerShell environment setup on Linux / WSL
.DESCRIPTION
    Checks that all required tools and modules are properly installed and configured
    for a complete PowerShell development environment on Ubuntu / WSL.
.EXAMPLE
    ./Scripts/Test-Linux.ps1
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
    $color  = if ($IsInstalled) { "Green" } else { "Red" }

    $output = "  $status $Component"
    if ($Version -and $IsInstalled) { $output += " ($Version)" }
    if ($Note) { $output += " - $Note" }

    Write-Host $output -ForegroundColor $color
}

function Write-OptionalResult {
    param([string]$Component, [bool]$IsInstalled, [string]$Version = "", [string]$Note = "")

    $status = if ($IsInstalled) { "✓" } else { "⊘" }
    $color  = if ($IsInstalled) { "Green" } else { "Yellow" }

    $output = "  $status $Component (optional)"
    if ($Version -and $IsInstalled) { $output += " ($Version)" }
    if ($Note) { $output += " - $Note" }

    Write-Host $output -ForegroundColor $color
}

function Write-Info {
    param([string]$Message)
    Write-Host "    ℹ $Message" -ForegroundColor Gray
}

# Check platform
if (-not $IsLinux) {
    Write-Host "❌ This script is for Linux / WSL only. Use Test.ps1 for Windows or Test-macOS.ps1 for macOS." -ForegroundColor Red
    exit 1
}

# Detect WSL
$kernelVersion = Get-Content /proc/version -ErrorAction SilentlyContinue
$isWSL = $kernelVersion -match "microsoft|WSL"

Write-Host @"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║     PowerShell Environment Validation (Linux / WSL)        ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

if ($isWSL) {
    Write-Host "  ℹ Running inside WSL" -ForegroundColor Cyan
}

$totalChecks   = 0
$passedChecks  = 0
$failedChecks  = 0
$optionalFails = 0

# ─── Package manager ──────────────────────────────────────────────────────────

Write-CheckHeader "Package Manager"

$totalChecks++
$aptInstalled = Test-CommandExists "apt-get"
Write-CheckResult -Component "apt (Ubuntu/Debian)" -IsInstalled $aptInstalled `
    -Note $(if (-not $aptInstalled) { "Unsupported distro — only Ubuntu/Debian is tested" })

if ($aptInstalled) { $passedChecks++ } else { $failedChecks++ }

# ─── Core tools ───────────────────────────────────────────────────────────────

Write-CheckHeader "Core Tools"

$coreTools = @(
    @{Name = "oh-my-posh";      Command = "oh-my-posh"; VersionCmd = { oh-my-posh version }; InstallHint = "Run ./Scripts/Setup-Linux.ps1" }
    @{Name = "fzf";             Command = "fzf";        VersionCmd = { (fzf --version).Split(' ')[0] }; InstallHint = "sudo apt-get install fzf" }
    @{Name = "zoxide";          Command = "zoxide";     VersionCmd = { (zoxide --version).Split(' ')[1] }; InstallHint = "Run ./Scripts/Setup-Linux.ps1" }
    @{Name = "glow";            Command = "glow";       VersionCmd = { (glow --version).Split(' ')[-1] }; InstallHint = "Run ./Scripts/Setup-Linux.ps1 (adds charm.sh repo)" }
    @{Name = "yazi";            Command = "yazi";       VersionCmd = { (yazi --version).Split(' ')[1] }; InstallHint = "Run ./Scripts/Setup-Linux.ps1" }
    @{Name = "Microsoft Edit";  Command = "edit";       VersionCmd = { (edit --version 2>&1 | Select-Object -First 1) }; InstallHint = "Run ./Scripts/Setup-Linux.ps1 (installs via snap)" }
)

foreach ($tool in $coreTools) {
    $totalChecks++
    $installed = Test-CommandExists $tool.Command

    $version = if ($installed -and $tool.VersionCmd) {
        try { & $tool.VersionCmd } catch { "unknown" }
    }
    else { "" }

    Write-CheckResult -Component $tool.Name -IsInstalled $installed -Version $version

    if ($installed) {
        $passedChecks++
    }
    else {
        $failedChecks++
        Write-Info $tool.InstallHint
    }
}

# ─── PowerShell modules ───────────────────────────────────────────────────────

Write-CheckHeader "PowerShell Modules"

$requiredModules = @("PSFzf", "Terminal-Icons", "F7History", "posh-git")

foreach ($moduleName in $requiredModules) {
    $totalChecks++
    $module = Get-Module -ListAvailable -Name $moduleName | Select-Object -First 1
    $installed = $null -ne $module

    Write-CheckResult -Component $moduleName -IsInstalled $installed -Version $(if ($module) { $module.Version })

    if ($installed) { $passedChecks++ } else {
        $failedChecks++
        Write-Info "Install with: Install-Module $moduleName -Scope CurrentUser"
    }
}

# PowerColorLS is optional
$pclsModule = Get-Module -ListAvailable -Name "PowerColorLS" | Select-Object -First 1
Write-OptionalResult -Component "PowerColorLS" -IsInstalled ($null -ne $pclsModule) `
    -Version $(if ($pclsModule) { $pclsModule.Version })

# ─── Fonts ────────────────────────────────────────────────────────────────────

Write-CheckHeader "Fonts"

if ($isWSL) {
    # In WSL, the font lives on the Windows side — check Windows fonts via /mnt/c
    $winLocalAppData = bash -c "wslpath '\$(cmd.exe /c echo %LOCALAPPDATA% 2>/dev/null)'" 2>$null
    $winLocalAppData = if ($winLocalAppData) { ($winLocalAppData | Select-Object -First 1).ToString().Trim() } else { $null }

    $cascadiaFound = $false
    if ($winLocalAppData -and (Test-Path $winLocalAppData)) {
        $winFontsPath   = Join-Path $winLocalAppData "Microsoft/Windows/Fonts"
        $sysFontsPath   = "/mnt/c/Windows/Fonts"
        $cascadiaFiles  = @(
            Get-ChildItem -Path $winFontsPath -Filter "Cascadia*" -ErrorAction SilentlyContinue
            Get-ChildItem -Path $sysFontsPath -Filter "Cascadia*" -ErrorAction SilentlyContinue
        )
        $cascadiaFound = $cascadiaFiles.Count -gt 0
    }

    $totalChecks++
    if ($cascadiaFound) {
        $passedChecks++
        Write-CheckResult -Component "CaskaydiaCove Nerd Font (Windows)" -IsInstalled $true -Note "detected in Windows Fonts"
    }
    else {
        $failedChecks++
        Write-CheckResult -Component "CaskaydiaCove Nerd Font (Windows)" -IsInstalled $false
        Write-Info "Run .\Scripts\Setup.ps1 on Windows, or: oh-my-posh font install CascadiaCode (on Windows)"
        Write-Info "Then set 'CaskaydiaCove Nerd Font Mono' in Windows Terminal → Profiles → Defaults → Appearance"
    }
}
else {
    # Native Linux: check XDG font directories
    $xdgFontDirs = @(
        "$HOME/.local/share/fonts",
        "/usr/share/fonts",
        "/usr/local/share/fonts"
    )
    $cascadiaFiles = @(
        $xdgFontDirs | ForEach-Object {
            Get-ChildItem -Path $_ -Recurse -Filter "*Caskaydia*" -ErrorAction SilentlyContinue
        }
    )

    $totalChecks++
    $fontInstalled = $cascadiaFiles.Count -gt 0
    Write-CheckResult -Component "CaskaydiaCove Nerd Font" -IsInstalled $fontInstalled `
        -Note $(if ($fontInstalled) { "$($cascadiaFiles.Count) font file(s) found" })

    if ($fontInstalled) { $passedChecks++ } else {
        $failedChecks++
        Write-Info "Install with: oh-my-posh font install CascadiaCode"
    }
}

# ─── PowerShell configuration ─────────────────────────────────────────────────

Write-CheckHeader "PowerShell Configuration"

$totalChecks++
$profileExists = Test-Path $PROFILE

Write-CheckResult -Component "PowerShell Profile" -IsInstalled $profileExists

if ($profileExists) {
    $passedChecks++
    $profileContent = Get-Content $PROFILE -Raw
    $configChecks = @{
        "oh-my-posh initialization" = $profileContent -match "oh-my-posh init"
        "Terminal-Icons import"     = $profileContent -match "Terminal-Icons"
        "posh-git import"           = $profileContent -match "posh-git"
        "zoxide initialization"     = $profileContent -match "zoxide init"
        "PSReadLine configuration"  = $profileContent -match "PSReadLine"
    }

    $issues = @()
    foreach ($check in $configChecks.GetEnumerator()) {
        if (-not $check.Value) { $issues += $check.Key }
    }

    if ($issues.Count -gt 0) {
        Write-Info "Profile missing configurations:"
        foreach ($issue in $issues) { Write-Host "      • $issue" -ForegroundColor Yellow }
    }
    else {
        Write-Info "All expected configurations present"
    }
}
else {
    $failedChecks++
    Write-Info "Run: ./Scripts/Setup-Linux.ps1 to deploy profile"
}

# Yazi configuration
$totalChecks++
$yaziConfigPath  = "$HOME/.config/yazi"
$yaziConfigExists = Test-Path $yaziConfigPath

Write-CheckResult -Component "Yazi Configuration" -IsInstalled $yaziConfigExists

if ($yaziConfigExists) {
    $passedChecks++
    $isGitRepo = Test-Path "$yaziConfigPath/.git"
    if ($isGitRepo) { Write-Info "Configuration is git-managed (can be updated)" }

    $pluginsPath = "$yaziConfigPath/plugins"
    if (Test-Path $pluginsPath) {
        $pluginCount = (Get-ChildItem $pluginsPath -Directory -ErrorAction SilentlyContinue).Count
        Write-Info "$pluginCount plugin(s) installed"
    }
}
else {
    $failedChecks++
    Write-Info "Will be created by Setup-Linux.ps1"
}

# oh-my-posh themes
$totalChecks++
$ompThemePath   = "$HOME/.config/powershell/Posh"
$ompThemesExist = Test-Path $ompThemePath

Write-CheckResult -Component "oh-my-posh Themes" -IsInstalled $ompThemesExist

if ($ompThemesExist) {
    $passedChecks++
    $themeCount = (Get-ChildItem $ompThemePath -Filter "*.json" -ErrorAction SilentlyContinue).Count
    if ($themeCount -gt 0) { Write-Info "$themeCount custom theme(s) deployed" }
}
else {
    $failedChecks++
    Write-Info "Run ./Scripts/Setup-Linux.ps1 to deploy themes"
}

# ─── Summary ──────────────────────────────────────────────────────────────────

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                       SUMMARY                              ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$passRate = [math]::Round(($passedChecks / $totalChecks) * 100, 1)
Write-Host "`nTotal Checks : $totalChecks" -ForegroundColor White
Write-Host "Passed       : $passedChecks" -ForegroundColor Green
Write-Host "Failed       : $failedChecks" -ForegroundColor $(if ($failedChecks -gt 0) { "Red" } else { "Green" })
Write-Host "Success Rate : $passRate%" -ForegroundColor $(if ($passRate -ge 90) { "Green" } elseif ($passRate -ge 70) { "Yellow" } else { "Red" })

if ($failedChecks -eq 0) {
    Write-Host "`n🎉 All checks passed! Your PowerShell environment is properly configured." -ForegroundColor Green
}
elseif ($failedChecks -le 3) {
    Write-Host "`n⚠️  Almost there! A few components need attention." -ForegroundColor Yellow
    Write-Host "Run ./Scripts/Setup-Linux.ps1 to install missing components." -ForegroundColor White
}
else {
    Write-Host "`n❌ Several components are missing or misconfigured." -ForegroundColor Red
    Write-Host "Run ./Scripts/Setup-Linux.ps1 to set up your environment." -ForegroundColor White
}

Write-Host ""

# Exit code: 0 = all required passed, 1 = missing required
exit $(if ($failedChecks -gt 0) { 1 } else { 0 })
