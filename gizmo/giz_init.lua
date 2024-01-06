cecho( f '\n\t<dark_violet>giz_init.lua<reset>: entry point to Gizmo-specific scripts and functions' )

session = getProfileTabNumber()

-- Common to all sessions
local commonScripts = {
  "game/trigger.lua",
  "config/events.lua",
  "config/config_common.lua",
  "alias/game_alias.lua",
  "eq/eqdb.lua",
  "status/affect.lua",
}

-- Specific to the main session
local mainScripts = {
  "map/map_unique.lua",
  "map/map_dirs.lua",
  "map/map_fol.lua",
  "config/config_main.lua",
  "gui/create_gui.lua",
  "gui/gui.lua",
  "status/update_status.lua",
  "status/parse_main.lua",
  "eq/inventory.lua",
}

-- Specific to alt sessions
local altScripts = {
  "config/config_alt.lua",
  "status/parse_alt.lua",
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
--[[
GitHub Copilot, ChatGPT notes:
Collaborate on Lua 5.1 scripts for Mudlet in VSCode. Use f-strings, camelCase, UPPER_CASE constants.
Prioritize performance, optimization, and modular design. Provide debugging output with cecho.
Be critical, suggest improvements, don't apologize for errors.
Respond concisely, treat me as a coworker.
]]
