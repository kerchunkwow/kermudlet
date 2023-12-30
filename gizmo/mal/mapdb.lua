--[[
The db: 'C:/Dev/mud/gizmo/data/gizwrld.db' and has 3 Tables: Area, Room, and Exit
There are 128 Areas, 8149 Rooms, and 19101 Exits.
The basic structure of the World is that Areas contain Rooms and Rooms contain Exits

Area Table:
areaRNumber INTEGER; A unique identifier and primary key for Area
areaName TEXT; The name of the Area in the MUD
areaResetType TEXT; A string describing how and when the area repopulates
areaFirstRoomName TEXT; The name of the first Room in the Area; usually the Room with areaMinRoomRNumber
areaMinRoomRNumber INTEGER; The lowest value of roomRNumber for Rooms in the Area
areaMaxRoomRNumber INTEGER; The highest value of roomRNumber for Rooms in the Area
areaMinVNumber INTEGER; The logest value of roomVNumber for Rooms in the Area; usually the same room as areaMinRoomRNumber
areaMaxVNumberActual INTEGER; The highest value for Rooms that actually exist in the Area
areaMaxVNumberAllowed INTEGER; The highest value that a Room could theoretically have in the Area
areaRoomCount INTEGER; How many Rooms are in the Area

Room Table:
roomName TEXT; The name of the Room in the MUD
roomVNumberd INTEGER; The VNumber of the Room; an alternative identifier
roomRNumber INTEGER; The RNumber of the Room; the primary unique identifier
roomType TEXT; The "Terrain" or "Sector" type of the Room; will be used for color selection
roomSpec BOOLEAN; Boolean value identifying Rooms with "special procedures" which will affect players in the Room
roomFlags TEXT; A list of flags that identify special properties of the Room
roomDescription TEXT; A long description of the Room that players see in game
roomExtraKeyword TEXT; A list of one or more words that identify things in the room players can examine or interact with
areaRNumber INTEGER; Foreign key to the Area in which this Room exists

Exit Table:
exitDirection TEXT; The direction the player must travel to use this Exit
exitDest INTEGER; The roomRNumber of the Room the player travels to when using this Exit
exitKeyword TEXT; Keywords Players use to interact with an Exit such as 'door' or 'gate'
exitFlags INTEGER; A list of flags that identify special properties of an Exit, usually a door
exitKey INTEGER; For Exits that require keys to lock/unlock, this is the in-game ID for the key
exitDescription TEXT; A short description of the Exit such as 'A gravel path leading west.'
roomRNumber INTEGER; Foreign key to the Room in which this Exit belongs
]]

-- From the gizwrld database, load the Area, Room, and Exit data into a Lua table
function loadWorldData()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  if not conn then
    cecho( f '{{Error connecting to the database.\n' )
    return nil
  end
  local areas = {}
  local cursor

  -- Load Areas
  cursor = conn:execute( "SELECT * FROM Area" )
  local row = cursor:fetch( {}, "a" )
  while row do
    areas[row.areaRNumber] = {
      areaRNumber = row.areaRNumber,
      areaName = row.areaName,
      areaResetType = row.areaResetType,
      areaFirstRoomName = row.areaFirstRoomName,
      areaMinRoomRNumber = row.areaMinRoomRNumber,
      areaMaxRoomRNumber = row.areaMaxRoomRNumber,
      areaMinVNumber = row.areaMinVNumber,
      areaMaxVNumberActual = row.areaMaxVNumberActual,
      areaMaxVNumberAllowed = row.areaMaxVNumberAllowed,
      areaRoomCount = row.areaRoomCount,
      rooms = {}
    }
    row = cursor:fetch( row, "a" )
  end
  cursor:close()

  -- Load Rooms
  cursor = conn:execute( "SELECT * FROM Room" )
  row = cursor:fetch( {}, "a" )
  while row do
    if areas[row.areaRNumber] then
      areas[row.areaRNumber].rooms[row.roomRNumber] = {
        roomRNumber = row.roomRNumber,
        roomName = row.roomName,
        roomType = row.roomType,
        roomSpec = row.roomSpec,
        roomFlags = row.roomFlags,
        roomDescription = row.roomDescription,
        roomExtraKeyword = row.roomExtraKeyword,
        roomVNumber = row.roomVNumber,
        exits = {}
      }
    else
      cecho( f '{{Unmatched Room: {row.roomRNumber} in Area: {row.areaRNumber}\n' )
    end
    row = cursor:fetch( row, "a" )
  end
  cursor:close()

  -- Load Exits
  cursor = conn:execute( "SELECT * FROM Exit" )
  row = cursor:fetch( {}, "a" )
  while row do
    for _, area in pairs( areas ) do
      if area.rooms[row.roomRNumber] then
        table.insert( area.rooms[row.roomRNumber].exits, {
          exitID = row.exitID,
          exitDirection = row.exitDirection,
          exitDest = row.exitDest,
          exitKeyword = row.exitKeyword,
          exitFlags = row.exitFlags,
          exitKey = row.exitKey,
          exitDescription = row.exitDescription
        } )
        break -- Exit found and added, no need to continue looping through areas
      end
    end
    row = cursor:fetch( row, "a" )
  end
  cursor:close()

  conn:close()
  env:close()

  return areas
end

function countWorldDataElements()
  local areaCount = 0
  local roomCount = 0
  local exitCount = 0

  for _, area in pairs( worldData ) do
    areaCount = areaCount + 1

    for _, room in pairs( area.rooms ) do
      roomCount = roomCount + 1
      exitCount = exitCount + #room.exits
    end
  end
  return areaCount, roomCount, exitCount
end
