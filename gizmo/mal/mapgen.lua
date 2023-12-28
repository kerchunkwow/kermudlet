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
"areaFirstRoomRNumber": number, -- The roomRNumber of the first Room in the Area
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

dkjson        = require( 'dkjson' )

-- An initially empty table for holding data about Areas (either individually or in aggregate)
areaData      = {}
dataFile      = "C:/Dev/mud/mudlet/gizmo/mal/areadata/gizmo_world.json"

-- When outputting data related to map generation, use these colors to highlight specific fields wich cecho()
-- e.g., cecho( MAPGEN_COLORS["areaName"] .. area["areaName"] .. "<reset>" )
MAPC          = {
  ["area"]     = "<deep_pink>",
  ["number"]   = "<dark_orange>",
  ["roomName"] = "<royal_blue>",
  ["roomDesc"] = "<olive_drab>",
  ["exit"]     = "<light_sea_green>",
  ["exitDir"]  = "<medium_spring_green>",
  ["exitTo"]   = "<gold>"
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
  ["n"] = 1,
  ["s"] = 2,
  ["e"] = 3,
  ["w"] = 4,
  ["u"] = 5,
  ["d"] = 6
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

-- Load area data for a single area
function loadAreaData( areaRNumber )
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
  for _, room in ipairs( area["areaRooms"] ) do
    local roomRNumber = room["roomRNumber"]
    rooms[roomRNumber] = room
    local exits = {}
    if room["roomExits"] then
      for _, exit in ipairs( room["roomExits"] ) do
        local exitDirection = DIRECTIONS[exit["exitDirection"]]
        if exitDirection then
          exits[exitDirection] = exit
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
  local file = io.open( 'C:/Dev/mud/mudlet/gizmo/mal/areadata', 'r' )
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

function printRoom( roomRNumber )
  for _, area in pairs( areaData ) do
    if type( area ) == "table" then -- Check if area is a table
      local room = area["areaRooms"][roomRNumber]
      if room then
        cecho( "\nRoom Name: " .. room["roomName"] )
        cecho( "\nRoom Area Number: " .. room["roomAreaNumber"] )
        cecho( "\nRoom VNumber: " .. room["roomVNumber"] )
        cecho( "\nRoom RNumber: " .. room["roomRNumber"] )
        cecho( "\nRoom Type: " .. room["roomType"] )
        cecho( "\nRoom Spec: " .. tostring( room["roomSpec"] ) )
        cecho( "\nRoom Flags: " .. room["roomFlags"] )
        cecho( "\nRoom Description: " .. room["roomDescription"] )
        cecho( "\nRoom Extra Keyword: " .. room["roomExtraKeyword"] )
        for _, exit in ipairs( room["exits"] ) do
          cecho( "\nExit Direction: " .. exit["exitDirection"] )
          cecho( "\nExit Keyword: " .. exit["exitKeyword"] )
          cecho( "\nExit Flags: " .. exit["exitFlags"] )
          cecho( "\nExit Key: " .. exit["exitKey"] )
          cecho( "\nExit Description: " .. exit["exitDescription"] )
          cecho( "\nExit Dest: " .. exit["exitDest"] )
        end
        return
      end
    end
  end
  cecho( "\nRoom not found with Room Number " .. roomRNumber )
end

function myPrintRoom( roomRNumber )
  local roomData = areaData["areaRooms"][roomRNumber]
  local exitData = areaData["areaRooms"][roomRNumber]["roomExits"]
  local areaNumber = roomData["roomAreaNumber"]
  local description = roomData["roomDescription"]
  local roomNum = roomData["roomRNumber"]
  local name = roomData["roomName"]
  local type = roomData["roomType"]

  local rn = MAPC["roomName"]
  local rd = MAPC["roomDesc"]
  local tc = TERRAIN_TYPES[type]
  local nc = MAPC["number"]

  cecho( f "\n{rn}{name}<reset> [{tc}{type}<reset>] ({nc}{roomNum}<reset>)" )
  cecho( f "\n{rd}{description}<reset>" )
  display( exitData )
end

deleteMap()
areaData = loadAreaData( 121 )
myPrintRoom( 7590 )
