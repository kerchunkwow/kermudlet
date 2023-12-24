cecho( f '\n\t<dark_violet>update_status.lua<reset>: maintains the pcStatus table w/ information about pc health, mana, etc.' )

-- Update status for the given pc with data captured from the prompt; we ignore "max" values from the prompt
-- since those change infrequently and would almost never result in inserts anyway
function pcStatusPrompt( pc, hpc, mnc, mvc, tnk, trg )
  pc = tonumber( pc )

  local myStatus = pcStatus[pc]

  if myStatus["currentHP"] ~= hpc then
    -- Grab current values for this pc
    local maxHP             = myStatus["maxHP"]
    local previousPercentHP = myStatus["percentHP"]

    -- Calculate new health percentage & make a label for gauge
    local percentHP         = (hpc / maxHP) * 100
    local hp_label          = string.format( "%.1f%%", percentHP )

    -- Calculate change in health percentage
    local delta_p           = previousPercentHP - percentHP

    -- Update status table with new values
    myStatus["currentHP"]   = hpc
    myStatus["percentHP"]   = percentHP

    -- Update & label the HP gauge for this pc
    hpGauge[pc]:setValue( hpc, maxHP, hp_label )

    -- If pc HP% is low or we took a big hit, send a warning & flash the gauge
    -- See: hp_monitor table in globals definition
    if (percentHP < 95) and checkHP( pc, percentHP, delta_p ) then
      hpGauge[pc]:flash( 0.5 )
      tempTimer( 0.75, f [[hpGauge[{pc}]:flash( 0.25 )]] )
    end
  end
  if myStatus["currentMana"] ~= mnc then
    myStatus["currentMana"] = mnc
    manaGauge[pc]:setValue( mnc, myStatus["maxMana"], mnc )

    -- Maybe put a check here to see if we're "spent"
  end
  if myStatus["currentMoves"] ~= mvc then
    myStatus["currentMoves"] = mvc
    movesGauge[pc]:setValue( mvc, myStatus["maxMoves"], mvc )

    -- Maybe put a check here to see if we're "spent"
  end
  -- When tank or target status changes, update our combat icon as needed
  if myStatus["target"] ~= trg or myStatus["tank"] ~= tnk then
    -- We have a target; we're in combat
    if trg and #trg > 1 then
      if tnk and #tnk > 1 then
        -- We also have a tank; use the standard indicator
        combatIcons[pc]:setBackgroundImage( [[C:/Gizmo/Mudlet/combat.png]] )
      else
        -- Target w/ no tank; use the primary target indicator
        combatIcons[pc]:setBackgroundImage( [[C:/Gizmo/Mudlet/targeted.png]] )

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
  local low_hp, big_hit = hp_monitor[pc][1], hp_monitor[pc][2]

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
function initPCStatusTable( pc_names )
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

function initPCLastStatus( pc_names )
  pc_last_status = {

    currentHP    = 0,
    currentMana  = 0,
    currentMoves = 0,
    tank         = 0,
    target       = 0,

  }
end

function printPCStatusTable()
  for pc = 1, 4 do
    local tnk = pcStatus[pc].tank or ""
    local trg = pcStatus[pc].trg or ""

    cecho( f [[<light_steel_blue>+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+]] .. "\n" )
    cecho( f [[<light_steel_blue>|<black>............<reset>Session #{pc}<black>..........<reset>|]] .. "\n" )
    cecho( f [[<light_steel_blue>+--------------------------------+]] .. "\n" )

    local hp_str     = f [[<yellow_green>{pcStatus[pc].currentHP}({pcStatus[pc].maxHP})  {pcStatus[pc].percentHP}%]]
    local mn_str     = f [[<steel_blue>{pcStatus[pc].currentMana}({pcStatus[pc].maxMana})]]
    local mv_str     = f [[<gold>{pcStatus[pc].currentMoves}({pcStatus[pc].maxMoves})]]
    local tank_str   = "<slate_blue>" .. tnk
    local target_str = "<violet_red>" .. trg

    cecho( f [[<light_steel_blue>|<black>................................<reset>]] .. "\n" )

    cecho( f [[<light_steel_blue>|<black>..<light_steel_blue>HP:<black>.....{hp_str}<black>........<reset>]] .. "\n" )
    cecho( f [[<light_steel_blue>|<black>..<light_steel_blue>MN:<black>.....{mn_str}<black>..............<reset>]] ..
      "\n" )
    cecho( f [[<light_steel_blue>|<black>..<light_steel_blue>MV:<black>.....{mv_str}<black>..............<reset>]] ..
      "\n" )
    cecho( f [[<light_steel_blue>|<black>..<light_steel_blue>Tank:<black>...{tank_str}<black>................<reset>]] ..
      "\n" )
    cecho( f [[<light_steel_blue>|<black>..<light_steel_blue>Target:<black>.{target_str}<black>................<reset>]] ..
      "\n" )

    cecho( f [[<light_steel_blue>|<black>................................<reset>]] .. "\n" )
    cecho( [[<light_steel_blue>+--------------------------------+]] .. "\n" )
  end
end
