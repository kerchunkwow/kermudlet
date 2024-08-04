-- This table will keep track of who gave the bot which items; it will be used to award players
-- for contributing to The Archive and to validate that the bot is returning items correctly
-- (or punish players who attempt to circumvent the system).
-- key: player name, values: item name (short description), timestamp
ItemsReceived     = ItemsReceived or {}

-- Global Variables
CurrentItem       = CurrentItem or nil
CurrentPlayer     = CurrentPlayer or nil
CurrentKeyword    = CurrentKeyword or nil
ItemsReceived     = ItemsReceived or {}
PotentialKeywords = PotentialKeywords or {}
IDTrigger         = IDTrigger or nil
ReturnTrigger     = ReturnTrigger or nil
ReturnedTrigger   = ReturnedTrigger or nil

-- Pattern for attempts to identify an item that fail (time to try next keyword)
MISS_ID           = "(?:You are not carrying anything like that\\.$|What should the spell be cast upon\\?$)"

-- Triggered by the in-game message resulting from another player giving the bot an item;
-- this "kicks off" the process of identifying and returning the item to the player.
-- Pattern: ^(\w+) gives you (.+)\.$
function triggerItemReceived()
  local player = trim( matches[2] )
  local item = trimItemName( matches[3] )
  receivedItem( item, player )
  -- If we're not already working on an item, process this one
  if not CurrentItem then
    processItem( item )
  end
end

-- To facilitate tracking & return of items, add incoming items to ItemsReceived.
function receivedItem( item, player )
  -- Initialize the table if it doesn't exist for some reason
  if not ItemsReceived then ItemsReceived = {} end
  -- When we register an item received, we will record a timestamp as well so we can keep
  -- track of how long an item has been queued.
  local timeReceived = getStopWatchTime( "timer" )
  ItemsReceived[item] = player
  cecho( f "{GDOK} receivedItem( {SC}{item}{RC}, {SC}{player}{RC} )" )
end

-- Following the identification process; attempt to return an item to the player who
-- gave it to the bot.
function returnItem()
  if not CurrentItem or not CurrentPlayer or not CurrentKeyword then
    cecho( f "{GDERR} returnItem() with {EC}no Current item{RC}" )
    return
  end
  local giveCommand = f "give {CurrentKeyword} {CurrentPlayer}"
  --local confirmRequest = f "say I tried to return `g{CurrentItem}`q to `c{CurrentPlayer}`q."
  --local confirmPattern = f "^{CurrentPlayer} nods solemnly."

  -- Triggered by the "Ok." received in response to the give command, prompts the
  -- player for confirmation to finalize the transaction.
  ReturnTrigger     = tempRegexTrigger( "Ok\\.$", function ()
    returnedItem()
    --send( confirmRequest, true )
    -- send( "say Please `nnod`q to confirm you received it.", true )
    -- ReturnedTrigger = tempRegexTrigger( confirmPattern, function ()
    --   returnedItem()
    --   killTrigger( ReturnedTrigger )
    -- end, 1 )
  end, 1 )
  -- Issue the command to actually hand it over to the player
  send( giveCommand )
end

-- The bot returned an item, remove it from the receipt register & see if there are
-- any more queued up to process.
function returnedItem()
  if not CurrentItem or not CurrentPlayer then
    cecho( f "{GDERR} returnedItem() with no CurrentItem or Player" )
    return
  end
  ItemsReceived[CurrentItem] = nil
  cecho( f "{GDOK} returnedItem( {SC}{CurrentItem}{RC}, {SC}{CurrentPlayer}{RC} )" )
  -- Reset global variables
  CurrentItem    = nil
  CurrentPlayer  = nil
  CurrentKeyword = nil

  -- Process the next item if any
  local nextItem = next( ItemsReceived )
  if nextItem then
    processItem( nextItem )
  else
    cecho( f "{GDOK} No more ItemsReceived" )
    -- This is probably unnecessary, but we'll "reset" everything just in case
    resetID()
  end
end

-- "Process" the next item in the ItemsReceived table by attempting to identify it
function processItem( item )
  CurrentItem = item
  CurrentPlayer = ItemsReceived[item]
  cecho( f "{GDOK} processItem( {SC}{item}{RC} )" )
  guessKeywords()
  attemptNextId()
end

-- Attempt to identify an item using a list of guessed keywords; once we run out of
-- guesses we will have to inquire with the player.
function attemptNextId()
  -- The ID bot has tried all of its guesses at keywords for the item; it will resort to asking the player
  -- to provide a keyword manually.
  if #PotentialKeywords == 0 then
    tempRegexTrigger( f "^{CurrentPlayer} says '(.+)'", function ()
      local keyword = trim( matches[2] )
      keyword = string.lower( keyword )
      table.insert( PotentialKeywords, keyword )
      attemptNextId()
    end, 1 )
    send( f "say `c{CurrentPlayer}`q please say a valid keyword for `g{CurrentItem}`q." )
    return
  end
  -- Pop the next keyword off the list
  CurrentKeyword = table.remove( PotentialKeywords, 1 )

  -- Attempt to identify the item using the potential keyword
  expandAlias( f "id {CurrentKeyword}" )

  -- Set up a trigger to attempt the next keyword if this one isn't valid; wait a couple seconds
  -- to avoid spamming casts.
  if IDTrigger then killTrigger( IDTrigger ) end
  IDTrigger = tempRegexTrigger( MISS_ID, function ()
    tempTimer( 2, [[attemptNextId()]] )
  end, 1 )
end

-- Once we're in possession of a player's item, we will try go guess a valid keyword for it to
-- spare the player the trouble of telling us.
function guessKeywords()
  cecho( f "{GDOK} guessKeywords()... guessing keywords" )
  -- Empty table to start
  PotentialKeywords = {}

  -- Lower the item name for case insensitivity
  local itemName = string.lower( CurrentItem )

  -- Split the short description into its component words
  local potentialKeywords = split( itemName, " " )

  -- Try to "spruce up" the guesses with some viariations
  PotentialKeywords = enhanceKeywords( potentialKeywords )
end

-- Cleanup and enhance a list of possible item keywords by removing unlikely keywords and adding
-- common variations and alterations seen in MUD item naming conventions.
function enhanceKeywords( keywords )
  local enhancedKeywords = {}
  local neverKeywords = {
    ["a"]      = true,
    ["an"]     = true,
    ["of"]     = true,
    ["and"]    = true,
    ["the"]    = true,
    ["from"]   = true,
    ["with"]   = true,
    ["new"]    = true,
    ["set"]    = true,
    ["great"]  = true,
    ["high"]   = true,
    ["made"]   = true,
    ["many"]   = true,
    ["thin"]   = true,
    ["tiny"]   = true,
    ["larger"] = true,
    ["little"] = true,
    ["smooth"] = true,
  }

  -- Helper function to add a keyword if it is not in the neverKeywords list
  local function addKeyword( keyword )
    if not neverKeywords[keyword] then
      enhancedKeywords[keyword] = true
    end
  end

  -- Process each baseline keyword
  for _, keyword in ipairs( keywords ) do
    addKeyword( keyword )
    -- Add sub-words for hyphenated words (e.g., star-sapphire -> star, sapphire)
    for subWord in keyword:gmatch( "[^-]+" ) do
      addKeyword( subWord )
    end
    -- Add versions without internal apostrophes (e.g., x'ot -> xot)
    if keyword:find( "'" ) then
      addKeyword( keyword:gsub( "'", "" ) )
      -- Add versions without 's for possessives (e.g., timothy's -> timothy)
      addKeyword( keyword:gsub( "'s", "" ) )
    end
    -- If a potential keyword is greater than 5 characters, search ItemKeywords
    -- for substrings to add as potential keywords
    if #keyword > 5 then
      cecho( f "{GDOK} {SC}{keyword}{RC} > 5 characters, searching sub-keywords" )
      for itemKeyword in pairs( ItemKeywords ) do
        if keyword:find( itemKeyword ) then
          cecho( f "{GDOK} \t+{SC}{itemKeyword}{RC}" )
          addKeyword( itemKeyword )
        end
      end
    end
  end
  -- Convert the set to a list
  local expandedKeywordList = {}
  for keyword in pairs( enhancedKeywords ) do
    table.insert( expandedKeywordList, keyword )
  end
  return expandedKeywordList
end

-- A function to reset the ID bot to "factory settings" to unstick it during development & testing
function resetID()
  -- If there are any items in the ItemsReceived table, print a warning and display the table before
  -- resetting it.
  if next( ItemsReceived ) then
    cecho( f "{GDERR} Resetting with non-empty ItemsReceived" )
    for item, player in pairs( ItemsReceived ) do
      cecho( f "{SC}{item}{RC} from <chartreuse>{player}{RC}" )
    end
  end
  CurrentItem       = nil
  CurrentPlayer     = nil
  CurrentKeyword    = nil
  ItemsReceived     = {}
  PotentialKeywords = {}
  if IDTrigger then killTrigger( IDTrigger ) end
  if ReturnTrigger then killTrigger( ReturnTrigger ) end
  if ReturnedTrigger then killTrigger( ReturnedTrigger ) end
  -- Also cancel any identify we have in progress (just in case)
  cancelIdentify( false )
end

-- After the bot is given an item, it will wait to receive a valid keyword to move
-- forward with the identification process.
function captureKeyword( kw )
  expandAlias( f "id {kw}" )
end

-- Calculate the bounty for an individual item
-- @param item The item to calculate the bounty for
-- @return The calculated bounty for the item
function calculateItemBounty( item )
  -- Turn off bounties for now
  --if true then return 0 end
  local itemBounty = 0
  for attribute, baseline in pairs( BOUNTY_VALUES ) do
    if item[attribute] then
      local value = item[attribute]
      value = tonumber( value )
      local bounty = value * baseline
      --cecho( f "\n\t<yellow_green>+Bounty<reset>: {SC}{attribute}{RC} = {NC}{value}{RC} * {NC}{baseline}{RC} = +{NC}{bounty}{RC}" )
      itemBounty = itemBounty + adjustBounty( bounty, item.baseType, attribute )
    end
  end
  -- If the item has a spell list (item["spellList"] table exists and is not empty), multiply the bounty
  -- by the number of spells in the list
  if item["spellList"] and #item["spellList"] > 0 then
    itemBounty = itemBounty * #item["spellList"]
  end
  if item.baseType == "KEY" then itemBounty = 25000 end
  -- Apply minimum and maximum bounty thresholds
  if itemBounty > MAX_BOUNTY then itemBounty = MAX_BOUNTY end
  if itemBounty < MIN_BOUNTY then itemBounty = MIN_BOUNTY end
  -- If the vendor value of the item (item["value"]) is greater than the calculated bounty AND less
  -- than 100000, use the vendor value as the bounty
  if item["value"] and item["value"] > itemBounty and item["value"] < 100000 then
    itemBounty = item["value"]
  end
  --cecho( f "\n\t<maroon>*Adjusted Bounty<reset>: {NC}{itemBounty}{RC}" )
  -- Add a bonus amount to itemBounty between 10 and 25% of itemBounty
  local bonus = math.random( 10, 25 ) / 100
  itemBounty = itemBounty + (itemBounty * bonus)
  return itemBounty
end

-- Adjust the bounty value based on item type and attribute
-- @param bounty The current bounty value
-- @param type The type of the item (e.g., WEAPON, ARMOR)
-- @param attribute The attribute being evaluated (e.g., averageDamage, dr)
-- @return The adjusted bounty value
function adjustBounty( bounty, type, attribute )
  -- Only treasure items should get credit for their value attribute
  if attribute == "value" and type ~= "TREASURE" then bounty = 0 end
  -- Weapons should not get credit for their dr attribute as it is already factored into averageDamage
  if attribute == "dr" and (type == "WEAPON" or type == "MISSILE") then bounty = 0 end
  -- "Missile" type items tend to have very high average damage so we need to reduce the bounty
  if attribute == "averageDamage" and type == "MISSILE" then bounty = bounty * 0.1 end
  -- Pay 5x bounty for items with greater than 20 average damage
  if attribute == "averageDamage" and type ~= "MISSILE" then
    if bounty > BOUNTY_VALUES["averageDamage"] * 20 then
      bounty = bounty * 5
    end
  end
  if type == "TRASH" or type == "FOOD" or type == "NOTE" or type == "KEY" then bounty = 5 end
  -- Some items have negative attribute values, but bounties should always be positive
  if bounty < 0 then bounty = 0 end
  return bounty
end

-- Just for fun function to estimate the total lifetime amount of all bounties paid for identified items
function estimateTotalBounty()
  -- For each item in Items, calculateItemBounty(item); sum the results and display with cecho()
  local totalBounty = 0
  for _, item in pairs( Items ) do
    totalBounty = totalBounty + calculateItemBounty( item )
  end
  totalBounty = expandNumber( totalBounty )
  --cecho( f "\n<maroon>Total Bounty Paid{RC}: <gold>{totalBounty}{RC}" )
  local msg = f "`fThe Archive`f has recorded `k{ArchivedItems}`f total items and paid `k{totalBounty}`f gold to the intrepid adventurers who discovered them."
  send( f [[goss {msg}]] )
end
