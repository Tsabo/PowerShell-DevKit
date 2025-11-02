# 🛠️ Developer Quick Reference

## Pre-Commit Validation Commands

```powershell
# 🎨 Format all code first (RECOMMENDED)
./Scripts/Format-AllCode.ps1         # Linux/macOS/WSL
.\Scripts\Format-AllCode.ps1         # Windows

# 🔍 Preview formatting changes
./Scripts/Format-AllCode.ps1 -WhatIf

# 🚀 REQUIRED before every commit (cross-platform)
./Scripts/Validate-Code.ps1          # Linux/macOS/WSL
.\Scripts\Validate-Code.ps1          # Windows

# ⚡ Quick syntax check only
./Scripts/Validate-Code.ps1 -Quick

# 🔍 Detailed analysis with all info
./Scripts/Validate-Code.ps1 -Detailed

# 📊 Export results to JSON files
./Scripts/Validate-Code.ps1 -Export

# 🔥 Strict mode (warnings = errors)
./Scripts/Validate-Code.ps1 -FailOnWarnings
```

## Cross-Platform Notes

```bash
# 🐧 Linux/macOS - PowerShell 7+ required
# Install PowerShell: https://docs.microsoft.com/powershell/scripting/install/installing-powershell

# Ubuntu/Debian
sudo apt update && sudo apt install -y powershell

# CentOS/RHEL/Fedora
sudo dnf install -y powershell

# macOS
brew install powershell

# Verify installation
pwsh --version
```

## PSScriptAnalyzer Commands

```powershell
# Project-specific analysis
Invoke-ScriptAnalyzer -Path . -Recurse -Settings .\PSScriptAnalyzerSettings.psd1

# Auto-fix common issues
Invoke-ScriptAnalyzer -Path . -Fix -Settings .\PSScriptAnalyzerSettings.psd1

# Check single file
Invoke-ScriptAnalyzer -Path .\Scripts\Setup.ps1 -Settings .\PSScriptAnalyzerSettings.psd1

# Export detailed results
Invoke-ScriptAnalyzer -Path . -Recurse -Settings .\PSScriptAnalyzerSettings.psd1 |
    Export-Csv "analysis-results.csv" -NoTypeInformation
```

## Common Rule Fixes

| Error | Quick Fix |
|-------|-----------|
| `PSAvoidUsingCmdletAliases` | Replace `ls` → `Get-ChildItem`, `cd` → `Set-Location` |
| `PSUseDeclaredVarsMoreThanAssignments` | Remove unused variables or use them |
| `PSAvoidUsingPositionalParameters` | Add parameter names: `-Path $file` |
| `PSUseCmdletCorrectly` | Check `Get-Help` for correct parameter usage |
| `PSAvoidGlobalVars` | Use function parameters or return values |

## Testing Commands

```powershell
# Full environment validation
.\Scripts\Test.ps1

# Test profile loading
powershell -NoProfile -Command ". '$PROFILE'"

# Test module imports
Import-Module .\PowerShell\CustomModules\utilities.psm1 -Force

# Test syntax of all PS files
Get-ChildItem -Include "*.ps1","*.psm1" -Recurse |
    ForEach-Object {
        $errors = $null
        [void][System.Management.Automation.PSParser]::Tokenize((Get-Content $_.FullName -Raw), [ref]$errors)
        if ($errors) { Write-Error "Error in $($_.Name)" }
    }
```

## Git Workflow

```powershell
# 1. Create feature branch
git checkout -b feature/my-feature

# 2. Make changes
# ... edit files ...

# 3. VALIDATE (REQUIRED)
.\Scripts\Validate-Code.ps1

# 4. Stage and commit
git add .
git commit -m "feat: add amazing feature"

# 5. Update from upstream
git fetch upstream
git rebase upstream/main

# 6. Push and create PR
git push origin feature/my-feature
```

## Emergency Fixes

```powershell
# Skip validation temporarily (NOT RECOMMENDED)
git commit --no-verify

# Fix common issues automatically
Invoke-ScriptAnalyzer -Path . -Fix

# Check what rules are being violated
Invoke-ScriptAnalyzer -Path . | Group-Object RuleName | Sort-Object Count -Descending

# Get help for specific rule
Get-Help about_PSAvoidUsingCmdletAliases
```

## File Locations

- **Validation Script**: `.\Scripts\Validate-Code.ps1`
- **PSScriptAnalyzer Settings**: `.\PSScriptAnalyzerSettings.psd1`
- **Contributing Guide**: `.\CONTRIBUTING.md`
- **GitHub Workflow**: `.\.github\workflows\validate.yml`

## Exit Codes

- `0` = Success
- `1` = PSScriptAnalyzer errors
- `2` = Syntax errors
- `3` = Configuration errors
- `4` = Missing dependencies

---
*💡 Pro Tip: Set up the pre-commit hook in CONTRIBUTING.md to automate validation!*