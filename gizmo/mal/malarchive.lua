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
