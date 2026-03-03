#!/bin/bash
# List all .md files from the notes directory for Alfred Script Filter
# Outputs note names for selection; prepend-to-file.sh handles the rest

# --- Read notes dir from config ---
NOTES_DIR=""
NOTES_CONFIG="$HOME/.config/capture/notes-dir.txt"
if [ -f "$NOTES_CONFIG" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
            \#*|"") continue ;;
        esac
        NOTES_DIR="$line"
        break
    done < "$NOTES_CONFIG"
fi

# Expand ~
case "$NOTES_DIR" in
    "~/"*) NOTES_DIR="$HOME/${NOTES_DIR#\~/}" ;;
    "~") NOTES_DIR="$HOME" ;;
esac

# --- Read repos dir from config ---
REPOS_DIR=""
REPOS_CONFIG="$HOME/.config/capture/repos-dir.txt"
if [ -f "$REPOS_CONFIG" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
            \#*|"") continue ;;
        esac
        REPOS_DIR="$line"
        break
    done < "$REPOS_CONFIG"
fi

# Expand ~
case "$REPOS_DIR" in
    "~/"*) REPOS_DIR="$HOME/${REPOS_DIR#\~/}" ;;
    "~") REPOS_DIR="$HOME" ;;
esac

# --- Build Alfred items ---
items='{"title":"gmail","subtitle":"Capture a quick idea","arg":"gmail","match":"gmail idea","icon":{"path":"'$HOME'/.config/capture/gmail.png"}}'

# If notes dir is not configured or missing, show gmail + error
if [ -z "$NOTES_DIR" ] || [ ! -d "$NOTES_DIR" ]; then
    items="${items},{\"title\":\"Notes dir not configured\",\"subtitle\":\"Edit ~/.config/capture/notes-dir.txt\",\"valid\":false}"
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
