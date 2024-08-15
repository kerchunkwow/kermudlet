-- Table to store the Gizmo in-game chat color codes; probably a better place for this later
CHAT_COLORS = {
  ['a'] = {"black"},
  ['b'] = {"red"},
  ['c'] = {"green"},
  ['d'] = {"yellow"},
  ['e'] = {"blue"},
  ['f'] = {"magenta"},
  ['g'] = {"cyan"},
  ['h'] = {"white"},
  ['i'] = {"light_red"},
  ['j'] = {"light_green"},
  ['k'] = {"light_yellow"},
  ['l'] = {"light_blue"},
  ['m'] = {"light_magenta"},
  ['n'] = {"light_cyan"},
  ['o'] = {"light_gray"},
  ['p'] = {"light_black"},
  ['q'] = {"reset"},
}

-- A one-time function to run when a session loads for the first time to clean up the BadLocates table
-- removing any keywords which have been successfully located in the past; BadLocates should only
-- contain keywords that have never returned a valid item.
function cleanupBadLocates()
  -- For each item in Items, check each keyword in item.keywords; if BadLocates[keyword] >= 0 then print
  -- that keyword
  for _, item in pairs( Items ) do
    for _, keyword in ipairs( item.keywords ) do
      if BadLocates[keyword] then
        BadLocates[keyword] = nil
      end
    end
  end
  for item, count in pairs( BadLocates ) do
    BadLocates[item] = 1
  end
  table.save( f "{DATA_PATH}/BadLocates.lua", BadLocates )
end

-- An occasional cleanup function to look through the unknown items table and remove items which have been
-- identified or which are marked as being carried by a player; this helps clean up when for example a
-- new player has arrived and is not yet in the KnownPlayers table.
function cleanupUnknown()
  -- For each item, mob combination in UnknownItems;
  for item, mob in pairs( UnknownItems ) do
    -- If the item is identified (Items[item] is not nil), remove it from the UnknownItems table
    if Items[item] then
      UnknownItems[item] = nil
    end
  end
end

function evaluateUnknown()
  for desc, mob in pairs( UnknownItems ) do
    local mobName = mob[1]
    if not KnownMobs[mobName] then
      cecho( f "\n{EC}{mobName}{RC}" )
    else
      local mobArea = getMobArea( mobName )
      cecho( f "\n<yellow_green>{mobName}{RC}, {SC}{mobArea}{RC}" )
    end
  end
end
