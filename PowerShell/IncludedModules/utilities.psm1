function clean {
    Get-ChildItem -Path . -Include bin, obj -Recurse -Force |
        ForEach-Object { Remove-Item $_.FullName -Recurse -Force }
}

function y {
    $tmp = (New-TemporaryFile).FullName
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        z $cwd
    }
    Remove-Item -Path $tmp
}

function Open-Solution {
    param([string]$solution = $null)

    # Support both .sln and .slnx formats
    if ([string]::IsNullOrEmpty($solution)) {
        $sln = Get-ChildItem -Include "*.sln", "*.slnx" | Select-Object -First 1
    }
    else {
        $sln = Get-ChildItem $solution | Select-Object -First 1
    }
    if ($sln) {
        # Use vswhere to find the latest Visual Studio installation
        $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

        if (Test-Path $vswhere) {
            # Find the latest VS installation, preferring Preview releases
            # Explicitly filter for Visual Studio products (not SQL Server Management Studio, etc.)
            $vsInstall = & $vswhere -latest -prerelease -products Microsoft.VisualStudio.Product.Enterprise Microsoft.VisualStudio.Product.Professional Microsoft.VisualStudio.Product.Community -property installationPath

            if ($vsInstall) {
                $devenv = Join-Path $vsInstall "Common7\IDE\devenv.exe"
                if (Test-Path $devenv) {
                    & $devenv $sln.FullName
                    return
                }
            }
        }

        # Fallback: try to find devenv.exe in PATH
        $devenvInPath = Get-Command devenv.exe -ErrorAction SilentlyContinue
        if ($devenvInPath) {
            & $devenvInPath.Source $sln.FullName
        }
        else {
            Write-Host "No Visual Studio installation found." -ForegroundColor Red
        }
    }
    else {
        Write-Host "No solution file found." -ForegroundColor Yellow
    }
}

function Touch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        # Create the file if it doesn't exist
        New-Item -ItemType File -Path $Path | Out-Null
    }
    else {
        # Update the last write time if it exists
        (Get-Item $Path).LastWriteTime = Get-Date
    }
}

function Convert-ISO8601ToLocalTime {
    [CmdletBinding()]
    [Alias("Convert-JsonDateTime")]
    param (
        [Parameter(Mandatory = $true)]
        [string]$isoTimestamp
    )

    <#
    .SYNOPSIS
    Converts an ISO 8601 UTC timestamp string to local time.

    .DESCRIPTION
    This function takes a UTC timestamp in ISO 8601 format (e.g., "2025-10-27T21:05:31.1564459Z")
    and converts it to the local time based on the system's time zone.

    .PARAMETER isoTimestamp
    The ISO 8601 formatted UTC timestamp string to convert.

    .EXAMPLE
    Convert-ISO8601ToLocalTime -isoTimestamp "2025-10-27T21:05:31.1564459Z"

    .EXAMPLE
    Convert-JsonDateTime "2025-10-27T21:05:31.1564459Z"
    #>

    try {
        $utcTime = [DateTime]::Parse($isoTimestamp)
        $localTime = $utcTime.ToLocalTime()

        $formattedTimes = @{
            "Short Date" = $localTime.ToString("MM/dd/yyyy")
            "Long Date" = $localTime.ToString("dddd, MMMM dd, yyyy")
            "Short Time" = $localTime.ToString("hh:mm tt")
            "Long Time" = $localTime.ToString("hh:mm:ss tt")
            "Full DateTime" = $localTime.ToString("MM/dd/yyyy hh:mm:ss tt")
            "Sortable DateTime" = $localTime.ToString("yyyy-MM-dd HH:mm:ss")
        }

        return $formattedTimes

    }
    catch {
        Write-Error "Invalid timestamp format: $isoTimestamp"
    }
}
