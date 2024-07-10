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
