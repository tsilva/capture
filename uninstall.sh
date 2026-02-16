#!/bin/bash
# MD Note Capture Uninstaller
# Removes Alfred workflow and helper scripts (does NOT touch capture CLI config)

set -e

CAPTURE_CONFIG_DIR="$HOME/.config/capture"
ALFRED_WORKFLOW="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows/user.workflow.md-note-capture"

echo "MD Note Capture Uninstaller"
echo "==========================="
echo

echo "This will remove:"
echo "  - $CAPTURE_CONFIG_DIR/list-md-files.sh"
echo "  - $CAPTURE_CONFIG_DIR/prepend-to-file.sh"
echo "  - $CAPTURE_CONFIG_DIR/alfred-search.sh"
echo "  - $CAPTURE_CONFIG_DIR/notes-dir.txt"
echo "  - Alfred MD Note Capture workflow"
echo
echo "Will NOT remove capture CLI config (client_secret.json, targets.json, etc.)"
echo

read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo

# Remove scripts
for script in list-md-files.sh prepend-to-file.sh alfred-search.sh; do
    if [ -f "$CAPTURE_CONFIG_DIR/$script" ]; then
        rm "$CAPTURE_CONFIG_DIR/$script"
        echo "✓ Removed $script"
    else
        echo "  $script not found"
    fi
done

# Remove notes-dir.txt
if [ -f "$CAPTURE_CONFIG_DIR/notes-dir.txt" ]; then
    rm "$CAPTURE_CONFIG_DIR/notes-dir.txt"
    echo "✓ Removed notes-dir.txt"
else
    echo "  notes-dir.txt not found"
fi

# Remove Alfred workflow
if [ -d "$ALFRED_WORKFLOW" ]; then
    rm -rf "$ALFRED_WORKFLOW"
    echo "✓ Removed Alfred MD Note Capture workflow"
else
    echo "  Alfred MD Note Capture workflow not found"
fi

echo
echo "Uninstall complete."
echo
echo "Note: Capture CLI and its config files were not removed."
echo "To uninstall the CLI: uv tool uninstall capture-cli"
