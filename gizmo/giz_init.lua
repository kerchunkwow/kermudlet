timeStart = os.time()
math.randomseed( timeStart )

-- Load our Mudlet standard library
runLuaFile( "stdlib.lua" )

runLuaFile( "game\\speedwalks.lua" )

-- Define the functions needed for sending messages between sessions
runLuaFile( "events.lua" )

-- Define functions to execute and support Aliases
runLuaFile( "alias\\utility_alias.lua" )
runLuaFile( "alias\\game_alias.lua" )

-- Define functions to execute and support Triggers
runLuaFile( "trigger.lua" )

-- Functions helpful while developing/testing new features
-- run_lua_file("devtools.lua")

session = getProfileTabNumber()

-- This defines globals & settings needed by all sessions
runLuaFile( "config\\config_common.lua" )

-- Here we distinguish the main session from alts; namely, the main session
-- is responsible for creating and updating the UI and pcStatus table while
if session == 1 then
  runLuaFile( "config\\config_main.lua" )

  -- Stuff for creating & updating the UI including party window and chat/info
  runLuaFile( "gui\\create_gui.lua" )
  runLuaFile( "gui\\gui.lua" )

  -- Stuff for the pcStatus table and score/prompt capture
  runLuaFile( "status\\update_status.lua" )
  runLuaFile( "status\\parse_main.lua" )
  runLuaFile( "status\\affect.lua" )
  initializeAffectTracking()

  -- EQ handling
  runLuaFile( "eq.lua" )
else
  runLuaFile( "config\\config_alt.lua" )
  runLuaFile( "status\\parse_alt.lua" )
end
-- This local function helps create "code strings" from the messages in the warning_messages
-- table (config_common) for later posting to the Info window
local function createWarningCalls()
  local calls = {}
  local warningMethod = nil

  if session == 1 then
    warningMethod = "show_warning"
  else
    warningMethod = "raiseGlobalEvent"
  end
  for item, _ in pairs( warning_messages ) do
    calls[item] = f [[{warningMethod}( "eventWarn", {session}, "{item}" )]]
  end
  return calls
end --local function

if session == 1 and not pcStatus then
  initPCStatusTable( pc_names )
end
--Create session-custom warning messages so they don't need to be created on demand
warning_calls = createWarningCalls()

tempTimer( 0.1, [[cecho(f"\n<olive_drab>(Game)<reset> configured for {my_color}{myself}<reset>.")]] )
