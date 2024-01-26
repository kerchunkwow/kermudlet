runLuaFile( "gizmo/map/map_const.lua" )
runLuaFile( "gizmo/map/map_ux.lua" )
runLuaFile( "gizmo/map/data/map_dirs.lua" )
runLuaFile( "gizmo/map/data/map_doors.lua" )
runLuaFile( "gizmo/map/data/map_unique.lua" )
runLuaFile( "gizmo/map/map_queue.lua" )
culledExits = {}
table.load( f '{homeDirectory}gizmo/map/data/culledExits.lua', culledExits )
defineCustomEnvColors()

-- Follow a list of directions; also used by the click-to-walk functionality from the Mapper
function doSpeedWalk()
  for _, dir in ipairs( speedWalkDir ) do
    if #dir > 1 then dir = SDIR[dir] end
    expandAlias( dir )
  end
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
    fullPathString = createWintin( fullPath )
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

-- Virtually traverse an exit from the players' current location to an adjoining room;
-- This is the primary function used to "follow" the PCs position in the Map; it is synchronized
-- with the MUD through the use of the mapQueue
function moveExit( direction )
  -- Make sure direction is long-version like 'north' to align with getRoomExits()
  local dir = LDIR[direction]
  local exits = getRoomExits( currentRoomNumber )

  if not exits[dir] then
    cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
    return false
  end
  local dst = tonumber( exits[dir] )
  if roomExists( dst ) then
    updatePlayerLocation( dst, direction )
    return true
  end
  cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
  return false
end

function updatePlayerLocation( id, dir )
  -- Store data about where we "came from" to get here
  if dir then
    lastDir = dir
  end
  setCurrentRoom( id )
  mX, mY, mZ = getRoomCoordinates( currentRoomNumber )
  centerview( currentRoomNumber )
end

function setCurrentRoom( id )
  local roomNumber = tonumber( id )
  local roomArea = getRoomArea( roomNumber )
  roomArea = tonumber( roomArea )
  -- If this is the first Area or the id is outside the current Area, update Area before Room
  if currentAreaNumber ~= roomArea then
    setCurrentArea( roomArea )
  end
  currentRoomNumber = roomNumber
  currentRoomName   = getRoomName( currentRoomNumber )
  roomExits         = getRoomExits( currentRoomNumber )
end

function setCurrentArea( id )
  -- If we're leaving an Area, store information and report on the transition
  if currentAreaNumber > 0 then
    lastAreaNumber = currentAreaNumber
    lastAreaName   = currentAreaName
  end
  currentAreaNumber = id
  currentAreaName   = getRoomAreaName( id )
  cecho( f "\n<dim_grey>  Entering {getAreaTag()}" )
  setMapZoom( 28 )
end

-- "Cull" or remove an exit from the map in the current room (useful for suppressing redundant exits, loops, etc.)
function cullExit( dir )
  -- If the direction is a single character, expand it to its long form
  if #dir == 1 and LDIR[dir] then
    dir = LDIR[dir]
  end
  cecho( f "\nCulling <cyan>{dir}<reset> exit from <dark_orange>{currentRoomNumber}<reset>" )
  culledExits[currentRoomNumber] = culledExits[currentRoomNumber] or {}
  setExit( currentRoomNumber, -1, dir )
  culledExits[currentRoomNumber][dir] = true
  table.save( 'gizmo/map/data/culledExits.lua', culledExits )
  updateMap()
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
