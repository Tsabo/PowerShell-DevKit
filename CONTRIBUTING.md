# 🤝 Contributing to PowerShell Environment

Thank you for considering contributing to this project! This document provides guidelines and instructions for contributing.

> **⚡ Quick Reference**: See [DEVELOPER-REFERENCE.md](DEVELOPER-REFERENCE.md) for command cheatsheet, validation scripts, and common fixes.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)

## 📜 Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Respect differing viewpoints and experiences

## 🚀 Getting Started

### Prerequisites

- Windows 10/11
- PowerShell 7+
- Git
- Code editor (VS Code recommended)

### Fork and Clone

```powershell
# Fork the repository on GitHub first

# Clone your fork
git clone https://github.com/YOUR-USERNAME/powershell-environment.git
cd powershell-environment

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL-OWNER/powershell-environment.git
```

## 🔧 How to Contribute

### Reporting Bugs

1. Check if the bug is already reported in [Issues](https://github.com/YOUR-USERNAME/powershell-environment/issues)
2. If not, create a new issue with:
   - Clear, descriptive title
   - Steps to reproduce
   - Expected vs actual behavior
   - PowerShell version (`$PSVersionTable`)
   - OS version
   - Relevant logs or screenshots

### Suggesting Enhancements

1. Check existing [Issues](https://github.com/YOUR-USERNAME/powershell-environment/issues) and [Discussions](https://github.com/YOUR-USERNAME/powershell-environment/discussions)
2. Create a new issue or discussion with:
   - Clear description of the enhancement
   - Why it would be useful
   - Possible implementation approach
   - Any alternatives considered

### Adding Features

Great areas to contribute:
- **Bundled Modules** - Add new `.psm1` files to `PowerShell/IncludedModules/` (shipped with repo)
- **Additional Standard Modules** - Suggest useful PSGallery modules to include
- **Yazi Plugins/Themes** - Additional Yazi configurations
- **oh-my-posh Themes** - New prompt themes
- **Documentation** - Improvements and examples
- **Bug Fixes** - Issue resolution
- **Performance** - Optimization improvements

#### 🆕 **Adding Bundled Modules** (Shipped with Repo)

Adding a new bundled module to the DevKit - add a `.psm1` file to `PowerShell/IncludedModules/`:

```powershell
# Example: PowerShell/IncludedModules/my-tools.psm1

<#
.SYNOPSIS
    My custom PowerShell utilities
#>

function Get-MyCustomTool {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    Write-Host "Running custom tool: $Name"
}

# Export only the functions you want to be public
Export-ModuleMember -Function Get-MyCustomTool
```

**That's it!** The module will be loaded via the Components system. Add it to the `Components.psm1` file to include it in the setup.

**Module Loading Rules:**
- ✅ Added to `PowerShell/IncludedModules/*.psm1`
- ✅ Registered in `Scripts/Components.psm1` for static loading
- ✅ Loaded during deferred startup (doesn't slow shell initialization)
- ✅ Use `Export-ModuleMember` to control what's public
- ✅ Shipped with the repo (tracked in git)

**Note for Users:** If you want to add your own personal modules (not contributed to the repo), create them in `PowerShell/CustomModules/` instead. Those are auto-discovered and never overwritten by updates.

## 💻 Development Setup

1. **Install Dependencies**
   ```powershell
   # Run the setup script
   .\Scripts\Setup-PowerShellEnvironment.ps1

   # Install PSScriptAnalyzer for linting
   Install-Module -Name PSScriptAnalyzer -Scope CurrentUser
   ```

2. **Create a Feature Branch**
   ```powershell
   git checkout -b feature/my-new-feature
   # or
   git checkout -b fix/bug-description
   ```

3. **Make Your Changes**
   - Edit files as needed
   - Test your changes
   - Follow coding standards (see below)

4. **Commit Your Changes**
   ```powershell
   git add .
   git commit -m "feat: add amazing new feature"
   ```

## 📝 Coding Standards

### PowerShell Scripts

- **Use PascalCase** for function names
- **Use camelCase** for variables
- **Use approved verbs** (Get-Verb for list)
- **Add comment-based help** to all functions
- **Include parameter validation** where appropriate
- **Use Write-Host for output**, Write-Verbose for debug info
- **Avoid aliases** in scripts (use full cmdlet names)

#### Example:

```powershell
<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Detailed description
.PARAMETER ParameterName
    Description of parameter
.EXAMPLE
    Example usage
#>
function Verb-Noun {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ParameterName
    )

    begin {
        Write-Verbose "Starting operation"
    }

    process {
        # Main logic here
    }

    end {
        Write-Verbose "Operation complete"
    }
}
```

### Module Organization

- One function per file (for large modules)
- Group related functions in modules
- Export only public functions
- Keep internal helpers private

### Configuration Files

- **TOML**: Use consistent indentation (2 spaces)
- **JSON**: Use 2-space indentation, validate with linter
- **Lua**: Follow [Lua style guide](http://lua-users.org/wiki/LuaStyleGuide)

### Documentation

- Update README.md if adding new features
- Update README.md if changing setup process
- Add inline comments for complex logic
- Update changelog (if maintained)

## 🧪 Testing & Code Quality

### 🔍 **Pre-Commit Validation (REQUIRED)**

**Before committing any changes, run our validation script:**

```powershell
# Run comprehensive validation (REQUIRED before commits)
.\Scripts\Validate-Code.ps1

# Quick validation (syntax only)
.\Scripts\Validate-Code.ps1 -Quick

# Show detailed PSScriptAnalyzer results
.\Scripts\Validate-Code.ps1 -Detailed
```

### 🛠️ **PSScriptAnalyzer Standards**

We use **PSScriptAnalyzer** to maintain high code quality. All code must pass analysis before being committed.

#### **Installation**
```powershell
# Install PSScriptAnalyzer
Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force
```

#### **Running Analysis**
```powershell
# Use project settings (RECOMMENDED)
Invoke-ScriptAnalyzer -Path . -Recurse -Settings .\PSScriptAnalyzerSettings.psd1

# Check specific file
Invoke-ScriptAnalyzer -Path .\Scripts\Setup.ps1 -Settings .\PSScriptAnalyzerSettings.psd1

# Export results for review
Invoke-ScriptAnalyzer -Path . -Recurse -Settings .\PSScriptAnalyzerSettings.psd1 |
    ConvertTo-Json | Out-File "analysis-results.json"
```

#### **Quality Standards**
- ✅ **ERRORS**: Must be zero (builds will fail)
- ⚠️ **WARNINGS**: Should be minimized (acceptable for merging)
- ℹ️ **INFORMATION**: Informational only

#### **Common Rule Violations & Fixes**

| Rule | Issue | Fix |
|------|-------|-----|
| `PSAvoidUsingCmdletAliases` | Using `ls` instead of `Get-ChildItem` | Use full cmdlet names |
| `PSUseDeclaredVarsMoreThanAssignments` | Unused variables | Remove or use variables |
| `PSAvoidGlobalVars` | Using `$global:` scope | Use parameters or return values |
| `PSUseCmdletCorrectly` | Incorrect parameter usage | Check parameter sets |
| `PSAvoidUsingPositionalParameters` | Missing parameter names | Use `-ParameterName` syntax |

### 📋 **Manual Testing Checklist**

#### **Before Submitting**

1. **✅ Code Analysis**
   ```powershell
   # Must pass with zero errors
   .\Scripts\Validate-Code.ps1
   ```

2. **✅ Syntax Validation**
   ```powershell
   # Test all PowerShell files
   Get-ChildItem -Path . -Include "*.ps1", "*.psm1" -Recurse |
       ForEach-Object {
           $errors = $null
           [void][System.Management.Automation.PSParser]::Tokenize((Get-Content $_.FullName -Raw), [ref]$errors)
           if ($errors) { Write-Error "Syntax error in $($_.Name): $($errors[0].Message)" }
       }
   ```

3. **✅ Functionality Testing**
   ```powershell
   # Test your specific changes
   .\Scripts\Test.ps1

   # For setup script changes, test on clean environment
   .\Scripts\Setup.ps1 -WhatIf
   ```

#### **Integration Testing**

4. **✅ Profile Loading**
   ```powershell
   # Test profile loads without errors
   powershell -NoProfile -Command ". '$PROFILE'"
   ```

5. **✅ Module Import**
   ```powershell
   # Test bundled modules import correctly
   Import-Module .\PowerShell\IncludedModules\utilities.psm1 -Force
   Import-Module .\PowerShell\IncludedModules\build_functions.psm1 -Force
   ```

6. **✅ Configuration Validation**
   ```powershell
   # Test Yazi config (if modified)
   yazi --check-config

   # Test oh-my-posh theme (if modified)
   oh-my-posh config validate --config .\Config\oh-my-posh\iterm2.omp.json
   ```

### 🔧 **Advanced Testing**

#### **Performance Testing**
```powershell
# Measure profile load time
Measure-Command { powershell -NoProfile -Command ". '$PROFILE'" }

# Should be under 2 seconds for good performance
```

#### **Cross-Version Testing**
```powershell
# Test on PowerShell 5.1 (if available)
powershell.exe -NoProfile -File .\Scripts\YourScript.ps1

# Test on PowerShell 7
pwsh -NoProfile -File .\Scripts\YourScript.ps1
```

#### **Clean Environment Testing**
For major changes, test on a clean environment:
```powershell
# Use Windows Sandbox, VM, or container
# Fresh Windows install → Clone repo → Run setup
```

### What to Test

- ✅ Script runs without errors
- ✅ All parameters work as expected
- ✅ Help documentation is accurate
- ✅ No breaking changes to existing functionality
- ✅ Works on Windows 10 and 11
- ✅ Follows existing patterns and style

## � **Pre-Commit Hook Setup (RECOMMENDED)**

Set up automatic validation before each commit:

### **Cross-Platform Setup**

```powershell
# Cross-platform pre-commit hook setup
$hookDir = Join-Path ".git" "hooks"
$hookFile = Join-Path $hookDir "pre-commit"

# Create hooks directory
New-Item -Path $hookDir -ItemType Directory -Force

# Create cross-platform pre-commit hook
$hookContent = @'
#!/bin/sh
# PowerShell code validation pre-commit hook (cross-platform)
echo "🔍 Running PowerShell code validation..."

# Try pwsh first (PowerShell 7+), fall back to powershell if needed
if command -v pwsh >/dev/null 2>&1; then
    pwsh -NoProfile -ExecutionPolicy Bypass -File "Scripts/Validate-Code.ps1" -Quick
elif command -v powershell >/dev/null 2>&1; then
    powershell -NoProfile -ExecutionPolicy Bypass -File "Scripts/Validate-Code.ps1" -Quick
else
    echo "❌ PowerShell not found. Please install PowerShell 7+ (pwsh)"
    exit 1
fi

if [ $? -ne 0 ]; then
    echo "❌ Code validation failed. Run './Scripts/Validate-Code.ps1' for details."
    echo "💡 Tip: Use 'git commit --no-verify' to skip validation (not recommended)"
    exit 1
fi

echo "✅ Code validation passed."
'@

# Write hook file with proper encoding
$hookContent | Out-File $hookFile -Encoding UTF8 -NoNewline

# Make executable on Unix-like systems
if ($IsLinux -or $IsMacOS) {
    chmod +x $hookFile
    Write-Host "✅ Pre-commit hook installed and made executable" -ForegroundColor Green
} else {
    Write-Host "✅ Pre-commit hook installed (Windows)" -ForegroundColor Green
}

Write-Host "🎯 Hook location: $hookFile" -ForegroundColor Cyan
```

### **Manual Installation (Linux/macOS)**

```bash
# Alternative setup for Linux/macOS/WSL
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
echo "🔍 Running PowerShell code validation..."
pwsh -NoProfile -ExecutionPolicy Bypass -File "Scripts/Validate-Code.ps1" -Quick
if [ $? -ne 0 ]; then
    echo "❌ Validation failed. Run './Scripts/Validate-Code.ps1' for details."
    exit 1
fi
echo "✅ Validation passed."
EOF

chmod +x .git/hooks/pre-commit
```

### �📤 Pull Request Process

### Before Creating PR

1. **Update from upstream**
   ```powershell
   git fetch upstream
   git rebase upstream/main
   ```

2. **🔍 REQUIRED: Run full validation**
   ```powershell
   # This MUST pass before creating PR
   .\Scripts\Validate-Code.ps1
   ```

3. **Update documentation** if needed

### Creating the PR

1. Push to your fork:
   ```powershell
   git push origin feature/my-new-feature
   ```

2. Go to GitHub and create a Pull Request

3. Fill in the PR template with:
   - **Description** of changes
   - **Motivation** for the change
   - **Type of change** (bugfix, feature, docs, etc.)
   - **Testing performed**
   - **Screenshots** if UI changes

### PR Title Format

Use conventional commits format:

- `feat: add new custom function`
- `fix: resolve yazi plugin installation issue`
- `docs: update README`
- `refactor: improve module loading performance`
- `test: add validation for custom modules`
- `chore: update dependencies`

### Review Process

- Maintainer will review your PR
- Address any feedback or requested changes
- Once approved, PR will be merged
- Your contribution will be credited!

## 🎯 Priority Areas

We'd especially love contributions in these areas:

1. **Cross-platform support** - Make scripts work on Linux/macOS
2. **Additional modules** - Useful PowerShell modules everyone should have
3. **Performance** - Speed up profile loading or scripts
4. **Documentation** - More examples, guides, tips
5. **Themes** - Additional oh-my-posh themes
6. **Yazi configs** - More plugin configurations
7. **Tests** - Automated testing improvements

## 💡 Tips for Contributors

### Good First Issues

Look for issues labeled:
- `good first issue`
- `help wanted`
- `documentation`

### Getting Help

- 💬 Start a [Discussion](https://github.com/YOUR-USERNAME/powershell-environment/discussions)
- 📖 Read existing documentation
- 🔍 Search closed issues for similar problems

### Resources

- [PowerShell Best Practices](https://poshcode.gitbooks.io/powershell-practice-and-style/)
- [PowerShell Approved Verbs](https://docs.microsoft.com/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🤖 **Automated Quality Checks**

### GitHub Actions Workflow

Every PR automatically runs comprehensive validation via GitHub Actions:

- ✅ **PSScriptAnalyzer** with project settings
- ✅ **Syntax validation** for all PowerShell files
- ✅ **Configuration validation** (JSON, TOML, PSD1)
- ✅ **Module import testing**
- ✅ **Cross-platform compatibility** checks

### Workflow Status

Check your PR status:
- 🟢 **All checks passed** → Ready for review
- 🟡 **Some warnings** → Review suggested fixes
- 🔴 **Failures detected** → Must fix before merge

### Accessing Detailed Reports

1. Go to your PR → "Checks" tab
2. Click "Validate PowerShell Scripts"
3. Download "pssa-results" artifact for detailed analysis
4. Review JSON reports for comprehensive issue details

### Local Validation Matches CI

The `Validate-Code.ps1` script uses identical rules to GitHub Actions, so local validation results will match CI results.

## 🙏 Recognition

All contributors will be:
- Listed in the project README
- Credited in release notes
- Part of building an awesome PowerShell environment!

Thank you for contributing! 🎉

---

**Questions?** Feel free to open an issue or discussion!
