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
