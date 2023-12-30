-- The purpose of mapgen.lua is to retrieve area data from a SQLite database to create a map within the Mudlet client.

-- Table to keep track of which areas and rooms have been successfully mapped
mappedStatus      = nil
-- Define a global table to track mapped areas and rooms
mappedData        = nil
-- A table to track Mudlet area numbers which will not necessarily be equal to areaRNumbers
-- Make sure we don't overwrite this on new sessions
areaMudletNumbers = nil

-- When outputting data related to map generation, use these colors to highlight specific fields wich cecho()
-- e.g., cecho( MAPGEN_COLORS["areaName"] .. area["areaName"] .. "<reset>" )
MAP_COLOR         = {
  -- Area, Room, Exit Data
  ["area"]      = "<deep_pink>",
  ["number"]    = "<dark_orange>",
  ["roomName"]  = "<royal_blue>",
  ["roomDesc"]  = "<ansi_light_black>",
  ["exitDir"]   = "<cyan>",
  ["exitStr"]   = "<dark_slate_grey>",
  ["exitSpec"]  = "<gold>",
  ["death"]     = "<ansi_red>",
  ["mapui"]     = "<medium_orchid>",
  ["cmd"]       = "<light_steel_blue>",
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
DIRECTIONS        = {
  ["north"] = 1,
  ["south"] = 2,
  ["east"]  = 3,
  ["west"]  = 4,
  ["up"]    = 5,
  ["down"]  = 6,
  ["n"]     = 1,
  ["s"]     = 2,
  ["e"]     = 3,
  ["w"]     = 4,
  ["u"]     = 5,
  ["d"]     = 6
}

-- Table to get the reverse of a direction; useful for bi-directional linking
REVERSE           = {
  north = "south",
  south = "north",
  east  = "west",
  west  = "east",
  up    = "down",
  down  = "up"
}

--[[
These globals are used to hold data related to the current Area and Room and track our "virtual position" on the map.
  currentAreaNumber: number; The areaRNumber of the Area we're mapping
  mX, mY, mZ: number; coordinates of Room we're mapping; used to draw room in Mudlet UI
currentRoom: dictionary; Room we're mapping as dictionary properties
areaData: dictionary; Area we're mapping as dictionary of properties
lastRoom: the roomRNumber of the room previous room
lastDir: the direction of our last movement; useful for linking]]

areaData           = nil
areaDataCache      = nil
currentAreaNumber  = nil
currentAreaName    = nil
currentAreaRNumber = nil
mX, mY, mZ         = 0, 0, 0
lastRoom           = nil
lastDir            = nil

currentRoom        = nil
-- {
--   roomName         = nil,
--   roomAreaNumber   = nil,
--   roomVNumber      = nil,
--   roomRNumber      = nil,
--   roomType         = nil,
--   roomSpec         = nil,
--   roomFlags        = nil,
--   roomDescription  = nil,
--   roomExtraKeyword = nil,
--   roomExits        = {}
-- }

-- Load the new area from cache or JSON
function loadAreaData( areaRNumber )
  -- If the destination area has been cached, load it from cache
  if areaDataCache[areaRNumber] then
    cecho( f "\nLoading area {MAP_COLOR['area']}{areaRNumber}<reset> from cache..." )
    areaData = areaDataCache[areaRNumber]
    return
  end
  -- Update currentAreaNumber to the destination area
  currentAreaNumber = areaRNumber

  -- Clear the primary areaData and load the new area from JSON
  areaData = {}

  local file = io.open( dataFile, 'r' )
  local content = file:read( "*all" )
  file:close()

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
  areaData["areaRooms"]            = rooms
  currentAreaRNumber               = areaData["areaRNumber"]
  currentMaxRnum                   = areaData["areaMaxRoomRNumber"]
  currentMinRnum                   = areaData["areaMinRoomRNumber"]
  currentAreaName                  = areaData["areaName"]
  mX, mY, mZ                       = 0, 0, 0

  -- Cache the newly loaded area
  areaDataCache[currentAreaNumber] = areaData
end

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
  currentRoom["roomFlags"]        = split( roomData["roomFlags"], " " )
  currentRoom["roomDescription"]  = roomData["roomDescription"]
  currentRoom["roomExtraKeyword"] = roomData["roomExtraKeyword"]
  currentRoom["roomExits"]        = roomData["roomExits"]
  currentRoom["deathTrap"]        = isIn( currentRoom["roomFlags"], "DEATH" )
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
  local uc          = MAP_COLOR["mapui"]

  cecho( f "\n\n{rn}{name}<reset> [{tc}{type}<reset>] ({nc}{roomNum}<reset>) ({uc}{mX}<reset>, {uc}{mY}<reset>, {uc}{mZ}<reset>)" )
  cecho( f "\n{rd}{description}<reset>" )
  printExits( roomNum )

  if currentRoom["deathTrap"] then
    cecho( f "\n\nThis is a {MAP_COLOR['death']}Death Trap<reset>; good thing this is all a dream." )
  end
  -- A little padding
  print( "\n" )
end

-- Given a room number, print that room's exits assuming it is in the areaData table
-- Use pairs to iterate because exits are not guaranteed to be contiguous (or present at all)
-- Print exits outside the range of the current area in a different color
function printExits( roomRNumber )
  local exitData = currentRoom["roomExits"]

  -- Exit string and styling variables
  local exitString = ""
  local ec = MAP_COLOR["exitDir"]
  local es = MAP_COLOR["exitStr"]
  local esp = MAP_COLOR["exitSpec"]
  local isFirstExit = true

  -- Assemble a complete exit string by iterating over the exit table and concatening each exit
  for _, exit in pairs( exitData ) do
    local dir      = exit["exitDirection"]
    local to       = exit["exitDest"]
    local keywords = exit["exitKeyword"]
    local flags    = exit["exitFlags"]
    local key      = exit["exitKey"]

    -- Given a room number, decide what color the exit should be based on room attributes
    local function exitColor()
      if to > currentMaxRnum or to < currentMinRnum then
        -- Exit leads out of the current area
        return MAP_COLOR["area"]
      elseif keywords ~= "" or flags ~= -1 or key > 0 then
        -- Exit has special properties (e.g., is a door, secret, etc.)
        return MAP_COLOR["exitSpec"]
      else
        local dstData = areaData["areaRooms"][to]
        local dstFlags = split( dstData["roomFlags"], " " )
        if isIn( dstFlags, "DEATH" ) then
          -- Exit leads to a death trap
          return MAP_COLOR["death"]
        else
          -- Exit is normal
          return MAP_COLOR["number"]
        end
      end
    end

    local nc       = exitColor( exit )

    local nextExit = f "{ec}{dir}<reset> ({nc}{to}<reset>)"
    if isFirstExit then
      exitString = f "{es}Exits:  [" .. nextExit .. f "{es}]<reset>"
      isFirstExit = false
    else
      exitString = exitString .. f " {es}[<reset>" .. nextExit .. f "{es}]<reset>"
    end
  end
  cecho( f "\n   {exitString}" )
end

-- Print information on a specific exit; useful especially for "special" exits
function printExit( direction )
  local exitData = currentRoom["roomExits"][DIRECTIONS[direction]]
  if exitData then
    local dir        = exitData["exitDirection"]
    local to         = exitData["exitDest"]
    local keywords   = exitData["exitKeyword"]
    local flags      = exitData["exitFlags"]
    local key        = exitData["exitKey"]
    local desc       = exitData["exitDescription"]
    local ec         = MAP_COLOR["exitDir"]
    local es         = MAP_COLOR["exitStr"]
    local esp        = MAP_COLOR["exitSpec"]
    local nc         = MAP_COLOR["number"]
    local exitString = ""

    local exitStr    = f "The {ec}{dir}<reset> exit: "
    if keywords and #keywords > 0 then exitStr = exitStr .. f "\n  keywords: {es}{keywords}<reset>" end
    if flags and flags ~= -1 then exitStr = exitStr .. f "\n  flags: {esp}{flags}<reset>" end
    if key and key > 0 then exitStr = exitStr .. f "\n  key: {nc}{key}<reset>, " end
    if desc and #desc > 0 then exitStr = exitStr .. f "\n  description: {es}{desc}<reset>" end
    cecho( f "\n{exitStr}" )
  else
    cecho( f "\n{MAP_COLOR['roomDesc']}You see no exit in that direction.<reset>" )
  end
end

-- Attempt to a virtual "move" by testing the direction then updating our position
function moveExit( direction )
  -- See if this direction is valid (appears in the roomExits table of the current room)
  for _, exit in pairs( currentRoom["roomExits"] ) do
    if exit.exitDirection == direction then
      local dst = exit.exitDest
      if dst > currentMaxRnum or dst < currentMinRnum then
        local nextArea = getRoomArea( dst )
        if nextArea then
          -- This direction leads to a different area; load that area then update and print the new room
          local startLoad = getStopWatchTime( "timer" )
          loadAreaData( nextArea )
          local endLoad = getStopWatchTime( "timer" )
          local loadTime = string.format( "%.3f", endLoad - startLoad )
          cecho( f "\n{MAP_COLOR['area']}Loading {MAP_COLOR['number']}{nextArea}<reset> took {MAP_COLOR['number']}{loadTime}<reset> seconds." )
          currentMaxRnum = areaData["areaMaxRoomRNumber"]
          currentMinRnum = areaData["areaMinRoomRNumber"]
          currentAreaName = areaData["areaName"]
          cecho( f "\n<dim_grey>Entering... [{MAP_COLOR['area']}{currentAreaName}<reset>]" )
        end
      else
        -- We stayed within the area; update our coordinates
        updateCoordinates( direction )
      end
      -- Direction and destination are valid; store our current room then update and print the new room
      lastRoom = currentRoom["roomRNumber"]
      lastDir = direction
      setCurrentRoom( exit.exitDest )
      printRoom()
      return
    end
  end
  -- Direction wasn't in the table of valid directions, print a MUD-like error
  cecho( f "\n<dim_grey>Alas, you cannot go that way.<reset>" )
  return false
end

-- These coordinates are used to position new rooms in the Mudlet mapper UI; update them when we move
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

-- Given a roomRNumber, return the areaRNumber of the area it's in; used to move between areas
function getRoomArea( roomRNumber )
  local str = io.open( dataFile, 'r' ):read( '*all' )
  local obj, pos, err = dkjson.decode( str, 1, nil )

  if err then
    gizErr( f "Error decoding JSON: {err}" )
    return nil
  end
  for areaRNumber, areaData in pairs( obj ) do
    if roomRNumber >= areaData["areaMinRoomRNumber"] and roomRNumber <= areaData["areaMaxRoomRNumber"] then
      return areaRNumber
    end
  end
  return nil
end

-- Function to check if an area or room is mapped
function isMapped( type, number )
  if mappedData[type] and mappedData[type][number] then
    return true
  else
    return false
  end
end

-- Attempt to add the current area to the Mudlet Mapper
function createCurrentArea()
  if not isMapped( "areas", currentAreaNumber ) then
    mappedStatus[currentAreaNumber] = {}
    mappedStatus[currentAreaNumber]["rooms"] = {}
    mappedStatus[currentAreaNumber]["mapped"] = true
    -- Save the ID returned by addAreaName for later mapping if needed
    areaMudletNumbers[currentAreaNumber] = addAreaName( currentAreaName )
  end
end

function createCurrentRoom()
  local roomRNumber = currentRoom["roomRNumber"]

  -- Check if the room has already been mapped
  if not isMapped( "rooms", roomRNumber ) then
    mappedStatus[currentAreaNumber]["rooms"][roomRNumber] = true

    -- Create the room
    addRoom( roomRNumber )

    -- Assign the room to the area
    setRoomArea( roomRNumber, currentAreaName )

    -- Set the room name
    setRoomName( roomRNumber, currentRoom["roomName"] )

    -- Store the extra room data
    setRoomUserData( roomRNumber, "roomVNumber", tostring( currentRoom["roomVNumber"] ) )
    setRoomUserData( roomRNumber, "roomType", tostring( currentRoom["roomType"] ) )
    setRoomUserData( roomRNumber, "roomSpec", tostring( currentRoom["roomSpec"] ) )
    setRoomUserData( roomRNumber, "roomFlags", tostring( currentRoom["roomFlags"] ) )
    setRoomUserData( roomRNumber, "roomDescription", tostring( currentRoom["roomDescription"] ) )
    setRoomUserData( roomRNumber, "roomExtraKeyword", tostring( currentRoom["roomExtraKeyword"] ) )
    setRoomCoordinates( roomRNumber, mX, mY, mZ )
    centerview( roomRNumber )
  end
end

-- Complete delete and reset the map and status tables
function deleteAndReset()
  deleteMap()
  mappedStatus = {}
  areaMudletNumbers = {}
end

clearScreen()
--loadAreaData( 21 )
--setCurrentRoom( 1121 )
--printRoom()
