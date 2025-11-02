# Intelligent Failure Recovery

PowerShell DevKit includes an advanced failure recovery system that provides actionable diagnostics and suggestions when installations or updates fail.

## Overview

The failure recovery system consists of:

1. **Detailed Logging** - JSON-based logs with full context
2. **Smart Suggestions** - Pattern-matching error analysis
3. **Failure History** - Track recurring issues
4. **Easy Diagnostics** - Simple commands to view failures

## Log Structure

### Log Files

Logs are stored in `Scripts/Logs/`:

- `setup-details.json` - Setup.ps1 failures
- `update-details.json` - Update.ps1 failures

### Log Entry Format

```json
{
  "Timestamp": "2025-11-02 10:30:15",
  "Component": "Yazi",
  "Type": "winget",
  "Operation": "winget install sxyazi.yazi",
  "ErrorMessage": "Network timeout during download",
  "FullOutput": "...(truncated)...",
  "ExitCode": 1,
  "IsAdmin": false
}
```

### Log Fields

| Field | Description | Example |
|-------|-------------|---------|
| `Timestamp` | When the failure occurred | "2025-11-02 10:30:15" |
| `Component` | Component that failed | "Yazi" |
| `Type` | Component type | "winget", "module", "custom" |
| `Operation` | Command that was executed | "winget install sxyazi.yazi" |
| `ErrorMessage` | Error description | "Network timeout" |
| `FullOutput` | Complete command output | Full stderr/stdout |
| `ExitCode` | Process exit code | 1 |
| `IsAdmin` | Running as administrator? | false |

## Viewing Failures

### Setup Failures

```powershell
# View detailed failure information
.\Scripts\Setup.ps1 -ShowDetails
```

**Output Example:**

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
   Output:
     Downloading package...
     Failed to download from https://...
     ... (truncated)
   Failure frequency: 3 times in last 7 days
   💡 Suggestion: Network issue. Check internet connection and try again
```

### Update Failures

```powershell
# View update failure details
.\Scripts\Update.ps1 -ShowDetails
```

## Suggestion Engine

The system analyzes errors and provides context-specific suggestions:

### Permission Issues

**Pattern:** `access denied`, `permission denied`

**Suggestions:**

- Run PowerShell as Administrator
- Use `--scope user` for winget installations
- Check file/folder permissions

**Example:**

```
💡 Suggestion: Permission denied. Try running as Administrator
```

### Network Issues

**Pattern:** `network`, `timeout`, `connection`, `download failed`

**Suggestions:**

- Check internet connectivity
- Verify firewall settings
- Try again later
- Check PowerShell Gallery access

**Example:**

```
💡 Suggestion: Network issue. Check internet connection and PowerShell Gallery access
```

### Execution Policy

**Pattern:** `execution policy`, `script cannot be run`

**Suggestions:**

- Set execution policy to RemoteSigned
- Component-specific instructions (Scoop requires this)

**Example:**

```
💡 Suggestion: Run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Module Installation

**Pattern:** `module not found`, `package source`

**Suggestions:**

- Update PowerShellGet
- Register PSGallery
- Check network connectivity

**Example:**

```
💡 Suggestion: Update PowerShellGet: Install-Module PowerShellGet -Force -AllowClobber
```

### Component-Specific

The system includes specific suggestions for known components:

| Component | Suggestion |
|-----------|------------|
| gsudo | Install manually: `winget install gerardog.gsudo --scope user` |
| CascadiaCode Font | Font updates often fail silently. Check Windows Settings > Fonts |
| oh-my-posh | Ensure PATH is updated. Run: `refreshenv` or restart PowerShell |
| fzf | Install manually: `winget install junegunn.fzf` |
| PSFzf | Update PowerShellGet: `Install-Module PowerShellGet -Force` |
| posh-git | Ensure Git is installed: `winget install Git.Git` |
| Scoop | Requires execution policy. See installation command |
| Yazi | Install manually: `winget install sxyazi.yazi` |

## Failure Frequency Tracking

The system tracks how often each component fails:

```
Failure frequency: 3 times in last 7 days
```

This helps identify:

- Persistent issues requiring manual intervention
- Environmental problems (network, permissions)
- Component conflicts

## Clearing Logs

### Clear Setup Logs

```powershell
.\Scripts\Setup.ps1 -ClearLogs
```

### Clear Update Logs

```powershell
.\Scripts\Update.ps1 -ClearLogs
```

This removes all stored failure information.

## Log Rotation

Logs automatically rotate to prevent unbounded growth:

- **Retention:** Last 50 failures per log file
- **Rotation:** Automatic when adding new entries
- **Scope:** Last 7 days shown in `-ShowDetails`

## Timeout Protection

All operations have timeout protection to prevent hangs:

### Timeout Values

| Operation | Timeout |
|-----------|---------|
| Package check | 15 seconds |
| Package installation | 60 seconds |
| Git operations | 30 seconds |

### Timeout Behavior

When a timeout occurs:

1. Operation is gracefully terminated
2. Failure is logged with timeout context
3. Installation continues with next component
4. User is notified of the timeout

**Example:**

```powershell
Write-Host "  → Check timed out, proceeding with installation..." -ForegroundColor Yellow
```

## Error Categories

### Critical Errors

Stop execution immediately:

- PowerShell version too old
- Missing required dependencies (winget)
- Invalid parameters

### Component Errors

Logged and skipped:

- Package installation failures
- Module installation failures
- Custom component failures

### Configuration Errors

Logged with warnings:

- Configuration file not found
- Permission issues on config deployment
- Invalid configuration format

## Integration with Scripts

### Setup.ps1

```powershell
function Write-SetupLog {
    param(
        [string]$Component,
        [string]$Type,
        [string]$Operation,
        [string]$ErrorMessage,
        [string]$FullOutput = "",
        [int]$ExitCode = 0
    )

    # Create log entry
    # Save to setup-details.json
    # Rotate if needed
}
```

### Update.ps1

```powershell
function Write-DetailedLog {
    param(
        [string]$Component,
        [string]$Type,
        [string]$Operation,
        [string]$ErrorMessage,
        [string]$FullOutput = ""
    )

    # Create log entry
    # Save to update-details.json
    # Rotate if needed
}
```

### Test.ps1

Test.ps1 does not write failure logs, but reads component definitions and validates them.

## Diagnostic Workflow

### 1. Setup Fails

```powershell
# Setup encounters errors
.\Scripts\Setup.ps1
# Some components fail...

# View details
.\Scripts\Setup.ps1 -ShowDetails

# Follow suggestions
# Fix issues (e.g., check internet, run as admin)

# Re-run setup (skips already-installed components)
.\Scripts\Setup.ps1
```

### 2. Update Fails

```powershell
# Update encounters errors
.\Scripts\Update.ps1
# Some components fail...

# View details
.\Scripts\Update.ps1 -ShowDetails

# Follow suggestions
# Fix issues

# Re-run update
.\Scripts\Update.ps1
```

### 3. Recurring Issues

```powershell
# If component fails multiple times:
# 1. Check failure frequency in -ShowDetails
# 2. Look for pattern in error messages
# 3. Consult component-specific documentation
# 4. Consider manual installation
# 5. Report issue on GitHub
```

## Best Practices

### For Users

- Always check `-ShowDetails` after failures
- Follow suggestions before re-running
- Clear logs periodically with `-ClearLogs`
- Report persistent issues on GitHub

### For Developers

When adding components:

- Provide clear error messages
- Include context in error logs
- Use appropriate timeout values
- Test failure scenarios
- Document known issues

When adding suggestions:

- Be specific and actionable
- Include exact commands when possible
- Link to documentation when needed
- Test suggestions actually work

## See Also

- [Architecture Overview](overview.md)
- [Component System](components.md)
- [Troubleshooting Guide](../troubleshooting.md)
