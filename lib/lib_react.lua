-- Enable an alias for the specified duration then disable it again; useful for triggers that are only
-- needed in niche circumstances like then viewing your 'eq' or interacting with a shopkeeper
function tempEnableTrigger( trigger, duration )
  enableTrigger( trigger )
  tempTimer( duration, f [[disableTrigger( "{trigger}" )]] )
end

-- Turn a trigger off for a specified duration; useful for triggers that react to unpredictable events that
-- might create "spam" and are not time sensitive or critical (e.g., drinking from fountains).
function tempDisableTrigger( trigger, duration )
  disableTrigger( trigger )
  tempTimer( duration, f [[enableTrigger( "{trigger}" )]] )
end

-- Feed a line to the client as if it came from the MUD (great for testing triggers).
-- Suggested alias: ^sim (.*)$
function simulateOutput( output )
  local simString = output or matches[2]
  simString = string.gsub( simString, "%$", "\n" )
  cfeedTriggers( simString )
end

-- Use a temporary trigger to recast on lost concentration
function sureCast( spell, target )
  local castCode

  if sureCastTrigger then killTrigger( sureCastTrigger ) end
  tempTimer( 5, function () killTrigger( sureCastTrigger ) end )

  if target then
    castCode = f [[send("cast '{spell}' {target}")]]
    send( f "cast '{spell}' {target}" )
  else
    castCode = f [[send("cast '{spell}'")]]
    send( f "cast '{spell}'" )
  end
  sureCastTrigger = tempRegexTrigger( "^You lost your concentration!$", castCode, 1 )
end

-- Make a temporary alias from the command line with
-- #alias p=pattern c=code; use *'s for wildcards
local function makeAlias( aliasString )
  -- Table to hold temporary alias IDs in case you want to kill 'em'
  if not tempAliases then
    tempAliases = {}
  end
  -- Parse the creation string
  local pattern, code = aliasString:match( "p=(.-) c=(.*)" )

  -- Replace incoming wildcard with regex
  pattern = pattern:gsub( "%*", "(\\w+)" )

  -- Replace outgoing wildcard with capture group
  code = code:gsub( "%*", "{matches[2]}" )

  -- Build the regex and code patterns
  pattern = '^' .. pattern .. '$'
  code = f [[send(f']] .. code .. [[')]]

  -- Create the alias
  local aliasID = tempAlias( pattern, code )

  -- Store it's ID
  table.insert( tempAliases, aliasID )

  -- Get some info
  cecho( f "\nCreated alias: {pattern} to execute code: {code} (#{#tempAliases} active temps)" )
end

-- Send a command multiple times (alternative to sendAll?)
local function repeatSend( cmd_string, count )
  for c = 1, count do
    send( cmd_string, false )
  end
end

-- "Nuclear option" that kills all temporary timers and triggers; will probably interfere with
-- third party packages if you have any.
function killAllTemps()
  local topTrigger = tempTrigger( "dummy", function () end )
  local topTimer   = tempTimer( 0, function () end )
  for i = 1, topTrigger do
    killTrigger( i )
  end
  for j = 1, topTimer do
    killTimer( j )
  end
end

-- Reset the clock (called at load after script init)
function resetClock()
  if tickTimer then killTimer( tickTimer ) end
  tickTimer = nil
  tickStep = nil
  tickStart = nil
end

if not tickTimer and not tickStep and not tickStart then
  tempTimer( 0, [[resetClock()]] )
end
-- Called from tickbound message triggers, this function keeps the tick timer synchronized
-- Depending on how well the timer stays synchronized once initialized, this may only be needed once
function synchronizeTickTimer()
  -- Append an indicator to messages that synch the tick timer (for tracking/debugging)
  cecho( ' [<spring_green>t<reset>]' )

  -- Once the timer is running, messages should arrive at the beginning of step 0;
  -- with some variation, anything beyond 2s probably means somethings wrong
  if tickStep and (tickStep < 119 and tickStep > 1) then
    iout( "Tick timer reset out of synch: {NC}{tickStep}{RC}:" )
    iout( "{SC}{line}{RC}" )
  end
  tickStep = 0
  tickStart = getStopWatchTime( "timer" )

  -- If the tick timer isn't running yet, start it
  if not tickTimer then
    tickTimer = tempTimer( 0.5, [[updateTickTimer()]], true )
  end
end

-- Once the timer is synchronized with the first tick-bound message; tickTimer uses
-- this function to animate the clock indefinitely until it's killed
function updateTickTimer()
  -- Reset the clock the after the final step
  if tickStep == TICK_STEPS then tickStep = 0 end
  -- Update the label image to the image corresponding to the current step
  local tickImage = f [[{ASSETS_DIR}/img/t/{tickStep}.png]]
  tickLabel:setBackgroundImage( tickImage )
  tickStep = tickStep + 1
end

function restUntilTick()
  if restTimer then killTimer( restTimer ) end
  -- Get time to tick plus a blink
  local restTime = ((TICK_STEPS - tickStep) / 2) + 0.2
  -- Rest and set a timer to stand again
  expandAlias( 'all rest' )
  restTimer = tempTimer( restTime, [[resumeStand()]] )
end

function resumeStand()
  expandAlias( 'all stand' )
end
