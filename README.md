<p align="center">
  <img src="logo.png" alt="capture logo" width="128">
</p>

<h1 align="center">capture</h1>

<p align="center">
  <strong>A CLI tool to quickly capture thoughts and ideas directly to Gmail</strong>
</p>

<p align="center">
  <a href="https://www.python.org/"><img src="https://img.shields.io/badge/python-3.8+-blue.svg" alt="Python 3.8+"></a>
  <a href="https://github.com/tsilva/capture"><img src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey" alt="Platform"></a>
</p>

---

## Overview

Capture helps you implement the **Getting Things Done (GTD)** methodology by providing a quick way to dump thoughts, tasks, and ideas from your mind into Gmail. Instead of keeping these thoughts in your head where they constantly demand attention, Capture lets you quickly send them to your inbox for later review and processing.

## Features

- Send quick notes to yourself or others via Gmail
- Define multiple email targets for different contexts (home, work, etc.)
- OAuth2 authentication with Gmail API
- Cross-platform support (macOS, Linux, Windows)

## Quick Start

```bash
# Install with uv
uv tool install git+https://github.com/tsilva/capture.git

# Send a quick thought
capture "home" "Buy groceries after work"
```

## Installation

### Prerequisites

- [uv](https://docs.astral.sh/uv/getting-started/installation/) package manager
- Google Cloud project with Gmail API enabled

### Install

```bash
# From GitHub
uv tool install git+https://github.com/tsilva/capture.git

# Or from local clone
git clone https://github.com/tsilva/capture.git
cd capture
uv tool install .
```

### Gmail API Setup

1. Create a project in [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the **Gmail API** for your project
3. Go to **Credentials** → **Create Credentials** → **OAuth 2.0 Client ID**
4. Select **Desktop app** as application type
5. Download the credentials file
6. Save it as `client_secret.json` in your config directory

## Configuration

### Config Directory

| Platform | Location |
|----------|----------|
| macOS/Linux | `~/.config/capture/` |
| Windows | `%APPDATA%\capture\` |

### Required Files

**client_secret.json** — OAuth credentials from Google Cloud Console

**targets.json** — Email target definitions:

```json
{
  "home": {
    "from": "your@gmail.com",
    "to": "your@gmail.com"
  },
  "work": {
    "from": "your@gmail.com",
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
| `target` | Key from your `targets.json` file |
| `message` | The thought or note to capture |

### Examples

```bash
# Capture a personal task
capture "home" "Call dentist to schedule appointment"

# Send a work reminder
capture "work" "Review PR #42 before standup"
```

## AutoHotkey Integration (Windows)

For instant capture with a hotkey:

1. Install [AutoHotkey](https://www.autohotkey.com/)
2. Copy `autohotkey/capture-home.ahk.example` to `capture-home.ahk`
3. Customize the target and run the script
4. Press **F1** to capture thoughts instantly

---

<p align="center">
  Built with Python and Gmail API
</p>
