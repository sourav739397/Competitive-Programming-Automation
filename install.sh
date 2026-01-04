#!/bin/bash
set -e

# ==============================================
#  Competitive Programming Assistant Installer
# ==============================================

# -------- Paths --------
INSTALL_PATH="/usr/local/bin"
SCRIPT_NAME="CPA"
CPA_DIR="$HOME/.CPA"
TEMP_DIR=$(mktemp -d)
REPO_URL="https://github.com/sourav739397/Competitive-Programming-Assistant"

# -------- Colors --------
C_OK="\033[0;32m"
C_ERR="\033[1;31m"
C_INFO="\033[1;36m"
C_WARN="\033[0;33m"
C_RST="\033[0m"

# ==============================================
# Cleanup on exit
# ==============================================
cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# ==============================================
# Download Repository
# ==============================================
download_repo() {
  echo -e "${C_INFO}  Downloading Competitive-Programming-Assistant:${C_RST}"
  cd "${TEMP_DIR}"
  git clone --depth 1 -q "$REPO_URL" CPA
  cd CPA
  echo -e "   [${C_OK}✓${C_RST}] Downloaded repository"
}

# ==============================================
# Dependency Check
# ==============================================
check_dependencies() {
  echo -e "$C_INFO  Checking dependencies:$C_RST"

  local deps=(g++ gcc git jq nc curl)
  local missing=()

  for dep in "${deps[@]}"; do
    if command -v "$dep" &>/dev/null; then
      echo -e "   [${C_OK}✓${C_RST}] $dep"
    else
      echo -e "   [${C_ERR}✗${C_RST}] $dep (missing)"
      missing+=("$dep")
    fi
  done

  if [ ${#missing[@]} -ne 0 ]; then
    echo -e "${C_ERR}  Installation failed:${C_RST} Install the missing dependencies and re-run the command"
    exit 1
  fi
}

# ==============================================
# Install CPA Files
# ==============================================
install_files() {
  echo -e "${C_INFO}  Installing Competitive-Programming-Assistant:${C_RST}"

  mkdir -p "$CPA_DIR/checkers"

  cp "$REPO_DIR/debug.h"   "$CPA_DIR/"
  cp "$REPO_DIR/testlib.h" "$CPA_DIR/"
  cp -r "$REPO_DIR/checkers/"* "$CPA_DIR/checkers/"

  sudo install -m 755 "$REPO_DIR/CPA.sh" "$INSTALL_PATH/$SCRIPT_NAME"

  echo -e "   [${C_OK}✓${C_RST}] Installed headers to $CPA_DIR"
  echo -e "   [${C_OK}✓${C_RST}] Installed checkers to $CPA_DIR/checkers"
  echo -e "   [${C_OK}✓${C_RST}] Installed CPA script to $INSTALL_PATH/$SCRIPT_NAME"
}

# ==============================================
# VS Code Keybinds (Optional)
# ==============================================
setup_vscode_keybinds() {
  echo -ne "\033[1;36m󰠗  Do you want to add a VS Code keybind for CPA? (y/N): \033[0m"
  read -r add_keybind
  add_keybind=${add_keybind:-n}  # default no
  if [[ "$add_keybind" =~ ^[Yy]$ ]]; then
    VSCODE_DIR="$HOME/.config/Code/User"
    KEYBINDINGS_FILE="$VSCODE_DIR/keybindings.json"

    # Create keybindings.json if it doesn't exist or is invalid
    if [ ! -f "$KEYBINDINGS_FILE" ] || ! jq -e 'type == "array"' "$KEYBINDINGS_FILE" &>/dev/null; then
      echo "[]" > "$KEYBINDINGS_FILE"
      echo -e "   [${C_OK}✓${C_RST}] Created new keybindings.json"
    fi

    # Add keybinding for CPA
    echo -ne "   [${C_WARN}?${C_RST}] Keybind for \033[0;33mParse problem\033[0m (default: alt+f): "
    read -r parse_key
    parse_key=${parse_key:-alt+f}

    echo -ne "   [${C_WARN}?${C_RST}] Keybind for \033[0;33mRun solution against testcases\033[0m (default: alt+d): "
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

    echo -e "   [${C_OK}✓${C_RST}] Added VS Code keybinds for CPA: Parse${C_WARN}[$parse_key]${C_RST} && Test${C_WARN}[$test_key]${C_RST}"
  fi
}

# ==============================================
# Main
# ==============================================
check_dependencies
download_repo
install_files
setup_vscode_keybinds

echo -e "$C_OK󰄲  Installation successful:$C_RST Run ${C_WARN}CPA --help${C_RST} to get started!!"
