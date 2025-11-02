# 🚀 PowerShell DevKit

<div align="center">

![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Architecture](https://img.shields.io/badge/Architecture-Component--Based-green.svg)

**A complete, enterprise-grade PowerShell development environment automation suite**

[Quick Start](getting-started/quick-start.md){ .md-button .md-button--primary }
[View on GitHub](https://github.com/Tsabo/PowerShell-DevKit){ .md-button }

</div>

---

## ✨ Features

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

### 🗂️ Modern Yazi Integration
- **Native Package Management** - Uses Yazi's built-in `ya pkg` system
- **Custom Plugin Fork** - Includes bug-fixed githead plugin
- **Git-Based Configuration** - Separate repository for easy sharing
- **SVG Support** - Optional resvg integration via Scoop
- **Automatic Updates** - Plugins and configuration stay current

### 🎨 Rich Terminal Experience
- **oh-my-posh Themes** - Beautiful, informative prompts
- **Git Integration** - Visual git status and branch information
- **Smart Navigation** - zoxide for intelligent directory jumping
- **Fuzzy Finding** - Advanced file and history search

---

## 📦 What's Included

### Core Tools
- **oh-my-posh** - Prompt theme engine
- **Yazi** - Modern terminal file manager
- **fzf** - Fuzzy finder
- **zoxide** - Smart directory navigation
- **Microsoft Edit** - Modern text editor

### PowerShell Modules
- **PSFzf** - Fuzzy finding integration
- **Terminal-Icons** - File/folder icons
- **F7History** - Enhanced history search
- **posh-git** - Git status in prompt

### Enhanced Yazi Ecosystem
- **7+ Optional Dependencies** - FFmpeg, 7-Zip, jq, Poppler, fd, ripgrep, ImageMagick
- **Auto-installed Plugins** - git, githead (custom fork)
- **Themes** - flexoki-light, vscode-dark-plus

[See all components →](components/overview.md)

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

- :material-rocket-launch: **[Quick Start](getting-started/quick-start.md)**

    Get up and running in minutes

- :material-package-variant: **[Components](components/overview.md)**

    Explore all installed tools

<!-- - :material-script-text: **[Scripts](scripts/setup.md)** -->
- :material-script-text: **Scripts**

    Learn about Setup, Test, and Update

    *(Coming soon)*

<!-- - :material-cog: **[Configuration](configuration/customization.md)** -->
- :material-cog: **Configuration**

    Customize your environment

    *(Coming soon)*

<!-- - :material-code-braces: **[Development](development/architecture.md)** -->
- :material-code-braces: **Development**

    Understand the architecture

    *(Coming soon)*

- :material-help-circle: **[Troubleshooting](troubleshooting.md)**

    Solve common issues

</div>

---

## 💡 Why PowerShell DevKit?

!!! success "Enterprise-Grade Quality"
    Built with production-ready practices: comprehensive error handling, detailed logging, intelligent recovery, and extensive testing.

!!! tip "Component-Based Architecture"
    Single source of truth for all components. Add once, available everywhere. Easy to extend and maintain.

!!! info "Modern Tool Integration"
    Seamlessly integrates the best modern CLI tools: oh-my-posh, Yazi, fzf, zoxide, and more.

!!! example "Continuous Updates"
    Built-in update mechanism keeps your entire environment current with minimal effort.

---

## 🤝 Contributing

Contributions are welcome! See our contributing guide to get started.
<!-- Contributions are welcome! See our [contributing guide](development/contributing.md) to get started. -->

*(Contributing guide coming soon)*

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/Tsabo/PowerShell-DevKit/blob/master/LICENSE) file for details.
