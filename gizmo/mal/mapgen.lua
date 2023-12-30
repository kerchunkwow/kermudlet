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
      return true
    end
  end
  return false
end

-- Attempt a "virtual move" in the given direction; if successful report on any area transitions and update
-- our virtual coordinates accordingly.
function moveExit( direction )
  for _, exit in pairs( currentRoomData.exits ) do
    if exit.exitDirection == direction then
      local dst = exit.exitDest
      for _, area in pairs( worldData ) do
        if area.rooms[dst] then
          -- Report on any area transitions
          if currentRoomData.areaRNumber ~= area.areaRNumber then
            local leavingAreaName = worldData[currentRoomData.areaRNumber].areaName
            local enteringAreaName = area.areaName
            local ac = MAP_COLOR["area"]
            mapInfo( f "Left {ac}{leavingAreaName}<reset>; Entered {ac}{enteringAreaName}" )
          end
          -- Update coordinates for the new Room (and possibly Area)
          updateCoordinates( direction, dst, area.areaRNumber )
          setCurrentRoom( dst )
          displayRoom()
          return true
        end
      end
    end
  end
  cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
  return false
end

-- Assuming you have a function to start the exploration or load the first room
function startExploration()
  -- Set the starting Room to Market Square and initilize coordinates
  mX, mY, mZ = 0, 0, 0
  roomCoordinates[21] = {}
  roomCoordinates[21][1121] = {mX, mY, mZ}
  setCurrentRoom( 1121 )
  -- Display the starting room
  displayRoom()
end

-- These coordinates are used to position new rooms in the Mudlet mapper UI; update them when we move
function updateCoordinates( direction, roomRNumber, areaRNumber )
  -- If roomCoordinates doesn't have a sub-table for this Area, create one
  roomCoordinates[areaRNumber] = roomCoordinates[areaRNumber] or {}
  local areaCoordinates = roomCoordinates[areaRNumber]

  -- Only set coordinates for a room once
  if not areaCoordinates[roomRNumber] then
    -- Assign the first Room in each Area 0,0,0
    if next( areaCoordinates ) == nil then
      local nc = MAP_COLOR["number"]
      local ac = MAP_COLOR["area"]
      local mc = MAP_COLOR["mapui"]
      mapInfo( f "New Area {ac}30<reset>; Room {nc}{roomRNumber}<reset>" )
      mX, mY, mZ = 0, 0, 0
    else
      -- Update and assign new coordinates
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
    areaCoordinates[roomRNumber] = {mX, mY, mZ}
  else
    -- Use previously assigned coordinates
    mX, mY, mZ = unpack( areaCoordinates[roomRNumber] )
  end
end

function virtualRecall()
  local funnyMessages = {
    "you won from a scratch-off lottery ticket.",
    "you found stuck your shoe.",
    "your mother sent you in a birthday card.",
    "no that was a Starbucks gift card.",
    "you giant pussy.",
  }

  local funnyMessage = funnyMessages[math.random( #funnyMessages )]

  cecho( f "\n\n<orchid>You recite a <deep_pink>scroll of recall<orchid> " .. funnyMessage .. "<reset>\n" )
  tempTimer( 0.1, function () setCurrentRoom( 1121 ) end )
  tempTimer( 0.2, function () displayRoom() end )
end

clearScreen()
startExploration( 1121 )
