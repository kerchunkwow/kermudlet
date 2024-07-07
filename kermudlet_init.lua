-- If this isn't the first time we've loaded this session, make sure to kill temporary triggers
-- on reload.
if FirstTempTrigger then
  cecho( "\n<deep_pink>...<reset>" )
  crawlKillTriggers()
end
-- Then set/update the ID of the first temporary trigger
local id = tempTrigger( [[dummy]], [[dummy]], 1 )
FirstTempTrigger = id
killTrigger( id )
cfeedTriggers( "" )
cecho( f [[Temporary triggers begin @ {FirstTempTrigger}]] )

-- Uses the default Windows Mudlet directory to determine a username for this session
local function setUserName()
  local path = lfs.currentdir()
  local pattern = "C:\\Users\\([^\\]+)\\"
  local username = string.match( path, pattern )
  if username then
    _G["USERNAME"] = username
  else
    cout( "<orange_red>Failed to parse USERNAME from lfs.currentdir()<reset>" )
  end
end
setUserName()

luasql = require( "luasql.sqlite3" )

-- Seed Lua's shitty useless piece of shit random number generator
math.randomseed( os.time() )

-- Mudlet stopwatch is good for milisecond timing; init one and save this session's startup time
if not Timer then
  Timer = createStopWatch( "timer", true )
  setStopWatchPersistence( "timer", false )
  StartTime = StartTime or getStopWatchTime( "timer" )
end
-- Mudlet has a variety of built-in variables that can hang on to old values between reloads; explicitly nil
-- some important ones here so we avoid carrying noise across updates.
matches         = nil -- Capture groups from matched regex
multimatches    = nil -- Capture groups from matched multi-line regex
line            = nil -- The full content of the last matched line
command         = nil -- The most recent command enter by the player
speedWalkDir    = nil -- Set by getPath() and other related map functions
speedWalkPath   = nil -- Set by getPath() and other related map functions
speedWalkWeight = nil -- Set by getPath() and other related map functions

-- Somewhat of a pointless function; but for now all scripts need to define at least one function
-- in the global namespace to be eligible for auto-reloading.
function loadLibs()
  -- Load the standard libraries
  runLuaFile( 'lib/lib_std.lua' )
  runLuaFile( 'lib/lib_gui.lua' )
  runLuaFile( 'lib/lib_react.lua' )
  runLuaFile( 'lib/lib_string.lua' )
  runLuaFile( 'lib/lib_db.lua' )
  runLuaFile( 'lib/lib_trigger.lua' )
  runLuaFile( 'lib/lib_data.lua' )

  -- Now branch into Gizmo-specific scripts
  runLuaFile( 'gizmo/gizmo_init.lua' )
end

loadLibs()

-- Register an event to listen for file modifications and reload scripts
registerAnonymousEventHandler( 'sysPathChanged', fileModifiedEvent )


-- Once all scripts are loaded, this function will iterate through the global namespace table and
-- call addFileWatch() on any file that has at least one function definition in the current interpreter.
-- This is done in each session's local interpreter, meaning we have four times the number of files to
-- watch; so it might be a good idea to disable this while you're not actively developing new scripts.
local function addFileWatchers()
  local homeDirectory = 'C:/dev/mud/mudlet/'
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

if SESSION_NAME == "GMAP" then
  disableTrigger( "gizmudlet2" )
  disableAlias( "gizmudlet2" )
  disableKey( "gizmudlet2" )
end
cout( [[Temporary triggers begin @ {NC}{FirstTempTrigger}{RC}]] )
