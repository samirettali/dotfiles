#!/usr/bin/env python3
"""Push the Ethereum mainnet base fee into a sketchybar item.

An `eth_subscribe newHeads` subscription over Infura's WebSocket delivers every
block header, about one every 12 seconds, and each header carries
`baseFeePerGas`. So this holds the socket open and publishes on every block,
which also refills the item after Sketchybar restarts.

The Infura key comes from `INFURA_API_KEY`.
"""

from __future__ import annotations

import asyncio
import json
import os
import subprocess
import sys

import websockets

URL = "wss://mainnet.infura.io/ws/v3/{key}"

# A block is due every 12 seconds. A minute without one means the connection is
# dead, which is also how a sleep shows up.
READ_TIMEOUT_SECONDS = 60
RECONNECT_DELAY_SECONDS = 5
# launchd spawns an agent at most once every 10 seconds, so a key rejected
# right after the start would be retried that often.
REJECTED_EXIT_DELAY_SECONDS = 60


def log(message: str) -> None:
    print(message, file=sys.stderr, flush=True)


def format_gwei(wei: int) -> str:
    gwei = wei / 1e9
    # The format follows the rounded value, so 9.97 reads 10 rather than 10.0.
    if round(gwei, 1) >= 10:
        return f"{gwei:.0f}"
    if float(f"{gwei:.2g}") >= 1:
        return f"{gwei:.1f}"
    return f"{gwei:.2g}"


def publish(**fields: str) -> None:
    args = [f"{name}={value}" for name, value in fields.items()]
    try:
        subprocess.run(
            ["sketchybar", "--trigger", "gas_price", *args],
            capture_output=True,
            timeout=10,
        )
    except (OSError, subprocess.TimeoutExpired) as err:
        log(f"sketchybar trigger failed: {err}")


async def watch(key: str, published: dict[str, str | None]) -> None:
    """Serve one subscription. Returns or raises when it ends."""
    async with websockets.connect(URL.format(key=key), open_timeout=30) as ws:
        await ws.send(
            json.dumps(
                {"jsonrpc": "2.0", "id": 1, "method": "eth_subscribe", "params": ["newHeads"]}
            )
        )
        while True:
            message = json.loads(await asyncio.wait_for(ws.recv(), READ_TIMEOUT_SECONDS))
            if "error" in message:
                raise ValueError(message["error"])
            if message.get("method") != "eth_subscription":
                continue
            fee = message["params"]["result"].get("baseFeePerGas")
            if fee is None:
                continue
            published["last"] = format_gwei(int(fee, 16))
            publish(gwei=published["last"], stale="0")


async def main() -> int:
    key = os.environ.get("INFURA_API_KEY")
    if not key:
        log("INFURA_API_KEY is not set")
        return 1
    published: dict[str, str | None] = {"last": None}
    while True:
        rejected = False
        try:
            await watch(key, published)
            log("subscription closed")
        except websockets.InvalidStatus as err:
            status = err.response.status_code
            log(f"infura returned {status}")
            # A revoked or replaced key: exit, so the caller can start this
            # again with a new one.
            rejected = status in (401, 403)
        except (
            OSError,
            ValueError,
            KeyError,
            TypeError,
            AttributeError,
            TimeoutError,
            websockets.WebSocketException,
        ) as err:
            log(f"infura unavailable: {err!r}")
        # Grey out the last fee rather than leave it looking current.
        if published["last"] is not None:
            publish(gwei=published["last"], stale="1")
            published["last"] = None
        if rejected:
            await asyncio.sleep(REJECTED_EXIT_DELAY_SECONDS)
            return 1
        await asyncio.sleep(RECONNECT_DELAY_SECONDS)


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
