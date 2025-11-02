# Scripts Overview

PowerShell DevKit includes four main orchestrator scripts that handle different lifecycle phases of your development environment.

## Main Scripts

### [Setup.ps1](setup.md)

**Purpose:** Initial installation and configuration

Automates the complete setup of your PowerShell development environment, including:

- Installing all required tools via winget
- Installing PowerShell modules from PSGallery
- Deploying configuration files
- Setting up Yazi ecosystem
- Installing optional components

**When to use:**

- First-time installation
- After cloning the repository
- To install missing components
- To update configuration files

[Learn more →](setup.md)

### [Test.ps1](test.md)

**Purpose:** Environment validation

Validates your PowerShell environment by checking:

- All installed components and their versions
- Configuration file deployment
- Module availability
- Font configuration

**When to use:**

- After running Setup.ps1
- To verify environment health
- Before starting development work
- When troubleshooting issues

[Learn more →](test.md)

### [Update.ps1](update.md)

**Purpose:** Multi-source package updates

Updates all components across multiple package managers:

- Winget packages
- PowerShell modules
- Scoop packages (if installed)
- Yazi plugins and themes
- Git-managed configurations

**When to use:**

- Weekly or monthly maintenance
- To get latest versions of tools
- After upstream updates to Yazi config
- When new features are announced

[Learn more →](update.md)

### [Deploy-Terminal.ps1](deploy-terminal.md)

**Purpose:** Windows Terminal configuration deployment

Deploys Windows Terminal settings with automatic backup:

- Copies custom settings.json
- Configures font settings
- Sets up color schemes
- Manages backups

**When to use:**

- After modifying terminal settings
- To restore terminal configuration
- When setting up new machine

[Learn more →](deploy-terminal.md)

## Supporting Scripts

### Validate-Code.ps1

**Purpose:** Code quality validation

Runs PSScriptAnalyzer on all PowerShell files to ensure code quality and consistency.

**Usage:**

```powershell
# Full validation
.\Scripts\Validate-Code.ps1

# Quick syntax check
.\Scripts\Validate-Code.ps1 -Quick

# Strict mode (warnings as errors)
.\Scripts\Validate-Code.ps1 -FailOnWarnings
```

See [Developer Reference](../development/developer-reference.md) for details.

## Script Architecture

All orchestrator scripts share a common architecture:

```
┌─────────────────────────────────────┐
│     Orchestrator Script             │
│  (Setup, Test, Update, Deploy)      │
└──────────────┬──────────────────────┘
               │
               ├─ Import Components.psm1
               │
               ├─ Parse Parameters
               │
               ├─ Validate Prerequisites
               │
               ├─ Process Components
               │  ├─ Setup: Install
               │  ├─ Test: Validate
               │  └─ Update: Upgrade
               │
               ├─ Log Failures (if any)
               │
               └─ Display Summary
```

### Shared Components

All scripts use `Components.psm1` for:

- Component definitions
- Validation logic
- Consistent behavior

### Common Patterns

#### Color Output

All scripts use consistent color coding:

- 🔹 **Cyan** - Section headers
- ✓ **Green** - Success messages
- ⚠️ **Yellow** - Warnings and skipped items
- ✗ **Red** - Errors
- ℹ️ **Blue** - Information

#### Error Handling

```powershell
try {
    # Operation
}
catch {
    Write-ErrorMsg "Failed: $_"
    Write-SetupLog -Component $name -ErrorMessage $_.Exception.Message
}
```

#### Timeout Protection

All potentially long-running operations use timeout protection:

```powershell
$job = Start-Job -ScriptBlock { winget install $pkg }
$completed = Wait-Job -Job $job -Timeout 60

if ($completed) {
    $result = Receive-Job -Job $job
} else {
    Stop-Job -Job $job
    Write-Warning "Operation timed out"
}
```

## Logging

### Log Locations

Scripts write detailed logs to:

```
Scripts/Logs/
├── setup-details.json      # Setup failures
└── update-details.json     # Update failures
```

### Log Format

JSON format with detailed context:

```json
{
  "Timestamp": "2025-11-02 10:30:15",
  "Component": "Yazi",
  "Type": "winget",
  "Operation": "winget install sxyazi.yazi",
  "ErrorMessage": "Network timeout",
  "FullOutput": "...",
  "ExitCode": 1,
  "IsAdmin": false
}
```

### Viewing Logs

```powershell
# Setup logs
.\Scripts\Setup.ps1 -ShowDetails

# Update logs
.\Scripts\Update.ps1 -ShowDetails
```

## Exit Codes

All scripts use consistent exit codes:

| Exit Code | Meaning |
|-----------|---------|
| 0 | Success |
| 1 | Component failures (non-critical) |
| 2 | Critical error (cannot continue) |

## Common Parameters

### -ShowDetails

View detailed failure information from previous runs:

```powershell
.\Scripts\Setup.ps1 -ShowDetails
.\Scripts\Update.ps1 -ShowDetails
```

### -ClearLogs

Clear stored failure logs:

```powershell
.\Scripts\Setup.ps1 -ClearLogs
.\Scripts\Update.ps1 -ClearLogs
```

## Best Practices

### Regular Maintenance

Recommended schedule:

1. **Daily:** Run `Test.ps1` if making changes
2. **Weekly:** Run `Update.ps1` to get latest versions
3. **Monthly:** Review `-ShowDetails` for recurring issues
4. **As Needed:** Run `Setup.ps1` after git pull

### Troubleshooting Workflow

1. **Run Test.ps1** to identify issues
2. **Check -ShowDetails** for failure context
3. **Follow suggestions** from failure recovery
4. **Re-run** the script (already-completed steps are skipped)
5. **Report persistent issues** on GitHub

### Administrator Rights

Most scripts work without admin rights, but some components benefit:

| Script | Admin Recommended? | Why |
|--------|-------------------|-----|
| Setup.ps1 | Yes | Font installation, some packages |
| Test.ps1 | No | Read-only validation |
| Update.ps1 | No | Updates user-scoped packages |
| Deploy-Terminal.ps1 | No | Copies to user directories |

## See Also

- [Setup.ps1 Details](setup.md)
- [Test.ps1 Details](test.md)
- [Update.ps1 Details](update.md)
- [Deploy-Terminal.ps1 Details](deploy-terminal.md)
- [Architecture Overview](../architecture/overview.md)
