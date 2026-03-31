<#
.SYNOPSIS
    Automated PowerShell environment setup for Ubuntu / WSL
.DESCRIPTION
    Sets up a complete PowerShell development environment on Ubuntu (including WSL)
    with all required tools and modules using apt and official install scripts.
.PARAMETER SkipOptional
    Skip installation of optional components
.PARAMETER ShowDetails
    Shows detailed failure information from previous setup runs
.PARAMETER ClearLogs
    Clears stored failure logs
.EXAMPLE
    ./Scripts/Setup-Linux.ps1
.EXAMPLE
    ./Scripts/Setup-Linux.ps1 -SkipOptional
.EXAMPLE
    ./Scripts/Setup-Linux.ps1 -ShowDetails
#>
[CmdletBinding()]
param(
    [switch]$SkipOptional,
    [switch]$ShowDetails,
    [switch]$ClearLogs
)

# Requires PowerShell 7+
#Requires -Version 7.0

$ErrorActionPreference = "Stop"

# Import shared component definitions
Import-Module (Join-Path $PSScriptRoot "Components.psm1") -Force

# Setup logging
$logDir = Join-Path $PSScriptRoot "Logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}
$logFile = Join-Path $logDir "setup-linux-details.json"

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

# Log detailed failure information
function Write-SetupLog {
    param(
        [string]$Component,
        [string]$Type,
        [string]$Operation,
        [string]$ErrorMessage,
        [string]$FullOutput = "",
        [int]$ExitCode = 0
    )

    $logEntry = @{
        Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Component    = $Component
        Type         = $Type
        Operation    = $Operation
        ErrorMessage = $ErrorMessage
        FullOutput   = $FullOutput
        ExitCode     = $ExitCode
    }

    $logData = [System.Collections.ArrayList]@()
    if (Test-Path $logFile) {
        try {
            $existing = Get-Content $logFile -Raw | ConvertFrom-Json
            if ($existing) {
                $logData = [System.Collections.ArrayList]@($existing)
            }
        }
        catch {
            $logData = [System.Collections.ArrayList]@()
        }
    }

    $logData.Add($logEntry) | Out-Null
    if ($logData.Count -gt 50) {
        $logData = [System.Collections.ArrayList]@($logData[-50..-1])
    }

    @($logData) | ConvertTo-Json -Depth 3 | Set-Content $logFile
}

# Show detailed setup failure information
function Show-SetupDetails {
    if (-not (Test-Path $logFile)) {
        Write-Host "No setup failure details found. Run a setup first." -ForegroundColor Yellow
        return
    }

    try {
        $logData = Get-Content $logFile -Raw | ConvertFrom-Json
        $recentFailures = $logData | Where-Object { $_.Timestamp -gt (Get-Date).AddDays(-7) }

        if ($recentFailures.Count -eq 0) {
            Write-Host "No recent setup failures found in the last 7 days." -ForegroundColor Green
            return
        }

        Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "║                 SETUP FAILURE DETAILS                      ║" -ForegroundColor Red
        Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Red

        $groupedFailures = $recentFailures | Group-Object Component

        foreach ($group in $groupedFailures) {
            $component = $group.Name
            $failures = $group.Group | Sort-Object Timestamp -Descending
            $latestFailure = $failures[0]

            Write-Host "`n🔸 $component ($($latestFailure.Type))" -ForegroundColor Yellow
            Write-Host "   Last failure: $($latestFailure.Timestamp)" -ForegroundColor Gray
            Write-Host "   Operation: $($latestFailure.Operation)" -ForegroundColor Gray

            if ($latestFailure.ExitCode) {
                Write-Host "   Exit Code: $($latestFailure.ExitCode)" -ForegroundColor Red
            }

            if ($latestFailure.ErrorMessage) {
                Write-Host "   Error: $($latestFailure.ErrorMessage)" -ForegroundColor Red
            }

            if ($latestFailure.FullOutput -and $latestFailure.FullOutput.Trim()) {
                Write-Host "   Output:" -ForegroundColor Gray
                $latestFailure.FullOutput -split "`n" | Select-Object -First 5 | ForEach-Object {
                    if ($_.Trim()) { Write-Host "     $($_.Trim())" -ForegroundColor DarkGray }
                }
            }

            if ($failures.Count -gt 1) {
                Write-Host "   Failure frequency: $($failures.Count) times in last 7 days" -ForegroundColor Yellow
            }
        }
    }
    catch {
        Write-Host "Error reading setup failure details: $_" -ForegroundColor Red
    }
}

# ─── Apt helper ───────────────────────────────────────────────────────────────

function Install-AptPackage {
    param(
        [string]$PackageName,
        [string]$DisplayName = $null
    )

    if (-not $DisplayName) { $DisplayName = $PackageName }

    # Check if already installed
    $check = bash -c "dpkg -s '$PackageName' 2>/dev/null | grep -q '^Status: install ok installed'" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Skip "$DisplayName is already installed"
        return $true
    }

    Write-Host "  → Installing $DisplayName via apt..." -ForegroundColor Gray
    try {
        $output = bash -c "sudo apt-get install -y '$PackageName' 2>&1"
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0) {
            Write-Success "$DisplayName installed successfully"
            return $true
        }
        else {
            Write-ErrorMsg "Failed to install $DisplayName (exit code: $exitCode)"
            Write-SetupLog -Component $DisplayName -Type "apt" -Operation "apt-get install $PackageName" `
                -ErrorMessage "apt-get failed" -ExitCode $exitCode -FullOutput ($output | Out-String)
            return $false
        }
    }
    catch {
        Write-ErrorMsg "Error installing $DisplayName : $_"
        Write-SetupLog -Component $DisplayName -Type "apt" -Operation "apt-get install $PackageName" `
            -ErrorMessage $_.Exception.Message -FullOutput $_.Exception.ToString()
        return $false
    }
}

# Install PowerShell module
function Install-PSModuleIfMissing {
    param(
        [string]$ModuleName,
        [string]$DisplayName = $null
    )

    if (-not $DisplayName) { $DisplayName = $ModuleName }

    Write-Step "Installing PowerShell module: $DisplayName..."

    if (Get-Module -ListAvailable -Name $ModuleName) {
        Write-Skip "$DisplayName is already installed"
        return $true
    }

    try {
        Install-Module -Name $ModuleName -Repository PSGallery -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
        Write-Success "$DisplayName installed successfully"
        return $true
    }
    catch {
        Write-ErrorMsg "Failed to install $DisplayName : $_"
        Write-SetupLog -Component $DisplayName -Type "module" -Operation "Install-Module $ModuleName" `
            -ErrorMessage $_.Exception.Message -FullOutput $_.Exception.ToString()
        return $false
    }
}

# ─── Linux-specific installers ────────────────────────────────────────────────

function Install-OhMyPoshLinux {
    Write-Step "Installing oh-my-posh..."

    if (Test-CommandExists "oh-my-posh") {
        Write-Skip "oh-my-posh is already installed"
        return $true
    }

    try {
        Write-Host "  → Downloading and running official install script..." -ForegroundColor Gray

        # Ensure ~/.local/bin exists and is on PATH for this session
        $localBin = "$HOME/.local/bin"
        if (-not (Test-Path $localBin)) {
            New-Item -ItemType Directory -Path $localBin -Force | Out-Null
        }
        if ($env:PATH -notmatch [regex]::Escape($localBin)) {
            $env:PATH = "${localBin}:$env:PATH"
        }

        $output = bash -c "curl -s https://ohmyposh.dev/install.sh | bash -s -- -d '$localBin' 2>&1"
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0 -and (Test-CommandExists "oh-my-posh")) {
            Write-Success "oh-my-posh installed successfully"
            return $true
        }
        else {
            Write-ErrorMsg "oh-my-posh installation failed (exit code: $exitCode)"
            Write-SetupLog -Component "oh-my-posh" -Type "script" `
                -Operation "curl https://ohmyposh.dev/install.sh | bash" `
                -ErrorMessage "Install script failed" -ExitCode $exitCode -FullOutput ($output | Out-String)
            return $false
        }
    }
    catch {
        Write-ErrorMsg "oh-my-posh installation exception: $_"
        Write-SetupLog -Component "oh-my-posh" -Type "script" `
            -Operation "curl https://ohmyposh.dev/install.sh | bash" `
            -ErrorMessage $_.Exception.Message -FullOutput $_.Exception.ToString()
        return $false
    }
}

function Install-ZoxideLinux {
    Write-Step "Installing zoxide..."

    if (Test-CommandExists "zoxide") {
        Write-Skip "zoxide is already installed"
        return $true
    }

    try {
        Write-Host "  → Downloading and running official install script..." -ForegroundColor Gray

        $localBin = "$HOME/.local/bin"
        if (-not (Test-Path $localBin)) {
            New-Item -ItemType Directory -Path $localBin -Force | Out-Null
        }
        if ($env:PATH -notmatch [regex]::Escape($localBin)) {
            $env:PATH = "${localBin}:$env:PATH"
        }

        $output = bash -c "curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh 2>&1"
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0 -and (Test-CommandExists "zoxide")) {
            Write-Success "zoxide installed successfully"
            return $true
        }
        else {
            Write-ErrorMsg "zoxide installation failed (exit code: $exitCode)"
            Write-SetupLog -Component "zoxide" -Type "script" `
                -Operation "curl zoxide install.sh | sh" `
                -ErrorMessage "Install script failed" -ExitCode $exitCode -FullOutput ($output | Out-String)
            return $false
        }
    }
    catch {
        Write-ErrorMsg "zoxide installation exception: $_"
        Write-SetupLog -Component "zoxide" -Type "script" `
            -Operation "curl zoxide install.sh | sh" `
            -ErrorMessage $_.Exception.Message -FullOutput $_.Exception.ToString()
        return $false
    }
}

function Install-GlowLinux {
    Write-Step "Installing glow..."

    if (Test-CommandExists "glow") {
        Write-Skip "glow is already installed"
        return $true
    }

    try {
        Write-Host "  → Adding charm.sh apt repository..." -ForegroundColor Gray

        $repoSetup = @'
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt-get update -qq
'@
        $repoOutput = bash -c $repoSetup 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-ErrorMsg "Failed to add charm.sh repository (exit code: $LASTEXITCODE)"
            Write-SetupLog -Component "glow" -Type "apt" -Operation "add charm.sh repo" `
                -ErrorMessage "Repository setup failed" -ExitCode $LASTEXITCODE -FullOutput ($repoOutput | Out-String)
            return $false
        }

        $output = bash -c "sudo apt-get install -y glow 2>&1"
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0) {
            Write-Success "glow installed successfully"
            return $true
        }
        else {
            Write-ErrorMsg "glow installation failed (exit code: $exitCode)"
            Write-SetupLog -Component "glow" -Type "apt" -Operation "apt-get install glow" `
                -ErrorMessage "apt-get failed" -ExitCode $exitCode -FullOutput ($output | Out-String)
            return $false
        }
    }
    catch {
        Write-ErrorMsg "glow installation exception: $_"
        Write-SetupLog -Component "glow" -Type "apt" -Operation "apt-get install glow" `
            -ErrorMessage $_.Exception.Message -FullOutput $_.Exception.ToString()
        return $false
    }
}

function Install-FzfLinux {
    Write-Step "Installing fzf..."

    if (Test-CommandExists "fzf") {
        Write-Skip "fzf is already installed"
        return $true
    }

    return Install-AptPackage -PackageName "fzf" -DisplayName "fzf"
}

function Install-MicrosoftEditLinux {
    Write-Step "Installing Microsoft Edit..."

    # Check specifically for our installed binary to avoid matching system 'edit'
    if (Test-Path "$HOME/.local/bin/edit") {
        Write-Skip "Microsoft Edit is already installed"
        return $true
    }

    try {
        $localBin = "$HOME/.local/bin"
        if (-not (Test-Path $localBin)) {
            New-Item -ItemType Directory -Path $localBin -Force | Out-Null
        }
        if ($env:PATH -notmatch [regex]::Escape($localBin)) {
            $env:PATH = "${localBin}:$env:PATH"
        }

        Write-Host "  → Fetching latest release info from GitHub..." -ForegroundColor Gray
        $releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/microsoft/edit/releases/latest" -ErrorAction Stop

        $archRaw = bash -c "uname -m" 2>$null
        $arch = if ($archRaw) { ($archRaw | Select-Object -First 1).ToString().Trim() } else { $null }

        $assetPattern = switch ($arch) {
            "x86_64"  { "x86_64-linux" }
            "aarch64" { "aarch64-linux" }
            "armv7l"  { "armv7-linux" }
            default   { $null }
        }

        if (-not $assetPattern) {
            Write-ErrorMsg "Unsupported architecture: $arch"
            Write-SetupLog -Component "Microsoft Edit" -Type "github-release" `
                -Operation "Detect architecture" -ErrorMessage "Unsupported architecture: $arch"
            return $false
        }

        $asset = $releaseInfo.assets | Where-Object { $_.name -match $assetPattern } | Select-Object -First 1

        if (-not $asset) {
            Write-ErrorMsg "No compatible Linux binary found in latest release"
            Write-Host "  ℹ Available assets:" -ForegroundColor Gray
            $releaseInfo.assets | ForEach-Object { Write-Host "    $($_.name)" -ForegroundColor Gray }
            Write-SetupLog -Component "Microsoft Edit" -Type "github-release" `
                -Operation "Find Linux asset for $arch" -ErrorMessage "No matching asset found" `
                -FullOutput ($releaseInfo.assets.name -join "`n")
            return $false
        }

        Write-Host "  → Downloading $($asset.name)..." -ForegroundColor Gray
        $tmpDir = "/tmp/ms-edit-$PID"
        bash -c "mkdir -p '$tmpDir'" | Out-Null

        $dlOutput = bash -c "curl -fsSL '$($asset.browser_download_url)' -o '$tmpDir/asset' 2>&1"
        if ($LASTEXITCODE -ne 0) {
            Write-ErrorMsg "Download failed (exit $LASTEXITCODE)"
            bash -c "rm -rf '$tmpDir'" | Out-Null
            Write-SetupLog -Component "Microsoft Edit" -Type "github-release" `
                -Operation "Download $($asset.name)" `
                -ErrorMessage "curl failed" -ExitCode $LASTEXITCODE -FullOutput ($dlOutput | Out-String)
            return $false
        }

        # Extract based on file type
        if ($asset.name -match '\.tar\.zst$') {
            # Ensure zstd is available for decompression
            $zstdCheck = bash -c "dpkg -s zstd 2>/dev/null | grep -q '^Status: install ok installed'" 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  → Installing zstd..." -ForegroundColor Gray
                bash -c "sudo apt-get install -y zstd 2>&1" | Out-Null
            }
            bash -c "tar -I zstd -xf '$tmpDir/asset' -C '$tmpDir'" | Out-Null
        }
        elseif ($asset.name -match '\.tar\.gz$|\.tgz$') {
            bash -c "tar -xzf '$tmpDir/asset' -C '$tmpDir'" | Out-Null
        }
        elseif ($asset.name -match '\.zip$') {
            bash -c "unzip -q '$tmpDir/asset' -d '$tmpDir'" | Out-Null
        }
        # else: raw binary already at $tmpDir/asset

        # Find the 'edit' binary in extracted contents
        $editBinRaw = bash -c "find '$tmpDir' -name 'edit' -type f 2>/dev/null | head -1" 2>$null
        $editBin = if ($editBinRaw) { ($editBinRaw | Select-Object -First 1).ToString().Trim() } else { "" }
        if (-not $editBin) { $editBin = "$tmpDir/asset" }  # fallback: raw binary

        $installOutput = bash -c "install -m755 '$editBin' '$localBin/edit' 2>&1"
        $installExit   = $LASTEXITCODE
        bash -c "rm -rf '$tmpDir'" | Out-Null

        if ($installExit -eq 0 -and (Test-Path "$localBin/edit")) {
            Write-Success "Microsoft Edit installed successfully"
            return $true
        }
        else {
            Write-ErrorMsg "Microsoft Edit binary install failed"
            Write-SetupLog -Component "Microsoft Edit" -Type "github-release" `
                -Operation "install -m755 edit to $localBin" `
                -ErrorMessage "install failed" -ExitCode $installExit -FullOutput ($installOutput | Out-String)
            return $false
        }
    }
    catch {
        Write-ErrorMsg "Microsoft Edit installation exception: $_"
        Write-SetupLog -Component "Microsoft Edit" -Type "github-release" `
            -Operation "GitHub release download" `
            -ErrorMessage $_.Exception.Message -FullOutput $_.Exception.ToString()
        return $false
    }
}

function Install-YaziLinux {
    Write-Step "Installing Yazi..."

    if (Test-CommandExists "yazi") {
        Write-Skip "Yazi is already installed"
        # Still proceed to set up config and plugins
    }
    else {
        try {
            Write-Host "  → Fetching latest Yazi release from GitHub..." -ForegroundColor Gray

            # Detect architecture
            $archRaw = bash -c "uname -m" 2>&1
            $arch = if ($archRaw) { ($archRaw | Select-Object -First 1).ToString().Trim() } else { $null }
            $yaziArch = switch ($arch) {
                "x86_64"  { "x86_64-unknown-linux-musl" }
                "aarch64" { "aarch64-unknown-linux-musl" }
                "armv7l"  { "armv7-unknown-linux-musleabihf" }
                default {
                    Write-ErrorMsg "Unsupported architecture: $arch"
                    return $false
                }
            }

            $localBin = "$HOME/.local/bin"
            if (-not (Test-Path $localBin)) {
                New-Item -ItemType Directory -Path $localBin -Force | Out-Null
            }
            if ($env:PATH -notmatch [regex]::Escape($localBin)) {
                $env:PATH = "${localBin}:$env:PATH"
            }

            # Ensure unzip is available (not always present in minimal Ubuntu installs)
            $unzipCheck = bash -c "dpkg -s unzip 2>/dev/null | grep -q '^Status: install ok installed'" 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  → Installing unzip (required for Yazi download)..." -ForegroundColor Gray
                bash -c "sudo apt-get install -y unzip 2>&1" | Out-Null
            }

            $downloadScript = (@'
set -e
TMP=$(mktemp -d)
cd "$TMP"
curl -fsSL "https://github.com/sxyazi/yazi/releases/latest/download/yazi-YAZI_ARCH.zip" -o yazi.zip
unzip -q yazi.zip
install -m755 "yazi-YAZI_ARCH/yazi" "LOCAL_BIN/yazi"
install -m755 "yazi-YAZI_ARCH/ya" "LOCAL_BIN/ya"
rm -rf "$TMP"
'@) -replace 'YAZI_ARCH', $yaziArch -replace 'LOCAL_BIN', $localBin

            # Write with LF line endings and no BOM — required for bash on Linux
            $tmpScript = "/tmp/yazi-install-$PID.sh"
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            try {
                [System.IO.File]::WriteAllText($tmpScript, ($downloadScript -replace "`r`n", "`n"), $utf8NoBom)
                $output = bash $tmpScript 2>&1
                $exitCode = $LASTEXITCODE
            }
            finally {
                Remove-Item $tmpScript -Force -ErrorAction SilentlyContinue
            }

            if ($exitCode -ne 0 -or -not (Test-CommandExists "yazi")) {
                Write-ErrorMsg "Yazi installation failed (exit code: $exitCode)"
                Write-SetupLog -Component "Yazi" -Type "github-release" `
                    -Operation "Download yazi-$yaziArch.zip" `
                    -ErrorMessage "Binary download/install failed" -ExitCode $exitCode -FullOutput ($output | Out-String)
                return $false
            }

            Write-Success "Yazi binary installed successfully"
        }
        catch {
            Write-ErrorMsg "Yazi installation exception: $_"
            Write-SetupLog -Component "Yazi" -Type "github-release" -Operation "Install Yazi binary" `
                -ErrorMessage $_.Exception.Message -FullOutput $_.Exception.ToString()
            return $false
        }
    }

    # Install optional dependencies via apt
    Write-Host "  → Installing optional dependencies..." -ForegroundColor Gray

    $aptDeps = @(
        @{Package = "ffmpeg";         Display = "FFmpeg";       Description = "video thumbnails" }
        @{Package = "p7zip-full";     Display = "7-Zip";        Description = "archive previews" }
        @{Package = "jq";             Display = "jq";           Description = "JSON previews" }
        @{Package = "poppler-utils";  Display = "Poppler";      Description = "PDF previews" }
        @{Package = "fd-find";        Display = "fd";           Description = "file searching" }
        @{Package = "ripgrep";        Display = "ripgrep";      Description = "content searching" }
        @{Package = "imagemagick";    Display = "ImageMagick";  Description = "image conversions" }
    )

    foreach ($dep in $aptDeps) {
        $check = bash -c "dpkg -s '$($dep.Package)' 2>/dev/null | grep -q '^Status: install ok installed'" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    ✓ $($dep.Display) already installed" -ForegroundColor Green
        }
        else {
            Write-Host "    → Installing $($dep.Display) (for $($dep.Description))..." -ForegroundColor DarkGray
            $out = bash -c "sudo apt-get install -y '$($dep.Package)' 2>&1"
            if ($LASTEXITCODE -eq 0) {
                Write-Host "    ✓ $($dep.Display) installed" -ForegroundColor Green

                # fd-find installs as fdfind; create a fd symlink
                if ($dep.Package -eq "fd-find") {
                    bash -c "command -v fdfind >/dev/null && ln -sf \$(which fdfind) ~/.local/bin/fd 2>/dev/null || true" 2>&1 | Out-Null
                }
            }
            else {
                Write-Host "    ⚠ $($dep.Display) failed (optional, continuing)" -ForegroundColor Yellow
            }
        }
    }

    # Setup Yazi configuration from git repo
    Write-Host "  → Setting up Yazi configuration..." -ForegroundColor Gray
    $yaziConfigDest = "$HOME/.config/yazi"

    try {
        if (-not (Test-Path $yaziConfigDest)) {
            Write-Host "  → Cloning yazi_config repository (timeout: 30s)..." -ForegroundColor Gray
            $gitJob = Start-Job -ScriptBlock {
                param($dest)
                git clone "https://github.com/Tsabo/yazi_config.git" $dest 2>&1 | Out-Null
                return $LASTEXITCODE
            } -ArgumentList $yaziConfigDest

            $gitCompleted = Wait-Job -Job $gitJob -Timeout 30
            if ($gitCompleted) {
                $gitOutput = Receive-Job -Job $gitJob
                Remove-Job -Job $gitJob
                $gitExitCode = $gitOutput | Select-Object -Last 1

                if ($gitExitCode -eq 0) {
                    Write-Host "  ✓ Yazi configuration cloned successfully" -ForegroundColor Green
                }
                else {
                    Write-Host "  ⚠ Git clone failed, skipping config setup" -ForegroundColor Yellow
                }
            }
            else {
                Stop-Job -Job $gitJob
                Remove-Job -Job $gitJob
                Write-Host "  ⚠ Git clone timed out, skipping config setup" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "  ℹ Config directory already exists" -ForegroundColor Cyan

            $isGitRepo = Test-Path (Join-Path $yaziConfigDest ".git")
            if ($isGitRepo) {
                Push-Location $yaziConfigDest
                try {
                    $gitStatus = git status --porcelain 2>$null
                    if ($gitStatus -and $gitStatus.Trim()) {
                        Write-Host "  ⚠ Local modifications detected - skipping update to preserve your changes" -ForegroundColor Yellow
                        Write-Host "    To update manually: cd '$yaziConfigDest' && git stash && git pull && git stash pop" -ForegroundColor DarkGray
                    }
                    else {
                        $pullOutput = git pull origin main 2>&1
                        if ($LASTEXITCODE -eq 0) {
                            if ($pullOutput -match "Already up to date") {
                                Write-Host "  ✓ Configuration already up to date" -ForegroundColor Green
                            }
                            else {
                                Write-Host "  ✓ Configuration updated successfully" -ForegroundColor Green
                            }
                        }
                    }
                }
                finally {
                    Pop-Location
                }
            }
        }
    }
    catch {
        Write-Host "  ⚠ Config setup failed: $_" -ForegroundColor Yellow
    }

    # Install Yazi plugins
    if (Test-CommandExists "ya") {
        Write-Host "  → Installing Yazi plugins..." -ForegroundColor Gray

        $yaziPlugins = @(
            @{Package = "yazi-rs/plugins:git";    Name = "git" }
            @{Package = "Tsabo/githead";           Name = "githead" }
            @{Package = "gosxrgxx/flexoki-light";  Name = "flexoki-light" }
            @{Package = "956MB/vscode-dark-plus";  Name = "vscode-dark-plus" }
        )

        foreach ($plugin in $yaziPlugins) {
            $out = ya pkg add $plugin.Package 2>&1
            $outStr = ($out | Out-String).Trim()
            if ($LASTEXITCODE -eq 0 -or $outStr -match "already|installed|updated|success|exists") {
                Write-Host "    ✓ $($plugin.Name) plugin installed" -ForegroundColor Green
            }
            else {
                Write-Host "    ⚠ $($plugin.Name) plugin failed (optional, continuing)" -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Host "  ⚠ Yazi package manager (ya) not found - skipping plugins" -ForegroundColor Yellow
        Write-Host "    Restart your terminal and re-run to install plugins" -ForegroundColor DarkGray
    }

    return $true
}

# Deploy PowerShell profile (same structure as macOS)
function Deploy-PowerShellProfileLinux {
    Write-Step "Deploying PowerShell profile..."

    $repoRoot = Split-Path -Parent $PSScriptRoot
    $profilePath = $PROFILE
    $profileDir = Split-Path -Parent $profilePath
    $psSourceDir = Join-Path $repoRoot "PowerShell"

    $deployments = @(
        @{Source = "Microsoft.PowerShell_profile.ps1"; Dest = $profilePath;                              Name = "PowerShell profile" }
        @{Source = "powershell.config.json";            Dest = (Join-Path $profileDir "powershell.config.json"); Name = "PowerShell config" }
        @{Source = "IncludedModules";                   Dest = (Join-Path $profileDir "IncludedModules"); Name = "IncludedModules"; IsDirectory = $true }
        @{Source = "IncludedScripts";                   Dest = (Join-Path $profileDir "IncludedScripts"); Name = "IncludedScripts"; IsDirectory = $true }
    )

    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    foreach ($deployment in $deployments) {
        $sourcePath = Join-Path $psSourceDir $deployment.Source
        if (Test-Path $sourcePath) {
            if ($deployment.IsDirectory -and (Test-Path $deployment.Dest)) {
                Remove-Item $deployment.Dest -Recurse -Force
            }
            Copy-Item $sourcePath -Destination $deployment.Dest -Recurse:($null -ne $deployment.IsDirectory) -Force
            Write-Host "  ✓ Deployed $($deployment.Name)" -ForegroundColor Green
        }
    }

    # Create custom directories
    $customModulesDir = Join-Path $profileDir "CustomModules"
    $customScriptsDir = Join-Path $profileDir "CustomScripts"

    if (-not (Test-Path $customModulesDir)) { New-Item -ItemType Directory -Path $customModulesDir -Force | Out-Null }
    if (-not (Test-Path $customScriptsDir)) { New-Item -ItemType Directory -Path $customScriptsDir -Force | Out-Null }

    # Copy READMEs for custom directories
    foreach ($pair in @(@("CustomModules", $customModulesDir), @("CustomScripts", $customScriptsDir))) {
        $readme = Join-Path $psSourceDir "$($pair[0])\README.md"
        if (Test-Path $readme) {
            Copy-Item $readme -Destination (Join-Path $pair[1] "README.md") -Force
        }
    }

    # Copy CustomProfile.ps1 template if it doesn't exist
    $customProfileTemplate = Join-Path $psSourceDir "CustomProfile.ps1.template"
    $customProfile = Join-Path $profileDir "CustomProfile.ps1"

    if ((Test-Path $customProfileTemplate) -and (-not (Test-Path $customProfile))) {
        Copy-Item $customProfileTemplate -Destination $customProfile -Force
        Write-Host "  ✓ Created CustomProfile.ps1" -ForegroundColor Green
    }

    Write-Success "PowerShell profile deployed successfully"
    return $true
}

# Deploy oh-my-posh themes
function Deploy-OhMyPoshThemeLinux {
    Write-Step "Deploying oh-my-posh themes..."

    $repoRoot = Split-Path -Parent $PSScriptRoot
    $ompConfigSource = Join-Path $repoRoot "Config/oh-my-posh"
    $ompConfigDest = "$HOME/.config/powershell/Posh"

    if (Test-Path $ompConfigSource) {
        if (-not (Test-Path $ompConfigDest)) {
            New-Item -ItemType Directory -Path $ompConfigDest -Force | Out-Null
        }
        Copy-Item "$ompConfigSource/*.json" -Destination $ompConfigDest -Force
        Write-Success "oh-my-posh themes deployed to $ompConfigDest"
        return $true
    }

    Write-Skip "oh-my-posh theme source not found"
    return $true
}

# ─── Main setup orchestrator ──────────────────────────────────────────────────

function Start-EnvironmentSetup {
    if ($ShowDetails) {
        Show-SetupDetails
        exit 0
    }

    if ($ClearLogs) {
        if (Test-Path $logFile) {
            Remove-Item $logFile -Force
            Write-Host "✓ Setup failure logs cleared successfully" -ForegroundColor Green
        }
        else {
            Write-Host "No setup failure logs found to clear" -ForegroundColor Yellow
        }
        exit 0
    }

    # Check platform
    if (-not $IsLinux) {
        Write-Host "`n❌ This script is for Linux / WSL only. Use Setup.ps1 for Windows or Setup-macOS.ps1 for macOS." -ForegroundColor Red
        exit 1
    }

    # Check for apt / Ubuntu
    if (-not (Test-CommandExists "apt-get")) {
        Write-Host "`n❌ apt-get not found. This script requires an Ubuntu/Debian-based distribution." -ForegroundColor Red
        exit 1
    }

    # Detect WSL
    $kernelVersion = Get-Content /proc/version -ErrorAction SilentlyContinue
    $isWSL = $kernelVersion -match "microsoft|WSL"

    Write-Host @"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║     PowerShell Environment Setup for Linux / WSL           ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

    if ($isWSL) {
        Write-Host "  ℹ Running inside WSL — fonts are managed on the Windows side." -ForegroundColor Cyan
        Write-Host "    If you haven't already, run .\Scripts\Setup.ps1 on Windows first" -ForegroundColor DarkGray
        Write-Host "    to install the CaskaydiaCove Nerd Font in Windows Terminal." -ForegroundColor DarkGray
    }

    $results = @{
        Success = @()
        Failed  = @()
        Skipped = @()
    }

    # 1. Update apt package index
    Write-Step "Updating apt package index..."
    $aptUpdate = bash -c "sudo apt-get update -qq 2>&1"
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Package index updated"
    }
    else {
        Write-Host "  ⚠ apt-get update had warnings (continuing)" -ForegroundColor Yellow
    }

    # 2. Install core tools
    # fzf is available in apt
    if (Install-FzfLinux) { $results.Success += "fzf" } else { $results.Failed += "fzf" }

    # oh-my-posh via official install script
    if (Install-OhMyPoshLinux) { $results.Success += "oh-my-posh" } else { $results.Failed += "oh-my-posh" }

    # zoxide via official install script
    if (Install-ZoxideLinux) { $results.Success += "zoxide" } else { $results.Failed += "zoxide" }

    # glow via charm.sh
    if (Install-GlowLinux) { $results.Success += "glow" } else { $results.Failed += "glow" }

    # Microsoft Edit via snap
    if (Install-MicrosoftEditLinux) { $results.Success += "Microsoft Edit" } else { $results.Failed += "Microsoft Edit" }

    # Note: gsudo / Scoop / Windows Terminal are not applicable
    $results.Skipped += "gsudo (use sudo)"
    $results.Skipped += "Scoop (Windows only)"

    # 3. Font note — fonts live on the Windows side
    if ($isWSL) {
        $results.Skipped += "CascadiaCode Font (managed on Windows side)"
    }

    # 4. Install PowerShell modules
    $modules = @(
        @{Name = "PSFzf";          Display = "PSFzf" }
        @{Name = "Terminal-Icons"; Display = "Terminal-Icons" }
        @{Name = "F7History";      Display = "F7History" }
        @{Name = "posh-git";       Display = "posh-git" }
    )

    if (-not $SkipOptional) {
        $modules += @{Name = "PowerColorLS"; Display = "PowerColorLS" }
    }

    foreach ($module in $modules) {
        if (Install-PSModuleIfMissing -ModuleName $module.Name -DisplayName $module.Display) {
            $results.Success += $module.Display
        }
        else {
            $results.Failed += $module.Display
        }
    }

    # 5. Install Yazi with configuration and dependencies
    if (Install-YaziLinux) {
        $results.Success += "Yazi"
    }
    else {
        $results.Failed += "Yazi"
    }

    # 6. Deploy oh-my-posh themes
    if (Deploy-OhMyPoshThemeLinux) {
        $results.Success += "oh-my-posh Themes"
    }
    else {
        $results.Failed += "oh-my-posh Themes"
    }

    # 7. Deploy PowerShell profile
    if (Deploy-PowerShellProfileLinux) {
        $results.Success += "PowerShell Profile"
    }
    else {
        $results.Failed += "PowerShell Profile"
    }

    # ─── Summary ───────────────────────────────────────────────────────────────
    Write-Host @"

╔════════════════════════════════════════════════════════════╗
║                    SETUP SUMMARY                            ║
╚════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

    if ($results.Success.Count -gt 0) {
        Write-Host "`n✅ Successfully Installed/Configured:" -ForegroundColor Green
        $results.Success | ForEach-Object { Write-Host "   • $_" -ForegroundColor Green }
    }

    if ($results.Skipped.Count -gt 0) {
        Write-Host "`n⊘ Skipped (not applicable on Linux):" -ForegroundColor Yellow
        $results.Skipped | ForEach-Object { Write-Host "   • $_" -ForegroundColor Yellow }
    }

    if ($results.Failed.Count -gt 0) {
        Write-Host "`n❌ Failed:" -ForegroundColor Red
        $results.Failed | ForEach-Object { Write-Host "   • $_" -ForegroundColor Red }
        Write-Host "`n  Run with -ShowDetails for diagnostic information." -ForegroundColor Gray
    }

    Write-Host "`n📋 Next Steps:" -ForegroundColor Cyan

    if ($isWSL) {
        Write-Host "  1. Ensure CaskaydiaCove Nerd Font is set in Windows Terminal" -ForegroundColor White
        Write-Host "     Settings → Profiles → Defaults → Appearance → Font face" -ForegroundColor Gray
    }

    Write-Host "  2. Reload your profile:" -ForegroundColor White
    Write-Host "       . `$PROFILE" -ForegroundColor DarkCyan
    Write-Host "  3. Validate the installation:" -ForegroundColor White
    Write-Host "       ./Scripts/Test-Linux.ps1" -ForegroundColor DarkCyan
    Write-Host "  4. Keep everything updated:" -ForegroundColor White
    Write-Host "       ./Scripts/Update-Linux.ps1" -ForegroundColor DarkCyan
    Write-Host ""

    if ($results.Failed.Count -eq 0) {
        Write-Host "🎉 Setup complete! Restart your terminal (or reload your profile) to enjoy your new environment." -ForegroundColor Green
    }
    else {
        Write-Host "⚠️  Setup completed with some failures. Run -ShowDetails to investigate." -ForegroundColor Yellow
    }
}

# Run
Start-EnvironmentSetup
