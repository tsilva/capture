#!/bin/bash
# Show a text input dialog and append the entered text to a markdown note
# Usage: prepend-to-file.sh <note-name>
#        prepend-to-file.sh <note-name>:::<message>  (inline mode, skips dialog)
# Reads notes directory from ~/.capture/config.json
# Creates <notes-dir>/<note-name>.md if it doesn't exist

INPUT="$1"
if [ -z "$INPUT" ]; then
    exit 0
fi

# Parse inline message delimiter (target:::message)
NOTE_NAME="$INPUT"
INLINE_MESSAGE=""
if [[ "$INPUT" == *":::"* ]]; then
    NOTE_NAME="${INPUT%%:::*}"
    INLINE_MESSAGE="${INPUT#*:::}"
fi

# Handle gmail
if [ "$NOTE_NAME" = "gmail" ]; then
    if [ -n "$INLINE_MESSAGE" ]; then
        "$HOME/.local/bin/capture" home "$INLINE_MESSAGE"
        exit 0
    fi
    # Legacy: show dialog
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

# Get note text: use inline message or show dialog
if [ -n "$INLINE_MESSAGE" ]; then
    NOTE="$INLINE_MESSAGE"
else
    NOTE=$(osascript -e "
        try
            set result to display dialog \"Add note to ${NOTE_NAME}.md:\" default answer \"\" buttons {\"Cancel\", \"Add\"} default button \"Add\" with title \"Add Note\"
            return text returned of result
        on error
            return \"\"
        end try
    " 2>/dev/null)
fi

# Exit if cancelled or empty
if [ -z "$NOTE" ]; then
    exit 0
fi

# Create file or append to existing
if [ ! -f "$FILE_PATH" ]; then
    printf '#process\n\n%s\n' "$NOTE" > "$FILE_PATH"
else
    # Append text to existing file
    printf '\n%s\n' "$NOTE" >> "$FILE_PATH"
fi

# Ensure first line contains #process tag
FIRST_LINE=$(head -1 "$FILE_PATH")
if ! echo "$FIRST_LINE" | grep -q '#process'; then
    if echo "$FIRST_LINE" | grep -q '^#'; then
        # First line has other tags, add #process to beginning
        sed -i '' "1s/^/#process /" "$FILE_PATH"
    else
        # No tags on first line, insert #process + blank line
        TMPFILE=$(mktemp)
        printf '#process\n\n' > "$TMPFILE"
        cat "$FILE_PATH" >> "$TMPFILE"
        mv "$TMPFILE" "$FILE_PATH"
    fi
fi
