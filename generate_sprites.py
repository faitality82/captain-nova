"""Generate pixel art sprites for SpaceTrader game — Solar System edition."""
import struct, zlib, math, os, random

def create_png(width, height, pixels):
    """Create a PNG from a 2D array of (R,G,B,A) tuples."""
    def chunk(ctype, data):
        c = ctype + data
        return struct.pack('>I', len(data)) + c + struct.pack('>I', zlib.crc32(c) & 0xffffffff)
    raw = b''
    for y in range(height):
        raw += b'\x00'
        for x in range(width):
            raw += bytes(pixels[y][x])
    return (b'\x89PNG\r\n\x1a\n' +
            chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)) +
            chunk(b'IDAT', zlib.compress(raw)) +
            chunk(b'IEND', b''))

def dist(x1, y1, x2, y2):
    return math.sqrt((x1-x2)**2 + (y1-y2)**2)

T = (0, 0, 0, 0)  # transparent

def make_sphere(w, h, base, light, dark, band_color=None, band_freq=8, band_width=2, atmo=None, atmo_size=3):
    """Generic planet sphere with shading, optional bands and atmosphere."""
    px = [[T]*w for _ in range(h)]
    cx, cy = w // 2, h // 2
    radius = min(cx, cy) - 2
    if atmo is None:
        atmo = (base[0], base[1], base[2], 60)

    for y in range(h):
        for x in range(w):
            d = dist(x, y, cx, cy)
            if d <= radius:
                nx = (x - cx) / radius
                ny = (y - cy) / radius
                shade = max(0, -nx * 0.5 - ny * 0.5 + 0.3)
                r = int(base[0] + (light[0] - base[0]) * shade)
                g = int(base[1] + (light[1] - base[1]) * shade)
                b = int(base[2] + (light[2] - base[2]) * shade)
                # Surface bands
                if band_color and int(y + math.sin(x * 0.3) * 3) % band_freq < band_width:
                    r = int(r * 0.7 + band_color[0] * 0.3)
                    g = int(g * 0.7 + band_color[1] * 0.3)
                    b = int(b * 0.7 + band_color[2] * 0.3)
                # Dark edge
                edge_fade = max(0, (d - radius * 0.85) / (radius * 0.15))
                r = int(r * (1 - edge_fade * 0.4))
                g = int(g * (1 - edge_fade * 0.4))
                b = int(b * (1 - edge_fade * 0.4))
                px[y][x] = (min(255, max(0, r)), min(255, max(0, g)), min(255, max(0, b)), 255)
            elif d <= radius + atmo_size:
                alpha = int(atmo[3] * (1 - (d - radius) / atmo_size))
                px[y][x] = (atmo[0], atmo[1], atmo[2], max(0, alpha))
    return px

# ─── SUN (96x96) ── bright yellow-orange with corona ───
def make_sun():
    w, h = 96, 96
    px = [[T]*w for _ in range(h)]
    cx, cy = 47, 47
    radius = 38
    for y in range(h):
        for x in range(w):
            d = dist(x, y, cx, cy)
            if d <= radius:
                nx = (x - cx) / radius
                ny = (y - cy) / radius
                shade = max(0, -nx * 0.3 - ny * 0.3 + 0.5)
                r = 255
                g = int(200 + 55 * shade)
                b = int(50 + 80 * shade)
                # Sunspot-like detail
                random.seed(int(x * 7 + y * 13))
                if random.random() < 0.03 and d < radius * 0.7:
                    r, g, b = 220, 140, 20
                px[y][x] = (min(255, r), min(255, g), min(255, max(0, b)), 255)
            elif d <= radius + 8:
                fade = (d - radius) / 8
                alpha = int(180 * (1 - fade))
                g_val = int(180 + 60 * (1 - fade))
                px[y][x] = (255, min(255, g_val), 50, max(0, alpha))
            elif d <= radius + 16:
                fade = (d - radius - 8) / 8
                alpha = int(60 * (1 - fade))
                px[y][x] = (255, 200, 80, max(0, alpha))
    return create_png(w, h, px)

# ─── MERCURY (24x24) ── small gray cratered rock ───
def make_mercury():
    w, h = 24, 24
    base = (160, 155, 145, 255)
    light = (200, 195, 185, 255)
    dark = (100, 95, 85, 255)
    px = make_sphere(w, h, base, light, dark, band_color=(120, 115, 105), band_freq=6, band_width=1, atmo_size=1)
    # Add craters
    cx, cy = w // 2, h // 2
    random.seed(1)
    for _ in range(5):
        cr_x = cx + random.randint(-6, 6)
        cr_y = cy + random.randint(-6, 6)
        cr_r = random.randint(1, 3)
        for y in range(max(0, cr_y - cr_r), min(h, cr_y + cr_r + 1)):
            for x in range(max(0, cr_x - cr_r), min(w, cr_x + cr_r + 1)):
                if dist(x, y, cr_x, cr_y) <= cr_r and px[y][x][3] == 255:
                    r, g, b = px[y][x][0], px[y][x][1], px[y][x][2]
                    px[y][x] = (max(0, r - 30), max(0, g - 30), max(0, b - 30), 255)
    return create_png(w, h, px)

# ─── VENUS (36x36) ── yellowish with thick hazy atmosphere ───
def make_venus():
    w, h = 36, 36
    base = (210, 180, 100, 255)
    light = (240, 220, 150, 255)
    dark = (160, 130, 60, 255)
    atmo = (240, 220, 160, 80)
    px = make_sphere(w, h, base, light, dark, band_color=(190, 160, 80), band_freq=5, band_width=2, atmo=atmo, atmo_size=4)
    return create_png(w, h, px)

# ─── EARTH (40x40) ── blue oceans, green continents ───
def make_earth():
    w, h = 40, 40
    px = [[T]*w for _ in range(h)]
    cx, cy = 19, 19
    radius = 17
    ocean = (40, 80, 180, 255)
    ocean_light = (70, 130, 220, 255)
    land = (60, 140, 60, 255)
    land_light = (90, 180, 80, 255)
    ice_cap = (220, 230, 240, 255)
    atmo = (100, 160, 255, 70)

    # Simple continent blobs
    random.seed(42)
    land_map = [[False]*w for _ in range(h)]
    blobs = [(cx - 4, cy - 2, 5), (cx + 5, cy + 3, 4), (cx - 2, cy + 6, 3), (cx + 3, cy - 5, 3)]
    for bx, by, br in blobs:
        for y in range(max(0, by - br), min(h, by + br + 1)):
            for x in range(max(0, bx - br), min(w, bx + br + 1)):
                if dist(x, y, bx, by) <= br:
                    land_map[y][x] = True

    for y in range(h):
        for x in range(w):
            d = dist(x, y, cx, cy)
            if d <= radius:
                nx = (x - cx) / radius
                ny = (y - cy) / radius
                shade = max(0, -nx * 0.5 - ny * 0.5 + 0.3)
                is_land = land_map[y][x]
                if abs(y - cy) > radius * 0.75:
                    r, g, b = ice_cap[0], ice_cap[1], ice_cap[2]
                elif is_land:
                    r = int(land[0] + (land_light[0] - land[0]) * shade)
                    g = int(land[1] + (land_light[1] - land[1]) * shade)
                    b = int(land[2] + (land_light[2] - land[2]) * shade)
                else:
                    r = int(ocean[0] + (ocean_light[0] - ocean[0]) * shade)
                    g = int(ocean[1] + (ocean_light[1] - ocean[1]) * shade)
                    b = int(ocean[2] + (ocean_light[2] - ocean[2]) * shade)
                edge_fade = max(0, (d - radius * 0.85) / (radius * 0.15))
                r = int(r * (1 - edge_fade * 0.4))
                g = int(g * (1 - edge_fade * 0.4))
                b = int(b * (1 - edge_fade * 0.4))
                px[y][x] = (min(255, max(0, r)), min(255, max(0, g)), min(255, max(0, b)), 255)
            elif d <= radius + 3:
                alpha = int(atmo[3] * (1 - (d - radius) / 3))
                px[y][x] = (atmo[0], atmo[1], atmo[2], max(0, alpha))
    return create_png(w, h, px)

# ─── MARS (32x32) ── red/orange desert with polar caps ───
def make_mars():
    w, h = 32, 32
    base = (190, 90, 40, 255)
    light = (220, 130, 70, 255)
    dark = (140, 60, 25, 255)
    atmo = (200, 130, 80, 40)
    px = make_sphere(w, h, base, light, dark, band_color=(160, 70, 30), band_freq=7, band_width=2, atmo=atmo, atmo_size=2)
    cx, cy = w // 2, h // 2
    radius = w // 2 - 2
    for y in range(h):
        for x in range(w):
            d = dist(x, y, cx, cy)
            if d <= radius and (y < cy - radius * 0.7 or y > cy + radius * 0.8):
                if px[y][x][3] == 255:
                    px[y][x] = (220, 210, 200, 255)
    return create_png(w, h, px)

# ─── JUPITER (96x96) ── orange/brown with bands and Great Red Spot ───
def make_jupiter():
    w, h = 96, 96
    px = [[T]*w for _ in range(h)]
    cx, cy = 47, 47
    radius = 44
    band_colors = [
        (200, 170, 120), (180, 130, 80), (210, 180, 140), (170, 120, 70),
        (220, 190, 150), (160, 100, 60), (200, 160, 110), (190, 140, 90),
    ]
    for y in range(h):
        for x in range(w):
            d = dist(x, y, cx, cy)
            if d <= radius:
                nx = (x - cx) / radius
                ny = (y - cy) / radius
                shade = max(0, -nx * 0.4 - ny * 0.4 + 0.3)
                band_idx = int((y - (cy - radius)) / (radius * 2) * len(band_colors))
                band_idx = min(band_idx, len(band_colors) - 1)
                bc = band_colors[band_idx]
                r = int(bc[0] + 40 * shade)
                g = int(bc[1] + 40 * shade)
                b = int(bc[2] + 40 * shade)
                # Great Red Spot
                spot_d = dist(x, y, cx + 10, cy + 8)
                if spot_d < 9:
                    r = int(200 + 30 * (1 - spot_d / 9))
                    g = int(80 + 20 * (1 - spot_d / 9))
                    b = int(50 + 10 * (1 - spot_d / 9))
                edge_fade = max(0, (d - radius * 0.85) / (radius * 0.15))
                r = int(r * (1 - edge_fade * 0.4))
                g = int(g * (1 - edge_fade * 0.4))
                b = int(b * (1 - edge_fade * 0.4))
                px[y][x] = (min(255, max(0, r)), min(255, max(0, g)), min(255, max(0, b)), 255)
            elif d <= radius + 3:
                alpha = int(40 * (1 - (d - radius) / 3))
                px[y][x] = (200, 170, 120, max(0, alpha))
    return create_png(w, h, px)

# ─── SATURN (96x64) ── golden with prominent ring system ───
def make_saturn():
    w, h = 96, 64
    px = [[T]*w for _ in range(h)]
    cx, cy = 47, 31
    body_radius = 26
    ring_inner, ring_outer = 32, 46
    ring_colors = [
        (200, 180, 140, 160), (180, 160, 120, 140), (210, 195, 160, 170),
        (170, 150, 110, 130), (190, 170, 130, 150),
    ]
    band_colors = [
        (210, 190, 130), (195, 170, 110), (220, 200, 145),
        (185, 160, 100), (210, 185, 125),
    ]

    # Draw rings behind planet
    for y in range(h):
        for x in range(w):
            dx = (x - cx)
            dy = (y - cy) * 3
            ring_d = math.sqrt(dx*dx + dy*dy)
            if ring_inner <= ring_d <= ring_outer:
                band = min(int((ring_d - ring_inner) / (ring_outer - ring_inner) * len(ring_colors)), len(ring_colors) - 1)
                px[y][x] = ring_colors[band]

    # Draw planet body
    for y in range(h):
        for x in range(w):
            d = dist(x, y, cx, cy)
            if d <= body_radius:
                nx = (x - cx) / body_radius
                ny = (y - cy) / body_radius
                shade = max(0, -nx * 0.4 - ny * 0.4 + 0.3)
                band_idx = min(int((y - (cy - body_radius)) / (body_radius * 2) * len(band_colors)), len(band_colors) - 1)
                bc = band_colors[band_idx]
                r = int(bc[0] + 30 * shade)
                g = int(bc[1] + 30 * shade)
                b = int(bc[2] + 30 * shade)
                edge_fade = max(0, (d - body_radius * 0.85) / (body_radius * 0.15))
                r = int(r * (1 - edge_fade * 0.4))
                g = int(g * (1 - edge_fade * 0.4))
                b = int(b * (1 - edge_fade * 0.4))
                px[y][x] = (min(255, max(0, r)), min(255, max(0, g)), min(255, max(0, b)), 255)

    # Redraw rings in front (below planet center only)
    for y in range(cy + 1, h):
        for x in range(w):
            dx = (x - cx)
            dy = (y - cy) * 3
            ring_d = math.sqrt(dx*dx + dy*dy)
            if ring_inner <= ring_d <= ring_outer and dist(x, y, cx, cy) > body_radius:
                band = min(int((ring_d - ring_inner) / (ring_outer - ring_inner) * len(ring_colors)), len(ring_colors) - 1)
                px[y][x] = ring_colors[band]

    return create_png(w, h, px)

# ─── URANUS (48x48) ── cyan/teal ice giant ───
def make_uranus():
    w, h = 48, 48
    base = (120, 200, 210, 255)
    light = (170, 230, 235, 255)
    dark = (70, 150, 170, 255)
    atmo = (150, 220, 230, 60)
    px = make_sphere(w, h, base, light, dark, band_color=(100, 180, 200), band_freq=10, band_width=2, atmo=atmo, atmo_size=3)
    return create_png(w, h, px)

# ─── NEPTUNE (48x48) ── deep blue with dark spot ───
def make_neptune():
    w, h = 48, 48
    base = (40, 60, 180, 255)
    light = (80, 110, 220, 255)
    dark = (20, 35, 120, 255)
    atmo = (60, 90, 200, 60)
    px = make_sphere(w, h, base, light, dark, band_color=(30, 50, 160), band_freq=9, band_width=2, atmo=atmo, atmo_size=3)
    # Great Dark Spot
    cx, cy = w // 2, h // 2
    spot_cx, spot_cy = cx - 4, cy + 3
    for y in range(h):
        for x in range(w):
            sd = dist(x, y, spot_cx, spot_cy)
            if sd < 5 and px[y][x][3] == 255:
                r, g, b = px[y][x][0], px[y][x][1], px[y][x][2]
                px[y][x] = (max(0, r - 20), max(0, g - 20), max(0, b - 30), 255)
    return create_png(w, h, px)

# ─── SHIP (32x32) ── top-down arrow/wedge shape ───
def make_ship():
    w, h = 32, 32
    px = [[T]*w for _ in range(h)]
    hull = (80, 130, 220, 255)
    hull_light = (120, 170, 255, 255)
    cockpit = (180, 220, 255, 255)
    engine = (255, 140, 50, 255)
    engine_glow = (255, 200, 80, 255)
    shape = [
        "                                ",
        "                                ",
        "                                ",
        "                                ",
        "                                ",
        "                                ",
        "                                ",
        "                                ",
        "                                ",
        "            LLLL                ",
        "         LLLHHHHLL              ",
        "   ee  LLHHHHHHHHHLL            ",
        "   eEeLLHHHHHHHHHHHLL          ",
        "   eEeHHHHHHHHHHHHHHHLC        ",
        "  eeEeHHHHHHHHHHHHHHHHLC       ",
        "  GEEeHHHHHHHHHHHHHHHHHCC      ",
        "  GEEeHHHHHHHHHHHHHHHHHCC      ",
        "  eeEeHHHHHHHHHHHHHHHHLC       ",
        "   eEeHHHHHHHHHHHHHHHLC        ",
        "   eEeLLHHHHHHHHHHHLL          ",
        "   ee  LLHHHHHHHHHLL            ",
        "         LLLHHHHLL              ",
        "            LLLL                ",
        "                                ",
        "                                ",
        "                                ",
        "                                ",
        "                                ",
        "                                ",
        "                                ",
        "                                ",
        "                                ",
    ]
    color_map = {'H': hull, 'L': hull_light, 'C': cockpit, 'e': engine, 'E': engine_glow, 'G': (255, 80, 30, 255)}
    for y in range(h):
        for x in range(w):
            ch = shape[y][x] if y < len(shape) and x < len(shape[y]) else ' '
            if ch in color_map:
                px[y][x] = color_map[ch]
    return create_png(w, h, px)

# ─── ASTEROID (32x32) ── irregular rocky shape ───
def make_asteroid():
    w, h = 32, 32
    px = [[T]*w for _ in range(h)]
    cx, cy = 15, 15
    rock = (140, 130, 120, 255)
    rock_light = (180, 170, 155, 255)
    rock_dark = (90, 85, 75, 255)
    rock_detail = (110, 100, 90, 255)
    random.seed(42)
    radii = [9 + random.randint(-3, 3) for _ in range(12)]
    for y in range(h):
        for x in range(w):
            dx, dy = x - cx, y - cy
            angle = math.atan2(dy, dx) % (2*math.pi)
            d = math.sqrt(dx*dx + dy*dy)
            idx = angle / (2*math.pi) * 12
            i0 = int(idx) % 12
            i1 = (i0 + 1) % 12
            frac = idx - int(idx)
            r = radii[i0] * (1-frac) + radii[i1] * frac
            if d <= r:
                if d > r - 2:
                    px[y][x] = rock_dark
                elif (x + y) % 5 == 0:
                    px[y][x] = rock_detail
                elif dx < 0 and dy < 0:
                    px[y][x] = rock_light
                else:
                    px[y][x] = rock
    return create_png(w, h, px)

# ─── BULLET (8x4) ── yellow energy bolt ───
def make_bullet():
    w, h = 8, 4
    px = [[T]*w for _ in range(h)]
    core = (255, 255, 200, 255)
    mid = (255, 220, 80, 255)
    edge = (255, 160, 30, 200)
    for y in range(h):
        for x in range(w):
            if 2 <= x <= 6 and 1 <= y <= 2:
                px[y][x] = core
            elif 1 <= x <= 7 and 0 <= y <= 3:
                px[y][x] = mid
            elif x == 0:
                px[y][x] = edge
    return create_png(w, h, px)

# ─── PICKUP (16x16) ── glowing diamond shape ───
def make_pickup():
    w, h = 16, 16
    px = [[T]*w for _ in range(h)]
    cx, cy = 7, 7
    white = (255, 255, 255, 255)
    glow = (255, 255, 255, 120)
    for y in range(h):
        for x in range(w):
            d = abs(x - cx) + abs(y - cy)
            if d <= 4:
                px[y][x] = white
            elif d <= 6:
                px[y][x] = glow
    return create_png(w, h, px)

# ─── ALIEN SHIP (24x24) ── menacing red triangle ───
def make_alien():
    w, h = 24, 24
    px = [[T]*w for _ in range(h)]
    hull = (180, 30, 30, 255)
    hull_light = (220, 60, 60, 255)
    cockpit = (255, 200, 50, 255)
    engine = (100, 200, 255, 255)
    # Arrow pointing left (toward player typically)
    shape = [
        "                        ",
        "                        ",
        "                        ",
        "                        ",
        "                        ",
        "                        ",
        "                        ",
        "        LL              ",
        "      LLHHLL            ",
        "    LLHHHHHHL           ",
        "   LHHHHHHHHHC          ",
        "  eEHHHHHHHHHHC        ",
        "  eEHHHHHHHHHHC        ",
        "   LHHHHHHHHHC          ",
        "    LLHHHHHHL           ",
        "      LLHHLL            ",
        "        LL              ",
        "                        ",
        "                        ",
        "                        ",
        "                        ",
        "                        ",
        "                        ",
        "                        ",
    ]
    color_map = {'H': hull, 'L': hull_light, 'C': cockpit, 'e': engine, 'E': (150, 230, 255, 255)}
    for y in range(h):
        for x in range(w):
            ch = shape[y][x] if y < len(shape) and x < len(shape[y]) else ' '
            if ch in color_map:
                px[y][x] = color_map[ch]
    return create_png(w, h, px)

# ─── SPAGHETTI MONSTER (40x40) ── blobby tentacled horror ───
def make_spaghetti_monster():
    w, h = 40, 40
    px = [[T]*w for _ in range(h)]
    cx, cy = 19, 19

    body = (180, 120, 50, 255)
    body_light = (220, 160, 80, 255)
    eye = (255, 255, 200, 255)
    pupil = (40, 0, 0, 255)
    tentacle = (160, 100, 40, 255)

    # Main body blob
    for y in range(h):
        for x in range(w):
            d = dist(x, y, cx, cy)
            # Wobbly body shape
            random.seed(int(math.atan2(y - cy, x - cx) * 100))
            wobble = random.random() * 3
            if d <= 12 + wobble:
                shade = max(0, -(x - cx) / 12 * 0.5 - (y - cy) / 12 * 0.5 + 0.3)
                r = int(body[0] + (body_light[0] - body[0]) * shade)
                g = int(body[1] + (body_light[1] - body[1]) * shade)
                b = int(body[2] + (body_light[2] - body[2]) * shade)
                px[y][x] = (min(255, r), min(255, g), min(255, b), 255)

    # Tentacles (8 directions)
    for i in range(8):
        angle = i * math.pi / 4
        for t in range(6, 16):
            tx = int(cx + math.cos(angle) * t + math.sin(t * 0.8) * 2)
            ty = int(cy + math.sin(angle) * t + math.cos(t * 0.8) * 2)
            for dy in range(-1, 2):
                for dx in range(-1, 2):
                    nx, ny = tx + dx, ty + dy
                    if 0 <= nx < w and 0 <= ny < h and px[ny][nx] == T:
                        px[ny][nx] = tentacle

    # Eyes (two big ones)
    for ex, ey in [(cx - 4, cy - 3), (cx + 4, cy - 3)]:
        for y in range(max(0, ey - 3), min(h, ey + 4)):
            for x in range(max(0, ex - 3), min(w, ex + 4)):
                d = dist(x, y, ex, ey)
                if d <= 3:
                    px[y][x] = eye
                if d <= 1.5:
                    px[y][x] = pupil

    return create_png(w, h, px)

# ─── ENEMY BULLET (6x6) ── red energy bolt ───
def make_enemy_bullet():
    w, h = 6, 6
    px = [[T]*w for _ in range(h)]
    cx, cy = 2, 2
    for y in range(h):
        for x in range(w):
            d = dist(x, y, cx, cy)
            if d <= 1.5:
                px[y][x] = (255, 100, 100, 255)
            elif d <= 2.5:
                px[y][x] = (255, 50, 50, 220)
            elif d <= 3.5:
                px[y][x] = (200, 30, 30, 100)
    return create_png(w, h, px)

# ─── MINER (16x16) ── little astronaut ───
def make_miner():
    w, h = 16, 16
    px = [[T]*w for _ in range(h)]
    # Simple top-down astronaut
    shape = [
        "                ",
        "     WWWW       ",
        "    WWWWWW      ",
        "    WGWWGW      ",
        "    WWWWWW      ",
        "     WWWW       ",
        "      WW        ",
        "    SSSSSS      ",
        "   SSSSSSSS     ",
        "   SSSWWSSS     ",
        "   SSSWWSSS     ",
        "   SSSSSSSS     ",
        "    SS  SS      ",
        "    SS  SS      ",
        "    BB  BB      ",
        "                ",
    ]
    color_map = {
        'W': (240, 240, 240, 255),  # white suit
        'G': (100, 180, 255, 255),  # visor
        'S': (200, 200, 200, 255),  # suit body
        'B': (140, 140, 140, 255),  # boots
    }
    for y in range(h):
        for x in range(w):
            ch = shape[y][x] if y < len(shape) and x < len(shape[y]) else ' '
            if ch in color_map:
                px[y][x] = color_map[ch]
    return create_png(w, h, px)

# ─── MINE NODE (12x12) ── glowing resource crystal ───
def make_mine_node():
    w, h = 12, 12
    px = [[T]*w for _ in range(h)]
    cx, cy = 5, 5
    # Diamond/crystal shape
    for y in range(h):
        for x in range(w):
            d = abs(x - cx) + abs(y - cy)
            if d <= 3:
                px[y][x] = (255, 255, 255, 255)
            elif d <= 4:
                px[y][x] = (200, 200, 200, 200)
            elif d <= 5:
                px[y][x] = (150, 150, 150, 100)
    return create_png(w, h, px)

# ─── LASER BOLT (12x2) ── thin green energy beam ───
def make_laser_bullet():
    w, h = 12, 2
    px = [[T]*w for _ in range(h)]
    core = (150, 255, 150, 255)
    bright = (100, 220, 100, 255)
    edge = (50, 180, 50, 180)
    for y in range(h):
        for x in range(w):
            if 2 <= x <= 10:
                px[y][x] = core
            elif x == 1 or x == 11:
                px[y][x] = bright
            else:
                px[y][x] = edge
    return create_png(w, h, px)

# ─── PILOT PORTRAIT (32x32) ── Captain Nova face portrait ───
def make_pilot():
    w, h = 32, 32
    px = [[T]*w for _ in range(h)]
    # Hair (dark brown, flowing)
    hair = (60, 30, 15, 255)
    hair_light = (90, 50, 25, 255)
    # Skin
    skin = (220, 180, 150, 255)
    skin_light = (240, 200, 170, 255)
    skin_shadow = (190, 150, 120, 255)
    # Eyes
    eye_white = (240, 240, 245, 255)
    iris = (50, 120, 180, 255)
    pupil_c = (20, 20, 30, 255)
    # Lips
    lips = (200, 100, 100, 255)
    # Suit collar
    suit = (80, 130, 220, 255)
    suit_light = (100, 150, 240, 255)

    shape = [
        "                                ",
        "        hhhhhhhhh               ",
        "       hhHHHHHHHhh              ",
        "      hhHHHHHHHHHhh             ",
        "     hhHHHHHHHHHHHh             ",
        "     hHHHHHHHHHHHHh             ",
        "     hHHssssssssHHh             ",
        "     hHssSsssSssHHh             ",
        "     hHssssssssssHh             ",
        "     hHsswEswEsssHh             ",
        "      hssswsswsssHh             ",
        "      hssssssssssh              ",
        "      hssssNsssssh              ",
        "      hsssLLLssssh              ",
        "       hsssssssh                ",
        "       hhssssshhh               ",
        "        hhssshh                 ",
        "      hhhh  hhhh               ",
        "     hhHHH  HHHhh              ",
        "    SSSSSSSSSSSSSSs             ",
        "   SsSSSSSSSSSSSSSSs            ",
        "   SSSSSSSSSSSSSSSSS            ",
        "   SSSSSSSSSSSSSSSSS            ",
        "                                ",
        "                                ",
        "                                ",
        "                                ",
        "                                ",
        "                                ",
        "                                ",
        "                                ",
        "                                ",
    ]
    color_map = {
        'h': hair, 'H': hair_light,
        's': skin, 'S': suit, 'L': lips,
        'w': eye_white, 'E': iris,
        'N': skin_shadow,
    }
    for y in range(h):
        for x in range(w):
            ch = shape[y][x] if y < len(shape) and x < len(shape[y]) else ' '
            if ch in color_map:
                px[y][x] = color_map[ch]
    return create_png(w, h, px)

# ─── SHIELD BULLET (10x10) ── cyan glowing orb ───
def make_shield_bullet():
    w, h = 10, 10
    px = [[T]*w for _ in range(h)]
    cx, cy = 4, 4
    for y in range(h):
        for x in range(w):
            d = dist(x, y, cx, cy)
            if d <= 2.5:
                px[y][x] = (200, 255, 255, 255)
            elif d <= 3.5:
                px[y][x] = (80, 220, 255, 255)
            elif d <= 4.5:
                alpha = int(180 * (1 - (d - 3.5)))
                px[y][x] = (50, 180, 255, max(0, alpha))
    return create_png(w, h, px)

# ─── SHIELD PICKUP (20x20) ── shield icon with cyan glow ───
def make_shield_pickup():
    w, h = 20, 20
    px = [[T]*w for _ in range(h)]
    cx, cy = 9, 9
    for y in range(h):
        for x in range(w):
            d = dist(x, y, cx, cy)
            if d <= 8 and d >= 6:
                px[y][x] = (60, 200, 255, 200)
            elif d <= 9 and d >= 5:
                alpha = int(100 * (1 - abs(d - 7) / 2))
                px[y][x] = (40, 160, 255, max(0, alpha))
    for y in range(h):
        for x in range(w):
            d = abs(x - cx) + abs(y - cy)
            if d <= 4:
                px[y][x] = (180, 255, 255, 255)
            elif d <= 5:
                existing = px[y][x]
                if existing[3] < 200:
                    px[y][x] = (120, 230, 255, 220)
    return create_png(w, h, px)

# ─── BOSS (64x64) ── menacing dark red dreadnought ───
def make_boss():
    w, h = 64, 64
    px = [[T]*w for _ in range(h)]
    hull = (120, 20, 20, 255)
    hull_light = (180, 40, 40, 255)
    hull_dark = (60, 10, 10, 255)
    cockpit = (255, 200, 50, 255)
    engine = (100, 200, 255, 255)
    engine_glow = (150, 230, 255, 255)
    armor = (80, 15, 15, 255)

    # Main body — big angular wedge
    cx, cy = 31, 31
    for y in range(h):
        for x in range(w):
            # Wedge shape: wider at back, pointed at front
            rel_x = x - 8
            rel_y = abs(y - cy)
            max_width_at_x = int(24 - rel_x * 0.35) if rel_x >= 0 else 0
            if 8 <= x <= 56 and rel_y <= max_width_at_x:
                # Shading
                shade = max(0, (x - 8) / 48)
                r = int(hull[0] + (hull_light[0] - hull[0]) * shade)
                g = int(hull[1] + (hull_light[1] - hull[1]) * shade)
                b = int(hull[2] + (hull_light[2] - hull[2]) * shade)
                # Armor plating lines
                if y % 8 == 0 or x % 12 == 0:
                    r, g, b = armor[0], armor[1], armor[2]
                # Edge darkening
                edge = rel_y / max(1, max_width_at_x)
                if edge > 0.7:
                    factor = 1.0 - (edge - 0.7) / 0.3 * 0.5
                    r = int(r * factor)
                    g = int(g * factor)
                    b = int(b * factor)
                px[y][x] = (min(255, max(0, r)), min(255, max(0, g)), min(255, max(0, b)), 255)

    # Cockpit (glowing eye)
    for y in range(cy - 3, cy + 4):
        for x in range(48, 55):
            d = dist(x, y, 51, cy)
            if d <= 3:
                px[y][x] = cockpit
            elif d <= 4:
                px[y][x] = (200, 150, 30, 200)

    # Engines (three at rear)
    for ey in [cy - 10, cy, cy + 10]:
        for y in range(max(0, ey - 2), min(h, ey + 3)):
            for x in range(4, 12):
                d = dist(x, y, 8, ey)
                if d <= 3:
                    px[y][x] = engine_glow if d <= 1.5 else engine

    # Wing spikes
    for spike_y_dir in [-1, 1]:
        for i in range(12):
            sx = 20 + i * 2
            sy = cy + spike_y_dir * (15 + i)
            if 0 <= sy < h and 0 <= sx < w:
                for dy in range(-1, 2):
                    ny = sy + dy
                    if 0 <= ny < h:
                        px[ny][sx] = hull_dark

    return create_png(w, h, px)

# ─── Write all sprites ───
os.makedirs('assets/sprites', exist_ok=True)

sprites = {
    'ship': make_ship,
    'asteroid': make_asteroid,
    'bullet': make_bullet,
    'pickup': make_pickup,
    'sun': make_sun,
    'mercury': make_mercury,
    'venus': make_venus,
    'earth': make_earth,
    'mars': make_mars,
    'jupiter': make_jupiter,
    'saturn': make_saturn,
    'uranus': make_uranus,
    'neptune': make_neptune,
    'alien': make_alien,
    'spaghetti_monster': make_spaghetti_monster,
    'enemy_bullet': make_enemy_bullet,
    'miner': make_miner,
    'mine_node': make_mine_node,
    'laser_bullet': make_laser_bullet,
    'pilot': make_pilot,
    'shield_bullet': make_shield_bullet,
    'shield_pickup': make_shield_pickup,
    'boss': make_boss,
}

print("Generating sprites...")
for name, func in sprites.items():
    data = func()
    with open(f'assets/sprites/{name}.png', 'wb') as f:
        f.write(data)
    size = len(data)
    print(f"  {name}.png: {size} bytes")

print("All sprites generated!")
