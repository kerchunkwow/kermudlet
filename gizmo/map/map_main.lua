function doSpeedWalk()
  iout( "Someone called <cyan>doSpeedWalk<medium_orchid>()<reset>" )
end

-- Get a complete Wintin-compatible path between two rooms including door commands
-- [TODO] Translating this to a Wintin-string is really only for convenience of output/sharing;
-- for efficiency we should just use a list of raw commands for the core functionality
function getFullDirs( srcID, dstID )
  -- Clear Mudlet's pathing globals
  speedWalkDir = nil
  speedWalkPath = nil

  -- Use Mudlet's built-in path finding to get the initial path
  local rm = srcID
  if getPath( srcID, dstID ) then
    -- Initialize a table to hold the full path
    local fullPathString1, fullPathString2 = "", ""
    local fullPath = {}
    for d = 1, #speedWalkDir do
      local dir = LDIR[tostring( speedWalkDir[d] )]
      local doors = getDoors( rm )
      if doors[dir] and doorData[rm] and doorData[rm][dir] then
        local doorInfo = doorData[rm][dir]
        -- If the door has a key associated with it; insert an unlock command into the path
        if doorInfo.exitKEy and doorInfo.exitKey > 0 then
          table.insert( fullPath, "unlock " .. doorInfo.exitKeyword )
        end
        -- All doors regardless of locked state need opening
        table.insert( fullPath, "open " .. doorInfo.exitKeyword )
        table.insert( fullPath, dir )
        -- Close doors behind us to minimize wandering mobs
        table.insert( fullPath, "close " .. doorInfo.exitKeyword )
      else
        -- With no door, just add the original direction
        table.insert( fullPath, dir )
      end
      -- "Step" to the next room along the path
      rm = tonumber( speedWalkPath[d] )
    end
    -- Convert the path to a Wintin-compatible command string
    fullPathString = createWintinString( fullPath )
    return fullPathString
  end
  cecho( f "\n<firebrick>Failed to find a path between {srcID} and {dstID}<reset>" )
  return nil
end

-- "Look" at an exit to get additional information about its status and the destination room
function inspectExit( id, direction )
  local dir = LDIR[direction]
  local exits = getRoomExits( id )
  if exits[dir] then
    local dstRoomString = getRoomString( exits[dir], 1 )
    local doorString = nil
    doorString = ""
    local word, key = nil, nil
    if doorData[id] and doorData[id][dir] then
      doorString = getDoorString( doorData[id][dir].exitKeyword, doorData[id][dir].exitKey )
    end
    cecho( f "\n<dim_grey>Looking <dark_slate_grey>{dir}<reset>{doorString} <dim_grey>you see<reset> {dstRoomString}" )
  else
    cecho( f "\n<dim_grey>Looking <dark_slate_grey>{dir}<dim_grey> you see why you didn't do well in geography class" )
  end
end

function setPlayerRoom( id )
  local resynch = false
  if not CurrentRoomNumber or CurrentRoomNumber <= 0 then
    resynch = true
  end
  local newRoomNumber = tonumber( id )
  -- Ignore attempts to move to the room we're already in
  if newRoomNumber == CurrentRoomNumber or not id then return end
  if roomExists( id ) then
    local roomArea = getRoomArea( id )
    if roomArea ~= CurrentAreaNumber then
      CurrentAreaNumber = roomArea
      CurrentAreaName   = getRoomAreaName( CurrentAreaNumber )
      cecho( f "\n<dim_grey>  Entering {getAreaTag()}" )
      loadAreaMobs( CurrentAreaNumber )
      loadMobTriggers()
      setMapZoom( 28 )
    end
    CurrentRoomNumber = id
    CurrentRoomName   = getRoomName( CurrentRoomNumber )
    roomExits         = getRoomExits( CurrentRoomNumber )
    centerview( CurrentRoomNumber )
    -- If we're currently searching rooms, remove the room we just entered from the result set (if it exists there)
    if #FoundRooms > 0 then removeFoundRoom( CurrentRoomNumber ) end
    -- For now, report when the map needs to be resynchronized just so we can keep an eye on how often it's necessary
    if SESSION == 1 and resynch then
      cecho( "info", f "\nMap synchronized at {getRoomString( CurrentRoomNumber, 2 )}" )
    end
  end
end

-- "Cull" or remove an exit from the map in the current room (useful for suppressing redundant exits, loops, etc.)
function cullExit( dir )
  -- If the direction is a single character, expand it to its long form
  if #dir == 1 and LDIR[dir] then
    dir = LDIR[dir]
  end
  cecho( f "\nCulling <cyan>{dir}<reset> exit from <dark_orange>{CurrentRoomNumber}<reset>" )
  culledExits[CurrentRoomNumber] = culledExits[CurrentRoomNumber] or {}
  setExit( CurrentRoomNumber, -1, dir )
  culledExits[CurrentRoomNumber][dir] = true
  table.save( 'gizmo/map/data/culledExits.lua', culledExits )
  updateMap()
end

-- Given the V-Number of a room, return it's R-Number
function getRoomRbyV( vNumber )
  local roomData    = searchRoomUserData( "roomVNumber", vNumber )
  local roomRNumber = roomData and roomData[1] or nil
  return roomRNumber
end

-- Find Rooms whose names are duplicated but are unique within an Area (i.e., 'area-unique')
local function getAreaUniques()
  local areaUniques = 0
  local allRooms = getRooms()
  -- Keep track of rooms that have already been identified as area-unique
  local uniqueRoomTracker = {}

  for id, name in pairs( allRooms ) do
    local roomName = getRoomName( id )

    -- Only check rooms that haven't already been identified as area-unique
    if uniqueRoomTracker[roomName] == nil then
      if not isUnique( roomName ) then
        -- searchRooms() returns a table of all rooms with the same name
        local dupeRooms = searchRoom( roomName )
        local areaUnique = true
        local dupeArea = nil
        -- Check each Room in this table to see if any are in a different Area
        for dupeID, _ in pairs( dupeRooms ) do
          local nextDupeArea = getRoomArea( dupeID )
          if not dupeArea then
            dupeArea = nextDupeArea
          elseif dupeArea ~= nextDupeArea then
            areaUnique = false
            break
          end
        end
        -- If areaUnique is still true; all Rooms were in the same Area
        if areaUnique then
          areaUniques = areaUniques + 1
          uniqueRoomTracker[roomName] = dupeArea
          local uniqueAreaName = getRoomAreaName( dupeArea )
          cecho( f "\n<royal_blue>{roomName}<reset> is unique within area <maroon>{uniqueAreaName}<reset>" )
        else
          uniqueRoomTracker[roomName] = false -- Mark as non-unique
        end
      end
    elseif uniqueRoomTracker[roomName] ~= false then
      -- Room is already confirmed unique, increment counter
      areaUniques = areaUniques + 1
    end
  end
  cecho( f "\n<dark_orange>{areaUniques}<reset> rooms are unique to a single area." )
end

function setSafeRoomCharacters()
  clearUserWindow( "info" )
  local allRooms = getRooms()
  for id, name in pairs( allRooms ) do
    local roomFlags = getRoomUserData( id, "roomFlags" )
    if roomFlags then
      --local noMob = string.find( roomFlags, "NO_MOB" )
      local safe = string.find( roomFlags, "SAFE" )
      --local safeRoom = noMob or safe
      if safe then
        local char = getRoomChar( id )
        --if char and #char > 0 and char ~= "" and char ~= " " then
        if char == "" or char == " " or char == "🅿️" then
          setRoomChar( id, "🌈" )
        end
      end
    end
  end
end

function checkChests( n )
  for i = 1, n do
    send( f [[unlock {i}.chest]] )
    send( f [[open {i}.chest]] )
    send( f [[get all {i}.chest]] )
    send( f [[close {i}.chest]] )
    send( f [[lock {i}.chest]] )
  end
end
