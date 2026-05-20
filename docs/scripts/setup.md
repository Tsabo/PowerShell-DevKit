# Setup.ps1

The Setup.ps1 script is the primary installation tool that automates the complete setup of your PowerShell development environment.

## Overview

**Purpose:** Install and configure all components of the PowerShell DevKit

**Features:**

- ✅ Component-based installation
- ✅ Intelligent failure recovery
- ✅ Timeout protection
- ✅ Detailed logging
- ✅ Skip already-installed components
- ✅ Optional component filtering

## Basic Usage

### Standard Installation

```powershell
# Full installation (recommended)
.\Scripts\Setup.ps1
```

This will:

1. Check prerequisites (PowerShell 7+, winget)
2. Install core tools via winget
3. Install PowerShell modules
4. Deploy configuration files
5. Set up Yazi ecosystem
6. Install optional components
7. Validate installation

### As Administrator

```powershell
# Run PowerShell as Administrator, then:
.\Scripts\Setup.ps1
```

**Benefits:**

- All components install successfully
- No UAC prompts during installation
- Font installation works correctly

## Parameters

### -SkipOptional

Skip installation of optional components:

```powershell
.\Scripts\Setup.ps1 -SkipOptional
```

**Skipped components:**

- gsudo
- PowerColorLS
- Scoop
- resvg
- Yazi optional dependencies

### -FontName

Specify the Nerd Font to install:

```powershell
.\Scripts\Setup.ps1 -FontName "JetBrainsMono"
```

**Default:** CascadiaCode

**Available fonts:**

- CascadiaCode
- JetBrainsMono
- FiraCode
- Hack
- Meslo

### -EnableAdminShares

Windows-only opt-in setting to enable local administrative shares for local administrator accounts.

```powershell
.\Scripts\Setup.ps1 -EnableAdminShares
```

This sets the following registry value:

- `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\LocalAccountTokenFilterPolicy = 1`

Notes:

- Requires running PowerShell as Administrator.
- Off by default; only applied when this switch is provided.
- This component is optional and is skipped by `-SkipOptional`.

### -ShowDetails

View detailed failure information from previous setup runs:

```powershell
.\Scripts\Setup.ps1 -ShowDetails
```

**Example output:**

```
╔════════════════════════════════════════════════════════════╗
║                 SETUP FAILURE DETAILS                      ║
╚════════════════════════════════════════════════════════════╝

🔸 Yazi (winget)
   Last failure: 2025-11-02 10:30:15
   Operation: winget install sxyazi.yazi
   Admin Rights: False
   Exit Code: 1
   Error: Network timeout during download
   💡 Suggestion: Network issue. Check internet connection and try again
```

### -ClearLogs

Clear stored failure logs:

```powershell
.\Scripts\Setup.ps1 -ClearLogs
```

## Installation Process

### 1. Prerequisites Check

```
🔹 Checking prerequisites...
  ✓ PowerShell 7.4.1
  ✓ winget available
```

Validates:

- PowerShell 7+ is installed
- winget is available
- Internet connectivity (implicit)

### 2. Core Tools Installation

Installs via winget:

- oh-my-posh
- Yazi
- fzf
- zoxide
- Microsoft Edit

**Example:**

```
🔹 Installing oh-my-posh...
  → Checking if already installed...
  → Running winget (timeout: 60s)...
  ✓ oh-my-posh installed successfully
```

### 3. Font Installation

Installs CascadiaCode Nerd Font (or specified font):

```
🔹 Installing CascadiaCode Nerd Font...
  ✓ Font installed via oh-my-posh
```

### 4. PowerShell Modules

Installs from PSGallery:

- PSFzf
- Terminal-Icons
- F7History
- posh-git

**Example:**

```
🔹 Installing PowerShell modules...
  → Installing PSFzf...
  ✓ PSFzf installed
  → Installing Terminal-Icons...
  ✓ Terminal-Icons installed
```

### 5. Configuration Deployment

Deploys:

- PowerShell profile → `$PROFILE`
- Windows Terminal settings
- oh-my-posh themes

```
🔹 Deploying PowerShell profile...
  ✓ Profile deployed to: C:\Users\...\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

### 6. Yazi Ecosystem

Installs:

- Yazi configuration (git clone)
- Yazi plugins (via `ya pkg`)
- Yazi themes
- Optional dependencies

```
🔹 Setting up Yazi configuration...
  → Cloning yazi_config repository...
  ✓ Yazi configuration deployed

🔹 Installing Yazi plugins...
  → Installing git plugin...
  ✓ git plugin installed
  → Installing githead plugin (custom fork)...
  ✓ githead plugin installed
```

### 7. Optional Components

If not skipped:

- gsudo
- PowerColorLS
- Scoop + resvg
- Local Admin Shares Policy (only when `-EnableAdminShares` is used)

```
🔹 Installing optional components...
  → Installing gsudo...
  ✓ gsudo installed
  ⊘ Scoop installation skipped (user declined)
```

### 8. Validation

Runs basic validation:

```
🔹 Validating installation...
  ✓ All core components installed
  ⚠ 2 optional components skipped
```

## Idempotent Behavior

Setup.ps1 is idempotent - safe to run multiple times:

- Already-installed components are detected and skipped
- Configuration files are updated if changed
- Failed components can be retried

**Example:**

```
🔹 Installing Yazi...
  → Checking if already installed...
  ⊘ Yazi is already installed
```

## Timeout Protection

All operations have timeouts to prevent hangs:

| Operation | Timeout |
|-----------|---------|
| Package check | 15 seconds |
| Package installation | 60 seconds |
| Git clone | 30 seconds |

When timeout occurs:

```
  → Check timed out, proceeding with installation...
```

Or:

```
  ⚠ Installation timed out, skipping component
```

## Error Handling

### Non-Critical Errors

Component failures are logged but setup continues:

```
  ✗ Failed to install PowerColorLS
  → Continuing with next component...
```

Failures are logged to `Scripts/Logs/setup-details.json`

### Critical Errors

Some errors stop execution:

- PowerShell version < 7.0
- winget not available
- Invalid parameters

```
ERROR: PowerShell 7.0 or higher is required
Current version: 5.1
Please install PowerShell 7: https://aka.ms/powershell
```

## Post-Installation

### Reload Profile

```powershell
# Reload PowerShell profile
. $PROFILE
```

Or restart PowerShell.

### Verify Installation

```powershell
# Run validation script
.\Scripts\Test.ps1
```

### Configure Terminal Font

In Windows Terminal:

1. Open Settings (`Ctrl+,`)
2. Profiles → Defaults → Appearance
3. Set Font face to "CaskaydiaCove Nerd Font Mono"

## Troubleshooting

### View Failure Details

```powershell
.\Scripts\Setup.ps1 -ShowDetails
```

### Common Issues

#### Execution Policy Error

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### winget Not Found

Update Windows or install App Installer from Microsoft Store.

#### Network Timeouts

- Check internet connection
- Try again later
- Use `-ShowDetails` to see which components failed

#### Permission Errors

Run PowerShell as Administrator.

### Re-run After Failures

Simply re-run Setup.ps1:

```powershell
.\Scripts\Setup.ps1
```

Already-installed components will be skipped, and it will retry failed components.

## Advanced Usage

### Custom Installation Path

The script uses standard paths, but you can customize by editing environment variables:

```powershell
# Custom profile path (before running setup)
$env:PSModulePath = "C:\CustomPath\Modules;$env:PSModulePath"
```

### Selective Installation

To install only specific component types, modify Components.psm1 to mark others as optional, then run:

```powershell
.\Scripts\Setup.ps1 -SkipOptional
```

## See Also

- [Test.ps1 - Validation](test.md)
- [Update.ps1 - Updates](update.md)
- [Scripts Overview](overview.md)
- [Troubleshooting Guide](../troubleshooting.md)
