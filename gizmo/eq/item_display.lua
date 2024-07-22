--[[ item_display.lua
Supports the Items data archive by providing functions to output items in-game either directly
to the client or through in-game chat channels when interacting with other players.
--]]

-- Uses the ITEM_SCHEMA table including its order attribute to display details about the current item;
-- useful for validation and feedback during development
function displayItem( desc, tier )
  if not tier then tier = -1 end
  local item = Items[desc]
  if not item then
    cout( f "\n{EC}displayItem{RC}: no such Item {SC}{desc}{RC}" )
    return
  end
  -- A local function to sort the keys in the ITEM_SCHEMA by order for structured output
  local function getOrderedKeys( schema )
    local keys = {}
    for key in pairs( schema ) do
      table.insert( keys, key )
    end
    table.sort( keys, function ( a, b )
      return schema[a].order < schema[b].order
    end )
    return keys
  end

  -- Compose a "title card" for the item including its core stats, flags, and affects
  local sstr = compositeString( "", item.shortDescription, "<green_yellow>" )
  sstr       = compositeString( sstr, item.statsString, "<dark_slate_grey>" )
  -- Add value information to treasure items
  if item.baseType == "TREASURE" and item.value > 0 then
    local valueString = expandNumber( item.value )
    sstr              = compositeString( sstr, f "{valueString}gp", "<gold>" )
  end
  sstr       = compositeString( sstr, item.affectString, "<ansi_cyan>" )
  sstr       = compositeString( sstr, item.flagString, "<firebrick>" )
  -- Add flare to the special tags if present
  sstr       = highlightTags( sstr )
  local slen = cLength( sstr ) + 2
  local dg   = "<dim_grey>"
  hrule( slen, dg )
  cout( f "{dg}| {sstr}{dg} |" )
  hrule( slen, dg )

  if tier == -1 then return end
  local op = "<indian_red> = <reset>"
  local keys = getOrderedKeys( ITEM_SCHEMA )
  -- Iterate through the ITEM_SCHEMA based on the defined tier
  for _, key in ipairs( keys ) do
    local properties = ITEM_SCHEMA[key]
    if tier == nil or properties.tier <= tier then
      local value = item[key]
      local typ = ITEM_SCHEMA[key].typ
      -- Boolean values are important even when they're false
      if value or typ == "boolean" then
        if typ == "boolean" then value = tostring( value ) end
        local ks = f "{SC}{key}{RC}"
        local vs = nil
        local isNumber = type( value ) == "number" and
        (value ~= 0 or key == "cloneable" or key == "holdable")
        local isString = type( value ) == "string" and value ~= ""
        local isBig = isNumber and (value >= 10000 or value <= -10000)
        if isNumber and isBig then value = expandNumber( value ) end
        if type( value ) == "table" and next( value ) ~= nil then
          vs = f "{dg}{table.concat(value, ', ')}{RC}"
        elseif isNumber or isString then
          vs = f "{dg}{value}{RC}"
        end
        if vs then
          cout( f "{ks}{op}{vs}" )
        end
      end
    end
  end
end

-- Display differences between two items
-- @param differences Table containing the differences
function displayItemDifferences( differences )
  if #differences == 0 then
    cecho( f "{GDOK} The items are identical.\n" )
  else
    cecho( f "{GDOK} <deep_pink>Differences<reset> between items:" )
    for _, diff in ipairs( differences ) do
      cecho( f "{diff}\n" )
    end
  end
end

-- Display a list of multiple items by calling displayItem successively for each item in the list;
-- if the list is empty, display all items in the database; if tier is nil, displayItem will default it to -1
function displayItems( descList, tier )
  if not descList or #descList == 0 then
    descList = {}
    for desc, _ in pairs( Items ) do
      if desc and type( desc ) == "string" and desc:find( "%S" ) then
        table.insert( descList, desc )
      end
    end
  end
  for _, desc in ipairs( descList ) do
    displayItem( desc, tier )
  end
end

-- Using cout(), display some useful stats about the Items data
function displayItemDataStats()
  local totalItems     = 0
  local totalWeight    = 0
  local totalValue     = 0
  local baseTypeCounts = {}

  for _, item in pairs( Items ) do
    totalItems = totalItems + 1
    -- Aggregate count of item by type
    local baseType = item.baseType or "Unknown"
    baseTypeCounts[baseType] = (baseTypeCounts[baseType] or 0) + 1
  end
  cout( f "\n<orchid>Known Items:   {NC}{totalItems}{RC}" )
  for baseType, count in pairs( baseTypeCounts ) do
    local btl = #baseType
    local pad = 10 - btl
    cout( f "    <slate_blue>{baseType}{RC}:{string.rep(' ', pad)}{NC}{count}{RC}" )
  end
end

-- Assemble a combined & condensed shorthand string showing all of the vital stats of an object based
-- on its type; this string actually gets stored in the Items table so it doesn't have to be rebuilt
function setItemStatsString()
  local damageString    = getDamageString()
  local coreStatsString = getStatString( CORE_STATS )
  if damageString then
    ItemObject.damageString = damageString
    if coreStatsString and #coreStatsString > 0 then
      ItemObject.statsString = f( "{damageString} {coreStatsString}" )
    else
      ItemObject.statsString = damageString
    end
  else
    ItemObject.statsString = coreStatsString
  end
  -- Don't insert items with empty stats strings (this is very rare and usually only occurs with trash items)
  if #ItemObject.statsString <= 0 or ItemObject.statsString == "" then
    ItemObject.statsString = nil
  end
end

-- Given a list of stats as a table of strings, return a composite string concatenating each of those stats
-- from the current ItemObject table, separating each with spaces and including + or - signs; Each stat
-- should be labeled using either the name of the attribute, or it's nick if one exists. e.g.,
-- if ItemObject["con"] == 3, ItemObject["armorClass"] == -10, and ItemObject["skillBlock"] == 10,
-- then getStatString {"con", "armorClass", "skillBlock"} ) should return:
-- +3con -10ac +10BLCK
function getStatString( statList )
  local result = {}
  for _, stat in ipairs( statList ) do
    local value     = ItemObject[stat]
    local valueType = type( value )
    local skip      = (ItemObject.baseType == "WEAPON" or ItemObject.baseType == "MISSILE") and
        (stat == "dr" or stat == "hr")
    if value and not skip then
      local signedValue = getSignedString( value )
      local label = ITEM_SCHEMA[stat].nick
      if not label or label == "" then
        label = stat
      end
      table.insert( result, signedValue .. label )
    end
  end
  local resultString = table.concat( result, " " )
  resultString = trimCondense( resultString )
  return resultString
end

-- For item types POTION, WAND, STAFF, and SCROLL; we will add a string representing what spells the item
-- confers upon use instead of a standard stat string
function getSpellApplyString()
  -- This string should include spellLevel and any spells in the spellList formatted as:
  -- [L{spellLevel} {spell1}, {spell2}, ...]
  if not ItemObject.spellLevel or not ItemObject.spellList or #ItemObject.spellList == 0 then
    return nil
  end
  -- Use the SPELL_MAP to get the nicknames for the spells
  local spellLevel = ItemObject.spellLevel
  local spellList = ItemObject.spellList
  local spellCharges = ItemObject.spellCharges
  local spellStringParts = {}

  for _, spell in ipairs( spellList ) do
    local spellNick = SPELL_MAP[spell] or spell
    table.insert( spellStringParts, spellNick )
  end
  local spellString = table.concat( spellStringParts, ", " )
  local applyString = f( "L{spellLevel} {spellString}" )

  if spellCharges and spellCharges > 0 then
    -- For consumables with charges, append an x# to the end of the stats string
    applyString = applyString .. f( " x{spellCharges}" )
  end
  return applyString
end

-- Called for items where baseType is WEAPON to parse the damage dice portion of the identification block and
-- derive associated values damageDice is a string in format "NDS" where N is the number of dice and S is the
-- number of sides on each die; This function assumes damageDice has already been set and is properly
-- formatted which should be guaranteed from the MUD
function getDamageString()
  if (ItemObject.baseType ~= "WEAPON" and ItemObject.baseType ~= "MISSILE") then
    return nil
  end
  local damageString = nil
  cecho( "{GDITM}    <dark_olive_green><i>~setting damageString</i><reset>" )
  local n, s = ItemObject.damageDice:match( "(%d+)D(%d+)" )
  if n and s then
    local dam   = ItemObject.dr or 0
    local drStr = getSignedString( ItemObject.dr )
    local hrStr = getSignedString( ItemObject.hr )
    -- For items with dr but not hr or vice versa, we need a 0 to distinguish the two
    if drStr == "" and hrStr ~= "" then
      drStr = "+0"
    elseif drStr ~= "" and hrStr == "" then
      hrStr = "+0"
    end
    n                        = tonumber( n )
    s                        = tonumber( s )
    ItemObject.damageNumber  = n
    ItemObject.damageSides   = s
    ItemObject.averageDamage = n * ((s + 1) / 2) + dam
    damageString             = f( "{n}D{s}{drStr}{hrStr} ({ItemObject.averageDamage}avg)" )
    return damageString
  else
    local damageError = f(
    "{GDITM} {EC}getDamageString{RC}(): Invalid damageDice {ItemObject.damageDice}" )
    cecho( damageError )
    return nil
  end
end

-- This function sets a shorthand representation of an item's "antis" by examining the flags and undeadAntis
-- properties and concatenating values from the ITEM_FLAGS table
function getItemFlagString()
  -- If ItemObject.flags is nil or an empty table, return nil
  if not ItemObject.flags or #ItemObject.flags == 0 then
    return nil
  end
  cecho( f "{GDITM}    <dark_olive_green><i>~setting flagString</i><reset>" )
  local shortFlags, rawFlags = {}, {}
  -- Combine the ItemObject flags and undeadAntis into a single table, acounting
  -- for possible empty tables
  for _, flag in ipairs( ItemObject.flags or {} ) do
    table.insert( rawFlags, flag )
  end
  for _, flag in ipairs( rawFlags ) do
    local flagData = ITEM_FLAGS[flag]
    if flagData and flagData.display then
      table.insert( shortFlags, flagData.nick )
    end
  end
  local flagString = table.concat( shortFlags, ' ' )
  flagString = trimCondense( flagString )
  -- If an item is cloneable, append CLONE_TAG to the end of its flagString (after a space)
  if ItemObject.cloneable then
    -- Add a space if there's already data in the string
    if flagString ~= "" then
      flagString = flagString .. " "
    end
    flagString = flagString .. CLONE_TAG
  end
  return flagString
end

-- Retrieve a shorthand version of the item's Affects, borrowing nicknames from the PERMANENT_AFFECTS table;
-- return nil for objects with no affects.
function getItemaffectString()
  -- If ItemObject.affects is nil or an empty table, return nil
  if not ItemObject.affects or #ItemObject.affects == 0 then
    return nil
  end
  cecho( f "{GDITM}    <dark_olive_green><i>~setting affectString</i><reset>" )
  local affectString = ""

  -- Iterate over ItemObject.affects using ipairs
  for _, aff in ipairs( ItemObject.affects ) do
    local affData = PERMANENT_AFFECTS[aff]
    if affData then
      local affNick = affData.nick
      -- Add a space if there's already data in the string
      local spc = (affectString ~= "") and " " or ""
      affectString = affectString .. spc .. affNick
    end
  end
  -- Clean up and return the result string
  affectString = trimCondense( affectString )
  return affectString
end

-- Used on the final output/display for an item's composited details, this function adds color highlights
-- to the special tags for visual distinction.
function highlightTags( s )
  local spec_color = "<gold>"
  local clone_color = "<royal_blue>"
  -- If SPEC_TAG or CLONE_TAG are found in the string, highlight them using the above
  -- colors; otherwise, return the string unchanged
  if s:find( SPEC_TAG ) then
    s = s:gsub( SPEC_TAG, spec_color .. SPEC_TAG .. "<reset>" )
  end
  if s:find( CLONE_TAG ) then
    s = s:gsub( CLONE_TAG, clone_color .. CLONE_TAG .. "<reset>" )
  end
  return s
end
