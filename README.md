<div align="center">
  <img src="logo.png" alt="capture" width="512"/>

  # capture

  [![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/)
  [![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
  [![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)](https://github.com/tsilva/capture)

  **🧠 Clear your mind instantly — capture thoughts to Gmail with a single command ⚡**

  [Quick Start](#quick-start) · [Installation](#installation) · [Configuration](#configuration)
</div>

---

## Overview

Capture implements the **Getting Things Done (GTD)** methodology by letting you dump thoughts, tasks, and ideas from your mind into Gmail instantly. Stop letting random thoughts interrupt your focus — capture them in seconds and process them later.

## Features

- **⚡ Instant capture** — Send notes to Gmail in under 2 seconds
- **🎯 Multiple targets** — Route messages to different inboxes (home, work, etc.)
- **🔒 Secure OAuth2** — Gmail API authentication, no passwords stored
- **💻 Cross-platform** — Works on macOS, Linux, and Windows
- **⌨️ Hotkey ready** — AutoHotkey (Windows) integration included

## Quick Start

```bash
# Install
uv tool install git+https://github.com/tsilva/capture.git

# Capture a thought
capture home "Buy groceries after work"
```

## Installation

### Prerequisites

- Python 3.8+
- [uv](https://docs.astral.sh/uv/getting-started/installation/) package manager
- Google Cloud project with Gmail API enabled

### Install

| Method | Command |
|--------|---------|
| From GitHub | `uv tool install git+https://github.com/tsilva/capture.git` |
| Local clone | `git clone https://github.com/tsilva/capture.git && cd capture && uv tool install .` |

### Gmail API Setup

1. Create a project in [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the **Gmail API**
3. Go to **Credentials** → **Create Credentials** → **OAuth 2.0 Client ID**
4. Select **Desktop app** as application type
5. Download and save as `client_secret.json` in your [config directory](#config-directory)

## Configuration

### Config Directory

| Platform | Location |
|----------|----------|
| macOS / Linux | `~/.config/capture/` |
| Windows | `%APPDATA%\capture\` |

### Required Files

**client_secret.json** — OAuth credentials from Google Cloud Console

**targets.json** — Email routing configuration:

```json
{
  "home": {
    "from": "you@gmail.com",
    "to": "you@gmail.com"
  },
  "work": {
    "from": "you@gmail.com",
    "to": "work@company.com"
  }
}
```

## Usage

```bash
capture <target> <message>
```

| Argument | Description |
|----------|-------------|
| `target` | Key from `targets.json` (e.g., `home`, `work`) |
| `message` | The thought or note to capture |

### Examples

```bash
# Personal reminder
capture home "Call dentist to schedule appointment"

# Work task
capture work "Review PR #42 before standup"

# Quick idea
capture home "Blog post idea: productivity tips for developers"
```

## Hotkey Integration

### AutoHotkey (Windows)

1. Install [AutoHotkey](https://www.autohotkey.com/)
2. Copy `autohotkey/capture-home.ahk.example` to `capture-home.ahk`
3. Edit the target if needed and run the script
4. Press **F1** to capture thoughts instantly

## Troubleshooting

### First Run Authentication

On first use, a browser window opens for Gmail authorization. Grant access to allow capture to send emails on your behalf.

### Missing Config Files

If you see "Missing required configuration files":

1. Ensure `client_secret.json` exists in your config directory
2. Create `targets.json` with at least one target defined
3. Run `capture` again to authenticate

---

<p align="center">
  Built with Python and Gmail API
</p>


## License

MIT
