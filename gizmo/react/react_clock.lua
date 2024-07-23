-- Implement an animated "tick clock" that displays the time remaining in the current
-- game tick; synchronizeTickClock() is tied to a variety of tickbound messages from the MUD
-- like weather, spell expiration, etc.

-- Clock image assets
CLOCK_PATH       = f "{ASSETS_PATH}/img/t/"
CLOCK_STEPS      = 120
STEPS_PER_SECOND = CLOCK_STEPS / 60

-- How often to call the update function
CLOCK_RATE       = 0.2

-- Track time since the most recent synchronization message & progress through the current tick
TickSynch        = TickSynch or -1
TickTime         = TickTime or -1

-- The current clock face image index
CurrentImage     = CurrentImage or 0

-- Global ID for timer that calls the update function
TickTimer        = TickTimer or nil

-- On receipt of a synch message, synchronize the tick clock
function synchronizeTickClock()
  -- Append the current TickTime to check for drift
  cecho( f ' [<deep_pink>T = {NC}{TickTime}{RC}<reset>]' )
  TickSynch = getStopWatchTime( "timer" )
  updateTickClock()
  -- If the update timer isn't running, start it
  if not TickTimer then
    TickTimer = tempTimer( CLOCK_RATE, [[updateTickClock()]], true )
    tickLabel:show()
  end
end

-- Once synchronized, TickTime & CurrentImage are updated at CLOCK_RATE
function updateTickClock()
  -- Elapsed time since the most recent synch message
  local elapsed = (getStopWatchTime( "timer" ) - TickSynch)
  -- Progress through the current tick
  TickTime = (elapsed % 60)
  -- Cycle the image only when necessary
  local imageIndex = math.floor( TickTime * STEPS_PER_SECOND )
  if CurrentImage ~= imageIndex then
    CurrentImage = imageIndex
    tickLabel:setBackgroundImage( f '{CLOCK_PATH}{CurrentImage}.png' )
  end
end

-- Fully reset the clock & timer
function resetTickClock()
  if TickTimer then killTimer( TickTimer ) end
  TickTimer = nil
  TickSynch = -1
  TickTime  = -1
  tickLabel:hide()
end

-- Global boolean to track whether or not we're currently Idle (AFK)
Idle = Idle or false
IdleTimer = IdleTimer or nil
function toggleIdle()
  if IdleTimer then killTimer( IdleTimer ) end
  IdleTimer = nil
  Idle = not Idle
  if Idle then
    cecho( "\n<tomato>Going AFK...<reset>" )
    -- Get a random integer between 400 and 600
    local idleTime = math.random( 400, 600 )
    IdleTimer = tempTimer( idleTime, [[keepAlive()]], false )
  end
end

-- This function should keep players online by issuing a random command
-- a unpredictable intervals, but never longer than 10 minutes apart
function keepAlive()
  local onePageSpells = {1, 2, 3, 6, 9, 10, 11, 12, 13, 14}
  -- Pick a random number from the onePageSpells table
  local nS = onePageSpells[math.random( 1, #onePageSpells )]
  nS = tostring( nS )
  local randomCommands = {
    "look",
    "score",
    "aff",
    "inv",
    "weather",
    "time",
    f "help {nS}spells",
    f "help {nS}skills",
    "help map",
    "help auction",
    "examine stocking",
    "eq",
    "save",
  }
  local idleCommand = randomCommands[math.random( 1, #randomCommands )]
  send( idleCommand, false )
  -- Start another timer to keep us online
  -- Get a random integer between 400 and 600
  local idleTime = math.random( 400, 600 )
  IdleTimer = tempTimer( idleTime, [[keepAlive()]], false )
end
