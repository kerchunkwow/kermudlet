-- Compile and execute a Lua function directly from the Mudlet command-line
-- @param matches Built-in Mudlet table capturing command-line arguments
function runLuaLine()
  local args = matches[2]

  -- Try to compile an expression.
  local func, err = loadstring( "return " .. args )

  -- If that fails, try a statement.
  if not func then
    func, err = loadstring( args )
    if not func then
      error( err )
    end
  end
  -- Create and call the function to display the result if not empty
  local function runFunc( ... )
    if not table.is_empty( {...} ) then
      display( ... )
    end
  end

  runFunc( func() )
end

-- Run (interpret) a Lua file using dofile()
-- @param file The path of the Lua file to be executed
function runLuaFile( file )
  local filePath = f '{homeDirectory}{file}'
  if lfs.attributes( filePath, "mode" ) == "file" then
    dofile( filePath )
  else
    cecho( f "\n{filePath}<reset> not found." )
  end
end

-- Use runLuaFile to run a table of Lua files
-- @param files Table containing paths of Lua files to be executed
function runLuaFiles( files )
  for _, file in ipairs( files ) do
    runLuaFile( file )
  end
end

-- Function to check if a value is in a list/table
-- @param table The table to search
-- @param value The value to search for
-- @param sequential Boolean indicating whether to use ipairs (true) or pairs (false) for iteration
-- @return Boolean indicating if the value is found in the table
function contains( table, value, sequential )
  if sequential then
    -- Use ipairs for sequential arrays/lists with consecutive integer keys
    for _, v in ipairs( table ) do
      if v == value then
        return true
      end
    end
  else
    -- Use pairs for tables that may have non-integer keys or gaps in integer keys
    for _, v in pairs( table ) do
      if v == value then
        return true
      end
    end
  end
  return false
end

-- Ensure a value remains within a fixed range
-- @param value The value to be clamped
-- @param min The minimum allowable value
-- @param max The maximum allowable value
-- @return The clamped value, ensuring it is within the range [min, max]
function clamp( value, min, max )
  return math.max( min, math.min( max, value ) )
end

-- Round a number to the nearest multiple of a specified step
-- @param n The number to be rounded
-- @param s The step to which the number should be rounded; defaults to 0.05 if not specified
-- @return The number rounded to the nearest multiple of the step
function round( n, s )
  s = s or 0.05
  return math.floor( n / s + 0.5 ) * s
end

-- Calculate the average expected outcome of a dice roll
-- @param n The number of dice to be rolled
-- @param s The number of sides on each die
-- @param m The modifier to be added to the result
-- @return The average expected outcome of the dice roll
function averageDice( n, s, m )
  return (n * (s + 1) / 2) + m
end

-- Invoked when sysPathChanged event fires for files previously registered by addFileWatchers()
-- Nils all global definitions sourced from the modified file then reloads its script from disk
-- @param _ unused (name of event that)
-- @param path The path of the modified file
function fileModifiedEvent( _, path )
  -- VSCode extensions trigger sysPathChanged repeatedly, so throttle the handler
  local fileModifiedDelay = 5 -- Seconds between auto-reloads
  if not fileModifiedEventDelayed then
    fileModifiedEventDelayed = true
    tempTimer( fileModifiedDelay, [[fileModifiedEventDelayed = nil]] )
    -- Unload all existing functions that reference this file as their source
    local function unloadFile( path )
      for k, v in pairs( _G ) do
        -- Don't unload ourselves
        if type( v ) == "function" and k ~= "fileModifiedEvent" then
          local functionSource = debug.getinfo( v ).source:sub( 2 )
          if functionSource:match( path ) then
            _G[k] = nil
          end
        end
      end
    end

    unloadFile( path )
    -- Reload the file; we know it's there since it had stuff in _G
    dofile( path )
  end
end

-- Get a formatted timestamp
-- @param format Optional. The desired format for the timestamp. Defaults to "%H:%M".
-- @return A string representing the current time formatted according to the specified or default format.
function getCurrentTime( format )
  return os.date( format or "%H:%M" )
end

-- Transform a uniformly distributed random value and skew it in favor of lower values
-- @param min: the minimum value of the desired range
-- @param max: the maximum value of the desired range
-- @param skewFactor: the factor by which to skew the distribution towards lower values
-- @return a skewed random value within the specified range
function skewedRandom( min, max, skewFactor )
  -- Generate a uniformly distributed random number between 0 and 1
  local uniformRandom = math.random()

  -- Apply a transformation to skew the distribution towards lower values
  -- A higher skewFactor will more aggressively bias towards lower values.
  local skewedRandom = uniformRandom ^ skewFactor

  -- Scale and shift the result to the desired range (min to max)
  return min + (max - min) * skewedRandom
end
