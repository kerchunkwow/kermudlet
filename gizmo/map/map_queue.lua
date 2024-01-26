-- To synchronize the Map with game output, use a FIFO queue and validate commands prior to executing
-- the next command in the queue.

cmdQueue   = {first = 0, last = -1}

-- Hold the last move for validation
cmdPending = nil

-- Add a new move to the queue
function cmdQueue.push( cmd )
  local last     = cmdQueue.last + 1
  cmdQueue.last  = last
  cmdQueue[last] = cmd
end

-- Pop the next move from the queue
function cmdQueue.pop()
  local first     = cmdQueue.first
  local cmd       = cmdQueue[first]
  cmdQueue[first] = nil
  cmdQueue.first  = first + 1
  return cmd
end

-- Check if the queue is empty
function cmdQueue.isEmpty()
  return cmdQueue.first > cmdQueue.last
end

-- "Request" to execute or queue a command
function nextCmd( cmd )
  -- If a move command is pending validation or moves are queued, queue this move
  if cmdPending or not cmdQueue.isEmpty() then
    cmdQueue.push( cmd )
  else
    -- Otherwise, execute the move immediately
    cmdPending = cmd
    executeCmd( cmd )
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

-- Triggered off of output from the MUD, validate that the last move worked
function validateCmd( type )
  if type == 'move' then
    -- Once a move has been validated, update the player's location on the map
    updatePlayerLocation( queueDst, cmdPending )
  end
  cmdPending = nil
  queueDst = nil
  -- And if additional commands are queued, continue processing
  if not cmdQueue.isEmpty() then
    cmdPending = cmdQueue.pop()
    executeCmd( cmdPending )
  end
end

-- Cancel any pending commands and empty the queue (i.e., stop speedwalking)
function clearQueue()
  if nextCmdTimer then killTimer( nextCmdTimer ) end
  cmdPending = nil
  queueDst = nil
  while not cmdQueue.isEmpty() do
    cmdQueue.pop()
  end
end
