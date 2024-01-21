cecho( f '\n  <steel_blue>lib_react.lua<dim_grey>: Functions related to Mudlet "reactions" i.e., triggers, aliases' )

sureCastTrigger = nil

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

-- "Nuclear option" that kills all temporary timers and triggers; will probably interfere with
-- third party packages if you have any.
function killAllTemps()
  local topTrigger = tempTrigger( "dummy", function () end )
  local topTimer = tempTimer( 0, function () end )
  for i = 1, topTrigger do
    killTrigger( i )
  end
  for j = 1, topTimer do
    killTimer( j )
  end
end

-- Feed a line to the client as if it came from the MUD (great for testing triggers).
-- Suggested alias: ^sim (.*)$
function simulateOutput()
  local simString = matches[2]
  simString = string.gsub( simString, "%$", "\n" )
  cfeedTriggers( simString )
end

-- Send a command multiple times (alternative to sendAll?)
function repeatSend( cmd, count )
  for c = 1, count do
    send( cmd, false )
  end
end

-- Make a temporary alias from the command line with
-- #alias p=pattern c=code; use *'s for wildcards
function makeAlias( aliasString )
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
