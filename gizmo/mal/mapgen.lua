--[[
The purpose of mapgen.lua is to retrieve area data from JSON to create a map within the Mudlet client.
Each Area has a dictionary of Rooms which themselves have a dictionary of Exits.
Exits describe connections to other Rooms, which can include travel between Areas.

Here is the JSON structure for the 3 objects that define the world:

Area:
"areaRNumber": number, -- The primary identifier for an Area; a unique number greater >= 0 and <= 130
"areaName": string, -- The in-game name of the Area (e.g. "The City of Midgaard")
"areaMaxVNumberAllowed": number, -- The maximum allowable roomVnumber; not necessarily the actual maximum roomVNumber
"areaResetType": string, -- A string describing when the Area "resets" or repopulates
"areaFirstRoomName": string, -- The roomName of the first Room in the Area
"areaMinRoomRNumber": number, -- The roomRNumber of the first Room in the Area
"areaMaxRoomRNumber": number, -- The highest actual roomRNumber in the Area
"areaMinVNumber": number, -- The minimum allowable roomVNumber; not necessarily the actual minimum roomVNumber
"areaMaxVNumberActual": number, -- The actual maximum roomVNumber as opposed to areaMaxVNumber which is the maximum allowable roomVNumber
"areaRoomCount": number, -- The actual number of Rooms in the Area
"areaRooms": dictionary -- A dictionary of Rooms in the Area; each Room is a dictionary

Room:
"roomName": string, -- The name of the Room (e.g. "The Baker's Shop")
"roomAreaNumber": number, -- The areaRNumber of the area the Room is in; outside the structure of JSON, this is how Rooms are assigned to Areas
"roomVNumber": number, -- A secondary identifier for a room; a unique number greater >= 0
"roomRNumber": number, -- The primary identifier for a Room; a unique number greater >= 0
"roomType": string, -- The type of terrain; one of the TERRAIN_TYPES
"roomSpec": boolean, -- Whether this room has a "special procedure" which are effects the player will experience when in the room
"roomFlags": number, -- A bitmask of flags which describe the room; see ROOM_FLAGS
"roomDescription": string, -- Long string describing the room; can span hundreds of characters
"roomExtraKeyword": string, -- Keywords that can be used to reference the room; can be multiple words space-delimited
"roomExits": dictionary -- A dictionary of Exits in the Room; Exits are dictionaries because they have multiple properties

Exit:
"exitDirection": string, -- The direction of travel to "use" this exit; must be one of the DIRECTIONS
"exitKeyword": string, -- Word to interact with this exit like "door" or "gate"
"exitFlags": number, -- A bitmask of flags describing extra properties of the exit; see EXIT_FLAGS; -1 if no flags
"exitKey": number, -- An integer corresponding to the in-game object that locks/unlocks this Exit; -1 if no key
"exitDescription": "", -- Some exits have an additional description like "There's a gate here."
"exitDest": number -- The roomRNumber of the Room this Exit leads to
]]


-- JSON Library & data file path
dkjson      = require( 'dkjson' )
dataFile    = "C:/Dev/mud/mudlet/gizmo/mal/areadata/gizmo_world.json"

-- An initially empty table for holding data about Areas (either individually or in aggregate)
areaData    = {}

-- Globals for tracking my "virtual position" in the world
currentArea = nil     -- The area I'm currently mapping
currentRoom = nil     -- The room I'm currently mapping
mX, mY, mZ  = 0, 0, 0 -- Coordinates of the room I'm currently mapping; for use by Mudlet to determine position in UI



-- When outputting data related to map generation, use these colors to highlight specific fields wich cecho()
-- e.g., cecho( MAPGEN_COLORS["areaName"] .. area["areaName"] .. "<reset>" )
MAPC          = {
  ["area"]     = "<deep_pink>",
  ["number"]   = "<dark_orange>",
  ["roomName"] = "<royal_blue>",
  ["roomDesc"] = "<ansi_light_black>",
  ["exitDir"]  = "<cyan>",
  ["exitStr"]  = "<ansi_light_black>"
}

-- Global constant table of Terrain or "Sector" types for use in building and customizing rooms
TERRAIN_TYPES = {
  ["Inside"]    = "<sienna>",
  ["Forest"]    = "<forest_green>",
  ["Mountains"] = "<rosy_brown>",
  ["City"]      = "<dark_khaki>",
  ["Water"]     = "<dodger_blue>",
  ["Field"]     = "<lawn_green>",
  ["Hills"]     = "<dark_olive_green>",
  ["Deepwater"] = "<midnight_blue>"
}

-- Valid directions for exits and travel; MUD does not support diagonal travel
DIRECTIONS    = {
  ["north"] = 1,
  ["south"] = 2,
  ["east"]  = 3,
  ["west"]  = 4,
  ["up"]    = 5,
  ["down"]  = 6
}

-- Bitmask used to encode/decode roomFlags which describe different properties of a Room
ROOM_FLAGS    = {
  ['INDOORS']  = 1,
  ['NONE']     = 2,
  ['DARK']     = 4,
  ['PRIVATE']  = 8,
  ['NO_MOB']   = 16,
  ['ARENA']    = 32,
  ['NO_MAGIC'] = 64,
  ['NEUTRAL']  = 128,
  ['SNDPROOF'] = 256,
  ['SAFE']     = 512,
  ['TUNNEL']   = 1024,
  ['DEATH']    = 2048,
  ['BFS_MARK'] = 4096,
  ['DUEL']     = 8192,
  ['CLUB']     = 16384,
  ['HALLOWED'] = 32768
}

-- Bitmask used to encode/decode exitFlags which describe different properties of an Exit
EXIT_FLAGS    = {
  ['IS-DOOR']  = 1,
  ['CLOSED']   = 2,
  ['LOCKED']   = 4,
  ['HIDDEN']   = 8,
  ['SECRET']   = 16,
  ['RSCLOSED'] = 32,
  ['!PICK']    = 64,
}

function createRoom( room, areaID, areaName )
  -- Create the room
  local roomRNumber = room["roomRNumber"]
  addRoom( roomRNumber )

  -- Assign the room to the area
  setRoomArea( roomRNumber, areaName )

  -- Set the room name
  setRoomName( roomRNumber, room["roomName"] )

  -- Store the extra room data
  setRoomUserData( roomRNumber, "roomVNumber", tostring( room["roomVNumber"] ) )
  setRoomUserData( roomRNumber, "roomType", tostring( room["roomType"] ) )
  setRoomUserData( roomRNumber, "roomSpec", tostring( room["roomSpec"] ) )
  setRoomUserData( roomRNumber, "roomFlags", tostring( room["roomFlags"] ) )
  setRoomUserData( roomRNumber, "roomDescription", room["roomDescription"] )
  setRoomUserData( roomRNumber, "roomExtraKeyword", room["roomExtraKeyword"] )

  -- Create the exits
  for _, exit in ipairs( room["exits"] ) do
    setExit( roomRNumber, exit["exitDest"], exit["exitDirection"] )
  end
end

function loadAreaData( areaRNumber )
  areaData = {}
  currentArea = areaRNumber
  local file = io.open( dataFile, 'r' )
  if not file then
    print( "Could not open dataFile" )
    return nil
  end
  local content = file:read( "*all" )
  file:close()

  local data, pos, err = dkjson.decode( content, 1, nil )
  if err then
    print( "Error:", err )
    return nil
  end
  local area = data[tostring( areaRNumber )]
  if not area then
    print( "Area not found with Area Number " .. areaRNumber )
    return nil
  end
  local rooms = {}
  for _, room in pairs( area["areaRooms"] ) do
    local roomRNumber = room["roomRNumber"]
    rooms[roomRNumber] = room
    local exits = {}
    if room["roomExits"] then
      for _, exit in pairs( room["roomExits"] ) do
        local exitDirection = DIRECTIONS[exit["exitDirection"]]
        if exitDirection then
          exits[exitDirection] = exit
        else
          print( "Invalid exit direction:", exit["exitDirection"] )
        end
      end
    end
    room["roomExits"] = exits
  end
  area["areaRooms"] = rooms

  return area
end

-- Use loadAreaData() to load all areas
function loadAllAreas()
  local areaData = {}
  local file = io.open( dataFile, 'r' )
  if not file then
    print( "Could not open file gizmo_world.json" )
    return areaData
  end
  local content = file:read( "*all" )
  file:close()

  local data, pos, err = dkjson.decode( content, 1, nil )
  if err then
    print( "Error:", err )
    return areaData
  end
  for areaRNumber, _ in pairs( data ) do
    local area = loadAreaData( areaRNumber )
    if area then
      areaData[tonumber( areaRNumber )] = area
    end
  end
  return areaData
end

-- Print the content of a room with highlights similar to the MUD output
function printRoom( roomRNumber )
  currentRoom = tonumber( roomRNumber )
  currentMaxRnum = areaData["areaMaxRoomRNumber"]
  currentMinRnum = areaData["areaMinRoomRNumber"]
  local roomData = areaData["areaRooms"][roomRNumber]
  --display( roomData )
  local areaNumber = roomData["roomAreaNumber"]
  local description = roomData["roomDescription"]
  local roomNum = roomData["roomRNumber"]
  local name = roomData["roomName"]
  local type = roomData["roomType"]

  local rn = MAPC["roomName"]
  local rd = MAPC["roomDesc"]
  local nc = MAPC["number"]
  local tc = TERRAIN_TYPES[type]

  cecho( f "\n\n{rn}{name}<reset> [{tc}{type}<reset>] ({nc}{roomNum}<reset>)" )
  cecho( f "\n{rd}{description}<reset>" )
  printExits( roomRNumber )

  --printExits( roomRNumber )
end

-- Given a room number, print that room's exits assuming it is in the areaData table
-- Use pairs to iterate because exits are not guaranteed to be contiguous (or present at all)
-- Print exits outside the range of the current area in a different color
function printExits( roomRNumber )
  local exitData = areaData["areaRooms"][roomRNumber]["roomExits"]

  local ec = MAPC["exitDir"]
  local es = MAPC["exitStr"]

  local exitString = ""
  local isFirstExit = true
  for _, exit in pairs( exitData ) do
    local dir = exit["exitDirection"]
    local to = exit["exitDest"]
    local nc = to > currentMaxRnum or to < currentMinRnum and MAPC["area"] or MAPC["number"]
    local nextExit = f "{ec}{dir}<reset> ({nc}{to}<reset>)"
    if isFirstExit then
      exitString = f "{es}Obvious Exits:   [" .. nextExit .. f "{es}]<reset>"
      isFirstExit = false
    else
      exitString = exitString .. f "  {es}[<reset>" .. nextExit .. f "{es}]<reset>"
    end
  end
  cecho( f "\n\t{exitString}" )
end

function updateCoordinates( direction )
  if direction == "north" then
    mY = mY + 1
  elseif direction == "south" then
    mY = mY - 1
  elseif direction == "east" then
    mX = mX + 1
  elseif direction == "west" then
    mX = mX - 1
  elseif direction == "up" then
    mZ = mZ + 1
  elseif direction == "down" then
    mZ = mZ - 1
  end
end

deleteMap()
clearScreen()
areaData = loadAreaData( 121 )
