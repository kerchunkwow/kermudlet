-- parse_alt.lua
-- These are the functions alternate sessions use to respond to parsing their prompts and score values;
-- use alternate definitions because they don't have direct access to the pcStatus table

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
  local needs_update = hpc ~= pc_last_status["currentHP"] or
      mnc ~= pc_last_status["currentMana"] or
      mvc ~= pc_last_status["currentMoves"] or
      tnk ~= pc_last_status["tank"] or
      trg ~= pc_last_status["target"]

  -- Exit early if nothing has changed
  if not needs_update then
    return
  else
    -- If something changed, update the prior-value table
    pc_last_status["currentHP"]    = hpc
    pc_last_status["currentMana"]  = mnc
    pc_last_status["currentMoves"] = mvc
    pc_last_status["tank"]         = tnk
    pc_last_status["target"]       = trg

    -- Then pass the updated values to the main session
    raiseGlobalEvent( "event_pcStatus_prompt", session, hpc, mnc, mvc, tnk, trg )
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

  raiseGlobalEvent( "event_pcStatus_score", session, dam, maxHP, hit, mnm, arm, mvm, mac, aln, exp, exh, exl, gld )
end
