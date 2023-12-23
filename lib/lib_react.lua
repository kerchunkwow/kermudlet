-- lib_react.lua
-- This lib includes core functions related to the basic Mudlet "reactions" -- triggers and aliases

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

-- Expand #WINTIN-style command strings
-- e.g., "#3 n;#2 u" = { "n", "n", "n", "u", "u" }
function expandWintin( wintinString )
  local commands = {}
  display( wintinString )
  -- Break on semi-colons
  for command in wintinString:gmatch( "[^;]+" ) do
    -- Insert 'command' '#' times
    local count, cmd = command:match( "#(%d+)%s*(.+)" )
    count = count or 1
    cmd = cmd or command

    for i = 1, tonumber( count ) do
      table.insert( commands, cmd )
    end
  end
  return commands
end

-- Use expandWintin to execute WINTIN-style command lists
function doWintin( wintinString )
  local commands = expandWintin( wintinString )
  for _, command in ipairs( commands ) do
    send( command, false )
    --cecho("\n" .. f "{command}")
  end
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
