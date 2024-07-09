-- MUDs measure time in "ticks" 60 seconds lone; this module synchronizes a
-- global variable and visual clock with the in-game tick cycle.

-- The number of clock images in the animation sequence
CLOCK_STEPS      = 180
STEPS_PER_SECOND = CLOCK_STEPS / 60

-- How often to call the update function
TICK_RATE        = 0.1

-- Time since the most recent synchronization message from the MUD and progress
-- through the current tick
TickSynch        = TickSynch or -1
TickTime         = TickTime or -1

-- Global ID of the timer that updates TickTime and the clock image
TickTimer        = TickTimer or nil

-- Fully reset the clock & timer
function restartTimer()
  if TickTimer then killTimer( TickTimer ) end
  TickTimer = nil
  TickSynch = -1
  TickTime  = -1
end

-- On receipt of a message from the MUD indicating the start of a tick, synchronize
-- or start the timer.
function synchronizeTickTimer()
  cout( "Tick reset at TickTime: {NC}{TickTime}{RC}" )
  -- Mark the arrival of the synchronization message and reset the current tick's
  -- time.
  TickSynch = getStopWatchTime( "timer" )
  TickTime  = 0

  -- If the timer isn't running, start it; append an indicator to the end of the
  -- line that triggered this synchronization.
  if not TickTimer then
    TickTimer = tempTimer( TICK_RATE, [[updateTickTimer()]], true )
    cecho( ' [<deep_pink>T<reset>]' )
  else
    cecho( ' [<spring_green>t<reset>]' )
  end
end

-- Once synchronized, this function is called repeatedly at TICK_RATE to update
-- TickTime and cycle the clock image.
-- CurrentImage tracks the index of the current image so it is only updated as
-- needed.
CurrentImage = CurrentImage or 0

function updateTickTimer()
  -- Calculate time elapsed since the last synchronization message
  local elapsed = getStopWatchTime( "timer" ) - TickSynch
  -- Set TickTime based on the elapsed time and the current 60s tick
  TickTime = (elapsed % 60) / 60
  -- Determine if the image needs to be updated
  local imageIndex = math.floor( TickTime * CLOCK_STEPS )
  if CurrentImage ~= imageIndex then
    CurrentImage = imageIndex
    tickLabel:setBackgroundImage( f '{ASSETS_PATH}/img/t/{CurrentImage}.png' )
  end
end
