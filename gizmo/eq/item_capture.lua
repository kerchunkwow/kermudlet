--[[ item_capture.lua
Module to implement the capture of data from item "identification" blocks in the MUD, to validate the data, and to
integrate with the Item table in gizwrld.db to store, update, and query item data.
--]]

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
  addItemObject( ItemObject )
  displayItem( ItemObject.shortDescription, 999 )
  -- Reset the item object table once it has been inserted
  ItemObject = {}
  tempTimer( 1, function ()
    idNextItem()
  end )
end

-- The full identify text of an item appears over multiple lines and has an arbitrary length; this function
-- aggregates the data using a global string variable.
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

-- The purpose of this function is to act as a "catch all" for items dropped from mobs until they
-- can be properly vetted and added to our database. For now this function should just associate
-- an item with the mob that dropped it. If the item is already in the table, it should verify
-- that it dropped from the same mob and if not it should report that a new mob has dropped an
-- item that's already in the log.
function logLoot( item, mob )
  -- Ignore gold coins and items loooted from players (corpse retrieval)
  if item == "gold coins" or KnownPlayers[mob] then return end
  if not LoggedLoot[item] then
    -- Highlight items depending on whether we have them in the Items archive
    local knownColor = Items[item] and "<spring_green>" or "<plum>"
    insertData( "LoggedLoot", item, mob )
    cecho( f "\t{knownColor}{item}{RC} found on {MC}{mob}{RC}" )
  else
    -- If the item is already in the log, check if it's the same mob
    if LoggedLoot[item] ~= mob then
      cecho( f "{EC}Conflict: {NC}{item}{RC} already logged as dropped by {SC}{LoggedLoot[item]}{RC}, now dropped by {SC}{mob}{RC}" )
    end
  end
end