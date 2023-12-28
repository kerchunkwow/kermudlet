mX, mY, mZ  = 0, 0, 0
roomCoords  = {}
roomCount   = 0

reverseDirs = {
  north = "south",
  south = "north",
  east  = "west",
  west  = "east",
  up    = "down",
  down  = "up"
}

exitMap     = {
  n     = 1,
  north = 1,
  e     = 4,
  east  = 4,
  w     = 5,
  west  = 5,
  s     = 6,
  south = 6,
  u     = 9,
  up    = 9,
  d     = 10,
  down  = 10,
  [1]   = "north",
  [4]   = "east",
  [5]   = "west",
  [6]   = "south",
  [9]   = "up",
  [10]  = "down",
}

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
