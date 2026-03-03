#!/bin/bash
# List all .md files from the notes directory for Alfred Script Filter
# Outputs note names for selection; prepend-to-file.sh handles the rest

CONFIG_FILE="$HOME/.capture/config.json"
NOTES_DIR=""
REPOS_DIR=""

# Read config.json
if [ -f "$CONFIG_FILE" ]; then
    NOTES_DIR=$(grep -o '"notes_dir": "[^"]*' "$CONFIG_FILE" | cut -d'"' -f4)
    REPOS_DIR=$(grep -o '"repos_dir": "[^"]*' "$CONFIG_FILE" | cut -d'"' -f4)
fi

# --- Build Alfred items ---
items='{"title":"gmail","subtitle":"Capture a quick idea","arg":"gmail","match":"gmail idea","icon":{"path":"'$HOME'/.capture/gmail.png"}}'

# If notes dir is not configured or missing, show gmail + error
if [ -z "$NOTES_DIR" ] || [ ! -d "$NOTES_DIR" ]; then
    items="${items},{\"title\":\"Notes dir not configured\",\"subtitle\":\"Edit ~/.capture/config.json\",\"valid\":false}"
    echo "{\"items\":[${items}]}"
    exit 0
fi

# List .md files from notes directory
for md_file in "$NOTES_DIR"/*.md; do
    [ -f "$md_file" ] || continue
    filename="$(basename "$md_file" .md)"
    escaped="${filename//\"/\\\"}"

    # Icon logic: git- prefixed files check repos dir for logo.png
    icon_json=""
    if [ -n "$REPOS_DIR" ]; then
        case "$filename" in
            git-*)
                repo_name="${filename#git-}"
                if [ -f "$REPOS_DIR/$repo_name/logo.png" ]; then
                    icon_json=",\"icon\":{\"path\":\"$REPOS_DIR/$repo_name/logo.png\"}"
                fi
                ;;
        esac
    fi

    items="${items},{\"title\":\"${escaped}\",\"subtitle\":\"Add note to ${escaped}.md\",\"arg\":\"${escaped}\",\"match\":\"${escaped}\"${icon_json}}"
done

echo "{\"items\":[${items}]}"
