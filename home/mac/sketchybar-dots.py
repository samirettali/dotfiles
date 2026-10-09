"""Write one anti-aliased dot PNG per market status into the given directory.

Sketchybar draws one colour per label, so a popup row's status dot is the
row's background image instead. The colours are TradingView's.
"""

import os
import struct
import sys
import zlib

COLORS = {
    "pre": (0xFF, 0x91, 0x02),
    "open": (0x43, 0xBD, 0xA8),
    "post": (0x82, 0xB1, 0xFF),
    "night": (0xBA, 0x68, 0xC8),
    "closed": (0x62, 0x62, 0x62),
}
# Drawn at twice the size and shown at half scale, for Retina.
SIZE = 16
RADIUS = 6.0


def chunk(kind: bytes, data: bytes) -> bytes:
    return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))


def dot(rgb: tuple[int, int, int]) -> bytes:
    center = SIZE / 2
    rows = []
    for y in range(SIZE):
        row = bytearray([0])
        for x in range(SIZE):
            distance = ((x + 0.5 - center) ** 2 + (y + 0.5 - center) ** 2) ** 0.5
            alpha = max(0.0, min(1.0, RADIUS - distance + 0.5))
            row += bytes([*rgb, round(alpha * 255)])
        rows.append(bytes(row))
    header = struct.pack(">IIBBBBB", SIZE, SIZE, 8, 6, 0, 0, 0)
    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", header)
        + chunk(b"IDAT", zlib.compress(b"".join(rows)))
        + chunk(b"IEND", b"")
    )


def main() -> None:
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    for name, rgb in COLORS.items():
        with open(os.path.join(out, f"{name}.png"), "wb") as handle:
            handle.write(dot(rgb))


if __name__ == "__main__":
    main()
