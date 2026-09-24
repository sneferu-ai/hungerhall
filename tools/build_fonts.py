#!/usr/bin/env python3
"""Build the HUNGERHALL original pixel fonts (SIL OFL 1.1, original glyphs).

G4 pins Silkscreen at res://Fonts/silkscreen_regular.ttf + silkscreen_bold.ttf.
No network access exists in this build sandbox, so we author an original
5x7 monospace pixel font (family name "HungerhallPixel", honest provenance)
and ship it at the pinned paths. The operator can drop the real Silkscreen
(SIL OFL 1.1) over these files later with zero code changes.

Output is a minimal but complete TrueType font: head/hhea/maxp/hmtx/cmap/
glyf/loca/name/post/OS-2. Every glyph is composed of axis-aligned pixel
rectangles on a 5x7 grid (pixel = 96 font units, em = 1024).
"""
import struct
import hashlib
from pathlib import Path

P = 96          # one font "pixel" in font units
EM = 1024
ASCENT = 768    # 8 px above baseline
DESCENT = -256
ADV = 576       # 6 px advance (5 glyph + 1 gap)
BODY_BOTTOM = 128  # baseline sits one pixel below the glyph body

# Classic 5x7 ASCII bitmaps (bit4 = leftmost column), rows top-to-bottom.
GLYPHS = {
    " ": [0, 0, 0, 0, 0, 0, 0],
    "!": [4, 4, 4, 4, 4, 0, 4],
    '"': [10, 10, 0, 0, 0, 0, 0],
    "#": [10, 31, 10, 10, 31, 10, 10],
    "$": [4, 15, 20, 14, 5, 30, 4],
    "%": [24, 25, 2, 4, 8, 19, 3],
    "&": [8, 20, 20, 8, 21, 18, 13],
    "'": [4, 4, 8, 0, 0, 0, 0],
    "(": [2, 4, 8, 8, 8, 4, 2],
    ")": [8, 4, 2, 2, 2, 4, 8],
    "*": [0, 10, 4, 31, 4, 10, 0],
    "+": [0, 4, 4, 31, 4, 4, 0],
    ",": [0, 0, 0, 0, 0, 4, 8],
    "-": [0, 0, 0, 31, 0, 0, 0],
    ".": [0, 0, 0, 0, 0, 0, 4],
    "/": [1, 1, 2, 4, 8, 16, 16],
    "0": [14, 17, 19, 21, 25, 17, 14],
    "1": [4, 12, 4, 4, 4, 4, 14],
    "2": [14, 17, 1, 6, 8, 16, 31],
    "3": [14, 17, 1, 6, 1, 17, 14],
    "4": [2, 6, 10, 18, 31, 2, 2],
    "5": [31, 16, 30, 1, 1, 17, 14],
    "6": [6, 8, 16, 30, 17, 17, 14],
    "7": [31, 1, 2, 4, 8, 8, 8],
    "8": [14, 17, 17, 14, 17, 17, 14],
    "9": [14, 17, 17, 15, 1, 2, 12],
    ":": [0, 0, 4, 0, 0, 4, 0],
    ";": [0, 0, 4, 0, 0, 4, 8],
    "<": [2, 4, 8, 16, 8, 4, 2],
    "=": [0, 0, 31, 0, 31, 0, 0],
    ">": [8, 4, 2, 1, 2, 4, 8],
    "?": [14, 17, 1, 2, 4, 0, 4],
    "@": [14, 17, 23, 21, 23, 16, 14],
    "A": [14, 17, 17, 31, 17, 17, 17],
    "B": [30, 17, 17, 30, 17, 17, 30],
    "C": [14, 17, 16, 16, 16, 17, 14],
    "D": [30, 17, 17, 17, 17, 17, 30],
    "E": [31, 16, 16, 30, 16, 16, 31],
    "F": [31, 16, 16, 30, 16, 16, 16],
    "G": [14, 17, 16, 23, 17, 17, 15],
    "H": [17, 17, 17, 31, 17, 17, 17],
    "I": [14, 4, 4, 4, 4, 4, 14],
    "J": [7, 2, 2, 2, 2, 18, 12],
    "K": [17, 18, 20, 24, 20, 18, 17],
    "L": [16, 16, 16, 16, 16, 16, 31],
    "M": [17, 27, 21, 21, 17, 17, 17],
    "N": [17, 25, 21, 19, 17, 17, 17],
    "O": [14, 17, 17, 17, 17, 17, 14],
    "P": [30, 17, 17, 30, 16, 16, 16],
    "Q": [14, 17, 17, 17, 21, 18, 13],
    "R": [30, 17, 17, 30, 20, 18, 17],
    "S": [15, 16, 16, 14, 1, 1, 30],
    "T": [31, 4, 4, 4, 4, 4, 4],
    "U": [17, 17, 17, 17, 17, 17, 14],
    "V": [17, 17, 17, 17, 17, 10, 4],
    "W": [17, 17, 17, 21, 21, 27, 17],
    "X": [17, 17, 10, 4, 10, 17, 17],
    "Y": [17, 17, 10, 4, 4, 4, 4],
    "Z": [31, 1, 2, 4, 8, 16, 31],
    "[": [14, 8, 8, 8, 8, 8, 14],
    "\\": [16, 16, 8, 4, 2, 1, 1],
    "]": [14, 2, 2, 2, 2, 2, 14],
    "^": [4, 10, 17, 0, 0, 0, 0],
    "_": [0, 0, 0, 0, 0, 0, 31],
    "`": [8, 8, 4, 0, 0, 0, 0],
    "a": [0, 0, 14, 1, 15, 17, 15],
    "b": [16, 16, 22, 25, 17, 17, 30],
    "c": [0, 0, 14, 16, 16, 17, 14],
    "d": [1, 1, 13, 19, 17, 17, 15],
    "e": [0, 0, 14, 17, 31, 16, 14],
    "f": [6, 9, 8, 28, 8, 8, 8],
    "g": [0, 15, 17, 17, 15, 1, 14],
    "h": [16, 16, 22, 25, 17, 17, 17],
    "i": [4, 0, 12, 4, 4, 4, 14],
    "j": [2, 0, 6, 2, 2, 18, 12],
    "k": [16, 16, 18, 20, 24, 20, 18],
    "l": [12, 4, 4, 4, 4, 4, 14],
    "m": [0, 0, 26, 21, 21, 17, 17],
    "n": [0, 0, 22, 25, 17, 17, 17],
    "o": [0, 0, 14, 17, 17, 17, 14],
    "p": [0, 30, 17, 17, 30, 16, 16],
    "q": [0, 13, 19, 17, 15, 1, 1],
    "r": [0, 22, 25, 16, 16, 16, 16],
    "s": [0, 15, 16, 14, 1, 1, 30],
    "t": [8, 8, 28, 8, 8, 9, 6],
    "u": [0, 0, 17, 17, 17, 19, 13],
    "v": [0, 0, 17, 17, 17, 10, 4],
    "w": [0, 0, 17, 17, 21, 21, 10],
    "x": [0, 0, 17, 10, 4, 10, 17],
    "y": [0, 17, 17, 17, 15, 1, 14],
    "z": [0, 0, 31, 2, 4, 8, 31],
    "{": [2, 4, 4, 8, 4, 4, 2],
    "|": [4, 4, 4, 4, 4, 4, 4],
    "}": [8, 4, 4, 2, 4, 4, 8],
    "~": [0, 0, 8, 21, 2, 0, 0],
}

CHARS = [chr(c) for c in range(32, 127)]


def glyph_contours(rows, bold=False):
    """Return a list of contours; each contour = [(x, y), ...] clockwise (y up)."""
    contours = []
    for r, row in enumerate(rows):
        bits = row
        if bold:
            bits = bits | (bits >> 1)  # thicken each stroke one sub-pixel right
        for c in range(5):
            if bits & (1 << (4 - c)):
                x0 = c * P
                y1 = BODY_BOTTOM + (7 - r) * P
                y0 = y1 - P
                contours.append([(x0, y0), (x0, y1), (x0 + P, y1), (x0 + P, y0)])
    return contours


def build_glyph(rows, bold=False):
    contours = glyph_contours(rows, bold)
    if not contours:  # space
        return struct.pack(">hhhhh", 0, 0, 0, 0, 0)
    all_pts = [pt for c in contours for pt in c]
    xs = [p[0] for p in all_pts]
    ys = [p[1] for p in all_pts]
    bbox = (min(xs), min(ys), max(xs), max(ys))
    n_contours = len(contours)
    end_pts = []
    idx = -1
    for c in contours:
        idx += len(c)
        end_pts.append(idx)
    out = struct.pack(">hhhhh", n_contours, *bbox)
    out += struct.pack(">%dH" % n_contours, *end_pts)
    out += struct.pack(">H", 0)  # instructionLength
    flags = []
    xcoords = []
    ycoords = []
    px, py = 0, 0
    for c in contours:
        for (x, y) in c:
            dx, dy = x - px, y - py
            f = 0x01  # on-curve
            if abs(dx) <= 255:
                f |= 0x02  # x-short
                if dx >= 0:
                    f |= 0x10  # positive
                xcoords.append(abs(dx))
            else:
                xcoords.append(dx)
            if abs(dy) <= 255:
                f |= 0x04  # y-short
                if dy >= 0:
                    f |= 0x20
                ycoords.append(abs(dy))
            else:
                ycoords.append(dy)
            flags.append(f)
            px, py = x, y
    out += struct.pack(">%dB" % len(flags), *flags)
    for i, f in enumerate(flags):
        if f & 0x02:
            out += struct.pack(">B", xcoords[i])
        else:
            out += struct.pack(">h", xcoords[i])
    for i, f in enumerate(flags):
        if f & 0x04:
            out += struct.pack(">B", ycoords[i])
        else:
            out += struct.pack(">h", ycoords[i])
    if len(out) % 2:
        out += b"\x00"
    return out


def checksum(data):
    while len(data) % 4:
        data += b"\x00"
    return sum(struct.unpack(">%dI" % (len(data) // 4), data)) & 0xFFFFFFFF


def pad4(b):
    return b + b"\x00" * ((4 - len(b) % 4) % 4)


def build_font(family, subfamily, bold):
    name_records = {
        0: "Copyright 2026 Sneferu Pipeline. Original glyph artwork. Released under the SIL Open Font License 1.1.",
        1: family,
        2: subfamily,
        3: f"{family}-{subfamily}-2026-pipeline",
        4: f"{family} {subfamily}",
        5: "Version 1.000",
        6: f"{family}-{subfamily}",
        13: "This Font Software is licensed under the SIL Open Font License, Version 1.1.",
        14: "https://openfontlicense.org",
    }
    glyphs = []
    # glyph 0: .notdef — hollow box
    notdef_rows = [31, 17, 17, 17, 17, 17, 31]
    contours = glyph_contours(notdef_rows)
    # make it a ring: outer box + inner box reversed — simplest: draw the box rows as pixels (filled), acceptable.
    glyphs.append(build_glyph(notdef_rows))
    for ch in CHARS:
        glyphs.append(build_glyph(GLYPHS[ch], bold))
    n_glyphs = len(glyphs)

    glyf = b"".join(glyphs)
    # loca (short format: offset/2)
    offsets = []
    off = 0
    for g in glyphs:
        offsets.append(off // 2)
        off += len(g)
    offsets.append(off // 2)
    loca = struct.pack(">%dH" % (n_glyphs + 1), *offsets)

    hmtx = b""
    for i in range(n_glyphs):
        if i == 0:
            hmtx += struct.pack(">Hh", ADV, P // 2)
        else:
            hmtx += struct.pack(">Hh", ADV, 0)

    # cmap format 4: one segment 32..126 → gid 1..95, plus 0xffff
    seg_start, seg_end = 32, 126
    seg_count = 2
    delta = (1 - seg_start) & 0xFFFF
    body = struct.pack(">HH", seg_end, 0xFFFF)  # endCode
    body += struct.pack(">H", 0)  # reservedPad
    body += struct.pack(">HH", seg_start, 0xFFFF)  # startCode
    body += struct.pack(">HH", delta, 1)  # idDelta
    body += struct.pack(">HH", 0, 0)  # idRangeOffset
    # header: format, length, language, segCountX2, searchRange, entrySelector, rangeShift
    head4 = struct.pack(">HHHHHHH", 4, 14 + len(body), 0, seg_count * 2, 4, 1, 0)
    cmap4 = head4 + body
    cmap = struct.pack(">HH", 0, 1) + struct.pack(">HHI", 3, 1, 12) + cmap4

    # name table (platform 3, encoding 1, lang 0x409), UTF-16BE
    recs = []
    string_data = b""
    for nid in sorted(name_records):
        s = name_records[nid].encode("utf-16-be")
        recs.append(struct.pack(">HHHHHH", 3, 1, 0x409, nid, len(s), len(string_data)))
        string_data += s
    name = struct.pack(">HHH", 0, len(recs), 6 + 12 * len(recs)) + b"".join(recs) + string_data

    xs_all, ys_all = [], []
    for g_rows in [notdef_rows] + [GLYPHS[c] for c in CHARS]:
        for cts in glyph_contours(g_rows, bold):
            for (x, y) in cts:
                xs_all.append(x)
                ys_all.append(y)
    gx_min, gx_max = min(xs_all), max(xs_all)
    gy_min, gy_max = min(ys_all), max(ys_all)

    max_points = max(len(c) for g_rows in [notdef_rows] + [GLYPHS[c] for c in CHARS] for c in glyph_contours(g_rows, bold))
    max_contours = max(len(glyph_contours(g_rows, bold)) for g_rows in [notdef_rows] + [GLYPHS[c] for c in CHARS])

    head = (
        struct.pack(">IIIIHHQQ", 0x00010000, 0x00010000, 0, 0x5F0F3CF5, 0x000B, EM, 0, 0)
        + struct.pack(">hhhhHHH", gx_min, gy_min, gx_max, gy_max, 1 if bold else 0, 8, 2)
        + struct.pack(">hh", 0, 0)  # fontDirectionHint=2, indexToLocFormat=0 (short), glyphDataFormat=0
    )

    hhea = struct.pack(
        ">IhhhHhhhhhhhhhhhH",
        0x00010000, ASCENT, DESCENT, 0, ADV,
        0, 0, gx_max, 1, 0, 0, 0, 0, 0, 0, 0, n_glyphs,
    )

    maxp = struct.pack(
        ">IHHHHHHHHHHHHHH",
        0x00010000, n_glyphs, max_points, max_contours, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0,
    )

    post = struct.pack(">IIhhIIIII", 0x00030000, 0, -128, 64, 1, 0, 0, 0, 0)

    os2 = struct.pack(
        ">HhHHHhhhhhhhhhhh",
        4, ADV, 400 if not bold else 700, 5, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    )
    os2 += b"\x00" * 10  # panose
    os2 += struct.pack(">IIII", 0x00000001, 0, 0, 0)  # unicode ranges: basic latin only
    os2 += b"SNFR"
    os2 += struct.pack(">HHH", 0x40 if not bold else 0x20, 32, 126)
    os2 += struct.pack(">hhHHH", ASCENT, DESCENT, 0, ASCENT, -DESCENT)
    os2 += struct.pack(">II", 1, 0)  # codepage: latin1
    os2 += struct.pack(">hhHHH", 672, 672, 0, 32, 1)

    tables = {
        "OS/2": os2,
        "cmap": cmap,
        "glyf": glyf,
        "head": head,
        "hhea": hhea,
        "hmtx": hmtx,
        "loca": loca,
        "maxp": maxp,
        "name": name,
        "post": post,
    }
    tags = sorted(tables)
    n = len(tags)
    import math
    sr = (2 ** int(math.log2(n))) * 16
    header = struct.pack(">IHHHH", 0x00010000, n, sr, int(math.log2(sr // 16)), n * 16 - sr)
    offset = 12 + 16 * n
    records = b""
    blob = b""
    checksums = {}
    for t in tags:
        data = pad4(tables[t])
        checksums[t] = checksum(data)
        records += t.encode("ascii") + struct.pack(">III", checksums[t], offset, len(tables[t]))
        blob += data
        offset += len(data)
    font = header + records + blob
    # checkSumAdjustment
    total = checksum(font)
    adj = (0xB1B0AFBA - total) & 0xFFFFFFFF
    head_off = 12 + 16 * tags.index("head") + 12  # offset field in record → data start
    # find head data offset from records
    rec = records[tags.index("head") * 16:(tags.index("head") + 1) * 16]
    data_off = struct.unpack(">III", rec[4:])[1]
    font = bytearray(font)
    font[data_off + 8:data_off + 12] = struct.pack(">I", adj)
    return bytes(font)


def main():
    out = Path(__file__).resolve().parent.parent / "Fonts"
    out.mkdir(exist_ok=True)
    reg = build_font("HungerhallPixel", "Regular", False)
    bold = build_font("HungerhallPixel", "Bold", True)
    (out / "silkscreen_regular.ttf").write_bytes(reg)
    (out / "silkscreen_bold.ttf").write_bytes(bold)
    for f in ("silkscreen_regular.ttf", "silkscreen_bold.ttf"):
        print(f, hashlib.sha256((out / f).read_bytes()).hexdigest()[:16], (out / f).stat().st_size, "bytes")


if __name__ == "__main__":
    main()
