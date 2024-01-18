cecho( f '\n\t<yellow_green>lib.lua<reset>: entry to libraries for common/shared functions' )

-- Use {dbc} whenever you're printing an error or important information with cecho()
dbc = "<orange_red>"
sureCastTrigger = nil

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
function runLuaFile( filePath )
  if lfs.attributes( filePath, "mode" ) == "file" then
    --cecho( f "\nLoading: <dim_grey>{filePath}<reset>" )
    dofile( filePath )
  else
    cecho( f "\n{dbc}{filePath}<reset> not found." )
  end
end

-- Use runLuaFile to run a table of Lua files
function runLuaFiles( filePaths )
  for _, filePath in ipairs( filePaths ) do
    runLuaFile( f "{rootDirectory}{filePath}" )
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

-- Round n to the nearest s
function round( n, s )
  s = s or 0.05
  return math.floor( n / s + 0.5 ) * s
end

function saveTable( tblStr )
  local tbl = _G[tblStr]
  if tbl then
    table.save( f "{rootDirectory}data/{tblStr}.lua", tbl )
  else
    cecho( f "<dark_orange>No such table<reset>: {tblStr}" )
  end
end

function loadTable( tblStr )
  local filePath = f "{rootDirectory}data/{tblStr}.lua"
  table.load( filePath, _G[tblStr] )
end

-- Load all the sub-libraries
runLuaFile( f '{rootDirectory}lib/lib_gui.lua' )
-- runLuaFile( f '{rootDirectory}lib/lib_moblist.lua' )
runLuaFile( f '{rootDirectory}lib/lib_react.lua' )
runLuaFile( f '{rootDirectory}lib/lib_string.lua' )
runLuaFile( f '{rootDirectory}lib/lib_wintin.lua' )

--[[
GitHub Copilot, ChatGPT notes:
Collaborate on Lua 5.1 scripts for Mudlet in VSCode. Use f-strings, camelCase, UPPER_CASE constants.
Prioritize performance, optimization, and modular design. Provide debugging output with cecho.
Be critical, suggest improvements, don't apologize for errors.
Respond concisely, treat me as a coworker.
]]
