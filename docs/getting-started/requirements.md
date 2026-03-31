# Requirements & Dependencies

This page provides a comprehensive overview of what you need to run PowerShell DevKit.

## System Requirements

### Operating System
- **Windows 10** (version 1903 or later)
- **Windows 11** (all versions)
- **Windows Server 2019/2022**
- **Ubuntu 22.04 LTS+** (WSL2 or bare metal) — Debian-based distros also supported
- **macOS 10.15+** (Catalina or later)

### PowerShell
- **PowerShell 7.0+** (automatically installed if missing)
- **PowerShell Core 6.x** also supported

!!! info "PowerShell Auto-Install"
    If you're running Windows PowerShell 5.1, the setup will automatically download and install PowerShell 7 for you.

### Permissions
- **Standard User** - Most features will work
- **Administrator** - Recommended for complete installation

### Disk Space
- **Minimum**: 500 MB
- **Recommended**: 1 GB (includes all optional components)

### Network
- **Internet Connection** - Required for package downloads
- **GitHub Access** - For repository cloning and updates

## Required Dependencies

These are installed automatically by the setup script:

### Package Managers
- **winget** - Windows Package Manager (built into Windows 10/11)
- **apt** - Ubuntu/Debian package manager (Linux)
- **Homebrew** - macOS package manager (macOS)

### Core Tools
| Tool | Size | Purpose |
|------|------|---------|
| oh-my-posh | ~15 MB | Prompt theming engine |
| Yazi | ~8 MB | Terminal file manager |
| fzf | ~3 MB | Fuzzy finder |
| zoxide | ~2 MB | Smart directory navigation |

### PowerShell Modules
All installed from PowerShell Gallery:
- PSFzf
- Terminal-Icons
- F7History
- posh-git

## Optional Dependencies

### For Enhanced Features
| Component | Purpose | Installation |
|-----------|---------|--------------|
| **gsudo** | Elevated permissions | Optional during setup |
| **Microsoft Edit** | Text editor | Installed by default (Linux: downloaded from GitHub release to `~/.local/bin`) |

### For Yazi Enhanced Functionality
| Component | Purpose | Size |
|-----------|---------|------|
| **FFmpeg** | Video thumbnails | ~80 MB |
| **7-Zip** | Archive previews | ~2 MB |
| **jq** | JSON processing | ~3 MB |
| **Poppler** | PDF support | ~15 MB |
| **fd** | Fast file search | ~3 MB |
| **ripgrep** | Text search | ~2 MB |
| **ImageMagick** | Image processing | ~30 MB |

!!! tip "Selective Installation"
    You can skip optional Yazi dependencies during setup and install them later with:
    ```powershell
    Install-YaziOptionals
    ```

### For SVG Support in Yazi

=== "Windows"
    ```powershell
    # Optional: Install Scoop and resvg for SVG thumbnails
    scoop bucket add extras
    scoop install resvg
    ```

=== "macOS"
    ```bash
    brew install resvg
    ```

=== "Linux / WSL"
    ```bash
    # Via Cargo (requires Rust)
    cargo install resvg

    # Or check your distro's package manager
    sudo apt-get install resvg
    ```

## Development Dependencies

Only needed if you're contributing:

### For Documentation
```powershell
pip install mkdocs-material
pip install mkdocs-git-revision-date-localized-plugin
```

### For Testing
- PSScriptAnalyzer (installed automatically)

## Compatibility Notes

### Terminal Emulators
Works best with:
- ✅ **Windows Terminal** (Recommended on Windows, configured automatically)
- ✅ **Windows Terminal Preview**
- ✅ **Windows Terminal (WSL profile)** — recommended for Linux / WSL
- ✅ **iTerm2** — recommended for macOS
- ⚠️ **ConEmu** (Some features may not work)
- ⚠️ **Console2** (Limited support)
- ❌ **cmd.exe** (Not supported, use PowerShell)

### Font Requirements
The setup installs **CascadiaCode** Nerd Font automatically, which includes:
- Programming ligatures
- Powerline symbols
- Nerd Font icons
- Box drawing characters

### Git
- **Not required** for basic functionality
- **Recommended** for git status in prompt
- Used for Yazi configuration updates

## Network Firewall Considerations

The setup needs to access:
- `winget.microsoft.com` - Package downloads
- `github.com` - Repository cloning
- `raw.githubusercontent.com` - Raw file access
- `www.powershellgallery.com` - Module downloads

!!! warning "Corporate Networks"
    If you're behind a corporate firewall, you may need to:
    - Configure proxy settings
    - Request firewall exceptions
    - Use internal package repositories

## Next Steps

Ready to install? Head to the [Installation Guide](installation.md).
