function doSpeedWalk()
  iout( "Someone called <cyan>doSpeedWalk<medium_orchid>()<reset>" )
end

function setRoomOnClick()
  local dst = getMapSelection()["rooms"][1]
  iout( "Player Location Set: {NC}{dst}{RC}" )
  setPlayerRoom( dst )
end

function showMobOnClick()
  local id = getMapSelection()["rooms"][1]
  displayMobsByRoom( id )
end

function showRoomOnClick()
  local id = getMapSelection()["rooms"][1]
  displayRoom( id )
end

function registerMapEvents()
  registerAnonymousEventHandler( "setRoomOnClick", "setRoomOnClick" )
  registerAnonymousEventHandler( "showMobOnClick", "showMobOnClick" )
  registerAnonymousEventHandler( "showRoomOnClick", "showRoomOnClick" )
  addMapEvent( "Set Current Room", "setRoomOnClick" )
  addMapEvent( "Show Mobs", "showMobOnClick" )
  addMapEvent( "Show Room", "showRoomOnClick" )
end

function displayRoom( id )
  local name       = getRoomName( id )
  local desc       = getRoomUserData( id, "roomDescription" )
  local flags      = getRoomUserData( id, "roomFlags" )
  local spec       = getRoomUserData( id, "roomSpec" )
  local type       = getRoomUserData( id, "roomType" )

  -- Use a special character to denote when a room has a procedure
  spec             = spec == "1" and "ƒ" or ""

  -- Format the room description as it might appear in the MUD
  desc             = formatRoomDescription( desc )

  -- Update each attribute with colorization tags
  local nc         = MAP_COLOR["roomName"] or "<dim_grey>"
  local tc         = MAP_COLOR[type] or "<dim_grey>"
  local dc         = MAP_COLOR["roomDesc"] or "<dim_grey>"
  local fc         = MAP_COLOR["mapui"] or "<dim_grey>"
  local sc         = "<ansi_yellow>"
  local ids        = f "({MAP_COLOR['number']}{id}{RC})"
  desc             = f "{dc}{desc}{RC}"
  flags            = f "{fc}{flags}{RC}"
  spec             = f "{sc}{spec}{RC}"
  name             = f "{nc}{name}{RC}"
  type             = f "[{tc}{type}{RC}]"
  local nameString = f "{name} {ids} {type} {spec}"
  cecho( f "\n{nameString}\n{desc}\n{flags}" )
end

function formatRoomDescription( desc )
  local maxLength = 80
  local indent = "   "
  local formattedDesc = indent
  local lineLength = #indent

  for word in string.gmatch( desc, "%S+" ) do
    if lineLength + #word + 1 > maxLength then
      formattedDesc = formattedDesc .. "\n" .. indent .. word
      lineLength = #indent + #word
    else
      if lineLength > #indent then
        formattedDesc = formattedDesc .. " " .. word
        lineLength = lineLength + 1 + #word
      else
        formattedDesc = formattedDesc .. word
        lineLength = lineLength + #word
      end
    end
  end
  return formattedDesc
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

function findSafeRooms()
  local allRooms = getRooms()
  for rNumber, name in pairs( allRooms ) do
    local roomFlags = getRoomUserData( rNumber, "roomFlags" )
    if roomFlags then
      -- if roomFlags contains the substring "NOMOB" then iout() it
      if string.find( roomFlags, "NO_MOB" ) then
        local char = getRoomChar( rNumber )
        if char == "😈" then
          iout( f "NO_MOB room has char: {char}" )
          --iout( roomFlags )
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
