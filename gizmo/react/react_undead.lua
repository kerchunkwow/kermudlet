-- New module/file for reactions exclusive to Undead player characters

function useBeazor()
  -- Get our current health percentage
  local hpp = pcStatus[1]['currentHP'] / pcStatus[1]['maxHP']
  -- Get our current mana percentage
  local mpp = pcStatus[1]['currentMana'] / pcStatus[1]['maxMana']

  -- Health regeneration strategy
  if hpp < 0.93 and hpp > 0.75 then
    send( 'eat 2.beazor hp', false )
  elseif hpp <= 0.75 then
    send( 'eat 1.beazor hp', false )
  end
  -- Mana regeneration strategy
  if mpp < 0.93 and mpp > 0.75 then
    send( 'eat 2.beazor mana', false )
  elseif mpp <= 0.75 then
    send( 'eat 1.beazor mana', false )
  end
end

function equipMinion( minion )
  local minionGear                 = {}
  local light, held, weapon        = nil, nil, nil
  local wearMsg, lightMsg, holdMsg = nil, nil, nil
  local boat                       = 'waterwalking'

  if minion == 'troll' then
    light      = 'hand'
    held       = 'tooth'
    weapon     = 'cutlass'
    wearMsg    = 'wears a Rune Covered Breast Plate'
    lightMsg   = 'uses the Hand of Glory'
    holdMsg    = 'grabs the Tooth of Ygaddrozil'
    minionGear = {
      'tooth',      -- held,  +3dr +3hr
      'onyx',       -- ring   +3dr +3hr
      'onyx',       -- ring   +3dr +3hr
      'ancient',    -- neck   -10ac +15hp +2dr
      'ancient',    -- neck   -10ac +15hp +2dr
      'rune',       -- body   -38ac +2dr
      'mask',       -- head   -12ac +3int +3con
      'oaken',      -- legs   -10ac +10hp +2dr
      'crocodile',  -- feet   -10ac +2str +1dr
      'agony',      -- hands  +3dr +2hr
      'Serpentine', -- arms   -7ac +1dr +1hr
      'ygaddrozil', -- shield -15ac -50mn +3dr +PFE
      'Masoch',     -- about  -20ac +45mn +5hr
      'order',      -- belt,  -10ac +1dr +2hr
      'freezing',   -- wrist, +2dr +2hr
      'freezing',   -- wrist, +2dr +2hr
      'hand',       -- light, +4dr +2hr
      'cutlass',
    }
  elseif minion == 'shade' then
    light      = 'hand'
    held       = 'blood'
    weapon     = 'dagger'
    wearMsg    = [[wears the Tzeentch's Platemail]]
    lightMsg   = 'uses the Hand of Glory'
    holdMsg    = [[grabs a drop of heart's blood]]
    minionGear = {
      'tooth',      -- held,  +3dr +3hr
      'sapphire',   -- ring   +3dr +3hr
      'sapphire',   -- ring   +3dr +3hr
      'xot',        -- neck   -10ac +15hp +2dr
      'xot',        -- neck   -10ac +15hp +2dr
      'platemail',  -- body   -38ac +2dr
      'crown',      -- head   -12ac +3int +3con
      'bodice',     -- legs   -10ac +10hp +2dr
      'bracelet',   -- wrist, +2dr +2hr
      'bracelet',   -- wrist, +2dr +2hr
      'outer',      -- feet   -10ac +2str +1dr
      'agony',      -- hands  +3dr +2hr
      'silver',     -- arms   -7ac +1dr +1hr
      'ygaddrozil', -- shield -15ac -50mn +3dr +PFE
      'fiend',      -- about  -20ac +45mn +5hr
      'demon',      -- belt,  -10ac +1dr +2hr
      'hand',       -- light, +4dr +2hr
      'cutlass',
    }
  end
  local wearCmd  = f 'order {minion} wear all'
  local holdCmd  = f 'order {minion} hold {held}'
  local lightCmd = f 'order {minion} hold {light}'
  -- Give all of the items to the minion
  for i, item in ipairs( minionGear ) do
    send( f 'get {item} {container}', true )
    send( f 'give {item} {minion}', true )
  end
  -- Order 'wear all'
  sureCommand( wearCmd, wearMsg, 'stubbornly refuses' )
  -- Trigger on an arbitrary wear message to hold the holdable
  tempTrigger( wearMsg,
    function ()
      sureCommand( holdCmd, holdMsg, 'stubbornly refuses' )
    end, 1 )
  -- Trigger on the hold message to light the light
  tempTrigger( holdMsg,
    function ()
      sureCommand( lightCmd, lightMsg, 'stubbornly refuses' )
    end, 1 )
  -- Trigger on the light to give them a boat
  tempTrigger( lightMsg,
    function ()
      send( [[get ]] .. boat .. [[ ]] .. container, true )
      send( [[give ]] .. boat .. [[ ]] .. minion, true )
    end, 1 )
end

-- Safer "look/sacrifice" combination that verifies minions are present before offing them
function sacMinion( minion )
  -- The pattern to look for in the room; expand later for more minions
  local minionPattern = ""
  if minion == 'troll' then
    minionPattern = [[^A hulking troll lurches around, obeying its banshee master\.$]]
  end
  -- Kill any pre-existing triggers and set one for the sacrifice
  if sacTrigger then killTrigger( sacTrigger ) end
  sacTrigger = tempRegexTrigger( minionPattern, "doSac('" .. minion .. "')" )
  -- Now look for pattern in room
  send( 'look', false )
end

-- Execute the actual sacrifice
function doSac( minion )
  send( f 'sacrifice {minion}' )
  send( 'get all corpse' )
  killTrigger( sacTrigger )
  sacTrigger = nil
end

function triggerTargetArrived()
  if inCombat then
    iout( 'Target arrived at tick step: {NC}{tickStep}{RC}' )
    send( 'order troll rescue kaylee', false )
  end
end

function triggerTrollRescue()
  send( 'order troll rescue kaylee' )
end
