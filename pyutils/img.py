from PIL import Image, ImageDraw, ImageFont

# Initial color definitions
START_FG       = '#9ACD32'
END_FG         = '#FF4500'
CLOCK_BG       = '#202020'
CLOCK_BORDER   = '#2F4F4F'
CLOCK_STEPS    = 120
CLOCK_DIAMETER = 32
CLOCK_FOLDER   = 'c:/Dev/mud/mudlet/gizmo/assets/img/t'

WARNING_BORDER = '#FF1493'
WARNING_BG     = '#353535'
WARNING_FONT   = "#FF1493"
EARLY_FONT     = "#4B0082"
LATE_FONT      = "#FF4500"

def hex_to_rgb(hex_color):
    """Convert hex to RGB."""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2 ,4))

def rgb_to_hex(rgb_color):
    """Convert RGB to hex."""
    return '#{:02x}{:02x}{:02x}'.format(*rgb_color)

def interpolate_color(start_color, end_color, fraction):
    """Interpolate between two colors."""
    start_rgb = hex_to_rgb(start_color)
    end_rgb = hex_to_rgb(end_color)
    interpolated_rgb = tuple(int(start + (end - start) * fraction) for start, end in zip(start_rgb, end_rgb))
    return rgb_to_hex(interpolated_rgb)

def get_timer_colors(frame, total_frames, start_color, end_color, font_start_color, font_end_color):
    """Get interpolated clock and font colors."""
    fraction = frame / total_frames
    clock_color = interpolate_color(start_color, end_color, fraction)
    font_color = interpolate_color(font_start_color, font_end_color, fraction)
    return clock_color, font_color

def create_timer_images():
    """Create timer images with interpolated colors and warning effect."""
    image_size = (CLOCK_DIAMETER, CLOCK_DIAMETER)

    try:
        font = ImageFont.truetype("DUBAI-BOLD.TTF", size=13)
    except IOError:
        font = ImageFont.load_default()

    for i in range(CLOCK_STEPS):
        seconds_remaining = (CLOCK_STEPS - i + 1) // 2
        if i in [115, 117, 119]:
            fill_color, font_color = WARNING_BG, WARNING_FONT
            border_color = WARNING_BORDER
        else:
            fill_color, font_color = get_timer_colors(i, CLOCK_STEPS-1, START_FG, END_FG, EARLY_FONT, LATE_FONT)
            border_color = CLOCK_BORDER

        img = Image.new('RGBA', image_size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        # Draw the clock face
        draw.ellipse([0, 0, CLOCK_DIAMETER - 1, CLOCK_DIAMETER - 1], fill=fill_color)
        end_angle = (i * 360 / CLOCK_STEPS)
        if i != 0:
            draw.pieslice([0, 0, CLOCK_DIAMETER - 1, CLOCK_DIAMETER - 1], start=-90, end=-90 + end_angle, fill=CLOCK_BG)
        draw.ellipse([0, 0, CLOCK_DIAMETER - 1, CLOCK_DIAMETER - 1], outline=border_color, width=1)

        # Position and draw the seconds text
        text = str(seconds_remaining)
        bbox = draw.textbbox((0, 0), text, font=font)
        text_position = ((CLOCK_DIAMETER - (bbox[2] - bbox[0])) / 2, (CLOCK_DIAMETER - (bbox[3] - bbox[1])) / 2)
        draw.text(text_position, text, fill=font_color, font=font)

        # Save the image with the original file naming convention
        img.save(f'{CLOCK_FOLDER}/{i}.png')

create_timer_images()
