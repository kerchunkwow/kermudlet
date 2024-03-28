-- Module to support the creation and maintenance of looping "paths" through areas which
-- can be followed periodically in either direction. Useful as the foundation of later
-- automation.

-- Relevant globals: REVERSE, CurrentAreaName, CurrentRoomName, CurrentRoomNumber
-- Function clarification:
-- iout() is defined elsewhere and performs argument interpolation
-- nextCmd() sends the command to the MUD while also keeping the map up to date

-- Global table mapping area names to their paths
AreaPaths = {}
AreaPath  = {}
table.load( f '{HOME_PATH}/gizmo/map/data/area_paths.lua', AreaPaths )

-- Global variable to track the current path and position of the player within; nil when not following a path
CurrentPath  = nil
PathPosition = nil

-- Global flag to indicate whether a path is currently being defined
CreatingPath = false

-- Follow the current path; use 1 to move forward, -1 to go back
function followPath( direction )
  if not CurrentPath or not PathPosition then
    setPath()
    -- setPath didn't find a path; it will explain why
    if not CurrentPath then return end
  end
  -- Traverse the path and update position index
  if direction == 1 then
    -- Return to the origin after the last step
    if PathPosition > #CurrentPath then
      PathPosition = 1
    end
    nextCmd( CurrentPath[PathPosition] )
    PathPosition = PathPosition + 1
  elseif direction == -1 then
    PathPosition = PathPosition - 1
    -- Stepping back from the origin goes to the end of the path
    if PathPosition < 1 then
      PathPosition = #CurrentPath
    end
    nextCmd( REVERSE[CurrentPath[PathPosition]] )
  end
end

-- Start defining a new path for the current area, setting the origin
function startCreatingPath()
  if not CurrentRoomNumber or CurrentRoomNumber < 0 then
    iout( "{EC}startCreatingPath{RC}(): Bad CurrentRoomNumber{RC}" )
    return
  end
  if AreaPaths[CurrentRoomNumber] then
    iout( f "{EC}Room '{SC}{CurrentRoomNumber}{RC}' already has a path.{RC}" )
  else
    CreatingPath = true
    AreaPath = {} -- Initialize the new path
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

-- Deletes an existing room's path so we can make a new one
function removePath( roomNumber )
  if AreaPaths[roomNumber] then
    AreaPaths[roomNumber] = nil
    iout( [[Path removed: {NC}{roomNumber}{RC}]] )
  else
    iout( [[No path to remove: {NC}{roomNumber}{RC}]] )
  end
end

-- Set or "load" the path for the current area, verifying player is in the origin room
function setPath()
  -- Verify if there's a path for the current room number
  if AreaPaths[CurrentRoomNumber] then
    CurrentPath = AreaPaths[CurrentRoomNumber]
    PathPosition = 1
    iout( f "Path set in {NC}{CurrentRoomNumber}{RC}" )
  else
    iout( f "{EC}No path exists from {NC}{CurrentRoomNumber}{RC}" )
  end
end

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
