# Custom Modules

Custom modules allow you to organize reusable PowerShell code in a structured way.

## Module Types

### IncludedModules (Bundled)

**Location:** `PowerShell/IncludedModules/`

**Purpose:** Modules shipped with the DevKit

**Examples:**

- `utilities.psm1` - General helper functions
- `build_functions.psm1` - Build automation functions

**Usage:**

- Version-controlled
- Shared across installations
- Updated with DevKit

### CustomModules (User-Created)

**Location:** `PowerShell/CustomModules/`

**Purpose:** Your personal modules

**Features:**

- Git-ignored (won't be committed)
- Auto-discovered and loaded
- Update-safe (never overwritten)

## Creating a Custom Module

### 1. Create Module File

```powershell
# Create new module
New-Item -Path "PowerShell\CustomModules\MyTools.psm1" -ItemType File

# Or copy template
Copy-Item "PowerShell\IncludedModules\example-module.psm1.template" `
          "PowerShell\CustomModules\MyTools.psm1"
```

### 2. Define Functions

```powershell
# PowerShell/CustomModules/MyTools.psm1

<#
.SYNOPSIS
    My custom PowerShell utilities
.DESCRIPTION
    Collection of helper functions for my workflow
#>

function Get-ProjectStatus {
    <#
    .SYNOPSIS
        Get status of all projects
    .DESCRIPTION
        Scans dev directory for git repositories and shows their status
    .EXAMPLE
        Get-ProjectStatus
    #>
    [CmdletBinding()]
    param(
        [string]$Path = "C:\Dev"
    )

    Get-ChildItem -Path $Path -Directory | ForEach-Object {
        if (Test-Path (Join-Path $_.FullName ".git")) {
            Write-Host "$($_.Name):" -ForegroundColor Cyan
            Push-Location $_.FullName
            git status -s
            Pop-Location
            Write-Host ""
        }
    }
}

function Start-DevEnvironment {
    <#
    .SYNOPSIS
        Start development environment
    .DESCRIPTION
        Opens common tools and navigates to project directory
    .EXAMPLE
        Start-DevEnvironment -Project "MyApp"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Project
    )

    $projectPath = "C:\Dev\$Project"

    if (Test-Path $projectPath) {
        Set-Location $projectPath
        code .
        Write-Host "Development environment started for $Project" -ForegroundColor Green
    } else {
        Write-Error "Project not found: $projectPath"
    }
}

# Export functions
Export-ModuleMember -Function Get-ProjectStatus, Start-DevEnvironment
```

### 3. Test Module

```powershell
# Import manually for testing
Import-Module .\PowerShell\CustomModules\MyTools.psm1 -Force

# Test functions
Get-ProjectStatus
Start-DevEnvironment -Project "TestApp"
```

### 4. Reload Profile

Module is now auto-loaded on every PowerShell start:

```powershell
# Reload to test auto-loading
. $PROFILE

# Functions should be available
Get-ProjectStatus
```

## Module Structure

### Basic Template

```powershell
<#
.SYNOPSIS
    Module description
#>

# Helper functions (internal, not exported)
function Get-InternalHelper {
    param([string]$Value)
    # Helper code
}

# Public functions
function Get-MyData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Source
    )

    # Function code
}

function Set-MyData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Value
    )

    # Function code
}

# Export only public functions
Export-ModuleMember -Function Get-MyData, Set-MyData
```

### Advanced Template

```powershell
<#
.SYNOPSIS
    Advanced module with variables and aliases
#>

# Module variables
$script:ModuleConfig = @{
    DefaultPath = "C:\Data"
    Timeout = 30
}

# Functions
function Get-ModuleConfig {
    [CmdletBinding()]
    param()

    return $script:ModuleConfig
}

function Set-ModuleConfig {
    [CmdletBinding()]
    param(
        [string]$DefaultPath,
        [int]$Timeout
    )

    if ($DefaultPath) { $script:ModuleConfig.DefaultPath = $DefaultPath }
    if ($Timeout) { $script:ModuleConfig.Timeout = $Timeout }
}

function Invoke-MyOperation {
    [CmdletBinding()]
    param([string]$Operation)

    # Use module config
    $path = $script:ModuleConfig.DefaultPath
    # Operation code
}

# Aliases
New-Alias -Name gmc -Value Get-ModuleConfig
New-Alias -Name smc -Value Set-ModuleConfig

# Export
Export-ModuleMember -Function Get-ModuleConfig, Set-ModuleConfig, Invoke-MyOperation
Export-ModuleMember -Alias gmc, smc
```

## Best Practices

### 1. Comment-Based Help

Always include help for your functions:

```powershell
<#
.SYNOPSIS
    Brief description
.DESCRIPTION
    Detailed description
.PARAMETER Name
    Parameter description
.EXAMPLE
    Example-Function -Name "Test"
    Description of what this example does
.NOTES
    Additional information
#>
```

### 2. Parameter Validation

Use parameter attributes:

```powershell
function Get-Data {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Source,

        [ValidateRange(1, 100)]
        [int]$Count = 10,

        [ValidateSet("Fast", "Normal", "Slow")]
        [string]$Speed = "Normal"
    )
}
```

### 3. Error Handling

Use try/catch and appropriate error actions:

```powershell
function Get-SafeData {
    [CmdletBinding()]
    param([string]$Path)

    try {
        if (-not (Test-Path $Path)) {
            throw "Path not found: $Path"
        }

        $data = Get-Content $Path -ErrorAction Stop
        return $data
    }
    catch {
        Write-Error "Failed to get data: $_"
        return $null
    }
}
```

### 4. Write Output

Use Write-Verbose, Write-Debug, etc.:

```powershell
function Process-Data {
    [CmdletBinding()]
    param([string]$Data)

    Write-Verbose "Processing data..."
    Write-Debug "Data length: $($Data.Length)"

    # Processing...

    Write-Verbose "Processing complete"
}
```

## Examples

### Development Workflow Module

```powershell
# PowerShell/CustomModules/DevWorkflow.psm1

function Start-WorkSession {
    [CmdletBinding()]
    param([string]$Project)

    # Navigate to project
    Set-Location "C:\Dev\$Project"

    # Open VS Code
    code .

    # Start Docker if needed
    if (Test-Path "docker-compose.yml") {
        Write-Host "Starting Docker containers..." -ForegroundColor Cyan
        docker-compose up -d
    }

    # Open browser
    Start-Process "http://localhost:3000"

    Write-Host "Work session started for $Project" -ForegroundColor Green
}

function Stop-WorkSession {
    [CmdletBinding()]
    param()

    # Stop Docker
    if (Test-Path "docker-compose.yml") {
        Write-Host "Stopping Docker containers..." -ForegroundColor Cyan
        docker-compose down
    }

    Write-Host "Work session ended" -ForegroundColor Green
}

Export-ModuleMember -Function Start-WorkSession, Stop-WorkSession
```

### Git Utilities Module

```powershell
# PowerShell/CustomModules/GitUtils.psm1

function Get-AllGitStatus {
    [CmdletBinding()]
    param([string]$Path = (Get-Location))

    Get-ChildItem -Path $Path -Directory | ForEach-Object {
        if (Test-Path (Join-Path $_.FullName ".git")) {
            Write-Host "`n$($_.Name):" -ForegroundColor Yellow
            Push-Location $_.FullName
            git status -s
            Pop-Location
        }
    }
}

function Update-AllGitRepos {
    [CmdletBinding()]
    param([string]$Path = (Get-Location))

    Get-ChildItem -Path $Path -Directory | ForEach-Object {
        if (Test-Path (Join-Path $_.FullName ".git")) {
            Write-Host "`nUpdating $($_.Name)..." -ForegroundColor Cyan
            Push-Location $_.FullName
            git pull
            Pop-Location
        }
    }
}

Export-ModuleMember -Function Get-AllGitStatus, Update-AllGitRepos
```

## Troubleshooting

### Module Not Loading

Check that:

- File has `.psm1` extension
- File is in `PowerShell/CustomModules/`
- Profile was reloaded: `. $PROFILE`
- No syntax errors: `Import-Module .\path\to\module.psm1`

### Functions Not Available

Ensure you exported them:

```powershell
Export-ModuleMember -Function MyFunction
```

### Conflicts with Other Modules

Use module-qualified names:

```powershell
# Call function from specific module
MyModule\Get-Data
```

## See Also

- [Customization Guide](customization.md)
- [Custom Profile](custom-profile.md)
- [PowerShell Profile](../components/powershell.md)
