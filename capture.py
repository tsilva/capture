#!/usr/bin/env python

"""Command line entry point for quickly sending Gmail messages."""

import os
import sys
import json
import base64
from pathlib import Path

from email.mime.text import MIMEText

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build


# Use user's home directory for config files
def get_config_dir():
    """Get or create the config directory for capture."""
    if sys.platform == "win32":
        config_dir = Path(os.environ.get("APPDATA", Path.home())) / "capture"
    else:
        config_dir = Path.home() / ".config" / "capture"

    config_dir.mkdir(parents=True, exist_ok=True)
    return config_dir


CONFIG_DIR = get_config_dir()
CLIENT_SECRET_FILE = str(CONFIG_DIR / "client_secret.json")
TARGETS_FILE = str(CONFIG_DIR / "targets.json")
OAUTH_SCOPE = "https://www.googleapis.com/auth/gmail.compose"
CACHE_DIR = Path.home() / ".capture"
CACHE_DIR.mkdir(parents=True, exist_ok=True)
TOKEN_FILE = str(CACHE_DIR / "token.json")
SCOPES = [OAUTH_SCOPE]


def _build_service():
    """Authorize the user and build a Gmail service object."""
    creds = None
    if os.path.exists(TOKEN_FILE):
        creds = Credentials.from_authorized_user_file(TOKEN_FILE, SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(CLIENT_SECRET_FILE, SCOPES)
            creds = flow.run_local_server(port=0)
        with open(TOKEN_FILE, "w") as token:
            token.write(creds.to_json())
    return build("gmail", "v1", credentials=creds)


def _ensure_config_files():
    """Ensure config files exist, guide user if missing."""
    missing_files = []

    if not os.path.exists(CLIENT_SECRET_FILE):
        missing_files.append("client_secret.json")

    if not os.path.exists(TARGETS_FILE):
        missing_files.append("targets.json")

    if missing_files:
        print(f"Missing required configuration files in {CONFIG_DIR}:")
        for f in missing_files:
            print(f"  - {f}")
        print("\nPlease create these files:")
        print(f"1. Get client_secret.json from Google Cloud Console")
        print(f"   (Enable Gmail API and create OAuth 2.0 credentials)")
        print(f"2. Create targets.json with email mappings:")
        print('   {"home": {"from": "your@gmail.com", "to": "your@gmail.com"}}')
        print(f"\nConfig directory: {CONFIG_DIR}")
        return False

    return True


def main(argv=None):
    """Entry point for the ``capture`` command."""

    if argv is None:
        argv = sys.argv[1:]

    # Check config files first
    if not _ensure_config_files():
        return 1

    remaining = argv

    if len(remaining) < 2:
        print("Usage: capture <target> <message>")
        return 1

    target = remaining[0]
    msg = " ".join(remaining[1:])

    with open(TARGETS_FILE, "r", encoding="utf-8") as target_file:
        targets_map = json.load(target_file)

    target_map = targets_map[target]
    from_email = target_map["from"]
    to_email = target_map["to"]

    gmail_service = _build_service()

    message = MIMEText(msg)
    message["to"] = to_email
    message["from"] = from_email
    message["subject"] = msg
    message_string = message.as_string()
    message_bytes = message_string.encode("utf-8")
    message_b64_bytes = base64.b64encode(message_bytes)
    message_b64 = message_b64_bytes.decode("utf-8")
    body = {"raw": message_b64}

    try:
        message = (
            gmail_service.users().messages().send(userId="me", body=body).execute()
        )
        print("Message Id: %s" % message["id"])
        print(message)
    except Exception as error:  # pragma: no cover - network call
        print("An error occurred: %s" % error)


if __name__ == "__main__":  # pragma: no cover
    sys.exit(main())
