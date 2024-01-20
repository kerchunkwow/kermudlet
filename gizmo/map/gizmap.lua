runLuaFile( f "{rootDirectory}map/map_def.lua" )
runLuaFile( f "{rootDirectory}map/map_ux.lua" )
runLuaFile( f "{rootDirectory}map/data/area_dirs.lua" )
runLuaFile( f "{rootDirectory}map/data/door_data.lua" )
runLuaFile( f "{rootDirectory}map/data/unique_rooms.lua" )
culledExits = {}
table.load( f '{rootDirectory}map/data/culledExits.lua', culledExits )
-- Print a message w/ a tag denoting it as coming from our Mapper script
function mapInfo( message )
  cecho( f "\n  [<peru>M<reset>] {message}" )
end

-- Follow a list of directions; also used by the click-to-walk functionality from the Mapper
function doSpeedWalk()
  for _, dir in ipairs( speedWalkDir ) do
    if #dir > 1 then dir = SDIR[dir] end
    expandAlias( dir )
  end
end

-- Get a complete Wintin-compatible path between two rooms including door commands
function getFullDirs( srcID, dstID )
  -- Clear Mudlet's pathing globals
  speedWalkDir = nil
  speedWalkPath = nil

  -- Use Mudlet's built-in path finding to get the initial path
  local rm = srcID
  if getPath( srcID, dstID ) then
    -- Initialize a table to hold the full path
    local fullPathString1, fullPathString2 = "", ""
    local fullPath = {}
    for d = 1, #speedWalkDir do
      local dir = LDIR[tostring( speedWalkDir[d] )]
      local doors = getDoors( rm )
      if doors[dir] and doorData[rm] and doorData[rm][dir] then
        local doorInfo = doorData[rm][dir]
        -- If the door has a key associated with it; insert an unlock command into the path
        if doorInfo.exitKEy and doorInfo.exitKey > 0 then
          table.insert( fullPath, "unlock " .. doorInfo.exitKeyword )
        end
        -- All doors regardless of locked state need opening
        table.insert( fullPath, "open " .. doorInfo.exitKeyword )
        table.insert( fullPath, dir )
        -- Close doors behind us to minimize wandering mobs
        table.insert( fullPath, "close " .. doorInfo.exitKeyword )
      else
        -- With no door, just add the original direction
        table.insert( fullPath, dir )
      end
      -- "Step" to the next room along the path
      rm = tonumber( speedWalkPath[d] )
    end
    -- Convert the path to a Wintin-compatible command string
    fullPathString = createWintin( fullPath )
    return fullPathString
  end
  cecho( f "\n<firebrick>Failed to find a path between {srcID} and {dstID}<reset>" )
  return nil
end

function inspectExit( id, direction )
  local dir = LDIR[direction]
  local exits = getRoomExits( id )
  if exits[dir] then
    local dstRoomString = getRoomString( exits[dir], 1 )
    local doorString = nil
    doorString = ""
    local word, key = nil, nil
    if doorData[id] and doorData[id][dir] then
      doorString = getDoorString( doorData[id][dir].exitKeyword, doorData[id][dir].exitKey )
    end
    cecho( f "\n<dim_grey>Looking <dark_slate_grey>{dir}<reset>{doorString} <dim_grey>you see<reset> {dstRoomString}" )
  else
    cecho( f "\n<dim_grey>Looking <dark_slate_grey>{dir}<dim_grey> you see why you didn't do well in geography class" )
  end
end

-- Virtually traverse an exit from the players' current location to an adjoining room
function moveExit( direction )
  -- Make sure direction is long-version like 'north' to align with getRoomExits()
  local dir = LDIR[direction]
  local exits = getRoomExits( currentRoomNumber )

  if not exits[dir] then
    cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
    return false
  end
  local dst = tonumber( exits[dir] )
  if roomExists( dst ) then
    updatePlayerLocation( dst, direction )
    displayRoom()
    return true
  end
  cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
  return false
end

-- Simulate a 'scroll of recall'; magical item in game that returns the player to the starting room
function virtualRecall()
  cecho( f "\n\n<orchid>You recite a <deep_pink>scroll of recall<orchid>.<reset>\n" )
  updatePlayerLocation( 1121 )
  displayRoom()
end

-- Get a virtualized "room" w/ name, description, and supporting data
function getRoomString( id, detail )
  detail = detail or 1
  local specTag = nil
  specTag = ""
  local roomString = nil
  local nc = MAP_COLOR["number"]
  local rc = nil
  local roomName = getRoomName( id )
  local roomSpec = tonumber( getRoomUserData( id, "roomSpec" ) )
  local roomType = getRoomUserData( id, "roomType" )

  if uniqueRooms[roomName] then
    rc = MAP_COLOR['roomNameU']
  else
    rc = MAP_COLOR['roomName']
  end
  -- Append specTag if roomSpec is available
  if roomSpec and roomSpec > 0 then
    specTag = f " ~<ansi_light_yellow>{roomSpec}<reset>~"
  end
  -- Detail 1: Just the name
  if detail == 1 then
    roomString = f "{rc}{roomName}<reset>{specTag}"
    return roomString
  end
  -- Add number and type for detail level 2
  local tc = MAP_COLOR[roomType] or MAP_COLOR["mapui"]
  if detail == 2 then
    roomString = f "{rc}{roomName}<reset> [{tc}{roomType}<reset>] ({nc}{id}<reset>){specTag}"
    return roomString
  end
  -- Add map coordinates at level 3
  local uc = MAP_COLOR["mapui"]
  local cX, cY, cZ = getRoomCoordinates( id )
  local cString = f "{uc}{cX}<reset>, {uc}{cY}<reset>, {uc}{cZ}<reset>"
  roomString = f "{rc}{roomName}<reset> [{tc}{roomType}<reset>] ({nc}{id}<reset>) ({cString}){specTag}"
  return roomString
end

function getDoorString( word, key )
  -- Double declaration because VSCode is confused by f-string interpolation
  local doorString, keyString, wordString = nil, nil, nil
  doorString, keyString, wordString = "", "", ""
  if word then wordString = f "<light_goldenrod>{word}<reset>" end
  if key then keyString = f " (<lawn_green>{key}<reset>)" end
  doorString = f " <dim_grey>past a {wordString}{keyString}"
  return doorString
end

function displayRoom( brief )
  brief = brief or true
  local rd = MAP_COLOR["roomDesc"]
  cecho( f "\n\n{getRoomString(currentRoomNumber, 1)}" )
  if not brief then
    local desc = getRoomUserData( currentRoomNumber, "roomDescription" )
    cecho( f "\n{rd}{desc}<reset>" )
  end
  local rSpec = tonumber( getRoomUserData( currentRoomNumber, "roomSpec" ) )
  if rSpec and rSpec > 0 then
    cecho( f "\n\tThis room has a ~<ansi_light_yellow>special procedure<reset>~.\n" )
  end
  --displayExits( currentRoomNumber )
  displayExits( currentRoomNumber )
end

function displayExits( id )
  local isFirstExit = true
  local exitData = getRoomExits( id )
  local sortedExits = {}
  local exitString = ""
  local dc = MAP_COLOR["exitDir"]

  for dir, to in pairs( exitData ) do
    table.insert( sortedExits, {dir = dir, to = to} )
  end
  table.sort( sortedExits, function ( a, b )
    local dirA = DIRECTIONS[a.dir]
    local dirB = DIRECTIONS[b.dir]
    return dirA < dirB
  end )
  for _, exit in ipairs( sortedExits ) do
    local dir = exit.dir
    local to = exit.to
    local tc = getExitColor( to, dir )
    --local nextExit = f "{dc}{dir}<reset> ({tc}{to}<reset>)"
    local nextExit = f "{tc}{dir}<reset>"
    if isFirstExit then
      isFirstExit = false
      exitString = f "<dim_grey>Exits:  [" .. nextExit .. f "<dim_grey>]<reset>"
    else
      exitString = exitString .. f " <dim_grey>[<reset>" .. nextExit .. f "<dim_grey>]<reset>"
    end
  end
  cecho( f "\n   {exitString}" )
end

function updatePlayerLocation( id, dir )
  -- Store data about where we "came from" to get here
  if dir then
    lastDir = dir
  end
  setCurrentRoom( id )
  mX, mY, mZ = getRoomCoordinates( currentRoomNumber )
  centerview( currentRoomNumber )
end

function setCurrentRoom( id )
  local roomNumber = tonumber( id )
  local roomArea = getRoomArea( roomNumber )
  roomArea = tonumber( roomArea )
  -- If this is the first Area or the id is outside the current Area, update Area before Room
  if currentAreaNumber ~= roomArea then
    setCurrentArea( roomArea )
  end
  currentRoomNumber = roomNumber
  currentRoomName   = getRoomName( currentRoomNumber )
  roomExits         = getRoomExits( currentRoomNumber )
end

function setCurrentArea( id )
  -- If we're leaving an Area, store information and report on the transition
  if currentAreaNumber > 0 then
    lastAreaNumber = currentAreaNumber
    lastAreaName   = currentAreaName
  end
  currentAreaNumber = id
  currentAreaName   = getRoomAreaName( id )
  cecho( f "\n<dim_grey>  Entering {areaTag()}" )
  setMapZoom( 28 )
end

function areaTag()
  return f "<medium_violet_red>{currentAreaName}<reset> [<maroon>{currentAreaNumber}<reset>]"
end

-- "Cull" or remove an exit from the map in the current room (useful for suppressing redundant exits, loops, etc.)
function cullExit( dir )
  -- If the direction is a single character, expand it to its long form
  if #dir == 1 and LDIR[dir] then
    dir = LDIR[dir]
  end
  cecho( f "\nCulling <cyan>{dir}<reset> exit from <dark_orange>{currentRoomNumber}<reset>" )
  culledExits[currentRoomNumber] = culledExits[currentRoomNumber] or {}
  setExit( currentRoomNumber, -1, dir )
  culledExits[currentRoomNumber][dir] = true
  table.save( '{rootDirectory}map/data/culledExits.lua', culledExits )
  updateMap()
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

-- For now, initialize our location as Market Square [1121]
function startExploration()
  openMapWidget()
  -- Set the starting Room to Market Square and initilize coordinates
  mX, mY, mZ = 0, 0, 0
  updatePlayerLocation( 1121 )
  displayRoom()
end

-- Customize label style based on type categories
function getLabelStyle( labelType )
  if labelType == "area" then
    return 199, 21, 133, 10
  elseif labelType == "room" then
    return 65, 105, 225, 8
  elseif labelType == "note" then
    return 189, 183, 107, 8
  elseif labelType == "dir" then
    return 64, 224, 208, 8
  elseif labelType == "key" then
    return 127, 255, 0, 8
  elseif labelType == "warn" then
    return 255, 99, 71, 10
  elseif labelType == "proc" then
    return 85, 25, 110, 8
  end
  return nil, nil, nil, nil
end

function addNewlineToRoomLabels( roomName )
  if #roomName <= 18 then -- Threshold for room name length
    return roomName
  end
  local midpoint = math.floor( #roomName / 2 )
  local spaceBefore = roomName:sub( 1, midpoint ):match( ".*%s()" )
  local spaceAfter = roomName:sub( midpoint + 1 ):match( "%s()" )

  if not spaceBefore and not spaceAfter then
    return roomName -- No space found, return original
  end
  local newlinePos
  if spaceBefore then
    newlinePos = spaceBefore
  else
    newlinePos = midpoint + spaceAfter
  end
  local firstLine = roomName:sub( 1, newlinePos - 1 )
  local secondLine = roomName:sub( newlinePos )

  -- Calculate padding to center-justify
  local lineLengthDiff = #firstLine - #secondLine
  if lineLengthDiff < 0 then -- The first line is shorter
    firstLine = string.rep( " ", math.floor( math.abs( lineLengthDiff ) / 2 ) ) .. firstLine
  else                       -- The second line is shorter
    secondLine = string.rep( " ", math.floor( lineLengthDiff / 2 ) ) .. secondLine
  end
  return firstLine .. "\n" .. secondLine
end

function defineCustomEnvColors()
  roomColors = nil
  customColorsDefined = true
  setCustomEnvColor( COLOR_DEATH, 255, 99, 71, 255 )     -- <tomato>
  setCustomEnvColor( COLOR_CLUB, 70, 40, 115, 255 )      -- <medium_slate_blue>
  setCustomEnvColor( COLOR_INSIDE, 98, 62, 30, 255 )     -- custom rusty-brown
  setCustomEnvColor( COLOR_FOREST, 50, 65, 30, 255 )     -- custom dark green
  setCustomEnvColor( COLOR_MOUNTAINS, 120, 90, 90, 255 ) -- custom rosy-grey
  setCustomEnvColor( COLOR_CITY, 98, 88, 98, 255 )       -- dim purple/grey
  setCustomEnvColor( COLOR_WATER, 70, 130, 180, 255 )    -- <steel_blue>
  setCustomEnvColor( COLOR_FIELD, 107, 142, 35, 255 )    -- <olive_drab>
  setCustomEnvColor( COLOR_HILLS, 85, 105, 45, 255 )     -- custom green/brown
  setCustomEnvColor( COLOR_DEEPWATER, 25, 25, 110, 255 ) -- custom navy
  setCustomEnvColor( COLOR_PROC, 40, 100, 100, 255 )     -- custom dark cyan
  setCustomEnvColor( COLOR_OVERLAP, 250, 0, 250, 255 )   -- not used
  setCustomEnvColor( COLOR_SHOP, 50, 50, 20, 255 )
  roomColors = getCustomEnvColorTable()
  updateMap()
end

defineCustomEnvColors()
function styleAllRooms()
  local allRooms = getRooms()
  for id, name in pairs( allRooms ) do
    setRoomStyle( id )
  end
end

-- Set the color of the current Room on the map based on terrain type or attributes
function setRoomStyle( id )
  --local id = currentRoomNumber
  local roomFlags = getRoomUserData( id, "roomFlags" )
  local roomSpec = tonumber( getRoomUserData( id, "roomSpec" ) )
  local roomType = getRoomUserData( id, "roomType" )
  -- Check if 'DEATH' is present in roomFlags
  if (roomFlags and string.find( roomFlags, "DEATH" )) then
    unHighlightRoom( id )
    setRoomEnv( id, COLOR_DEATH )
    setRoomChar( id, "💀 " )
    lockRoom( id, true ) -- Lock this room so it won't ever be used for speedwalking
  elseif roomSpec > 0 then
    unHighlightRoom( id )
    setRoomEnv( id, COLOR_PROC )
    setRoomChar( id, "📁 " )
    if roomFlags and string.find( roomFlags, "CLUB" ) then
      cecho( f "\n\n<deep_pink>WARNING: {id} with PROC flag and CLUB flag<reset>\n\n" )
    end
  elseif roomFlags and string.find( roomFlags, "CLUB" ) then
    unHighlightRoom( id )
    setRoomEnv( id, COLOR_CLUB )
    setRoomChar( id, "💤" )
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

    local color = roomTypeToColor[roomType]
    setRoomEnv( id, color )
  end
  updateMap()
end
