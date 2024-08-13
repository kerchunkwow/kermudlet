--[[ item_bot.lua
-- Module to implement an in-game identification "bot" to identify items provided by other players;
-- Will need to implement some basic error-handling and inventory management to ensure people get
-- their items back and the bot doesn't get confsed or overwhelmed.
--]]

-- Global boolean and toggle to turn The Gizdex bot on and off
Gizdexing     = Gizdexing or false
GizdexVersion = "0.2"
function toggleGizdexing()
  Gizdexing = not Gizdexing
  if Gizdexing then
    cecho( "ID Bot <yellow_green>ON<reset>" )
    enableTrigger( "ID Bot" )
  else
    cecho( "ID Bot <orange_red>OFF<reset>" )
    disableTrigger( "ID Bot" )
  end
end

runLuaFile( 'gizmo/data/Profanity.lua' )
runLuaFile( 'gizmo/eq/item_bot_data.lua' )
runLuaFile( 'gizmo/eq/item_bot_id.lua' )
runLuaFile( 'gizmo/eq/item_bot_dialog.lua' )

function chatAd()
  local ads = {
    "I'm doing a thing and could use your help. Read about it. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "If you read this & feel compelled to help, tell me which part did the trick. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "Ever get the feeling like something awesome was about to happen? This isn't it, but you can help me while you wait. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "I think this might technically be against the rules, but it's probably just cool enough to get a pass. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "I can't do it without you. I probably can't do it with you either, but I definitely can't do it without you. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "I only had three reasons to get our of bed today and the other two are still in bed. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "You're not a wildcard. You're the card on the top of the deck with the instructions that I throw away. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "We were so poor, we used to use donkey dung for fuel and when the donkey dung ran out, we would have to burn the donkey. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "It's a big bloody stupid hat with a big bloody stupid curse on it. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "Be strong, sweet little one. Some day they will all be dead and you will do a shit on all of their graves. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "How are you supposed to be a strong, thrilling, powerful warrior and love with a name like Jeff? `ghttps://i.imgur.com/ToiR9Is.png`f",
    "We have come up with a list of all the things we would like to change once the vampires are in charge. `ghttps://i.imgur.com/ToiR9Is.png`f",
  }
  -- Choose an ad at random
  local ad = ads[math.random( #ads )]
  -- Send the chosen ad
  send( "goss " .. ad )
end

-- The purpose of this global & function are to iterate through the table of AllKeywords to
-- locate items within the game; the secondary benefit of this will be populating the table of
-- unidentified items that are currently loaded.
-- Each time this function is called, it should locate the "next" keyword in the list by calling:
-- expandAlias( f"loc {keyword}" )
-- Once all keywords have been located, the function should return to the start of the list
-- A global counter to keep track of the position in the AllKeywords list
KeywordsIndex = KeywordsIndex or 1
function locateCommonItems()
  -- If we're already locating, don't start another round
  if LocateTimer then return end
  -- Get the current keyword using the counter
  local keyword = AllKeywords[KeywordsIndex]

  -- Use cecho to report every 10th index
  if KeywordsIndex % 10 == 0 then
    cecho( f "\n\n\t[{SC}Keyword Index{RC} <ansi_red>==<reset> {NC}{KeywordsIndex}{RC}]\n\n" )
    table.save( f "{DATA_PATH}/UnknownItems.lua", UnknownItems )
  end
  -- Expand the alias to locate the current keyword
  expandAlias( f "loc {keyword}" )

  -- Increment the counter to the next keyword
  KeywordsIndex = KeywordsIndex + 1

  -- If the counter exceeds the length of the AllKeywords list, reset it to 1
  if KeywordsIndex > #AllKeywords then
    disableTimer( [[Locate Commons]] )
    send( "south;;south;;down" )
    KeywordsIndex = 1
  end
end

-- Global tables to keep track of items that have been located using 'locate object' within the current
-- game session; used to cross-reference with the item database to find new items to add.

-- UnknownItems holds any item which is not yet identified regardless of location
UnknownItems = UnknownItems or {}

-- Add an item to the UnknownItems table if this specific item, mob pair does not already exist
function addLoad( item, mob )
  -- For items not yet in the Items table, add them to the UnknownItems table for fetch quests
  if not Items[item] then
    -- Initialize the list if the item is not already present
    if not UnknownItems[item] then
      UnknownItems[item] = {}
    end
    -- Check if the mob is already in the list for the item
    for _, existingMob in ipairs( UnknownItems[item] ) do
      if existingMob == mob then
        return
      end
    end
    -- Add the mob to the list for the item
    table.insert( UnknownItems[item], mob )
  else
    -- For known items, do the same but use ItemLoads table for later cross-reference with mob data
    -- and tracking of load locations of known items
    if not ItemLoads[item] then
      ItemLoads[item] = {}
    end
    for _, existingMob in ipairs( ItemLoads[item] ) do
      if existingMob == mob then
        return
      end
    end
    table.insert( ItemLoads[item], mob )
    table.save( f "{DATA_PATH}/ItemLoads.lua", ItemLoads )
  end
end

-- Remove an item (and all associated mobs) from the UnknownItems table
function remLoad( item )
  UnknownItems[item] = nil
end

-- Construct a "request" message for an item in the UnknownItems table; a specific item can be
-- queried or if the parameter is nil then a random item should be selected from the table.
function requestLoad( item )
  if not item then
    -- Local function to select a random item from the UnknownItems table
    local function getRandomLoadedItem()
      local itemList = {}
      for k in pairs( UnknownItems ) do
        if not k:lower():match( "%f[%a]key%f[%A]" ) then
          table.insert( itemList, k )
        end
      end
      if #itemList == 0 then
        return nil
      end
      return itemList[math.random( #itemList )]
    end
    item = getRandomLoadedItem()
    if not item then
      cecho( "<red>No loaded items found.\n" )
      return
    end
  end
  local mobString = getItemMobList( item )
  speak( "FETCH_QUEST" )
end

function getItemMobList( item )
  local mobList = UnknownItems[item] or ItemLoads[item]

  if not mobList then
    print( "Error: Item not found in either table." )
    return nil
  end
  if UnknownItems[item] and ItemLoads[item] then
    print( "Error: Item found in both tables." )
    return nil
  end
  local mobString = ""
  -- Create a "mob string" using the mobList from this item, when more than one mob is present each
  -- should be separated by an "and" in the string for example:
  -- "a guard and a soldier"
  for i, mob in ipairs( mobList ) do
    if i == 1 then
      mobString = "`f" .. mob .. "`q"
    else
      mobString = mobString .. " or `f" .. mob .. "`q"
    end
  end
  return mobString
end

-- Verify items are in their proper location in the donation room by validating a list of items against
-- a checklist consisting of either worn locations or item base types
function auditDonations( itemList, checkList )
  -- Validate each item in the itemList to ensure:
  -- It has been identified (Items[item] exists)
  -- It has a matching worn value (Items[item].worn in checkList) OR
  -- It has a matching base type (Items[item].baseType in checkList)
  for _, item in ipairs( itemList ) do
    local itemData = Items[item]
    local worn = itemData and itemData.worn or nil
    local type = itemData and itemData.baseType or nil
    local valid = table.contains( checkList, worn ) or table.contains( checkList, type )
    if not valid then
      cecho( f "\n{SC}{item}{RC} ({worn}, {type})" )
      --cecho( f "\n{EC}Misplaced Item{RC}: {SC}{item}{RC} ({worn}, {type})" )
    end
  end
end

-- Function to sort a parcel in the donation room by removing items by type and placing them back into
-- the parcel; each time an item is put into a container it is sorted to the top, so this function should
-- effectively sort the parcel by item type.
function sortDonationParcel()
  local parcelItems = {
    "Adventurer's boots",
    "a Freezing Bracelet",
    "a Linen Bodice",
    "Dark banded mail",
    "Adventurer's cloak",
    "a Long Cloth Skirt",
    "a Belt of Ten Thousand Names",
    "Oaken Greaves",
    "small ring",
    "Spider cloak",
    "the Crown of the Marquis",
    "Silvery Dagger",
    "Elven bow",
    "a Wicked Tooth",
    "a mammoth's tusk",
    "a jeweled cutlass",
    "a dueling pistol",
    "an Oaken Cudgel",
    "the Spear of Hezryl",
    "a metal shovel",
    "a vibrant white potion",
    "a bright magenta potion",
    "a firey-red potion",
    "a scroll of purification",
    "a jug",
    "a pair of Cantu boots",
    "transparent potion",
    "Large copper key",
    "a Sslessi scale",
    "a scroll of armament",
    "the Path of Grace",
    "the meteorite key",
    "a Simurgh Feather",
    "a Crawdad Bible",
    "an ebony key",
    "a scroll of healing",
    "an excavation helmet",
    "a beautiful rose",
    "an iron key",
    "a sandstone keystone",
    "a copper keystone",
    "a granite keystone",
    "an iron keystone",
    "a diamond keystone",
    "a scroll of recall",
    "a knights sword",
    "a well-crafted longsword",
    "a well-crafted dagger",
    "an adamant ring encrusted with diamonds",
    "fiendish bracelet",
    "a Golden Halo",
    "Thigh-High Boots",
    "polished gold sollerets",
    "Vadir Belt",
    "Gold Dragon Shield",
    "Shield made from leaves",
    "the mark of the betrayer",
    "a blackened belt",
    "a Red Wristband",
    "a cloudy potion",
    "a stolen Shantak relic",
    "a lavish opium pipe",
    "hardtack",
    "a Huge Treasure Chest",
    "a scroll of remove curse",
    "a traveller belt",
    "an apple",
    "golden trident",
    "a smooth granite pole",
    "a silver cutlass",
    "a lumber axe",
    "a simple hammer",
    "a noble's longsword",
    "a firey dagger",
    "Golden scimitar",
    "a black broadsword",
    "a hammer",
    "a rowan staff of the sages",
    "a Glowing Amethyst",
    "a beech stick",
    "potion of harming",
    "a scroll of object location",
    "a maple stick",
    "a balsa stick",
    "a birch stick",
    "a pine stick",
    "an ash stick",
    "a poplar stick",
    "a jug",
    "a Small Sliver of Topaz",
    "an emerald staff",
    "an heirloom of the Dromaer family",
    "a thin chain of gold",
    "a Rum bottle",
    "an energy scroll",
    "elemental wand of lightning",
    "anti-cyclops elixir",
    "a peacock feather",
    "a treasure map",
    "a giraffe pelt",
    "a little emerald ring",
    "an herbal potion",
    "Talisman d'Balor",
    "a wand of invisibility",
    "elemental wand of wind and air",
    "magic dust",
    "a withered red rose",
    "a waterfall cloak",
    "a Pair of Rose Slippers",
    "a pair of adventurer arm bands",
    "an icy girth",
    "dwarven plate mail",
    "Silver Shield",
    "a pebble-studded sash",
    "a crown of rose petals",
    "Water Boots",
    "a pair of leather boots",
    "a black pendant",
    "a chequered shirt",
    "a Mercador riding spurs",
    "a white sash",
    "a Blue Jester's Cap",
    "a Moody Blue Hat",
    "a golden honey necklace",
    "a striped T-shirt",
    "a blue suit of Celestial",
    "a halfing cap",
    "flame red cape",
    "a pair of chaos leggings",
    "a glowing amulet",
    "an emerald ring",
    "a transparent cloak",
  }

  local parcelData = {}
  -- For each item in the parcelItems table, find its optimal keyword so it can be used in the subsequent
  -- get/put commands
  for _, desc in ipairs( parcelItems ) do
    local data = Items[desc]
    local itemType = data and data.baseType or nil
    local kw = BestKeywords[desc]
    if itemType and kw then
      table.insert( parcelData, {itemType, kw} )
    end
  end
  -- For each type in the ITEM_TYPES global table, look for items of that type in the parcelData and execute
  -- the corresponding get/put command to sort those items to the top of the parcel; this should sort items
  -- in the parcel in the same order as they appear in ITEM_TYPES
  local dt = 0.1
  for itemType in pairs( ITEM_TYPES ) do
    for _, item in ipairs( parcelData ) do
      if itemType == "WEAPON" and item[1] == itemType then
        -- Use tempTimer to separate each pair of commands by a short delay to prevent too much spam
        local itemKeyword = item[2]
        local getCmd = f "get all.{itemKeyword} parcel"
        --local putCmd = f "get all.{itemKeyword} chest"
        tempTimer( dt, function ()
          send( getCmd )
          --send( putCmd )
        end )
        dt = dt + 0.1
      end
    end
  end
end

function clearFoundItems()
  -- For each item in the UnknownItems table, remove it from the table if it contains the whole word "corpse", case insensitive
  for item in pairs( UnknownItems ) do
    if item:lower():match( "%f[%a]corpse%f[%A]" ) then
      UnknownItems[item] = nil
    end
  end
end

function sanitizeUnknown()
  -- Clean up the ItemLoads table by removing players and shopkeepers (we only care about mobs)
  -- For each item, list in ItemLoads, iterate over the list of loading entities, if any are in KnownPlayers, cecho item & name
  for item, mobList in pairs( UnknownItems ) do
    local trashItems = {"coins", "corpse"}
    local badMobs = {"someone", "shopkeeper", "armorer", "armourer", "weaponmaster", "weaponsmith"}
    local itemName = trim( item:lower() )
    for _, trashItem in ipairs( trashItems ) do
      if itemName:match( trashItem ) then
        cecho( f "\n{EC}{item}{RC} removed from UnknownItems" )
        UnknownItems[item] = nil
      end
    end
    for i, mob in ipairs( mobList ) do
      local isPC    = KnownPlayers[mob]
      local mobName = trim( mob:lower() )
      local isBad   = false
      for _, badMob in ipairs( badMobs ) do
        if mobName:match( badMob ) then
          isBad = true
          break
        end
      end
      if isPC or isBad then
        cecho( f "\n{EC}{mob}{RC} removed from {SC}{item}{RC} due to mob name: {VC}{mobName}{RC}" )
        table.remove( mobList, i )
        -- If the mobList is empty now, also remove the item from UnknownItems
        if #mobList == 0 then
          UnknownItems[item] = nil
        end
      end
    end
  end
  table.save( f "{DATA_PATH}/UnknownItems.lua", UnknownItems )
end

function sanitizeItemLoads()
  -- Clean up the ItemLoads table by removing players and shopkeepers (we only care about mobs)
  -- For each item, list in ItemLoads, iterate over the list of loading entities, if any are in KnownPlayers, cecho item & name
  for item, mobList in pairs( ItemLoads ) do
    for i, mob in ipairs( mobList ) do
      local isPC    = KnownPlayers[mob]
      local mobName = trim( mob:lower() )
      local isBad   = false
      if mobName:match( "someone" ) then isBad = true end
      if isPC or isBad then
        cecho( f "\n{EC}{mob}{RC} removed from {SC}{item}{RC}" )
        table.remove( mobList, i )
        -- If the mobList is empty now, also remove the item from ItemLoads
        if #mobList == 0 then
          cecho( f "\n{SC}{item}{RC} removed from ItemLoads due to no mobs" )
          ItemLoads[item] = nil
        end
      end
    end
  end
  table.save( f "{DATA_PATH}/ItemLoads.lua", ItemLoads )
end
