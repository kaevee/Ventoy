#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
    echo "Usage: $0 <mount-point>"
    echo "Example: $0 /mnt/usb"
    exit 1
fi

DRIVE="$1"
if [ ! -d "$DRIVE" ]; then
    echo "Error: '$DRIVE' not found."
    exit 1
fi

REPO="kaevee/Ventoy"
API_URL="https://api.github.com/repos/$REPO/releases/latest"

echo "Fetching latest release from $REPO..."
RELEASE_JSON=$(curl -fsSL "$API_URL")
TAG=$(echo "$RELEASE_JSON" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4)
echo "Found release: $TAG"

VENTOY_DIR="$DRIVE/ventoy"
AUTOINSTALL_DIR="$VENTOY_DIR/autoinstall"
mkdir -p "$AUTOINSTALL_DIR"

echo "$RELEASE_JSON" | grep -o '"browser_download_url": *"[^"]*"' | cut -d'"' -f4 | while read -r url; do
    name=$(basename "$url")
    if [ "$name" = "ventoy.json" ]; then
        dest="$VENTOY_DIR/ventoy.json"
    else
        dest="$AUTOINSTALL_DIR/$name"
    fi
    echo "  -> Downloading $name..."
    curl -fsSL "$url" -o "$dest"
done

echo ""
echo "Installed Ventoy autoinstall ($TAG) to $DRIVE"
echo "  $VENTOY_DIR/ventoy.json"
echo "  $AUTOINSTALL_DIR/base.img"
echo "  $AUTOINSTALL_DIR/docker.img"

# Check for the expected ISO
ISO_NAME="ubuntu-26.04-live-server-amd64.iso"
ISO_PATH="$DRIVE/$ISO_NAME"
if [ -f "$ISO_PATH" ]; then
    echo ""
    echo "ISO found: $ISO_PATH"
else
    echo ""
    echo "WARNING: ISO not found: $ISO_PATH"
    echo "Download it from: https://ubuntu.com/download/server"
    echo "Then copy it to: $DRIVE/$ISO_NAME"
fi
