# PowerShell DevKit

<p align="center">
  <img src="https://img.shields.io/badge/PowerShell-7%2B-blue.svg" alt="PowerShell 7+">
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License MIT">
  <img src="https://img.shields.io/badge/Platform-Windows-blue.svg" alt="Windows">
</p>

<p align="center">
  <strong>Keep your PowerShell development environments perfectly synchronized across all your machines</strong>
</p>

<p align="center">
  <a href="getting-started/quick-start/" class="md-button md-button--primary">Quick Start</a>
  <a href="https://github.com/Tsabo/PowerShell-DevKit" class="md-button">View on GitHub</a>
</p>

---

## 🎯 The Problem It Solves

**Tired of manually syncing your development environment across multiple machines?**

We've all been there - following lengthy OneNote instructions, manually installing tools, copy-pasting configurations, and hoping you didn't miss anything. Every new machine or reinstall meant hours of tedious setup work.

**PowerShell DevKit eliminates that pain:**

- ✅ **One command** to set up your complete environment
- ✅ **Git-based configuration** keeps everything in sync
- ✅ **Automatic updates** across all your machines
- ✅ **Intelligent recovery** when things go wrong
- ✅ **Consistent experience** whether you're on your desktop, laptop, or fresh Windows install

Clone once, run Setup.ps1, and you're done. Your perfect PowerShell environment, reproduced identically everywhere.

---

## ✨ Key Features

### 🔄 Environment Synchronization
- **Single Source of Truth** - Git repository manages all configurations
- **Multi-Machine Ready** - Same setup on desktop, laptop, and VMs
- **Update Once, Deploy Everywhere** - Push changes, pull on other machines
- **No Manual Steps** - Automated installation and configuration

### 🏗️ Enterprise Architecture
- **Component-Based Design** - Modular, maintainable, and extensible
- **Intelligent Failure Recovery** - Detailed logging with smart suggestions
- **Shared Component Library** - Single source of truth for all scripts
- **Comprehensive Testing** - Built-in validation and diagnostics

### 🎯 Smart Automation
- **One-Command Setup** - Complete environment in minutes
- **Automatic Updates** - Keep everything current with `Update.ps1`
- **Dependency Management** - Intelligent package manager integration
- **Failure Diagnostics** - Advanced troubleshooting with actionable suggestions

### 🎨 Rich Terminal Experience
- **oh-my-posh Themes** - Beautiful, informative prompts
- **Git Integration** - Visual git status and branch information
- **Smart Navigation** - zoxide for intelligent directory jumping
- **Fuzzy Finding** - Advanced file and history search

### 🗂️ Modern Tooling
- **Yazi File Manager** - Modern, fast, git-aware file browser
- **Native Package Management** - Uses Yazi's built-in `ya pkg` system
- **Git-Based Configuration** - Separate repository for easy sharing
- **Automatic Updates** - Keep everything current with one command

---

## 📦 What's Included

### Core Tools
- **oh-my-posh** - Prompt theme engine with git integration
- **Yazi** - Modern terminal file manager with git-managed config
- **fzf** - Fuzzy finder for files and command history
- **zoxide** - Smart directory navigation (learns your habits)

### PowerShell Modules
- **PSFzf** - Fuzzy finding integration for PowerShell
- **Terminal-Icons** - Beautiful file and folder icons
- **F7History** - Enhanced command history search
- **posh-git** - Git status in your prompt

### Yazi Ecosystem
- **Git-managed configuration** - Auto-synced across machines
- **Auto-installed plugins** - git, githead (custom fork with bug fixes)
- **Themes** - flexoki-light, vscode-dark-plus
- **Optional enhancements** - FFmpeg, 7-Zip, jq, Poppler, fd, ripgrep, ImageMagick

[View all components →](components/overview.md)

---

## 🚀 Quick Start

```powershell
# 1. Clone the repository
git clone https://github.com/Tsabo/PowerShell-DevKit.git
cd PowerShell-DevKit

# 2. Run setup (as Administrator recommended)
.\Scripts\Setup.ps1

# 3. Reload your profile
. $PROFILE
```

[Detailed installation guide →](getting-started/installation.md)

---

## 📚 Documentation

<div class="grid cards" markdown>

-   **🚀 Getting Started**

    ---

    - [Quick Start](getting-started/quick-start.md) - Get running in 5 minutes
    - [Installation](getting-started/installation.md) - Detailed setup guide
    - [Requirements](getting-started/requirements.md) - What you need

-   **📦 Components**

    ---

    - [Overview](components/overview.md) - All installed components
    - [oh-my-posh](components/oh-my-posh.md) - Prompt theming
    - [Yazi](components/yazi.md) - File manager
    - [PowerShell](components/powershell.md) - Profile configuration
    - [Optional Components](components/optional.md) - Extra tools

-   **📜 Scripts**

    ---

    - [Overview](scripts/overview.md) - Script comparison
    - [Setup.ps1](scripts/setup.md) - Installation
    - [Test.ps1](scripts/test.md) - Validation
    - [Update.ps1](scripts/update.md) - Updates
    - [Deploy-Terminal.ps1](scripts/deploy-terminal.md) - Terminal config

-   **⚙️ Configuration**

    ---

    - [Customization Guide](configuration/customization.md) - Overview
    - [Custom Modules](configuration/custom-modules.md) - Your own modules
    - [Custom Profile](configuration/custom-profile.md) - Personal settings
    - [Themes](configuration/themes.md) - Visual customization

-   **🏗️ Architecture**

    ---

    - [System Overview](architecture/overview.md) - Design principles
    - [Components](architecture/components.md) - Component system
    - [Failure Recovery](architecture/failure-recovery.md) - Error handling

-   **💻 Development**

    ---

    - [Contributing](development/contributing.md) - How to contribute
    - [Developer Reference](development/developer-reference.md) - Command cheatsheet
    - [Testing](development/testing.md) - Testing procedures

-   **❓ Help**

    ---

    - [Troubleshooting](troubleshooting.md) - Common issues
    - [FAQ](faq.md) - Frequently asked questions

</div>

---

## 💡 Why PowerShell DevKit?

!!! success "Eliminate Manual Setup"
    Stop following lengthy OneNote instructions. One command sets up your complete development environment, consistently across all machines.

!!! tip "Stay Synchronized"
    Git-based configuration means your environment stays in sync. Update on one machine, pull on others. No more configuration drift.

!!! info "Enterprise-Grade Quality"
    Production-ready practices: comprehensive error handling, detailed logging, intelligent recovery suggestions, and extensive testing.

!!! example "Modern Tools"
    Seamlessly integrates the best modern CLI tools with smart defaults. Everything just works together.

---

## 🤝 Contributing

We welcome contributions! Whether it's bug fixes, new features, improved documentation, or sharing your custom configurations.

**How to Contribute:**

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run validation: `.\Scripts\Validate-Code.ps1`
5. Test your changes: `.\Scripts\Test.ps1`
6. Commit with conventional commits (`git commit -m 'feat: add amazing feature'`)
7. Push to your branch
8. Open a Pull Request

**Resources:**

- [Contributing Guide](development/contributing.md) - Detailed contribution workflow
- [Developer Reference](development/developer-reference.md) - Command cheatsheet and best practices
- [Testing Guide](development/testing.md) - How to test your changes

**Ideas for Contributions:**

- Additional component integrations
- Enhanced failure recovery suggestions
- New custom PowerShell modules
- Improved Yazi configurations
- Theme customizations
- Documentation improvements

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/Tsabo/PowerShell-DevKit/blob/master/LICENSE) file for details.

---

<div align="center">

**Made with ❤️ for PowerShell developers who value their time**

[Documentation](https://tsabo.github.io/PowerShell-DevKit/) • [GitHub](https://github.com/Tsabo/PowerShell-DevKit) • [Issues](https://github.com/Tsabo/PowerShell-DevKit/issues) • [Discussions](https://github.com/Tsabo/PowerShell-DevKit/discussions)

</div>
