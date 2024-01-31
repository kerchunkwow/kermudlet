SESSION           = getProfileTabNumber()
pcName            = pcNames[SESSION]
container         = containers[SESSION]

-- [TODO] An obviously incomplete set of variables that get used when grouping with
-- different parties to set things like tank, co-pummeler, etc.
backupMira        = false
gtank             = "Kevin"

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
