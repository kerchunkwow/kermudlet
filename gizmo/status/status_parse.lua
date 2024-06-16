RecallDelay = false
StunDelay = StunDelay or false
-- Keep track of how long we've been out of combat so we can resume AutoPathing if it gets interrupted
TimeSinceCombat = TimeSinceCombat or 0
TimeLeftCombat = TimeLeftCombat or getStopWatchTime( "timer" )
TransferDelay = TransferDelay or false
function triggerParsePrompt()
  -- Parse & typecast current & maximum stat values from the prompt
  -- HP
  local hpc, hpm = tonumber( matches[2] ), tonumber( matches[3] )

  -- Calculate current health percentage
  local hpp = hpc / hpm
  local hpr, hpg, hpb = interpolateColor( FULL_HP_COLOR, EMPTY_HP_COLOR, hpp )
  selectString( matches[2], 1 )
  setFgColor( hpr, hpg, hpb )
  resetFormat()
  -- Mana
  local mnc, mnm      = tonumber( matches[4] ), tonumber( matches[5] )
  -- Calculate current mana percentage
  local mpp           = mnc / mnm
  local mpr, mpg, mpb = interpolateColor( FULL_MN_COLOR, EMPTY_MN_COLOR, mpp )

  local mvc, mvm      = tonumber( matches[6] ), tonumber( matches[7] )


  -- Look for tank & target conditions; they're only present in combat
  local tnk, trg    = matches[8], matches[9]

  -- Each session has a "local global" for its own combaorder tt state
  local wasInCombat = inCombat
  inCombat          = trg and #trg > 0

  -- Keep track of how long it's been since our last combat; for now this is most useful to resume AutoPathing
  local now         = getStopWatchTime( "timer" )
  if not inCombat then
    -- If we just left combat, mark the time so we can resume AutoPathing if needed
    if wasInCombat then
      TimeSinceCombat = 0
      TimeLeftCombat = now
    else
      TimeSinceCombat = now - TimeLeftCombat
      -- If we've been out of combat for 2 minutes and we're AutoPathing, something probably interrupted our
      -- loop; try and resume with a lookCheck()
      if (TimeSinceCombat > 120) and AutoPathing then
        TimeSinceCombat = 0
        lookCheck()
      end
    end
  end
  RecallDeathwalkTimer = RecallDeathwalkTimer or nil
  RecallTrollTimer     = RecallTrollTimer or nil
  RecallShadeTimer     = RecallShadeTimer or nil
  RecallSacrificeTimer = RecallSacrificeTimer or nil
  StunDelayTimer       = StunDelayTimer or nil
  if inCombat then
    -- Highlight tank condition on the prompt line for quick visual distinction
    if tnk then highlightCondition( tnk ) end
    -- Check for low health conditions of both tank and ourselves; recall in emergencies
    local tankDying = (tnk == 'bad' or tnk == 'awful' or tnk == 'bleeding')
    local tankHurt = (tnk == 'fair' or tnk == 'wounded')
    local meDying = (hpp < 0.50)
    if (tankDying or meDying) and not RecallDelay and not IncapDelay then
      RecallDelay = true
      tempTimer( 3, function () RecallDelay = false end )
      triggerEmergency()
    elseif tankHurt and not TransferDelay and not IncapDelay then
      TransferDelay = true
      tempTimer( 6, function () TransferDelay = false end )
      send( 'order nymph transfer health troll', true )
    end
    -- If we're in combat and our Troll tank is injured (below 'fine' condition) and not defending, swap to defending
    -- Skip during incapacitate delay or if we're already attempting to swap modes
    if not IncapDelay and not TrollSwapping and tnk and (tnk ~= "" and tnk ~= "full" and tnk ~= "fine") and TrollMode ~= "defend" then
      aliasTrollDefend()
      -- Otherwise, when we're trying to stun, sing our stun song periodically if we're not starting/ending combat
    elseif not IncapDelay and AutoStunning and trg and (trg ~= "" and trg ~= "bleeding" and trg ~= "fine") and not StunDelay then
      StunDelay = true
      StunDelayTimer = tempTimer( 60, function () StunDelay = false end )
      --guaranteeSong( [[where]], [[you ask yourself]] )
      expandAlias( 'te' )
    end
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
  local gld        = ""

  -- At max level, chars don't have the "exp to next level" line so swap it for gold value which moves up a line
  if not multimatches[9] then
    gld = exl
    exl = nil
  else
    gld = string.gsub( multimatches[9][2], ",", "" )
  end
  exp = tonumber( exp )
  exh = tonumber( exh )
  if exl then exl = tonumber( exl ) end
  gld = tonumber( gld )

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
