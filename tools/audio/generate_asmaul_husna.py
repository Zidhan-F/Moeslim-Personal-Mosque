import asyncio
import pathlib
import re
import sys

import edge_tts
from mutagen.mp3 import MP3

ROOT = pathlib.Path(__file__).resolve().parents[2]
CATALOG = ROOT / "packages" / "personal_core" / "lib" / "src" / "content" / "asmaul_husna.dart"
OUT_DIR = ROOT / "apps" / "mobile" / "assets" / "audio" / "asmaul_husna"

VOICE = "ar-SA-HamedNeural"
RATE = "-15%"
CONCURRENCY = 5


def parse_catalog() -> list[tuple[int, str, str]]:
    text = CATALOG.read_text(encoding="utf-8")
    pattern = re.compile(r"AsmaulHusnaItem\(\s*(\d+)\s*,\s*'([^']+)'\s*,\s*'((?:\\'|[^'])+)'")
    items: list[tuple[int, str, str]] = []
    for m in pattern.finditer(text):
        num = int(m.group(1))
        arabic = m.group(2)
        latin = m.group(3).replace("\\'", "'")
        items.append((num, arabic, latin))
    items.sort(key=lambda x: x[0])
    if len(items) != 99 or [x[0] for x in items] != list(range(1, 100)):
        raise RuntimeError(f"Expected 99 ordered items, parsed {len(items)}")
    return items


def normalize_for_tts(arabic: str) -> str:
    # Normalize Quranic dagger alif (U+0670) so neural Arabic TTS reads Ar-Rahman cleanly.
    return arabic.replace("\u0670", "")


async def synth_one(sem: asyncio.Semaphore, num: int, arabic: str, latin: str) -> tuple[int, int, float]:
    out_file = OUT_DIR / f"{num:02d}.mp3"
    tts_text = normalize_for_tts(arabic)
    async with sem:
        for attempt in range(1, 4):
            try:
                comm = edge_tts.Communicate(tts_text, voice=VOICE, rate=RATE)
                await comm.save(str(out_file))
                info = MP3(str(out_file)).info
                size = out_file.stat().st_size
                if size < 1500 or info.length < 0.4:
                    raise RuntimeError(f"Suspicious MP3 for #{num}: {size}B, {info.length:.2f}s")
                return num, size, info.length
            except Exception as exc:
                if attempt == 3:
                    raise RuntimeError(f"Failed #{num} ({latin}): {exc}") from exc
                await asyncio.sleep(1.5 * attempt)
    raise AssertionError("unreachable")


async def main() -> None:
    items = parse_catalog()
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    sem = asyncio.Semaphore(CONCURRENCY)
    results = await asyncio.gather(*(synth_one(sem, n, a, l) for n, a, l in items))
    total_bytes = sum(r[1] for r in results)
    total_secs = sum(r[2] for r in results)
    min_dur = min(r[2] for r in results)
    max_dur = max(r[2] for r in results)
    print(
        f"Generated {len(results)} MP3 files in {OUT_DIR}\n"
        f"Total size: {total_bytes / 1024:.1f} KB ({total_bytes / (1024 * 1024):.2f} MB)\n"
        f"Total duration: {total_secs:.1f}s (min {min_dur:.2f}s, max {max_dur:.2f}s)"
    )


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        sys.exit(130)
