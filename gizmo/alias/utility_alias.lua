--- utility_alias.lua
--- Aliases related to session management, script manipulation, Lua functionality, UI/UX, etc.


-- Create the party console, open chat & info windows
function aliasPlayGizmo()
  tempTimer( 0.5, [[openOutputWindows()]] )
  tempTimer( 1.5, [[createPartyConsole()]] )
end --function

-- Compile and execute a lua function directly from the command-line; used
-- throughout other scripts and in aliases as 'lua <command> <args>'
function runLuaLine( args )
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
  local run_func =

      function ( ... )
        if not table.is_empty( { ... } ) then
          display( ... )
        end
      end

  -- Call it
  run_func( func() )
end --function
