<#
.SYNOPSIS
    Automated PowerShell environment setup script for macOS
.DESCRIPTION
    Sets up a complete PowerShell environment on macOS with all required tools and modules
    using Homebrew as the package manager.
.PARAMETER SkipOptional
    Skip installation of optional components
.PARAMETER ShowDetails
    Shows detailed failure information from previous setup runs
.PARAMETER ClearLogs
    Clears stored failure logs
.EXAMPLE
    ./Setup-macOS.ps1
.EXAMPLE
    ./Setup-macOS.ps1 -SkipOptional
.EXAMPLE
    ./Setup-macOS.ps1 -ShowDetails
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
$logFile = Join-Path $logDir "setup-macos-details.json"

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
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Component = $Component
        Type = $Type
        Operation = $Operation
        ErrorMessage = $ErrorMessage
        FullOutput = $FullOutput
        ExitCode = $ExitCode
    }

    # Read existing log or create new
    $logData = @()
    if (Test-Path $logFile) {
        try {
            $existingData = Get-Content $logFile -Raw | ConvertFrom-Json
            if ($existingData) {
                if ($existingData -is [Array]) {
                    $logData = [System.Collections.ArrayList]@($existingData)
                }
                else {
                    $logData = [System.Collections.ArrayList]@($existingData)
                }
            }
        }
        catch {
            $logData = [System.Collections.ArrayList]@()
        }
    }
    else {
        $logData = [System.Collections.ArrayList]@()
    }

    # Add new entry and keep only last 50 entries
    $logData.Add($logEntry) | Out-Null
    if ($logData.Count -gt 50) {
        $logData = [System.Collections.ArrayList]@($logData[-50..-1])
    }

    # Save log
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
                $outputLines = $latestFailure.FullOutput -split "`n" | Select-Object -First 5
                foreach ($line in $outputLines) {
                    if ($line.Trim()) {
                        Write-Host "     $($line.Trim())" -ForegroundColor DarkGray
                    }
                }
            }

            # Show failure frequency
            if ($failures.Count -gt 1) {
                Write-Host "   Failure frequency: $($failures.Count) times in last 7 days" -ForegroundColor Yellow
            }
        }
    }
    catch {
        Write-Host "Error reading setup failure details: $_" -ForegroundColor Red
    }
}

# Install Homebrew package
function Install-BrewPackage {
    param(
        [string]$PackageName,
        [string]$Name,
        [string]$Tap = $null
    )

    Write-Step "Installing $Name via Homebrew..."

    try {
        # Add tap if specified
        if ($Tap) {
            Write-Host "  → Adding tap: $Tap..." -ForegroundColor Gray
            brew tap $Tap 2>&1 | Out-Null
        }

        # Check if already installed
        $installed = brew list $PackageName 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Skip "$Name is already installed"
            return $true
        }

        Write-Host "  → Installing via Homebrew..." -ForegroundColor Gray
        $output = brew install $PackageName 2>&1
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0) {
            Write-Success "$Name installed successfully"
            return $true
        }
        else {
            Write-ErrorMsg "Failed to install $Name (exit code: $exitCode)"
            Write-SetupLog -Component $Name -Type "homebrew" -Operation "brew install $PackageName" -ErrorMessage "brew install failed" -ExitCode $exitCode -FullOutput ($output | Out-String)
            return $false
        }
    }
    catch {
        Write-ErrorMsg "Error installing $Name : $_"
        Write-SetupLog -Component $Name -Type "homebrew" -Operation "brew install $PackageName" -ErrorMessage $_.Exception.Message -FullOutput $_.Exception.ToString()
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
        Write-SetupLog -Component $DisplayName -Type "module" -Operation "Install-Module $ModuleName" -ErrorMessage $_.Exception.Message -FullOutput $_.Exception.ToString()
        return $false
    }
}

# Install oh-my-posh on macOS
function Install-OhMyPoshMacOS {
    Write-Step "Installing oh-my-posh..."

    if (Test-CommandExists "oh-my-posh") {
        Write-Skip "oh-my-posh is already installed"
        return $true
    }

    return Install-BrewPackage -PackageName "oh-my-posh" -Name "oh-my-posh"
}

# Install CascadiaCode font on macOS
function Install-CascadiaFontMacOS {
    Write-Step "Installing CascadiaCode Nerd Font..."

    # Check if font is already installed
    $fontDir = "$HOME/Library/Fonts"
    $cascadiaFiles = Get-ChildItem -Path $fontDir -Filter "*Caskaydia*" -ErrorAction SilentlyContinue

    if ($cascadiaFiles.Count -gt 0) {
        Write-Skip "CascadiaCode font already installed"
        return $true
    }

    try {
        Write-Host "  → Installing font via Homebrew cask..." -ForegroundColor Gray

        # Tap the cask-fonts repository if not already tapped
        brew tap homebrew/cask-fonts 2>&1 | Out-Null

        # Install the font
        $output = brew install --cask font-caskaydia-cove-nerd-font 2>&1
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0) {
            Write-Success "CascadiaCode font installed successfully"
            return $true
        }
        else {
            Write-ErrorMsg "Font installation failed"
            Write-SetupLog -Component "CascadiaCode Font" -Type "homebrew-cask" -Operation "brew install --cask font-caskaydia-cove-nerd-font" -ErrorMessage "cask install failed" -ExitCode $exitCode -FullOutput ($output | Out-String)
            return $false
        }
    }
    catch {
        Write-ErrorMsg "Font installation exception: $_"
        Write-SetupLog -Component "CascadiaCode Font" -Type "homebrew-cask" -Operation "brew install --cask" -ErrorMessage $_.Exception.Message -FullOutput $_.Exception.ToString()
        return $false
    }
}

# Install Yazi on macOS
function Install-YaziMacOS {
    Write-Step "Installing Yazi..."

    # Install Yazi via Homebrew
    $success = Install-BrewPackage -PackageName "yazi" -Name "Yazi"
    if (-not $success) {
        return $false
    }

    # Install optional dependencies
    Write-Host "  → Installing optional dependencies..." -ForegroundColor Gray

    $optionalDeps = @("ffmpeg", "7zip", "jq", "poppler", "fd", "ripgrep", "imagemagick")

    foreach ($dep in $optionalDeps) {
        Write-Host "    → Installing $dep..." -ForegroundColor DarkGray
        brew install $dep 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "      ✓ $dep installed" -ForegroundColor Green
        }
    }

    # Setup Yazi configuration
    Write-Host "  → Setting up Yazi configuration..." -ForegroundColor Gray
    $yaziConfigDest = "$HOME/.config/yazi"

    try {
        if (-not (Test-Path $yaziConfigDest)) {
            Write-Host "  → Cloning yazi_config repository..." -ForegroundColor Gray
            git clone "https://github.com/Tsabo/yazi_config.git" $yaziConfigDest 2>&1 | Out-Null

            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Yazi configuration cloned successfully" -ForegroundColor Green
            }
        }
        else {
            Write-Host "  ℹ Config directory already exists" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "  ⚠ Config setup failed: $_" -ForegroundColor Yellow
    }

    # Install Yazi plugins
    if (Test-CommandExists "ya") {
        Write-Host "  → Installing Yazi plugins..." -ForegroundColor Gray

        $yaziPlugins = @(
            @{Package = "yazi-rs/plugins:git"; Name = "git" }
            @{Package = "Tsabo/githead"; Name = "githead" }
            @{Package = "gosxrgxx/flexoki-light"; Name = "flexoki-light" }
            @{Package = "956MB/vscode-dark-plus"; Name = "vscode-dark-plus" }
        )

        foreach ($plugin in $yaziPlugins) {
            ya pkg add $plugin.Package 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "    ✓ $($plugin.Name) plugin installed" -ForegroundColor Green
            }
        }
    }

    return $true
}

# Deploy PowerShell profile for macOS
function Deploy-PowerShellProfileMacOS {
    Write-Step "Deploying PowerShell profile..."

    $scriptRoot = Split-Path -Parent $PSScriptRoot
    $profilePath = $PROFILE
    $profileDir = Split-Path -Parent $profilePath
    $psSourceDir = Join-Path $scriptRoot "PowerShell"

    $deployments = @(
        @{Source = "Microsoft.PowerShell_profile.ps1"; Dest = $profilePath; Name = "PowerShell profile" }
        @{Source = "powershell.config.json"; Dest = (Join-Path $profileDir "powershell.config.json"); Name = "PowerShell config" }
        @{Source = "IncludedModules"; Dest = (Join-Path $profileDir "IncludedModules"); Name = "IncludedModules"; IsDirectory = $true }
        @{Source = "IncludedScripts"; Dest = (Join-Path $profileDir "IncludedScripts"); Name = "IncludedScripts"; IsDirectory = $true }
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
            Copy-Item $sourcePath -Destination $deployment.Dest -Recurse:$deployment.IsDirectory -Force
            Write-Host "  ✓ Deployed $($deployment.Name)" -ForegroundColor Green
        }
    }

    # Create custom directories
    $customModulesDir = Join-Path $profileDir "CustomModules"
    $customScriptsDir = Join-Path $profileDir "CustomScripts"

    if (-not (Test-Path $customModulesDir)) {
        New-Item -ItemType Directory -Path $customModulesDir -Force | Out-Null
    }
    if (-not (Test-Path $customScriptsDir)) {
        New-Item -ItemType Directory -Path $customScriptsDir -Force | Out-Null
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
function Deploy-OhMyPoshThemeMacOS {
    Write-Step "Deploying oh-my-posh themes..."

    $scriptRoot = Split-Path -Parent $PSScriptRoot
    $ompConfigSource = Join-Path $scriptRoot "Config/oh-my-posh"
    $ompConfigDest = "$HOME/.config/powershell/Posh"

    if (Test-Path $ompConfigSource) {
        if (-not (Test-Path $ompConfigDest)) {
            New-Item -ItemType Directory -Path $ompConfigDest -Force | Out-Null
        }
        Copy-Item "$ompConfigSource/*.json" -Destination $ompConfigDest -Force
        Write-Success "oh-my-posh themes deployed"
        return $true
    }

    Write-Skip "oh-my-posh theme source not found"
    return $true
}

# Main setup orchestrator
function Start-EnvironmentSetup {
    # Handle special parameters first
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

    Write-Host @"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║     PowerShell Environment Setup for macOS                 ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

    # Check if running on macOS
    if (-not $IsMacOS) {
        Write-Host "`n❌ This script is for macOS only. Use Setup.ps1 for Windows." -ForegroundColor Red
        exit 1
    }

    $results = @{
        Success = @()
        Failed = @()
        Skipped = @()
    }

    # 1. Ensure Homebrew is installed
    Write-Step "Checking Homebrew installation..."
    if (-not (Test-CommandExists "brew")) {
        Write-Host "  → Installing Homebrew..." -ForegroundColor Gray
        if (Install-Homebrew) {
            $results.Success += "Homebrew"
        }
        else {
            $results.Failed += "Homebrew"
            Write-Host "`n❌ Homebrew installation failed. Cannot continue." -ForegroundColor Red
            return
        }
    }
    else {
        Write-Skip "Homebrew is already installed"
    }

    # 2. Install core tools via Homebrew
    $coreTools = @(
        @{Package = "oh-my-posh"; Name = "oh-my-posh"; Installer = { Install-OhMyPoshMacOS } }
        @{Package = "fzf"; Name = "fzf"; Installer = { Install-BrewPackage -PackageName "fzf" -Name "fzf" } }
        @{Package = "zoxide"; Name = "zoxide"; Installer = { Install-BrewPackage -PackageName "zoxide" -Name "zoxide" } }
        @{Package = "microsoft/edit/edit"; Name = "Microsoft Edit"; Tap = "microsoft/edit"; Installer = { Install-BrewPackage -PackageName "microsoft/edit/edit" -Name "Microsoft Edit" -Tap "microsoft/edit" } }
        @{Package = "glow"; Name = "glow"; Installer = { Install-BrewPackage -PackageName "glow" -Name "glow" } }
    )

    foreach ($tool in $coreTools) {
        if (& $tool.Installer) {
            $results.Success += $tool.Name
        }
        else {
            $results.Failed += $tool.Name
        }
    }

    # 3. Install CascadiaCode font
    if (Install-CascadiaFontMacOS) {
        $results.Success += "CascadiaCode Font"
    }
    else {
        $results.Failed += "CascadiaCode Font"
    }

    # 4. Install PowerShell modules
    $modules = @(
        @{Name = "PSFzf"; Display = "PSFzf" }
        @{Name = "Terminal-Icons"; Display = "Terminal-Icons" }
        @{Name = "F7History"; Display = "F7History" }
        @{Name = "posh-git"; Display = "posh-git" }
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

    # 5. Install Yazi with configuration
    if (Install-YaziMacOS) {
        $results.Success += "Yazi"
    }
    else {
        $results.Failed += "Yazi"
    }

    # 6. Deploy oh-my-posh themes
    if (Deploy-OhMyPoshThemeMacOS) {
        $results.Success += "oh-my-posh themes"
    }

    # 7. Deploy PowerShell profile
    if (Deploy-PowerShellProfileMacOS) {
        $results.Success += "PowerShell Profile"
    }
    else {
        $results.Failed += "PowerShell Profile"
    }

    # Show summary
    Write-Host "`n`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                    SETUP SUMMARY                           ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

    if ($results.Success.Count -gt 0) {
        Write-Host "`n✅ Successfully installed ($($results.Success.Count)):" -ForegroundColor Green
        $results.Success | ForEach-Object { Write-Host "   • $_" -ForegroundColor Green }
    }

    if ($results.Skipped.Count -gt 0) {
        Write-Host "`n⊘ Skipped ($($results.Skipped.Count)):" -ForegroundColor Yellow
        $results.Skipped | ForEach-Object { Write-Host "   • $_" -ForegroundColor Yellow }
    }

    if ($results.Failed.Count -gt 0) {
        Write-Host "`n❌ Failed ($($results.Failed.Count)):" -ForegroundColor Red
        $results.Failed | ForEach-Object { Write-Host "   • $_" -ForegroundColor Red }
        Write-Host "`n💡 For detailed failure information, run: " -NoNewline -ForegroundColor Cyan
        Write-Host "./Setup-macOS.ps1 -ShowDetails" -ForegroundColor White
    }

    # Next steps
    Write-Host "`n`n📝 NEXT STEPS:" -ForegroundColor Cyan
    Write-Host "   1. Reload your profile: " -NoNewline
    Write-Host ". `$PROFILE" -ForegroundColor Yellow
    Write-Host "   2. Set your terminal font to " -NoNewline
    Write-Host "CaskaydiaCove Nerd Font Mono" -ForegroundColor Yellow
    Write-Host "   3. Customize using " -NoNewline
    Write-Host "CustomProfile.ps1" -ForegroundColor Yellow
    Write-Host "   4. Add custom modules to " -NoNewline
    Write-Host "CustomModules/" -ForegroundColor Yellow

    if ($results.Failed.Count -eq 0) {
        Write-Host "`n🎉 Setup completed successfully!" -ForegroundColor Green

        # Offer to reload profile
        if ($results.Success -contains "PowerShell Profile") {
            Write-Host "`n💡 Would you like to reload your profile now? (Y/n): " -NoNewline -ForegroundColor Cyan
            $response = Read-Host

            if ($response -eq "" -or $response -match "^[Yy]") {
                Write-Host "`n🔄 Reloading profile..." -ForegroundColor Cyan
                try {
                    . $PROFILE
                    Write-Host "✅ Profile reloaded successfully!" -ForegroundColor Green
                }
                catch {
                    Write-Host "⚠️  Could not reload profile: $_" -ForegroundColor Yellow
                }
            }
        }
    }
}

# Run the setup
try {
    Start-EnvironmentSetup
}
catch {
    Write-Host "`n❌ Setup failed with error: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}
