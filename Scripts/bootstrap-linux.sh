#!/usr/bin/env bash
# bootstrap-linux.sh
# Installs PowerShell on Ubuntu / WSL if it isn't already, then hands off to
# Setup-Linux.ps1.  Run this first when setting up a fresh instance.
#
# Usage:
#   bash ./Scripts/bootstrap-linux.sh
#   bash ./Scripts/bootstrap-linux.sh --skip-optional
#   bash ./Scripts/bootstrap-linux.sh --set-default-shell

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PWSH_ARGS=()

for arg in "$@"; do
  case $arg in
    --skip-optional)    PWSH_ARGS+=("-SkipOptional") ;;
    --set-default-shell) PWSH_ARGS+=("-SetDefaultShell") ;;
    *) PWSH_ARGS+=("$arg") ;;
  esac
done

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         PowerShell DevKit — Linux Bootstrap                ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# ─── Ensure PowerShell is installed ────────────────────────────────────────
if command -v pwsh &>/dev/null; then
    echo "✓ PowerShell already installed: $(pwsh --version)"
else
    echo "→ PowerShell not found. Installing via Microsoft apt repository..."

    echo "  → Updating package index and installing prerequisites..."
    sudo apt-get update -qq
    sudo apt-get install -y curl wget apt-transport-https software-properties-common lsb-release

    UBUNTU_VER=$(lsb_release -rs)
    PKG_URL="https://packages.microsoft.com/config/ubuntu/${UBUNTU_VER}/packages-microsoft-prod.deb"

    echo "  → Adding Microsoft package repository (Ubuntu ${UBUNTU_VER})..."
    wget -q "$PKG_URL" -O /tmp/packages-microsoft-prod.deb
    sudo dpkg -i /tmp/packages-microsoft-prod.deb
    rm -f /tmp/packages-microsoft-prod.deb

    sudo apt-get update -qq
    echo "  → Installing PowerShell..."
    sudo apt-get install -y powershell

    if ! command -v pwsh &>/dev/null; then
        echo ""
        echo "✗ PowerShell installation failed."
        echo "  Manual install guide:"
        echo "  https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu"
        exit 1
    fi

    echo "✓ PowerShell installed: $(pwsh --version)"
fi

# ─── Run the main setup script ─────────────────────────────────────────────
echo ""
echo "→ Launching Setup-Linux.ps1..."
echo ""

pwsh -File "$SCRIPT_DIR/Setup-Linux.ps1" "${PWSH_ARGS[@]}"
