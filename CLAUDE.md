# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Capture is a CLI tool for quickly sending thoughts/ideas to Gmail, implementing GTD (Getting Things Done) methodology. It uses Gmail API with OAuth2 authentication. It also includes an Alfred workflow (MD Note Capture) for adding notes to markdown files and quick idea capture via the CLI.

## Build and Installation

```bash
# Install CLI locally with uv
uv tool install .

# Install CLI from GitHub
uv tool install git+https://github.com/tsilva/capture.git

# Install Alfred workflow and helper scripts
./install.sh

# Remove Alfred workflow and helper scripts
./uninstall.sh
```

## Usage

```bash
capture <target> <message>
# Example: capture "home" "Buy groceries"
```

## Architecture

This is a single-module Python CLI application:

- **capture.py** - Entire application logic including:
  - Gmail API authentication via OAuth2 (oauth2client library)
  - Config file management (client_secret.json, targets.json, gmail.storage)
  - Email construction and sending

**Config directory:** `~/.config/capture/` (Linux/Mac) or `%APPDATA%\capture\` (Windows)

**Required config files:**
- `client_secret.json` - OAuth credentials from Google Cloud Console
- `targets.json` - Email target mappings (e.g., `{"home": {"from": "...", "to": "..."}}`)

**Entry point:** `capture:main` function, registered via pyproject.toml `[project.scripts]`

**Alfred Workflow (MD Note Capture):** `install.sh` copies helper scripts to `~/.config/capture/` and installs an Alfred workflow. The `list-md-files.sh` script scans `~/repos/tsilva/` for git repos and outputs Alfred Script Filter JSON with an `@email` item for quick idea capture. `prepend-to-file.sh` shows an osascript dialog and prepends text to `<notes-dir>/<repo-name>.md` (configured via `notes-dir.txt`). For `@email`, it runs `capture home "<text>"` via the CLI.

**Notes config:** `~/.config/capture/notes-dir.txt` - path to the directory where repo notes are stored

## Dependencies

- google-api-python-client - Gmail API client
- oauth2client - OAuth2 authentication
- httplib2 - HTTP client for API calls

- README.md should be kept up to date with any significant project changes
