-- Called when sysPathChanged events fire on files which were registered by addFileWatchers()
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

registerAnonymousEventHandler( 'sysPathChanged', fileModifiedEvent )
