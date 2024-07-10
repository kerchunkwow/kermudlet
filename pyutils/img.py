# Module to generate a series of "clock" images which when animated create the effect of a timer gradually
# progressing between two color values and providing a warning state at the end of each cycle.
from PIL import Image, ImageDraw, ImageFont

# Where you want the output images to be saved
CLOCK_FOLDER   = 'C:/Dev/mud/mudlet/gizmo/assets/img/t'

# Various size & appearance settings; make sure the font is available on your system
CLOCK_DIAMETER  = 64
CLOCK_STEPS     = 120
CLOCK_FONT_FACE = "DUBAI-BOLD.TTF"
CLICK_FONT_SIZE = 16

# Each step of the clock will be an interpolated color value between these state and end points
START_FG       = '#9ACD32'
END_FG         = '#FF4500'

# As the color of the clock face changes, it may help to alter the font color to maintain readability
START_FONT     = "#4B0082"
END_FONT       = "#FF4500"

# Give the clock a border and BG color that works well for your UI
CLOCK_BG       = '#202020'
CLOCK_BORDER   = '#2F4F4F'

# In the final seconds of each minutes, the clock will briefly display these colors, alternating back to
# normal to create a flashing "warning" effect
WARNING_BORDER = '#FF1493'
WARNING_BG     = '#353535'
WARNING_FONT   = "#FF1493"

def create_timer_images():
    """Create a series of clock face images"""
    image_size = (CLOCK_DIAMETER, CLOCK_DIAMETER)

    try:
        font = ImageFont.truetype(CLOCK_FONT_FACE, size=CLICK_FONT_SIZE)
    except IOError:
        font = ImageFont.load_default()

    # How many "steps" the clock will spend in each second of the minute
    steps_per_second = CLOCK_STEPS // 60

    for i in range(CLOCK_STEPS):
        # Calculate the number of seconds remaining in the current minute
        seconds_remaining = 60 - (i // steps_per_second)

        # Warning track;
        # If we are in the last two seconds AND i is even, then use warning colors
        if i in range(CLOCK_STEPS - (3 * steps_per_second), CLOCK_STEPS, 2):
            fill_color, font_color = WARNING_BG, WARNING_FONT
            border_color = WARNING_BORDER
        else:
            fill_color, font_color = get_timer_colors(i, CLOCK_STEPS - 1, START_FG, END_FG, START_FONT, END_FONT)
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
        text_position = get_text_position(seconds_remaining, bbox, CLOCK_DIAMETER)
        draw.text(text_position, text, fill=font_color, font=font)

        # Save the image with the original file naming convention
        img.save(f'{CLOCK_FOLDER}/{i}.png')

def hex_to_rgb( hex_color ):
    """Unpack a HEX color into DEC RGB components"""
    hex_color = hex_color.lstrip( '#' )
    return tuple( int( hex_color[i:i+2], 16 ) for i in ( 0, 2 ,4 ) )

def rgb_to_hex( rgb_color ):
    """Pack a DEC RGB color into its HEX equivalent"""
    return '#{:02x}{:02x}{:02x}'.format( *rgb_color )

def interpolate_color( start_color, end_color, fraction ):
    """Given start and end colors, return a color a fraction of the distance between them"""
    start_rgb        = hex_to_rgb( start_color )
    end_rgb          = hex_to_rgb( end_color )
    interpolated_rgb = tuple( int( start + ( end - start ) * fraction ) for start, end in zip( start_rgb, end_rgb ) )

    return rgb_to_hex( interpolated_rgb )

def get_timer_colors( frame, total_frames, start_color, end_color, font_start_color, font_end_color ):
    """Get colors adjusted for each frame of the animated timer"""
    fraction    = frame / total_frames
    clock_color = interpolate_color( start_color, end_color, fraction )
    font_color  = interpolate_color( font_start_color, font_end_color, fraction )

    return clock_color, font_color

def get_text_position(seconds_remaining, bbox, diameter):
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    center_x = (diameter - text_width) / 2
    center_y = (diameter - text_height) / 2
    offset = 10

    if seconds_remaining > 29:
        # First half: upper left
        position_x = center_x - 12
        position_y = center_y - 12
    else:
        # Second half: lower right
        position_x = center_x + 10
        position_y = center_y + 6

    return position_x, position_y

create_timer_images()
