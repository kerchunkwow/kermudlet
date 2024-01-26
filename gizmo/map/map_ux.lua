-- Table of predefined text colors for use throughout the Map UI & console map output
TXT_COLOR       = {
  default   = "<dim_grey>",
  roomName  = "<royal_blue>",
  roomDesc  = "<olive_drab>",
  basicExit = "<ansi_cyan>",
  doorExit  = "<honeydew>",
  death     = "<tomato>",
  area      = "<maroon>",
  noteLabel = "<yellow>",
  warnLabel = "<red>",
  dirLabel  = "<yellow>",
  key       = "<goldenrod>",
  number    = "<dark_orange>",
  string    = "<medium_orchid>",
  error     = "<ansi_light_magenta>",
}

-- Shorthand for the more commonly used text colors from the table above
NC              = TXT_COLOR['number']
RMNC            = TXT_COLOR['roomName']
RMDC            = TXT_COLOR['roomDesc']
ARC             = TXT_COLOR['area']
DTC             = TXT_COLOR['death']
ERRC            = TXT_COLOR['error']
KEYC            = TXT_COLOR['key']
DOORC           = TXT_COLOR['doorExit']
EXC             = TXT_COLOR['basicExit']
R               = "<reset>"

-- IDs assigned to specific Room color configurations by defineCustomColors();
-- remember them as global constants so we can style rooms in response to MUD output
COLOR_DEATH     = 300
COLOR_CLUB      = 310
COLOR_INSIDE    = 320
COLOR_FOREST    = 330
COLOR_MOUNTAINS = 340
COLOR_CITY      = 350
COLOR_WATER     = 360
COLOR_FIELD     = 370
COLOR_HILLS     = 380
COLOR_DEEPWATER = 390
COLOR_OVERLAP   = 400
COLOR_LANDMARK  = 410
COLOR_SHOP      = 420
COLOR_PROC      = 430


-- Get a string representing the "room name" with varying levels of detail
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

-- Get a string representing a door depending on its status and key value
function getDoorString( word, key )
  -- Double declaration because VSCode is confused by f-string interpolation
  local doorString, keyString, wordString = nil, nil, nil
  doorString, keyString, wordString = "", "", ""
  if word then wordString = f "<light_goldenrod>{word}<reset>" end
  if key then keyString = f " (<lawn_green>{key}<reset>)" end
  doorString = f " <dim_grey>past a {wordString}{keyString}"
  return doorString
end

-- Build a "line" of all exits from the current room, color-coded based on the attributes of
-- the exit or destination room.
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
      exitString = f "<dim_grey>Obvious Exits:   [" .. nextExit .. f "<dim_grey>]<reset>"
    else
      exitString = exitString .. f " <dim_grey>[<reset>" .. nextExit .. f "<dim_grey>]<reset>"
    end
  end
  --cecho( f "{exitString}" )
  simulateOutput( f "   {exitString}" )
end

-- Select one of the predefined colors to display an Exit based on Door and Destination status
-- Prioritize colros and exit early as soon as the first condition is met
function getExitColor( to, dir )
  local isMissing = not roomExists( to )
  if isMissing then return ERRC end
  local toFlags = getRoomUserData( to, "roomFlags" )
  local isDT    = toFlags and toFlags:find( "DEATH" )
  if isDT then return DTC end
  local isDoor = doorData[currentRoomNumber] and doorData[currentRoomNumber][LDIR[dir]]
  local hasKey = isDoor and doorData[currentRoomNumber][LDIR[dir]].exitKey
  if hasKey then return KEYC elseif isDoor then return DOORC end
  local isBorder = currentAreaNumber ~= getRoomArea( to )
  if isBorder then return ARC else return EXC end
end

-- Get a useful string representation of an Area including it's ID number for output (e.g., with cecho)
function getAreaTag()
  return f "<medium_violet_red>{currentAreaName}<reset> [<maroon>{currentAreaNumber}<reset>]"
end

-- Configure the "Custom Environments" used by Mudlet to determine the style of rooms in the Map
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

-- Add a label string to the Map customized by topic; used by the 'lbl' alias
function addLabel()
  local labelDirection = matches[2]
  local labelType = matches[3]
  local dX = 0
  local dY = 0
  -- Adjust the label position based on initial direction parameter for less after-placement adjustment
  dX, dY = getLabelPosition( labelDirection )

  -- Hang on to the rest in globals so we can nudge with WASD; confirm with 'F' and cancel with 'C'
  if labelType == "room" then
    labelText = formatLabel( currentRoomName )
  elseif labelType == "key" and lastKey > 0 then
    labelText = tostring( lastKey )
    lastKey = -1
  elseif labelType == "proc" then
    labelText = currentRoomData.roomSpec
  else
    labelText = formatLabel( matches[4] )
    -- Replace '\\n' in our label strings with a "real" newline; probably a better way to do this
    -- labelText = labelText:gsub( "\\\\n", "\n" )
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

-- Once we're finished placing a label, clean up the globals we used to keep track of it
function finishLabel( keepLabel )
  if not keepLabel then deleteMapLabel( labelArea, labelID ) end
  labelText, labelArea, labelX, labelY = nil, nil, nil, nil
  labelR, labelG, labelB, labelSize = nil, nil, nil, nil
  labelID = nil
  disableKey( "Labeling" )
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

-- Start new labels at a relative offset to minimize post-labeling adjustments
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

-- For longer labels, insert newlines & attempt to center-justify
-- [TODO] Update this to support an arbitrary number of lines
function formatLabel( lbl )
  -- Adjust threshhold where labels will be broken with newline
  if #lbl <= 18 then
    return lbl
  end
  local midpoint = math.floor( #lbl / 2 )
  local spaceBefore = lbl:sub( 1, midpoint ):match( ".*%s()" )
  local spaceAfter = lbl:sub( midpoint + 1 ):match( "%s()" )

  -- Ignore labels with no spaces
  if not spaceBefore and not spaceAfter then
    return lbl
  end
  local newlinePos
  if spaceBefore then
    newlinePos = spaceBefore
  else
    newlinePos = midpoint + spaceAfter
  end
  -- Calculate padding to center-justify; indenting whichever line is shorter
  local firstLine = lbl:sub( 1, newlinePos - 1 )
  local secondLine = lbl:sub( newlinePos )
  local lineLengthDiff = #firstLine - #secondLine
  if lineLengthDiff < 0 then
    firstLine = string.rep( " ", math.floor( math.abs( lineLengthDiff ) / 2 ) ) .. firstLine
  else
    secondLine = string.rep( " ", math.floor( lineLengthDiff / 2 ) ) .. secondLine
  end
  return firstLine .. "\n" .. secondLine
end

-- Print a message w/ a tag denoting it as coming from our Mapper script
function mapInfo( message )
  cecho( f "\n  [<peru>M<reset>] {message}" )
end

-- Call setRoomStyle for all rooms in the MUD (kind of a global reset/refresh)
local function styleAllRooms()
  local allRooms = getRooms()
  for id, name in pairs( allRooms ) do
    setRoomStyle( id )
  end
end
