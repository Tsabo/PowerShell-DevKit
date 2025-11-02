# Yazi File Manager

Yazi is a blazing-fast terminal file manager built with modern technologies.

## Overview

**Features:**

- ⚡ Lightning-fast performance
- 🖼️ Image and video previews
- 📁 Archive browsing
- 🔌 Plugin system
- 🎨 Theme support
- ⌨️ Vim-like keybindings
- 🔄 Git integration

## Installation

Yazi is automatically installed by Setup.ps1 along with its complete ecosystem.

## Configuration

### Git-Managed Configuration

Yazi configuration is managed via a separate git repository:

**Repository:** https://github.com/Tsabo/yazi_config

**Location:** `%APPDATA%\yazi\`

**Files:**

```
%APPDATA%\yazi/
├── config/
│   ├── yazi.toml      # Main configuration
│   ├── keymap.toml    # Keybindings
│   ├── theme.toml     # Theme selection
│   └── init.lua       # Lua initialization
├── plugins/           # Auto-installed plugins
│   ├── git.yazi/
│   └── githead.yazi/
└── flavors/           # Auto-installed themes
    ├── flexoki-light.yazi/
    └── vscode-dark-plus.yazi/
```

## Usage

### Launch Yazi

```powershell
# Standard mode
yazi

# With directory change on exit (recommended)
y
```

The `y` function allows Yazi to change your PowerShell directory when you quit.

### Navigation

| Key | Action |
|-----|--------|
| `j` / `↓` | Move down |
| `k` / `↑` | Move up |
| `h` / `←` | Go to parent directory |
| `l` / `→` / `Enter` | Enter directory or open file |
| `g` + `g` | Go to top |
| `G` | Go to bottom |

### File Operations

| Key | Action |
|-----|--------|
| `Space` | Select/deselect file |
| `c` | Copy selected files |
| `x` | Cut selected files |
| `p` | Paste files |
| `d` | Delete selected files |
| `r` | Rename file |
| `a` | Create new file |
| `o` | Open file with default app |

### Search and Navigation

| Key | Action |
|-----|--------|
| `/` | Search in current directory |
| `n` | Next search result |
| `N` | Previous search result |
| `z` | Jump to directory (uses zoxide) |
| `q` | Quit |

## Plugins

### Installed Plugins

#### git.yazi

Displays git status for files:

- 🟢 Added files
- 🟡 Modified files
- 🔴 Deleted files
- ⚪ Untracked files

**Source:** https://github.com/yazi-rs/plugins

#### githead.yazi (Custom Fork)

Enhanced git information in header.

**Source:** https://github.com/Tsabo/githead.yazi

**Features:**

- Current branch
- Commit information
- Repository status
- Bug fixes for edge cases

### Managing Plugins

```powershell
# List installed plugins
ya pkg list

# Update all plugins
ya pkg update

# Add new plugin
ya pkg add "username/plugin-name"

# Remove plugin
ya pkg remove "plugin-name"
```

## Themes

### Installed Themes

- **vscode-dark-plus** - Dark theme matching VS Code
- **flexoki-light** - Light theme option

### Changing Theme

Edit `%APPDATA%\yazi\config\theme.toml`:

```toml
# Use vscode-dark-plus (default)
use = "~/.config/yazi/flavors/vscode-dark-plus.yazi"

# Or use flexoki-light
# use = "~/.config/yazi/flavors/flexoki-light.yazi"
```

### Installing New Themes

```powershell
# Browse themes: https://github.com/yazi-rs/flavors

# Install theme
ya pkg add "username/theme-name"
```

## Optional Dependencies

For enhanced functionality, these are auto-installed by Setup.ps1:

### Media Support

| Tool | Purpose |
|------|---------|
| FFmpeg | Video thumbnails |
| ImageMagick | Image processing |
| Poppler | PDF previews |
| resvg | SVG rendering (via Scoop) |

### Archive Support

| Tool | Purpose |
|------|---------|
| 7-Zip | Archive extraction/previews |

### Search & Processing

| Tool | Purpose |
|------|---------|
| jq | JSON formatting |
| fd | Fast file search |
| ripgrep | Text search |

### Manual Installation

If not installed automatically:

```powershell
# Run the installation function
Install-YaziOptionals

# Or install specific tools
winget install Gyan.FFmpeg
winget install 7zip.7zip
winget install jqlang.jq
```

## Configuration Updates

### Automatic Updates

Run Update.ps1 to sync configuration:

```powershell
.\Scripts\Update.ps1
```

This will:

1. Update Yazi plugins via `ya pkg update`
2. Sync configuration repository via `git pull`

### Manual Updates

```powershell
# Update plugins
ya pkg update

# Update configuration
cd $env:APPDATA\yazi
git pull
```

### Custom Modifications

If you modify configuration locally:

```powershell
cd $env:APPDATA\yazi
git stash              # Save changes
git pull               # Update
git stash pop          # Restore changes
```

## Advanced Configuration

### Custom Keybindings

Edit `%APPDATA%\yazi\config\keymap.toml`:

```toml
[manager]
prepend_keymap = [
  { on = [ "<C-n>" ], exec = "create" },
  { on = [ "<C-d>" ], exec = "remove" },
]
```

### Lua Initialization

Edit `%APPDATA%\yazi\config\init.lua` for advanced customization.

## Troubleshooting

### Previews Not Working

**Issue:** No file previews

**Solution:**

```powershell
# Install optional dependencies
Install-YaziOptionals

# Or manually install specific tools
winget install Gyan.FFmpeg
winget install ImageMagick.ImageMagick
```

### Plugins Not Loading

**Issue:** Plugins don't appear active

**Solution:**

```powershell
# Reinstall plugins
ya pkg update

# Check plugin list
ya pkg list

# If missing, reinstall
ya pkg add "yazi-rs/plugins:git"
```

### Configuration Not Updating

**Issue:** Changes to config not reflected

**Solution:**

- Restart Yazi completely
- Check for syntax errors in TOML files
- Reload configuration: `:reload` in Yazi

### SVG Previews Not Working

**Issue:** SVG files show no preview

**Solution:**

```powershell
# Install Scoop (if not installed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# Install resvg
scoop install resvg
```

## Resources

- [Official Documentation](https://yazi-rs.github.io/)
- [Plugin Repository](https://github.com/yazi-rs/plugins)
- [Theme Repository](https://github.com/yazi-rs/flavors)
- [Configuration Repository](https://github.com/Tsabo/yazi_config)

## See Also

- [Components Overview](overview.md)
- [Optional Components](optional.md)
- [Customization Guide](../configuration/customization.md)
