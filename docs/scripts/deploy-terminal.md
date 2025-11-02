# Deploy-Terminal.ps1

Deploys Windows Terminal settings with automatic backup.

## Overview

**Purpose:** Configure Windows Terminal with DevKit settings

**Features:**

- ✅ Automatic backup of existing settings
- ✅ Font configuration
- ✅ Color scheme setup
- ✅ Safe rollback capability

## Basic Usage

```powershell
# Deploy with backup (recommended)
.\Scripts\Deploy-Terminal.ps1
```

## Parameters

### -NoBackup

Skip backup of existing settings:

```powershell
.\Scripts\Deploy-Terminal.ps1 -NoBackup
```

!!! warning
    Use with caution. Existing settings will be overwritten without backup.

## What Gets Configured

- **Font**: CaskaydiaCove Nerd Font Mono
- **Color Schemes**: Custom schemes
- **Window Settings**: Size, transparency
- **Default Shell**: PowerShell 7

## Manual Configuration

If you prefer to configure manually:

1. Open Windows Terminal Settings (`Ctrl+,`)
2. Profiles → Defaults → Appearance
3. Set Font face to "CaskaydiaCove Nerd Font Mono"
4. Save

## See Also

- [Windows Terminal Component](../components/terminal.md)
- [Setup.ps1](setup.md)
