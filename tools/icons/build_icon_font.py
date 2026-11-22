"""Bangun font ikon `MoeslimIcons` dari SVG asset kit Moeslim PM.

Sumber (tools/icons/svg/):
  ui/      120 ikon UI (glyph Font Awesome 4, satu <path> + transform), lihat ATRIBUSI_ICON.txt
  islami/  15 ikon Islami bergaris (stroke 1.7, ujung & sambungan bulat), garis diubah jadi bidang
  sholat/  5 ikon waktu salat (glyph Font Awesome 4)

Keluaran:
  packages/moeslim_brand/fonts/MoeslimIcons.ttf
  packages/moeslim_brand/lib/src/icons.dart   (kelas MoeslimIcons, IconData per ikon)

Jalankan:  python -P tools/icons/build_icon_font.py   (butuh fontTools)
"""

from __future__ import annotations

import math
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

from fontTools.fontBuilder import FontBuilder
from fontTools.pens.cu2quPen import Cu2QuPen
from fontTools.pens.recordingPen import RecordingPen
from fontTools.pens.transformPen import TransformPen
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.svgLib.path import parse_path

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "tools" / "icons" / "svg"
FONT_OUT = ROOT / "packages" / "moeslim_brand" / "fonts" / "MoeslimIcons.ttf"
DART_OUT = ROOT / "packages" / "moeslim_brand" / "lib" / "src" / "icons.dart"

UPM = 2400  # 24 px viewBox x 100
SCALE = UPM / 24
FIRST_CODEPOINT = 0xE000
NS = "{http://www.w3.org/2000/svg}"

# ---------------------------------------------------------------- glyph Font Awesome


def fa_glyph(svg: Path, pen) -> None:
    """Glyph FA: koordinat asli (y ke atas) + transform SVG → ruang font 0..2400 (y ke atas)."""
    root = ET.parse(svg).getroot()
    path = root.find(f"{NS}path")
    m = re.match(
        r"translate\(12 12\) scale\(([-\d.]+) -[\d.]+\) translate\(([-\d.]+) ([-\d.]+)\)",
        path.get("transform", ""),
    )
    if not m:
        raise ValueError(f"transform tidak dikenal: {svg}")
    s, tx, ty = float(m.group(1)), float(m.group(2)), float(m.group(3))
    k = SCALE * s
    # svg: X = 12 + s(x+tx), Y = 12 - s(y+ty)  →  font: X*100, (24-Y)*100
    t = (k, 0, 0, k, SCALE * 12 + k * tx, SCALE * 12 + k * ty)
    parse_path(path.get("d"), TransformPen(Cu2QuPen(pen, 1.0, reverse_direction=False), t))


# ---------------------------------------------------------------- garis → bidang

def _flatten(d: str) -> list[tuple[list[tuple[float, float]], bool]]:
    """Ratakan path SVG (M L H V Q C A Z) menjadi polyline (subpath, tertutup?)."""
    rec = RecordingPen()
    parse_path(d, rec)  # arc sudah diubah jadi kurva kubik oleh fontTools
    out: list[tuple[list[tuple[float, float]], bool]] = []
    pts: list[tuple[float, float]] = []
    for op, args in rec.value:
        if op == "moveTo":
            if len(pts) > 1:
                out.append((pts, False))
            pts = [args[0]]
        elif op == "lineTo":
            pts.append(args[0])
        elif op == "qCurveTo":
            p0 = pts[-1]
            # rangkaian titik kendali kuadratik implisit (TrueType); fontTools memberi 1 kendali + ujung
            ctrl = list(args[:-1])
            end = args[-1]
            segs = []
            cur = p0
            for i, c in enumerate(ctrl):
                nxt = end if i == len(ctrl) - 1 else ((c[0] + ctrl[i + 1][0]) / 2, (c[1] + ctrl[i + 1][1]) / 2)
                segs.append((cur, c, nxt))
                cur = nxt
            for a, c, b in segs:
                for i in range(1, 17):
                    t = i / 16
                    u = 1 - t
                    pts.append((u * u * a[0] + 2 * u * t * c[0] + t * t * b[0], u * u * a[1] + 2 * u * t * c[1] + t * t * b[1]))
        elif op == "curveTo":
            a = pts[-1]
            c1, c2, b = args
            for i in range(1, 25):
                t = i / 24
                u = 1 - t
                pts.append(
                    (
                        u**3 * a[0] + 3 * u * u * t * c1[0] + 3 * u * t * t * c2[0] + t**3 * b[0],
                        u**3 * a[1] + 3 * u * u * t * c1[1] + 3 * u * t * t * c2[1] + t**3 * b[1],
                    )
                )
        elif op == "closePath":
            if len(pts) > 1:
                out.append((pts, True))
            pts = [pts[0]] if pts else []
        elif op == "endPath":
            if len(pts) > 1:
                out.append((pts, False))
            pts = []
    if len(pts) > 1:
        out.append((pts, False))
    return out


def _circle_pts(cx: float, cy: float, r: float, n: int = 96) -> list[tuple[float, float]]:
    return [(cx + r * math.cos(2 * math.pi * i / n), cy + r * math.sin(2 * math.pi * i / n)) for i in range(n)]


def _orient(poly: list[tuple[float, float]], clockwise: bool) -> list[tuple[float, float]]:
    area = sum(poly[i][0] * poly[(i + 1) % len(poly)][1] - poly[(i + 1) % len(poly)][0] * poly[i][1] for i in range(len(poly)))
    # ruang font y ke atas: area > 0 = berlawanan jarum jam
    return poly[::-1] if (area > 0) == clockwise else poly


class Stroker:
    """Garis bulat (cap & join round) sebagai gabungan bidang: kapsul per segmen + lingkaran per titik.

    Semua kontur searah jarum jam → aturan isi non-zero TrueType menghasilkan gabungannya.
    """

    def __init__(self) -> None:
        self.contours: list[list[tuple[float, float]]] = []

    def _add(self, poly):
        self.contours.append(_orient([(x * SCALE, (24 - y) * SCALE) for x, y in poly], clockwise=True))

    def dot(self, x: float, y: float, r: float) -> None:
        self._add(_circle_pts(x, y, r, 20))

    def segment(self, a, b, w: float) -> None:
        dx, dy = b[0] - a[0], b[1] - a[1]
        ln = math.hypot(dx, dy)
        if ln < 1e-6:
            return
        nx, ny = -dy / ln * w / 2, dx / ln * w / 2
        self._add([(a[0] + nx, a[1] + ny), (b[0] + nx, b[1] + ny), (b[0] - nx, b[1] - ny), (a[0] - nx, a[1] - ny)])

    def polyline(self, pts, closed: bool, w: float) -> None:
        seq = pts + [pts[0]] if closed else pts
        for a, b in zip(seq, seq[1:]):
            self.segment(a, b, w)
        # lingkaran pada setiap sudut nyata & ujung; titik hasil perataan kurva cukup dijaga kapsulnya
        for i, p in enumerate(pts):
            if not closed and i in (0, len(pts) - 1):
                self.dot(*p, w / 2)
                continue
            prev = pts[i - 1] if i > 0 else (pts[-1] if closed else None)
            nxt = pts[i + 1] if i + 1 < len(pts) else (pts[0] if closed else None)
            if prev is None or nxt is None:
                continue
            a1 = math.atan2(p[1] - prev[1], p[0] - prev[0])
            a2 = math.atan2(nxt[1] - p[1], nxt[0] - p[0])
            turn = abs((a2 - a1 + math.pi) % (2 * math.pi) - math.pi)
            if turn > math.radians(3):
                self.dot(*p, w / 2)

    def ring(self, cx, cy, r, w: float, dash: tuple[float, float] | None) -> None:
        if not dash:
            outer = _circle_pts(cx, cy, r + w / 2)
            inner = _circle_pts(cx, cy, r - w / 2)
            self._add(outer)
            # lubang: arah berlawanan
            self.contours.append(_orient([(x * SCALE, (24 - y) * SCALE) for x, y in inner], clockwise=False))
            return
        on, off = dash
        circ = 2 * math.pi * r
        pos = 0.0
        while pos < circ - 1e-6:
            a0 = pos / r
            a1 = min(pos + on, circ) / r
            pts = [(cx + r * math.cos(a0 + (a1 - a0) * i / 4), cy + r * math.sin(a0 + (a1 - a0) * i / 4)) for i in range(5)]
            self.polyline(pts, False, w)
            pos += on + off


def _clean(pts, closed):
    clean = [pts[0]]
    for p in pts[1:]:
        if math.hypot(p[0] - clean[-1][0], p[1] - clean[-1][1]) > 1e-4:
            clean.append(p)
    if closed and len(clean) > 2 and math.hypot(clean[0][0] - clean[-1][0], clean[0][1] - clean[-1][1]) < 1e-4:
        clean.pop()
    return clean


def _round_rect(x, y, w, h, r):
    r = min(r, w / 2, h / 2)
    pts = []
    for cx, cy, a0 in ((x + w - r, y + r, -90), (x + w - r, y + h - r, 0), (x + r, y + h - r, 90), (x + r, y + r, 180)):
        for i in range(9):
            a = math.radians(a0 + 90 * i / 8)
            pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def stroke_glyph(svg: Path, pen) -> None:
    """Ikon bergaris/berisi sederhana (path, circle, rect) dengan atribut warisan dari <g>."""
    root = ET.parse(svg).getroot()
    st = Stroker()

    def walk(node, inherited):
        attrs = dict(inherited)
        for k in ("stroke", "stroke-width", "fill", "stroke-dasharray"):
            if node.get(k) is not None:
                attrs[k] = node.get(k)
        tag = node.tag.replace(NS, "")
        if tag in ("svg", "g"):
            for child in node:
                walk(child, attrs)
            return
        if tag in ("title", "desc", "defs"):
            return
        stroked = attrs.get("stroke", "none") != "none"
        filled = attrs.get("fill", "#000") != "none"
        w = float(attrs.get("stroke-width", "1"))
        dash = attrs.get("stroke-dasharray")
        if tag == "path":
            for pts, closed in _flatten(node.get("d")):
                pts = _clean(pts, closed)
                if stroked:
                    st.polyline(pts, closed, w)
                if filled and closed:
                    st._add(pts)
        elif tag == "circle":
            cx, cy, r = float(node.get("cx")), float(node.get("cy")), float(node.get("r"))
            if stroked:
                st.ring(cx, cy, r, w, tuple(float(v) for v in dash.split()) if dash else None)
            if filled:
                st._add(_circle_pts(cx, cy, r))
        elif tag == "rect":
            pts = _round_rect(float(node.get("x", 0)), float(node.get("y", 0)), float(node.get("width")),
                              float(node.get("height")), float(node.get("rx", 0)))
            if stroked:
                st.polyline(pts, True, w)
            if filled:
                st._add(pts)
        else:
            raise ValueError(f"elemen {tag} belum didukung: {svg}")

    walk(root, {})
    for c in st.contours:
        pen.moveTo(c[0])
        for p in c[1:]:
            pen.lineTo(p)
        pen.closePath()


def auto_glyph(svg: Path, pen) -> None:
    """Glyph FA bila ada transform khas FA; selain itu diubah dari garis/isi SVG."""
    if 'transform="translate(12 12) scale(' in svg.read_text(encoding="utf-8"):
        fa_glyph(svg, pen)
    else:
        stroke_glyph(svg, pen)


# ---------------------------------------------------------------- penamaan & build

def camel(name: str) -> str:
    parts = name.split("_")
    return parts[0] + "".join(p.capitalize() for p in parts[1:])


GROUPS = [
    ("ui", auto_glyph, ""),
    ("islami", stroke_glyph, ""),
    ("sholat", auto_glyph, "sholat_"),
]

DOC = {
    "ui": "Ikon UI umum (Font Awesome 4 oleh Dave Gandy, SIL OFL 1.1, lihat Tentang & Lisensi).",
    "islami": "Ikon Islami bergaris (asset kit Moeslim PM).",
    "sholat": "Ikon waktu salat.",
}


def main() -> int:
    entries: list[tuple[str, str, str, object, Path]] = []  # (group, dartName, glyphName, fn, path)
    for group, fn, prefix in GROUPS:
        for svg in sorted((SRC / group).glob("*.svg")):
            stem = prefix + svg.stem
            entries.append((group, camel(stem), stem, fn, svg))
    names = [e[1] for e in entries]
    dupes = {n for n in names if names.count(n) > 1}
    if dupes:
        raise SystemExit(f"nama ikon ganda: {dupes}")

    glyph_order = [".notdef"] + [e[2] for e in entries]
    cmap: dict[int, str] = {}
    glyphs = {}
    empty = TTGlyphPen(None)
    glyphs[".notdef"] = empty.glyph()
    for i, (group, dart, gname, fn, svg) in enumerate(entries):
        pen = TTGlyphPen(None)
        fn(svg, pen)
        glyphs[gname] = pen.glyph()
        cmap[FIRST_CODEPOINT + i] = gname

    fb = FontBuilder(UPM, isTTF=True)
    fb.setupGlyphOrder(glyph_order)
    fb.setupCharacterMap(cmap)
    fb.setupGlyf(glyphs)
    metrics = {}
    for g in glyph_order:
        gl = glyphs[g]
        gl.recalcBounds(None)
        lsb = gl.xMin if gl.numberOfContours != 0 else 0
        metrics[g] = (UPM, lsb)
    fb.setupHorizontalMetrics(metrics)
    fb.setupHorizontalHeader(ascent=UPM, descent=0)
    fb.setupNameTable(
        {
            "familyName": "MoeslimIcons",
            "styleName": "Regular",
            "copyright": "UI glyphs derived from Font Awesome 4 by Dave Gandy (SIL OFL 1.1); Islamic icons: Moeslim PM asset kit",
        }
    )
    fb.setupOS2(sTypoAscender=UPM, sTypoDescender=0, usWinAscent=UPM, usWinDescent=0)
    fb.setupPost()
    FONT_OUT.parent.mkdir(parents=True, exist_ok=True)
    fb.save(str(FONT_OUT))

    lines = [
        "// GENERATED: jangan diedit manual. Sumber: tools/icons/build_icon_font.py",
        "// ignore_for_file: constant_identifier_names",
        "",
        "import 'package:material_ui/material_ui.dart';",
        "",
        "/// Ikon Moeslim PM dari asset kit (font `MoeslimIcons`). Pakai seperti `Icons.xxx`:",
        "/// `Icon(MoeslimIcons.beranda)`. Warna & ukuran mengikuti [IconTheme].",
        "abstract final class MoeslimIcons {",
        "  static const _family = 'MoeslimIcons';",
        "  static const _package = 'moeslim_brand';",
    ]
    last = None
    for i, (group, dart, gname, fn, svg) in enumerate(entries):
        if group != last:
            lines += ["", f"  // {DOC[group]}"]
            last = group
        lines.append(
            f"  static const IconData {dart} = IconData(0x{FIRST_CODEPOINT + i:X}, fontFamily: _family, fontPackage: _package);"
        )
    lines += ["", "  /// Semua ikon beserta nama sumbernya (untuk galeri & test).", "  static const Map<String, IconData> all = {"]
    for group, dart, gname, fn, svg in entries:
        lines.append(f"    '{gname}': {dart},")
    lines += ["  };", "}", ""]
    DART_OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"{len(entries)} ikon -> {FONT_OUT.relative_to(ROOT)} ({FONT_OUT.stat().st_size} B), {DART_OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
