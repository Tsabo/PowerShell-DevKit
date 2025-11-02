<#
.SYNOPSIS
    Installs optional Yazi dependencies and plugins
.DESCRIPTION
    This script installs the optional dependencies and plugins for Yazi that were
    skipped during the main setup to avoid hanging issues. Run this after Yazi is installed.
.EXAMPLE
    .\Install-YaziOptionals.ps1
    Installs all optional Yazi components
.EXAMPLE
    .\Install-YaziOptionals.ps1 -DependenciesOnly
    Installs only the optional dependencies, not the plugins
.EXAMPLE
    .\Install-YaziOptionals.ps1 -PluginsOnly
    Installs only the plugins, not the dependencies
#>
[CmdletBinding()]
param(
    [switch]$DependenciesOnly,
    [switch]$PluginsOnly
)

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        Yazi Optional Components Installation               ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Install optional dependencies
if (-not $PluginsOnly) {
    Write-Host "`n📦 Installing optional dependencies..." -ForegroundColor Yellow
    Write-Host "These enhance Yazi's functionality but aren't required.`n" -ForegroundColor Gray

    $optionalDeps = @(
        @{Id = "Gyan.FFmpeg"; Name = "FFmpeg (video thumbnails)" }
        @{Id = "7zip.7zip"; Name = "7-Zip (archive support)" }
        @{Id = "jqlang.jq"; Name = "jq (JSON processing)" }
        @{Id = "oschwartz10612.Poppler"; Name = "Poppler (PDF previews)" }
        @{Id = "sharkdp.fd"; Name = "fd (fast file finder)" }
        @{Id = "BurntSushi.ripgrep.MSVC"; Name = "ripgrep (fast grep)" }
        @{Id = "junegunn.fzf"; Name = "fzf (fuzzy finder)" }
        @{Id = "ajeetdsouza.zoxide"; Name = "zoxide (smart cd)" }
        @{Id = "ImageMagick.ImageMagick"; Name = "ImageMagick (image processing)" }
    )

    $installed = 0
    foreach ($dep in $optionalDeps) {
        Write-Host "  → $($dep.Name)..." -NoNewline
        $check = winget list --id $dep.Id --exact --disable-interactivity 2>$null
        if ($LASTEXITCODE -eq 0 -and $check -match $dep.Id) {
            Write-Host " already installed" -ForegroundColor Green
            $installed++
        }
        else {
            $result = winget install $dep.Id --silent --disable-interactivity --accept-package-agreements --accept-source-agreements 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host " ✓" -ForegroundColor Green
                $installed++
            }
            else {
                Write-Host " failed" -ForegroundColor Red
            }
        }
    }
    Write-Host "`n✅ Installed $installed of $($optionalDeps.Count) dependencies" -ForegroundColor Green
}

# Install Yazi plugins
if (-not $DependenciesOnly) {
    Write-Host "`n🔌 Installing Yazi plugins..." -ForegroundColor Yellow
    Write-Host "These add extra functionality to Yazi.`n" -ForegroundColor Gray

    $plugins = @(
        "gosxrgxx/flexoki-light"
        "956MB/vscode-dark-plus"
        "yazi-rs/plugins:git"
        "Tsabo/githead.yazi#feature/guards_save_sync_block_with_pcall"
    )

    foreach ($plugin in $plugins) {
        Write-Host "  → $plugin..." -NoNewline
        try {
            & ya pkg add $plugin 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host " ✓" -ForegroundColor Green
            }
            else {
                Write-Host " failed" -ForegroundColor Red
            }
        }
        catch {
            Write-Host " failed" -ForegroundColor Red
        }
    }
}

Write-Host "`n🎉 Yazi optional components installation complete!" -ForegroundColor Green
Write-Host "`n💡 Tip: Restart Yazi to use the new plugins and themes." -ForegroundColor Cyan
