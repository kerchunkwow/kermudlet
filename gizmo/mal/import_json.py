import json
import sqlite3

# Load the JSON data
with open('C:/Dev/mud/mudlet/gizmo/mal/areadata/gizmo_world.json') as f:
    data = json.load(f)

# Create a SQLite database and establish a connection
conn = sqlite3.connect('C:/Dev/mud/gizmo/data/gizwrld.db')
c = conn.cursor()

for area in data.values():
    try:
        c.execute('''
            INSERT INTO Area (areaRNumber, areaName, areaResetType, areaMinRoomRNumber, areaFirstRoomName, areaMaxRoomRNumber, areaMinVNumber, areaMaxVNumberActual, areaMaxVNumberAllowed, areaRoomCount)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            area['areaRNumber'],
            area['areaName'],
            area['areaResetType'],
            area['areaMinRoomRNumber'],
            area['areaFirstRoomName'],
            area['areaMaxRoomRNumber'],
            area['areaMinVNumber'],
            area['areaLastVNumber'],
            area['areaMaxVNumber'],
            area['areaRoomCount']
        ))
    except sqlite3.IntegrityError:
        print(f"Duplicate Area not added: {area}")

    for room in area['areaRooms']:
        try:
            c.execute('''
                INSERT INTO Room (roomName, roomVNumber, roomRNumber, roomType, roomSpec, roomFlags, roomDescription, roomExtraKeyword, areaRNumber)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                room['roomName'],
                room['roomVNumber'],
                room['roomRNumber'],
                room['roomType'],
                room['roomSpec'],
                room['roomFlags'],
                room['roomDescription'],
                room['roomExtraKeyword'],
                area['areaRNumber']
            ))
        except sqlite3.IntegrityError:
            print(f"Duplicate Room not added: {room}")

        for exit in room['roomExits']:
            try:
                c.execute('''
                    INSERT INTO Exit (exitDirection, exitKeyword, exitFlags, exitKey, exitDescription, exitDest, roomRNumber)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                ''', (
                    exit['exitDirection'],
                    exit['exitKeyword'],
                    exit['exitFlags'],
                    exit['exitKey'],
                    exit['exitDescription'],
                    exit['exitDest'],
                    room['roomRNumber']
                ))
            except sqlite3.IntegrityError:
                print(f"Duplicate Exit not added: {exit}")

# Commit the changes and close the connection
conn.commit()
conn.close()
