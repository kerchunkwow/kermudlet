luasql = require( "luasql.sqlite3" )

-- If we're reloading, clear the screen and reset the timers
if clearScreen then clearScreen() end
cecho( f '\n\t<yellow_green>kermudlet.lua<reset>: common entry point for all of my Mudlet stuff' )

-- Send profiles through a shared init to establish consistency and avoid deuplicating common/shared tasks
timeStart = os.time()
math.randomseed( timeStart )

if not timer then
  timer = createStopWatch( "timer", true )
  setStopWatchPersistence( "timer", true )
end
runLuaFile( f "{rootDirectory}lib/lib.lua" )

matches           = nil
multimatches      = nil
line              = nil
command           = nil

-- Fork depending on which game we're playing
local profileName = getProfileName()

if profileName == "IMM" then -- Gizmo IMM
  rootDirectory = rootDirectory .. "gizmo/"
  runLuaFile( f "{rootDirectory}map/map_def.lua" )
  runLuaFile( f "{rootDirectory}map/map_data.lua" )
  runLuaFile( f "{rootDirectory}map/map_dirs.lua" )
  runLuaFile( f "{rootDirectory}map/map_unique.lua" )
  runLuaFile( f "{rootDirectory}map/map_sim.lua" )
  runLuaFile( f "{rootDirectory}map/map_gen.lua" )
elseif profileName == "DD" then -- Death's Domain
  rootDirectory = rootDirectory .. "dd/"
  runLuaFile( f "{rootDirectory}dd_init.lua" )
else -- Gizmo
  rootDirectory = rootDirectory .. "gizmo/"
  runLuaFile( f "{rootDirectory}giz_init.lua" )
end
--[[
GitHub Copilot, ChatGPT notes:
Collaborate on Lua 5.1 scripts for Mudlet in VSCode. Use f-strings, camelCase, UPPER_CASE constants.
Prioritize performance, optimization, and modular design. Provide debugging output with cecho.
Be critical, suggest improvements, don't apologize for errors.
Respond concisely, treat me as a coworker.
]]
