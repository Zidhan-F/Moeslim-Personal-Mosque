"""Impor aset dari *Moeslim PM Complete Asset Kit* ke paket `moeslim_brand`.

    python -P tools/asset_kit/import_kit.py <folder Moeslim_PM_Complete_Asset_Kit>

- 02_ILUSTRASI_PNG  → assets/illustrations/<nama>_<n>.webp  (latar krem dibuat transparan
                       lewat flood-fill dari tepi + color-to-alpha, agar menyatu di mode gelap)
- 04_BACKGROUND     → assets/backgrounds/<nama>.webp
- 03_POLA_GEOMETRIS → assets/patterns/<nama>.png   (384 px, satu warna → bisa diwarnai ulang)
- 06 Ubin_Fitur, 08_ELEMEN_FITUR → assets/kit/**.svg  (teks statis berfont Arial dibuang; judul
                       empty state & huruf mata angin dirender Flutter dengan Inter agar aksesibel)

Ikon UI/Islami/salat tidak di sini; lihat tools/icons/build_icon_font.py.
"""

from __future__ import annotations

import math
import re
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
PKG = ROOT / "packages" / "moeslim_brand" / "assets"

ILLUSTRATIONS = ["masjid_pagi", "alquran_rehal", "ramadan_malam", "manajemen_masjid"]
BACKGROUNDS = [
    "splash_gelap", "personal_terang", "masjid_terang", "ramadan_gelap", "alquran_krem",
    "banner_gelap", "banner_terang", "header_masjid", "tv_gelap", "tv_terang",
]
PATTERNS = ["anyaman", "bintang_delapan", "bunga_geometri", "crescent", "diamonds", "gelombang", "lingkar_islam", "mihrab"]
TILES = [
    "alquran", "arah_kiblat", "display", "doa_dzikir", "imams", "iqamah", "jadwal_sholat",
    "kalender_hijriah", "keuangan", "masjid", "ramadan", "sajadah", "tasbih",
]
EMPTY = ["kosong_agenda", "kosong_transaksi", "tanpa_internet", "tidak_ada_hasil"]
ELEMENTS = {
    "Alquran/bingkai_ayat.svg": "quran/bingkai_ayat.svg",
    "Alquran/header_mushaf.svg": "quran/header_mushaf.svg",
    "Alquran/pemisah_ayat.svg": "quran/pemisah_ayat.svg",
    "Dekorasi/bulan_bintang.svg": "decor/bulan_bintang.svg",
    "Dekorasi/siluet_masjid.svg": "decor/siluet_masjid.svg",
    "Kiblat/jarum_kompas.svg": "qibla/jarum_kompas.svg",
}


def cut_background(src: Path, dst: Path) -> None:
    """Latar krem bertekstur → transparan. Deteksi di salinan median-blur (tekstur kertas hilang),
    wilayah latar = terhubung ke tepi; lubang kecil (bintik) ikut latar; tepi 3 px dihaluskan."""
    im = Image.open(src).convert("RGB")
    smooth = im.filter(ImageFilter.MedianFilter(5)).filter(ImageFilter.GaussianBlur(1.5))
    a = np.asarray(im).astype(np.float32)
    sm = np.asarray(smooth).astype(np.float32)
    h, w, _ = a.shape
    border = np.concatenate([sm[0], sm[-1], sm[:, 0], sm[:, -1]])
    bg = np.median(border, axis=0)

    marker = (255, 0, 255)
    probe = smooth.copy()
    step = 8
    seeds = [(x, 0) for x in range(0, w, step)] + [(x, h - 1) for x in range(0, w, step)]
    seeds += [(0, y) for y in range(0, h, step)] + [(w - 1, y) for y in range(0, h, step)]
    for s in seeds:
        px = probe.getpixel(s)
        if px != marker and np.abs(np.asarray(px, np.float32) - bg).max() < 22:
            ImageDraw.floodfill(probe, s, marker, thresh=22)
    mask = np.all(np.asarray(probe) == marker, axis=-1)

    def grow(m, n):
        for _ in range(n):
            g = m.copy()
            g[1:] |= m[:-1]; g[:-1] |= m[1:]; g[:, 1:] |= m[:, :-1]; g[:, :-1] |= m[:, 1:]
            m = g
        return m

    def shrink(m, n):
        return ~grow(~m, n)

    mask = shrink(grow(mask, 3), 3)  # tutup bintik kecil di latar
    band = grow(mask, 3) & ~shrink(mask, 1)

    # alfa: latar 0; pita tepi = color-to-alpha (dari salinan halus agar tanpa bintik); konten 1
    diff = np.clip(bg - sm, 0, None) / np.maximum(bg, 1)
    over = np.clip(sm - bg, 0, None) / np.maximum(255 - bg, 1)
    alpha_c = np.clip(np.maximum(diff, over).max(axis=-1) * 2.2, 0, 1)
    alpha = np.where(mask & ~band, 0.0, np.where(band, alpha_c, 1.0))
    safe = np.maximum(alpha, 1e-3)[..., None]
    soft = np.where((alpha_c > 0.9)[..., None], a, np.clip(bg + (sm - bg) / safe, 0, 255))
    rgb = np.where(band[..., None], soft, a)
    rgb = np.where((alpha == 0)[..., None], 0, rgb)
    out = np.dstack([rgb, alpha * 255]).astype(np.uint8)
    Image.fromarray(out, "RGBA").save(dst, "WEBP", quality=82, method=6)


def dashed_circles_to_dots(svg: str) -> str:
    """flutter_svg mengabaikan stroke-dasharray: lingkaran putus-putus (dash pendek, ujung bulat)
    diganti deretan titik berisi agar tampil seperti di asset kit (mis. cincin tasbih)."""

    def repl(m: re.Match) -> str:
        attrs = dict(re.findall(r'([\w-]+)="([^"]*)"', m.group(0)))
        cx, cy, r = float(attrs["cx"]), float(attrs["cy"]), float(attrs["r"])
        on, off = (float(v) for v in attrs["stroke-dasharray"].split())
        w = float(attrs.get("stroke-width", 1))
        # warna garis: atribut sendiri, atau stroke terdekat sebelum elemen (warisan <g>)
        inherited = re.findall(r'stroke="(#[0-9A-Fa-f]{3,6})"', svg[: m.start()])
        color = attrs.get("stroke") or (inherited[-1] if inherited else "#087E65")
        n = int(2 * math.pi * r // (on + off))
        dots = []
        for i in range(n):
            a = (i * (on + off) + on / 2) / r
            dots.append(f'<circle cx="{cx + r * math.cos(a):.2f}" cy="{cy + r * math.sin(a):.2f}" r="{w / 2 + on / 4:.2f}" fill="{color}" stroke="none"/>')
        return "".join(dots)

    return re.sub(r'<circle\b[^>]*stroke-dasharray="[^"]+"[^>]*/>', repl, svg)


def strip_text(svg: str) -> str:
    svg = re.sub(r"<text\b[^>]*>.*?</text>", "", svg, flags=re.S)
    return re.sub(r"<title>.*?</title>", "", svg, flags=re.S)


def write(dst: Path, text: str) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(text, encoding="utf-8")


def main(kit: Path) -> int:
    n = 0
    (PKG / "illustrations").mkdir(parents=True, exist_ok=True)
    for name in ILLUSTRATIONS:
        for v in range(1, 5):
            cut_background(kit / "02_ILUSTRASI_PNG" / f"{name}_variasi_0{v}.png", PKG / "illustrations" / f"{name}_{v}.webp")
            n += 1

    (PKG / "backgrounds").mkdir(parents=True, exist_ok=True)
    for name in BACKGROUNDS:
        src = next((kit / "04_BACKGROUND").glob(f"{name}_*x*.png"))
        Image.open(src).convert("RGB").save(PKG / "backgrounds" / f"{name}.webp", "WEBP", quality=82, method=6)
        n += 1

    (PKG / "patterns").mkdir(parents=True, exist_ok=True)
    for name in PATTERNS:
        Image.open(kit / "03_POLA_GEOMETRIS" / f"{name}_384x384.png").convert("RGBA").save(
            PKG / "patterns" / f"{name}.png", optimize=True
        )
        n += 1

    for name in TILES:
        svg = strip_text((kit / "06_IKON_ISLAMI" / "Ubin_Fitur" / f"{name}.svg").read_text("utf-8"))
        write(PKG / "kit" / "tiles" / f"{name}.svg", dashed_circles_to_dots(svg))
        n += 1
    for name in EMPTY:
        svg = strip_text((kit / "08_ELEMEN_FITUR" / "Empty_States" / f"{name}.svg").read_text("utf-8"))
        # hanya gambar (lingkaran r=100 di 260,155); judul & pesan dirender Flutter
        svg = re.sub(r'width="520" height="400" viewBox="0 0 520 400"', 'width="220" height="220" viewBox="150 45 220 220"', svg)
        write(PKG / "kit" / "empty" / f"{name}.svg", svg)
        n += 1
    for src, dst in ELEMENTS.items():
        write(PKG / "kit" / dst, strip_text((kit / "08_ELEMEN_FITUR" / src).read_text("utf-8")))
        n += 1
    write(PKG / "kit" / "qibla" / "dial_kompas.svg", strip_text((kit / "08_ELEMEN_FITUR" / "Kiblat" / "dial_kompas.svg").read_text("utf-8")))
    n += 1
    print(f"{n} aset diimpor ke {PKG.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    sys.exit(main(Path(sys.argv[1])))
