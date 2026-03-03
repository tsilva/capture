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

**Config directory:** `~/.capture/` (all platforms)

**Config file:** `~/.capture/config.json` — consolidated configuration with structure:
```json
{
  "notes_dir": "/path/to/notes",
  "repos_dir": "/path/to/repos"
}
```

**Required config files:**
- `client_secret.json` - OAuth credentials from Google Cloud Console
- `targets.json` - Email target mappings (e.g., `{"home": {"from": "...", "to": "..."}}`)
- `config.json` - Notes and repos directory paths (created interactively by `install.sh`)

**Entry point:** `capture:main` function, registered via pyproject.toml `[project.scripts]`

**Alfred Workflow (MD Note Capture):** `install.sh` copies helper scripts to `~/.capture/` and installs an Alfred workflow. The `list-md-files.sh` script scans the notes directory (from config.json) for `.md` files and outputs Alfred Script Filter JSON with a `gmail` item (with Gmail icon) for quick idea capture. Files prefixed with `git-` get their icon from the matching repo's `logo.png` (using repos_dir from config.json). `prepend-to-file.sh` shows an osascript dialog and prepends text to `<notes_dir>/<note-name>.md` (configured via config.json). For `gmail`, it runs `capture home "<text>"` via the CLI.

## Dependencies

- google-api-python-client - Gmail API client
- oauth2client - OAuth2 authentication
- httplib2 - HTTP client for API calls

- README.md should be kept up to date with any significant project changes
