-- The goal is to keep kermudlet_init MUD-agnostic so it could potentially be reused for others
homeDirectory = 'C:/dev/mud/mudlet/'
luasql = require( "luasql.sqlite3" )

-- Seed Lua's shitty useless piece of shit random number generator
math.randomseed( os.time() )

-- Mudlet stopwatch is good for milisecond timing; init one and save this session's startup time
if not timer then
  timer = createStopWatch( "timer", true )
  setStopWatchPersistence( "timer", false )
end
timeStart    = getStopWatchTime( "timer" )

-- nil Mudlet's built-in parsing variables to ensure nothing hangs arounda after reloads
matches      = nil
multimatches = nil
line         = nil
command      = nil

-- Somewhat of a pointless function; but for now all scripts need to define at least one function
-- in the global namespace to be eligible for auto-reloading.
function loadLibs()
  -- Load the standard libraries
  runLuaFile( 'lib/lib_script.lua' )
  runLuaFile( 'lib/lib_std.lua' )
  runLuaFile( 'lib/lib_gui.lua' )
  runLuaFile( 'lib/lib_react.lua' )
  runLuaFile( 'lib/lib_string.lua' )
  runLuaFile( 'lib/lib_wintin.lua' )
  runLuaFile( 'lib/lib_db.lua' )

  -- Now branch into Gizmo-specific scripts
  runLuaFile( 'gizmo/gizmo_init.lua' )
end

loadLibs()

-- Once all scripts are loaded, this function will iterate through the global namespace table and
-- call addFileWatch() on any file that has at least one function definition in the current interpreter.
-- This is done in each session's local interpreter, meaning we have four times the number of files to
-- watch; so it might be a good idea to disable this while you're not actively developing new scripts.
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
  -- [NOTE] You can set a watcher on the .mpackage as well which will unpack the XML file any time
  -- you modify it, but this pops up a command console so I prefer to do it manually with the 'refxml' alias
  -- addFileWatch( "C:/Dev/mud/mudlet/gizmo/gizmudlet.mpackage" )
end
addFileWatchers()
