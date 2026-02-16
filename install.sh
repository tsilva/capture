#!/bin/bash
# MD Note Capture Installer
# Installs Alfred workflow and helper scripts for note capture

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPTURE_CONFIG_DIR="$HOME/.config/capture"
ALFRED_WORKFLOWS_DIR="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows"

echo "MD Note Capture Installer"
echo "========================="
echo

# Check for Alfred
if [ -d "$ALFRED_WORKFLOWS_DIR" ]; then
    echo "✓ Alfred workflows directory found"
else
    echo "⚠ Alfred workflows directory not found"
    echo "  Alfred workflow will not be installed"
    ALFRED_WORKFLOWS_DIR=""
fi

echo

# Create config directory
echo "Creating directories..."
mkdir -p "$CAPTURE_CONFIG_DIR"
echo "✓ Created $CAPTURE_CONFIG_DIR"
echo

# Copy scripts
echo "Installing scripts..."
for script in list-md-files.sh prepend-to-file.sh alfred-search.sh; do
    cp "$SCRIPT_DIR/scripts/$script" "$CAPTURE_CONFIG_DIR/$script"
    chmod +x "$CAPTURE_CONFIG_DIR/$script"
    echo "✓ Installed $script"
done
echo

# Handle notes-dir.txt
echo "Setting up notes-dir.txt..."
if [ -f "$CAPTURE_CONFIG_DIR/notes-dir.txt" ]; then
    echo "✓ Existing notes-dir.txt found (keeping your customizations)"
elif [ -f "$HOME/.config/aerospace/notes-dir.txt" ]; then
    # Migrate from aerospace-setup
    cp "$HOME/.config/aerospace/notes-dir.txt" "$CAPTURE_CONFIG_DIR/notes-dir.txt"
    echo "✓ Migrated notes-dir.txt from ~/.config/aerospace/"
else
    cp "$SCRIPT_DIR/config/notes-dir.txt.example" "$CAPTURE_CONFIG_DIR/notes-dir.txt"
    echo "✓ Created notes-dir.txt from template"
    echo "  Edit $CAPTURE_CONFIG_DIR/notes-dir.txt to set your notes folder path"
fi
echo

# Install Alfred workflow
if [ -n "$ALFRED_WORKFLOWS_DIR" ]; then
    echo "Installing Alfred workflow..."
    WORKFLOW_DEST="$ALFRED_WORKFLOWS_DIR/user.workflow.md-note-capture"
    mkdir -p "$WORKFLOW_DEST"
    sed "s|__HOME__|$HOME|g" "$SCRIPT_DIR/alfred/md-note-capture/info.plist" > "$WORKFLOW_DEST/info.plist"
    echo "✓ Installed Alfred workflow: MD Note Capture"
    echo "  Use 'c' in Alfred for notes & quick capture"
fi
echo

echo "========================="
echo "Installation complete!"
echo
echo "Usage:"
echo "  Type 'c' in Alfred to list repos and @email"
echo "  Select a repo to add a note to <notes-dir>/<repo>.md"
echo "  Select @email to capture a quick idea via Gmail"
echo
echo "Configuration:"
echo "  $CAPTURE_CONFIG_DIR/notes-dir.txt  Notes folder path"

# Suggest keybinding if aerospace is installed
if [ -f "$HOME/.aerospace.toml" ]; then
    echo
    echo "Tip: Add this to ~/.aerospace.toml for an alt+c keybinding:"
    echo "  alt-c = 'exec-and-forget ~/.config/capture/alfred-search.sh c'"
fi
