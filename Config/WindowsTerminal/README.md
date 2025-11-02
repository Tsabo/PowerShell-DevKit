# Windows Terminal Settings Configuration

This directory contains Windows Terminal settings templates and deployment tools to ensure consistent terminal configuration across all your machines.

## 🎯 **What This Provides**

### **Font Configuration**
- ✅ **CaskaydiaCove Nerd Font Mono** as default font
- ✅ Proper font size (11pt) for readability
- ✅ Consistent font across all profiles

### **Window Settings**
- ✅ Initial window width (135 columns) for better code visibility

### **Profile Management**
- ✅ Preserves ALL existing settings and profiles
- ✅ Only modifies font and window width
- ✅ Non-destructive deployment

## 📁 **Files**

### **`settings.json`**
Minimal Windows Terminal configuration template containing only:
- Default font: CaskaydiaCove Nerd Font Mono
- Initial column width: 135 columns
- No other modifications to preserve Windows Terminal defaults

## 🚀 **Usage**

### **Automatic Deployment (Recommended)**
The Windows Terminal settings are automatically deployed when you run the main setup:
```powershell
.\Scripts\Setup.ps1
```

### **Manual Deployment**
Deploy just the terminal settings:
```powershell
.\Scripts\Deploy-Terminal.ps1
```

### **Management Menu**
Use the interactive management menu:
```powershell
# Management menu has been removed - use direct script calls instead
```

### **Deployment Options**

#### **Safe Deployment (Default)**
Creates backup of existing settings:
```powershell
.\Scripts\Deploy-Terminal.ps1
```

#### **No Backup**
Deploy without creating backup:
```powershell
.\Scripts\Deploy-Terminal.ps1 -NoBackup
```

#### **Force Overwrite**
Replace all settings with template (no merging):
```powershell
.\Scripts\Deploy-Terminal.ps1 -Force -NoBackup
```

## 🔧 **How It Works**

### **Minimal Application**
The deployment script applies only essential changes to existing settings:

1. **Preserves** ALL existing profiles, shortcuts, themes, and custom configurations
2. **Sets** CaskaydiaCove Nerd Font Mono as the default font for all profiles
3. **Applies** 135 column initial width for better code visibility
4. **Maintains** all Windows Terminal defaults for everything else

### **Backup Protection**
- Automatically creates timestamped backups of existing settings
- Backup location: `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json.backup.YYYYMMDD-HHMMSS`
- Use `-NoBackup` flag to skip backup creation

### **Detection Logic**
The script automatically detects:
- Windows Terminal installation (regular or preview)
- Existing settings.json location
- Profile configurations that need font updates

## ✅ **Validation**

The test script (`Test.ps1`) validates:
- Windows Terminal installation
- CaskaydiaCove Nerd Font configuration
- Settings file integrity

## 🎨 **Customization**

### **Modify Template**
Edit `Config\WindowsTerminal\settings.json` to customize:
- Default font and size
- Color schemes
- Opacity and visual effects
- Keyboard shortcuts
- Window behavior

### **Font Preferences**
To use a different font, update the template:
```json
{
  "profiles": {
    "defaults": {
      "font": {
        "face": "Your Preferred Font Name",
        "size": 11
      }
    }
  }
}
```

### **Window Settings**
To change the initial window width, update the template:
```json
{
  "initialCols": 120
}
```

## 🔍 **Troubleshooting**

### **Windows Terminal Not Found**
```
Error: Windows Terminal not found
```
**Solution**: Install Windows Terminal from Microsoft Store

### **Settings Deployment Failed**
```
Error: Failed to apply settings
```
**Solutions**:
1. Check Windows Terminal is not running
2. Verify you have write permissions
3. Use `-Force` flag to overwrite corrupted settings

### **Font Not Applied**
**Check**:
1. CaskaydiaCove Nerd Font is installed (`winget list Microsoft.CascadiaCode`)
2. Windows Terminal was restarted after deployment
3. The correct profile is selected as default

### **Backup Settings Location**
Backups are created in the Windows Terminal LocalState directory:
- Regular: `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\`
- Preview: `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\`

## 🔄 **Sync Across Machines**

1. **Update template** in your repository with preferred settings
2. **Commit changes** to version control
3. **Pull updates** on other machines
3. **Run deployment** script to apply changes:
   ```powershell
   .\Scripts\Deploy-Terminal.ps1
   ```

This ensures all your development machines have consistent Windows Terminal configuration with your preferred font, shortcuts, and visual settings.