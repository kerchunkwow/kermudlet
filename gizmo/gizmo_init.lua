cecho( f '\n<orange_red>gizmo_init.lua<reset>: entry point to Gizmo-specific scripts and functions' )

session = getProfileTabNumber()

-- Common to all sessions
local commonScripts = {
  "gizmo/game/game_trigger.lua",
  "gizmo/config/config_events.lua",
  "gizmo/config/config_common.lua",
  "gizmo/alias/game_alias.lua",
  "gizmo/eq/eq_db.lua",
  "gizmo/status/status_affect.lua",
}

-- Specific to the main session
local mainScripts = {
  "gizmo/config/config_main.lua",
  "gizmo/gui/gui_create.lua",
  "gizmo/gui/gui.lua",
  "gizmo/status/status_update.lua",
  "gizmo/status/status_parse_main.lua",
  "gizmo/eq/eq_inventory.lua",
}

-- Specific to alt sessions
local altScripts = {
  "gizmo/config/config_alt.lua",
  "gizmo/status/status_parse_alt.lua",
}

runLuaFiles( commonScripts )

if session == 1 then
  runLuaFiles( mainScripts )
else
  runLuaFiles( altScripts )
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
end

if session == 1 and not pcStatus then
  initPCStatusTable( pc_names )
end
--Create session-custom warning messages so they don't need to be created on demand
warning_calls = createWarningCalls()

tempTimer( 0.1, [[cecho(f"\n<olive_drab>(Gizmo)<reset> loaded for {my_color}{myself}<reset>.")]] )
