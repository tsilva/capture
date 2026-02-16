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
CAPTURE_CONFIG_DIR="$HOME/.config/capture"
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
echo

# [4/4] Handle notes-dir.txt & Alfred
echo -e "${BWHITE}[4/4] Setting up config...${RESET}"
if [ -f "$CAPTURE_CONFIG_DIR/notes-dir.txt" ]; then
    echo -e "  ${GREEN}✓${RESET} Existing ${DIM}notes-dir.txt${RESET} found ${DIM}(keeping your customizations)${RESET}"
elif [ -f "$HOME/.config/aerospace/notes-dir.txt" ]; then
    cp "$HOME/.config/aerospace/notes-dir.txt" "$CAPTURE_CONFIG_DIR/notes-dir.txt"
    echo -e "  ${GREEN}✓${RESET} Migrated ${DIM}notes-dir.txt${RESET} from ${DIM}~/.config/aerospace/${RESET}"
else
    cp "$SCRIPT_DIR/config/notes-dir.txt.example" "$CAPTURE_CONFIG_DIR/notes-dir.txt"
    echo -e "  ${GREEN}✓${RESET} Created ${DIM}notes-dir.txt${RESET} from template"
    echo -e "    ${DIM}Edit ${CAPTURE_CONFIG_DIR}/notes-dir.txt to set your notes folder path${RESET}"
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
echo -e "  Type ${BCYAN}c${RESET} in Alfred to list repos and @email"
echo -e "  Select a repo to add a note to ${DIM}<notes-dir>/<repo>.md${RESET}"
echo -e "  Select ${BCYAN}@email${RESET} to capture a quick idea via Gmail"
echo
echo -e "${BWHITE}Configuration:${RESET}"
echo -e "  ${DIM}${CAPTURE_CONFIG_DIR}/notes-dir.txt${RESET}  Notes folder path"

# Suggest keybinding if aerospace is installed
if [ -f "$HOME/.aerospace.toml" ]; then
    echo
    echo -e "${BWHITE}Tip:${RESET} Add this to ${DIM}~/.aerospace.toml${RESET} for an ${BCYAN}alt+c${RESET} keybinding:"
    echo -e "  ${DIM}alt-c = 'exec-and-forget ~/.config/capture/alfred-search.sh c'${RESET}"
fi
