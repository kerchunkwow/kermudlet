--[[ mapsim.lua

Module to create a "virtual" offline version of the MUD by interacting with the worldData
table and outputting data related to Areas, Rooms, and Exits.

--]]

-- Some rooms are currently unmappable (i.e., I couldn't reach them on my IMM.)
ignoredRooms = {
  [0] = true,
  [8284] = true,
  [6275] = true,
  [2276] = true,
  [2223] = true,
  [1290] = true,
  [979] = true,
  [1284] = true, -- Alchemist's Shoppe after an explosion?
  [1285] = true, -- Temple Avenue outside the Alchemist's Shoppe after an explosion?
}

function clearCharacters()
  allRooms = getRooms()
  for id, name in pairs( allRooms ) do
    setRoomChar( id, "" )
  end
end

function combinePhantom()
  local phantom1 = worldData[102].rooms
  local phantom2 = worldData[103].rooms
  local phantom3 = worldData[108].rooms
  local movedRooms = 0
  for _, room in pairs( phantom2 ) do
    local id = room.roomRNumber
    if roomExists( id ) and getRoomArea( id ) ~= 102 then
      setRoomArea( id, 102 )
      movedRooms = movedRooms + 1
    end
  end
  for _, room in pairs( phantom3 ) do
    local id = room.roomRNumber
    if roomExists( id ) and getRoomArea( id ) ~= 102 then
      setRoomArea( id, 102 )
      movedRooms = movedRooms + 1
    end
  end
  cecho( f "\n{movedRooms} rooms moved to Phantom Zone." )
end

function areaHunt()
  local rooms = getRooms()
  local areaID = 1
  for areaID = 1, 128 do
    if areaID == 107 then areaID = areaID + 1 end
    local areaData = worldData[areaID]
    local roomData = areaData.rooms
    for _, room in pairs( roomData ) do
      local id = room.roomRNumber
      if roomExists( id ) then
        exitData = room.exits
        for _, exit in pairs( exitData ) do
          local dir = exit.exitDirection
          local to = exit.exitDest
          if not roomExists( to ) and not ignoredRooms[to] then
            cecho( f "\n<firebrick>{to}<reset> is <cyan>{dir}<reset> from <dark_orange>{id}" )
          end
        end
      end
    end
  end
end

-- Report on Rooms which have been moved in the Mudlet client to an Area other than their original
-- Area from the database.
function movedRoomsReport()
  local ac = MAP_COLOR["area"]
  for areaID = 1, 128 do
    -- Skip Area 107; it's missing from our database
    if areaID == 107 then areaID = areaID + 1 end
    local areaData = worldData[areaID]
    local roomData = areaData.rooms
    for _, room in pairs( roomData ) do
      local id = room.roomRNumber
      local mudletArea = getRoomArea( id )
      local dataArea = roomToAreaMap[id]
      if mudletArea and dataArea and (mudletArea ~= dataArea) then
        cecho( f "\n{getRoomString(id,1)} from {ac}{dataArea}<reset> has moved to {ac}{mudletArea}<reset>" )
      end
    end
  end
end

function areaReport()
  local nc = MAP_COLOR["number"]
  local ac = MAP_COLOR["area"]
  mapInfo( f "Map report for {ac}{currentAreaName}<reset> [{ac}{currentAreaNumber}<reset>]" )
  local areaData = worldData[currentAreaNumber]
  local dbCount = areaData.areaRoomCount
  local mudletCount = 0
  local roomData = areaData.rooms
  for _, room in pairs( roomData ) do
    local id = room.roomRNumber
    if not roomExists( id ) and not ignoredRooms[id] then
      mapInfo( f "<firebrick>Missing<reset>: {getRoomString(id,2)}" )
    else
      mudletCount = mudletCount + 1
    end
  end
  local unmappedCount = dbCount - mudletCount
  mapInfo( f '<yellow_green>Database<reset> rooms: {nc}{dbCount}<reset>' )
  mapInfo( f '<olive_drab>Mudlet<reset> rooms: {nc}{mudletCount}<reset>' )
end

function worldReport()
  local nc          = MAP_COLOR["number"]
  local ac          = MAP_COLOR["area"]
  local worldCount  = 0
  local mappedCount = 0
  local missedCount = 0
  for areaID = 1, 128 do
    -- Skip Area 107; it's missing from our database
    if areaID == 107 then areaID = areaID + 1 end
    local areaData = worldData[areaID]
    local roomData = areaData.rooms
    for _, room in pairs( roomData ) do
      local id = room.roomRNumber
      worldCount = worldCount + 1
      if roomExists( id ) or ignoredRooms[id] then
        mappedCount = mappedCount + 1
      else
        local roomArea = roomToAreaMap[id]
        local roomAreaName = worldData[areaID].areaName
        cecho( f "\n{getRoomString(id,2)} in {ac}{roomAreaName}<reset>" )
        missedCount = missedCount + 1
        if missedCount > 5 then return end
      end
    end
  end
  local unmappedCount = worldCount - mappedCount
  mapInfo( f '<yellow_green>World<reset> total: {nc}{worldCount}<reset>' )
  mapInfo( f '<olive_drab>Mapped<reset> total: {nc}{mappedCount}<reset>' )
  mapInfo( f '<orange_red>Unmapped<reset> total: {nc}{unmappedCount}<reset>' )
end

-- Like findNewRoom(), but globally; search every Area in the MUD for a Room that has an Exit leading
-- to a Room that hasn't been mapped yet.
function findNewLand()
  local ac = MAP_COLOR["area"]
  -- getRooms() dumps a global list of mapped Room Names & IDs with no other detail
  for id, name in pairs( getRooms() ) do
    -- getRoomArea tells us which Area a Room is in
    local areaID = getRoomArea( id )
    -- While worldData was derived from the database and may contain unmapped Areas and Rooms
    if worldData[areaID] and worldData[areaID].rooms[id] then
      local roomData = worldData[areaID].rooms[id]
      local exitData = roomData.exits
      -- Check the destination of each Exit and report back of there's a Room that doesn't exist
      -- and hasn't been flagged unmappable.
      for _, exit in pairs( exitData ) do
        local dir = exit.exitDirection
        local to = exit.exitDest
        if not roomExists( to ) and not contains( unmappable, to ) then
          -- Uncomment this to immediately walk to the first unmapped Room
          --expandAlias( f 'goto {rnum}' );return
          cecho( f "\n<firebrick>{to}<reset> is <cyan>{dir}<reset> from <dark_orange>{id}" )
        end
      end
    end
  end
end

-- Search every room in the current Area for one that has an Exit to a room we haven't mapped yet.
function findNewRoom()
  -- Get a list of every Room in the area
  local allRooms = getAreaRooms( currentAreaNumber )
  -- Which is zero-based for some godforsaken reason...
  local r = 0
  while allRooms[r] do
    local rnum = allRooms[r]
    -- Verify the Room exists
    if worldData[currentAreaNumber].rooms[rnum] then
      -- Then check all of its Exits to see if any lead to an unmapped room
      local exitData = worldData[currentAreaNumber].rooms[rnum].exits
      for _, exit in pairs( exitData ) do
        local dir = exit.exitDirection
        local to = exit.exitDest
        if not roomExists( to ) then
          -- Uncomment this to immediately walk to the first unmapped Room
          --expandAlias( f 'goto {rnum}' );return
          cecho( f "\n(<firebrick>{to}<reset>) is <cyan>{dir}<reset> from (<dark_orange>{rnum}<reset>)" )
          return
        end
      end
    end
    r = r + 1
  end
  -- If we didn't find any unmapped rooms, run a report to verify
  cecho( "\n<green_yellow>No unmapped rooms found at this time.<reset>" )
end

-- The "main" display function to print the current room as if we just moved into it or looked at it
-- in the game; prints the room name, description, and exits.
function displayRoom( brief )
  brief = brief or true
  local rd = MAP_COLOR["roomDesc"]
  cecho( f "\n\n{getRoomString(currentRoomNumber, 3)}" )
  if not brief then
    cecho( f "\n{rd}{currentRoomData.roomDescription}<reset>" )
  end
  if currentRoomData.roomSpec > 0 then
    local renv = getRoomEnv( currentRoomNumber )
    if renv ~= COLOR_PROC then
      setRoomStyle()
    end
    --playSoundFile( {name = "msg.wav"} )
    cecho( f "\n\tThis room has a ~<ansi_light_yellow>special procedure<reset>~.\n" )
  end
  displayExits()
end

-- Display all exits of the current room as they might appear in the MUD
function displayExits()
  local exitData = currentRoomData.exits
  local exitString = ""
  local isFirstExit = true

  local minRNumber = currentAreaData.areaMinRoomRNumber
  local maxRNumber = currentAreaData.areaMaxRoomRNumber

  for _, exit in pairs( exitData ) do
    local dir = exit.exitDirection
    local to = exit.exitDest
    local ec = MAP_COLOR["exitDir"]
    local nc

    -- Determine the color based on exit prope8rties
    if to == currentRoomNumber or (culledExits[currentRoomNumber] and culledExits[currentRoomNumber][dir]) then
      -- "Dim" the exit if it leads to the same room or has been culled (because several exits lead to the same destination)
      nc = "<dim_grey>"
    elseif not isInArea( to, currentAreaNumber ) then --to < minRNumber or to > maxRNumber then
      -- The room leads to a different area
      nc = MAP_COLOR["area"]
    else
      local destRoom = currentAreaData.rooms[to]
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
        if exit.exitKey and exit.exitKey > 0 then
          lastKey = exit.exitKey
        end
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

-- Attempt a "virtual move"; on success report on area transitions and update virtual coordinates.
function moveExit( direction )
  local nc = MAP_COLOR["number"]
  -- Guard against variations in the Exit data by searching for the Exit in question
  for _, exit in pairs( currentRoomData.exits ) do
    if exit.exitDirection == direction then
      if not roomToAreaMap[exit.exitDest] then
        cecho( f "\n<dim_grey>err: Room {nc}{exit.exitDest}<reset><dim_grey> has no area mapping.<reset>" )
        return
      end
      -- Update coordinates for the new Room (and possibly Area)
      updatePlayerLocation( exit.exitDest, direction )
      displayRoom()
      return true
    end
  end
  -- -- Move failed, report error & play bloop
  -- if not sound_delayed then
  --   sound_delayed = true
  --   tempTimer( 5, [[sound_delayed = nil]] )
  --   playSoundFile( {name = "bloop.wav"} )
  -- end
  cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
  return false
end

-- Simulate a 'scroll of recall'; magical item in game that returns the player to the starting room
function virtualRecall()
  local funnyMessages = {
    "you won from a scratch-off lottery ticket.",
    "you found stuck to the bottom of your shoe.",
    "wait no that was a Starbucks gift card.",
    "what're you chicken or sumthin'?",
    "and suddenly remember where you left your keys shit wrong recall.",
  }

  local funnyMessage = funnyMessages[math.random( #funnyMessages )]

  cecho( f "\n\n<orchid>You recite a <deep_pink>scroll of recall<orchid>.<reset>\n" )
  --tempTimer( 0.05, function () setCurrentRoom( 1121 ) end )
  --tempTimer( 0.15, function () displayRoom() end )
  updatePlayerLocation( 1121 )
  displayRoom()
end

-- Given a list of room numbers, traverse them virtually while looking for doors in our path; add
-- open commands as needed and produce a WINTIN-compatible command list including opens and moves.
function traverseRooms( roomList )
  -- Check if the room list is valid
  if not roomList or #roomList == 0 then
    cecho( "\nError: Invalid room list provided." )
    return {}
  end
  local directionsTaken = {} -- This will store all the directions and 'open' commands

  -- Iterate through each room in the path
  for i = 1, #roomList - 1 do
    local currentRoom = tonumber( roomList[i] )  -- Current room in the iteration
    local nextRoom = tonumber( roomList[i + 1] ) -- The next room in the path

    local found = false                          -- Flag to check if a valid exit is found for the next room

    -- Search for the current room in the worldData
    for areaRNumber, areaData in pairs( worldData ) do
      if areaData.rooms[currentRoom] then
        local roomData = areaData.rooms[currentRoom]

        -- Iterate through exits of the current room
        for _, exit in pairs( roomData.exits ) do
          -- Check if the exit leads to the next room
          if exit.exitDest == nextRoom then
            found = true

            -- Check if the exit is a door and add 'open' command to directions
            -- This is for offline/virtual movement, so the command isn't executed
            if exit.exitFlags ~= -1 and exit.exitKeyword and exit.exitKeyword ~= "" then
              local doorString = ""
              local keyword = exit.exitKeyword:match( "%w+" )
              local keynum = exit.exitKey
              -- A door with a key number but no keyword to unlock might be a problem in the data
              if keynum > 0 and (not keyword or keyword == "") then
                gizErr( "Key with no keyword found in room " .. currentRoom )
              end
              -- If the door has a key number, unlock it before opening
              if keyword and keynum > 0 then
                doorString = "unlock " .. keyword .. ";open " .. keyword
              elseif keyword and (not keynum or keynum < 0) then
                doorString = "open " .. keyword
              end
              table.insert( directionsTaken, doorString )
            end
            -- Use moveExit to update the virtual location in the map
            moveExit( exit.exitDirection )
            table.insert( directionsTaken, exit.exitDirection )
            break -- Exit found, no need to continue checking other exits
          end
        end
        if found then
          break -- Exit found, no need to continue checking other areas
        end
      end
    end
    -- If no valid exit is found, report an error
    if not found then
      cecho( "\nError: Path broken at room " .. currentRoom .. " to " .. nextRoom )
      return {}
    end
  end
  return directionsTaken -- Return the list of directions and 'open' commands
end

-- Get a full Wintin-compatible path between two rooms including any necessary "open" commands;
-- This function relies fully on Mudlet Mapper data and does not refer to the worldData table or database
function getFullPath( srcID, dstID )
  -- Clear Mudlet's pathing globals
  speedWalkDir = nil
  speedWalkPath = nil
  -- See if Mudlet can find a path between the rooms
  local rm = srcID
  if getPath( srcID, dstID ) then
    for d = 1, #speedWalkDir do
      local dir = tostring( speedWalkDir[d] )
      local doors = getDoors( rm )
      display( doors )
      if doors[dir] then
        -- There is a door between rooms along our path, so I need to insert commands into the path
        -- If doors[dir] == 2 then I need an open command
        -- If doors[dir] == 1 then I need an unlock command followed by an open command
        -- The MUD requires that a keyword be used to open doors, please suggest the most computationally efficient
        -- solution for storing data related to doors, keywords, and locked/unlocked status so this step can be completed
        -- as quickly as possible when calculating new paths.
      end
      rm = tonumber( speedWalkPath[d] )
    end
  end
end

function doSpeedWalk()
  for _, dir in ipairs( speedWalkDir ) do
    if #dir > 1 then dir = SDIR[dir] end
    expandAlias( dir )
  end
end

-- Basically just getPathAlias but automatically follow the route.
function gotoAlias()
  getPathAlias()
  doSpeedWalk()
end

-- Use built-in Mudlet path finding to get a path to the specified room.
function getPathAlias()
  -- Clear the path globals
  speedWalkDir = nil
  speedWalkPath = nil

  local dstRoomName = nil
  local dstRoomNumber = tonumber( matches[2] )
  local dstRoomString = getRoomString( dstRoomNumber )
  local dirString = nil

  local nc, rc = MAP_COLOR["number"], MAP_COLOR["roomNameU"]

  if currentRoomNumber == dstRoomNumber then
    cecho( f "\nYou're already in {rc}{currentRoomName}<reset> [{nc}{dstRoomNumber}<reset>]" )
  elseif not roomExists( dstRoomNumber ) then
    cecho( f "\nRoom {nc}{dstRoomNumber}<reset> doesn't exist yet." )
  else
    getPath( currentRoomNumber, dstRoomNumber )
    if speedWalkDir then
      dstRoomName = getRoomName( dstRoomNumber )
      dirStringD = createWintin( speedWalkDir )
      dirStringP = traverseRooms( speedWalkPath )
      cecho( f "\n\nPath from {getRoomString(currentRoomNumber)} to {getRoomString(dstRoomNumber)}:" )
      cecho( f "\n\t<orange>{dirStringD}<reset>" )
      cecho( f "\n\t<yellow_green>{dirStringP}<reset>" )
      walkPath = dirString
    end
  end
end

entryRooms = entryRooms or {}

function getMSPath()
  -- Clear the path globals
  local dirString = nil
  speedWalkDir = nil
  speedWalkPath = nil

  -- Calculate the path to our current room from Market Square
  getPath( 1121, currentRoomNumber )
  if speedWalkDir then
    dirString = traverseRooms( speedWalkPath )
    -- Add an entry to the entryRooms table that maps currentAreaNumber to currentRoomNumber and the path to that room from Market Square
    cecho( f "\nAdding or updating path from MS to {getRoomString(currentRoomNumber,1)}" )
    entryRooms[currentAreaNumber] = {
      roomNumber = currentRoomNumber,
      path = dirString
    }
  else
    cecho( "\nUnable to find a path from Market Square to the current room." )
  end
  saveTable( 'entryRooms' )
end

function getRoomString( id, detail )
  detail = detail or 1
  local specTag = ""
  local roomString = nil
  local roomData = worldData[roomToAreaMap[id]].rooms[id]
  local roomName = roomData.roomName
  local nc = MAP_COLOR["number"]
  local rc = nil

  if roomData.roomSpec > 0 then
    specTag = f " ~<ansi_light_yellow>{roomData.roomSpec}<reset>~"
  end
  if uniqueRooms[roomName] then
    rc = MAP_COLOR['roomNameU']
  else
    rc = MAP_COLOR['roomName']
  end
  -- Detail 1 is name and number
  if detail == 1 then
    roomString = f "{rc}{roomName}<reset> ({MAP_COLOR['number']}{id}<reset>){specTag}"
    return roomString
  end
  -- Add room type for detail level 2
  local roomType = roomData.roomType
  local tc = MAP_COLOR[roomType]
  if detail == 2 then
    roomString = f "{rc}{roomName}<reset> [{tc}{roomType}<reset>] ({nc}{id}<reset>){specTag}"
    return roomString
  end
  -- Add map coordinates at level 3
  local uc = MAP_COLOR["mapui"]
  local cX = nil
  local cY = nil
  local cZ = nil
  cX, cY, cZ = getRoomCoordinates( id )
  local cString = f "{uc}{cX}<reset>, {uc}{cY}<reset>, {uc}{cZ}<reset>"
  roomString = f "{rc}{roomName}<reset> [{tc}{roomType}<reset>] ({nc}{id}<reset>) ({cString}){specTag}"
  return roomString
end

function showPaths()
end
