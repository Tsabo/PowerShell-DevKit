# Contributing to PowerShell DevKit

Thank you for considering contributing to PowerShell DevKit! This guide will help you get started.

## Quick Start for Contributors

1. **Fork** the repository on GitHub
2. **Clone** your fork locally
3. **Create** a feature branch
4. **Make** your changes
5. **Validate** with `Validate-Code.ps1`
6. **Test** with `Test.ps1`
7. **Commit** with descriptive messages
8. **Push** to your fork
9. **Open** a Pull Request

## Development Setup

### Prerequisites

- Windows 10/11
- PowerShell 7+
- Git
- Code editor (VS Code recommended)

### Initial Setup

```powershell
# Fork the repository on GitHub first

# Clone your fork
git clone https://github.com/YOUR-USERNAME/PowerShell-DevKit.git
cd PowerShell-DevKit

# Add upstream remote
git remote add upstream https://github.com/Tsabo/PowerShell-DevKit.git

# Install the environment
.\Scripts\Setup.ps1
```

## Before You Commit

### 1. Validate Code Quality

```powershell
# REQUIRED: Run validation
.\Scripts\Validate-Code.ps1

# This checks:
# - PSScriptAnalyzer rules
# - Syntax errors
# - Code formatting
# - Best practices
```

**Must pass** before committing!

### 2. Test Functionality

```powershell
# Validate environment
.\Scripts\Test.ps1

# Test specific functionality
# - Install/update components
# - Configuration deployment
# - Error handling
```

### 3. Update Documentation

If your changes affect:

- User-facing features → Update docs/
- Scripts → Update relevant script documentation
- Components → Update component pages
- Architecture → Update architecture docs

## Contribution Areas

### Add New Components

**Great for beginners!**

Edit `Scripts/Components.psm1`:

```powershell
@{
    Name = "New Tool"
    Type = "winget"  # or "module" or "custom"
    IsOptional = $false
    Properties = @{
        PackageId = "Publisher.NewTool"
    }
}
```

See [Component System](../architecture/components.md) for details.

### Add Bundled Modules

Add `.psm1` files to `PowerShell/IncludedModules/`:

```powershell
# Example: PowerShell/IncludedModules/my-tools.psm1

function Get-MyTool {
    [CmdletBinding()]
    param([string]$Name)

    Write-Host "Tool: $Name"
}

Export-ModuleMember -Function Get-MyTool
```

### Improve Documentation

- Fix typos or clarify existing docs
- Add examples
- Create missing pages
- Update screenshots

### Bug Fixes

1. **Search** existing issues
2. **Create issue** if not exists
3. **Reference issue** in PR

### Feature Enhancements

1. **Discuss** in issues first
2. **Get feedback** on approach
3. **Implement** with tests
4. **Document** the feature

## Code Standards

### PowerShell Style

```powershell
# Good: Clear function names
function Get-UserData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$UserId
    )

    # Implementation
}

# Good: Comment-based help
<#
.SYNOPSIS
    Gets user data
.PARAMETER UserId
    The user identifier
.EXAMPLE
    Get-UserData -UserId "12345"
#>
```

### Follow PSScriptAnalyzer

The project uses `PSScriptAnalyzerSettings.psd1`:

- No aliases in scripts
- Proper parameter names
- Error handling
- Comment-based help

### Error Handling

```powershell
# Good: Try/catch with logging
try {
    $result = Invoke-Operation
}
catch {
    Write-Error "Operation failed: $_"
    Write-SetupLog -Component "Name" -ErrorMessage $_.Exception.Message
    return $false
}
```

### Output Messages

Use color-coded output:

```powershell
Write-Step "Installing component..."     # Cyan - Section headers
Write-Success "Component installed"      # Green - Success
Write-Skip "Already installed"           # Yellow - Skipped
Write-ErrorMsg "Installation failed"     # Red - Errors
```

## Commit Messages

### Format

```
type(scope): brief description

Longer description if needed.

Fixes #123
```

### Types

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `style:` Formatting
- `refactor:` Code restructuring
- `test:` Tests
- `chore:` Maintenance

### Examples

```
feat(components): add ripgrep component

Add ripgrep as optional component for Yazi text search.

Related to #45

---

fix(setup): handle network timeout gracefully

Previously hung indefinitely. Now times out after 60s.

Fixes #78

---

docs(architecture): document failure recovery system

Add comprehensive guide for intelligent failure recovery.
```

## Pull Request Process

### 1. Create Feature Branch

```powershell
git checkout -b feature/my-feature
```

### 2. Make Changes

- Follow code standards
- Add tests if applicable
- Update documentation

### 3. Validate

```powershell
# Validate code
.\Scripts\Validate-Code.ps1

# Test functionality
.\Scripts\Test.ps1
```

### 4. Commit

```powershell
git add .
git commit -m "feat(component): add amazing feature"
```

### 5. Update from Upstream

```powershell
git fetch upstream
git rebase upstream/master
```

### 6. Push

```powershell
git push origin feature/my-feature
```

### 7. Create PR

1. Go to GitHub
2. Click "New Pull Request"
3. Fill in template
4. Link related issues

### PR Template

```markdown
## Description
Brief description of changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation
- [ ] Performance improvement

## Testing
- [ ] Validated with Validate-Code.ps1
- [ ] Tested with Test.ps1
- [ ] Manually tested functionality

## Related Issues
Fixes #123

## Screenshots
If applicable.
```

## Testing

### Automated Testing

```powershell
# Code validation (required)
.\Scripts\Validate-Code.ps1

# Environment validation
.\Scripts\Test.ps1
```

### Manual Testing

- Install from scratch
- Update existing installation
- Test with `-SkipOptional`
- Test failure scenarios
- Test on clean Windows install (VM)

## Documentation

### Documentation Structure

```
docs/
├── getting-started/      # Installation, quick start
├── components/           # Component details
├── scripts/              # Script documentation
├── configuration/        # Customization guides
├── architecture/         # System design
└── development/          # Contributing, testing
```

### Writing Documentation

- Use clear, concise language
- Include code examples
- Add troubleshooting sections
- Test all commands
- Update navigation in `mkdocs.yml`

### Preview Documentation

```powershell
# Serve locally
mkdocs serve

# Build static site
mkdocs build
```

See [Local Development Guide](../LOCAL_DEVELOPMENT.md).

## Code Review

### What We Look For

- ✅ Code quality (PSScriptAnalyzer)
- ✅ Functionality (does it work?)
- ✅ Documentation (is it documented?)
- ✅ Tests (is it tested?)
- ✅ Maintainability (can others understand it?)

### Review Process

1. Automated checks run (GitHub Actions)
2. Maintainer reviews code
3. Feedback provided
4. You make changes
5. Approved and merged

## Getting Help

- **Questions:** Open a Discussion
- **Bugs:** Open an Issue
- **Feature Ideas:** Open an Issue for discussion

## Resources

- [Developer Reference](developer-reference.md) - Command cheatsheet
- [Testing Guide](testing.md) - Testing procedures
- [Architecture](../architecture/overview.md) - System design

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Provide constructive feedback
- Focus on the code, not the person

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
