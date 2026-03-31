# PowerShell-DevKit

> **Keep your PowerShell development environments perfectly synchronized across all your machines - Windows, macOS, and Ubuntu / WSL**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PowerShell 7+](https://img.shields.io/badge/PowerShell-7+-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Windows](https://img.shields.io/badge/Platform-Windows-blue.svg)](https://www.microsoft.com/windows)
[![macOS](https://img.shields.io/badge/Platform-macOS-silver.svg)](https://www.apple.com/macos)
[![Linux WSL](https://img.shields.io/badge/Platform-Linux%20%2F%20WSL-orange.svg)](https://learn.microsoft.com/en-us/windows/wsl/)
[![Documentation](https://img.shields.io/badge/docs-online-blue.svg)](https://tsabo.github.io/PowerShell-DevKit/)

---

## 🎯 The Problem

**Tired of manually syncing your development environment across multiple machines and platforms?**

We've all been there - following lengthy OneNote instructions, manually installing tools, copy-pasting configurations, and hoping you didn't miss anything. Every new machine or reinstall meant hours of tedious setup work. Switching between Windows and macOS made it even worse.

**PowerShell DevKit eliminates that pain:**

- ✅ **One command** to set up your complete environment
- ✅ **Cross-platform** - Works on Windows, macOS, and Ubuntu / WSL
- ✅ **Git-based configuration** keeps everything in sync
- ✅ **Automatic updates** across all your machines
- ✅ **Intelligent recovery** when things go wrong
- ✅ **Consistent experience** whether you're on your desktop, laptop, Windows PC, MacBook, or WSL terminal

Clone once, run the appropriate setup script, and you're done. Your perfect PowerShell environment, reproduced identically everywhere.

---

## 🚀 Quick Start

### Windows
```powershell
# 1. Clone the repository
git clone https://github.com/Tsabo/PowerShell-DevKit.git
cd PowerShell-DevKit

# 2. Run setup
.\Scripts\Setup.ps1

# 3. Validate installation
.\Scripts\Test.ps1

# 4. Keep everything updated
.\Scripts\Update.ps1
```

### macOS
```powershell
# 1. Clone the repository
git clone https://github.com/Tsabo/PowerShell-DevKit.git
cd PowerShell-DevKit

# 2. Run macOS setup
./Scripts/Setup-macOS.ps1

# 3. Validate installation
./Scripts/Test-macOS.ps1

# 4. Keep everything updated
./Scripts/Update-macOS.ps1
```

**[📖 macOS Setup Guide →](docs/getting-started/macos-setup.md)**

### Ubuntu / WSL
```bash
# 1. Clone the repository (inside WSL / Ubuntu)
git clone https://github.com/Tsabo/PowerShell-DevKit.git
cd PowerShell-DevKit

# 2. Run the Linux setup (from within pwsh)
pwsh -File ./Scripts/Setup-Linux.ps1

# 3. Validate installation
pwsh -File ./Scripts/Test-Linux.ps1

# 4. Keep everything updated
pwsh -File ./Scripts/Update-Linux.ps1
```

**[📖 Linux / WSL Setup Guide →](docs/getting-started/linux-setup.md)**

### 🔄 Updating PowerShell-DevKit

To update to the latest version with new features and improvements:

```powershell
# 1. Pull the latest changes from the repository
git pull

# 2. Re-run setup to apply any configuration updates (safe to run multiple times)
# Windows:
.\Scripts\Setup.ps1
# macOS:
./Scripts/Setup-macOS.ps1
# Linux / WSL:
pwsh -File ./Scripts/Setup-Linux.ps1

# 3. Update all installed components (packages, modules, etc.)
# Windows:
.\Scripts\Update.ps1
# macOS:
./Scripts/Update-macOS.ps1
# Linux / WSL:
pwsh -File ./Scripts/Update-Linux.ps1
```

> 💡 **Note**: `Setup.ps1` is safe to run multiple times - it only installs missing components and updates configurations.

**[📖 Read the Full Documentation →](https://tsabo.github.io/PowerShell-DevKit/)**

---

## ✨ What You Get

**Modern Terminal Experience:**
- oh-my-posh with beautiful, informative prompts
- Yazi file manager with git-aware navigation
- Fuzzy finding for files and command history
- Smart directory navigation with zoxide
- Git integration throughout

**Smart Automation:**
- Component-based architecture with intelligent failure recovery
- Multi-source package management (winget, PSGallery, Scoop, Yazi)
- Comprehensive environment validation
- Update-safe customization patterns

**Everything Stays in Sync:**
- Git-managed configurations auto-sync across machines
- Single source of truth for all components
- Update once, deploy everywhere

**[View All Features →](https://tsabo.github.io/PowerShell-DevKit/#-key-features)**

---

## � Documentation

**[Complete Documentation Site →](https://tsabo.github.io/PowerShell-DevKit/)**

| Section | Description |
|---------|-------------|
| **[Getting Started](https://tsabo.github.io/PowerShell-DevKit/getting-started/quick-start/)** | Installation, requirements, quick start guide |
| **[Components](https://tsabo.github.io/PowerShell-DevKit/components/overview/)** | Detailed docs for oh-my-posh, Yazi, PowerShell modules |
| **[Scripts](https://tsabo.github.io/PowerShell-DevKit/scripts/overview/)** | Setup, Test, Update, Deploy-Terminal scripts |
| **[Configuration](https://tsabo.github.io/PowerShell-DevKit/configuration/customization/)** | Customize modules, profiles, and themes |
| **[Architecture](https://tsabo.github.io/PowerShell-DevKit/architecture/overview/)** | System design and failure recovery |
| **[Development](https://tsabo.github.io/PowerShell-DevKit/development/contributing/)** | Contributing guide and developer reference |
| **[Help](https://tsabo.github.io/PowerShell-DevKit/troubleshooting/)** | Troubleshooting and FAQ |

---

## 🤝 Contributing

We welcome contributions! See our [Contributing Guide](https://tsabo.github.io/PowerShell-DevKit/development/contributing/) for the complete workflow.

**Quick start:** Fork → Create feature branch → Run `.\Scripts\Validate-Code.ps1` → Submit PR

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

---

<div align="center">

**Made with ❤️ for PowerShell developers who value their time**

[Documentation](https://tsabo.github.io/PowerShell-DevKit/) • [Issues](https://github.com/Tsabo/PowerShell-DevKit/issues) • [Discussions](https://github.com/Tsabo/PowerShell-DevKit/discussions)

</div>
