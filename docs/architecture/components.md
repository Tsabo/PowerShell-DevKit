# Component System

The PowerShell DevKit uses a centralized component definition system to ensure consistency and maintainability across all scripts.

## Components.psm1

The heart of the system is `Scripts/Components.psm1`, which exports a single function:

```powershell
Get-EnvironmentComponents
```

This function returns an array of component definitions that Setup.ps1, Test.ps1, and Update.ps1 all consume.

## Component Schema

### Base Structure

```powershell
@{
    Name = [string]           # Display name
    Type = [string]           # "winget" | "module" | "custom"
    IsOptional = [bool]       # Skip with -SkipOptional flag
    Properties = @{           # Type-specific properties
        # Varies by type
    }
    CustomInstaller = [scriptblock]  # Optional
    CustomValidator = [scriptblock]  # Optional
}
```

### Component Types

#### Winget Components

For applications installed via Windows Package Manager:

```powershell
@{
    Name = "Yazi"
    Type = "winget"
    IsOptional = $false
    Properties = @{
        PackageId = "sxyazi.yazi"
    }
}
```

**Properties:**

- `PackageId` - The winget package identifier

#### Module Components

For PowerShell modules from PSGallery:

```powershell
@{
    Name = "PSFzf"
    Type = "module"
    IsOptional = $false
    Properties = @{
        ModuleName = "PSFzf"
        MinimumVersion = "2.5.0"  # Optional
    }
}
```

**Properties:**

- `ModuleName` - The PowerShell Gallery module name
- `MinimumVersion` - Optional minimum version requirement

#### Custom Components

For components with custom installation/validation logic:

```powershell
@{
    Name = "Yazi Configuration"
    Type = "custom"
    IsOptional = $false
    Properties = @{
        ConfigRepo = "https://github.com/Tsabo/yazi_config.git"
        ConfigPath = "$env:APPDATA\yazi"
    }
    CustomInstaller = {
        param($Component)

        $configPath = $Component.Properties.ConfigPath
        if (Test-Path $configPath) {
            # Update existing
            Push-Location $configPath
            git pull
            Pop-Location
            return $true
        } else {
            # Clone new
            git clone $Component.Properties.ConfigRepo $configPath
            return $?
        }
    }
    CustomValidator = {
        param($Component)

        $configPath = $Component.Properties.ConfigPath
        $installed = Test-Path $configPath

        return @{
            IsInstalled = $installed
            Version = if ($installed) { "Git-managed" } else { $null }
        }
    }
}
```

**Properties:**

- Custom properties as needed by the component
- `CustomInstaller` - Script block for installation
- `CustomValidator` - Script block for validation

## Component Lifecycle

### Discovery

```powershell
# Scripts import and call the function
Import-Module (Join-Path $PSScriptRoot "Components.psm1") -Force
$components = Get-EnvironmentComponents
```

### Filtering

```powershell
# Setup.ps1 can skip optional components
if ($SkipOptional) {
    $components = $components | Where-Object { -not $_.IsOptional }
}
```

### Installation (Setup.ps1)

```powershell
foreach ($component in $components) {
    switch ($component.Type) {
        "winget" {
            Install-WingetPackage -PackageId $component.Properties.PackageId `
                                  -Name $component.Name
        }
        "module" {
            Install-PowerShellModule -ModuleName $component.Properties.ModuleName `
                                      -Name $component.Name
        }
        "custom" {
            $result = & $component.CustomInstaller $component
            if (-not $result) {
                Write-SetupLog -Component $component.Name -Type "custom" `
                              -ErrorMessage "Custom installer failed"
            }
        }
    }
}
```

### Validation (Test.ps1)

```powershell
foreach ($component in $components) {
    $result = Test-EnvironmentComponent -Component $component

    if ($result.IsInstalled) {
        Write-Installed -Name $component.Name -Version $result.Version
    } else {
        Write-Missing -Name $component.Name
    }
}
```

### Updates (Update.ps1)

```powershell
# Group by type for efficient batch updates
$wingetComponents = $components | Where-Object { $_.Type -eq "winget" }
$moduleComponents = $components | Where-Object { $_.Type -eq "module" }

# Update winget packages
foreach ($component in $wingetComponents) {
    Update-WingetPackage -PackageId $component.Properties.PackageId
}

# Update PowerShell modules
foreach ($component in $moduleComponents) {
    Update-Module -Name $component.Properties.ModuleName -Force
}

# Update custom components
$customComponents = $components | Where-Object { $_.Type -eq "custom" }
foreach ($component in $customComponents) {
    & $component.CustomInstaller $component
}
```

## Current Components

### Core Tools (Winget)

| Component | Package ID | Optional |
|-----------|-----------|----------|
| oh-my-posh | JanDeDobbeleer.OhMyPosh | No |
| Yazi | sxyazi.yazi | No |
| fzf | junegunn.fzf | No |
| zoxide | ajeetdsouza.zoxide | No |
| Microsoft Edit | Microsoft.Edit | No |
| gsudo | gerardog.gsudo | Yes |

### PowerShell Modules

| Component | Module Name | Optional |
|-----------|------------|----------|
| PSFzf | PSFzf | No |
| Terminal-Icons | Terminal-Icons | No |
| F7History | F7History | No |
| posh-git | posh-git | No |
| PowerColorLS | PowerColorLS | Yes |

### Custom Components

| Component | Description | Optional |
|-----------|-------------|----------|
| CascadiaCode Font | Nerd Font for icons | No |
| Yazi Configuration | Git-managed config | No |
| Yazi Plugins | git, githead plugins | No |
| Yazi Themes | flexoki-light, vscode-dark-plus | No |
| Yazi Optionals | FFmpeg, 7-Zip, jq, etc. | Yes |
| Scoop | Package manager | Yes |
| resvg | SVG rendering | Yes |
| PowerShell Profile | Main profile file | No |
| Windows Terminal | Settings deployment | No |

## Adding New Components

### Simple Winget Package

To add a new winget package:

1. Open `Scripts/Components.psm1`
2. Add to the component array:

```powershell
@{
    Name = "New Tool"
    Type = "winget"
    IsOptional = $false
    Properties = @{
        PackageId = "Publisher.NewTool"
    }
}
```

3. Component is now available in Setup, Test, and Update

### PowerShell Module

To add a new PowerShell module:

```powershell
@{
    Name = "New Module"
    Type = "module"
    IsOptional = $false
    Properties = @{
        ModuleName = "NewModule"
        MinimumVersion = "1.0.0"  # Optional
    }
}
```

### Complex Custom Component

For components requiring custom logic:

```powershell
@{
    Name = "Custom Integration"
    Type = "custom"
    IsOptional = $false
    Properties = @{
        Url = "https://example.com/download"
        InstallPath = "$env:LOCALAPPDATA\CustomTool"
    }
    CustomInstaller = {
        param($Component)

        try {
            # Download
            $url = $Component.Properties.Url
            $path = $Component.Properties.InstallPath

            Invoke-WebRequest -Uri $url -OutFile "$path\tool.exe"

            # Verify
            if (Test-Path "$path\tool.exe") {
                return $true
            }
            return $false
        }
        catch {
            Write-Error "Installation failed: $_"
            return $false
        }
    }
    CustomValidator = {
        param($Component)

        $path = $Component.Properties.InstallPath
        $exePath = "$path\tool.exe"

        if (Test-Path $exePath) {
            # Get version if available
            $version = & $exePath --version 2>$null
            return @{
                IsInstalled = $true
                Version = $version
            }
        }

        return @{
            IsInstalled = $false
            Version = $null
        }
    }
}
```

## Component Dependencies

Some components depend on others. This is handled through:

### Order of Installation

Components are installed in the order defined in `Components.psm1`. Place dependencies first:

```powershell
# Git must be installed before posh-git
@{
    Name = "Git"
    Type = "winget"
    Properties = @{ PackageId = "Git.Git" }
}

# posh-git depends on Git
@{
    Name = "posh-git"
    Type = "module"
    Properties = @{ ModuleName = "posh-git" }
}
```

### Conditional Installation

Check for dependencies in custom installers:

```powershell
CustomInstaller = {
    param($Component)

    # Check if prerequisite exists
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Warning "Git is required but not found"
        return $false
    }

    # Proceed with installation
    # ...
}
```

## Component Testing

Test components using `Test-EnvironmentComponent`:

```powershell
# Import module
Import-Module .\Scripts\Components.psm1 -Force

# Get components
$components = Get-EnvironmentComponents

# Test a specific component
$yaziComponent = $components | Where-Object { $_.Name -eq "Yazi" }
$result = Test-EnvironmentComponent -Component $yaziComponent

# Check result
if ($result.IsInstalled) {
    Write-Host "Yazi is installed: $($result.Version)"
} else {
    Write-Host "Yazi is not installed"
}
```

## Best Practices

### Naming Conventions

- Use clear, descriptive names
- Match official product names
- Include clarifying suffixes for similar components (e.g., "Yazi Configuration")

### Optional vs Required

Mark as optional if:

- Not essential for core functionality
- Requires additional prerequisites
- Large download size
- Platform-specific

### Error Handling

Custom installers should:

- Return `$true` on success, `$false` on failure
- Log errors appropriately
- Handle partial installations gracefully
- Clean up on failure

### Version Detection

Custom validators should:

- Return accurate version information when available
- Use "Git-managed" or similar for git-based configs
- Return `$null` if version cannot be determined
- Avoid expensive version checks (use caching if needed)

## See Also

- [Architecture Overview](overview.md)
- [Failure Recovery System](failure-recovery.md)
- [Testing Guide](../development/testing.md)
