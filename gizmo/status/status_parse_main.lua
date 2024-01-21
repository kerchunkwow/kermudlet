---@diagnostic disable: cast-local-type
cecho( f '\n  <coral>status_parse_main.lua<reset>: main session prompt parser, it can access the pcStatus table directly' )

-- Pull stats from the prompt and update status & status table
function triggerParsePrompt()
  -- Get current HP, MANA, MOVE from prompt
  local hpc, mnc, mvc = tonumber( matches[2] ), tonumber( matches[3] ), tonumber( matches[4] )

  -- Tank & Target conditions (if present)
  local tnk, trg = matches[5], matches[6]

  if (backup_mira and tnk ~= "full") and (gtank) then
    send( f "cast 'miracle' {gtank}" )
  end
  backup_mira = false

  -- Store a 'localilzed' combat status for convenience
  if trg and #trg > 0 then
    in_combat = true
  else
    in_combat = false
  end
  -- Main session can compare directly to the existing values in the master status table
  local needs_update = hpc ~= pcStatus[1]["currentHP"] or
      mnc ~= pcStatus[1]["currentMana"] or
      mvc ~= pcStatus[1]["currentMoves"] or
      tnk ~= pcStatus[1]["tank"] or
      trg ~= pcStatus[1]["target"]

  if not needs_update then
    return
  else
    pcStatusPrompt( session, hpc, mnc, mvc, tnk, trg )
  end
end

function triggerParseScore()
  -- Just need this to fire once each time we 'score'
  disableTrigger( "Parse Score" )

  -- The multimatches table holds the values from score in a 2-dimensional array
  -- in the order they appear in score, so multimatches[l][n] = nth value on line l
  local dam, maxHP = tonumber( multimatches[1][2] ), tonumber( multimatches[1][3] )
  local hit, mnm   = tonumber( multimatches[2][2] ), tonumber( multimatches[2][3] )
  local arm, mvm   = tonumber( multimatches[3][2] ), tonumber( multimatches[3][3] )
  local mac        = tonumber( multimatches[4][2] )
  local aln        = tonumber( multimatches[5][2] )

  -- For the numbers that get "big" we need to strip commas & convert to numbers
  local exp        = string.gsub( multimatches[6][2], ",", "" )
  local exh        = string.gsub( multimatches[7][2], ",", "" )
  local exl        = string.gsub( multimatches[8][2], ",", "" )
  local gld        = string.gsub( multimatches[9][2], ",", "" )

  exp              = tonumber( exp )
  exh              = tonumber( exh )
  exl              = tonumber( exl )
  gld              = tonumber( gld )

  pcStatusScore( session, dam, maxHP, hit, mnm, arm, mvm, mac, aln, exp, exh, exl, gld )
end
