--[[ id_capture.lua
Module to implement the capture of data from item "identification" blocks in the MUD, to validate the data, and to
integrate with the Item table in gizwrld.db to store, update, and query item data.
--]]

-- Some items grant a permament "buff" spell or ability; PERMANENT_AFFECTS lists all such affects (known)
-- The "nick" for each affect helps create condensed strings for display in game; "display" dictates whether the affect is shown
-- Items can grant multiple affects, so ItemObject stores this as a table and the Item table in gizwrld.db will use a JSON column
-- These affects are captured as a space-delimited string using the following Perl regex:
-- ^Item will give you following abilities:\s*(.+)\s*$
PERMANENT_AFFECTS = {
  -- We get DAL, DLF, PFE from RANK so turn those off; also CURSE can go f itself
  ["SNEAK"]            = {nick = "+SNK", display = true},
  ["INVISIBLE"]        = {nick = "+INV", display = true},
  ["DETECT-ALIGNMENT"] = {nick = "+DAL", display = false},
  ["DETECT-MAGIC"]     = {nick = "+DMA", display = true},
  ["SENSE-LIFE"]       = {nick = "+DLF", display = false},
  ["INFRAVISION"]      = {nick = "+INF", display = true},
  ["FLY"]              = {nick = "+FLY", display = true},
  ["DETECT-INVISIBLE"] = {nick = "+DIN", display = true},
  ["PROTECT-EVIL"]     = {nick = "+PFE", display = false},
  ["INVUL"]            = {nick = "+VUL", display = true},
  ["SANCTUARY"]        = {nick = "+SNC", display = true},
  ["DUAL"]             = {nick = "+DUA", display = true},
  ["FURY"]             = {nick = "+FUR", display = true},
  ["CURSE"]            = {nick = "+CUR", display = false},
  ["POISON"]           = {nick = "+POI", display = true},
  ["IMINV"]            = {nick = "+IMM", display = true},
}

-- ITEM_FLAGS contains all possible "flags" that appear on items; flags describe a range of item properties, most importantly
-- identifying which characters can use the item based on their class, gender, and alignment.
-- Like PERMANENT_AFFECTS, flags are captured as a space-delim'd string, stored in a table in ItemObject, and a JSON column in the Item table of gizwrld.db,
-- and "nick" and "display" are used to help build condensed in-game display strings.
-- Item flags can be captured from one of two lines in the id block:
-- ^Item is: (.+)\s*$
-- ^Undead antis: (.+)\s*$
-- Example: Item is: INVISIBLE ANTI-GOOD ANTI-NEUTRAL ANTI-WARRIOR ANTI-CLERIC ANTI-MAGIC_USER
-- Example: Undead antis: ANTI_DEATH_TYRANT ANTI_BANSHEE ANTI_LICH ANTI_WRAITH ANTI_DEATH_KNIGHT
ITEM_FLAGS        = {
  ["ANTI_BANSHEE"]      = {nick = "!BN", display = true},
  ["ANTI_BONE_GOLEM"]   = {nick = "!BG", display = false},
  ["ANTI_DEATH_KNIGHT"] = {nick = "!DK", display = false},
  ["ANTI_DEATH_TYRANT"] = {nick = "!DT", display = false},
  ["ANTI_LICH"]         = {nick = "!LI", display = false},
  ["ANTI_WRAITH"]       = {nick = "!WR", display = false},
  ["ANTI-ANTI-PALADIN"] = {nick = "!AP", display = true},
  ["ANTI-AVATAR"]       = {nick = "!AV", display = false},
  ["ANTI-BARD"]         = {nick = "!BA", display = true},
  ["ANTI-CLERIC"]       = {nick = "!CL", display = true},
  ["ANTI-COMMANDO"]     = {nick = "!CO", display = false},
  ["ANTI-EVIL"]         = {nick = "!EV", display = true},
  ["ANTI-FEMALE"]       = {nick = "!FE", display = true},
  ["ANTI-GOOD"]         = {nick = "!GO", display = true},
  ["ANTI-MAGIC_USER"]   = {nick = "!MU", display = true},
  ["ANTI-MALE"]         = {nick = "!MA", display = false},
  ["ANTI-NEUTRAL"]      = {nick = "!NE", display = true},
  ["ANTI-NINJA"]        = {nick = "!NI", display = false},
  ["ANTI-NOMAD"]        = {nick = "!NO", display = false},
  ["ANTI-PALADIN"]      = {nick = "!PA", display = false},
  ["ANTI-RENT"]         = {nick = "!RE", display = true},
  ["ANTI-THIEF"]        = {nick = "!TH", display = false},
  ["ANTI-WARRIOR"]      = {nick = "!WA", display = true},
  ["RSPEC"]             = {nick = "ƒ", display = true},
  ["SHORTSPEC"]         = {nick = "ƒ", display = true},
  ["BLESS"]             = {nick = "", display = false},
  ["CLONED"]            = {nick = "", display = false},
  ["DARK"]              = {nick = "", display = false},
  ["EVIL"]              = {nick = "", display = false},
  ["GLOW"]              = {nick = "", display = false},
  ["HUM"]               = {nick = "", display = false},
  ["INVISIBLE"]         = {nick = "", display = false},
  ["LIMITED"]           = {nick = "", display = false},
  ["MAGIC"]             = {nick = "", display = false},
  ["NOBITS"]            = {nick = "", display = false},
  ["NOBITSNOBITS"]      = {nick = "", display = false},
  ["NODROP"]            = {nick = "", display = false},
  ["NONE"]              = {nick = "", display = false},
}

-- Item type, or "base type," is a high-level item categorization scheme whose subcategories are more important for determining
-- specific item functionality/usefulness. Base type can come in handy when validating item data (e.g., WEAPONs have damageDice).
-- Base type is captured from the identification block with the following regex:
-- Item type: (\w+)\s*$
-- Example: Item type: ARMOR
ITEM_TYPES        = {
  ["ARMOR"]     = true,
  ["WORN"]      = true,
  ["WEAPON"]    = true,
  ["LIGHT"]     = true,
  ["MUSICAL"]   = true,
  ["TREASURE"]  = true,
  ["UNKNOWN"]   = true,
  ["OTHER"]     = true,
  ["BOAT"]      = true,
  ["CONTAINER"] = true,
}

-- "worn" is the more important subcategory of base type determining how players can utilize items in the game, but its
-- relationship to base type can be confusing like when BOATs go on FEET or items worn on FINGER can be ARMOR, TREASURE, or WORN
WORN              = {
  ["ABOUT"]  = true,
  ["ARMS"]   = true,
  ["BODY"]   = true,
  ["FEET"]   = true,
  ["FINGER"] = true,
  ["HANDS"]  = true,
  ["HEAD"]   = true,
  ["HOLD"]   = true,
  ["LEGS"]   = true,
  ["LIGHT"]  = true,
  ["NECK"]   = true,
  ["SHIELD"] = true,
  ["WAIST"]  = true,
  ["WEAPON"] = true,
  ["WRIST"]  = true,
}

-- The ATTRIBUTE_MAP table translates from in-game string representation of item stats which are generally in a
-- CAPITAL_SNAKE_CASE format into corresponding field and column names for ItemObject and the Item table in gizwrld.db
-- Once again "nick" and "display" determine which of these stats to show in game (not all of them are relevant)
-- These values are captured from lines in the id block of an item in the following format:
-- ^\s*Affects : (\w+) By (-?\d+)\s*$
-- Example:
-- Affects : HITROLL By 2
ATTRIBUTE_MAP     = {
  AGE            = {col = "pcAge", nick = "", display = false},
  ARMOR          = {col = "armor", nick = "", display = false},
  CHAR_HEIGHT    = {col = "pcHeight", nick = "", display = false},
  CHAR_WEIGHT    = {col = "pcWeight", nick = "", display = false},
  CON            = {col = "con", nick = "con", display = true},
  DAMROLL        = {col = "dr", nick = "dr", display = true},
  DEX            = {col = "dex", nick = "dex", display = true},
  HIT            = {col = "hp", nick = "hp", display = true},
  HITROLL        = {col = "hr", nick = "hr", display = true},
  INT            = {col = "int", nick = "int", display = true},
  MANA           = {col = "mn", nick = "mn", display = true},
  MOVE           = {col = "mv", nick = "mv", display = true},
  SAVING_BREATH  = {col = "savingBreath", nick = "", display = false},
  SAVING_PARA    = {col = "savingParalyze", nick = "", display = false},
  SAVING_PETRI   = {col = "savingPetrify", nick = "", display = false},
  SAVING_SPELL   = {col = "savingSpell", nick = "", display = false},
  SKILL_BACKSTAB = {col = "skillBackstab", nick = "STAB", display = true},
  SKILL_BASH     = {col = "skillBash", nick = "BASH", display = true},
  SKILL_BLOCK    = {col = "skillBlock", nick = "BLOK", display = true},
  SKILL_CIRCLE   = {col = "skillCircle", nick = "CIRC", display = true},
  SKILL_DISARM   = {col = "skillDisarm", nick = "DSRM", display = true},
  SKILL_DODGE    = {col = "skillDodge", nick = "DDGE", display = true},
  SKILL_DUAL     = {col = "skillDual", nick = "DUAL", display = true},
  SKILL_HIDE     = {col = "skillHide", nick = "HIDE", display = true},
  SKILL_KNOCK    = {col = "skillKnock", nick = "KNOK", display = true},
  SKILL_PARRY    = {col = "skillParry", nick = "PRRY", display = true},
  SKILL_PEEK     = {col = "skillPeek", nick = "PEEK", display = true},
  SKILL_PICKLOCK = {col = "skillPick", nick = "PICK", display = true},
  SKILL_QUAD     = {col = "skillQuad", nick = "QUAD", display = true},
  SKILL_RESCUE   = {col = "skillRescue", nick = "RESC", display = true},
  SKILL_SNEAK    = {col = "skillSneak", nick = "SNEK", display = true},
  SKILL_STEAL    = {col = "skillSteal", nick = "STEL", display = true},
  SKILL_THROW    = {col = "skillThrow", nick = "THRW", display = true},
  SKILL_TRAP     = {col = "skillTrap", nick = "TRAP", display = true},
  SKILL_TRIPLE   = {col = "skillTriple", nick = "TRPL", display = true},
  STR            = {col = "str", nick = "str", display = true},
  WIS            = {col = "wis", nick = "wis", display = true},
}

-- The ItemObject global table exists to capture and hold data related to an item and to validate it prior to insertion into the Item
-- table of gizwlrd.db; eventually once two-way integration is done we can also use this same table to hold item data extracted by queries
-- or searches prior to display in game (or Discord, etc.).
ItemObject        = ItemObject or {}
function initializeItem()
  ItemObject                  = {}
  -- The ItemObject (table) starts with primary fields captured directly from the identification block in game
  -- Set by a call to captureItemAttribute() with the appropriate attribute and value
  ItemObject.keywords         = {} -- Space-delimited keyword list split on " " into a table of individual keywords
  ItemObject.baseType         = "" -- High-level category of item (e.g. "ARMOR", "WEAPON", "WORN" etc.)
  ItemObject.dr               = 0  -- Bonus to damage roll; added to damageString when baseType is WEAPON
  ItemObject.hr               = 0  -- Bonus to hit roll; added to damageString when baseType is WEAPON
  ItemObject.hp               = 0  -- Bonus to hit points (health)
  ItemObject.mn               = 0  -- Bonus to mana
  ItemObject.mv               = 0  -- Bonus to movement points
  ItemObject.ac               = 0  -- Bonus to armor class (negative values are better); from "AC-apply is" lines
  ItemObject.armor            = 0  -- Bonus to armor class (negative values are better); from "Affects : ARMOR By" lines
  ItemObject.str              = 0  -- Bonus to player Strength attribute
  ItemObject.int              = 0  -- Bonus to player Intelligence attribute
  ItemObject.wis              = 0  -- Bonus to player Wisdom attribute
  ItemObject.dex              = 0  -- Bonus to player Dexterity attribute
  ItemObject.con              = 0  -- Bonus to player Constitution attribute
  ItemObject.wt               = 0  -- Weight of the item
  ItemObject.value            = 0  -- Value of the item in gold coins
  ItemObject.affects          = {} -- Space-delimited list of permanent affects split into a table of individual affect strings
  ItemObject.flags            = {} -- Space-delimited list of item flags split into a table of individual strings
  ItemObject.undeadAntis      = {} -- Space-delimited list of undead-specific flags split into a table of individual strings
  ItemObject.damageDice       = "" -- String value for damage when baseType is WEAPON (e.g. "2D6")
  ItemObject.pcAge            = 0  -- Modifies the age of a player character
  ItemObject.pcHeight         = 0  -- Modifies the height of a player character
  ItemObject.pcWeight         = 0  -- Modifies the weight of a player character
  ItemObject.skillBackstab    = 0  -- Each skill* value modifies the corresponding in-game ability of the pc wearing the item
  ItemObject.skillBash        = 0
  ItemObject.skillBlock       = 0
  ItemObject.skillCircle      = 0
  ItemObject.skillDisarm      = 0
  ItemObject.skillDodge       = 0
  ItemObject.skillDual        = 0
  ItemObject.skillHide        = 0
  ItemObject.skillKnock       = 0
  ItemObject.skillParry       = 0
  ItemObject.skillPeek        = 0
  ItemObject.skillPick        = 0
  ItemObject.skillQuad        = 0
  ItemObject.skillRescue      = 0
  ItemObject.skillSneak       = 0
  ItemObject.skillSteal       = 0
  ItemObject.skillThrow       = 0
  ItemObject.skillTrap        = 0
  ItemObject.skillTriple      = 0
  ItemObject.decays           = 0 -- Integers as "boolean" indicating if the item decays over time; defaults false and true when "Item decays" line exists
  -- These secondary fields/columns are derived or calculated from the data captured from the identification block
  -- Set by calls to corresponding functions once the primary data is captured from the game
  ItemObject.armorClass       = 0  -- Calculated as ((ac*3) + armor) for items WORN == BODY or (ac+armor) for all other items
  ItemObject.damageNumber     = 0  -- Parsed from damageDice when baseType is WEAPON becomes the n value in nDs+hr+dr
  ItemObject.damageSides      = 0  -- Parsed from damageDice when baseType is WEAPON becomes the s value in nDs+hr+dr
  ItemObject.damageString     = "" -- Truncated string representation of WEAPON damage
  ItemObject.averageDamage    = 0  -- Calculated as average damage from an nDs+dr roll: n * ( ( s + 1 ) / 2 ) + dr
  ItemObject.clone            = 1  -- Integer as "boolean" indicating if item can be duplicated; defaults to true & set false when LIMITED flag exists
  ItemObject.loadingMob       = 0  -- The unique rNumber value of the mob that "loads" this item; can be derived when loadString matches a Mob
  ItemObject.statsString      = "" -- Truncated "stats string" for condensed in-game display
  ItemObject.flagString       = "" -- Truncated string of anti flags for condensed in-game display
  ItemObject.affectsString    = "" -- Truncated string of perm affects for condensed in-game display
  ItemObject.identifyText     = "" -- The full text of the identification block; useful for debugging & back reference
  -- Neither captured nor calculated/derived these fields must be manually supplied by the user entering or querying an item
  ItemObject.shortDescription = "" -- The item's "name" as it appears in game
  ItemObject.worn             = "" -- The body location this item occupies when used by a player or mob
  ItemObject.loadString       = "" -- Where to obtain; when Mob, attempt to match with Mob table
end

-- For values in ItemObject that are non-zero, non-empty, or non-nil, use iout() to display
-- the key,value pair. iout() encapsulates f-string interpolation and new-lines
function displayItem()
  local op = "<indian_red> = <reset>"
  for key, value in pairs( ItemObject ) do
    local ks = f "{SC}{key}{RC}"
    local vs = nil
    if type( value ) == "table" and next( value ) ~= nil then
      vs = f "{VC}{table.concat(value, ', ')}{RC}"
    elseif (type( value ) == "number" and value ~= 0) or (type( value ) == "string" and value ~= "") then
      vs = f "{VC}{value}{RC}"
    end
    if vs then
      cout( f "{ks}{op}{vs}" )
    end
  end
  -- Display the flags string after all other properties
  local flagString = getItemFlagString()
  if flagString and flagString ~= "" then
    cout( f "{SC}flagString{RC}{op}{VC}{flagString}{RC}" )
  end
end

-- Called from Mudlet as regex patterns are matched against triggers to capture the content of an item's identification text
-- This function will be called multiple times for each identified item, each invocation setting a single attribute's value
-- This function can also be used with isManual true to add user-supplied fields like worn and name/shortDescription
function captureItemAttribute( attribute, value, isManual )
  iout( f [[Captured: {attribute}, {value}]] )

  local attrEntry = ATTRIBUTE_MAP[attribute]
  local column = attrEntry and attrEntry.col or attribute
  local attributeType = type( ItemObject[column] )

  if attributeType == "number" then
    value = tonumber( value )
    if not value then
      iout( f "Invalid number for {attribute}: {value}" )
      return
    end
  elseif attributeType == "table" and type( value ) == "string" then
    -- Check for 'LIMITED' flag before splitting to avoid looking it up in a table later
    if attribute == "flags" and string.find( value, "LIMITED" ) then
      ItemObject.clone = 0
    end
    value = split( value, " " )
  elseif attributeType == "string" and type( value ) ~= "string" then
    iout( f "Invalid type for {attribute}: {value} is not a string" )
    return
  end
  ItemObject[column] = value

  -- Some manual values should be validated and can trigger the calculation of derived fields
  if isManual then
    if attribute == "worn" and not WORN[value] then
      iout( f "Invalid worn location: {value}" )
    elseif attribute == "worn" then
      -- Once we know worn, we should be able to calculate the item's total effective armor class
      setItemArmorClass()
    end
  end
end

-- Called for items where baseType is WEAPON to parse the damage dice portion of the identification block and derive associated values
-- damageDice is a string in format "NDS" where N is the number of dice and S is the number of sides on each die
-- This function assumes damageDice has already been set and is properly formatted which should be guaranteed from the MUD
function setItemDamage()
  local n, s = ItemObject.damageDice:match( "(%d+)D(%d+)" )
  if n and s then
    n                        = tonumber( n )
    s                        = tonumber( s )
    ItemObject.damageNumber  = n
    ItemObject.damageSides   = s
    ItemObject.damageString  = f "{n}D{s}+{ItemObject.dr}+{ItemObject.hr}"
    ItemObject.averageDamage = n * ((s + 1) / 2) + ItemObject.dr
  else
    iout( "{EC}setItemDamage{RC}(): Invalid damageDice {ItemObject.damageDice}" )
  end
end

-- Items can modify armor class by way of two different fields from the id block; additionally, BODY armor confers
-- triple the listed amount from the "AC-apply is" line. This function calculates the final total armorClass for the Item.
-- NOTE: This can only be called once WORN has been indicated, which is not a captured field - calling this function will
-- need to be deferred until the WORN type is supplied by the user via captureItemAttribute().
function setItemArmorClass()
  local acMultiplier = (ItemObject.worn == "BODY") and 3 or 1
  ItemObject.armorClass = (ItemObject.ac * acMultiplier) + ItemObject.armor
end

function getItemStatString()
  -- Initialize local statsString to an empty string
  -- If ItemObject.damageString is not empty, concatenate ItemObject.damageString to statsString
  -- For each attr = ATTRIBUTE_MAP[n] where attr.display is true and ItemObject.attr is not nil, 0, or an empty string
  -- If ItemObject.attr is a string, concatenate f"+{ItemObject.attr}{attr.nick}" to statsString
  -- If ItemObject.attr is a number, concatenate f"{sym}{ItemObject.attr}{attr.nick}" to statsString where sym is "+" or "-"
  -- Be sure to include a space between each concatenated string
  -- Example, if ATTRIBUTE_MAP[INT].display is true and ItemObject.int = 2, then "+2int" should be added to statsString
  -- if ATTRIBUTE_MAP[BASH].display is true and ItemObject.skillBash = 3, then "+3BASH" should be added to statsString
  -- NOTE: DAMROLL and HITROLL should be skipped when ItemObject.damageString is not empty, as these values are already present
  -- in this consolidated string for WEAPON objects
end

-- This function returns a shorthand representation of an items "antis" by examining the flags and undeadAntis
-- properties and concatenating values from the ANTI_NICKS table
function getItemFlagString()
  local flags = {}
  for _, flag in ipairs( ItemObject.flags ) do
    local flagData = ITEM_FLAGS[flag]
    if flagData and flagData.display then
      table.insert( flags, flagData.nick )
    end
  end
  for _, flag in ipairs( ItemObject.undeadAntis ) do
    local flagData = ITEM_FLAGS[flag]
    if flagData and flagData.display then
      table.insert( flags, flagData.nick )
    end
  end
  local result = table.concat( flags, ' ' )
  return result
end

-- This function acts as a "go between" after data has been captured from an id block and entered by the player, it ensures the item
-- is complete and valid -- for now it displays the item, later it will insert it into a database
function finalizeItem()
  -- If damage dice are present but the weapon's damage string hasn't been populated yet, do so
  ItemObject.worn = 'BODY' -- Test setting remove later
  if ItemObject.damageDice ~= "" and ItemObject.damageString == "" then setItemDamage() end
  if ItemObject.ac ~= 0 or ItemObject.armor ~= 0 then setItemArmorClass() end
  displayItem()
end

-- The item name, also known as its "short description" is how the item appears when interacted with or worn by players;
-- this value does not appear in an item's id block, and will therefore be supplied to this funciton by means of a
-- user command or supporting query/function.
function setItemShortDescription( shortDescription )
  -- Strip superfluous modifiers from the string if they were supplied
  shortDescription = trimItemName( shortDescription )
  ItemObject.shortDescription = shortDescription
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
