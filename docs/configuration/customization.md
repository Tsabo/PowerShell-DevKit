# Customization Guide

PowerShell DevKit is designed to be easily customizable while maintaining update safety.

## Customization Layers

### 1. Git-Tracked (Shared)

Files in the repository that can be modified and shared:

- `Config/oh-my-posh/*.omp.json` - Prompt themes
- `Config/WindowsTerminal/settings.json` - Terminal settings
- `PowerShell/IncludedModules/*.psm1` - Bundled modules

**Workflow:**

1. Modify files
2. Commit changes
3. Push to your fork
4. Share with team/community

### 2. User-Specific (Local)

Files that are git-ignored for personal customization:

- `PowerShell/CustomModules/*.psm1` - Your custom modules
- `PowerShell/CustomProfile.ps1` - Your personal profile additions

**Workflow:**

1. Create files
2. Customize freely
3. Updates won't overwrite
4. Backup separately if needed

### 3. External (Configuration)

Yazi configuration in separate repository:

- Fork https://github.com/Tsabo/yazi_config
- Point Setup.ps1 to your fork
- Manage independently

## Common Customizations

### Change Prompt Theme

**Option 1: Use Different Built-in Theme**

```powershell
# Edit $PROFILE
code $PROFILE

# Find line:
oh-my-posh init pwsh --config "...\iterm2.omp.json" | Invoke-Expression

# Change to:
oh-my-posh init pwsh --config "$(oh-my-posh get shell-themes-path)\jandedobbeleer.omp.json" | Invoke-Expression
```

**Option 2: Create Custom Theme**

```powershell
# Export current theme
oh-my-posh config export --output "Config\oh-my-posh\mytheme.omp.json"

# Edit theme
code Config\oh-my-posh\mytheme.omp.json

# Update profile to use it
oh-my-posh init pwsh --config "$PSScriptRoot\..\..\Config\oh-my-posh\mytheme.omp.json" | Invoke-Expression
```

Browse themes: https://ohmyposh.dev/docs/themes

### Add Custom Functions

**Option 1: CustomProfile.ps1 (For simple functions)**

```powershell
# Create from template
Copy-Item "PowerShell\CustomProfile.ps1.template" "PowerShell\CustomProfile.ps1"

# Edit
code PowerShell\CustomProfile.ps1

# Add functions
function MyFunction {
    param([string]$Name)
    Write-Host "Hello, $Name!"
}
```

**Option 2: Custom Module (For organized code)**

```powershell
# Create module file
New-Item -Path "PowerShell\CustomModules\MyTools.psm1" -ItemType File

# Edit module
code PowerShell\CustomModules\MyTools.psm1
```

```powershell
# MyTools.psm1

function Get-MyData {
    [CmdletBinding()]
    param([string]$Source)

    # Your code
}

function Set-MyData {
    [CmdletBinding()]
    param([string]$Value)

    # Your code
}

# Export functions
Export-ModuleMember -Function Get-MyData, Set-MyData
```

Functions are automatically available in new sessions.

### Customize Yazi

**Option 1: Fork Configuration Repository**

1. Fork https://github.com/Tsabo/yazi_config
2. Modify `Scripts/Components.psm1`:

```powershell
Properties = @{
    ConfigRepo = "https://github.com/YourUsername/yazi_config.git"
    ConfigPath = "$env:APPDATA\yazi"
}
```

3. Run Setup.ps1 to clone your fork

**Option 2: Local Modifications**

```powershell
# Edit configuration
code $env:APPDATA\yazi\config\yazi.toml

# Stash before updates
cd $env:APPDATA\yazi
git stash
git pull
git stash pop
```

### Add Custom Aliases

In `CustomProfile.ps1`:

```powershell
# Git shortcuts
Set-Alias -Name g -Value git
Set-Alias -Name gs -Value Get-GitStatus

# Navigation
Set-Alias -Name .. -Value Set-LocationUp
function Set-LocationUp { Set-Location .. }

# Tools
Set-Alias -Name v -Value code
```

### Modify Key Bindings

**PSReadLine (PowerShell):**

In `CustomProfile.ps1`:

```powershell
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteChar
Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardDeleteWord
```

**Yazi:**

Edit `$env:APPDATA\yazi\config\keymap.toml`:

```toml
[manager]
prepend_keymap = [
  { on = [ "<C-n>" ], exec = "create" },
  { on = [ "<C-r>" ], exec = "rename" },
]
```

## Advanced Customizations

### Add New Components

Edit `Scripts/Components.psm1`:

```powershell
@{
    Name = "MyTool"
    Type = "winget"
    IsOptional = $false
    Properties = @{
        PackageId = "Publisher.MyTool"
    }
}
```

Now Setup.ps1, Test.ps1, and Update.ps1 will handle it automatically.

### Custom Installation Logic

For complex components:

```powershell
@{
    Name = "CustomTool"
    Type = "custom"
    IsOptional = $false
    CustomInstaller = {
        param($Component)

        # Your installation logic
        Write-Host "Installing CustomTool..."
        # Download, extract, configure, etc.

        return $true  # or $false
    }
    CustomValidator = {
        param($Component)

        # Your validation logic
        $installed = Test-Path "C:\Tools\CustomTool.exe"

        return @{
            IsInstalled = $installed
            Version = if ($installed) { "1.0.0" } else { $null }
        }
    }
}
```

### Environment Variables

In `CustomProfile.ps1`:

```powershell
# Development paths
$env:DEV_ROOT = "C:\Dev"
$env:PROJECTS = "$env:DEV_ROOT\Projects"

# API keys (use secure storage in production)
$env:MY_API_KEY = "key-value"

# Tool configuration
$env:EDITOR = "code"
$env:VISUAL = "code"
```

## Best Practices

### 1. Use Layers Appropriately

- **Shared changes** → Git-tracked files
- **Personal preferences** → CustomProfile.ps1
- **Reusable code** → CustomModules
- **Temporary experiments** → Don't commit

### 2. Test Before Committing

```powershell
# Test profile
. $PROFILE

# Validate code
.\Scripts\Validate-Code.ps1

# Test environment
.\Scripts\Test.ps1
```

### 3. Document Customizations

Add comments explaining why:

```powershell
# Workaround for company proxy
$env:HTTP_PROXY = "http://proxy.company.com:8080"

# Custom function for deployment workflow
function Deploy-ToStaging {
    # Deploys current branch to staging environment
    # ...
}
```

### 4. Backup Custom Files

CustomProfile.ps1 and CustomModules are git-ignored, so backup separately:

```powershell
# Backup script
$backup = "C:\Backups\PowerShell-Custom-$(Get-Date -Format 'yyyyMMdd').zip"
Compress-Archive -Path "PowerShell\Custom*" -DestinationPath $backup
```

## Update Safety

### What Gets Preserved

- ✅ CustomProfile.ps1
- ✅ CustomModules/
- ✅ Local Yazi modifications (with stash)

### What Gets Updated

- ✅ Main profile template
- ✅ IncludedModules/
- ✅ Components.psm1
- ✅ Setup/Test/Update scripts

### Safe Update Process

```powershell
# 1. Backup custom files
# 2. Pull updates
git pull

# 3. Review changes
git diff

# 4. Re-run setup if needed
.\Scripts\Setup.ps1

# 5. Reload profile
. $PROFILE

# 6. Test
.\Scripts\Test.ps1
```

## See Also

- [Custom Modules Guide](custom-modules.md)
- [Custom Profile Guide](custom-profile.md)
- [Theme Customization](themes.md)
- [Architecture Overview](../architecture/overview.md)
