-- Clean up minimum room numbers corrupted by my dumb ass
function fixMinimumRoomNumbers()
  local aid = 0
  while worldData[aid] do
    local roomsData = worldData[aid].rooms
    local minRoom = nil
    for _, room in pairs( roomsData ) do
      local roomRNumber = tonumber( room.roomRNumber )
      if roomRNumber and (not minRoom or minRoom > roomRNumber) then
        minRoom = roomRNumber
      end
    end
    if minRoom and minRoom ~= worldData[aid].areaMinRoomRNumber then
      setMinimumRoomNumber( aid, minRoom )
    end
    aid = aid + 1
    -- Skip area 107
    if aid == 107 then aid = aid + 1 end
  end
end

-- One-Time Load all of the door data into the doorData table and save it
function loadDoorData()
  local doorCount = 0
  local allRooms = getRooms()
  doorData = {} -- Initialize the doorData table

  for id, name in pairs( allRooms ) do
    --id = tonumber( r )
    if not id then
      cecho( f "\nFailed to convert{r} to number." )
    else
      local doors = getDoors( id )
      if next( doors ) then               -- Check if there are doors in the room
        doorData[id] = doorData[id] or {} -- Initialize the table for the room

        for dir, status in pairs( doors ) do
          local doorString, keyNumber = getDoorData( id, tostring( dir ) )
          doorData[id][dir] = {}           -- Initialize the table for the direction
          doorData[id][dir].state = status -- 1 for regular, 2 for locked
          doorData[id][dir].word = doorString

          if keyNumber and keyNumber > 0 then
            doorData[id][dir].key = keyNumber
          end
          doorCount = doorCount + 1
        end
      end
    end
  end
  cecho( f "\nLoaded <maroon>{doorCount}<reset> doors.\n" )
  table.save( "C:/Dev/mud/mudlet/gizmo/data/doorData.lua", doorData )
end

-- Help create the master door data table (one time load)
function getDoorData( id, dir )
  local exitData = worldData[roomToAreaMap[id]].rooms[id].exits
  for _, exit in pairs( exitData ) do
    if SDIR[exit.exitDirection] == dir then
      local kw = exit.exitKeyword:match( "%w+" )
      local kn = tonumber( exit.exitKey )
      return kw, kn
    end
  end
end

-- Run some checks on the doorData table/file to make sure it's valid
function validateDoorData()
  --loadTable( "doorData" ) -- Load the doorData table from file
  local errorCount = 0
  local verifiedCount = 0

  for id, doors in pairs( doorData ) do
    local mudletDoors = getDoors( id )
    local roomExits = getRoomExits( id )

    for dir, doorInfo in pairs( doors ) do
      -- 1.1 Verify doorData[x][dir] matches an entry in the table returned by getDoors(x)
      if not mudletDoors[dir] then
        cecho( f "\nError: Door in room {id} direction {dir} not found in Mudlet door data." )
        errorCount = errorCount + 1
      end
      -- 1.2 Verify the room has a full valid exit leading that direction
      local fullDir = LDIR[dir] or dir
      if not roomExits[fullDir] then
        cecho( f "\nError: No valid exit {fullDir} in room {id}." )
        errorCount = errorCount + 1
      end
      -- 1.3 Verify that the door has a keyword string with 1 or more characters
      if not doorInfo.word or #doorInfo.word == 0 then
        cecho( f "\nError: Door in room {id} direction {dir} has no keyword." )
        errorCount = errorCount + 1
      end
      -- 1.4 Verify door state and key if locked
      if doorInfo.state == 3 and (not doorInfo.key or doorInfo.key <= 0) then
        cecho( f "\nError: Locked door in room {id} direction {dir} has invalid key." )
        errorCount = errorCount + 1
      end
      if errorCount == 0 then
        verifiedCount = verifiedCount + 1
      end
    end
  end
  if errorCount == 0 then
    cecho( f "\nSuccessfully verified {verifiedCount} doors." )
  else
    cecho( f "\nCompleted validation with {errorCount} errors found." )
  end
end

-- Original function to instantiate an empty world
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

-- Replaced by getFullPath/getAreaDirs
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

-- Original function to populate areaDirs table
function getAreaDirs()
  local fullDirs = getFullDirs( 1121, currentRoomNumber )
  local roomArea = getRoomArea( currentRoomNumber )
  if fullDirs then
    areaDirs[roomArea]            = {}
    -- Store our Wintin-compatible path string along with the raw output from Mudlet's pathing
    areaDirs[roomArea].dirs       = fullDirs
    areaDirs[roomArea].rawDirs    = speedWalkDir
    -- Store the name & number of the destination room (the area entry room)
    areaDirs[roomArea].roomNumber = currentRoomNumber
    areaDirs[roomArea].roomName   = getRoomName( currentRoomNumber )
    -- The cost to walk the path is two times the length
    areaDirs[roomArea].cost       = (#speedWalkDir * 2)
    cecho( f "\nAdded <dark_orange>{nextArea}<reset> to the areaDirs table" )
  end
end

-- Not as good an attempt to do getAreaDirs()
function getAreaDirs()
  for _, roomID in ipairs( areaFirstRooms ) do
    local pathString = getFullDirs( 1121, roomID ) -- Assuming 1121 is your starting room (e.g., Market Square)
    if pathString then
      cecho( f( "\nPath from <dark_orange>1121<reset> to room <dark_orange>{roomID}<reset>:\n\t<olive_drab>{pathString}" ) )
    else
      cecho( f( "\nNo path found from <dark_orange>1121<reset> to room <dark_orange>{roomID}<reset>" ) )
    end
  end
end

--Brute force find the room that's closest to our current location that belongs to the given area
function findArea( id )
  local allRooms           = getRooms()
  local shortestDirsLength = 750000 -- Initialize to a very high number
  local shortestDirs       = nil
  local nearestRoom        = nil

  for r, n in pairs( allRooms ) do -- Use pairs for iteration
    local roomID = tonumber( r )
    if getRoomArea( roomID ) == id then
      if getPath( 1121, roomID ) then -- Check if path is found
        local currentPathLength = #speedWalkDir
        if currentPathLength < shortestDirsLength then
          shortestDirsLength = currentPathLength
          nearestRoom        = getRoomString( roomID, 2 )
          shortestDirs       = getFullDirs( 1121, roomID )
        end
      end
    end
  end
  if shortestDirs then
    doWintin( shortestDirs )
    return true
  else
    cecho( f "\nFailed to find a room in area <dark_orange>{id}<reset>" )
    return false
  end
end

function buildAreaMap()
  areaMap = {}
  for areaID in pairs( areaDirs ) do
    local areaName = getRoomAreaName( areaID )
    if areaName then
      -- Cleanse & normalize the names
      print( areaName )
      areaName = areaName:gsub( "^The%s+", "" ):gsub( "%s+", "" ):lower()
      print( areaName )
      areaMap[areaName] = areaID
    end
  end
end

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
      dirString1 = createWintin( speedWalkDir )
      dirString2 = createWintinGPT( speedWalkDir )
      cecho( f "\n\nPath from {getRoomString(currentRoomNumber)} to {getRoomString(dstRoomNumber)}:" )
      cecho( f "\n\t<orange>{dirString1}<reset>" )
      cecho( f "\n\t<yellow_green>{dirString2}<reset>" )
      walkPath = dirString
    end
  end
end

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
        local h1r, h1g, h1b = getModifiedColor( br, bg, bb, -20 )
        local h2r, h2g, h2b = getModifiedColor( br, bg, bb, 80 )
        highlightRoom( id, h1r, h1g, h1b, h2r, h2g, h2b, 0.45, 255, 255 )
      end
    end
  end
  cecho( f "\nChecked {roomsChecked} rooms." )
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

-- Globally update area labels from deep_pink to medium_violet_red
function updateAllAreaLabels()
  local areaID = 1
  local modCount = 0
  while worldData[areaID] do
    modCount = modCount + updateLabelStyle( areaID, 255, 69, 0, 255, 99, 71, 10 )
    areaID = areaID + 1
    -- Skip area 107; it's missing from our database
    if areaID == 107 then areaID = areaID + 1 end
  end
  cecho( f "\n<dark_orange>{modCount}<reset> room labels updated." )
end

-- Globally update room labels from orange-ish to royal_blue
function updateAllRoomLabels()
  local areaID = 1
  local modCount = 0
  while worldData[areaID] do
    modCount = modCount + updateLabelStyle( areaID, 255, 140, 0, 65, 105, 225, 8 )
    areaID = areaID + 1
    -- Skip area 107; it's missing from our database
    if areaID == 107 then areaID = areaID + 1 end
  end
  cecho( f "\n<dark_orange>{modCount}<reset> room labels updated." )
end

-- For a given area, update labels from an old color to a new color and size
function updateLabelStyle( id, oR, oG, oB, nR, nG, nB, nS )
  local areaLabels = getMapLabels( id )
  local labelCount = #areaLabels
  local modCount = 0
  -- Ignore missing areas and ones w/ no labels
  if areaLabels and labelCount > 0 then
    -- getMapLabels is zero-based
    for lbl = 0, labelCount do
      local labelData = getMapLabel( id, lbl )
      if labelData then
        local lR = labelData.FgColor.r
        local lG = labelData.FgColor.g
        local lB = labelData.FgColor.b
        -- Check for labels w/ old color
        if lR == oR and lG == oG and lB == oB then
          local lT = labelData.Text
          -- Round the coordinates to the nearest 0.025
          local lX = round( labelData.X )
          local lY = round( labelData.Y )
          local lZ = round( labelData.Z )
          -- Delete existing label and create a new one in its place using the new color & size
          deleteMapLabel( id, lbl )
          createMapLabel( id, lT, lX, lY, lZ, nR, nG, nB, 0, 0, 0, 0, nS, true, true, "Bitstream Vera Sans Mono", 255, 0 )
          modCount = modCount + 1
        end
      end
    end
    updateMap()
  end
  return modCount
end

function viewLabelData()
  local areaLabels = getMapLabels( currentAreaNumber )
  for lbl = 0, #areaLabels do
    local labelData = getMapLabel( currentAreaNumber, lbl )
    if labelData then
      local lT = labelData.Text
      local lR = labelData.FgColor.r
      local lG = labelData.FgColor.g
      local lB = labelData.FgColor.b
      cecho( f "\n<royal_blue>{lT}<reset>: ({lR}, {lG}, {lB})" )
    end
  end
end

function showAreaPaths()
  cecho( f "\nGlobal Area Paths:\n" )
  for areaID, entryData in pairs( entryRooms ) do
    local roomNumber = entryData.roomNumber
    local areaName = getRoomAreaName( getRoomArea( roomNumber ) )
    local path = entryData.path
    cecho( f [[
<medium_violet_red>{areaName}<reset> <dim_grey>[<reset><maroon>{areaID}<reset><dim_grey>]<reset>
    <dim_grey>Entrance: {getRoomString(roomNumber,1)}
    <dim_grey>Dirs: <olive_drab>{path}<reset>
]] )
  end
end

function updateAreaPaths()
  cecho( f "\nGlobal Area Paths:\n" )
  for areaID, entryData in pairs( entryRooms ) do
    local roomNumber = entryData.roomNumber
    local oldPath = entryData.path
    local areaName = getRoomAreaName( getRoomArea( roomNumber ) )
    print( f "Looking for path to: {roomNumber}" )
    --getPath( 1121, roomNumber )
    --display( speedWalkPath )
    local newPath = getFullDirs( 1121, tonumber( roomNumber ) )
    --<dim_grey>New Dirs: <yellow_green>{display(newPath)}<reset>
    cecho( f [[
<medium_violet_red>{areaName}<reset> <dim_grey>[<reset><maroon>{areaID}<reset><dim_grey>]<reset>
    <dim_grey>Entrance: {getRoomString(roomNumber,1)}
    <dim_grey>Dirs: <olive_drab>{oldPath}<reset>
]] )
  end
end
