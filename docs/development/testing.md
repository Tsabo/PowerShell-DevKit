# Testing Guide

Comprehensive testing guide for PowerShell DevKit contributors.

## Testing Overview

PowerShell DevKit uses multiple testing approaches:

1. **Automated Code Validation** - PSScriptAnalyzer
2. **Environment Validation** - Test.ps1
3. **Manual Testing** - Component functionality
4. **Integration Testing** - Full workflow testing

## Automated Testing

### Code Validation (Required)

```powershell
# Run before every commit
.\Scripts\Validate-Code.ps1
```

**Checks:**

- PSScriptAnalyzer rules
- Syntax errors
- Code formatting
- Best practices compliance

**Must pass** before committing!

### Environment Validation

```powershell
# Validate installation
.\Scripts\Test.ps1
```

**Checks:**

- Component installation status
- Component versions
- Configuration deployment
- Module availability

## Manual Testing

### Component Installation

Test each component can be installed:

```powershell
# Fresh install
.\Scripts\Setup.ps1

# Skip optional
.\Scripts\Setup.ps1 -SkipOptional

# Verify
.\Scripts\Test.ps1
```

### Component Updates

Test updates work correctly:

```powershell
# Update all
.\Scripts\Update.ps1

# Update specific types
.\Scripts\Update.ps1 -WingetOnly
.\Scripts\Update.ps1 -ModulesOnly

# Verify
.\Scripts\Test.ps1
```

### Configuration Deployment

Test configuration files deploy correctly:

```powershell
# Deploy profile
.\Scripts\Setup.ps1

# Verify profile exists
Test-Path $PROFILE

# Verify profile loads
. $PROFILE

# Deploy terminal
.\Scripts\Deploy-Terminal.ps1

# Verify terminal settings
Test-Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json"
```

### Error Handling

Test failure scenarios:

```powershell
# Network timeout (disconnect network)
.\Scripts\Setup.ps1

# Check failure logging
.\Scripts\Setup.ps1 -ShowDetails

# Permission errors (run as standard user)
.\Scripts\Setup.ps1

# Missing prerequisites (uninstall winget)
.\Scripts\Setup.ps1
```

## Integration Testing

### Full Workflow

Test complete installation workflow:

```powershell
# 1. Clean environment (VM recommended)
# 2. Clone repository
git clone https://github.com/Tsabo/PowerShell-DevKit.git
cd PowerShell-DevKit

# 3. Run setup
.\Scripts\Setup.ps1

# 4. Validate
.\Scripts\Test.ps1

# 5. Test profile
. $PROFILE

# 6. Test components
yazi
y
oh-my-posh version
z --version

# 7. Test updates
.\Scripts\Update.ps1

# 8. Re-validate
.\Scripts\Test.ps1
```

### Idempotency Testing

Verify setup is idempotent:

```powershell
# Run setup multiple times
.\Scripts\Setup.ps1
.\Scripts\Setup.ps1
.\Scripts\Setup.ps1

# Should skip already-installed components
# Should not show errors
```

### Update Workflow

Test update preserves customizations:

```powershell
# 1. Fresh install
.\Scripts\Setup.ps1

# 2. Create customizations
Copy-Item "PowerShell\CustomProfile.ps1.template" "PowerShell\CustomProfile.ps1"
New-Item "PowerShell\CustomModules\test.psm1"

# 3. Pull updates
git pull

# 4. Run setup again
.\Scripts\Setup.ps1

# 5. Verify customizations preserved
Test-Path "PowerShell\CustomProfile.ps1"
Test-Path "PowerShell\CustomModules\test.psm1"
```

## Component-Specific Testing

### oh-my-posh

```powershell
# Check installation
oh-my-posh version

# Test theme
oh-my-posh init pwsh --config ".\Config\oh-my-posh\iterm2.omp.json" | Invoke-Expression

# Verify font
# Check terminal displays icons correctly
```

### Yazi

```powershell
# Check installation
yazi --version

# Test launch
yazi

# Test directory change function
y

# Test plugins
# Navigate to git repository
# Verify git status shows
```

### PowerShell Modules

```powershell
# Check modules installed
Get-Module -ListAvailable PSFzf
Get-Module -ListAvailable Terminal-Icons
Get-Module -ListAvailable posh-git

# Test module import
Import-Module PSFzf
Import-Module Terminal-Icons

# Test functionality
Ctrl+R  # PSFzf history
ls      # Terminal-Icons
```

## Test Environments

### Recommended Test Setups

1. **Primary Development** - Windows 11, PowerShell 7, all components
2. **Minimal Setup** - Windows 10, PowerShell 7, no optional components
3. **Clean Install** - Fresh Windows VM, first-time installation
4. **Upgrade Path** - Existing installation → pull updates → re-run setup

### Virtual Machine Testing

Use VMs for destructive testing:

- Fresh Windows installation
- Test installation from scratch
- Test with limited permissions
- Test with network restrictions

### Windows Versions

Test on multiple Windows versions:

- Windows 10 (latest)
- Windows 11
- Windows Server 2022 (if applicable)

## Test Checklist

### Before Committing

- [ ] `Validate-Code.ps1` passes
- [ ] `Test.ps1` passes
- [ ] Manually tested changes
- [ ] Documentation updated
- [ ] No syntax errors

### Before Pull Request

- [ ] All automated tests pass
- [ ] Manual testing completed
- [ ] Integration testing completed
- [ ] Clean install tested (VM)
- [ ] Update workflow tested
- [ ] Documentation accurate

### Component Addition

- [ ] Component defined in Components.psm1
- [ ] Installation tested
- [ ] Validation tested
- [ ] Update tested
- [ ] Documentation added
- [ ] Optional flag set correctly

## Common Test Scenarios

### Scenario 1: New Component

```powershell
# 1. Add component to Components.psm1
# 2. Test installation
.\Scripts\Setup.ps1

# 3. Verify in Test.ps1
.\Scripts\Test.ps1

# 4. Test update
.\Scripts\Update.ps1

# 5. Document in docs/components/
```

### Scenario 2: Profile Change

```powershell
# 1. Modify profile
# 2. Test loading
. $PROFILE

# 3. Check for errors
# 4. Test functions work
# 5. Restart PowerShell and verify
```

### Scenario 3: Failure Recovery

```powershell
# 1. Cause intentional failure (disconnect network)
.\Scripts\Setup.ps1

# 2. Check failure logged
.\Scripts\Setup.ps1 -ShowDetails

# 3. Fix issue (reconnect network)
# 4. Re-run setup
.\Scripts\Setup.ps1

# 5. Verify recovery worked
```

## Debugging

### Enable Verbose Output

```powershell
# Verbose messages
.\Scripts\Setup.ps1 -Verbose

# Debug messages
$DebugPreference = "Continue"
.\Scripts\Setup.ps1
```

### Check Logs

```powershell
# View setup logs
.\Scripts\Setup.ps1 -ShowDetails

# View update logs
.\Scripts\Update.ps1 -ShowDetails

# Read JSON directly
Get-Content .\Scripts\Logs\setup-details.json | ConvertFrom-Json
```

### Profile Debugging

```powershell
# Test profile without loading
powershell -NoProfile -Command ". '$PROFILE'"

# Check specific module
Import-Module .\PowerShell\IncludedModules\utilities.psm1 -Verbose
```

## Continuous Integration

### GitHub Actions (Future)

When CI is set up:

```yaml
- name: Validate Code
  run: .\Scripts\Validate-Code.ps1

- name: Test Environment
  run: .\Scripts\Test.ps1
```

## See Also

- [Contributing Guide](contributing.md)
- [Developer Reference](developer-reference.md)
- [Architecture Overview](../architecture/overview.md)
