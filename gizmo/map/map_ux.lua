-- Mapper UI menu function to update current player location; useful when
-- map gets out of synch (e.g., flee, teleported).
function setRoomOnClick()
  local dst = getMapSelection()["rooms"][1]
  iout( "Player Location Set: {NC}{dst}{RC}" )
  setPlayerRoom( dst )
end

-- Mapper UI menu function to displayMob() for all mobs in a room
function showMobOnClick()
  local function displayMobsByRoom( roomRNumber )
    for _, mob in ipairs( mobData ) do
      if mob.roomRNumber == roomRNumber then
        displayMob( mob.rNumber )
      end
    end
  end
  local id = getMapSelection()["rooms"][1]
  displayMobsByRoom( id )
end

-- Mapper UI to display a "virtual" version of a room
function showRoomOnClick()
  local id = getMapSelection()["rooms"][1]
  displayRoom( id )
  cecho( "\n" )
end

function timeSomeMapStuff()
  local roomCount = 0
  local startTime = getStopWatchTime( "timer" )
  local allRooms = getRooms()
  for id, room in pairs( allRooms ) do
    roomCount = roomCount + 1
    displayRoom( id )
  end
  local endTime = getStopWatchTime( "timer" )
  local elapsed = endTime - startTime
  elapsed = round( elapsed, 0.001 )
  cout( f "Displayed {NC}{roomCount}{RC} rooms in {NC}{elapsed}{RC}s" )
end

-- Mapper UI to label mobs in a room that award fame
-- [TODO] Will not work for rooms with multiple fame mobs (rare)
function labelMobOnClick()
  local id = getMapSelection()["rooms"][1]
  -- Find each mob in a room that awards fame and add a corresponding label using their short desc
  for _, mob in ipairs( mobData ) do
    local inRoom = mob.roomRNumber == id
    local hasFame = mob.fame > 0
    if inRoom and hasFame then
      local labelText = trimArticle( mob.shortDescription )
      addLabel( "n", "mob", labelText )
    end
  end
end

-- Triggered when the Mapper UI is opened for the first time to register event handlers for
-- custom menu items & functions; only needed once per client session.
function mapperOpenedEvent()
  iout( "{SYC}Registering Mapper UI menu events{RC}" )
  registerAnonymousEventHandler( "setRoomOnClick", "setRoomOnClick" )
  registerAnonymousEventHandler( "showMobOnClick", "showMobOnClick" )
  registerAnonymousEventHandler( "showRoomOnClick", "showRoomOnClick" )
  registerAnonymousEventHandler( "labelMobOnClick", "labelMobOnClick" )
  addMapEvent( "Set Current Room", "setRoomOnClick" )
  addMapEvent( "Show Mobs", "showMobOnClick" )
  addMapEvent( "Show Room", "showRoomOnClick" )
  addMapEvent( "Label Mob", "labelMobOnClick" )
  mapperOpenedEvent = nil
end

-- Register a one-shot event to call the above function when the Mapper UI is opened
registerAnonymousEventHandler( 'mapOpenEvent', mapperOpenedEvent, 1 )

function displayRoom( id )
  local name       = getRoomName( id )
  local exit       = getExitString( id )
  local desc       = getRoomUserData( id, "roomDescription" )
  --local flags      = getRoomUserData( id, "roomFlags" )
  local flags      = getFormattedFlags( id )
  local spec       = getRoomUserData( id, "roomSpec" )
  local type       = getRoomUserData( id, "roomType" )

  -- Use a special character to denote when a room has a procedure
  spec             = spec == "1" and " ƒ" or ""

  -- Format the room description as it might appear in the MUD
  desc             = formatRoomDescription( desc )

  -- Update each attribute with colorization tags
  local nc         = MAP_COLOR["roomName"] or "<dim_grey>"
  local tc         = MAP_COLOR[type] or "<dim_grey>"
  local dc         = MAP_COLOR["roomDesc"] or "<dim_grey>"
  --local fc         = MAP_COLOR["mapui"] or "<dim_grey>"
  local sc         = "<ansi_yellow>"
  local ids        = f "({MAP_COLOR['number']}{id}{RC})"
  --flags            = f "|{fc}{flags}{RC}|"
  type             = f "[{tc}{type}{RC}]"
  desc             = f "{dc}{desc}{RC}"
  spec             = f "{sc}{spec}{RC}"
  name             = f "{nc}{name}{RC}"
  local nameString = f "{name}{spec} {ids} {type} {flags}"
  cecho( f "\n{nameString}\n{desc}\n{exit}" )
  listMobsInRoom( id )
end

-- Function to display every mob in a particular room
function listMobsInRoom( roomRNumber )
  for _, mob in ipairs( mobData ) do
    if mob.roomRNumber == roomRNumber then
      local ld = mob.longDescription
      local fm = f " [<gold>{mob.fame}<reset>]" or ""
      cout( f "<tomato>{ld}<reset>{fm}" )
    end
  end
end

-- Check all rooms and report on rooms marked with character "🅿️" that
-- have at least one mob in them.
function noMobRoomCheck()
  local rooms = getRooms()
  for roomID, roomName in pairs( rooms ) do
    local roomChar = getRoomChar( roomID )
    if roomChar == "🅿️" then
      for _, mob in ipairs( mobData ) do
        local sent = string.find( mob.flags, "SENTINEL" )
        if mob.roomRNumber == roomID and mob.aggro and sent then
          local mobID = mob.rNumber
          setRoomChar( roomID, "" )
          setRoomChar( roomID, "🔺" )
        end
      end
    end
  end
end

-- Get a more friendly, consolidated string to display the flags for a given room
function getFormattedFlags( id )
  local flagMap = {
    INDOORS  = "",
    PRIVATE  = "",
    SAFE     = "🤝",
    NO_MOB   = "⛔",
    NO_MAGIC = "🤐",
    DARK     = "",
    NEUTRAL  = "",
    ARENA    = "",
    CLUB     = "💤",
    NONE     = "",
    DEATH    = "💀",
    BFS_MARK = "",
    TUNNEL   = "",
    HALLOWED = "⛪",
    DUEL     = "",
    SNDPROOF = "🙉"
  }

  local roomFlags = getRoomUserData( id, "roomFlags" )
  local formattedFlags = ""
  for flag in string.gmatch( roomFlags, "%S+" ) do
    if flagMap[flag] then
      formattedFlags = formattedFlags .. flagMap[flag]
    end
  end
  return formattedFlags
end

function formatRoomDescription( desc )
  local maxLength = 80
  local indent = "   "
  local formattedDesc = indent
  local lineLength = #indent
  local firstLine = true

  for word in string.gmatch( desc, "%S+" ) do
    if lineLength + #word + 1 > maxLength then
      if firstLine then
        formattedDesc = formattedDesc .. "\n" .. word
        firstLine = false
      else
        formattedDesc = formattedDesc .. "\n" .. word
      end
      lineLength = #word
    else
      if lineLength > (firstLine and #indent or 0) then
        formattedDesc = formattedDesc .. " " .. word
        lineLength = lineLength + 1 + #word
      else
        formattedDesc = formattedDesc .. word
        lineLength = lineLength + #word
      end
    end
  end
  return formattedDesc
end

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

  if UNIQUE_ROOMS[roomName] then
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

function displayExits( id )
  local exitString = ""
  if not id or id < 1 then
    exitString = "<dim_grey>   Obvious Exits:   <dim_grey>[No Data]<reset>"
  else
    exitString = getExitString( id )
  end
  cecho( f "\n{exitString}" )
end

-- Build a "line" of all exits from the current room, color-coded based on the attributes of
-- the exit or destination room.
function getExitString( id )
  local exitData    = getRoomExits( id )
  local exitString  = ""
  local isFirstExit = true
  local sortedExits = {}
  local dc          = MAP_COLOR["exitDir"]

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
    local nextExit = f "{tc}{dir}<reset>"
    if isFirstExit then
      isFirstExit = false
      exitString = f "<dim_grey>   Obvious Exits:   [" .. nextExit .. f "<dim_grey>]<reset>"
    else
      exitString = exitString .. f " <dim_grey>[<reset>" .. nextExit .. f "<dim_grey>]<reset>"
    end
  end
  return exitString
end

-- Select one of the predefined colors to display an Exit based on Door and Destination status
-- Prioritize colros and exit early as soon as the first condition is met
function getExitColor( to, dir )
  local isMissing = not roomExists( to )
  if isMissing then return ERRC end
  local toFlags = getRoomUserData( to, "roomFlags" )
  local isDT    = toFlags and toFlags:find( "DEATH" )
  if isDT then return DTC end
  local isDoor = doorData[CurrentRoomNumber] and doorData[CurrentRoomNumber][LDIR[dir]]
  local hasKey = isDoor and doorData[CurrentRoomNumber][LDIR[dir]].exitKey
  if hasKey then return KEYC elseif isDoor then return DOORC end
  local isBorder = CurrentAreaNumber ~= getRoomArea( to )
  if isBorder then return ARC else return EXC end
end

-- Get a useful string representation of an Area including it's ID number for output (e.g., with cecho)
function getAreaTag()
  return f "<medium_violet_red>{CurrentAreaName}<reset> [<maroon>{CurrentAreaNumber}<reset>]"
end

-- Configure the "Custom Environments" used by Mudlet to determine the style of rooms in the Map
function defineCustomEnvColors()
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

-- Style rooms based on user data
function setRoomStyle( id )
  local roomFlags = getRoomUserData( id, "roomFlags" )
  local roomSpec  = tonumber( getRoomUserData( id, "roomSpec" ) )
  local roomType  = getRoomUserData( id, "roomType" )
  -- Check if 'DEATH' is present in roomFlags
  if (roomFlags and string.find( roomFlags, "DEATH" )) then
    setRoomEnv( id, COLOR_DEATH )
    setRoomChar( id, "💀 " )
    lockRoom( id, true ) -- Lock this room so it won't ever be used for speedwalking
  elseif roomSpec > 0 then
    setRoomEnv( id, COLOR_PROC )
    setRoomChar( id, "📁 " ) -- Rooms with special procedures get the folder icon
  elseif roomFlags and string.find( roomFlags, "CLUB" ) then
    unHighlightRoom( id )
    setRoomEnv( id, COLOR_CLUB )
    setRoomChar( id, "💤" ) -- Mana or resting rooms
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
    labelText = formatLabel( CurrentRoomName )
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
  labelArea = getRoomArea( CurrentRoomNumber )
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


function styleAllRooms()
  local rooms = getRooms()
  for id, name in pairs( rooms ) do
    setRoomStyle( id )
  end
end

-- Set room character & style based on user data
function setRoomStyle( id )
  -- Retrieve data from the room
  local roomFlags   = getRoomUserData( id, "roomFlags" )
  local roomTerrain = getRoomUserData( id, "roomTerrain" )

  -- Style rooms with special flags, otherwise use terrain type
  if (roomFlags and string.find( roomFlags, "DEATH" )) then
    setRoomEnv( id, COLOR_DEATH )
    setRoomChar( id, "💀" )
    lockRoom( id, true ) -- Lock this room so it won't ever be used for speedwalking
  elseif roomFlags and string.find( roomFlags, "CLUB" ) then
    unHighlightRoom( id )
    setRoomEnv( id, COLOR_CLUB )
    setRoomChar( id, "💤" ) -- Mana or resting rooms
  else
    setRoomEnv( id, getEnvColorByTerrain( roomTerrain ) )
  end
  updateMap()
end

function getEnvColorByTerrain( terrain )
  -- Set environment/color by terrain type
  local terrainToColorMap = {
    ["Inside"]    = COLOR_INSIDE,
    ["Forest"]    = COLOR_FOREST,
    ["Mountains"] = COLOR_MOUNTAINS,
    -- etc.
  }
  return terrainToColorMap[terrain]
end
