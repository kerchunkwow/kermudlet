# Piss with images and shit; for now, this makes a set of .pngs to create a the clock animation
from PIL import Image, ImageDraw

# Define start & end colors; your clock will interpolate between these as it counts down
START_COLOR    = '#9ACD32'
END_COLOR      = '#FF4500'
CLOCK_BG       = '#202020'
CLOCK_STEPS    = 120
CLOCK_DIAMETER = 36
CLOCK_FOLDER   = 'C:/Dev/mud/mudlet/gizmo/assets/img/t'

def hex_to_rgb(hex_color):
    """Convert a hex color to an RGB tuple."""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def rgb_to_hex(rgb_color):
    """Convert an RGB tuple back to a hex color."""
    return '#{:02x}{:02x}{:02x}'.format(*rgb_color)

def interpolate_color(start_color, end_color, fraction):
    """Interpolate between two RGB colors."""
    start_rgb = hex_to_rgb(start_color)
    end_rgb = hex_to_rgb(end_color)
    # Linear interpolation of each color channel
    interpolated_rgb = tuple(int(start + (end - start) * fraction) for start, end in zip(start_rgb, end_rgb))
    return rgb_to_hex(interpolated_rgb)

def get_timer_colors(frame, total_frames, start_color, end_color):
    """Return the border and fill colors for the current frame."""
    fraction = frame / total_frames
    # Calculate the border and fill colors for this frame
    color = interpolate_color(start_color, end_color, fraction)
    return color, color

def create_timer_images():

    image_size = (CLOCK_DIAMETER, CLOCK_DIAMETER)  # Size of the image
    step = 360 / CLOCK_STEPS  # Degree step based on the number of frames

    for i in range(CLOCK_STEPS):
        # Get the interpolated colors for the current frame
        border_color, fill_color = get_timer_colors(i, CLOCK_STEPS, START_COLOR, END_COLOR)

        # Create an image with a transparent background (RGBA mode)
        img = Image.new('RGBA', image_size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        # Draw a full circle with the fill color
        draw.ellipse([0, 0, CLOCK_DIAMETER - 1, CLOCK_DIAMETER - 1], fill=fill_color)

        # Calculate the end angle for the dim grey arc representing the elapsed time
        end_angle = (i * step)  # Increase angle to simulate elapsed time clockwise

        # Draw the dim grey arc (elapsed time) if not the first frame
        if i != 0:
            draw.pieslice([0, 0, CLOCK_DIAMETER - 1, CLOCK_DIAMETER - 1], start=-90, end=-90 + end_angle, fill=CLOCK_BG)

        # Draw the border around the circle
        draw.ellipse([0, 0, CLOCK_DIAMETER - 1, CLOCK_DIAMETER - 1], outline=border_color, width=2)

        # Save the image
        img.save(f'{i}.png')


# Run the function with default parameters
create_timer_images()
