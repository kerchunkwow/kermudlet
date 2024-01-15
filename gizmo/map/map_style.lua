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
  ["area"]      = "<deep_pink>",
  ["number"]    = "<dark_orange>",
  ["roomName"]  = "<sky_blue>",
  ["roomNameU"] = "<royal_blue>",
  ["roomDesc"]  = "<ansi_light_black>",
  ["exitDir"]   = "<cyan>",
  ["exitStr"]   = "<dark_slate_grey>",
  ["exitSpec"]  = "<gold>",
  ["death"]     = "<ansi_red>",
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

-- Set the color of the current Room on the map based on terrain type or attributes
function setRoomStyle()
  if not customColorsDefined then
    defineCustomEnvColors()
  end
  local id = currentRoomNumber
  -- Check if 'DEATH' is present in roomFlags
  if (currentRoomData.roomFlags and string.find( currentRoomData.roomFlags, "DEATH" )) then
    setRoomEnv( id, COLOR_DEATH )
    setRoomChar( id, "DT" )
    lockRoom( id, true ) -- Lock this room so it won't ever be used for speedwalking
  elseif currentRoomData.roomSpec > 0 then
    setRoomEnv( id, COLOR_PROC )
    setRoomChar( id, "*" )
    setRoomCharColor( id, 0, 0, 0, 255 )
    if currentRoomData.roomFlags and string.find( currentRoomData.roomFlags, "CLUB" ) then
      playSoundFile( {name = "bloop.wav"} )
      cecho( "\n\n<deep_pink>WARNING: PROC ROOM WITH CLUB FLAG<reset>\n\n" )
    end
  elseif currentRoomData.roomFlags and string.find( currentRoomData.roomFlags, "CLUB" ) then
    setRoomEnv( id, COLOR_CLUB )
    setRoomChar( id, "M" )
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

function defineCustomEnvColors()
  roomColors = nil
  customColorsDefined = true
  setCustomEnvColor( COLOR_DEATH, 255, 69, 0, 255 )        -- <orange_red>
  setCustomEnvColor( COLOR_CLUB, 72, 61, 139, 255 )        -- <dark_slate_blue>
  setCustomEnvColor( COLOR_INSIDE, 160, 82, 45, 255 )      -- <sienna>
  setCustomEnvColor( COLOR_FOREST, 107, 142, 35, 255 )     -- <olive_drab>
  setCustomEnvColor( COLOR_MOUNTAINS, 188, 143, 143, 255 ) -- <rosy_brown>
  setCustomEnvColor( COLOR_CITY, 105, 105, 105, 255 )      -- <dim_grey>
  setCustomEnvColor( COLOR_WATER, 30, 144, 255, 255 )      -- <dodger_blue>
  setCustomEnvColor( COLOR_FIELD, 60, 179, 113, 255 )      -- <medium_sea_green>
  setCustomEnvColor( COLOR_HILLS, 85, 105, 45, 255 )       -- custom green/brown
  setCustomEnvColor( COLOR_DEEPWATER, 25, 25, 110, 255 )   -- custom navy
  setCustomEnvColor( COLOR_PROC, 255, 20, 147, 255 )       -- <deep_pink>
  setCustomEnvColor( COLOR_OVERLAP, 250, 0, 250, 255 )
  setCustomEnvColor( COLOR_SHOP, 90, 90, 90, 255 )
  roomColors = getCustomEnvColorTable()
  updateMap()
end

defineCustomEnvColors()
-- Iterate over all rooms in the map; for any room with an up/down exit, add a gradient highlight circle;
-- uses getModifiedColor() to create a highlight based off the room's current color (terrain type)
function highlightStairs()
  -- Map room types to their respective environment IDs (color table index)
  local TYPE_MAP = {
    ['Forest']    = COLOR_FOREST,
    ['Mountains'] = COLOR_MOUNTAINS,
    ['City']      = COLOR_CITY,
    ['Water']     = COLOR_WATER,
    ['Field']     = COLOR_FIELD,
    ['Hills']     = COLOR_HILLS,
    ['Deepwater'] = COLOR_DEEPWATER,
    ['Inside']    = COLOR_INSIDE,
  }

  -- For all rooms in the map, check exits for up/down and highlight accordingly
  local roomsChecked = 0
  for id, name in pairs( getRooms() ) do
    roomsChecked = roomsChecked + 1
    local exits = getRoomExits( id )
    if exits['up'] or exits['down'] then
      unHighlightRoom( id )
      local roomName = getRoomName( id )
      local roomType = getRoomUserData( id, "roomType" )
      local roomEnv = roomColors[TYPE_MAP[roomType]]

      if roomEnv then
        local br, bg, bb = roomEnv[1], roomEnv[2], roomEnv[3]
        -- Highlight with colors -33% and +66% off baseline (makes a little "cone" effect)
        local h1r, h1g, h1b = getModifiedColor( br, bg, bb, -25 )
        local h2r, h2g, h2b = getModifiedColor( br, bg, bb, 75 )
        highlightRoom( id, h1r, h1g, h1b, h2r, h2g, h2b, 0.45, 255, 255 )
      end
    end
  end
  cecho( f "\nChecked {roomsChecked} rooms." )
end

function addNewlineToRoomLabels( roomName )
  if #roomName <= 20 then -- Threshold for room name length
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

function alignLabels( id )
  local nc = MAP_COLOR["number"]
  local areaLabels = getMapLabels( id )
  local labelCount = #areaLabels
  local modCount = 0
  -- Ignore missing areas and ones w/ no labels
  if areaLabels and labelCount > 0 then
    -- getMapLabels is zero-based
    for lbl = 0, labelCount do
      local labelData = getMapLabel( id, lbl )
      if labelData then
        lT = labelData.Text
        lX = labelData.X
        lY = labelData.Y
        cecho( f "\n<royal_blue>{lT}<reset>: {nc}{lX}<reset>, {nc}{lY}<reset>" )
      end
    end
  end
end
