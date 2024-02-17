-- Create a local copy of this file named client_config.lua in this location; customize it to your
-- local environment and preference, and make sure it"s in your .gitignore so we don"t cross streams.
pcNames            = {"Colin", "Nadja", "Laszlo", "Nandor"}
containers         = {"stocking", "cradle", "cradle", "cradle"}
waterskin          = "waterskin"
food               = "bread"

-- These should be the abbreviations you use to issue commands to session windows; they're used by the
-- aliasSessionCommand function in config_events.lua to raise the event matching the desired session.
-- e.g., issuing 'col command' will raise event_command_1
sessionNumbers     = {
  ["col"] = 1, ["nad"] = 2, ["las"] = 3, ["nan"] = 4
}
sessionAliases     = {"col", "nad", "las", "nan"}

-- Using this table, define which spells are castable from specific player positions within your party;
-- use this table anywhere you need to select from among a set of possible casters (e.g., when rebuffing).
partySpells        = {
  ['vitality'] = {1, 2, 3}
}

-- Local customization options for GUI windows; expand this list for more GUI customizations later
-- These are only needed to create the GUI/console and will be nil'd in deleteConsoleStyles()
customChatFontFace = "Bitstream Vera Sans Mono"
customChatFontSize = 14
customInfoFontFace = "Bitstream Vera Sans Mono"
customInfoFontSize = 14
customChatWrap     = 60
customInfoWrap     = 60
customConsoleFonts = {
  ["label"]     = "Ebrima",
  ["gauge_sm"]  = "Bitstream Vera Sans Mono",
  ["gauge_lrg"] = "Montserrat",
  ["room"]      = "Consolas",
}
-- Used when updating the pcStatus table to decide whether to send a warning about someone's health
-- A warning will be sent if the health falls below low% or loses more than big% in a single update
-- Make sure to align these values with the order of your party (same as in pcNames, etc.)
healthMonitor      = {
  --[#] = {low%, big%}
  [1] = {50, 20},
  [2] = {80, 10},
  [3] = {80, 10},
  [4] = {25, 20},
}

-- Customize colors for your PCs; local for now 'cause it's only used to make the tags below
local pcColors     = {
  "<cornflower_blue>",
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
  ["norecall"]  = "🌀 Out of Recalls"
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
  ["Sanctuary"] = {duration = 7, color = "lavender_blush", char = "🌟"},
  ["Bless"]     = {duration = 6, color = "light_goldenrod", char = "🙏"},
  ["Fury"]      = {duration = 2, color = "tomato", char = "😡"},
  ["Armor"]     = {duration = 24, color = "steel_blue", char = "🛡️"},
  ["Endure"]    = {duration = 24, color = "orange", char = "💪"},
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
  ["glowing"]    = "Sanctuary",
  ["aura"]       = "Sanctuary",
  ["righteous"]  = "Bless",
  ["angry"]      = "Fury",
  ["calm"]       = "Fury",
  ["protecting"] = "Armor",
  ["protected"]  = "Armor",
}

-- Select which ANTI-FLAGS to include in stat output from eq/eq_db.lua
function customizeAntiString( antis )
  local includedFlags = {
    ["!EVI"] = true,
    ["!MU"] = true,
    ["!CL"] = true,
    ["!CO"] = true,
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
  -- ++ON for Main session
  {name = "Main Format",               type = "trigger", state = true,  scope = 'Main'},
  {name = "gather",                    type = "trigger", state = true,  scope = 'Main'},
  {name = "Tank Condition (automira)", type = "trigger", state = true,  scope = 'Main'},
  {name = "map",                       type = "trigger", state = true,  scope = 'Main'},
  {name = "Movement (Map)",            type = "key",     state = true,  scope = 'Main'},
  -- --OFF for Main session
  {name = "Alt Gags",                  type = "trigger", state = false, scope = 'Main'},
  -- ++ON for Alts
  {name = "Movement (Raw)",            type = "key",     state = true,  scope = 'Alts'},
  {name = "Alt Gags",                  type = "trigger", state = true,  scope = 'Alts'},
  -- --OFF for Alts
  {name = "gather",                    type = "trigger", state = false, scope = 'Alts'},
  {name = "Tank Condition (automira)", type = "trigger", state = false, scope = 'Alts'},
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

function aliasDoWield()
  expandAlias( "col gett crocodile", false )
  expandAlias( "col rem boots", false )
  expandAlias( "col wear crocodile", false )
  expandAlias( "col wield mace", false )
  expandAlias( "col rem crocodile", false )
  expandAlias( "nan gett crocodile", false )
  expandAlias( "nan rem boots", false )
  expandAlias( "nan wear crocodile", false )
  expandAlias( "nan wield mace", false )
  expandAlias( "nan rem crocodile", false )
  expandAlias( "nan putt crocodile", false )
end
