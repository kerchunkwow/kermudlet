-- Module to support the creation and maintenance of looping "paths" through areas which
-- can be followed periodically in either direction.

-- Also supports the creation of "PathMobs" sets which indicate which mobs along a given
-- path should have targeting triggers created for them.

-- Global table mapping area names to their paths
AreaPaths = AreaPaths or {}
AreaPath  = AreaPath or {}
table.load( f '{HOME_PATH}/gizmo/map/data/area_paths.lua', AreaPaths )

-- Holds the ID of the timer for executing "next actions" during auto-pathing
NextTimer    = NextTimer or nil

-- Global variable to track the current path and position of the player within; nil when not following a path
CurrentPath  = CurrentPath or nil
PathPosition = PathPosition or nil

-- Global flag to indicate whether a path is currently being defined
CreatingPath = CreatingPath or false

-- A table mapping room numbers to sets mapping mob id numbers to "true"
-- This table can be used with loadMobTriggers( mobRNumbers ) to create triggers
-- for specific targets along a path.
PathMobs     = PathMobs or {}
table.load( f '{HOME_PATH}/gizmo/map/data/area_path_mobs.lua', PathMobs )

TrollInCombat = TrollInCombat or false
SkippingRoom  = SkippingRoom or false
DangerZone    = DangerZone or false
ActionTimer   = ActionTimer or nil
LookTimer     = LookTimer or nil
TargetCount   = TargetCount or 0

-- Follow the current path; use 1 to move forward, -1 to go back
function followPath( direction )
  if inCombat then
    iout( "{EC}Ignoring followPath() while in combat{RC}" )
    return
  end
  if not CurrentPath or not PathPosition then
    setPathByRoom()
    -- setPathByRoom didn't find a path; it will explain why
    if not CurrentPath then return end
  end
  local pathDir = nil
  -- Traverse the path and update position index
  if direction == 1 then
    -- Return to the origin after the last step
    if PathPosition > #CurrentPath then
      PathPosition = 1
    end
    pathDir = CurrentPath[PathPosition]
    nextCmd( pathDir )
    PathPosition = PathPosition + 1
  elseif direction == -1 then
    PathPosition = PathPosition - 1
    -- Stepping back from the origin goes to the end of the path
    if PathPosition < 1 then
      PathPosition = #CurrentPath
    end
    pathDir = CurrentPath[PathPosition]
    nextCmd( REVERSE[pathDir] )
  end
end

-- Perform the next action along our path;
-- Other improvements in the future should include a table of multiple markedTargets to allow
-- for somewhat more nuanced behavior like target prioritization.
function performNextAction()
  -- Double check that we're meant to be AutoPathing here just for safety's sake
  if not AutoPathing then return end
  -- Make sure only the most recent call to this function ever results in an action; avoid "overlapping"
  -- or queueing multiple actions.
  if ActionTimer then killTimer( ActionTimer ) end
  ActionTimer = nil
  -- Add some small random delay to appear less automated and avoid spamming the server
  local humanDelay = skewedRandom( 1, 2, 2 )
  ActionTimer = tempTimer( humanDelay, function ()
    if markedTarget then
      -- Attack the marked target (and clear the mark)
      cecho( f "<dim_grey>Attacking<reset>: {VC}{markedTarget}{RC}\n" )
      aliasKillCommand( markedTarget )
    else
      -- No targets available; move forward along the path until we find one
      followPath( 1 )
      -- When the next prompt arrives, markedTarget will be set if we saw any enemies
      -- Otherwise, we'll know to move along
      onNextPrompt( performNextAction )
    end
  end )
end

-- Keep track of the ID of the current "look" timer in case we want to kill/reset it
-- "Look" at the room and schedule a response to its contents
function lookCheck()
  if LookTimer then killTimer( LookTimer ) end
  LookTimer = nil
  -- Add some small random delay to appear less automated and avoid spamming the server
  local lookDelay = skewedRandom( 1, 2, 2 )
  LookTimer = tempTimer( lookDelay, function ()
    TrollInCombat = false
    send( 'look', false )
    -- When the next prompt arrives, markedTarget will be set if we saw any enemies
    -- Otherwise, we'll know to move along
    onNextPrompt( performNextAction )
  end )
end

-- If we're auto-pating and take any action that changes our position like flee, recall
-- etc.
function cancelPathing()
end

-- Set or "load" the path originating from the current room (if there is one)
-- If a set of mobs has been identified for the path originating from this room, load the associated
-- mob triggers.
-- Alias: ^path$
function setPathByRoom()
  -- Verify if there's a path for the current room number
  if AreaPaths[CurrentRoomNumber] then
    CurrentPath  = AreaPaths[CurrentRoomNumber]
    PathPosition = 1
    iout( f "Path set @ {NC}{CurrentRoomNumber}{RC}" )
  else
    iout( f "{EC}No path{RC} @ {NC}{CurrentRoomNumber}{RC}" )
  end
  -- If this path is associated with a set of mobs, load triggers for them
  if PathMobs[CurrentRoomNumber] then
    iout( f "Mobs loaded @ {NC}{CurrentRoomNumber}{RC}" )
    loadMobTriggers( PathMobs[CurrentRoomNumber] )
  else
    -- Otherwise, create triggers for all mobs in the same area as the path's origin
    loadMobTriggers()
  end
end

-- Provide a simple visual representation of the current path and our position within
-- Alias: ^dpath$
function displayPath()
  if not CurrentPath or #CurrentPath == 0 then
    iout( "{EC}No current path to display.{RC}" )
    return
  end
  local pathString = ""
  for i, direction in ipairs( CurrentPath ) do
    local dirLetter = direction:sub( 1, 1 )
    if i == PathPosition then
      pathString = pathString .. "<deep_pink>" .. dirLetter .. "<dim_grey>"
    else
      pathString = pathString .. dirLetter
    end
  end
  iout( "[<dim_grey>" .. pathString .. "<reset>]" )
end

--[[
Functions for creating new area paths
--]]

-- Start defining a new path for the current area, setting the origin
-- Alias: ^startpath$
function startCreatingPath()
  if not CurrentRoomNumber or CurrentRoomNumber < 0 then
    iout( "{EC}startCreatingPath{RC}(): Bad CurrentRoomNumber{RC}" )
    return
  end
  if AreaPaths[CurrentRoomNumber] then
    iout( f "{EC}Room '{SC}{CurrentRoomNumber}{RC}' already has a path.{RC}" )
  else
    CreatingPath = true
    AreaPath = {}
    iout( [[New path started w/ origin == {NC}{CurrentRoomNumber}{RC}]] )
  end
end

-- Insert a command into the current area's path (if we're defining one)
-- Just directions for now, but may later include commands like 'open door'
function addCommandToPath( command )
  if not CreatingPath or not CurrentAreaName then
    iout( [[{EC}addCommandToPath{RC}(): No path in progress; use startNewPath()]] )
    return
  end
  table.insert( AreaPath, command )
end

-- An 'undo' to remove the most recent command from the path; useful if we
-- get interrupted in game (e.g., by an enemy)
function undoLastCommand()
  if CreatingPath and #AreaPath > 0 then
    table.remove( AreaPath )
  else
    iout( [[{EC}undoLastCommand{RC}():Nothing to undo or not creating]] )
  end
end

-- Finish defining the path for the current area and store the origin
-- ^finishpath$
function finishCreatingPath()
  if CreatingPath and #AreaPath > 0 then
    AreaPaths[CurrentRoomNumber] = AreaPath
    CreatingPath = false
    iout( "Path complete for origin == {NC}{CurrentRoomNumber}{RC}." )
    table.save( f '{HOME_PATH}/gizmo/map/data/area_paths.lua', AreaPaths )
  else
    iout( "{EC}finishCreatingPath{RC}(): Path empty or not in progress{RC}" )
  end
end

-- Delete a pre-existing path and associated mobs
-- Alias: ^rmob (\d+)$
function removePath( roomNumber )
  roomNumber = roomNumber or CurrentRoomNumber
  local removed = false

  if AreaPaths[roomNumber] then
    AreaPaths[roomNumber] = nil
    -- Ensure to save changes to the AreaPaths file
    table.save( f '{HOME_PATH}/gizmo/map/data/area_paths.lua', AreaPaths )
    removed = true
  end
  if PathMobs[roomNumber] then
    PathMobs[roomNumber] = nil
    -- Ensure to save changes to the PathMobs file
    table.save( f '{HOME_PATH}/gizmo/map/data/area_path_mobs.lua', PathMobs )
    removed = true
  end
  if removed then
    iout( f "Path and associated mobs removed: {NC}" .. roomNumber .. "{RC}" )
  else
    iout( f "No path or associated mobs to remove: {NC}" .. roomNumber .. "{RC}" )
  end
end

--[[
Functions for associating mobs with paths
--]]

-- If AreaPaths[CurrentRoomNumber] exists, set PathMobs[CurrentRoomNumber][mobRNumber] = true
-- Alias: ^amob (\d+)$
function addMobToPath( mobRNumber )
  if not AreaPaths[CurrentRoomNumber] then
    iout( f "{EC}No path exists from {NC}{CurrentRoomNumber}{RC}" )
    return
  end
  PathMobs[CurrentRoomNumber] = PathMobs[CurrentRoomNumber] or {}
  PathMobs[CurrentRoomNumber][mobRNumber] = true

  table.save( f '{HOME_PATH}/gizmo/map/data/area_path_mobs.lua', PathMobs )
  iout( f "Mob {NC}{mobRNumber}{RC} added to path from {NC}{CurrentRoomNumber}{RC}" )
end

-- If AreaPaths[CurrentRoomNumber] and PathMobs[CurrentRoomNumber] both exist, set PathMobs[CurrentRoomNumber][mobRNumber] = nil
-- Alias: ^rmob (\d+)$
function removeMobFromPath( mobRNumber )
  if not PathMobs[CurrentRoomNumber] or not PathMobs[CurrentRoomNumber][mobRNumber] then
    iout( f "{EC}Mob or path does not exist from {NC}{CurrentRoomNumber}{RC}" )
    return
  end
  PathMobs[CurrentRoomNumber][mobRNumber] = nil
  table.save( f '{HOME_PATH}/gizmo/map/data/area_path_mobs.lua', PathMobs )
  iout( f "Mob {NC}{mobRNumber}{RC} removed from path from {NC}{CurrentRoomNumber}{RC}" )
end

-- If AreaPaths[CurrentRoomNumber] and PathMobs[CurrentRoomNumber] both exist, displayMob( rNumber ) for each mob in PathMobs[CurrentRoomNumber]
function displayPathMobs()
  if not PathMobs[CurrentRoomNumber] then
    iout( f "{EC}No mobs loaded for path from {NC}{CurrentRoomNumber}{RC}" )
    return
  end
  iout( f "Mobs for path starting at {NC}{CurrentRoomNumber}{RC}:" )
  for mobRNumber, _ in pairs( PathMobs[CurrentRoomNumber] ) do
    displayMob( mobRNumber )
  end
end

ConfirmedCircuit = {
  884, --Kranch
  855, --the mazekeeper
}
TestCircuit = {
  156,  --master
  304,  --caretaker
  361,  --Ghost of Lormick
  494,  --Isha, the Necromancer Queen
  541,  --the Sadist
  543,  --the Baron von Masoch
  545,  --Justine
  628,  --Durgathel
  643,  --Kegroch The Mighty
  748,  --Hecate
  749,  --Proserpina
  750,  --Hades
  813,  --Rakjak, the Lead Archivist
  814,  --Toktok, the Librarian
  916,  --the Headmaster
  917,  --the Main Physician
  924,  --Kretz
  925,  --Adrin
  926,  --Edrin
  1049, --the Neptune
  1056, --the Hermit Sage
  1099, --the Furies
  1177, --the Wicked Witch
  1194, --a Githyaddi Priest
  1345, --Ekaziel
  1407, --Monsieur Pierre
  1409, --Monsieur Firmin
  1457, --Monsieur Etienne
  1460, --Gaston
  1512, --the huge ancient dragon
  1516, --the lost adventurer
  1521, --the King Cobra
  1523, --the Chief of the Ettins
  1528, --the dark ettin Wizard
  1533, --Ancient Crocodile
  1536, --Ettin Cleric
  1665, --the Gnoll Treasurer
  1666, --the Gnoll Lord
  1668, --Gnoll Sage
  1695, --the Sslessi Shaman
  1701, --the High Priest of the Night
  1730, --the Shantak Shaman
  1876, --the Venus's-flytrap
  1877, --the Sabre-toothed Tiger
  1879, --Mammoth's Skeleton
  1889, --Seth the God of Death
  1890, --the Tournament Knight
  1891, --a skeleton of the caveman
  1947, --the Mad Scientist
  1949, --the Demi-Lich
  1959, --the kraken
  1996, --Gnash the Snow Troll
  2179, --Gwark, the Kobold Chieftain
  2180, --Kobold Shaman
}

function findReachableFame()
  for _, rNumber in ipairs( TestCircuit ) do
    local mob = getMob( rNumber )
    local name = mob.shortDescription
    local room = mob.roomRNumber
    if getPath( 1121, room ) then
      local steps = #speedWalkDir
      iout( f [[{SC}{name}{RC} reachable from Market Square in {NC}{steps}{RC} steps]] )
    else
      iout( f [[{EC}{name}{RC} unreachable from Market Square to {NC}{room}{RC}]] )
    end
  end
end

-- Set path to a specific room number using Mudlet's built-in getPath function
-- Alias: ^proom (.*)$
function setPathToRoomNumber( roomRNumber )
  -- True if a path exists between where I'm at and where I need to be;
  -- If true, sets speedWalkDir and speedWalkPath globals
  if getPath( CurrentRoomNumber, roomRNumber ) then
    CurrentPath  = speedWalkDir
    PathPosition = 1
    local steps  = #CurrentPath
    cout( "Path Set to ({NC}{roomRNumber}{RC}) [{NC}{steps}{RC} steps]" )
  end
end

-- If called with a number OR a room name that maps to a number in the UNIQUE_ROOMS table, we
-- can path directly to the room. Otherwise, display the table of possible destinations.
function setPathToRoom( destination )
  -- If the room is in UNIQUE_ROOMS; it can be mapped to a room number
  destination = UNIQUE_ROOMS[destination] or destination
  -- We either received a number parameter, or a unique room, path directly to the room
  if type( destination ) == "number" then
    setPathToRoomNumber( destination )
  elseif type( destination ) == "stpring" then
    -- The parameter was a string representing a non-unique room, display a table of possible destinations
    local dstRooms = searchRoom( destination, true, true )
    display( dstRooms )
  end
end

-- Set our path using Mudlet's built-in getPath function to find a path between rooms (in this case the room a mob is in)
-- Alias: ^pmob (\d+)$
function setPathToMob( mobRNumber )
  local targetMob  = getMob( mobRNumber )
  local targetRoom = targetMob.roomRNumber
  local mobName    = targetMob.shortDescription
  if getPath( CurrentRoomNumber, targetRoom ) then
    local steps = #speedWalkDir
    iout( "Path set to {SC}{mobName}{RC} ({NC}{targetRoom}{RC}); currently {NC}{steps}{RC} away" )
    CurrentPath  = speedWalkDir
    PathPosition = 1
  end
end

-- Used by the Mudlet client alias to capture a 'proom' command, identifies the parameter
-- as being either string or number and calls setPathToRoom() accordingly
function aliasPathToRoom()
  local rstr = matches[2]
  local rnum = tonumber( rstr )
  if rnum then
    setPathToRoom( rnum )
  else
    setPathToRoom( rstr )
  end
end

-- Given a room name, search for it in the map; for each room with that name, print the "room string" for some
-- basic information, and determine the best path to the room either from Market Square or the player's current
-- location.
-- The found rooms table is used to store the room numbers of rooms returned by the most recent search for later use.
FoundRooms = FoundRooms or {}
function findRoom( roomName )
  roomName = roomName or trim( matches[2] )
  local rooms = searchRoom( roomName, true, true )
  FoundRooms = {}
  for id, name in pairs( rooms ) do
    local roomString = getRoomString( id, 2 )
    local roomArea = getRoomArea( id )
    local roomAreaName = getRoomAreaName( roomArea )

    local stepsMe = getPath( CurrentRoomNumber, id ) and #speedWalkDir or 999
    local stepsMS = getPath( 1121, id ) and #speedWalkDir or 999
    hline()
    cout( roomString )
    cout( "Area: {SC}{roomAreaName}{RC}" )

    if stepsMe < 999 or stepsMS < 999 then
      local minSteps = math.min( stepsMe, stepsMS )
      table.insert( FoundRooms, {
        roomId = id,
        steps = minSteps
      } )
      local pathSrc = stepsMe <= stepsMS and "<dark_violet>Here<reset>" or "<green_yellow>MS<reset>"
      cout( "{NC}{minSteps}{RC} from {pathSrc}" )
    else
      cout( "{EC}No path found.{RC}" )
    end
  end
  -- Sort FoundRooms by the shortest available path (for efficient multi-room traversal)
  table.sort( FoundRooms, function ( a, b ) return a.steps < b.steps end )
end

-- After findRoom( roomName ) is complete, this function can be called repeatedly to set a path to
-- each room in turn starting with the nearest.
function pathToNextResult()
  if #FoundRooms == 0 then
    cout( "No more rooms to path to." )
    return
  end
  local nextRoom = table.remove( FoundRooms, 1 )
  setPathToRoomNumber( nextRoom.roomId )
end

-- This function is called for every room entered when FoundRooms has at least one entry; it removes visited rooms
-- even if they have not been explicitly pathed to directly.
function removeFoundRoom( roomId )
  for index, room in ipairs( FoundRooms ) do
    if room.roomId == roomId then
      table.remove( FoundRooms, index )
      iout( "Removed {NC}{roomId}{RC} from {VC}FoundRooms{RC}" )
      return true
    end
  end
  return false
end

function displayAllRooms()
  local allRooms = getRooms()
  local file = io.open( "C:/Dev/mud/mudlet/roomData.txt", "w" ) -- Open a file in write mode

  for rNumber, room in pairs( allRooms ) do
    file:write( f "Data for {room} ({rNumber})\n" )
    local roomData = getAllRoomUserData( rNumber )
    for key, value in pairs( roomData ) do
      file:write( f "{key} == {value}\n" )
    end
  end
  file:close() -- Close the file
end
