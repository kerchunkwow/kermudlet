-- Attempt to insert a newly captured item into the Items registry; skip items which are
-- fully identical, and file alternate versions in an Alternate Items table for later review
AutoSavingData = AutoSavingData or true
ArchivedItems = table.size( Items )
function addItemObject( newItem )
  local desc = newItem.shortDescription
  local existingItem = Items[desc]

  -- If an item with the same short already appears in the archives; do a deep compare to
  -- see if they are identical.
  if existingItem then
    local itemDifferences = {}
    -- If the items are exactly identical, we don't want to store any data
    if deepCompareItems( existingItem, newItem, itemDifferences ) then
      speak( "DUPLICATE" )
      rejectDuplicate()
    elseif isAlternateVersion( existingItem, newItem ) then
      -- If the items are alternate versions of each other, store them in a separate table
      displayItemDifferences( itemDifferences )
      cecho( f "{GDITM} <dark_orchid>Alternate<reset> Item Accepted: {SC}{desc}{RC}" )
      speak( "ALTERNATE" )
      acceptAlternate( newItem )
    end
  else
    -- The item is new and unique; add it to the Items table
    -- [TODO] Eventually, we should add a "validation" step to ensure new items are complete
    -- and inclusive of all required basic data
    cecho( f "{GDITM} <chartreuse>New<reset> Item Accepted: {SC}{desc}{RC}" )

    -- if CurrentPlayer is non-nil, set the contributor attribute of the item before inserting it
    if CurrentPlayer then
      newItem.contributor = CurrentPlayer
      speak( "NEW" )
      local bounty = calculateItemBounty( newItem )
      send( f "give {bounty} coins {CurrentPlayer}" )
      -- Convert the bounty amount into a nice string for reporting in-game
      bounty = "say A fine specimen worth every one of these `k" ..
          expandNumber( bounty ) .. "`q coins."
      send( bounty )
    end
    local recorded = getTime( true, "yyyy.MM.dd hh:mm:ss" )

    -- Record the date/time of the item's record creation
    ItemObject.dateRecorded = recorded
    insertData( "Items", desc, newItem )
    -- Update the global item count
    ArchivedItems = table.size( Items )
    --cout( f "{GDITM} <ansi_red>REMINDER<reset>: Item addition temporarily disabled" )
    -- If the newly added item's desc is in the UnknownItems table, remove it
    if UnknownItems[desc] then
      UnknownItems[desc] = nil
    end
    -- Finally, store the name of the most recent item
    LastItem = desc
    -- If we're auto-saving, write the data file every time a new item is added
    if AutoSavingData then saveDataFiles() end
  end
  speakItemStats( desc )
end

-- In contrast to deepCompare() this function is designed to determine when two items are
-- alternate versions of an item; that is, the same "base item" with alternate stats which
-- can happen in certain cases like quest items or items with variable stats. An item is
-- considered to be an alternate version if it has equivalence in:
-- 1. baseType
-- 2. worn
-- 3. longDescription
-- 4. shortDescription
AlternateItems = AlternateItems or {}
function isAlternateVersion( foundItem, newItem )
  return foundItem.baseType == newItem.baseType and
      foundItem.worn == newItem.worn and
      foundItem.longDescription == newItem.longDescription and
      foundItem.shortDescription == newItem.shortDescription
end

-- Compare two items after filtering fields flagged for exclusion
function deepCompareItems( item1, item2, itemDifferences )
  local function filterFields( item )
    local filteredItem = {}
    for k, v in pairs( item ) do
      if not EXCLUDE_FROM_COMPARE[k] then
        filteredItem[k] = v
      end
    end
    return filteredItem
  end
  local filteredItem1 = filterFields( item1 )
  local filteredItem2 = filterFields( item2 )
  return deepCompare( filteredItem1, filteredItem2, itemDifferences )
end

-- Unlike the Items table which is indexed by short description, the AlternateItems table will
-- need to use sequential indices because it may have many items with the same descriptions
function acceptAlternate( newItem )
  table.insert( AlternateItems, newItem )
  saveSafe( f '{DATA_PATH}/AlternateItems.lua', AlternateItems )
end

-- Placeholder for handling the case where a duplicate item add was attempted; when running the
-- ID bot, this will be common and will require an appropriate response to the user
function rejectDuplicate()
end

-- Remove an item from the Items table by key (short description); useful for cleanup & especially
-- during testing.
function deleteItem( desc )
  if Items[desc] then
    Items[desc] = nil
    cecho( f "{GDITM} {SC}{desc}{RC} <deep_pink>deleted<reset> from Items" )
  else
    cecho( f "{GDITM} deleteItem() called for {EC}unknown item{RC}" )
  end
end

-- Uses LastItem to delete the item most recently added; this is the most common application as
-- new items are added but some error was seen during the ID capture process.
function deleteLastItem()
  deleteItem( LastItem )
end

-- To help identify items "on the ground" that are not yet in the database, this function
-- iterates through the Items table and compares the parameter to each known item's longDescription,
-- returning true if a match is found. Rather than servicing the ID and capture process, this is
-- about recognizing items in the game world that are not yet in the database.
function itemIsKnown( longDescription )
  for _, item in pairs( Items ) do
    if item.longDescription == longDescription then
      return true
    end
  end
  return false
end

-- Simple helper to determine if an item falls into a consumable baseType
function consumable( type )
  return type == "POTION" or type == "SCROLL" or type == "WAND" or type == "STAFF"
end

-- Item names (short descriptions) in game include modifying strings which indicate additional properties of items
-- these are not relevant to our purpose and will not be stored in the database, so this function exists to trim & discard
-- e.g., The Sword of Truth (glowing) (humming) -> The Sword of Truth
function trimItemName( name )
  -- Look for known modifiers
  local flags = {"%(glowing%)", "%(humming%)", "%(invisible%)", "%(cloned%)", "%(lined%)", "%(blue%)"}

  -- Strip them off the end of the name
  for _, flag in ipairs( flags ) do
    name = string.gsub( name, flag, '' )
  end
  -- Item names can also vary when they are modified by jewelcrafting (e.g., with a buckle);
  -- here we trim that content so we can match the raw name in the database
  name = string.gsub( name, ' with %w+ %w+ buckle', '' )
  return trimCondense( name )
end

-- Given a search string, returns a list of all items whose names contain that string
-- Comparison is case-insensitive
function getMatchingItemNames( str )
  str = trim( str )
  str = string.lower( str )
  local matches = {}
  for desc, item in pairs( Items ) do
    name = string.lower( desc )
    if string.find( name, str ) then
      table.insert( matches, desc )
    end
  end
  return matches
end

-- This function sanitizes a single identifyText string by removing common errant patterns
function sanitizeIdentifyText( text )
  local dirtyPatterns = {
    "< %d+%(%d+%) %d+%(%d+%) %d+%(%d+%) >", -- A prompt (hp, mana, moves)
    "^%s*$",                                -- An empty line with no data
    "^%s*%.%s*$"                            -- A line with a single period and arbitrary whitespace
  }

  for _, pattern in ipairs( dirtyPatterns ) do
    text = text:gsub( pattern, "" )
  end
  return text
end

-- A function to help testing mapping & usability functions by creating a "random" player as a
-- combination of alignment, sex, and class
function getRandomProperties()
  local align, sex, class = nil, nil, nil
  local function randomProperty( map )
    local keys = {}
    for k, _ in pairs( map ) do
      table.insert( keys, k )
    end
    return keys[math.random( #keys )]
  end
  align = randomProperty( ALIGNMENT )
  sex   = randomProperty( SEX )
  class = randomProperty( CLASS )
  -- 20% of the time, switch align to "any"
  if math.random( 1, 5 ) == 1 then align = "any" end
  -- 20% of the time, switch sex to "any"
  if math.random( 1, 5 ) == 1 then sex = "any" end
  return align, sex, class
end

-- This function attempts to parse an input string and then map the components to player properties
function mapPlayerProperties( propertyString )
  -- Lower the input string and remove any extra internal & surrounding whitespace
  propertyString = propertyString:lower()
  propertyString = trimCondense( propertyString )
  -- Split the properties on space to convert to a table of strings
  propertyString = split( propertyString, " " )
  -- Confirm there are between 1 and 4 properties in the table (align, sex, class, worn)
  if #propertyString < 1 or #propertyString > 4 then
    cecho( "{EC}Invalid property count{RC} in mapPlayerProperties()" )
    return nil
  end
  -- Map an input string p to a property in the given map; return the property or nil if
  -- no match is found
  local function mapProperty( p, map )
    p = p:lower()
    for property, strings in pairs( map ) do
      for _, s in ipairs( strings ) do
        s = s:lower()
        if p:find( "^" .. s ) or s:find( "^" .. p ) then
          -- Use cecho to report which property was matched
          --cecho( f "\n\t{SC}{p}{RC} -> {NC}{property}{RC}" )
          return property
        end
      end
    end
    return nil
  end

  -- Local variables to hold the mapped player properties
  local align, sex, class, worn = nil, nil, nil, nil

  -- For each property in the properties table, attempt mapProperty( p, map ) on the ALIGNMENT,
  -- SEX, CLASS, and WORN_MAP maps in that order; when a match is found set the corresponding local variable
  for _, p in ipairs( propertyString ) do
    local matched = false
    if not align then
      align = mapProperty( p, ALIGNMENT )
      if align then matched = true end
    end
    if not matched and not sex then
      sex = mapProperty( p, SEX )
      if sex then matched = true end
    end
    if not matched and not class then
      class = mapProperty( p, CLASS )
      if class then matched = true end
    end
    if not matched and not worn then
      worn = mapProperty( p, WORN_MAP )
      if worn then matched = true end
    end
  end
  -- If any of align, sex, class, or worn are nil at this point, set them to "any"
  if not align then align = "any" end
  if not sex then sex = "any" end
  if not class then class = "any" end
  if not worn then worn = "any" end
  return align, sex, class, worn
end

function triggerMapProperties( p )
  p = trimCondense( p )
  local al, se, cl, wo = mapPlayerProperties( p )
  al = f "`k{al}`q"
  se = f "`f{se}`q"
  cl = f "`c{cl}`q"
  wo = f "`n{wo}`q"
  local res = f "Align: {al}, Sex: {se}, Class: {cl}, Worn: {wo}"
  send( f "say {res}" )
end

-- This function determines whether a given player will be able to equip a certain item based
-- on the item's "anti" flags and the player's alignment, sex, and class; this function will
-- be used to respond to queries in real-time in the game, so it must be made flexible to a variety
-- of inputs (i.e., abbreviations, case insensitivity, etc.)
function usable( item, align, sex, class )
  -- Construct a formatted anti-flag for comparison to in-game strings, or nil on "any"
  local function antiProperty( property )
    if property:lower() == "any" then return nil end
    return "ANTI-" .. property:upper()
  end

  -- Convert property parameters to corresponding anti-flags
  local antiAlign = antiProperty( align )
  local antiSex   = antiProperty( sex )
  local antiClass = antiProperty( class )

  local flags     = item.flags or {}

  -- Check if the item has any flags that make it unusable by the player
  local function hasAnti( flag )
    return table.contains( flags, flag )
  end

  local badAlign = hasAnti( antiAlign )
  local badSex   = hasAnti( antiSex )
  local badClass = hasAnti( antiClass )

  -- An item is unusuable if any of the anti-flags are present
  return not (badAlign or badSex or badClass)
end

-- Function to determine if an item is desirable by comparing its stats to those in the DESIRED_STATS table
function desired( item )
  -- Get the highest stats for this item's worn location
  local desiredStats = DESIRED_STATS[item.worn]
  -- Initialize desirability to false
  local isDesired = false
  -- Only consider items with valid worn locations
  if desiredStats then
    -- Store the actual stats of this item for comparison
    local itemStats = {
      armorClass = item.armorClass and item.armorClass * -1 or 0,
      averageDamage = item.averageDamage or 0,
      dr = item.dr or 0,
      hp = item.hp or 0,
      hr = item.hr or 0,
      mn = item.mn or 0,
    }
    -- If any of the item's stats meet or exceed the value in the highestStats table, the item is desirable
    for stat, value in pairs( itemStats ) do
      if desiredStats[stat] and value >= desiredStats[stat] then
        isDesired = true
        -- Use cecho to report on which stat/value pair made the item desirable
        --cecho( f "\n\t{SC}{stat} {VC}{value}{RC} >= {NC}{desiredStats[stat]}{RC}" )
      end
    end
  end
  return isDesired
end

function findDesiredItems( align, sex, class )
end

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

-- The purpose of this function is to identify common or frequently used keywords so they can be used
-- to locate new unidentified items that happen to have those same keywords
function findCommonKeywords()
  local keyWordCounts = {}
  -- For each item in Items, iterate over item.keywords; for each keyword, increment a count in keyWordCounts;
  -- Initialize count to 1 the first time a keyword is seen
  for _, item in pairs( Items ) do
    for _, keyword in ipairs( item.keywords ) do
      if not keyWordCounts[keyword] then
        keyWordCounts[keyword] = 1
      else
        keyWordCounts[keyword] = keyWordCounts[keyword] + 1
      end
    end
  end
  local keyWordMin = 2
  -- Remove any keywords in keyWordCounts with a count less than keyWordMin
  for keyword, count in pairs( keyWordCounts ) do
    if count < keyWordMin then
      keyWordCounts[keyword] = nil
    end
  end
  local totalUniqueKeywords = table.size( keyWordCounts )
  display( keyWordCounts )
  cecho( f "\nTotal keywords: {NC}{totalUniqueKeywords}{RC}" )
end
