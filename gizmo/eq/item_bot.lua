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

-- This global table keeps track of all items currently loaded that have not been identified; the table
-- maps the names of items to a list of the mobs currently carrying the item, for instance:
-- LoadedItems["a sword"] = {"a guard", "a soldier"}
LoadedItems = LoadedItems or {}

-- Add an item to the LoadedItems table if this specific item, mob pair does not already exist
function addLoad( item, mob )
  -- Initialize the list if the item is not already present
  if not LoadedItems[item] then
    LoadedItems[item] = {}
  end
  -- Check if the mob is already in the list for the item
  for _, existingMob in ipairs( LoadedItems[item] ) do
    if existingMob == mob then
      return
    end
  end
  -- Add the mob to the list for the item
  table.insert( LoadedItems[item], mob )
end

-- Remove an item (and all associated mobs) from the LoadedItems table
function remLoad( item )
  LoadedItems[item] = nil
end

-- Construct a "request" message for an item in the LoadedItems table; a specific item can be
-- queried or if the parameter is nil then a random item should be selected from the table.
function requestLoad( item )
  if not item then
    -- Local function to select a random item from the LoadedItems table
    local function getRandomLoadedItem()
      local itemList = {}
      for k in pairs( LoadedItems ) do
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
  local mobList = LoadedItems[item]
  local mobString = ""
  -- Create a "mob string" using the mobList from this item, when more than one mob is present each
  -- should be separated by an "and" in the string for example:
  -- "a guard and a soldier"
  for i, mob in ipairs( mobList ) do
    if i == 1 then
      mobString = "`b" .. mob .. "`q"
    else
      mobString = mobString .. " or `b" .. mob .. "`q"
    end
  end
  local requestString = f "Please fetch `g{item}`q from {mobString}."
  --send( f "say {requestString}" )
  speak( "FETCH_QUEST" )
end
