--[[ mapdef.lua

Globals & constants for Mapping & the Mudlet Mapper

--]]

COLOR_DEATH         = 300
COLOR_CLUB          = 310
COLOR_INSIDE        = 320
COLOR_FOREST        = 330
COLOR_MOUNTAINS     = 340
COLOR_CITY          = 350
COLOR_WATER         = 360
COLOR_FIELD         = 370
COLOR_HILLS         = 380
COLOR_DEEPWATER     = 390
COLOR_OVERLAP       = 400

customColorsDefined = false

-- When outputting data related to map generation, use these colors to highlight specific fields wich cecho()
-- e.g., cecho( MAPGEN_COLORS["areaName"] .. area["areaName"] .. "<reset>" )
MAP_COLOR           = {
  -- Area, Room, Exit Data
  ["area"]      = "<deep_pink>",
  ["number"]    = "<dark_orange>",
  ["roomName"]  = "<light_steel_blue>",
  ["roomNameU"] = "<royal_blue>",
  ["roomDesc"]  = "<ansi_light_black>",
  ["exitDir"]   = "<cyan>",
  ["exitStr"]   = "<dark_slate_grey>",
  ["exitSpec"]  = "<gold>",
  ["death"]     = "<ansi_red>",
  ["mapui"]     = "<medium_orchid>",
  ["cmd"]       = "<light_steel_blue>",
}

-- Valid directions for exits and travel; MUD does not support diagonal travel
DIRECTIONS          = {
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
exitMap             = {
  n = 1,
  north = 1,
  e = 4,
  east = 4,
  w = 5,
  west = 5,
  s = 6,
  south = 6,
  u = 9,
  up = 9,
  d = 10,
  down = 10
}
-- Table to get the reverse of a direction; useful for bi-directional linking
REVERSE             = {
  north = "south",
  south = "north",
  east  = "west",
  west  = "east",
  up    = "down",
  down  = "up"
}

currentRoomData     = {}
currentRoomNumber   = -1
currentAreaNumber   = -1
roomToAreaMap       = {}
worldData           = {}

-- Coordinates to track the "physical" location of the room relative to the starting point of the Area so Mudlet can draw it
mX, mY, mZ          = 0, 0, 0

lastRoomNumber      = -1
lastAreaNumber      = -1
lastAreaName        = ""
lastDir             = ""
