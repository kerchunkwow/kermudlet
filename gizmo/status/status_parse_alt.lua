---@diagnostic disable: cast-local-type

-- Parse prompt components and trigger an update if anything has changed; ignore maximum values
function triggerParsePrompt()
  -- Grab current HP, MANA, MOVE from prompt
  local hpc, mnc, mvc = tonumber( matches[2] ), tonumber( matches[3] ), tonumber( matches[4] )

  -- Tank & Target conditions (if present)
  local tnk, trg = matches[5], matches[6]

  -- Store a 'localilzed' combat status for convenience
  if trg and #trg > 0 then
    in_combat = true
  else
    in_combat = false
  end
  -- Compare new values to local prior values
  local needs_update = hpc ~= pcLastStatus["currentHP"] or
      mnc ~= pcLastStatus["currentMana"] or
      mvc ~= pcLastStatus["currentMoves"] or
      tnk ~= pcLastStatus["tank"] or
      trg ~= pcLastStatus["target"]

  -- Exit early if nothing has changed
  if not needs_update then
    return
  else
    -- If something changed, update the prior-value table
    pcLastStatus["currentHP"]    = hpc
    pcLastStatus["currentMana"]  = mnc
    pcLastStatus["currentMoves"] = mvc
    pcLastStatus["tank"]         = tnk
    pcLastStatus["target"]       = trg

    -- Then pass the updated values to the main session
    raiseGlobalEvent( "event_pcStatus_prompt", SESSION, hpc, mnc, mvc, tnk, trg )
  end
end

-- Parse score components and send them to the main session
function triggerParseScore()
  -- Just need this to fire once each time we 'score'
  disableTrigger( "Parse Score" )

  -- The multimatches table holds the values from score in a 2-dimensional array
  -- in the order they appear in score, so multimatches[l][n] = nth value on line l
  local dam, maxHP = multimatches[1][2], multimatches[1][3]
  local hit, mnm   = multimatches[2][2], multimatches[2][3]
  local arm, mvm   = multimatches[3][2], multimatches[3][3]
  local mac        = multimatches[4][2]
  local aln        = multimatches[5][2]

  -- For the numbers that get "big" we need to strip commas & convert to numbers
  local exp        = string.gsub( multimatches[6][2], ",", "" )
  local exh        = string.gsub( multimatches[7][2], ",", "" )
  local exl        = string.gsub( multimatches[8][2], ",", "" )
  local gld        = string.gsub( multimatches[9][2], ",", "" )

  exp              = tonumber( exp )
  exh              = tonumber( exh )
  exl              = tonumber( exl )
  gld              = tonumber( gld )

  raiseGlobalEvent( "event_pcStatus_score", SESSION, dam, maxHP, hit, mnm, arm, mvm, mac, aln, exp, exh, exl, gld )
end

-- Alt Sessions maintain a "last status" table locally so they can avoid sending redundant stats without checking
-- the main pcStatus table; assumption being that checking a local global table is more efficient than using
-- the event engine to retrieve stats.
local function initPCLastStatus()
  if SESSION == 1 then return end
  pcLastStatus                 = {}
  pcLastStatus["currentHP"]    = -1
  pcLastStatus["currentMana"]  = -1
  pcLastStatus["currentMoves"] = -1
  pcLastStatus["tank"]         = "nil"
  pcLastStatus["target"]       = "nil"
end
initPCLastStatus()
