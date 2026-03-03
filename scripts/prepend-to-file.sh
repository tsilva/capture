#!/bin/bash
# Show a text input dialog and prepend the entered text to a markdown note
# Usage: prepend-to-file.sh <note-name>
# Reads notes directory from ~/.capture/config.json
# Creates <notes-dir>/<note-name>.md if it doesn't exist

NOTE_NAME="$1"
if [ -z "$NOTE_NAME" ]; then
    exit 0
fi

# Handle gmail: show dialog and run capture CLI
if [ "$NOTE_NAME" = "gmail" ]; then
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

CONFIG_FILE="$HOME/.capture/config.json"

# Read notes directory from config.json
NOTES_DIR=""
if [ -f "$CONFIG_FILE" ]; then
    NOTES_DIR=$(grep -o '"notes_dir": "[^"]*' "$CONFIG_FILE" | cut -d'"' -f4)
fi

if [ -z "$NOTES_DIR" ] || [ ! -d "$NOTES_DIR" ]; then
    osascript -e 'display dialog "Notes directory not configured.\nEdit ~/.capture/config.json" buttons {"OK"} default button "OK" with title "Error" with icon stop' 2>/dev/null
    exit 0
fi

FILE_PATH="$NOTES_DIR/${NOTE_NAME}.md"

# Show text input dialog via osascript
NOTE=$(osascript -e "
    try
        set result to display dialog \"Add note to ${NOTE_NAME}.md:\" default answer \"\" buttons {\"Cancel\", \"Add\"} default button \"Add\" with title \"Add Note\"
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
