--[[ mapdata.lua

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
  local mappedRooms = getAreaRooms( currentAreaNumber )
  local roomsMapped = #mappedRooms + 1
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
      if not contains( mappedRooms, roomRNumber, true ) then
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

function areaTag()
  return f "<deep_pink>{currentAreaName}<reset> [<violet_red>{currentAreaNumber}<reset>]"
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

function setMinimumRoomNumber( id )
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
  local cursor, err = conn:execute( f( "SELECT areaMinRoomRNumber FROM Area WHERE areaRNumber = {currentAreaNumber}" ) )
  if not cursor then
    gizErr( f( "Error fetching data: {err}" ) )
    return
  end
  local row = cursor:fetch( {}, "a" )
  if not row then
    gizErr( "Area not found." )
    return
  end
  local currentMinRoomNumber = tonumber( row.areaMinRoomRNumber )
  if currentMinRoomNumber == id then
    cecho( f "\nFirst room for {ac}{currentAreaNumber}<reset> already {nc}{id}<reset>" )
  else
    -- Update the minimum room number
    local update_stmt = f( "UPDATE Area SET areaMinRoomRNumber = {id} WHERE areaRNumber = {currentAreaNumber}" )
    local res, upd_err = conn:execute( update_stmt )
    if not res then
      gizErr( f( "Error updating data: {upd_err}" ) )
      return
    end
    cecho( f "\nUpdated first room for {ac}{currentAreaNumber}<reset> from {nc}{currentMinRoomNumber}<reset> to {nc}{id}<reset>" )
  end
  -- Clean up
  if cursor then cursor:close() end
  conn:close()
  env:close()
end
