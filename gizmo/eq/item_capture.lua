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
  setItemStatsString()
  setItemFlagString()
  setItemaffectString()
  insertItemObject( ItemObject )
  displayItem( 999, ItemObject.shortDescription )
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
  if ItemObject.baseType == "POTION" and ItemObject.spellLevel then
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

-- Called for items where baseType is WEAPON to parse the damage dice portion of the identification block and derive associated values
-- damageDice is a string in format "NDS" where N is the number of dice and S is the number of sides on each die
-- This function assumes damageDice has already been set and is properly formatted which should be guaranteed from the MUD
function setItemDamage()
  if ItemObject.baseType ~= "WEAPON" then
    return
  end
  cecho( "\n\t  [ <dark_olive_green><i>~setting damageString</i><reset> ]" )
  local n, s = ItemObject.damageDice:match( "(%d+)D(%d+)" )
  if n and s then
    local dam                = ItemObject.dr or 0
    local damStr             = getSignedString( ItemObject.dr )
    local hitStr             = getSignedString( ItemObject.hr )
    n                        = tonumber( n )
    s                        = tonumber( s )
    ItemObject.damageNumber  = n
    ItemObject.damageSides   = s
    ItemObject.averageDamage = n * ((s + 1) / 2) + dam
    ItemObject.damageString  = f "{n}D{s}{damStr}{hitStr} ({ItemObject.averageDamage}avg)"
  else
    local damageError = f "{EC}setItemDamage{RC}(): Invalid damageDice {ItemObject.damageDice}"
    cecho( damageError )
  end
end

function getDamageString()
  if ItemObject.baseType ~= "WEAPON" then
    return nil
  end
  cecho( "\n\t  [ <dark_olive_green><i>~setting damageString</i><reset> ]" )
  local n, s = ItemObject.damageDice:match( "(%d+)D(%d+)" )
  if n and s then
    local dam                = ItemObject.dr or 0
    local damStr             = getSignedString( ItemObject.dr )
    local hitStr             = getSignedString( ItemObject.hr )
    n                        = tonumber( n )
    s                        = tonumber( s )
    ItemObject.damageNumber  = n
    ItemObject.damageSides   = s
    ItemObject.averageDamage = n * ((s + 1) / 2) + dam
    return f( "{n}D{s}{damStr}{hitStr} ({ItemObject.averageDamage}avg)" )
  else
    local damageError = f( "{EC}getDamageString{RC}(): Invalid damageDice {ItemObject.damageDice}" )
    cecho( damageError )
    return nil
  end
end

function setItemStatsString()
  local damageString = getDamageString()
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
  return trim( name )
end

-- This function sets a shorthand representation of an item's "antis" by examining the flags and undeadAntis
-- properties and concatenating values from the ITEM_FLAGS table
function setItemFlagString()
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
  ItemObject.flagString = table.concat( shortFlags, ' ' )
  ItemObject.flagString = trim( ItemObject.flagString )
  -- Replace any instances of double space with single space (repeat until none are found)
  while ItemObject.flagString:find( "  " ) do
    ItemObject.flagString = ItemObject.flagString:gsub( "  ", " " )
  end
end

-- This function sets a shorthand representation of an item's affects based on PERMANENT_AFFECTS
function setItemaffectString()
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
  -- Clean up and set the value in the object table
  affectString = trim( affectString )
  while affectString:find( "  " ) do
    affectString = affectString:gsub( "  ", " " )
  end
  ItemObject.affectString = affectString
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
    local skip      = ItemObject.damageString and (stat == "dr" or stat == "hr")
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
