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

-- Advertise The Archive by occasionally contributing an item to The Archive when a player
-- arrives in the room.

-- One-time initialization of the table of items for the auto-contribute feature
function createACFile()
  ACItems = {
    "tooth",
    "sickle",
    "snake",
    "flowing",
    "ettin",
    "masoch",
    "golden",
    "dangling",
    "names",
    "dragonrider",
    "covered",
    "cannibal",
    "heroism",
    "skull",
    "necklace",
    "blackened",
    "adamantite",
    "medallion",
    "gloves",
    "righteousness",
    "feather",
    "insect",
    "earth",
    "handcuffs",
    "sleeves",
    "chaos",
    "might",
    "adventurers",
    "rope",
    "accordian",
    "blackgloves",
    "pearl",
    "tuning",
    "dirty",
    "platinum",
    "small",
    "darkness",
    "sobs",
    "signet",
    "slender",
    "vest",
    "fiend",
    "diamonds",
    "eye",
    "crawdad",
    "wrist",
    "human",
    "pointy",
    "skin",
    "heavy",
    "threggi",
    "sala",
    "thigh",
    "dragons",
    "transparent",
    "gurundi",
    "bangle",
    "protection",
    "aman",
    "legs",
    "alabaster",
    "jeweled",
    "lord",
    "buckler",
    "crystal",
    "sky",
    "lich",
    "wind",
    "dragon",
    "lich",
    "shovel",
    "jeweled",
    "headmaster",
    "emer",
    "ygaddrozil",
    "flesh",
    "bloody",
    "manifestation",
    "drop",
    "scalpel",
    "spiral",
    "sleeves",
    "order",
    "pair",
    "tmask",
    "helmet",
    "blkbrac",
    "scale",
    "crystal",
    "onyx",
    "globe",
    "bom",
    "idiocy",
    "kings",
    "loftwick",
    "sorrow",
    "working",
    "lies",
    "stone",
  }
  table.save( f '{DATA_PATH}/ACItems.lua', ACItems )
end

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
