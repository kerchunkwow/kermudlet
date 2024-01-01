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
  areaMinVNumber INTEGER; The logest value of roomVNumber for Rooms in the Area; usually the same room as areaMinRoomRNumber
  areaMaxVNumberActual INTEGER; The highest value for Rooms that actually exist in the Area
  areaMaxVNumberAllowed INTEGER; The highest value that a Room could theoretically have in the Area
  areaRoomCount INTEGER; How many Rooms are in the Area

  Room Table:
  roomName TEXT; The name of the Room in the MUD
  roomVNumberd INTEGER; The VNumber of the Room; an alternative identifier
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

-- Function to traverse a list of rooms and return the sequence of directions taken
function traverseRooms( roomList )
  -- Ensure the room list is provided and valid
  if not roomList or #roomList == 0 then
    cecho( "\nError: Invalid room list provided." )
    return
  end
  local directionsTaken = {} -- Store the sequence of directions taken

  -- Iterate through each room in the list, except for the last one
  for i = 1, #roomList - 1 do
    local currentRoom = roomList[i]
    local nextRoom = roomList[i + 1]

    -- Ensure currentRoomData is valid and corresponds to currentRoom
    if not currentRoomData or currentRoomData.roomRNumber ~= currentRoom then
      cecho( "\nError: Current room data is not synchronized." )
      return
    end
    -- Find the exit that leads to the next room
    local exitFound = false
    for _, exit in ipairs( currentRoomData.exits ) do
      if exit.exitDest == nextRoom then
        -- Move in the direction of the exit
        moveExit( exit.exitDirection )
        table.insert( directionsTaken, exit.exitDirection ) -- Record the direction taken
        exitFound = true
        break                                               -- Exit found, no need to continue checking
      end
    end
    -- If no exit was found to the next room, report an error
    if not exitFound then
      cecho( "\nError: No exit found leading to room " .. nextRoom )
      return
    end
    -- Optional: add a delay or some condition before moving to the next room
    -- tempTimer(1, function() end) -- Example delay of 1 second
  end
  return directionsTaken -- Return the list of directions taken
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
  cursor:close()
  conn:close()
  env:close()
  return areas
end

-- Get a list of all the Rooms in the current Area which border a different Area
function findAreaBorderRooms( areaRNumber )
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  local function closeResources()
    if cursor then cursor:close() end
    if conn then conn:close() end
    if env then env:close() end
  end

  -- Initialize borderRooms table if it doesn't exist
  borderRooms = borderRooms or {}

  -- Retrieve min and max room numbers and the name for the area
  local cursor = conn:execute( "SELECT areaMinRoomRNumber, areaMaxRoomRNumber FROM Area WHERE areaRNumber = " ..
    areaRNumber )
  local areaInfo = cursor:fetch( {}, "a" )
  if not areaInfo then
    echo( "Area not found.\n" )
    closeResources()
    return
  end
  local minRoomRNumber = areaInfo.areaMinRoomRNumber
  local maxRoomRNumber = areaInfo.areaMaxRoomRNumber
  cursor:close() -- Close the first cursor

  -- Query for exits that lead to the specified area but are in different areas
  cursor = conn:execute( [[
    SELECT DISTINCT Room.roomRNumber, Room.roomName, Room.areaRNumber, Area.areaName
    FROM Exit
    JOIN Room ON Exit.roomRNumber = Room.roomRNumber
    JOIN Area ON Room.areaRNumber = Area.areaRNumber
    WHERE Exit.exitDest BETWEEN ]] .. minRoomRNumber .. [[ AND ]] .. maxRoomRNumber .. [[
    AND (Room.roomRNumber < ]] .. minRoomRNumber .. [[ OR Room.roomRNumber > ]] .. maxRoomRNumber .. [[)
  ]] )

  local row = cursor:fetch( {}, "a" )
  if not row then
    borderRooms[areaRNumber] = nil
    closeResources()
    return
  end
  borderRooms[areaRNumber] = borderRooms[areaRNumber] or {}
  while row do
    if row.areaRNumber ~= areaRNumber then
      table.insert( borderRooms[areaRNumber], {
        roomRNumber = row.roomRNumber,
        roomName = row.roomName,
        borderAreaRNumber = row.areaRNumber,
        borderAreaName = row.areaName
      } )
    end
    row = cursor:fetch( {}, "a" )
  end
  -- Clean up
  closeResources()
end

-- Using findAreaBorderRooms, get a list of every Room in the World which borders an Area other than its own
function findAllBorders()
  for areaRNumber, _ in pairs( worldData ) do
    findAreaBorderRooms( areaRNumber )
  end
end

-- Find all exits where exitFlags ~= -1; i.e., Doors, Special Exits, etc.
function findSpecialExits()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  if not conn then
    gizErr( "Error connecting to the database." )
    return
  end
  local query = "SELECT * FROM Exit WHERE exitFlags != -1"
  local cursor, error = conn:execute( query )

  if not cursor then
    print( "Error executing query:", error )
    conn:close()
    env:close()
    return
  end
  local row = cursor:fetch( {}, "a" )
  while row do
    print( "Exit ID:", row.exitID, "Direction:", row.exitDirection, "Destination:", row.exitDest )
    row = cursor:fetch( row, "a" )
  end
  cursor:close()
  conn:close()
  env:close()
end
