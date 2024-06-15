-- Functions in this class override existing/default functions in order to facilitate
-- offline map traversal/simulation.

-- Coordinates to track the "physical" location of the room relative to the starting point of the Area so Mudlet can draw it
mX, mY, mZ = 0, 0, 0

-- Override moveExit while offline to simulate movement and display virtual rooms
function nextCmd( direction )
  if CreatingPath then
    addCommandToPath( direction )
  end
  -- Make sure direction is long-version like 'north' to align with getRoomExits()
  local dir = LDIR[direction]
  local exits = getRoomExits( CurrentRoomNumber )

  if not exits[dir] then
    cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
    return false
  end
  local dst = tonumber( exits[dir] )
  if roomExists( dst ) then
    setPlayerRoom( dst )
    displayRoom( dst, false )
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

-- Display a full "simulated" room including name, description (if not brief), and exits
-- By default, display the current room in brief mode (no room description)
function displayRoom( id, brief )
  local rd = MAP_COLOR["roomDesc"]
  cfeedTriggers( f "\n\n{getRoomString(id, 2)}" )
  if not brief then
    local desc = getRoomUserData( id, "roomDescription" )
    cfeedTriggers( f "{rd}{desc}<reset>" )
  end
  cecho( "\n\n<slate_grey>< 250(250) 400(400) 500(500) ><reset>" )
end
