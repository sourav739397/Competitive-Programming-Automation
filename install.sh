#!/bin/bash
set -e

INSTALL_PATH="/usr/local/bin"
SCRIPT_NAME="cprun"
CPRUN_DIR="~/.cprun"

SCRIPT_URL="https://raw.githubusercontent.com/sourav739397/Competitive-Programming-Automation/main/cprun.sh"
DEBUG_URL="https://raw.githubusercontent.com/sourav739397/Competitive-Programming-Automation/main/debug.h"
TESTLIB_URL="https://raw.githubusercontent.com/sourav739397/Competitive-Programming-Automation/main/testlib.h"

echo "Starting CP script installer..."

# Create ~/.cprun directory
echo "Creating $CPRUN_DIR ..."
mkdir -p "$CPRUN_DIR"

# Download headers
echo "Downloading debug.h and testlib.h ..."
curl -fsSL "$DEBUG_URL"   -o "$CPRUN_DIR/debug.h"
curl -fsSL "$TESTLIB_URL" -o "$CPRUN_DIR/testlib.h"

chmod 644 "$CPRUN_DIR/"*.h

# Download main script
echo "Downloading cprun script..."
curl -fsSL "$SCRIPT_URL" -o "$INSTALL_PATH/$SCRIPT_NAME"

# Make executable
chmod +x "$INSTALL_PATH/$SCRIPT_NAME"

echo "Installation complete ✅"
echo "• Script : cprun"
echo "• Headers: $CPRUN_DIR/{debug.h,testlib.h}"
echo
echo "Run for help 👉  cprun --help"