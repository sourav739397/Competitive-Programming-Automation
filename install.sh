#!/bin/bash

set -e

INSTALL_PATH="/usr/local/bin"
SCRIPT_NAME="cprun"
# Updated GitHub raw URL to point to the actual raw content of cprun.sh
SCRIPT_URL="https://raw.githubusercontent.com/sourav739397/Competitive-Programming-Automation/main/cprun.sh"

echo "Starting CP script installer..."

# Download the script from GitHub
echo "Downloading script from GitHub..."
curl -fsSL "$SCRIPT_URL" -o "$INSTALL_PATH/$SCRIPT_NAME"

# Make it executable
chmod +x "$INSTALL_PATH/$SCRIPT_NAME"

echo "Installed: You can now use the script by typing: cprun"
