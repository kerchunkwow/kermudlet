-- Functions for interacting with the equipment database

function trimName( name )
  -- Trim the "flags" from the end of an item name (along with any excess whitespace)

  -- [NOTE] Glowing, humming, and invisible flags are technically permanent so this isn't precisely
  -- needed; but it does make for shorter names which is nice.

  -- Look for these flags
  local flags = {"%(glowing%)", "%(humming%)", "%(invisible%)", "%(cloned%)"}

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
  if ignored_items[item_name] then
    return
  end
  -- Connect to local item db
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn, cerr = env:connect( "C:\\Gizmo\\data\\gizdb.db" )

  if not conn then
    cecho( "info", "\n<dark_orange>;Connect to item db failed<reset>" )
    return
  end
  -- Query for the item's stats, antis, and cloneability values
  local query = string.format( [[SELECT name, stats_str, antis_str, clone FROM simple_item WHERE name = '%s']],
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
    -- Some basic formatting and alignment
    local padding = string.rep( " ", 44 - true_length )
    longest_eq = longest_eq or 0
    if #item_name > longest_eq then longest_eq = #item_name end
    -- Build display string from stats &amp; cloneable flag
    local display_string = ""
    local stats = item.stats_str or ""
    local antis = item.antis_str or ""

    local cloneable = " <dodger_blue>!<reset>"
    local clone_indicator = item.clone == 1 and cloneable or ""

    -- Add a space if strings don't have a sign (looks nicer, usually weapons)
    if not string.match( stats, "^[+-]" ) then
      stats = " " .. stats
    end
    if eqmode == 0 and stats ~= "" then
      display_string = padding .. string.format( "<sea_green>%s<reset>%s", stats, clone_indicator )
    elseif eqmode == 1 and (stats ~= "" or antis ~= "") then
      display_string = padding ..
          string.format( "<sea_green>%s<reset> <firebrick>%s<reset>%s", stats, antis,
            clone_indicator )
    end
    -- Print the final string
    if display_string ~= "" then
      cecho( display_string )
    end
  else
    cecho( "info", string.format( "\nNo item named <medium_orchid>%s<reset>; #add me!", item_name ) )
  end
end
