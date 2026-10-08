"""
Procedural placeholder sprite generator for the Dark Fantasy platformer.
Draws simple transparent PNG sprites with PIL — no external art assets.
Run: .assetenv/bin/python assets/generate_assets.py
"""
import math
import os
import random

from PIL import Image, ImageDraw, ImageFilter

random.seed(7)

OUT = os.path.join(os.path.dirname(__file__), "sprites")
os.makedirs(OUT, exist_ok=True)

# Palette
PURPLE_DARK = (28, 18, 46, 255)
PURPLE_MID = (61, 42, 97, 255)
PURPLE_LIGHT = (107, 74, 158, 255)
GOLD = (196, 150, 70, 255)
GOLD_LIGHT = (235, 196, 120, 255)
EYE_GLOW = (170, 220, 255, 255)
LANTERN_GLOW = (200, 110, 230, 255)
EMBER = (255, 110, 60, 255)
FLAME = (255, 190, 90, 255)
STONE = (46, 44, 55, 255)
STONE_DARK = (30, 28, 36, 255)
WOOD = (58, 40, 30, 255)
WOOD_DARK = (38, 26, 20, 255)
SKY_TOP = (10, 10, 30, 255)
SKY_BOTTOM = (35, 28, 60, 255)


def new(w, h):
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def save(img, name):
    img.save(os.path.join(OUT, name))
    print("wrote", name, img.size)


def glow_circle(img, cx, cy, r, color, steps=6):
    draw = ImageDraw.Draw(img, "RGBA")
    for i in range(steps, 0, -1):
        a = int(color[3] * (i / steps) * 0.18)
        rr = r * i / steps
        draw.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], fill=(color[0], color[1], color[2], a))


# ---------------------------------------------------------------- PLAYER ----
def make_player():
    # Body + head: hooded shadow figure with purple flame-hair silhouette, glowing eyes
    w, h = 64, 72
    img = new(w, h)
    d = ImageDraw.Draw(img)
    cx = w // 2
    # flame hair tendrils behind head
    for i, ang in enumerate([-70, -40, -15, 15, 40, 70]):
        rad = math.radians(ang)
        length = 22 + (i % 3) * 6
        x2 = cx + length * math.sin(rad)
        y2 = 20 - length * math.cos(rad) - 6
        d.line([cx, 18, x2, y2], fill=PURPLE_LIGHT, width=5)
        d.ellipse([x2 - 3, y2 - 3, x2 + 3, y2 + 3], fill=PURPLE_MID)
    # cloak body (trapezoid)
    d.polygon([(cx - 14, 26), (cx + 14, 26), (cx + 20, h - 4), (cx - 20, h - 4)], fill=PURPLE_DARK)
    d.polygon([(cx - 14, 26), (cx + 14, 26), (cx + 17, h - 10), (cx - 17, h - 10)], fill=(20, 12, 34, 255))
    # hood / head
    d.ellipse([cx - 16, 6, cx + 16, 34], fill=PURPLE_DARK)
    # face shadow
    d.ellipse([cx - 11, 12, cx + 11, 30], fill=(8, 5, 14, 255))
    # glowing eyes
    d.ellipse([cx - 6, 18, cx - 2, 22], fill=EYE_GLOW)
    d.ellipse([cx + 2, 18, cx + 6, 22], fill=EYE_GLOW)
    # satchel strap
    d.line([(cx - 10, 28), (cx + 12, 54)], fill=GOLD, width=3)
    d.rectangle([cx + 6, 50, cx + 20, 62], fill=WOOD)
    d.rectangle([cx + 6, 50, cx + 20, 62], outline=GOLD, width=1)
    img = img.filter(ImageFilter.SMOOTH_MORE)
    save(img, "player_body.png")

    # Arms: wispy cloak sleeves with clawed hand, curling tendrils (left/right mirrored)
    for side in ("left", "right"):
        aw, ah = 30, 40
        a = new(aw, ah)
        ad = ImageDraw.Draw(a)
        flip = -1 if side == "left" else 1
        ox = aw // 2
        ad.polygon([(ox - 8 * flip, 2), (ox + 8 * flip, 2), (ox + 10 * flip, 22), (ox - 6 * flip, 24)], fill=PURPLE_DARK)
        ad.ellipse([ox - 9, 20, ox + 9, 36], fill=PURPLE_MID)
        for i, dy in enumerate([24, 29, 34]):
            tx = ox + (10 + i * 3) * flip
            ad.line([(ox, dy), (tx, dy + 4)], fill=PURPLE_LIGHT, width=3)
        a = a.filter(ImageFilter.SMOOTH)
        save(a, f"player_arm_{side}.png")


# --------------------------------------------------------------- SOLDIER ----
def make_soldier():
    w, h = 54, 70
    img = new(w, h)
    d = ImageDraw.Draw(img)
    cx = w // 2
    # shako hat
    d.rectangle([cx - 11, 2, cx + 11, 20], fill=PURPLE_DARK)
    d.rectangle([cx - 13, 16, cx + 13, 22], fill=GOLD)
    d.polygon([(cx, -4), (cx - 4, 6), (cx + 4, 6)], fill=GOLD_LIGHT)
    d.line([(cx - 11, 10), (cx + 11, 10)], fill=GOLD, width=2)
    # face plate
    d.ellipse([cx - 9, 20, cx + 9, 36], fill=PURPLE_MID)
    d.rectangle([cx - 9, 25, cx + 9, 30], fill=(12, 8, 20, 255))
    d.ellipse([cx - 4, 26, cx + 1, 30], fill=LANTERN_GLOW)
    # torso with epaulettes and crossbelt
    d.polygon([(cx - 13, 34), (cx + 13, 34), (cx + 15, 58), (cx - 15, 58)], fill=PURPLE_DARK)
    d.line([(cx - 13, 36), (cx + 10, 56)], fill=GOLD, width=3)
    d.rectangle([cx - 17, 32, cx - 9, 40], fill=GOLD)
    d.rectangle([cx + 9, 32, cx + 17, 40], fill=GOLD)
    d.rectangle([cx - 15, 56, cx + 15, 62], fill=GOLD)
    img = img.filter(ImageFilter.SMOOTH_MORE)
    save(img, "soldier_body.png")

    for side in ("left", "right"):
        aw, ah = 22, 34
        a = new(aw, ah)
        ad = ImageDraw.Draw(a)
        ox = aw // 2
        ad.rounded_rectangle([ox - 6, 2, ox + 6, 20], radius=4, fill=PURPLE_DARK, outline=GOLD, width=1)
        ad.ellipse([ox - 7, 18, ox + 7, 32], fill=PURPLE_MID, outline=GOLD, width=1)
        a = a.filter(ImageFilter.SMOOTH)
        save(a, f"soldier_arm_{side}.png")

    # Lantern held by the soldier's lit (right) hand
    lw, lh = 26, 40
    l = new(lw, lh)
    ld = ImageDraw.Draw(l)
    ox = lw // 2
    ld.line([(ox, 0), (ox, 8)], fill=GOLD, width=2)
    ld.polygon([(ox - 3, 8), (ox + 3, 8), (ox + 6, 12), (ox - 6, 12)], fill=GOLD)
    ld.rectangle([ox - 7, 12, ox + 7, 30], fill=(40, 10, 50, 180), outline=GOLD, width=2)
    glow_circle(l, ox, 21, 16, LANTERN_GLOW)
    ld.rectangle([ox - 5, 14, ox + 5, 28], fill=LANTERN_GLOW)
    ld.polygon([(ox - 4, 30), (ox + 4, 30), (ox, 36)], fill=GOLD)
    l = l.filter(ImageFilter.SMOOTH)
    save(l, "soldier_lantern.png")


# -------------------------------------------------------- LIGHT CONE (PNG)--
def make_light_cone():
    w, h = 220, 160
    img = new(w, h)
    draw = ImageDraw.Draw(img, "RGBA")
    apex = (10, h // 2)
    for i in range(40, 0, -1):
        a = int(70 * (i / 40))
        spread = 34 * (i / 40)
        length = w - 20
        x = 10 + length * (i / 40)
        top = apex[1] - spread
        bot = apex[1] + spread
        draw.polygon([apex, (x, top), (x, bot)], fill=(LANTERN_GLOW[0], LANTERN_GLOW[1], LANTERN_GLOW[2], a // 6))
    draw.polygon([apex, (w - 10, h // 2 - 50), (w - 10, h // 2 + 50)],
                 fill=(LANTERN_GLOW[0], LANTERN_GLOW[1], LANTERN_GLOW[2], 55))
    img = img.filter(ImageFilter.GaussianBlur(3))
    save(img, "light_cone.png")


# -------------------------------------------------------------- ENVIRONMENT -
def make_sky():
    w, h = 1600, 720
    img = Image.new("RGBA", (w, h), (0, 0, 0, 255))
    for y in range(h):
        t = y / h
        r = int(SKY_TOP[0] + (SKY_BOTTOM[0] - SKY_TOP[0]) * t)
        g = int(SKY_TOP[1] + (SKY_BOTTOM[1] - SKY_TOP[1]) * t)
        b = int(SKY_TOP[2] + (SKY_BOTTOM[2] - SKY_TOP[2]) * t)
        ImageDraw.Draw(img).line([(0, y), (w, y)], fill=(r, g, b, 255))
    random.seed(3)
    d = ImageDraw.Draw(img, "RGBA")
    for _ in range(140):
        x, y = random.randint(0, w), random.randint(0, int(h * 0.55))
        s = random.choice([1, 1, 1, 2])
        a = random.randint(80, 200)
        d.ellipse([x, y, x + s, y + s], fill=(230, 230, 255, a))
    save(img, "sky_stars.png")


def make_moon():
    s = 180
    img = new(s, s)
    d = ImageDraw.Draw(img)
    glow_circle(img, s / 2, s / 2, s / 2, (220, 220, 255, 255), steps=10)
    d.ellipse([30, 30, s - 30, s - 30], fill=(235, 235, 250, 255))
    d.ellipse([60, 40, 85, 65], fill=(205, 205, 225, 255))
    d.ellipse([95, 80, 125, 110], fill=(205, 205, 225, 255))
    d.ellipse([55, 95, 75, 115], fill=(215, 215, 235, 255))
    save(img, "moon.png")


def make_cloud(idx, w=320, h=120):
    img = new(w, h)
    d = ImageDraw.Draw(img, "RGBA")
    random.seed(idx * 11 + 1)
    puffs = random.randint(6, 9)
    for _ in range(puffs):
        cx = random.randint(30, w - 30)
        cy = random.randint(h // 2 - 20, h // 2 + 20)
        r = random.randint(30, 55)
        d.ellipse([cx - r, cy - r * 0.7, cx + r, cy + r * 0.7], fill=(8, 6, 16, 235))
    img = img.filter(ImageFilter.GaussianBlur(6))
    save(img, f"cloud_{idx}.png")


def building_row(name, w, h, base_color, roof_color, n_buildings, window_rows=2, church=False):
    img = new(w, h)
    d = ImageDraw.Draw(img)
    random.seed(len(name) * 97)
    x = 0
    ground_y = h - 4
    while x < w:
        bw = random.randint(90, 170)
        bh = random.randint(int(h * 0.45), int(h * 0.85))
        top = ground_y - bh
        d.rectangle([x, top, x + bw, ground_y], fill=base_color)
        # roof
        d.polygon([(x - 6, top), (x + bw // 2, top - 34), (x + bw + 6, top)], fill=roof_color)
        # chimney
        if random.random() < 0.6:
            cxp = x + bw - 20
            d.rectangle([cxp, top - 46, cxp + 10, top - 20], fill=STONE_DARK)
        # windows (drawn as dark sockets; separate Window sprites overlay dynamically in-game)
        rows = random.randint(1, window_rows)
        for r in range(rows):
            wy = top + 14 + r * 26
            cols = max(1, bw // 40)
            for c in range(cols):
                wx = x + 14 + c * 36
                if wx + 14 < x + bw - 6:
                    d.rectangle([wx, wy, wx + 14, wy + 18], fill=(10, 8, 16, 255))
        x += bw + random.randint(4, 14)
    if church:
        d.polygon([(w - 220, ground_y), (w - 160, ground_y - 230), (w - 100, ground_y)], fill=base_color)
        d.rectangle([w - 172, ground_y - 230, w - 148, ground_y - 170], fill=base_color)
        d.polygon([(w - 172, ground_y - 230), (w - 160, ground_y - 260), (w - 148, ground_y - 230)], fill=roof_color)
        d.line([(w - 160, ground_y - 260), (w - 160, ground_y - 278)], fill=STONE_DARK, width=4)
        d.line([(w - 168, ground_y - 272), (w - 152, ground_y - 272)], fill=STONE_DARK, width=4)
        for yy in range(ground_y - 200, ground_y - 40, 30):
            d.polygon([(w - 165, yy), (w - 160, yy - 12), (w - 155, yy)], fill=(10, 8, 16, 255))
    save(img, name)


def make_castle_silhouette():
    w, h = 1600, 420
    img = new(w, h)
    d = ImageDraw.Draw(img)
    base = (16, 14, 26, 255)
    ground = h - 10
    towers = [120, 340, 560, 820, 1040, 1280, 1460]
    for tx in towers:
        tw = random.randint(50, 80)
        th = random.randint(160, 300)
        d.rectangle([tx, ground - th, tx + tw, ground], fill=base)
        for i in range(4):
            bx = tx + i * (tw / 4)
            d.rectangle([bx, ground - th - 14, bx + tw / 8, ground - th], fill=base)
    d.rectangle([0, ground - 90, w, ground], fill=base)
    save(img, "castle_far.png")


def make_ground():
    w, h = 1600, 90
    img = new(w, h)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, w, h], fill=STONE_DARK)
    random.seed(5)
    for _ in range(260):
        x = random.randint(0, w)
        y = random.randint(0, h - 6)
        s = random.randint(10, 26)
        shade = random.randint(-10, 10)
        c = tuple(max(0, min(255, v + shade)) for v in STONE[:3]) + (255,)
        d.rectangle([x, y, x + s, y + 5], fill=c)
    d.rectangle([0, 0, w, 6], fill=(20, 18, 28, 255))
    save(img, "ground.png")


def make_torch():
    w, h = 20, 70
    img = new(w, h)
    d = ImageDraw.Draw(img)
    d.rectangle([w // 2 - 3, 20, w // 2 + 3, h], fill=WOOD_DARK)
    d.polygon([(w // 2 - 7, 18), (w // 2 + 7, 18), (w // 2 + 4, 26), (w // 2 - 4, 26)], fill=STONE_DARK)
    save(img, "torch_pole.png")

    for state, (col, r) in {
        "bright": (FLAME, 22),
        "low": (EMBER, 10),
        "ember": ((120, 40, 20, 255), 5),
    }.items():
        f = new(44, 54)
        fd = ImageDraw.Draw(f, "RGBA")
        glow_circle(f, 22, 36, r + 14, col)
        fd.ellipse([22 - r * 0.5, 36 - r, 22 + r * 0.5, 36 + r * 0.2], fill=col)
        fd.ellipse([22 - r * 0.3, 30 - r * 0.6, 22 + r * 0.3, 30], fill=(255, 235, 200, 255))
        f = f.filter(ImageFilter.GaussianBlur(1.2))
        save(f, f"torch_flame_{state}.png")


def make_lamp_post():
    w, h = 26, 140
    img = new(w, h)
    d = ImageDraw.Draw(img)
    d.rectangle([w // 2 - 3, 0, w // 2 + 3, h - 20], fill=STONE_DARK)
    d.polygon([(2, 0), (w - 2, 0), (w // 2, 16)], fill=STONE_DARK)
    d.ellipse([2, h - 26, w - 2, h - 2], outline=GOLD, width=2)
    save(img, "lamp_post.png")

    lamp = new(40, 46)
    ld = ImageDraw.Draw(lamp)
    glow_circle(lamp, 20, 23, 20, FLAME)
    ld.rectangle([6, 6, 34, 36], fill=(30, 20, 10, 160), outline=GOLD, width=2)
    ld.ellipse([11, 11, 29, 31], fill=FLAME)
    ld.polygon([(2, 2), (38, 2), (20, -8)], fill=GOLD)
    save(lamp, "lamp_head.png")


def make_window():
    w, h = 32, 40
    closed = new(w, h)
    d = ImageDraw.Draw(closed)
    d.rectangle([0, 0, w, h], fill=WOOD_DARK)
    d.rectangle([3, 3, w - 3, h - 3], fill=(10, 8, 16, 255))
    for i in range(1, 3):
        d.line([(3, 3 + i * (h - 6) / 3), (w - 3, 3 + i * (h - 6) / 3)], fill=WOOD_DARK, width=1)
    save(closed, "window_closed.png")

    glow = new(w, h)
    gd = ImageDraw.Draw(glow, "RGBA")
    gd.rounded_rectangle([2, 2, w - 2, h - 2], radius=6, outline=(255, 190, 110, 220), width=3)
    glow = glow.filter(ImageFilter.GaussianBlur(2))
    save(glow, "window_curtain_glow.png")

    opened = new(w, h)
    od = ImageDraw.Draw(opened)
    glow_circle(opened, w / 2, h / 2, w, (255, 200, 120, 255), steps=8)
    od.rectangle([2, 2, w - 2, h - 2], fill=(255, 215, 150, 255))
    od.rectangle([0, 0, 4, h], fill=WOOD_DARK)
    od.rectangle([w - 4, 0, w, h], fill=WOOD_DARK)
    save(opened, "window_open.png")


def make_barrel():
    w, h = 34, 40
    img = new(w, h)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([2, 2, w - 2, h - 2], radius=8, fill=WOOD)
    for yy in (8, h // 2, h - 8):
        d.line([(2, yy), (w - 2, yy)], fill=STONE_DARK, width=2)
    d.line([(4, 4), (4, h - 4)], fill=WOOD_DARK, width=2)
    d.line([(w - 4, 4), (w - 4, h - 4)], fill=WOOD_DARK, width=2)
    save(img, "barrel.png")


def make_cage(alive=True):
    w, h = 40, 70
    img = new(w, h)
    d = ImageDraw.Draw(img)
    d.line([(w // 2, 0), (w // 2, 10)], fill=STONE_DARK, width=2)
    d.rounded_rectangle([4, 10, w - 4, h - 4], radius=4, outline=STONE_DARK, width=3)
    for x in range(8, w - 6, 6):
        d.line([(x, 10), (x, h - 4)], fill=STONE_DARK, width=2)
    body_color = (90, 70, 70, 255) if alive else (70, 70, 80, 255)
    d.ellipse([w // 2 - 7, 20, w // 2 + 7, 34], fill=body_color)
    d.rectangle([w // 2 - 6, 32, w // 2 + 6, h - 10], fill=body_color)
    if alive:
        d.ellipse([w // 2 - 4, 23, w // 2 - 1, 26], fill=EYE_GLOW)
        d.ellipse([w // 2 + 1, 23, w // 2 + 4, 26], fill=EYE_GLOW)
    save(img, "cage_prisoner_alive.png" if alive else "cage_prisoner_dead.png")


def make_gallows():
    w, h = 90, 110
    img = new(w, h)
    d = ImageDraw.Draw(img)
    d.rectangle([8, 10, 16, h - 4], fill=WOOD_DARK)
    d.rectangle([w - 16, 10, w - 8, h - 4], fill=WOOD_DARK)
    d.rectangle([8, 6, w - 8, 16], fill=WOOD_DARK)
    d.line([(w // 2, 16), (w // 2, 40)], fill=STONE_DARK, width=2)
    d.rectangle([w // 2 - 6, 40, w // 2 + 6, 42], fill=STONE_DARK)
    save(img, "gallows.png")


def make_stocks():
    w, h = 50, 40
    img = new(w, h)
    d = ImageDraw.Draw(img)
    d.rectangle([4, 10, w - 4, 26], fill=WOOD)
    d.ellipse([14, 2, 30, 18], fill=(90, 70, 70, 255))
    d.rectangle([2, 24, w - 2, h - 2], fill=WOOD_DARK)
    for lx in (10, 20, 30, 40):
        d.rectangle([lx, 24, lx + 6, h - 2], fill=STONE_DARK)
    save(img, "stocks.png")


def make_rat(kind):
    w, h = 22, 14
    img = new(w, h)
    d = ImageDraw.Draw(img)
    colors = {
        "normal": (60, 50, 44, 255),
        "plague": (90, 40, 90, 255),
        "skeleton": (210, 205, 190, 255),
    }
    c = colors[kind]
    d.ellipse([2, 4, 16, 14], fill=c)
    d.ellipse([12, 2, 20, 10], fill=c)
    d.line([(2, 8), (-6, 4)], fill=c, width=2)
    d.ellipse([13, 4, 16, 7], fill=(0, 0, 0, 255) if kind != "plague" else EYE_GLOW)
    if kind == "plague":
        for _ in range(4):
            x, y = random.randint(2, 16), random.randint(4, 12)
            d.ellipse([x, y, x + 2, y + 2], fill=(140, 80, 160, 255))
    if kind == "skeleton":
        for x in range(4, 14, 3):
            d.line([(x, 6), (x, 12)], fill=(120, 115, 105, 255), width=1)
    save(img, f"rat_{kind}.png")


def make_moth():
    w, h = 10, 8
    img = new(w, h)
    d = ImageDraw.Draw(img, "RGBA")
    d.polygon([(5, 4), (0, 0), (2, 4), (0, 8)], fill=(230, 220, 190, 220))
    d.polygon([(5, 4), (10, 0), (8, 4), (10, 8)], fill=(230, 220, 190, 220))
    d.ellipse([4, 2, 6, 6], fill=(60, 50, 40, 255))
    save(img, "moth.png")


def make_tavern():
    w, h = 260, 260
    img = new(w, h)
    d = ImageDraw.Draw(img)
    ground = h - 6
    d.rectangle([10, ground - 180, w - 10, ground], fill=(70, 50, 36, 255))
    d.polygon([(0, ground - 180), (w // 2, ground - 240), (w, ground - 180)], fill=WOOD_DARK)
    d.rectangle([w // 2 - 28, ground - 70, w // 2 + 28, ground], fill=WOOD_DARK)
    d.rectangle([w // 2 - 24, ground - 64, w // 2 + 24, ground - 4], fill=(255, 200, 120, 255))
    for wx in (36, w - 70):
        d.rectangle([wx, ground - 150, wx + 36, ground - 110], fill=(255, 210, 140, 255))
        d.rectangle([wx, ground - 150, wx + 36, ground - 110], outline=WOOD_DARK, width=3)
    d.ellipse([w // 2 - 30, ground - 230, w // 2 + 30, ground - 190], fill=GOLD)
    d.rectangle([w // 2 - 2, ground - 196, w // 2 + 2, ground - 180], fill=STONE_DARK)
    save(img, "tavern.png")


if __name__ == "__main__":
    make_player()
    make_soldier()
    make_light_cone()
    make_sky()
    make_moon()
    for i in range(4):
        make_cloud(i)
    make_castle_silhouette()
    building_row("buildings_far.png", 1600, 360, (26, 22, 36, 255), (18, 15, 26, 255), 10, window_rows=2)
    building_row("buildings_mid.png", 1600, 420, (40, 32, 48, 255), (26, 20, 32, 255), 8, window_rows=2, church=True)
    building_row("buildings_near.png", 1600, 520, (54, 42, 58, 255), (34, 24, 36, 255), 7, window_rows=3)
    make_ground()
    make_torch()
    make_lamp_post()
    make_window()
    make_barrel()
    make_cage(True)
    make_cage(False)
    make_gallows()
    make_stocks()
    for k in ("normal", "plague", "skeleton"):
        make_rat(k)
    make_moth()
    make_tavern()
    print("Done. Assets in", OUT)
