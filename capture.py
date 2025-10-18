#!/usr/bin/env python

"""Command line entry point for quickly sending Gmail messages."""

import os
import sys
import json
import base64
import httplib2
import shutil
from pathlib import Path

from email.mime.text import MIMEText

from apiclient.discovery import build
from oauth2client.client import flow_from_clientsecrets
from oauth2client.file import Storage
from oauth2client.tools import run_flow, argparser


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
STORAGE_FILE = str(CONFIG_DIR / "gmail.storage")

OAUTH_SCOPE = "https://www.googleapis.com/auth/gmail.compose"
STORAGE = Storage(STORAGE_FILE)


def _build_service(flags):
    """Authorize the user and build a Gmail service object."""

    flow = flow_from_clientsecrets(CLIENT_SECRET_FILE, scope=OAUTH_SCOPE)
    http = httplib2.Http()

    credentials = STORAGE.get()
    if credentials is None or credentials.invalid:
        credentials = run_flow(flow, STORAGE, flags, http=http)

    http = credentials.authorize(http)
    return build("gmail", "v1", http=http)


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

    # Parse oauth2client flags first
    flags, remaining = argparser.parse_known_args(argv)

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

    gmail_service = _build_service(flags)

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
