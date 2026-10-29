"""Generate Captain Nova 32x32 pixel art sprites for the city platformer scene.
Produces 8 animation frames: idle(2), walk(4), jump(2)."""
from PIL import Image
import os

# ═══ COLOR PALETTE ═══
T = (0, 0, 0, 0)           # Transparent
SKIN    = (210, 170, 140, 255)
HAIR    = (35, 25, 30, 255)
VISOR   = (0, 230, 255, 255)    # Neon cyan glow
VISOR_D = (0, 150, 200, 255)    # Visor dark
JACK_D  = (35, 40, 55, 255)     # Jacket dark
JACK_M  = (50, 55, 70, 255)     # Jacket mid
JACK_L  = (65, 70, 85, 255)     # Jacket light
BELT    = (80, 60, 40, 255)
BUCKLE  = (200, 180, 100, 255)
PANTS   = (40, 42, 50, 255)
BOOTS   = (30, 28, 35, 255)
CYAN_T  = (0, 200, 230, 255)    # Cyan trim
OUTLINE = (20, 18, 25, 255)     # Subtle dark outline

# ═══ NEW ENHANCED COLORS ═══
VISOR_GLOW  = (100, 240, 255, 255)   # Bright visor highlight
ENERGY      = (0, 180, 220, 180)     # Translucent energy lines
BOOT_GLOW   = (0, 200, 230, 200)     # Thruster glow on boots
HAIR_HI     = (55, 45, 50, 255)      # Hair highlight
SKIN_SHADOW = (180, 140, 110, 255)   # Skin shadow
JACK_ACCENT = (0, 160, 200, 255)     # Jacket accent stripe
VISOR_GLOW_DIM = (60, 180, 200, 120) # Dimmed visor glow for ambient
WHITE_HI    = (240, 250, 255, 255)   # White specular highlight
MOTION_BLUR = (30, 30, 40, 100)      # Dim trailing pixel for walk
WIND_STREAK = (80, 120, 140, 80)     # Dim wind lines for falling

OUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                       "assets", "sprites")


def make_image():
    """Create a blank 32x32 RGBA image."""
    return Image.new("RGBA", (32, 32), T)


def px(img, x, y, color):
    """Set a single pixel if in bounds."""
    if 0 <= x < 32 and 0 <= y < 32:
        img.putpixel((x, y), color)


def hline(img, y, x1, x2, color):
    """Draw a horizontal line from x1 to x2 inclusive."""
    for x in range(x1, x2 + 1):
        px(img, x, y, color)


def draw_outline_base(img):
    """Add subtle outline pixels around key contour points of the base pose."""
    # Top of head
    px(img, 12, 1, OUTLINE)
    px(img, 18, 1, OUTLINE)
    hline(img, 1, 13, 17, OUTLINE)

    # Head sides
    px(img, 10, 5, OUTLINE)
    px(img, 10, 6, OUTLINE)
    px(img, 10, 7, OUTLINE)

    # Shoulder edges
    px(img, 9, 11, OUTLINE)
    px(img, 22, 11, OUTLINE)

    # Boot bottom edges
    px(img, 10, 30, OUTLINE)
    px(img, 16, 30, OUTLINE)
    px(img, 22, 30, OUTLINE)


def draw_visor_glow(img, visor_row=6):
    """Add glow effect above and below the visor, plus a specular highlight."""
    # Glow above visor (row above)
    px(img, 13, visor_row - 1, VISOR_GLOW_DIM)
    px(img, 15, visor_row - 1, VISOR_GLOW_DIM)
    px(img, 17, visor_row - 1, VISOR_GLOW_DIM)

    # Glow below visor (row below)
    px(img, 14, visor_row + 1, VISOR_GLOW_DIM)
    px(img, 16, visor_row + 1, VISOR_GLOW_DIM)

    # White specular highlight on visor
    px(img, 14, visor_row, WHITE_HI)
    px(img, 15, visor_row, VISOR_GLOW)


def draw_jacket_energy(img, row_start=11, row_end=15):
    """Draw cyan accent stripes on the jacket."""
    # Vertical accent stripe at x=13
    for y in range(row_start, row_end + 1):
        px(img, 13, y, JACK_ACCENT)

    # Shoulder pips
    px(img, 11, row_start, JACK_ACCENT)
    px(img, 20, row_start, JACK_ACCENT)


def draw_boot_glow(img, left_x=11, right_x=17, glow_row=30):
    """Draw thruster glow below boots."""
    # Left boot glow
    px(img, left_x + 1, glow_row, BOOT_GLOW)
    px(img, left_x + 2, glow_row, BOOT_GLOW)
    px(img, left_x + 3, glow_row, BOOT_GLOW)

    # Right boot glow
    px(img, right_x + 1, glow_row, BOOT_GLOW)
    px(img, right_x + 2, glow_row, BOOT_GLOW)
    px(img, right_x + 3, glow_row, BOOT_GLOW)


def draw_base_nova(img):
    """Draw the base idle pose (nova_idle_0) facing RIGHT.

    Layout (0-indexed rows):
      Row 2-3:   Top of hair
      Row 4-8:   Head with visor, ponytail extending right
      Row 9-18:  Torso with jacket, belt
      Row 19-26: Legs (pants)
      Row 27-29: Boots
    """
    # --- HAIR top ---
    # Row 2: top of hair
    hline(img, 2, 13, 17, HAIR)
    # Row 3: hair wider
    hline(img, 3, 12, 18, HAIR)
    # Hair highlight on top
    px(img, 14, 2, HAIR_HI)
    px(img, 16, 2, HAIR_HI)
    px(img, 13, 3, HAIR_HI)
    px(img, 17, 3, HAIR_HI)

    # --- HEAD rows 4-8 ---
    # Row 4: hair with skin forehead peeking
    hline(img, 4, 11, 19, HAIR)
    px(img, 20, 4, HAIR)  # ponytail start
    px(img, 15, 4, HAIR_HI)  # hair highlight

    # Row 5: forehead - hair outline, skin, hair on right for ponytail
    px(img, 11, 5, HAIR)
    hline(img, 5, 12, 18, SKIN)
    hline(img, 5, 19, 22, HAIR)  # ponytail extends right
    px(img, 21, 5, HAIR_HI)  # ponytail highlight

    # Row 6: VISOR row (signature feature) - full width of face
    px(img, 11, 6, HAIR)
    px(img, 12, 6, VISOR_D)
    hline(img, 6, 13, 17, VISOR)
    px(img, 18, 6, VISOR_D)
    hline(img, 6, 19, 23, HAIR)  # ponytail
    px(img, 22, 6, HAIR_HI)  # ponytail highlight

    # Visor glow and specular highlight
    draw_visor_glow(img, visor_row=6)

    # Row 7: below visor - lower face / mouth area
    px(img, 11, 7, HAIR)
    hline(img, 7, 12, 18, SKIN)
    # Skin shadow under visor
    px(img, 12, 7, SKIN_SHADOW)
    px(img, 18, 7, SKIN_SHADOW)
    hline(img, 7, 19, 22, HAIR)  # ponytail lower

    # Row 8: chin / jaw
    hline(img, 8, 12, 18, SKIN)
    px(img, 12, 8, SKIN_SHADOW)  # jaw shadow
    px(img, 18, 8, SKIN_SHADOW)  # jaw shadow
    px(img, 19, 8, HAIR)  # ponytail trailing
    px(img, 20, 8, HAIR)

    # --- TORSO rows 9-18 ---
    # Row 9: neck
    hline(img, 9, 14, 17, SKIN)
    px(img, 14, 9, SKIN_SHADOW)  # neck shadow

    # Row 10: collar with cyan trim
    hline(img, 10, 12, 19, JACK_D)
    px(img, 14, 10, CYAN_T)
    px(img, 17, 10, CYAN_T)

    # Row 11: shoulders (slightly wider for shoulder pads)
    hline(img, 11, 10, 21, JACK_D)
    px(img, 10, 11, JACK_L)  # left shoulder pad highlight
    px(img, 21, 11, JACK_L)  # right shoulder pad highlight

    # Row 12: upper torso
    hline(img, 12, 11, 20, JACK_M)
    px(img, 10, 12, JACK_D)  # left arm
    px(img, 21, 12, JACK_D)  # right arm

    # Row 13: mid torso
    hline(img, 13, 11, 20, JACK_M)
    px(img, 10, 13, JACK_D)
    px(img, 21, 13, JACK_D)

    # Row 14: torso
    hline(img, 14, 11, 20, JACK_M)
    px(img, 10, 14, JACK_D)
    px(img, 21, 14, JACK_D)

    # Row 15: lower torso
    hline(img, 15, 11, 20, JACK_D)
    px(img, 10, 15, JACK_D)

    # Jacket energy accent stripes
    draw_jacket_energy(img, row_start=11, row_end=15)

    # Row 16: waist / belt top
    hline(img, 16, 12, 19, BELT)
    px(img, 15, 16, BUCKLE)
    px(img, 16, 16, BUCKLE)

    # Row 17: belt bottom
    hline(img, 17, 12, 19, BELT)

    # Row 18: below belt transition
    hline(img, 18, 12, 19, JACK_D)

    # --- LEGS rows 19-26 ---
    # Row 19-20: upper legs
    hline(img, 19, 12, 15, PANTS)  # left leg
    hline(img, 19, 16, 19, PANTS)  # right leg

    hline(img, 20, 12, 15, PANTS)
    hline(img, 20, 16, 19, PANTS)

    # Row 21-22: mid legs
    hline(img, 21, 12, 15, PANTS)
    hline(img, 21, 16, 19, PANTS)

    hline(img, 22, 12, 15, PANTS)
    hline(img, 22, 16, 19, PANTS)

    # Row 23-24: lower legs
    hline(img, 23, 12, 15, PANTS)
    hline(img, 23, 16, 19, PANTS)

    hline(img, 24, 12, 15, PANTS)
    hline(img, 24, 16, 19, PANTS)

    # Row 25-26: ankles
    hline(img, 25, 12, 15, PANTS)
    hline(img, 25, 16, 19, PANTS)

    hline(img, 26, 12, 15, PANTS)
    hline(img, 26, 16, 19, PANTS)

    # --- BOOTS rows 27-29 ---
    hline(img, 27, 11, 15, BOOTS)
    hline(img, 27, 16, 20, BOOTS)
    # Cyan trim on boot tops
    px(img, 12, 27, CYAN_T)
    px(img, 17, 27, CYAN_T)

    hline(img, 28, 11, 15, BOOTS)
    hline(img, 28, 16, 20, BOOTS)

    hline(img, 29, 11, 16, BOOTS)  # left boot with heel
    hline(img, 29, 17, 21, BOOTS)  # right boot with heel

    # Boot thruster glow
    draw_boot_glow(img, left_x=11, right_x=17, glow_row=30)

    # Silhouette outline at key contour points
    draw_outline_base(img)

    return img


def draw_arms_idle(img):
    """Draw arms hanging at sides for idle pose."""
    # Left arm (closer to viewer) - hangs at side
    for y in range(12, 18):
        px(img, 9, y, JACK_D)
    # Arm shading
    px(img, 9, 14, JACK_M)
    px(img, 9, 15, JACK_M)

    # Right arm - hangs at side
    for y in range(12, 18):
        px(img, 22, y, JACK_D)
    # Arm shading
    px(img, 22, 14, JACK_M)
    px(img, 22, 15, JACK_M)

    # Hands with shadow
    px(img, 9, 18, SKIN)
    px(img, 9, 17, SKIN_SHADOW)
    px(img, 22, 18, SKIN)
    px(img, 22, 17, SKIN_SHADOW)


def gen_idle_0():
    """Standing pose, arms at sides."""
    img = make_image()
    draw_base_nova(img)
    draw_arms_idle(img)
    return img


def gen_idle_1():
    """Breathing frame - chest shifted 1px up (subtle) with energy pulse."""
    img = make_image()
    draw_base_nova(img)
    draw_arms_idle(img)

    # Shift torso rows 11-15 content up by making row 11 brighter
    # and slightly adjusting mid-torso shading for "breath" effect
    hline(img, 12, 11, 20, JACK_L)  # slightly brighter mid-torso
    px(img, 10, 12, JACK_M)
    px(img, 21, 12, JACK_M)

    # Subtle shoulder raise
    px(img, 10, 10, JACK_L)
    px(img, 21, 10, JACK_L)

    # Energy pulse on jacket accent stripe (brighter energy during breath)
    for y in range(11, 16):
        px(img, 13, y, ENERGY)
    px(img, 14, 12, ENERGY)  # pulse bleed to adjacent pixel

    # Visor glow shifts slightly (re-draw with offset highlight)
    px(img, 15, 6, WHITE_HI)  # highlight shifts right by 1
    px(img, 16, 6, VISOR_GLOW)
    # Extra glow below during pulse
    px(img, 15, 7, VISOR_GLOW_DIM)

    return img


def gen_walk_0():
    """Walk frame 0: right leg forward, left arm forward."""
    img = make_image()

    # Draw upper body (head + torso) same as idle
    draw_base_nova(img)

    # Clear default legs and boots (rows 19-29)
    for y in range(19, 31):
        for x in range(8, 25):
            px(img, x, y, T)

    # LEFT LEG (back, shifted slightly left/back)
    hline(img, 19, 12, 15, PANTS)
    hline(img, 20, 12, 15, PANTS)
    hline(img, 21, 11, 14, PANTS)
    hline(img, 22, 11, 14, PANTS)
    hline(img, 23, 11, 14, PANTS)
    hline(img, 24, 11, 14, PANTS)
    hline(img, 25, 11, 14, PANTS)
    hline(img, 26, 11, 14, PANTS)
    hline(img, 27, 10, 14, BOOTS)
    px(img, 11, 27, CYAN_T)  # boot trim
    hline(img, 28, 10, 14, BOOTS)
    hline(img, 29, 9, 14, BOOTS)

    # RIGHT LEG (forward, shifted right)
    hline(img, 19, 16, 19, PANTS)
    hline(img, 20, 17, 20, PANTS)
    hline(img, 21, 18, 21, PANTS)
    hline(img, 22, 18, 21, PANTS)
    hline(img, 23, 18, 21, PANTS)
    hline(img, 24, 18, 21, PANTS)
    hline(img, 25, 18, 21, PANTS)
    hline(img, 26, 18, 21, PANTS)
    hline(img, 27, 18, 22, BOOTS)
    px(img, 19, 27, CYAN_T)  # boot trim
    hline(img, 28, 18, 22, BOOTS)
    hline(img, 29, 18, 23, BOOTS)

    # Boot glow
    px(img, 10, 30, BOOT_GLOW)
    px(img, 11, 30, BOOT_GLOW)
    px(img, 12, 30, BOOT_GLOW)
    px(img, 19, 30, BOOT_GLOW)
    px(img, 20, 30, BOOT_GLOW)
    px(img, 21, 30, BOOT_GLOW)

    # Motion blur trailing pixels behind the back foot (left leg)
    px(img, 13, 30, MOTION_BLUR)
    px(img, 14, 30, MOTION_BLUR)

    # LEFT ARM forward (swings opposite to legs)
    for y in range(12, 17):
        px(img, 8, y, JACK_D)
    px(img, 8, 14, JACK_M)  # arm shading
    px(img, 7, 17, JACK_D)
    px(img, 7, 18, SKIN)

    # RIGHT ARM back
    for y in range(12, 17):
        px(img, 22, y, JACK_D)
    px(img, 22, 14, JACK_M)  # arm shading
    px(img, 23, 17, JACK_D)
    px(img, 23, 18, SKIN)

    return img


def gen_walk_1():
    """Walk frame 1: legs passing (together), neutral arms."""
    img = make_image()
    draw_base_nova(img)
    draw_arms_idle(img)
    # Legs are together (same as idle but slightly narrower gap)
    return img


def gen_walk_2():
    """Walk frame 2: left leg forward, right arm forward (mirror of walk_0)."""
    img = make_image()

    draw_base_nova(img)

    # Clear default legs and boots (rows 19-29)
    for y in range(19, 31):
        for x in range(8, 25):
            px(img, x, y, T)

    # RIGHT LEG (back, shifted slightly right)
    hline(img, 19, 16, 19, PANTS)
    hline(img, 20, 16, 19, PANTS)
    hline(img, 21, 17, 20, PANTS)
    hline(img, 22, 17, 20, PANTS)
    hline(img, 23, 17, 20, PANTS)
    hline(img, 24, 17, 20, PANTS)
    hline(img, 25, 17, 20, PANTS)
    hline(img, 26, 17, 20, PANTS)
    hline(img, 27, 17, 21, BOOTS)
    px(img, 18, 27, CYAN_T)  # boot trim
    hline(img, 28, 17, 21, BOOTS)
    hline(img, 29, 17, 22, BOOTS)

    # LEFT LEG (forward, shifted left)
    hline(img, 19, 12, 15, PANTS)
    hline(img, 20, 11, 14, PANTS)
    hline(img, 21, 10, 13, PANTS)
    hline(img, 22, 10, 13, PANTS)
    hline(img, 23, 10, 13, PANTS)
    hline(img, 24, 10, 13, PANTS)
    hline(img, 25, 10, 13, PANTS)
    hline(img, 26, 10, 13, PANTS)
    hline(img, 27, 9, 13, BOOTS)
    px(img, 10, 27, CYAN_T)  # boot trim
    hline(img, 28, 9, 13, BOOTS)
    hline(img, 29, 8, 13, BOOTS)

    # Boot glow
    px(img, 9, 30, BOOT_GLOW)
    px(img, 10, 30, BOOT_GLOW)
    px(img, 11, 30, BOOT_GLOW)
    px(img, 18, 30, BOOT_GLOW)
    px(img, 19, 30, BOOT_GLOW)
    px(img, 20, 30, BOOT_GLOW)

    # Motion blur trailing pixels behind the back foot (right leg)
    px(img, 18, 30, MOTION_BLUR)
    px(img, 19, 30, MOTION_BLUR)

    # RIGHT ARM forward
    for y in range(12, 17):
        px(img, 23, y, JACK_D)
    px(img, 23, 14, JACK_M)  # arm shading
    px(img, 24, 17, JACK_D)
    px(img, 24, 18, SKIN)

    # LEFT ARM back
    for y in range(12, 17):
        px(img, 9, y, JACK_D)
    px(img, 9, 14, JACK_M)  # arm shading
    px(img, 8, 17, JACK_D)
    px(img, 8, 18, SKIN)

    return img


def gen_walk_3():
    """Walk frame 3: legs passing (together), neutral arms - same as walk_1."""
    return gen_walk_1()


def gen_jump_0():
    """Jump rising: legs tucked slightly, arms up, boot thrusters firing."""
    img = make_image()

    # Draw head same as base (shifted up 1px for rising feel)
    # Head rows 1-7 (shifted up by 1)
    hline(img, 1, 13, 17, HAIR)
    hline(img, 2, 12, 18, HAIR)
    # Hair highlights
    px(img, 14, 1, HAIR_HI)
    px(img, 16, 1, HAIR_HI)
    px(img, 13, 2, HAIR_HI)

    hline(img, 3, 11, 19, HAIR)
    px(img, 20, 3, HAIR)
    px(img, 15, 3, HAIR_HI)

    px(img, 11, 4, HAIR)
    hline(img, 4, 12, 18, SKIN)
    hline(img, 4, 19, 22, HAIR)  # ponytail
    px(img, 21, 4, HAIR_HI)

    px(img, 11, 5, HAIR)
    px(img, 12, 5, VISOR_D)
    hline(img, 5, 13, 17, VISOR)
    px(img, 18, 5, VISOR_D)
    hline(img, 5, 19, 23, HAIR)  # ponytail
    # Visor glow for jump
    draw_visor_glow(img, visor_row=5)

    px(img, 11, 6, HAIR)
    hline(img, 6, 12, 18, SKIN)
    px(img, 12, 6, SKIN_SHADOW)
    px(img, 18, 6, SKIN_SHADOW)
    hline(img, 6, 19, 22, HAIR)

    hline(img, 7, 12, 18, SKIN)
    px(img, 12, 7, SKIN_SHADOW)
    px(img, 18, 7, SKIN_SHADOW)
    px(img, 19, 7, HAIR)
    px(img, 20, 7, HAIR)

    # Neck
    hline(img, 8, 14, 17, SKIN)
    px(img, 14, 8, SKIN_SHADOW)

    # Torso (rows 9-17)
    hline(img, 9, 12, 19, JACK_D)
    px(img, 14, 9, CYAN_T)
    px(img, 17, 9, CYAN_T)

    hline(img, 10, 10, 21, JACK_D)
    px(img, 10, 10, JACK_L)
    px(img, 21, 10, JACK_L)
    # Shoulder accent pips
    px(img, 11, 10, JACK_ACCENT)
    px(img, 20, 10, JACK_ACCENT)

    hline(img, 11, 11, 20, JACK_M)
    hline(img, 12, 11, 20, JACK_M)
    hline(img, 13, 11, 20, JACK_M)
    hline(img, 14, 11, 20, JACK_D)

    # Jacket accent stripe
    for y in range(10, 15):
        px(img, 13, y, JACK_ACCENT)

    # Belt
    hline(img, 15, 12, 19, BELT)
    px(img, 15, 15, BUCKLE)
    px(img, 16, 15, BUCKLE)
    hline(img, 16, 12, 19, BELT)
    hline(img, 17, 12, 19, JACK_D)

    # Arms UP (raised for jump)
    # Left arm going up-left
    px(img, 9, 10, JACK_D)
    px(img, 8, 9, JACK_D)
    px(img, 7, 8, JACK_D)
    px(img, 8, 10, JACK_M)  # arm shading
    px(img, 7, 7, SKIN)  # hand

    # Right arm going up-right
    px(img, 22, 10, JACK_D)
    px(img, 23, 9, JACK_D)
    px(img, 24, 8, JACK_D)
    px(img, 23, 10, JACK_M)  # arm shading
    px(img, 24, 7, SKIN)  # hand

    # TUCKED LEGS (shorter, bent)
    hline(img, 18, 12, 15, PANTS)
    hline(img, 18, 16, 19, PANTS)
    hline(img, 19, 12, 15, PANTS)
    hline(img, 19, 16, 19, PANTS)
    hline(img, 20, 13, 15, PANTS)
    hline(img, 20, 16, 18, PANTS)
    hline(img, 21, 13, 15, PANTS)
    hline(img, 21, 16, 18, PANTS)
    hline(img, 22, 13, 15, PANTS)
    hline(img, 22, 16, 18, PANTS)

    # Tucked boots (pulled up)
    hline(img, 23, 12, 15, BOOTS)
    hline(img, 23, 16, 19, BOOTS)
    px(img, 13, 23, CYAN_T)  # boot trim
    px(img, 17, 23, CYAN_T)  # boot trim
    hline(img, 24, 12, 16, BOOTS)
    hline(img, 24, 17, 20, BOOTS)

    # THRUSTER FIRE below boots (signature jump effect)
    # Left boot thruster
    px(img, 13, 25, BOOT_GLOW)
    px(img, 14, 25, BOOT_GLOW)
    px(img, 15, 25, BOOT_GLOW)
    px(img, 14, 26, VISOR_GLOW_DIM)  # flame tail

    # Right boot thruster
    px(img, 18, 25, BOOT_GLOW)
    px(img, 19, 25, BOOT_GLOW)
    px(img, 17, 25, BOOT_GLOW)
    px(img, 18, 26, VISOR_GLOW_DIM)  # flame tail

    # Outline: top of head, shoulder edges
    hline(img, 0, 13, 17, OUTLINE)
    px(img, 9, 10, OUTLINE)
    px(img, 22, 10, OUTLINE)

    return img


def gen_jump_1():
    """Jump falling: legs extended down, arms out for balance, wind streaks."""
    img = make_image()

    # Draw head (normal position)
    draw_base_nova(img)

    # Clear default arms
    for y in range(12, 19):
        px(img, 9, y, T)
        px(img, 22, y, T)

    # Clear default legs and boots (rows 19-31)
    for y in range(19, 31):
        for x in range(8, 25):
            px(img, x, y, T)

    # Arms OUT to sides for balance
    # Left arm extended left
    px(img, 9, 12, JACK_D)
    px(img, 8, 12, JACK_D)
    px(img, 7, 12, JACK_D)
    px(img, 7, 13, JACK_M)  # arm shading
    px(img, 6, 13, JACK_D)
    px(img, 6, 14, SKIN)  # hand

    # Right arm extended right
    px(img, 22, 12, JACK_D)
    px(img, 23, 12, JACK_D)
    px(img, 24, 12, JACK_D)
    px(img, 24, 13, JACK_M)  # arm shading
    px(img, 25, 13, JACK_D)
    px(img, 25, 14, SKIN)  # hand

    # EXTENDED LEGS (stretched down, slightly apart)
    # Left leg
    hline(img, 19, 12, 15, PANTS)
    hline(img, 20, 12, 15, PANTS)
    hline(img, 21, 11, 14, PANTS)
    hline(img, 22, 11, 14, PANTS)
    hline(img, 23, 11, 14, PANTS)
    hline(img, 24, 11, 14, PANTS)
    hline(img, 25, 11, 14, PANTS)
    hline(img, 26, 11, 14, PANTS)
    hline(img, 27, 10, 14, BOOTS)
    px(img, 11, 27, CYAN_T)  # boot trim
    hline(img, 28, 10, 14, BOOTS)
    hline(img, 29, 9, 14, BOOTS)

    # Right leg
    hline(img, 19, 16, 19, PANTS)
    hline(img, 20, 16, 19, PANTS)
    hline(img, 21, 17, 20, PANTS)
    hline(img, 22, 17, 20, PANTS)
    hline(img, 23, 17, 20, PANTS)
    hline(img, 24, 17, 20, PANTS)
    hline(img, 25, 17, 20, PANTS)
    hline(img, 26, 17, 20, PANTS)
    hline(img, 27, 17, 21, BOOTS)
    px(img, 18, 27, CYAN_T)  # boot trim
    hline(img, 28, 17, 21, BOOTS)
    hline(img, 29, 17, 22, BOOTS)

    # Boot glow (less intense than jump_0 since falling)
    px(img, 11, 30, VISOR_GLOW_DIM)
    px(img, 12, 30, VISOR_GLOW_DIM)
    px(img, 18, 30, VISOR_GLOW_DIM)
    px(img, 19, 30, VISOR_GLOW_DIM)

    # WIND STREAKS above character (falling effect)
    # Short dim horizontal lines above the head
    hline(img, 0, 10, 13, WIND_STREAK)
    hline(img, 1, 19, 22, WIND_STREAK)
    px(img, 8, 3, WIND_STREAK)
    px(img, 9, 3, WIND_STREAK)
    px(img, 24, 4, WIND_STREAK)
    px(img, 25, 4, WIND_STREAK)

    return img


def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    generators = [
        ("nova_idle_0.png", gen_idle_0),
        ("nova_idle_1.png", gen_idle_1),
        ("nova_walk_0.png", gen_walk_0),
        ("nova_walk_1.png", gen_walk_1),
        ("nova_walk_2.png", gen_walk_2),
        ("nova_walk_3.png", gen_walk_3),
        ("nova_jump_0.png", gen_jump_0),
        ("nova_jump_1.png", gen_jump_1),
    ]

    for name, gen_func in generators:
        img = gen_func()
        path = os.path.join(OUT_DIR, name)
        img.save(path)
        print(f"Saved {path}")

    # Save nova.png as copy of idle_0
    idle_0 = gen_idle_0()
    nova_path = os.path.join(OUT_DIR, "nova.png")
    idle_0.save(nova_path)
    print(f"Saved {nova_path}")

    print(f"\nGenerated 9 files in {OUT_DIR}")


if __name__ == "__main__":
    main()
