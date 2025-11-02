# Developer Reference

Quick command reference for contributors working on PowerShell DevKit.

## Pre-Commit Validation

### Required Before Every Commit

```powershell
# Run code validation (REQUIRED)
.\Scripts\Validate-Code.ps1
```

**Must pass** before committing!

### Validation Options

```powershell
# Quick syntax check only
.\Scripts\Validate-Code.ps1 -Quick

# Detailed analysis
.\Scripts\Validate-Code.ps1 -Detailed

# Export results to JSON
.\Scripts\Validate-Code.ps1 -Export

# Strict mode (warnings = errors)
.\Scripts\Validate-Code.ps1 -FailOnWarnings
```

## PSScriptAnalyzer

### Project Analysis

```powershell
# Analyze entire project
Invoke-ScriptAnalyzer -Path . -Recurse -Settings .\PSScriptAnalyzerSettings.psd1

# Auto-fix issues
Invoke-ScriptAnalyzer -Path . -Fix -Settings .\PSScriptAnalyzerSettings.psd1

# Single file
Invoke-ScriptAnalyzer -Path .\Scripts\Setup.ps1
```

### Common Fixes

| Rule | Fix |
|------|-----|
| PSAvoidUsingCmdletAliases | `ls` → `Get-ChildItem` |
| PSAvoidUsingPositionalParameters | Add `-Parameter` names |
| PSUseDeclaredVarsMoreThanAssignments | Remove unused variables |
| PSUseCmdletCorrectly | Check `Get-Help` for usage |

## Testing

### Environment Validation

```powershell
# Full validation
.\Scripts\Test.ps1

# Check specific component
Import-Module .\Scripts\Components.psm1
$component = (Get-EnvironmentComponents | Where-Object { $_.Name -eq "Yazi" })
Test-EnvironmentComponent -Component $component
```

### Profile Testing

```powershell
# Test profile loading
powershell -NoProfile -Command ". '$PROFILE'"

# Test module imports
Import-Module .\PowerShell\IncludedModules\utilities.psm1 -Force
```

### Syntax Validation

```powershell
# Check all PowerShell files
Get-ChildItem -Include "*.ps1","*.psm1" -Recurse | ForEach-Object {
    $errors = $null
    [void][System.Management.Automation.PSParser]::Tokenize(
        (Get-Content $_.FullName -Raw), [ref]$errors
    )
    if ($errors) { Write-Error "Error in $($_.Name)" }
}
```

## Git Workflow

### Feature Development

```powershell
# Create feature branch
git checkout -b feature/my-feature

# Make changes...

# Validate code
.\Scripts\Validate-Code.ps1

# Stage and commit
git add .
git commit -m "feat: add amazing feature"

# Update from upstream
git fetch upstream
git rebase upstream/master

# Push
git push origin feature/my-feature
```

### Commit Message Format

```
type(scope): brief description

Detailed description if needed.

Fixes #issue-number
```

**Types:** feat, fix, docs, style, refactor, test, chore

## Component Development

### Add New Component

```powershell
# Edit Scripts/Components.psm1
# Add to array:

@{
    Name = "NewTool"
    Type = "winget"
    IsOptional = $false
    Properties = @{
        PackageId = "Publisher.NewTool"
    }
}

# Test
.\Scripts\Test.ps1
```

### Custom Component

```powershell
@{
    Name = "CustomComponent"
    Type = "custom"
    CustomInstaller = {
        param($Component)
        # Installation logic
        return $true  # or $false
    }
    CustomValidator = {
        param($Component)
        return @{
            IsInstalled = $true
            Version = "1.0.0"
        }
    }
}
```

## Documentation

### Preview Docs Locally

```powershell
# Serve with live reload
mkdocs serve

# Open browser to http://127.0.0.1:8000

# Build static site
mkdocs build
```

### Documentation Structure

- `docs/getting-started/` - Installation guides
- `docs/components/` - Component details
- `docs/scripts/` - Script documentation
- `docs/configuration/` - Customization
- `docs/architecture/` - System design
- `docs/development/` - Contributing

## Emergency Fixes

### Skip Validation (Not Recommended)

```powershell
# Skip pre-commit hook
git commit --no-verify
```

### Auto-Fix Issues

```powershell
# Fix common issues automatically
Invoke-ScriptAnalyzer -Path . -Fix
```

### Check Violated Rules

```powershell
# See most common violations
Invoke-ScriptAnalyzer -Path . |
    Group-Object RuleName |
    Sort-Object Count -Descending
```

## File Locations

| File | Purpose |
|------|---------|
| `.\Scripts\Validate-Code.ps1` | Code validation |
| `.\PSScriptAnalyzerSettings.psd1` | Analyzer settings |
| `.\Scripts\Components.psm1` | Component definitions |
| `.\mkdocs.yml` | Documentation config |
| `.\.gitignore` | Git ignore rules |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | PSScriptAnalyzer errors |
| 2 | Syntax errors |
| 3 | Configuration errors |
| 4 | Missing dependencies |

## Useful Commands

### Find Component Definition

```powershell
Import-Module .\Scripts\Components.psm1
Get-EnvironmentComponents | Where-Object { $_.Name -eq "Yazi" }
```

### Test Component Installation

```powershell
Import-Module .\Scripts\Components.psm1
$yazi = Get-EnvironmentComponents | Where-Object { $_.Name -eq "Yazi" }
Test-EnvironmentComponent -Component $yazi
```

### List All Components

```powershell
Import-Module .\Scripts\Components.psm1
Get-EnvironmentComponents | Format-Table Name, Type, IsOptional
```

## See Also

- [Contributing Guide](contributing.md)
- [Testing Guide](testing.md)
- [Architecture Overview](../architecture/overview.md)
