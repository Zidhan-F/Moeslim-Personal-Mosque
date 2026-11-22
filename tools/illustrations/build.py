"""Generator ilustrasi Moeslim PM (SVG), gaya selaras dengan Asset Kit (warm editorial Islamic illustration):
masjid krem berkubah zamrud (emerald) & sabuk emas, cahaya mihrab hangat keemasan, halo matahari pagi,
dedaunan organik berlapis, Al-Qur'an di rehal kayu ukir dengan bintang Rub el Hizb, serta ornamen kisi.

Jalankan:  python build.py && node render.js && python optimize.py
Keluaran:  svg/*.svg  →  packages/moeslim_brand/assets/illustrations/*.webp
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
    <stop offset="0" stop-color="#BEE2D8"/><stop offset=".48" stop-color="#E4F2EA"/><stop offset="1" stop-color="#FBF4DC"/>
  </linearGradient>
  <radialGradient id="sunDisk" cx=".5" cy=".5" r=".5">
    <stop offset="0" stop-color="#FFFDF0"/><stop offset=".45" stop-color="#FCE28E"/><stop offset=".85" stop-color="#F5CA63" stop-opacity=".55"/><stop offset="1" stop-color="#F5CA63" stop-opacity="0"/>
  </radialGradient>
  <linearGradient id="wall" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0" stop-color="#FFFDF8"/><stop offset=".6" stop-color="#F6EFE0"/><stop offset="1" stop-color="#E5D8BD"/>
  </linearGradient>
  <linearGradient id="wallDark" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0" stop-color="#EDE3CC"/><stop offset="1" stop-color="#D4C4A0"/>
  </linearGradient>
  <radialGradient id="dome" cx=".35" cy=".28" r=".82">
    <stop offset="0" stop-color="#35B896"/><stop offset=".48" stop-color="{EMERALD}"/><stop offset="1" stop-color="#043A30"/>
  </radialGradient>
  <linearGradient id="gold" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#FCE69E"/><stop offset=".5" stop-color="{GOLD}"/><stop offset="1" stop-color="#9E7316"/>
  </linearGradient>
  <linearGradient id="window" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#C9831B"/><stop offset=".45" stop-color="#F3B740"/><stop offset="1" stop-color="#FFF3B8"/>
  </linearGradient>
  <linearGradient id="windowDeep" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#05352C"/><stop offset=".55" stop-color="#086A55"/><stop offset="1" stop-color="#159A7C"/>
  </linearGradient>
  <linearGradient id="grass" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#8CCB6E"/><stop offset="1" stop-color="#2D7A47"/>
  </linearGradient>
  <linearGradient id="tree" x1="0" y1="0" x2="0.4" y2="1">
    <stop offset="0" stop-color="#98D66C"/><stop offset=".55" stop-color="#439952"/><stop offset="1" stop-color="#1E5D38"/>
  </linearGradient>
  <linearGradient id="treeBack" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#6EB862"/><stop offset="1" stop-color="#1B5233"/>
  </linearGradient>
  <linearGradient id="leaf" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#64B85F"/><stop offset="1" stop-color="#22603A"/>
  </linearGradient>
  <linearGradient id="trunk" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0" stop-color="#9A7144"/><stop offset="1" stop-color="#5E4124"/>
  </linearGradient>
  <linearGradient id="page" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0" stop-color="#F4E8CA"/><stop offset=".82" stop-color="#FFFDF6"/><stop offset="1" stop-color="#E6D5AD"/>
  </linearGradient>
  <linearGradient id="pageR" x1="1" y1="0" x2="0" y2="0">
    <stop offset="0" stop-color="#F4E8CA"/><stop offset=".82" stop-color="#FFFDF6"/><stop offset="1" stop-color="#E6D5AD"/>
  </linearGradient>
  <linearGradient id="wood" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#C88A4B"/><stop offset=".5" stop-color="#9C622B"/><stop offset="1" stop-color="#5D3714"/>
  </linearGradient>
  <linearGradient id="emerald" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#14A07F"/><stop offset=".55" stop-color="{EMERALD}"/><stop offset="1" stop-color="{DARK}"/>
  </linearGradient>
  <radialGradient id="glow" cx=".5" cy=".5" r=".5">
    <stop offset="0" stop-color="#FFF4C7"/><stop offset=".6" stop-color="#F7C65A"/><stop offset="1" stop-color="#E09A2A"/>
  </radialGradient>
  <radialGradient id="halo" cx=".5" cy=".5" r=".5">
    <stop offset="0" stop-color="#FFEAA6" stop-opacity=".82"/><stop offset="1" stop-color="#FFEAA6" stop-opacity="0"/>
  </radialGradient>
  <filter id="soft" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="6"/></filter>
  <filter id="shadow" x="-20%" y="-20%" width="140%" height="160%">
    <feDropShadow dx="0" dy="6" stdDeviation="8" flood-color="#132A23" flood-opacity=".22"/>
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
    """Bulan sabit emas menghadap atas-kanan di puncak kubah/menara."""
    return (
        f'<path d="M{cx - r * .75:.1f} {cy - r * .45:.1f} A{r:.1f} {r:.1f} 0 1 0 {cx + r * .85:.1f} {cy - r * .15:.1f} '
        f'A{r * .78:.1f} {r * .78:.1f} 0 1 1 {cx - r * .75:.1f} {cy - r * .45:.1f} Z" fill="url(#gold)"/>'
    )


def finial(cx, top, h=26, r=5):
    return (
        f'<path d="M{cx - r * 1.1:.1f} {top + h + 8:.1f} L{cx:.1f} {top + 8:.1f} L{cx + r * 1.1:.1f} {top + h + 8:.1f} Z" fill="url(#gold)"/>'
        f'<circle cx="{cx}" cy="{top + h * .48 + 8:.1f}" r="{r * .72:.1f}" fill="url(#gold)"/>'
        f'<circle cx="{cx}" cy="{top + h * .78 + 8:.1f}" r="{r * .95:.1f}" fill="url(#gold)"/>'
        + crescent(cx, top + 4, r * 1.35)
    )


def onion_dome(cx, base, w, h, gold_band=True):
    """Kubah zamrud berusuk halus dengan sabuk emas & bulan sabit."""
    x0, x1 = cx - w / 2, cx + w / 2
    top = base - h
    d = (
        f'M{x0:.1f} {base:.1f} C{x0 - w * .06:.1f} {base - h * .52:.1f} {cx - w * .34:.1f} {top + h * .22:.1f} {cx:.1f} {top:.1f} '
        f'C{cx + w * .34:.1f} {top + h * .22:.1f} {x1 + w * .06:.1f} {base - h * .52:.1f} {x1:.1f} {base:.1f} Z'
    )
    out = f'<path d="{d}" fill="url(#dome)" stroke="#054A3D" stroke-width="1.2"/>'
    # Rusuk meridian kubah halus
    for k in (-0.28, -0.14, 0.14, 0.28):
        rx = cx + w * k
        out += (
            f'<path d="M{cx:.1f} {top + 2:.1f} Q{rx + w * k * .45:.1f} {base - h * .45:.1f} {rx:.1f} {base - 2:.1f}" '
            f'stroke="#5CE0B8" stroke-width="1.2" fill="none" opacity=".28"/>'
        )
    if gold_band:
        out += f'<rect x="{x0 - 3:.1f}" y="{base - 5:.1f}" width="{w + 6:.1f}" height="8" rx="3" fill="url(#gold)"/>'
    out += finial(cx, top - 32, 26, max(4.2, w * .048))
    return out


def arch_path(x, y, w, h):
    """Pintu/jendela lengkung runcing (alas di y+h)."""
    r = w / 2
    return (
        f'M{x:.1f} {y + h:.1f} L{x:.1f} {y + r:.1f} Q{x:.1f} {y:.1f} {x + r:.1f} {y - r * .36:.1f} '
        f'Q{x + w:.1f} {y:.1f} {x + w:.1f} {y + r:.1f} L{x + w:.1f} {y + h:.1f} Z'
    )


def minaret(cx, top, ground, w=26):
    x = cx - w / 2
    out = f'<rect x="{x:.1f}" y="{top + 32:.1f}" width="{w}" height="{ground - top - 32:.1f}" fill="url(#wall)"/>'
    out += f'<rect x="{x:.1f}" y="{top + 32:.1f}" width="{w * .28:.1f}" height="{ground - top - 32:.1f}" fill="#FFFFFF" opacity=".6"/>'
    out += f'<rect x="{x - 3:.1f}" y="{ground - 18:.1f}" width="{w + 6:.1f}" height="18" fill="#137A63"/>'
    # Lantern gallery di puncak menara
    ly = top + 32
    out += f'<path d="{arch_path(cx - w * .24, ly + 8, w * .48, 22)}" fill="url(#window)"/>'
    for by in (top + 62, top + 132):
        if by < ground - 30:
            out += f'<rect x="{x - 6:.1f}" y="{by:.1f}" width="{w + 12}" height="8" rx="3" fill="#0B6E58"/>'
            out += f'<rect x="{x - 4:.1f}" y="{by - 4:.1f}" width="{w + 8}" height="5" rx="2" fill="url(#gold)"/>'
            if by > top + 80:
                out += f'<path d="{arch_path(cx - 4.5, by - 28, 9, 22)}" fill="url(#window)"/>'
    out += onion_dome(cx, top + 32, w + 8, 30, gold_band=True)
    return out


def mosque(scale=1.0, x=0, y=0, minarets=True):
    """Masjid krem-gading berkubah zamrud, jendela bercahaya hangat keemasan, dan dua menara."""
    G = 320
    b = ''
    if minarets:
        b += minaret(32, 22, G, 26) + minaret(388, 22, G, 26)
    # Sayap samping
    for sx in (62, 286):
        b += onion_dome(sx + 36, 206, 56, 42)
        b += f'<rect x="{sx}" y="208" width="72" height="{G - 208}" fill="url(#wall)"/>'
        b += f'<rect x="{sx - 3}" y="202" width="78" height="7" rx="2" fill="#0A705A"/>'
        b += f'<rect x="{sx}" y="{G - 14}" width="72" height="14" fill="#137A63"/>'
        for i in range(2):
            wx = sx + 11 + i * 28
            b += f'<path d="{arch_path(wx - 2, 244, 24, 64)}" fill="#E2D3B3"/>'
            b += f'<path d="{arch_path(wx, 246, 20, 62)}" fill="url(#window)"/>'
    # Drum + kubah utama
    b += f'<rect x="150" y="148" width="120" height="36" fill="url(#wall)"/>'
    for i in range(5):
        b += f'<path d="{arch_path(160 + i * 21, 156, 12, 22)}" fill="url(#windowDeep)" opacity=".92"/>'
    b += onion_dome(210, 150, 142, 114)
    # Aula tengah & pishtaq (fasad mihrab utama)
    b += f'<rect x="122" y="184" width="176" height="{G - 184}" fill="url(#wall)"/>'
    b += f'<rect x="118" y="178" width="184" height="8" rx="2" fill="#0A705A"/>'
    b += f'<rect x="122" y="186" width="176" height="5" fill="url(#gold)"/>'
    # Fasad pishtaq tengah
    b += f'<rect x="154" y="172" width="112" height="{G - 172}" fill="#FFFDF8" stroke="#E4D6B8" stroke-width="1.5"/>'
    b += f'<rect x="150" y="168" width="120" height="7" rx="2" fill="url(#gold)"/>'
    # Relung mihrab utama berlapis
    b += f'<path d="{arch_path(168, 212, 84, 108)}" fill="#E7D9BC" stroke="url(#gold)" stroke-width="3"/>'
    b += f'<path d="{arch_path(176, 224, 68, 96)}" fill="url(#window)"/>'
    b += f'<path d="{arch_path(188, 244, 44, 76)}" fill="#FFF8D2" opacity=".75"/>'
    # Jendela mengapit pishtaq
    for ax in (130, 274):
        b += f'<path d="{arch_path(ax, 246, 16, 62)}" fill="url(#window)"/>'
    # Undakan tangga
    b += f'<rect x="146" y="{G - 10}" width="128" height="5" rx="2" fill="#EFE6D0"/>'
    b += f'<rect x="134" y="{G - 5}" width="152" height="5" rx="2" fill="#DFD2B5"/>'
    return g(b, x, y, scale)


def palm(x, ground, h=200, flip=False, s=1.0):
    """Palem organik dengan pelepah melengkung halus (tanpa garis sisir kaku)."""
    sx = -1 if flip else 1
    tx, ty = 28 * sx, -h
    trunk = (
        f'<path d="M-8 0 Q{10 * sx} {-h * .5:.1f} {tx - 4.5:.1f} {ty:.1f} L{tx + 4.5:.1f} {ty:.1f} '
        f'Q{18 * sx} {-h * .5:.1f} 8 0 Z" fill="url(#trunk)"/>'
    )
    rings = ''
    for i in range(1, 11):
        t = i / 11
        cx = (1 - t) ** 2 * 0 + 2 * (1 - t) * t * (14 * sx) + t * t * tx
        rings += f'<path d="M{cx - 6:.1f} {-h * t:.1f} q6 -4 12 0" stroke="#4D331B" stroke-width="1.4" fill="none" opacity=".45"/>'

    def frond(ang, L, droop, col, wdt):
        a = math.radians(ang)
        ex, ey = tx + math.cos(a) * L, ty + math.sin(a) * L * .45 + droop
        cx1, cy1 = tx + math.cos(a) * L * .48, ty - abs(math.cos(a)) * L * .26 - 8
        nx, ny = -math.sin(a) * wdt, math.cos(a) * wdt * .55
        out = (
            f'<path d="M{tx:.1f} {ty:.1f} Q{cx1 - nx:.1f} {cy1 - ny - wdt * .85:.1f} {ex:.1f} {ey:.1f} '
            f'Q{cx1 + nx * .45:.1f} {cy1 + ny * .35:.1f} {tx:.1f} {ty + 3:.1f} Z" fill="{col}"/>'
        )
        out += f'<path d="M{tx:.1f} {ty:.1f} Q{cx1:.1f} {cy1 - 2:.1f} {ex:.1f} {ey:.1f}" stroke="#8BD174" stroke-width="1.3" fill="none" opacity=".55"/>'
        return out

    back = ''.join(frond(a, 118, 46, '#23633B', 26) for a in (-174, -144, -108, -60, -28, -4, 168))
    front = ''.join(frond(a, 108, 40, 'url(#leaf)', 28) for a in (-160, -128, -94, -72, -42, -14, 192))
    return g(trunk + rings + back + front, x, ground, s)


def round_tree(x, ground, r=60, s=1.0):
    """Pohon rimbun bergaya ilustrasi buku (kanopi berlapis organik & cabang pohon)."""
    b = (
        f'<path d="M-8 0 Q-5 {-r * .45:.1f} -4 {-r * .95:.1f} L4 {-r * .95:.1f} Q5 {-r * .45:.1f} 8 0 Z" fill="url(#trunk)"/>'
        f'<path d="M-2 {-r * .65:.1f} L{-r * .38:.1f} {-r * 1.05:.1f} M2 {-r * .72:.1f} L{r * .36:.1f} {-r * 1.08:.1f}" '
        f'stroke="url(#trunk)" stroke-width="6" stroke-linecap="round"/>'
    )
    # Kanopi belakang
    b += (
        f'<path d="M{-r * .88:.1f} {-r * .92:.1f} '
        f'C{-r * 1.05:.1f} {-r * 1.28:.1f} {-r * .72:.1f} {-r * 1.68:.1f} {-r * .32:.1f} {-r * 1.65:.1f} '
        f'C{-r * .15:.1f} {-r * 1.98:.1f} {r * .25:.1f} {-r * 1.98:.1f} {r * .38:.1f} {-r * 1.62:.1f} '
        f'C{r * .78:.1f} {-r * 1.65:.1f} {r * 1.05:.1f} {-r * 1.25:.1f} {r * .85:.1f} {-r * .9:.1f} '
        f'C{r * .65:.1f} {-r * .68:.1f} {-r * .65:.1f} {-r * .68:.1f} {-r * .88:.1f} {-r * .92:.1f} Z" fill="url(#treeBack)"/>'
    )
    # Kanopi utama & sorot cahaya atas
    b += (
        f'<path d="M{-r * .78:.1f} {-r * 1.02:.1f} '
        f'C{-r * .92:.1f} {-r * 1.35:.1f} {-r * .58:.1f} {-r * 1.72:.1f} {-r * .22:.1f} {-r * 1.68:.1f} '
        f'C{-r * .08:.1f} {-r * 1.96:.1f} {r * .22:.1f} {-r * 1.94:.1f} {r * .34:.1f} {-r * 1.64:.1f} '
        f'C{r * .72:.1f} {-r * 1.64:.1f} {r * .92:.1f} {-r * 1.3:.1f} {r * .74:.1f} {-r * .98:.1f} '
        f'C{r * .45:.1f} {-r * .78:.1f} {-r * .45:.1f} {-r * .78:.1f} {-r * .78:.1f} {-r * 1.02:.1f} Z" fill="url(#tree)"/>'
    )
    b += (
        f'<ellipse cx="{-r * .18:.1f}" cy="{-r * 1.62:.1f}" rx="{r * .28:.1f}" ry="{r * .16:.1f}" '
        f'fill="#C7EA85" opacity=".42"/>'
    )
    return g(b, x, ground, s)


def bush(x, ground, w=90, s=1.0):
    """Semak organik menyatu dengan tanah (bukan deretan bola terpisah)."""
    hw = w * 0.55
    h = w * 0.36
    b = (
        f'<path d="M{-hw:.1f} 0 '
        f'C{-hw * 1.05:.1f} {-h * .55:.1f} {-hw * .72:.1f} {-h * .92:.1f} {-hw * .36:.1f} {-h * .82:.1f} '
        f'C{-hw * .2:.1f} {-h * 1.18:.1f} {hw * .22:.1f} {-h * 1.18:.1f} {hw * .38:.1f} {-h * .8:.1f} '
        f'C{hw * .74:.1f} {-h * .9:.1f} {hw * 1.05:.1f} {-h * .52:.1f} {hw:.1f} 0 Z" fill="url(#tree)"/>'
        f'<path d="M{-hw * .55:.1f} {-h * .12:.1f} '
        f'C{-hw * .45:.1f} {-h * .72:.1f} {hw * .15:.1f} {-h * .95:.1f} {hw * .48:.1f} {-h * .22:.1f} Z" '
        f'fill="#B8E47A" opacity=".32"/>'
    )
    return g(b, x, ground, s)


def cloud(x, y, s=1.0, o=.88):
    b = (
        '<path d="M-58 10 H58 C70 10 78 2 78 -8 C78 -18 70 -25 59 -26 '
        'C54 -42 38 -52 20 -50 C10 -62 -10 -64 -24 -52 '
        'C-38 -54 -52 -42 -54 -26 C-66 -25 -74 -16 -74 -5 C-74 4 -67 10 -58 10 Z" fill="#FFFFFF"/>'
    )
    return g(b, x, y, s, f'opacity="{o}"')


def quran_rehal(x, y, s=1.0):
    """Al-Qur'an terbuka di atas rehal kayu ukir + cahaya hangat & bintang Rub el Hizb."""
    b = ''
    # Pancaran cahaya hangat di belakang mushaf
    b += '<circle cx="0" cy="-108" r="118" fill="url(#halo)"/>'
    # Bintang delapan Rub el Hizb di atas mushaf
    b += (
        '<g transform="translate(0 -168)">'
        '<rect x="-18" y="-18" width="36" height="36" fill="none" stroke="url(#gold)" stroke-width="3"/>'
        '<rect x="-18" y="-18" width="36" height="36" transform="rotate(45)" fill="none" stroke="url(#gold)" stroke-width="3"/>'
        '<circle cx="0" cy="0" r="6" fill="url(#gold)"/>'
        '</g>'
    )
    # Pelataran oval gading berbingkai emas & rehal kayu ukir (bentuk X berlekuk)
    b += '<ellipse cx="0" cy="6" rx="146" ry="20" fill="#FAF2DC" stroke="url(#gold)" stroke-width="2.5"/>'
    b += '<path d="M-112 10 L-96 -28 L12 -74 L26 -54 L-58 10 L-76 -2 L-92 10 Z" fill="url(#wood)" stroke="#5A3310" stroke-width="1.2" stroke-linejoin="round"/>'
    b += '<path d="M112 10 L96 -28 L-12 -74 L-26 -54 L58 10 L76 -2 L92 10 Z" fill="url(#wood)" stroke="#5A3310" stroke-width="1.2" stroke-linejoin="round"/>'
    b += '<path d="M-142 -38 L0 -86 L142 -38 L132 -24 L0 -70 L-132 -24 Z" fill="#6E411B"/>'
    # Sampul zamrud berbingkai emas
    b += '<path d="M-168 -52 Q-88 -90 0 -76 Q88 -90 168 -52 L160 -38 Q88 -74 0 -62 Q-88 -74 -160 -38 Z" fill="url(#emerald)" stroke="url(#gold)" stroke-width="2"/>'
    # Ketebalan blok halaman
    b += '<path d="M-162 -56 Q-86 -98 -2 -76 L-2 -64 Q-86 -84 -156 -44 Z" fill="#E2CFA3"/>'
    b += '<path d="M162 -56 Q86 -98 2 -76 L2 -64 Q86 -84 156 -44 Z" fill="#E2CFA3"/>'
    # Halaman kiri & kanan terbuka
    b += '<path d="M-162 -56 Q-86 -142 -2 -112 L-2 -74 Q-86 -102 -162 -56 Z" fill="url(#page)" stroke="url(#gold)" stroke-width="2.2"/>'
    b += '<path d="M162 -56 Q86 -142 2 -112 L2 -74 Q86 -102 162 -56 Z" fill="url(#pageR)" stroke="url(#gold)" stroke-width="2.2"/>'
    # Bingkai dalam & baris ayat
    for i in range(5):
        yy = -118 + i * 8
        b += f'<path d="M{-134 + i * 3} {yy + 32 - i * 1.8:.1f} Q-78 {yy - 6:.1f} -22 {yy + 10:.1f}" stroke="#BDA776" stroke-width="2" fill="none" opacity=".6"/>'
        b += f'<path d="M{134 - i * 3} {yy + 32 - i * 1.8:.1f} Q78 {yy - 6:.1f} 22 {yy + 10:.1f}" stroke="#BDA776" stroke-width="2" fill="none" opacity=".6"/>'
    b += '<path d="M-2 -112 L-2 -72 L2 -72 L2 -112 Z" fill="url(#gold)"/>'
    return g(b, x, y, s, 'filter="url(#shadow)"')


def kaaba(x, y, s=1.0):
    """Ka'bah isometrik di atas pelataran marmer putih dengan sabuk emas Hizam & pintu Bab al-Ka'bah."""
    b = '<ellipse cx="0" cy="-10" rx="126" ry="38" fill="#FFFDF7" stroke="url(#gold)" stroke-width="3"/>'
    b += '<ellipse cx="0" cy="-10" rx="104" ry="29" fill="none" stroke="#087E65" stroke-width="1.5" opacity=".35"/>'
    # Dinding Kiswah
    b += '<path d="M-86 -20 L0 18 L0 -132 L-86 -170 Z" fill="#181B1A"/>'
    b += '<path d="M0 18 L86 -20 L86 -170 L0 -132 Z" fill="#272B2A"/>'
    b += '<path d="M-86 -170 L0 -208 L86 -170 L0 -132 Z" fill="#353A38"/>'
    # Sabuk emas Hizam
    b += '<path d="M-86 -140 L0 -102 L86 -140 L86 -122 L0 -84 L-86 -122 Z" fill="url(#gold)"/>'
    for i in range(5):
        b += f'<path d="M{-76 + i * 15} {-131 + i * 6.5:.1f} l8 3.5" stroke="#6E4F0B" stroke-width="2.4" stroke-linecap="round"/>'
        b += f'<path d="M{10 + i * 15} {-99 - i * 6.5:.1f} l8 -3.5" stroke="#6E4F0B" stroke-width="2.4" stroke-linecap="round"/>'
    # Pintu emas Bab al-Ka'bah
    b += '<path d="M26 -36 L56 -49 L56 -108 L26 -95 Z" fill="url(#gold)"/>'
    b += '<path d="M31 -43 L51 -52 L51 -100 L31 -91 Z" fill="#8C6816"/>'
    b += '<circle cx="38" cy="-70" r="2.2" fill="#FCE69E"/><circle cx="44" cy="-73" r="2.2" fill="#FCE69E"/>'
    return g(b, x, y, s, 'filter="url(#shadow)"')


def mosque_silhouette(x, ground, s=1.0, fill=DARK, opacity=1.0, minarets=True):
    b = ''
    if minarets:
        for mx in (24, 296):
            b += f'<rect x="{mx - 8}" y="44" width="16" height="196" />'
            b += f'<path d="M{mx - 10} 46 C{mx - 10} 26 {mx} 14 {mx} 8 C{mx} 14 {mx + 10} 26 {mx + 10} 46 Z"/>'
            b += f'<rect x="{mx - 1}" y="0" width="2" height="12"/>'
            b += f'<rect x="{mx - 13}" y="96" width="26" height="6" rx="2"/>'
    b += '<rect x="64" y="148" width="192" height="92"/>'
    b += '<path d="M102 150 C96 92 138 68 160 40 C182 68 224 92 218 150 Z"/><rect x="159" y="12" width="2.4" height="28"/>'
    b += '<path d="M62 168 C60 138 80 126 92 114 C104 126 124 138 122 168 Z"/>'
    b += '<path d="M198 168 C196 138 216 126 228 114 C240 126 260 138 258 168 Z"/>'
    return g(f'<g fill="{fill}" opacity="{opacity}">{b}</g>', x, ground - 240 * s, s)


def onion_arch_clip(cid, x, y, w, h):
    """Jendela berbentuk lengkung mihrab (onion arch) untuk bingkai adegan."""
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
        f'<path d="M0 {y + 18} Q{cx * .5:.1f} {y - 10} {cx:.1f} {y} Q{cx * 1.5:.1f} {y + 10} {w} {y - 6} L{w} {y + h} L0 {y + h} Z" fill="url(#grass)"/>'
        f'<path d="M{cx - 65:.1f} {y + 2:.1f} L{cx + 65:.1f} {y + 2:.1f} L{cx + 125:.1f} {y + h:.1f} L{cx - 125:.1f} {y + h:.1f} Z" fill="#F3E8CB" opacity=".85"/>'
    )


def write(name, content):
    with open(os.path.join(OUT, f'{name}.svg'), 'w', encoding='utf-8') as f:
        f.write(content)


# ── Adegan ──────────────────────────────────────────────────────────────

def scene_hero_quran():
    """Daftar Surah & Doa Harian: masjid berkubah zamrud dalam bingkai mihrab emas, Al-Qur'an di rehal di depan."""
    W, H = 800, 720
    clip, d = onion_arch_clip('heroArch', 90, 24, 620, 590)
    inner = '<rect width="800" height="720" fill="url(#sky)"/>'
    inner += '<circle cx="400" cy="270" r="230" fill="url(#sunDisk)"/>'
    inner += cloud(210, 165, 1.15) + cloud(590, 140, 1.0)
    inner += mosque(1.18, 152, 134, minarets=True)
    inner += ground_band(800, 505, 215)
    body = f'<defs>{clip}</defs><g clip-path="url(#heroArch)">{inner}</g>'
    body += f'<path d="{d}" fill="none" stroke="url(#gold)" stroke-width="8"/>'
    body += round_tree(135, 565, 76) + round_tree(665, 565, 76)
    body += bush(175, 610, 160) + bush(625, 610, 160)
    body += '<ellipse cx="400" cy="656" rx="280" ry="30" fill="#164A37" opacity=".16" filter="url(#soft)"/>'
    body += quran_rehal(400, 676, 1.25)
    write('hero_quran', svg(W, H, body))


def scene_mosque_circle():
    """Pilih Peran / landing Mosque: masjid berkubah zamrud di medali langit pagi dengan pepohonan."""
    W, H = 800, 640
    inner = '<rect width="800" height="640" fill="url(#sky)"/>'
    inner += '<circle cx="400" cy="280" r="240" fill="url(#sunDisk)"/>'
    inner += cloud(230, 155, 1.05) + cloud(575, 130, .92)
    inner += mosque(1.24, 140, 126)
    inner += ground_band(800, 515, 140)
    body = f'<defs><clipPath id="circ"><circle cx="400" cy="320" r="296"/></clipPath></defs><g clip-path="url(#circ)">{inner}</g>'
    body += '<circle cx="400" cy="320" r="296" fill="none" stroke="url(#gold)" stroke-width="7"/>'
    body += round_tree(118, 566, 86) + round_tree(682, 566, 86)
    body += bush(185, 608, 175) + bush(615, 608, 175)
    body += '<path d="M55 602 Q400 644 745 602 L745 636 L55 636 Z" fill="url(#grass)"/>'
    write('mosque_circle', svg(W, H, body))


def scene_mosque_banner():
    """Banner hijau Moeslim Mosque: masjid krem berkubah zamrud & emas + palem, latar transparan."""
    W, H = 900, 560
    body = '<ellipse cx="470" cy="522" rx="410" ry="36" fill="#052921" opacity=".38" filter="url(#soft)"/>'
    body += '<circle cx="470" cy="280" r="220" fill="url(#sunDisk)" opacity=".65"/>'
    body += palm(135, 520, 290, False, 1.02) + palm(815, 520, 265, True, 1.02)
    body += mosque(1.42, 172, 64)
    body += bush(245, 534, 165) + bush(695, 534, 175) + bush(470, 540, 135)
    write('mosque_banner', svg(W, H, body))


def scene_skyline():
    """Siluet masjid untuk sapaan Beranda (latar transparan) dengan aksen bulan sabit emas."""
    W, H = 900, 320
    c = '#26A884'
    body = mosque_silhouette(375, 320, 1.06, c, .78)
    body += mosque_silhouette(135, 320, .72, c, .52)
    body += mosque_silhouette(685, 320, .64, c, .52)
    body += crescent(790, 74, 24)
    write('skyline', svg(W, H, body))


def scene_kaaba():
    W, H = 400, 400
    body = '<ellipse cx="200" cy="336" rx="152" ry="28" fill="#05261E" opacity=".18" filter="url(#soft)"/>' + kaaba(200, 318, 1.15)
    write('kaaba', svg(W, H, body))


def scene_login_shield():
    """Login Admin: siluet masjid zamrud lembut, perisai zamrud berbingkai emas dengan gembok."""
    W, H = 900, 560
    body = '<circle cx="450" cy="250" r="220" fill="url(#sunDisk)" opacity=".55"/>'
    body += mosque_silhouette(115, 432, .76, '#6CBF9E', .85) + mosque_silhouette(555, 432, .76, '#6CBF9E', .85)
    body += mosque_silhouette(335, 432, .56, '#9ED4BD', .9, minarets=False)
    body += '<path d="M90 432 Q450 398 810 432 L810 452 L90 452 Z" fill="#C4E8D7"/>'
    body += '<path d="M230 452 L670 452 L740 520 L160 520 Z" fill="#0B5E4C"/>'
    body += '<path d="M160 520 L740 520 L736 532 L164 532 Z" fill="#07372F"/>'
    body += ''.join(f'<rect x="{262 + c * 34 - r * 8}" y="{462 + r * 16}" width="26" height="10" rx="2" fill="#19A583" opacity=".55"/>' for r in range(3) for c in range(12 + r))
    body += '<rect x="400" y="508" width="100" height="8" rx="3" fill="url(#gold)" opacity=".85"/>'
    shield = 'M450 68 C520 108 580 110 620 108 C626 260 580 380 450 440 C320 380 274 260 280 108 C320 110 380 108 450 68 Z'
    body += f'<path d="{shield}" fill="url(#gold)" filter="url(#shadow)"/>'
    body += '<path d="M450 90 C512 124 562 128 598 128 C600 262 562 362 450 416 C338 362 300 262 302 128 C338 128 388 124 450 90 Z" fill="url(#emerald)"/>'
    body += '<path d="M450 90 C512 124 562 128 598 128 C600 180 594 222 580 260 C540 200 470 150 450 90 Z" fill="#fff" opacity=".1"/>'
    body += '<path d="M412 248 L412 214 A38 38 0 0 1 488 214 L488 248" fill="none" stroke="url(#gold)" stroke-width="16" stroke-linecap="round"/>'
    body += '<rect x="386" y="244" width="128" height="102" rx="18" fill="#FFFDF7" stroke="url(#gold)" stroke-width="3"/>'
    body += '<circle cx="450" cy="286" r="13" fill="#087E65"/><rect x="444" y="290" width="12" height="28" rx="5" fill="#087E65"/>'
    write('login_shield', svg(W, H, body))


def scene_tv():
    """Pemandangan masjid megah untuk panel kanan Layar Utama TV."""
    W, H = 1300, 1000
    body = '<rect width="1300" height="1000" fill="url(#sky)"/>'
    body += '<circle cx="650" cy="390" r="370" fill="url(#sunDisk)"/>'
    body += cloud(210, 155, 1.35) + cloud(650, 105, 1.05) + cloud(1090, 175, 1.25)
    body += mosque(1.98, 234, 164)
    body += '<rect x="0" y="792" width="1300" height="208" fill="url(#grass)"/>'
    body += '<path d="M0 864 Q650 824 1300 864 L1300 1000 L0 1000 Z" fill="#EAE1C8"/>'
    body += '<path d="M555 1000 L615 856 L685 856 L745 1000 Z" fill="#F7F1E1"/>'
    for i, px in enumerate((55, 165, 1135, 1245)):
        body += palm(px, 858, 360 + (i % 2) * 55, px > 650, 1.1)
    for bx in (130, 325, 495, 805, 975, 1170):
        body += bush(bx, 864, 195)
    write('tv_mosque', svg(W, H, body))


def scene_arch_header():
    """Kepala halaman berornamen (Jadwal Salat, Detail Doa, Mushaf): lengkung mihrab ganda & siluet masjid emas."""
    W, H = 1000, 420
    _, d = onion_arch_clip('a', 56, 36, 888, 524)
    _, d2 = onion_arch_clip('a2', 70, 50, 860, 510)
    body = '<rect width="1000" height="420" fill="url(#lattice)" opacity=".65"/>'
    body += f'<path d="{d}" fill="#FFFDF6"/>'
    body += f'<path d="{d}" fill="none" stroke="url(#gold)" stroke-width="5"/>'
    body += f'<path d="{d2}" fill="none" stroke="#087E65" stroke-width="1.6" opacity=".35"/>'
    body += mosque_silhouette(74, 420, .54, GOLD, .24) + mosque_silhouette(756, 420, .54, GOLD, .24)
    write('arch_header', svg(W, H, body))


def scene_tasbih_side():
    """Dekorasi sisi cincin tasbih: menara masjid & pepohonan lembut (transparan)."""
    W, H = 900, 500
    body = '<g opacity=".55">'
    body += minaret(88, 124, 470, 26) + round_tree(58, 480, 56) + bush(145, 486, 115)
    body += minaret(812, 124, 470, 26) + round_tree(842, 480, 56) + bush(755, 486, 115)
    body += '</g>'
    write('tasbih_side', svg(W, H, body))


def scene_corner():
    """Ornamen sudut kisi hijau & pita emas (latar halaman)."""
    W, H = 420, 420
    body = (
        '<defs><radialGradient id="fade" cx="0" cy="0" r="1"><stop offset="0" stop-color="#fff"/>'
        '<stop offset=".75" stop-color="#fff" stop-opacity=".25"/><stop offset="1" stop-color="#fff" stop-opacity="0"/></radialGradient>'
        '<mask id="m"><rect width="420" height="420" fill="url(#fade)"/></mask></defs>'
        '<rect width="420" height="420" fill="url(#lattice)" mask="url(#m)"/>'
        '<path d="M0 300 Q120 280 180 180 Q240 80 330 0" fill="none" stroke="url(#gold)" stroke-width="5" opacity=".82"/>'
    )
    write('corner_lattice', svg(W, H, body))


def scene_qari():
    """Lencana qari (tanpa wajah): medali zamrud-emas, Al-Qur'an di rehal ukir & gelombang tilawah."""
    W, H = 400, 400
    body = '<circle cx="200" cy="200" r="192" fill="url(#gold)"/><circle cx="200" cy="200" r="176" fill="url(#emerald)"/>'
    body += '<circle cx="200" cy="200" r="164" fill="none" stroke="url(#gold)" stroke-width="2" opacity=".45"/>'
    body += mosque_silhouette(72, 304, .8, '#053A2F', .65)
    body += quran_rehal(200, 326, .74)
    for i, r in enumerate((56, 86, 116)):
        body += f'<path d="M{200 - r} 142 A{r} {r} 0 0 1 {200 + r} 142" fill="none" stroke="#FCE69E" stroke-width="6" stroke-linecap="round" opacity="{.92 - i * .24:.2f}"/>'
    write('qari_badge', svg(W, H, body))


def scene_calibrate():
    W, H = 360, 300
    body = '<path d="M56 150 C56 58 170 58 180 150 C190 242 304 242 304 150 C304 58 190 58 180 150 C170 242 56 242 56 150 Z" fill="none" stroke="url(#gold)" stroke-width="5.5" stroke-dasharray="12 9" stroke-linecap="round"/>'
    body += '<g transform="rotate(-18 180 150)" filter="url(#shadow)"><rect x="140" y="68" width="80" height="154" rx="16" fill="#FFFDF8" stroke="#087E65" stroke-width="5.5"/>'
    body += '<rect x="151" y="86" width="58" height="108" rx="6" fill="#E6F5EC"/><circle cx="180" cy="140" r="18" fill="none" stroke="#D9AB36" stroke-width="3"/><path d="M180 126L186 144L180 139L174 144Z" fill="#087E65"/><circle cx="180" cy="207" r="4.5" fill="#087E65"/></g>'
    body += '<path d="M292 108 l16 -14 l4 20 Z" fill="url(#gold)"/>'
    write('calibrate', svg(W, H, body))


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for f in [
        scene_hero_quran, scene_mosque_circle, scene_mosque_banner, scene_skyline, scene_kaaba,
        scene_login_shield, scene_tv, scene_arch_header, scene_tasbih_side, scene_corner, scene_qari, scene_calibrate,
    ]:
        f()
    print('ok', len(os.listdir(OUT)))
