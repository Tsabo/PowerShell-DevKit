<#
.SYNOPSIS
    Automated PowerShell environment setup script
.DESCRIPTION
    Sets up a complete PowerShell environment with all required tools and modules
    based on your OneNote setup guide.
.PARAMETER SkipOptional
    Skip installation of optional components (gsudo, PowerColorLS)
.PARAMETER FontName
    Font to install for oh-my-posh (default: CascadiaCode)
.PARAMETER ShowDetails
    Shows detailed failure information from previous setup runs
.PARAMETER ClearLogs
    Clears stored failure logs
.EXAMPLE
    .\Setup.ps1
.EXAMPLE
    .\Setup.ps1 -SkipOptional
.EXAMPLE
    .\Setup.ps1 -ShowDetails
    Shows detailed failure information from the last setup run
.EXAMPLE
    .\Setup.ps1 -ClearLogs
    Clears stored failure logs
#>
[CmdletBinding()]
param(
    [switch]$SkipOptional,
    [string]$FontName = "CascadiaCode",
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
$logFile = Join-Path $logDir "setup-details.json"

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

# Check if running as admin (needed for some operations)
function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Log detailed failure information
function Write-SetupLog {
    param(
        [string]$Component,
        [string]$Type,
        [string]$Operation,
        [string]$ErrorMessage,
        [string]$FullOutput = ""
    )

    $logEntry = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Component = $Component
        Type = $Type
        Operation = $Operation
        ErrorMessage = $ErrorMessage
        FullOutput = $FullOutput
        ExitCode = $LASTEXITCODE
        IsAdmin = Test-IsAdmin
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
            Write-Host "   Admin Rights: $($latestFailure.IsAdmin)" -ForegroundColor Gray

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
                if (($latestFailure.FullOutput -split "`n").Count -gt 5) {
                    Write-Host "     ... (truncated)" -ForegroundColor DarkGray
                }
            }

            # Show failure frequency
            if ($failures.Count -gt 1) {
                Write-Host "   Failure frequency: $($failures.Count) times in last 7 days" -ForegroundColor Yellow
            }

            # Setup-specific suggestions
            $suggestion = Get-SetupSuggestion -Component $component -ErrorMessage $latestFailure.ErrorMessage -IsAdmin $latestFailure.IsAdmin
            if ($suggestion) {
                Write-Host "   💡 Suggestion: $suggestion" -ForegroundColor Cyan
            }
        }

    }
    catch {
        Write-Host "Error reading setup failure details: $_" -ForegroundColor Red
    }
}

# Provide setup-specific suggestions
function Get-SetupSuggestion {
    param([string]$Component, [string]$ErrorMessage, [bool]$IsAdmin)

    # Admin-specific suggestions
    if (-not $IsAdmin) {
        if ($Component -match "font|CascadiaCode" -or $ErrorMessage -match "access.*denied") {
            return "Run PowerShell as Administrator for font installations"
        }
        if ($Component -eq "gsudo") {
            return "gsudo installation requires Administrator privileges"
        }
    }

    $suggestions = @{
        "gsudo" = "Install manually: winget install gerardog.gsudo --scope user"
        "CascadiaCode Font" = "Install manually via Windows Settings > Fonts, or download from GitHub"
        "oh-my-posh" = "Ensure PATH is updated. Run: refreshenv or restart PowerShell"
        "fzf" = "Install manually: winget install junegunn.fzf"
        "PSFzf" = "Update PowerShellGet: Install-Module PowerShellGet -Force -Scope CurrentUser"
        "Terminal-Icons" = "Check PowerShell Gallery access: Test-NetConnection powershellgallery.com -Port 443"
        "posh-git" = "Ensure Git is installed: winget install Git.Git"
        "Scoop" = "Install manually: Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression"
        "resvg" = "Install Scoop first, then run: scoop install resvg"
        "Yazi" = "Install manually: winget install sxyazi.yazi"
        "Microsoft Edit" = "Install manually: winget install Microsoft.Edit"
        "PowerShell Profile" = "Check profile path permissions: Test-Path (Split-Path $PROFILE)"
        "Windows Terminal" = "Install Windows Terminal from Microsoft Store first"
    }

    # Check for common error patterns
    if ($ErrorMessage -match "access.*denied|permission.*denied") {
        return "Permission denied. Try running as Administrator or use --scope user"
    }
    if ($ErrorMessage -match "network|timeout|connection|powershellgallery") {
        return "Network issue. Check internet connection and PowerShell Gallery access"
    }
    if ($ErrorMessage -match "execution.*policy") {
        if ($Component -eq "Scoop") {
            return "Run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser (required for Scoop)"
        }
        return "Run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
    }
    if ($ErrorMessage -match "module.*not.*found|cannot.*find.*module") {
        return "Update PowerShellGet: Install-Module PowerShellGet -Force -AllowClobber"
    }

    return $suggestions[$Component]
}

# Install winget package
function Install-WingetPackage {
    param(
        [string]$PackageId,
        [string]$Name
    )

    Write-Step "Installing $Name via winget..."

    # Check if already installed
    $installed = winget list --id $PackageId --exact 2>$null
    if ($LASTEXITCODE -eq 0 -and $installed -match $PackageId) {
        Write-Skip "$Name is already installed"
        return $true
    }

    try {
        $result = winget install $PackageId --silent --accept-package-agreements --accept-source-agreements 2>&1
        $resultString = $result | Out-String

        if ($LASTEXITCODE -eq 0) {
            Write-Success "$Name installed successfully"
            return $true
        }
        else {
            Write-ErrorMsg "Failed to install $Name"
            Write-SetupLog -Component $Name -Type "winget" -Operation "winget install $PackageId" -ErrorMessage "winget install failed" -FullOutput $resultString
            return $false
        }
    }
    catch {
        Write-ErrorMsg "Error installing $Name : $_"
        Write-SetupLog -Component $Name -Type "winget" -Operation "winget install $PackageId" -ErrorMessage $_.Exception.Message -FullOutput $_.Exception.ToString()
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

# Install oh-my-posh with font
function Install-OhMyPoshWithFont {
    $success = Install-WinGetPackage -PackageId "JanDeDobbeleer.OhMyPosh" -Name "oh-my-posh"
    if (-not $success) { return $false }

    # Install font
    Write-Step "Installing $FontName font..."
    try {
        if ($FontName -eq "CascadiaCode") {
            $fontInstalled = winget list --id "Microsoft.CascadiaCode" --exact 2>$null
            if ($LASTEXITCODE -eq 0 -and $fontInstalled -match "Microsoft.CascadiaCode") {
                Write-Skip "CascadiaCode font is already installed"
                return $true
            }
            else {
                winget install Microsoft.CascadiaCode --silent --accept-package-agreements --accept-source-agreements
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "CascadiaCode font installed"
                    return $true
                }
            }
        }
        else {
            Write-Host "  → Run 'oh-my-posh font install' manually to select $FontName" -ForegroundColor Yellow
            return $true  # Consider this success - user needs to do manual step
        }
    }
    catch {
        Write-ErrorMsg "Font installation failed: $_"
        return $false
    }
    return $false
}

# Install Yazi with configuration
function Install-YaziWithConfig {
    $success = Install-WinGetPackage -PackageId "sxyazi.yazi" -Name "Yazi"
    if (-not $success) { return $false }

    Write-Step "Installing optional Yazi dependencies..."
    try {
        $optionalDeps = @(
            @{Id = "Gyan.FFmpeg"; Name = "FFmpeg" },
            @{Id = "7zip.7zip"; Name = "7-Zip" },
            @{Id = "jqlang.jq"; Name = "jq" },
            @{Id = "oschwartz10612.Poppler"; Name = "Poppler" },
            @{Id = "sharkdp.fd"; Name = "fd" },
            @{Id = "BurntSushi.ripgrep.MSVC"; Name = "ripgrep" },
            @{Id = "junegunn.fzf"; Name = "fzf" },
            @{Id = "ajeetdsouza.zoxide"; Name = "zoxide" },
            @{Id = "ImageMagick.ImageMagick"; Name = "ImageMagick" }
        )

        $installedCount = 0
        foreach ($dep in $optionalDeps) {
            $installed = winget list --id $dep.Id --exact 2>$null
            if ($LASTEXITCODE -ne 0 -or $installed -notmatch $dep.Id) {
                Write-Host "  → Installing $($dep.Name)..." -ForegroundColor Gray
                winget install $dep.Id --silent --accept-package-agreements --accept-source-agreements 2>$null
                if ($LASTEXITCODE -eq 0) { $installedCount++ }
            }
        }
        Write-Success "Installed $installedCount optional Yazi dependencies"
    }
    catch {
        Write-Host "  → Some optional dependencies may have failed to install" -ForegroundColor Yellow
    }

    Write-Step "Setting up Yazi configuration..."
    try {
        $yaziConfigDest = Join-Path $env:APPDATA "yazi"

        # Check if yazi_config repo exists, clone if not
        if (-not (Test-Path $yaziConfigDest)) {
            Write-Host "  → Cloning Yazi configuration from GitHub..." -ForegroundColor Gray
            git clone "https://github.com/Tsabo/yazi_config.git" $yaziConfigDest 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Yazi configuration cloned successfully"
            }
            else {
                Write-ErrorMsg "Failed to clone Yazi configuration"
                return $false
            }
        }
        else {
            Write-Host "  → Updating Yazi configuration..." -ForegroundColor Gray
            Push-Location $yaziConfigDest
            try {
                git pull origin main 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Yazi configuration updated"
                }
                else {
                    Write-Host "  → Configuration update skipped (local changes may exist)" -ForegroundColor Yellow
                }
            }
            finally {
                Pop-Location
            }
        }

        Write-Step "Installing Yazi packages..."
        try {
            # Install flavors
            Write-Host "  → Installing flavors..." -ForegroundColor Gray
            & ya pkg add "gosxrgxx/flexoki-light" 2>$null
            & ya pkg add "956MB/vscode-dark-plus" 2>$null

            # Install plugins (including your fork)
            Write-Host "  → Installing plugins..." -ForegroundColor Gray
            & ya pkg add "yazi-rs/plugins:git" 2>$null
            & ya pkg add "Tsabo/githead.yazi#feature/guards_save_sync_block_with_pcall" 2>$null

            Write-Success "Yazi packages installed"
            return $true
        }
        catch {
            Write-ErrorMsg "Yazi package installation failed: $_"
            return $false
        }
    }
    catch {
        Write-ErrorMsg "Yazi configuration setup failed: $_"
        return $false
    }
}

# Deploy oh-my-posh theme
function Deploy-OhMyPoshTheme {
    Write-Step "Deploying oh-my-posh theme..."
    try {
        $ompConfigSource = Join-Path (Split-Path (Split-Path $PSScriptRoot)) "Config\oh-my-posh"

        # Try OneDrive location first, fallback to regular Documents
        $ompConfigDest = Join-Path $env:USERPROFILE "OneDrive\PowerShell\Posh"
        if (-not (Test-Path (Split-Path $ompConfigDest))) {
            $ompConfigDest = Join-Path $env:USERPROFILE "Documents\PowerShell\Posh"
        }

        if (Test-Path $ompConfigSource) {
            if (-not (Test-Path $ompConfigDest)) {
                New-Item -ItemType Directory -Path $ompConfigDest -Force | Out-Null
            }

            Copy-Item "$ompConfigSource\*.json" -Destination $ompConfigDest -Force
            Write-Success "oh-my-posh theme deployed to: $ompConfigDest"
            return $true
        }
        else {
            Write-Skip "oh-my-posh theme source not found"
            return $true
        }
    }
    catch {
        Write-ErrorMsg "oh-my-posh theme deployment failed: $_"
        return $false
    }
}

# Deploy PowerShell profile and modules
function Deploy-PowerShellProfile {
    Write-Step "Deploying PowerShell profile and custom modules..."
    try {
        $profilePath = $PROFILE
        $profileDir = Split-Path -Parent $profilePath
        $psSourceDir = Join-Path (Split-Path (Split-Path $PSScriptRoot)) "PowerShell"

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
                if ($deployment.IsDirectory) {
                    if (Test-Path $deployment.Dest) {
                        Remove-Item $deployment.Dest -Recurse -Force
                    }
                }
                Copy-Item $sourcePath -Destination $deployment.Dest -Recurse:$deployment.IsDirectory -Force
                Write-Success "$($deployment.Name) deployed to: $($deployment.Dest)"
            }
            else {
                Write-Skip "$($deployment.Name) source not found at: $sourcePath"
            }
        }

        # Create custom directories (user-specific, git-ignored)
        $customModulesDir = Join-Path $profileDir "CustomModules"
        $customScriptsDir = Join-Path $profileDir "CustomScripts"

        if (-not (Test-Path $customModulesDir)) {
            New-Item -ItemType Directory -Path $customModulesDir -Force | Out-Null
            Write-Success "CustomModules directory created"
        }

        if (-not (Test-Path $customScriptsDir)) {
            New-Item -ItemType Directory -Path $customScriptsDir -Force | Out-Null
            Write-Success "CustomScripts directory created"
        }

        return $true
    }
    catch {
        Write-ErrorMsg "PowerShell profile deployment failed: $_"
        return $false
    }
}

# Deploy Windows Terminal settings
function Deploy-TerminalSettings {
    Write-Step "Applying Windows Terminal font and window settings..."
    try {
        $terminalDeployScript = Join-Path $PSScriptRoot "Deploy-Terminal.ps1"

        if (Test-Path $terminalDeployScript) {
            $deployResult = & $terminalDeployScript -NoBackup 2>&1

            if ($LASTEXITCODE -eq 0 -or $deployResult -match "successfully") {
                Write-Success "Windows Terminal settings deployed"
                return $true
            }
            else {
                Write-ErrorMsg "Windows Terminal deployment failed"
                return $false
            }
        }
        else {
            Write-Skip "Windows Terminal deployment script not found"
            return $true
        }
    }
    catch {
        Write-ErrorMsg "Windows Terminal settings deployment failed: $_"
        return $false
    }
}

# Process a single component
function Install-SetupComponent {
    param($Component, [hashtable]$Results)

    # Skip optional components if requested
    if ($Component.IsOptional -and $SkipOptional) {
        $Results.Skipped += "$($Component.Name) (optional)"
        return
    }

    $success = switch ($Component.Type) {
        "winget" { Install-WinGetPackage -PackageId $Component.Properties.PackageId -Name $Component.Name }
        "module" { Install-PSModuleIfMissing -ModuleName $Component.Properties.ModuleName -DisplayName $Component.Name }
        "custom" { & $Component.CustomInstaller }
        default {
            Write-ErrorMsg "Unknown component type: $($Component.Type)"
            $false
        }
    }

    if ($success) {
        $Results.Success += $Component.Name
    }
    else {
        # Log detailed failure information
        $operation = switch ($Component.Type) {
            "winget" { "winget install $($Component.Properties.PackageId)" }
            "module" { "Install-Module $($Component.Properties.ModuleName)" }
            "custom" { "Custom installer" }
            default { "Unknown operation" }
        }

        Write-SetupLog -Component $Component.Name -Type $Component.Type -Operation $operation -ErrorMessage "Installation failed"

        if ($Component.IsOptional) {
            $Results.Skipped += "$($Component.Name) (failed, optional)"
        }
        else {
            $Results.Failed += $Component.Name
        }
    }
}

# Show setup summary
function Show-SetupSummary {
    param([hashtable]$Results)

    Write-Host "`n`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                    SETUP SUMMARY                           ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

    if ($Results.Success.Count -gt 0) {
        Write-Host "`n✅ Successfully installed ($($Results.Success.Count)):" -ForegroundColor Green
        $Results.Success | ForEach-Object { Write-Host "   • $_" -ForegroundColor Green }
    }

    if ($Results.Skipped.Count -gt 0) {
        Write-Host "`n⊘ Skipped ($($Results.Skipped.Count)):" -ForegroundColor Yellow
        $Results.Skipped | ForEach-Object { Write-Host "   • $_" -ForegroundColor Yellow }
    }

    if ($Results.Failed.Count -gt 0) {
        Write-Host "`n❌ Failed ($($Results.Failed.Count)):" -ForegroundColor Red
        $Results.Failed | ForEach-Object { Write-Host "   • $_" -ForegroundColor Red }
        Write-Host "`n💡 For detailed failure information, run: " -NoNewline -ForegroundColor Cyan
        Write-Host ".\Setup.ps1 -ShowDetails" -ForegroundColor White
    }

    # Next steps
    Write-Host "`n`n📝 NEXT STEPS:" -ForegroundColor Cyan
    Write-Host "   1. Restart your PowerShell session or run: " -NoNewline
    Write-Host "refreshenv" -ForegroundColor Yellow
    Write-Host "   2. Configure your PowerShell profile if not already done" -ForegroundColor White
    Write-Host "   3. Set your terminal font to CascadiaCode NF (Nerd Font)" -ForegroundColor White
    Write-Host "   4. Configure oh-my-posh theme: " -NoNewline
    Write-Host "oh-my-posh init pwsh --config <theme>" -ForegroundColor Yellow

    if ($Results.Failed.Count -eq 0) {
        Write-Host "`n🎉 " -NoNewline -ForegroundColor Green
        Write-Host "Setup completed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "`n⚠️  " -NoNewline -ForegroundColor Yellow
        Write-Host "Setup completed with some failures. Please review above." -ForegroundColor Yellow
    }
}

# Main setup orchestrator - clean and focused
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
║     PowerShell Environment Setup Automation                ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

    $results = @{
        Success = @()
        Failed = @()
        Skipped = @()
    }

    $components = Get-EnvironmentComponents

    foreach ($component in $components) {
        Install-SetupComponent -Component $component -Results $results
    }

    Show-SetupSummary -Results $results
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
