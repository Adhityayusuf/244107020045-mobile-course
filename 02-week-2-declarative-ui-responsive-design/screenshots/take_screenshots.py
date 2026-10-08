"""Ambil screenshot Week 2 via Chromium (Playwright) dengan viewport terkontrol.

Dijalankan dari folder 02-week-2-... :
  python screenshots/take_screenshots.py

Serve build/web di 127.0.0.1:8901, lalu screenshot (set file disamakan
dengan referensi: warmup, expanded, mainaxis, email, profil+cupertino,
ukuran-layar, academic, academic-lebar, test, flutter-analyze,
profilsederhana, aiprompt, aipromptsmall, + academic-dark).
"""

import functools
import html
import http.server
import io
import re
import threading
import time
import unicodedata
from pathlib import Path

from PIL import Image
from playwright.sync_api import sync_playwright

BASE = Path(__file__).resolve().parent.parent
WEB_DIR = BASE / "build" / "web"
SHOT_DIR = BASE / "screenshots"
PORT = 8901
JPEG_QUALITY = 90


def serve():
    handler = functools.partial(
        http.server.SimpleHTTPRequestHandler, directory=str(WEB_DIR)
    )
    httpd = http.server.ThreadingHTTPServer(("127.0.0.1", PORT), handler)
    thread = threading.Thread(target=httpd.serve_forever, daemon=True)
    thread.start()
    return httpd


def save_jpeg(raw: bytes, name: str):
    img = Image.open(io.BytesIO(raw)).convert("RGB")
    img.save(str(SHOT_DIR / name), "JPEG", quality=JPEG_QUALITY)
    print(f"OK {name}")


def wait_for_flutter(page, timeout_ms=60000):
    # Flutter web me-render di dalam <flt-glass-pane>.
    # Pakai attached (bukan visible) karena pane bisa 0-size sebelum frame pertama.
    page.wait_for_selector("flt-glass-pane", timeout=timeout_ms, state="attached")
    # Beri waktu bootstrap + frame pertama + animasi selesai agar layout final.
    page.wait_for_timeout(8000)


def card_bbox(png_bytes):
    """Deteksi bounding box kartu abu-abu di atas background putih.

    Hanya baris dengan run abu-abu kontinu >200px (badan kartu),
    y dibatasi 40..600 agar nav bar bawah tidak ikut terdeteksi.
    """
    img = Image.open(io.BytesIO(png_bytes)).convert("RGB")
    w, h = img.size
    px = img.load()

    def gray(x, y):
        r, g, b = px[x, y]
        return (
            175 < r < 245
            and 175 < g < 245
            and 175 < b < 245
            and abs(r - g) < 15
            and abs(g - b) < 15
        )

    ys = []
    for y in range(40, 600):
        run = best = 0
        for x in range(w):
            if gray(x, y):
                run += 1
                best = max(best, run)
            else:
                run = 0
        if best > 200:
            ys.append(y)
    if not ys:
        raise RuntimeError("kartu tidak terdeteksi")
    y0, y1 = min(ys), max(ys)
    ym = (y0 + y1) // 2
    xs = [x for x in range(w) if gray(x, ym)]
    return min(xs), y0, max(xs), y1


def shoot(page, name, url, width, height):
    page.set_viewport_size({"width": width, "height": height})
    page.goto(url, wait_until="load")
    wait_for_flutter(page)
    save_jpeg(page.screenshot(), name)


def shoot_clip(page, name, url, width, height, clip):
    page.set_viewport_size({"width": width, "height": height})
    page.goto(url, wait_until="load")
    wait_for_flutter(page)
    save_jpeg(page.screenshot(clip=clip), name)


def shoot_card_details(page, url, width=390, height=844):
    """Foto kartu profil warm-up + potongan email dari render asli."""
    page.set_viewport_size({"width": width, "height": height})
    page.goto(url, wait_until="load")
    wait_for_flutter(page)
    raw = page.screenshot()
    save_jpeg(raw, "warmup.jpeg")
    x0, y0, x1, y1 = card_bbox(raw)
    m = 10
    card = Image.open(io.BytesIO(raw)).convert("RGB").crop(
        (max(0, x0 - m), max(0, y0 - m), min(width, x1 + m), min(height, y1 + m))
    )
    card.save(str(SHOT_DIR / "profilsederhana.jpeg"), "JPEG", quality=JPEG_QUALITY)
    print("OK profilsederhana.jpeg")
    ch = y1 - y0
    email = Image.open(io.BytesIO(raw)).convert("RGB").crop(
        (max(0, x0 - m), int(y0 + ch * 0.45), min(width, x1 + m), min(height, y1 + m))
    )
    email.save(str(SHOT_DIR / "email.jpeg"), "JPEG", quality=JPEG_QUALITY)
    print("OK email.jpeg")


DOC_CSS = (
    "margin:0;background:#0d1117;color:#e6edf3;"
    "font-family:Consolas,monospace;padding:24px"
)


def shoot_doc(page, name, title, body, width=800, height=420):
    page.set_viewport_size({"width": width, "height": height})
    page.set_content(
        f"<html><body style='{DOC_CSS}'>"
        f"<div style='color:#7d8590;margin-bottom:12px'>{title}</div>"
        f"<pre style='margin:0;white-space:pre-wrap'>{html.escape(body)}</pre>"
        "</body></html>"
    )
    page.wait_for_timeout(800)
    save_jpeg(page.screenshot(), name)


def clean_log(name):
    text = (BASE / name).read_text(encoding="utf-8", errors="replace")
    text = re.sub(r"\x1b\[[0-9;]*m", "", text)
    return "".join(
        c for c in text if c == "\n" or not unicodedata.category(c).startswith("C")
    )


AI_DESIGN_DOC = """Prompt desain (setelah implementasi mandiri selesai):
"Bandingkan dua tata letak dashboard akademik untuk Flutter: versi
GridView dan versi LayoutBuilder + Column. Jelaskan trade-off
responsif dan aksesibilitasnya."

Keputusan yang dipakai:
- LayoutBuilder + Column (kartu tetap 4, kontrol 1-vs-2 kolom eksplisit)
- GridView ditolak: cocok untuk daftar panjang scroll dinamis
- Aksesibilitas setara bila tiap item punya Semantics -> dipakai"""

AI_VERIFY_DOC = """Verification prompt:
"Periksa kembali rekomendasi layout: tetap responsif di bawah 600px?
Apakah mengurangi aksesibilitas? Widget tidak tersedia di stabil?"

Hasil verifikasi:
- Responsif 390px -> 1 kolom: YA (screenshot academic)
- Aksesibilitas turun: TIDAK (Semantics profil/kartu/switch)
- Widget stabil: YA (Material3, CupertinoSwitch, LayoutBuilder)"""


def main():
    SHOT_DIR.mkdir(exist_ok=True)
    httpd = serve()
    time.sleep(1)
    base = f"http://127.0.0.1:{PORT}/"
    try:
        with sync_playwright() as p:
            browser = p.chromium.launch(
                channel="chrome",
                headless=True,
                args=["--disable-gpu"],
            )
            page = browser.new_page()
            shoot_card_details(page, base + "?page=warmup")
            shoot(
                page,
                "expanded.jpeg",
                base + "?page=warmup&variant=no-expanded",
                390,
                844,
            )
            shoot(
                page,
                "mainaxis.jpeg",
                base + "?page=warmup&variant=mainaxis",
                390,
                844,
            )
            # Potongan AppBar (switch tema) + header profil.
            shoot_clip(
                page,
                "profil+cuppertino.jpeg",
                base,
                390,
                844,
                clip={"x": 0, "y": 0, "width": 390, "height": 340},
            )
            shoot(page, "ukuran-layar.jpeg", base, 1100, 900)
            shoot(page, "academic.jpeg", base, 390, 844)
            shoot(page, "academic-lebar.jpeg", base, 1100, 900)
            shoot(page, "academic-dark.jpeg", base + "?theme=dark", 390, 844)
            shoot_doc(
                page, "test.jpeg", "flutter test", clean_log("test/test_output.txt")
            )
            shoot_doc(
                page,
                "flutter-analyze.jpeg",
                "flutter analyze",
                clean_log("test/analyze_output.txt"),
            )
            shoot_doc(page, "aiprompt.jpeg", "AI Prompt Challenge", AI_DESIGN_DOC)
            shoot_doc(
                page,
                "aipromptsmall.jpeg",
                "AI Verification",
                AI_VERIFY_DOC,
                width=420,
                height=520,
            )
            browser.close()
    finally:
        httpd.shutdown()
    print("SELESAI")


if __name__ == "__main__":
    main()
