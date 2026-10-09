#!/usr/bin/env python3
"""Push live crypto and stock prices into sketchybar items.

Three WebSockets, no keys: Binance's `@ticker` streams for the crypto pairs, one
update a second each, Yahoo Finance's streamer for the stocks, which also
carries pre-market and after-hours prices, and TradingView's quote stream for
the session each Yahoo market is in. Yahoo sends a symbol only when it
trades, so after a closed market or a sleep the stocks would be empty or old:
every Yahoo connection reads each one from the chart endpoint until the stream
sends it.

Each side also gets one figure for the bar: the change of its total market cap.
Caps are prices times units outstanding, which come from Yahoo's quote endpoint
once a day and are cached.

Prices go to a JSON file, which the items read on `market_update`. The trigger
fires at most once a second, and only when something on screen changed.
"""

from __future__ import annotations

import asyncio
import base64
import http.client
import http.cookiejar
import json
import os
import random
import re
import string
import struct
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

import websockets

BINANCE_URL = "wss://stream.binance.com:9443/stream?streams={streams}"
YAHOO_URL = "wss://streamer.finance.yahoo.com/?version=2"
YAHOO_CHART_URL = "https://query1.finance.yahoo.com/v8/finance/chart/{symbol}?interval=1d&range=1d"
# The chart endpoint answers 429 to a request without a browser User-Agent.
YAHOO_USER_AGENT = "Mozilla/5.0"

YAHOO_COOKIE_URL = "https://fc.yahoo.com"
YAHOO_CRUMB_URL = "https://query1.finance.yahoo.com/v1/test/getcrumb"
YAHOO_QUOTE_URL = "https://query1.finance.yahoo.com/v7/finance/quote?symbols={symbols}&crumb={crumb}"

# TradingView's quote stream, as its own pages use it, without an account.
TRADINGVIEW_URL = "wss://data.tradingview.com/socket.io/websocket"
TRADINGVIEW_ORIGIN = "https://www.tradingview.com"
# TradingView's names for a session, mapped to the item's.
TRADINGVIEW_SESSIONS = {
    "market": "open",
    "pre_market": "pre",
    "post_market": "post",
    "night": "night",
    "out_of_session": "closed",
}
# A fresh snapshot of every session this often, in case a change is not pushed.
TRADINGVIEW_REFRESH_SECONDS = 300
# How long the first Yahoo reads wait for the sessions, which decide the
# overnight basis.
SESSIONS_WAIT_SECONDS = 10

STATE_PATH = os.path.expanduser("~/.cache/sketchybar/market.json")
UNITS_PATH = os.path.expanduser("~/.cache/sketchybar/market-units.json")
# Shares outstanding and coin supply move slowly; a day-old figure is fine.
UNITS_MAX_AGE_SECONDS = 24 * 3600
UNITS_RETRY_SECONDS = 3600

# Stocks go quiet when their market closes, so silence on the Yahoo socket
# cannot tell a dead connection from a weekend. Bitcoin trades around the clock
# and Yahoo sends it every few seconds: it is subscribed only as a heartbeat.
YAHOO_CANARY = "BTC-USD"
# yfinance re-sends the subscription every 15 seconds to keep the stream alive.
YAHOO_RESUBSCRIBE_SECONDS = 15

# Wall-clock seconds of silence after which a source counts as down. The wall
# clock keeps running through sleep, unlike asyncio's monotonic one, so prices
# grey out as soon as the Mac wakes rather than a timeout later.
# TradingView sends a heartbeat every 10 seconds.
STALE_AFTER_SECONDS = {"binance": 15, "yahoo": 30, "tradingview": 45}
RECV_POLL_SECONDS = 5
RECONNECT_DELAY_SECONDS = 5
# The chart endpoint rate-limits with 429; a failed symbol waits this long.
SEED_RETRY_SECONDS = 60
PUBLISH_INTERVAL_SECONDS = 1



def log(message: str) -> None:
    print(message, file=sys.stderr, flush=True)


# The groups that get a figure in the bar, crypto first. The macro group
# (indices, currencies, commodities) has no market cap and gets none.
SIDES = ("crypto", "stocks")


def yahoo_symbol(market: dict) -> str:
    """Yahoo's quote symbol, which for a Binance pair is its coin in dollars."""
    if market["source"] == "binance":
        return f"{market['name']}-USD"
    return market["symbol"]


class Prices:
    def __init__(self, markets: list[dict]) -> None:
        self.markets = markets
        self.quotes: dict[str, dict] = {}
        self.heard: dict[str, float] = {}
        # Units outstanding by Yahoo symbol: shares, or coins in circulation.
        self.units: dict[str, float] = {}
        # Sessions by TradingView symbol: open, pre, post, night or closed.
        self.sessions: dict[str, str] = {}
        self.sessions_heard = asyncio.Event()

    def symbols(self, source: str) -> list[str]:
        return [market["symbol"] for market in self.markets if market["source"] == source]

    def alive(self, source: str) -> None:
        self.heard[source] = time.time()

    def set(self, symbol: str, price: float, change: float | None) -> None:
        self.quotes[symbol] = {"price": price, "change": change}

    def status(self, market: dict) -> str:
        """The market's session; closed, shown grey, while it is unknown."""
        if market["source"] == "binance":
            return "open"
        if self.stale("tradingview"):
            return "closed"
        return self.sessions.get(market.get("tradingview", ""), "closed")

    def stale(self, source: str) -> bool:
        return time.time() - self.heard.get(source, 0) > STALE_AFTER_SECONDS[source]

    def side(self, group: str) -> dict | None:
        """The change of the side's total market cap since the previous close.

        A market without units counts only when no market on that side has
        any, and the figure falls back to a plain average.
        """
        now = before = 0.0
        changes = []
        sources = {market["source"] for market in self.markets if market["group"] == group}
        for market in self.markets:
            quote = self.quotes.get(market["symbol"])
            if market["group"] != group or quote is None or quote["change"] is None:
                continue
            changes.append(quote["change"])
            units = self.units.get(yahoo_symbol(market))
            if units:
                cap = quote["price"] * units
                now += cap
                before += cap / (1 + quote["change"] / 100)
        if not changes:
            return None
        change = (now / before - 1) * 100 if before else sum(changes) / len(changes)
        return {
            "change": f"{change:+.2f}%",
            "direction": direction(change),
            "stale": any(self.stale(source) for source in sources),
        }

    def document(self) -> dict:
        quotes = {}
        for market in self.markets:
            quote = self.quotes.get(market["symbol"])
            if quote is None:
                continue
            change = quote["change"]
            quotes[market["symbol"]] = {
                "price": format_price(quote["price"], market.get("decimals")),
                "change": "" if change is None else f"{change:+.2f}%",
                "direction": direction(change),
                "status": self.status(market),
                "stale": self.stale(market["source"]),
            }
        sides = {}
        for group in SIDES:
            side = self.side(group)
            if side is not None:
                sides[group] = side
        return {"quotes": quotes, "sides": sides, "order": self.order()}

    def order(self) -> dict[str, list[str]]:
        """Each side's symbols by market cap, largest first.

        A market without a cap keeps its place in the list, after the others.
        """

        def cap(market: dict) -> float:
            quote = self.quotes.get(market["symbol"])
            units = self.units.get(yahoo_symbol(market))
            return quote["price"] * units if quote and units else -1.0

        return {
            group: [
                market["symbol"]
                for market in sorted(
                    (market for market in self.markets if market["group"] == group), key=cap, reverse=True
                )
            ]
            for group in SIDES
        }


def format_price(price: float, decimals: int | None = None) -> str:
    return f"{price:,.{2 if decimals is None else decimals}f}"


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
            prices.set(data["s"], float(data["c"]), float(data["P"]))


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
    prices.set(symbol, float(fields[2]), None if change is None else float(change))
    return symbol


def fetch_meta(symbol: str) -> dict:
    url = YAHOO_CHART_URL.format(symbol=urllib.parse.quote(symbol, safe=""))
    request = urllib.request.Request(url, headers={"User-Agent": YAHOO_USER_AGENT})
    with urllib.request.urlopen(request, timeout=15) as response:
        return json.load(response)["chart"]["result"][0]["meta"]


def quote_from(meta: dict, night: bool) -> tuple[float, float | None]:
    # `fulldayPrice` includes extended hours and its change is measured from the
    # previous close, the same figures the stream carries in 2 and 47.
    if "fulldayPrice" in meta:
        price = float(meta["fulldayPrice"])
        if night and meta.get("regularMarketPrice"):
            # Overnight already belongs to the next day, as the stream has it.
            return price, (price / meta["regularMarketPrice"] - 1) * 100
        change = meta.get("fulldayChangePercent")
        return price, None if change is None else float(change)
    price = float(meta["regularMarketPrice"])
    previous = meta.get("chartPreviousClose")
    return price, (price - previous) / previous * 100 if previous else None


CHART_ERRORS = (OSError, ValueError, KeyError, IndexError, TypeError, http.client.HTTPException)


async def seed_yahoo(prices: Prices, streamed: set[str]) -> None:
    """Read every stock the stream has not sent on this connection.

    A price from before the connection may be hours old, from before a sleep or
    a weekend, so it is replaced rather than trusted.
    """
    markets = {market["symbol"]: market for market in prices.markets if market["source"] == "yahoo"}
    pending = set(markets)
    try:
        await asyncio.wait_for(prices.sessions_heard.wait(), SESSIONS_WAIT_SECONDS)
    except TimeoutError:
        log("tradingview sessions not in yet; reading yahoo without them")
    while True:
        for symbol in sorted(pending - streamed):
            night = prices.status(markets[symbol]) == "night"
            try:
                meta = await asyncio.to_thread(fetch_meta, symbol)
                price, change = quote_from(meta, night)
            except CHART_ERRORS as err:
                log(f"yahoo chart {symbol}: {err!r}")
                continue
            # The stream may have sent it while the request was in flight.
            if symbol not in streamed:
                prices.set(symbol, price, change)
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


def tradingview_frame(method: str, *params: object) -> str:
    body = json.dumps({"m": method, "p": list(params)})
    return f"~m~{len(body)}~m~{body}"


async def refresh_sessions(ws: websockets.ClientConnection, session: str, symbols: list[str]) -> None:
    """Re-add every symbol now and then, which makes TradingView resend it whole."""
    while True:
        await asyncio.sleep(TRADINGVIEW_REFRESH_SECONDS)
        try:
            await ws.send(tradingview_frame("quote_remove_symbols", session, *symbols))
            await ws.send(tradingview_frame("quote_add_symbols", session, *symbols))
        except websockets.ConnectionClosed:
            return


async def watch_tradingview(prices: Prices) -> None:
    symbols = sorted({market["tradingview"] for market in prices.markets if market.get("tradingview")})
    session = "qs_" + "".join(random.choices(string.ascii_lowercase, k=12))
    async with websockets.connect(
        TRADINGVIEW_URL, origin=TRADINGVIEW_ORIGIN, user_agent_header=YAHOO_USER_AGENT, open_timeout=30
    ) as ws:
        await ws.send(tradingview_frame("set_auth_token", "unauthorized_user_token"))
        await ws.send(tradingview_frame("quote_create_session", session))
        await ws.send(tradingview_frame("quote_set_fields", session, "current_session"))
        await ws.send(tradingview_frame("quote_add_symbols", session, *symbols))
        prices.alive("tradingview")
        refresh = asyncio.create_task(refresh_sessions(ws, session, symbols))
        try:
            while True:
                raw = await receive(ws, prices, "tradingview")
                # One frame can carry several messages, each behind its length.
                for body in re.split(r"~m~\d+~m~", raw if isinstance(raw, str) else raw.decode()):
                    if body.startswith("~h~"):
                        # A heartbeat, which TradingView wants echoed.
                        prices.alive("tradingview")
                        await ws.send(f"~m~{len(body)}~m~{body}")
                        continue
                    if not body.startswith("{"):
                        continue
                    message = json.loads(body)
                    if message.get("m") != "qsd":
                        continue
                    quote = message["p"][1]
                    current = quote.get("v", {}).get("current_session")
                    if quote.get("s") == "ok" and current in TRADINGVIEW_SESSIONS:
                        prices.alive("tradingview")
                        prices.sessions[quote["n"]] = TRADINGVIEW_SESSIONS[current]
                        if set(symbols) <= set(prices.sessions):
                            prices.sessions_heard.set()
        finally:
            refresh.cancel()


def fetch_units(symbols: list[str]) -> dict[str, float]:
    """Units outstanding per symbol, as market cap over price.

    `sharesOutstanding` counts one share class only (Alphabet's GOOG leaves out
    GOOGL), while `marketCap` covers the company, so the quotient does too.
    The endpoint wants the crumb that goes with Yahoo's session cookie.
    """
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
    opener.addheaders = [("User-Agent", YAHOO_USER_AGENT)]
    try:
        opener.open(YAHOO_COOKIE_URL, timeout=15).close()
    except urllib.error.HTTPError:
        # It answers 404, with the cookie set all the same.
        pass
    with opener.open(YAHOO_CRUMB_URL, timeout=15) as response:
        crumb = response.read().decode().strip()
    url = YAHOO_QUOTE_URL.format(
        symbols=urllib.parse.quote(",".join(symbols)), crumb=urllib.parse.quote(crumb)
    )
    with opener.open(url, timeout=15) as response:
        results = json.load(response)["quoteResponse"]["result"]
    units = {}
    for quote in results:
        cap, price = quote.get("marketCap"), quote.get("regularMarketPrice")
        if cap and price:
            units[quote["symbol"]] = cap / price
    return units


def read_units() -> tuple[float, dict[str, float]]:
    try:
        with open(UNITS_PATH) as handle:
            cached = json.load(handle)
        return float(cached["fetched"]), {str(k): float(v) for k, v in cached["units"].items()}
    except (OSError, ValueError, KeyError, TypeError, AttributeError):
        return 0.0, {}


def write_units(fetched: float, units: dict[str, float]) -> None:
    os.makedirs(os.path.dirname(UNITS_PATH), exist_ok=True)
    temporary = f"{UNITS_PATH}.tmp"
    with open(temporary, "w") as handle:
        json.dump({"fetched": fetched, "units": units}, handle)
    os.replace(temporary, UNITS_PATH)


async def keep_units(prices: Prices) -> None:
    """Keep the units no older than a day, across restarts through the cache."""
    wanted = sorted({yahoo_symbol(market) for market in prices.markets if market["group"] in SIDES})
    fetched, prices.units = read_units()
    while True:
        due = fetched + UNITS_MAX_AGE_SECONDS - time.time()
        if due > 0 and set(wanted) <= set(prices.units):
            await asyncio.sleep(due)
            continue
        try:
            units = await asyncio.to_thread(fetch_units, wanted)
        except (OSError, ValueError, KeyError, IndexError, TypeError, http.client.HTTPException) as err:
            log(f"yahoo units: {err!r}")
            await asyncio.sleep(UNITS_RETRY_SECONDS)
            continue
        missing = set(wanted) - set(units)
        if missing:
            log(f"yahoo units missing for {', '.join(sorted(missing))}")
        # A symbol the answer left out keeps its previous figure.
        prices.units = {**prices.units, **units}
        fetched = time.time()
        try:
            await asyncio.to_thread(write_units, fetched, prices.units)
        except OSError as err:
            log(f"could not write {UNITS_PATH}: {err}")
        if missing:
            await asyncio.sleep(UNITS_RETRY_SECONDS)
            fetched = 0.0


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
    tasks = [publish(prices), keep_units(prices)]
    if prices.symbols("binance"):
        tasks.append(keep_watching("binance", watch_binance, prices))
    if prices.symbols("yahoo"):
        tasks.append(keep_watching("yahoo", watch_yahoo, prices))
    if any(market.get("tradingview") for market in prices.markets):
        tasks.append(keep_watching("tradingview", watch_tradingview, prices))
    await asyncio.gather(*tasks)
    return 0


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
