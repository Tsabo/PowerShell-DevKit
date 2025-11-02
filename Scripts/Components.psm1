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

# Custom installer functions for components requiring special handling
function Install-OhMyPoshWithFont {
    param([string]$FontName = "CascadiaCode")

    # Install oh-my-posh via winget with timeout protection
    $installed = winget list --id "JanDeDobbeleer.OhMyPosh" --exact --disable-interactivity 2>$null
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0 -or $installed -notmatch "JanDeDobbeleer.OhMyPosh") {
        $installOutput = winget install JanDeDobbeleer.OhMyPosh --silent --disable-interactivity --accept-package-agreements --accept-source-agreements 2>&1
        $installExitCode = $LASTEXITCODE

        # Check for common "already installed" patterns in output
        $outputString = $installOutput | Out-String
        $alreadyInstalled = $outputString -match "already installed|No available upgrade|No newer package versions"

        if ($installExitCode -ne 0 -and -not $alreadyInstalled) {
            Write-Warning "oh-my-posh installation failed with exit code: $installExitCode"
            Write-Warning "Output: $outputString"
            return $false
        }
    }

    # Note: Font installation is handled separately via the CascadiaCode Font component
    # We don't install it here to avoid duplicate installations
    return $true
}

function Install-CascadiaCodeFont {
    # Check if oh-my-posh is available (required for font installation)
    if (-not (Test-CommandExists "oh-my-posh")) {
        Write-Warning "oh-my-posh is required to install fonts. Please install oh-my-posh first."
        return $false
    }

    # Check if font is already installed by looking for font files in Windows Fonts directory
    $fontsPath = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
    $systemFontsPath = "C:\Windows\Fonts"

    $cascadiaFontFiles = @(
        Get-ChildItem -Path $fontsPath -Filter "Cascadia*" -ErrorAction SilentlyContinue
        Get-ChildItem -Path $systemFontsPath -Filter "Cascadia*" -ErrorAction SilentlyContinue
    )

    if ($cascadiaFontFiles.Count -gt 0) {
        Write-Host "  ✓ CascadiaCode font already installed" -ForegroundColor Green
        return $true
    }

    # Install font using oh-my-posh
    Write-Host "  → Installing CascadiaCode font via oh-my-posh..." -ForegroundColor Gray
    try {
        $output = oh-my-posh font install CascadiaCode 2>&1
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0) {
            Write-Host "  ✓ CascadiaCode font installed successfully" -ForegroundColor Green
            return $true
        }
        else {
            Write-Warning "Font installation failed with exit code: $exitCode"
            Write-Warning "Output: $($output | Out-String)"
            return $false
        }
    }
    catch {
        Write-Warning "Font installation exception: $_"
        return $false
    }
}

function Install-YaziWithConfig {
    Write-Host "  → Installing Yazi..." -ForegroundColor Gray

    # Install Yazi
    $installed = winget list --id "sxyazi.yazi" --exact --disable-interactivity 2>$null
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0 -or $installed -notmatch "sxyazi.yazi") {
        Write-Host "  → Downloading and installing Yazi binary..." -ForegroundColor Gray
        $installOutput = winget install sxyazi.yazi --silent --disable-interactivity --accept-package-agreements --accept-source-agreements 2>&1
        $installExitCode = $LASTEXITCODE

        # Check for common "already installed" patterns in output
        $outputString = $installOutput | Out-String
        $alreadyInstalled = $outputString -match "already installed|No available upgrade|No newer package versions"

        if ($installExitCode -ne 0 -and -not $alreadyInstalled) {
            Write-Warning "Yazi installation failed with exit code: $installExitCode"
            Write-Warning "Output: $outputString"
            return $false
        }
        Write-Host "  ✓ Yazi binary installed" -ForegroundColor Green
    }
    else {
        Write-Host "  ✓ Yazi binary already installed" -ForegroundColor Green
    }

    # Install optional dependencies with progress feedback
    Write-Host "  → Installing optional dependencies for enhanced functionality..." -ForegroundColor Gray

    $optionalDeps = @(
        @{Name = "FFmpeg"; PackageId = "Gyan.FFmpeg"; Description = "video thumbnails" }
        @{Name = "7-Zip"; PackageId = "7zip.7zip"; Description = "archive previews" }
        @{Name = "jq"; PackageId = "jqlang.jq"; Description = "JSON previews" }
        @{Name = "Poppler"; PackageId = "Poppler"; Description = "PDF previews" }
        @{Name = "fd"; PackageId = "sharkdp.fd"; Description = "file searching" }
        @{Name = "ripgrep"; PackageId = "BurntSushi.ripgrep.MSVC"; Description = "content searching" }
        @{Name = "ImageMagick"; PackageId = "ImageMagick.ImageMagick"; Description = "image conversions" }
    )

    $depCount = $optionalDeps.Count
    $depIndex = 0
    foreach ($dep in $optionalDeps) {
        $depIndex++
        Write-Host "    → [$depIndex/$depCount] Checking $($dep.Name) (for $($dep.Description))..." -ForegroundColor Gray

        # Check if already installed
        Write-Host "      → Checking installation status (timeout: 15s)..." -ForegroundColor DarkGray
        $checkJob = Start-Job -ScriptBlock {
            param($packageId)
            winget list --id $packageId --exact --disable-interactivity 2>&1
            return $LASTEXITCODE
        } -ArgumentList $dep.PackageId

        $checkCompleted = Wait-Job -Job $checkJob -Timeout 15
        if ($checkCompleted) {
            $checkOutput = Receive-Job -Job $checkJob
            $checkExitCode = $checkOutput[-1]  # Last item is the exit code
            Remove-Job -Job $checkJob

            $alreadyInstalled = $checkExitCode -eq 0 -and ($checkOutput -join "`n") -match $dep.PackageId

            if (-not $alreadyInstalled) {
                Write-Host "      → Installing $($dep.Name) (timeout: 60s)..." -ForegroundColor DarkGray

                $installJob = Start-Job -ScriptBlock {
                    param($packageId)
                    winget install $packageId --silent --disable-interactivity --accept-package-agreements --accept-source-agreements 2>&1
                    return $LASTEXITCODE
                } -ArgumentList $dep.PackageId

                $installCompleted = Wait-Job -Job $installJob -Timeout 60
                if ($installCompleted) {
                    $installOutput = Receive-Job -Job $installJob
                    $installExitCode = $installOutput[-1]  # Last item is the exit code
                    Remove-Job -Job $installJob

                    $outputString = ($installOutput[0..($installOutput.Count - 2)] -join "`n")
                    $installedOk = $installExitCode -eq 0 -or $outputString -match "already installed|No available upgrade"

                    if ($installedOk) {
                        Write-Host "      ✓ $($dep.Name) installed" -ForegroundColor Green
                    }
                    else {
                        Write-Host "      ⚠ $($dep.Name) failed (optional, continuing)" -ForegroundColor Yellow
                    }
                }
                else {
                    Stop-Job -Job $installJob
                    Remove-Job -Job $installJob
                    Write-Host "      ⚠ $($dep.Name) installation timed out (optional, continuing)" -ForegroundColor Yellow
                }
            }
            else {
                Write-Host "      ✓ $($dep.Name) already installed" -ForegroundColor Green
            }
        }
        else {
            Stop-Job -Job $checkJob
            Remove-Job -Job $checkJob
            Write-Host "      ⚠ $($dep.Name) check timed out (optional, continuing)" -ForegroundColor Yellow
        }
    }

    # Setup Yazi configuration from git repo
    Write-Host "  → Setting up Yazi configuration..." -ForegroundColor Gray
    $yaziConfigDest = Join-Path $env:APPDATA "yazi"

    try {
        if (-not (Test-Path $yaziConfigDest)) {
            Write-Host "  → Cloning yazi_config repository (timeout: 30s)..." -ForegroundColor Gray
            $gitJob = Start-Job -ScriptBlock {
                param($dest)
                git clone "https://github.com/Tsabo/yazi_config.git" $dest 2>&1 | Out-Null
                return $LASTEXITCODE
            } -ArgumentList $yaziConfigDest

            $gitCompleted = Wait-Job -Job $gitJob -Timeout 30
            if ($gitCompleted) {
                $gitOutput = Receive-Job -Job $gitJob
                Remove-Job -Job $gitJob
                # Get the last item which is the exit code
                $gitExitCode = $gitOutput | Select-Object -Last 1

                if ($gitExitCode -eq 0) {
                    Write-Host "  ✓ Yazi configuration cloned successfully" -ForegroundColor Green
                }
                else {
                    Write-Host "  ✗ Git clone failed, skipping config setup" -ForegroundColor Yellow
                }
            }
            else {
                Stop-Job -Job $gitJob
                Remove-Job -Job $gitJob
                Write-Host "  ✗ Git clone timed out, skipping config setup" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "  ℹ Config directory already exists" -ForegroundColor Cyan

            # Check if it's a git repository
            $isGitRepo = Test-Path (Join-Path $yaziConfigDest ".git")

            if ($isGitRepo) {
                Write-Host "  → Checking for local modifications..." -ForegroundColor Gray

                Push-Location $yaziConfigDest
                try {
                    # Check for uncommitted changes
                    $gitStatus = git status --porcelain 2>$null
                    $hasLocalChanges = $gitStatus -and $gitStatus.Trim()

                    if ($hasLocalChanges) {
                        Write-Host "  ⚠ Local modifications detected - skipping update to preserve your changes" -ForegroundColor Yellow
                        Write-Host "    Modified files:" -ForegroundColor DarkGray
                        $gitStatus -split "`n" | Select-Object -First 5 | ForEach-Object {
                            Write-Host "      $_" -ForegroundColor DarkGray
                        }
                        Write-Host "    To update manually: cd `"$yaziConfigDest`" && git stash && git pull && git stash pop" -ForegroundColor DarkGray
                    }
                    else {
                        Write-Host "  → Pulling latest changes from repository..." -ForegroundColor Gray
                        $pullOutput = git pull origin main 2>&1
                        if ($LASTEXITCODE -eq 0) {
                            if ($pullOutput -match "Already up to date") {
                                Write-Host "  ✓ Configuration already up to date" -ForegroundColor Green
                            }
                            else {
                                Write-Host "  ✓ Configuration updated successfully" -ForegroundColor Green
                            }
                        }
                        else {
                            Write-Host "  ⚠ Could not update config (local changes may exist)" -ForegroundColor Yellow
                        }
                    }
                }
                finally {
                    Pop-Location
                }
            }
            else {
                Write-Host "  ℹ Config exists but is not a git repository - leaving unchanged" -ForegroundColor Cyan
            }
        }
    }
    catch {
        Write-Host "  ✗ Config setup failed: $_" -ForegroundColor Yellow
    }

    # Install Yazi plugins with progress feedback
    Write-Host "  → Installing Yazi plugins..." -ForegroundColor Gray

    # Check if ya command is available (Yazi package manager)
    if (-not (Test-CommandExists "ya")) {
        Write-Host "  ⚠ Yazi package manager (ya) not found - skipping plugins" -ForegroundColor Yellow
        Write-Host "    You may need to restart your terminal and run 'Install-YaziOptionals -PluginsOnly'" -ForegroundColor DarkGray
    }
    else {
        # Define plugins to install
        $yaziPlugins = @(
            # plugins
            @{Name = "git"; Package = "yazi-rs/plugins:git"; Description = "git integration" }
            @{Name = "githead"; Package = "Tsabo/githead"; Description = "git status in header" }
            @{Name = "piper"; Package = "yazi-rs/plugins:piper"; Description = "previewer" }

            #flavors
            @{Name = "flexoki-light"; Package = "gosxrgxx/flexoki-light"; Description = "light theme" }
            @{Name = "vscode-dark-plus"; Package = "956MB/vscode-dark-plus"; Description = "dark theme" }
        )

        $pluginCount = $yaziPlugins.Count
        $pluginIndex = 0

        foreach ($plugin in $yaziPlugins) {
            $pluginIndex++
            Write-Host "    → [$pluginIndex/$pluginCount] Installing $($plugin.Name) plugin ($($plugin.Description))..." -ForegroundColor Gray

            try {
                $output = & { ya pkg add $plugin.Package } 2>&1
                $exitCode = $LASTEXITCODE
                $outputString = ($output | Out-String).Trim()

                if ($exitCode -eq 0 -or $outputString -match "already|installed|updated|success|exists") {
                    if ($outputString -match "already exists") {
                        Write-Host "      ✓ $($plugin.Name) plugin already installed" -ForegroundColor Green
                    }
                    else {
                        Write-Host "      ✓ $($plugin.Name) plugin installed" -ForegroundColor Green
                    }
                }
                else {
                    Write-Host "      ⚠ $($plugin.Name) plugin failed (optional, continuing)" -ForegroundColor Yellow
                    if ($outputString) {
                        Write-Host "        Output: $outputString" -ForegroundColor DarkGray
                    }
                }
            }
            catch {
                Write-Host "      ⚠ $($plugin.Name) plugin failed: $_ (optional, continuing)" -ForegroundColor Yellow
            }
        }
    }    return $true
}

function Deploy-OhMyPoshTheme {
    $scriptRoot = Split-Path -Parent $PSCommandPath
    $ompConfigSource = Join-Path (Split-Path $scriptRoot) "Config\oh-my-posh"

    # Try OneDrive location first, fallback to regular Documents
    $ompConfigDest = Join-Path $env:USERPROFILE "OneDrive\PowerShell\Posh"
    if (-not (Test-Path (Split-Path $ompConfigDest))) {
        $ompConfigDest = Join-Path $env:USERPROFILE "Documents\PowerShell\Posh"
    }

    if (Test-Path $ompConfigSource) {
        if (-not (Test-Path $ompConfigDest)) {
            New-Item -ItemType Directory -Path $ompConfigDest -Force | Out-Null
        }
        Copy-Item "$ompConfigSource\*.json" -Destination $ompConfigDest -Force
        return $true
    }
    return $true
}

function Deploy-PowerShellProfile {
    $scriptRoot = Split-Path -Parent $PSCommandPath
    $profilePath = $PROFILE
    $profileDir = Split-Path -Parent $profilePath
    $psSourceDir = Join-Path (Split-Path $scriptRoot) "PowerShell"

    $deployments = @(
        @{Source = "Microsoft.PowerShell_profile.ps1"; Dest = $profilePath; Name = "PowerShell profile" }
        @{Source = "powershell.config.json"; Dest = (Join-Path $profileDir "powershell.config.json"); Name = "PowerShell config" }
        @{Source = "IncludedModules"; Dest = (Join-Path $profileDir "IncludedModules"); Name = "IncludedModules"; IsDirectory = $true }
        @{Source = "IncludedScripts"; Dest = (Join-Path $profileDir "IncludedScripts"); Name = "IncludedScripts"; IsDirectory = $true }
    )

    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    foreach ($deployment in $deployments) {
        $sourcePath = Join-Path $psSourceDir $deployment.Source
        if (Test-Path $sourcePath) {
            if ($deployment.IsDirectory -and (Test-Path $deployment.Dest)) {
                Remove-Item $deployment.Dest -Recurse -Force
            }
            Copy-Item $sourcePath -Destination $deployment.Dest -Recurse:$deployment.IsDirectory -Force
        }
    }

    # Create custom directories and copy READMEs
    $customModulesDir = Join-Path $profileDir "CustomModules"
    $customScriptsDir = Join-Path $profileDir "CustomScripts"

    if (-not (Test-Path $customModulesDir)) {
        New-Item -ItemType Directory -Path $customModulesDir -Force | Out-Null
    }
    if (-not (Test-Path $customScriptsDir)) {
        New-Item -ItemType Directory -Path $customScriptsDir -Force | Out-Null
    }

    # Copy READMEs for custom directories
    $customModulesReadme = Join-Path $psSourceDir "CustomModules\README.md"
    $customScriptsReadme = Join-Path $psSourceDir "CustomScripts\README.md"

    if (Test-Path $customModulesReadme) {
        Copy-Item $customModulesReadme -Destination (Join-Path $customModulesDir "README.md") -Force
    }
    if (Test-Path $customScriptsReadme) {
        Copy-Item $customScriptsReadme -Destination (Join-Path $customScriptsDir "README.md") -Force
    }

    # Copy CustomProfile.ps1 template if it doesn't exist
    $customProfileTemplate = Join-Path $psSourceDir "CustomProfile.ps1.template"
    $customProfile = Join-Path $profileDir "CustomProfile.ps1"

    if ((Test-Path $customProfileTemplate) -and (-not (Test-Path $customProfile))) {
        Copy-Item $customProfileTemplate -Destination $customProfile -Force
    }

    return $true
}

function Deploy-TerminalSettings {
    $scriptRoot = Split-Path -Parent $PSCommandPath
    $terminalDeployScript = Join-Path $scriptRoot "Deploy-Terminal.ps1"

    if (Test-Path $terminalDeployScript) {
        try {
            & $terminalDeployScript -NoBackup 2>&1 | Out-Null
            return ($LASTEXITCODE -eq 0)
        }
        catch {
            return $false
        }
    }
    return $true
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

function Test-CascadiaCodeFont {
    # Check for CascadiaCode font files in Windows Fonts directories
    $fontsPath = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
    $systemFontsPath = "C:\Windows\Fonts"

    $cascadiaFontFiles = @(
        Get-ChildItem -Path $fontsPath -Filter "Cascadia*" -ErrorAction SilentlyContinue
        Get-ChildItem -Path $systemFontsPath -Filter "Cascadia*" -ErrorAction SilentlyContinue
    )

    if ($cascadiaFontFiles.Count -gt 0) {
        return @{
            IsInstalled = $true
            Version = "installed"
        }
    }
    else {
        return @{
            IsInstalled = $false
        }
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
        [SetupComponent]::new("gsudo", "winget", @{PackageId = "gerardog.gsudo" }, $true)
        [SetupComponent]::new("oh-my-posh", { Install-OhMyPoshWithFont }, { Test-OhMyPosh }, $false)
        [SetupComponent]::new("CascadiaCode Font", { Install-CascadiaCodeFont }, { Test-CascadiaCodeFont }, $false)
        [SetupComponent]::new("fzf", "winget", @{PackageId = "junegunn.fzf" })
        [SetupComponent]::new("PSFzf", "module", @{ModuleName = "PSFzf" })
        [SetupComponent]::new("Terminal-Icons", "module", @{ModuleName = "Terminal-Icons" })
        [SetupComponent]::new("F7History", "module", @{ModuleName = "F7History" })
        [SetupComponent]::new("zoxide", "winget", @{PackageId = "ajeetdsouza.zoxide" })
        [SetupComponent]::new("Microsoft Edit", "winget", @{PackageId = "Microsoft.Edit" })
        [SetupComponent]::new("posh-git", "module", @{ModuleName = "posh-git" })
        [SetupComponent]::new("PowerColorLS", "module", @{ModuleName = "PowerColorLS" }, $true)
        [SetupComponent]::new("glow", "winget", @{PackageId = "charmbracelet.glow" })
        [SetupComponent]::new("Scoop", { Install-Scoop }, { Test-ScoopInstalled }, $true)
        [SetupComponent]::new("resvg", { Install-ScoopPackage -PackageName "resvg" -DisplayName "resvg" }, { Test-ScoopPackage -PackageName "resvg" }, $true)
        [SetupComponent]::new("Yazi", { Install-YaziWithConfig }, { Test-Yazi }, $false)
        [SetupComponent]::new("PowerShell Profile", { Deploy-PowerShellProfile }, { Test-PowerShellProfile }, $false)
        [SetupComponent]::new("Windows Terminal", { Deploy-TerminalSettings }, { Test-WindowsTerminal }, $false)
    )
}

# Validate a single component
function Test-EnvironmentComponent {
    param($Component)

    switch ($Component.Type) {
        "winget" {
            $version = Get-WingetPackageVersion -PackageId $Component.Properties.PackageId
            $isInstalled = $version -ne $null

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
        }
        else {
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
        }
        else {
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
        }
        else {
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
            }
            else {
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
                    }
                    else {
                        Write-Host "Configuration update skipped (local changes may exist)" -ForegroundColor Yellow
                    }
                }
                finally {
                    Pop-Location
                }
            }

            return $true
        }
        else {
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
