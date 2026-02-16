#!/bin/bash
# MD Note Capture Uninstaller
# Removes Alfred workflow and helper scripts (does NOT touch capture CLI config)

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
    BRED='\033[1;31m'
    BYELLOW='\033[1;33m'
else
    BOLD='' DIM='' RESET='' CYAN='' GREEN='' YELLOW='' RED='' BCYAN='' BWHITE='' BRED='' BYELLOW=''
fi

CAPTURE_CONFIG_DIR="$HOME/.config/capture"
ALFRED_WORKFLOW="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows/user.workflow.md-note-capture"

# Banner
echo
echo -e "${BYELLOW}┏━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
echo -e "${BYELLOW}┃   Capture  ·  Uninstall  ┃${RESET}"
echo -e "${BYELLOW}┗━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
echo

echo -e "${BWHITE}This will remove:${RESET}"
echo -e "  ${RED}•${RESET} ${DIM}${CAPTURE_CONFIG_DIR}/list-md-files.sh${RESET}"
echo -e "  ${RED}•${RESET} ${DIM}${CAPTURE_CONFIG_DIR}/prepend-to-file.sh${RESET}"
echo -e "  ${RED}•${RESET} ${DIM}${CAPTURE_CONFIG_DIR}/alfred-search.sh${RESET}"
echo -e "  ${RED}•${RESET} ${DIM}${CAPTURE_CONFIG_DIR}/notes-dir.txt${RESET}"
echo -e "  ${RED}•${RESET} ${DIM}Alfred MD Note Capture workflow${RESET}"
echo
echo -e "${DIM}Will NOT remove capture CLI config (client_secret.json, targets.json, etc.)${RESET}"
echo

echo -ne "Continue? (${BWHITE}y${RESET}/${BWHITE}N${RESET}): "
read -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cancelled.${RESET}"
    exit 0
fi

echo

# Remove scripts
for script in list-md-files.sh prepend-to-file.sh alfred-search.sh; do
    if [ -f "$CAPTURE_CONFIG_DIR/$script" ]; then
        rm "$CAPTURE_CONFIG_DIR/$script"
        echo -e "  ${GREEN}✓${RESET} Removed ${DIM}${script}${RESET}"
    else
        echo -e "  ${DIM}─${RESET} ${DIM}${script} not found${RESET}"
    fi
done

# Remove notes-dir.txt
if [ -f "$CAPTURE_CONFIG_DIR/notes-dir.txt" ]; then
    rm "$CAPTURE_CONFIG_DIR/notes-dir.txt"
    echo -e "  ${GREEN}✓${RESET} Removed ${DIM}notes-dir.txt${RESET}"
else
    echo -e "  ${DIM}─${RESET} ${DIM}notes-dir.txt not found${RESET}"
fi

# Remove Alfred workflow
if [ -d "$ALFRED_WORKFLOW" ]; then
    rm -rf "$ALFRED_WORKFLOW"
    echo -e "  ${GREEN}✓${RESET} Removed ${DIM}Alfred MD Note Capture workflow${RESET}"
else
    echo -e "  ${DIM}─${RESET} ${DIM}Alfred MD Note Capture workflow not found${RESET}"
fi

echo
echo -e "${GREEN}Uninstall complete.${RESET}"
echo
echo -e "${DIM}Capture CLI and its config files were not removed.${RESET}"
echo -e "${DIM}To uninstall the CLI:${RESET} ${BWHITE}uv tool uninstall capture-cli${RESET}"
