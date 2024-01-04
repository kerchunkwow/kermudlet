--[[

The purpose of mapgen.lua is to facilitate the creation of a Mudlet Map using the Mudlet Mapper API.
It accomplishes this by interacting with the worldData table which contains all Areas, Rooms, and Exits.

worldData Structure:
worldData[areaRNumber] = { area properties, rooms = { [roomRNumber] = { room properties, exits = { [index] = { exit properties } } } } }
This Lua table is structured hierarchically with Areas containing Rooms, and Rooms containing Exits, each populated with respective properties.

--]]

worldData = loadWorldData()

-- Set & update the player's location, updating coordinates & creating rooms as necessary
function updatePlayerLocation( roomRNumber, direction )
  -- Store data about where we "came from" to get here
  if direction then
    lastDir        = direction
    lastRoomNumber = currentRoomNumber
    lastAreaNumber = currentRoomData.areaRNumber
    lastAreaName   = currentRoomData.areaName
  end
  -- Update current room data
  currentRoomNumber           = roomRNumber
  currentRoomData             = getRoomData( currentRoomNumber )
  currentRoomData.areaRNumber = roomToAreaMap[currentRoomNumber]
  currentRoomData.areaName    = worldData[currentRoomData.areaRNumber].areaName

  if roomExists( currentRoomNumber ) then
    lX, lY, lZ = getNextCoordinates( direction )
    mX, mY, mZ = getRoomCoordinates( currentRoomNumber )
  else
    if currentRoomData.areaRNumber ~= lastAreaNumber then
      lX, lY, lZ = getNextCoordinates( direction )
      mX, mY, mZ = 0, 0, 0
    else
      mX, mY, mZ = getNextCoordinates( direction )
    end
    createRoom()
  end
  createExits()
  centerview( currentRoomNumber )
end

-- Create all of the exits from the current room either as stubs (if the destination room doesn't exist),
-- or as actual exits when it does
function createExits()
  -- Create all Exits, Exit Stubs, and/or Doors from the Current Room to adjacent Rooms
  for _, exit in ipairs( currentRoomData.exits ) do
    local exitDirection = exit.exitDirection
    local exitDest = exit.exitDest
    local exitKeyword = exit.exitKeyword
    local exitFlags = exit.exitFlags
    local exitKey = exit.exitKey
    local exitDescription = exit.exitDescription

    -- If the destination room is already mapped, remove any existing exit stub and create a real exit
    if roomExists( exitDest ) then
      setExitStub( currentRoomNumber, exitDirection, false )
      setExit( currentRoomNumber, exitDest, exitDirection )

      -- Check if the destination room we just linked has a stub to the currentRoom to "link back"
      local reverseDir = exitMap[REVERSE[exitDirection]]
      local destStubs = getExitStubs1( exitDest )
      if isIn( reverseDir, destStubs ) then
        setExitStub( exitDest, reverseDir, false )
        setExit( exitDest, currentRoomNumber, reverseDir )
      end
    else
      -- If the destination room is not mapped, create an exit stub
      setExitStub( currentRoomNumber, exitDirection, true )
    end
    -- If the exit has any flags, assume it's a door
    if exitFlags and exitFlags ~= -1 then
      -- If the door has a key, it's locked (3)
      local status = (exitKey and exitKey > 0) and 3 or 2
      local keyword = exit.exitKeyword:match( "%w+" )
      setDoor( currentRoomNumber, exitDirection, status )
    end
  end
end

function createExits2()
  -- Create exit from the last room to the current room
  if lastRoomNumber > 0 and lastDir then
    setExit( lastRoomNumber, currentRoomNumber, lastDir )
  end
  -- Check if there's an exit from the current room back to the last room
  for _, exit in ipairs( currentRoomData.exits ) do
    if exit.exitDest == lastRoomNumber then
      setExit( currentRoomNumber, lastRoomNumber, REVERSE[lastDir] )
      break -- Exit found, no need to check further
    end
  end
end

-- Get new coordinates based on the existing global coordinates and the recent direction of travel
function getNextCoordinates( direction )
  local nextX, nextY, nextZ = mX, mY, mZ
  if direction == "north" then
    nextY = nextY + 2
  elseif direction == "south" then
    nextY = nextY - 2
  elseif direction == "east" then
    nextX = nextX + 2
  elseif direction == "west" then
    nextX = nextX - 2
  elseif direction == "up" then
    nextZ = nextZ + 2
  elseif direction == "down" then
    nextZ = nextZ - 2
  end
  return nextX, nextY, nextZ
end

-- Create a new room in the Mudlet
function createRoom()
  if not customColorsDefined then defineCustomEnvColors() end
  -- Create a new room in the Mudlet mapper
  addRoom( currentRoomNumber )
  setRoomName( currentRoomNumber, currentRoomData.roomName )
  -- Assign the room to its Area with coordinates
  setRoomArea( currentRoomNumber, currentRoomData.areaName )
  setRoomCoordinates( currentRoomNumber, mX, mY, mZ )
  setRoomUserData( currentRoomNumber, "roomVNumber", currentRoomData.roomVNumber )
  setRoomUserData( currentRoomNumber, "roomType", currentRoomData.roomType )
  setRoomUserData( currentRoomNumber, "roomSpec", currentRoomData.roomSpec )
  setRoomUserData( currentRoomNumber, "roomFlags", currentRoomData.roomFlags )
  setRoomUserData( currentRoomNumber, "roomDescription", currentRoomData.roomDescription )
  setRoomUserData( currentRoomNumber, "roomExtraKeyword", currentRoomData.roomExtraKeyword )
  setRoomStyle()
end

-- Set the color of the current Room on the map based on terrain type or attributes
function setRoomStyle()
  if not customColorsDefined then
    defineCustomEnvColors()
  end
  local id = currentRoomNumber
  -- Check if 'DEATH' is present in roomFlags
  if currentRoomData.roomFlags and string.find( currentRoomData.roomFlags, "DEATH" ) then
    setRoomEnv( id, COLOR_DEATH )
    setRoomChar( id, "DT" )
  elseif currentRoomData.roomFlags and string.find( currentRoomData.roomFlags, "CLUB" ) then
    setRoomEnv( id, COLOR_CLUB )
    setRoomChar( id, "M" )
    return
  else
    -- Check roomType and set color accordingly
    local roomTypeToColor = {
      ["Inside"]    = COLOR_INSIDE,
      ["Forest"]    = COLOR_FOREST,
      ["Mountains"] = COLOR_MOUNTAINS,
      ["City"]      = COLOR_CITY,
      ["Water"]     = COLOR_WATER,
      ["Field"]     = COLOR_FIELD,
      ["Hills"]     = COLOR_HILLS,
      ["Deepwater"] = COLOR_DEEPWATER
    }

    local color = roomTypeToColor[currentRoomData.roomType]
    setRoomEnv( id, color )
  end
  updateMap()
end

function createEmptyAreas()
  for _, areaData in pairs( worldData ) do
    local areaName, areaID = areaData.areaName, areaData.areaRNumber
    if areaID ~= 0 then
      addAreaName( areaName )
    end
  end
  for _, areaData in pairs( worldData ) do
    local areaName, areaID = areaData.areaName, areaData.areaRNumber
    if areaID ~= 0 then
      setAreaName( areaID, areaName )
    end
  end
end

function defineCustomEnvColors()
  customColorsDefined = true
  setCustomEnvColor( COLOR_DEATH, 255, 69, 0, 255 )
  setCustomEnvColor( COLOR_CLUB, 255, 215, 0, 255 )
  setCustomEnvColor( COLOR_INSIDE, 160, 82, 45, 255 )
  setCustomEnvColor( COLOR_FOREST, 107, 142, 35, 255 )
  setCustomEnvColor( COLOR_MOUNTAINS, 188, 143, 143, 255 )
  setCustomEnvColor( COLOR_CITY, 140, 140, 110, 255 )
  setCustomEnvColor( COLOR_WATER, 30, 144, 255, 255 )
  setCustomEnvColor( COLOR_FIELD, 35, 140, 35, 255 )
  setCustomEnvColor( COLOR_HILLS, 85, 105, 45, 255 )
  setCustomEnvColor( COLOR_DEEPWATER, 25, 25, 110, 255 )
  setCustomEnvColor( COLOR_OVERLAP, 250, 0, 250, 255 )
end

-- For now, initialize our location as Market Square [1121]
function startExploration()
  --deleteMap()
  clearScreen()
  --createEmptyAreas()
  openMapWidget()
  -- Set the starting Room to Market Square and initilize coordinates
  mX, mY, mZ                  = 0, 0, 0
  -- Update current room data
  currentRoomNumber           = 1121
  currentRoomData             = getRoomData( currentRoomNumber )
  currentRoomData.areaRNumber = roomToAreaMap[currentRoomNumber]
  currentRoomData.areaName    = worldData[currentRoomData.areaRNumber].areaName
  if not roomExists( 1121 ) then createRoom() end
  updatePlayerLocation( currentRoomNumber )
  displayRoom()
end

-- Function to check if a value is in a list
function isIn( value, list )
  for _, v in ipairs( list ) do
    if v == value then
      return true
    end
  end
  return false
end

function addLabel()
  local lblType = tostring( matches[2] )
  local lblString = tostring( matches[3] )
  local lr = 0
  local lg = 0
  local lb = 0
  if lblType == "area" then
    lr, lg, lb = 255, 20, 147
  elseif lblType == "room" then
    lr, lg, lb = 255, 140, 0
  else
    return
  end
  print( lblType, lblString )
  createMapLabel( currentRoomData.areaRNumber, lblString, mX, mY, mZ, lr, lg, lb, 0, 0, 0, 30, 10, true, false,
    "Bitstream Vera Sans Mono", 255, 0 )
end
