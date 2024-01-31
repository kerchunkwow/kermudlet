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
  -- Trim/remove any modifications added by "jewelcrafting"
  name = string.gsub( name, ' with %w+ %w+ buckle', '' )
  return trim( name )
end

function itemQueryAppend()
  itemName = matches[2]
  -- Store untrimmed string length for later padding/alignment
  local true_length = #itemName
  selectString( itemName, 1 )
  fg( "slate_gray" )
  selectString( "glowing", 1 )
  fg( "gold" )
  selectString( "humming", 1 )
  fg( "olive_drab" )
  selectString( "cloned", 1 )
  fg( "royal_blue" )
  resetFormat()
  itemShortName = trimName( itemName )

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
    itemShortName:gsub( "'", "''" ) )
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
    local ec      = "<ansi_cyan>"   -- +Affects
    local cc      = "<steel_blue>"  -- Cloneability
    local spc     = "<ansi_yellow>" -- Proc
    local ac      = "<firebrick>"   -- Antis

    -- Padding for alignment
    local padding = string.rep( " ", 46 - true_length )
    longest_eq    = longest_eq or 0
    if #itemShortName > longest_eq then longest_eq = #itemShortName end
    -- Build display string from stats & cloneable flag
    local display_string = nil
    local specTag        = itemHasSpec( itemShortName ) and f " {spc}ƒ{R}" or ""
    local cloneTag       = item.clone == 1 and f " {cc}c{R}" or ""
    local stats          = item.stats_str and f "{sc}{item.stats_str}{R}" or ""
    -- Add a space if strings don't start with a sign (looks nicer, usually weapons)
    if not string.match( stats, "^[+-]" ) then stats = " " .. stats end
    -- Display basic string or add additional details based on query mode
    if itemQueryMode == 0 then
      display_string = f "{padding}{stats}{cloneTag}{specTag}"
    elseif itemQueryMode == 1 and (stats ~= "") then
      -- Add effects and anti-flags when mode == 1
      local effects, antis = nil, nil
      effects              = item.effects_str and f " {ec}{item.effects_str}{R}" or ""
      antis                = item.antis_str or ""
      -- If there's an anti-string and a customize function is defined, use it
      if #antis >= 1 and customizeAntiString then
        antis = customizeAntiString( antis )
        antis = f " {ac}{antis}{R}"
      end
      display_string = f "{padding}{stats}{cloneTag}{specTag}{effects}{antis}"
    end
    -- Print the final string
    if display_string ~= "" then
      cecho( display_string )
    end
  else
    --cecho( "info", string.format( "\nNo item named <medium_orchid>%s<reset>; #add me!", itemShortName ) )
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
