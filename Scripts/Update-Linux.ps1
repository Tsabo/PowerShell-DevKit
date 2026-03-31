<#
.SYNOPSIS
    Updates all components in your PowerShell environment on Linux / WSL
.DESCRIPTION
    Updates apt packages, PowerShell modules, and Yazi plugins / git-managed
    configurations in your PowerShell development environment on Ubuntu / WSL.
.PARAMETER AptOnly
    Only update apt packages and binaries installed via scripts
.PARAMETER ModulesOnly
    Only update PowerShell modules
.PARAMETER YaziOnly
    Only update Yazi plugins and configuration
.EXAMPLE
    ./Scripts/Update-Linux.ps1
    Updates all components
.EXAMPLE
    ./Scripts/Update-Linux.ps1 -ModulesOnly
    Only updates PowerShell modules
#>
[CmdletBinding()]
param(
    [switch]$AptOnly,
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

# Check platform
if (-not $IsLinux) {
    Write-Host "❌ This script is for Linux / WSL only. Use Update.ps1 for Windows or Update-macOS.ps1 for macOS." -ForegroundColor Red
    exit 1
}

Write-Host @"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║     PowerShell Environment Update (Linux / WSL)            ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

$results = @{
    AptSuccess     = @()
    AptFailed      = @()
    ModulesSuccess = @()
    ModulesFailed  = @()
    YaziSuccess    = $false
}

# Determine what to update
$updateApt     = (-not $ModulesOnly -and -not $YaziOnly) -or $AptOnly
$updateModules = (-not $AptOnly -and -not $YaziOnly) -or $ModulesOnly
$updateYazi    = (-not $AptOnly -and -not $ModulesOnly) -or $YaziOnly

# ─── Update apt packages ──────────────────────────────────────────────────────

if ($updateApt) {
    Write-Step "Updating apt packages..."

    if (-not (Test-CommandExists "apt-get")) {
        Write-Host "  ⚠ apt-get not found, skipping" -ForegroundColor Yellow
    }
    else {
        try {
            Write-Host "  → Running apt-get update..." -ForegroundColor Gray
            bash -c "sudo apt-get update -qq 2>&1" | Out-Null

            # Update tracked apt packages
            $aptPackages = @("fzf", "glow")
            foreach ($pkg in $aptPackages) {
                if (Test-CommandExists $pkg) {
                    Write-Host "  → Upgrading $pkg..." -ForegroundColor Gray
                    bash -c "sudo apt-get install --only-upgrade -y '$pkg' 2>&1" | Out-Null
                    if ($LASTEXITCODE -eq 0) {
                        $results.AptSuccess += $pkg
                    }
                    else {
                        $results.AptFailed += $pkg
                    }
                }
            }

            Write-Success "apt packages checked"
        }
        catch {
            Write-Host "  ✗ Error updating apt packages: $_" -ForegroundColor Red
            $results.AptFailed += "apt packages"
        }
    }

    # Update Microsoft Edit via snap
    Write-Step "Updating Microsoft Edit..."

    if (Test-CommandExists "snap") {
        try {
            Write-Host "  → Running snap refresh..." -ForegroundColor Gray
            $before = if (Test-CommandExists "edit") { edit --version 2>&1 | Select-Object -First 1 } else { "" }
            bash -c "sudo snap refresh ms-edit 2>&1" | Out-Null
            $after = if (Test-CommandExists "edit") { edit --version 2>&1 | Select-Object -First 1 } else { "" }

            if ($before -ne $after) {
                Write-Success "Microsoft Edit updated ($before → $after)"
            }
            else {
                Write-Host "  ✓ Microsoft Edit is already up to date" -ForegroundColor Green
            }
            $results.AptSuccess += "Microsoft Edit"
        }
        catch {
            Write-Host "  ✗ Error updating Microsoft Edit: $_" -ForegroundColor Red
            $results.AptFailed += "Microsoft Edit"
        }
    }
    else {
        Write-Host "  ⚠ snap not available, skipping Microsoft Edit update" -ForegroundColor Yellow
    }

    # Update oh-my-posh (re-run official install script — it updates in-place)
    Write-Step "Updating oh-my-posh..."

    if (Test-CommandExists "oh-my-posh") {
        try {
            Write-Host "  → Running official install script to check for updates..." -ForegroundColor Gray
            $localBin = "$HOME/.local/bin"

            $before = if (Test-CommandExists "oh-my-posh") { oh-my-posh version 2>$null } else { "" }
            bash -c "curl -s https://ohmyposh.dev/install.sh | bash -s -- -d '$localBin' 2>&1" | Out-Null
            $after  = if (Test-CommandExists "oh-my-posh") { oh-my-posh version 2>$null } else { "" }

            if ($before -ne $after) {
                Write-Success "oh-my-posh updated ($before → $after)"
                $results.AptSuccess += "oh-my-posh"
            }
            else {
                Write-Host "  ✓ oh-my-posh is already up to date ($before)" -ForegroundColor Green
                $results.AptSuccess += "oh-my-posh"
            }
        }
        catch {
            Write-Host "  ✗ Error updating oh-my-posh: $_" -ForegroundColor Red
            $results.AptFailed += "oh-my-posh"
        }
    }
    else {
        Write-Host "  ⚠ oh-my-posh not installed, skipping" -ForegroundColor Yellow
    }

    # Update zoxide (re-run official install script)
    Write-Step "Updating zoxide..."

    if (Test-CommandExists "zoxide") {
        try {
            Write-Host "  → Running official install script to check for updates..." -ForegroundColor Gray
            $before = if (Test-CommandExists "zoxide") { zoxide --version 2>$null } else { "" }
            bash -c "curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh 2>&1" | Out-Null
            $after  = if (Test-CommandExists "zoxide") { zoxide --version 2>$null } else { "" }

            if ($before -ne $after) {
                Write-Success "zoxide updated ($before → $after)"
                $results.AptSuccess += "zoxide"
            }
            else {
                Write-Host "  ✓ zoxide is already up to date ($before)" -ForegroundColor Green
                $results.AptSuccess += "zoxide"
            }
        }
        catch {
            Write-Host "  ✗ Error updating zoxide: $_" -ForegroundColor Red
            $results.AptFailed += "zoxide"
        }
    }
    else {
        Write-Host "  ⚠ zoxide not installed, skipping" -ForegroundColor Yellow
    }

    # Update Yazi binary from GitHub releases
    Write-Step "Updating Yazi binary..."

    if (Test-CommandExists "yazi") {
        try {
            $currentVersion = (yazi --version 2>$null).Split(' ') | Select-Object -Last 1

            Write-Host "  → Checking latest Yazi release on GitHub..." -ForegroundColor Gray
            $releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/sxyazi/yazi/releases/latest" -ErrorAction SilentlyContinue
            $latestVersion = if ($releaseInfo -and $releaseInfo.tag_name) { $releaseInfo.tag_name -replace '^v', '' } else { $null }

            if ($latestVersion -and $latestVersion -ne $currentVersion) {
                Write-Host "  → Updating Yazi from $currentVersion to $latestVersion..." -ForegroundColor Gray

                $archRaw = bash -c "uname -m" 2>$null
                $arch = if ($archRaw) { ($archRaw | Select-Object -First 1).ToString().Trim() } else { $null }
                $yaziArch = switch ($arch) {
                    "x86_64"  { "x86_64-unknown-linux-musl" }
                    "aarch64" { "aarch64-unknown-linux-musl" }
                    "armv7l"  { "armv7-unknown-linux-musleabihf" }
                    default   { $null }
                }

                if ($yaziArch) {
                    $localBin = "$HOME/.local/bin"

                    # Ensure unzip is available
                    $unzipCheck = bash -c "dpkg -s unzip 2>/dev/null | grep -q '^Status: install ok installed'" 2>&1
                    if ($LASTEXITCODE -ne 0) {
                        Write-Host "  → Installing unzip..." -ForegroundColor Gray
                        bash -c "sudo apt-get install -y unzip 2>&1" | Out-Null
                    }

                    $scriptContent = (@'
set -e
TMP=$(mktemp -d)
cd "$TMP"
curl -fsSL "https://github.com/sxyazi/yazi/releases/latest/download/yazi-YAZI_ARCH.zip" -o yazi.zip
unzip -q yazi.zip
install -m755 "yazi-YAZI_ARCH/yazi" "LOCAL_BIN/yazi"
install -m755 "yazi-YAZI_ARCH/ya" "LOCAL_BIN/ya"
rm -rf "$TMP"
'@) -replace 'YAZI_ARCH', $yaziArch -replace 'LOCAL_BIN', $localBin

                    $tmpScript = "/tmp/yazi-update-$PID.sh"
                    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
                    try {
                        $scriptBytes = $utf8NoBom.GetBytes(($scriptContent -replace "`r`n", "`n"))
                        [System.IO.File]::WriteAllBytes($tmpScript, $scriptBytes)
                        bash $tmpScript 2>&1 | Out-Null
                        $exitCode = $LASTEXITCODE
                    }
                    finally {
                        Remove-Item $tmpScript -ErrorAction SilentlyContinue
                    }

                    if ($exitCode -eq 0) {
                        Write-Success "Yazi binary updated to $latestVersion"
                        $results.AptSuccess += "Yazi binary"
                    }
                    else {
                        Write-Host "  ✗ Yazi binary update failed" -ForegroundColor Red
                        $results.AptFailed += "Yazi binary"
                    }
                }
                else {
                    Write-Host "  ⚠ Unsupported architecture: $arch" -ForegroundColor Yellow
                }
            }
            else {
                Write-Host "  ✓ Yazi is already up to date ($currentVersion)" -ForegroundColor Green
                $results.AptSuccess += "Yazi binary"
            }
        }
        catch {
            Write-Host "  ⚠ Could not check Yazi release (network issue?): $_" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "  ⚠ Yazi not installed, skipping" -ForegroundColor Yellow
    }
}

# ─── Update PowerShell modules ────────────────────────────────────────────────

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

# ─── Update Yazi components ───────────────────────────────────────────────────

if ($updateYazi) {
    Write-Step "Updating Yazi components..."

    # Update Yazi plugins via ya
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
        Write-Host "  ⚠ Yazi (ya) command not found — skipping plugin updates" -ForegroundColor Yellow
    }

    # Update Yazi configuration git repo
    $yaziConfigPath = "$HOME/.config/yazi"
    if (Test-Path "$yaziConfigPath/.git") {
        Write-Host "  → Updating Yazi configuration repository..." -ForegroundColor Gray
        Push-Location $yaziConfigPath
        try {
            $gitStatus = git status --porcelain 2>$null
            if ($gitStatus -and $gitStatus.Trim()) {
                Write-Host "  ⚠ Local modifications detected — skipping config update" -ForegroundColor Yellow
                Write-Host "    To update manually: cd '$yaziConfigPath' && git stash && git pull && git stash pop" -ForegroundColor DarkGray
            }
            else {
                $gitOutput = git pull origin main 2>&1
                if ($LASTEXITCODE -eq 0) {
                    if ($gitOutput -match "Already up to date") {
                        Write-Success "Yazi configuration already up to date"
                    }
                    else {
                        Write-Success "Yazi configuration updated"
                    }
                }
                else {
                    Write-Host "  ⚠ Could not update Yazi configuration (network issue?)" -ForegroundColor Yellow
                }
            }
        }
        finally {
            Pop-Location
        }
    }
}

# ─── Summary ──────────────────────────────────────────────────────────────────

Write-Host @"

╔════════════════════════════════════════════════════════════╗
║                    UPDATE SUMMARY                           ║
╚════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

if ($updateApt) {
    Write-Host "`n📦 Packages / Binaries:" -ForegroundColor White
    $results.AptSuccess | ForEach-Object { Write-Host "   ✓ $_" -ForegroundColor Green }
    $results.AptFailed  | ForEach-Object { Write-Host "   ✗ $_" -ForegroundColor Red }
}

if ($updateModules) {
    Write-Host "`n📚 PowerShell Modules:" -ForegroundColor White
    $results.ModulesSuccess | ForEach-Object { Write-Host "   ✓ $_" -ForegroundColor Green }
    $results.ModulesFailed  | ForEach-Object { Write-Host "   ✗ $_" -ForegroundColor Red }
}

if ($updateYazi) {
    Write-Host "`n🗂️  Yazi:" -ForegroundColor White
    if ($results.YaziSuccess) {
        Write-Host "   ✓ Plugins" -ForegroundColor Green
    }
}

$totalFailed = $results.AptFailed.Count + $results.ModulesFailed.Count
if ($totalFailed -eq 0) {
    Write-Host "`n🎉 Everything is up to date!" -ForegroundColor Green
}
else {
    Write-Host "`n⚠️  $totalFailed component(s) failed to update. Check the output above." -ForegroundColor Yellow
}

if ($results.ModulesSuccess.Count -gt 0) {
    Write-Host "`n💡 Tip: Restart your PowerShell session to use updated modules." -ForegroundColor Cyan
}

Write-Host ""
