# oh-my-posh

oh-my-posh is a prompt theme engine that makes your terminal beautiful and informative.

## Overview

oh-my-posh provides:

- Beautiful, customizable prompts
- Git status integration
- Execution time display
- Error indicators
- Cross-platform support

## Installation

oh-my-posh is automatically installed by Setup.ps1:

```powershell
.\Scripts\Setup.ps1
```

## Configuration

### Theme Location

Themes are stored in:

```
Config/oh-my-posh/
├── iterm2.omp.json       # Default theme
└── paradox.omp.json      # Alternative theme
```

### Current Theme

The active theme is configured in your PowerShell profile:

```powershell
# Located in: $PROFILE
oh-my-posh init pwsh --config "$env:USERPROFILE\Documents\PowerShell-DevKit\Config\oh-my-posh\iterm2.omp.json" | Invoke-Expression
```

## Changing Themes

### Use Built-in Theme

```powershell
# Preview a theme
oh-my-posh init pwsh --config "$(oh-my-posh get shell-themes-path)/jandedobbeleer.omp.json" | Invoke-Expression

# Make permanent: Edit $PROFILE
code $PROFILE
# Change the --config path
```

### Browse Available Themes

Visit: https://ohmyposh.dev/docs/themes

### Use Custom Theme

1. **Export current theme:**
```powershell
oh-my-posh config export --output "$env:USERPROFILE\Documents\PowerShell-DevKit\Config\oh-my-posh\mytheme.omp.json"
```

2. **Edit theme:**
```powershell
code "$env:USERPROFILE\Documents\PowerShell-DevKit\Config\oh-my-posh\mytheme.omp.json"
```

3. **Update profile:**
```powershell
# Edit $PROFILE to point to your custom theme
oh-my-posh init pwsh --config "$env:USERPROFILE\Documents\PowerShell-DevKit\Config\oh-my-posh\mytheme.omp.json" | Invoke-Expression
```

## Font Requirements

oh-my-posh requires a Nerd Font for icons and symbols.

**Installed automatically:** CaskaydiaCove Nerd Font Mono

**Configure in Windows Terminal:**

1. Settings → Profiles → Defaults → Appearance
2. Font face: "CaskaydiaCove Nerd Font Mono"

## Theme Elements

### Git Segment

Shows:

- Current branch
- Working directory status (clean/dirty)
- Ahead/behind remote
- Stash count

### Path Segment

Shows:

- Current directory
- Shortened path for deep directories
- Home directory symbol (~)

### Execution Time

Shows duration of last command if it took > 2 seconds.

### Error Indicator

Red prompt segment when last command failed.

## Customization

### Theme JSON Structure

```json
{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "blocks": [
    {
      "type": "prompt",
      "segments": [
        {
          "type": "path",
          "style": "powerline",
          "properties": {
            "style": "folder"
          }
        }
      ]
    }
  ]
}
```

### Adding Segments

See official documentation: https://ohmyposh.dev/docs/configuration/segment

### Color Schemes

Customize colors in theme JSON:

```json
{
  "background": "#003543",
  "foreground": "#3C873A",
  "powerline_symbol": "\uE0B0"
}
```

## Troubleshooting

### Icons Not Showing

**Issue:** Boxes or weird characters instead of icons

**Solution:**

1. Install Nerd Font: `oh-my-posh font install CascadiaCode`
2. Configure terminal to use the font
3. Restart terminal

### Slow Prompt

**Issue:** Prompt takes time to appear

**Solution:**

- Simplify theme (remove expensive segments)
- Disable git status in large repositories
- Use minimal theme

### Git Status Not Showing

**Issue:** Git branch/status not visible

**Solution:**

- Ensure git is installed: `git --version`
- Ensure you're in a git repository
- Check theme includes git segment

## Resources

- [Official Documentation](https://ohmyposh.dev/)
- [Theme Gallery](https://ohmyposh.dev/docs/themes)
- [Segment Documentation](https://ohmyposh.dev/docs/configuration/segment)

## See Also

- [Components Overview](overview.md)
- [PowerShell Profile](powershell.md)
- [Windows Terminal](terminal.md)
