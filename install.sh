#!/bin/bash

set -e

INSTALL_PATH="/usr/bin"
SCRIPT_NAME="cp-run"
SCRIPT_URL="https://raw.githubusercontent.com/sourav739397/All-In-ONE-cp/main/run.sh"

echo "🚀 Starting CP script installer..."

# Check for root
if [ "$EUID" -ne 0 ]; then
  echo "⚠️  Please run as root: sudo sh -c \"\$(curl -fsSL https://...)\""
  exit 1
fi

echo "⬇️  Downloading script from GitHub..."
curl -fsSL "$SCRIPT_URL" -o "$INSTALL_PATH/$SCRIPT_NAME"

chmod +x "$INSTALL_PATH/$SCRIPT_NAME"

echo "✅ Installed: You can now use the script by typing: cp-run"
