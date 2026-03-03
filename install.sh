#!/bin/bash
# MD Note Capture Installer
# Installs Alfred workflow and helper scripts for note capture

set -e

# Colors (disabled when stdout is not a TTY)
if [ -t 1 ]; then
    BOLD='\033[1m'
    DIM='\033[2m'
    RESET='\033[0m'
    CYAN='\033[36m'
    GREEN='\033[32m'
    YELLOW='\033[33m'
    RED='\033[31m'
    BCYAN='\033[1;36m'
    BWHITE='\033[1;37m'
    BGREEN='\033[1;32m'
else
    BOLD='' DIM='' RESET='' CYAN='' GREEN='' YELLOW='' RED='' BCYAN='' BWHITE='' BGREEN=''
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPTURE_CONFIG_DIR="$HOME/.capture"
ALFRED_WORKFLOWS_DIR="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows"

# Banner
echo
echo -e "${BCYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
echo -e "${BCYAN}┃   Capture  ·  Install  ┃${RESET}"
echo -e "${BCYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
echo

# [1/4] Check for Alfred
echo -e "${BWHITE}[1/4] Checking Alfred...${RESET}"
if [ -d "$ALFRED_WORKFLOWS_DIR" ]; then
    echo -e "  ${GREEN}✓${RESET} Alfred workflows directory found"
else
    echo -e "  ${YELLOW}⚠${RESET} Alfred workflows directory not found"
    echo -e "    ${DIM}Alfred workflow will not be installed${RESET}"
    ALFRED_WORKFLOWS_DIR=""
fi
echo

# [2/4] Create config directory
echo -e "${BWHITE}[2/4] Creating directories...${RESET}"
mkdir -p "$CAPTURE_CONFIG_DIR"
echo -e "  ${GREEN}✓${RESET} Created ${DIM}${CAPTURE_CONFIG_DIR}${RESET}"
echo

# [3/4] Copy scripts
echo -e "${BWHITE}[3/4] Installing scripts...${RESET}"
for script in list-md-files.sh prepend-to-file.sh alfred-search.sh; do
    cp "$SCRIPT_DIR/scripts/$script" "$CAPTURE_CONFIG_DIR/$script"
    chmod +x "$CAPTURE_CONFIG_DIR/$script"
    echo -e "  ${GREEN}✓${RESET} Installed ${DIM}${script}${RESET}"
done
cp "$SCRIPT_DIR/icons/gmail.png" "$CAPTURE_CONFIG_DIR/gmail.png"
echo -e "  ${GREEN}✓${RESET} Installed ${DIM}gmail.png${RESET}"
echo

# Validation helpers
validate_notes_dir() {
    local dir="$1"
    [ -d "$dir" ] && [ -n "$(find "$dir" -maxdepth 1 -name "*.md" -print -quit)" ]
}

validate_repos_dir() {
    local dir="$1"
    [ -d "$dir" ] && [ -n "$(find "$dir" -maxdepth 2 -name ".git" -print -quit)" ]
}

# Prompt helper for paths
prompt_path() {
    local prompt_text="$1"
    local validate_fn="$2"
    local err_msg="$3"
    local input expanded

    while true; do
        printf "  %s" "$prompt_text" >&2
        read -r input
        expanded="${input/#\~/$HOME}"
        if $validate_fn "$expanded"; then
            echo "$expanded"
            break
        else
            echo -e "  ${RED}✗${RESET} $err_msg" >&2
        fi
    done
}

# [4/4] Handle config.json
echo -e "${BWHITE}[4/4] Setting up config...${RESET}"
if [ -f "$CAPTURE_CONFIG_DIR/config.json" ]; then
    echo -e "  ${GREEN}✓${RESET} Existing ${DIM}config.json${RESET} found ${DIM}(keeping your customizations)${RESET}"
else
    NOTES_DIR=$(prompt_path "Enter path to your notes directory: " "validate_notes_dir" "Directory doesn't exist or contains no .md files")
    REPOS_DIR=$(prompt_path "Enter path to your repos directory: " "validate_repos_dir" "Directory doesn't exist or contains no git repos")

    cat > "$CAPTURE_CONFIG_DIR/config.json" <<EOF
{
  "notes_dir": "$NOTES_DIR",
  "repos_dir": "$REPOS_DIR"
}
EOF
    echo -e "  ${GREEN}✓${RESET} Created ${DIM}config.json${RESET}"
fi

if [ -n "$ALFRED_WORKFLOWS_DIR" ]; then
    WORKFLOW_DEST="$ALFRED_WORKFLOWS_DIR/user.workflow.md-note-capture"
    mkdir -p "$WORKFLOW_DEST"
    sed "s|__HOME__|$HOME|g" "$SCRIPT_DIR/alfred/md-note-capture/info.plist" > "$WORKFLOW_DEST/info.plist"
    echo -e "  ${GREEN}✓${RESET} Installed Alfred workflow: ${DIM}MD Note Capture${RESET}"
fi
echo

# Summary
echo -e "${BGREEN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
echo -e "${BGREEN}┃   Installation complete! ✓     ┃${RESET}"
echo -e "${BGREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
echo
echo -e "${BWHITE}Usage:${RESET}"
echo -e "  Type ${BCYAN}c${RESET} in Alfred to list notes and gmail"
echo -e "  Select a note to add text to ${DIM}<notes-dir>/<note>.md${RESET}"
echo -e "  Select ${BCYAN}gmail${RESET} to capture a quick idea via Gmail"
echo
echo -e "${BWHITE}Configuration:${RESET}"
echo -e "  ${DIM}${CAPTURE_CONFIG_DIR}/config.json${RESET}  Notes and repos folder paths"
