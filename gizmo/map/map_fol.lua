roomToAreaMap = {}
worldData = {}
currentAreaData = {}
currentRoomData = {}
currentAreaNumber = -1
currentAreaName = ""
currentRoomNumber = -1
currentRoomName = ""
roomExits = {}

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

function setCurrentArea( id )
  currentAreaData   = worldData[id]
  currentAreaNumber = tonumber( currentAreaData.areaRNumber )
  currentAreaName   = tostring( currentAreaData.areaName )
end

function setCurrentRoom( id )
  -- If this is the first Area or the id is outside the current Area, update Area before Room
  if currentAreaNumber < 0 or not currentAreaData.rooms[id] then
    setCurrentArea( roomToAreaMap[id] )
  end
  currentRoomData   = currentAreaData.rooms[id]
  currentRoomNumber = currentRoomData.roomRNumber
  currentRoomName   = currentRoomData.roomName
  roomExits         = getRoomExits( currentRoomNumber )
end

function updatePlayerLocation( roomRNumber )
  setCurrentRoom( roomRNumber )
  centerview( currentRoomNumber )
end

worldData = loadFollowData()
