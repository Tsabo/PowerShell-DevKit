# Troubleshooting

Common issues and their solutions.

## Setup Issues

### Execution Policy Error

**Symptom:**
```
.\Scripts\Setup.ps1 : File cannot be loaded because running scripts is disabled on this system.
```

**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

### winget Not Found

**Symptom:**
```
winget : The term 'winget' is not recognized
```

**Solutions:**

1. **Update Windows:**
   - Open Settings → Windows Update
   - Install all available updates
   - Restart your computer

2. **Install App Installer:**
   - Open Microsoft Store
   - Search for "App Installer"
   - Click "Get" or "Update"

3. **Manual Installation:**
   - Download from [GitHub](https://github.com/microsoft/winget-cli/releases)
   - Install the `.msixbundle` file

---

### Module Installation Failed

**Symptom:**
```
WARNING: Unable to resolve package source 'PSGallery'
```

**Solution:**
```powershell
# Trust PSGallery
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Re-run setup
.\Scripts\Setup.ps1
```

---

### Setup Hangs

**Symptom:**
Setup appears frozen on a specific package installation.

**Cause:**
Timeout protection should prevent this, but if it occurs:

**Solution:**
1. Wait for 60-second timeout
2. Press `Ctrl+C` to cancel
3. Check logs in `.\Scripts\Logs\`
4. Re-run setup (already installed components will be skipped)

---

## Component Issues

### oh-my-posh Not Showing Correctly

**Symptom:**
Weird characters or boxes in prompt.

**Solutions:**

1. **Font Issue:**
   ```powershell
   # Reinstall font
   oh-my-posh font install CascadiaCode
   ```

2. **Terminal Font Settings:**
   - Open Windows Terminal settings
   - Set font to "CaskaydiaCove Nerd Font Mono"
   - Restart terminal

---

### Yazi Doesn't Start

**Symptom:**
```
yazi : The term 'yazi' is not recognized
```

**Solution:**
```powershell
# Restart terminal to refresh PATH
# Or manually add to PATH
$env:PATH += ";$env:LOCALAPPDATA\Microsoft\WinGet\Links"

# Reload profile
. $PROFILE
```

---

### Git Status Not Showing in Prompt

**Symptom:**
No git branch or status in prompt when in a git repository.

**Solutions:**

1. **Ensure posh-git is installed:**
   ```powershell
   Get-Module -ListAvailable posh-git
   ```

2. **Reload profile:**
   ```powershell
   . $PROFILE
   ```

3. **Check oh-my-posh theme:**
   - Ensure theme includes git segment

---

## Yazi Issues

### Plugins Not Loading

**Symptom:**
Yazi plugins don't appear to work.

**Solution:**
```powershell
# Check plugin installation
ya pkg list

# Reinstall plugins
ya pkg add "yazi-rs/plugins:git"
ya pkg add "Tsabo/githead"
```

---

### No File Previews

**Symptom:**
Yazi doesn't show file previews.

**Cause:**
Missing optional dependencies.

**Solution:**
```powershell
# Install all optional dependencies
Install-YaziOptionals
```

---

### Configuration Overwritten

**Symptom:**
Custom Yazi configuration changes are lost.

**Cause:**
Git pull overwrites local changes.

**Prevention:**
The setup now detects local modifications and skips pulling updates.

**Manual Update:**
```powershell
cd $env:APPDATA\yazi
git stash
git pull
git stash pop
```

---

## Update Issues

### Update Script Fails

**Symptom:**
`Update.ps1` reports errors.

**Solution:**
```powershell
# Update with detailed output
.\Scripts\Update.ps1 -Verbose

# Check specific component
.\Scripts\Test.ps1
```

---

### Modules Won't Update

**Symptom:**
PowerShell modules show as outdated but won't update.

**Solution:**
```powershell
# Force update
Update-Module -Name PSFzf -Force
Update-Module -Name Terminal-Icons -Force
Update-Module -Name posh-git -Force
```

---

## Diagnostic Commands

### Check Installation Status

```powershell
# Run test script
.\Scripts\Test.ps1

# Check specific component
Get-Command oh-my-posh
Get-Command yazi
Get-Module -ListAvailable PSFzf
```

### View Setup Logs

```powershell
# View latest log
Get-Content .\Scripts\Logs\Setup_*.log | Select-Object -Last 50

# Search for errors
Get-Content .\Scripts\Logs\Setup_*.log | Select-String "error|fail"
```

### Verify PATH

```powershell
# Check if tools are in PATH
$env:PATH -split ';' | Where-Object { $_ -like '*winget*' -or $_ -like '*yazi*' }
```

### Check Profile Loading

```powershell
# Verify profile exists
Test-Path $PROFILE

# Check profile content
Get-Content $PROFILE

# Reload profile
. $PROFILE
```

---

## Getting More Help

If you're still experiencing issues:

1. **Check Logs:** Review `.\Scripts\Logs\` for detailed error messages
2. **Run Tests:** Execute `.\Scripts\Test.ps1` for component status
3. **Clean Install:** Remove installed components and re-run setup
4. **GitHub Issues:** Open an issue with logs and error messages

## Frequently Asked Questions

See the [FAQ](faq.md) for common questions.
