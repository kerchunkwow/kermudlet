import os
from moviepy.editor import VideoFileClip

def rename_mp4_files(directory):
    for filename in os.listdir(directory):
        if filename.endswith(".mp4"):
            filepath = os.path.join(directory, filename)
            try:
                video = VideoFileClip(filepath)
                duration = int(video.duration)
                minutes = duration // 60
                seconds = duration % 60
                video.close()  # Ensure the video file is closed
                new_name = f"{minutes:02}.{seconds:02} {filename}"
                new_filepath = os.path.join(directory, new_name)
                os.rename(filepath, new_filepath)
                print(f"Renamed '{filename}' to '{new_name}'")
            except Exception as e:
                print(f"Error processing '{filename}': {e}")

# Example usage
directory_path = "R:/Downloads/"  # Replace with your directory path
rename_mp4_files(directory_path)
