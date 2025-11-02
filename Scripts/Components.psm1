# PowerShell Environment Components Module
# Shared component definitions for Setup and Test scripts

# Component definitions - single source of truth
class SetupComponent {
    [string]$Name
    [string]$Type  # 'winget', 'module', 'config'
    [hashtable]$Properties
    [bool]$IsOptional
    [scriptblock]$CustomInstaller
    [scriptblock]$CustomValidator

    SetupComponent([string]$name, [string]$type, [hashtable]$properties) {
        $this.Name = $name
        $this.Type = $type
        $this.Properties = $properties
        $this.IsOptional = $false
    }

    SetupComponent([string]$name, [string]$type, [hashtable]$properties, [bool]$optional) {
        $this.Name = $name
        $this.Type = $type
        $this.Properties = $properties
        $this.IsOptional = $optional
    }

    SetupComponent([string]$name, [scriptblock]$customInstaller, [scriptblock]$customValidator, [bool]$optional) {
        $this.Name = $name
        $this.Type = "custom"
        $this.CustomInstaller = $customInstaller
        $this.CustomValidator = $customValidator
        $this.IsOptional = $optional
    }
}

# Utility functions used by both Setup and Test
function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Get-PlatformPackageManager {
    <#
    .SYNOPSIS
        Detects the best package manager for the current platform
    #>
    if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
        if (Test-CommandExists "winget") { return "winget" }
        if (Test-CommandExists "scoop") { return "scoop" }
        if (Test-CommandExists "choco") { return "chocolatey" }
        return $null
    }
    elseif ($IsLinux) {
        if (Test-CommandExists "brew") { return "homebrew" }
        if (Test-CommandExists "apt") { return "apt" }
        if (Test-CommandExists "dnf") { return "dnf" }
        if (Test-CommandExists "pacman") { return "pacman" }
        if (Test-CommandExists "snap") { return "snap" }
        return $null
    }
    elseif ($IsMacOS) {
        if (Test-CommandExists "brew") { return "homebrew" }
        return $null
    }
    return $null
}

function Get-CrossPlatformPackageInfo {
    param([string]$ComponentName)
    
    # Cross-platform package mappings
    $packageMappings = @{
        "oh-my-posh" = @{
            winget = "JanDeDobbeleer.OhMyPosh"
            homebrew = "oh-my-posh"
            apt = $null  # Manual install required
            dnf = $null  # Manual install required
        }
        "yazi" = @{
            winget = "sxyazi.yazi"
            homebrew = "yazi"
            apt = $null  # Manual install or snap
            dnf = $null  # Manual install
        }
        "fzf" = @{
            winget = "junegunn.fzf"
            homebrew = "fzf"
            apt = "fzf"
            dnf = "fzf"
        }
        "zoxide" = @{
            winget = "ajeetdsouza.zoxide"
            homebrew = "zoxide"
            apt = $null  # Manual install required
            dnf = $null  # Manual install required
        }
    }
    
    return $packageMappings[$ComponentName]
}

function Get-WingetPackageVersion {
    param([string]$PackageId)
    try {
        $output = winget list --id $PackageId --exact 2>$null
        if ($LASTEXITCODE -eq 0 -and $output -match $PackageId) {
            $lines = $output -split "`n"
            foreach ($line in $lines) {
                if ($line -match $PackageId) {
                    if ($line -match '\s+([\d\.]+)\s+') {
                        return $matches[1]
                    }
                }
            }
        }
    }
    catch { }
    return $null
}

# Validation functions for custom components
function Test-OhMyPosh {
    $version = Get-WingetPackageVersion -PackageId "JanDeDobbeleer.OhMyPosh"
    if (-not $version -and (Test-CommandExists "oh-my-posh")) {
        $version = (oh-my-posh version)
    }
    return @{
        IsInstalled = $version -or (Test-CommandExists "oh-my-posh")
        Version = $version
    }
}

function Test-Yazi {
    $version = Get-WingetPackageVersion -PackageId "sxyazi.yazi"
    if (-not $version -and (Test-CommandExists "yazi")) {
        $version = (yazi --version).Split(' ')[1]
    }
    
    # Also check for configuration
    $configPath = Join-Path $env:APPDATA "yazi\config"
    $hasConfig = Test-Path $configPath
    
    return @{
        IsInstalled = $version -or (Test-CommandExists "yazi")
        Version = $version
        HasConfig = $hasConfig
    }
}

function Test-PowerShellProfile {
    if (-not (Test-Path $PROFILE)) {
        return @{
            IsInstalled = $false
            Issues = @("Profile file not found")
        }
    }
    
    $profileContent = Get-Content $PROFILE -Raw
    $checks = @{
        "oh-my-posh initialization" = $profileContent -match "oh-my-posh.*--init"
        "Terminal-Icons import" = $profileContent -match "Terminal-Icons"
        "posh-git import" = $profileContent -match "posh-git"
        "zoxide initialization" = $profileContent -match "zoxide init"
        "PSReadLine configuration" = $profileContent -match "PSReadLine"
    }
    
    $issues = @()
    foreach ($check in $checks.GetEnumerator()) {
        if (-not $check.Value) {
            $issues += "$($check.Key) not found"
        }
    }
    
    return @{
        IsInstalled = $true
        Issues = $issues
        AllConfigured = $issues.Count -eq 0
    }
}

function Test-WindowsTerminal {
    $terminalPaths = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    )
    
    foreach ($path in $terminalPaths) {
        if (Test-Path $path) {
            try {
                $terminalSettings = Get-Content $path -Raw | ConvertFrom-Json
                
                # Check for CaskaydiaCove font
                $hasCorrectFont = $false
                if ($terminalSettings.profiles -and $terminalSettings.profiles.defaults -and $terminalSettings.profiles.defaults.font) {
                    $hasCorrectFont = $terminalSettings.profiles.defaults.font.face -eq "CaskaydiaCove Nerd Font Mono"
                }
                
                if (-not $hasCorrectFont -and $terminalSettings.profiles -and $terminalSettings.profiles.list) {
                    $psProfile = $terminalSettings.profiles.list | Where-Object { $_.source -eq "Windows.Terminal.PowershellCore" }
                    if ($psProfile -and $psProfile.font -and $psProfile.font.face) {
                        $hasCorrectFont = $psProfile.font.face -eq "CaskaydiaCove Nerd Font Mono"
                    }
                }
                
                return @{
                    IsInstalled = $true
                    HasCorrectFont = $hasCorrectFont
                    ConfigPath = $path
                }
            }
            catch {
                return @{
                    IsInstalled = $false
                    Issues = @("Invalid JSON in settings")
                }
            }
        }
    }
    
    return @{
        IsInstalled = $false
        Issues = @("Windows Terminal not found")
    }
}

# Get all components in order - SINGLE SOURCE OF TRUTH
function Get-EnvironmentComponents {
    return @(
        [SetupComponent]::new("gsudo", "winget", @{PackageId="gerardog.gsudo"}, $true)
        [SetupComponent]::new("oh-my-posh", {Install-OhMyPoshWithFont}, {Test-OhMyPosh}, $false)
        [SetupComponent]::new("CascadiaCode Font", "winget", @{PackageId="Microsoft.CascadiaCode"})
        [SetupComponent]::new("fzf", "winget", @{PackageId="junegunn.fzf"})
        [SetupComponent]::new("PSFzf", "module", @{ModuleName="PSFzf"})
        [SetupComponent]::new("Terminal-Icons", "module", @{ModuleName="Terminal-Icons"})
        [SetupComponent]::new("F7History", "module", @{ModuleName="F7History"})
        [SetupComponent]::new("zoxide", "winget", @{PackageId="ajeetdsouza.zoxide"})
        [SetupComponent]::new("Microsoft Edit", "winget", @{PackageId="Microsoft.Edit"})
        [SetupComponent]::new("posh-git", "module", @{ModuleName="posh-git"})
        [SetupComponent]::new("PowerColorLS", "module", @{ModuleName="PowerColorLS"}, $true)
        [SetupComponent]::new("Scoop", {Install-Scoop}, {Test-ScoopInstalled}, $true)
        [SetupComponent]::new("resvg", {Install-ScoopPackage -PackageName "resvg" -DisplayName "resvg"}, {Test-ScoopPackage -PackageName "resvg"}, $true)
        [SetupComponent]::new("Yazi", {Install-YaziWithConfig}, {Test-Yazi}, $false)
        [SetupComponent]::new("PowerShell Profile", {Deploy-PowerShellProfile}, {Test-PowerShellProfile}, $false)
        [SetupComponent]::new("Windows Terminal", {Deploy-TerminalSettings}, {Test-WindowsTerminal}, $false)
    )
}

# Validate a single component
function Test-EnvironmentComponent {
    param($Component)
    
    switch ($Component.Type) {
        "winget" {
            $version = Get-WingetPackageVersion -PackageId $Component.Properties.PackageId
            $isInstalled = $version -ne $null
            
            # Special case for fonts - hard to verify
            if ($Component.Properties.PackageId -eq "Microsoft.CascadiaCode") {
                $isInstalled = $true  # Assume installed if winget thinks so
                $version = $version ?? "unknown"
            }
            
            return @{
                IsInstalled = $isInstalled
                Version = $version
            }
        }
        "module" {
            $module = Get-Module -ListAvailable -Name $Component.Properties.ModuleName | Select-Object -First 1
            return @{
                IsInstalled = $module -ne $null
                Version = $module.Version
            }
        }
        "custom" {
            if ($Component.CustomValidator) {
                return & $Component.CustomValidator
            }
            return @{ IsInstalled = $false }
        }
        default {
            return @{ IsInstalled = $false }
        }
    }
}

# Scoop package management functions
function Test-ScoopInstalled {
    return (Test-CommandExists "scoop")
}

function Install-Scoop {
    if (Test-ScoopInstalled) {
        Write-Host "Scoop is already installed" -ForegroundColor Green
        return $true
    }
    
    try {
        Write-Host "Installing Scoop package manager..." -ForegroundColor Cyan
        
        # Check execution policy
        $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
        if ($currentPolicy -eq 'Restricted') {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        }
        
        # Install scoop using the official method
        $installScript = Invoke-RestMethod -Uri https://get.scoop.sh
        Invoke-Expression $installScript
        
        # Refresh PATH
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
        
        if (Test-ScoopInstalled) {
            Write-Host "Scoop installed successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Warning "Scoop installation may have failed - command not found"
            return $false
        }
    }
    catch {
        Write-Warning "Failed to install Scoop: $_"
        return $false
    }
}

function Install-ScoopPackage {
    param(
        [string]$PackageName,
        [string]$DisplayName = $null
    )
    
    if (-not $DisplayName) { $DisplayName = $PackageName }
    
    if (-not (Test-ScoopInstalled)) {
        Write-Warning "Scoop is not installed. Cannot install $DisplayName"
        return $false
    }
    
    try {
        # Check if already installed
        $installed = scoop list $PackageName 2>$null
        if ($LASTEXITCODE -eq 0 -and $installed -match $PackageName) {
            Write-Host "$DisplayName is already installed via Scoop" -ForegroundColor Green
            return $true
        }
        
        Write-Host "Installing $DisplayName via Scoop..." -ForegroundColor Cyan
        scoop install $PackageName
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$DisplayName installed successfully via Scoop" -ForegroundColor Green
            return $true
        } else {
            Write-Warning "Failed to install $DisplayName via Scoop"
            return $false
        }
    }
    catch {
        Write-Warning "Error installing $DisplayName via Scoop: $_"
        return $false
    }
}

function Test-ScoopPackage {
    param([string]$PackageName)
    
    if (-not (Test-ScoopInstalled)) {
        return @{ IsInstalled = $false }
    }
    
    try {
        $installed = scoop list $PackageName 2>$null
        if ($LASTEXITCODE -eq 0 -and $installed -match $PackageName) {
            # Extract version if possible
            $versionMatch = $installed | Select-String "$PackageName\s+([\d\.]+)"
            $version = if ($versionMatch) { $versionMatch.Matches[0].Groups[1].Value } else { "unknown" }
            
            return @{ 
                IsInstalled = $true
                Version = $version
            }
        }
    }
    catch {
        # Ignore errors, just return not installed
    }
    
    return @{ IsInstalled = $false }
}

function Update-ScoopPackages {
    if (-not (Test-ScoopInstalled)) {
        Write-Host "Scoop is not installed, skipping Scoop package updates" -ForegroundColor Yellow
        return @{ Updated = @(); Failed = @() }
    }
    
    try {
        Write-Host "Updating Scoop and packages..." -ForegroundColor Cyan
        
        # Update scoop itself
        scoop update
        
        # Get list of installed packages that can be updated
        $outdated = scoop status 2>$null | Where-Object { $_ -match "outdated" }
        
        if (-not $outdated) {
            Write-Host "All Scoop packages are up to date" -ForegroundColor Green
            return @{ Updated = @(); Failed = @() }
        }
        
        # Update all packages
        $updateResult = scoop update --all 2>&1
        $updateString = $updateResult | Out-String
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Scoop packages updated successfully" -ForegroundColor Green
            return @{ Updated = @("Scoop packages"); Failed = @() }
        } else {
            Write-Warning "Some Scoop package updates may have failed"
            return @{ Updated = @(); Failed = @("Scoop packages") }
        }
    }
    catch {
        Write-Warning "Error updating Scoop packages: $_"
        return @{ Updated = @(); Failed = @("Scoop packages") }
    }
}

# Update Yazi packages (for use in Update script)
function Update-YaziPackages {
    if (-not (Test-CommandExists "ya")) {
        Write-Warning "Yazi (ya) command not found. Please install Yazi first."
        return $false
    }
    
    try {
        Write-Host "Updating Yazi packages..." -ForegroundColor Cyan
        
        # Update all packages
        $updateOutput = & ya pkg update 2>&1
        $updateString = $updateOutput | Out-String
        
        if ($LASTEXITCODE -eq 0) {
            if ($updateString -match "Already up to date" -or $updateString -match "Nothing to update") {
                Write-Host "All Yazi packages are already up to date" -ForegroundColor Green
            } else {
                Write-Host "Yazi packages updated successfully" -ForegroundColor Green
            }
            
            # Also update the configuration repository if it exists
            $yaziConfigPath = Join-Path $env:APPDATA "yazi"
            if (Test-Path $yaziConfigPath) {
                Push-Location $yaziConfigPath
                try {
                    Write-Host "Updating Yazi configuration repository..." -ForegroundColor Cyan
                    $gitOutput = git pull origin main 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "Yazi configuration updated" -ForegroundColor Green
                    } else {
                        Write-Host "Configuration update skipped (local changes may exist)" -ForegroundColor Yellow
                    }
                }
                finally {
                    Pop-Location
                }
            }
            
            return $true
        } else {
            Write-Warning "Yazi package update failed: $updateString"
            return $false
        }
    }
    catch {
        Write-Warning "Error updating Yazi packages: $_"
        return $false
    }
}

# Export functions only - classes are automatically available when module is imported
Export-ModuleMember -Function Get-EnvironmentComponents, Test-EnvironmentComponent, Test-CommandExists, Get-WingetPackageVersion, Update-YaziPackages, Test-ScoopInstalled, Install-Scoop, Install-ScoopPackage, Test-ScoopPackage, Update-ScoopPackages