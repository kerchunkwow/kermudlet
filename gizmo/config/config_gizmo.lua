-- New approach to configuration which branches based on a USERNAME set at startup by parsing Mudlet's home directory.
local function configByUsername()
  if not USERNAME then
    cecho( "\n" .. [[<orange_red>USERNAME missing<reset>; skipping local setup in config_gizmo.lua]] )
  elseif USERNAME == "12404" then
    cecho( "\n" .. f [[Configuring gizmo for USERNAME <green_yellow>{USERNAME}<reset> in config_gizmo.lua]] )

    Buffs              = Buffs or {
      ["Achilles"] = false,
      ["Karma"] = false,
    }

    -- Toggle whether we automatically flee/recall from combat when we're in danger
    AutoRecall         = AutoRecall or false -- (CTRL-R)

    -- Toggle whether we're automatically following our current path
    AutoPathing        = AutoPathing or false -- (CTRL-P)

    -- Toggle whether we automatically re-buff when our spells wear off
    AutoBuffing        = AutoBuffing or false -- (CTRL-B)

    -- Toggle wheter we automatically "look" periodically during combat (to see if we're being attacked)
    AutoLooking        = AutoLooking or false -- (CTRL-L)

    -- Toggle whether we periodically sing our 'Where is My Mind' stun song when AutoPathing
    AutoStunning       = AutoStunning or false -- (CTRL-W)

    -- Toggle whether we're AFK (auto-shutdown on emergency/message)
    AFK                = AFK or nil -- (CTRL-ALT-A)
    -- Modal "flags" that that help to throttle certain commands or delay re-issuing commands to limit
    -- spam or temporarily disable automatic reactions under certain conditions.

    -- When mobs are incapacitated just before dying, the prompt indicates there is no tank which can
    -- trigger certain panic reactions or warnings; this flag is enabled temporarily to suppress them.
    IncapDelay         = IncapDelay or false

    -- Use to throttle attempts to re-assist
    AssistDelay        = AssistDelay or false

    -- Is the Troll currently in the process of "swapping" between Defend and Pummel?
    TrollSwapping      = TrollSwapping or false

    -- Track whether the Troll minion is in our group
    TrollGrouped       = TrollGrouped or false

    -- Local Paths
    ASSETS_PATH        = [[C:/Dev/mud/mudlet/gizmo/assets]]
    DB_PATH            = [[C:/Dev/mud/gizmo/data/gizwrld.db]]
    HOME_PATH          = [[C:/Dev/mud/mudlet]]

    -- Player Names, Containers, and Basic Consumables
    pcNames            = {"Kaylee", "Nadja", "Laszlo", "Nandor"}
    containers         = {"stocking", "stocking", "cradle", "cradle"}
    waterskin          = "waterskin"
    food               = "bread"

    pcCount            = 1

    -- These should be the abbreviations you use to issue commands to session windows; they're used by the
    -- aliasSessionCommand function in config_events.lua to raise the event matching the desired session.
    -- e.g., issuing 'col command' will raise event_command_1
    sessionAliases     = {"kay", "nad", "las", "nan"}

    -- Map session abbreviations to expected session/tab numbers
    sessionNumbers     = {
      ["kay"] = 1, ["nad"] = 2, ["las"] = 3, ["nan"] = 4
    }

    -- Using this table, define which spells are castable from specific player positions within your party;
    -- use this table anywhere you need to select from among a set of possible casters (e.g., when rebuffing).
    partySpells        = {
      ['vitality'] = {2, 3}
    }

    -- Local customization options for GUI windows; expand this list for more GUI customizations later
    -- These are only needed to create the GUI/console and will be nil'd in deleteConsoleStyles()
    customChatFontFace = "Bitstream Vera Sans Mono"
    customChatFontSize = 14
    customInfoFontFace = "Consolas"
    customInfoFontSize = 12
    customChatWrap     = 80
    customInfoWrap     = 120
    customConsoleFonts = {
      ["label"]     = "Ebrima",
      ["gauge_sm"]  = "Bitstream Vera Sans Mono",
      ["gauge_lrg"] = "Montserrat",
      ["room"]      = "Consolas",
    }

    -- Use these shorthand color tags in string literals in order to limit their length
    -- Example instead of iout(f"<orange_red>text<reset>") you can use iout("{EC}text{RC}")
    -- Sacrifices some readiability for concise strings without overhead of a function call or table lookup
    NC                 = "<orange>"          -- Numbers
    VC                 = "<dark_violet>"     -- Values (Boolean, etc.)
    EC                 = "<orange_red>"      -- Errors & Warnings
    DC                 = "<ansi_yellow>"     -- Derived or Calculated Values
    FC                 = "<maroon>"          -- Flags & Affects like 'Sanctuary'
    SC                 = "<cornflower_blue>" -- String Literals such as Room & Mob Names
    SYC                = "<ansi_magenta>"    -- System Messages (Client Status, etc.)
    RC                 = "<reset>"           -- Reset Color (do not use </reset> or </color> syntax)

    -- Used when updating the pcStatus table to decide whether to send a warning about someone's health
    -- A warning will be sent if the health falls below low% or loses more than big% in a single update
    -- Make sure to align these values with the order of your party (same as in pcNames, etc.)
    healthMonitor      = {
      --[#] = {low%, big%}
      [1] = {20, 25},
      [2] = {80, 10},
      [3] = {80, 10},
      [4] = {25, 20},
    }

    -- Customize colors for your PCs; local for now 'cause it's only used to make the tags below
    local pcColors     = {
      "<medium_orchid>",
      "<medium_violet_red>",
      "<dark_violet>",
      "<dark_orange>",
    }

    -- Customized nametags for each player; primarily useful for warnings echoed to the info window
    pcTags             = {
      f "<reset>[{pcColors[1]}{pcNames[1]}<reset>]",
      f "<reset>[{pcColors[2]}{pcNames[2]}<reset>]",
      f "<reset>[{pcColors[3]}{pcNames[3]}<reset>]",
      f "<reset>[{pcColors[4]}{pcNames[4]}<reset>]",
    }

    -- Customize chat output colors
    messageColors      = {
      ["auction"] = "<navajo_white>",
      ["debug"]   = "<dodger_blue>",
      ["say"]     = "<cyan>",
      ["gossip"]  = "<chartreuse>",
      ["replies"] = "<pale_violet_red>",
      ["quest"]   = "<gold>",
      ["whisper"] = "<deep_pink>",
      ["honor"]   = "<orange_red>",
    }

    -- You can send these messages to the "Info" window with the showWarning function; this
    -- window belongs to session 1, so other sessions must raise eventWarn to pass warnings
    warningMessages    = {
      ["water"]     = "Needs <powder_blue>Water<reset>",
      ["mvs"]       = "Low <gold>Moves<reset>",
      ["food"]      = "Needs <olive_drab>Food<reset>",
      ["whacked"]   = "🩸 <medium_violet_red>.w.h.A.C.K.e.d.<reset>",
      ["switched"]  = "👿 Targeted",
      ["hp"]        = "🤕 Critical <tomato>HP<reset> ",
      ["exhausted"] = "👟 No Moves",
      ["norecall"]  = "🌀 !Out of Recalls! 🌀"
    }

    -- Critical warnings will play bloop.wav when sent.
    criticalWarnings   = {
      ["whacked"]   = true,
      ["exhausted"] = true,
      ["hp"]        = true,
      ["switched"]  = true,
      ["norecall"]  = true,
    }

    -- Customize your affect info to match the duration of your own buffs and desired colors & characters
    affectInfo         = {
      --["Darkness"]             = {duration = 10, color = "lavender_blush", char = "🌙"},
      ["Fireshield"]           = {duration = 5, color = "tomato", char = "🔥"},
      ["Sanctuary"]            = {duration = 10, color = "lavender_blush", char = "🌟"},
      ["Bless"]                = {duration = 6, color = "light_goldenrod", char = "🙏"},
      ["Fury"]                 = {duration = 2, color = "tomato", char = "😡"},
      ["Armor"]                = {duration = 24, color = "steel_blue", char = "🛡️"},
      ["Endure"]               = {duration = 24, color = "orange", char = "💪"},
      ["Protection from evil"] = {duration = 24, color = "gold", char = "🧿"},
      ["Achilles' last stand"] = {duration = 4, color = "medium_violet_red", char = "⚔️"}
    }
    -- Colors to use in the Party Console labels to indicate duration of affects
    affectDuration     = {
      ['high'] = "YellowGreen",
      ['med']  = "Orange",
      ['low']  = "Crimson",
    }
    -- These keywords are captured in trigger phrases to indicate which spell has been applied or removed.
    -- They are used to map to the spell name in applyAffect() and removeAffect().
    affectKeywords     = {
      ["glowing"]           = "Sanctuary",
      ["aura"]              = "Sanctuary",
      ["righteous"]         = "Bless",
      ["angry"]             = "Fury",
      ["calm"]              = "Fury",
      ["protecting"]        = "Armor",
      ["protected"]         = "Armor",
      ["righteous feeling"] = "Protection from evil",
      ["circle of fire"]    = "Fireshield",
    }

    -- Affects that do not need to be tracked or displayed on the Party/Player Console (and don't print a warning)
    IGNORED_AFFECTS    = {
      ['Strength'] = true,
      ['Invulnerability'] = true,
      ['Darkness'] = true,
      ["Achilles' last stand"] = true,
    }

    -- How many "steps" does the tick clock have (i.e., how many individual images make up the animation)
    TICK_STEPS         = 120

    -- Select which ANTI-FLAGS to include in stat output from eq/eq_db.lua
    -- Keep this updated w/ who you're trying to equip so you don't get confused about 'missing' flags
    function customizeAntiString( antis )
      local includedFlags = {
        ["!NEU"] = true,
        ["!GOO"] = true,
        ["!EVI"] = true,
        ["!MU"] = true,
        ["!CL"] = true,
        ["!CO"] = true,
        ["!BA"] = true,
        ["!WA"] = true,
        ["!AP"] = true,
        ["!TH"] = true,
        ["!FEM"] = true,
        ["!MAL"] = true,
        ["!RENT"] = true
      }

      -- Match & replace any flag that isn't in the included table
      antis = antis:gsub( "!%w+", function ( flag )
        if not includedFlags[flag] then
          return ""
        else
          return flag
        end
      end )

      -- Trim and condense
      return antis:gsub( "%s+", " " ):trim()
    end

    -- Table & following function sets the initial state for Triggers, Keys, and Aliases; localizing this
    -- should allow for some personalization (e.g., if you don't want Map-related stuff enabled by default).
    -- This list does not need to be exhaustive, but it should include anything you want to guarantee is in
    -- a certain state at startup (e.g., this is a good time to make sure temporary triggers start disabled).
    local initialReactionState = {
      -- ++ON for everyone
      {name = "PC Login",                  type = "trigger", state = true,  scope = 'All'},
      {name = "Total Recall (wor)",        type = "alias",   state = true,  scope = 'All'},
      {name = "All Rec Recall (rr)",       type = "alias",   state = true,  scope = 'All'},
      -- --OFF for everyone
      {name = "hunger",                    type = "trigger", state = false, scope = 'All'},
      {name = "thirst",                    type = "trigger", state = false, scope = 'All'},
      {name = "fountain",                  type = "trigger", state = false, scope = 'All'},
      {name = "Group XP",                  type = "trigger", state = false, scope = 'All'},
      {name = "Solo XP",                   type = "trigger", state = false, scope = 'All'},
      {name = "EQ Stats",                  type = "trigger", state = false, scope = 'All'},
      {name = "Missing EQ",                type = "trigger", state = false, scope = 'All'},
      {name = "Parse Score",               type = "trigger", state = false, scope = 'All'},
      {name = "List Fonts (lfonts)",       type = "alias",   state = false, scope = 'All'},
      {name = "Print Variables (pvars)",   type = "alias",   state = false, scope = 'All'},
      {name = "Tank Condition (automira)", type = "trigger", state = false, scope = 'All'},
      -- ++ON for Main session
      {name = "Main Format",               type = "trigger", state = true,  scope = 'Main'},
      {name = "gather",                    type = "trigger", state = true,  scope = 'Main'},
      {name = "map",                       type = "trigger", state = true,  scope = 'Main'},
      {name = "Movement (Map)",            type = "key",     state = true,  scope = 'Main'},
      -- --OFF for Main session
      {name = "Alt Gags",                  type = "trigger", state = false, scope = 'Main'},
      -- ++ON for Alts
      {name = "Movement (Raw)",            type = "key",     state = true,  scope = 'Alts'},
      {name = "Alt Gags",                  type = "trigger", state = true,  scope = 'Alts'},
      -- --OFF for Alts
      {name = "status",                    type = "trigger", state = false, scope = 'Alts'},
      {name = "gather",                    type = "trigger", state = false, scope = 'Alts'},
      {name = "Main Format",               type = "trigger", state = false, scope = 'Alts'},
      {name = "map",                       type = "trigger", state = false, scope = 'Alts'},
      {name = "Movement (Map)",            type = "key",     state = false, scope = 'Alts'},
    }

    local function initializeReactions()
      cecho( "\nInitial Trigger, Alias, and Key states\n" )
      cecho( "______________________________________\n" )

      local function formatReactionState( reaction, isEnabled )
        local typeTag = reaction.type == "trigger" and "<hot_pink>T<reset>" or
            (reaction.type == "key" and "<dark_turquoise>K<reset>" or "<ansi_yellow>A<reset>")
        local nameState = isEnabled and f "<olive_drab>+{reaction.name}<reset>" or f "<brown>-{reaction.name}<reset>"
        return string.format( "%-5s %-5s %-35s", reaction.scope, typeTag, nameState )
      end

      for _, reaction in ipairs( initialReactionState ) do
        if reaction.scope == "All" or (reaction.scope == "Main" and SESSION == 1) or (reaction.scope == "Alts" and SESSION ~= 1) then
          local isEnabled = false
          if reaction.type == "trigger" then
            if reaction.state then
              enableTrigger( reaction.name )
              isEnabled = true
            else
              disableTrigger( reaction.name )
            end
          elseif reaction.type == "alias" then
            if reaction.state then
              enableAlias( reaction.name )
              isEnabled = true
            else
              disableAlias( reaction.name )
            end
          elseif reaction.type == "key" then
            if reaction.state then
              enableKey( reaction.name )
              isEnabled = true
            else
              disableKey( reaction.name )
            end
          end
          local formattedReaction = formatReactionState( reaction, isEnabled )
          cecho( f "\n{formattedReaction}" )
        end
      end
    end

    initializeReactions()
  else
    -- Username exists, but no corresponding configuration settings were found
    cecho( f '\n<orange_red>No configuration<reset> for {USERNAME} in config_gizmo.lua' )
  end
  cecho( f "\n<orange_red>REMINDER:<reset> status triggers disabled in Alt sessions temporarily" )
end

configByUsername()
SESSION_NAME      = getProfileName()
SESSION           = getProfileTabNumber()
pcName            = pcNames[SESSION]
container         = containers[SESSION]

-- [TODO] An obviously incomplete set of variables that get used when grouping with
-- different parties to set things like tank, co-pummeler, etc.
backupMira        = false
gtank             = "Troll"

-- Default query mode for the item database; modifies itemQueryAppend behavior
itemQueryMode     = 1

-- Used to hold IDs of temporary triggers so they can be disabled subsequently
temporaryTriggers = {}

-- Neutral color for "ui" output like spacer lines, separators, etc.
uiColor           = "<light_steel_blue>"

-- Mob short descriptions that start with articles end up lowercase in some contexts;
-- this table helps map between the two.
ARTICLES          = {"A ", "An ", "The "}

-- Table of constants to be used when highlighting player and enemy conditions in game
CONDITION_COLORS  = {
  ["full"]     = {125, 200, 25},  -- Vibrant Green
  ["fine"]     = {175, 220, 120}, -- Lighter Green
  ["good"]     = {220, 240, 100}, -- Yellow-Green
  ["fair"]     = {240, 240, 85},  -- Yellow
  ["wounded"]  = {255, 195, 0},   -- Orange
  ["bad"]      = {255, 150, 0},   -- Darker Orange
  ["awful"]    = {255, 100, 0},   -- Red-Orange
  ["bleeding"] = {200, 50, 25}    -- Red
}

local DG          = "<dim_grey>"
local MSB         = "<medium_slate_blue>"
local OB          = "<olive_drab>"
local DK          = "<dark_khaki>"
local FB          = "<firebrick>"

function saveCustomDataTables()
  table.save( f '{HOME_PATH}/gizmo/map/data/player_containers.lua', PlayerContainers )
  table.save( f '{HOME_PATH}/gizmo/map/data/potion_affects.lua', PotionAffects )
  table.save( f '{HOME_PATH}/gizmo/map/data/desirable_items.lua', DesirableItems )
  table.save( f '{HOME_PATH}/gizmo/map/data/known_players.lua', KnownPlayers )
end

function loadCustomDataTables()
  table.load( f '{HOME_PATH}/gizmo/map/data/player_containers.lua', PlayerContainers )
  table.load( f '{HOME_PATH}/gizmo/map/data/potion_affects.lua', PotionAffects )
  table.load( f '{HOME_PATH}/gizmo/map/data/desirable_items.lua', DesirableItems )
  table.load( f '{HOME_PATH}/gizmo/map/data/known_players.lua', KnownPlayers )
end

function printCustomDataTable( tbl )
  for k, v in pairs( tbl ) do
    cecho( f "\n<royal_blue>{k}<reset> = <violet>{v}<reset>" )
  end
end

KnownPlayers = KnownPlayers or {}
function addKnownPlayer( playerName )
  iout( f " Player name: {playerName}" )
  cecho( f [[  + Adding <deep_pink>{pcName}<reset> to {SC}KnownPlayers<reset> +]] )
  KnownPlayers[playerName] = true
  table.save( f '{HOME_PATH}/gizmo/map/data/known_players.lua', KnownPlayers )
end

PotionAffects = PotionAffects or {}
function addPotionAffect( potionName, affectString )
  cecho( f [[ + Adding {SC}{potionName}{RC} = {SC}{affectString}{RC} +]] )
  PotionAffects[potionName] = affectString
  table.save( f '{HOME_PATH}/gizmo/map/data/potion_affects.lua', PotionAffects )
end

-- When a potion is seen in-game, append its affect data to the end of the line
function appendPotionAffect()
  local obj = trim( matches[2] )
  local vr, meo = "<violet_red>", "<medium_orchid>"
  if PotionAffects[obj] then
    local aff = PotionAffects[obj]
    aff = f " {vr}[{meo}{aff}{vr}]{RC}"
    cecho( aff )
  end
end

-- A one-time function to clean up potion affect strings; for each potion in the PotionAffects table this
-- function should remove the leading "(" character and the trailing ")" character from each string in the table
function cleanPotionAffects()
  for potion, affect in pairs( PotionAffects ) do
    local cleanAffect = affect:gsub( "%(", "" ):gsub( "%)", "" )
    PotionAffects[potion] = cleanAffect
  end
  table.save( f '{HOME_PATH}/gizmo/map/data/potion_affects.lua', PotionAffects )
end

PlayerContainers, PotionAffects, DesirableItems, KnownPlayers = {}, {}, {}, {}
loadCustomDataTables()

TimeCheck = nil

function parseDateString( dateString )
  local pattern = "(%a+) (%a+) (%d+) (%d+):(%d+):(%d+) (%d+) (%a+)"
  local _, _, month, day, hour, min, sec, year, tz = dateString:find( pattern )
  local monthTable = {
    Jan = 1,
    Feb = 2,
    Mar = 3,
    Apr = 4,
    May = 5,
    Jun = 6,
    Jul = 7,
    Aug = 8,
    Sep = 9,
    Oct = 10,
    Nov = 11,
    Dec = 12
  }
  local timeTable = {
    year = tonumber( year ),
    month = monthTable[month],
    day = tonumber( day ),
    hour = tonumber( hour ),
    min = tonumber( min ),
    sec = tonumber( sec )
  }
  return os.time( timeTable )
end

function timeSince( newTime )
  local newTimeSec = parseDateString( newTime )
  local elapsedTime = 0

  if TimeCheck == nil then
    TimeCheck = newTimeSec
  else
    elapsedTime = os.difftime( newTimeSec, TimeCheck )
    TimeCheck = newTimeSec
  end
  local sinceString = f "(Elapsed: {NC}{elapsedTime}{RC}s)"
  cout( sinceString )
end
