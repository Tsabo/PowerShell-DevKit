# Linux / WSL Setup Guide

Complete guide for setting up PowerShell DevKit on Ubuntu, including WSL (Windows Subsystem for Linux).

## Overview

PowerShell DevKit supports Ubuntu (and compatible Debian-based distributions) running either natively or inside WSL2. The Linux setup uses `apt` for system packages and official install scripts for tools not available in the Ubuntu repositories.

!!! note "WSL2 Recommended"
    If you're on Windows, using WSL2 gives you the best of both worlds: a full Ubuntu environment with access to Windows binaries and the same Windows Terminal you'd configure for the Windows setup.

## Prerequisites

| Requirement | Details |
|-------------|---------|
| **Distribution** | Ubuntu 22.04 LTS or later (Debian-based) |
| **PowerShell** | 7.0+ — install via [Microsoft's instructions](https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu) |
| **WSL version** | WSL2 (if running under Windows) |
| **git** | `sudo apt-get install git` |
| **curl / unzip** | `sudo apt-get install curl unzip` |
| **Internet** | Required for downloads |

### Install PowerShell on Ubuntu

```bash
# Microsoft's official one-liner for Ubuntu
curl -fsSL https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb \
  -o /tmp/packages-microsoft-prod.deb
sudo dpkg -i /tmp/packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell
```

Then launch it:

```bash
pwsh
```

## Quick Start

```bash
# 1. Clone the repository (inside WSL / Ubuntu)
git clone https://github.com/Tsabo/PowerShell-DevKit.git
cd PowerShell-DevKit

# 2. Run the Linux setup (from within pwsh)
pwsh -File ./Scripts/Setup-Linux.ps1

# — or, if you're already in a pwsh session —
./Scripts/Setup-Linux.ps1

# 3. Validate the installation
./Scripts/Test-Linux.ps1

# 4. Keep everything updated
./Scripts/Update-Linux.ps1
```

## What Gets Installed

| Component | Source | Notes |
|-----------|--------|-------|
| **oh-my-posh** | Official install script | Placed in `~/.local/bin` |
| **fzf** | apt | `sudo apt-get install fzf` |
| **zoxide** | Official install script | Placed in `~/.local/bin` |
| **glow** | charm.sh apt repo | Adds `/etc/apt/sources.list.d/charm.list` |
| **yazi** | GitHub releases | Placed in `~/.local/bin` |
| **ya** | GitHub releases | Yazi package manager (bundled with yazi) |
| **PSFzf** | PSGallery | Current user scope |
| **Terminal-Icons** | PSGallery | Current user scope |
| **F7History** | PSGallery | Current user scope |
| **posh-git** | PSGallery | Current user scope |
| **PowerColorLS** | PSGallery | Optional |
| **Yazi optional deps** | apt | ffmpeg, 7zip, jq, poppler-utils, fd-find, ripgrep, imagemagick |
| **Yazi config** | Git | Cloned to `~/.config/yazi` |
| **Yazi plugins** | ya pkg | git, githead, flexoki-light, vscode-dark-plus |

### What is *not* installed on Linux

| Component | Reason |
|-----------|--------|
| **CascadiaCode Font** | Fonts live on the Windows side in WSL; no display server in headless Linux |
| **Microsoft Edit** | Windows-only binary |
| **gsudo** | Use `sudo` instead |
| **Scoop / resvg** | Windows-only package manager |
| **Windows Terminal** | Windows-side configuration |

## Fonts in WSL

WSL runs inside Windows Terminal, so fonts are configured on the **Windows** side. The `CaskaydiaCove Nerd Font` must be installed on Windows for icons to display correctly.

**Option A — Run the Windows setup first (recommended):**

```powershell
# On Windows (PowerShell), from the same repo:
.\Scripts\Setup.ps1
```

This installs the font automatically.

**Option B — Install manually on Windows:**

```powershell
# On Windows PowerShell
oh-my-posh font install CascadiaCode
```

Then configure Windows Terminal:

1. Open **Windows Terminal** → Settings → **Profiles** → **Defaults** → **Appearance**
2. Set **Font face** to `CaskaydiaCove Nerd Font Mono`
3. Restart Windows Terminal

## Configuration Paths on Linux

| Configuration | Path |
|---------------|------|
| PowerShell Profile | `~/.config/powershell/Microsoft.PowerShell_profile.ps1` |
| oh-my-posh Themes | `~/.config/powershell/Posh/` |
| Yazi Config | `~/.config/yazi/` |
| Binaries | `~/.local/bin/` |

!!! tip "`~/.local/bin` on PATH"
    The setup script adds `~/.local/bin` to the current session's `$env:PATH`. To make this permanent in bash/zsh, add the following to `~/.bashrc` or `~/.zshrc`:
    ```bash
    export PATH="$HOME/.local/bin:$PATH"
    ```

## Updating

```bash
# Inside pwsh:
./Scripts/Update-Linux.ps1

# Update only apt packages and binaries
./Scripts/Update-Linux.ps1 -AptOnly

# Update only PowerShell modules
./Scripts/Update-Linux.ps1 -ModulesOnly

# Update only Yazi plugins and config
./Scripts/Update-Linux.ps1 -YaziOnly
```

## Troubleshooting

### Icons not showing (boxes / question marks)

This is always a font issue in WSL.

1. Ensure the **CaskaydiaCove Nerd Font** is installed on **Windows** (see [Fonts in WSL](#fonts-in-wsl) above).
2. In Windows Terminal: Settings → Profiles → Defaults → Appearance → Font face = `CaskaydiaCove Nerd Font Mono`.
3. Restart Windows Terminal.

### `oh-my-posh` or `zoxide` not found after setup

The binaries are installed to `~/.local/bin`. If that directory isn't on your shell's PATH, they won't be found.

```bash
# Check if ~/.local/bin is on PATH
echo $PATH | grep -o "$HOME/.local/bin"

# Add it if missing (bash)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

The PowerShell profile auto-adds the path for `pwsh` sessions, but your login shell (bash/zsh) needs it too if you launch `pwsh` interactively.

### `sudo` not available or prompts for password

The setup script uses `sudo` for system-level operations. If sudo isn't configured:

```bash
# Check sudo access
sudo -v

# If not in sudo group:
su -c "usermod -aG sudo $USER"
# Then log out and back in
```

### Yazi displays no previews

Install the optional dependencies:

```bash
sudo apt-get install ffmpeg p7zip-full jq poppler-utils fd-find ripgrep imagemagick
```

Or re-run the setup:

```bash
./Scripts/Setup-Linux.ps1
```

### `apt-get update` fails (corporate proxy / restricted network)

Configure apt proxy settings:

```bash
# /etc/apt/apt.conf.d/99proxy
Acquire::http::Proxy "http://your-proxy:port/";
Acquire::https::Proxy "http://your-proxy:port/";
```

### WSL2 networking issues

```bash
# Reset WSL network adapter (run in PowerShell on Windows)
netsh winsock reset
# Then restart WSL
wsl --shutdown
```

## Differences vs Windows / macOS

| Feature | Windows | macOS | Linux / WSL |
|---------|---------|-------|-------------|
| Package manager | winget | Homebrew | apt + install scripts |
| Font installation | oh-my-posh font install | brew cask | On Windows side |
| Terminal deployment | ✅ Auto | N/A | N/A (use Windows Terminal |
| gsudo | ✅ Optional | ❌ | ❌ (use sudo) |
| Scoop / resvg | ✅ Optional | ❌ | ❌ |
| Microsoft Edit | ✅ | ✅ (brew) | ❌ |
| Default shell change | N/A | ✅ (chsh) | Optional (chsh) |
| Profile path | `$PROFILE` (Documents) | `~/.config/powershell/` | `~/.config/powershell/` |

## See Also

- [Installation Guide](installation.md)
- [Requirements](requirements.md)
- [macOS Setup Guide](macos-setup.md)
- [oh-my-posh Component](../components/oh-my-posh.md)
- [Troubleshooting](../troubleshooting.md)
