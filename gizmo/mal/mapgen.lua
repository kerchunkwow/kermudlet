--[[
The purpose of mapgen.lua is to facilitate the creation of a Mudlet Map using the Mudlet Mapper API.
It accomplishes this by interacting with the worldData table which contains all Areas, Rooms, and Exits.

worldData Structure:
worldData[areaRNumber] = { area properties, rooms = { [roomRNumber] = { room properties, exits = { [index] = { exit properties } } } } }
This Lua table is structured hierarchically with Areas containing Rooms, and Rooms containing Exits, each populated with respective properties.

--]]

-- Load the world from our SQLite database
worldData       = loadWorldData()
currentRoomData = {}

-- Global table to store coordinates of rooms
roomCoordinates = {}

-- Coordinates to track the "physical" location of the room relative to the starting point of the Area so Mudlet can draw it
mX, mY, mZ      = 0, 0, 0

-- When outputting data related to map generation, use these colors to highlight specific fields wich cecho()
-- e.g., cecho( MAPGEN_COLORS["areaName"] .. area["areaName"] .. "<reset>" )
MAP_COLOR       = {
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
DIRECTIONS      = {
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
REVERSE         = {
  north = "south",
  south = "north",
  east  = "west",
  west  = "east",
  up    = "down",
  down  = "up"
}


lastRoom = nil
lastDir  = nil

-- Store the current room in a separate table for more efficient access
function setCurrentRoom( currentRoom )
  for areaRNumber, area in pairs( worldData ) do
    if area.rooms[currentRoom] then
      currentRoomData = area.rooms[currentRoom]
      currentRoomData.areaRNumber = areaRNumber
      currentRoomData.areaName = area.areaName
      return true
    end
  end
  return false
end

-- These coordinates are used to position new rooms in the Mudlet mapper UI; update them when we move
function updateCoordinates( direction, roomRNumber, areaRNumber )
  -- If roomCoordinates doesn't have a sub-table for this Area, create one
  roomCoordinates[areaRNumber] = roomCoordinates[areaRNumber] or {}
  local areaCoordinates = roomCoordinates[areaRNumber]

  -- Only set coordinates for a room once
  if not areaCoordinates[roomRNumber] then
    local nc = MAP_COLOR["number"]
    local ac = MAP_COLOR["area"]
    -- Calculate new coordinates
    local newX, newY, newZ = mX, mY, mZ
    if direction == "north" then
      newY = newY + 1
    elseif direction == "south" then
      newY = newY - 1
    elseif direction == "east" then
      newX = newX + 1
    elseif direction == "west" then
      newX = newX - 1
    elseif direction == "up" then
      newZ = newZ + 1
    elseif direction == "down" then
      newZ = newZ - 1
    end
    -- Check for rooms that have already been assigned to these coordinates (overlapping)
    for otherRoom, coords in pairs( areaCoordinates ) do
      if coords[1] == newX and coords[2] == newY and coords[3] == newZ and otherRoom ~= roomRNumber then
        local nc = MAP_COLOR["number"]
        mapInfo( f "Room {nc}{roomRNumber}<reset> overlaps Room {nc}{otherRoom}<reset>" )
        break
      end
    end
    -- Assign the first Room in each Area 0,0,0 if it's the first room being mapped
    if next( areaCoordinates ) == nil then
      local nc = MAP_COLOR["number"]
      mapInfo( f "New Area {ac}{areaRNumber}<reset>; Room {nc}{roomRNumber}<reset>" )
      newX, newY, newZ = 0, 0, 0
    end
    -- Update global coordinates and assign to the room
    mX, mY, mZ = newX, newY, newZ
    areaCoordinates[roomRNumber] = {mX, mY, mZ}
  else
    -- Use previously assigned coordinates
    mX, mY, mZ = unpack( areaCoordinates[roomRNumber] )
  end
end

clearScreen()
startExploration( 1121 )
