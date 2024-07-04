-- Common to all sessions
local commonScripts = {
  'gizmo/config/config_gizmo.lua',
  'gizmo/react/react_trigger.lua',
  'gizmo/react/react_alias.lua',
  'gizmo/react/react_undead.lua',
  'gizmo/config/config_events.lua',
  'gizmo/gui/gui_warn.lua',
  'gizmo/eq/item_const.lua',
  'gizmo/eq/item_data.lua',
  'gizmo/eq/item_capture.lua',
  'gizmo/eq/eq_db.lua',
  'gizmo/status/status_affect.lua',
  'gizmo/map/map_const.lua',
  'gizmo/map/map_ux.lua',
  'gizmo/map/data/map_dirs.lua',
  'gizmo/map/data/map_doors.lua',
  'gizmo/map/data/map_unique.lua',
  'gizmo/map/map_queue.lua',
  'gizmo/map/map_main.lua',
  'gizmo/status/status_parse.lua',
  '/gizmo/eq/item_const.lua',
}

-- Specific to the main session
local mainScripts = {
  'gizmo/gui/gui_create.lua',
  'gizmo/gui/gui.lua',
  'gizmo/status/status_update.lua',
  'gizmo/map/map_mobs.lua',
  'gizmo/map/map_path.lua',
}

runLuaFiles( commonScripts )

if SESSION == 1 or SESSION == 2 then
  runLuaFiles( mainScripts )
end
if SESSION == 2 then
  runLuaFile( 'gizmo/eq/eq_cloner.lua' )
end
-- Using Powershell, delete and re-extract the Mudlet module's XML file, then convert
-- it to a Lua file that your IDE can interpret.
function refreshModuleXML()
  local modulePath  = "C:/Dev/mud/mudlet/gizmo/gizmudlet2.mpackage"
  local tempZipPath = "C:/Dev/mud/mudlet/gizmo/gizmudlet2.zip"
  local xmlPath     = "C:/Dev/mud/mudlet/gizmo/gizmudlet2.xml"
  local extractDir  = "C:/Dev/mud/mudlet/gizmo/temp_extract"

  -- If there's already a copy of the .xml present, delete it first
  os.remove( xmlPath )

  -- Copy/rename the .mpackage file to a .zip file
  os.execute( 'copy "' .. modulePath:gsub( '/', '\\' ) .. '" "' .. tempZipPath:gsub( '/', '\\' ) .. '"' )

  -- Extract everything from the .zip to a temporary directory
  local extractCmd = 'powershell -command "Expand-Archive -LiteralPath \'' ..
      tempZipPath:gsub( '/', '\\' ) .. '\' -DestinationPath \'' .. extractDir:gsub( '/', '\\' ) .. '\' -Force"'
  os.execute( extractCmd )

  -- Relocate the .xml and delete the temporary stuff
  local moveCmd = 'move "' .. extractDir:gsub( '/', '\\' ) .. '\\gizmudlet2.xml" "' .. xmlPath:gsub( '/', '\\' ) .. '"'
  os.execute( moveCmd )
  os.remove( tempZipPath )
  os.execute( 'rmdir "' .. extractDir:gsub( '/', '\\' ) .. '" /s /q' )

  -- Now run the parser to generate the Lua-equivalent of the XML, keeping the PowerShell window open
  os.execute( 'powershell -command "python \\"C:/Dev/mud/mudlet/parse_xml.py\\""' )
  os.remove( xmlPath )
end

-- Once the final session is finished loading, alert the Main session to initialize the GUI
if SESSION == 1 then tempTimer( 0, [[raiseEvent( 'eventProfilesLoaded' )]] ) end
