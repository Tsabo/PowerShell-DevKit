<#
.SYNOPSIS
    Updates all PowerShell environment components
.DESCRIPTION
    Updates winget packages and PowerShell modules used in your environment
.PARAMETER WingetOnly
    Only update winget packages
.PARAMETER ModulesOnly
    Only update PowerShell modules
.EXAMPLE
    .\Update.ps1
.EXAMPLE
    .\Update.ps1 -ModulesOnly
.EXAMPLE
    .\Update.ps1 -ShowDetails
    Shows detailed failure information from the last update run
.EXAMPLE
    .\Update.ps1 -ClearLogs
    Clears stored failure logs
#>
[CmdletBinding()]
param(
    [switch]$WingetOnly,
    [switch]$ModulesOnly,
    [switch]$ShowDetails,
    [switch]$ClearLogs
)

# Import shared component definitions
Import-Module (Join-Path $PSScriptRoot "Components.psm1") -Force

$ErrorActionPreference = "Continue"

# Setup logging
$logDir = Join-Path $PSScriptRoot "Logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}
$logFile = Join-Path $logDir "update-details.json"

function Write-Step {
    param([string]$Message)
    Write-Host "`n🔹 $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "  ℹ $Message" -ForegroundColor Blue
}

# Log detailed failure information
function Write-DetailedLog {
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
    }
    
    # Read existing log or create new
    $logData = @()
    if (Test-Path $logFile) {
        try {
            $existingData = Get-Content $logFile -Raw | ConvertFrom-Json
            # Ensure we have an array
            if ($existingData) {
                if ($existingData -is [Array]) {
                    $logData = [System.Collections.ArrayList]@($existingData)
                } else {
                    $logData = [System.Collections.ArrayList]@($existingData)
                }
            }
        } catch {
            $logData = [System.Collections.ArrayList]@()
        }
    } else {
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

# Show detailed failure information
function Show-FailureDetails {
    if (-not (Test-Path $logFile)) {
        Write-Host "No failure details found. Run an update first." -ForegroundColor Yellow
        return
    }
    
    try {
        $logData = Get-Content $logFile -Raw | ConvertFrom-Json
        $recentFailures = $logData | Where-Object { $_.Timestamp -gt (Get-Date).AddDays(-7) }
        
        if ($recentFailures.Count -eq 0) {
            Write-Host "No recent failures found in the last 7 days." -ForegroundColor Green
            return
        }
        
        Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "║                    FAILURE DETAILS                         ║" -ForegroundColor Red  
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
                if (($latestFailure.FullOutput -split "`n").Count -gt 5) {
                    Write-Host "     ... (truncated)" -ForegroundColor DarkGray
                }
            }
            
            # Show failure frequency
            if ($failures.Count -gt 1) {
                Write-Host "   Failure frequency: $($failures.Count) times in last 7 days" -ForegroundColor Yellow
            }
            
            # Suggest solutions based on common patterns
            $suggestion = Get-FailureSuggestion -Component $component -Error $latestFailure.ErrorMessage
            if ($suggestion) {
                Write-Host "   💡 Suggestion: $suggestion" -ForegroundColor Cyan
            }
        }
        
    } catch {
        Write-Host "Error reading failure details: $_" -ForegroundColor Red
    }
}

# Provide suggestions based on common failure patterns  
function Get-FailureSuggestion {
    param([string]$Component, [string]$Error)
    
    $suggestions = @{
        "gsudo" = "Try running PowerShell as Administrator, or install manually: winget install gerardog.gsudo"
        "CascadiaCode Font" = "Font updates often fail silently. Manually check if font is installed in Windows Settings"
        "oh-my-posh" = "Try refreshing environment variables: refreshenv, or restart PowerShell"
        "PSFzf" = "Update PowerShellGet first: Install-Module PowerShellGet -Force"
        "Terminal-Icons" = "Check if module is locked by running process. Close all PowerShell windows and retry"
        "posh-git" = "Ensure Git is installed and in PATH. Run: git --version"
    }
    
    # Check for common error patterns
    if ($Error -match "access.*denied|permission.*denied") {
        return "Permission denied. Try running as Administrator"
    }
    if ($Error -match "network|timeout|connection") {
        return "Network issue. Check internet connection and try again"
    }
    if ($Error -match "locked|in use") {
        return "Resource locked. Close applications using this component and retry"
    }
    
    return $suggestions[$Component]
}

# Handle special parameters first
if ($ShowDetails) {
    Show-FailureDetails
    exit 0
}

if ($ClearLogs) {
    if (Test-Path $logFile) {
        Remove-Item $logFile -Force
        Write-Host "✓ Failure logs cleared successfully" -ForegroundColor Green
    } else {
        Write-Host "No failure logs found to clear" -ForegroundColor Yellow
    }
    exit 0
}

Write-Host @"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║     PowerShell Environment Updater                         ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

$updates = @{
    WingetSuccess = @()
    WingetFailed = @()
    ModulesSuccess = @()
    ModulesFailed = @()
    ScoopSuccess = @()
    ScoopFailed = @()
    YaziSuccess = @()
    YaziFailed = @()
}

# Update winget packages
if (-not $ModulesOnly) {
    Write-Step "Updating winget packages..."
    
    $components = Get-EnvironmentComponents
    $wingetComponents = $components | Where-Object { $_.Type -eq "winget" }
    
    foreach ($component in $wingetComponents) {
        $pkg = $component.Properties.PackageId
        try {
            Write-Host "`n  Checking $($component.Name)..." -ForegroundColor Gray
            $result = winget upgrade $pkg --silent --accept-package-agreements --accept-source-agreements 2>&1
            $resultString = $result | Out-String
            
            if ($LASTEXITCODE -eq 0) {
                if ($resultString -match "No applicable update found" -or $resultString -match "No installed package found") {
                    Write-Info "$($component.Name) is up to date or not installed"
                } else {
                    Write-Success "$($component.Name) updated"
                    $updates.WingetSuccess += $component.Name
                }
            } else {
                Write-Host "  ⚠ Failed to update $($component.Name)" -ForegroundColor Yellow
                $updates.WingetFailed += $component.Name
                Write-DetailedLog -Component $component.Name -Type "winget" -Operation "upgrade" -ErrorMessage "winget upgrade failed" -FullOutput $resultString
            }
        }
        catch {
            Write-Host "  ⚠ Error updating $($component.Name) : $_" -ForegroundColor Yellow
            $updates.WingetFailed += $component.Name
            Write-DetailedLog -Component $component.Name -Type "winget" -Operation "upgrade" -ErrorMessage $_.Exception.Message -FullOutput $_.Exception.ToString()
        }
    }
}

# Update PowerShell modules
if (-not $WingetOnly) {
    Write-Step "Updating PowerShell modules..."
    
    $components = Get-EnvironmentComponents
    $moduleComponents = $components | Where-Object { $_.Type -eq "module" }
    
    foreach ($component in $moduleComponents) {
        $moduleName = $component.Properties.ModuleName
        $installedModule = Get-Module -ListAvailable -Name $moduleName | 
            Sort-Object Version -Descending | 
            Select-Object -First 1
        
        if ($installedModule) {
            Write-Host "`n  Checking $($component.Name) (current: $($installedModule.Version))..." -ForegroundColor Gray
            
            try {
                # Find the latest version available
                $latestModule = Find-Module -Name $moduleName -ErrorAction Stop
                
                if ($latestModule.Version -gt $installedModule.Version) {
                    Write-Host "    Updating from $($installedModule.Version) to $($latestModule.Version)..." -ForegroundColor Yellow
                    Update-Module -Name $moduleName -Force -ErrorAction Stop
                    Write-Success "$($component.Name) updated to $($latestModule.Version)"
                    $updates.ModulesSuccess += "$($component.Name) ($($latestModule.Version))"
                } else {
                    Write-Info "$($component.Name) is up to date ($($installedModule.Version))"
                }
            }
            catch {
                Write-Host "  ⚠ Error updating $($component.Name) : $_" -ForegroundColor Yellow
                $updates.ModulesFailed += $component.Name
                Write-DetailedLog -Component $component.Name -Type "module" -Operation "Update-Module" -ErrorMessage $_.Exception.Message -FullOutput $_.Exception.ToString()
            }
        } else {
            Write-Host "  ⊘ $($component.Name) not installed, skipping" -ForegroundColor Yellow
        }
    }
}

# Update Scoop packages
if (-not $WingetOnly -and -not $ModulesOnly) {
    Write-Step "Updating Scoop packages..."
    
    try {
        $scoopUpdateResult = Update-ScoopPackages
        if ($scoopUpdateResult.Updated.Count -gt 0) {
            $updates.ScoopSuccess += $scoopUpdateResult.Updated
        }
        if ($scoopUpdateResult.Failed.Count -gt 0) {
            $updates.ScoopFailed += $scoopUpdateResult.Failed
            Write-DetailedLog -Component "Scoop packages" -Type "scoop" -Operation "scoop update --all" -ErrorMessage "Some scoop packages failed to update" -FullOutput ""
        }
    }
    catch {
        $updates.ScoopFailed += "Scoop packages"
        Write-DetailedLog -Component "Scoop packages" -Type "scoop" -Operation "scoop update --all" -ErrorMessage $_.Exception.Message -FullOutput $_.Exception.ToString()
    }
}

# Update Yazi packages
if (-not $WingetOnly -and -not $ModulesOnly) {
    Write-Step "Updating Yazi packages and configuration..."
    
    try {
        $yaziUpdateResult = Update-YaziPackages
        if ($yaziUpdateResult) {
            $updates.YaziSuccess += "Yazi packages and configuration"
        } else {
            $updates.YaziFailed += "Yazi packages"
            Write-DetailedLog -Component "Yazi packages" -Type "yazi" -Operation "ya pkg update" -ErrorMessage "Yazi package update failed" -FullOutput ""
        }
    }
    catch {
        $updates.YaziFailed += "Yazi packages"
        Write-DetailedLog -Component "Yazi packages" -Type "yazi" -Operation "ya pkg update" -ErrorMessage $_.Exception.Message -FullOutput $_.Exception.ToString()
    }
}

# Summary
Write-Host "`n`n" -NoNewline
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    UPDATE SUMMARY                          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$totalUpdates = $updates.WingetSuccess.Count + $updates.ModulesSuccess.Count + $updates.ScoopSuccess.Count + $updates.YaziSuccess.Count
$totalFailed = $updates.WingetFailed.Count + $updates.ModulesFailed.Count + $updates.ScoopFailed.Count + $updates.YaziFailed.Count

if ($updates.WingetSuccess.Count -gt 0) {
    Write-Host "`n✅ Winget packages updated ($($updates.WingetSuccess.Count)):" -ForegroundColor Green
    $updates.WingetSuccess | ForEach-Object { Write-Host "   • $_" -ForegroundColor Green }
}

if ($updates.ModulesSuccess.Count -gt 0) {
    Write-Host "`n✅ PowerShell modules updated ($($updates.ModulesSuccess.Count)):" -ForegroundColor Green
    $updates.ModulesSuccess | ForEach-Object { Write-Host "   • $_" -ForegroundColor Green }
}

if ($updates.ScoopSuccess.Count -gt 0) {
    Write-Host "`n✅ Scoop packages updated ($($updates.ScoopSuccess.Count)):" -ForegroundColor Green
    $updates.ScoopSuccess | ForEach-Object { Write-Host "   • $_" -ForegroundColor Green }
}

if ($updates.YaziSuccess.Count -gt 0) {
    Write-Host "`n✅ Yazi components updated ($($updates.YaziSuccess.Count)):" -ForegroundColor Green
    $updates.YaziSuccess | ForEach-Object { Write-Host "   • $_" -ForegroundColor Green }
}

if ($totalFailed -gt 0) {
    Write-Host "`n❌ Failed updates ($totalFailed):" -ForegroundColor Red
    $updates.WingetFailed | ForEach-Object { Write-Host "   • $_ (winget)" -ForegroundColor Red }
    $updates.ModulesFailed | ForEach-Object { Write-Host "   • $_ (module)" -ForegroundColor Red }
    $updates.ScoopFailed | ForEach-Object { Write-Host "   • $_ (scoop)" -ForegroundColor Red }
    $updates.YaziFailed | ForEach-Object { Write-Host "   • $_ (yazi)" -ForegroundColor Red }
    Write-Host "`n💡 For detailed failure information, run: " -NoNewline -ForegroundColor Cyan
    Write-Host ".\Update.ps1 -ShowDetails" -ForegroundColor White
}

if ($totalUpdates -eq 0 -and $totalFailed -eq 0) {
    Write-Host "`n✓ All components are already up to date!" -ForegroundColor Green
} elseif ($totalUpdates -gt 0) {
    Write-Host "`n🎉 Successfully updated $totalUpdates component(s)!" -ForegroundColor Green
    Write-Host "`n📝 Note: Restart PowerShell to use updated components" -ForegroundColor Yellow
}
