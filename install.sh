#!/bin/bash
set -e

INSTALL_PATH="/usr/local/bin"
SCRIPT_NAME="CPA"
CPA_DIR="$HOME/.CPA"

SCRIPT_URL="https://raw.githubusercontent.com/sourav739397/Competitive-Programming-Assistant/main/CPA.sh"
DEBUG_URL="https://raw.githubusercontent.com/sourav739397/Competitive-Programming-Assistant/main/debug.h"
TESTLIB_URL="https://raw.githubusercontent.com/sourav739397/Competitive-Programming-Assistant/main/testlib.h"


# ================ DEPENDENCY CHECKING ================
check_dependency() {
  echo -e "\033[1;36m  Checking dependencies:\033[0m"
  
  local dependencies=("g++" "gcc" "jq" "nc" "git" "curl")
  local missing_deps=()
  
  for dep in "${dependencies[@]}"; do
    if command -v "$dep" &> /dev/null; then
      echo -e "   [\033[0;32m✓\033[0m] $dep"
    else
      echo -e "   [\033[1;31m✗\033[0m] $dep (missing)"
      missing_deps+=("$dep")
    fi
  done

  if [ ${#missing_deps[@]} -ne 0 ]; then
    echo -e "\033[1;31m  Please install the missing dependencies and re-run the installer.\033[0m"
    exit 1
  else
    echo -e "\033[1;32m󰄲  All dependencies are satisfied.\033[0m"
  fi
}

check_dependency

echo -e "\033[1;36m  Installing Competitive-Programming-Assistant:\033[0m"

# Create ~/.CPA directory (always succeeds as it's in user's HOME)
echo -e "   [\033[0;32m✓\033[0m] Created $CPA_DIR"
mkdir -p "$CPA_DIR"

# # Download headers to user directory
# echo -e "   [\033[0;36m-\033[0m] Downloading header files..."
# curl -fsSL "$DEBUG_URL"   -o "$CPA_DIR/debug.h"
# curl -fsSL "$TESTLIB_URL" -o "$CPA_DIR/testlib.h"
# echo -e "   [\033[0;32m✓\033[0m] Downloaded headers to $CPA_DIR"
# chmod 644 "$CPA_DIR/"*.h

# Download headers to user directory
echo -ne "   [\033[0;36m-\033[0m] Downloading header files"
(
  curl -fsSL "$DEBUG_URL"   -o "$CPA_DIR/debug.h" 2>/dev/null &&
  curl -fsSL "$TESTLIB_URL" -o "$CPA_DIR/testlib.h" 2>/dev/null
) &

PID=$!
dots=""
while kill -0 "$PID" 2>/dev/null; do
  dots+="."
  [[ ${#dots} -gt 3 ]] && dots=""
  printf "\r   [\033[0;36m-\033[0m] Downloading header files%s" "$dots"
  sleep 0.3
done
wait "$PID"

echo -e "\r\033[K   [\033[0;32m✓\033[0m] Downloaded headers to $CPA_DIR"


# =============== INSTALL MAIN SCRIPT ================
sudo curl -fsSL "$SCRIPT_URL" -o "$INSTALL_PATH/$SCRIPT_NAME"
sudo chmod +x "$INSTALL_PATH/$SCRIPT_NAME"
echo -e "   [\033[0;32m✓\033[0m] Installed CPA script to $INSTALL_PATH"


# =================== DONE ====================
echo -e "\033[1;32m󰄲  Installation successful:\033[0m For help run \033[1;37m\"CPA --help\"\033[0m"
exit 0