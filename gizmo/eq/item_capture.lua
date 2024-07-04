--[[ item_capture.lua
Module to implement the capture of data from item "identification" blocks in the MUD, to validate the data, and to
integrate with the Item table in gizwrld.db to store, update, and query item data.
--]]

-- Each ItemObject represents a single identified item; once identified the item will be inserted into the parent Items
-- table after validation
ItemObject = ItemObject or {}

-- We need to hold the keyword we used to identify the object in a global so we can issue commands like drop/get using
-- that keyword (this allows us to identify sword and 2.sword for example)
IDKeyword = IDKeyword or nil



-- Triggered by the "informed" message that precedes item identification, performs the necessary
-- setup to capture the item's data from the id block and additional commands
function startNewIdentify()
  cecho( "\n    [ <yellow_green>+++<b>ID Capture Enabled</b>+++<reset> ]" )
  -- Initialize a new empty ItemObject
  initializeItemObject()
  -- Turn on the trigger groups for capturing item data
  enableTrigger( "ID Capture" )
  enableTrigger( "Full Item ID" )
  -- On the next prompt, we will have the full ID text; close this trigger group
  -- and store the full ID block
  tempRegexTrigger( "^<", function ()
    disableTrigger( "Full Item ID" )
    captureItemAttribute( "identifyText", FullIDText )
  end, 1 )
end

-- Reset and prepare an empty ItemObject for capture
function initializeItemObject()
  ItemObject = {}
  FullIDText = ""

  -- Set any default values that are defined in the ITEM_SCHEMA, and add empty tables for table types
  for key, properties in pairs( ITEM_SCHEMA ) do
    if properties.typ == "table" then
      ItemObject[key] = {}
    else
      ItemObject[key] = properties.def
    end
  end
end

-- Called when all data about an item has been captured and processed to insert the item into the
-- Items table; can display item data for validation purposes
function endIdentify()
  cecho( "\n    [ <yellow_green>---<b>ID Capture Disabled</b>---<reset> ]\n" )
  disableTrigger( "ID Capture" )
  -- If an item's worn attribute has not yet been captured, infer it from its baseType or
  -- holdable status.
  if not ItemObject.worn then
    if ItemObject.baseType == "WEAPON" then
      ItemObject.worn = "WIELD"
    elseif ItemObject.holdable then
      -- Note: Some other baseTypes can be held; HOLD is for items that are ONLY held
      ItemObject.worn = "HOLD"
    end
  end
  -- Set armorClass for any items with non-zero armor properties
  if (ItemObject.acApply or ItemObject.armorAffect) then
    setItemArmorClass()
  end
  if consumable( ItemObject.baseType ) then
    ItemObject.statsString = getSpellApplyString()
  else
    setItemStatsString()
  end
  ItemObject.affectString = getItemaffectString()
  ItemObject.flagString   = getItemFlagString()
  insertItemObject( ItemObject )
  displayItem( ItemObject.shortDescription, 999 )
  -- Reset the item object table once it has been inserted
  ItemObject = {}
  tempTimer( 1, function ()
    idNextItem()
  end )
end

-- The full identify text of an item appears over multiple lines and has an arbitrary length; this function
-- aggregates the data using a global string variable.
FullIDText = FullIDText or ""
function appendID( line )
  -- Trim leading and trailing whitespace from the line
  line = trim( line )

  -- Check if the line should be ignored
  if line == "" or line:find( "^<" ) or line == "You feel informed:" then
    return
  end
  -- Start each new line with a newline character except the first
  if #FullIDText == 0 then
    FullIDText = line
  else
    FullIDText = FullIDText .. "\n" .. line
  end
  if consumable( ItemObject.baseType ) and ItemObject.spellLevel then
    -- Every line after the spell level of a potion is a spell name, append it to ItemObject.spellList
    table.insert( ItemObject.spellList, line )
  end
end

-- Once a blank item is initialized, this function is called repeatedly as data is matched by
-- Mudlet triggers to capture and store data for the ItemObject (and eventually Items table)
function captureItemAttribute( attribute, value )
  --cecho( f "\n\t[ <ansi_magenta><i>{attribute} captured</i><reset>: <dark_orange>{value}<reset> ]" )
  cecho( f " [ <olive_drab><i>+{attribute}</i><reset> ]" )
  selectString( value, 1 )
  fg( "dim_grey" )
  resetFormat()

  -- Some attributes appear in game in UPPER_SNAKE_CASE, we want to convert them to Lua-friendly format
  local column        = ATTRIBUTE_MAP[attribute] or attribute
  local attributeType = ITEM_SCHEMA[column].typ
  -- Perform conversions, including converting multi-value strings to tables
  if attributeType == "number" then
    value = tonumber( value )
  elseif attributeType == "table" then
    value = trim( value )
    value = split( value, " " )
    if attribute == "flags" and contains( value, "LIMITED" ) then
      ItemObject.cloneable = false
    end
  end
  -- With keywords, we can queue some commands to capture additional details
  if attribute == "keywords" and not ItemObject.shortDescription then
    local kw = value[1]
    local cmd = f "drop {IDKeyword};;look;;get {kw}"
    if ItemObject.baseType ~= "POTION" then
      cmd = cmd .. f ";;wear {kw};;hold {kw}"
    end
    tempTimer( 2.3, function ()
      send( cmd, true )
    end )
  elseif attribute == "baseType" and consumable( value ) then
    -- Consumable items cannot be cloned but are not guaranteed to have the LIMITED flag
    ItemObject.cloneable = false
  end
  ItemObject[column] = value
end

-- Some items like wands and potions have a list of spells that will be applied when using the
-- item; these appear one at a time on separate lines so we need some additional capture logic
function captureItemSpells()
  -- We invoke this from the ID line with the level of the potion or wand
  local spellLevel = trim( matches[2] )
  captureItemAttribute( "spellLevel", spellLevel )
end

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
    local skip      = ItemObject.baseType == "WEAPON" and (stat == "dr" or stat == "hr")
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
  resultString = trim( resultString )
  return resultString
end

-- For items like POTIONS, WANget DS, and SCROLLS; we will add a string representing what spells the item
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
  cecho( "Apply string: <deep_pink>" .. applyString )
  return applyString
end

-- Called for items where baseType is WEAPON to parse the damage dice portion of the identification block and derive associated values
-- damageDice is a string in format "NDS" where N is the number of dice and S is the number of sides on each die
-- This function assumes damageDice has already been set and is properly formatted which should be guaranteed from the MUD
function getDamageString()
  if ItemObject.baseType ~= "WEAPON" then
    return nil
  end
  local damageString = nil
  cecho( "\n\t  [ <dark_olive_green><i>~setting damageString</i><reset> ]" )
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
    cecho( damageString )
    return damageString
  else
    local damageError = f( "{EC}getDamageString{RC}(): Invalid damageDice {ItemObject.damageDice}" )
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
  cecho( "\n\t  [ <dark_olive_green><i>~setting flagString</i><reset> ]" )
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
    flagString = flagString .. " " .. CLONE_TAG
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
  cecho( "\n\t  [ <dark_olive_green><i>~setting affectString</i><reset> ]" )
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

-- Items can modify armor class by way of two different fields from the id block; additionally, BODY armor confers
-- triple the listed amount from the "AC-apply is" line. This function calculates the final total armorClass for the Item.
-- NOTE: This can only be called once WORN has been indicated, which is not a captured field - calling this function will
-- need to be deferred until the WORN type is supplied by the user via captureItemAttribute().
function setItemArmorClass()
  cecho( "\n\t  [ <dark_olive_green><i>~setting armorClass</i><reset> ]" )
  local acMultiplier = (ItemObject.worn == "BODY") and -3 or -1
  local acApplyValue = ItemObject.acApply or 0
  local armorValue = ItemObject.armorAffect or 0
  ItemObject.armorClass = (acApplyValue * acMultiplier) + armorValue
end

-- Invoked from the Mudlet command line to identify multiple items in succession by holding keywords in a list and iterating
-- through them after each successful identify is completed.
IDQueue = IDQueue or nil

function idItemList( itemString )
  IDQueue = split( itemString, " " )
  display( IDQueue )
  idNextItem()
end

-- If there are any items in the IDQueue, pop one and identify it
function idNextItem()
  if IDQueue and #IDQueue > 0 then
    IDKeyword = table.remove( IDQueue, 1 )
    send( f( "cast 'identify' {IDKeyword}" ), true )
  else
    IDQueue   = nil
    IDKeyword = nil
  end
end
