-- To synchronize the Map with game output, use a FIFO queue and validate commands prior to executing
-- the next command in the queue.

cmdQueue   = {first = 0, last = -1}

-- Hold the last command for validation
cmdPending = nil

-- Add a new command to the queue
function cmdQueue.push( cmd )
  local last     = cmdQueue.last + 1
  cmdQueue.last  = last
  cmdQueue[last] = cmd
end

-- Pop the next command from the queue
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
  if CreatingPath then
    addCommandToPath( cmd )
  end
  -- If we don't have a room number, the map isn't ready to handle the command queue yet
  -- [TODO] This is kind of a brute force hack need to figure out why the map is not setting/maintaining these values
  if not CurrentRoomNumber or CurrentRoomNumber <= 0 then
    send( cmd, false )
  end
  -- If a move command is pending validation or commands are queued, queue this command
  if cmdPending or not cmdQueue.isEmpty() then
    cmdQueue.push( cmd )
  else
    -- Otherwise, execute the command immediately
    cmdPending = cmd
    executeCmd( cmd )
  end
end

-- Attempt to execute a queuable command
function executeCmd( cmd )
  -- Make sure the command is the "long" version of a direction
  local longDir = LDIR[cmd]
  -- Make sure the map knows where we're at before using it to move
  if longDir and CurrentRoomNumber > 0 then
    local exits = getRoomExits( CurrentRoomNumber )
    if exits[longDir] then
      queueDst = tonumber( exits[longDir] )
    else
      cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
      cmdPending = nil
      return false
    end
  end
  -- If there's a door in the direction we're moving, open it before proceeding
  local door = doorData[CurrentRoomNumber] and doorData[CurrentRoomNumber][longDir]
  if door then
    openDoor( longDir, door['exitKeyword'], door['exitKey'] )
  end
  send( cmd, false )
  -- Print a "real time" update of our position while auto-pathing
  if AutoPathing then
    tempTimer( 0.5, [[displayPath()]] )
  end
  return true
end

-- Triggered off of output from the MUD, validate that the last move worked
function validateCmd( type )
  if type == 'move' then
    -- Once a move has been validated, update the player's location on the map
    setPlayerRoom( queueDst )
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
  cmdPending = nil
  queueDst = nil
  while not cmdQueue.isEmpty() do
    cmdQueue.pop()
  end
end
