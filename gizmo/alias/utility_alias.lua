--- utility_alias.lua
--- Aliases related to session management, script manipulation, Lua functionality, UI/UX, etc.

-- In the main session, 'cls' also clears the info windows; clearUserWindow()
-- seems inconsistent unless new output is also sent to these windows
function aliasClearScreens()
  clearUserWindow()

  if session == 1 then
    local clear_str = "\n"

    clearUserWindow("info")
    --clearUserWindow( "chat" )

    cecho("info", clear_str .. clear_str)
    --cecho( "chat", clear_str .. clear_str )
  end --if
end   --function

-- Create the party console, open chat & info windows
function aliasPlayGizmo()
  tempTimer(0.5, [[openOutputWindows()]])
  tempTimer(1.5, [[createPartyConsole()]])
end --function

-- Compile and execute a lua function directly from the command-line; used
-- throughout other scripts and in aliases as 'lua <command> <args>'
function runLuaLine(args)
  -- Try to compile an expression.
  local func, err = loadstring("return " .. args)

  -- If that fails, try a statement.
  if not func then
    func, err = assert(loadstring(args))
  end

  -- If that fails, raise an error.
  if not func then
    error(err)
  end

  -- Create the function
  local run_func =

      function(...)
        if not table.is_empty({ ... }) then
          display(...)
        end
      end

  -- Call it
  run_func(func())
end --function
