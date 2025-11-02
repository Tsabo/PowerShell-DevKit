# PowerShell Profile

The PowerShell profile is the heart of your customized shell experience, loading modules, functions, and configurations on startup.

## Overview

**Location:** Deployed to `$PROFILE` (typically `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`)

**Source:** `PowerShell/Microsoft.PowerShell_profile.ps1`

**Features:**

- Deferred module loading for fast startup
- Auto-discovery of custom modules
- oh-my-posh initialization
- Argument completers
- Custom functions
- UTF-8 encoding

## Profile Structure

### 1. Performance Optimizations

```powershell
# Deferred module loading
Register-EngineEvent PowerShell.OnIdle -Action {
    # Load modules after shell is ready
}
```

Modules load in the background after PowerShell starts, ensuring fast startup times.

### 2. oh-my-posh Initialization

```powershell
oh-my-posh init pwsh --config "path\to\theme.omp.json" | Invoke-Expression
```

Loads your custom prompt theme.

### 3. Module Imports

**Deferred loading:**

- PSFzf
- Terminal-Icons
- posh-git
- F7History

**Immediate loading:**

- Custom modules from `IncludedModules/`
- Custom modules from `CustomModules/` (auto-discovered)

### 4. Custom Functions

#### `y` Function

Launch Yazi with directory change capability:

```powershell
function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath $cwd
    }
    Remove-Item -Path $tmp
}
```

#### `clean` Function

Remove bin/obj directories recursively:

```powershell
function clean {
    Get-ChildItem -Include bin,obj -Recurse -Directory |
        Remove-Item -Recurse -Force
}
```

#### `Open-Solution` Function

Open Visual Studio solution files:

```powershell
function Open-Solution {
    param([string]$SolutionPath)
    # Opens .sln in Visual Studio
}
```

## Custom Modules

### IncludedModules (Bundled)

Located in `PowerShell/IncludedModules/`:

- `utilities.psm1` - General helper functions
- `build_functions.psm1` - Build-related utilities

**Usage:**

```powershell
# These are automatically loaded by the profile
# Functions are immediately available
```

### CustomModules (User-Added)

Located in `PowerShell/CustomModules/`:

**Auto-discovery:** Any `.psm1` file in this directory is automatically imported.

**Example:**

```powershell
# PowerShell/CustomModules/my-tools.psm1

function Get-MyTool {
    [CmdletBinding()]
    param([string]$Name)

    Write-Host "Running tool: $Name"
}

Export-ModuleMember -Function Get-MyTool
```

This function is automatically available in new PowerShell sessions.

## Customization

### Using CustomProfile.ps1

For customizations that shouldn't be in version control:

```powershell
# Create from template
Copy-Item "$HOME\Documents\PowerShell\CustomProfile.ps1.template" `
          "$HOME\Documents\PowerShell\CustomProfile.ps1"

# Edit
code "$HOME\Documents\PowerShell\CustomProfile.ps1"
```

**What to add:**

- Personal aliases
- Environment variables
- Additional module imports
- Company-specific configurations

**Example CustomProfile.ps1:**

```powershell
# Personal aliases
Set-Alias -Name g -Value git
Set-Alias -Name v -Value vim

# Environment variables
$env:MY_VAR = "value"

# Additional modules
Import-Module MyCompanyModule

# Custom functions
function Start-MyWorkflow {
    # Your workflow
}
```

This file is git-ignored and won't be overwritten by updates.

## Argument Completers

The profile registers completers for:

- **winget** - Package names and commands
- **dotnet** - .NET CLI commands
- **git** - Git commands (via posh-git)

## Encoding

UTF-8 encoding is set by default:

```powershell
[console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
```

This ensures proper handling of Unicode characters.

## zoxide Integration

Smart directory navigation:

```powershell
Invoke-Expression (& { (zoxide init powershell | Out-String) })
```

Enables the `z` command for jumping to frequently-used directories.

## PSReadLine Configuration

Enhanced command-line editing:

- **Predictive IntelliSense**
- **History-based suggestions**
- **Syntax highlighting**
- **Custom key bindings**

## Reloading Profile

After making changes:

```powershell
# Reload profile
. $PROFILE
```

Or restart PowerShell.

## See Also

- [Custom Profile Guide](../configuration/custom-profile.md)
- [Custom Modules Guide](../configuration/custom-modules.md)
- [oh-my-posh Documentation](oh-my-posh.md)
