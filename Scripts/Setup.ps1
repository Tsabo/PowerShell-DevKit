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

    # Check if already installed with timeout
    try {
        Write-Host "  → Checking if already installed..." -ForegroundColor Gray

        $checkJob = Start-Job -ScriptBlock {
            param($pkgId)
            $result = winget list --id $pkgId --exact --disable-interactivity 2>$null
            return @{
                Output = $result
                ExitCode = $LASTEXITCODE
            }
        } -ArgumentList $PackageId

        $checkCompleted = Wait-Job -Job $checkJob -Timeout 15

        if ($checkCompleted) {
            $checkResult = Receive-Job -Job $checkJob
            Remove-Job -Job $checkJob

            if ($checkResult.ExitCode -eq 0 -and $checkResult.Output -match $PackageId) {
                Write-Skip "$Name is already installed"
                return $true
            }
        }
        else {
            # Check timed out, continue with installation
            Stop-Job -Job $checkJob
            Remove-Job -Job $checkJob
            Write-Host "  → Check timed out, proceeding with installation..." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  → Check failed, proceeding with installation..." -ForegroundColor Yellow
    }

    try {
        # Create a job to run winget with timeout
        Write-Host "  → Running winget (timeout: 60s)..." -ForegroundColor Gray

        $job = Start-Job -ScriptBlock {
            param($pkgId)
            $output = winget install $pkgId --silent --disable-interactivity --accept-package-agreements --accept-source-agreements 2>&1
            return @{
                Output = $output | Out-String
                ExitCode = $LASTEXITCODE
            }
        } -ArgumentList $PackageId

        # Wait for job with 60 second timeout
        $completed = Wait-Job -Job $job -Timeout 60

        if ($completed) {
            $jobResult = Receive-Job -Job $job
            Remove-Job -Job $job

            if ($jobResult.ExitCode -eq 0) {
                Write-Success "$Name installed successfully"
                return $true
            }
            else {
                Write-ErrorMsg "Failed to install $Name (exit code: $($jobResult.ExitCode))"
                Write-SetupLog -Component $Name -Type "winget" -Operation "winget install $PackageId" -ErrorMessage "winget install failed" -ExitCode $jobResult.ExitCode -FullOutput $jobResult.Output
                return $false
            }
        }
        else {
            # Timeout occurred
            Stop-Job -Job $job
            Remove-Job -Job $job
            Write-ErrorMsg "Installation of $Name timed out after 60 seconds"
            Write-SetupLog -Component $Name -Type "winget" -Operation "winget install $PackageId" -ErrorMessage "Installation timed out" -ExitCode -1
            return $false
        }
    }
    catch {
        Write-ErrorMsg "Error installing $Name : $_"
        Write-SetupLog -Component $Name -Type "winget" -Operation "winget install $PackageId" -ErrorMessage $_.Exception.Message -ExitCode 0 -FullOutput $_.Exception.ToString()
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

# Note: Custom installer functions (Install-OhMyPoshWithFont, Install-YaziWithConfig,
# Deploy-OhMyPoshTheme, Deploy-PowerShellProfile, Deploy-TerminalSettings) are now
# defined in Components.psm1 where they're used by the component definitions.

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
        "custom" {
            try {
                Write-Step "Installing $($Component.Name)..."
                Write-Host "  → Running custom installer..." -ForegroundColor Gray
                $result = & $Component.CustomInstaller 2>&1

                # Debug: Show what we got back
                Write-Host "  → Installer returned: $($result | Out-String)" -ForegroundColor DarkGray

                # Check if result is explicitly false or null
                if ($result -eq $false -or $null -eq $result) {
                    Write-ErrorMsg "Custom installer returned: $result"
                    $false
                }
                elseif ($result -is [bool]) {
                    $result
                }
                else {
                    # Try to convert to boolean, default to true if we got any output
                    if ($result -match "true|success") {
                        $true
                    }
                    elseif ($result -match "false|fail") {
                        $false
                    }
                    else {
                        # If we got here, assume success (function completed without error)
                        $true
                    }
                }
            }
            catch {
                Write-ErrorMsg "Custom installer exception: $_"
                Write-ErrorMsg "Stack trace: $($_.ScriptStackTrace)"
                $false
            }
        }
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

        # Capture exit code immediately
        $currentExitCode = if ($LASTEXITCODE) { $LASTEXITCODE } else { 0 }

        Write-SetupLog -Component $Component.Name -Type $Component.Type -Operation $operation -ErrorMessage "Installation failed" -ExitCode $currentExitCode

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

    if ($Results.Failed.Count -eq 0 -and $Results.Success -contains "PowerShell Profile") {
        Write-Host "   1. Reload your profile to apply changes: " -NoNewline
        Write-Host ". `$PROFILE" -ForegroundColor Yellow
        Write-Host "   2. Set your terminal font to CascadiaCode NF (Nerd Font)" -ForegroundColor White
        Write-Host "   3. Customize your environment using " -NoNewline
        Write-Host "CustomProfile.ps1" -ForegroundColor Yellow
        Write-Host "   4. Add your own modules to " -NoNewline
        Write-Host "CustomModules\" -ForegroundColor Yellow
        Write-Host "   5. Add your own scripts to " -NoNewline
        Write-Host "CustomScripts\" -ForegroundColor Yellow
    }
    else {
        Write-Host "   1. Restart your PowerShell session or run: " -NoNewline
        Write-Host "refreshenv" -ForegroundColor Yellow
        Write-Host "   2. Configure your PowerShell profile if not already done" -ForegroundColor White
        Write-Host "   3. Set your terminal font to CascadiaCode NF (Nerd Font)" -ForegroundColor White
        Write-Host "   4. Configure oh-my-posh theme: " -NoNewline
        Write-Host "oh-my-posh init pwsh --config <theme>" -ForegroundColor Yellow
    }

    if ($Results.Failed.Count -eq 0) {
        Write-Host "`n🎉 " -NoNewline -ForegroundColor Green
        Write-Host "Setup completed successfully!" -ForegroundColor Green

        # Offer to reload profile if it was deployed
        if ($Results.Success -contains "PowerShell Profile") {
            Write-Host "`n💡 Would you like to reload your profile now? " -NoNewline -ForegroundColor Cyan
            Write-Host "(Y/n): " -NoNewline -ForegroundColor White
            $response = Read-Host

            if ($response -eq "" -or $response -match "^[Yy]") {
                Write-Host "`n🔄 Reloading profile..." -ForegroundColor Cyan
                try {
                    . $PROFILE
                    Write-Host "✅ Profile reloaded successfully!" -ForegroundColor Green
                }
                catch {
                    Write-Host "⚠️  Could not reload profile: $_" -ForegroundColor Yellow
                    Write-Host "   Please reload manually with: " -NoNewline
                    Write-Host ". `$PROFILE" -ForegroundColor Yellow
                }
            }
        }
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
