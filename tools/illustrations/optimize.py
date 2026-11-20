"""Ubah PNG hasil render menjadi WebP (kualitas 90, alfa dipertahankan) agar ukuran aplikasi tetap kecil."""
import glob
import os

from PIL import Image

DIR = os.path.join(os.path.dirname(__file__), '../../packages/moeslim_brand/assets/illustrations')
for f in sorted(glob.glob(os.path.join(DIR, '*.png'))):
    out = f[:-4] + '.webp'
    Image.open(f).save(out, 'WEBP', quality=90, method=6)
    os.remove(f)
    print(os.path.basename(out), os.path.getsize(out) // 1024, 'KB')
