--[[ mapdef.lua

Globals & constants for Mapping & the Mudlet Mapper

--]]

-- Valid directions for exits and travel; MUD does not support diagonal travel
DIRECTIONS        = DIRECTIONS or {
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
REVERSE           = REVERSE or {
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

LONG_DIRS         = LONG_DIRS or {
  n = "north",
  s = "south",
  e = "east",
  w = "west",
  u = "up",
  d = "down"
}
SHORT_DIRS        = SHORT_DIRS or {
  north = "n",
  south = "s",
  east  = "e",
  west  = "w",
  up    = "u",
  down  = "d"
}
-- Map exit directions to internal IDs used by the Mudlet Mapper API
EXIT_MAP          = EXIT_MAP or {
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

currentAreaData   = {}
currentAreaNumber = {}
currentAreaName   = ""

currentRoomData   = {}
currentRoomNumber = -1
currentAreaNumber = -1
roomToAreaMap     = {}
worldData         = {}
culledExits       = {}
table.load( 'C:/Dev/mud/mudlet/gizmo/data/culledExits.lua', culledExits )

-- Coordinates to track the "physical" location of the room relative to the starting point of the Area so Mudlet can draw it
mX, mY, mZ          = 0, 0, 0

firstAreaRoomNumber = -1
lastRoomNumber      = -1
lastAreaNumber      = -1
lastAreaName        = ""
lastDir             = ""
lastKey             = -1
