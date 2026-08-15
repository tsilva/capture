import base64
import json
from email import message_from_bytes

import capture


class FakeGmailService:
    def __init__(self):
        self.sent = []

    def users(self):
        return self

    def messages(self):
        return self

    def send(self, *, userId, body):
        self.sent.append((userId, body))
        return self

    def execute(self):
        return {"id": "message-123"}


def test_main_builds_and_sends_expected_message(tmp_path, monkeypatch, capsys):
    targets_file = tmp_path / "targets.json"
    targets_file.write_text(
        json.dumps({"home": {"from": "sender@example.com", "to": "inbox@example.com"}}),
        encoding="utf-8",
    )
    service = FakeGmailService()
    monkeypatch.setattr(capture, "CLIENT_SECRET_FILE", str(tmp_path / "client_secret.json"))
    monkeypatch.setattr(capture, "TARGETS_FILE", str(targets_file))
    monkeypatch.setattr(capture, "_ensure_config_files", lambda: True)
    monkeypatch.setattr(capture, "_build_service", lambda: service)

    assert capture.main(["home", "A", "legitimate", "thought"]) is None
    assert len(service.sent) == 1
    user_id, body = service.sent[0]
    message = message_from_bytes(base64.b64decode(body["raw"]))

    assert user_id == "me"
    assert message["from"] == "sender@example.com"
    assert message["to"] == "inbox@example.com"
    assert message["subject"] == "A legitimate thought"
    assert message.get_payload() == "A legitimate thought"
    assert "Message Id: message-123" in capsys.readouterr().out


def test_main_stops_before_authentication_when_config_is_missing(monkeypatch):
    monkeypatch.setattr(capture, "_ensure_config_files", lambda: False)
    monkeypatch.setattr(
        capture,
        "_build_service",
        lambda: (_ for _ in ()).throw(AssertionError("authentication must not start")),
    )

    assert capture.main(["home", "message"]) == 1


def test_main_requires_target_and_message(monkeypatch, capsys):
    monkeypatch.setattr(capture, "_ensure_config_files", lambda: True)

    assert capture.main(["home"]) == 1
    assert "Usage: capture <target> <message>" in capsys.readouterr().out
