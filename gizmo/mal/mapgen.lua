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
mX, mY, mZ  = 0, 0, 0 -- Coordinates of the room I'm currently mapping; for use by Mudlet to determine position in UI




-- When outputting data related to map generation, use these colors to highlight specific fields wich cecho()
-- e.g., cecho( MAPGEN_COLORS["areaName"] .. area["areaName"] .. "<reset>" )
MAP_COLOR  = {
  -- Area, Room, Exit Data
  ["area"]      = "<deep_pink>",
  ["number"]    = "<dark_orange>",
  ["roomName"]  = "<royal_blue>",
  ["roomDesc"]  = "<ansi_light_black>",
  ["exitDir"]   = "<cyan>",
  ["exitStr"]   = "<ansi_light_black>",
  ["death"]     = "<ansi_red>",
  -- Terrain/Sector Types
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
DIRECTIONS = {
  ["north"] = 1,
  ["south"] = 2,
  ["east"]  = 3,
  ["west"]  = 4,
  ["up"]    = 5,
  ["down"]  = 6
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

-- Reset and repopulate the areaData table with data from the world file
function loadAreaData( areaRNumber )
  areaData = {}
  currentArea = areaRNumber

  local file = io.open( dataFile, 'r' )
  local content = file:read( "*all" )
  file:close()

  -- Use dkjson library to parse the world JSON data
  local data, pos, err = dkjson.decode( content, 1, nil )
  if err then
    gizErr( f "Error decoding JSON: {err}" )
    return nil
  end
  areaData = data[tostring( areaRNumber )]
  if not areaData then
    gizErr( f "Invalid area number: {areaRNumber}" )
    return nil
  end
  local rooms = {}
  for _, room in pairs( areaData["areaRooms"] ) do
    local roomRNumber = room["roomRNumber"]
    rooms[roomRNumber] = room
    local exits = {}
    if room["roomExits"] then
      for _, exit in pairs( room["roomExits"] ) do
        local exitDirection = DIRECTIONS[exit["exitDirection"]]
        if exitDirection then
          exits[exitDirection] = exit
        else
          gizErr( f "Invalid exit direction in room {roomRNumber}" )
        end
      end
    end
    room["roomExits"] = exits
  end
  areaData["areaRooms"] = rooms
end

-- A global table to store the contents of the room we're curenting "in" as we map for Mudlet
currentRoom = {
  roomName         = nil,
  roomAreaNumber   = nil,
  roomVNumber      = nil,
  roomRNumber      = nil,
  roomType         = nil,
  roomSpec         = nil,
  roomFlags        = nil,
  roomDescription  = nil,
  roomExtraKeyword = nil,
  roomExits        = {}
}

-- Reset then set values in the currentRoom table based on the room we're currently mapping
function setCurrentRoom( roomRNumber )
  currentRoomNumber               = tonumber( roomRNumber )
  currentRoom                     = {}
  local roomData                  = areaData["areaRooms"][currentRoomNumber]
  currentRoom["roomName"]         = roomData["roomName"]
  currentRoom["roomAreaNumber"]   = roomData["roomAreaNumber"]
  currentRoom["roomVNumber"]      = roomData["roomVNumber"]
  currentRoom["roomRNumber"]      = roomData["roomRNumber"]
  currentRoom["roomType"]         = roomData["roomType"]
  currentRoom["roomSpec"]         = roomData["roomSpec"]
  currentRoom["roomFlags"]        = decodeValue( roomData["roomFlags"], ROOM_FLAGS )
  currentRoom["roomDescription"]  = roomData["roomDescription"]
  currentRoom["roomExtraKeyword"] = roomData["roomExtraKeyword"]
  currentRoom["roomExits"]        = roomData["roomExits"]
end

-- Print the content of the currentRoom w/ highlighting similar to MUD output
function printRoom()
  local areaNumber  = currentRoom["roomAreaNumber"]
  local description = currentRoom["roomDescription"]
  local roomNum     = currentRoom["roomRNumber"]
  local name        = currentRoom["roomName"]
  local type        = currentRoom["roomType"]

  local rn          = MAP_COLOR["roomName"]
  local rd          = MAP_COLOR["roomDesc"]
  local nc          = MAP_COLOR["number"]
  local tc          = MAP_COLOR[type]

  cecho( f "\n\n{rn}{name}<reset> [{tc}{type}<reset>] ({nc}{roomNum}<reset>)" )
  cecho( f "\n{rd}{description}<reset>" )
  printExits( roomRNumber )
end

-- Given a room number, print that room's exits assuming it is in the areaData table
-- Use pairs to iterate because exits are not guaranteed to be contiguous (or present at all)
-- Print exits outside the range of the current area in a different color
function printExits( roomRNumber )
  --local exitData = areaData["areaRooms"][roomRNumber]["roomExits"]
  local exitData = currentRoom["roomExits"]

  -- Exit string and styling variables
  local exitString = ""
  local ec = MAP_COLOR["exitDir"]
  local es = MAP_COLOR["exitStr"]
  local isFirstExit = true


  for _, exit in pairs( exitData ) do
    local dir = exit["exitDirection"]
    local to = exit["exitDest"]
    local nc = to > currentMaxRnum or to < currentMinRnum and MAP_COLOR["area"] or MAP_COLOR["number"]
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

-- Given a room number, decide what color the exit should be based on room attributes
function exitColor( roomRNumber )
  local dstData = areaData["areaRooms"][roomRNumber]
  local dstFlags = decodeValue( dstData["roomFlags"], ROOM_FLAGS )
  if isIn( dstFlags, "DEATH" ) then
    return MAP_COLOR["death"]
  end
  if roomRNumber > currentMaxRnum or roomRNumber < currentMinRnum then
    return MAP_COLOR["area"]
  else
    return MAP_COLOR["number"]
  end
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

function moveExit( direction )
  for _, exit in pairs( currentRoom["roomExits"] ) do
    if exit.exitDirection == direction then
      local dst = exit.exitDest
      if dst > currentMaxRnum or dst < currentMinRnum then
        cecho( f "\n<dim_grey>Alas, that would take you {MAP_COLOR['area']}elsewhere<reset>." )
        return
      end
      setCurrentRoom( exit.exitDest )
      printRoom()
      return
    end
  end
  cecho( f "\n<dim_grey>Alas, you cannot go that way.<reset>" )
  return false
end

deleteMap()
clearScreen()
loadAreaData( 121 )
currentMaxRnum = areaData["areaMaxRoomRNumber"]
currentMinRnum = areaData["areaMinRoomRNumber"]
setCurrentRoom( 7590 )
printRoom()
