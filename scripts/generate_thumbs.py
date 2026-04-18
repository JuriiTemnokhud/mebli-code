#!/usr/bin/env python3
"""
Генератор прев'юш для папки "Кухні".
Створює WebP прев'ю у підпапці `thumbs` та оновлює `kukhnia-gallery.html`, щоб використовувати прев'ю з атрибутом data-full для повного зображення.

Використання:
    py scripts\generate_thumbs.py

Якщо Pillow не встановлено: `py -m pip install pillow`
"""
import sys
from pathlib import Path

try:
    from PIL import Image
except Exception as e:
    print('Pillow не знайдений. Встановіть його: py -m pip install pillow')
    raise

ROOT = Path(__file__).resolve().parents[1]
KUHNI = ROOT / 'images' / 'My Work' / 'Кухні'
THUMBS = KUHNI / 'thumbs'
GALLERY = ROOT / 'kukhnia-gallery.html'

if not KUHNI.exists():
    print('Папка не знайдена:', KUHNI)
    sys.exit(1)

THUMBS.mkdir(parents=True, exist_ok=True)

IMG_EXTS = {'.jpg', '.jpeg', '.png', '.webp'}

def make_thumb(src_path: Path, max_size=400):
    """Create thumbnail WebP."""
    dest_webp = THUMBS / (src_path.stem + '.webp')
    try:
        with Image.open(src_path) as im:
            im.convert('RGB')
            im.thumbnail((max_size, max_size), Image.LANCZOS)
            im.save(dest_webp, 'WEBP', quality=82, method=6)
        print('Thumb created:', dest_webp.name)
    except Exception as ex:
        print('Error processing', src_path.name, ex)

def make_responsive_sizes(src_path: Path):
    """Create responsive WebP sizes: 640w (medium), 1200w (large)."""
    sizes_map = {'640w': 640, '1200w': 1200}
    created = []
    try:
        with Image.open(src_path) as im:
            orig_w, orig_h = im.size
            im_rgb = im.convert('RGB')
            for size_label, max_w in sizes_map.items():
                if orig_w <= max_w:
                    # skip if source is already smaller
                    continue
                dest = THUMBS / f'{src_path.stem}_{size_label}.webp'
                ratio = max_w / orig_w
                new_h = int(orig_h * ratio)
                resized = im_rgb.resize((max_w, new_h), Image.LANCZOS)
                resized.save(dest, 'WEBP', quality=85, method=6)
                created.append((size_label, dest.name))
                print(f'Responsive created: {dest.name}')
    except Exception as ex:
        print(f'Error creating responsive sizes for {src_path.name}: {ex}')
    return created

def update_gallery_html():
    if not GALLERY.exists():
        print('gallery file not found:', GALLERY)
        return
    text = GALLERY.read_text(encoding='utf-8')
    import re

    def repl(m):
        fname = m.group(1)
        p = KUHNI / fname
        if not p.exists():
            return m.group(0)
        webp = THUMBS / (p.stem + '.webp')
        if webp.exists():
            # encode the space in the folder name for HTML src/srcset
            new = f'src="images/My%20Work/Кухні/thumbs/{webp.name}" data-full="images/My%20Work/Кухні/{fname}"'
            return new
        return m.group(0)

    # Replace occurrences of src="images/My Work/Кухні/<file>" for img tags
    new_text = re.sub(r'src="images/My Work/Кухні/([^"<>]+\.(?:jpg|jpeg|png|webp))"', repl, text, flags=re.IGNORECASE)
    if new_text != text:
        GALLERY.write_text(new_text, encoding='utf-8')
        print('Updated', GALLERY.name, 'to use thumbs where available')
    else:
        print('No replacements needed in', GALLERY.name)

def main():
    images = [p for p in KUHNI.iterdir() if p.suffix.lower() in IMG_EXTS and p.is_file()]
    if not images:
        print('Не знайдено зображень у', KUHNI)
        return

    for img in images:
        make_thumb(img)
        make_responsive_sizes(img)

    update_gallery_html()

if __name__ == '__main__':
    main()
