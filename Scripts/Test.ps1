<#
.SYNOPSIS
    Validates PowerShell environment setup
.DESCRIPTION
    Checks if all required tools and modules from your setup guide are installed
    and reports their versions and status.
.EXAMPLE
    .\Test.ps1
#>
[CmdletBinding()]
param()

# Import shared component definitions
Import-Module (Join-Path $PSScriptRoot "Components.psm1") -Force

# Color output functions
function Write-CheckHeader {
    param([string]$Message)
    Write-Host "`n═══ $Message ═══" -ForegroundColor Cyan
}

function Write-Installed {
    param([string]$Name, [string]$Version = "")
    if ($Version) {
        Write-Host "  ✓ $Name" -ForegroundColor Green -NoNewline
        Write-Host " ($Version)" -ForegroundColor Gray
    } else {
        Write-Host "  ✓ $Name" -ForegroundColor Green
    }
}

function Write-Missing {
    param([string]$Name, [string]$InstallCommand = "")
    Write-Host "  ✗ $Name" -ForegroundColor Red -NoNewline
    if ($InstallCommand) {
        Write-Host " → Install: " -ForegroundColor Yellow -NoNewline
        Write-Host $InstallCommand -ForegroundColor White
    } else {
        Write-Host ""
    }
}

function Write-Optional {
    param([string]$Name, [bool]$Installed, [string]$Version = "")
    if ($Installed) {
        Write-Installed -Name "$Name (optional)" -Version $Version
    } else {
        Write-Host "  ⊘ $Name (optional - not installed)" -ForegroundColor Yellow
    }
}

# Validate a single component and display result
function Test-ComponentAndDisplay {
    param($Component, [hashtable]$Stats)
    
    $Stats.Total++
    if ($Component.IsOptional) { $Stats.Optional++ }
    
    $result = Test-EnvironmentComponent -Component $Component
    
    if ($result.IsInstalled) {
        if ($Component.IsOptional) {
            Write-Optional -Name $Component.Name -Installed $true -Version $result.Version
        } else {
            Write-Installed -Name $Component.Name -Version $result.Version
        }
        $Stats.Installed++
        
        # Show additional info for complex components
        if ($result.Issues -and $result.Issues.Count -gt 0) {
            foreach ($issue in $result.Issues) {
                Write-Host "    ⚠ $issue" -ForegroundColor Yellow
            }
        }
        if ($result.HasConfig -eq $false) {
            Write-Host "    ⚠ Configuration not deployed" -ForegroundColor Yellow
        }
        if ($result.HasCorrectFont -eq $false) {
            Write-Host "    ⚠ CaskaydiaCove Nerd Font not set as default" -ForegroundColor Yellow
        }
        
    } else {
        if ($Component.IsOptional) {
            Write-Optional -Name $Component.Name -Installed $false
        } else {
            $installCmd = switch ($Component.Type) {
                "winget" { "winget install $($Component.Properties.PackageId)" }
                "module" { "Install-Module -Name $($Component.Properties.ModuleName) -Scope CurrentUser" }
                default { "Run .\Setup.ps1" }
            }
            Write-Missing -Name $Component.Name -InstallCommand $installCmd
            $Stats.Missing++
        }
    }
}

Write-Host @"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║     PowerShell Environment Validation                      ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

$stats = @{
    Total = 0
    Installed = 0
    Missing = 0
    Optional = 0
}

# Check PowerShell version first
Write-CheckHeader "PowerShell"
$stats.Total++
if ($PSVersionTable.PSVersion.Major -ge 7) {
    Write-Installed -Name "PowerShell" -Version $PSVersionTable.PSVersion
    $stats.Installed++
} else {
    Write-Host "  ⚠ PowerShell $($PSVersionTable.PSVersion) (consider upgrading to 7+)" -ForegroundColor Yellow
    $stats.Installed++
}

# Get all components and group them by type for better display
$components = Get-EnvironmentComponents

# Group components for organized display
$wingetComponents = $components | Where-Object { $_.Type -eq "winget" }
$moduleComponents = $components | Where-Object { $_.Type -eq "module" }
$customComponents = $components | Where-Object { $_.Type -eq "custom" }

# Check winget packages
if ($wingetComponents.Count -gt 0) {
    Write-CheckHeader "Winget Packages"
    foreach ($component in $wingetComponents) {
        Test-ComponentAndDisplay -Component $component -Stats $stats
    }
}

# Check PowerShell modules
if ($moduleComponents.Count -gt 0) {
    Write-CheckHeader "PowerShell Modules"
    foreach ($component in $moduleComponents) {
        Test-ComponentAndDisplay -Component $component -Stats $stats
    }
}

# Check custom configurations
if ($customComponents.Count -gt 0) {
    Write-CheckHeader "Configuration Components"
    foreach ($component in $customComponents) {
        Test-ComponentAndDisplay -Component $component -Stats $stats
    }
}

# Summary
Write-Host "`n`n" -NoNewline
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                       SUMMARY                              ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$required = $stats.Total - $stats.Optional
$requiredInstalled = $stats.Installed - ($stats.Optional - ($stats.Total - $stats.Installed - $stats.Missing))

Write-Host "`nRequired Components: " -NoNewline
Write-Host "$requiredInstalled" -ForegroundColor $(if ($stats.Missing -gt 0) { "Yellow" } else { "Green" }) -NoNewline
Write-Host " / $required installed"

Write-Host "Optional Components: Included in total count" -ForegroundColor Gray
Write-Host "Total: " -NoNewline
Write-Host "$($stats.Installed)" -ForegroundColor $(if ($stats.Missing -gt 0) { "Yellow" } else { "Green" }) -NoNewline
Write-Host " / $($stats.Total) installed"

if ($stats.Missing -eq 0) {
    Write-Host "`n🎉 All required components are installed!" -ForegroundColor Green
    Write-Host "Your PowerShell environment is ready to go!" -ForegroundColor Green
} else {
    Write-Host "`n⚠️  $($stats.Missing) component(s) missing" -ForegroundColor Yellow
    Write-Host "Run the setup script to install missing components:" -ForegroundColor White
    Write-Host "  .\Setup.ps1" -ForegroundColor Cyan
}

# Return exit code based on missing required components
if ($stats.Missing -gt 0) {
    exit 1
} else {
    exit 0
}
