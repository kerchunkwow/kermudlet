-- Enable an alias for the specified duration then disable it again; useful for triggers that are only
-- needed in niche circumstances like then viewing your 'eq' or interacting with a shopkeeper
function tempEnableTrigger( trigger, duration )
  -- Triggers that "exist" were created previous in the Mudlet client
  enableTrigger( trigger )
  tempTimer( duration, f [[disableTrigger( "{trigger}" )]] )
end

-- Turn a trigger off for a specified duration; useful for triggers that react to unpredictable events that
-- might create "spam" and are not time sensitive or critical (e.g., drinking from fountains).
function tempDisableTrigger( trigger, duration )
  disableTrigger( trigger )
  tempTimer( duration, f [[enableTrigger( "{trigger}" )]] )
end

-- Reset the clock (called at load after script init)
function resetClock()
  local resetTime = round( getStopWatchTime( "timer" ), 1 )
  iout( "<tomato>Resetting{RC} tick clock at {resetTime}s" )
  if tickTimer then killTimer( tickTimer ) end
  tickTimer = nil
  tickStep = nil
  tickStart = nil
end

-- Calculate time until the next tick and sit down until then; set a timer to stand again
function restUntilTick()
  if restTimer then killTimer( restTimer ) end
  -- Get time to tick plus a blink
  local restTime = ((TICK_STEPS - tickStep) / 2) + 0.25
  -- Rest and set a timer to stand again
  expandAlias( 'all rest' )
  restTimer = tempTimer( restTime, [[expandAlias( 'all stand' )]] )
end

-- Use expandWintinString to execute WINTIN-style command lists
-- Kind of just a generic "do command list" function
-- [TODO] Improve/clarify how this and similar functions interact with the command queue;
-- i.e., need a system to determine which commands should be queued vs. executed immediately
function doWintin( wintinString, echo )
  echo = echo or true
  local commands = expandWintinString( wintinString )
  for _, command in ipairs( commands ) do
    nextCmd( command, echo )
  end
end

-- Table of custom line highlights; use 6 values for fg and bg
CustomHighlights = {
  system     = {0, 80, 180},
  trollminor = {55, 65, 0},
  trollbasic = {80, 120, 0},
  trollmajor = {180, 240, 0, 65, 110, 0},
  trolldef   = {80, 180, 250, 10, 50, 80},
}
-- Highlight a line of output from the MUD using the specified colors
function triggerHighlightLine( color )
  local r, g, b, br, bg, bb
  -- If the color is a string, look for it first in Mudlet's built-in color_table, then
  -- our local custom color table
  if type( color ) == 'string' then
    if color_table[color] then
      r, g, b = unpack( color_table[color] )
    elseif CustomHighlights[color] then
      r, g, b, br, bg, bb = unpack( CustomHighlights[color] )
    end
  elseif type( color ) == 'table' and #color == 3 then
    r, g, b, br, bg, bb = unpack( color )
  end
  -- Select the line and highlight it with the specified color
  selectString( line, 1 )
  setFgColor( r, g, b )
  -- If background values were in the parameter, use them
  if br then setBgColor( br, bg, bb ) end
  resetFormat()
end

LastAlert = LastAlert or getStopWatchTime( "timer" )
function sendAlert( message )
  local now = getStopWatchTime( "timer" )
  local sinceLast = now - LastAlert
  if sinceLast > 3 then
    LastAlert        = now
    local bot_token  = [[7118770481:AAEMvomEAOiCFjoCu_fSdxlBmUZ8GSYG4Hs]]
    local chat_id    = [[7155655445]]
    local pythonPath = [[C:/Users/12404/AppData/Local/Programs/Python/Python310/python.exe]]
    local scriptPath = [[C:/Dev/mud/mudlet/pyutils/gizmogram.py]]

    -- Print info to the InfoWindow
    iout( "{SC}Telegram Alert: {message}{RC}" )

    -- Play a local warning too just in case we're at the keyboard and just distracted
    playSoundFile( {name = [[bloop.wav]]} )

    local command = string.format( '%s "%s" "%s" "%s" "%s"', pythonPath, scriptPath, bot_token, chat_id, message )
    os.execute( command )
  end
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
