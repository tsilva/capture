# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Capture is a CLI tool for quickly sending thoughts/ideas to Gmail, implementing GTD (Getting Things Done) methodology. It uses Gmail API with OAuth2 authentication.

## Build and Installation

```bash
# Install locally with uv
uv tool install .

# Install from GitHub
uv tool install git+https://github.com/tsilva/capture.git
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

## Dependencies

- google-api-python-client - Gmail API client
- oauth2client - OAuth2 authentication
- httplib2 - HTTP client for API calls
