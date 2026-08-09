#!/usr/bin/env python3
"""Minimal Firefox Remote Debugging Protocol client.

Speaks the length-prefixed JSON framing ("<bytes>:<json>") to a Firefox started
with --start-debugger-server, and evaluates JS either in the browser chrome or
inside a page.

  echo 'document.title' | rdp.py                 # chrome (the browser UI)
  echo 'document.title' | rdp.py --tab github    # first live tab matching

As a library:

  from rdp import RDP
  c = RDP()
  c.eval(c.parent_console(), "...")              # chrome
  c.eval(c.tab_console("example.com"), "...")    # page
"""
import json
import socket
import sys


class RDP:
    def __init__(self, host="127.0.0.1", port=6000, timeout=20):
        self.sock = socket.create_connection((host, port), timeout=timeout)
        self.buf = b""
        self.hello = self.recv()

    def send(self, packet):
        raw = json.dumps(packet).encode()
        self.sock.sendall(str(len(raw)).encode() + b":" + raw)

    def recv(self):
        while True:
            if b":" in self.buf:
                head, rest = self.buf.split(b":", 1)
                if head.isdigit():
                    n = int(head)
                    if len(rest) >= n:
                        self.buf = rest[n:]
                        return json.loads(rest[:n])
            chunk = self.sock.recv(65536)
            if not chunk:
                raise RuntimeError("connection closed by the server")
            self.buf += chunk

    def request(self, packet, want=None):
        """Send a packet, return the first reply matching `want`."""
        self.send(packet)
        for _ in range(200):
            msg = self.recv()
            if want is None or want(msg):
                return msg
        raise RuntimeError("no matching reply")

    # -- targets ---------------------------------------------------------

    def parent_console(self):
        """Console actor for the parent process: the browser's own UI."""
        proc = self.request(
            {"to": "root", "type": "getProcess", "id": 0},
            lambda m: "processDescriptor" in m or "error" in m,
        )
        if "error" in proc:
            raise RuntimeError(f"getProcess: {proc}")
        target = self.request(
            {"to": proc["processDescriptor"]["actor"], "type": "getTarget"},
            lambda m: "process" in m or "error" in m,
        )
        if "error" in target:
            raise RuntimeError(f"getTarget: {target}")
        return target["process"]["consoleActor"]

    def tabs(self):
        return self.request(
            {"to": "root", "type": "listTabs"}, lambda m: "tabs" in m
        )["tabs"]

    def tab_console(self, match=None):
        """Console actor for a page. `match` is a substring of url or title.

        Skips tabs Firefox has unloaded (`isZombieTab`); those cannot be
        attached until something loads them again.
        """
        for tab in self.tabs():
            hay = (tab.get("url") or "") + " " + (tab.get("title") or "")
            if match and match.lower() not in hay.lower():
                continue
            if tab.get("isZombieTab"):
                continue
            reply = self.request(
                {"to": tab["actor"], "type": "getTarget"},
                lambda m: "frame" in m or "error" in m,
            )
            if "frame" in reply:
                return reply["frame"]["consoleActor"]
        raise RuntimeError(f"no live tab matching {match!r}")

    # -- evaluation ------------------------------------------------------

    def eval(self, console, text):
        return self.request(
            {"to": console, "type": "evaluateJSAsync", "text": text},
            lambda m: m.get("type") == "evaluationResult" or "error" in m,
        )


def main():
    args = sys.argv[1:]
    match = None
    if args and args[0] == "--tab":
        match = args[1] if len(args) > 1 else ""
    code = sys.stdin.read()
    c = RDP()
    console = c.tab_console(match) if match is not None else c.parent_console()
    out = c.eval(console, code)
    if out.get("exception"):
        print("EXCEPTION:", json.dumps(out.get("exceptionMessage") or out["exception"])[:500])
    result = out.get("result")
    if isinstance(result, dict) and result.get("type") == "undefined":
        result = None
    print(result if result is not None else "(undefined)")


if __name__ == "__main__":
    main()
