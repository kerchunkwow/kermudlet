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

areaMap = {}
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
