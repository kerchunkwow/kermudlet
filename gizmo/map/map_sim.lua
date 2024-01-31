-- Functions in this class override existing/default functions in order to facilitate
-- offline map traversal/simulation.

-- Coordinates to track the "physical" location of the room relative to the starting point of the Area so Mudlet can draw it
mX, mY, mZ = 0, 0, 0

-- Override doWintin when simulating offline map so commands are echoed instead of sent
function doWintin( wintinString )
  local commands = expandWintinString( wintinString )
  for _, command in ipairs( commands ) do
    nextCmd( command )
  end
end

-- To simulate realistic offline movement, display the "next" room after a brief
-- artificial delay.
function executeCmd( cmd )
  cecho( f " <ivory>\n{cmd}<reset>" )
  local cmdDelay = randomFloat( 0.2, 0.3 )
  if DIRECTIONS[cmd] then
    local exits = getRoomExits( currentRoomNumber )
    local longDir = LDIR[cmd]
    queueDst = tonumber( exits[longDir] )
    nextCmdTimer = tempTimer( cmdDelay, f [[displayRoom( {queueDst}, true )]] )
  else
    nextCmdTimer = tempTimer( cmdDelay, [[simulateOutput('\nOk.\n')]] )
  end
end

-- Override moveExit while offline to simulate movement and display virtual rooms
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
    local moveDelay = randomFloat( 0.1, 0.5 )
    tempTimer( moveDelay, f [[finalizeMove( {dst}, {dir})]] )
    return true
  end
  cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
  return false
end

-- Simulate a 'scroll of recall'; magical item in game that returns the player to the starting room
function virtualRecall()
  cecho( f "\n\n<orchid>You recite a <deep_pink>scroll of recall<orchid>.<reset>\n" )
  setPlayerRoom( 1121 )
  displayRoom( 1121, true )
end

-- Initialize location to Market Square; set default coordinates
function startExploration()
  --openMapWidget()
  -- Set the starting Room to Market Square and initilize coordinates
  mX, mY, mZ = 0, 0, 0
  setPlayerRoom( 1121 )
  displayRoom( 1121, true )
end

-- Display a full "simulated" room including name, description (if not brief), and exits
-- By default, display the current room in brief mode (no room description)
function displayRoom( id, brief )
  local rd = MAP_COLOR["roomDesc"]
  simulateOutput( f "\n\n{getRoomString(id, 2)}" )
  if not brief then
    local desc = getRoomUserData( id, "roomDescription" )
    simulateOutput( f "{rd}{desc}<reset>" )
  end
  -- local rSpec = tonumber( getRoomUserData( id, "roomSpec" ) )
  -- if rSpec and rSpec > 0 then
  --   cecho( f "\n\tThis room has a ~<ansi_light_yellow>special procedure<reset>~.\n" )
  -- end
  local exitString = getExitString( id )
  cfeedTriggers( f "\n{exitString}" )
  cecho( "\n\n<olive_drab>< 250(250) 400(400) 500(500) ><reset>" )
end
