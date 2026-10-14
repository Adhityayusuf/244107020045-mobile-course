"""Pemeriksaan otomatis portofolio: dipakai CI untuk menolak PR kotor.

Memverifikasi, per folder minggu 01-08:
1. README.md ada dan memuat section wajib.
2. Setiap gambar `screenshots/*` yang dirujuk README benar-benar ada.
3. docs/ai-challenge.md ada untuk minggu yang mewajibkan (03-08).

Keluar kode 1 bila ada pelanggaran (CI merah).
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
WEEKS = sorted(p for p in ROOT.iterdir() if p.is_dir() and re.match(r"^\d{2}-", p.name))
AI_WEEKS = {"03", "04", "05", "06", "07", "08"}
REQUIRED_SECTIONS = ["Menjalankan", "## Refleksi"]
IMAGE_EXTS = (".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg")

errors: list[str] = []


def check_week(week: Path) -> None:
    prefix = week.name[:2]
    readme = week / "README.md"
    if not readme.is_file():
        errors.append(f"{week.name}: README.md hilang")
        return
    text = readme.read_text(encoding="utf-8", errors="replace")
    for section in REQUIRED_SECTIONS:
        if section not in text:
            errors.append(f"{week.name}: section '{section}' hilang di README")
    shots = week / "screenshots"
    for ref in re.findall(r"screenshots/([^\s)\"'<>`]+)", text):
        if not ref.lower().endswith(IMAGE_EXTS):
            continue
        if not (shots / ref).is_file():
            errors.append(f"{week.name}: gambar '{ref}' dirujuk tapi tidak ada")
    if prefix in AI_WEEKS and not (week / "docs" / "ai-challenge.md").is_file():
        # Week 8 memakai ai-review-vs-keputusan.md sebagai pengganti.
        if prefix != "08" or not (week / "docs" / "ai-review-vs-keputusan.md").is_file():
            errors.append(f"{week.name}: docs AI hilang")


def main() -> int:
    if not WEEKS:
        print("tidak ada folder minggu ditemukan")
        return 1
    checked = [w for w in WEEKS if w.name[:2] in {"01", "02", "03", "04", "05", "06", "07", "08"}]
    for week in checked:
        check_week(week)
    if errors:
        print(f"{len(errors)} pelanggaran ditemukan:")
        for error in errors:
            print(f"  - {error}")
        return 1
    print(f"OK: {len(checked)} folder minggu lolos pemeriksaan")
    return 0


if __name__ == "__main__":
    sys.exit(main())
