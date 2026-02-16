#!/bin/bash
# Show a text input dialog and prepend the entered text to a repo's markdown note
# Usage: prepend-to-file.sh <repo-name>
# Reads notes directory from ~/.config/capture/notes-dir.txt
# Creates <notes-dir>/<repo-name>.md if it doesn't exist

REPO_NAME="$1"
if [ -z "$REPO_NAME" ]; then
    exit 0
fi

# Handle @email: show dialog and run capture CLI
if [ "$REPO_NAME" = "@email" ]; then
    IDEA=$(osascript -e "
        try
            set result to display dialog \"Capture idea:\" default answer \"\" buttons {\"Cancel\", \"Capture\"} default button \"Capture\" with title \"Quick Capture\"
            return text returned of result
        on error
            return \"\"
        end try
    " 2>/dev/null)
    if [ -n "$IDEA" ]; then
        "$HOME/.local/bin/capture" home "$IDEA"
    fi
    exit 0
fi

CONFIG_FILE="$HOME/.config/capture/notes-dir.txt"

# Read notes directory from config (skip comments and empty lines)
NOTES_DIR=""
if [ -f "$CONFIG_FILE" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
            \#*|"") continue ;;
        esac
        NOTES_DIR="$line"
        break
    done < "$CONFIG_FILE"
fi

# Expand ~ manually
case "$NOTES_DIR" in
    "~/"*) NOTES_DIR="$HOME/${NOTES_DIR#\~/}" ;;
    "~") NOTES_DIR="$HOME" ;;
esac

if [ -z "$NOTES_DIR" ] || [ ! -d "$NOTES_DIR" ]; then
    osascript -e 'display dialog "Notes directory not configured.\nEdit ~/.config/capture/notes-dir.txt" buttons {"OK"} default button "OK" with title "Error" with icon stop' 2>/dev/null
    exit 0
fi

FILE_PATH="$NOTES_DIR/${REPO_NAME}.md"

# Show text input dialog via osascript
NOTE=$(osascript -e "
    try
        set result to display dialog \"Add note to ${REPO_NAME}.md:\" default answer \"\" buttons {\"Cancel\", \"Add\"} default button \"Add\" with title \"Add Note\"
        return text returned of result
    on error
        return \"\"
    end try
" 2>/dev/null)

# Exit if cancelled or empty
if [ -z "$NOTE" ]; then
    exit 0
fi

# Create file if it doesn't exist
if [ ! -f "$FILE_PATH" ]; then
    printf '%s\n' "$NOTE" > "$FILE_PATH"
else
    # Prepend text to existing file using temp file
    TMPFILE=$(mktemp)
    printf '%s\n\n' "$NOTE" > "$TMPFILE"
    cat "$FILE_PATH" >> "$TMPFILE"
    mv "$TMPFILE" "$FILE_PATH"
fi
