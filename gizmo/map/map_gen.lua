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
    lastDir = direction
  end
  -- Update the current Room (this function updates Area as needed)
  setCurrentRoom( roomRNumber )
  -- If the room exists already, set coordinates, otherwise calculate new ones based on the direction of travel
  if roomExists( currentRoomNumber ) then
    mX, mY, mZ = getRoomCoordinates( currentRoomNumber )
  else
    mX, mY, mZ = getNextCoordinates( direction )
    createRoom()
  end
  updateExits()
  centerview( currentRoomNumber )
end

-- Create all of the exits from the current room either as stubs (if the destination room doesn't exist),
-- or as actual exits when it does
function updateExits()
  -- Create all Exits, Exit Stubs, and/or Doors from the Current Room to adjacent Rooms
  for _, exit in ipairs( currentRoomData.exits ) do
    local exitDirection = exit.exitDirection
    local exitDest = exit.exitDest
    local exitKeyword = exit.exitKeyword
    local exitFlags = exit.exitFlags
    local exitKey = tonumber( exit.exitKey )
    local exitDescription = exit.exitDescription


    -- If the destination room is already mapped, remove any existing exit stub and create a real exit
    if roomExists( exitDest ) then
      setExitStub( currentRoomNumber, exitDirection, false )
      setExit( currentRoomNumber, exitDest, exitDirection )

      -- Check if the destination room we just linked has a stub to the currentRoom to "link back"
      local reverseDir = EXIT_MAP[REVERSE[exitDirection]]
      local destStubs = getExitStubs1( exitDest )
      if contains( destStubs, reverseDir, false ) then
        setExitStub( exitDest, reverseDir, false )
        setExit( exitDest, currentRoomNumber, reverseDir )
      end
    else
      -- If the destination room is not mapped, create an exit stub
      setExitStub( currentRoomNumber, exitDirection, true )
    end
    if exitFlags and exitFlags ~= -1 then
      local doorStatus = (exitKey and exitKey > 0) and 3 or 2
      local shortExit = exitDirection:match( '%w' )
      setDoor( currentRoomNumber, shortExit, doorStatus )
      if exitKey and exitKey > 0 then
        setRoomUserData( currentRoomNumber, f "key_{shortExit}", exitKey )
      end
    end
  end
end

-- Get new coordinates based on the existing global coordinates and the recent direction of travel
function getNextCoordinates( direction )
  local nextX, nextY, nextZ = mX, mY, mZ
  -- Increment by 2 to provide a buffer on the Map for moving rooms around (don't buffer in the Z dimension)
  if direction == "north" then
    nextY = nextY + 2
  elseif direction == "south" then
    nextY = nextY - 2
  elseif direction == "east" then
    nextX = nextX + 2
  elseif direction == "west" then
    nextX = nextX - 2
  elseif direction == "up" then
    nextZ = nextZ + 1
  elseif direction == "down" then
    nextZ = nextZ - 1
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
  setRoomArea( currentRoomNumber, currentAreaName )
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
    lockRoom( id, true ) -- Lock this room so it won't ever be used for speedwalking
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
  setCustomEnvColor( COLOR_CLUB, 72, 61, 139, 255 )
  setCustomEnvColor( COLOR_INSIDE, 160, 82, 45, 255 )
  setCustomEnvColor( COLOR_FOREST, 107, 142, 35, 255 )
  setCustomEnvColor( COLOR_MOUNTAINS, 188, 143, 143, 255 )
  setCustomEnvColor( COLOR_CITY, 140, 140, 110, 255 )
  setCustomEnvColor( COLOR_WATER, 30, 144, 255, 255 )
  setCustomEnvColor( COLOR_FIELD, 35, 140, 35, 255 )
  setCustomEnvColor( COLOR_HILLS, 85, 105, 45, 255 )
  setCustomEnvColor( COLOR_DEEPWATER, 25, 25, 110, 255 )
  setCustomEnvColor( COLOR_OVERLAP, 250, 0, 250, 255 )
  setCustomEnvColor( COLOR_SHOP, 90, 90, 90, 255 )
end

-- For now, initialize our location as Market Square [1121]
function startExploration()
  clearScreen()
  openMapWidget()
  -- Set the starting Room to Market Square and initilize coordinates
  mX, mY, mZ = 0, 0, 0
  updatePlayerLocation( 1121 )
  displayRoom()
end

-- Group related areas into a contiguous group for labeling purposes
function getLabelArea()
  if currentAreaNumber == 21 or currentAreaNumber == 30 or currentAreaNumber == 24 or currentAreaNumber == 22 then
    return 21
  else
    return tonumber( currentAreaNumber )
  end
end

-- Give new labels a relative starting point to speed up placement
function getLabelPosition( direction )
  if direction == 'n' then
    return -0.5, 1
  elseif direction == 's' then
    return -0.5, -1
  elseif direction == 'e' then
    return 0.5, 1
  elseif direction == 'w' then
    return -1, 0.5
  end
end

-- Customize label style based on type categories
function getLabelStyle( labelType )
  if labelType == "area" then
    return 255, 20, 147, 10
  elseif labelType == "room" then
    return 255, 140, 0, 8
  elseif labelType == "note" then
    return 255, 215, 0, 8
  elseif labelType == "dir" then
    return 64, 224, 208, 8
  elseif labelType == "key" then
    return 127, 255, 0, 8
  elseif labelType == "warn" then
    return 255, 69, 0, 10
  end
  return 255, 0, 255, 30
end

-- Add a label string to the Map customized by topic
function addLabel()
  local labelDirection = matches[2]
  local labelType = matches[3]
  local dX = 0
  local dY = 0
  -- Adjust the label position based on initial direction parameter for less after-placement adjustment
  dX, dY = getLabelPosition( labelDirection )

  -- Hang on to the rest in globals so we can nudge with WASD; confirm with 'F' and cancel with 'C'
  labelText = matches[4]
  labelArea = getLabelArea()
  labelX = mX + dX
  labelY = mY + dY
  labelR, labelG, labelB, labelSize = getLabelStyle( labelType )
  labelID = createMapLabel( labelArea, labelText, labelX, labelY, mZ, labelR, labelG, labelB, 0, 0, 0, 0, labelSize, true,
    true, "Bitstream Vera Sans Mono", 255, 0 )

  enableKey( "Labeling" )
end

-- Nudge a label around on the map until satisfied; uses Mudlet aliases
function adjustLabel( direction )
  deleteMapLabel( labelArea, labelID )
  if direction == "left" then
    labelX = labelX - 0.05
  elseif direction == "right" then
    labelX = labelX + 0.05
  elseif direction == "up" then
    labelY = labelY + 0.05
  elseif direction == "down" then
    labelY = labelY - 0.05
  end
  labelID = createMapLabel( labelArea, labelText, labelX, labelY, mZ, labelR, labelG, labelB, 0, 0, 0, 0, labelSize, true,
    true, "Bitstream Vera Sans Mono", 255, 0 )
end

function setCurrentArea( id )
  -- If we're leaving an Area, store information and report on the transition
  if currentAreaNumber > 0 then
    lastAreaNumber = currentAreaNumber
    lastAreaName   = currentAreaName
    mapInfo( f "Left: {areaTag()}" )
  end
  currentAreaData   = worldData[id]
  currentAreaNumber = tonumber( currentAreaData.areaRNumber )
  currentAreaName   = tostring( currentAreaData.areaName )
  mapInfo( f "Entered {areaTag()}" )
end

function setCurrentRoom( id )
  -- If this is the first Area or the id is outside the current Area, update Area before Room
  if currentAreaNumber < 0 or (not worldData[currentAreaNumber].rooms[id]) then
    setCurrentArea( roomToAreaMap[id] )
  end
  -- Save our lastRoomNumber for back-linking
  if currentRoomNumber > 0 then
    lastRoomNumber = currentRoomNumber
  end
  currentRoomData   = currentAreaData.rooms[id]
  currentRoomNumber = currentRoomData.roomRNumber
  currentRoomName   = currentRoomData.roomName
end

function setRoomStyleAlias()
  local roomStyle = matches[2]
  if roomStyle == "mana" then
    setRoomEnv( currentRoomNumber, COLOR_CLUB )
    setRoomChar( currentRoomNumber, "M" )
    setRoomCharColor( currentRoomNumber, 0, 191, 255, 255 )
  elseif roomStyle == "shop" then
    setRoomEnv( currentRoomNumber, COLOR_SHOP )
    setRoomChar( currentRoomNumber, "$" )
    setRoomCharColor( currentRoomNumber, 200, 170, 25, 255 )
  end
end

-- Print a message w/ a tag denoting it as coming from our Mapper script
function mapInfo( message )
  cecho( f "\n  [<peru>M<reset>] {message}" )
end
