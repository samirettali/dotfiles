#!/usr/bin/env python3
"""Minimal Firefox Remote Debugging Protocol client.

Speaks the length-prefixed JSON framing ("<bytes>:<json>") to a Firefox that was
started with --start-debugger-server, attaches to the parent process target and
evaluates JS in the chrome context.
"""
import json
import socket
import sys


class RDP:
    def __init__(self, host="127.0.0.1", port=6000, timeout=20):
        self.sock = socket.create_connection((host, port), timeout=timeout)
        self.buf = b""
        self.pending = []
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
                raise RuntimeError("connessione chiusa dal server")
            self.buf += chunk

    def request(self, packet, want=None):
        """Send a packet and return the first reply that matches `want`."""
        self.send(packet)
        for _ in range(200):
            msg = self.recv()
            if want is None or want(msg):
                return msg
            self.pending.append(msg)
        raise RuntimeError("nessuna risposta corrispondente")

    def parent_console(self):
        proc = self.request(
            {"to": "root", "type": "getProcess", "id": 0},
            lambda m: "processDescriptor" in m or "error" in m,
        )
        if "error" in proc:
            raise RuntimeError(f"getProcess: {proc}")
        actor = proc["processDescriptor"]["actor"]
        target = self.request(
            {"to": actor, "type": "getTarget"},
            lambda m: "process" in m or "error" in m,
        )
        if "error" in target:
            raise RuntimeError(f"getTarget: {target}")
        return target["process"]["consoleActor"]

    def eval(self, console, text):
        res = self.request(
            {"to": console, "type": "evaluateJSAsync", "text": text},
            lambda m: m.get("type") == "evaluationResult" or "result" in m or "error" in m,
        )
        return res


if __name__ == "__main__":
    code = sys.stdin.read()
    c = RDP()
    console = c.parent_console()
    out = c.eval(console, code)
    if "exception" in out and out["exception"]:
        print("ECCEZIONE:", json.dumps(out.get("exceptionMessage") or out["exception"])[:500])
    r = out.get("result")
    if isinstance(r, dict) and r.get("type") == "undefined":
        r = None
    print(out.get("helperResult") or r if r is not None else "(undefined)")
