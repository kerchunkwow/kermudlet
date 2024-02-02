-- Update status for the given pc with data captured from the prompt
function pcStatusPrompt( pc, hpc, hpm, mnc, mnm, mvc, mvm, tnk, trg )
  pc = tonumber( pc )

  local myStatus = pcStatus[pc]

  -- If our current or maximum health have changed, update as needed
  if myStatus["currentHP"] ~= hpc or myStatus["maxHP"] ~= hpm then
    local previousPercentHP = myStatus["percentHP"]

    -- Calculate new health percentage & make a label for gauge
    local percentHP         = (hpc / hpm) * 100
    local hp_label          = string.format( "%.1f%%", percentHP )

    -- Calculate change in health percentage
    local delta_p           = previousPercentHP - percentHP

    -- Update status table with new values
    myStatus["currentHP"]   = hpc
    myStatus["maxHP"]       = hpm
    myStatus["percentHP"]   = percentHP

    -- Update & label the HP gauge for this pc
    hpGauge[pc]:setValue( hpc, hpm, hp_label )

    -- If pc HP% is low or we took a big hit, send a warning & flash the gauge
    -- See: hp_monitor table in globals definition
    if (percentHP < 95) and checkHP( pc, percentHP, delta_p ) then
      hpGauge[pc]:flash( 0.5 )
      tempTimer( 0.75, f [[hpGauge[{pc}]:flash( 0.25 )]] )
    end
  end
  -- If our current or maximum mana have changed, update as needed
  if myStatus["currentMana"] ~= mnc or myStatus["maxMana"] ~= mnm then
    myStatus["currentMana"] = mnc
    myStatus["maxMana"]     = mnm
    manaGauge[pc]:setValue( mnc, mnm, mnc )

    -- Maybe put a check here to see if we're "spent"
  end
  if myStatus["currentMoves"] ~= mvc or myStatus["maxMoves"] ~= mvm then
    myStatus["currentMoves"] = mvc
    myStatus["maxMoves"]     = mvm
    movesGauge[pc]:setValue( mvc, mvm, mvc )

    -- Maybe put a check here to see if we're "spent"
  end
  -- When tank or target status changes, update our combat icon as needed
  if myStatus["target"] ~= trg or myStatus["tank"] ~= tnk then
    -- We have a target; we're in combat
    if trg and #trg > 1 then
      if tnk and #tnk > 1 then
        -- We also have a tank; use the standard indicator
        combatIcons[pc]:setBackgroundImage( [[C:/Dev/mud/mudlet/gizmo/assets/img/combat.png]] )
      else
        -- Target w/ no tank; use the primary target indicator
        combatIcons[pc]:setBackgroundImage( [[C:/Dev/mud/mudlet/gizmo/assets/img/targeted.png]] )

        -- If we're not Nandor and we lost our tank mid-combat and we didn't recently incap a target
        if pc ~= 4 and myStatus["tank"] and #myStatus["tank"] > 1 and not incap_delay then
          raiseEvent( "eventWarn", pc, "switched" )
        end
      end
      combatIcons[pc]:show()
    else
      combatIcons[pc]:hide()
    end
    -- Update the status table
    myStatus["target"] = trg
    myStatus["tank"]   = tnk
  end
end

-- Use the hp_monitor table to see if we should send a warning
function checkHP( pc, percentHP, delta_p )
  local low_hp, big_hit = healthMonitor[pc][1], healthMonitor[pc][2]

  if percentHP < low_hp then
    raiseEvent( "eventWarn", pc, "hp", percentHP )
    return true
  elseif delta_p > big_hit then
    raiseEvent( "eventWarn", pc, "whacked", delta_p )
    return true
  end
end

-- Update status for the given pc with data captured from secore; this is where we get the max values for hp/mn/mv
function pcStatusScore( pc, dam, maxHP, hit, mnm, arm, mvm, mac, aln, exp, exh, exl, gld )
  pcStatus[pc]["damageRoll"] = dam
  pcStatus[pc]["maxHP"]      = maxHP
  pcStatus[pc]["hitRoll"]    = hit
  pcStatus[pc]["maxMana"]    = mnm
  pcStatus[pc]["armor"]      = arm
  pcStatus[pc]["maxMoves"]   = mvm
  pcStatus[pc]["ac"]         = mac
  pcStatus[pc]["align"]      = aln
  pcStatus[pc]["exp"]        = exp
  pcStatus[pc]["expPerHour"] = exh
  pcStatus[pc]["expToLevel"] = exl
  pcStatus[pc]["gold"]       = gld
end

-- Update the room label for a pc
function pcStatusRoom( pc, room )
  pcStatus[pc]["room"] = room
  roomLabel[pc]:echo( room )
end

-- Create and default a table to hold status info for each pc
local function initPCStatusTable()
  pcStatus = {}

  for pc = 1, 4 do
    pcStatus[pc] = {

      currentHP    = 100 * pc,
      maxHP        = 100 * pc,
      percentHP    = 100 * pc,
      currentMana  = 100 * pc,
      maxMana      = 100 * pc,
      currentMoves = 100 * pc,
      maxMoves     = 100 * pc,
      tank         = "",
      target       = "",
      combat       = false,
      room         = "The Bucklodge",
      damageRoll   = 10 * pc,
      hitRoll      = 10 * pc,
      align        = 10 * pc,
      armor        = 10 * pc,
      ac           = 10 * pc,
      exp          = 10 * pc,
      expPerHour   = 10 * pc,
      expToLevel   = 10 * pc,
      gold         = 10 * pc,


    }
  end
end
initPCStatusTable()
