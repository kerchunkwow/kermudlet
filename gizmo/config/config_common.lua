cecho( f '\n  <coral>config_common.lua<reset>: define globals & tables shared by all sessions' )

-- Neutral color for "ui" output like spacer lines, separators, etc.
ui_color           = "<light_steel_blue>"

-- Update for your players; make sure pc_names and short_names are in the same order as your Mudlet tabs; these
-- will define your session command aliases and help pass messages between sessions.
pc_names           = {
  "Colin",
  "Nadja",
  "Laszlo",
  "Nandor",
}
myself             = pc_names[session]
short_names        = {
  "col",
  "nad",
  "las",
  "nan",
}
session_numbers    = {
  [f "{short_names[1]}"] = "1",
  [f "{short_names[2]}"] = "2",
  [f "{short_names[3]}"] = "3",
  [f "{short_names[4]}"] = "4",
}

-- If you want to be able to send aliases between sessions, you must add them to this table so the session_command
-- function will use expandAlias() instead of send().
isAlias            = {
  ["rp"] = true,
  ["sim"] = true,
  ["lua"] = true,
  ["cls"] = true,
}

-- Custom colors and nametags for your PCs; used for highlighted messages
pc_colors          = {
  "<cornflower_blue>",
  "<medium_violet_red>",
  "<dark_violet>",
  "<dark_orange>",
}
my_color           = pc_colors[session]
pc_tags            = {
  f "<reset>[{pc_colors[1]}{pc_names[1] }<reset>]",
  f "<reset>[{pc_colors[2]}{pc_names[2] }<reset>]",
  f "<reset>[{pc_colors[3]}{pc_names[3]}<reset>]",
  f "<reset>[{pc_colors[4]}{pc_names[4]}<reset>]",
}
my_tag             = pc_tags[session]

-- Custom colors for in-game chat channels for the Chat window
msg_colors         = {
  ["auction"] = "<navajo_white>",
  ["debug"]   = "<dodger_blue>",
  ["say"]     = "<cyan>",
  ["gossip"]  = "<chartreuse>",
  ["replies"] = "<pale_violet_red>",
  ["quest"]   = "<gold>",
  ["whisper"] = "<deep_pink>",
}

-- You can send these messages to the "Info" window with the show_warning function; this
-- window belongs to session 1, so other sessions must raise eventWarn to pass warnings
warning_messages   = {
  ["water"]     = "Needs a <light_sky_blue>water<reset> refill!",
  ["mvs"]       = "Getting low on <dark_goldenrod>moves<reset>.",
  ["food"]      = "🍖 Needs more <yellow_green>food<reset>!",
  ["whacked"]   = "I just got <medium_violet_red>whACKed<reset>!",
  ["switched"]  = "Mob just <dark_violet>switched<reset> to me!",
  ["hp"]        = "Critical <orange_red>HP<reset>!",
  ["exhausted"] = "I'm <gold>exhausted<reset>!",
}
-- Critical warnings will play bloop.wav when sent.
critical_warnings  = {
  ["whacked"]   = true,
  ["exhausted"] = true,
  ["hp"]        = true,
  ["switched"]  = true,
}

-- Keywords to look for in output that indicate when spell status changes
affectKeywords     = {
  ["glowing"]    = "Sanctuary",
  ["aura"]       = "Sanctuary",
  ["righteous"]  = "Bless",
  ["angry"]      = "Fury",
  ["calm"]       = "Fury",
  ["protecting"] = "Armor",
  ["protected"]  = "Armor",
}
-- Not used just yet, but plan to use this in the future to gag output from non-main players
alt_pcs            = {
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
}

-- For now, only used to simulate prompt output for testing purposes; will probably come in handy later
combat_conditions  = {
  "full",
  "fine",
  "good",
  "fair",
  "wounded",
  "bad",
  "awful",
  "bleeding",
}

-- Items to ignore when checking to see whether something has been added to the database;
-- this is going to get way too long and needs another solution eventually.
ignored_items      = {
  ["a pair of dace"]                   = true,
  ["the trust flag"]                   = true,
  ["a bread"]                          = true,
  ["a waterskin"]                      = true,
  ["glowing potion"]                   = true,
  ["transparent potion"]               = true,
  ["a yellow potion of see invisible"] = true,
  ["a snowball"]                       = true,
  ["a golden goblet"]                  = true,
  ["a scroll of recall"]               = true,
  ["an olive branch"]                  = true,
  ["a small ball of Labdanum resin"]   = true,
  ["a raft"]                           = true,
  ["a Seawater Potion"]                = true,
  ["a bag"]                            = true,
  ["a bottle of red potion"]           = true,
  ["a pouch of irridescent pollen"]    = true,
  ["a Frosty Potion"]                  = true,
  ["a bloody brew"]                    = true,
  ["a strong-smelling brew"]           = true,
  ["a five cheesecake chit"]           = true,
  ["a five brownie chit"]              = true,
  ["a milky orange potion"]            = true,
  ["a small ice opal"]                 = true,
  ["a Christmas Stocking"]             = true,
}

-- Initializing some empty globals
pc_effects         = {}
temporary_triggers = {}

-- A table for tracking spell effects and their duration
pc_effects         = {}

if session == 1 then container = "stocking" else container = "bag" end
waterskin       = "waterskin"
food            = "bread"

new_room        = true
my_room         = "The Bucklodge"

casting_delayed = false

miracond        = "bad"
warning_delayed = false
backup_mira     = false

gtank           = "Kevin"

-- Initial trigger states
enableTrigger( "PC Login" )
enableTrigger( "fountain" )
disableTrigger( "Parse Score" )
disableTrigger( "Group Parser" )

-- Every session listens for "event_session_all" in addition to their own "event_command_#" event.
registerAnonymousEventHandler( [[event_command_all]], [[sessionCommand]] )
registerAnonymousEventHandler( f [[event_command_{session}]], [[sessionCommand]] )

-- Disable Aliases in the "Development Tools" folder
disableAlias( "Devlopment Tools" )
disableAlias( "List Fonts (listfonts)" )
disableAlias( "Print Variables (printvars)" )
disableAlias( "Simulate Group (simgroup)" )
disableAlias( "Simulate Score (simsc)" )
disableAlias( "Simulate Prompt (rp)" )
disableAlias( "Create Group Console (cgc)" )
