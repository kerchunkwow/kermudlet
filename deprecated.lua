-- Use with cecho etc. to colorize output without massively long f-strings
function ec( s, c )
  local colors = {
    err  = "orange_red",   -- Error
    dbg  = "dodger_blue",  -- Debug
    val  = "blue_violet",  -- Value
    var  = "dark_orange",  -- Variable Name
    func = "green_yellow", -- Function Name
    info = "sea_green",    -- Info/Data
  }
  local sc = colors[c] or "ivory"
  if c ~= 'func' then
    return "<" .. sc .. ">" .. s .. "<reset>"
  else
    return "<" .. sc .. ">" .. s .. "<reset>()"
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

-- Prototype/beta function for importing Wintin commands from an external file
function importWintinActions()
  local testActions = {}
  -- Make an empty group to hold the imported triggers
  permRegexTrigger( "Imported", "", {"^#"}, "" )

  local triggerCounter = 1

  for _, actionString in ipairs( testActions ) do
    local triggerName = "Imported" .. triggerCounter
    local pattern, command, priority = parseWintinAction( actionString )

    command = f [[print("{command}")]]

    if isRegex( pattern ) then
      permRegexTrigger( triggerName, "Imported", {pattern}, command )
    else
      permSubstringTrigger( triggerName, "Imported", {pattern}, command )
    end
    triggerCounter = triggerCounter + 1
  end
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

-- For all rooms globally delete any exit which leads to its own origin (and store that exit in culledExits)
function cullLoopedExits()
  local cullCount = 0
  local allRooms = getRooms()
  for id, name in pairs( allRooms ) do
    local exits = getRoomExits( id )
    for dir, dst in pairs( exits ) do
      if dst == id then
        cullCount = cullCount + 1
        culledExits[id] = culledExits[id] or {}
        setExit( id, -1, dir )
        culledExits[id][dir] = true
        cecho( f "\n<dim_grey>Culled looping <cyan>{dir}<dim_grey> exit from <dark_orange>{id}<reset>" )
      end
    end
  end
  cecho( f "\n<dim_grey>Culled <dark_orange>{cullCount}<dim_grey> total exits<reset>" )
  updateMap()
  table.save( 'C:/Dev/mud/mudlet/gizmo/data/culledExits.lua', culledExits )
end

function combineArea( dstArea, srcArea )
  local srcRooms = getAreaRooms( srcArea )
  for _, srcRoom in ipairs( srcRooms ) do
    setRoomArea( srcRoom, dstArea )
  end
  updateMap()
end

function getRoomStringOld( id, detail )
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

-- Attempt a "virtual move"; on success report on area transitions and update virtual coordinates.
function moveExitOld( direction )
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
  cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
  return false
end

exitData = exitData or {}

-- Load all Exit data from the gizwrld.db database into a Lua table
function loadExitData()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  if not conn then
    gizErr( "Error connecting to gizwrld.db." )
    return nil
  end
  local cursor = conn:execute( "SELECT * FROM Exit" )

  local row = cursor:fetch( {}, "a" )
  while row do
    local roomID = tonumber( row.roomRNumber )
    local dir = row.exitDirection
    local keyword = row.exitKeyword

    -- Only store exits with a keyword that is not nil and not an empty string
    if keyword and #keyword > 0 then
      -- Extract only the first word from the keyword
      local firstWord = keyword:match( "^(%w+)" )
      exitData[roomID] = exitData[roomID] or {}
      exitData[roomID][dir] = {
        exitDest = tonumber( row.exitDest ),
        exitKeyword = firstWord,
        exitFlags = tonumber( row.exitFlags ),
        exitDescription = row.exitDescription
      }

      -- Only store keys when exitKey is not nil and greater than 0
      local key = tonumber( row.exitKey )
      if key and key > 0 then
        exitData[roomID][dir].exitKey = key
      end
    end
    row = cursor:fetch( row, "a" )
  end
  cursor:close()
  conn:close()
  env:close()

  table.save( 'C:/Dev/mud/mudlet/gizmo/data/exitData.lua', exitData )
end

-- Load all Exit data from the gizwrld.db database into a Lua table
function loadExitData()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  if not conn then
    gizErr( "Error connecting to gizwrld.db." )
    return nil
  end
  local cursor = conn:execute( "SELECT * FROM Exit" )

  local row = cursor:fetch( {}, "a" )
  while row do
    local roomID = tonumber( row.roomRNumber )
    local dir = row.exitDirection
    local keyword = row.exitKeyword

    -- Only store exits with a keyword that is not nil and not an empty string
    if keyword and #keyword > 0 then
      -- Extract only the first word from the keyword
      local firstWord = keyword:match( "^(%w+)" )
      exitData[roomID] = exitData[roomID] or {}
      exitData[roomID][dir] = {
        exitDest = tonumber( row.exitDest ),
        exitKeyword = firstWord,
        exitFlags = tonumber( row.exitFlags ),
        exitDescription = row.exitDescription
      }

      -- Only store keys when exitKey is not nil and greater than 0
      local key = tonumber( row.exitKey )
      if key and key > 0 then
        exitData[roomID][dir].exitKey = key
      end
    end
    row = cursor:fetch( row, "a" )
  end
  cursor:close()
  conn:close()
  env:close()

  table.save( 'C:/Dev/mud/mudlet/gizmo/data/exitData.lua', exitData )
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

-- Get the Area data for a given areaRNumber
function getAreaData( areaRNumber )
  return worldData[areaRNumber]
end

-- Get the Room data for a given roomRNumber
function getRoomData( roomRNumber )
  local areaRNumber = roomToAreaMap[roomRNumber]
  if areaRNumber and worldData[areaRNumber] then
    return worldData[areaRNumber].rooms[roomRNumber]
  end
end

-- Get Exits from room with the given roomRNumber
function getExitData( roomRNumber )
  local roomData = getRoomData( roomRNumber )
  return roomData and roomData.exits
end

function getAreaByRoom( roomRNumber )
  local areaRNumber = roomToAreaMap[roomRNumber]
  return getAreaData( areaRNumber )
end

function getAllRoomsByArea( areaRNumber )
  local areaData = getAreaData( areaRNumber )
  return areaData and areaData.rooms or {}
end

-- Use a breadth-first-search (BFS) to find the shortest path between two rooms
function findShortestPath( srcRoom, dstRoom )
  if srcRoom == dstRoom then return {srcRoom} end
  -- Table for visisted rooms to avoid revisiting
  local visitedRooms = {}

  -- The search queue, seeded with the srcRoom
  local pathQueue    = {{srcRoom}}

  -- As long as there are paths in the queue, "pop" one off and explore it fully
  while #pathQueue > 0 do
    local path = table.remove( pathQueue, 1 )
    local lastRoom = path[#path]

    -- Only visit unvisited rooms (this path)
    if not visitedRooms[lastRoom] then
      -- Mark the room visited
      visitedRooms[lastRoom] = true

      -- Look up the room in the worldData table
      for _, areaData in pairs( worldData ) do
        local roomData = areaData.rooms[lastRoom]

        -- For the love of St. Christopher (patron saint of bachelors and travel), don't add DTs to paths
        if roomData and not roomData.roomFlags:find( "DEATH" ) then
          -- Examine each exit from the room
          for _, exit in pairs( roomData.exits ) do
            local nextRoom = exit.exitDest

            -- If one of the exits is dstRoom; constrcut and return the path
            if nextRoom == dstRoom then
              local shortestPath = {unpack( path )}
              table.insert( shortestPath, nextRoom )
              return shortestPath
            end
            -- Otherwise, extend the path and queue
            if not visitedRooms[nextRoom] then
              local newPath = {unpack( path )}
              table.insert( newPath, nextRoom )
              pathQueue[#pathQueue + 1] = newPath
            end
          end
        end
      end
    end
  end
  -- Couldn't find a path to the destination
  return nil
end

function roomsReport()
  local minRoom = worldData[currentAreaNumber].areaMinRoomRNumber
  local maxRoom = worldData[currentAreaNumber].areaMaxRoomRNumber
  local roomsMapped = 0
  for r = minRoom, maxRoom do
    if roomExists( r ) then roomsMapped = roomsMapped + 1 end
  end
  --local mappedRooms = getAreaRooms( currentAreaNumber )
  --local roomsMapped = #mappedRooms + 1
  local roomsTotal = worldData[currentAreaNumber].areaRoomCount
  local roomsLeft = roomsTotal - roomsMapped
  local ac = MAP_COLOR["area"]
  local nc = MAP_COLOR["number"]
  local rc = MAP_COLOR["roomName"]
  mapInfo( f 'Found <yellow_green>{roomsMapped}<reset> of <dark_orange>{roomsTotal}<reset> rooms in {areaTag()}<reset>.' )

  -- Check if there are 10 or fewer rooms left to map
  if roomsLeft == 0 then
    mapInfo( "<yellow_green>Area Complete!<reset>" )
  elseif roomsLeft > 0 and roomsLeft <= 10 then
    mapInfo( "\n<orange>Unmapped<reset>:\n" )
    for roomRNumber, roomData in pairs( worldData[currentAreaNumber].rooms ) do
      if not contains( roomsMapped, roomRNumber, true ) then
        local roomName = roomData.roomName
        local exitsInfo = ""

        -- Iterate through exits using pairs
        for _, exit in pairs( roomData.exits ) do
          exitsInfo = exitsInfo .. exit.exitDirection .. f " to {nc}" .. exit.exitDest .. "<reset>; "
        end
        cecho( f '[+   Room: {rc}{roomName}<reset> (ID: {nc}{roomRNumber}<reset>)\n    Exits: {exitsInfo}\n' )
      end
    end
  end
  local worldRooms = getRooms()
  local worldRoomsCount = 0

  for _ in pairs( worldRooms ) do
    worldRoomsCount = worldRoomsCount + 1
  end
  mapInfo( f '<olive_drab>World<reset> total: {nc}{worldRoomsCount}<reset>' )
end

function roomTag()
  return f "<light_steel_blue>currentRoomName<reset> [<royal_blue>currentRoomNumber<reset>]"
end

-- Function to find all neighboring rooms with exits leading to a specific roomRNumber
function findNeighbors( targetRoomRNumber )
  local neighbors = {}
  local nc = MAP_COLOR["number"]
  local minR, maxR = currentAreaData.areaMinRoomRNumber, currentAreaData.areaMaxRoomRNumber
  for r = minR, maxR do
    local roomData = currentAreaData.rooms[r]
    local exitData = roomData.exits
    for _, exit in pairs( exitData ) do
      if exit.exitDest == targetRoomRNumber then
        table.insert( neighbors, r )
      end
    end
  end
  mapInfo( f ' Neighbors for {nc}{targetRoomRNumber}<reset>:\n' )
  display( neighbors )
end

function setMinimumRoomNumber( areaID, newMinimum )
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )
  local nc = MAP_COLOR["number"]
  local ac = MAP_COLOR["area"]
  if not conn then
    gizErr( 'Error connecting to gizwrld.db.' )
    return
  end
  -- Fetch the current minimum room number for the area
  local cursor, err = conn:execute( f( "SELECT areaMinRoomRNumber FROM Area WHERE areaRNumber = {areaID}" ) )
  if not cursor then
    gizErr( f( "Error fetching data for {ac}{areaID}<reset>: {err}" ) )
    return
  end
  local row = cursor:fetch( {}, "a" )
  if not row then
    gizErr( f "Area {ac}{areaID}<reset> not found." )
    return
  end
  local currentMinRoomNumber = tonumber( row.areaMinRoomRNumber )
  if currentMinRoomNumber == newMinimum then
    cecho( f "\nFirst room for {ac}{areaID}<reset> already {nc}{newMinimum}<reset>" )
  else
    -- Update the minimum room number
    local update_stmt = f( "UPDATE Area SET areaMinRoomRNumber = {newMinimum} WHERE areaRNumber = {areaID}" )
    local res, upd_err = conn:execute( update_stmt )
    if not res then
      gizErr( f( "Error updating data for {ac}{areaID}<reset>: {upd_err}" ) )
      return
    end
    cecho( f "\nUpdated first room for {ac}{areaID}<reset> from {nc}{currentMinRoomNumber}<reset> to {nc}{newMinimum}<reset>" )
  end
  -- Clean up
  if cursor then cursor:close() end
  conn:close()
  env:close()
end

-- From the current room, search for neighboring rooms in this Area;
-- Good neighbors are those that have a corresponding return/reverse exit back to our current room; reposition those rooms near us
-- Bad neighbors have no return/reverse exit; cull those exits (remove them from the map and store them in the culledExits table)
function findNearestNeighbors()
  local currentExits = getRoomExits( currentRoomNumber )
  local rc = MAP_COLOR["number"]

  for dir, roomNumber in pairs( currentExits ) do
    if roomExists( roomNumber ) and roomNumber ~= currentRoomNumber then
      local reverseDir = REVERSE[dir]
      local neighborExits = getRoomExits( roomNumber )

      if neighborExits and neighborExits[reverseDir] == currentRoomNumber then
        -- Good neighbor: reposition
        repositionRoom( roomNumber, dir )
        local path = createWintin( {dir} )
        --cecho( f( "\n<cyan>{path}<reset> to room {rc}{roomNumber}<reset>" ) )
      elseif neighborExits and (not neighborExits[reverseDir] or neighborExits[reverseDir] ~= currentRoomNumber) then
        cecho( f "\nRoom {rc}{roomNumber}<reset> is bad neighbor to our <cyan>{dir}<reset>, consider <firebrick>culling<reset> it" )
        --cullExit( dir )
      end
    end
  end
end

-- Move a room to a location relative to our current location (mX, mY, mZ)
function repositionRoom( id, relativeDirection )
  if not id or not relativeDirection then return end
  local rc = MAP_COLOR["number"]
  local mc = "<medium_orchid>"
  local rX, rY, rZ = mX, mY, mZ
  if relativeDirection == "north" then
    rY = rY + 1
  elseif relativeDirection == "south" then
    rY = rY - 1
  elseif relativeDirection == "east" then
    rX = rX + 1
  elseif relativeDirection == "west" then
    rX = rX - 1
  elseif relativeDirection == "up" then
    rZ = rZ + 1
  elseif relativeDirection == "down" then
    rZ = rZ - 1
  end
  cecho( f "\nRoom {rc}{id}<reset> is good neighbor to our <cyan>{relativeDirection}<reset>, moving to {mc}{rX}<reset>, {mc}{rY}<reset>, {mc}{rZ}<reset>" )
  setRoomCoordinates( id, rX, rY, rZ )
  updateMap()
end

function auditAreaCoordinates()
  local nc = MAP_COLOR["number"]
  local areaCoordinates = {}
  local minRoom = worldData[currentAreaNumber].areaMinRoomRNumber
  local maxRoom = worldData[currentAreaNumber].areaMaxRoomRNumber

  for r = minRoom, maxRoom do
    if roomExists( r ) then
      local roomX, roomY, roomZ = getRoomCoordinates( r )
      local coordKey = roomX .. ":" .. roomY .. ":" .. roomZ

      if areaCoordinates[coordKey] then
        -- Found overlapping rooms
        cecho( f(
          "\nRooms {nc}{areaCoordinates[coordKey]}<reset> and {nc}{r}<reset> overlap at coordinates ({roomX}, {roomY}, {roomZ})." ) )
      else
        -- Store the coordinate key with its room number
        areaCoordinates[coordKey] = r
      end
    end
  end
end

function countRooms()
  local areaCounts = {}
  local allRooms = getRooms()
  for id, name in pairs( allRooms ) do
    local area = getRoomArea( id )
    local areaName = getRoomAreaName( area )
    areaCounts[areaName] = (areaCounts[areaName] or 0) + 1
  end
  display( areaCounts )
end

-- The "main" display function to print the current room as if we just moved into it or looked at it
-- in the game; prints the room name, description, and exits.
function displayRoom( brief )
  brief = brief or true
  local rd = MAP_COLOR["roomDesc"]
  cecho( f "\n\n{getRoomString(currentRoomNumber, 2)}" )
  if not brief then
    cecho( f "\n{rd}{currentRoomData.roomDescription}<reset>" )
  end
  if currentRoomData.roomSpec > 0 then
    local renv = getRoomEnv( currentRoomNumber )
    if renv ~= COLOR_PROC then
      setRoomStyle()
    end
    cecho( f "\n\tThis room has a ~<ansi_light_yellow>special procedure<reset>~.\n" )
  end
  displayExits()
end

function setCurrentRoomxx( id )
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

function setCurrentRoom( id )
  local roomNumber = tonumber( id )
  local roomArea = getRoomArea( roomNumber )
  roomArea = tonumber( roomArea )
  -- If this is the first Area or the id is outside the current Area, update Area before Room
  if currentAreaNumber ~= roomArea then
    setCurrentArea( roomArea )
  end
  --currentRoomData   = currentAreaData.rooms[id]
  currentRoomNumber = roomNumber                       -- currentRoomData.roomRNumber
  currentRoomName   = getRoomName( currentRoomNumber ) -- currentRoomData.roomName
  roomExits         = getRoomExits( currentRoomNumber )
end

function setCurrentAreax( id )
  currentAreaData   = worldData[id]
  currentAreaNumber = tonumber( currentAreaData.areaRNumber )
  currentAreaName   = tostring( currentAreaData.areaName )
end

function setCurrentArea( id )
  -- Store the room number of the "entrance" so we can easily reset to the start of an area when mapping
  -- firstAreaRoomNumber = id
  -- If we're leaving an Area, store information and report on the transition
  if currentAreaNumber > 0 then
    lastAreaNumber = currentAreaNumber
    lastAreaName   = currentAreaName
    mapInfo( f "Left: {areaTag()}" )
  end
  -- currentAreaData   = worldData[id]
  -- currentAreaNumber = tonumber( currentAreaData.areaRNumber )
  -- currentAreaName   = tostring( currentAreaData.areaName )
  currentAreaNumber = getRoomArea( id )
  currentAreaName   = getRoomAreaName( id )
  mapInfo( f "Entered {areaTag()}" )
  setMapZoom( 28 )
end

function setCurrentRoomNew( id )
  if currentAreaNumber < 0 or getRoomArea( id ) ~= currentAreaNumber then
    setCurrentArea( getRoomArea( id ) )
  end
end

function setCurrentAreaNew( id )
  -- If we're leaving an Area, store information and report on the transition
  if currentAreaNumber > 0 then
    lastAreaNumber = currentAreaNumber
    lastAreaName   = currentAreaName
    mapInfo( f "Left: {areaTag()}" )
  end
  currentAreaNumber = getRoomArea( id )
  currentAreaName   = getRoomAreaName( id )
  mapInfo( f "Entered {areaTag()}" )
  setMapZoom( 28 )
end

function setCurrentRoomxx( id )
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

-- Display all exits of the current room as they might appear in the MUD
function displayExits( id )
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

    -- Determine the color based on exit properties
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
    --local nextExit = f "{ec}{dir}<reset> ({nc}{to}<reset>)"
    local nextExit = f "{nc}{dir}<reset>)"
    if isFirstExit then
      exitString = f "{MAP_COLOR['exitStr']}Exits:  [" .. nextExit .. f "{MAP_COLOR['exitStr']}]<reset>"
      isFirstExit = false
    else
      exitString = exitString .. f " {MAP_COLOR['exitStr']}[<reset>" .. nextExit .. f "{MAP_COLOR['exitStr']}]<reset>"
    end
  end
  cecho( f "\n   {exitString}" )
end

-- A function to determine whether a Room belongs to a given Area
function isInArea( roomID, areaID )
  local roomArea = getRoomArea( roomID )
  -- If the Room exists (i.e., it has been mapped), then use Mudlet as our source of truth
  if roomArea == areaID or roomArea == getRoomArea( currentRoomNumber ) then
    return true
    -- If the Room has not been mapped, see if it is a member of the Area's room table in the worldData table
  elseif not roomExists( roomID ) and worldData[areaID].rooms[roomID] then
    return true
  end
  return false
end

-- From the gizwrld database, load the Area, Room, and Exit data into a Lua table
function loadWorldData()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  if not conn then
    gizErr( f 'Error connecting to gizwrld.db.' )
    return nil
  end
  local areas = {}
  local cursor

  -- Load Areas
  cursor = conn:execute( "SELECT * FROM Area" )
  local row = cursor:fetch( {}, "a" )
  while row do
    areas[row.areaRNumber] = {
      areaRNumber = row.areaRNumber,
      areaName = row.areaName,
      areaResetType = row.areaResetType,
      areaFirstRoomName = row.areaFirstRoomName,
      areaMinRoomRNumber = row.areaMinRoomRNumber,
      areaMaxRoomRNumber = row.areaMaxRoomRNumber,
      areaMinVNumber = row.areaMinVNumber,
      areaMaxVNumberActual = row.areaMaxVNumberActual,
      areaMaxVNumberAllowed = row.areaMaxVNumberAllowed,
      areaRoomCount = row.areaRoomCount,
      rooms = {}
    }
    row = cursor:fetch( row, "a" )
  end
  cursor:close()

  -- Load Rooms
  cursor = conn:execute( "SELECT * FROM Room" )
  row = cursor:fetch( {}, "a" )
  while row do
    if areas[row.areaRNumber] then
      areas[row.areaRNumber].rooms[row.roomRNumber] = {
        roomRNumber = row.roomRNumber,
        roomName = row.roomName,
        roomType = row.roomType,
        roomSpec = row.roomSpec,
        roomFlags = row.roomFlags,
        roomDescription = row.roomDescription,
        roomExtraKeyword = row.roomExtraKeyword,
        roomVNumber = row.roomVNumber,
        exits = {}
      }
    else
      cecho( f '{{Unmatched Room: {row.roomRNumber} in Area: {row.areaRNumber}\n' )
    end
    row = cursor:fetch( row, "a" )
  end
  cursor:close()

  -- Load Exits
  cursor = conn:execute( "SELECT * FROM Exit" )
  row = cursor:fetch( {}, "a" )
  while row do
    for _, area in pairs( areas ) do
      if area.rooms[row.roomRNumber] then
        table.insert( area.rooms[row.roomRNumber].exits, {
          exitID = row.exitID,
          exitDirection = row.exitDirection,
          exitDest = row.exitDest,
          exitKeyword = row.exitKeyword,
          exitFlags = row.exitFlags,
          exitKey = row.exitKey,
          exitDescription = row.exitDescription
        } )
        break -- Exit found and added, no need to continue looping through areas
      end
    end
    row = cursor:fetch( row, "a" )
  end
  -- Create a lookup table that maps roomRNumber(s) to areaRNumber(s)
  for areaID, area in pairs( areas ) do
    for roomID, _ in pairs( area.rooms ) do
      roomToAreaMap[roomID] = areaID
    end
  end
  cursor:close()
  conn:close()
  env:close()
  return areas
end

--[[
Functions to load, query, and interact with data from the database: 'C:/Dev/mud/gizmo/data/gizwrld.db'

Table Structure:
  Area Table:
  areaRNumber INTEGER; A unique identifier and primary key for Area
  areaName TEXT; The name of the Area in the MUD
  areaResetType TEXT; A string describing how and when the area repopulates
  areaFirstRoomName TEXT; The name of the first Room in the Area; usually the Room with areaMinRoomRNumber
  areaMinRoomRNumber INTEGER; The lowest value of roomRNumber for Rooms in the Area
  areaMaxRoomRNumber INTEGER; The highest value of roomRNumber for Rooms in the Area
  areaMinVNumber INTEGER; The lowest value of roomVNumber for Rooms in the Area; usually the same room as areaMinRoomRNumber
  areaMaxVNumberActual INTEGER; The highest value for Rooms that actually exist in the Area
  areaMaxVNumberAllowed INTEGER; The highest value that a Room could theoretically have in the Area
  areaRoomCount INTEGER; How many Rooms are in the Area

  Room Table:
  roomName TEXT; The name of the Room in the MUD
  roomVNumber INTEGER; The VNumber of the Room; an alternative identifier
  roomRNumber INTEGER; The RNumber of the Room; the primary unique identifier
  roomType TEXT; The "Terrain" or "Sector" type of the Room; will be used for color selection
  roomSpec BOOLEAN; Boolean value identifying Rooms with "special procedures" which will affect players in the Room
  roomFlags TEXT; A list of flags that identify special properties of the Room
  roomDescription TEXT; A long description of the Room that players see in game
  roomExtraKeyword TEXT; A list of one or more words that identify things in the room players can examine or interact with
  areaRNumber INTEGER; Foreign key to the Area in which this Room exists

  Exit Table:
  exitDirection TEXT; The direction the player must travel to use this Exit
  exitDest INTEGER; The roomRNumber of the Room the player travels to when using this Exit
  exitKeyword TEXT; Keywords Players use to interact with an Exit such as 'door' or 'gate'
  exitFlags INTEGER; A list of flags that identify special properties of an Exit, usually a door
  exitKey INTEGER; For Exits that require keys to lock/unlock, this is the in-game ID for the key
  exitDescription TEXT; A short description of the Exit such as 'A gravel path leading west.'
  roomRNumber INTEGER; Foreign key to the Room in which this Exit belongs
--]]
-- From the gizwrld database, load the Area, Room, and Exit data into a Lua table
function loadFollowData()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  if not conn then
    gizErr( f 'Error connecting to gizwrld.db.' )
    return nil
  end
  local areas = {}
  local cursor

  -- Load Areas
  cursor = conn:execute( "SELECT * FROM Area" )
  local row = cursor:fetch( {}, "a" )
  while row do
    areas[row.areaRNumber] = {
      areaRNumber = row.areaRNumber,
      areaName = row.areaName,
      rooms = {}
    }
    row = cursor:fetch( row, "a" )
  end
  cursor:close()

  -- Load Rooms
  cursor = conn:execute( "SELECT * FROM Room" )
  row = cursor:fetch( {}, "a" )
  while row do
    if areas[row.areaRNumber] then
      areas[row.areaRNumber].rooms[row.roomRNumber] = {
        roomRNumber = row.roomRNumber,
        roomName = row.roomName,
        exits = {}
      }
    else
      cecho( f '{{Unmatched Room: {row.roomRNumber} in Area: {row.areaRNumber}\n' )
    end
    row = cursor:fetch( row, "a" )
  end
  cursor:close()

  -- Load Exits
  cursor = conn:execute( "SELECT * FROM Exit" )
  row = cursor:fetch( {}, "a" )
  while row do
    for _, area in pairs( areas ) do
      if area.rooms[row.roomRNumber] then
        table.insert( area.rooms[row.roomRNumber].exits, {
          exitDirection = row.exitDirection,
          exitDest = row.exitDest,
        } )
        break -- Exit found and added, no need to continue looping through areas
      end
    end
    row = cursor:fetch( row, "a" )
  end
  -- Create a lookup table that maps roomRNumber(s) to areaRNumber(s)
  for areaID, area in pairs( areas ) do
    for roomID, _ in pairs( area.rooms ) do
      roomToAreaMap[roomID] = areaID
    end
  end
  cursor:close()
  conn:close()
  env:close()
  -- Create a lookup table that maps roomRNumber(s) to areaRNumber(s)
  for areaID, area in pairs( areas ) do
    for roomID, _ in pairs( area.rooms ) do
      roomToAreaMap[roomID] = areaID
    end
  end
  return areas
end

roomToAreaMap = {}
worldData = {}
currentAreaData = {}
currentRoomData = {}
currentAreaNumber = -1
currentAreaName = ""
currentRoomNumber = -1
currentRoomName = ""
roomExits = {}

-- Basically just getPathAlias but automatically follow the route.
function gotoAlias()
  getPathAlias()
  doWintin( walkPath )
end

-- Use built-in Mudlet path finding to get a path to the specified room.
function getPathAlias()
  -- Clear the pathing globals
  speedWalkDir = nil
  speedWalkPath = nil

  local nc = MAP_COLOR["number"]
  local rc = MAP_COLOR["roomNameU"]
  local dirs = nil
  local dstRoomName = nil
  local dstRoomNumber = tonumber( matches[2] )
  if currentRoomNumber == dstRoomNumber then
    cecho( f "\nYou're already in {rc}{currentRoomName}<reset>." )
  elseif not roomExists( dstRoomNumber ) then
    cecho( f "\nRoom {nc}{dstRoomNumber}<reset> doesn't exist yet." )
  else
    getPath( currentRoomNumber, dstRoomNumber )
    if speedWalkDir then
      dstRoomName = getRoomName( dstRoomNumber )
      dirs = createWintin( speedWalkDir )
      cecho( f "\n\nPath from {rc}{currentRoomName}<reset> [{nc}{currentRoomNumber}<reset>] to {rc}{dstRoomName}<reset> [{nc}{dstRoomNumber}<reset>]:" )
      cecho( f "\n<green_yellow>{dirs}<reset>" )
      walkPath = dirs
    end
  end
end

worldData = loadFollowData()
-- Create all Exits, Exit Stubs, and/or Doors from the Current Room to adjacent Rooms
function updateExits()
  if true then return end
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

function setRoomStyleAlias()
  local roomStyle = matches[2]
  if roomStyle == "mana" then
    unHighlightRoom( currentRoomNumber )
    setRoomEnv( currentRoomNumber, COLOR_CLUB )
    setRoomChar( currentRoomNumber, "💤" )
  elseif roomStyle == "shop" then
    unHighlightRoom( currentRoomNumber )
    setRoomEnv( currentRoomNumber, COLOR_SHOP )
    setRoomChar( currentRoomNumber, "💰" )
    --setRoomCharColor( currentRoomNumber, 140, 130, 15, 255 )
  elseif roomStyle == "death" then
    unHighlightRoom( currentRoomNumber )
    setRoomEnv( currentRoomNumber, COLOR_DEATH )
    setRoomChar( currentRoomNumber, "💀 " )
    lockRoom( currentRoomNumber, true )
  elseif roomStyle == "proc" then
    unHighlightRoom( id )
    setRoomEnv( id, COLOR_PROC )
    setRoomChar( id, "📁 " )
  end
end

-- Cull redundant (leading to the same room) exits from a given room
function cullRedundantExits( roomID )
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
      culledExits[roomID] = culledExits[roomID] or {}

      -- If the destination room has a "reverse" (return) of the exit, keep that one
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
          exitToKeep = exitDir
          break
        end
      end
    end
    -- If there's no matching 'return' exit, prefer exits in this order
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
        cullExit( exitDir )
      end
    end
  end
end

-- Set & update the player's location, updating coordinates & creating rooms as necessary
function updatePlayerLocationyy( roomRNumber, direction )
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
  --updateExits()
  centerview( currentRoomNumber )
end

function splitPrint( str, delimiter )
  local substrings = split( str, delimiter )
  for _, substring in ipairs( substrings ) do
    print( substring )
  end
end
