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

-- Redefine this here so VSCode recognizes it
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
    runLuaFile( f "{file}" )
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

-- Ensure all changes to global external functions are pulled into Mudlet by undefining all functions before a reload
local function unfunctionAll()
  for _, funcName in ipairs( allFunctions ) do
    if type( _G[funcName] ) == "function" then
      _G[funcName] = nil
    end
  end
  allFunctions = {}
end

-- Load all the sub-libraries
runLuaFile( 'lib/lib_gui.lua' )
runLuaFile( 'lib/lib_react.lua' )
runLuaFile( 'lib/lib_string.lua' )
runLuaFile( 'lib/lib_wintin.lua' )
