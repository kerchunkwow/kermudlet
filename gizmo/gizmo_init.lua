session = getProfileTabNumber()

-- Common to all sessions
local commonScripts = {
  'gizmo/react/react_trigger.lua',
  'gizmo/react/react_alias.lua',
  'gizmo/session/session_events.lua',
  'gizmo/session/session_common.lua',
  'gizmo/eq/eq_db.lua',
  'gizmo/status/status_affect.lua',
}

-- Specific to the main session
local mainScripts = {
  'gizmo/session/session_main.lua',
  'gizmo/gui/gui_create.lua',
  'gizmo/gui/gui.lua',
  'gizmo/status/status_update.lua',
  'gizmo/status/status_parse_main.lua',
  'gizmo/eq/eq_inventory.lua',
  'gizmo/map/map_main.lua',
}

-- Specific to alt sessions
local altScripts = {
  'gizmo/session/session_alt.lua',
  'gizmo/status/status_parse_alt.lua',
}

runLuaFiles( commonScripts )

if session == 1 then
  runLuaFiles( mainScripts )
else
  runLuaFiles( altScripts )
end
-- This local function helps create "code strings" from the messages in the warning_messages
-- table (session_common) for later posting to the Info window
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
end

if session == 1 and not pcStatus then
  initPCStatusTable( pc_names )
end
--Create session-custom warning messages so they don't need to be created on demand
warning_calls = createWarningCalls()

enableKey( 'Movement' )
disableKey( 'Movement (Offline)' )
disableAlias( 'Map Sim' )
enableAlias( 'Total Recall (rr)' )

function startMapSim()
  runLuaFile( 'gizmo/map/map_sim.lua' )
  disableAlias( 'Total Recall (rr)' )
  enableAlias( 'Virtual Recall' )
  --disableKey( 'Movement' )
  --enableKey( 'Movement (Offline)' )
  enableAlias( 'Map Sim' )
  startExploration()
end
