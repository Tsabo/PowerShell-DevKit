# Update.ps1

The Update.ps1 script updates all components across multiple package managers and sources.

## Overview

**Purpose:** Unified multi-source package updates

**Features:**

- ✅ Update winget packages
- ✅ Update PowerShell modules
- ✅ Update Scoop packages (if installed)
- ✅ Update Yazi plugins and themes
- ✅ Sync git-managed configurations
- ✅ Intelligent failure recovery

## Basic Usage

### Update Everything

```powershell
# Recommended: Update all components
.\Scripts\Update.ps1
```

This updates:

- All winget packages
- All PowerShell modules
- Scoop packages (if installed)
- Yazi plugins and themes
- Yazi configuration repository

## Parameters

### -WingetOnly

Update only winget packages:

```powershell
.\Scripts\Update.ps1 -WingetOnly
```

### -ModulesOnly

Update only PowerShell modules:

```powershell
.\Scripts\Update.ps1 -ModulesOnly
```

### -ShowDetails

View detailed failure information:

```powershell
.\Scripts\Update.ps1 -ShowDetails
```

### -ClearLogs

Clear stored failure logs:

```powershell
.\Scripts\Update.ps1 -ClearLogs
```

## Update Process

### 1. Winget Packages

Updates all winget-installed tools:

```
🔹 Updating winget packages...
  → Updating oh-my-posh...
  ✓ oh-my-posh updated to 19.14.2
  → Updating Yazi...
  ⊘ Yazi already at latest version (0.2.4)
```

### 2. PowerShell Modules

Updates all PSGallery modules:

```
🔹 Updating PowerShell modules...
  → Updating PSFzf...
  ✓ PSFzf updated to 2.5.22
  → Updating Terminal-Icons...
  ✓ Terminal-Icons updated
```

### 3. Scoop Packages

If Scoop is installed:

```
🔹 Updating Scoop packages...
  → Running scoop update...
  ✓ Scoop packages updated
```

### 4. Yazi Ecosystem

Updates Yazi components:

```
🔹 Updating Yazi ecosystem...
  → Updating Yazi plugins...
  ✓ Plugins updated via ya pkg
  → Syncing configuration repository...
  ✓ Configuration synchronized
```

## Update Sources

| Source | Components | Command |
|--------|-----------|---------|
| Winget | oh-my-posh, Yazi, fzf, zoxide, etc. | `winget upgrade` |
| PSGallery | PSFzf, Terminal-Icons, posh-git, etc. | `Update-Module` |
| Scoop | resvg, optional tools | `scoop update` |
| Yazi pkg | Plugins, themes | `ya pkg update` |
| Git | Yazi config, DevKit | `git pull` |

## Best Practices

### Regular Updates

Recommended frequency:

- **Weekly:** Run Update.ps1
- **Monthly:** Review `-ShowDetails` for issues
- **After announcements:** When new features are released

### Update Workflow

```powershell
# 1. Update components
.\Scripts\Update.ps1

# 2. If failures occurred, check details
.\Scripts\Update.ps1 -ShowDetails

# 3. Fix issues based on suggestions

# 4. Re-run update
.\Scripts\Update.ps1

# 5. Validate environment
.\Scripts\Test.ps1

# 6. Restart PowerShell
exit
```

## Troubleshooting

### View Failures

```powershell
.\Scripts\Update.ps1 -ShowDetails
```

### Common Issues

#### Module Locked

**Error:** "Module is in use"

**Solution:**

```powershell
# Close all PowerShell windows
# Reopen and run update
.\Scripts\Update.ps1
```

#### Network Timeout

**Error:** "Download timeout"

**Solution:**

- Check internet connection
- Try again later
- Check `-ShowDetails` for specific component

#### Git Conflicts

**Error:** "Local changes would be overwritten"

**Solution:**

```powershell
# Stash changes
cd $env:APPDATA\yazi
git stash
git pull
git stash pop
```

## Selective Updates

### Update Specific Module

```powershell
Update-Module -Name PSFzf -Force
```

### Update Specific Package

```powershell
winget upgrade --id sxyazi.yazi
```

## See Also

- [Setup.ps1 - Installation](setup.md)
- [Test.ps1 - Validation](test.md)
- [Troubleshooting](../troubleshooting.md)
