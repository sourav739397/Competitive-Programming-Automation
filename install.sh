#!/bin/bash
set -e

INSTALL_PATH="/usr/local/bin"
SCRIPT_NAME="CPA"
CPA_DIR="$HOME/.CPA"

# URLS TO DOWNLOAD FILES
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
    echo -e "\033[1;31m  Installation failed:\033[0m Install the missing dependencies and re-run the command"
    exit 1
  # else
  #   echo -e "\033[1;32m󰄲  All dependencies are satisfied.\033[0m"
  fi
}

check_dependency

echo -e "\033[1;36m  Installing Competitive-Programming-Assistant:\033[0m"
# =============== CREATE CPA DIRECTORY ================
echo -e "   [\033[0;32m✓\033[0m] Created $CPA_DIR"
mkdir -p "$CPA_DIR"


# ============== DOWNLOAD HEADER FILES ==============
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
# chmod 644 "$CPA_DIR/"*.h

echo -e "\r\033[K   [\033[0;32m✓\033[0m] Downloaded headers to $CPA_DIR"


# =============== INSTALL MAIN SCRIPT ================
sudo curl -fsSL "$SCRIPT_URL" -o "$INSTALL_PATH/$SCRIPT_NAME"
sudo chmod +x "$INSTALL_PATH/$SCRIPT_NAME"
echo -e "   [\033[0;32m✓\033[0m] Installed CPA script to $INSTALL_PATH"


# ============== ADD VS CODE KEYBINDINGS ================
echo -ne "\033[1;36m󰠗  Do you want to add a VS Code keybind for CPA? (y/N): \033[0m"
read -r add_keybind
add_keybind=${add_keybind:-n}  # default no
if [[ "$add_keybind" =~ ^[Yy]$ ]]; then
  VSCODE_DIR="$HOME/.config/Code/User"
  KEYBINDINGS_FILE="$VSCODE_DIR/keybindings.json"

  # Create keybindings.json if it doesn't exist
  if [ ! -f "$KEYBINDINGS_FILE" ]; then
    echo "[]" > "$KEYBINDINGS_FILE"
    echo -e "   [\033[0;32m✓\033[0m] Created new keybindings.json"
  fi

  # Add keybinding for CPA
  echo -ne "   [\033[0;33m?\033[0m] Keybind for \033[0;33mParse problem\033[0m (default: alt+f): "
  read -r parse_key
  parse_key=${parse_key:-alt+f}

  echo -ne "   [\033[0;33m?\033[0m] Keybind for \033[0;33mRun solution against testcases\033[0m (default: alt+d): "
  read -r test_key
  test_key=${test_key:-alt+d}
  #  ==============================================
  # Add or update keybindings in the file
  temp_file=$(mktemp)
  jq "(
    (map(if .args.text == \"CPA --test -d \${fileBasename}\n\" then .key = \"$test_key\" else . end) |
     if any(.args.text == \"CPA --test -d \${fileBasename}\n\") then . else
       . += [{
         \"key\": \"$test_key\",
         \"command\": \"workbench.action.terminal.sendSequence\",
         \"args\": {
           \"text\": \"CPA --test -d \${fileBasename}\n\"
         }
       }]
     end) |
    (map(if .args.text == \"CPA --parse\n\" then .key = \"$parse_key\" else . end) |
     if any(.args.text == \"CPA --parse\n\") then . else
       . += [{
         \"key\": \"$parse_key\",
         \"command\": \"workbench.action.terminal.sendSequence\",
         \"args\": {
           \"text\": \"CPA --parse\n\"
         }
       }]
     end)
  )" "$KEYBINDINGS_FILE" > "$temp_file"
  
  mv "$temp_file" "$KEYBINDINGS_FILE"
  # ======================================

  echo -e "   [\033[0;32m✓\033[0m] Added VS Code keybinds for CPA: Parse\033[1;35m[$parse_key]\033[0m Test\033[1;35m[$test_key]\033[0m"
fi

# =================== DONE ====================
echo -e "\033[1;32m󰄲  Installation successful:\033[0m For help run \033[1;33mCPA --help\033[0m"
exit 0