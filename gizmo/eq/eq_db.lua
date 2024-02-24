if not itemData then
  -- Global table to hold all item data
  itemData = {}
  -- Load items on startup (after scripts have been initialized)
  tempTimer( 0, [[loadAllItems()]] )
end
-- Load all items from the Item table into a globally-accessible table indexed by item name
function loadAllItems()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( "C:/Dev/mud/gizmo/data/gizwrld.db" )

  if not conn then
    iout( "{EC}eq_db.lua{RC} failed database connection in loadAllItems()" )
    return
  end
  local cur, err = conn:execute( "SELECT name, statsString, antisString, clone, affectsString FROM Item" )
  if not cur then
    iout( "{EC}eq_db.lua{RC} failed query in loadAllItems(): {err}" )
    conn:close()
    env:close()
    return
  end
  local row = cur:fetch( {}, "a" )
  while row do
    local trimmedName = trimItemName( row.name )
    itemData[trimmedName] = {
      name = row.name,
      nameTrimmed = trimmedName,
      nameLength = #row.name,
      clone = row.clone == 1,
      statsString = row.statsString,
      antisString = row.antisString,
      affectsString = row.affectsString,
      hasSpec = itemHasSpec( trimmedName )
    }
    row = cur:fetch( row, "a" )
  end
  cur:close()
  conn:close()
  env:close()
  -- Only needed at load/reload
  loadAllItems = nil
end

-- Triggered by items seen in game (e.g., worn by players), this function pulls stats from the global
-- itemData table and appends them to the item's name in the game window
function itemQueryAppend()
  local itemName        = matches[2]
  local itemNameTrimmed = trimItemName( itemName )
  local itemNameLength  = #itemName

  -- Colorize the item and any flags
  selectString( itemName, 1 )
  fg( "slate_gray" )
  selectString( "glowing", 1 )
  fg( "gold" )
  selectString( "humming", 1 )
  fg( "olive_drab" )
  selectString( "cloned", 1 )
  fg( "royal_blue" )
  resetFormat()

  local item = itemData[itemNameTrimmed]

  -- Proceed if the item was found
  if item then
    -- Some shorthanded color codes
    local sc       = "<sea_green>"   -- Item stats
    local ec       = "<ansi_cyan>"   -- +Affects
    local cc       = "<steel_blue>"  -- Cloneability
    local spc      = "<ansi_yellow>" -- Proc
    local ac       = "<firebrick>"   -- Antis

    -- Padding for alignment
    local padding  = string.rep( " ", 46 - itemNameLength )

    -- Build display string from stats & cloneable flag
    local specTag  = item.hasSpec and f " {spc}ƒ{R}" or ""
    local cloneTag = item.clone and f " {cc}c{R}" or ""
    local stats    = item.statsString and f "{sc}{item.statsString}{R}" or ""
    -- Add a space if strings don't start with a sign (looks nicer, usually weapons)
    if not string.match( stats, "^[+-]" ) then stats = " " .. stats end
    -- Display basic string or add additional details based on query mode
    local display_string
    if itemQueryMode == 0 then
      display_string = f "{padding}{stats}{cloneTag}{specTag}"
    elseif itemQueryMode == 1 and (stats ~= "") then
      -- Add effects and anti-flags when mode == 1
      local effects = item.affectsString and f " {ec}{item.affectsString}{R}" or ""
      local antis   = item.antisString or ""
      -- If there's an anti-string and a customize function is defined, use it
      if #antis >= 1 and customizeAntiString then
        antis = customizeAntiString( antis )
        antis = f " {ac}{antis}{R}"
      end
      display_string = f "{padding}{stats}{cloneTag}{specTag}{effects}{antis}"
    end
    -- Print the final string to the game window (appears after stat'd item)
    if display_string then
      cecho( display_string )
    end
  end
end

-- Trim "flags" from the end of in-game items to create shorter, sanitized item names;
-- e.g., The Sword of Truth (glowing) (humming) -> The Sword of Truth
function trimItemName( name )
  -- Look for known flags
  local flags = {"%(glowing%)", "%(humming%)", "%(invisible%)", "%(cloned%)", "%(lined%)"}

  -- Strip them off the end of the name
  for _, flag in ipairs( flags ) do
    name = string.gsub( name, flag, '' )
  end
  -- Item names can also vary when they are modified by jewelcrafting (e.g., with a buckle);
  -- here we trim that content so we can match the raw name in the database
  name = string.gsub( name, ' with %w+ %w+ buckle', '' )
  return trim( name )
end

-- Inefficient method for determining if an item has a special proc (reconnect to the db and look at ID text)
function itemHasSpec( item_name )
  -- Connect to the database
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn, cerr = env:connect( "C:/Dev/mud/gizmo/data/gizwrld.db" )

  if not conn then
    iout( "{EC}eq_db.lua{RC} failed database connection in itemHasSpec()" )
    return false
  end
  -- Prepare and execute the query
  local query = string.format( [[SELECT identifyText FROM Item WHERE name = '%s']], item_name:gsub( "'", "''" ) )
  local cur, qerr = conn:execute( query )

  if not cur then
    iout( "{EC}eq_db.lua{RC} failed query in itemHasSpec(): {query}" )
    conn:close()
    env:close()
    return false
  end
  -- Fetch the result
  local result = cur:fetch( {}, "a" )
  cur:close()
  conn:close()
  env:close()

  -- Check for 'RSPEC' in full_id
  if result and result.identifyText and string.find( result.identifyText, "RSPEC" ) then
    return true
  else
    return false
  end
end

-- Deprecated to eliminate runtime dependency on the database; if for some reason you want to continue using this
-- method just remove the local qualifier and change the function name (and don't call loadAllItems)
local function itemQueryAppendDatabase()
  -- Capture the item name from Mudlet's regex array and a trimmed version for query-matching
  local itemName        = matches[2]
  local itemNameTrimmed = trimItemName( itemName )
  local itemNameLength  = #itemName

  -- Colorize the item and any flags
  selectString( itemName, 1 )
  fg( "slate_gray" )
  selectString( "glowing", 1 )
  fg( "gold" )
  selectString( "humming", 1 )
  fg( "olive_drab" )
  selectString( "cloned", 1 )
  fg( "royal_blue" )
  resetFormat()

  -- Connect to local db
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn, cerr = env:connect( "C:/Dev/mud/gizmo/data/gizwrld.db" )

  if not conn then
    iout( "{EC}eq_db.lua{RC} failed database connection in itemQueryAppend()" )
    return
  end
  -- Query for the item's stats, antis, and cloneability values
  local query = string.format(
    [[SELECT name, statsString, antisString, clone, affectsString FROM Item WHERE name = '%s']],
    itemNameTrimmed:gsub( "'", "''" ) )
  local cur, qerr = conn:execute( query )

  if not cur then
    iout( "{EC}eq_db.lua{RC} failed query: {query}" )
    conn:close()
    env:close()
    return
  end
  local item = cur:fetch( {}, "a" )

  cur:close()
  conn:close()
  env:close()

  if item then
    -- Some shorthanded color codes
    local sc      = "<sea_green>"   -- Item stats
    local ec      = "<ansi_cyan>"   -- +Affects
    local cc      = "<steel_blue>"  -- Cloneability
    local spc     = "<ansi_yellow>" -- Proc
    local ac      = "<firebrick>"   -- Antis

    -- Padding for alignment
    local padding = string.rep( " ", 46 - itemNameLength )
    longest_eq    = longest_eq or 0
    if #itemNameTrimmed > longest_eq then longest_eq = #itemNameTrimmed end
    -- Build display string from stats & cloneable flag
    local display_string = nil
    local specTag        = itemHasSpec( itemNameTrimmed ) and f " {spc}ƒ{R}" or ""
    local cloneTag       = item.clone == 1 and f " {cc}c{R}" or ""
    local stats          = item.statsString and f "{sc}{item.statsString}{R}" or ""
    -- Add a space if strings don't start with a sign (looks nicer, usually weapons)
    if not string.match( stats, "^[+-]" ) then stats = " " .. stats end
    -- Display basic string or add additional details based on query mode
    if itemQueryMode == 0 then
      display_string = f "{padding}{stats}{cloneTag}{specTag}"
    elseif itemQueryMode == 1 and (stats ~= "") then
      -- Add effects and anti-flags when mode == 1
      local effects, antis = nil, nil
      effects              = item.affectsString and f " {ec}{item.affectsString}{R}" or ""
      antis                = item.antisString or ""
      -- If there's an anti-string and a customize function is defined, use it
      if #antis >= 1 and customizeAntiString then
        antis = customizeAntiString( antis )
        antis = f " {ac}{antis}{R}"
      end
      display_string = f "{padding}{stats}{cloneTag}{specTag}{effects}{antis}"
    end
    -- Print the final string to the game window (appears after stat'd item)
    if display_string ~= "" then
      cecho( display_string )
    end
  end
end
