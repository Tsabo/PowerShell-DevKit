#Requires -Version 5.1
<#
.SYNOPSIS
    Validates PowerShell code quality before commits using PSScriptAnalyzer and custom checks.

.DESCRIPTION
    This script performs comprehensive validation of all PowerShell code in the repository:
    - PSScriptAnalyzer analysis with project-specific settings
    - Syntax validation for all .ps1 and .psm1 files
    - Configuration file validation (JSON, TOML)
    - Custom project-specific checks

    Use this script before committing changes to ensure code quality standards.

.PARAMETER Quick
    Runs only essential checks (syntax validation). Faster but less comprehensive.

.PARAMETER Detailed
    Shows detailed PSScriptAnalyzer results including Information-level messages.

.PARAMETER Path
    Specific path to validate. Defaults to current directory.

.PARAMETER FailOnWarnings
    Treat warnings as failures. Use for strict validation.

.PARAMETER Export
    Export results to JSON files for detailed analysis.

.EXAMPLE
    .\Scripts\Validate-Code.ps1
    Runs standard validation with errors and warnings.

.EXAMPLE
    .\Scripts\Validate-Code.ps1 -Quick
    Runs only syntax validation for quick checks.

.EXAMPLE
    .\Scripts\Validate-Code.ps1 -Detailed -Export
    Runs detailed analysis and exports results to files.

.EXAMPLE
    .\Scripts\Validate-Code.ps1 -Path ".\Scripts" -FailOnWarnings
    Validates only Scripts directory with strict failure criteria.

.NOTES
    This script is designed to be run before committing code changes.
    It uses the project's PSScriptAnalyzerSettings.psd1 for custom rules.

    Exit codes:
    0 = Success (no errors)
    1 = PSScriptAnalyzer errors found
    2 = Syntax errors found
    3 = Configuration errors found
    4 = Missing dependencies
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Run only essential checks for faster validation")]
    [switch]$Quick,

    [Parameter(HelpMessage = "Show detailed results including Information messages")]
    [switch]$Detailed,

    [Parameter(HelpMessage = "Path to validate (defaults to current directory)")]
    [ValidateScript({ Test-Path $_ })]
    [string]$Path = ".",

    [Parameter(HelpMessage = "Treat warnings as failures")]
    [switch]$FailOnWarnings,

    [Parameter(HelpMessage = "Export detailed results to JSON files")]
    [switch]$Export
)

#region Helper Functions

function Write-ValidationHeader {
    param([string]$Title)

    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host " $Title" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Cyan
}

function Write-ValidationResult {
    param(
        [string]$Message,
        [ValidateSet("Success", "Warning", "Error", "Info")]
        [string]$Type = "Info"
    )

    $color = switch ($Type) {
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error" { "Red" }
        "Info" { "Cyan" }
    }

    $icon = switch ($Type) {
        "Success" { "✅" }
        "Warning" { "⚠️ " }
        "Error" { "❌" }
        "Info" { "ℹ️ " }
    }

    Write-Host "$icon $Message" -ForegroundColor $color
}

function Test-PSScriptAnalyzerAvailable {
    try {
        $null = Get-Module -Name PSScriptAnalyzer -ListAvailable
        return $true
    }
    catch {
        return $false
    }
}

function Test-SyntaxErrors {
    param([string]$FilePath)

    try {
        $errors = $null
        $content = Get-Content -Path $FilePath -Raw -ErrorAction Stop
        $null = [System.Management.Automation.PSParser]::Tokenize($content, [ref]$errors)

        return @{
            HasErrors = $errors.Count -gt 0
            Errors = $errors
            FilePath = $FilePath
        }
    }
    catch {
        return @{
            HasErrors = $true
            Errors = @(@{ Message = $_.Exception.Message; Type = "ParseException" })
            FilePath = $FilePath
        }
    }
}

function Get-CrossPlatformPath {
    param([string]$Path)
    # Normalize path separators for cross-platform compatibility
    return $Path -replace '\\', [System.IO.Path]::DirectorySeparatorChar
}

#endregion

#region Main Validation Logic

try {
    $ErrorActionPreference = "Stop"
    $startTime = Get-Date
    $totalIssues = 0
    $criticalIssues = 0

    Write-ValidationHeader "PowerShell Code Quality Validation"
    Write-Host "Path: $Path" -ForegroundColor Gray
    Write-Host "Mode: $(if ($Quick) { 'Quick' } elseif ($Detailed) { 'Detailed' } else { 'Standard' })" -ForegroundColor Gray
    Write-Host "Started: $($startTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray

    # Check dependencies
    Write-ValidationHeader "Dependency Check"

    if (-not (Test-PSScriptAnalyzerAvailable)) {
        Write-ValidationResult "PSScriptAnalyzer module not found" -Type "Error"
        Write-Host "Install with: Install-Module -Name PSScriptAnalyzer -Scope CurrentUser" -ForegroundColor Yellow
        exit 4
    }

    Write-ValidationResult "PSScriptAnalyzer module available" -Type "Success"

    # Find PowerShell files (cross-platform path filtering)
    $psFiles = Get-ChildItem -Path $Path -Include "*.ps1", "*.psm1" -Recurse |
        Where-Object {
            $_.FullName -notmatch [regex]::Escape([System.IO.Path]::DirectorySeparatorChar + '.git' + [System.IO.Path]::DirectorySeparatorChar) -and
            $_.FullName -notmatch [regex]::Escape([System.IO.Path]::DirectorySeparatorChar + 'Logs' + [System.IO.Path]::DirectorySeparatorChar)
        }

    Write-ValidationResult "Found $($psFiles.Count) PowerShell files to validate" -Type "Info"

    if ($psFiles.Count -eq 0) {
        Write-ValidationResult "No PowerShell files found to validate" -Type "Warning"
        exit 0
    }

    # Syntax validation (always run)
    Write-ValidationHeader "Syntax Validation"

    $syntaxErrors = @()
    foreach ($file in $psFiles) {
        $result = Test-SyntaxErrors -FilePath $file.FullName
        if ($result.HasErrors) {
            $syntaxErrors += $result
            Write-ValidationResult "Syntax error in $($file.Name): $($result.Errors[0].Message)" -Type "Error"
        }
        else {
            Write-Host "✓ $($file.Name)" -ForegroundColor DarkGreen
        }
    }

    if ($syntaxErrors.Count -gt 0) {
        Write-ValidationResult "$($syntaxErrors.Count) files have syntax errors" -Type "Error"
        $criticalIssues += $syntaxErrors.Count
    }
    else {
        Write-ValidationResult "All files have valid syntax" -Type "Success"
    }

    # Skip PSScriptAnalyzer in Quick mode
    if (-not $Quick) {
        Write-ValidationHeader "PSScriptAnalyzer Code Quality Check"

        # Determine settings file (cross-platform path)
        $settingsFile = Get-CrossPlatformPath (Join-Path $Path "PSScriptAnalyzerSettings.psd1")
        $settings = if (Test-Path $settingsFile) {
            Write-Host "Using project settings: $settingsFile" -ForegroundColor Gray
            $settingsFile
        }
        else {
            Write-Host "Using default PSGallery settings" -ForegroundColor Gray
            "PSGallery"
        }

        # Run PSScriptAnalyzer
        try {
            $severityLevels = if ($Detailed) {
                @('Error', 'Warning', 'Information')
            }
            else {
                @('Error', 'Warning')
            }

            Write-Host "Analyzing with severity levels: $($severityLevels -join ', ')" -ForegroundColor Gray

            $results = Invoke-ScriptAnalyzer -Path $Path -Recurse -Settings $settings -Severity $severityLevels

            if ($results) {
                # Group by severity
                $errors = $results | Where-Object Severity -EQ 'Error'
                $warnings = $results | Where-Object Severity -EQ 'Warning'
                $information = $results | Where-Object Severity -EQ 'Information'

                # Report errors
                if ($errors) {
                    Write-Host ""
                    Write-ValidationResult "$($errors.Count) Error(s) Found:" -Type "Error"
                    $errors | ForEach-Object {
                        Write-Host "  📁 $($_.ScriptName):$($_.Line) - $($_.RuleName)" -ForegroundColor Red
                        Write-Host "     $($_.Message)" -ForegroundColor DarkRed
                    }
                    $criticalIssues += $errors.Count
                }

                # Report warnings
                if ($warnings) {
                    Write-Host ""
                    Write-ValidationResult "$($warnings.Count) Warning(s) Found:" -Type "Warning"
                    if ($Detailed) {
                        $warnings | ForEach-Object {
                            Write-Host "  📁 $($_.ScriptName):$($_.Line) - $($_.RuleName)" -ForegroundColor Yellow
                            Write-Host "     $($_.Message)" -ForegroundColor DarkYellow
                        }
                    }
                    else {
                        $warnings | Group-Object RuleName | ForEach-Object {
                            Write-Host "  ⚠️  $($_.Name): $($_.Count) occurrence(s)" -ForegroundColor Yellow
                        }
                    }

                    if ($FailOnWarnings) {
                        $criticalIssues += $warnings.Count
                    }
                }

                # Report information (if detailed)
                if ($information -and $Detailed) {
                    Write-Host ""
                    Write-ValidationResult "$($information.Count) Information Message(s):" -Type "Info"
                    $information | Group-Object RuleName | ForEach-Object {
                        Write-Host "  ℹ️  $($_.Name): $($_.Count) occurrence(s)" -ForegroundColor Cyan
                    }
                }

                $totalIssues = $results.Count

                # Export results if requested
                if ($Export) {
                    $exportPath = "validation-results.json"
                    $results | ConvertTo-Json -Depth 3 | Out-File $exportPath -Encoding UTF8
                    Write-ValidationResult "Detailed results exported to: $exportPath" -Type "Info"

                    $summary = @{
                        Timestamp = Get-Date
                        TotalFiles = $psFiles.Count
                        TotalIssues = $totalIssues
                        Errors = $errors.Count
                        Warnings = $warnings.Count
                        Information = if ($information) { $information.Count } else { 0 }
                        TopRules = $results | Group-Object RuleName | Sort-Object Count -Descending | Select-Object -First 5 Name, Count
                    }
                    $summary | ConvertTo-Json -Depth 2 | Out-File "validation-summary.json" -Encoding UTF8
                    Write-ValidationResult "Summary exported to: validation-summary.json" -Type "Info"
                }
            }
            else {
                Write-ValidationResult "No PSScriptAnalyzer issues found!" -Type "Success"
            }
        }
        catch {
            Write-ValidationResult "PSScriptAnalyzer failed: $($_.Exception.Message)" -Type "Error"
            $criticalIssues++
        }
    }

    # Configuration validation (if not Quick mode)
    if (-not $Quick) {
        Write-ValidationHeader "Configuration File Validation"

        # Test JSON files (cross-platform filtering)
        $jsonFiles = Get-ChildItem -Path $Path -Include "*.json" -Recurse |
            Where-Object {
                $_.FullName -notmatch [regex]::Escape([System.IO.Path]::DirectorySeparatorChar + '.git' + [System.IO.Path]::DirectorySeparatorChar) -and
                $_.FullName -notmatch [regex]::Escape([System.IO.Path]::DirectorySeparatorChar + 'node_modules' + [System.IO.Path]::DirectorySeparatorChar)
            }

        foreach ($file in $jsonFiles) {
            try {
                $null = Get-Content $file.FullName | ConvertFrom-Json
                Write-Host "✓ $($file.Name) - Valid JSON" -ForegroundColor DarkGreen
            }
            catch {
                Write-ValidationResult "Invalid JSON in $($file.Name): $($_.Exception.Message)" -Type "Error"
                $criticalIssues++
            }
        }

        # Test PowerShell data files (cross-platform filtering)
        $psdFiles = Get-ChildItem -Path $Path -Include "*.psd1" -Recurse |
            Where-Object { $_.FullName -notmatch [regex]::Escape([System.IO.Path]::DirectorySeparatorChar + '.git' + [System.IO.Path]::DirectorySeparatorChar) }

        foreach ($file in $psdFiles) {
            try {
                $null = Import-PowerShellDataFile $file.FullName
                Write-Host "✓ $($file.Name) - Valid PowerShell data file" -ForegroundColor DarkGreen
            }
            catch {
                Write-ValidationResult "Invalid PowerShell data file $($file.Name): $($_.Exception.Message)" -Type "Error"
                $criticalIssues++
            }
        }
    }

    # Final results
    Write-ValidationHeader "Validation Results"

    $endTime = Get-Date
    $duration = $endTime - $startTime

    Write-Host "Validation completed in $($duration.TotalSeconds.ToString('F1')) seconds" -ForegroundColor Gray
    Write-Host "Files checked: $($psFiles.Count)" -ForegroundColor Gray

    if ($criticalIssues -eq 0) {
        Write-ValidationResult "🎉 All checks passed! Code is ready for commit." -Type "Success"

        if ($totalIssues -gt 0 -and -not $FailOnWarnings) {
            Write-ValidationResult "Note: $totalIssues non-critical issue(s) found (warnings/info)" -Type "Info"
        }

        exit 0
    }
    else {
        Write-ValidationResult "❌ $criticalIssues critical issue(s) must be fixed before committing" -Type "Error"

        Write-Host ""
        Write-Host "💡 Quick fixes:" -ForegroundColor Yellow
        Write-Host "  • Run 'Invoke-ScriptAnalyzer -Path . -Fix' to auto-fix some issues" -ForegroundColor Yellow
        Write-Host "  • Check CONTRIBUTING.md for common rule violations and fixes" -ForegroundColor Yellow
        Write-Host "  • Use 'Get-Help about_PSScriptAnalyzer' for more information" -ForegroundColor Yellow

        if ($syntaxErrors.Count -gt 0) {
            exit 2
        }
        elseif ($criticalIssues -gt 0) {
            exit 1
        }
    }
}
catch {
    Write-ValidationResult "Validation failed with error: $($_.Exception.Message)" -Type "Error"
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 4
}

#endregion
