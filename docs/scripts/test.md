# Test.ps1

The Test.ps1 script validates your PowerShell development environment by checking all installed components and their configurations.

## Overview

**Purpose:** Comprehensive environment validation

**Features:**

- ✅ Check all component installations
- ✅ Report component versions
- ✅ Validate configurations
- ✅ Categorized output (Winget, Modules, Custom)
- ✅ Summary statistics

## Basic Usage

```powershell
# Run full environment validation
.\Scripts\Test.ps1
```

## Example Output

```
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║     PowerShell Environment Validation                      ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

═══ PowerShell ═══
  ✓ PowerShell (7.4.1)

═══ Winget Packages ═══
  ✓ oh-my-posh (19.14.2)
  ✓ Yazi (0.2.4)
  ✓ fzf (0.44.1)
  ✓ zoxide (3.8.0)
  ✓ Microsoft Edit (1.0.0)
  ⊘ gsudo (optional - not installed)

═══ PowerShell Modules ═══
  ✓ PSFzf (2.5.22)
  ✓ Terminal-Icons (0.11.0)
  ✓ F7History (1.0.0)
  ✓ posh-git (1.1.0)
  ⊘ PowerColorLS (optional - not installed)

═══ Configuration Components ═══
  ✓ Yazi Configuration (Git-managed)
  ✓ PowerShell Profile (Deployed)
  ✓ Windows Terminal (Configured)
    ⚠ CaskaydiaCove Nerd Font not set as default

╔════════════════════════════════════════════════════════════╗
║                       SUMMARY                              ║
╚════════════════════════════════════════════════════════════╝

Required Components: 14 / 14 installed
Optional Components: Included in total count
Total: 14 / 16 installed

🎉 All required components are installed!
Your PowerShell environment is ready to go!
```

## What Gets Checked

### Winget Packages

- Installation status
- Installed version
- Availability in PATH

### PowerShell Modules

- Module availability
- Module version
- Import capability

### Custom Components

- Yazi configuration presence
- PowerShell profile deployment
- Windows Terminal settings
- Font configuration

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All required components installed |
| 1 | One or more required components missing |

## Status Indicators

| Symbol | Meaning | Color |
|--------|---------|-------|
| ✓ | Installed | Green |
| ✗ | Missing (required) | Red |
| ⊘ | Not installed (optional) | Yellow |
| ⚠ | Installed with issues | Yellow |

## Using Test Results

### All Components Installed

```
🎉 All required components are installed!
Your PowerShell environment is ready to go!
```

You're ready to use all features.

### Missing Components

```
⚠️  2 component(s) missing
Run the setup script to install missing components:
  .\Setup.ps1
```

Run Setup.ps1 to install missing components.

### Configuration Issues

If you see warnings:

```
  ✓ Windows Terminal (Configured)
    ⚠ CaskaydiaCove Nerd Font not set as default
```

Follow the specific guidance provided.

## Automation

### CI/CD Integration

```powershell
# In CI pipeline
.\Scripts\Test.ps1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Environment validation failed"
    exit 1
}
```

### Pre-Work Validation

```powershell
# Add to your workflow
function Start-Work {
    .\Scripts\Test.ps1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Environment validated. Starting work..."
    } else {
        Write-Host "Please run Setup.ps1 first"
    }
}
```

## See Also

- [Setup.ps1 - Installation](setup.md)
- [Update.ps1 - Updates](update.md)
- [Troubleshooting](../troubleshooting.md)
