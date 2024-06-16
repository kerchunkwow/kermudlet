-- Doubleclick the room name to summon that pc
function roomClicked( pc, pcName, event )
  cecho( "info", f "\nGot double-click on <royal_blue>Room<reset> @ {pcTags[pc]}" )
  send( f [[cast 'super summon' {pcName}]] )
end

-- Click the hitpoint gauge to heal that pc ([COLIN])
function healthClicked( pc, pcName, event )
  cecho( "info", f "\nGot click on <olive_drab>Health<reset> @ {pcTags[pc]}" )
  -- Emergency heal if hp is critical
  if pcStatus[pc]["percentHP"] <= 33 then
    local optimalHealingSpell = getBestHeal( pcStatus[1]["currentMana"] )
    send( f "cast '{optimalHealingSpell}' {pcNames[pc]}" )
    return
  end
  -- Otherwise, heal more casually based on health deficit
  local hpd = pcStatus[pc]["maxHP"] - pcStatus[pc]["currentHP"]

  if hpd <= 50 then
    send( f "cast 'cure critic' {pcNames[pc]}" )
  else
    send( f "cast 'heal' {pcNames[pc]}" )
  end
end

-- Click the move gauge to refresh that pc with the opimal caster
function movesClicked( pc, pcName, event )
  cecho( "info", f "\nGot click on <gold>Moves<reset> @ {pcTags[pc]}" )
  local mvd = (pcStatus[pc]["maxMoves"] - pcStatus[pc]["currentMoves"])
  optimalRefresh( pcName )
end

-- Click the combat icon to have Nandor attempt a rescue ([COLIN])
function combatClicked( pc, pcName, event )
  if (pc ~= 4) then
    expandAlias( f "nan rescue {pcName}" )
  end
end

function affectsClicked( pc, pcName, event )
  cecho( "info", f "\nGot click on <violet>Affects<reset> @ {pcTags[pc]}" )
end

function highlightCondition( condition )
  if CONDITION_COLORS[condition] then
    selectString( condition, 1 )
    local color = CONDITION_COLORS[condition]
    setFgColor( color[1], color[2], color[3] )
    resetFormat()
  end
end

function enableMetaTriggers()
  enableTrigger( [[Meta Shop]] )

  local t = "[       Metaphysician Services       ]"

  local hr = "+------------------------------------+"
  local ids = f "<orange>#{RC}"
  local its = f "<slate_blue>Item{RC}"
  local xps = f "<deep_pink>XP{RC}"
  local gps = f "<ansi_light_yellow>GP{RC}"

  creplaceLine( f "\n{hr}\n{t}\n{hr}\n|   {ids}  {its}              {xps}     {gps}   |\n{hr}" )
  onNextPrompt( function () disableTrigger( [[Meta Shop]] ) end )
end

-- Make the Meta shop prettier
function translateMetaCosts()
  -- To align all items, if the length of the itemID is less than 3, pad it with spaces
  local itemID   = trim( matches[2] )
  local idLength = string.len( itemID )
  if idLength < 3 then
    itemID = string.rep( " ", 3 - idLength ) .. itemID
  end
  -- To align item costs, add spaces at the end of item names so they're all 15 characters long
  local itemName       = trim( matches[3] )
  local itemNameLength = string.len( itemName )
  if itemNameLength < 17 then
    itemName = itemName .. string.rep( " ", 17 - itemNameLength )
  end
  local xpNumber       = trim( matches[4] )
  local xpString       = abbreviateNumber( xpNumber )

  -- Pad xpStrings so they are all six characters in length
  local xpStringLength = string.len( xpString )
  if xpStringLength < 6 then
    xpString = xpString .. string.rep( " ", 6 - xpStringLength )
  end
  local goldNumber, goldString = 0, "0"
  if matches[5] then
    goldNumber = trim( matches[5] )
    goldString = abbreviateNumber( goldNumber )
  end
  -- Pad goldStrings so they are all six characters in length
  local goldStringLength = string.len( goldString )
  if goldStringLength < 4 then
    goldString = goldString .. string.rep( " ", 4 - goldStringLength )
  end
  -- Combine the item ID, name, and costs into a single string; xp is always present, gold is optional
  -- Use {SC} to color strings, {NC} for numbers, and {RC} to reset colors.
  local formattedString = f "| <chocolate>{itemID}{RC}. <dark_slate_blue>{itemName}{RC} <maroon>{xpString}{RC} "
  if goldNumber then
    formattedString = formattedString .. f "<dark_goldenrod>{goldString}{RC} |"
  end
  if xpNumber == "0" then
    deleteLine()
  else
    creplaceLine( formattedString )
    --iout( formattedString )
  end
end
