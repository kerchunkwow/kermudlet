walkedPath = {1121}

-- Function to walk the current room
function walkRoom()
  -- Add the current room to the walkedRooms table
  if currentRoomData and currentRoomData.roomRNumber then
    table.insert( walkedPath, currentRoomData.roomRNumber )
  end
end

-- Function to validate the walked path against the shortest path
function validateShortestPath()
  local shortPath = findShortestPath( 1121, currentRoomData.roomRNumber )

  -- Check if both paths are available
  if not shortPath or not walkedPath then
    gizErr( "Bad paths in validateShortestPath()." )
    return
  end
  -- Compare the length of both paths
  if #walkedPath ~= #shortPath then
    gizErr( "Paths differ in length." )
    return
  end
  -- Compare each room in both paths
  for i = 1, #walkedPath do
    if walkedPath[i] ~= shortPath[i] then
      gizErr( f "Paths differ at position {i}" )
      return
    end
  end
  -- If paths are the same
  local nc = MAP_COLOR["number"]
  cecho( f "\n<yellow_green>Matched<reset> with Length {nc}{#walkedPath}<reset>" )
end

-- Find the shortest path between two rooms anywhere in the MUD
function findShortestPath( srcRoom, dstRoom )
  if srcRoom == dstRoom then return {srcRoom} end
  -- Queues for a breadth-first-search (BFS)
  local visitedRooms = {}
  local pathQueue    = {{srcRoom}}

  -- Queues as long as we have paths left to check, pop one and follow it
  while #pathQueue > 0 do
    local path = table.remove( pathQueue, 1 )
    local lastRoom = path[#path]

    -- Don't visit visited rooms (on this path)
    if not visitedRooms[lastRoom] then
      visitedRooms[lastRoom] = true

      for _, areaData in pairs( worldData ) do
        local roomData = areaData.rooms[lastRoom]

        -- For the love of St. Christopher (patron saint of bachelors and travel), don't put DTs in your paths
        if roomData and not roomData.roomFlags:find( "DEATH" ) then
          for _, exit in pairs( roomData.exits ) do
            local nextRoom = exit.exitDest

            if nextRoom == dstRoom then
              local shortestPath = {}
              for _, room in ipairs( path ) do
                table.insert( shortestPath, room )
              end
              table.insert( shortestPath, nextRoom )
              return shortestPath
            end
            if not visitedRooms[nextRoom] then
              local newPath = {}
              for _, room in ipairs( path ) do
                table.insert( newPath, room )
              end
              table.insert( newPath, nextRoom )
              pathQueue[#pathQueue + 1] = newPath
            end
          end
        end
      end
    end
  end
  return nil -- Path not found
end

function displayAreaPaths()
  for areaNum, path in pairs( areaPaths ) do
    local readablePath = {}
    for _, area in ipairs( path ) do
      -- Assuming you have a way to get the name of an area by its number
      local areaName = worldData[area] and worldData[area].areaName or "Unknown Area"
      table.insert( readablePath, string.format( "%s (%d)", areaName, area ) )
    end
    local pathString = table.concat( readablePath, " -> " )
    mapInfo( string.format( "Path to %s: %s", worldData[areaNum].areaName, pathString ) )
  end
end

function findAreaPaths()
  local startArea = 21 -- Starting area number
  local visited = {}   -- Tracks visited areas
  areaPaths = {}       -- Stores paths to each area

  -- Initialize the BFS queue with the starting area
  local queue = {startArea}
  visited[startArea] = true
  areaPaths[startArea] = {startArea}

  while #queue > 0 do
    local currentArea = table.remove( queue, 1 ) -- Dequeue the first element

    -- Check border rooms for adjacent areas
    if borderRooms[currentArea] then
      for _, borderRoom in ipairs( borderRooms[currentArea] ) do
        local adjacentArea = borderRoom.borderAreaRNumber

        -- If the adjacent area is not visited, enqueue it and update the path
        if not visited[adjacentArea] then
          visited[adjacentArea] = true
          queue[#queue + 1] = adjacentArea

          -- Update the path to the adjacent area
          areaPaths[adjacentArea] = {unpack( areaPaths[currentArea] )}
          table.insert( areaPaths[adjacentArea], adjacentArea )
        end
      end
    end
  end
  displayAreaPaths( areaPaths )
  return areaPaths
end

-- Using findAreaBorderRooms, get a list of every Room in the World which borders an Area other than its own
function findAllBorders()
  for areaRNumber, _ in pairs( worldData ) do
    findAreaBorderRooms( areaRNumber )
  end
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

function updateUniqueRooms()
  -- Iterate over uniqueRooms
  for roomName, _ in pairs( uniqueRooms ) do
    -- Look for the room in worldData
    for _, areaData in pairs( worldData ) do
      for roomRNumber, roomData in pairs( areaData.rooms ) do
        if roomData.roomName == roomName then
          -- Update the value in uniqueRooms with the roomRNumber
          uniqueRooms[roomName] = roomRNumber
          break -- Exit the inner loop once the room is found
        end
      end
    end
  end
end
