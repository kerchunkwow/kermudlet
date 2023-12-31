--[[mapdisplay.lua
Functions to display the current Room & Exits as though we were playing the MUD.
This "virtual exploration" is used to help us map the MUD.
--]]

-- The "main" display function to print the current room as if we just moved into it or looked at it
-- in the game; prints the room name, description, and exits.
function displayRoom()
  local rn = MAP_COLOR["roomName"]
  local rd = MAP_COLOR["roomDesc"]
  local nc = MAP_COLOR["number"]
  local tc = MAP_COLOR[currentRoomData.roomType] or MAP_COLOR["mapui"]
  local uc = MAP_COLOR["mapui"]

  -- Check if the room has been visited before and coordinates are assigned
  if roomCoordinates[currentRoomData.roomRNumber] then
    -- Use existing coordinates
    mX, mY, mZ = unpack( roomCoordinates[currentRoomData.roomRNumber] )
  else
    -- Assign new coordinates (assuming mX, mY, mZ have been updated by moveExit or other means)
    roomCoordinates[currentRoomData.roomRNumber] = {mX, mY, mZ}
  end
  cecho( f "\n\n{rn}{currentRoomData.roomName}<reset> [{tc}{currentRoomData.roomType}<reset>] ({nc}{currentRoomData.roomRNumber}<reset>) ({uc}{mX}<reset>, {uc}{mY}<reset>, {uc}{mZ}<reset>)" )
  cecho( f "\n{rd}{currentRoomData.roomDescription}<reset>" )
  displayExits()
end

-- Display all exits of the current room as they might appear in the MUD
function displayExits()
  local exitData = currentRoomData.exits
  local exitString = ""
  local isFirstExit = true

  local currentArea = worldData[currentRoomData.areaRNumber]
  local minRNumber = currentArea.areaMinRoomRNumber
  local maxRNumber = currentArea.areaMaxRoomRNumber

  for _, exit in pairs( exitData ) do
    local dir = exit.exitDirection
    local to = exit.exitDest
    local ec = MAP_COLOR["exitDir"]
    local nc

    -- Determine the color based on exit properties
    if to < minRNumber or to > maxRNumber then
      nc = MAP_COLOR["area"]
    else
      local destRoom = currentArea.rooms[to]
      if destRoom and destRoom.roomFlags:find( "DEATH" ) then
        nc = MAP_COLOR["death"]
      elseif (exit.exitFlags and exit.exitFlags ~= -1) or (exit.exitKey and exit.exitKey ~= -1) then
        nc = MAP_COLOR["exitSpec"]
      else
        nc = MAP_COLOR["number"]
      end
    end
    local nextExit = f "{ec}{dir}<reset> ({nc}{to}<reset>)"
    if isFirstExit then
      exitString = f "{MAP_COLOR['exitStr']}Exits:  [" .. nextExit .. f "{MAP_COLOR['exitStr']}]<reset>"
      isFirstExit = false
    else
      exitString = exitString .. f " {MAP_COLOR['exitStr']}[<reset>" .. nextExit .. f "{MAP_COLOR['exitStr']}]<reset>"
    end
  end
  cecho( f "\n   {exitString}" )
end

-- Display the properties of an exit for mapping and validation purposes; displayed when I issue a virtual "look <direction>" command
function inspectExit( direction )
  local fullDirection
  for dir, num in pairs( DIRECTIONS ) do
    if DIRECTIONS[direction] == num and #dir > 1 then
      fullDirection = dir
      break
    end
  end
  for _, exit in ipairs( currentRoomData.exits ) do
    if exit.exitDirection == fullDirection then
      local ec      = MAP_COLOR["exitDir"]
      local es      = MAP_COLOR["exitStr"]
      local esp     = MAP_COLOR["exitSpec"]
      local nc      = MAP_COLOR["number"]

      local exitStr = f "The {ec}{fullDirection}<reset> exit: "
      if exit.exitKeyword and #exit.exitKeyword > 0 then
        exitStr = exitStr .. f "\n  keywords: {es}{exit.exitKeyword}<reset>"
      end
      local isSpecial = false
      if (exit.exitFlags and exit.exitFlags ~= -1) or (exit.exitKey and exit.exitKey ~= -1) then
        isSpecial = true
        exitStr = exitStr ..
            (exit.exitFlags and exit.exitFlags ~= -1 and f "\n  flags: {esp}{exit.exitFlags}<reset>" or "") ..
            (exit.exitKey and exit.exitKey ~= -1 and f "\n  key: {nc}{exit.exitKey}<reset>" or "")
      end
      if exit.exitDescription and #exit.exitDescription > 0 then
        exitStr = exitStr .. f "\n  description: {es}{exit.exitDescription}<reset>"
      end
      cecho( f "\n{exitStr}" )
      return
    end
  end
  cecho( f "\n{MAP_COLOR['roomDesc']}You see no exit in that direction.<reset>" )
end

-- Print an unnecessarily beautiful info message related to map updates & information
function mapInfo( message )
  -- Calculate the length of the visible characters in the message
  local visibleLength = #message:gsub( "<[^>]+>", "" ) -- Remove color tags for length calculation

  -- Calculate the total padding required to center-align the message
  local totalPadLength = math.max( 70 - visibleLength - 4, 0 ) -- Subtract 4 for the brackets and plus signs in markers

  -- Split the padding between left and right, adjusting for odd lengths
  local leftPadLength = math.floor( totalPadLength / 2 )
  local rightPadLength = math.ceil( totalPadLength / 2 )

  local leftPad = string.rep( " ", leftPadLength )
  local rightPad = string.rep( " ", rightPadLength )

  local mtl = f "{MAP_COLOR['mapui']}  [+{leftPad}<reset>" -- Marker tag left
  local mtr = f "{MAP_COLOR['mapui']}{rightPad}+]<reset>"  -- Marker tag right

  -- Combine the message with marker tags and print it
  --cecho( f "\n{mtl}{message}{mtr}" )
  cecho( f "\n{message}" )
end
