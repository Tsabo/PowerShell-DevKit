# Windows Terminal Configuration

Windows Terminal provides a modern, feature-rich terminal experience for PowerShell and other shells.

## Overview

The DevKit provides a pre-configured Windows Terminal settings file optimized for development.

**Source:** `Config/WindowsTerminal/settings.json`

**Destination:** `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`

## Features

- **Nerd Font configured** - Icons and symbols work out of the box
- **Custom color schemes** - Professional, easy-on-the-eyes themes
- **Optimized defaults** - Sensible settings for development
- **Backup on deploy** - Original settings preserved

## Deployment

### Automatic

```powershell
.\Scripts\Deploy-Terminal.ps1
```

Creates backup and deploys configuration.

### Manual

1. Open Windows Terminal
2. Settings (`Ctrl+,`)
3. Open JSON file (bottom-left corner)
4. Copy content from `Config/WindowsTerminal/settings.json`

## Configuration

### Font Settings

```json
{
  "defaults": {
    "font": {
      "face": "CaskaydiaCove Nerd Font Mono",
      "size": 10
    }
  }
}
```

### Color Schemes

Custom schemes are included and can be activated in the appearance settings.

### Window Settings

- Transparency options
- Acrylic background
- Startup size

## Customization

### Change Font Size

1. Settings → Profiles → Defaults → Appearance
2. Font size: Adjust as needed

### Change Color Scheme

1. Settings → Profiles → Defaults → Appearance
2. Color scheme: Select from dropdown

### Add Custom Scheme

Edit settings.json:

```json
{
  "schemes": [
    {
      "name": "MyCustomScheme",
      "background": "#1e1e1e",
      "foreground": "#cccccc",
      // ... other colors
    }
  ]
}
```

## See Also

- [Components Overview](overview.md)
- [Customization Guide](../configuration/customization.md)
