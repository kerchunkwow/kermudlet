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

-- Create all Exits, Exit Stubs, and/or Doors from the Current Room to adjacent Rooms
function updateExits()
  for _, exit in ipairs( currentRoomData.exits ) do
    local exitDirection = exit.exitDirection
    if (not culledExits[currentRoomNumber]) or (not culledExits[currentRoomNumber][exitDirection]) then
      local exitDest = tonumber( exit.exitDest )
      local exitKeyword = exit.exitKeyword
      local exitFlags = exit.exitFlags
      local exitKey = tonumber( exit.exitKey )
      local exitDescription = exit.exitDescription

      -- Skip any exits that lead to the room we're already in
      if exitDest ~= currentRoomNumber then
        -- If the destination room is already mapped, remove any existing exit stub and create a "real" exit in that direction
        if roomExists( exitDest ) then
          setExitStub( currentRoomNumber, exitDirection, false )
          setExit( currentRoomNumber, exitDest, exitDirection )

          -- If the destination room we just linked links back to the current room, create the corresponding reverse exit
          local reverseDir = EXIT_MAP[REVERSE[exitDirection]]
          local destStubs = getExitStubs1( exitDest )
          if contains( destStubs, reverseDir, false ) then
            setExitStub( exitDest, reverseDir, false )
            setExit( exitDest, currentRoomNumber, reverseDir )
          end
          -- With all exits presumably created, call optimizeExits to remove superfluous or redundant exits
          -- (e.g., if room A has e/w exits to room B but room B only has an e exit to room A, we'll eliminate the w exit from A)
          --optimizeExits( currentRoomNumber )
        else
          -- If the destination room hasn't been mapped yet, create a stub for later
          setExitStub( currentRoomNumber, exitDirection, true )
        end
        -- The presence of exitFlags indicates a door; a non-zero key value indicates locked status
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

-- Create a new room in the Mudlet; by default operates on the "current" room being the one you just arrived in;
-- passing dir and id will create a room offset from the current room (which no associated user data)
function createRoom( dir, id )
  if not customColorsDefined then defineCustomEnvColors() end
  local newRoomNumber = id or currentRoomNumber
  local nX, nY, nZ = mX, mY, mZ
  if dir == "east" then
    nX = nX + 1
  elseif dir == "west" then
    nX = nX - 1
  elseif dir == "north" then
    nY = nY + 1
  elseif dir == "south" then
    nY = nY - 1
  elseif dir == "up" then
    nZ = nZ + 1
  elseif dir == "down" then
    nZ = nZ - 1
  end
  -- Create a new room in the Mudlet mapper in the Area we're currently mapping
  addRoom( newRoomNumber )
  if currentAreaNumber == 115 or currentAreaNumber == 116 then
    currentAreaNumber = 115
    currentAreaName = 'Undead Realm'
  end
  setRoomArea( newRoomNumber, currentAreaName )
  setRoomCoordinates( currentRoomNumber, nX, nY, nZ )

  if not dir and not id then
    setRoomName( newRoomNumber, currentRoomData.roomName )
    setRoomUserData( newRoomNumber, "roomVNumber", currentRoomData.roomVNumber )
    setRoomUserData( newRoomNumber, "roomType", currentRoomData.roomType )
    setRoomUserData( newRoomNumber, "roomSpec", currentRoomData.roomSpec )
    setRoomUserData( newRoomNumber, "roomFlags", currentRoomData.roomFlags )
    setRoomUserData( newRoomNumber, "roomDescription", currentRoomData.roomDescription )
    setRoomUserData( newRoomNumber, "roomExtraKeyword", currentRoomData.roomExtraKeyword )
  else
    setRoomName( newRoomNumber, tostring( id ) )
  end
  setRoomStyle()
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
  if currentAreaNumber == 21 or currentAreaNumber == 30 or currentAreaNumber == 24 or currentAreaNumber == 22 or currentAreaData == 110 then
    return 21
  elseif currentAreaNumber == 89 or currentAreaNumber == 116 or currentAreaNumber == 87 then
    return 87
  elseif currentAreaNumber == 108 or currentAreaNumber == 103 or currentAreaNumber == 102 then
    return 102
  else
    return tonumber( currentAreaNumber )
  end
end

-- Give new labels a relative starting point to speed up placement
function getLabelPosition( direction )
  if direction == 'n' then
    return -0.5, 0.5
  elseif direction == 's' then
    return -0.5, -0.5
  elseif direction == 'e' then
    return 0.5, 0.5
  elseif direction == 'w' then
    return -2.5, 0.5 -- Labels are justified, so move them further left to compensate
  end
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
  if labelType == "room" then
    labelText = addNewlineToRoomLabels( currentRoomName )
  elseif labelType == "key" and lastKey > 0 then
    labelText = tostring( lastKey )
    lastKey = -1
  elseif labelType == "proc" then
    labelText = currentRoomData.roomSpec
  else
    labelText = matches[4]
    -- Replace '\\n' in our label strings with a "real" newline; probably a better way to do this
    labelText = labelText:gsub( "\\\\n", "\n" )
  end
  labelArea = getRoomArea( currentRoomNumber )
  labelX = mX + dX
  labelY = mY + dY
  labelR, labelG, labelB, labelSize = getLabelStyle( labelType )
  if not labelSize then return end -- Return if type invalid
  labelID = createMapLabel( labelArea, labelText, labelX, labelY, mZ, labelR, labelG, labelB, 0, 0, 0, 0, labelSize, true,
    true, "Bitstream Vera Sans Mono", 255, 0 )

  enableKey( "Labeling" )
end

-- Once we're finished placing a label, clean up the globals we used to keep track of it
function finishLabel()
  labelText, labelArea, labelX, labelY = nil, nil, nil, nil
  labelR, labelG, labelB, labelSize = nil, nil, nil, nil
  labelID = nil
  disableKey( "Labeling" )
end

-- Delete the label we're working on and clean up globals
function cancelLabel()
  deleteMapLabel( labelArea, labelID )
  finishLabel()
end

-- Bind to keys in "Labeling" category to fine-tune label positions between addLabel() and finishLabel()
-- e.g., W for adjustLabel( 'left' ), CTRL-W for adjustLabel( 'left', 0.025 ) for finer-tune adjustments
function adjustLabel( direction, scale )
  -- Adjust the default scale as needed based on your Map's zoom level, font size, and auto scaling preference
  scale = scale or 0.05
  deleteMapLabel( labelArea, labelID )
  if direction == "left" then
    labelX = labelX - scale
  elseif direction == "right" then
    labelX = labelX + scale
  elseif direction == "up" then
    labelY = labelY + scale
  elseif direction == "down" then
    labelY = labelY - scale
  end
  -- Round coordinates to the nearest scale value
  labelX = round( labelX, scale )
  labelY = round( labelY, scale )
  -- Recreate the label at the new position
  labelID = createMapLabel( labelArea, labelText, labelX, labelY, mZ, labelR, labelG, labelB, 0, 0, 0, 0, labelSize, true,
    true, "Bitstream Vera Sans Mono", 255, 0 )
end

function setCurrentArea( id )
  -- Store the room number of the "entrance" so we can easily reset to the start of an area when mapping
  firstAreaRoomNumber = id
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
  setMapZoom( 29 )
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
    unHighlightRoom( currentRoomNumber )
    setRoomEnv( currentRoomNumber, COLOR_CLUB )
    setRoomChar( currentRoomNumber, "💤" )
    setRoomCharColor( currentRoomNumber, 0, 191, 255, 255 )
  elseif roomStyle == "shop" then
    unHighlightRoom( currentRoomNumber )
    setRoomEnv( currentRoomNumber, COLOR_SHOP )
    setRoomChar( currentRoomNumber, "$" )
    setRoomCharColor( currentRoomNumber, 140, 130, 15, 255 )
  end
end

-- Print a message w/ a tag denoting it as coming from our Mapper script
function mapInfo( message )
  cecho( f "\n  [<peru>M<reset>] {message}" )
end

function optimizeExits( roomID )
  local nc = MAP_COLOR["number"]
  local roomExits = getRoomExits( roomID )
  local exitCounts = {}

  -- Count the number of exits leading to each destination
  for dir, destID in pairs( roomExits ) do
    if not exitCounts[destID] then
      exitCounts[destID] = {}
    end
    table.insert( exitCounts[destID], dir )
  end
  for destID, exits in pairs( exitCounts ) do
    -- Proceed only if there are multiple exits leading to the same destination
    if #exits > 1 then
      mapInfo( f "Optimizing repeat exits from {nc}{roomID}<reset> to {nc}{destID}<reset>" )
      culledExits[roomID] = culledExits[roomID] or {}

      -- If the destination room has a "reverse" of the exit, keep that one
      local destExits = getRoomExits( destID )
      local reverseExit = nil
      for destDir, backDestID in pairs( destExits ) do
        if backDestID == roomID then
          reverseExit = destDir
          break
        end
      end
      -- Find the corresponding exit to keep
      local exitToKeep = nil
      if reverseExit then
        for _, exitDir in pairs( exits ) do
          if REVERSE[exitDir] == reverseExit then
            exitToKeep = exitDir
            break
          end
        end
      end
      -- If no corresponding exit, keep the first one in order n, s, e, w, u, d
      if not exitToKeep then
        local dirOrder = {"north", "south", "east", "west", "up", "down"}
        for _, dir in ipairs( dirOrder ) do
          if contains( exits, dir, true ) then
            exitToKeep = dir
            break
          end
        end
      end
      -- Remove all exits except the one to keep
      for _, exitDir in pairs( exits ) do
        if exitDir ~= exitToKeep then
          mapInfo( f( "Removing <cyan>{exitDir}<reset> exit between {nc}{roomID}<reset> and {nc}{destID}<reset>" ) )
          setExit( roomID, -1, exitDir )
          culledExits[roomID][exitDir] = true
          table.save( 'C:/Dev/mud/mudlet/gizmo/data/culledExits.lua', culledExits )
        end
      end
    end
  end
end

-- "Cull" or remove an exit from the map in the current room (useful for suppressing redundant exits, loops, etc.)
function cullExit( dir )
  -- Reject calls with invalid directions
  if not dir or (#dir == 1 and not LONG_DIRS[dir]) then return end
  -- If the direction is a single character, expand it
  if #dir == 1 and LONG_DIRS[dir] then
    dir = LONG_DIRS[dir]
  end
  cecho( f "\nCulling {dir} exit from {currentRoomNumber}" )
  culledExits[currentRoomNumber] = culledExits[currentRoomNumber] or {}
  setExit( currentRoomNumber, -1, dir )
  culledExits[currentRoomNumber][dir] = true
  table.save( 'C:/Dev/mud/mudlet/gizmo/data/culledExits.lua', culledExits )
  updateMap()
end
