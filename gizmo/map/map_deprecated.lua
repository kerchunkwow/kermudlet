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
  cecho( f "\nLoaded {doorCount} doors.\n" )
  saveTable( "doorData" )
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
