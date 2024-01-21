--[[
  kermudlet.lua is an entry point to establish some commonality and consistency across Mudlet sessions and profiles
--]]
cecho( f '\n<ansi_light_magenta>gizmudlet.lua<dim_grey>: common entry point all projects' )
homeDirectory = 'C:/dev/mud/mudlet/'
luasql = require( "luasql.sqlite3" )

local function createLibAliasesOnce()
  if exists( 'lib', 'alias' ) == 0 then
    permAlias( 'lib', '', '', '' )
    permAlias( 'Run Lua File (rf)', 'lib', '^rf (.+?)(?:\\.lua)?$', 'runLuaFile( matches[2] )' )
    permAlias( 'Run Lua (lua)', 'lib', '^lua (.*)$', 'runLuaLine( matches[2] )' )
    permAlias( 'Clear Screen (cls)', 'lib', '^cls$', 'clearScreen()' )
    permAlias( 'Simulate Output (sim)', 'lib', '^sim (.+)$', 'simulateOutput()' )
    permAlias( 'Save Layout (swl)', 'lib', '^swl$', 'saveWindowLayout()' )
  end
end
createLibAliasesOnce()

-- If we're reloading, clear the screen and reset the timers
if clearScreen then clearScreen() end
-- A table to hold the names of defined functions in case we want to undefine them later
allFunctions      = {}

-- nil Mudlet's built-in parsing variables to ensure nothing hangs arounda after reloads
matches           = nil
multimatches      = nil
line              = nil
command           = nil

-- Store the name of our profile in a global
local profileName = getProfileName()

-- Seed Lua's shitty useless piece of shit random number generator
math.randomseed( os.time() )

-- Mudlet stopwatch is good for milisecond timing; init one and save this session's startup time
if not timer then
  timer = createStopWatch( "timer", true )
  setStopWatchPersistence( "timer", true )
end
timeStart = getStopWatchTime( "timer" )

-- Load the standard library (and any sub-libraries it loads)
runLuaFile( 'lib/lib_std.lua' )

if profileName == "MAP" then -- Offline Mapping
  runLuaFile( 'gizmo/map/map_main.lua' )
else                         -- Playing Gizmo
  runLuaFile( 'gizmo/gizmo_init.lua' )
end
-- Put a little buffer after the init/loading messages
cecho( "\n\n" )
