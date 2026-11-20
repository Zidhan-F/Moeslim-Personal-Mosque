"""Generator ilustrasi Moeslim PM (SVG) — gaya mengikuti paket visualisasi UI:
masjid krem berkubah emas, langit biru lembut, pepohonan & palem, Al-Qur'an di rehal, ornamen kisi hijau.

Jalankan:  python3 build.py && node render.js
Keluaran:  svg/*.svg  →  packages/moeslim_brand/assets/illustrations/*.png
"""

import math
import os

OUT = os.path.join(os.path.dirname(__file__), 'svg')

EMERALD = '#087E65'
DEEP = '#07372F'
DARK = '#06473D'
GOLD = '#D9AB36'
CREAM = '#F7F7F1'

DEFS = f'''
<defs>
  <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#8FCBE6"/><stop offset=".55" stop-color="#CFE9F1"/><stop offset="1" stop-color="#F6F1E2"/>
  </linearGradient>
  <linearGradient id="wall" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0" stop-color="#FFFEFA"/><stop offset=".6" stop-color="#F6EFDF"/><stop offset="1" stop-color="#E4D8BE"/>
  </linearGradient>
  <linearGradient id="wallDark" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0" stop-color="#EDE3CC"/><stop offset="1" stop-color="#D6C7A6"/>
  </linearGradient>
  <radialGradient id="dome" cx=".36" cy=".3" r=".85">
    <stop offset="0" stop-color="#FFFFFF"/><stop offset=".45" stop-color="#F5EEDD"/><stop offset="1" stop-color="#CDBD98"/>
  </radialGradient>
  <linearGradient id="gold" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#F6DC8C"/><stop offset=".5" stop-color="{GOLD}"/><stop offset="1" stop-color="#A47A1C"/>
  </linearGradient>
  <linearGradient id="window" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#6E968D"/><stop offset="1" stop-color="#3F6A61"/>
  </linearGradient>
  <linearGradient id="grass" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#9BD08C"/><stop offset="1" stop-color="#4F995C"/>
  </linearGradient>
  <radialGradient id="tree" cx=".35" cy=".3" r=".8">
    <stop offset="0" stop-color="#8CCB6E"/><stop offset=".6" stop-color="#4E9E4F"/><stop offset="1" stop-color="#2D6E3D"/>
  </radialGradient>
  <linearGradient id="leaf" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#5BAA5E"/><stop offset="1" stop-color="#2C6A3E"/>
  </linearGradient>
  <linearGradient id="trunk" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0" stop-color="#A07B4E"/><stop offset="1" stop-color="#6E5030"/>
  </linearGradient>
  <linearGradient id="page" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0" stop-color="#F3E7C8"/><stop offset=".85" stop-color="#FFFBEF"/><stop offset="1" stop-color="#EADBB5"/>
  </linearGradient>
  <linearGradient id="pageR" x1="1" y1="0" x2="0" y2="0">
    <stop offset="0" stop-color="#F3E7C8"/><stop offset=".85" stop-color="#FFFBEF"/><stop offset="1" stop-color="#EADBB5"/>
  </linearGradient>
  <linearGradient id="wood" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#B07A43"/><stop offset="1" stop-color="#6F4521"/>
  </linearGradient>
  <linearGradient id="emerald" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#14A07F"/><stop offset=".55" stop-color="{EMERALD}"/><stop offset="1" stop-color="{DARK}"/>
  </linearGradient>
  <radialGradient id="glow" cx=".5" cy=".5" r=".5">
    <stop offset="0" stop-color="#FFF4C7"/><stop offset=".6" stop-color="#F7C65A"/><stop offset="1" stop-color="#E09A2A"/>
  </radialGradient>
  <radialGradient id="halo" cx=".5" cy=".5" r=".5">
    <stop offset="0" stop-color="#FFE7A0" stop-opacity=".75"/><stop offset="1" stop-color="#FFE7A0" stop-opacity="0"/>
  </radialGradient>
  <filter id="soft" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="6"/></filter>
  <filter id="shadow" x="-20%" y="-20%" width="140%" height="160%">
    <feDropShadow dx="0" dy="6" stdDeviation="8" flood-color="#2b2b1f" flood-opacity=".22"/>
  </filter>
  <pattern id="lattice" width="48" height="48" patternUnits="userSpaceOnUse">
    <g fill="none" stroke="{EMERALD}" stroke-width="1.6" opacity=".55">
      <path d="M24 4 L30 18 L44 24 L30 30 L24 44 L18 30 L4 24 L18 18 Z"/>
      <path d="M10 10 L24 16 L38 10 L32 24 L38 38 L24 32 L10 38 L16 24 Z"/>
      <path d="M0 0 L10 10 M48 0 L38 10 M0 48 L10 38 M48 48 L38 38"/>
    </g>
  </pattern>
  <pattern id="latticeGold" width="48" height="48" patternUnits="userSpaceOnUse">
    <g fill="none" stroke="{GOLD}" stroke-width="1.4" opacity=".5">
      <path d="M24 4 L30 18 L44 24 L30 30 L24 44 L18 30 L4 24 L18 18 Z"/>
      <path d="M10 10 L24 16 L38 10 L32 24 L38 38 L24 32 L10 38 L16 24 Z"/>
    </g>
  </pattern>
</defs>'''


def svg(w, h, body, defs=DEFS):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">{defs}{body}</svg>'


def g(body, x=0, y=0, s=1.0, extra=''):
    return f'<g transform="translate({x:.1f} {y:.1f}) scale({s:.3f})" {extra}>{body}</g>'


# ── Bagian ──────────────────────────────────────────────────────────────

def crescent(cx, cy, r):
    """Bulan sabit emas di puncak menara/kubah."""
    return (
        f'<path d="M{cx + r * .2:.1f} {cy - r:.1f} A{r} {r} 0 1 0 {cx + r * .2:.1f} {cy + r:.1f} '
        f'A{r * .78:.1f} {r * .78:.1f} 0 1 1 {cx + r * .2:.1f} {cy - r:.1f} Z" fill="url(#gold)"/>'
    )


def finial(cx, top, h=26, r=5):
    return (
        f'<rect x="{cx - 1.4}" y="{top + 8}" width="2.8" height="{h}" fill="url(#gold)"/>'
        f'<circle cx="{cx}" cy="{top + h * .62 + 8:.1f}" r="{r * .8:.1f}" fill="url(#gold)"/>'
        f'<circle cx="{cx}" cy="{top + h * .9 + 8:.1f}" r="{r:.1f}" fill="url(#gold)"/>'
        + crescent(cx, top + 2, r * 1.15)
    )


def onion_dome(cx, base, w, h, gold_band=True):
    """Kubah bawang runcing; alas di y=base, lebar w, tinggi h."""
    x0, x1 = cx - w / 2, cx + w / 2
    top = base - h
    d = (
        f'M{x0:.1f} {base:.1f} C{x0 - w * .08:.1f} {base - h * .55:.1f} {cx - w * .32:.1f} {top + h * .2:.1f} {cx:.1f} {top:.1f} '
        f'C{cx + w * .32:.1f} {top + h * .2:.1f} {x1 + w * .08:.1f} {base - h * .55:.1f} {x1:.1f} {base:.1f} Z'
    )
    out = f'<path d="{d}" fill="url(#dome)" stroke="#C9B78E" stroke-width="1.2"/>'
    if gold_band:
        out += f'<rect x="{x0 - 2:.1f}" y="{base - 3:.1f}" width="{w + 4:.1f}" height="6" rx="2" fill="url(#gold)"/>'
    out += finial(cx, top - 34, 30, max(4, w * .045))
    return out


def arch_path(x, y, w, h):
    """Pintu/jendela lengkung runcing (alas di y+h)."""
    r = w / 2
    return (
        f'M{x:.1f} {y + h:.1f} L{x:.1f} {y + r:.1f} Q{x:.1f} {y:.1f} {x + r:.1f} {y - r * .35:.1f} '
        f'Q{x + w:.1f} {y:.1f} {x + w:.1f} {y + r:.1f} L{x + w:.1f} {y + h:.1f} Z'
    )


def minaret(cx, top, ground, w=24):
    x = cx - w / 2
    out = f'<rect x="{x:.1f}" y="{top + 30:.1f}" width="{w}" height="{ground - top - 30:.1f}" fill="url(#wall)"/>'
    out += f'<rect x="{x:.1f}" y="{top + 30:.1f}" width="{w * .28:.1f}" height="{ground - top - 30:.1f}" fill="#FFFFFF" opacity=".6"/>'
    for by in (top + 70, top + 140):
        if by < ground - 30:
            out += f'<rect x="{x - 6:.1f}" y="{by:.1f}" width="{w + 12}" height="9" rx="3" fill="url(#wallDark)"/>'
            out += f'<rect x="{x - 3:.1f}" y="{by + 9:.1f}" width="{w + 6}" height="4" fill="url(#gold)" opacity=".8"/>'
            out += f'<path d="{arch_path(cx - 4, by - 26, 8, 20)}" fill="url(#window)"/>'
    out += onion_dome(cx, top + 32, w + 6, 30, gold_band=True)
    return out


def mosque(scale=1.0, x=0, y=0, minarets=True):
    """Masjid putih-krem, kubah utama & dua kubah samping, dua menara. Ukuran lokal 420×320, tanah di y=320."""
    G = 320
    b = ''
    if minarets:
        b += minaret(30, 20, G, 22) + minaret(390, 20, G, 22)
    # sayap samping
    for sx in (70, 290):
        b += f'<rect x="{sx}" y="210" width="60" height="{G - 210}" fill="url(#wall)"/>'
        b += f'<rect x="{sx - 3}" y="204" width="66" height="8" rx="2" fill="url(#wallDark)"/>'
        b += onion_dome(sx + 30, 206, 46, 40)
        for i in range(2):
            b += f'<path d="{arch_path(sx + 10 + i * 24, 248, 16, 60)}" fill="url(#window)"/>'
    # aula utama
    b += f'<rect x="120" y="190" width="180" height="{G - 190}" fill="url(#wall)"/>'
    b += f'<rect x="116" y="182" width="188" height="10" rx="3" fill="url(#wallDark)"/>'
    for i in range(12):
        b += f'<rect x="{121 + i * 15.3:.1f}" y="174" width="8" height="9" rx="2" fill="url(#wallDark)"/>'
    # drum + kubah utama
    b += f'<rect x="160" y="150" width="100" height="34" fill="url(#wall)"/>'
    for i in range(5):
        b += f'<path d="{arch_path(168 + i * 18, 158, 10, 22)}" fill="url(#window)" opacity=".9"/>'
    b += onion_dome(210, 152, 128, 112)
    # pintu utama besar + pintu samping
    b += f'<path d="{arch_path(186, 236, 48, 84)}" fill="url(#window)"/>'
    b += f'<path d="{arch_path(180, 230, 60, 90)}" fill="none" stroke="url(#gold)" stroke-width="3"/>'
    for ax in (134, 160, 248, 274):
        b += f'<path d="{arch_path(ax, 256, 14, 64)}" fill="url(#window)"/>'
    # undakan
    b += f'<rect x="100" y="{G - 6}" width="220" height="6" fill="#E2D6BA"/>'
    return g(b, x, y, scale)


def palm(x, ground, h=200, flip=False, s=1.0):
    """Palem rimbun: batang melengkung bercincin, 11 pelepah berdaun menjuntai (dua lapis)."""
    sx = -1 if flip else 1
    tx, ty = 30 * sx, -h
    trunk = (
        f'<path d="M-9 0 Q{10 * sx} {-h * .5:.1f} {tx - 5:.1f} {ty:.1f} L{tx + 5:.1f} {ty:.1f} '
        f'Q{20 * sx} {-h * .5:.1f} 9 0 Z" fill="url(#trunk)"/>'
    )
    rings = ''
    for i in range(1, 14):
        t = i / 14
        cx = (1 - t) ** 2 * 0 + 2 * (1 - t) * t * (15 * sx) + t * t * tx
        rings += f'<path d="M{cx - 7:.1f} {-h * t:.1f} q7 -5 14 0" stroke="#5A4026" stroke-width="1.6" fill="none" opacity=".55"/>'

    def frond(ang, L, droop, col, wdt):
        a = math.radians(ang)
        ex, ey = tx + math.cos(a) * L, ty + math.sin(a) * L * .45 + droop
        cx1, cy1 = tx + math.cos(a) * L * .45, ty - abs(math.cos(a)) * L * .28 - 10
        # helai daun: sisi atas & bawah pelepah, ujung runcing
        nx, ny = -math.sin(a) * wdt, math.cos(a) * wdt * .6
        out = (
            f'<path d="M{tx:.1f} {ty:.1f} Q{cx1 - nx:.1f} {cy1 - ny - wdt:.1f} {ex:.1f} {ey:.1f} '
            f'Q{cx1 + nx:.1f} {cy1 + ny + wdt * .6:.1f} {tx:.1f} {ty + 4:.1f} Z" fill="{col}"/>'
        )
        # urat tengah
        out += f'<path d="M{tx:.1f} {ty:.1f} Q{cx1:.1f} {cy1 - 2:.1f} {ex:.1f} {ey:.1f}" stroke="#24563A" stroke-width="1.4" fill="none" opacity=".7"/>'
        # torehan helai
        for k in range(1, 7):
            t = k / 7
            px = (1 - t) ** 2 * tx + 2 * (1 - t) * t * cx1 + t * t * ex
            py = (1 - t) ** 2 * ty + 2 * (1 - t) * t * cy1 + t * t * ey
            out += f'<path d="M{px:.1f} {py:.1f} l{nx * .9:.1f} {wdt * .9:.1f}" stroke="#2A6A42" stroke-width="1.2" opacity=".55"/>'
        return out

    back = ''.join(frond(a, 120, 50, '#2F6E43', 30) for a in (-178, -150, -112, -62, -30, -2, 165, 25))
    front = ''.join(frond(a, 110, 44, 'url(#leaf)', 32) for a in (-165, -132, -98, -78, -48, -15, 195))
    fruit = ''.join(f'<circle cx="{tx + dx}" cy="{ty + 10 + dy}" r="5" fill="#8A5A22"/>' for dx, dy in ((-6, 0), (5, 2), (0, 7)))
    return g(trunk + rings + back + fruit + front, x, ground, s)


def round_tree(x, ground, r=60, s=1.0):
    b = f'<rect x="-6" y="{-r * .9:.1f}" width="12" height="{r * .9:.1f}" fill="url(#trunk)"/>'
    for dx, dy, rr in ((-r * .45, -r * 1.25, r * .62), (r * .45, -r * 1.2, r * .6), (0, -r * 1.65, r * .66), (0, -r * 1.05, r * .55)):
        b += f'<circle cx="{dx:.1f}" cy="{dy:.1f}" r="{rr:.1f}" fill="url(#tree)"/>'
    b += f'<circle cx="{-r * .25:.1f}" cy="{-r * 1.75:.1f}" r="{r * .18:.1f}" fill="#B6E08F" opacity=".45"/>'
    return g(b, x, ground, s)


def bush(x, ground, w=90, s=1.0):
    b = ''.join(
        f'<circle cx="{dx:.1f}" cy="{-w * .18:.1f}" r="{w * .24:.1f}" fill="url(#tree)"/>' for dx in (-w * .3, 0, w * .3)
    )
    return g(b, x, ground, s)


def cloud(x, y, s=1.0, o=.9):
    b = (
        '<ellipse cx="0" cy="0" rx="46" ry="16" fill="#fff"/>'
        '<ellipse cx="-18" cy="-10" rx="22" ry="16" fill="#fff"/>'
        '<ellipse cx="14" cy="-14" rx="26" ry="20" fill="#fff"/>'
    )
    return g(b, x, y, s, f'opacity="{o}"')


def quran_rehal(x, y, s=1.0):
    """Al-Qur'an terbuka di atas rehal kayu. Titik acuan: tengah bawah rehal."""
    b = ''
    # rehal (bentuk X)
    b += '<path d="M-120 0 L-30 -70 L-14 -62 L-100 8 Z" fill="url(#wood)"/>'
    b += '<path d="M120 0 L30 -70 L14 -62 L100 8 Z" fill="url(#wood)"/>'
    b += '<path d="M-150 -40 L0 -95 L150 -40 L140 -30 L0 -80 L-140 -30 Z" fill="#7B4C24"/>'
    # sampul
    b += '<path d="M-176 -58 Q-90 -96 0 -84 Q90 -96 176 -58 L170 -46 Q90 -82 0 -72 Q-90 -82 -170 -46 Z" fill="#0B6B4F"/>'
    # halaman kiri & kanan
    b += '<path d="M-168 -64 Q-90 -150 -2 -118 L-2 -80 Q-90 -110 -168 -60 Z" fill="url(#page)"/>'
    b += '<path d="M168 -64 Q90 -150 2 -118 L2 -80 Q90 -110 168 -60 Z" fill="url(#pageR)"/>'
    for i in range(6):
        yy = -125 + i * 9
        b += f'<path d="M{-140 + i * 3} {yy + 34 - i * 2} Q-80 {yy - 6} -22 {yy + 12}" stroke="#8C7A57" stroke-width="2" fill="none" opacity=".45"/>'
        b += f'<path d="M{140 - i * 3} {yy + 34 - i * 2} Q80 {yy - 6} 22 {yy + 12}" stroke="#8C7A57" stroke-width="2" fill="none" opacity=".45"/>'
    b += '<path d="M-2 -118 L-2 -80 L2 -80 L2 -118 Z" fill="#D2BE8E"/>'
    b += '<path d="M-168 -64 Q-90 -150 -2 -118 M168 -64 Q90 -150 2 -118" stroke="url(#gold)" stroke-width="3" fill="none"/>'
    return g(b, x, y, s, 'filter="url(#shadow)"')


def lantern(x, y, s=1.0):
    """Lentera emas bergaya Timur Tengah; (x,y) = titik gantung."""
    b = f'<circle cx="0" cy="150" r="120" fill="url(#halo)"/>'
    b += '<path d="M0 0 L0 40" stroke="url(#gold)" stroke-width="4"/>'
    b += '<circle cx="0" cy="44" r="8" fill="none" stroke="url(#gold)" stroke-width="4"/>'
    b += '<path d="M-26 92 Q-24 60 0 52 Q24 60 26 92 Z" fill="url(#gold)"/>'
    b += '<rect x="-38" y="90" width="76" height="10" rx="3" fill="url(#gold)"/>'
    b += '<path d="M-34 100 L-40 190 L40 190 L34 100 Z" fill="url(#glow)"/>'
    for xx in (-34, -12, 12, 34):
        b += f'<path d="M{xx} 100 L{xx * 1.18:.1f} 190" stroke="#A47A1C" stroke-width="4"/>'
    b += '<path d="M-37 140 L37 140" stroke="#A47A1C" stroke-width="3"/>'
    b += '<path d="M-44 190 L44 190 L30 214 L-30 214 Z" fill="url(#gold)"/>'
    b += '<path d="M-14 214 L14 214 L0 236 Z" fill="url(#gold)"/>'
    return g(b, x, y, s)


def kaaba(x, y, s=1.0):
    """Ka'bah isometrik. (x,y) = tengah alas depan."""
    b = '<path d="M-90 -20 L0 20 L0 -130 L-90 -170 Z" fill="#1B1B1B"/>'
    b += '<path d="M0 20 L90 -20 L90 -170 L0 -130 Z" fill="#2C2C2C"/>'
    b += '<path d="M-90 -170 L0 -210 L90 -170 L0 -130 Z" fill="#3A3A3A"/>'
    b += '<path d="M-90 -140 L0 -100 L90 -140 L90 -122 L0 -82 L-90 -122 Z" fill="url(#gold)"/>'
    for i in range(6):
        b += f'<path d="M{-82 + i * 14} {-133 + i * 6.2:.1f} l6 2.6" stroke="#7A5A10" stroke-width="2"/>'
        b += f'<path d="M{8 + i * 14} {-98 - i * 6.2:.1f} l6 -2.6" stroke="#7A5A10" stroke-width="2"/>'
    b += '<path d="M30 -40 L58 -52 L58 -110 L30 -98 Z" fill="url(#gold)"/>'
    b += '<path d="M36 -48 L52 -55 L52 -100 L36 -93 Z" fill="#8C6A1A"/>'
    return g(b, x, y, s)


def mosque_silhouette(x, ground, s=1.0, fill=DARK, opacity=1.0, minarets=True):
    b = ''
    if minarets:
        for mx in (20, 300):
            b += f'<rect x="{mx - 8}" y="40" width="16" height="200" />'
            b += f'<path d="M{mx - 10} 44 Q{mx} 6 {mx + 10} 44 Z"/><rect x="{mx - 1}" y="0" width="2" height="14"/>'
            b += f'<rect x="{mx - 13}" y="100" width="26" height="7" rx="2"/>'
    b += '<rect x="70" y="150" width="180" height="90"/>'
    b += '<path d="M100 152 C92 90 140 70 160 40 C180 70 228 90 220 152 Z"/><rect x="159" y="10" width="2" height="30"/>'
    b += '<path d="M60 170 C58 140 80 130 90 118 C100 130 122 140 120 170 Z"/>'
    b += '<path d="M200 170 C198 140 220 130 230 118 C240 130 262 140 260 170 Z"/>'
    return g(f'<g fill="{fill}" opacity="{opacity}">{b}</g>', x, ground - 240 * s, s)


def onion_arch_clip(cid, x, y, w, h):
    """Jendela berbentuk lengkung bawang (onion arch) untuk bingkai adegan."""
    cx = x + w / 2
    shoulder = y + h * .32
    d = (
        f'M{x:.1f} {y + h:.1f} L{x:.1f} {shoulder:.1f} C{x:.1f} {y + h * .14:.1f} {cx - w * .26:.1f} {y + h * .1:.1f} {cx:.1f} {y:.1f} '
        f'C{cx + w * .26:.1f} {y + h * .1:.1f} {x + w:.1f} {y + h * .14:.1f} {x + w:.1f} {shoulder:.1f} L{x + w:.1f} {y + h:.1f} Z'
    )
    return f'<clipPath id="{cid}"><path d="{d}"/></clipPath>', d


def ground_band(w, y, h, cx=None):
    cx = w / 2 if cx is None else cx
    return (
        f'<path d="M0 {y + 20} Q{cx * .5:.1f} {y - 10} {cx:.1f} {y} Q{cx * 1.5:.1f} {y + 10} {w} {y - 6} L{w} {y + h} L0 {y + h} Z" fill="url(#grass)"/>'
        f'<path d="M0 {y + 36} Q{cx:.1f} {y + 14} {w} {y + 30} L{w} {y + h} L0 {y + h} Z" fill="#3F8A52" opacity=".35"/>'
    )


def write(name, content):
    with open(os.path.join(OUT, f'{name}.svg'), 'w') as f:
        f.write(content)


# ── Adegan ──────────────────────────────────────────────────────────────

def scene_hero_quran():
    """Onboarding / Daftar Surah / Doa Harian: masjid & pepohonan dalam jendela lengkung, Al-Qur'an di rehal di depan."""
    W, H = 800, 720
    clip, d = onion_arch_clip('heroArch', 90, 20, 620, 600)
    inner = '<rect width="800" height="720" fill="url(#sky)"/>'
    inner += cloud(230, 160, 1.3) + cloud(560, 120, 1.0) + cloud(640, 230, .8, .8)
    inner += minaret(212, 120, 520, 32)
    inner += mosque(1.32, 255, 98, minarets=False)
    inner += minaret(720, 210, 536, 24)
    inner += ground_band(800, 500, 220)
    body = f'<defs>{clip}</defs><g clip-path="url(#heroArch)">{inner}</g>'
    body += round_tree(150, 560, 82) + round_tree(255, 590, 58) + round_tree(670, 575, 70) + round_tree(740, 600, 50)
    body += bush(120, 620, 140) + bush(700, 625, 130)
    body += f'<ellipse cx="400" cy="650" rx="300" ry="34" fill="#2E6B3E" opacity=".12" filter="url(#soft)"/>'
    body += quran_rehal(400, 680, 1.25)
    write('hero_quran', svg(W, H, body))


def scene_mosque_circle():
    """Pilih Peran / landing Mosque: masjid di lingkaran langit dengan pohon di kiri-kanan."""
    W, H = 800, 640
    inner = '<rect width="800" height="640" fill="url(#sky)"/>' + cloud(250, 150, 1.1) + cloud(560, 110, .9)
    inner += mosque(1.25, 138, 130)
    inner += ground_band(800, 520, 140)
    body = f'<defs><clipPath id="circ"><circle cx="400" cy="320" r="300"/></clipPath></defs><g clip-path="url(#circ)">{inner}</g>'
    body += round_tree(110, 560, 92) + round_tree(200, 590, 58) + round_tree(690, 560, 92) + round_tree(600, 595, 55)
    body += bush(150, 610, 160) + bush(660, 612, 160)
    body += f'<path d="M60 600 Q400 650 740 600 L740 640 L60 640 Z" fill="url(#grass)"/>'
    write('mosque_circle', svg(W, H, body))


def scene_mosque_banner():
    """Banner hijau (Registrasi, Dashboard, Keuangan, Petugas): masjid putih + palem, latar transparan."""
    W, H = 900, 560
    body = f'<ellipse cx="470" cy="520" rx="420" ry="40" fill="#0A3A2F" opacity=".35" filter="url(#soft)"/>'
    body += palm(130, 520, 300, False, 1.05) + palm(830, 520, 270, True, 1.05)
    body += mosque(1.45, 165, 56)
    body += bush(250, 532, 150) + bush(680, 532, 170) + bush(470, 540, 120)
    body += palm(60, 540, 220, False, .9)
    write('mosque_banner', svg(W, H, body))


def scene_skyline():
    """Siluet masjid hijau untuk sapaan Beranda (latar transparan) — lebih terang dari latar banner agar terbaca."""
    W, H = 900, 320
    c = '#1E9474'
    body = mosque_silhouette(380, 320, 1.05, c, .75)
    body += mosque_silhouette(140, 320, .7, c, .5)
    body += mosque_silhouette(690, 320, .62, c, .5)
    body += palm(840, 320, 170, True, .9).replace('url(#leaf)', c).replace('url(#trunk)', c).replace('#2F6E43', c).replace('#6E5030', c).replace('#8A5A22', c).replace('<g transform', '<g opacity=".55" transform', 1)
    write('skyline', svg(W, H, body))


def scene_naghom():
    """Banner 7 Irama: lengkung emas, lentera bercahaya, Al-Qur'an di rehal (transparan)."""
    W, H = 700, 620
    _, d = onion_arch_clip('n', 140, 20, 420, 560)
    body = f'<path d="{d}" fill="#0B5E4C" opacity=".55"/>'
    body += f'<path d="{d}" fill="url(#latticeGold)"/>'
    body += f'<path d="{d}" fill="none" stroke="url(#gold)" stroke-width="10"/>'
    body += lantern(350, 30, 1.3)
    body += quran_rehal(350, 600, 1.0)
    write('naghom_lantern', svg(W, H, body))


def scene_kaaba():
    W, H = 400, 400
    body = '<ellipse cx="200" cy="330" rx="150" ry="30" fill="#000" opacity=".18" filter="url(#soft)"/>' + kaaba(200, 320, 1.2)
    write('kaaba', svg(W, H, body))


def scene_login_shield():
    """Login Admin: siluet masjid hijau muda, perisai hijau berbingkai emas dengan gembok, alas laptop."""
    W, H = 900, 560
    body = mosque_silhouette(110, 430, .75, '#7CC4A4', .85) + mosque_silhouette(560, 430, .75, '#7CC4A4', .85)
    body += mosque_silhouette(330, 430, .55, '#A6D9C1', .9, minarets=False)
    body += '<path d="M90 430 Q450 396 810 430 L810 452 L90 452 Z" fill="#BFE6D3"/>'
    # alas laptop
    body += '<path d="M230 452 L670 452 L740 520 L160 520 Z" fill="#0B5E4C"/>'
    body += '<path d="M160 520 L740 520 L736 532 L164 532 Z" fill="#07372F"/>'
    body += ''.join(f'<rect x="{262 + c * 34 - r * 8}" y="{462 + r * 16}" width="26" height="10" rx="2" fill="#14A07F" opacity=".55"/>' for r in range(3) for c in range(12 + r))
    body += '<rect x="400" y="508" width="100" height="8" rx="3" fill="#14A07F" opacity=".7"/>'
    # perisai
    shield = 'M450 70 C520 110 580 112 620 110 C626 260 580 380 450 440 C320 380 274 260 280 110 C320 112 380 110 450 70 Z'
    body += f'<path d="{shield}" fill="url(#gold)" filter="url(#shadow)"/>'
    body += '<path d="M450 92 C512 126 562 130 598 130 C600 262 562 362 450 416 C338 362 300 262 302 130 C338 130 388 126 450 92 Z" fill="url(#emerald)"/>'
    body += '<path d="M450 92 C512 126 562 130 598 130 C600 180 594 222 580 260 C540 200 470 150 450 92 Z" fill="#fff" opacity=".08"/>'
    # gembok
    body += '<path d="M410 250 L410 215 A40 40 0 0 1 490 215 L490 250" fill="none" stroke="#fff" stroke-width="18"/>'
    body += '<rect x="384" y="245" width="132" height="104" rx="18" fill="#fff"/>'
    body += '<circle cx="450" cy="288" r="14" fill="#0B5E4C"/><rect x="444" y="292" width="12" height="30" rx="5" fill="#0B5E4C"/>'
    write('login_shield', svg(W, H, body))


def scene_tv():
    """Pemandangan masjid untuk panel kanan Layar Utama TV (rasio ±1,3): langit, masjid besar, palem, halaman."""
    W, H = 1300, 1000
    body = '<rect width="1300" height="1000" fill="url(#sky)"/>'
    body += cloud(200, 150, 1.5) + cloud(640, 90, 1.1) + cloud(1110, 170, 1.4) + cloud(900, 260, .9, .8)
    body += mosque(2.0, 230, 160)
    body += '<rect x="0" y="790" width="1300" height="210" fill="url(#grass)"/>'
    body += '<path d="M0 860 Q650 820 1300 860 L1300 1000 L0 1000 Z" fill="#E9E2CC"/>'
    body += '<path d="M560 1000 L620 860 L680 860 L740 1000 Z" fill="#F4EEDC"/>'
    for i, px in enumerate((40, 150, 1150, 1260)):
        body += palm(px, 860, 380 + (i % 2) * 60, px > 650, 1.15)
    for i, px in enumerate((255, 1045)):
        body += palm(px, 840, 250, px > 650, .9)
    for bx in (110, 330, 520, 780, 970, 1190):
        body += bush(bx, 866, 200)
    write('tv_mosque', svg(W, H, body))


def scene_arch_header():
    """Kepala halaman berornamen (Jadwal Salat, Detail Doa, Mushaf): lengkung kisi hijau + siluet masjid emas tipis."""
    W, H = 1000, 420
    _, d = onion_arch_clip('a', 60, 40, 880, 520)
    body = f'<rect width="1000" height="420" fill="url(#lattice)" opacity=".7"/>'
    body += f'<path d="{d}" fill="#FFFDF6"/>'
    body += f'<path d="{d}" fill="none" stroke="url(#gold)" stroke-width="4"/>'
    body += mosque_silhouette(70, 420, .55, GOLD, .28) + mosque_silhouette(760, 420, .55, GOLD, .28)
    write('arch_header', svg(W, H, body))


def scene_tasbih_side():
    """Dekorasi sisi cincin tasbih: menara & pohon pucat (transparan)."""
    W, H = 900, 500
    body = '<g opacity=".55">'
    body += minaret(90, 120, 470, 26) + round_tree(60, 480, 60) + bush(150, 486, 110)
    body += minaret(810, 120, 470, 26) + round_tree(840, 480, 60) + bush(750, 486, 110)
    body += '</g>'
    write('tasbih_side', svg(W, H, body))


def scene_corner():
    """Ornamen sudut kisi hijau (latar halaman), memudar ke tengah."""
    W, H = 420, 420
    body = (
        '<defs><radialGradient id="fade" cx="0" cy="0" r="1"><stop offset="0" stop-color="#fff"/>'
        '<stop offset=".75" stop-color="#fff" stop-opacity=".25"/><stop offset="1" stop-color="#fff" stop-opacity="0"/></radialGradient>'
        '<mask id="m"><rect width="420" height="420" fill="url(#fade)"/></mask></defs>'
        '<rect width="420" height="420" fill="url(#lattice)" mask="url(#m)"/>'
        '<path d="M0 300 Q120 280 180 180 Q240 80 330 0" fill="none" stroke="url(#gold)" stroke-width="5" opacity=".8"/>'
    )
    write('corner_lattice', svg(W, H, body))


def scene_qari():
    """Lencana qari generik (tanpa wajah orang sungguhan): lingkaran emas, Al-Qur'an & gelombang suara."""
    W, H = 400, 400
    body = '<circle cx="200" cy="200" r="190" fill="url(#gold)"/><circle cx="200" cy="200" r="176" fill="url(#emerald)"/>'
    body += mosque_silhouette(72, 300, .8, '#0A5A49', .7)
    body += quran_rehal(200, 330, .75)
    for i, r in enumerate((60, 90, 120)):
        body += f'<path d="M{200 - r} 150 A{r} {r} 0 0 1 {200 + r} 150" fill="none" stroke="#F6DC8C" stroke-width="6" stroke-linecap="round" opacity="{.9 - i * .25:.2f}"/>'
    write('qari_badge', svg(W, H, body))


def scene_calibrate():
    W, H = 360, 300
    body = '<path d="M60 150 C60 60 170 60 180 150 C190 240 300 240 300 150 C300 60 190 60 180 150 C170 240 60 240 60 150 Z" fill="none" stroke="url(#gold)" stroke-width="5" stroke-dasharray="12 10"/>'
    body += '<g transform="rotate(-20 180 150)"><rect x="140" y="70" width="80" height="150" rx="14" fill="#fff" stroke="#07372F" stroke-width="6"/>'
    body += '<rect x="152" y="88" width="56" height="106" rx="4" fill="#E3F2EC"/><circle cx="180" cy="206" r="5" fill="#07372F"/></g>'
    body += '<path d="M290 110 l14 -12 l4 18 Z" fill="url(#gold)"/>'
    write('calibrate', svg(W, H, body))


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for f in [
        scene_hero_quran, scene_mosque_circle, scene_mosque_banner, scene_skyline, scene_naghom, scene_kaaba,
        scene_login_shield, scene_tv, scene_arch_header, scene_tasbih_side, scene_corner, scene_qari, scene_calibrate,
    ]:
        f()
    print('ok', len(os.listdir(OUT)))
