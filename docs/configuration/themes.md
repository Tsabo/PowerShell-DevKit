# Theme Customization

Customize the visual appearance of your PowerShell environment.

## oh-my-posh Themes

### Browse Available Themes

Visit: https://ohmyposh.dev/docs/themes

### Preview a Theme

```powershell
# Preview theme temporarily
oh-my-posh init pwsh --config "$(oh-my-posh get shell-themes-path)\jandedobbeleer.omp.json" | Invoke-Expression
```

Reload profile to return to default.

### Change Default Theme

**Edit your profile:**

```powershell
code $PROFILE
```

**Find and modify:**

```powershell
# Change this line
oh-my-posh init pwsh --config "$PSScriptRoot\..\..\Config\oh-my-posh\iterm2.omp.json" | Invoke-Expression

# To use built-in theme
oh-my-posh init pwsh --config "$(oh-my-posh get shell-themes-path)\paradox.omp.json" | Invoke-Expression

# Or custom theme in Config folder
oh-my-posh init pwsh --config "$PSScriptRoot\..\..\Config\oh-my-posh\mytheme.omp.json" | Invoke-Expression
```

### Create Custom Theme

#### 1. Export Current Theme

```powershell
oh-my-posh config export --output "Config\oh-my-posh\mytheme.omp.json"
```

#### 2. Edit Theme

```powershell
code Config\oh-my-posh\mytheme.omp.json
```

#### 3. Test Theme

```powershell
oh-my-posh init pwsh --config ".\Config\oh-my-posh\mytheme.omp.json" | Invoke-Expression
```

#### 4. Make Permanent

Update `$PROFILE` to use your custom theme.

### Theme Structure

Basic theme JSON:

```json
{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "version": 2,
  "final_space": true,
  "console_title_template": "{{ .Shell }} in {{ .Folder }}",
  "blocks": [
    {
      "type": "prompt",
      "alignment": "left",
      "segments": [
        {
          "type": "path",
          "style": "powerline",
          "powerline_symbol": "\uE0B0",
          "foreground": "#ffffff",
          "background": "#61AFEF",
          "properties": {
            "style": "folder"
          }
        },
        {
          "type": "git",
          "style": "powerline",
          "powerline_symbol": "\uE0B0",
          "foreground": "#193549",
          "background": "#95ffa4",
          "properties": {
            "display_status": true
          }
        }
      ]
    }
  ]
}
```

## Windows Terminal Themes

### Built-in Schemes

Windows Terminal includes many color schemes:

1. Open Settings (`Ctrl+,`)
2. Profiles → Defaults → Appearance
3. Color scheme: Select from dropdown

### Custom Color Scheme

**Edit settings.json:**

```json
{
  "schemes": [
    {
      "name": "My Custom Theme",
      "background": "#1E1E1E",
      "foreground": "#D4D4D4",
      "black": "#000000",
      "blue": "#0037DA",
      "cyan": "#3A96DD",
      "green": "#13A10E",
      "purple": "#881798",
      "red": "#C50F1F",
      "white": "#CCCCCC",
      "yellow": "#C19C00",
      "brightBlack": "#767676",
      "brightBlue": "#3B78FF",
      "brightCyan": "#61D6D6",
      "brightGreen": "#16C60C",
      "brightPurple": "#B4009E",
      "brightRed": "#E74856",
      "brightWhite": "#F2F2F2",
      "brightYellow": "#F9F1A5"
    }
  ]
}
```

**Apply the scheme:**

1. Settings → Profiles → Defaults → Appearance
2. Color scheme: "My Custom Theme"

## Yazi Themes

### Available Themes

- vscode-dark-plus (default)
- flexoki-light

### Switch Theme

**Edit:** `$env:APPDATA\yazi\config\theme.toml`

```toml
# Use dark theme
use = "~/.config/yazi/flavors/vscode-dark-plus.yazi"

# Or light theme
# use = "~/.config/yazi/flavors/flexoki-light.yazi"
```

### Install Additional Themes

Browse: https://github.com/yazi-rs/flavors

```powershell
# Install theme
ya pkg add "username/theme-name"

# Update theme.toml to use it
code $env:APPDATA\yazi\config\theme.toml
```

## See Also

- [oh-my-posh Component](../components/oh-my-posh.md)
- [Windows Terminal Component](../components/terminal.md)
- [Yazi Component](../components/yazi.md)
- [Customization Guide](customization.md)
