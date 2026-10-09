"""Generates seamless custom skyboxes (6 faces each) for the three worlds.

Usage: python3 tools/make_skybox.py   (needs numpy + Pillow)
Writes skybox/<World>_<Face>.png for World in Sky/Candy/Space and Face in Bk/Dn/Ft/Lf/Rt/Up.

The colour gradient depends only on elevation (how high you look), so the faces line up
perfectly no matter how they're oriented. Clouds/nebulae are drawn away from face edges,
so there are no visible seams.
"""
import os

import numpy as np
from PIL import Image

SIZE = 512
MARGIN = 70
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "skybox")


def elevation(face):
    """sin(elevation angle) for every pixel of a face."""
    t = np.linspace(-1, 1, SIZE)
    u, v = np.meshgrid(t, -t)  # v = +1 at the top row
    if face == "Up":
        return 1 / np.sqrt(u * u + v * v + 1)
    if face == "Dn":
        return -1 / np.sqrt(u * u + v * v + 1)
    return v / np.sqrt(u * u + v * v + 1)


def gradient(e, stops):
    """stops: list of (elevation, (r,g,b)) sorted by elevation."""
    img = np.zeros(e.shape + (3,))
    es = [s[0] for s in stops]
    for c in range(3):
        img[..., c] = np.interp(e, es, [s[1][c] for s in stops])
    return img


def blob(img, cx, cy, rx, ry, color, alpha):
    y, x = np.mgrid[0:SIZE, 0:SIZE]
    d = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
    a = alpha * np.exp(-d * 2.2)
    for c in range(3):
        img[..., c] = img[..., c] * (1 - a) + color[c] * a


def cloud(img, rng, cx, cy, scale, colors):
    for _ in range(rng.integers(5, 9)):
        ox, oy = rng.normal(0, 18 * scale), rng.normal(0, 5 * scale)
        r = rng.uniform(14, 26) * scale
        col = colors[rng.integers(len(colors))]
        blob(img, cx + ox, cy + oy, r * 1.4, r * 0.8, col, rng.uniform(0.55, 0.85))


def stars(img, rng, count, colors, mask=None):
    for _ in range(count):
        x, y = rng.integers(1, SIZE - 1, 2)
        if mask is not None and not mask[y, x]:
            continue
        col = np.array(colors[rng.integers(len(colors))])
        b = rng.uniform(0.4, 1.0)
        img[y, x] = img[y, x] * (1 - b) + col * b
        if rng.random() < 0.15:  # a few bigger, twinkly stars
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                img[y + dy, x + dx] = img[y + dy, x + dx] * (1 - b * 0.5) + col * b * 0.5


WORLDS = {
    "Sky": {
        "stops": [(-1, (150, 190, 235)), (-0.05, (205, 225, 250)), (0.0, (235, 243, 255)),
                  (0.25, (150, 195, 250)), (1, (60, 125, 230))],
        "clouds": [(255, 255, 255), (240, 246, 255), (225, 235, 250)],
        "stars": 0,
    },
    "Candy": {
        "stops": [(-1, (255, 170, 205)), (-0.05, (255, 205, 185)), (0.0, (255, 220, 190)),
                  (0.3, (255, 160, 205)), (1, (175, 135, 255))],
        "clouds": [(255, 225, 240), (255, 205, 230), (215, 225, 255)],
        "stars": 120,
        "star_colors": [(255, 255, 255), (255, 240, 200)],
    },
    "Space": {
        "stops": [(-1, (8, 4, 20)), (-0.1, (25, 10, 45)), (0.0, (45, 20, 75)),
                  (0.35, (15, 8, 40)), (1, (3, 3, 12))],
        "nebula": [(140, 60, 200), (60, 120, 220), (220, 70, 160)],
        "stars": 1400,
        "star_colors": [(255, 255, 255), (200, 220, 255), (255, 240, 200)],
    },
}


def make_face(world, face, rng):
    cfg = WORLDS[world]
    e = elevation(face)
    img = gradient(e, cfg["stops"])
    side = face not in ("Up", "Dn")
    if cfg.get("stars"):
        mask = e > (-0.2 if world == "Space" else 0.15)
        stars(img, rng, cfg["stars"] // (1 if side else 2), cfg["star_colors"], mask)
    if "clouds" in cfg and side:
        for _ in range(rng.integers(3, 6)):
            cx = rng.uniform(MARGIN + 40, SIZE - MARGIN - 40)
            cy = rng.uniform(SIZE * 0.42, SIZE * 0.56)  # just above the horizon
            cloud(img, rng, cx, cy, rng.uniform(0.8, 1.3), cfg["clouds"])
    if "clouds" in cfg and face == "Up":
        for _ in range(3):
            cloud(img, rng, rng.uniform(MARGIN + 60, SIZE - MARGIN - 60), rng.uniform(MARGIN + 60, SIZE - MARGIN - 60), 1.2, cfg["clouds"])
    if "nebula" in cfg and face != "Dn":
        for _ in range(rng.integers(2, 4)):
            col = cfg["nebula"][rng.integers(len(cfg["nebula"]))]
            cx = rng.uniform(MARGIN + 60, SIZE - MARGIN - 60)
            cy = rng.uniform(MARGIN + 60, SIZE - MARGIN - 60)
            for _ in range(5):
                blob(img, cx + rng.normal(0, 25), cy + rng.normal(0, 25), rng.uniform(30, 55), rng.uniform(20, 40), col, 0.22)
    return Image.fromarray(np.clip(img, 0, 255).astype(np.uint8))


def main():
    os.makedirs(OUT, exist_ok=True)
    for w, world in enumerate(WORLDS):
        for f, face in enumerate(("Bk", "Dn", "Ft", "Lf", "Rt", "Up")):
            rng = np.random.default_rng(1000 + w * 10 + f)
            make_face(world, face, rng).save(os.path.join(OUT, f"{world}_{face}.png"))
    print("wrote", len(os.listdir(OUT)), "skybox faces to", OUT)


if __name__ == "__main__":
    main()
