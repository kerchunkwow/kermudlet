-- The primary unit for measuring the passage of time within a MUD is the "Tick"
-- The goal of this module is to help track the passing of Ticks using a visual
-- clock animation comprised of a series of PNG images which will display in
-- sequence as each Tick passes.

-- For increased fidelity, this module uses 360 PNG images named 0.png through
-- 359.png; 0.png is the first image displayed representing a full clock labeled
-- 60; 359.png is the final image before the next Tick begins. It is an empty
-- clock labeled 0.

-- We will update the click using a Mudlet timer set to fire at an appropriate
-- interval based on the total number of images.

-- Global constants with our current settings
TICK_STEPS       = 360
STEPS_PER_SECOND = TICK_STEPS / 60
SYNCH_TOLERANCE  = 2 * STEPS_PER_SECOND
EARLY_SYNCH      = SYNCH_TOLERANCE
LATE_SYNCH       = TICK_STEPS - SYNCH_TOLERANCE

-- Global variable to track our current step within the Tick; -1 indicates an
-- unsynchronized timer.
TickStep         = TickStep or -1

-- The moment (ms) at which the current Tick began as measured by the global
-- Mudlet stopwatch.
TickStart        = TickStart or -1

-- The global ID of the timer used to track ticks; if it's nil, the timer hasn't
-- started yet.
TickTimer        = TickTimer or nil

-- Many messages from the MUD indicate when a Tick has occurred such as changes
-- in weather patterns, expiration of spells, the onset of hunger, etc.
-- We will use these messages to synchronize the clock and to determine if and
-- when it gets out of synch.
function synchronizeTickTimer()
  -- If the timer is running, check if the current step is out of sync
  if TickTimer and (TickStep >= EARLY_SYNCH and TickStep <= LATE_SYNCH) then
    iout( f 'Ticked out of synch {EC}{TickStep}{RC}' )
  end
  -- Append an indicator to the end of any line which synchronizes the clock
  cecho( ' [<spring_green>t<reset>]' )

  TickStep = 0
  TickStart = getStopWatchTime( "timer" )

  -- If the timer isn't running yet, start it
  if not TickTimer then
    local tickRate = 1 / STEPS_PER_SECOND
    TickTimer = tempTimer( tickRate, [[updateTickTimer()]], true )
  end
end

-- Called repeatedly by the timer to increment TickStep and update the clock image
function updateTickTimer()
  -- Update the clock image to use the image corresponding to the current step
  local tickImage = f [[{ASSETS_PATH}/img/t/{TickStep}.png]]
  tickLabel:setBackgroundImage( tickImage )

  -- Update TickStep, wrapping around to 0 after the final step
  TickStep = (TickStep % TICK_STEPS) + 1
end
