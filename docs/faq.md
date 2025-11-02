# Frequently Asked Questions

## General

### What is PowerShell DevKit?

PowerShell DevKit is an enterprise-grade automation suite that sets up a complete PowerShell development environment with modern tools, themes, and configurations.

### Do I need to be an administrator?

Administrator rights are recommended for the best experience, but most components will install with standard user permissions. Some features may require manual UAC approval.

### Will this work on PowerShell 5.1?

The setup script will automatically install PowerShell 7+ for you if you're running Windows PowerShell 5.1. PowerShell 7+ is required for full functionality.

### Can I uninstall components later?

Yes! Each component can be uninstalled independently:
```powershell
# Uninstall via winget
winget uninstall oh-my-posh
winget uninstall yazi

# Uninstall PowerShell modules
Uninstall-Module PSFzf
```

---

## Installation

### How long does installation take?

Typically 5-10 minutes depending on your internet connection and whether components are already installed.

### Can I install on multiple machines?

Yes! Clone the repository on each machine and run `Setup.ps1`. The setup is idempotent—it skips already-installed components.

### What if setup fails partway through?

Simply re-run `Setup.ps1`. Already-installed components will be detected and skipped, and it will continue from where it failed.

### Can I customize what gets installed?

Currently, you can skip optional components during setup.
<!-- For more granular control, see the [Customization Guide](configuration/customization.md). *(Coming soon)* -->

---

## Usage

### How do I update everything?

```powershell
.\Scripts\Update.ps1
```

This updates all winget packages, PowerShell modules, and Yazi components.

### How do I customize my prompt?

Edit the oh-my-posh theme files in `Config/oh-my-posh/`.
<!-- See the [oh-my-posh guide](components/oh-my-posh.md) for details. *(Coming soon)* -->

### How do I add my own PowerShell functions?

Create them in `PowerShell/CustomModules/` or `PowerShell/CustomProfile.ps1`.
<!-- See the [Custom Profile guide](configuration/custom-profile.md) for details. *(Coming soon)* -->

### Can I use a different terminal?

Yes, but Windows Terminal is recommended. The setup auto-configures Windows Terminal. Other terminals may require manual configuration.

---

## Yazi

### How do I launch Yazi?

Simply type `yazi` in PowerShell:
```powershell
yazi
```

### Yazi shortcuts aren't working

Make sure you've reloaded your profile:
```powershell
. $PROFILE
```

### How do I add more Yazi plugins?

```powershell
# List available plugins
ya pkg list

# Add a plugin
ya pkg add "username/plugin-name"
```

### Can I use my own Yazi configuration?

Yes! The setup clones the configuration from a git repository. You can:
1. Fork the [yazi_config](https://github.com/Tsabo/yazi_config) repository
2. Modify `Components.psm1` to point to your fork
3. Customize the configuration in your fork

---

## Troubleshooting

### Fonts look weird in my prompt

Install the CascadiaCode Nerd Font:
```powershell
oh-my-posh font install CascadiaCode
```

Then set it in Windows Terminal settings.

### winget commands aren't working

Ensure winget is installed:
```powershell
winget --version
```

If not installed, update Windows or install [App Installer](https://www.microsoft.com/p/app-installer/9nblggh4nns1) from Microsoft Store.

### Some modules failed to install

Trust the PowerShell Gallery:
```powershell
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
```

### Where are the logs?

Setup logs are in `.\Scripts\Logs\Setup_YYYYMMDD_HHMMSS.log`.

---

## Configuration

### Where is my PowerShell profile?

```powershell
# View profile location
$PROFILE

# Open profile
code $PROFILE
```

### How do I change my oh-my-posh theme?

Edit your profile (`$PROFILE`) and change the theme path:
```powershell
oh-my-posh init pwsh --config "path\to\your\theme.omp.json" | Invoke-Expression
```

### Can I sync my configuration across machines?

Yes! The entire `PowerShell-DevKit` folder can be version-controlled. Custom modules and profiles are in separate directories that can be synced.

---

## Updates

### How often should I run Update.ps1?

Weekly or monthly is recommended, or whenever you want the latest versions of tools.

### Will updates break my customizations?

No. Custom modules, custom profile, and Yazi local modifications are preserved during updates.

### Can I auto-update?

You can schedule `Update.ps1` with Windows Task Scheduler, but it's recommended to review updates manually.

---

## Advanced

### Can I contribute?

Yes! Check the repository for contribution guidelines.
<!-- See the [Contributing Guide](development/contributing.md) for details. *(Coming soon)* -->

### How do I understand the architecture?

The system uses a component-based architecture with orchestrator scripts (`Setup.ps1`, `Test.ps1`, `Update.ps1`) and a shared component definition module (`Components.psm1`).
<!-- See the [Architecture Guide](development/architecture.md) for a deep dive. *(Coming soon)* -->

### Can I add my own components?

Yes! Components are defined in `Scripts/Components.psm1` with properties like Name, Source, and custom installers.
<!-- See the [Component System Guide](development/components.md) for detailed instructions. *(Coming soon)* -->

### Is this compatible with WSL?

The PowerShell DevKit is designed for Windows PowerShell. For WSL, you'd need to adapt it for Linux package managers and paths.

---

## Still have questions?

- Check the [Troubleshooting Guide](troubleshooting.md)
- Open an issue on [GitHub](https://github.com/Tsabo/PowerShell-DevKit/issues)
- Review the full [documentation](index.md)
