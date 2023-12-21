-- The affects we want to track; set this to "save" in Variables to maintain durations between sessions
spellInfo      = spellInfo or {
  ["Bless"] = { duration = nil, cost = 22 },
  ["Armor"] = { duration = nil, cost = 22 },
  ["Levitate"] = { duration = nil, cost = nil },
  ["Haste"] = { duration = nil, cost = 90 },
}

-- "Up" and "down" messages for each affect
affectMessages = {
  ["You are Sanctuary."]                        = { affect = "Sanctuary", state = true },
  ["You are not Sanctuary."]                    = { affect = "Sanctuary", state = false },
  ["You feel righteous."]                       = { affect = "Bless", state = true },
  ["You feel less righteous."]                  = { affect = "Bless", state = false },
  ["You feel hasty."]                           = { affect = "Haste", state = true },
  ["You feel less hasty."]                      = { affect = "Haste", state = false },
  ["You feel someone protecting you."]          = { affect = "Armor", state = true },
  ["You are not Armor."]                        = { affect = "Armor", state = false },
  ["You are Levitate."]                         = { affect = "Levitate", state = true },
  ["You feel your feet on solid ground again."] = { affect = "Levitate", state = false },
}

-- Highlights for console output
affColor       = "<gold>"
upColor        = "<chartreuse>"
downColor      = "<firebrick>"
