#!/bin/bash
# List all repos from ~/repos/tsilva/ for Alfred Script Filter (note capture)
# Outputs repo names for selection; prepend-to-file.sh handles the rest

REPOS_DIR="$HOME/repos/tsilva"

items='{"title":"gmail","subtitle":"Capture a quick idea","arg":"gmail","match":"gmail idea","icon":{"path":"'$HOME'/.config/capture/gmail.png"}}'
for repo_dir in "$REPOS_DIR"/*/ "$REPOS_DIR"/.[!.]*/; do
    [ -d "$repo_dir/.git" ] || continue
    repo_name="$(basename "$repo_dir")"
    repo_escaped="${repo_name//\"/\\\"}"

    # Check for repo logo
    if [ -f "${repo_dir}logo.png" ]; then
        icon_json=",\"icon\":{\"path\":\"${repo_dir}logo.png\"}"
    else
        icon_json=""
    fi

    if [ -n "$items" ]; then
        items="${items},"
    fi
    items="${items}{\"title\":\"${repo_escaped}\",\"subtitle\":\"Add note to ${repo_escaped}.md\",\"arg\":\"${repo_escaped}\",\"match\":\"${repo_escaped}\"${icon_json}}"
done

if [ -z "$items" ]; then
    echo '{"items":[{"title":"No repos found","subtitle":"No git repos in '"$REPOS_DIR"'","valid":false}]}'
    exit 0
fi

echo "{\"items\":[${items}]}"
