-- Redefine this here so VSCode recognizes it
function runLuaFile( luaFile )
  local filePath = rootDirectory .. luaFile
  if lfs.attributes( filePath, "mode" ) == "file" then
    dofile( filePath )
  else
    error( filePath .. " not found." )
  end
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
