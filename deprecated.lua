---@diagnostic disable: undefined-global, assign-type-mismatch, cast-local-type
-- Highlights key milestones within a specific context such as an important quest
function testPropertyMapping()
  local testAlign = {"good", "neutral", "evil", "goo", "neu", "evi", "go", "ne", "ev"}
  local testClass = {"anti-paladin", "bard", "cleric", "command", "paladin", "ninja", "nomad",
    "thief", "magic-user", "warrior",
    "anti", "bar", "cle", "com", "pal", "nin", "nom", "thi", "mag", "war",
    "ap", "ba", "cl", "co", "pa", "ni", "no", "th", "mag", "wa"}
  local testSex = {"male", "female", "mal", "fem", "ma", "fe"}
  local testWorn = {
    "about",
    "robe",
    "cloak",
    "abo",
    "rob",
    "clo",
    "arms",
    "arm",
    "sleeves",
    "sleeve",
    "body",
    "chest",
    "bod",
    "feet",
    "boots",
    "boot",
    "foot",
    "fingers",
    "finger",
    "fin",
    "rings",
    "rin",
    "ri",
    "hands",
    "gloves",
    "glo",
    "han",
    "head",
    "hold",
    "held",
    "hol",
    "legs",
    "pants",
    "leg",
    "light",
    "torch",
    "torches",
    "lights",
    "neck",
    "necklace",
    "amulet",
    "shield",
    "waist",
    "wield",
    "weapons",
    "weap",
    "wrists",
    "bracelets",
  }
  local align, class, sex, worn = nil, nil, nil, nil
  -- Set align, class, sex, and worn to a random value from each of the local test tables; for each, use "any"
  -- 25% of the time instead of a random value
  if math.random( 1, 5 ) == 1 then align = "" else align = testAlign[math.random( #testAlign )] end
  if math.random( 1, 8 ) == 1 then class = "" else class = testClass[math.random( #testClass )] end
  if math.random( 1, 2 ) == 1 then sex = "" else sex = testSex[math.random( #testSex )] end
  if math.random( 1, 8 ) == 1 then worn = "" else worn = testWorn[math.random( #testWorn )] end
  local function shuffleString( s )
    local n = #s
    for i = n, 2, -1 do
      local j = math.random( i )
      s[i], s[j] = s[j], s[i]
    end
  end
  local function shuffleProperties( a, c, s, w )
    local properties = {a, c, s, w}
    shuffleString( properties )
    local propertyString = table.concat( properties, " " )
    return propertyString
  end
  local propertyString = shuffleProperties( align, class, sex, worn )
  propertyString = trimCondense( propertyString )
  send( f "say find {propertyString}" )
end

-- Define a table called QuestHighlights which is a table of strings; each string may be associated with
-- one or both of an info string and command string; define the table with a sample entry
QuestHighlights = {
  ["You see a rat"] = {info = "A rat is here!", code = "burp"},
}
function highlightQuest( string )
  -- Highlight the triggering string in bright orange on dark purple
  selectString( string, 1 )
  bg( "dark_slate_blue" )
  fg( "goldenrod" )

  -- If the string has info associated with it, use onNextPrompt() to create a trigger with function () that will
  -- cecho that content after the next prompt.
  if QuestHighlights[string].info then
    local info = QuestHighlights[string].info
    onNextPrompt( function ()
      cecho( "\n\t<:dark_slate_blue><goldenrod>" .. {QuestHighlights[string].info} )
      resetFormat()
    end )
  end
  -- If the string has an associated command, use iout to report on the triggered command incl. the triggering text,
  -- then send the command with send().
  if QuestHighlights[string].code then
    local command = QuestHighlights[string].code
    --iout( f "<deep_pink>{cmd} triggered on <royal_blue>{string}<reset>" )
    send( QuestHighlights[string].code, true )
  end
end

-- This function should start by populating tableOfPatterns with the triggering patterns from QuestHighlights
-- It should then use permRegexTrigger() to create a trigger that calls highlightQuest(string) when triggered.
-- The passed parameter should be the string from QuestHighlights.
function createQuestHighlightTriggers()
  local tableOfPatterns = {}

  -- Populate tableOfPatterns with the keys from QuestHighlights
  for pattern, _ in pairs( QuestHighlights ) do
    table.insert( tableOfPatterns, pattern )
  end
  -- Create a single permanent trigger for all patterns
  permRegexTrigger( "Quest Highlights", "", tableOfPatterns, [[
highlightQuest( matches[1] )
]] )
end

-- A temporary function for analyzing item data and identifying the best items in a particular category
function findDesiredItems()
  local lowCounts = {}
  for loc, _ in pairs( WORN ) do
    lowCounts[loc] = 0
  end
  local desiredItems = {}
  for pc, properties in pairs( PLAYER_COMBINATIONS ) do
    local pal = properties.align
    local pse = properties.sex
    local pcl = properties.class
    local player = pal .. " " .. pse .. " " .. pcl
    desiredItems[player] = {}
    for loc, _ in pairs( WORN ) do
      desiredItems[player][loc] = {}
    end
  end
  -- Count how many desirable items are found for each player combination
  for pc, properties in pairs( PLAYER_COMBINATIONS ) do
    local pal = properties.align
    local pse = properties.sex
    local pcl = properties.class
    local player = pal .. " " .. pse .. " " .. pcl
    for desc, item in pairs( Items ) do
      local worn = item.worn
      if desired( item ) and usable( item, pal, pse, pcl ) then
        -- Add the desc of this item to the desiredItems table at the worn location
        table.insert( desiredItems[player][worn], desc )
      end
    end
  end
  -- Display the results of the desired items hunt
  local highestPlayer = nil -- Player combination with the most desired items
  local lowestPlayer  = nil -- Player combination with the fewest desired items
  local totalItems    = 0   -- Total number of desired items across all player combinations
  local playerCounts  = {}  -- Table to store the number of desired items for each player combination

  for player, locs in pairs( desiredItems ) do
    -- Keep track of how many desirable items each player combination has
    local playerCount = 0
    hrule( 60, "dark_slate_blue" )
    local playerString = player:upper()
    playerString = f "<yellow_green>{player}{RC}"
    cecho( f "\n{playerString}\n" )
    for loc, items in pairs( locs ) do
      local count = #items
      playerCount = playerCount + count
      -- Define a local "cc" as "<light_slate_grey>" if count is > 3, otherwise "<deep_pink>";
      -- Useful to highlight low numbers of desired items.
      local cc = count > 1 and "<light_slate_grey>" or "<deep_pink>"
      -- Pad the output to align the counts
      local pad = fill( 8 - #loc )
      if count <= 1 then
        lowCounts[loc] = lowCounts[loc] + 1
        cecho( f "{NC}{loc}{RC}: {cc}{count}{RC} " )
      end
    end
    -- Update highestPlayer and lowestPlayer
    if not highestPlayer or playerCount > playerCounts[highestPlayer] then
      highestPlayer = player
    end
    if not lowestPlayer or playerCount < playerCounts[lowestPlayer] then
      lowestPlayer = player
    end
    -- Store the player count
    playerCounts[player] = playerCount
    -- Update the total number of items
    totalItems = totalItems + playerCount
  end
  -- Calculate the average number of items
  local averagePlayer = totalItems / table.size( PLAYER_COMBINATIONS )

  -- Display aggregate values
  hrule( 60, "dark_slate_blue" )
  cecho( f "\n<gold>Desired Items Summary<reset>\n" )
  cecho( f "<light_slate_grey>Most {RC}: {highestPlayer} with {NC}{playerCounts[highestPlayer]}{RC}\n" )
  cecho( f "<light_slate_grey>Least{RC}: {lowestPlayer} with {NC}{playerCounts[lowestPlayer]}{RC}\n" )
  averagePlayer = round( averagePlayer, 0.1 )
  cecho( f "<light_slate_grey>Avg  {RC}: {NC}{averagePlayer}{RC}\n" )
  display( lowCounts )
end

local function testMapping()
  -- For each item in testItems, generate a random align, sex, class combo with getRandomProperties()
  -- then invoke usable( item, align, sex, class )
  for desc, data in pairs( Items ) do
    local align, sex, class = getRandomProperties()
    if not usable( desc, align, sex, class ) then
      displayItem( desc )
      cecho( f "\n\t{EC}Unusable{RC} by <gold>{align}{RC}, <maroon>{sex}{RC}, {VC}{class}{RC}" )
    end
  end
end

-- To start a new round of QA testing and enhancements to the bot, fully reset and write the Items table
-- reporting on who contributed to this round of testing most effectively.
local function resetItemData()
  local contributors = {}
  local count = 0
  for desc, item in pairs( Items ) do
    count = count + 1
    if item.contributor and item.contributor ~= "Nadja" and item.contributor ~= "Kaylee" then
      if not contributors[item.contributor] then
        contributors[item.contributor] = 1
      else
        contributors[item.contributor] = contributors[item.contributor] + 1
      end
    end
    deleteItem( desc )
  end
  for name, num in pairs( contributors ) do
    cecho( f "{GDITM} {VC}{name}{RC} contributed {num} items" )
  end
  cecho( f "{GDITM} {EC}{count}{RC} items deleted" )
  -- Force a write of the new empty items table with a direct table.save()
  table.save( f '{DATA_PATH}/Items.lua', Items )
end
-- Advertise The Archive by occasionally contributing an item to The Archive when a player
-- arrives in the room.

-- When we last attempted an auto-contribution; don't do too many too often
LastAC  = LastAC or 0
ACDelay = 600
function autoContribute()
  -- If the queue of items doesn't exist, try to load it from disk
  if not ACItems then
    ACItems = {}
    iout( "Loading ACItems" )
    table.load( f '{DATA_PATH}/ACItems.lua', ACItems )
  end
  local now       = getStopWatchTime( "timer" )
  local noItems   = not ACItems or #ACItems == 0
  local tooRecent = (now - LastAC) < ACDelay
  if noItems or tooRecent or not ACTarget then
    -- If we have no more items too process, or not enough time has passed,
    -- or our intended audience has left the room, skip this round.
    iout(
      "{EC}Skipped{RC} AC: i = {VC}{noItems}{RC}, r = {VC}{tooRecent}{RC}, t = {VC}{ACTarget}{RC}" )
    return
  end
  -- Update the last contribution time
  LastAC        = now
  -- "Pop" the nex item keyword off the queue
  local nBefore = #ACItems
  local kw      = table.remove( ACItems, 1 )
  -- Write/overwrite the data file to reflect the removal
  table.save( f '{DATA_PATH}/ACItems.lua', ACItems )
  local nAfter  = #ACItems
  -- Display some status debug output to track the behavior of the queue
  local nStatus = f "ACItems reduced from {NC}{nBefore}{RC} -> {nAfter}{RC}"
  local status  = f "Showing {SC}{kw}{RC} to <medium_sea_green>{ACTarget}{RC}"
  iout( nStatus )
  iout( status )
  send( f "get {kw} stocking" )
  send( f "give {kw} Nadja" )
  -- Reset the timer/audience variables
  ACTimer  = nil
  ACTarget = nil
end

-- Timer to control the auto-contribution on a short delay
ACTimer  = ACTimer or nil
-- The player "audience" for the auto-contribution so we can try to cancel
-- the timer if the player leaves before we proceed.
ACTarget = ACTarget or nil
function triggerAutoContribute()
  local arrival = trim( matches[2] )
  -- Make sure it's a known player (so we don't try to impress mobs)
  if KnownPlayers[arrival] then
    selectString( arrival, 1 )
    fg( "medium_sea_green" )
    resetFormat()
    ACTarget = arrival
    -- Use a refreshing timer on a delay so multiple arrivals only trigger one
    -- item.
    if ACTimer then killTimer( ACTimer ) end
    ACTimer = tempTimer( 2, [[autoContribute()]], false )
  end
end

local function displayAllAntis()
  -- For each item in Items, iterate over item.flags;
  -- for each item in item.flags, if the item contains the substring "ANTI" then
  -- append it to a result table.
  -- Display the results once the table is fully populated
  local antiFlags = {}
  local uniqueFlags = {}
  for desc, item in pairs( Items ) do
    for _, flag in ipairs( item.flags ) do
      if flag:find( "ANTI" ) and not uniqueFlags[flag] then
        uniqueFlags[flag] = true
        table.insert( antiFlags, flag )
      end
    end
  end
  display( antiFlags )
end

-- A one-time cleanup function to "pad" the levels of all potions with level less than 10
-- to align them with higher level potions.
local function padPotionLevels()
  -- For each item in Items where baseType == POTION and spellLevel < 10, print the item name
  -- and set the spellLevel to a padded version of itself
  for desc, item in pairs( Items ) do
    local isConsumable = consumable( item.baseType )
    if isConsumable and item.spellLevel < 10 then
      cout( f "\nPadding stat display for {SC}{desc}{RC}..." )
      local oldString = "L" .. tostring( item.spellLevel )
      local newString = "L0" .. tostring( item.spellLevel )
      local newStatsString = item.statsString:gsub( oldString, newString )
      item.statsString = newStatsString
    end
  end
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

function itemQueryAppend( itemName )
  itemName              = itemName or matches[2]
  local itemNameTrimmed = trimItemName( itemName )
  local itemNameLength  = #itemName

  abbreviateWorn()

  -- Colorize the item
  if selectString( itemName, 1 ) > 0 then fg( "slate_gray" ) end
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

-- This function should populate the ItemKeywordCounts table with a count of how many times each individual
-- keyword appears on any item in the LegacyItem table; the goal will be to use this data to identify
-- each item's "optimal" keyword.
local function countItemKeywords()
end

-- Load all items from the Item table into a globally-accessible table indexed by item name
local function loadAllItems()
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

-- This function should populate the ItemKeywordCounts table with a count of how many times each individual
-- keyword appears on any item in the LegacyItem table; the goal will be to use this data to identify
-- each item's "optimal" keyword.
local function countItemKeywords()
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

local function findOptimizedKeyword( item )
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
local function itemQueryAppend( itemName )
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

-- Inefficient method for determining if an item has a special proc (reconnect to the db and look at ID text)
local function itemHasSpec( item_name )
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
local function exportIDStrings()
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


local function loadLegacyItems()
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
local function planBotPrizes( itemType, attribute, basePrize, prizeMultiplier )
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

local function getItemBounty( item )
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

local function findNonKeywords()
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
-- Dialog for the bot to use when responding to commands and interactions;
-- responses are singular responses of which one is picked at random, while
-- sequences are multiple lines of dialog spoken in order at SpeechRate
BOT_DIALOG = {
  ["SEMICOLON"] = {
    responses = {
      "A semicolon, {Speaker}, really? Don't try that again. [`i+Demerit`q]",
      "Did you just try to semicolon me, {Speaker}? It's not 1996 and I'm not amused. [`i+Demerit`q]",
      "Please refrain from including semicolons in our dialogs. [`i+Demerit`q]",
      "Semicolon isn't even my command character, but I'm still offended that you tried it. [`i+Demerit`q]",
    }
  },
  ["PROFANITY"] = {
    responses = {
      "I'm not sure that's language you should be using, {Speaker}. [`i+Demerit`q]",
      "Why, I never. Do you kiss my mother with that mouth? [`i+Demerit`q]",
      "How rude. I'm not going to repeat that, {Speaker}. [`i+Demerit`q]",
    }
  },
  ["HELP"] = {
    sequence = {
      "Thanks for your interest in `fThe Archive`q, {Speaker}.",
      "We're just getting started, so our services are somewhat limited at the moment.",
      "For instance, I'll only work with people in the room. Someday soon I'll respond to `dtells`q and `fgossip`q.",
      "If you ask me to `gID <item>`q, I'll tell you what I know about it.",
      --"If I'm holding an item of yours and you need it back, try RETURN <keyword>.",
      "For details on any of our services, use `gHELP <command>`q.",
    }
  },
  ["HELP_ID"] = {
    responses = {
      "Once I've added an item to The Archive, I can look up its stats with the ID command.",
      "Until I improve my filing system, you'll need to provide an exact short description.",
      "Core stats will appear in `cgreen`q, permanent affects in `eblue`q, and anti-flags in `bred`q.",
    }
  },
  ["BUSY_RECEIVE"] = {
    responses = {
      "I'm already working on an item, {Speaker}. Please wait a moment.",
      "I'm currently processing an item, {Speaker}. Please be patient.",
    }
  },
  ["REQUEST_KEYWORD"] = {
    responses = {
      "I guess you'll be wanting me to identify this, eh {Speaker}? Just say the KEYWORD <word>.",
    }
  }
}
-- Define & initialize a new global table named ItemKeywords
ItemKeywords = {}

-- Function to catalog keywords from RawItemData
function catalogKeywords()
  loadLegacyItems()
  for _, item in pairs( RawItemData ) do
    if item.keywords and item.keywords ~= "" then
      for keyword in item.keywords:gmatch( "%S+" ) do
        ItemKeywords[keyword] = true
      end
    end
  end
end

-- This function will iterate through the itemList which is a list of keywords, and attempt to
-- 'get' each item from container 1 and put each item into container 2
local function transferItems( itemList, container1, container2 )
  for i, item in ipairs( itemList ) do
    local function transfer()
      send( "get " .. item .. " " .. container1 )
      send( "put " .. item .. " " .. container2 )
    end
    tempTimer( (i - 1) * 0.25, transfer )
  end
  ItemsForTransfer = nil
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
  local conn, cerr = env:connect( DB_PATH )

  if not conn then
    iout( "{EC}eq_db.lua{RC} failed database connection in itemQueryAppend()" )
    return
  end
  -- Query for the item's stats, antis, and cloneability values
  local query = string.format(
    [[SELECT name, statsString, antisString, clone, affectsString FROM LegacyItem WHERE name = '%s']],
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
-- Print all variables currently in _G (Lua's table for all variables); probably
-- not very readable but might be helpful
local function printVariables()
  for k, v in pairs( _G ) do
    local nameStr, typeStr, valStr = nil, nil, nil
    local vName, vType, vVal       = nil, nil, nil

    vType                          = type( v )
    vName                          = tostring( k )
    vVal                           = tostring( v )

    nameStr                        = "<sea_green>" .. vName .. RC
    typeStr                        = "<ansi_magenta>" .. vType .. RC
    valStr                         = "<cyan>" .. vVal .. RC

    if vType == "number" or vType == "boolean" then
      cecho( f "\n{nameStr} ({typeStr}) == {valStr}\n-----" )
    elseif vType == "string" then
      cecho( f "\n{nameStr} ({typeStr}) ==\n{valStr}\n-----" )
    end
  end
end

-- Feed the contents of a file line-by-line as if it came from the MUD
local function feedFile( feedPath )
  local feedRate = 0.01
  local file = io.open( feedPath, "r" )

  local lines = file:lines()

  local function feedLine()
    local nextLine = lines()
    if nextLine then
      cfeedTriggers( nextLine )
      tempTimer( feedRate, feedLine )
    else
      file:close()
    end
  end

  feedLine()
end

-- Guess a string is regex if it starts with ^, ends with $, or contains a backslash
local function isRegex( str )
  if string.sub( str, 1, 1 ) == '^' then
    return true
  end
  if string.sub( str, -1 ) == '$' then
    return true
  end
  if string.find( str, "\\" ) then
    return true
  end
  return false
end

-- Parse a WINTIN-style action/trigger definition into a table of its components
-- "#ACTION {pattern} {command} {priority}" = { "pattern", "command", "priorisy" }
-- Intended as part of a solution for importing WINTIN/TINTIN files into a Mudlet project
local function parseWintinAction( actionString )
  local pattern, command, priority = "", "", ""
  local section = 1
  local braceDepth = 0
  local temp = ""

  for i = 1, #actionString do
    local char = actionString:sub( i, i )

    -- Do some ridiculous bullshit to deal with nested braces
    if char == "{" then
      braceDepth = braceDepth + 1
      if braceDepth == 1 then
        -- Open section
        temp = ""
      else
        temp = temp .. char
      end
    elseif char == "}" then
      braceDepth = braceDepth - 1
      if braceDepth == 0 then
        -- Close section
        if section == 1 then
          pattern = temp
        elseif section == 2 then
          command = temp
        elseif section == 3 then
          priority = temp
        end
        section = section + 1
      else
        temp = temp .. char
      end
    elseif braceDepth > 0 then
      temp = temp .. char
    end
  end
  return trim( pattern ), trim( command ), trim( priority )
end

local function swapGear()
  -- Define the swappable gear sets; the last two items must be 'wield' and 'hold'
  local dpsGear = {"onyx", "onyx", "cape", "cape", "platemail", "masoch", "flaming", "flaming",
    "cudgel", "scalpel"}
  local tankGear = {"one", "one", "skin", "skin", "vest", "kings", "fanra", "fanra", "cutlass",
    "bangle"}
  local held, toHold = "", ""

  -- These need to be global temporarily so subsequent swap functions can access them
  currentGear, nextGear = {}, {}
  doReady, finishReady = 0, 0

  -- Figure out what we're swapping to/from
  if nanMode == "dps" then
    held, toHold = "a bloody scalpel", "a metal bangle"
    nanMode = "tank"
    currentGear = dpsGear
    nextGear = tankGear
  else
    toHold, held = "a bloody scalpel", "a metal bangle"
    nanMode = "dps"
    currentGear = tankGear
    nextGear = dpsGear
  end
  -- Set triggers to watch the swap and trigger next steps as each one completes
  tempRegexTrigger( f [[Nandor stops using ]] .. held .. [[\.$]], [[doSwap()]], 1 )
  tempRegexTrigger( f [[You get ]] .. toHold .. [[ from a Christmas Stocking\.$]], [[doSwap()]], 1 )
  tempRegexTrigger( f [[Nandor gives you ]] .. held .. [[\.$]], [[finishSwap()]], 1 )
  prepSwap()
end

-- Prepare the swap by removing the current gear set and getting the next set from storage
local function prepSwap()
  for i = 1, #currentGear do
    expandAlias( f 'nan remove {currentGear[i]}', false )
    expandAlias( f 'col get {nextGear[i]} stocking', false )
  end
end

-- Perform the swap through the sensual art of mutual giving
local function doSwap()
  -- Ignore the first call of this function so we only proceed when both swappers are prepped
  doReady = doReady + 1
  if doReady < 2 then return end
  -- Count "Ok." which indicates an item was given to the receiver; make sure we get one for every item before proceeding
  tempRegexTrigger( [[Ok\.$]], [[finishSwap()]], #nextGear )
  for i = 1, #nextGear do
    expandAlias( f 'col give {nextGear[i]} Nandor', false )
    expandAlias( f 'nan give {currentGear[i]} Colin', false )
  end
end

local function finishSwap()
  -- Ignore calls to this function until all items have been given (and Nandor's holdable has been removed which is why +1)
  finishReady = finishReady + 1
  if finishReady < (#nextGear + 1) then return end
  -- Most items need to be worn
  local wearCommand = "wear"
  for i = 1, #nextGear do
    -- But use wield/hold for the last two
    if i == #nextGear - 1 then wearCommand = "wield" elseif i == #nextGear then wearCommand = "hold" end
    expandAlias( f 'col put {currentGear[i]} stocking', false )
    expandAlias( f 'nan {wearCommand} {nextGear[i]}', false )
  end
  -- Clean up globals we don't need anymore
  currentGear, nextGear, doReady, finishReady = nil, nil, nil, nil
end

local function getFullDirs( srcID, dstID )
  -- Clear Mudlet's pathing globals
  speedWalkDir = nil
  speedWalkPath = nil

  -- Use Mudlet's built-in path finding to get the initial path
  local rm = srcID
  if getPath( srcID, dstID ) then
    -- Initialize a table to hold the full path
    local fullPathString1, fullPathString2 = "", ""
    local fullPath = {}
    for d = 1, #speedWalkDir do
      local dir = LDIR[tostring( speedWalkDir[d] )]
      local doors = getDoors( rm )
      if doors[dir] and doorData[rm] and doorData[rm][dir] then
        local doorInfo = doorData[rm][dir]
        -- If the door has a key associated with it; insert an unlock command into the path
        if doorInfo.exitKEy and doorInfo.exitKey > 0 then
          table.insert( fullPath, "unlock " .. doorInfo.exitKeyword )
        end
        -- All doors regardless of locked state need opening
        table.insert( fullPath, "open " .. doorInfo.exitKeyword )
        table.insert( fullPath, dir )
        -- Close doors behind us to minimize wandering mobs
        table.insert( fullPath, "close " .. doorInfo.exitKeyword )
      else
        -- With no door, just add the original direction
        table.insert( fullPath, dir )
      end
      -- "Step" to the next room along the path
      rm = tonumber( speedWalkPath[d] )
    end
    -- Convert the path to a Wintin-compatible command string
    fullPathString = createWintinString( fullPath )
    return fullPathString
  end
  cecho( f "\n<firebrick>Failed to find a path between {srcID} and {dstID}<reset>" )
  return nil
end

-- Display one or more mobs whose keywords include the specified string(s)
local function displayMobByKeyword( keywords )
  local NC = "<dark_orange>"
  local SC = "<royal_blue>"
  local DC = "<gold>"
  local RC = RC

  -- Split the keywords string into a table of individual keywords
  local keywordsTable = split( keywords, ' ' )
  local sqlCondition = ""

  -- Construct SQL condition for each keyword
  for i, keyword in ipairs( keywordsTable ) do
    if i > 1 then sqlCondition = sqlCondition .. " AND " end
    sqlCondition = sqlCondition .. string.format( "keywords LIKE '%%%s%%'", keyword )
  end
  local sql = "SELECT * FROM Mob WHERE " .. sqlCondition
  local cursor, conn, env = getCursor( sql )

  if not cursor then
    cecho( string.format( "\nError fetching mobs with keywords: %s\n", keywords ) )
    return nil
  end
  local mob = cursor:fetch( {}, "a" )
  while mob do
    local lng, shrt, kws = mob.longDescription, mob.shortDescription, mob.keywords
    cecho( string.format( "\n%s%s%s", SC, lng, RC ) )
    cecho( string.format( "\n  %s%s%s (%s%s%s)", SC, shrt, RC, SC, kws, RC ) )
    local hp, xp = mob.health, mob.xp
    local xpph = round( (xp / hp), 0.05 )
    cecho( string.format( "\n  HP: %s%s%s  XP: %s%s%s  (%s%s%s xp/hp)", NC, expandNumber( hp ), RC,
      NC,
      expandNumber( xp ),
      RC, DC, xpph, RC ) )
    local gp = mob.gold
    local gpph = round( (gp / hp), 0.05 )
    cecho( string.format( "\n  Gold: %s%s%s  (%s%s%s gp/hp)", NC, expandNumber( gp ), RC, DC, gpph,
      RC ) )
    local dn, ds, dm, hr = mob.damageDice, mob.damageSides, mob.damageModifier, mob.hitroll
    local da = averageDice( dn, ds, dm )
    cecho( string.format( "\n  Damage: %s%sd%s+%s+%s%s (%s%s%s avg)", NC, dn, ds, dm, hr, RC, DC, da,
      RC ) )
    local flg, aff = mob.flags, mob.affects
    cecho( string.format( "\n  Flags: <maroon>%s%s", flg, RC ) )
    cecho( string.format( "\n  Affects: <maroon>%s%s", aff, RC ) )

    -- Fetch the next mob
    mob = cursor:fetch( mob, "a" )
  end
  -- Don't forget to close the cursor and connection
  cursor:close()
  conn:close()
  env:close()
end

local function getMob( rNumber )
  -- Convert rNumber to a number in case it's passed as a string
  rNumber = tonumber( rNumber )

  -- Find mob in mobData
  for _, mob in ipairs( mobData ) do
    if mob.rNumber == rNumber then
      return mob
    end
  end
  cecho( string.format( "\nMob with rNumber <orange>%d<reset> not found.", rNumber ) )
  return nil
end

local function populateMobAreas()
  local luasql     = require "luasql.sqlite3"
  local env        = luasql.sqlite3()
  local conn, cerr = env:connect( "C:/Dev/mud/gizmo/data/gizwrld.db" )

  if not conn then
    print( "Error connecting to database:", cerr )
    return
  end
end

local function getMobArea( rn )
  local sql = string.format( "SELECT * FROM Mob WHERE rnumber = %d", rn )
  local dbpath = "C:/Dev/mud/gizmo/data/gizwrld.db"
  local cursor, conn, env = getCursor( dbpath, sql )
  local mobAreaName = "Unknown Area"

  if not cursor then
    return mobAreaName
  end
  local mob = cursor:fetch( {}, "a" )
  cursor:close()

  if mob then
    local mobRoomVNumber = tonumber( mob.roomVNumber )
    local mobRoomRNumber = searchRoomUserData( "roomVNumber", tostring( mobRoomVNumber ) )[1]
    if roomExists( mobRoomRNumber ) then
      local mobAreaRNumber = getRoomArea( mobRoomRNumber )
      mobAreaName = getRoomAreaName( mobAreaRNumber )
    end
  end
  conn:close()
  env:close()

  return mobAreaName
end

local function calculateMobDamage( rn )
  local DC, SC, R = "<maroon>", "<medium_violet_red>", RC
  local dbpath = "C:/Dev/mud/gizmo/data/gizwrld.db"
  -- SQL statement to select the mob by rnumber
  local mobSql = string.format( "SELECT * FROM Mob WHERE rnumber = %d", rn )
  local mobCursor, mobConn, mobEnv = getCursor( dbpath, mobSql )

  if mobCursor then
    local mob = mobCursor:fetch( {}, "a" )
    mobCursor:close()

    if mob then
      local mobShort = mob.shortDescription
      local totalAverage = 0
      cecho( f "\nDamage for {DC}{mobShort}{R}:" )
      local bn, bs, bm = mob.damageDice, mob.damageSides, mob.damroll
      local ba = averageDice( bn, bs, bm )
      cecho( f "\n  Base: {DC}{bn}d{bs} +{bm}{R} (~{DC}{ba}{R})" )
      totalAverage = totalAverage + ba

      -- Now fetch special attacks for this mob
      local specSql = string.format( "SELECT * FROM SpecialAttack WHERE rnumber = %d", rn )
      local specCursor, _, _ = getCursor( dbpath, specSql )

      if specCursor then
        local specNumber = 1
        local spec = specCursor:fetch( {}, "a" )
        while spec do
          local sc, sn, ss, sm = spec.chance, spec.damageDice, spec.damageSides, spec.damageModifier
          local sa = averageDice( sn, ss, sm ) * (sc / 100)
          cecho( f "\n  Spec {specNumber}: {SC}{sc}{R}% chance of {SC}{sn}d{ss}{R} +{SC}{sm}{R} ({SC}{sa}{R} ave)" )
          totalAverage = totalAverage + sa
          specNumber = specNumber + 1
          spec = specCursor:fetch( spec, "a" )
        end
        specCursor:close()
      end
      cecho( f "\n  Total: ~<dark_orange>{totalAverage}<reset>" )
    end
    mobConn:close()
    mobEnv:close()
  end
end

local function listMobsWithSpecialAttacks()
  local dbpath = "C:/Dev/mud/gizmo/data/gizwrld.db"
  local sql = [[
    SELECT DISTINCT Mob.shortDescription
    FROM Mob
    JOIN SpecialAttack ON Mob.rNumber = SpecialAttack.rNumber
  ]]

  local cursor, conn, env = getCursor( dbpath, sql )
  if not cursor then
    cecho( "\n<red>Failed to query database for mobs with special attacks.<reset>" )
    return
  end
  local mob = cursor:fetch( {}, "a" ) -- Initialize mob to fetch in loop
  if not mob then
    cecho( "\n<green>No mobs with special attacks found.<reset>" )
  else
    cecho( "\n<green>Mobs with Special Attacks:<reset>" )
    while mob do
      cecho( f( "\n- {mob.shortDescription}" ) )
      mob = cursor:fetch( mob, "a" ) -- Fetch next row into mob
    end
  end
  -- It's important to close the cursor and connection
  cursor:close()
  conn:close()
  env:close()
end

local function insertSpecialAttacks()
  for rNumber, mob in pairs( specialAttacks ) do
    for _, spec in pairs( mob ) do
      local chance            = spec[1]
      local damageDice        = spec[2]
      local damageSides       = spec[3]
      local damageModifier    = spec[4]
      local hitroll           = spec[5]
      local target            = spec[6]
      local type              = spec[7]
      local description       = spec[8]

      local sql               = string.format( [[
        INSERT INTO SpecialAttacks (
          rNumber, chance, damageDice, damageSides, damageModifier, hitroll, target, type, description
        ) VALUES (
          %d, %d, %d, %d, %d, %d, %d, %d, '%s'
        )]], rNumber, chance, damageDice, damageSides, damageModifier, hitroll, target, type,
        description )

      local cursor, conn, env = getCursor( sql )
      if cursor then
        cecho( f "Special attack inserted successfully for rNumber: {rNumber}\n" )
      end
      -- Make sure to close the cursor, connection, and environment when done
      if conn then conn:close() end
      if env then env:close() end
    end
  end
end

-- Triggered by a "multi-line match" as a result of the 'stat' command to trap all mob stats
local function parseStatBlock()
  local statBlock = {}
  for l = 1, #multimatches do
    for m = 2, #multimatches[l] do
      local value = multimatches[l][m]
      local numberValue = tonumber( value )
      if numberValue then
        table.insert( statBlock, numberValue )
      else
        table.insert( statBlock, trim( value ) )
      end
    end
  end
  -- Mob rnumbers are unique, so don't store stats for the same rnumber twice
  local rnumber = statBlock[4]
  if mobsCaptured[rnumber] then return end
  currentKey = rnumber
  mobsCaptured[currentKey] = {}
  if #statBlock == 78 then
    local mob             = mobsCaptured[currentKey]
    mob.short_description = statBlock[7]
    mob.long_description  = statBlock[9]
    mob.keywords          = statBlock[3]
    mob.rnumber           = statBlock[4]
    mob.vnumber           = statBlock[6]
    mob.level             = statBlock[11]
    mob.health            = statBlock[42]
    -- Combine damage numbers, sides, and damroll into a list like '4d3+20' = {4, 3, 20}
    mob.damage            = {statBlock[61], statBlock[62], statBlock[51]}
    -- Directly copy the special attacks table from the statBlock table
    mob.proc              = statBlock[60]
    mob.special_attacks   = {}
    mob.ac                = statBlock[47]
    mob.xp                = statBlock[49]
    mob.gold              = statBlock[52]
    mob.alignment         = statBlock[12]
    mob.flags             = statBlock[58]
    mob.affects           = statBlock[78]
    mob.health_regen      = statBlock[43]
    mob.hitroll           = statBlock[50]
    mob.inventory         = statBlock[65]
    mob.equipped          = statBlock[66]
    -- Combine saving throws into a single list
    mob.saves             = {statBlock[67], statBlock[68], statBlock[69], statBlock[70],
      statBlock[71]}
    mob.room              = statBlock[5]
  else
    cecho( "info", f "\nFailed to parse stats for: <orange_red>{currentKey}<reset>" )
  end
end

-- Return the area name of a captured/scanned mob (or string version of room number for unknown areas)
local function getWhereArea( number )
  for _, area in ipairs( whereMap ) do
    local startNum, endNum, name = unpack( area )
    if number >= startNum and number <= endNum then
      return name
    end
  end
  -- For areas outside the ranges of the map, return a string representation of the room number
  return tostring( number )
end

local function loadMobsIntoDatabase()
  local luasql     = require "luasql.sqlite3"
  local env        = luasql.sqlite3()
  local conn, cerr = env:connect( "C:/Dev/mud/gizmo/data/gizwrld.db" )

  if not conn then
    print( "Error connecting to database:", cerr )
    return
  end
  local insertedCount = 0
  local skippedCount = 0

  for rnumber, mob in pairs( mobsCaptured ) do
    local specialProcedureFlag = (mob.proc == 'Exists') and 1 or 0

    local mobInsertCmd = string.format( [[
      INSERT INTO Mob (rnumber, shortDescription, longDescription, keywords, level, health, ac, gold, xp, alignment, flags, affects, damageDice, damageSides, damroll, hitroll, room, specialProcedure)
      VALUES (%d, '%s', '%s', '%s', %d, %d, %d, %d, %d, %d, '%s', '%s', %d, %d, %d, %d, %d, %d)
    ]],
      rnumber,
      mob.short_description:gsub( "'", "''" ), -- Escape single quotes
      mob.long_description:gsub( "'", "''" ),
      mob.keywords:gsub( "'", "''" ),
      mob.level,
      mob.health,
      mob.ac,
      mob.gold,
      mob.xp,
      mob.alignment,
      mob.flags:gsub( "'", "''" ),
      mob.affects:gsub( "'", "''" ),
      mob.damage[1], -- damageDice
      mob.damage[2], -- damageSides
      mob.damage[3], -- damroll, assuming 3rd value in damage is damroll
      mob.hitroll,
      mob.room,
      specialProcedureFlag
    )

    local res, serr = conn:execute( mobInsertCmd )
    if not res then
      print( string.format( "Failed to insert mob rnumber %d: %s", rnumber, serr ) )
      skippedCount = skippedCount + 1
    else
      insertedCount = insertedCount + 1
    end
    -- Insert special attack data
    for _, attack in ipairs( mob.special_attacks ) do
      local specialAttackInsertCmd = string.format( [[
        INSERT INTO SpecialAttack (rnumber, chance, damageDice, damageSides, damageModifier, hitroll, strings, target, type)
        VALUES (%d, %d, %d, %d, %d, %d, '%s', %d, %d)
      ]],
        rnumber,
        attack.chance,
        attack.damage.n,
        attack.damage.s,
        attack.damage.m,
        attack.hitRoll,
        attack.strings:gsub( "'", "''" ),
        attack.target,
        attack.type
      )
      local saRes, saSerr = conn:execute( specialAttackInsertCmd )
      if not saRes then
        print( string.format( "Failed to insert special attack for mob rnumber %d: %s", rnumber,
          saSerr ) )
        -- Not incrementing skippedCount here as the mob insert is the critical part
      end
    end
  end
  print( string.format( "Data loading complete. Inserted: %d, Skipped: %d", insertedCount,
    skippedCount ) )
  conn:close()
  env:close()
end

-- The last 'where' command returned 'Couldn't find that entity'; log the error
local function badKeyword()
  local errorString = f(
    "{currentMobKeyword} ({currentMobIndex-1}) returned no entities from 'where'" )
  cecho( "info", f "\n<orange_red>{errorString}<reset>" )
end

-- Some mobs have a special attack table that lists the chance, damage, and other data about special attacks
-- a mob can perform; here we parse them and store them in the capturedMobs table; an example special attacks table:
--[[
CHANCE DAMAGE HITROLL TARGET TYPE STRINGS
-------------------------------------------
  5   25D16+50    0       2     0  spray of green gas/spray of green gas
 20   25D12+100    0       0   236
100   25D12+100    0       0   236
--]]
local function parseSpecialAttack()
  local chance, diceNum, diceSides, diceModifier = tonumber( matches[2] ), tonumber( matches[3] ),
      tonumber( matches[4] ),
      tonumber( matches[5] )
  local hitRoll, target, type = tonumber( matches[6] ), tonumber( matches[7] ),
      tonumber( matches[8] )
  local strings = matches[9] and trim( matches[9] ) or ""

  -- Constructing the special attack table
  local specialAttack = {
    chance  = chance,
    damage  = {n = diceNum, s = diceSides, m = diceModifier},
    hitRoll = hitRoll,
    target  = target,
    type    = type,
    strings = strings
  }

  -- Ensure currentKey is valid and the mob exists in mobsCaptured
  if mobsCaptured[currentKey] then
    -- Initialize the special_attacks table if it doesn't exist
    mobsCaptured[currentKey].special_attacks = mobsCaptured[currentKey].special_attacks or {}
    -- Append the new special attack
    table.insert( mobsCaptured[currentKey].special_attacks, specialAttack )
  else
    cecho( "info", f "\nSpec parsed for unknown or invalid key: <orange_red>{currentKey}<reset>" )
  end
end

-- mobKeywords is a predefined list of comprehensive keywords designed to cover as many mobs as possible;
-- This function will issue a 'where' command for each keyword in the list, the output from which should
-- trigger the capture and 'stat'ing of each mob
local function whereNextMob()
  if mobKeywords[currentMobIndex] then
    currentMobKeyword = mobKeywords[currentMobIndex]
    whereMob( currentMobKeyword )
    currentMobIndex = currentMobIndex + 1
  else
    -- Once all keywords have been scanned, write the table and logout of the game (currently printing a fake logout)
    cecho( "info", f "\nMob scan completed @ index <orange>{currentMobIndex}<reset>." )
    --table.save( f '{homeDirectory}gizmo/map/data/mob_data.lua', mobsCaptured )
    tempTimer( 5, [[send( 'quit' )]] )
    tempTimer( 7, [[send( '0' )]] )
  end
end

-- Issue a 'where' command to find all mobs matching the specified keyword
local function whereMob( keyword )
  -- Use a temporary regex to match the next prompt indicating the 'where' is complete and we can stat any
  -- new mobs.
  tempRegexTrigger( "\\s*^<", statCapturedMobs, 1 )
  send( f 'where {keyword}', false )
end

-- This function is triggered once for each line of 'where' output in order to capture the mob on that line
-- A unique key is created by combining the mobs short description and area; unique mobs are queued for 'stat'ing
local function captureWhereMobs()
  -- windex is the position within the 'where' command itself and must be saved for subsequent 'stat' command;
  -- note that this is NOT a static value so 'stat' must be issued shortly after where or this may change
  local windex = trim( matches[2] )
  windex       = tonumber( windex )
  local sdesc  = trim( matches[3] )
  if playerNames[sdesc] then return end -- Don't stat players
  local rmvnum = trim( matches[5] )

  -- Create a unique key by combining the mob's short name and rmvnum
  local uniqueKey = sdesc .. "_" .. rmvnum

  -- If a mob with this short description has been seen in this room, assume we can skip it
  if not mobsToStat[uniqueKey] then
    mobsToStat[uniqueKey] = {} -- Initialize the table before assigning properties
    mobsToStat[uniqueKey].index = windex
    mobsToStat[uniqueKey].keyword = currentMobKeyword
    mobsToStat[uniqueKey].stated = false
  end
end

-- Immediately after a 'where' command concludes, we want to 'stat' any newly added mobs due to the dynamic nature
-- of the index number which can change as new mobs spawn/areas reset; for any mobs in the mobsCaptured that have
-- not been 'stat'ed, this function queues a stat command at a rate of 0.5 seconds per mob
local function statCapturedMobs()
  local statRate   = 0.75 -- Time to delay between each stat command
  local statOffset = 0    -- Start with no offset and increase for each mob
  for uniqueKey, mob in pairs( mobsToStat ) do
    if not mob.stated then
      tempTimer( statOffset,
        f [[send( 'stat c ]] .. mob.index .. [[.]] .. mob.keyword .. [[', false )]] )
      mob.stated = true -- Update this in mobsToStat
      statOffset = statOffset + statRate
    end
  end
  -- Optionally, schedule the next step after all stat commands are issued
  local whereOffset = statOffset + 2
  tempTimer( whereOffset, whereNextMob )
end

-- This function is triggered once for each line of 'where' output in order to capture the mob on that line
-- A unique key is created by combining the mobs short description and area; unique mobs are queued for 'stat'ing
local function captureWhereMobs()
  -- windex is the position within the 'where' command itself and must be saved for subsequent 'stat' command;
  -- note that this is NOT a static value so 'stat' must be issued shortly after where or this may change
  local windex = trim( matches[2] )
  windex       = tonumber( windex )
  local sdesc  = trim( matches[3] )
  if playerNames[sdesc] then return end -- Don't stat players
  local rmvnum    = trim( matches[5] )
  -- Get the area name by translating vnum->rnum->area; unknown areas are represented by the room number
  rmvnum          = tonumber( rmvnum )
  local rmarea    = getWhereArea( rmvnum )

  -- Create a unique key by combining the mob's short name and rmvnum
  local uniqueKey = sdesc .. "_" .. rmvnum

  -- If a mob with this short description has been seen in this room, assume we can skip it
  if not mobsToStat[uniqueKey] then
    mobsToStat[uniqueKey].index   = windex
    mobsToStat[uniqueKey].keyword = currentMobKeyword
    mobsToStat[uniqueKey].stated  = false
  end
  if not mobsCaptured[uniqueKey] then
    mobsCaptured[uniqueKey] = {
      stated            = false,
      short_description = sdesc,
      index             = windex,
      area              = rmarea,
      special_attacks   = {},
      stats             = {},
      known_rooms       = {rmvnum}
    }
  else
    -- If the mob/area combination is known, update its list of known rooms if this room is new
    if not table.contains( mobsCaptured[uniqueKey].known_rooms, rmvnum ) then
      table.insert( mobsCaptured[uniqueKey].known_rooms, rmvnum )
    end
  end
end

-- Function to initiate stat command for the next unstated mob
local function statNextMob()
  cecho( f "\n<yellow_green>statNextMob()<reset>" )
  local foundUnstated = false

  for uniqueKey, mob in pairs( mobsCaptured ) do
    if not mob.stated then
      cecho( f "\nstatNextMob() found mob to stat: <yellow_green>{uniqueKey}<reset>" )
      -- Issue the stat command for the current mob
      send( f 'stat c {mob.index}.{currentMobKeyword}', false )
      -- Mark the mob as stated to avoid re-stat'ing
      mob.stated    = true
      foundUnstated = true
      -- Set up the temporary trigger for the next prompt to call statNextMob again
      tempRegexTrigger( "\\s*^<", statNextMob, 1 )
      break -- Exit the loop after scheduling a stat for one mob
    end
  end
  -- If no unstated mob was found, all mobs have been processed; call whereNextMob
  if not foundUnstated then
    cecho( f "\n<maroon>No unstated mobs found<reset>, moving to <royal_blue>whereNextMob()<reset>" )
    whereNextMob()
  end
end

-- Stat block seen with "PC" type; remove this entry from the capturedMobs table
local function removeCapturedPC( pcName )
  cecho( "info", f "\nRemoving <royal_blue>{pcName}<reset> from capturedMobs" )
  for i = #capturedMobs, 1, -1 do
    if capturedMobs[i].short == pcName then
      table.remove( capturedMobs, i )
      break
    end
  end
end

-- I already have a trim() function; you don't need to implement one.
-- Triggered by lines returned by the 'where' command; add or update mob data in the capturedMobs list
local function captureWhereMob()
  local mobIndex = tonumber( matches[2] )
  local mobShort = trim( matches[3] )
  local roomID   = tonumber( matches[5] )

  local mobFound = false
  for _, mob in ipairs( capturedMobs ) do
    if mob.short == mobShort then
      mobFound = true
      -- Update the rooms list for this mob in the capturedMobs table
      -- Every mob should end up with a list of rooms in which it was "seen"
      if not table.contains( mob.rooms, roomID ) then
        table.insert( mob.rooms, roomID )
      end
      break
    end
  end
  if not mobFound then
    -- Add the newly-discovered mob to the capturedMobs table with an empty stat block
    table.insert( capturedMobs, {
      short = mobShort, -- Match against this when inserting stat blocks
      stats = {},
      specials = {},
      rooms = {roomID}
    } )
    -- Add index to mobIndicesToStat table for new mobs
    -- We'll iterate over this later issuing stat commands like 'stat c 1.arachnid'
    table.insert( mobIndicesToStat, {index = mobIndex, keyword = currentMobKeyword} )
  end
end

-- Mudlet has a built-in table.contains() function, you don't need to implement one.
-- Print the content of the capturedMobs table filtered by the first letter of the mob's name
local function displayCapturedMobsByLetter( letter )
  local filterLetter = letter:lower() -- To handle case insensitivity
  cecho( "\n<green>--- Captured Mobs Starting with '" .. letter .. "' ---<reset>" )

  for _, mob in ipairs( capturedMobs ) do
    local mobFirstLetter = mob.short:sub( 1, 1 ):lower()
    if mobFirstLetter == filterLetter then
      cecho( f( "\n<yellow>Mob: <reset>{mob.short}" ) )
      cecho( f( "\n<yellow>Rooms: <reset>{table.concat(mob.rooms, ', ')}" ) )

      if #mob.specials > 0 then
        cecho( "\n<yellow>Special Attacks:<reset>" )
        for _, special in ipairs( mob.specials ) do
          local attackDetails = f(
            "Chance: {special.chance}, Damage: {special.damage.n}D{special.damage.s}+{special.damage.m}, HitRoll: {special.hitRoll}, Target: {special.target}, Type: {special.type}, Strings: {special.strings}" )
          cecho( f( "\n\t{attackDetails}" ) )
        end
      end
      if next( mob.stats ) ~= nil then
        cecho( "\n<yellow>Stats:<reset>" )
        -- Assuming stats are stored as a sequence of values; adjust based on actual structure
        for i, stat in ipairs( mob.stats ) do
          cecho( f( "\n\tStat {i}: {stat}" ) )
        end
      end
    end
  end
end

-- Function to calculate duration
local function calculateDuration( pc, spellName )
  local endTime = getStopWatchTime( "timer" )
  local startTime = affectStartTimes[pc][spellName]
  if startTime then
    local newDuration = endTime - startTime
    local existingDuration = affectInfo[spellName].duration

    if existingDuration then
      if math.abs( newDuration - existingDuration ) <= 60 then
        -- If there's already a duration stored for this spell, average the new and existing durations
        return math.floor( ((newDuration + existingDuration) / 2) / 10 ) * 10
      end
      -- If the calculated duration differs by more than +/- 60s, this was probably an error so discard
      return existingDuration
    else
      -- This is the first recorded duration
      return math.floor( newDuration / 10 ) * 10
    end
  end
  return nil
end

local function feedFile()
  local testRate = 0.01
  local filePath = "C:\\Dev\\mud\\mudlet\\wheres.txt" -- Update the path as necessary
  local file = io.open( filePath, "r" )               -- Open the file for reading

  local lines = file:lines()                          -- Get an iterator over lines in the file

  local function feedLine()
    local nextLine = lines()          -- Read the next line
    if nextLine then                  -- Continue if there's a line to read
      cfeedTriggers( nextLine )       -- Feed the line to Mudlet's trigger processing
      tempTimer( testRate, feedLine ) -- Schedule the next call
    else
      file:close()                    -- Close the file when done
    end
  end

  feedLine() -- Start the process
end

-- Parse prompt components and trigger an update if anything has changed; ignore maximum values
local function triggerParsePrompt()
  -- Grab current HP, MANA, MOVE from prompt
  local hpc, mnc, mvc = tonumber( matches[2] ), tonumber( matches[3] ), tonumber( matches[4] )

  -- Tank & Target conditions (if present)
  local tnk, trg = matches[5], matches[6]

  -- Store a 'localilzed' combat status for convenience
  if trg and #trg > 0 then
    in_combat = true
  else
    in_combat = false
  end
  -- Compare new values to local prior values
  local needs_update = hpc ~= pcLastStatus["currentHP"] or
      mnc ~= pcLastStatus["currentMana"] or
      mvc ~= pcLastStatus["currentMoves"] or
      tnk ~= pcLastStatus["tank"] or
      trg ~= pcLastStatus["target"]

  -- Exit early if nothing has changed
  if not needs_update then
    return
  else
    -- If something changed, update the prior-value table
    pcLastStatus["currentHP"]    = hpc
    pcLastStatus["currentMana"]  = mnc
    pcLastStatus["currentMoves"] = mvc
    pcLastStatus["tank"]         = tnk
    pcLastStatus["target"]       = trg

    -- Then pass the updated values to the main session
    raiseGlobalEvent( "event_pcStatus_prompt", SESSION, hpc, mnc, mvc, tnk, trg )
  end
end

-- Parse score components and send them to the main session
local function triggerParseScore()
  -- Just need this to fire once each time we 'score'
  disableTrigger( "Parse Score" )

  -- The multimatches table holds the values from score in a 2-dimensional array
  -- in the order they appear in score, so multimatches[l][n] = nth value on line l
  local dam, maxHP = multimatches[1][2], multimatches[1][3]
  local hit, mnm   = multimatches[2][2], multimatches[2][3]
  local arm, mvm   = multimatches[3][2], multimatches[3][3]
  local mac        = multimatches[4][2]
  local aln        = multimatches[5][2]

  -- For the numbers that get "big" we need to strip commas & convert to numbers
  local exp        = string.gsub( multimatches[6][2], ",", "" )
  local exh        = string.gsub( multimatches[7][2], ",", "" )
  local exl        = string.gsub( multimatches[8][2], ",", "" )
  local gld        = string.gsub( multimatches[9][2], ",", "" )

  exp              = tonumber( exp )
  exh              = tonumber( exh )
  exl              = tonumber( exl )
  gld              = tonumber( gld )

  raiseGlobalEvent( "event_pcStatus_score", SESSION, dam, maxHP, hit, mnm, arm, mvm, mac, aln, exp,
    exh, exl, gld )
end


-- Pull stats from the prompt and update status & status table
local function triggerParsePromptOld()
  -- Get current HP, MANA, MOVE from prompt
  local hpc, mnc, mvc = tonumber( matches[2] ), tonumber( matches[3] ), tonumber( matches[4] )

  -- Tank & Target conditions (if present)
  local tnk, trg = matches[5], matches[6]

  if (backupMira and tnk ~= "full") and (gtank) then
    send( f "cast 'miracle' {gtank}" )
  end
  backupMira = false

  -- Store a 'localilzed' combat status for convenience
  if trg and #trg > 0 then
    in_combat = true
  else
    in_combat = false
  end
  -- Main session can compare directly to the existing values in the master status table
  local needs_update = hpc ~= pcStatus[1]["currentHP"] or
      mnc ~= pcStatus[1]["currentMana"] or
      mvc ~= pcStatus[1]["currentMoves"] or
      tnk ~= pcStatus[1]["tank"] or
      trg ~= pcStatus[1]["target"]

  if not needs_update then
    return
  else
    pcStatusPrompt( SESSION, hpc, mnc, mvc, tnk, trg )
  end
end

local function isIgnoredItem( item )
  local ignoredItemPatterns = {
    ["^.*chit$"] = true,
    ["^.*[Pp]otion.*$"] = true,
    ["^.*scroll of.*$"] = true,
  }
  for pattern in pairs( ignoredItemPatterns ) do
    if item:match( pattern ) then
      return true
    end
  end
  return false
end

local function laswield()
  expandAlias( 'las rem ring', false )
  expandAlias( 'las rem leg', false )
  expandAlias( 'las rem gloves', false )
  expandAlias( 'las get sky bag', false )
  expandAlias( 'las get gauntlets bag', false )
  expandAlias( 'las get bionic bag', false )
  expandAlias( 'las wear sky', false )
  expandAlias( 'las wear gauntlets', false )
  expandAlias( 'las wear bionic', false )
  expandAlias( 'las wield spirit', false )
  expandAlias( 'las rem sky', false )
  expandAlias( 'las rem gauntlets', false )
  expandAlias( 'las rem bionic', false )
  expandAlias( 'las give sky nandor', false )
  expandAlias( 'las give gauntlets nandor', false )
  expandAlias( 'las give bionic nadja', false )
  expandAlias( 'las wear gloves', false )
  expandAlias( 'las wear ring', false )
  expandAlias( 'las wear leg', false )
end

local function nanwield()
  expandAlias( 'nan rem onyx', false )
  expandAlias( 'nan wear gauntlets', false )
  expandAlias( 'nan wear sky', false )
  expandAlias( 'nan wield cudgel', false )
  expandAlias( 'nan hold scalpel', false )
  expandAlias( 'nan rem sky', false )
  expandAlias( 'nan rem gauntlets', false )
  expandAlias( 'nan give sky nadja', false )
  expandAlias( 'nan give gauntlets nadja', false )
  expandAlias( 'nan wear onyx', false )
  expandAlias( 'nan wear gloves', false )
end

-- Called repeatedly to iterate each list of cloning assignments until complete
local function doClone()
  -- First/last call condition
  if not nadjaClones then
    startClone()
  elseif #nadjaClones == 0 and #laszloClones == 0 then
    endClone()
  end
  -- If Nadja has clone mana, try the next clone
  if pcStatus[2]["currentMana"] > 100 and nadjaClones and #nadjaClones > 0 then
    -- Stand up & attempt to clone after setting a fresh success trigger
    expandAlias( "nad stand" )
    if nadCloneTrigger then killTrigger( nadCloneTrigger ) end
    nadCloneTrigger = tempTrigger( "Nadja creates a duplicate", [[table.remove( nadjaClones, 1 )]] )
    local nextClone = nadjaClones[1]
    expandAlias( f [[nad cast 'clone' {nextClone}]] )
  elseif pcStatus[2]["currentMana"] < 100 and #nadjaClones > 0 then
    expandAlias( "nad rest" )
  end
  -- Repeat for Laszlo
  if pcStatus[3]["currentMana"] > 100 and laszloClones and #laszloClones > 0 then
    expandAlias( "las stand" )
    if lasCloneTrigger then killTrigger( lasCloneTrigger ) end
    lasCloneTrigger = tempTrigger( "Laszlo creates a duplicate", [[table.remove( laszloClones, 1 )]] )
    local nextClone = laszloClones[1]
    expandAlias( f [[las cast 'clone' {nextClone}]] )
  elseif pcStatus[3]["currentMana"] < 100 and #laszloClones > 0 then
    expandAlias( "las rest" )
  end
end

local function endClone()
  if lasCloneTrigger then killTrigger( lasCloneTrigger ) end
  if nadCloneTrigger then killTrigger( nadCloneTrigger ) end
  if nadjaClones then nadjaClones = nil end
  if laszloClones then laszloClones = nil end
  expandAlias( 'col get staff', false )
  expandAlias( 'col get halo', false )
  expandAlias( 'col get cuffs', false )
  expandAlias( 'col hold staff', false )
  expandAlias( 'col wear halo', false )
  expandAlias( 'col wear cuffs', false )

  expandAlias( 'las get staff', false )
  expandAlias( 'las get cuffs', false )
  expandAlias( 'las hold staff', false )
  expandAlias( 'las wear cuffs', false )
  expandAlias( 'las wear crocodile', false )

  expandAlias( 'nan get staff', false )
  expandAlias( 'nan get crocodile', false )
  expandAlias( 'nan hold staff', false )
  expandAlias( 'nan wear crocodile', false )

  expandAlias( 'nad hold staff', false )
  expandAlias( 'nad wear cuffs', false )

  expandAlias( "las give halo nandor", false )
  tempTimer( 1, [[expandAlias( "nan wear halo", false )]] )

  expandAlias( 'all save', false )
end

-- Prepare cloning sequence with gear assignments
local function startClone()
  nadjaClones = {'cuffs', 'skin'}
  laszloClones = {'halo'}

  expandAlias( "nan rem halo", false )
  expandAlias( "nan give halo laszlo", false )
  send( 'get skin stocking', false )
  send( 'give skin nadja', false )

  -- And remove the items to clone
  expandAlias( 'nad rem cuffs', false )
end

local function nadwield()
  expandAlias( 'nad rem ring', false )
  expandAlias( 'nad rem gloves', false )
  expandAlias( 'nad rem leg', false )
  expandAlias( 'nad wear sky', false )
  expandAlias( 'nad wear gauntlets', false )
  expandAlias( 'nad wear bionic', false )
  expandAlias( 'nad wield spirit', false )
  expandAlias( 'nad hold malachite', false )
  expandAlias( 'nad rem sky', false )
  expandAlias( 'nad rem gauntlets', false )
  expandAlias( 'nad rem bionic', false )
  expandAlias( 'nad give sky colin', false )
  expandAlias( 'nad give gauntlets colin', false )
  expandAlias( 'nad give bionic colin', false )
  expandAlias( 'nad wear ring', false )
  expandAlias( 'nad wear gloves', false )
  expandAlias( 'nad wear leg', false )
end

local function colwield()
  expandAlias( 'col rem ring', false )
  expandAlias( 'col rem greaves', false )
  expandAlias( 'col wear sky', false )
  expandAlias( 'col wear bionic', false )
  expandAlias( 'col wear gauntlets', false )
  expandAlias( 'col wield hammer', false )
  expandAlias( 'col hold malachite', false )
  expandAlias( 'col rem sky', false )
  expandAlias( 'col rem gauntlets', false )
  expandAlias( 'col rem bionic', false )
  expandAlias( 'col give sky laszlo', false )
  expandAlias( 'col give gauntlets laszlo', false )
  expandAlias( 'col give bionic laszlo', false )
  expandAlias( 'col wear onyx', false )
  expandAlias( 'col wear greaves', false )
end

-- Use with cecho etc. to colorize output without massively long f-strings
local function ec( s, c )
  local colors = {
    err  = "orange_red",   -- Error
    dbg  = "dodger_blue",  -- Debug
    val  = "blue_violet",  -- Value
    var  = "dark_orange",  -- Variable Name
    func = "green_yellow", -- Function Name
    info = "sea_green",    -- Info/Data
  }
  local sc = colors[c] or "ivory"
  if c ~= 'func' then
    return "<" .. sc .. ">" .. s .. RC
  else
    return "<" .. sc .. ">" .. s .. "<reset>()"
  end
end

-- Group related areas into a contiguous group for labeling purposes
local function getLabelArea()
  if currentAreaNumber == 21 or currentAreaNumber == 30 or currentAreaNumber == 24 or currentAreaNumber == 22 or currentAreaData == 110 then
    return 21
  elseif currentAreaNumber == 89 or currentAreaNumber == 116 or currentAreaNumber == 87 then
    return 87
  elseif currentAreaNumber == 108 or currentAreaNumber == 103 or currentAreaNumber == 102 then
    return 102
  else
    return tonumber( currentAreaNumber )
  end
end

-- Prototype/beta function for importing Wintin commands from an external file
local function importWintinActions()
  local testActions = {}
  -- Make an empty group to hold the imported triggers
  permRegexTrigger( "Imported", "", {"^#"}, "" )

  local triggerCounter = 1

  for _, actionString in ipairs( testActions ) do
    local triggerName = "Imported" .. triggerCounter
    local pattern, command, priority = parseWintinAction( actionString )

    command = f [[print("{command}")]]

    if isRegex( pattern ) then
      permRegexTrigger( triggerName, "Imported", {pattern}, command )
    else
      permSubstringTrigger( triggerName, "Imported", {pattern}, command )
    end
    triggerCounter = triggerCounter + 1
  end
end

-- Clean up minimum room numbers corrupted by my dumb ass
local function fixMinimumRoomNumbers()
  local aid = 0
  while worldData[aid] do
    local roomsData = worldData[aid].rooms
    local minRoom = nil
    for _, room in pairs( roomsData ) do
      local roomRNumber = tonumber( room.roomRNumber )
      if roomRNumber and (not minRoom or minRoom > roomRNumber) then
        minRoom = roomRNumber
      end
    end
    if minRoom and minRoom ~= worldData[aid].areaMinRoomRNumber then
      setMinimumRoomNumber( aid, minRoom )
    end
    aid = aid + 1
    -- Skip area 107
    if aid == 107 then aid = aid + 1 end
  end
end

-- One-Time Load all of the door data into the doorData table and save it
local function loadDoorData()
  local doorCount = 0
  local allRooms = getRooms()
  doorData = {} -- Initialize the doorData table

  for id, name in pairs( allRooms ) do
    --id = tonumber( r )
    if not id then
      cecho( f "\nFailed to convert{r} to number." )
    else
      local doors = getDoors( id )
      if next( doors ) then               -- Check if there are doors in the room
        doorData[id] = doorData[id] or {} -- Initialize the table for the room

        for dir, status in pairs( doors ) do
          local doorString, keyNumber = getDoorData( id, tostring( dir ) )
          doorData[id][dir] = {}           -- Initialize the table for the direction
          doorData[id][dir].state = status -- 1 for regular, 2 for locked
          doorData[id][dir].word = doorString

          if keyNumber and keyNumber > 0 then
            doorData[id][dir].key = keyNumber
          end
          doorCount = doorCount + 1
        end
      end
    end
  end
  cecho( f "\nLoaded <maroon>{doorCount}<reset> doors.\n" )
  table.save( "C:/Dev/mud/mudlet/gizmo/data/doorData.lua", doorData )
end

-- Help create the master door data table (one time load)
local function getDoorData( id, dir )
  local exitData = worldData[roomToAreaMap[id]].rooms[id].exits
  for _, exit in pairs( exitData ) do
    if SDIR[exit.exitDirection] == dir then
      local kw = exit.exitKeyword:match( "%w+" )
      local kn = tonumber( exit.exitKey )
      return kw, kn
    end
  end
end

-- Run some checks on the doorData table/file to make sure it's valid
local function validateDoorData()
  --loadTable( "doorData" ) -- Load the doorData table from file
  local errorCount = 0
  local verifiedCount = 0

  for id, doors in pairs( doorData ) do
    local mudletDoors = getDoors( id )
    local roomExits = getRoomExits( id )

    for dir, doorInfo in pairs( doors ) do
      -- 1.1 Verify doorData[x][dir] matches an entry in the table returned by getDoors(x)
      if not mudletDoors[dir] then
        cecho( f "\nError: Door in room {id} direction {dir} not found in Mudlet door data." )
        errorCount = errorCount + 1
      end
      -- 1.2 Verify the room has a full valid exit leading that direction
      local fullDir = LDIR[dir] or dir
      if not roomExits[fullDir] then
        cecho( f "\nError: No valid exit {fullDir} in room {id}." )
        errorCount = errorCount + 1
      end
      -- 1.3 Verify that the door has a keyword string with 1 or more characters
      if not doorInfo.word or #doorInfo.word == 0 then
        cecho( f "\nError: Door in room {id} direction {dir} has no keyword." )
        errorCount = errorCount + 1
      end
      -- 1.4 Verify door state and key if locked
      if doorInfo.state == 3 and (not doorInfo.key or doorInfo.key <= 0) then
        cecho( f "\nError: Locked door in room {id} direction {dir} has invalid key." )
        errorCount = errorCount + 1
      end
      if errorCount == 0 then
        verifiedCount = verifiedCount + 1
      end
    end
  end
  if errorCount == 0 then
    cecho( f "\nSuccessfully verified {verifiedCount} doors." )
  else
    cecho( f "\nCompleted validation with {errorCount} errors found." )
  end
end

-- Original function to instantiate an empty world
local function createEmptyAreas()
  for _, areaData in pairs( worldData ) do
    local areaName, areaID = areaData.areaName, areaData.areaRNumber
    if areaID ~= 0 then
      addAreaName( areaName )
    end
  end
  for _, areaData in pairs( worldData ) do
    local areaName, areaID = areaData.areaName, areaData.areaRNumber
    if areaID ~= 0 then
      setAreaName( areaID, areaName )
    end
  end
end

-- Given a list of room numbers, traverse them virtually while looking for doors in our path; add
-- open commands as needed and produce a WINTIN-compatible command list including opens and moves.
local function traverseRooms( roomList )
  -- Check if the room list is valid
  if not roomList or #roomList == 0 then
    cecho( "\nError: Invalid room list provided." )
    return {}
  end
  local directionsTaken = {} -- This will store all the directions and 'open' commands

  -- Iterate through each room in the path
  for i = 1, #roomList - 1 do
    local currentRoom = tonumber( roomList[i] )  -- Current room in the iteration
    local nextRoom = tonumber( roomList[i + 1] ) -- The next room in the path

    local found = false                          -- Flag to check if a valid exit is found for the next room

    -- Search for the current room in the worldData
    for areaRNumber, areaData in pairs( worldData ) do
      if areaData.rooms[currentRoom] then
        local roomData = areaData.rooms[currentRoom]

        -- Iterate through exits of the current room
        for _, exit in pairs( roomData.exits ) do
          -- Check if the exit leads to the next room
          if exit.exitDest == nextRoom then
            found = true

            -- Check if the exit is a door and add 'open' command to directions
            -- This is for offline/virtual movement, so the command isn't executed
            if exit.exitFlags ~= -1 and exit.exitKeyword and exit.exitKeyword ~= "" then
              local doorString = ""
              local keyword = exit.exitKeyword:match( "%w+" )
              local keynum = exit.exitKey
              -- A door with a key number but no keyword to unlock might be a problem in the data
              if keynum > 0 and (not keyword or keyword == "") then
                gizErr( "Key with no keyword found in room " .. currentRoom )
              end
              -- If the door has a key number, unlock it before opening
              if keyword and keynum > 0 then
                doorString = "unlock " .. keyword .. ";open " .. keyword
              elseif keyword and (not keynum or keynum < 0) then
                doorString = "open " .. keyword
              end
              table.insert( directionsTaken, doorString )
            end
            -- Use moveExit to update the virtual location in the map
            moveExit( exit.exitDirection )
            table.insert( directionsTaken, exit.exitDirection )
            break -- Exit found, no need to continue checking other exits
          end
        end
        if found then
          break -- Exit found, no need to continue checking other areas
        end
      end
    end
    -- If no valid exit is found, report an error
    if not found then
      cecho( "\nError: Path broken at room " .. currentRoom .. " to " .. nextRoom )
      return {}
    end
  end
  return directionsTaken -- Return the list of directions and 'open' commands
end

-- Replaced by getFullPath/getAreaDirs
local function getMSPath()
  -- Clear the path globals
  local dirString = nil
  speedWalkDir = nil
  speedWalkPath = nil

  -- Calculate the path to our current room from Market Square
  getPath( 1121, currentRoomNumber )
  if speedWalkDir then
    dirString = traverseRooms( speedWalkPath )
    -- Add an entry to the entryRooms table that maps currentAreaNumber to currentRoomNumber and the path to that room from Market Square
    cecho( f "\nAdding or updating path from MS to {getRoomString(currentRoomNumber,1)}" )
    entryRooms[currentAreaNumber] = {
      roomNumber = currentRoomNumber,
      path = dirString
    }
  else
    cecho( "\nUnable to find a path from Market Square to the current room." )
  end
  saveTable( 'entryRooms' )
end

-- Original function to populate areaDirs table
local function getAreaDirs()
  local fullDirs = getFullDirs( 1121, currentRoomNumber )
  local roomArea = getRoomArea( currentRoomNumber )
  if fullDirs then
    areaDirs[roomArea]            = {}
    -- Store our Wintin-compatible path string along with the raw output from Mudlet's pathing
    areaDirs[roomArea].dirs       = fullDirs
    areaDirs[roomArea].rawDirs    = speedWalkDir
    -- Store the name & number of the destination room (the area entry room)
    areaDirs[roomArea].roomNumber = currentRoomNumber
    areaDirs[roomArea].roomName   = getRoomName( currentRoomNumber )
    -- The cost to walk the path is two times the length
    areaDirs[roomArea].cost       = (#speedWalkDir * 2)
    cecho( f "\nAdded <dark_orange>{nextArea}<reset> to the areaDirs table" )
  end
end

-- Not as good an attempt to do getAreaDirs()
local function getAreaDirs()
  for _, roomID in ipairs( areaFirstRooms ) do
    local pathString = getFullDirs( 1121, roomID ) -- Assuming 1121 is your starting room (e.g., Market Square)
    if pathString then
      cecho( f(
        "\nPath from <dark_orange>1121<reset> to room <dark_orange>{roomID}<reset>:\n\t<olive_drab>{pathString}" ) )
    else
      cecho( f( "\nNo path found from <dark_orange>1121<reset> to room <dark_orange>{roomID}<reset>" ) )
    end
  end
end

--Brute force find the room that's closest to our current location that belongs to the given area
local function findArea( id )
  local allRooms           = getRooms()
  local shortestDirsLength = 750000 -- Initialize to a very high number
  local shortestDirs       = nil
  local nearestRoom        = nil

  for r, n in pairs( allRooms ) do -- Use pairs for iteration
    local roomID = tonumber( r )
    if getRoomArea( roomID ) == id then
      if getPath( 1121, roomID ) then -- Check if path is found
        local currentPathLength = #speedWalkDir
        if currentPathLength < shortestDirsLength then
          shortestDirsLength = currentPathLength
          nearestRoom        = getRoomString( roomID, 2 )
          shortestDirs       = getFullDirs( 1121, roomID )
        end
      end
    end
  end
  if shortestDirs then
    doWintin( shortestDirs )
    return true
  else
    cecho( f "\nFailed to find a room in area <dark_orange>{id}<reset>" )
    return false
  end
end

local function buildAreaMap()
  areaMap = {}
  for areaID in pairs( areaDirs ) do
    local areaName = getRoomAreaName( areaID )
    if areaName then
      -- Cleanse & normalize the names
      print( areaName )
      areaName = areaName:gsub( "^The%s+", "" ):gsub( "%s+", "" ):lower()
      print( areaName )
      areaMap[areaName] = areaID
    end
  end
end

local function combinePhantom()
  local phantom1 = worldData[102].rooms
  local phantom2 = worldData[103].rooms
  local phantom3 = worldData[108].rooms
  local movedRooms = 0
  for _, room in pairs( phantom2 ) do
    local id = room.roomRNumber
    if roomExists( id ) and getRoomArea( id ) ~= 102 then
      setRoomArea( id, 102 )
      movedRooms = movedRooms + 1
    end
  end
  for _, room in pairs( phantom3 ) do
    local id = room.roomRNumber
    if roomExists( id ) and getRoomArea( id ) ~= 102 then
      setRoomArea( id, 102 )
      movedRooms = movedRooms + 1
    end
  end
  cecho( f "\n{movedRooms} rooms moved to Phantom Zone." )
end

local function areaHunt()
  local rooms = getRooms()
  local areaID = 1
  for areaID = 1, 128 do
    if areaID == 107 then areaID = areaID + 1 end
    local areaData = worldData[areaID]
    local roomData = areaData.rooms
    for _, room in pairs( roomData ) do
      local id = room.roomRNumber
      if roomExists( id ) then
        exitData = room.exits
        for _, exit in pairs( exitData ) do
          local dir = exit.exitDirection
          local to = exit.exitDest
          if not roomExists( to ) and not ignoredRooms[to] then
            cecho( f "\n<firebrick>{to}<reset> is <cyan>{dir}<reset> from <dark_orange>{id}" )
          end
        end
      end
    end
  end
end

-- Report on Rooms which have been moved in the Mudlet client to an Area other than their original
-- Area from the database.
local function movedRoomsReport()
  local ac = MAP_COLOR["area"]
  for areaID = 1, 128 do
    -- Skip Area 107; it's missing from our database
    if areaID == 107 then areaID = areaID + 1 end
    local areaData = worldData[areaID]
    local roomData = areaData.rooms
    for _, room in pairs( roomData ) do
      local id = room.roomRNumber
      local mudletArea = getRoomArea( id )
      local dataArea = roomToAreaMap[id]
      if mudletArea and dataArea and (mudletArea ~= dataArea) then
        cecho( f "\n{getRoomString(id,1)} from {ac}{dataArea}<reset> has moved to {ac}{mudletArea}<reset>" )
      end
    end
  end
end

-- Like findNewRoom(), but globally; search every Area in the MUD for a Room that has an Exit leading
-- to a Room that hasn't been mapped yet.
local function findNewLand()
  local ac = MAP_COLOR["area"]
  -- getRooms() dumps a global list of mapped Room Names & IDs with no other detail
  for id, name in pairs( getRooms() ) do
    -- getRoomArea tells us which Area a Room is in
    local areaID = getRoomArea( id )
    -- While worldData was derived from the database and may contain unmapped Areas and Rooms
    if worldData[areaID] and worldData[areaID].rooms[id] then
      local roomData = worldData[areaID].rooms[id]
      local exitData = roomData.exits
      -- Check the destination of each Exit and report back of there's a Room that doesn't exist
      -- and hasn't been flagged unmappable.
      for _, exit in pairs( exitData ) do
        local dir = exit.exitDirection
        local to = exit.exitDest
        if not roomExists( to ) and not contains( unmappable, to ) then
          -- Uncomment this to immediately walk to the first unmapped Room
          --expandAlias( f 'goto {rnum}' );return
          cecho( f "\n<firebrick>{to}<reset> is <cyan>{dir}<reset> from <dark_orange>{id}" )
        end
      end
    end
  end
end

-- Search every room in the current Area for one that has an Exit to a room we haven't mapped yet.
local function findNewRoom()
  -- Get a list of every Room in the area
  local allRooms = getAreaRooms( currentAreaNumber )
  -- Which is zero-based for some godforsaken reason...
  local r = 0
  while allRooms[r] do
    local rnum = allRooms[r]
    -- Verify the Room exists
    if worldData[currentAreaNumber].rooms[rnum] then
      -- Then check all of its Exits to see if any lead to an unmapped room
      local exitData = worldData[currentAreaNumber].rooms[rnum].exits
      for _, exit in pairs( exitData ) do
        local dir = exit.exitDirection
        local to = exit.exitDest
        if not roomExists( to ) then
          -- Uncomment this to immediately walk to the first unmapped Room
          --expandAlias( f 'goto {rnum}' );return
          cecho( f "\n(<firebrick>{to}<reset>) is <cyan>{dir}<reset> from (<dark_orange>{rnum}<reset>)" )
          return
        end
      end
    end
    r = r + 1
  end
  -- If we didn't find any unmapped rooms, run a report to verify
  cecho( "\n<green_yellow>No unmapped rooms found at this time.<reset>" )
end

local function areaReport()
  local nc = MAP_COLOR["number"]
  local ac = MAP_COLOR["area"]
  mapInfo( f "Map report for {ac}{currentAreaName}<reset> [{ac}{currentAreaNumber}<reset>]" )
  local areaData = worldData[currentAreaNumber]
  local dbCount = areaData.areaRoomCount
  local mudletCount = 0
  local roomData = areaData.rooms
  for _, room in pairs( roomData ) do
    local id = room.roomRNumber
    if not roomExists( id ) and not ignoredRooms[id] then
      mapInfo( f "<firebrick>Missing<reset>: {getRoomString(id,2)}" )
    else
      mudletCount = mudletCount + 1
    end
  end
  local unmappedCount = dbCount - mudletCount
  mapInfo( f '<yellow_green>Database<reset> rooms: {nc}{dbCount}<reset>' )
  mapInfo( f '<olive_drab>Mudlet<reset> rooms: {nc}{mudletCount}<reset>' )
end

local function worldReport()
  local nc          = MAP_COLOR["number"]
  local ac          = MAP_COLOR["area"]
  local worldCount  = 0
  local mappedCount = 0
  local missedCount = 0
  for areaID = 1, 128 do
    -- Skip Area 107; it's missing from our database
    if areaID == 107 then areaID = areaID + 1 end
    local areaData = worldData[areaID]
    local roomData = areaData.rooms
    for _, room in pairs( roomData ) do
      local id = room.roomRNumber
      worldCount = worldCount + 1
      if roomExists( id ) or ignoredRooms[id] then
        mappedCount = mappedCount + 1
      else
        local roomArea = roomToAreaMap[id]
        local roomAreaName = worldData[areaID].areaName
        cecho( f "\n{getRoomString(id,2)} in {ac}{roomAreaName}<reset>" )
        missedCount = missedCount + 1
        if missedCount > 5 then return end
      end
    end
  end
  local unmappedCount = worldCount - mappedCount
  mapInfo( f '<yellow_green>World<reset> total: {nc}{worldCount}<reset>' )
  mapInfo( f '<olive_drab>Mapped<reset> total: {nc}{mappedCount}<reset>' )
  mapInfo( f '<orange_red>Unmapped<reset> total: {nc}{unmappedCount}<reset>' )
end

-- Basically just getPathAlias but automatically follow the route.
local function gotoAlias()
  getPathAlias()
  doSpeedWalk()
end

-- Use built-in Mudlet path finding to get a path to the specified room.
local function getPathAlias()
  -- Clear the path globals
  speedWalkDir = nil
  speedWalkPath = nil

  local dstRoomName = nil
  local dstRoomNumber = tonumber( matches[2] )
  local dstRoomString = getRoomString( dstRoomNumber )
  local dirString = nil

  local nc, rc = MAP_COLOR["number"], MAP_COLOR["roomNameU"]

  if currentRoomNumber == dstRoomNumber then
    cecho( f "\nYou're already in {rc}{currentRoomName}<reset> [{nc}{dstRoomNumber}<reset>]" )
  elseif not roomExists( dstRoomNumber ) then
    cecho( f "\nRoom {nc}{dstRoomNumber}<reset> doesn't exist yet." )
  else
    getPath( currentRoomNumber, dstRoomNumber )
    if speedWalkDir then
      dstRoomName = getRoomName( dstRoomNumber )
      dirString1 = createWintin( speedWalkDir )
      dirString2 = createWintinGPT( speedWalkDir )
      cecho( f "\n\nPath from {getRoomString(currentRoomNumber)} to {getRoomString(dstRoomNumber)}:" )
      cecho( f "\n\t<orange>{dirString1}<reset>" )
      cecho( f "\n\t<yellow_green>{dirString2}<reset>" )
      walkPath = dirString
    end
  end
end

-- Iterate over all rooms in the map; for any room with an up/down exit, add a gradient highlight circle;
-- uses getModifiedColor() to create a highlight based off the room's current color (terrain type)
local function highlightStairs()
  -- Map room types to their respective environment IDs (color table index)
  local TYPE_MAP = {
    ['Forest']    = COLOR_FOREST,
    ['Mountains'] = COLOR_MOUNTAINS,
    ['City']      = COLOR_CITY,
    ['Water']     = COLOR_WATER,
    ['Field']     = COLOR_FIELD,
    ['Hills']     = COLOR_HILLS,
    ['Deepwater'] = COLOR_DEEPWATER,
    ['Inside']    = COLOR_INSIDE,
  }

  -- For all rooms in the map, check exits for up/down and highlight accordingly
  local roomsChecked = 0
  for id, name in pairs( getRooms() ) do
    roomsChecked = roomsChecked + 1
    local exits = getRoomExits( id )
    if exits['up'] or exits['down'] then
      unHighlightRoom( id )
      local roomName = getRoomName( id )
      local roomType = getRoomUserData( id, "roomType" )
      local roomEnv = roomColors[TYPE_MAP[roomType]]

      if roomEnv then
        local br, bg, bb = roomEnv[1], roomEnv[2], roomEnv[3]
        -- Highlight with colors -33% and +66% off baseline (makes a little "cone" effect)
        local h1r, h1g, h1b = getModifiedColor( br, bg, bb, -20 )
        local h2r, h2g, h2b = getModifiedColor( br, bg, bb, 80 )
        highlightRoom( id, h1r, h1g, h1b, h2r, h2g, h2b, 0.45, 255, 255 )
      end
    end
  end
  cecho( f "\nChecked {roomsChecked} rooms." )
end

local function showAreaPaths()
  cecho( f "\nGlobal Area Paths:\n" )
  for areaID, entryData in pairs( entryRooms ) do
    local roomNumber = entryData.roomNumber
    local areaName = getRoomAreaName( getRoomArea( roomNumber ) )
    local path = entryData.path
    cecho( f [[
<medium_violet_red>{areaName}<reset> <dim_grey>[<reset><maroon>{areaID}<reset><dim_grey>]<reset>
    <dim_grey>Entrance: {getRoomString(roomNumber,1)}
    <dim_grey>Dirs: <olive_drab>{path}<reset>
]] )
  end
end

local function updateAreaPaths()
  cecho( f "\nGlobal Area Paths:\n" )
  for areaID, entryData in pairs( entryRooms ) do
    local roomNumber = entryData.roomNumber
    local oldPath = entryData.path
    local areaName = getRoomAreaName( getRoomArea( roomNumber ) )
    print( f "Looking for path to: {roomNumber}" )
    --getPath( 1121, roomNumber )
    --display( speedWalkPath )
    local newPath = getFullDirs( 1121, tonumber( roomNumber ) )
    --<dim_grey>New Dirs: <yellow_green>{display(newPath)}<reset>
    cecho( f [[
<medium_violet_red>{areaName}<reset> <dim_grey>[<reset><maroon>{areaID}<reset><dim_grey>]<reset>
    <dim_grey>Entrance: {getRoomString(roomNumber,1)}
    <dim_grey>Dirs: <olive_drab>{oldPath}<reset>
]] )
  end
end

-- For all rooms globally delete any exit which leads to its own origin (and store that exit in culledExits)
local function cullLoopedExits()
  local cullCount = 0
  local allRooms = getRooms()
  for id, name in pairs( allRooms ) do
    local exits = getRoomExits( id )
    for dir, dst in pairs( exits ) do
      if dst == id then
        cullCount = cullCount + 1
        culledExits[id] = culledExits[id] or {}
        setExit( id, -1, dir )
        culledExits[id][dir] = true
        cecho( f "\n<dim_grey>Culled looping <cyan>{dir}<dim_grey> exit from <dark_orange>{id}<reset>" )
      end
    end
  end
  cecho( f "\n<dim_grey>Culled <dark_orange>{cullCount}<dim_grey> total exits<reset>" )
  updateMap()
  table.save( 'C:/Dev/mud/mudlet/gizmo/data/culledExits.lua', culledExits )
end

local function combineArea( dstArea, srcArea )
  local srcRooms = getAreaRooms( srcArea )
  for _, srcRoom in ipairs( srcRooms ) do
    setRoomArea( srcRoom, dstArea )
  end
  updateMap()
end

local function getRoomStringOld( id, detail )
  detail = detail or 1
  local specTag = ""
  local roomString = nil
  local roomData = worldData[roomToAreaMap[id]].rooms[id]
  local roomName = roomData.roomName
  local nc = MAP_COLOR["number"]
  local rc = nil

  if roomData.roomSpec > 0 then
    specTag = f " ~<ansi_light_yellow>{roomData.roomSpec}<reset>~"
  end
  if uniqueRooms[roomName] then
    rc = MAP_COLOR['roomNameU']
  else
    rc = MAP_COLOR['roomName']
  end
  -- Detail 1 is name and number
  if detail == 1 then
    roomString = f "{rc}{roomName}<reset> ({MAP_COLOR['number']}{id}<reset>){specTag}"
    return roomString
  end
  -- Add room type for detail level 2
  local roomType = roomData.roomType
  local tc = MAP_COLOR[roomType]
  if detail == 2 then
    roomString = f "{rc}{roomName}<reset> [{tc}{roomType}<reset>] ({nc}{id}<reset>){specTag}"
    return roomString
  end
  -- Add map coordinates at level 3
  local uc = MAP_COLOR["mapui"]
  local cX = nil
  local cY = nil
  local cZ = nil
  cX, cY, cZ = getRoomCoordinates( id )
  local cString = f "{uc}{cX}<reset>, {uc}{cY}<reset>, {uc}{cZ}<reset>"
  roomString = f "{rc}{roomName}<reset> [{tc}{roomType}<reset>] ({nc}{id}<reset>) ({cString}){specTag}"
  return roomString
end

-- Attempt a "virtual move"; on success report on area transitions and update virtual coordinates.
local function moveExitOld( direction )
  local nc = MAP_COLOR["number"]
  -- Guard against variations in the Exit data by searching for the Exit in question
  for _, exit in pairs( currentRoomData.exits ) do
    if exit.exitDirection == direction then
      if not roomToAreaMap[exit.exitDest] then
        cecho( f "\n<dim_grey>err: Room {nc}{exit.exitDest}<reset><dim_grey> has no area mapping.<reset>" )
        return
      end
      -- Update coordinates for the new Room (and possibly Area)
      updatePlayerLocation( exit.exitDest, direction )
      displayRoom()
      return true
    end
  end
  cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
  return false
end

-- Load all Exit data from the gizwrld.db database into a Lua table
local function loadExitData()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  if not conn then
    gizErr( "Error connecting to gizwrld.db." )
    return nil
  end
  local cursor = conn:execute( "SELECT * FROM Exit" )

  local row = cursor:fetch( {}, "a" )
  while row do
    local roomID = tonumber( row.roomRNumber )
    local dir = row.exitDirection
    local keyword = row.exitKeyword

    -- Only store exits with a keyword that is not nil and not an empty string
    if keyword and #keyword > 0 then
      -- Extract only the first word from the keyword
      local firstWord = keyword:match( "^(%w+)" )
      exitData[roomID] = exitData[roomID] or {}
      exitData[roomID][dir] = {
        exitDest = tonumber( row.exitDest ),
        exitKeyword = firstWord,
        exitFlags = tonumber( row.exitFlags ),
        exitDescription = row.exitDescription
      }

      -- Only store keys when exitKey is not nil and greater than 0
      local key = tonumber( row.exitKey )
      if key and key > 0 then
        exitData[roomID][dir].exitKey = key
      end
    end
    row = cursor:fetch( row, "a" )
  end
  cursor:close()
  conn:close()
  env:close()

  table.save( 'C:/Dev/mud/mudlet/gizmo/data/exitData.lua', exitData )
end

-- Load all Exit data from the gizwrld.db database into a Lua table
local function loadExitData()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  if not conn then
    gizErr( "Error connecting to gizwrld.db." )
    return nil
  end
  local cursor = conn:execute( "SELECT * FROM Exit" )

  local row = cursor:fetch( {}, "a" )
  while row do
    local roomID = tonumber( row.roomRNumber )
    local dir = row.exitDirection
    local keyword = row.exitKeyword

    -- Only store exits with a keyword that is not nil and not an empty string
    if keyword and #keyword > 0 then
      -- Extract only the first word from the keyword
      local firstWord = keyword:match( "^(%w+)" )
      exitData[roomID] = exitData[roomID] or {}
      exitData[roomID][dir] = {
        exitDest = tonumber( row.exitDest ),
        exitKeyword = firstWord,
        exitFlags = tonumber( row.exitFlags ),
        exitDescription = row.exitDescription
      }

      -- Only store keys when exitKey is not nil and greater than 0
      local key = tonumber( row.exitKey )
      if key and key > 0 then
        exitData[roomID][dir].exitKey = key
      end
    end
    row = cursor:fetch( row, "a" )
  end
  cursor:close()
  conn:close()
  env:close()

  table.save( 'C:/Dev/mud/mudlet/gizmo/data/exitData.lua', exitData )
end

-- Get the Area data for a given areaRNumber
local function getAreaData( areaRNumber )
  return worldData[areaRNumber]
end

-- Get the Room data for a given roomRNumber
local function getRoomData( roomRNumber )
  local areaRNumber = roomToAreaMap[roomRNumber]
  if areaRNumber and worldData[areaRNumber] then
    return worldData[areaRNumber].rooms[roomRNumber]
  end
end

-- Use a breadth-first-search (BFS) to find the shortest path between two rooms
local function findShortestPath( srcRoom, dstRoom )
  if srcRoom == dstRoom then return {srcRoom} end
  -- Table for visisted rooms to avoid revisiting
  local visitedRooms = {}

  -- The search queue, seeded with the srcRoom
  local pathQueue    = {{srcRoom}}

  -- As long as there are paths in the queue, "pop" one off and explore it fully
  while #pathQueue > 0 do
    local path = table.remove( pathQueue, 1 )
    local lastRoom = path[#path]

    -- Only visit unvisited rooms (this path)
    if not visitedRooms[lastRoom] then
      -- Mark the room visited
      visitedRooms[lastRoom] = true

      -- Look up the room in the worldData table
      for _, areaData in pairs( worldData ) do
        local roomData = areaData.rooms[lastRoom]

        -- For the love of St. Christopher (patron saint of bachelors and travel), don't add DTs to paths
        if roomData and not roomData.roomFlags:find( "DEATH" ) then
          -- Examine each exit from the room
          for _, exit in pairs( roomData.exits ) do
            local nextRoom = exit.exitDest

            -- If one of the exits is dstRoom; constrcut and return the path
            if nextRoom == dstRoom then
              local shortestPath = {unpack( path )}
              table.insert( shortestPath, nextRoom )
              return shortestPath
            end
            -- Otherwise, extend the path and queue
            if not visitedRooms[nextRoom] then
              local newPath = {unpack( path )}
              table.insert( newPath, nextRoom )
              pathQueue[#pathQueue + 1] = newPath
            end
          end
        end
      end
    end
  end
  -- Couldn't find a path to the destination
  return nil
end

local function roomsReport()
  local minRoom = worldData[currentAreaNumber].areaMinRoomRNumber
  local maxRoom = worldData[currentAreaNumber].areaMaxRoomRNumber
  local roomsMapped = 0
  for r = minRoom, maxRoom do
    if roomExists( r ) then roomsMapped = roomsMapped + 1 end
  end
  --local mappedRooms = getAreaRooms( currentAreaNumber )
  --local roomsMapped = #mappedRooms + 1
  local roomsTotal = worldData[currentAreaNumber].areaRoomCount
  local roomsLeft = roomsTotal - roomsMapped
  local ac = MAP_COLOR["area"]
  local nc = MAP_COLOR["number"]
  local rc = MAP_COLOR["roomName"]
  mapInfo( f 'Found <yellow_green>{roomsMapped}<reset> of <dark_orange>{roomsTotal}<reset> rooms in {areaTag()}<reset>.' )

  -- Check if there are 10 or fewer rooms left to map
  if roomsLeft == 0 then
    mapInfo( "<yellow_green>Area Complete!<reset>" )
  elseif roomsLeft > 0 and roomsLeft <= 10 then
    mapInfo( "\n<orange>Unmapped<reset>:\n" )
    for roomRNumber, roomData in pairs( worldData[currentAreaNumber].rooms ) do
      if not contains( roomsMapped, roomRNumber, true ) then
        local roomName = roomData.roomName
        local exitsInfo = ""

        -- Iterate through exits using pairs
        for _, exit in pairs( roomData.exits ) do
          exitsInfo = exitsInfo .. exit.exitDirection .. f " to {nc}" .. exit.exitDest .. "<reset>; "
        end
        cecho( f '[+   Room: {rc}{roomName}<reset> (ID: {nc}{roomRNumber}<reset>)\n    Exits: {exitsInfo}\n' )
      end
    end
  end
  local worldRooms = getRooms()
  local worldRoomsCount = 0

  for _ in pairs( worldRooms ) do
    worldRoomsCount = worldRoomsCount + 1
  end
  mapInfo( f '<olive_drab>World<reset> total: {nc}{worldRoomsCount}<reset>' )
end

local function roomTag()
  return f "<light_steel_blue>currentRoomName<reset> [<royal_blue>currentRoomNumber<reset>]"
end

-- Function to find all neighboring rooms with exits leading to a specific roomRNumber
local function findNeighbors( targetRoomRNumber )
  local neighbors = {}
  local nc = MAP_COLOR["number"]
  local minR, maxR = currentAreaData.areaMinRoomRNumber, currentAreaData.areaMaxRoomRNumber
  for r = minR, maxR do
    local roomData = currentAreaData.rooms[r]
    local exitData = roomData.exits
    for _, exit in pairs( exitData ) do
      if exit.exitDest == targetRoomRNumber then
        table.insert( neighbors, r )
      end
    end
  end
  mapInfo( f ' Neighbors for {nc}{targetRoomRNumber}<reset>:\n' )
  display( neighbors )
end

local function setMinimumRoomNumber( areaID, newMinimum )
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )
  local nc = MAP_COLOR["number"]
  local ac = MAP_COLOR["area"]
  if not conn then
    gizErr( 'Error connecting to gizwrld.db.' )
    return
  end
  -- Fetch the current minimum room number for the area
  local cursor, err = conn:execute( f(
    "SELECT areaMinRoomRNumber FROM Area WHERE areaRNumber = {areaID}" ) )
  if not cursor then
    gizErr( f( "Error fetching data for {ac}{areaID}<reset>: {err}" ) )
    return
  end
  local row = cursor:fetch( {}, "a" )
  if not row then
    gizErr( f "Area {ac}{areaID}<reset> not found." )
    return
  end
  local currentMinRoomNumber = tonumber( row.areaMinRoomRNumber )
  if currentMinRoomNumber == newMinimum then
    cecho( f "\nFirst room for {ac}{areaID}<reset> already {nc}{newMinimum}<reset>" )
  else
    -- Update the minimum room number
    local update_stmt = f(
      "UPDATE Area SET areaMinRoomRNumber = {newMinimum} WHERE areaRNumber = {areaID}" )
    local res, upd_err = conn:execute( update_stmt )
    if not res then
      gizErr( f( "Error updating data for {ac}{areaID}<reset>: {upd_err}" ) )
      return
    end
    cecho( f "\nUpdated first room for {ac}{areaID}<reset> from {nc}{currentMinRoomNumber}<reset> to {nc}{newMinimum}<reset>" )
  end
  -- Clean up
  if cursor then cursor:close() end
  conn:close()
  env:close()
end

-- From the current room, search for neighboring rooms in this Area;
local function auditAreaCoordinates()
  local nc = MAP_COLOR["number"]
  local areaCoordinates = {}
  local minRoom = worldData[currentAreaNumber].areaMinRoomRNumber
  local maxRoom = worldData[currentAreaNumber].areaMaxRoomRNumber

  for r = minRoom, maxRoom do
    if roomExists( r ) then
      local roomX, roomY, roomZ = getRoomCoordinates( r )
      local coordKey = roomX .. ":" .. roomY .. ":" .. roomZ

      if areaCoordinates[coordKey] then
        -- Found overlapping rooms
        cecho( f(
          "\nRooms {nc}{areaCoordinates[coordKey]}<reset> and {nc}{r}<reset> overlap at coordinates ({roomX}, {roomY}, {roomZ})." ) )
      else
        -- Store the coordinate key with its room number
        areaCoordinates[coordKey] = r
      end
    end
  end
end

local function countRooms()
  local areaCounts = {}
  local allRooms = getRooms()
  for id, name in pairs( allRooms ) do
    local area = getRoomArea( id )
    local areaName = getRoomAreaName( area )
    areaCounts[areaName] = (areaCounts[areaName] or 0) + 1
  end
  display( areaCounts )
end

-- A function to determine whether a Room belongs to a given Area
local function isInArea( roomID, areaID )
  local roomArea = getRoomArea( roomID )
  -- If the Room exists (i.e., it has been mapped), then use Mudlet as our source of truth
  if roomArea == areaID or roomArea == getRoomArea( currentRoomNumber ) then
    return true
    -- If the Room has not been mapped, see if it is a member of the Area's room table in the worldData table
  elseif not roomExists( roomID ) and worldData[areaID].rooms[roomID] then
    return true
  end
  return false
end

-- From the gizwrld database, load the Area, Room, and Exit data into a Lua table
local function loadWorldData()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  if not conn then
    gizErr( f 'Error connecting to gizwrld.db.' )
    return nil
  end
  local areas = {}
  local cursor

  -- Load Areas
  cursor = conn:execute( "SELECT * FROM Area" )
  local row = cursor:fetch( {}, "a" )
  while row do
    areas[row.areaRNumber] = {
      areaRNumber = row.areaRNumber,
      areaName = row.areaName,
      areaResetType = row.areaResetType,
      areaFirstRoomName = row.areaFirstRoomName,
      areaMinRoomRNumber = row.areaMinRoomRNumber,
      areaMaxRoomRNumber = row.areaMaxRoomRNumber,
      areaMinVNumber = row.areaMinVNumber,
      areaMaxVNumberActual = row.areaMaxVNumberActual,
      areaMaxVNumberAllowed = row.areaMaxVNumberAllowed,
      areaRoomCount = row.areaRoomCount,
      rooms = {}
    }
    row = cursor:fetch( row, "a" )
  end
  cursor:close()

  -- Load Rooms
  cursor = conn:execute( "SELECT * FROM Room" )
  row = cursor:fetch( {}, "a" )
  while row do
    if areas[row.areaRNumber] then
      areas[row.areaRNumber].rooms[row.roomRNumber] = {
        roomRNumber = row.roomRNumber,
        roomName = row.roomName,
        roomType = row.roomType,
        roomSpec = row.roomSpec,
        roomFlags = row.roomFlags,
        roomDescription = row.roomDescription,
        roomExtraKeyword = row.roomExtraKeyword,
        roomVNumber = row.roomVNumber,
        exits = {}
      }
    else
      cecho( f '{{Unmatched Room: {row.roomRNumber} in Area: {row.areaRNumber}\n' )
    end
    row = cursor:fetch( row, "a" )
  end
  cursor:close()

  -- Load Exits
  cursor = conn:execute( "SELECT * FROM Exit" )
  row = cursor:fetch( {}, "a" )
  while row do
    for _, area in pairs( areas ) do
      if area.rooms[row.roomRNumber] then
        table.insert( area.rooms[row.roomRNumber].exits, {
          exitID = row.exitID,
          exitDirection = row.exitDirection,
          exitDest = row.exitDest,
          exitKeyword = row.exitKeyword,
          exitFlags = row.exitFlags,
          exitKey = row.exitKey,
          exitDescription = row.exitDescription
        } )
        break -- Exit found and added, no need to continue looping through areas
      end
    end
    row = cursor:fetch( row, "a" )
  end
  -- Create a lookup table that maps roomRNumber(s) to areaRNumber(s)
  for areaID, area in pairs( areas ) do
    for roomID, _ in pairs( area.rooms ) do
      roomToAreaMap[roomID] = areaID
    end
  end
  cursor:close()
  conn:close()
  env:close()
  return areas
end

--[[
local functions to load, query, and interact with data from the database: 'C:/Dev/mud/gizmo/data/gizwrld.db'

Table Structure:
  Area Table:
  areaRNumber INTEGER; A unique identifier and primary key for Area
  areaName TEXT; The name of the Area in the MUD
  areaResetType TEXT; A string describing how and when the area repopulates
  areaFirstRoomName TEXT; The name of the first Room in the Area; usually the Room with areaMinRoomRNumber
  areaMinRoomRNumber INTEGER; The lowest value of roomRNumber for Rooms in the Area
  areaMaxRoomRNumber INTEGER; The highest value of roomRNumber for Rooms in the Area
  areaMinVNumber INTEGER; The lowest value of roomVNumber for Rooms in the Area; usually the same room as areaMinRoomRNumber
  areaMaxVNumberActual INTEGER; The highest value for Rooms that actually exist in the Area
  areaMaxVNumberAllowed INTEGER; The highest value that a Room could theoretically have in the Area
  areaRoomCount INTEGER; How many Rooms are in the Area

  Room Table:
  roomName TEXT; The name of the Room in the MUD
  roomVNumber INTEGER; The VNumber of the Room; an alternative identifier
  roomRNumber INTEGER; The RNumber of the Room; the primary unique identifier
  roomType TEXT; The "Terrain" or "Sector" type of the Room; will be used for color selection
  roomSpec BOOLEAN; Boolean value identifying Rooms with "special procedures" which will affect players in the Room
  roomFlags TEXT; A list of flags that identify special properties of the Room
  roomDescription TEXT; A long description of the Room that players see in game
  roomExtraKeyword TEXT; A list of one or more words that identify things in the room players can examine or interact with
  areaRNumber INTEGER; Foreign key to the Area in which this Room exists

  Exit Table:
  exitDirection TEXT; The direction the player must travel to use this Exit
  exitDest INTEGER; The roomRNumber of the Room the player travels to when using this Exit
  exitKeyword TEXT; Keywords Players use to interact with an Exit such as 'door' or 'gate'
  exitFlags INTEGER; A list of flags that identify special properties of an Exit, usually a door
  exitKey INTEGER; For Exits that require keys to lock/unlock, this is the in-game ID for the key
  exitDescription TEXT; A short description of the Exit such as 'A gravel path leading west.'
  roomRNumber INTEGER; Foreign key to the Room in which this Exit belongs
--]]
-- From the gizwrld database, load the Area, Room, and Exit data into a Lua table
local function loadFollowData()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  if not conn then
    gizErr( f 'Error connecting to gizwrld.db.' )
    return nil
  end
  local areas = {}
  local cursor

  -- Load Areas
  cursor = conn:execute( "SELECT * FROM Area" )
  local row = cursor:fetch( {}, "a" )
  while row do
    areas[row.areaRNumber] = {
      areaRNumber = row.areaRNumber,
      areaName = row.areaName,
      rooms = {}
    }
    row = cursor:fetch( row, "a" )
  end
  cursor:close()

  -- Load Rooms
  cursor = conn:execute( "SELECT * FROM Room" )
  row = cursor:fetch( {}, "a" )
  while row do
    if areas[row.areaRNumber] then
      areas[row.areaRNumber].rooms[row.roomRNumber] = {
        roomRNumber = row.roomRNumber,
        roomName = row.roomName,
        exits = {}
      }
    else
      cecho( f '{{Unmatched Room: {row.roomRNumber} in Area: {row.areaRNumber}\n' )
    end
    row = cursor:fetch( row, "a" )
  end
  cursor:close()

  -- Load Exits
  cursor = conn:execute( "SELECT * FROM Exit" )
  row = cursor:fetch( {}, "a" )
  while row do
    for _, area in pairs( areas ) do
      if area.rooms[row.roomRNumber] then
        table.insert( area.rooms[row.roomRNumber].exits, {
          exitDirection = row.exitDirection,
          exitDest = row.exitDest,
        } )
        break -- Exit found and added, no need to continue looping through areas
      end
    end
    row = cursor:fetch( row, "a" )
  end
  -- Create a lookup table that maps roomRNumber(s) to areaRNumber(s)
  for areaID, area in pairs( areas ) do
    for roomID, _ in pairs( area.rooms ) do
      roomToAreaMap[roomID] = areaID
    end
  end
  cursor:close()
  conn:close()
  env:close()
  -- Create a lookup table that maps roomRNumber(s) to areaRNumber(s)
  for areaID, area in pairs( areas ) do
    for roomID, _ in pairs( area.rooms ) do
      roomToAreaMap[roomID] = areaID
    end
  end
  return areas
end

-- Basically just getPathAlias but automatically follow the route.
local function gotoAlias()
  getPathAlias()
  doWintin( walkPath )
end

-- Use built-in Mudlet path finding to get a path to the specified room.
local function getPathAlias()
  -- Clear the pathing globals
  speedWalkDir = nil
  speedWalkPath = nil

  local nc = MAP_COLOR["number"]
  local rc = MAP_COLOR["roomNameU"]
  local dirs = nil
  local dstRoomName = nil
  local dstRoomNumber = tonumber( matches[2] )
  if currentRoomNumber == dstRoomNumber then
    cecho( f "\nYou're already in {rc}{currentRoomName}<reset>." )
  elseif not roomExists( dstRoomNumber ) then
    cecho( f "\nRoom {nc}{dstRoomNumber}<reset> doesn't exist yet." )
  else
    getPath( currentRoomNumber, dstRoomNumber )
    if speedWalkDir then
      dstRoomName = getRoomName( dstRoomNumber )
      dirs = createWintin( speedWalkDir )
      cecho( f "\n\nPath from {rc}{currentRoomName}<reset> [{nc}{currentRoomNumber}<reset>] to {rc}{dstRoomName}<reset> [{nc}{dstRoomNumber}<reset>]:" )
      cecho( f "\n<green_yellow>{dirs}<reset>" )
      walkPath = dirs
    end
  end
end

-- Create all Exits, Exit Stubs, and/or Doors from the Current Room to adjacent Rooms
local function updateExits()
  if true then return end
  for _, exit in ipairs( currentRoomData.exits ) do
    local exitDirection = exit.exitDirection
    if (not culledExits[currentRoomNumber]) or (not culledExits[currentRoomNumber][exitDirection]) then
      local exitDest = tonumber( exit.exitDest )
      local exitKeyword = exit.exitKeyword
      local exitFlags = exit.exitFlags
      local exitKey = tonumber( exit.exitKey )
      local exitDescription = exit.exitDescription

      -- Skip any exits that lead to the room we're already in
      if exitDest ~= currentRoomNumber then
        -- If the destination room is already mapped, remove any existing exit stub and create a "real" exit in that direction
        if roomExists( exitDest ) then
          setExitStub( currentRoomNumber, exitDirection, false )
          setExit( currentRoomNumber, exitDest, exitDirection )

          -- If the destination room we just linked links back to the current room, create the corresponding reverse exit
          local reverseDir = EXIT_MAP[REVERSE[exitDirection]]
          local destStubs = getExitStubs1( exitDest )
          if contains( destStubs, reverseDir, false ) then
            setExitStub( exitDest, reverseDir, false )
            setExit( exitDest, currentRoomNumber, reverseDir )
          end
          -- With all exits presumably created, call optimizeExits to remove superfluous or redundant exits
          -- (e.g., if room A has e/w exits to room B but room B only has an e exit to room A, we'll eliminate the w exit from A)
          --optimizeExits( currentRoomNumber )
        else
          -- If the destination room hasn't been mapped yet, create a stub for later
          setExitStub( currentRoomNumber, exitDirection, true )
        end
        -- The presence of exitFlags indicates a door; a non-zero key value indicates locked status
        if exitFlags and exitFlags ~= -1 then
          local doorStatus = (exitKey and exitKey > 0) and 3 or 2
          local shortExit = exitDirection:match( '%w' )
          setDoor( currentRoomNumber, shortExit, doorStatus )
          if exitKey and exitKey > 0 then
            setRoomUserData( currentRoomNumber, f "key_{shortExit}", exitKey )
          end
        end
      end
    end
  end
end

-- Cull redundant (leading to the same room) exits from a given room
local function cullRedundantExits( roomID )
  local roomExits = getRoomExits( roomID )
  local exitCounts = {}

  -- Count the number of exits leading to each destination
  for dir, destID in pairs( roomExits ) do
    if not exitCounts[destID] then
      exitCounts[destID] = {}
    end
    table.insert( exitCounts[destID], dir )
  end
  for destID, exits in pairs( exitCounts ) do
    -- Proceed only if there are multiple exits leading to the same destination
    if #exits > 1 then
      culledExits[roomID] = culledExits[roomID] or {}

      -- If the destination room has a "reverse" (return) of the exit, keep that one
      local destExits = getRoomExits( destID )
      local reverseExit = nil
      for destDir, backDestID in pairs( destExits ) do
        if backDestID == roomID then
          reverseExit = destDir
          break
        end
      end
      -- Find the corresponding exit to keep
      local exitToKeep = nil
      if reverseExit then
        for _, exitDir in pairs( exits ) do
          exitToKeep = exitDir
          break
        end
      end
    end
    -- If there's no matching 'return' exit, prefer exits in this order
    if not exitToKeep then
      local dirOrder = {"north", "south", "east", "west", "up", "down"}
      for _, dir in ipairs( dirOrder ) do
        if contains( exits, dir, true ) then
          exitToKeep = dir
          break
        end
      end
    end
    -- Remove all exits except the one to keep
    for _, exitDir in pairs( exits ) do
      if exitDir ~= exitToKeep then
        cullExit( exitDir )
      end
    end
  end
end

-- Set & update the player's location, updating coordinates & creating rooms as necessary
local function updatePlayerLocationyy( roomRNumber, direction )
  -- Store data about where we "came from" to get here
  if direction then
    lastDir = direction
  end
  -- Update the current Room (this function updates Area as needed)
  setCurrentRoom( roomRNumber )
  -- If the room exists already, set coordinates, otherwise calculate new ones based on the direction of travel
  if roomExists( currentRoomNumber ) then
    mX, mY, mZ = getRoomCoordinates( currentRoomNumber )
  else
    mX, mY, mZ = getNextCoordinates( direction )
    createRoom()
  end
  --updateExits()
  centerview( currentRoomNumber )
end

local function splitPrint( str, delimiter )
  local substrings = split( str, delimiter )
  for _, substring in ipairs( substrings ) do
    print( substring )
  end
end

-- Select which ANTI-FLAGS to include in stat output from eq/eq_db.lua
local function customizeAntiString( antis )
  local includedFlags = {
    ["!NEU"] = true,
    ["!GOO"] = true,
    ["!EVI"] = true,
    --["!MU"] = true,
    --["!CL"] = true,
    --["!CO"] = true,
    ["!BA"] = true,
    ["!WA"] = true,
    ["!TH"] = true,
    ["!FEM"] = true,
    --["!MAL"] = true,
    ["!RENT"] = true
  }

  -- Match & replace any flag that isn't in the included table
  antis = antis:gsub( "!%w+", function ( flag )
    if not includedFlags[flag] then
      return ""
    else
      return flag
    end
  end )

  -- Trim and condense
  return antis:gsub( "%s+", " " ):trim()
end

local function initializeReactions()
  cecho( "\nInitial Trigger, Alias, and Key states\n" )
  cecho( "______________________________________\n" )

  local function formatReactionState( reaction, isEnabled )
    local typeTag = reaction.type == "trigger" and "<hot_pink>T<reset>" or
        (reaction.type == "key" and "<dark_turquoise>K<reset>" or "<ansi_yellow>A<reset>")
    local nameState = isEnabled and f "<olive_drab>+{reaction.name}<reset>" or
        f "<brown>-{reaction.name}<reset>"
    return string.format( "%-5s %-5s %-35s", reaction.scope, typeTag, nameState )
  end

  for _, reaction in ipairs( initialReactionState ) do
    if reaction.scope == "All" or (reaction.scope == "Main" and SESSION == 1) or (reaction.scope == "Alts" and SESSION ~= 1) then
      local isEnabled = false
      if reaction.type == "trigger" then
        if reaction.state then
          enableTrigger( reaction.name )
          isEnabled = true
        else
          disableTrigger( reaction.name )
        end
      elseif reaction.type == "alias" then
        if reaction.state then
          enableAlias( reaction.name )
          isEnabled = true
        else
          disableAlias( reaction.name )
        end
      elseif reaction.type == "key" then
        if reaction.state then
          enableKey( reaction.name )
          isEnabled = true
        else
          disableKey( reaction.name )
        end
      end
      local formattedReaction = formatReactionState( reaction, isEnabled )
      cecho( f "\n{formattedReaction}" )
    end
  end
end

-- Override moveExit while offline to simulate movement and display virtual rooms
local function nextCmd( direction )
  if CreatingPath then
    addCommandToPath( direction )
  end
  -- Make sure direction is long-version like 'north' to align with getRoomExits()
  local dir = LDIR[direction]
  local exits = getRoomExits( CurrentRoomNumber )

  if not exits[dir] then
    cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
    return false
  end
  local dst = tonumber( exits[dir] )
  if roomExists( dst ) then
    setPlayerRoom( dst )
    displayRoom( dst, false )
    return true
  end
  cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
  return false
end

-- Simulate a 'scroll of recall'; magical item in game that returns the player to the starting room
local function virtualRecall()
  cecho( f "\n\n<orchid>You recite a <deep_pink>scroll of recall<orchid>.<reset>\n" )
  setPlayerRoom( 1121 )
  displayRoom( 1121, true )
end

-- Display a full "simulated" room including name, description (if not brief), and exits
-- By default, display the current room in brief mode (no room description)
local function displayRoom( id, brief )
  local rd = MAP_COLOR["roomDesc"]
  cfeedTriggers( f "\n\n{getRoomString(id, 2)}" )
  if not brief then
    local desc = getRoomUserData( id, "roomDescription" )
    cfeedTriggers( f "{rd}{desc}<reset>" )
  end
  cecho( "\n\n<slate_grey>< 250(250) 400(400) 500(500) ><reset>" )
end

-- Virtually traverse an exit from the players' current location to an adjoining room;
-- This is the primary function used to "follow" the PCs position in the Map; it is synchronized
-- with the MUD through the use of the mapQueue
local function moveExit( direction )
  -- Make sure direction is long-version like 'north' to align with getRoomExits()
  local dir = LDIR[direction]
  local exits = getRoomExits( currentRoomNumber )

  if not exits[dir] then
    cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
    return false
  end
  local dst = tonumber( exits[dir] )
  if roomExists( dst ) then
    updatePlayerLocation( dst, direction )
    return true
  end
  cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
  return false
end

-- Build a "line" of all exits from the current room, color-coded based on the attributes of
-- the exit or destination room.
local function getExitString( id )
  local exitData    = getRoomExits( id )
  local exitString  = ""
  local isFirstExit = true
  local sortedExits = {}
  local dc          = MAP_COLOR["exitDir"]

  for dir, to in pairs( exitData ) do
    table.insert( sortedExits, {dir = dir, to = to} )
  end
  table.sort( sortedExits, function ( a, b )
    local dirA = DIRECTIONS[a.dir]
    local dirB = DIRECTIONS[b.dir]
    return dirA < dirB
  end )
  for _, exit in ipairs( sortedExits ) do
    local dir = exit.dir
    local to = exit.to
    local tc = getExitColor( to, dir )
    local nextExit = f "{tc}{dir}<reset>"
    if isFirstExit then
      isFirstExit = false
      exitString = f "<dim_grey>   Obvious Exits:   [" .. nextExit .. f "<dim_grey>]<reset>"
    else
      exitString = exitString .. f " <dim_grey>[<reset>" .. nextExit .. f "<dim_grey>]<reset>"
    end
  end
  return exitString
end

-- Select one of the predefined colors to display an Exit based on Door and Destination status
-- Prioritize colros and exit early as soon as the first condition is met
local function getExitColor( to, dir )
  local isMissing = not roomExists( to )
  if isMissing then return ERRC end
  local toFlags = getRoomUserData( to, "roomFlags" )
  local isDT    = toFlags and toFlags:find( "DEATH" )
  if isDT then return DTC end
  local isDoor = doorData[CurrentRoomNumber] and doorData[CurrentRoomNumber][LDIR[dir]]
  local hasKey = isDoor and doorData[CurrentRoomNumber][LDIR[dir]].exitKey
  if hasKey then return KEYC elseif isDoor then return DOORC end
  local isBorder = CurrentAreaNumber ~= getRoomArea( to )
  if isBorder then return ARC else return EXC end
end

-- Get a useful string representation of an Area including it's ID number for output (e.g., with cecho)
local function getAreaTag()
  return f "<medium_violet_red>{CurrentAreaName}<reset> [<maroon>{CurrentAreaNumber}<reset>]"
end

-- Get a string representing a door depending on its status and key value
local function getDoorString( word, key )
  -- Double declaration because VSCode is confused by f-string interpolation
  local doorString, keyString, wordString = nil, nil, nil
  doorString, keyString, wordString = "", "", ""
  if word then wordString = f "<light_goldenrod>{word}<reset>" end
  if key then keyString = f " (<lawn_green>{key}<reset>)" end
  doorString = f " <dim_grey>past a {wordString}{keyString}"
  return doorString
end

local function displayExits( id )
  local exitString = ""
  if not id or id < 1 then
    exitString = "<dim_grey>   Obvious Exits:   <dim_grey>[No Data]<reset>"
  else
    exitString = getExitString( id )
  end
  cecho( f "\n{exitString}" )
end
