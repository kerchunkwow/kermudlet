function trimName( name )
  -- Trim the "flags" from the end of an item name (along with any excess whitespace)

  -- [NOTE] Glowing, humming, and invisible flags are technically permanent so this isn't precisely
  -- needed; but it does make for shorter names which is nice.

  -- Look for these flags
  local flags = {"%(glowing%)", "%(humming%)", "%(invisible%)", "%(cloned%)", "%(lined%)"}

  -- Strip them off the end of the name
  for _, flag in ipairs( flags ) do
    -- The second return value of gsub is the number of substitutions made,
    -- which we don't need, so it's ignored with _
    name = string.gsub( name, flag, '' )
  end
  -- Make sure we didn't leave any whitespace behind
  name = string.match( name, "^%s*(.-)%s*$" )

  return name
end

function itemQueryAppend( item_name )
  -- Store untrimmed string length for later padding/alignment
  local true_length = #item_name
  item_name = trimName( item_name )

  -- Check if the item is in the ignored list and return immediately if it is
  if ignoredItems[item_name] then
    return
  end
  -- Connect to local item db
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn, cerr = env:connect( "C:/Dev/mud/gizmo/data/gizdb.db" )

  if not conn then
    cecho( "info", "\n<dark_orange>Connection to eq database failed<reset>" )
    return
  end
  -- Query for the item's stats, antis, and cloneability values
  local query = string.format(
    [[SELECT name, stats_str, antis_str, clone, effects_str FROM simple_item WHERE name = '%s']],
    item_name:gsub( "'", "''" ) )
  local cur, qerr = conn:execute( query )

  if not cur then
    cecho( "info", f "\n<dark_orange>Item query failed: {query}<reset>" )
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
    local ec      = "<ansi_cyan>"   -- Effects
    local cc      = "<steel_blue>"  -- Cloneability
    local spc     = "<ansi_yellow>" -- Proc
    local ac      = "<firebrick>"   -- Antis

    -- Padding for alignment
    local padding = string.rep( " ", 32 - true_length )
    longest_eq    = longest_eq or 0
    if #item_name > longest_eq then longest_eq = #item_name end
    -- Build display string from stats & cloneable flag
    local display_string = nil
    local specTag        = itemHasSpec( item_name ) and f " {spc}ƒ{R}" or ""
    local cloneTag       = item.clone == 1 and f " {cc}c{R}" or ""
    local stats          = item.stats_str and f "{sc}{item.stats_str}{R}" or ""
    -- Add a space if strings don't start with a sign (looks nicer, usually weapons)
    if not string.match( stats, "^[+-]" ) then stats = " " .. stats end
    -- Display basic string or add additional details based on query mode
    if itemQueryMode == 0 then
      display_string = f "{padding}{stats}{cloneTag}{specTag}"
    elseif itemQueryMode == 1 and (stats ~= "" or antis ~= "") then
      -- Add effects and anti-flags when mode == 1
      local effects, antis = nil, nil
      effects              = item.effects_str and f " {ec}{item.effects_str}{R}" or ""
      antis                = item.antis_str and f " {ac}{item.antis_str}{R}" or ""
      display_string       = f "{padding}{stats}{cloneTag}{specTag}{effects}{antis}"
    end
    -- Print the final string
    if display_string ~= "" then
      cecho( display_string )
    end
  else
    cecho( "info", string.format( "\nNo item named <medium_orchid>%s<reset>; #add me!", item_name ) )
  end
end

-- Ugly/inefficient solution for checking when an item has RSPEC (special proc)
function itemHasSpec( item_name )
  -- Connect to the database
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn, cerr = env:connect( "C:/Dev/mud/gizmo/data/gizdb.db" )

  if not conn then
    print( "Connection to the database failed" )
    return false
  end
  -- Prepare and execute the query
  local query = string.format( [[SELECT full_id FROM item WHERE name = '%s']], item_name:gsub( "'", "''" ) )
  local cur, qerr = conn:execute( query )

  if not cur then
    print( "Query execution failed" )
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
  if result and result.full_id and string.find( result.full_id, "RSPEC" ) then
    return true
  else
    return false
  end
end
