"""Generate detailed 48x48 pixel art spaceship with idle/thrust/boost animations.
Supports 4 visual tiers (0-3) based on total upgrades purchased."""
from PIL import Image
import numpy as np


# ═══ COLOR PALETTES PER TIER ═══
TIER_PALETTES = {
    0: {  # Base: blue-gray standard
        "hull": ([30,42,65], [45,62,92], [68,95,135], [100,135,175], [140,170,205], [180,200,225]),
        "trim": [25, 35, 55],
        "wing": ([38,52,78], [55,75,108], [75,100,140], [95,120,160]),
        "stripe": ([160,50,30], [210,75,40], [240,110,50]),
        "nav_green": [80, 255, 80],
        "nav_red": [255, 80, 80],
    },
    1: {  # Silver: sleek upgrade
        "hull": ([50,55,65], [80,88,100], [120,130,145], [155,165,180], [185,195,210], [215,225,235]),
        "trim": [35, 38, 48],
        "wing": ([55,60,72], [80,88,105], [110,120,140], [135,145,165]),
        "stripe": ([30,100,200], [50,140,240], [80,170,255]),  # blue stripe
        "nav_green": [80, 255, 120],
        "nav_red": [255, 80, 80],
    },
    2: {  # Gold: veteran trader
        "hull": ([55,42,20], [85,65,30], [130,100,45], [170,135,55], [200,165,75], [225,195,110]),
        "trim": [40, 30, 15],
        "wing": ([60,48,25], [90,70,35], [120,95,50], [150,120,70]),
        "stripe": ([200,200,200], [230,230,230], [255,255,255]),  # white stripe
        "nav_green": [80, 255, 80],
        "nav_red": [255, 80, 80],
    },
    3: {  # Crimson: elite
        "hull": ([65,20,20], [100,30,30], [145,45,45], [180,60,55], [210,85,75], [235,120,100]),
        "trim": [45, 15, 15],
        "wing": ([70,25,25], [100,40,38], [135,60,55], [165,85,75]),
        "stripe": ([255,200,50], [255,220,80], [255,240,120]),  # gold stripe
        "nav_green": [120, 255, 120],
        "nav_red": [255, 120, 120],
    },
}


def create_detailed_ship(tier=0):
    px = np.zeros((48, 48, 4), dtype=np.uint8)
    pal = TIER_PALETTES[tier]

    hull_darkest, hull_dark, hull_mid, hull_light, hull_highlight, hull_shine = [
        c + [255] for c in pal["hull"]
    ]
    trim_dark = pal["trim"] + [255]
    wing_dark, wing_mid, wing_light, wing_edge = [c + [255] for c in pal["wing"]]
    stripe_dark, stripe_mid, stripe_light = [c + [255] for c in pal["stripe"]]

    # Fixed colors
    glass_dark = [40, 140, 170, 255]
    glass_mid = [80, 190, 220, 255]
    glass_light = [140, 225, 245, 255]
    glass_shine = [220, 250, 255, 255]
    eng_dark = [35, 35, 50, 255]
    eng_mid = [55, 55, 70, 255]
    eng_light = [75, 75, 95, 255]
    eng_rim = [90, 100, 130, 255]
    eng_inner = [20, 20, 35, 255]
    weapon_dark = [50, 50, 60, 255]
    weapon_light = [80, 80, 100, 255]
    weapon_tip = [200, 60, 60, 255]
    panel = [max(0, c - 20) for c in pal["trim"]] + [255]
    antenna = [120, 140, 170, 255]
    antenna_tip = [255, 80, 80, 255]

    # Higher tier = brighter engine rims
    if tier >= 2:
        eng_rim = [120, 130, 160, 255]
        eng_light = [90, 90, 110, 255]
    if tier >= 3:
        eng_rim = [140, 100, 100, 255]
        weapon_tip = [255, 200, 50, 255]  # gold weapon tips

    def hline(y, x1, x2, color):
        for x in range(x1, x2 + 1):
            if 0 <= x < 48 and 0 <= y < 48:
                px[y, x] = color

    def sp(y, x, color):
        if 0 <= x < 48 and 0 <= y < 48:
            px[y, x] = color

    # === MAIN FUSELAGE ===
    for r in range(20, 29):
        for c in range(14, 37):
            if r < 22:
                px[r, c] = hull_light
            elif r < 25:
                px[r, c] = hull_mid
            else:
                px[r, c] = hull_dark

    hline(19, 16, 36, trim_dark)
    hline(29, 16, 36, trim_dark)
    for r in range(20, 29):
        sp(r, 13, trim_dark)

    hline(20, 17, 35, hull_highlight)
    hline(21, 16, 36, hull_shine)
    hline(23, 18, 34, panel)
    hline(26, 18, 34, panel)

    for r in range(20, 29):
        sp(r, 22, panel)
        sp(r, 30, panel)

    for c in [20, 25, 28, 33]:
        sp(22, c, hull_shine)
        sp(27, c, eng_mid)

    # === NOSE ===
    for c in range(36, 40):
        depth = c - 36
        for r in range(21 + depth, 28 - depth):
            px[r, c] = hull_light
    sp(23, 40, hull_highlight)
    sp(24, 41, hull_shine)
    sp(25, 41, hull_shine)
    sp(24, 42, hull_highlight)
    sp(25, 42, hull_highlight)
    sp(24, 43, antenna)
    sp(25, 43, antenna)

    for c in range(36, 40):
        depth = c - 36
        sp(27 - depth, c, hull_dark)

    for c in range(37, 41):
        depth = c - 36
        sp(20 + depth, c, trim_dark)
        sp(29 - depth, c, trim_dark)

    # === COCKPIT ===
    sp(19, 32, glass_dark)
    sp(19, 33, glass_mid)
    sp(19, 34, glass_mid)
    sp(19, 35, glass_light)
    sp(19, 36, glass_mid)
    sp(20, 33, glass_mid)
    sp(20, 34, glass_light)
    sp(20, 35, glass_shine)
    sp(20, 36, glass_light)
    sp(20, 37, glass_mid)
    sp(21, 34, glass_mid)
    sp(21, 35, glass_light)
    sp(21, 36, glass_shine)
    sp(21, 37, glass_light)
    sp(21, 38, glass_dark)

    for c in range(32, 37):
        sp(18, c, trim_dark)
    sp(19, 31, trim_dark)
    sp(19, 37, trim_dark)
    sp(20, 32, trim_dark)
    sp(20, 38, trim_dark)
    sp(21, 33, trim_dark)
    sp(21, 39, trim_dark)

    # === RACING STRIPES ===
    hline(24, 15, 40, stripe_mid)
    hline(25, 15, 40, stripe_dark)
    for c in range(20, 38, 3):
        sp(24, c, stripe_light)

    # === TOP WING ===
    for r in range(12, 20):
        ws = 10 + (19 - r) * 2 // 3
        we = min(28, 14 + (19 - r))
        for c in range(ws, we):
            px[r, c] = wing_mid if r < 15 else wing_dark
        sp(r, ws, wing_edge)
        sp(r, ws + 1, wing_light)

    sp(11, 13, wing_edge)
    sp(11, 14, wing_mid)
    sp(10, 14, wing_edge)
    sp(10, 15, wing_light)
    sp(9, 15, wing_edge)

    for r in range(13, 19):
        sp(r, 18, panel)
    sp(14, 16, wing_light)
    sp(16, 14, wing_light)
    hline(19, 14, 22, trim_dark)

    sp(11, 12, weapon_dark)
    sp(10, 13, weapon_dark)
    sp(9, 14, weapon_light)
    sp(9, 13, weapon_tip)

    # === BOTTOM WING ===
    for r in range(29, 37):
        ws = 10 + (r - 29) * 2 // 3
        we = min(28, 14 + (r - 29))
        for c in range(ws, we):
            px[r, c] = wing_mid if r > 33 else wing_dark
        sp(r, ws, wing_edge)
        sp(r, ws + 1, wing_light)

    sp(37, 13, wing_edge)
    sp(37, 14, wing_mid)
    sp(38, 14, wing_edge)
    sp(38, 15, wing_light)
    sp(39, 15, wing_edge)

    for r in range(30, 36):
        sp(r, 18, panel)
    hline(29, 14, 22, trim_dark)

    sp(37, 12, weapon_dark)
    sp(38, 13, weapon_dark)
    sp(39, 14, weapon_light)
    sp(39, 13, weapon_tip)

    # === ENGINE SECTION ===
    for r in range(21, 28):
        for c in range(8, 14):
            px[r, c] = eng_dark if c < 10 else (eng_mid if c < 12 else eng_light)

    for r in range(20, 29):
        sp(r, 8, eng_rim)
    sp(20, 9, eng_rim)
    sp(20, 10, eng_rim)
    sp(28, 9, eng_rim)
    sp(28, 10, eng_rim)

    for r in range(22, 27):
        sp(r, 8, eng_inner)
        sp(r, 7, eng_inner)

    for r in range(16, 20):
        for c in range(12, 16):
            px[r, c] = eng_mid
    sp(16, 12, eng_rim)
    sp(16, 13, eng_rim)
    for r in range(17, 20):
        sp(r, 11, eng_inner)
        sp(r, 12, eng_dark)

    for r in range(29, 33):
        for c in range(12, 16):
            px[r, c] = eng_mid
    sp(32, 12, eng_rim)
    sp(32, 13, eng_rim)
    for r in range(29, 32):
        sp(r, 11, eng_inner)
        sp(r, 12, eng_dark)

    # === TIER-SPECIFIC EXTRAS ===
    if tier >= 1:
        # Extra armor plating on nose
        sp(22, 38, hull_highlight)
        sp(23, 39, hull_highlight)
        # Reinforced wing edges
        for r in range(13, 18):
            ws = 10 + (19 - r) * 2 // 3
            sp(r, ws, hull_shine)

    if tier >= 2:
        # Belly cannon (visible under fuselage)
        sp(29, 24, weapon_dark)
        sp(30, 24, weapon_light)
        sp(31, 24, weapon_tip)
        # Dorsal sensor array
        sp(18, 28, antenna)
        sp(17, 28, antenna)
        sp(17, 29, antenna_tip)

    if tier >= 3:
        # Shield emitter glow on wingtips
        sp(9, 12, [100, 180, 255, 200])
        sp(8, 15, [100, 180, 255, 150])
        sp(39, 12, [100, 180, 255, 200])
        sp(40, 15, [100, 180, 255, 150])
        # Extra engine detail
        sp(20, 7, eng_rim)
        sp(28, 7, eng_rim)

    # Antenna & vents
    sp(17, 30, antenna)
    sp(16, 31, antenna)
    sp(15, 31, antenna_tip)
    for c in range(25, 29):
        sp(28, c, eng_mid)

    # Navigation lights
    sp(20, 16, pal["nav_green"] + [255])
    sp(28, 16, pal["nav_red"] + [255])

    return px


def add_idle_glow(base, intensity):
    px = base.copy()
    def sp(y, x, color):
        if 0 <= x < 48 and 0 <= y < 48:
            px[y, x] = color
    ga = 140 + intensity * 40
    gb = 100 + intensity * 30
    for r in range(22, 27):
        sp(r, 7, [180 + intensity * 25, 100 + intensity * 15, 30, ga])
        sp(r, 6, [140 + intensity * 30, 70 + intensity * 15, 20, gb])
    for r in range(17, 20):
        sp(r, 11, [160 + intensity * 30, 90 + intensity * 15, 25, gb])
        sp(r, 10, [120 + intensity * 25, 60 + intensity * 10, 15, max(0, gb - 40)])
    for r in range(29, 32):
        sp(r, 11, [160 + intensity * 30, 90 + intensity * 15, 25, gb])
        sp(r, 10, [120 + intensity * 25, 60 + intensity * 10, 15, max(0, gb - 40)])
    return px


def add_thrust_flame(base, frame):
    px = base.copy()
    def sp(y, x, color):
        if 0 <= x < 48 and 0 <= y < 48:
            px[y, x] = color

    core = [255, 245, 180, 255]
    hot = [255, 200, 80, 255]
    mid = [255, 140, 40, 240]
    outer = [255, 90, 25, 200]
    tip = [220, 60, 15, 140]
    wisp = [180, 40, 10, 80]
    colors = [core, hot, mid, outer, tip, wisp]

    lengths = [(3, 2, 2), (5, 3, 3), (4, 3, 2), (6, 4, 4)]
    main_len, top_len, bot_len = lengths[frame % 4]

    for r in range(22, 27):
        sp(r, 7, core)
        sp(r, 8, hot)
        for d in range(main_len):
            c = 6 - d
            ci = min(d, len(colors) - 1)
            sp(r, c, colors[ci])
    sp(21, 7, [255, 180, 60, 100])
    sp(27, 7, [255, 180, 60, 100])

    for r in range(17, 20):
        sp(r, 11, core)
        sp(r, 12, hot)
        for d in range(top_len):
            c = 10 - d
            ci = min(d, len(colors) - 1)
            sp(r, c, colors[ci])

    for r in range(29, 32):
        sp(r, 11, core)
        sp(r, 12, hot)
        for d in range(bot_len):
            c = 10 - d
            ci = min(d, len(colors) - 1)
            sp(r, c, colors[ci])

    if frame == 1 or frame == 3:
        sp(24, max(0, 6 - main_len), wisp)
        sp(16, 10, [255, 150, 40, 80])
        sp(32, 10, [255, 150, 40, 80])

    return px


def add_boost_flame(base, frame):
    px = base.copy()
    def sp(y, x, color):
        if 0 <= x < 48 and 0 <= y < 48:
            px[y, x] = color

    white = [255, 255, 245, 255]
    core = [255, 245, 180, 255]
    hot = [255, 210, 100, 255]
    mid_c = [255, 150, 50, 245]
    outer = [255, 100, 30, 210]
    tip = [230, 65, 20, 160]
    wisp = [190, 45, 12, 90]
    faint = [150, 35, 8, 50]
    colors = [white, core, hot, mid_c, outer, tip, wisp, faint]

    main_len = 7 + frame
    for r in range(21, 28):
        for d in range(main_len):
            c = 7 - d
            ci = min(d, len(colors) - 1)
            sp(r, c, colors[ci])
    for r in range(22, 27):
        sp(r, 7, white)
        sp(r, 8, white)
    for d in range(4):
        sp(20, 6 - d, [255, 160, 50, max(0, 120 - d * 25)])
        sp(28, 6 - d, [255, 160, 50, max(0, 120 - d * 25)])

    top_len = 5 + frame
    for r in range(16, 21):
        sp(r, 11, white)
        sp(r, 12, core)
        for d in range(top_len):
            c = 11 - d
            ci = min(d, len(colors) - 1)
            sp(r, c, colors[ci])
    for r in range(28, 33):
        sp(r, 11, white)
        sp(r, 12, core)
        for d in range(top_len):
            c = 11 - d
            ci = min(d, len(colors) - 1)
            sp(r, c, colors[ci])

    if frame == 1:
        for r in range(19, 30):
            sp(r, 0, faint)
        sp(15, 10, [255, 120, 30, 60])
        sp(33, 10, [255, 120, 30, 60])

    return px


if __name__ == "__main__":
    out_dir = "C:/Users/Faita/Documents/SpaceTrader/assets/sprites"

    for tier in range(4):
        base = create_detailed_ship(tier)
        prefix = f"ship_t{tier}"

        all_frames = []
        for i in range(3):
            all_frames.append(("idle", i, add_idle_glow(base, i)))
        for i in range(4):
            all_frames.append(("thrust", i, add_thrust_flame(base, i)))
        for i in range(2):
            all_frames.append(("boost", i, add_boost_flame(base, i)))

        for name, idx, pixels in all_frames:
            img = Image.fromarray(pixels)
            path = f"{out_dir}/{prefix}_{name}_{idx}.png"
            img.save(path)

        print(f"Tier {tier}: saved {len(all_frames)} frames ({prefix}_*)")

    # Also save tier 0 as the base ship frames (for backward compat)
    base0 = create_detailed_ship(0)
    for i in range(3):
        Image.fromarray(add_idle_glow(base0, i)).save(f"{out_dir}/ship_idle_{i}.png")
    for i in range(4):
        Image.fromarray(add_thrust_flame(base0, i)).save(f"{out_dir}/ship_thrust_{i}.png")
    for i in range(2):
        Image.fromarray(add_boost_flame(base0, i)).save(f"{out_dir}/ship_boost_{i}.png")
    Image.fromarray(add_idle_glow(base0, 1)).save(f"{out_dir}/ship.png")

    print("\nAlso saved base ship_idle/thrust/boost + ship.png")
    print("Done! 4 tiers x 9 frames = 36 tier frames + 9 base frames")
