#!/usr/bin/env python

"""Command line entry point for quickly sending Gmail messages."""

import os
import sys
import json
import base64
import httplib2

from email.mime.text import MIMEText

from apiclient.discovery import build
from oauth2client.client import flow_from_clientsecrets
from oauth2client.file import Storage
from oauth2client.tools import run_flow


CLIENT_SECRET_FILE = os.path.join(os.path.dirname(os.path.realpath(__file__)), "client_secret.json")
OAUTH_SCOPE = "https://www.googleapis.com/auth/gmail.compose"
STORAGE = Storage(os.path.join(os.path.dirname(os.path.realpath(__file__)), "gmail.storage"))


def _build_service():
    """Authorize the user and build a Gmail service object."""

    flow = flow_from_clientsecrets(CLIENT_SECRET_FILE, scope=OAUTH_SCOPE)
    http = httplib2.Http()

    credentials = STORAGE.get()
    if credentials is None or credentials.invalid:
        credentials = run_flow(flow, STORAGE, http=http)

    http = credentials.authorize(http)
    return build("gmail", "v1", http=http)


def main(argv=None):
    """Entry point for the ``capture`` command."""

    if argv is None:
        argv = sys.argv[1:]

    if len(argv) < 2:
        print("Usage: capture <target> <message>")
        return 1

    target = argv[0]
    msg = " ".join(argv[1:])

    script_dir = os.path.dirname(os.path.realpath(__file__))
    target_path = os.path.join(script_dir, "targets.json")
    with open(target_path, "r", encoding="utf-8") as target_file:
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
