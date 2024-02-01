-- Common to all sessions
local commonScripts = {
  'gizmo/react/react_trigger.lua',
  'gizmo/react/react_alias.lua',
  'gizmo/config/config_local.lua',
  'gizmo/config/config_shared.lua',
  'gizmo/config/config_events.lua',
  'gizmo/gui/gui_warn.lua',
  'gizmo/eq/eq_db.lua',
  'gizmo/status/status_affect.lua',
  'gizmo/map/map_const.lua',
  'gizmo/map/map_ux.lua',
  'gizmo/map/data/map_dirs.lua',
  'gizmo/map/data/map_doors.lua',
  'gizmo/map/data/map_unique.lua',
  'gizmo/map/map_queue.lua',
  'gizmo/map/map_main.lua',
}

-- Specific to the main session
local mainScripts = {
  'gizmo/gui/gui_create.lua',
  'gizmo/gui/gui.lua',
  'gizmo/status/status_update.lua',
  'gizmo/status/status_parse_main.lua',
  'gizmo/eq/eq_inventory.lua',
}

-- Specific to alt sessions
local altScripts = {
  'gizmo/status/status_parse_alt.lua',
}

runLuaFiles( commonScripts )

if SESSION == 1 then
  runLuaFiles( mainScripts )
else
  runLuaFiles( altScripts )
end
-- Using Powershell, delete and re-extract the Mudlet module's XML file so it is
-- visible to global searches (nice to know when you rename or redefine something)
-- that is being referenced from within Mudlet.
function refreshModuleXML()
  local modulePath  = "C:/Dev/mud/mudlet/gizmo/gizmudlet.mpackage"
  local tempZipPath = "C:/Dev/mud/mudlet/gizmo/gizmudlet.zip"
  local xmlPath     = "C:/Dev/mud/mudlet/gizmo/gizmudlet.xml"

  -- Delete the existing XML file
  os.remove( xmlPath )

  -- Copy the .mpackage file to a .zip file
  os.execute( 'copy "' .. modulePath:gsub( '/', '\\' ) .. '" "' .. tempZipPath:gsub( '/', '\\' ) .. '"' )

  -- Extract the XML file from the temporary .zip file
  local extractCmd = 'powershell -command "Expand-Archive -LiteralPath \'' ..
      tempZipPath:gsub( '/', '\\' ) .. '\' -DestinationPath \'C:/Dev/mud/mudlet/gizmo\' -Force"'

  os.execute( extractCmd )

  -- Delete the temporary .zip file
  os.remove( tempZipPath )
end
