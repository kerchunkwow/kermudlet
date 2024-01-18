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

function setRoomSymbols()

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

defineCustomEnvColors()

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
