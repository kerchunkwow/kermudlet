pummelMode = pummelMode or false
defendMode = defendMode or false
wailMode = wailMode or false
function triggerParsePrompt()
  -- Parse & typecast current & maximum stat values from the prompt
  -- HP
  local hpc, hpm = tonumber( matches[2] ), tonumber( matches[3] )


  -- Mana
  local mnc, mnm = tonumber( matches[4] ), tonumber( matches[5] )
  -- Moves
  local mvc, mvm = tonumber( matches[6] ), tonumber( matches[7] )

  -- Look for tank & target conditions; they're only present in combat
  local tnk, trg = matches[8], matches[9]

  -- Each session has a "local global" for its own combaorder tt state
  inCombat = trg and #trg > 0

  -- Temporary emergency egress logic
  if inCombat then
    -- Calculate current health percentage
    local hpp = hpc / hpm
    -- Calculate amount of health lost since last prompt
    local hpl = pcStatus[1]["currentHP"] - hpc
    if hpp < 0.4 or hpl > 500 then
      send( 'recite recall' )
      send( 'flee' )
      send( 'order troll recall' )
    end
  end
  if inCombat and wailMode and not wailDelay then
    wailDelay = true
    send( 'wail', false )
    wailTimer = tempTimer( 3, [[wailDelay = false]] )
  end
  -- The main session can compare directly against the master pcStatus table; Alt sessions use their local lastStatus table
  local currentStatus = (SESSION == 1) and pcStatus[1] or pcLastStatus

  local function statusNeedsUpdated()
    return hpc ~= currentStatus["currentHP"] or hpm ~= currentStatus["maxHP"] or
        mnc ~= currentStatus["currentMana"] or mnm ~= currentStatus["maxMana"] or
        mvc ~= currentStatus["currentMoves"] or mvm ~= currentStatus["maxMoves"] or
        tnk ~= currentStatus["tank"] or trg ~= currentStatus["target"]
  end
  -- If nothing has changed, exit early
  if not statusNeedsUpdated() then return end
  -- At least one value has changed since the last prompt, update the status table
  if SESSION == 1 then
    pcStatusPrompt( SESSION, hpc, hpm, mnc, mnm, mvc, mvm, tnk, trg )
  else
    raiseGlobalEvent( "event_pcStatusPrompt", SESSION, hpc, hpm, mnc, mnm, mvc, mvm, tnk, trg )
  end
end

-- Pull stats & data from a "score"; unlike prompt(s) this updates the maximum values
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

  -- From the main session, send parsed values directly to the status table, otherwise raise an event
  if SESSION == 1 then
    pcStatusScore( SESSION, dam, maxHP, hit, mnm, arm, mvm, mac, aln, exp, exh, exl, gld )
  else
    raiseGlobalEvent( "event_pcStatus_score", SESSION, dam, maxHP, hit, mnm, arm, mvm, mac, aln, exp, exh, exl, gld )
  end
end

-- Alt Sessions maintain a "last status" table locally so they can avoid sending redundant stats without checking
-- the main pcStatus table; assumption being that checking a local global table is more efficient than using
-- the event engine to retrieve stats.
local function initPCLastStatus()
  pcLastStatus                 = {}
  pcLastStatus["currentHP"]    = -1
  pcLastStatus["maxHP"]        = -1
  pcLastStatus["currentMana"]  = -1
  pcLastStatus["maxMana"]      = -1
  pcLastStatus["currentMoves"] = -1
  pcLastStatus["maxMoves"]     = -1
  pcLastStatus["tank"]         = "nil"
  pcLastStatus["target"]       = "nil"
end
if SESSION ~= 1 then initPCLastStatus() end
