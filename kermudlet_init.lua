homeDirectory = 'C:/dev/mud/mudlet/'
luasql = require( "luasql.sqlite3" )

-- Seed Lua's shitty useless piece of shit random number generator
math.randomseed( os.time() )

-- Mudlet stopwatch is good for milisecond timing; init one and save this session's startup time
if not timer then
  timer = createStopWatch( "timer", true )
  setStopWatchPersistence( "timer", true )
end
timeStart    = getStopWatchTime( "timer" )

-- nil Mudlet's built-in parsing variables to ensure nothing hangs arounda after reloads
matches      = nil
multimatches = nil
line         = nil
command      = nil

if clearScreen then clearScreen() end
-- Silly function but it will put this file on the map.
function loadLibs()
  -- Load the standard libraries
  runLuaFile( 'lib/lib_script.lua' )
  runLuaFile( 'lib/lib_std.lua' )
  runLuaFile( 'lib/lib_gui.lua' )
  runLuaFile( 'lib/lib_react.lua' )
  runLuaFile( 'lib/lib_string.lua' )
  runLuaFile( 'lib/lib_wintin.lua' )
end

loadLibs()

-- Now branch into Gizmo-specific scripts
runLuaFile( 'gizmo/gizmo_init.lua' )

-- Ensure all scripts have been fully loaded, then add file watchers to any file
-- that defined at least one function; this enables auto-reloading via the
-- sysPathChanged event
local function addFileWatchers()
  -- Table to hold all of the filenames that have defined functions in the current interpreter
  local mySources = {}
  -- Use a custom local 'contains' since we're pissing around in _G[]
  local function gotSource( src )
    for _, source in pairs( mySources ) do
      if source == src then
        return true
      end
    end
    return false
  end
  for k, v in pairs( _G ) do
    -- If the source of the definition includes the home directory, it's one of ours
    if type( v ) == "function" then
      local functionInfo = debug.getinfo( _G[k] )
      local functionSource = functionInfo.source
      functionSource = functionSource:sub( 2 )
      local isCustom = functionSource:match( homeDirectory )
      if isCustom and not gotSource( functionSource ) then
        table.insert( mySources, functionSource )
        removeFileWatch( functionSource )
        addFileWatch( functionSource )
      end
    end
  end
  -- Add a watcher explicitly to the module itself to refresh the XML file
  -- [NOTE] This will cause a console window to pop-up momentarily; comment this
  -- out if you're making a ton of updates in Mudlet.
  -- addFileWatch( "C:/Dev/mud/mudlet/gizmo/gizmudlet.mpackage" )
end
addFileWatchers()
