"""Generate 24-frame rotating planet sprites for SpaceTrader.
Each planet gets a 1D surface texture strip that scrolls horizontally,
mapped onto a sphere with edge compression and lighting."""

from PIL import Image, ImageDraw
import numpy as np
import math
import glob
import os

OUT_DIR = "C:/Users/Faita/Documents/SpaceTrader/assets/sprites"
NUM_FRAMES = 24

# ═══ PLANET DEFINITIONS ═══
PLANETS = {
    "mercury": {
        "size": (48, 48),
        "type": "rocky",
    },
    "venus": {
        "size": (56, 56),
        "type": "gas",
    },
    "earth": {
        "size": (56, 56),
        "type": "terrestrial",
    },
    "mars": {
        "size": (52, 52),
        "type": "rocky",
    },
    "jupiter": {
        "size": (72, 72),
        "type": "gas_giant",
    },
    "saturn": {
        "size": (80, 52),
        "type": "gas_giant",
    },
    "uranus": {
        "size": (64, 64),
        "type": "ice_giant",
    },
    "neptune": {
        "size": (60, 60),
        "type": "ice_giant",
    },
    "phobos": {
        "size": (24, 24),
        "type": "rocky",
    },
}


def make_mercury_strip(h):
    """Gray, heavily cratered surface."""
    w = h * 3
    strip = np.zeros((h, w, 4), dtype=np.uint8)
    rng = np.random.RandomState(42)

    # Base gray surface with variation
    for y in range(h):
        for x in range(w):
            base = 140 + rng.randint(-15, 15)
            strip[y, x] = [base, base - 5, base - 8, 255]

    # Craters - many small and medium
    craters = []
    for _ in range(35):
        cx, cy = rng.randint(0, w), rng.randint(0, h)
        r = rng.randint(2, max(3, h // 8))
        craters.append((cx, cy, r))
    for _ in range(12):
        cx, cy = rng.randint(0, w), rng.randint(0, h)
        r = rng.randint(max(3, h // 10), max(4, h // 5))
        craters.append((cx, cy, r))

    for cx, cy, r in craters:
        for dy in range(-r - 1, r + 2):
            for dx in range(-r - 1, r + 2):
                dist = math.sqrt(dx * dx + dy * dy)
                px = cx + dx
                py = cy + dy
                if py < 0 or py >= h:
                    continue
                px = px % w
                if dist <= r:
                    # Dark crater floor
                    dark = max(60, 110 - int(20 * (1 - dist / r)))
                    strip[py, px] = [dark, dark - 5, dark - 8, 255]
                elif dist <= r + 1:
                    # Bright rim (lit side)
                    if dx > 0 or dy < 0:
                        bright = min(255, 180 + rng.randint(0, 30))
                        strip[py, px] = [bright, bright - 5, bright - 5, 255]
                    else:
                        dark = max(50, 100 + rng.randint(-10, 5))
                        strip[py, px] = [dark, dark - 5, dark - 8, 255]

    return strip


def make_venus_strip(h):
    """Yellow-orange with thick swirling cloud bands."""
    w = h * 3
    strip = np.zeros((h, w, 4), dtype=np.uint8)
    rng = np.random.RandomState(101)

    for y in range(h):
        # Horizontal cloud bands
        band = math.sin(y * math.pi / h * 6) * 0.3 + math.sin(y * math.pi / h * 2.5) * 0.5
        for x in range(w):
            # Swirl offset
            swirl = math.sin((y + x * 0.3) * 0.15) * 15
            val = band + math.sin((x + swirl) * 0.08) * 0.3 + rng.uniform(-0.05, 0.05)
            val = max(0, min(1, val * 0.5 + 0.5))
            r = int(200 + val * 55)
            g = int(160 + val * 50)
            b = int(60 + val * 40)
            strip[y, x] = [min(255, r), min(255, g), min(255, b), 255]

    return strip


def make_earth_strip(h):
    """Blue oceans, green/brown continents, white cloud wisps."""
    w = h * 3
    strip = np.zeros((h, w, 4), dtype=np.uint8)
    rng = np.random.RandomState(200)

    # Ocean base
    for y in range(h):
        for x in range(w):
            depth = rng.uniform(-0.1, 0.1)
            strip[y, x] = [30 + int(depth * 20), 80 + int(depth * 30), 180 + int(depth * 40), 255]

    # Continents using noise-like blobs
    continent_seeds = [(int(w * 0.15), int(h * 0.35), 10),
                       (int(w * 0.15), int(h * 0.55), 8),
                       (int(w * 0.45), int(h * 0.3), 14),
                       (int(w * 0.45), int(h * 0.5), 11),
                       (int(w * 0.7), int(h * 0.25), 9),
                       (int(w * 0.7), int(h * 0.45), 12),
                       (int(w * 0.7), int(h * 0.65), 7),
                       (int(w * 0.9), int(h * 0.4), 10)]

    land_map = np.zeros((h, w), dtype=float)
    for sx, sy, sr in continent_seeds:
        # Add several overlapping blobs per continent
        for _ in range(rng.randint(3, 7)):
            bx = sx + rng.randint(-sr, sr)
            by = sy + rng.randint(-sr // 2, sr // 2)
            br = rng.randint(max(2, sr // 2), sr + 3)
            for dy in range(-br, br + 1):
                for dx in range(-br, br + 1):
                    dist = math.sqrt(dx * dx + dy * dy)
                    if dist < br:
                        py = by + dy
                        px = (bx + dx) % w
                        if 0 <= py < h:
                            land_map[py, px] += max(0, 1 - dist / br)

    for y in range(h):
        for x in range(w):
            if land_map[y, x] > 0.6:
                # Latitude-based coloring
                lat = abs(y - h / 2) / (h / 2)
                if lat > 0.85:
                    # Polar ice
                    strip[y, x] = [230, 240, 250, 255]
                elif lat > 0.7:
                    # Tundra
                    g = 100 + rng.randint(0, 30)
                    strip[y, x] = [80, g, 60, 255]
                elif lat < 0.2:
                    # Tropical green
                    g = 140 + rng.randint(0, 40)
                    strip[y, x] = [40, g, 30, 255]
                else:
                    # Temperate - mix green/brown
                    mix = rng.uniform(0, 1)
                    if mix > 0.5:
                        g = 120 + rng.randint(0, 40)
                        strip[y, x] = [60, g, 40, 255]
                    else:
                        strip[y, x] = [130 + rng.randint(0, 30), 100 + rng.randint(0, 20), 50, 255]

    # Cloud wisps
    for _ in range(8):
        cx = rng.randint(0, w)
        cy = rng.randint(2, h - 2)
        length = rng.randint(5, 15)
        for dx in range(length):
            px = (cx + dx) % w
            py = cy + int(math.sin(dx * 0.5) * 1.5)
            if 0 <= py < h:
                # Semi-transparent white
                old = strip[py, px].copy()
                alpha = 160 + rng.randint(0, 60)
                blend = alpha / 255
                strip[py, px, 0] = int(old[0] * (1 - blend) + 240 * blend)
                strip[py, px, 1] = int(old[1] * (1 - blend) + 245 * blend)
                strip[py, px, 2] = int(old[2] * (1 - blend) + 255 * blend)

    return strip


def make_mars_strip(h):
    """Red-orange desert, darker rock formations, white polar ice caps."""
    w = h * 3
    strip = np.zeros((h, w, 4), dtype=np.uint8)
    rng = np.random.RandomState(300)

    for y in range(h):
        lat = abs(y - h / 2) / (h / 2)
        for x in range(w):
            noise = rng.uniform(-0.08, 0.08)
            if lat > 0.85:
                # Polar ice caps
                strip[y, x] = [220 + rng.randint(0, 35), 225 + rng.randint(0, 30),
                                230 + rng.randint(0, 25), 255]
            else:
                # Red-orange base
                base_r = int(180 + noise * 60)
                base_g = int(100 + noise * 40)
                base_b = int(50 + noise * 20)
                strip[y, x] = [max(0, min(255, base_r)), max(0, min(255, base_g)),
                                max(0, min(255, base_b)), 255]

    # Dark rock formations / channels
    for _ in range(15):
        sx = rng.randint(0, w)
        sy = rng.randint(int(h * 0.15), int(h * 0.85))
        length = rng.randint(4, 12)
        for d in range(length):
            px = (sx + d) % w
            py = sy + int(math.sin(d * 0.7) * 2)
            if 0 <= py < h:
                strip[py, px] = [120 + rng.randint(0, 20), 60 + rng.randint(0, 15),
                                  30 + rng.randint(0, 10), 255]
                if py + 1 < h:
                    strip[py + 1, px] = [130 + rng.randint(0, 15), 70 + rng.randint(0, 10),
                                          35, 255]

    # Olympus Mons - big dark circle
    mx, my = int(w * 0.3), int(h * 0.4)
    mr = max(3, h // 7)
    for dy in range(-mr, mr + 1):
        for dx in range(-mr, mr + 1):
            dist = math.sqrt(dx * dx + dy * dy)
            if dist < mr:
                px = (mx + dx) % w
                py = my + dy
                if 0 <= py < h:
                    dark = max(0, 1 - dist / mr) * 0.3
                    old = strip[py, px].copy()
                    strip[py, px, 0] = int(old[0] * (1 - dark) + 100 * dark)
                    strip[py, px, 1] = int(old[1] * (1 - dark) + 50 * dark)
                    strip[py, px, 2] = int(old[2] * (1 - dark) + 25 * dark)

    return strip


def make_phobos_strip(h):
    """Phobos: dusty gray-brown regolith, dark craters, one rust smear (the Meat Works)."""
    w = h * 3
    strip = np.zeros((h, w, 4), dtype=np.uint8)
    rng = np.random.RandomState(9090)
    base = np.array([96, 88, 82])
    for y in range(h):
        for x in range(w):
            n = rng.uniform(-14, 14)
            c = np.clip(base + n, 0, 255)
            strip[y, x] = [int(c[0]), int(c[1]), int(c[2]), 255]
    # craters
    for _ in range(max(3, h // 3)):
        cx, cy, r = rng.randint(0, w), rng.randint(0, h), rng.randint(1, max(2, h // 5))
        for y in range(max(0, cy - r), min(h, cy + r + 1)):
            for x in range(max(0, cx - r), min(w, cx + r + 1)):
                if (x - cx) ** 2 + (y - cy) ** 2 <= r * r:
                    strip[y, x, :3] = (strip[y, x, :3] * 0.55).astype(np.uint8)
    # the factory: a 2px rust-red smear with a magenta pixel (neon)
    fx, fy = w // 4, h // 2
    strip[fy, fx:fx + 2, :3] = [140, 74, 47]
    strip[fy, fx + 1, :3] = [255, 61, 166]
    return strip


def make_jupiter_strip(h):
    """Orange/brown horizontal bands, Great Red Spot, turbulent."""
    w = h * 3
    strip = np.zeros((h, w, 4), dtype=np.uint8)
    rng = np.random.RandomState(400)

    # Strong horizontal bands
    band_colors = [
        (210, 180, 140),  # light tan
        (180, 120, 60),   # brown
        (220, 190, 150),  # cream
        (160, 100, 50),   # dark brown
        (230, 200, 160),  # pale
        (190, 130, 70),   # orange-brown
        (200, 160, 110),  # medium
        (170, 110, 55),   # dark
    ]

    for y in range(h):
        band_idx = int(y / h * len(band_colors))
        band_idx = min(band_idx, len(band_colors) - 1)
        # Blend between bands
        t = (y / h * len(band_colors)) - band_idx
        next_idx = min(band_idx + 1, len(band_colors) - 1)
        bc = band_colors[band_idx]
        nc = band_colors[next_idx]

        for x in range(w):
            turbulence = math.sin(x * 0.12 + y * 0.3) * 0.1 + rng.uniform(-0.03, 0.03)
            tt = max(0, min(1, t + turbulence))
            r = int(bc[0] * (1 - tt) + nc[0] * tt)
            g = int(bc[1] * (1 - tt) + nc[1] * tt)
            b = int(bc[2] * (1 - tt) + nc[2] * tt)
            strip[y, x] = [max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b)), 255]

    # Great Red Spot
    grs_x = int(w * 0.5)
    grs_y = int(h * 0.6)
    grs_rx = max(4, h // 6)
    grs_ry = max(3, h // 9)
    for dy in range(-grs_ry - 1, grs_ry + 2):
        for dx in range(-grs_rx - 1, grs_rx + 2):
            dist = math.sqrt((dx / grs_rx) ** 2 + (dy / grs_ry) ** 2)
            if dist < 1.0:
                px = (grs_x + dx) % w
                py = grs_y + dy
                if 0 <= py < h:
                    blend = max(0, 1 - dist) * 0.8
                    # Reddish center
                    strip[py, px, 0] = int(strip[py, px, 0] * (1 - blend) + 200 * blend)
                    strip[py, px, 1] = int(strip[py, px, 1] * (1 - blend) + 80 * blend)
                    strip[py, px, 2] = int(strip[py, px, 2] * (1 - blend) + 50 * blend)

    return strip


def make_saturn_strip(h):
    """Yellow-tan horizontal bands. No rings (separate node). Width is 80 but planet body is ~52."""
    # Saturn sprite is 80x52 but the planet disc itself should be centered
    # The strip height matches the full image height
    w = h * 3
    strip = np.zeros((h, w, 4), dtype=np.uint8)
    rng = np.random.RandomState(500)

    band_colors = [
        (220, 200, 160),  # pale yellow
        (200, 180, 130),  # tan
        (230, 210, 170),  # cream
        (190, 170, 120),  # darker tan
        (215, 195, 155),  # medium
        (205, 185, 140),  # warm
    ]

    for y in range(h):
        band_idx = int(y / h * len(band_colors))
        band_idx = min(band_idx, len(band_colors) - 1)
        t = (y / h * len(band_colors)) - band_idx
        next_idx = min(band_idx + 1, len(band_colors) - 1)
        bc = band_colors[band_idx]
        nc = band_colors[next_idx]

        for x in range(w):
            turb = math.sin(x * 0.1 + y * 0.2) * 0.08 + rng.uniform(-0.03, 0.03)
            tt = max(0, min(1, t + turb))
            r = int(bc[0] * (1 - tt) + nc[0] * tt)
            g = int(bc[1] * (1 - tt) + nc[1] * tt)
            b = int(bc[2] * (1 - tt) + nc[2] * tt)
            strip[y, x] = [max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b)), 255]

    return strip


def make_uranus_strip(h):
    """Teal/cyan, very subtle light bands, faint atmosphere."""
    w = h * 3
    strip = np.zeros((h, w, 4), dtype=np.uint8)
    rng = np.random.RandomState(600)

    for y in range(h):
        band = math.sin(y * math.pi / h * 3) * 0.08
        for x in range(w):
            noise = rng.uniform(-0.03, 0.03)
            val = band + noise
            r = int(120 + val * 30)
            g = int(200 + val * 25)
            b = int(210 + val * 20)
            strip[y, x] = [max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b)), 255]

    # Faint lighter bands
    for band_y in [int(h * 0.3), int(h * 0.6)]:
        for dy in range(-1, 2):
            y = band_y + dy
            if 0 <= y < h:
                for x in range(w):
                    strip[y, x, 0] = min(255, strip[y, x, 0] + 12)
                    strip[y, x, 1] = min(255, strip[y, x, 1] + 15)
                    strip[y, x, 2] = min(255, strip[y, x, 2] + 10)

    return strip


def make_neptune_strip(h):
    """Deep blue, darker storm spots, faint cloud streaks."""
    w = h * 3
    strip = np.zeros((h, w, 4), dtype=np.uint8)
    rng = np.random.RandomState(700)

    for y in range(h):
        band = math.sin(y * math.pi / h * 4) * 0.1
        for x in range(w):
            noise = rng.uniform(-0.04, 0.04)
            val = band + noise
            r = int(40 + val * 20)
            g = int(60 + val * 30)
            b = int(180 + val * 40)
            strip[y, x] = [max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b)), 255]

    # Dark storm spots
    storms = [(int(w * 0.3), int(h * 0.4), max(3, h // 8)),
              (int(w * 0.7), int(h * 0.6), max(2, h // 10))]
    for sx, sy, sr in storms:
        for dy in range(-sr, sr + 1):
            for dx in range(-sr - 1, sr + 2):
                dist = math.sqrt(dx * dx + dy * dy)
                if dist < sr:
                    px = (sx + dx) % w
                    py = sy + dy
                    if 0 <= py < h:
                        blend = max(0, 1 - dist / sr) * 0.5
                        strip[py, px, 0] = int(strip[py, px, 0] * (1 - blend) + 25 * blend)
                        strip[py, px, 1] = int(strip[py, px, 1] * (1 - blend) + 35 * blend)
                        strip[py, px, 2] = int(strip[py, px, 2] * (1 - blend) + 130 * blend)

    # Faint cloud streaks
    for _ in range(6):
        cx = rng.randint(0, w)
        cy = rng.randint(3, h - 3)
        length = rng.randint(6, 18)
        for d in range(length):
            px = (cx + d) % w
            py = cy + int(math.sin(d * 0.4) * 1)
            if 0 <= py < h:
                strip[py, px, 0] = min(255, strip[py, px, 0] + 20)
                strip[py, px, 1] = min(255, strip[py, px, 1] + 25)
                strip[py, px, 2] = min(255, strip[py, px, 2] + 30)

    return strip


STRIP_MAKERS = {
    "mercury": make_mercury_strip,
    "venus": make_venus_strip,
    "earth": make_earth_strip,
    "mars": make_mars_strip,
    "jupiter": make_jupiter_strip,
    "saturn": make_saturn_strip,
    "uranus": make_uranus_strip,
    "neptune": make_neptune_strip,
    "phobos": make_phobos_strip,
}


def render_planet_frame(strip, img_w, img_h, frame, total_frames=24):
    """Render one frame of a rotating planet.

    For Saturn (80x52), the planet disc is centered using the smaller dimension.
    For all others, img_w == img_h == planet diameter.

    Uses sphere projection: the strip is mapped onto a circle, with horizontal
    compression at the edges to simulate a sphere.
    """
    strip_h, strip_w = strip.shape[:2]
    # The planet disc diameter is the smaller of w/h
    diameter = min(img_w, img_h)
    radius = diameter / 2.0
    cx = img_w / 2.0
    cy = img_h / 2.0

    result = np.zeros((img_h, img_w, 4), dtype=np.uint8)

    # How far to shift the strip this frame
    shift = frame * strip_w / total_frames

    for py in range(img_h):
        dy = py - cy + 0.5
        if abs(dy) >= radius:
            continue
        # Half-width of the circle at this scanline
        half_w = math.sqrt(radius * radius - dy * dy)

        for px in range(img_w):
            dx = px - cx + 0.5
            if abs(dx) >= half_w:
                continue

            # Sphere projection: map dx to longitude
            # dx / half_w ranges from -1 to 1
            norm_x = dx / half_w  # -1..1
            # Asin projection for 3D sphere feel
            lon = math.asin(max(-1, min(1, norm_x))) / (math.pi / 2)  # -1..1
            # Map to strip x coordinate
            strip_x = ((lon + 1) / 2 * diameter + shift) % strip_w
            # Map dy to strip y
            norm_y = (dy + radius) / diameter
            strip_y = norm_y * strip_h

            sx = int(strip_x) % strip_w
            sy = int(strip_y) % strip_h

            pixel = strip[sy, sx].copy()

            # Lighting: left side lit, right side shadow
            # norm_x: -1 (left) to 1 (right)
            light = 1.0 - norm_x * 0.25  # left brighter, right darker
            # Also darken edges (limb darkening)
            edge_dist = math.sqrt(norm_x ** 2 + (dy / radius) ** 2)
            if edge_dist > 0.7:
                limb = 1.0 - (edge_dist - 0.7) / 0.3 * 0.3
                light *= max(0.5, limb)

            pixel[0] = max(0, min(255, int(pixel[0] * light)))
            pixel[1] = max(0, min(255, int(pixel[1] * light)))
            pixel[2] = max(0, min(255, int(pixel[2] * light)))

            result[py, px] = pixel

    return result


def delete_old_frames(planet_name):
    """Delete old frame files for a planet."""
    pattern = os.path.join(OUT_DIR, f"{planet_name}_frame_*.png")
    old_files = glob.glob(pattern)
    for f in old_files:
        os.remove(f)
        # Also remove .import files
        imp = f + ".import"
        if os.path.exists(imp):
            os.remove(imp)
    if old_files:
        print(f"  Deleted {len(old_files)} old frame files for {planet_name}")


def generate_planet(name):
    """Generate all 24 frames for one planet."""
    spec = PLANETS[name]
    img_w, img_h = spec["size"]
    diameter = min(img_w, img_h)

    print(f"Generating {name} ({img_w}x{img_h}, {NUM_FRAMES} frames)...")

    # Delete old frames first
    delete_old_frames(name)

    # Create surface texture strip
    strip = STRIP_MAKERS[name](diameter)

    for frame in range(NUM_FRAMES):
        pixels = render_planet_frame(strip, img_w, img_h, frame, NUM_FRAMES)
        img = Image.fromarray(pixels, "RGBA")

        path = os.path.join(OUT_DIR, f"{name}_frame_{frame}.png")
        img.save(path)

        # Frame 0 also becomes the base sprite
        if frame == 0:
            base_path = os.path.join(OUT_DIR, f"{name}.png")
            img.save(base_path)

    print(f"  Saved {NUM_FRAMES} frames + base sprite for {name}")


if __name__ == "__main__":
    os.makedirs(OUT_DIR, exist_ok=True)

    for planet_name in PLANETS:
        generate_planet(planet_name)

    total = len(PLANETS) * NUM_FRAMES
    print(f"\nDone! Generated {total} frames for {len(PLANETS)} planets.")
