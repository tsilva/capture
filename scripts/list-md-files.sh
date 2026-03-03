#!/bin/bash
# Alfred Script Filter: list targets with inline compose support
# States:
#   "" or partial  → target selection (prefix-filtered, with autocomplete)
#   "<target> "    → compose prompt ("Type your message...")
#   "<target> msg" → actionable item (arg = "target:::msg")

QUERY="${1:-}"
shopt -s nocasematch
CONFIG_FILE="$HOME/.capture/config.json"
NOTES_DIR=""
REPOS_DIR=""

if [ -f "$CONFIG_FILE" ]; then
    NOTES_DIR=$(grep -o '"notes_dir": "[^"]*' "$CONFIG_FILE" | cut -d'"' -f4)
    REPOS_DIR=$(grep -o '"repos_dir": "[^"]*' "$CONFIG_FILE" | cut -d'"' -f4)
fi

# JSON-escape a string (handles backslashes and double quotes)
json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    printf '%s' "$s"
}

# --- Collect targets as pipe-delimited: name|subtitle|icon_path ---
TARGETS=()
TARGETS+=("gmail|Capture a quick idea|$HOME/.capture/gmail.png")

if [ -n "$NOTES_DIR" ] && [ -d "$NOTES_DIR" ]; then
    for md_file in "$NOTES_DIR"/*.md; do
        [ -f "$md_file" ] || continue
        filename="$(basename "$md_file" .md)"
        icon_path=""
        if [ -n "$REPOS_DIR" ]; then
            case "$filename" in
                git-*)
                    repo_name="${filename#git-}"
                    [ -f "$REPOS_DIR/$repo_name/logo.png" ] && icon_path="$REPOS_DIR/$repo_name/logo.png"
                    ;;
            esac
        fi
        TARGETS+=("${filename}|Add note to ${filename}.md|${icon_path}")
    done
fi

# Repos without existing note files
if [ -n "$REPOS_DIR" ] && [ -d "$REPOS_DIR" ] && [ -n "$NOTES_DIR" ]; then
    for repo_dir in "$REPOS_DIR"/*/; do
        [ -d "$repo_dir" ] || continue
        repo_name="$(basename "$repo_dir")"
        [ -f "$NOTES_DIR/git-${repo_name}.md" ] && continue
        icon_path=""
        [ -f "$REPOS_DIR/$repo_name/logo.png" ] && icon_path="$REPOS_DIR/$repo_name/logo.png"
        TARGETS+=("git-${repo_name}|Add note to git-${repo_name}.md|${icon_path}")
    done
fi

# --- Detect compose mode: query starts with "<known-target> " ---
MATCHED_TARGET=""
MATCHED_ICON=""
MESSAGE=""

for entry in "${TARGETS[@]}"; do
    name="${entry%%|*}"
    rest="${entry#*|}"
    icon="${rest#*|}"
    if [[ "$QUERY" == "$name "* ]]; then
        MATCHED_TARGET="$name"
        MATCHED_ICON="$icon"
        MESSAGE="${QUERY:${#name}+1}"
        break
    fi
done

if [ -n "$MATCHED_TARGET" ]; then
    # --- Compose mode ---
    escaped_target=$(json_escape "$MATCHED_TARGET")
    icon_part=""
    [ -n "$MATCHED_ICON" ] && icon_part=",\"icon\":{\"path\":\"$(json_escape "$MATCHED_ICON")\"}"

    if [ -z "$MESSAGE" ]; then
        echo "{\"items\":[{\"title\":\"Type your message...\",\"subtitle\":\"Send to ${escaped_target}\",\"valid\":false${icon_part}}]}"
    else
        escaped_msg=$(json_escape "$MESSAGE")
        echo "{\"items\":[{\"title\":\"${escaped_msg}\",\"subtitle\":\"Send to ${escaped_target}\",\"arg\":\"${escaped_target}:::${escaped_msg}\"${icon_part}}]}"
    fi
else
    # --- Target selection mode (prefix filter) ---
    items=""

    for entry in "${TARGETS[@]}"; do
        name="${entry%%|*}"
        rest="${entry#*|}"
        subtitle="${rest%%|*}"
        icon="${rest#*|}"

        if [[ -n "$QUERY" ]] && [[ "$name" != "$QUERY"* ]]; then
            continue
        fi

        escaped_name=$(json_escape "$name")
        escaped_sub=$(json_escape "$subtitle")
        icon_part=""
        [ -n "$icon" ] && icon_part=",\"icon\":{\"path\":\"$(json_escape "$icon")\"}"

        [ -n "$items" ] && items="${items},"
        items="${items}{\"title\":\"${escaped_name}\",\"subtitle\":\"${escaped_sub}\",\"arg\":\"${escaped_name}\",\"autocomplete\":\"${escaped_name} \"${icon_part}}"
    done

    if [ -z "$NOTES_DIR" ] || [ ! -d "$NOTES_DIR" ]; then
        [ -n "$items" ] && items="${items},"
        items="${items}{\"title\":\"Notes dir not configured\",\"subtitle\":\"Edit ~/.capture/config.json\",\"valid\":false}"
    fi

    if [ -z "$items" ]; then
        items="{\"title\":\"No matches\",\"subtitle\":\"No targets match your query\",\"valid\":false}"
    fi

    echo "{\"items\":[${items}]}"
fi
