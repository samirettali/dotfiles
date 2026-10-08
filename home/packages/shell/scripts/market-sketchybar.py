#!/usr/bin/env python3
"""Push live crypto and stock prices into sketchybar items.

Two WebSockets, no keys: Binance's `@ticker` streams for the crypto pairs, one
update a second each, and Yahoo Finance's streamer for the stocks, which also
carries pre-market and after-hours prices. Yahoo sends a symbol only when it
trades, so after a closed market or a sleep the stocks would be empty or old:
every Yahoo connection reads each one from the chart endpoint until the stream
sends it.

Prices go to a JSON file, which the items read on `market_update`. The trigger
fires at most once a second, and only when something on screen changed.
"""

from __future__ import annotations

import asyncio
import base64
import http.client
import json
import os
import struct
import subprocess
import sys
import time
import urllib.parse
import urllib.request

import websockets

BINANCE_URL = "wss://stream.binance.com:9443/stream?streams={streams}"
YAHOO_URL = "wss://streamer.finance.yahoo.com/?version=2"
YAHOO_CHART_URL = "https://query1.finance.yahoo.com/v8/finance/chart/{symbol}?interval=1d&range=1d"
# The chart endpoint answers 429 to a request without a browser User-Agent.
YAHOO_USER_AGENT = "Mozilla/5.0"

STATE_PATH = os.path.expanduser("~/.cache/sketchybar/market.json")

# Stocks go quiet when their market closes, so silence on the Yahoo socket
# cannot tell a dead connection from a weekend. Bitcoin trades around the clock
# and Yahoo sends it every few seconds: it is subscribed only as a heartbeat.
YAHOO_CANARY = "BTC-USD"
# yfinance re-sends the subscription every 15 seconds to keep the stream alive.
YAHOO_RESUBSCRIBE_SECONDS = 15

# Wall-clock seconds of silence after which a source counts as down. The wall
# clock keeps running through sleep, unlike asyncio's monotonic one, so prices
# grey out as soon as the Mac wakes rather than a timeout later.
STALE_AFTER_SECONDS = {"binance": 15, "yahoo": 30}
RECV_POLL_SECONDS = 5
RECONNECT_DELAY_SECONDS = 5
# The chart endpoint rate-limits with 429; a failed symbol waits this long.
SEED_RETRY_SECONDS = 60
PUBLISH_INTERVAL_SECONDS = 1

# PricingData's `market_hours`. Crypto arrives as 1, after-hours stocks as 2.
# Proto3 omits a zero, so a message without the field is pre-market.
SESSIONS = {0: "pre", 2: "post", 3: "night"}


def log(message: str) -> None:
    print(message, file=sys.stderr, flush=True)


class Prices:
    def __init__(self, markets: list[dict]) -> None:
        self.markets = markets
        self.quotes: dict[str, dict] = {}
        self.heard: dict[str, float] = {}

    def symbols(self, source: str) -> list[str]:
        return [market["symbol"] for market in self.markets if market["source"] == source]

    def alive(self, source: str) -> None:
        self.heard[source] = time.time()

    def set(self, symbol: str, price: float, change: float | None, session: str | None) -> None:
        self.quotes[symbol] = {"price": price, "change": change, "session": session}

    def stale(self, source: str) -> bool:
        return time.time() - self.heard.get(source, 0) > STALE_AFTER_SECONDS[source]

    def document(self) -> dict:
        quotes = {}
        for market in self.markets:
            quote = self.quotes.get(market["symbol"])
            if quote is None:
                continue
            change = quote["change"]
            quotes[market["symbol"]] = {
                "price": format_price(quote["price"]),
                "change": "" if change is None else f"{change:+.2f}%",
                "direction": direction(change),
                "session": quote["session"] or "",
                "stale": self.stale(market["source"]),
            }
        return {"quotes": quotes}


def format_price(price: float) -> str:
    if price >= 1000:
        return f"{price:,.0f}"
    if price >= 1:
        return f"{price:,.2f}"
    return f"{price:.4g}"


def direction(change: float | None) -> str:
    # Judged on the rounded figure, so +0.00% is not painted green.
    if change is None or round(change, 2) == 0:
        return "flat"
    return "up" if change > 0 else "down"


async def receive(ws: websockets.ClientConnection, prices: Prices, source: str) -> str | bytes:
    """Wait for the next message, giving up once the source has been silent too long."""
    while True:
        try:
            return await asyncio.wait_for(ws.recv(), RECV_POLL_SECONDS)
        except TimeoutError:
            if prices.stale(source):
                raise TimeoutError(f"{source} silent for {STALE_AFTER_SECONDS[source]}s") from None


async def watch_binance(prices: Prices) -> None:
    wanted = set(prices.symbols("binance"))
    streams = "/".join(f"{symbol.lower()}@ticker" for symbol in sorted(wanted))
    # Binance closes every connection after 24 hours; the caller reconnects.
    async with websockets.connect(BINANCE_URL.format(streams=streams), open_timeout=30) as ws:
        prices.alive("binance")
        while True:
            message = json.loads(await receive(ws, prices, "binance"))
            data = message.get("data") if isinstance(message, dict) else None
            if not isinstance(data, dict) or data.get("s") not in wanted:
                continue
            prices.alive("binance")
            # `P` is the change over the rolling 24 hours, crypto's only "day".
            prices.set(data["s"], float(data["c"]), float(data["P"]), None)


def read_varint(data: bytes, index: int) -> tuple[int, int]:
    result = shift = 0
    while True:
        byte = data[index]
        index += 1
        result |= (byte & 0x7F) << shift
        shift += 7
        if byte < 0x80:
            return result, index


def decode_pricing(data: bytes) -> dict[int, object]:
    """Decode the PricingData fields this needs; yfinance's pricing.proto names them."""
    fields: dict[int, object] = {}
    index = 0
    while index < len(data):
        key, index = read_varint(data, index)
        number, wire = key >> 3, key & 7
        if wire == 0:
            fields[number], index = read_varint(data, index)
        elif wire == 1:
            index += 8
        elif wire == 2:
            length, index = read_varint(data, index)
            fields[number] = data[index : index + length]
            index += length
        elif wire == 5:
            (fields[number],) = struct.unpack("<f", data[index : index + 4])
            index += 4
        else:
            raise ValueError(f"unsupported protobuf wire type {wire}")
    return fields


def apply_pricing(prices: Prices, fields: dict[int, object], wanted: set[str]) -> str | None:
    """Store a followed stock's price and return its symbol, or return None."""
    raw = fields.get(1)
    symbol = raw.decode() if isinstance(raw, bytes) else None
    if symbol not in wanted or not isinstance(fields.get(2), float):
        return None
    # Outside regular hours 8 measures from the regular close and 47 from the
    # previous one; 47 is missing during regular hours, when the two agree.
    # Using 47 when present keeps the figure on the same base all day. It is
    # not in yfinance's proto: it was read off live messages.
    change = fields.get(47, fields.get(8))
    session = SESSIONS.get(int(fields.get(7, 0)))
    prices.set(symbol, float(fields[2]), None if change is None else float(change), session)
    return symbol


def trading_session(periods: dict, now: float) -> str | None:
    for session in ("pre", "post"):
        period = periods.get(session) or {}
        if period.get("start", 0) <= now < period.get("end", 0):
            return session
    return None


def fetch_chart(symbol: str) -> tuple[float, float | None, str | None]:
    url = YAHOO_CHART_URL.format(symbol=urllib.parse.quote(symbol, safe=""))
    request = urllib.request.Request(url, headers={"User-Agent": YAHOO_USER_AGENT})
    with urllib.request.urlopen(request, timeout=15) as response:
        meta = json.load(response)["chart"]["result"][0]["meta"]
    session = trading_session(meta.get("currentTradingPeriod") or {}, time.time())
    # `fulldayPrice` includes extended hours and its change is measured from the
    # previous close, the same figures the stream carries in 2 and 47.
    if "fulldayPrice" in meta:
        change = meta.get("fulldayChangePercent")
        return float(meta["fulldayPrice"]), None if change is None else float(change), session
    price = float(meta["regularMarketPrice"])
    previous = meta.get("chartPreviousClose")
    return price, (price - previous) / previous * 100 if previous else None, session


async def seed_yahoo(prices: Prices, streamed: set[str]) -> None:
    """Read every stock the stream has not sent on this connection.

    A price from before the connection may be hours old, from before a sleep or
    a weekend, so it is replaced rather than trusted.
    """
    pending = set(prices.symbols("yahoo"))
    while True:
        for symbol in sorted(pending - streamed):
            try:
                price, change, session = await asyncio.to_thread(fetch_chart, symbol)
            except (OSError, ValueError, KeyError, IndexError, TypeError, http.client.HTTPException) as err:
                log(f"yahoo chart {symbol}: {err!r}")
                continue
            # The stream may have sent it while the request was in flight.
            if symbol not in streamed:
                prices.set(symbol, price, change, session)
            pending.discard(symbol)
        pending -= streamed
        if not pending:
            return
        await asyncio.sleep(SEED_RETRY_SECONDS)


async def resubscribe(ws: websockets.ClientConnection, subscription: str) -> None:
    while True:
        await asyncio.sleep(YAHOO_RESUBSCRIBE_SECONDS)
        try:
            await ws.send(subscription)
        except websockets.ConnectionClosed:
            # The reader sees the same close and reconnects.
            return


async def watch_yahoo(prices: Prices) -> None:
    wanted = set(prices.symbols("yahoo"))
    subscription = json.dumps({"subscribe": sorted(wanted | {YAHOO_CANARY})})
    streamed: set[str] = set()
    seed = asyncio.create_task(seed_yahoo(prices, streamed))
    try:
        async with websockets.connect(YAHOO_URL, open_timeout=30) as ws:
            await ws.send(subscription)
            prices.alive("yahoo")
            heartbeat = asyncio.create_task(resubscribe(ws, subscription))
            try:
                while True:
                    message = json.loads(await receive(ws, prices, "yahoo"))
                    if not isinstance(message, dict) or message.get("type") != "pricing":
                        continue
                    prices.alive("yahoo")
                    fields = decode_pricing(base64.b64decode(message["message"]))
                    symbol = apply_pricing(prices, fields, wanted)
                    if symbol:
                        streamed.add(symbol)
            finally:
                heartbeat.cancel()
    finally:
        seed.cancel()


async def keep_watching(name: str, watch, prices: Prices) -> None:
    while True:
        try:
            await watch(prices)
            log(f"{name} closed")
        except (
            OSError,
            ValueError,
            KeyError,
            TypeError,
            IndexError,
            AttributeError,
            UnicodeDecodeError,
            struct.error,
            TimeoutError,
            websockets.WebSocketException,
        ) as err:
            log(f"{name} unavailable: {err!r}")
        await asyncio.sleep(RECONNECT_DELAY_SECONDS)


def write_state(document: dict) -> None:
    os.makedirs(os.path.dirname(STATE_PATH), exist_ok=True)
    temporary = f"{STATE_PATH}.tmp"
    with open(temporary, "w") as handle:
        json.dump(document, handle)
    # Atomic, so the item never reads half a file.
    os.replace(temporary, STATE_PATH)


def trigger() -> None:
    try:
        subprocess.run(["sketchybar", "--trigger", "market_update"], capture_output=True, timeout=10)
    except (OSError, subprocess.TimeoutExpired) as err:
        log(f"sketchybar trigger failed: {err}")


async def publish(prices: Prices) -> None:
    published = None
    while True:
        document = prices.document()
        if document != published:
            try:
                await asyncio.to_thread(write_state, document)
            except OSError as err:
                log(f"could not write {STATE_PATH}: {err}")
            else:
                await asyncio.to_thread(trigger)
                published = document
        await asyncio.sleep(PUBLISH_INTERVAL_SECONDS)


async def main() -> int:
    if len(sys.argv) != 2:
        log("usage: market-sketchybar <markets.json>")
        return 2
    with open(sys.argv[1]) as handle:
        prices = Prices(json.load(handle))
    tasks = [publish(prices)]
    if prices.symbols("binance"):
        tasks.append(keep_watching("binance", watch_binance, prices))
    if prices.symbols("yahoo"):
        tasks.append(keep_watching("yahoo", watch_yahoo, prices))
    await asyncio.gather(*tasks)
    return 0


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
