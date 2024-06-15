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
        ["!NEU"] = false,
        ["!GOO"] = false,
        ["!EVI"] = false,
        ["!MU"] = false,
        ["!CL"] = false,
        ["!CO"] = false,
        ["!BA"] = false,
        ["!WA"] = false,
        ["!AP"] = false,
        ["!TH"] = false,
        ["!FEM"] = false,
        ["!MAL"] = false,
        ["!RENT"] = false
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

-- A list of Alts; used by filter triggers to limit spam from Alts
ALT_PC            = {
  ["Nadja"]    = true,
  ["Blain"]    = true,
  ["Cait"]     = true,
  ["Glory"]    = true,
  ["Hocken"]   = true,
  ["Drago"]    = true,
  ["Huck"]     = true,
  ["Mac"]      = true,
  ["Lemon"]    = true,
  ["Iuck"]     = true,
  ["Dillon"]   = true,
  ["Jock"]     = true,
  ["Nordberg"] = true,
  ["Laszlo"]   = true,
  ["Youke"]    = true,
  ["Ludwig"]   = true,
  ["Chaliz"]   = true,
  ["Nandor"]   = true,
  ["Acute"]    = true,
  ["Cyrus"]    = true,
  ["Topaz"]    = true,
  ["Anima"]    = true,
  ["Poncho"]   = true,
  ["Anna"]     = true,
  ["Elbryan"]  = true,
  ["Qxuilur"]  = true,
}

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

KnownPlayers      = {
  ["Jubei"]          = true,
  ["Crest"]          = true,
  ["Cigarrillo"]     = true,
  ["Aiden"]          = true,
  ["Buffer"]         = true,
  ["Tumble"]         = true,
  ["Damage"]         = true,
  ["Health"]         = true,
  ["Cellulite"]      = true,
  ["Gandalv"]        = true,
  ["Tempus"]         = true,
  ["Logain"]         = true,
  ["Fitz"]           = true,
  ["Gaea"]           = true,
  ["Rogue"]          = true,
  ["Ajathar"]        = true,
  ["Terran"]         = true,
  ["Acapela"]        = true,
  ["Stp"]            = true,
  ["Gus"]            = true,
  ["Evo"]            = true,
  ["Tek"]            = true,
  ["Ranyk"]          = true,
  ["Attis"]          = true,
  ["Tormund"]        = true,
  ["Wolgast"]        = true,
  ["Connolly"]       = true,
  ["Quark"]          = true,
  ["Lepton"]         = true,
  ["Muon"]           = true,
  ["Boson"]          = true,
  ["Blain"]          = true,
  ["Dillon"]         = true,
  ["Mac"]            = true,
  ["Billy"]          = true,
  ["Organ"]          = true,
  ["Trachea"]        = true,
  ["Digest"]         = true,
  ["Germ"]           = true,
  ["Glory"]          = true,
  ["Anima"]          = true,
  ["Cyrus"]          = true,
  ["Vassago"]        = true,
  ["Youko"]          = true,
  ["Drago"]          = true,
  ["Manwe"]          = true,
  ["Turambar"]       = true,
  ["Finarfin"]       = true,
  ["Irelia"]         = true,
  ["Nandor"]         = true,
  ["Laszlo"]         = true,
  ["Nadja"]          = true,
  ["Colin"]          = true,
  ["Elbryan"]        = true,
  ["Qxuilur"]        = true,
  ["Ace"]            = true,
  ["Reedus"]         = true,
  ["Rax"]            = true,
  ["Sly"]            = true,
  ["Tzu"]            = true,
  ["Pastor"]         = true,
  ["Jacob"]          = true,
  ["Topaz"]          = true,
  ["Caitlin"]        = true,
  ["Saben"]          = true,
  ["Chaliz"]         = true,
  ["Acute"]          = true,
  ["Bangle"]         = true,
  ["Opal"]           = true,
  ["Turil"]          = true,
  ["Charneus"]       = true,
  ["Alluran"]        = true,
  ["Avernus"]        = true,
  ["Killian"]        = true,
  ["Nikki"]          = true,
  ["Bongo"]          = true,
  ["Youke"]          = true,
  ["Viron"]          = true,
  ["Youky"]          = true,
  ["Anna"]           = true,
  ["Celion"]         = true,
  ["Harlae"]         = true,
  ["Borsoi"]         = true,
  ["Lever"]          = true,
  ["Strap"]          = true,
  ["Regret"]         = true,
  ["Kaylee"]         = true,
  ["ThunderCat"]     = true,
  ["Codee"]          = true,
  ["Aliya"]          = true,
  ["Turbo"]          = true,
  ["Nicolav"]        = true,
  ["Presto"]         = true,
  ["Sartre"]         = true,
  ["Camma"]          = true,
  ["Salieri"]        = true,
  ["Drift"]          = true,
  ["Blackjack"]      = true,
  ["Tempest"]        = true,
  ["Cyclone"]        = true,
  ["Barrage"]        = true,
  ["Torment"]        = true,
  ["Tree"]           = true,
  ["Poncho"]         = true,
  ["Liono"]          = true,
  ["Tygra"]          = true,
  ["Panthro"]        = true,
  ["Cheetara"]       = true,
  ["Jaga"]           = true,
  ["WilyKat"]        = true,
  ["WilyKit"]        = true,
  ["Spellfire"]      = true,
  ["Tissue"]         = true,
  ["Intestine"]      = true,
  ["Raw"]            = true,
  ["Banget"]         = true,
  ["Padre"]          = true,
  ["Izaur"]          = true,
  ["Nikolas"]        = true,
  ["Youku"]          = true,
  ["a shade minion"] = true,
  ["a troll minion"] = true,
}

PlayerContainers  = {
  ["a plain brown parcel"]                  = true,
  ["a Swingin' Udder"]                      = true,
  ["a BMF wallet"]                          = true,
  ["the inner sarcophagus"]                 = true,
  ["a Vault of Lost war-cries (screaming)"] = true,
  ["a bag"]                                 = true,
  ["a large green sack"]                    = true,
  ["King Crotus' sarcophagus"]              = true,
  ["a Christmas Stocking"]                  = true,
  ["Cradle of the Forest"]                  = true,
  ["Legends Satchel"]                       = true,
  ["an explorer's backpack"]                = true,
  ["a black asbestos cloak"]                = true,
  ["The Library of Sin"]                    = true,
  ["The Shrine of The Prophets of Rage"]    = true,
  ["a Legends Satchel"]                     = true,
  ["a rift in space"]                       = true,
  ["the UYAM stocking"]                     = true,
}

DesiredItems      = {
  ["a flowing black cape"]                    = true,
  ["cloak of the fiend"]                      = true,
  ["a pair of chaos sleeves"]                 = true,
  ["armbands of hell"]                        = true,
  ["a Linen Bodice"]                          = true,
  ["a Reptilian Scaled Plate"]                = true,
  ["Boots of Harmony"]                        = true,
  ["Boots of the Outer Planes"]               = true,
  ["a Black Onyx Ring"]                       = true,
  ["a blood red ruby ring"]                   = true,
  ["an adamant ring encrusted with diamonds"] = true,
  ["ring of the soul eater"]                  = true,
  ["a Pair of Bloody gloves"]                 = true,
  ["the Gloves of Agony"]                     = true,
  ["the Gloves of the Void"]                  = true,
  ["a drop of heart's blood"]                 = true,
  ["a malachite"]                             = true,
  ["a ships rutter"]                          = true,
  ["a Long Cloth Skirt"]                      = true,
  ["a pair of Zyca leg plates"]               = true,
  ["a spyglass"]                              = true,
  ["Fang of the Vadir"]                       = true,
  ["Lantern of the Outer Planes"]             = true,
  ["the Evil Globe of Hyless"]                = true,
  ["the Hand of Glory"]                       = true,
  ["the Medallion of Macabre"]                = true,
  ["the Necklace of Ancient Power"]           = true,
  ["a Plate from Ygaddrozil"]                 = true,
  ["a Shield of Festering Mortal Skins"]      = true,
  ["a spiked leather belt"]                   = true,
  ["Belt of Burnt Flesh"]                     = true,
  ["charred and bloody belt"]                 = true,
  ["desecrated belt of holy symbols"]         = true,
  ["a Fencing Foil"]                          = true,
  ["a mammoth's tusk"]                        = true,
  ["a Slender Dagger"]                        = true,
  ["the Barbed Fishhook"]                     = true,
  ["the Mace of Legend"]                      = true,
  ["a Flaming Bracelet"]                      = true,
  ["a Freezing Bracelet"]                     = true,
  ["Bracelet of the Outer Planes"]            = true,
}

local DG          = "<dim_grey>"
local MSB         = "<medium_slate_blue>"
local OB          = "<olive_drab>"
local DK          = "<dark_khaki>"
local FB          = "<firebrick>"

-- A global table of potion affects so we can see specific spell name/levels next
-- to potion names in game.
POTION_AFFECT     = {
  ["Some Sea Essence"]                 = f " {DG}(L30 tiny mana x2){RC}",
  ["a Pitcher Plant Potion"]           = f " {DG}(L33 lil miracle x2, vitality){RC}",
  ["a Frosty Potion"]                  = f " {DG}(L30 lesser mana){RC}",
  ["a jar of blackened blood"]         = f " {DG}(L45 lesser mana x2, strength){RC}",
  ["a vibrant white potion(humming)"]  = f " {DG}(L30 pfe, heal, bless){RC}",
  ["glowing potion(glowing)"]          = f " {DG}(L30 strength, heal, sanct){RC}",
  ["a Seawater Potion"]                = f " {DG}(L30 tiny mana){RC}",
  ["a swirling blue potion(glowing)"]  = f " {DG}(L30 pfe, strength, armor){RC}",
  ["a bright magenta potion(glowing)"] = f " {DG}(L30 armor, bless){RC}",
  ["a scroll of purification"]         = f " {DG}(L50 decurse, dispel evil, bless){RC}",
  ["a golden stick(glowing)"]          = f " {DG}(L30 miracle){RC}",
  ["a milky orange potion"]            = f " {DG}(L20 vitality, endure){RC}",
  ["a thick brew"]                     = f " {DG}(L50 lil miracle){RC}",
  ["a bloody brew"]                    = f " {DG}(L50 fury){RC}",
}
