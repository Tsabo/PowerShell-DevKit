# Optional Components

PowerShell DevKit includes several optional components that enhance functionality but aren't required for core features.

## Overview

Optional components can be skipped during installation:

```powershell
.\Scripts\Setup.ps1 -SkipOptional
```

## Components

### gsudo

**Purpose:** Elevated permissions without leaving current terminal

**Installation:** Automatic (unless skipped)

**Usage:**

```powershell
# Run command as administrator
gsudo Get-Service

# Open elevated PowerShell session
gsudo pwsh
```

**Manual installation:**

```powershell
winget install gerardog.gsudo
```

### PowerColorLS

**Purpose:** Colorized directory listings

**Installation:** Optional PowerShell module

**Usage:**

```powershell
# Enhanced ls
PowerColorLS
```

**Manual installation:**

```powershell
Install-Module -Name PowerColorLS -Scope CurrentUser
```

### Scoop

**Purpose:** Command-line package manager

**Why optional:** Primarily needed for resvg (SVG support in Yazi)

**Installation:**

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

### resvg

**Purpose:** SVG thumbnail rendering in Yazi

**Requires:** Scoop

**Installation:**

```powershell
scoop install resvg
```

## Yazi Optional Dependencies

### Media Support

**FFmpeg** - Video thumbnails

```powershell
winget install Gyan.FFmpeg
```

**ImageMagick** - Image processing

```powershell
winget install ImageMagick.ImageMagick
```

**Poppler** - PDF previews

```powershell
winget install oschwartz10612.Poppler
```

### Archive Support

**7-Zip** - Archive previews

```powershell
winget install 7zip.7zip
```

### Utilities

**jq** - JSON processing

```powershell
winget install jqlang.jq
```

**fd** - Fast file search

```powershell
winget install sharkdp.fd
```

**ripgrep** - Text search

```powershell
winget install BurntSushi.ripgrep.MSVC
```

## Bulk Installation

Install all Yazi optional dependencies:

```powershell
# Function available after Setup.ps1
Install-YaziOptionals

# Just dependencies (no plugins)
Install-YaziOptionals -DependenciesOnly

# Just plugins (no dependencies)
Install-YaziOptionals -PluginsOnly
```

## See Also

- [Components Overview](overview.md)
- [Yazi Documentation](yazi.md)
