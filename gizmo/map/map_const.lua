cecho( f '\n  <olive_drab>map_ux.lua<reset>: constants & defines for mapping & following the map' )

mapZoomLevel        = 28

-- Valid directions for exits and travel; MUD does not support diagonal travel
DIRECTIONS          = {
  north = 1,
  south = 2,
  east  = 3,
  west  = 4,
  up    = 5,
  down  = 6,
  n     = 1,
  s     = 2,
  e     = 3,
  w     = 4,
  u     = 5,
  d     = 6
}

-- Table to get the reverse of a direction; useful for bi-directional linking
REVERSE             = REVERSE or {
  north = "south",
  south = "north",
  east  = "west",
  west  = "east",
  up    = "down",
  down  = "up",
  n     = "south",
  s     = "north",
  e     = "west",
  w     = "east",
  u     = "down",
  d     = "up"
}

-- Use tables to map/translate directions into SHORT or LONG versions; include redundant entries to avoid "unmapping"
LDIR                = {
  n     = "north",
  s     = "south",
  e     = "east",
  w     = "west",
  u     = "up",
  d     = "down",
  north = "north",
  south = "south",
  east  = "east",
  west  = "west",
  up    = "up",
  down  = "down"
}

SDIR                = {
  north = "n",
  south = "s",
  east  = "e",
  west  = "w",
  up    = "u",
  down  = "d",
  n     = "n",
  s     = "s",
  e     = "e",
  w     = "w",
  u     = "u",
  d     = "d"
}
-- Map exit directions to internal IDs used by the Mudlet Mapper API
EXIT_MAP            = EXIT_MAP or {
  north = 1,
  south = 6,
  east  = 4,
  west  = 5,
  up    = 9,
  down  = 10,
  n     = 1,
  s     = 6,
  e     = 4,
  w     = 5,
  u     = 9,
  d     = 10,
}

currentAreaData     = {}
currentAreaNumber   = {}
currentAreaName     = ""
currentRoomData     = {}
currentRoomNumber   = -1
currentAreaNumber   = -1
roomToAreaMap       = {}
worldData           = {}
culledExits         = {}

-- Coordinates to track the "physical" location of the room relative to the starting point of the Area so Mudlet can draw it
mX, mY, mZ          = 0, 0, 0

lastRoomNumber      = -1
lastAreaNumber      = -1
lastAreaName        = ""
lastDir             = ""
lastKey             = -1
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
COLOR_LANDMARK      = 410
COLOR_SHOP          = 420
COLOR_PROC          = 430

customColorsDefined = false

-- When outputting data related to map generation, use these colors to highlight specific fields wich cecho()
-- e.g., cecho( MAPGEN_COLORS["areaName"] .. area["areaName"] .. "<reset>" )
MAP_COLOR           = {
  -- Area, Room, Exit Data
  ["area"]      = "<maroon>",
  ["number"]    = "<dark_orange>",
  ["roomName"]  = "<sky_blue>",
  ["roomNameU"] = "<royal_blue>",
  ["roomDesc"]  = "<olive_drab>",
  ["exitDir"]   = "<cyan>",
  ["exitStr"]   = "<dark_slate_grey>",
  ["exitSpec"]  = "<gold>",
  ["death"]     = "<orange_red>",
  ["mapui"]     = "<medium_orchid>",
  ["cmd"]       = "<light_steel_blue>",
  ['Forest']    = "<olive_drab>",
  ['Mountains'] = "<rosy_brown>",
  ['City']      = "<dim_grey>",
  ['Water']     = "<dodger_blue>",
  ['Field']     = "<medium_sea_green>",
  ['Hills']     = "<ansi_yellow>",
  ['Deepwater'] = "<midnight_blue>",
  ['Inside']    = "<sienna>",
}
