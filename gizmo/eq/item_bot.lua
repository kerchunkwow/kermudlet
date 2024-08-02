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

-- The purpose of this global & function are to iterate through the table of CommonKeywords to
-- locate items within the game; the secondary benefit of this will be populating the table of
-- unidentified items that are currently loaded.
-- Each time this function is called, it should locate the "next" keyword in the list by calling:
-- expandAlias( f"loc {keyword}" )
-- Once all keywords have been located, the function should return to the start of the list
-- A global counter to keep track of the position in the CommonKeywords list
CommonKeywordsCounter = CommonKeywordsCounter or 1
function locateCommonItems()
  -- Get the current keyword using the counter
  local keyword = CommonKeywords[CommonKeywordsCounter]

  -- Expand the alias to locate the current keyword
  expandAlias( f "loc {keyword}" )

  -- Increment the counter to the next keyword
  CommonKeywordsCounter = CommonKeywordsCounter + 1

  -- If the counter exceeds the length of the CommonKeywords list, reset it to 1
  if CommonKeywordsCounter > #CommonKeywords then
    CommonKeywordsCounter = 1
  end
end

-- This global table keeps track of all unknown/unidentified items currently loaded; the table
-- maps the names of items to a list of the mobs currently carrying the item, for instance:
-- UnknownItems["a sword"] = {"a guard", "a soldier"}
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
        table.insert( itemList, k )
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
  --local mobList = UnknownItems[item]
  local mobString = getItemMobList( item )
  -- Create a "mob string" using the mobList from this item, when more than one mob is present each
  -- should be separated by an "and" in the string for example:
  -- "a guard and a soldier"
  -- for i, mob in ipairs( mobList ) do
  --   if i == 1 then
  --     mobString = "`b" .. mob .. "`q"
  --   else
  --     mobString = mobString .. " or `b" .. mob .. "`q"
  --   end
  -- end
  --local requestString = f "Please fetch `g{item}`q from {mobString}."
  --send( f "say {requestString}" )
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

function auditDonationContents()
  local armorChecklist = {
    "WRISTS",
    "WAIST",
    "ABOUT",
    "SHIELD",
    "ARMS",
    "HANDS",
    "FEET",
    "LEGS",
    "HEAD",
    "BODY",
    "NECK",
    "FINGERS",
    "LIGHT",
  }
  local miscChecklist = {
    "LIGHT",
    "HOLD",
    "SCROLL",
    "KEY",
    "POTION",
    "CONTAINER",
    "WAND",
    "LIQUID CONTAINER",
    "OTHER",
    "TREASURE",
  }
  local itemList = {
    ["a strange elixir"]                  = 1,
    ["a quick note"]                      = 1,
    ["a Winter Wolf Pelt"]                = 1,
    ["a scroll of armament"]              = 19,
    ["a bright magenta potion"]           = 6,
    ["a firey-red potion"]                = 3,
    ["an adamantite scale"]               = 1,
    ["an ebony key"]                      = 7,
    ["a dark black cape"]                 = 1,
    ["a key ring"]                        = 3,
    ["the trust flag"]                    = 3,
    ["Large copper key"]                  = 7,
    ["a small key"]                       = 6,
    ["an iron keystone"]                  = 2,
    ["a diamond keystone"]                = 4,
    ["a vibrant white potion"]            = 24,
    ["the meteorite key"]                 = 3,
    ["a Blue Wristband"]                  = 1,
    ["a buffalo horn"]                    = 1,
    ["a scroll of purification"]          = 15,
    ["a Blue Potion"]                     = 1,
    ["a beaver's potion"]                 = 1,
    ["an Ancient Parchment"]              = 1,
    ["a Huge Piece of Amber"]             = 2,
    ["a Sack of Amber Drops"]             = 1,
    ["an iron sceptre"]                   = 1,
    ["a pair of Cantu boots"]             = 1,
    ["a leafy necklace"]                  = 1,
    ["a vial of tree sap"]                = 1,
    ["a gold key"]                        = 1,
    ["a vial of Holy water"]              = 3,
    ["a Rosicrucian Strongbox"]           = 1,
    ["the Trumpet of Ashmedai"]           = 1,
    ["an Exorcist's Broken Crucifix"]     = 1,
    ["an old staff"]                      = 1,
    ["the rainbow staff"]                 = 1,
    ["a crystal staff"]                   = 1,
    ["a Diabolic Tome"]                   = 1,
    ["a small wyvern scale"]              = 2,
    ["a bright golden key"]               = 1,
    ["a scroll of healing"]               = 4,
    ["a Small Cask of Vodka"]             = 1,
    ["a milky orange potion"]             = 2,
    ["a fish oil potion"]                 = 2,
    ["a frosty blue potion"]              = 2,
    ["a carved ivory fetish"]             = 2,
    ["a pair of dice"]                    = 5,
    ["a Pair of Snowshoes"]               = 1,
    ["a Brass Lantern"]                   = 1,
    ["a small stone"]                     = 3,
    ["an engraved ebony seal"]            = 1,
    ["an engraved ivory seal"]            = 1,
    ["a sandstone keystone"]              = 1,
    ["Red staff"]                         = 1,
    ["a silver whistle"]                  = 1,
    ["a granite keystone"]                = 3,
    ["a copper keystone"]                 = 1,
    ["an Ancient Key"]                    = 1,
    ["a golden branch"]                   = 1,
    ["Scepter with a dragon's claw"]      = 1,
    ["a Roc claw"]                        = 1,
    ["an Ozymar's ring"]                  = 1,
    ["a Simurgh Feather"]                 = 3,
    ["a green potion"]                    = 1,
    ["a pitch black potion"]              = 1,
    ["a lantern"]                         = 1,
    ["a torch"]                           = 1,
    ["a bag"]                             = 1,
    ["a box"]                             = 1,
    ["a Sea Chest"]                       = 1,
    ["an ugly skull of Draco"]            = 1,
    ["a teak staff"]                      = 1,
    ["a golden apple"]                    = 1,
    ["a Fishy Potion"]                    = 1,
    ["Some Sea Essence"]                  = 1,
    ["a potion of honey"]                 = 1,
    ["a white potion"]                    = 1,
    ["a glowing gland"]                   = 2,
    ["a Cup of Espresso"]                 = 1,
    ["a Cup of Herbal Tea"]               = 1,
    ["a fine wine glass"]                 = 1,
    ["a brown bottle"]                    = 1,
    ["a Grolsh bottle"]                   = 1,
    ["a pink and green stone"]            = 1,
    ["an iridescent stone"]               = 1,
    ["a folded envelope"]                 = 1,
    ["a vial of Holy Water"]              = 2,
    ["a fetish of Mituras"]               = 1,
    ["a Crawdad Bible"]                   = 1,
    ["the Path of Grace"]                 = 2,
    ["a vibrant purple stone"]            = 1,
    ["a scarlet and blue stone"]          = 1,
    ["a pearly white stone"]              = 1,
    ["a pale green stone"]                = 1,
    ["a pale blue stone"]                 = 1,
    ["a clear stone"]                     = 1,
    ["a lavender and green stone"]        = 1,
    ["a incandescent blue stone"]         = 1,
    ["a dull grey stone"]                 = 1,
    ["a pink stone"]                      = 1,
    ["a golden harp"]                     = 1,
    ["a dusty rose stone"]                = 1,
    ["a silver flute"]                    = 1,
    ["a mandolin"]                        = 1,
    ["a deep red stone"]                  = 1,
    ["a flowered scroll"]                 = 1,
    ["an herbal potion"]                  = 2,
    ["the mark of the betrayer"]          = 3,
    ["a swirling blue potion"]            = 1,
    ["potion of harming"]                 = 3,
    ["the Ancient Vessel of Aquarius"]    = 1,
    ["Bottle of dirty water"]             = 1,
    ["a scroll of recall"]                = 1,
    ["a Mithril flute"]                   = 1,
    ["a cup"]                             = 1,
    ["a mine key"]                        = 2,
    ["an old pewter key"]                 = 2,
    ["a papyrus note"]                    = 1,
    ["a scroll of identify"]              = 1,
    ["a small green bag"]                 = 1,
    ["a pixie wand"]                      = 1,
    ["a ruby wand"]                       = 1,
    ["a blood red vial"]                  = 1,
    ["an opal potion"]                    = 1,
    ["a black Dragon scale"]              = 1,
    ["a Glowing Amethyst"]                = 1,
    ["a small moonstone"]                 = 1,
    ["a javelin"]                         = 4,
    ["red gem"]                           = 1,
    ["a stolen Shantak relic"]            = 1,
    ["an heirloom of the Dromaer family"] = 1,
  }
  for item, count in pairs( itemList ) do
    local itemData = Items[item]
    local type = itemData.baseType
    if type == "POTION" then
      local kw = itemData.keywords[1]
      local n = count > 1 and tostring( count ) .. " " or ""
      send( f "get {n}{kw} parcel" )
      send( f "put {n}{kw} strongbox" )
    end
  end
end
