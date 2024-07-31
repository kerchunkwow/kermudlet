--[[ libdata.lua
A module to manage the loading, saving, and backup of various data files related to Gizmo MUD.
--]]

DATA_PATH = [[C:/Dev/mud/mudlet/gizmo/data/]]

-- A temporary dummy function to help the rest of the file recognize data types etc.
local function tableDefinitions()
  Items            = {}
  RejectedItems    = {}
  StaticItems      = {}
  LoggedLoot       = {}
  CommonKeywords   = {}
  PotionAffects    = {}
  KnownPlayers     = {}
  PlayerContainers = {}
  ItemKeywords     = {}
end

DATA_FILES = {
  "Items",
  "RejectedItems",
  "StaticItems",
  "LoggedLoot",
  "CommonKeywords",
  "PotionAffects",
  "KnownPlayers",
  "PlayerContainers",
  "ItemKeywords",
}

-- A wrapper for Mudlet's table.save() that prevents data loss by checking the outgoing
-- table against the existing one and only saves tables with at least the same number
-- of entries.
function saveSafe( path, tbl )
  local oldTbl = {}
  table.load( path, oldTbl )
  if not oldTbl or next( oldTbl ) == nil then
    table.save( path, tbl )
    return
  end
  local oldCount, newCount = table.size( oldTbl ), table.size( tbl )
  if newCount >= oldCount then
    table.save( path, tbl )
  end
end

-- Attempt to save all data files; skip any which are empty or smaller than the existing
-- file.
function saveDataFiles()
  for _, tblName in ipairs( DATA_FILES ) do
    local tbl = _G[tblName]
    if next( tbl ) == nil then
      cout( f '\nAttempted to save {EC}empty{RC} table: {tblName}.' )
    else
      saveSafe( f '{DATA_PATH}/{tblName}.lua', tbl )
    end
  end
end

-- Load data for any file not currently loaded (nil or empty table); if all is true,
-- force a reload of all files
function loadDataFiles( all )
  for _, tblName in ipairs( DATA_FILES ) do
    local tblEmpty = not _G[tblName] or next( _G[tblName] ) == nil
    if tblEmpty or all then
      _G[tblName] = {}
      table.load( f '{DATA_PATH}/{tblName}.lua', _G[tblName] )
    end
  end
end

loadDataFiles()
-- Backup data for any table modified since the last backup; if all is true, backup all tables
-- Reset the msb flag for each table after backing up
function backupDataFiles()
  for _, tblName in ipairs( DATA_FILES ) do
    local src = f '{DATA_PATH}/{tblName}.lua'
    local dest = f '{BACKUP_PATH}/{tblName}.lua'
    local success, err = backupFile( src, dest )
    if success then
      iout( f 'Backup created successfully for {tblName}' )
    else
      iout( f 'Error creating backup for {tblName}: {err}' )
    end
  end
end

-- Insert data into one of the custom data tables; set the msb and mss flags for the table in question in FILE_STATUS
function insertData( tblName, key, value )
  cout( f '<chartreuse>Inserting{RC}: {SC}{key}{RC} into <yellow_green>{tblName}<reset>' )
  _G[tblName][key] = value
end

-- Wrapper for insertData to add a player container to the PotionAffects table
function addPotionAffect( potionName, affectString )
  local pot, aff = matches[2], matches[3]
  if pot and aff then
    insertData( "PotionAffects", pot, aff )
  end
end

-- Wrapper for insertData to add a player container to the KnownPlayers table
function addKnownPlayer( playerName )
  insertData( "KnownPlayers", playerName, true )
end

-- Copy a file from one location to another using the 'copy' command in Windows
function copyFile( src, dest )
  local command = string.format( 'copy "%s" "%s"', src, dest )
  local result = os.execute( command )
  if result == 0 then
    return true
  else
    return false, "Failed to copy file"
  end
end

-- Using copyFile, create a copy of a source file while appending a timestamp with getCurrentTime()
-- in order to create a unique timestamped backup of a file
function backupFile( src, dest )
  local timestamp = getCurrentTime( "%Y%m%d%H%M%S" )
  local destWithTimestamp = dest:gsub( "(%.[^%.]+)$", "_" .. timestamp .. "%1" )
  return copyFile( src, destWithTimestamp )
end

function saveStaticItems()
  table.save( f '{HOME_PATH}/gizmo/data/static_items.lua', StaticItems )
end

function printCustomDataTable( tbl )
  for k, v in pairs( tbl ) do
    cecho( f "\n<royal_blue>{k}<reset> = <violet>{v}<reset>" )
  end
end

-- When a potion is seen in-game, append its affect data to the end of the line
function appendPotionAffect()
  local obj = trim( matches[2] )
  local vr, meo = "<violet_red>", "<medium_orchid>"
  if PotionAffects[obj] then
    local aff = PotionAffects[obj]
    aff = f " {vr}[{meo}{aff}{vr}]{RC}"
    cecho( aff )
  end
end
