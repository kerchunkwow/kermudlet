function newSandboxMap()
  -- Delete the map entirely while sandboxing
  deleteMap()

  -- Create a single area to sandbox in
  areaID = addAreaName( "Sandbox" )
  local roomID = createRoomID()

  addRoom( roomID )
  setRoomName( roomID, f "Room ({roomID})" )
  setRoomArea( roomID, areaID )
  setRoomCoordinates( roomID, mX, mY, mZ )
  centerview( roomID )
  currentRoom = getPlayerRoom()
end

function stepCoordinates( direction )
  if direction == "north" then
    mY = mY + 1
  elseif direction == "south" then
    mY = mY - 1
  elseif direction == "west" then
    mX = mX - 1
  elseif direction == "east" then
    mX = mX + 1
  elseif direction == "up" then
    mZ = mZ + 1
  elseif direction == "up" then
    mZ = mZ - 1
  end
end

function loadAreaDB()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn, cerr = env:connect( "C:\\Dev\\mud\\gizmo\\data\\gizdb.db" )

  if not conn then
    print( "Connection to database failed: " .. (cerr or "Unknown error") )
    return
  end
  local query = string.format( [[SELECT * FROM zone_list]] )
  local cur = conn:execute( query )
  local a = 1
  local row = cur:fetch( {}, "a" )

  row = cur:fetch( {}, "a" ) -- Skip the first row "Limbo"
  while row do
    -- Area name and R-Number (use this for Mudlet ID)
    local name, id = row.name, tonumber( row.rn )

    -- The range of V-Numbers (room IDs) in the area
    local vnumMin, vnumMax, vnumLast = tonumber( row.first_vn ), tonumber( row.max_vn ), tonumber( row.last_vn )

    -- How/when this area resets
    local resetType = row.reset

    -- The starting/first room of the area (not sure if this will be the actual "entrance")
    local firstID, firstName = row.first_rn, row.first_room

    -- Create the area and hang on to its ID in a list
    local areaID = addAreaName( name )
    areaIDs[a] = areaID
    setAreaUserData( areaID, "vnumMax", vnumMax )
    setAreaUserData( areaID, "vnumMin", vnumMin )
    setAreaUserData( areaID, "vnumLast", vnumLast )
    setAreaUserData( areaID, "resetType", resetType )
    setAreaUserData( areaID, "firstRoom", firstID )

    -- Create this area's "zero room" and set its coordinates
    addRoom( firstID )
    setRoomName( firstID, f "{firstName}" )
    setRoomArea( firstID, areaID )
    setRoomCoordinates( firstID, 0, 0, 0 )

    a = a + 1
    row = cur:fetch( {}, "a" )
  end
  -- Cleanup
  conn:close()
  env:close()
end

function simRoomData()
  local file = io.open( 'C:/Dev/mud/gizmo/data/areas/gizmo_rooms.txt', "r" )
  for line in file:lines() do
    local feedDelay = lineCount * feedRate
    tempTimer( feedDelay, f [[cfeedTriggers(]] .. line .. [[)]] )
    lineCount = lineCount + 1
  end
  cecho( f "\n<dodger_blue>Lines parsed<reset>: <dark_orange>{lineCount}<reset> in <yellow_green>simRoomData<reset>()" )
  cecho( "\n<dodger_blue>Rooms parsed: <dark_orange>" .. roomCount .. "<reset>" )
  file:close()
end

function linkRooms( fromRoom, toRoom, direction )
  setExit( fromRoom, toRoom, direction )
  setExit( toRoom, fromRoom, reverseDirs[direction] )
end

function gotoArea( areaID )
  local dst = getAreaUserData( areaID, "firstRoom" )
  centerview( dst )
end

function statArea( areaID )
  stattingArea = areaID
  stattingStart = getAreaUserData( areaID, "vnumMin" )
  stattingEnd = getAreaUserData( areaID, "vnumLast" )
end

local mstr = ec( 'Lines parsed', 'dbg' )
local vstr = ec( lineCount, 'val' )
local fstr = ec( 'simRoomData', 'func' )
cecho( f "{mstr}: {vstr} in {fstr}" )
function sanitizeDescriptions()
  local file = io.open( 'C:/Dev/mud/gizmo/data/areas/gizmo_rooms.txt', "r" )
  local content = file:read( "*a" )
  file:close()

  content = content:gsub( "^roomDescription:(.*(?:\n(?!roomExtraKeyword:).*)*)", function ( description )
    description = description:gsub( "\n", " " )  -- Replace newlines with single space
    description = description:gsub( "%s+", " " ) -- Replace multiple spaces with single space
    description = description:gsub( "\t", " " )  -- Replace tabs with single space
    return "roomDescription: " .. trim( description )
  end )

  local outputFile = io.open( 'C:/Dev/mud/gizmo/data/areas/gizmo_rooms_sanitized.txt', "w" )
  outputFile:write( content )
  outputFile:close()
end

function createNewArea( areaID )
  -- Instantiate the Area with data from the rawAreaData table
  local areaData = rawAreaData[areaID]
  if not areaData then
    local errs = ec( 'Area data not found', 'err' )
    local vals = ec( areaID, "val" )
    cecho( f "\n{errs} for ID #{vals}" )
    return false
  else
    local istr = ec( 'New Area', 'info' )
    local vstr = ec( areaID, "val" )
    cecho( f "\n{istr}: {vstr}, <dodger_blue>{areaData.areaName}<reset>" )
  end
  areaList[areaID] = {
    areaName           = areaData.areaName,
    areaRNumber        = areaID,
    areaResetType      = areaData.areaResetType,
    areaRNumberMinimum = areaData.areaFirstRoomRNumber,
    areaRNumberMaximum = -1,
    areaVNumberMinimum = areaData.areaMinVNumber,
    areaVNumberMaximum = areaData.areaLastVNumber,
    areaRoomCount      = 0,
    roomList           = {}
  }
  return true
end

function processLine( line )
  cfeedTriggers( line )
end

-- Quickly output the file contents as MUD output so we can use Mudlet triggers to parse it
-- Uses a coroutine and rate limiter to avoid overloading Mudlets output buffer or trigger queue
function simRoomData()
  local file = io.open( 'C:/Dev/mud/gizmo/data/areas/gizmo_rooms.txt', "r" )
  local lineRate = 0.009
  local lineCount, roomCount = 0, 0

  local co = coroutine.create( function ()
    for line in file:lines() do
      coroutine.yield( line )
    end
    file:close()
  end )

  local function handleLine()
    local status, line = coroutine.resume( co )
    if status and line then
      processLine( line )
      lineCount = lineCount + 1
      tempTimer( lineRate, handleLine )
    else
      cecho( "\n{dbgc('Lines')}: {numc(lineCount)}" )
      cecho( "\n{dbgc('Rooms')}: {numc(roomCount)}" )
    end
  end

  handleLine()
end

function parsedNewRoom()
  insertRoom( roomName, roomAreaNumber, roomVNumber, roomRNumber, roomType, roomSpec, roomFlags, roomDescription,
    roomExtraKeyword )
  roomName         = nil
  roomAreaNumber   = nil
  roomVNumber      = nil
  roomRNumber      = nil
  roomType         = nil
  roomSpec         = nil
  roomFlags        = nil
  roomDescription  = ""
  roomExtraKeyword = nil
end

function fetchRawAreaData()
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizdb.db' )
  if not conn then
    local errs, funcs = ec( 'DB connect failed', 'err' ), ec( 'fetchRawAreaData', 'func' )
    cecho( f "\n{errs} in {funcs}" )
    return
  end
  local cursor, errorString = conn:execute(
    "SELECT name, rn, reset, first_rn, max_vn, first_room, first_vn, last_vn, room_cnt FROM zone_list" )
  if not cursor then
    local errs, fucns = ec( 'SELECT failed', 'err' ), ec( 'fetchRawAreaData', 'func' )
    cecho( f "\n{errs} in {funcs}" )
    return
  end
  local row = cursor:fetch( {}, "a" )
  while row do
    rawAreaData[row.rn] = {
      areaName = row.name,
      areaRNumber = row.rn,
      areaMaxVNumber = row.max_vn,
      areaResetType = row.reset,
      areaFirstRoomName = row.first_room,
      areaFirstRoomRNumber = row.first_rn,
      areaMinVNumber = row.first_vn,
      areaLastVNumber = row.last_vn,
      areaRoomCount = row.room_cnt
    }
    row = cursor:fetch( row, "a" )
  end
  cursor:close()
  conn:close()
  env:close()
end

function insertRoom( roomName, roomAreaNumber, roomVNumber, roomRNumber, roomType, roomSpec, roomFlags, roomDescription,
                     roomExtraKeyword )
  -- If the area this room is in doesn't exist yet, create it
  if not areaList[roomAreaNumber] then
    createNewArea( roomAreaNumber )
  end
  local istr = ec( 'New Room', 'info' )
  local vstr1 = ec( roomRNumber, 'val' )
  local vstr2 = ec( roomAreaNumber, 'val' )
  local areaName = areaList[roomAreaNumber].areaName
  local vstr3 = ec( areaName, 'info' )
  cecho( f "\n{istr}: Parsed room {vstr1} in area {vstr2}, {vstr3}" )
  local newRoom = {
    roomName         = roomName,
    roomAreaNumber   = roomAreaNumber,
    roomRNumber      = roomRNumber,
    roomType         = roomType,
    roomSpec         = roomSpec or false,
    roomFlags        = roomFlags,
    roomDescription  = roomDescription,
    roomExtraKeyword = roomExtraKeyword,
    --roomContents     = roomContents or {},
    --roomIsPortal     = roomIsPortal or false,
    exitList         = {}
  }

  -- Check if a room with the same RNumber or VNumber already exists in the roomList of the area
  for _, room in ipairs( areaList[roomAreaNumber].roomList or {} ) do
    if room.roomRNumber == roomRNumber or room.roomVNumber == roomVNumber then
      local errs = ec( 'Duplicate room', 'err' )
      local vstr1 = ec( roomRNumber, 'val' )
      local vstr2 = ec( roomAreaNumber, 'val' )
      cecho( f "\n{errs} for #{vstr1} in area #{vstr2}" )
      return
    end
  end
  -- New unique room; insert it
  table.insert( areaList[roomAreaNumber].roomList, newRoom )

  -- Increment the room count for the area
  areaList[roomAreaNumber].areaRoomCount = areaList[roomAreaNumber].areaRoomCount + 1

  -- Update the area's maximum room RNumber if necessary
  if roomRNumber > (areaList[roomAreaNumber].areaRNumberMaximum or 0) then
    areaList[roomAreaNumber].areaRNumberMaximum = roomRNumber
  end
end

function printArea( areaNumber )
  -- Convert areaNumber to an integer
  areaNumber = tonumber( areaNumber )

  -- Load the area data from the specific JSON file
  local file = io.open( 'C:/Dev/mud/mudlet/gizmo/mal/areadata/' .. areaNumber .. '.json', 'r' )
  if not file then
    cecho( "\nNo area found with Area Number " .. areaNumber )
    return
  end
  local area_data = file:read( "*all" )
  file:close()

  local area = json.decode( area_data )

  -- Print the area data
  for _, room in ipairs( area["areaRooms"] ) do
    cecho( "\n<reset>Room Name: <dodger_blue>" .. room.roomName )
    cecho( "\n<reset>Room Area Number: <dark_orange>" .. room.roomAreaNumber )
    cecho( "\n<reset>Room VNumber:  <dark_orange>" .. room.roomVNumber )
    cecho( "\n<reset>Room RNumber:  <dark_orange>" .. room.roomRNumber )
    cecho( "\n<reset>Room Type: <gold>" .. room.roomType )
    cecho( "\n<reset>Room Spec: <blue_violet>" .. room.roomSpec )
    cecho( "\n<reset>Room Flags: <dark_orange>" .. room.roomFlags )
    cecho( "\n<reset>Room Description: <olive_drab>" .. room.roomDescription )
    cecho( "\n<reset>Room Extra Keyword: <gold>" .. room.roomExtraKeyword )
  end
end

function printMaxRoomNumber()
  local maxRNumber = -1
  for _, room in pairs( areaData["areaRooms"] ) do
    if room["roomRNumber"] > maxRNumber then
      maxRNumber = room["roomRNumber"]
    end
  end
  print( "Area " .. currentAreaNumber .. " max roomRNumber: " .. maxRNumber )
end

function printAllMaxRoomNumbers()
  currentAreaNumber = 0
  while true do
    if currentAreaNumber == 107 then
      currentAreaNumber = 108
    end
    areaData = loadAreaData( currentAreaNumber )
    if areaData then
      printMaxRoomNumber()
      currentAreaNumber = currentAreaNumber + 1
    else
      break
    end
  end
end

-- Load area data for a single area
function loadAreaData( areaRNumber )
  areaData = {}
  currentAreaNumber = areaRNumber
  local file = io.open( dataFile, 'r' )
  if not file then
    print( "Could not open dataFile" )
    return nil
  end
  local content = file:read( "*all" )
  file:close()

  local data, pos, err = dkjson.decode( content, 1, nil )
  if err then
    print( "Error:", err )
    return nil
  end
  local area = data[tostring( areaRNumber )]
  if not area then
    print( "Area not found with Area Number " .. areaRNumber )
    return nil
  end
  local rooms = {}
  for _, room in ipairs( area["areaRooms"] ) do
    local roomRNumber = room["roomRNumber"]
    rooms[roomRNumber] = room
    local exits = {}
    if room["roomExits"] then
      for _, exit in ipairs( room["roomExits"] ) do
        local exitDirection = DIRECTIONS[exit["exitDirection"]]
        if exitDirection then
          exits[exitDirection] = exit
        else
          print( "Invalid exit direction:", exit["exitDirection"] )
        end
      end
    end
    room["roomExits"] = exits
  end
  area["areaRooms"] = rooms

  return area
end

-- Use loadAreaData() to load all areas
function loadAllAreas()
  local areaData = {}
  local file = io.open( dataFile, 'r' )
  if not file then
    print( "Could not open file gizmo_world.json" )
    return areaData
  end
  local content = file:read( "*all" )
  file:close()

  local data, pos, err = dkjson.decode( content, 1, nil )
  if err then
    print( "Error:", err )
    return areaData
  end
  for areaRNumber, _ in pairs( data ) do
    local area = loadAreaData( areaRNumber )
    if area then
      areaData[tonumber( areaRNumber )] = area
    end
  end
  return areaData
end

function createAreas()
  cecho( "\n<blue>Starting to create areas...<reset>" )
  local areaNumber = 0

  while true do
    local file = io.open( 'C:/Dev/mud/mudlet/gizmo/mal/areadata/' .. areaNumber .. '.json', 'r' )
    if file then
      cecho( "\n<dodger_blue>Creating area for file: " .. areaNumber .. ".json<reset>" )
      createArea( areaNumber )
      file:close()
      areaNumber = areaNumber + 1
      if areaNumber == 107 then areaNumber = 108 elseif areaNumber == 129 then areaNumber = 130 end
    else
      break
    end
  end
  createRooms()
end

function createRooms()
  cecho( "\n<blue>Starting to create rooms for all areas...<reset>" )
  local areaNumber = 0
  while true do
    local file = io.open( 'C:/Dev/mud/mudlet/gizmo/mal/areadata/' .. areaNumber .. '.json', 'r' )
    if file then
      cecho( "\n<dodger_blue>Creating rooms for area: " .. areaNumber .. "<reset>" )
      local area_data = file:read( "*all" )
      file:close()
      local area = json.decode( area_data )
      local areaName = area["areaName"]
      local areaID = getAreaTable()[areaName]
      if area["areaRooms"] then
        for _, room in ipairs( area["areaRooms"] ) do
          createRoom( room, areaID, areaName )
        end
      else
        cecho( "\n<red>No rooms found in area: " .. areaNumber .. "<reset>" )
      end
      areaNumber = areaNumber + 1
      if areaNumber == 107 then areaNumber = 108 elseif areaNumber == 129 then areaNumber = 130 end
    else
      break
    end
  end
  setRoomExitsAndCoordinates()
end

function setRoomExitsAndCoordinates()
  cecho( "\n<blue>Setting room exits and coordinates...<reset>" )
  local areaNumber = 0
  while true do
    local file = io.open( 'C:/Dev/mud/mudlet/gizmo/mal/areadata/' .. areaNumber .. '.json', 'r' )
    if file then
      cecho( "\n<dodger_blue>Setting exits and coordinates for area: " .. areaNumber .. "<reset>" )
      local area_data = file:read( "*all" )
      file:close()
      local area = json.decode( area_data )
      if area["areaRooms"] then
        for _, room in ipairs( area["areaRooms"] ) do
          setRoomExitsAndCoordinatesForRoom( room )
        end
      else
        cecho( "\n<red>No rooms found in area: " .. areaNumber .. "<reset>" )
      end
      areaNumber = areaNumber + 1
      if areaNumber == 107 then areaNumber = 108 elseif areaNumber == 129 then areaNumber = 130 end
    else
      break
    end
  end
end

function setRoomExitsAndCoordinatesForRoom( room )
  local roomRNumber = room["roomRNumber"]
  if room["exits"] then
    for _, exit in ipairs( room["exits"] ) do
      local direction = string.lower( exit["exitDirection"] )
      local exitDest = exit["exitDest"]
      setExit( roomRNumber, exitDest, direction )
      if direction == "north" then
        mY = mY + 1
      elseif direction == "south" then
        mY = mY - 1
      elseif direction == "east" then
        mX = mX + 1
      elseif direction == "west" then
        mX = mX - 1
      elseif direction == "up" then
        mZ = mZ + 1
      elseif direction == "down" then
        mZ = mZ - 1
      end
      setRoomCoordinates( roomRNumber, mX, mY, mZ )
    end
  end
end

ROOM_STYLES = {
  ['DEATH']     = {color = {0, 0, 0, 0}, char = "💀"},
  ['MANA']      = {color = {0, 0, 0, 0}, char = "⚡"},
  ['BOSS']      = {color = {0, 0, 0, 0}, char = "👿"},
  ["Inside"]    = {color = {0, 0, 0, 0}, char = nil},
  ["Forest"]    = {color = {0, 0, 0, 0}, char = nil},
  ["Mountains"] = {color = {0, 0, 0, 0}, char = nil},
  ["City"]      = {color = {0, 0, 0, 0}, char = nil},
  ["Water"]     = {color = {0, 0, 0, 0}, char = nil},
}
-- Given a room number, decide what color the exit should be based on room attributes
function exitColor( roomRNumber )
  if roomRNumber > currentMaxRnum or roomRNumber < currentMinRnum then
    return MAP_COLOR["area"]
  else
    local dstData = areaData["areaRooms"][roomRNumber]
    local dstFlags = split( dstData["roomFlags"], " " )
    if isIn( dstFlags, "DEATH" ) then
      return MAP_COLOR["death"]
    else
      return MAP_COLOR["number"]
    end
  end
end

-- Print the content of the currentRoom w/ highlighting similar to MUD output
function printRoom()
  local areaNumber  = currentRoom["roomAreaNumber"]
  local description = currentRoom["roomDescription"]
  local roomNum     = currentRoom["roomRNumber"]
  local name        = currentRoom["roomName"]
  local type        = currentRoom["roomType"]

  local rn          = MAP_COLOR["roomName"]
  local rd          = MAP_COLOR["roomDesc"]
  local nc          = MAP_COLOR["number"]
  local tc          = MAP_COLOR[type]
  local uc          = MAP_COLOR["mapui"]

  cecho( f "\n\n{rn}{roomName}<reset> [{tc}{roomType}<reset>] ({nc}{roomRNumber}<reset>) ({uc}{mX}<reset>, {uc}{mY}<reset>, {uc}{mZ}<reset>)" )
  cecho( f "\n{rd}{roomDescription}<reset>" )
  printExits( roomNum )

  if currentRoom["deathTrap"] then
    cecho( f "\n\nThis is a {MAP_COLOR['death']}Death Trap<reset>; good thing this is all a dream." )
  end
  -- A little padding
  print( "\n" )
end

-- Load the new area from cache or JSON
function loadAreaData( areaRNumber )
  -- If the destination area has been cached, load it from cache
  if areaDataCache[areaRNumber] then
    cecho( f "\nLoading area {MAP_COLOR['area']}{areaRNumber}<reset> from cache..." )
    areaData = areaDataCache[areaRNumber]
    return
  end
  -- Update currentAreaNumber to the destination area
  currentAreaNumber = areaRNumber

  -- Clear the primary areaData and load the new area from JSON
  areaData = {}

  local file = io.open( dataFile, 'r' )
  local content = file:read( "*all" )
  file:close()

  local data, pos, err = dkjson.decode( content, 1, nil )
  if err then
    gizErr( f "Error decoding JSON: {err}" )
    return nil
  end
  areaData = data[tostring( areaRNumber )]
  if not areaData then
    gizErr( f "Invalid area number: {areaRNumber}" )
    return nil
  end
  local rooms = {}
  for _, room in pairs( areaData["areaRooms"] ) do
    local roomRNumber = room["roomRNumber"]
    rooms[roomRNumber] = room
    local exits = {}
    if room["roomExits"] then
      for _, exit in pairs( room["roomExits"] ) do
        local exitDirection = DIRECTIONS[exit["exitDirection"]]
        if exitDirection then
          exits[exitDirection] = exit
        else
          gizErr( f "Invalid exit direction in room {roomRNumber}" )
        end
      end
    end
    room["roomExits"] = exits
  end
  areaData["areaRooms"]            = rooms
  currentAreaRNumber               = areaData["areaRNumber"]
  currentMaxRnum                   = areaData["areaMaxRoomRNumber"]
  currentMinRnum                   = areaData["areaMinRoomRNumber"]
  currentAreaName                  = areaData["areaName"]
  mX, mY, mZ                       = 0, 0, 0

  -- Cache the newly loaded area
  areaDataCache[currentAreaNumber] = areaData
end

function displayAllBorders()
  for _, area in pairs( worldData ) do
    findAreaBorderRooms( area.areaRNumber )
  end
end

function findAreaBorderRooms( areaRNumber )
  local ac = MAP_COLOR["area"]
  local nc = MAP_COLOR["number"]
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  local function closeResources()
    if cursor then cursor:close() end
    if conn then conn:close() end
    if env then env:close() end
  end

  -- Retrieve min and max room numbers and the name for the area
  local cursor = conn:execute( "SELECT areaMinRoomRNumber, areaMaxRoomRNumber, areaName FROM Area WHERE areaRNumber = " ..
    areaRNumber )
  local areaInfo = cursor:fetch( {}, "a" )
  if not areaInfo then
    echo( "Area not found.\n" )
    closeResources()
    return
  end
  local minRoomRNumber = areaInfo.areaMinRoomRNumber
  local maxRoomRNumber = areaInfo.areaMaxRoomRNumber
  local areaName = areaInfo.areaName
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
    mapInfo( f "\nNo rooms bordering {ac}{areaName}<reset> [{nc}{areaRNumber}<reset>]" )
    closeResources()
    return
  end
  mapInfo( f "\nRooms bordering {ac}{areaName}<reset> [{nc}{areaRNumber}<reset>]" )
  while row do
    if row.areaRNumber ~= areaRNumber then
      mapInfo( f "- <olive_drab>{row.roomName}<reset> ({nc}{row.roomRNumber}<reset>) in {ac}{row.areaName}<reset> [{nc}{row.areaRNumber}<reset>]" )
    end
    row = cursor:fetch( {}, "a" )
  end
  -- Clean up
  closeResources()
end

function findShortestPath( startRoom, targetRoom )
  if startRoom == targetRoom then return {startRoom} end
  -- Initialize queues for a breadth-first-search of rooms
  local visitedRooms = {}            -- Tracks visited rooms
  local pathQueue    = {{startRoom}} -- Initialize queue for BFS with the starting room

  -- As long as paths are queued, "pop" one and follow it until we've visisted its last room
  while #pathQueue > 0 do
    local path = table.remove( pathQueue, 1 )
    local lastRoom = path[#path]

    -- Don't visit visited rooms
    if not visitedRooms[lastRoom] then
      visitedRooms[lastRoom] = true

      -- For all Areas and Rooms
      for _, areaData in pairs( worldData ) do
        local roomData = areaData.rooms[lastRoom]
        if roomData then
          -- Iterate through exits of the current room
          for _, exit in pairs( roomData.exits ) do
            local nextRoom = exit.exitDest

            -- Target spotted; return this path
            if nextRoom == targetRoom then
              local shortestPath = {unpack( path )}
              table.insert( shortestPath, nextRoom )
              return shortestPath
            end
            -- Add the next room to the path if it hasn't been visited
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
  -- Failed to find a path
  return nil
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

roomCoords = nil
roomCount  = nil


function createRoom( room, areaID, areaName )
  -- Create the room
  local roomRNumber = room["roomRNumber"]
  addRoom( roomRNumber )

  -- Assign the room to the area
  setRoomArea( roomRNumber, areaName )

  -- Set the room name
  setRoomName( roomRNumber, room["roomName"] )

  -- Store the extra room data
  setRoomUserData( roomRNumber, "roomVNumber", tostring( room["roomVNumber"] ) )
  setRoomUserData( roomRNumber, "roomType", tostring( room["roomType"] ) )
  setRoomUserData( roomRNumber, "roomSpec", tostring( room["roomSpec"] ) )
  setRoomUserData( roomRNumber, "roomFlags", tostring( room["roomFlags"] ) )
  setRoomUserData( roomRNumber, "roomDescription", room["roomDescription"] )
  setRoomUserData( roomRNumber, "roomExtraKeyword", room["roomExtraKeyword"] )
  roomCount = roomCount + 1
end

function createArea( areaNumber )
  cecho( "\n<dodger_blue>Creating area with number: " .. areaNumber .. "<reset>" )
  -- Load the area data from the specific JSON file
  local file = io.open( 'C:/Dev/mud/mudlet/gizmo/mal/areadata/' .. areaNumber .. '.json', 'r' )
  if not file then
    echo( "\nNo area found with Area Number " .. areaNumber )
    return
  end
  local area_data = file:read( "*all" )
  file:close()

  local area = json.decode( area_data )

  -- Create the area
  local areaID = addAreaName( area["areaName"] )
  if not areaID then
    echo( "\nFailed to create area with name " .. area["areaName"] )
    return
  end
  -- Store the real area ID
  setAreaUserData( areaID, "areaRNumber", tostring( area["areaRNumber"] ) )
  cecho( "\n<olive_drab>Successfully created area with name " ..
    area["areaName"] .. " and ID " .. area["areaRNumber"] .. ".<reset>" )
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
