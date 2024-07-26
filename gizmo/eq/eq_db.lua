if not itemData then
  -- Global table to hold all item data
  itemData = {}
  -- Load items on startup (after scripts have been initialized)
  tempTimer( 0, [[loadAllItems()]] )
end
ItemKeywordCounts = ItemKeywordCounts or nil
-- This function should populate the ItemKeywordCounts table with a count of how many times each individual
-- keyword appears on any item in the LegacyItem table; the goal will be to use this data to identify
-- each item's "optimal" keyword.
function countItemKeywords()
end

-- Load all items from the Item table into a globally-accessible table indexed by item name
function loadAllItems()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( DB_PATH )

  if not conn then
    iout( "{EC}eq_db.lua{RC} failed database connection in loadAllItems()" )
    return
  end
  local cur, err = conn:execute(
    "SELECT name, keywords, statsString, antisString, clone, affectsString FROM LegacyItem" )
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
      keywords = row.keywords,
      keyword = "nil",
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
  countItemKeywords()
  -- For each item in the newly populated item table, use findOptimizedKeyword to determine the best keyword
  for _, item in pairs( itemData ) do
    item.keyword = findOptimizedKeyword( item )
  end
end

ItemKeywordCounts = ItemKeywordCounts or {}
-- This function should populate the ItemKeywordCounts table with a count of how many times each individual
-- keyword appears on any item in the LegacyItem table; the goal will be to use this data to identify
-- each item's "optimal" keyword.
function countItemKeywords()
  -- Initialize ItemKeywordCounts table
  ItemKeywordCounts = {}

  -- Iterate through each item in itemData
  for _, item in pairs( itemData ) do
    -- Split the keywords string into individual keywords
    local keywords = split( item.keywords, " " )

    -- Iterate through each keyword
    for _, keyword in ipairs( keywords ) do
      -- Increment the count for this keyword in ItemKeywordCounts
      ItemKeywordCounts[keyword] = (ItemKeywordCounts[keyword] or 0) + 1
    end
  end
end

function findOptimizedKeyword( item )
  local ic = "<royal_blue>" -- color for the name of the item itself

  -- Colors for the optimized keyword based on frequency
  local uc = "<green_yellow>" -- unique keywords
  local sc = "<goldenrod>"    -- "strong" keywords appearing 3 or fewer times
  local cc = "<orange>"       -- "common" keywords appearing 4 or more times

  -- Split the keywords string into individual keywords
  local keywords = split( item.keywords, " " )

  -- Initialize the best keyword and its count
  local bestKeyword = nil
  local bestCount = math.huge

  -- Iterate through each keyword
  for _, keyword in ipairs( keywords ) do
    -- Get the count for this keyword from ItemKeywordCounts
    local count = ItemKeywordCounts[keyword] or 0

    -- If this keyword has a lower count than the current best keyword, update the best keyword and count
    if count < bestCount then
      bestKeyword = keyword
      bestCount = count
    end
  end
  -- Determine the color based on the count
  local color = uc
  if bestCount > 3 then
    color = cc
  elseif bestCount > 1 then
    color = sc
  end
  -- Print the report using iout()
  iout( f "{ic}{item.name}<reset>: {color}{bestKeyword}<reset> (count: {bestCount})" )

  -- Return the best keyword
  return bestKeyword
end

-- Triggered by items seen in game (e.g., worn by players), this function pulls stats from the global
-- itemData table and appends them to the item's name in the game window
-- local TransferTime = 0
-- local TransferRate = 0.5
--ItemsForTransfer = ItemsForTransfer or {}        -- Ensure it's initialized properly
function itemQueryAppend( itemName )
  --ItemsForTransfer      = ItemsForTransfer or {} -- Ensure it's initialized properly
  itemName              = itemName or matches[2]
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
  selectString( "blue", 1 )
  fg( "medium_slate_blue" )
  resetFormat()

  local item = itemData[itemNameTrimmed]
  -- Proceed if the item was found
  if item then
    local kw       = item.keyword
    kw             = f " (<dark_slate_blue><i>{kw}</i><reset>)"
    -- table.insert( ItemsForTransfer, kw )

    -- Some shorthanded color codes
    local sc       = "<sea_green>"   -- Item stats
    local ec       = "<ansi_cyan>"   -- +Affects
    local cc       = "<steel_blue>"  -- Cloneability
    local spc      = "<ansi_yellow>" -- Proc
    local ac       = "<firebrick>"   -- Antis

    -- Padding for alignment
    local padding  = string.rep( " ", 46 - itemNameLength )

    local antis    = ""

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
      antis         = item.antisString or ""
      -- If there's an anti-string and a customize function is defined, use it
      if #antis >= 1 and customizeAntiString then
        antis = customizeAntiString( antis )
        if #antis > 0 then
          antis = f " {ac}{antis}{R}"
        end
      end
      display_string = f "{padding}{stats}{cloneTag}{specTag}{effects}{antis}{kw}"
    end
    -- Print the final string to the game window (appears after stat'd item)
    if display_string then
      -- Update the old item query append function to start marking items missing from the new
      -- Items table.
      if not Items[itemNameTrimmed] then
        display_string = f "{display_string} <tomato>*<reset>"
      end
      cecho( display_string )
    end
    return true
  end
  return false
end

function itemQueryAppend( itemName )
  itemName              = itemName or matches[2]
  local itemNameTrimmed = trimItemName( itemName )
  local itemNameLength  = #itemName

  abbreviateWorn()

  -- Colorize the item and any flags
  if selectString( itemName, 1 ) > 0 then fg( "slate_gray" ) end
  if selectString( "glowing", 1 ) > 0 then creplace( "<goldenrod>g<reset>" ) end
  if selectString( "humming", 1 ) > 0 then creplace( "<medium_sea_green>h<reset>" ) end
  if selectString( "cloned", 1 ) > 0 then creplace( "<royal_blue>c<reset>" ) end
  if selectString( "blue", 1 ) > 0 then creplace( "<medium_slate_blue>m<reset>" ) end
  resetFormat()
  local item = Items[itemNameTrimmed]
  -- Proceed if the item was found
  if item then
    local kw       = item.keywords[1]
    kw             = f " (<dark_slate_blue><i>{kw}</i><reset>)"
    -- table.insert( ItemsForTransfer, kw )

    -- Some shorthanded color codes
    local sc       = "<sea_green>"   -- Item stats
    local ec       = "<ansi_cyan>"   -- +Affects
    local cc       = "<steel_blue>"  -- Cloneability
    local spc      = "<ansi_yellow>" -- Proc
    local ac       = "<firebrick>"   -- Antis

    -- Padding for alignment
    local padding  = string.rep( " ", 46 - itemNameLength )

    local antis    = ""

    -- Build display string from stats & cloneable flag
    --local specTag  = item.hasSpec and f " {spc}ƒ{R}" or ""
    local cloneTag = item.cloneable and f " {cc}{CLONE_TAG}{RC}" or ""
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
      antis         = item.antisString or ""
      -- If there's an anti-string and a customize function is defined, use it
      if #antis >= 1 and customizeAntiString then
        antis = customizeAntiString( antis )
        if #antis > 0 then
          antis = f " {ac}{antis}{R}"
        end
      end
      --display_string = f "{padding}{stats}{cloneTag}{specTag}{effects}{antis}{kw}"
      display_string = f "{padding}{stats}{cloneTag}{effects}{antis}"
      display_string = highlightTags( display_string )
    end
    -- Print the final string to the game window (appears after stat'd item)
    cecho( display_string )
    return true
  end
  return false
end

function abbreviateWorn()
  if true then return end
  -- Items are either "worn" or "used"
  if selectString( "worn on ", 1 ) > 0 or
      selectString( "used as", 1 ) > 0 or
      selectString( "worn about ", 1 ) > 0 or
      selectString( "worn around ", 1 ) > 0 or
      selectString( "worn as ", 1 ) > 0 then
    replace( "" )
  end
end

-- Inefficient method for determining if an item has a special proc (reconnect to the db and look at ID text)
function itemHasSpec( item_name )
  -- Connect to the database
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn, cerr = env:connect( DB_PATH )

  if not conn then
    iout( "{EC}eq_db.lua{RC} failed database connection in itemHasSpec()" )
    return false
  end
  -- Prepare and execute the query
  local query = string.format( [[SELECT identifyText FROM Item WHERE name = '%s']],
    item_name:gsub( "'", "''" ) )
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

-- Load all items from the Item table into a globally-accessible table indexed by item name
function exportIDStrings()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( DB_PATH )

  if not conn then
    iout( "{EC}eq_db.lua{RC} failed database connection in loadAllItems()" )
    return
  end
  local cur, err = conn:execute( "SELECT identifyText FROM LegacyItem" )
  if not cur then
    iout( "{EC}Error exporting ID strings." )
    conn:close()
    env:close()
    return
  end
  local file = io.open( "C:\\Dev\\mud\\mudlet\\legacyIDStrings.txt", "a" )
  if not file then
    cur:close()
    conn:close()
    env:close()
    return
  end
  local row = cur:fetch( {}, "a" )
  while row do
    -- Write the ID block to an external file named "legacyIDStrings.txt"
    local success, writeErr = file:write( "\n" .. row.identifyText )
    if not success then
      iout( "{EC}Error writing to file: " .. writeErr )
      break
    end
    row = cur:fetch( row, "a" )
  end
  file:close()
  cur:close()
  conn:close()
  env:close()
end

RawItemData = RawItemData or {}
function loadLegacyItems()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( DB_PATH )

  if not conn then
    iout( "{EC}eq_db.lua{RC} failed database connection in loadLegacyItems()" )
    return
  end
  local cur, err = conn:execute( "SELECT * FROM LegacyItem" )
  if not cur then
    iout( "{EC}eq_db.lua{RC} failed query in loadLegacyItems(): " .. err )
    conn:close()
    env:close()
    return
  end
  local row = cur:fetch( {}, "a" )
  while row do
    local id = row.id
    RawItemData[id] = {}
    for k, v in pairs( row ) do
      RawItemData[id][k] = v
    end
    row = cur:fetch( row, "a" )
  end
  cur:close()
  conn:close()
  env:close()
end

-- This function is designed to help develop a prize/reward structure for players who submit items to
-- be identified by the new item identification bot system; it iterates through the legacy items and
-- performs math on various item attributes to try and determine reasonable prize scales for different
-- item types.
function planBotPrizes( itemType, attribute, basePrize, prizeMultiplier )
  local totalPrizes    = 0
  local itemCount      = 0
  local totalAttribute = 0

  -- Function to get the multiplier for a given attribute value
  local function getMultiplier( value )
    for _, entry in ipairs( prizeMultiplier ) do
      if value < entry.threshold then
        return entry.multiplier
      end
    end
    return 1 -- Default multiplier
  end

  for id, item in pairs( RawItemData ) do
    if item["baseType"] == itemType then
      cout( f "{SC}{item.name}{RC} ({attribute})" )
    end
    if item[attribute] and item[attribute] ~= 0 then
      cout( f "<orange>{item[attribute]}" )
      local attrValue = item[attribute]
      itemCount = itemCount + 1
      totalAttribute = totalAttribute + attrValue
      local multiplier = getMultiplier( attrValue )
      local thisPrize = (basePrize * multiplier) * attrValue
      -- Get some output to check specific values
      if thisPrize > 200000 then
        local prizeString = expandNumber( thisPrize )
        --cout( f "{SC}{item.name}{RC} (<tomato>{attrValue}<reset>) == <gold>{prizeString}<reset>gp" )
      end
      totalPrizes = totalPrizes + thisPrize
    end
  end
  local averageAttribute = (totalAttribute / itemCount)
  local averagePrize     = round( totalPrizes / itemCount, 0.1 )
  averagePrize           = expandNumber( averagePrize )
  totalPrizes            = expandNumber( totalPrizes )
  averageAttribute       = round( averageAttribute, 0.1 )

  hrule( 80, "<dark_slate_grey>" )
  cecho( f "\nTotal Prizes to be Paid: {NC}{totalPrizes}" )
  cecho( f "\nAverage Prize:           {NC}{averagePrize}" )
  cecho( f "\nTotal Number of {itemType}s: {NC}{itemCount}" )
end

function getItemBounty( item )
  -- An item's "prize key" is based on its item type and represents the most important aspects of an item in that category
  local prizeKey = 0
  if item.baseType == "ARMOR" then
    prizeKey = item.ac + item.armor
  elseif item.baseType == "WEAPON" then
    prizeKey = item.averageDamage
  elseif item.baseType == "TREASURE" then
    prizeKey = item.value
  elseif item.baseType == "LIGHT" or item.baseType == "WORN" or item.baseType == "MUSICAL" then
  end
end

function findNonKeywords()
  -- Create a local table named "allNameWords"
  local allNameWords = {}

  -- Iterate over RawItemData and split each item's name into words
  for _, item in pairs( RawItemData ) do
    if item.name and item.name ~= "" then
      -- lower the item name for case insensitivity
      local itm = item.name:lower()
      for word in itm:gmatch( "%S+" ) do
        if not allNameWords[word] then
          allNameWords[word] = true
        end
      end
    end
  end
  -- Count the size of allNameWords
  local allNameWordsSize = 0
  for _ in pairs( allNameWords ) do
    allNameWordsSize = allNameWordsSize + 1
  end
  cecho( "\nSize of allNameWords: " .. allNameWordsSize )

  -- Create a list named nonKeywords
  local nonKeywords = {}

  -- Check ItemKeywords[word] for every word in allNameWords
  for word in pairs( allNameWords ) do
    if not ItemKeywords[word] then
      cout( word )
      table.insert( nonKeywords, word )
    end
  end
  -- Display the nonKeywords list

  --display( nonKeywords )
  cecho( "\nSize of nonKeywords: " .. #nonKeywords )
end

-- Format and print large bounties
-- @param bigBounties The list of items with large bounties
-- @param longestLine The length of the longest report name
local function displayLargeBounties( bigBounties, longestLine )
  cecho( "\n\nLarge Bounties:\n" )
  for _, entry in ipairs( bigBounties ) do
    local reportName = f "{entry.name} ({entry.baseType})"
    local padding = string.rep( " ", longestLine - #reportName )
    reportName = "<dodger_blue>" .. reportName
    reportName = reportName:gsub( "%(", "<reset>(<dark_slate_grey>" )
    reportName = reportName:gsub( "%)", "<reset>)" )
    cecho( f "\n{reportName}{padding} <gold>{expandNumber(entry.bounty)}<reset>" )
  end
end

-- Print summary statistics
-- @param totalBounty The total bounty value
-- @param averageBounty The average bounty value
-- @param itemCount The total number of items
local function displaySummary( totalBounty, averageBounty, itemCount )
  totalBounty   = expandNumber( totalBounty )
  averageBounty = round( averageBounty, 1000 )
  averageBounty = expandNumber( averageBounty )
  hrule( 80, "<dark_slate_grey>" )
  cecho( f "\nTotal Payout:   {NC}{totalBounty}" )
  cecho( f "\nAverage Reward: {NC}{averageBounty}" )
  cecho( f "\nTotal Items:    {NC}{itemCount}" )
end

-- Print a detailed summary by item type of the bounties paid out for that particular category
local function printDetailedBountySummary()
  local typeSummary = {}

  for id, item in pairs( RawItemData ) do
    local itemBounty = calculateItemBounty( item )
    local itemType = item.baseType

    if not typeSummary[itemType] then
      typeSummary[itemType] = {
        count = 0,
        totalBounty = 0,
        highestBounty = 0,
        mostValuableItem = {name = "", bounty = 0}
      }
    end
    typeSummary[itemType].count = typeSummary[itemType].count + 1
    typeSummary[itemType].totalBounty = typeSummary[itemType].totalBounty + itemBounty

    if itemBounty > typeSummary[itemType].mostValuableItem.bounty then
      typeSummary[itemType].mostValuableItem.name = item.name
      typeSummary[itemType].mostValuableItem.bounty = itemBounty
    end
  end
  cecho( "\n\nDetailed Bounty Summary:\n" )

  for itemType, summary in pairs( typeSummary ) do
    local typeName = itemType or "UNKNOWN"
    local most = expandNumber( summary.mostValuableItem.bounty )
    local best = summary.mostValuableItem.name
    local total = expandNumber( summary.totalBounty )
    hrule( 60, "<dark_slate_grey>" )
    cout( "Type:           {SC}{typeName}{RC}" )
    cout( "Total Items:    {NC}{summary.count}{RC}" )
    cout( "Total Bounty:   {NC}{total}{RC}" )
    cout( "Best Item:      {SC}{best}{RC} (<gold>{most}{RC})" )
    --displayItemBountyDetails( best )
  end
end

local function displayItemBountyDetails( itemName )
  local item = nil

  -- Look up the item by name in RawItemData
  for _, data in pairs( RawItemData ) do
    if data.name == itemName then
      item = data
      break
    end
  end
  if not item then
    cecho( f( "{BOTERR} Item {itemName} not found.\n" ) )
    return
  end
  cecho( f( "\nBounty Calculation for {dodger_blue}{item.name}{reset}:\n" ) )
  local totalBounty = 0

  for attribute, baseline in pairs( BOUNTY_VALUES ) do
    if item[attribute] then
      local value = item[attribute]
      local bounty = value * baseline
      bounty = adjustBounty( bounty, item.baseType, attribute )
      cecho( f( "{attribute}: {NC}{value} x {baseline} = {bounty}\n" ) )
      totalBounty = totalBounty + bounty
    end
  end
  cecho( f( "\nTotal Bounty for {dodger_blue}{item.name}{reset}: {NC}{expandNumber(totalBounty)}\n" ) )
end

-- The goal of this function is to work with the BOUNTY_VALUES table and thresholds above
-- to determine a "prize structure" for paying out rewards to players who contribute items
-- to identify; its important to know how much potential gold I will be paying so I don't
-- accidentally go broke.
local function calculateItemBounties()
  local bigBounty = 200000
  local bigBounties = {}
  local longestLine = 0
  local totalBounty = 0
  local itemCount = 0

  for id, item in pairs( RawItemData ) do
    local itemBounty = calculateItemBounty( item )
    totalBounty = totalBounty + itemBounty
    itemCount = itemCount + 1

    if itemBounty > bigBounty then
      local reportName = f "{item.name} ({item.baseType})"
      local ilen = #reportName
      if ilen > longestLine then
        longestLine = ilen
      end
      table.insert( bigBounties, {name = item.name, baseType = item.baseType, bounty = itemBounty} )
    end
  end
  local averageBounty = totalBounty / itemCount
  -- displayLargeBounties( bigBounties, longestLine )
  -- displaySummary( totalBounty, averageBounty, itemCount )
end
