-- File to define a variety of constants for use throughout the new Item data structure.

-- Tags to help distinguish items as being cloneable or having special procedures (procs),
-- and their ASCII equivalents  for in-game chat channels.
CLONE_TAG            = "†"
CLONE_TAG_A          = "`q(`ec`q)"
SPEC_TAG             = "ƒ"
SPEC_TAG_A           = "`q(`kf`q)"

-- Universal "tag" to prepend to console output related to items & the item database
GDITM                = "\n\t<slate_blue>►<dark_slate_grey>╔╝<slate_blue>◄<reset>"
GDERR                = "\n\t<firebrick>◄<orange_red>ß<reset>"
GDOK                 = "\n\t<spring_green>◄<chartreuse>ß<spring_green>►<reset>"

-- Table defining the data schema for each Item in the Items table; each row in this table defines properties of
-- the item data; other functions in the data module can refer to this table to validate data captured during the id process;
-- Properties include:
-- def: The default value for this field where applicable
-- tier: How "important" this data is; used e.g., by displayItem() to decide what to show/hide
-- src: How the data is obtained; by CAPture, CALCulated, or derived via some CoMmanD like 'look' or 'wear'
-- req: If true, this field must be non-nil for an item to be considered complete & valid
-- typ: The type of data that belongs in this field; useful when the table index is nil and we want to validate caputred data
-- nick: Some properties have short-hand nicknames to condense in-game displays
-- order: When displayItem() shows many fields, this determines their order to improve readability
ITEM_SCHEMA          = {
  ["shortDescription"] = {def = nil, tier = 0, src = "cmd", typ = "string", nick = "short", order = 20},
  ["statsString"]      = {def = nil, tier = 0, src = "calc", typ = "string", nick = "stats", order = 30},
  ["loadString"]       = {def = nil, tier = 1, src = "cap", typ = "string", nick = "loads", order = 40},
  ["worn"]             = {def = nil, tier = 0, src = "cmd", typ = "string", nick = "", order = 50},
  ["baseType"]         = {def = nil, tier = 1, src = "cap", typ = "string", nick = "type", order = 60},
  ["keywords"]         = {def = nil, tier = 0, src = "cap", typ = "table", nick = "", order = 70},
  ["longDescription"]  = {def = nil, tier = 1, src = "cmd", typ = "string", nick = "long", order = 80},
  ["armorClass"]       = {def = nil, tier = 0, src = "calc", typ = "number", nick = "ac", order = 90},
  ["dr"]               = {def = nil, tier = 0, src = "cap", typ = "number", nick = "", order = 100},
  ["hr"]               = {def = nil, tier = 0, src = "cap", typ = "number", nick = "", order = 110},
  ["hp"]               = {def = nil, tier = 0, src = "cap", typ = "number", nick = "", order = 120},
  ["mn"]               = {def = nil, tier = 0, src = "cap", typ = "number", nick = "", order = 130},
  ["mv"]               = {def = nil, tier = 0, src = "cap", typ = "number", nick = "", order = 140},
  ["str"]              = {def = nil, tier = 0, src = "cap", typ = "number", nick = "", order = 150},
  ["int"]              = {def = nil, tier = 0, src = "cap", typ = "number", nick = "", order = 160},
  ["wis"]              = {def = nil, tier = 0, src = "cap", typ = "number", nick = "", order = 170},
  ["dex"]              = {def = nil, tier = 0, src = "cap", typ = "number", nick = "", order = 180},
  ["con"]              = {def = nil, tier = 0, src = "cap", typ = "number", nick = "", order = 190},
  ["weight"]           = {def = 0, tier = 1, src = "cap", typ = "number", nick = "wt", order = 200},
  ["value"]            = {def = 0, tier = 1, src = "calc", typ = "number", nick = "", order = 210},
  ["cloneable"]        = {def = true, tier = 0, src = "calc", typ = "boolean", nick = "", order = 220},
  ["holdable"]         = {def = false, tier = 0, src = "cmd", typ = "boolean", nick = "", order = 230},
  ["affectString"]     = {def = nil, tier = 2, src = "calc", typ = "string", nick = "", order = 270},
  ["affects"]          = {def = nil, tier = 2, src = "cap", typ = "table", nick = "", order = 275},
  ["flagString"]       = {def = nil, tier = 2, src = "calc", typ = "string", nick = "", order = 280},
  ["flags"]            = {def = nil, tier = 2, src = "cap", typ = "table", nick = "", order = 285},
  ["undeadAntis"]      = {def = nil, tier = 2, src = "cap", typ = "table", nick = "", order = 290},
  ["acApply"]          = {def = nil, tier = 2, src = "cap", typ = "number", nick = "", order = 300},
  ["armorAffect"]      = {def = nil, tier = 2, src = "cap", typ = "number", nick = "", order = 310},
  ["damageDice"]       = {def = nil, tier = 2, src = "cap", typ = "string", nick = "", order = 320},
  ["damageNumber"]     = {def = nil, tier = 2, src = "calc", typ = "number", nick = "", order = 330},
  ["damageSides"]      = {def = nil, tier = 2, src = "calc", typ = "number", nick = "", order = 340},
  ["averageDamage"]    = {def = nil, tier = 2, src = "calc", typ = "number", nick = "", order = 350},
  ["damageString"]     = {def = nil, tier = 2, src = "calc", typ = "string", nick = "damage", order = 355},
  ["skillBackstab"]    = {def = nil, tier = 2, src = "cap", typ = "number", nick = "STAB", order = 360},
  ["skillBash"]        = {def = nil, tier = 2, src = "cap", typ = "number", nick = "BASH", order = 370},
  ["skillBlock"]       = {def = nil, tier = 2, src = "cap", typ = "number", nick = "BLCK", order = 380},
  ["skillCharge"]      = {def = nil, tier = 2, src = "cap", typ = "number", nick = "CHRG", order = 385},
  ["skillCircle"]      = {def = nil, tier = 2, src = "cap", typ = "number", nick = "CIRC", order = 390},
  ["skillDisarm"]      = {def = nil, tier = 2, src = "cap", typ = "number", nick = "DSRM", order = 400},
  ["skillDodge"]       = {def = nil, tier = 2, src = "cap", typ = "number", nick = "DDGE", order = 410},
  ["skillDual"]        = {def = nil, tier = 2, src = "cap", typ = "number", nick = "DUAL", order = 420},
  ["skillHide"]        = {def = nil, tier = 2, src = "cap", typ = "number", nick = "HIDE", order = 430},
  ["skillKick"]        = {def = nil, tier = 2, src = "cap", typ = "number", nick = "KICK", order = 435},
  ["skillKnock"]       = {def = nil, tier = 2, src = "cap", typ = "number", nick = "KNCK", order = 440},
  ["skillParry"]       = {def = nil, tier = 2, src = "cap", typ = "number", nick = "PRRY", order = 450},
  ["skillPeek"]        = {def = nil, tier = 2, src = "cap", typ = "number", nick = "PEEK", order = 460},
  ["skillPick"]        = {def = nil, tier = 2, src = "cap", typ = "number", nick = "PICK", order = 470},
  ["skillQuad"]        = {def = nil, tier = 2, src = "cap", typ = "number", nick = "QUAD", order = 480},
  ["skillRescue"]      = {def = nil, tier = 2, src = "cap", typ = "number", nick = "RESC", order = 490},
  ["skillSneak"]       = {def = nil, tier = 2, src = "cap", typ = "number", nick = "SNEK", order = 500},
  ["skillSteal"]       = {def = nil, tier = 2, src = "cap", typ = "number", nick = "STEL", order = 510},
  ["skillThrow"]       = {def = nil, tier = 2, src = "cap", typ = "number", nick = "THRW", order = 520},
  ["skillTrap"]        = {def = nil, tier = 2, src = "cap", typ = "number", nick = "TRAP", order = 530},
  ["skillTriple"]      = {def = nil, tier = 2, src = "cap", typ = "number", nick = "TRPL", order = 540},
  ["pcAge"]            = {def = nil, tier = 2, src = "cap", typ = "number", nick = "age", order = 550},
  ["pcHeight"]         = {def = nil, tier = 2, src = "cap", typ = "number", nick = "height", order = 560},
  ["pcWeight"]         = {def = nil, tier = 2, src = "cap", typ = "number", nick = "", order = 570},
  ["decays"]           = {def = false, tier = 0, src = "cap", typ = "boolean", nick = "", order = 580},
  ["spellLevel"]       = {def = nil, tier = 0, src = "cap", typ = "number", nick = "", order = 582},
  ["spellList"]        = {def = nil, tier = 0, src = "cap", typ = "table", nick = "", order = 584},
  ["spellCharges"]     = {def = nil, tier = 0, src = "cap", typ = "number", nick = "", order = 586},
  ["identifyText"]     = {def = nil, tier = 2, src = "cap", typ = "string", nick = "id", order = 590},
  ["savingBreath"]     = {def = nil, tier = 2, src = "cap", typ = "number", nick = "vBRTH", order = 595},
  ["savingParalyze"]   = {def = nil, tier = 2, src = "cap", typ = "number", nick = "vPARA", order = 600},
  ["savingPetrify"]    = {def = nil, tier = 2, src = "cap", typ = "number", nick = "vPETR", order = 605},
  ["savingSpell"]      = {def = nil, tier = 2, src = "cap", typ = "number", nick = "vSPLL", order = 610},
  ["contributor"]      = {def = nil, tier = 1, src = "cap", typ = "string", nick = "", order = 800},
  ["dateRecorded"]     = {def = nil, tier = 2, src = "calc", typ = "string", nick = "date", order = 850},
}

-- This table identifies attributes in the ITEM_SCHEMA which should be skipped or ignored when considering
-- whether two items are identical; things like datetime and contributing player will be different when
-- all other stats will be the same.
EXCLUDE_FROM_COMPARE = {
  contributor  = true,
  dateRecorded = true,
  identifyText = true,
  -- Value varies in some weird ways (e.g., donated stuff); ignore it for now but
  -- maybe do something more interesting later
  value        = true,
}

-- When paying out rewards for items contributed to The Gixdex library, use these values
BOUNTY_VALUES        = {
  ["averageDamage"] = 2000,
  ["dr"]            = 2000,
  ["hr"]            = 500,
  ["hp"]            = 100,
  ["mn"]            = 200,
  ["mv"]            = 50,
  ["ac"]            = 500,
  ["armor"]         = 500,
  ["str"]           = 100,
  ["int"]           = 50,
  ["wis"]           = 50,
  ["dex"]           = 100,
  ["con"]           = 50,
  ["value"]         = 1,
  ["skillBackstab"] = 1000,
  ["skillBash"]     = 100,
  ["skillBlock"]    = 500,
  ["skillCircle"]   = 1000,
  ["skillDisarm"]   = 100,
  ["skillDodge"]    = 500,
  ["skillDual"]     = 1000,
  ["skillHide"]     = 25,
  ["skillKnock"]    = 25,
  ["skillParry"]    = 500,
  ["skillPeek"]     = 25,
  ["skillPick"]     = 25,
  ["skillQuad"]     = 1000,
  ["skillSneak"]    = 25,
  ["skillSteal"]    = 25,
  ["skillThrow"]    = 500,
  ["skillTrap"]     = 25,
  ["skillTriple"]   = 1000,
}

-- When paying out rewards for contributions, clamp rewards to these values
MAX_BOUNTY           = 500000
MIN_BOUNTY           = 1000

-- CORE_STATS are considered critical to the function and benefit from an item, and will be
-- included in the item's primary "stat string" representing its stast in-game
CORE_STATS           = {
  "dr",
  "hr",
  "armorClass",
  "hp",
  "mn",
  "mv",
  "str",
  "int",
  "wis",
  "dex",
  "con",
  "skillBackstab",
  "skillBash",
  "skillBlock",
  "skillCharge",
  "skillCircle",
  "skillDisarm",
  "skillDodge",
  "skillDual",
  "skillHide",
  "skillKnock",
  "skillParry",
  "skillPeek",
  "skillPick",
  "skillQuad",
  "skillRescue",
  "skillSneak",
  "skillSteal",
  "skillThrow",
  "skillTrap",
  "skillTriple",
}
-- Some items grant a permament "buff" spell or ability; PERMANENT_AFFECTS lists all such affects (known)
-- The "nick" for each affect helps create condensed strings for display in game; "display" dictates whether the affect is shown
-- Items can grant multiple affects, so ItemObject stores this as a table and the Item table in gizwrld.db will use a JSON column
-- These affects are captured as a space-delimited string using the following Perl regex:
-- ^Item will give you following abilities:\s*(.+)\s*$
PERMANENT_AFFECTS    = {
  -- We get DAL, DLF, PFE from RANK so turn those off; also CURSE can go f itself
  ["SNEAK"]            = {nick = "+SNK", display = true},
  ["INVISIBLE"]        = {nick = "+INV", display = true},
  ["DETECT-ALIGNMENT"] = {nick = "+DAL", display = true},
  ["DETECT-MAGIC"]     = {nick = "+DMA", display = true},
  ["SENSE-LIFE"]       = {nick = "+DLF", display = true},
  ["INFRAVISION"]      = {nick = "+INF", display = true},
  ["FLY"]              = {nick = "+FLY", display = true},
  ["DETECT-INVISIBLE"] = {nick = "+DIN", display = true},
  ["PROTECT-EVIL"]     = {nick = "+PFE", display = true},
  ["INVUL"]            = {nick = "+VUL", display = true},
  ["SANCTUARY"]        = {nick = "+SNC", display = true},
  ["DUAL"]             = {nick = "+DUA", display = true},
  ["FURY"]             = {nick = "+FUR", display = true},
  ["CURSE"]            = {nick = "+CUR", display = true},
  ["POISON"]           = {nick = "+POI", display = true},
  ["IMINV"]            = {nick = "+IMM", display = true},
}

-- ITEM_FLAGS contains all possible "flags" that appear on items; flags describe a range of item properties, most importantly
-- identifying which characters can use the item based on their class, sex, and alignment.
-- Like PERMANENT_AFFECTS, flags are captured as a space-delim'd string and will be stored as a table in ItemObject;
-- Using nick & display, this table is used to create condensed strings for in-game display (and filter out unwanted data)
-- Item flags can be captured from one of two lines in the id block:
-- ^Item is: (.+)\s*$
-- ^Undead antis: (.+)\s*$
-- Example: Item is: INVISIBLE ANTI-GOOD ANTI-NEUTRAL ANTI-WARRIOR ANTI-CLERIC ANTI-MAGIC_USER
-- Example: Undead antis: ANTI_DEATH_TYRANT ANTI_BANSHEE ANTI_LICH ANTI_WRAITH ANTI_DEATH_KNIGHT
ITEM_FLAGS           = {
  ["ANTI_BANSHEE"]      = {nick = "!BN", display = true},
  ["ANTI_BONE_GOLEM"]   = {nick = "!BG", display = true},
  ["ANTI_DEATH_KNIGHT"] = {nick = "!DK", display = true},
  ["ANTI_DEATH_TYRANT"] = {nick = "!DT", display = true},
  ["ANTI_LICH"]         = {nick = "!LI", display = true},
  ["ANTI_WRAITH"]       = {nick = "!WR", display = true},
  ["ANTI-ANTI-PALADIN"] = {nick = "!AP", display = true},
  ["ANTI-AVATAR"]       = {nick = "!AV", display = true},
  ["ANTI-BARD"]         = {nick = "!BA", display = true},
  ["ANTI-CLERIC"]       = {nick = "!CL", display = true},
  ["ANTI-COMMANDO"]     = {nick = "!CO", display = true},
  ["ANTI-EVIL"]         = {nick = "!EVI", display = true},
  ["ANTI-FEMALE"]       = {nick = "!FEM", display = true},
  ["ANTI-GOOD"]         = {nick = "!GOO", display = true},
  ["ANTI-MAGIC_USER"]   = {nick = "!MU", display = true},
  ["ANTI-MALE"]         = {nick = "!MAL", display = true},
  ["ANTI-NEUTRAL"]      = {nick = "!NEU", display = true},
  ["ANTI-NINJA"]        = {nick = "!NI", display = true},
  ["ANTI-NOMAD"]        = {nick = "!NO", display = true},
  ["ANTI-PALADIN"]      = {nick = "!PA", display = true},
  ["ANTI-RENT"]         = {nick = "!REN", display = true},
  ["ANTI-THIEF"]        = {nick = "!TH", display = true},
  ["ANTI-WARRIOR"]      = {nick = "!WA", display = true},
  ["RSPEC"]             = {nick = SPEC_TAG, display = true},
  ["SHORTSPEC"]         = {nick = SPEC_TAG, display = true},
  ["BLESS"]             = {nick = "", display = true},
  ["CLONED"]            = {nick = "", display = true},
  ["DARK"]              = {nick = "", display = true},
  ["EVIL"]              = {nick = "", display = true},
  ["GLOW"]              = {nick = "", display = true},
  ["HUM"]               = {nick = "", display = true},
  ["INVISIBLE"]         = {nick = "", display = true},
  ["LIMITED"]           = {nick = "", display = true},
  ["MAGIC"]             = {nick = "", display = true},
  ["NOBITS"]            = {nick = "", display = true},
  ["NOBITSNOBITS"]      = {nick = "", display = true},
  ["NODROP"]            = {nick = "", display = true},
  ["NONE"]              = {nick = "", display = true},
  ["DECAY_ON_RENT"]     = {nick = "!REN", display = true},
}

-- Item type, or "base type," is a high-level item categorization scheme whose subcategories are more important for determining
-- specific item functionality/usefulness. Base type can come in handy when validating item data (e.g., WEAPONs have damageDice).
-- Base type is captured from the identification block with the following regex:
-- Item type: (\w+)\s*$
-- Example: Item type: ARMOR
ITEM_TYPES           = {
  ["ARMOR"]            = true,
  ["WORN"]             = true,
  ["WEAPON"]           = true,
  ["LIGHT"]            = true,
  ["MUSICAL"]          = true,
  ["TREASURE"]         = true,
  ["UNKNOWN"]          = true,
  ["OTHER"]            = true,
  ["BOAT"]             = true,
  ["CONTAINER"]        = true,
  ["LIQUID CONTAINER"] = true,
}

-- "worn" is the more important subcategory of base type determining how players can utilize items in the game, but its
-- relationship to base type can be confusing like when BOATs go on FEET or items worn on FINGER can be ARMOR, TREASURE, or WORN
WORN                 = {
  ["ABOUT"]   = true,
  ["ARMS"]    = true,
  ["BODY"]    = true,
  ["FEET"]    = true,
  ["FINGERS"] = true,
  ["HANDS"]   = true,
  ["HEAD"]    = true,
  ["HOLD"]    = true,
  ["LEGS"]    = true,
  ["LIGHT"]   = true,
  ["NECK"]    = true,
  ["SHIELD"]  = true,
  ["WAIST"]   = true,
  ["WIELD"]   = true,
  ["WRISTS"]  = true,
}

-- The ATTRIBUTE_MAP table translates from in-game string representation of item stats which are generally in a
-- CAPITAL_SNAKE_CASE format into corresponding field and column names for ItemObject and the Item table in gizwrld.db
-- Once again "nick" and "display" determine which of these stats to show in game (not all of them are relevant)
-- These values are captured from lines in the id block of an item in the following format:
-- ^\s*Affects : (\w+) By (-?\d+)\s*$
-- Example:
-- Affects : HITROLL By 2
ATTRIBUTE_MAP        = {
  AGE            = "pcAge",
  ARMOR          = "armorAffect",
  CHAR_HEIGHT    = "pcHeight",
  CHAR_WEIGHT    = "pcWeight",
  CON            = "con",
  DAMROLL        = "dr",
  DEX            = "dex",
  HIT            = "hp",
  HITROLL        = "hr",
  INT            = "int",
  MANA           = "mn",
  MOVE           = "mv",
  SAVING_BREATH  = "savingBreath",
  SAVING_PARA    = "savingParalyze",
  SAVING_PETRI   = "savingPetrify",
  SAVING_SPELL   = "savingSpell",
  SKILL_BACKSTAB = "skillBackstab",
  SKILL_BASH     = "skillBash",
  SKILL_BLOCK    = "skillBlock",
  SKILL_CHARGE   = "skillCharge",
  SKILL_CIRCLE   = "skillCircle",
  SKILL_DISARM   = "skillDisarm",
  SKILL_DODGE    = "skillDodge",
  SKILL_DUAL     = "skillDual",
  SKILL_HIDE     = "skillHide",
  SKILL_KICK     = "skillKick",
  SKILL_KNOCK    = "skillKnock",
  SKILL_PARRY    = "skillParry",
  SKILL_PEEK     = "skillPeek",
  SKILL_PICKLOCK = "skillPick",
  SKILL_QUAD     = "skillQuad",
  SKILL_RESCUE   = "skillRescue",
  SKILL_SNEAK    = "skillSneak",
  SKILL_STEAL    = "skillSteal",
  SKILL_THROW    = "skillThrow",
  SKILL_TRAP     = "skillTrap",
  SKILL_TRIPLE   = "skillTriple",
  STR            = "str",
  WIS            = "wis",
}

SPELL_MAP            = {
  ["blindness"]            = "blind",
  ["cure blind"]           = "!blind",
  ["cure critic"]          = "+critic",
  ["cure light"]           = "+light",
  ["cure serious"]         = "+serious",
  ["curse"]                = "curse",
  ["detect alignment"]     = "daln",
  ["detect invisibility"]  = "dinv",
  ["detect magic"]         = "dmag",
  ["detect poison"]        = "dpoi",
  ["endure"]               = "end",
  ["fireshield"]           = "fshield",
  ["grace of god"]         = "gog",
  ["great miracle"]        = "+great mira",
  ["hand of god"]          = "hog",
  ["heal"]                 = "+heal",
  ["holy bless"]           = "hbless",
  ["improve invisibility"] = "imp inv",
  ["infravision"]          = "infra",
  ["invisibility"]         = "inv",
  ["invulnerability"]      = "invuln",
  ["miracle"]              = "mira",
  ["paralyze"]             = "para",
  ["protection from evil"] = "pfe",
  ["remove curse"]         = "-curse",
  ["remove paralysis"]     = "-para",
  ["remove poison"]        = "-poison",
  ["sanctuary"]            = "sanct",
  ["sense life"]           = "dlif",
  ["strength"]             = "str",
  ["super harm"]           = "sharm",
  ["swiftness"]            = "swift",
  ["enchant weapon"]       = "ench weapon",
}

-- A dummy function to register this file with the auto-reload system
function touchBoobs()
  cecho( "You absolute perv." )
end
