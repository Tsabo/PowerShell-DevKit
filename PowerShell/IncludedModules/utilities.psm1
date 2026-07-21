function y {
    <#
    .SYNOPSIS
    Launches Yazi and automatically changes the shell's working directory based on Yazi's output.

    .DESCRIPTION
    The y function is a convenience wrapper around the Yazi terminal file manager.
    It creates a temporary file and passes its path to Yazi via the --cwd-file option,
    along with the current PowerShell directory so Yazi opens there even on platforms
    where the new process would not otherwise inherit it (e.g. macOS/Linux).
    When Yazi exits, it writes the desired working directory to that file.

    The function reads the directory from the temporary file and, if it is not empty
    and differs from the current working directory, uses the `z` command to jump to
    that location. Finally, the temporary file is removed.

    This provides seamless directory navigation when using Yazi inside PowerShell.

    .PARAMETER args
    Any arguments passed to Yazi. These are forwarded directly to the `yazi` command.

    .EXAMPLE
    y
    Launches Yazi and changes the working directory after exit if Yazi requests it.

    .EXAMPLE
    y --chooser
    Runs Yazi with additional arguments and updates the working directory accordingly.
    #>

    $tmp = (New-TemporaryFile).FullName
    yazi $PWD.Path @args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        z $cwd
    }
    Remove-Item -Path $tmp
}

function Clean-Solution {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]
    param(
        [Parameter()]
        [switch]$DryRun,

        [Parameter()]
        [int]$Depth = [int]::MaxValue,

        [Parameter()]
        [string[]]$Include = @('bin', 'obj'),

        [Parameter()]
        [switch]$VerboseOutput
    )

    <#
    .SYNOPSIS
    Cleans .NET build output directories (bin and obj) with safety, flexibility, and optional dry-run support.

    .DESCRIPTION
    The Clean function recursively removes build output directories such as 'bin' and 'obj'
    from the current directory tree. It improves on simple deletion by adding:

    - SupportsShouldProcess for safe deletion with -Confirm and -WhatIf
    - Optional -DryRun mode to preview deletions
    - Optional -Depth limit to restrict recursion
    - Customizable -Include list for additional directory names
    - Verbose output for detailed logging
    - Directory-only matching to avoid accidental file deletion

    .PARAMETER DryRun
    Shows which directories would be removed without actually deleting them.

    .PARAMETER Depth
    Limits recursion depth relative to the current directory. Default is unlimited.

    .PARAMETER Include
    Specifies which directory names to remove. Defaults to 'bin' and 'obj'.

    .PARAMETER VerboseOutput
    Displays detailed information about found and removed directories.

    .EXAMPLE
    Clean
    Removes all bin and obj directories under the current directory.

    .EXAMPLE
    Clean -DryRun
    Shows which directories would be removed without deleting anything.

    .EXAMPLE
    Clean -Depth 2
    Removes bin/obj directories only within two levels of the current directory.

    .EXAMPLE
    Clean -Include @('bin', 'obj', 'out')
    Removes bin, obj, and out directories.
    #>

    # Build search parameters
    $searchParams = @{
        Path = '.'
        Directory = $true
        Recurse = $true
        Force = $true
    }

    # Find matching directories
    $targets = Get-ChildItem @searchParams |
        Where-Object {
            $Include -contains $_.Name -and
            $_.FullName.Split([IO.Path]::DirectorySeparatorChar).Count -le ($PWD.Path.Split([IO.Path]::DirectorySeparatorChar).Count + $Depth)
        }

    if (-not $targets) {
        Write-Verbose "No matching directories found."
        return
    }

    foreach ($dir in $targets) {
        if ($VerboseOutput) {
            Write-Host "Found: $($dir.FullName)" -ForegroundColor Cyan
        }

        if ($DryRun) {
            Write-Host "[DryRun] Would remove: $($dir.FullName)" -ForegroundColor Yellow
            continue
        }

        if ($PSCmdlet.ShouldProcess($dir.FullName, "Remove directory")) {
            try {
                Remove-Item -LiteralPath $dir.FullName -Recurse -Force -ErrorAction Stop
                if ($VerboseOutput) {
                    Write-Host "Removed: $($dir.FullName)" -ForegroundColor Green
                }
            }
            catch {
                Write-Warning "Failed to remove $($dir.FullName): $_"
            }
        }
    }
}

function Open-Solution {
    param([string]$solution = $null)

    <#
    .SYNOPSIS
    Opens a Visual Studio solution using the best available Visual Studio installation.

    .DESCRIPTION
    The Open-Solution function locates and opens a .sln or .slnx file in Visual Studio.
    If a solution path is provided, that file is used. If not, the function searches
    recursively for the first solution file, excluding those inside .vs directories.

    The function attempts to locate Visual Studio using vswhere.exe, preferring the
    latest installation and allowing prerelease versions. It explicitly filters for
    actual Visual Studio SKUs (Enterprise, Professional, Community). If vswhere is
    not available or no installation is found, the function falls back to any
    devenv.exe available on the PATH.

    If no solution file is found or no Visual Studio installation is available,
    a descriptive message is displayed.

    .PARAMETER solution
    Optional path to a specific .sln or .slnx file. If omitted, the function searches
    the current directory tree for the first matching solution file.

    .EXAMPLE
    Open-Solution
    Searches for the first .sln or .slnx file in the current directory tree and opens
    it in the latest installed Visual Studio instance.

    .EXAMPLE
    Open-Solution -solution "src/MyApp/MyApp.sln"
    Opens the specified solution file in Visual Studio.

    .EXAMPLE
    "project.slnx" | Open-Solution
    Uses pipeline input to open the specified solution file.
    #>

    # Support both .sln and .slnx formats
    if ([string]::IsNullOrEmpty($solution)) {
        $sln = Get-ChildItem -Recurse -Include "*.sln", "*.slnx" |
            Where-Object { $_.FullName -notmatch '\\\.vs\\' } |
            Select-Object -First 1
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

    <#
    .SYNOPSIS
    Updates the last write time of a file or creates it if it does not exist.

    .DESCRIPTION
    The Touch function mimics the behavior of the Unix 'touch' command.
    If the specified file exists, its LastWriteTime property is updated to the current date and time.
    If the file does not exist, an empty file is created at the specified path.

    .PARAMETER Path
    The full path to the file that should be created or updated.

    .EXAMPLE
    Touch -Path "C:\Temp\example.txt"
    Creates the file C:\Temp\example.txt if it does not exist, or updates its last write time if it does.

    .EXAMPLE
    "report.log" | Touch
    Uses pipeline input to update or create the file named report.log in the current directory.
    #>

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

function grep {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Pattern,

        [Parameter(ValueFromPipeline = $true)]
        [object]$InputObject,

        [switch]$i,
        [switch]$v
    )

    <#
    .SYNOPSIS
    Emulates basic Linux 'grep' behavior in PowerShell pipelines.

    .DESCRIPTION
    The `grep` function provides a lightweight text-filtering mechanism similar to
    the GNU grep command. It is designed for use in PowerShell pipelines and works
    by wrapping `Select-String` while forcing plain-text output.

    PowerShell normally passes objects through the pipeline, but Linux grep expects
    raw text. This function bridges that gap by extracting only the matched lines
    and writing them as strings.

    It supports:
    - Basic pattern matching
    - Case-insensitive matching (-i)
    - Inverted matching (-v)

    The function accepts pipeline input and processes each incoming object as text.

    .PARAMETER Pattern
    The text or regular expression pattern to search for. This parameter is
    mandatory and corresponds to the first positional argument in traditional grep.

    .PARAMETER i
    Enables case-insensitive matching. Equivalent to `grep -i` in Linux.

    .PARAMETER v
    Inverts the match, returning only lines that *do not* match the pattern.
    Equivalent to `grep -v` in Linux.

    .INPUTS
    System.Object
    Any object passed through the pipeline. Objects are converted to text before
    pattern matching.

    .OUTPUTS
    System.String
    Lines of text that match (or do not match, when using -v) the specified pattern.

    .EXAMPLE
    Get-Content log.txt | grep error
    Searches for lines containing "error" in log.txt.

    .EXAMPLE
    ps | grep powershell
    Filters the process list to only lines containing "powershell".

    .EXAMPLE
    Get-Content log.txt | grep -i warning
    Case-insensitive search for "warning".

    .EXAMPLE
    Get-Content log.txt | grep -v debug
    Returns all lines that do NOT contain "debug".
    #>

    begin {
        $matchParams = @{ Pattern = $Pattern }
        if ($i) {
            $matchParams['CaseSensitive'] = $false
        }
        $collected = @()
    }

    process {
        $collected += $InputObject
    }

    end {
        # Format the WHOLE collection at once, just like the console does,
        # then split into individual text lines.
        $lines = $collected | Out-String -Stream

        foreach ($line in $lines) {
            if ($v) {
                if ($line -notmatch $Pattern) {
                    $line
                }
            }
            else {
                if ($line | Select-String @matchParams) {
                    $line
                }
            }
        }
    }
}
