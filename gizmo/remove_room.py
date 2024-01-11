import sqlite3
import shutil
import os
from datetime import datetime

def backup_database():
    original_db_path = 'C:/Dev/mud/gizmo/data/gizwrld.db'
    backup_dir = 'C:/Dev/mud/gizmo/data/backup'
    if not os.path.exists(backup_dir):
        os.makedirs(backup_dir)

    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup_file = os.path.join(backup_dir, f'backup-{timestamp}.db')
    shutil.copyfile(original_db_path, backup_file)
    print(f"Database backed up to {backup_file}")

def remove_room_from_database(room_rnumber):
    db_path = 'C:/Dev/mud/gizmo/data/gizwrld.db'
    # Connect to the SQLite database
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    try:
        # Find the area to which this room belongs
        cursor.execute("SELECT areaRNumber FROM Room WHERE roomRNumber = ?", (room_rnumber,))
        area_rnumber_row = cursor.fetchone()

        # Proceed only if the room exists and has an area
        if area_rnumber_row:
            area_rnumber = area_rnumber_row[0]

            # Delete exits associated with the room
            cursor.execute("DELETE FROM Exit WHERE roomRNumber = ?", (room_rnumber,))

            # Delete the room itself
            cursor.execute("DELETE FROM Room WHERE roomRNumber = ?", (room_rnumber,))

            # Update Area table
            cursor.execute("""
                UPDATE Area SET
                areaMinRoomRNumber = (SELECT MIN(roomRNumber) FROM Room WHERE areaRNumber = ?),
                areaMaxRoomRNumber = (SELECT MAX(roomRNumber) FROM Room WHERE areaRNumber = ?),
                areaMinVNumber = (SELECT MIN(roomVNumber) FROM Room WHERE areaRNumber = ?),
                areaMaxVNumberActual = (SELECT MAX(roomVNumber) FROM Room WHERE areaRNumber = ?),
                areaRoomCount = areaRoomCount - 1
                WHERE areaRNumber = ?
            """, (area_rnumber, area_rnumber, area_rnumber, area_rnumber, area_rnumber))

        # Commit the changes
        conn.commit()

    except sqlite3.Error as e:
        print(f"An error occurred: {e}")
        conn.rollback()

    finally:
        # Close the connection
        conn.close()

# Usage
backup_database()
remove_room_from_database(3037)
