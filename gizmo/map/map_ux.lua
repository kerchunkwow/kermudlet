TXT_COLOR = {
  default   = "<dim_grey>",
  roomName  = "<royal_blue>",
  roomDesc  = "<olive_drab>",
  basicExit = "<dark_slate_grey>",
  doorExit  = "<medium_sea_green>",
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

NC        = TXT_COLOR['number']
RMNC      = TXT_COLOR['roomName']
RMDC      = TXT_COLOR['roomDesc']
ARC       = TXT_COLOR['area']
DTC       = TXT_COLOR['death']
ERRC      = TXT_COLOR['error']
KEYC      = TXT_COLOR['key']
DOORC     = TXT_COLOR['doorExit']
EXC       = TXT_COLOR['basicExit']
R         = "<reset>"


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
