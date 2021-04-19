#!/usr/local/bin/python

import os
import sys
import time
import json
import base64
import httplib2

from email.mime.text import MIMEText

from apiclient.discovery import build
from oauth2client.client import flow_from_clientsecrets
from oauth2client.file import Storage
from oauth2client.tools import run_flow

# Path to the client_secret.json file downloaded from the Developer Console
CLIENT_SECRET_FILE = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'client_secret.json')

# Check https://developers.google.com/gmail/api/auth/scopes for all available scopes
OAUTH_SCOPE = 'https://www.googleapis.com/auth/gmail.compose'

# Location of the credentials storage file
STORAGE = Storage(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'gmail.storage'))

# Start the OAuth flow to retrieve credentials
flow = flow_from_clientsecrets(CLIENT_SECRET_FILE, scope=OAUTH_SCOPE)
http = httplib2.Http()

# Try to retrieve credentials from storage or run the flow to generate them
credentials = STORAGE.get()
if credentials is None or credentials.invalid:
	credentials = run_flow(flow, STORAGE, http=http)

# Authorize the httplib2.Http object with our credentials
http = credentials.authorize(http)

# Build the Gmail service from discovery
gmail_service = build('gmail', 'v1', http=http)

# Retrieve message, sender and receiver from args
script_dir = os.path.dirname(os.path.realpath(__file__))
target_path = os.path.join(script_dir, 'targets.json')
target_file = open(target_path, "rb")
try: target_data = target_file.read()
finally: target_file.close()
target = sys.argv[1]
targets_map = json.loads(target_data)
target_map = targets_map[target]
from_email = target_map["from"]
to_email = target_map["to"]
msg = " ".join(sys.argv[2:])

# create a message to send
message = MIMEText(msg)
message['to'] = to_email
message['from'] = from_email
message['subject'] = msg
message_string = message.as_string()
message_bytes = message_string.encode("utf-8")
message_b64_bytes = base64.b64encode(message_bytes)
message_b64 = message_b64_bytes.decode("utf-8")
body = {'raw': message_b64}

# send it
try:
  message = (gmail_service.users().messages().send(userId="me", body=body).execute())
  print('Message Id: %s' % message['id'])
  print(message)
except Exception as error:
  print('An error occurred: %s' % error)
