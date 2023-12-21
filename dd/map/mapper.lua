deleteMap()
areaIDs = {}
loadAreaDB()

reverseDirs = {
  north = "south",
  south = "north",
  east = "west",
  west = "east",
  up = "down",
  down = "up"
}

exitMap = {
  n = 1,
  north = 1,
  e = 4,
  east = 4,
  w = 5,
  west = 5,
  s = 6,
  south = 6,
  u = 9,
  up = 9,
  d = 10,
  down = 10,
  [1] = "north",
  [4] = "east",
  [5] = "west",
  [6] = "south",
  [9] = "up",
  [10] = "down",
}

mX, mY, mZ = 0, 0, 0
currentRoom = -1

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
  local conn, cerr = env:connect( "C:\\Gizmo\\data\\gizdb.db" )

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
    setAreaUserData( areaID, "areaName", name )
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

function gotoArea( areaID )
  local dst = getAreaUserData( areaID, "firstRoom" )
  clearMapSelection()
  centerview( dst )
end

function statArea( areaID )
  stattingArea = areaID
  stattingStart = getAreaUserData( areaID, "vnumMin" )
  stattingEnd = getAreaUserData( areaID, "vnumLast" )
end
