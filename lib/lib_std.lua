function getCurrentTime()
  return os.date( "%H:%M" )
end

-- Compile and execute a lua function directly from the command-line; used
-- throughout other scripts and in aliases as 'lua <command> <args>'
function runLuaLine()
  local args = matches[2]
  -- Try to compile an expression.
  local func, err = loadstring( "return " .. args )

  -- If that fails, try a statement.
  if not func then
    func, err = assert( loadstring( args ) )
  end
  -- If that fails, raise an error.
  if not func then
    error( err )
  end
  -- Create the function
  local runFunc =

      function ( ... )
        if not table.is_empty( {...} ) then
          display( ... )
        end
      end

  -- Call it
  runFunc( func() )
end

function runLuaFile( file )
  local filePath = f '{homeDirectory}{file}'
  if lfs.attributes( filePath, "mode" ) == "file" then
    dofile( filePath )
  else
    cecho( f "\n{filePath}<reset> not found." )
  end
end

-- Use runLuaFile to run a table of Lua files
function runLuaFiles( files )
  for _, file in ipairs( files ) do
    runLuaFile( file )
  end
end

-- Function to check if a value is in a list or table
function contains( table, value, usePairs )
  if usePairs then
    for _, v in pairs( table ) do
      if v == value then
        return true
      end
    end
  else
    for _, v in ipairs( table ) do
      if v == value then
        return true
      end
    end
  end
  return false
end

-- Ensure a value remains within a fixed range
function clamp( value, min, max )
  return math.max( min, math.min( max, value ) )
end

-- Get a random FP value between lower and upper bounds
function randomFloat( lower, upper )
  return lower + math.random() * (upper - lower)
end

-- Round n to the nearest s
function round( n, s )
  s = s or 0.05
  return math.floor( n / s + 0.5 ) * s
end

-- Print all variables currently in _G (Lua's table for all variables); probably
-- not very readable but might be helpful
function printVariables()
  for k, v in pairs( _G ) do
    local nameStr, typeStr, valStr = nil, nil, nil
    local vName, vType, vVal       = nil, nil, nil

    vType                          = type( v )
    vName                          = tostring( k )
    vVal                           = tostring( v )

    nameStr                        = "<sea_green>" .. vName .. "<reset>"
    typeStr                        = "<ansi_magenta>" .. vType .. "<reset>"
    valStr                         = "<cyan>" .. vVal .. "<reset>"

    if vType == "number" or vType == "boolean" then
      cecho( f "\n{nameStr} ({typeStr}) == {valStr}\n-----" )
    elseif vType == "string" then
      cecho( f "\n{nameStr} ({typeStr}) ==\n{valStr}\n-----" )
    end
  end
end

-- Delete the current line then any of the subsequent 3 lines that are either empty or "prompt only"
function deleteComplete()
  deleteLine()
  tempLineTrigger( 1, 3, [[completeDelete()]] )
end

-- Support deleteComplete() by deleteing the current line if it's empty or "prompt only"
function completeDelete()
  local justAPrompt = string.match( line, "< %d+%(%d+%) %d+%(%d+%) %d+%(%d+%) > $" )
  if justAPrompt or #line <= 0 then
    deleteLine()
  end
end

-- Given a set of dice values as n, s, m, return the average roll (e.g., 3d8+2 = 3, 8, 2)
function averageDice( n, s, m )
  return (((n * s) + n) / 2) + m
end

-- Feed the contents of a file line-by-line as if it came from the MUD
function feedFile( feedPath )
  local feedRate = 0.01
  local file = io.open( feedPath, "r" )

  local lines = file:lines()

  local function feedLine()
    local nextLine = lines()
    if nextLine then
      cfeedTriggers( nextLine )
      tempTimer( feedRate, feedLine )
    else
      file:close()
    end
  end

  feedLine()
end

-- Invoked when sysPathChanged event fires for files previously registered by addFileWatchers();
-- nils all global definitions sourced from the modofied file then reloads its script from disk
function fileModifiedEvent( _, path )
  -- Throttle this event 'cause VS-Code extensions fire extra modifications with each save
  local fileModifiedDelay = 5 -- seconds between auto-reloads
  if not fileModifiedEventDelayed then
    fileModifiedEventDelayed = true
    tempTimer( fileModifiedDelay, [[fileModifiedEventDelayed = nil]] )
    -- If it's the Mudlet module that was changed, refresh the XML file
    if path:match( 'mpackage' ) then
      refreshModuleXML()
      return
    end
    -- nil all existing functions that reference this file as their source
    local function unloadFile( path )
      for k, v in pairs( _G ) do
        -- Don't 💀 ourselves
        if type( v ) == "function" and k ~= "fileModifiedEvent" then
          local functionInfo = debug.getinfo( v )
          local functionSource = functionInfo.source
          functionSource = functionSource:sub( 2 )
          if functionSource:match( path ) then
            _G[k] = nil
          end
        end
      end
    end
    unloadFile( path )
    -- Just reload the file; we know it's there since it had stuff in _G[]
    dofile( path )
  end
end

-- Transform a uniformly distributed random value to favor lower values
function skewedRandom( min, max, skewFactor )
  -- Generate a uniformly distributed random number between 0 and 1
  local uniformRandom = math.random()

  -- Apply a transformation to skew the distribution towards lower values
  -- A higher skewFactor will now more aggressively bias towards lower values.
  local skewedRandom = uniformRandom ^ skewFactor

  -- Scale and shift the result to the desired range (min to max)
  return min + (max - min) * skewedRandom
end

function testSkew()
  -- Initialize variables for the accumulation and the loop
  local sum        = 0
  local trials     = 1000

  -- Specify the parameters for the skewedRandom function
  local min        = 2
  local max        = 8
  local skewFactor = 3

  -- Loop 1000 times, calling skewedRandom and accumulating the results
  for i = 1, trials do
    local result = skewedRandom( min, max, skewFactor )
    sum = sum + result
  end
  -- Calculate the average
  local average = round( sum / trials, 0.01 )

  iout( [[Average: {NC}{average}{RC}]] )
end
