-- New module/file for reactions exclusive to Undead player characters

TrollMode       = TrollMode or nil
RescueDelay     = false
TROLL_DMG       = [[crush]]

-- My minions
MINIONS         = {"troll", "shade", "nymph"}

-- Current index to keep track of whose turn it is to eat
CorpseIndex     = 1

TransferTrigger = TransferTrigger or nil
function orderTransferTroll()
  TransferTrigger = tempTrigger( [[stubbornly refuses]], function ()
    send( 'order nymph transfer health troll', true )
  end, 1 )
  tempTimer( 5, function ()
    killTrigger( TransferTrigger )
    TransferTrigger = nil
  end )
  send( 'order nymph transfer health troll', true )
end

-- Utilize the undead "beazor" to regenerate health and mana
function useBeazor()
  -- Get our current health percentage
  local hpp = pcStatus[1]['currentHP'] / pcStatus[1]['maxHP']
  -- Get our current mana percentage
  local mpp = pcStatus[1]['currentMana'] / pcStatus[1]['maxMana']

  -- Health regeneration strategy
  if hpp < 0.90 then send( 'eat beazor hp', false ) end
  -- Mana regeneration strategy
  if mpp < 0.90 then send( 'eat beazor mana', false ) end
end

PickTrigger = PickTrigger or nil
PickedTrigger = PickedTrigger or nil
function sharnPick( door )
  local pickCommand = f [[pick {door}]]
  if PickTrigger then
    killTrigger( PickTrigger )
    PickTrigger = nil
  end
  PickTrigger = tempTrigger( [[failed to pick]], function ()
    send( pickCommand, true )
  end )
  if not PickedTrigger then
    PickedTrigger = tempTrigger( [[quickly yields]], function ()
      send( 'rem sharn', true )
      send( 'wear agony', true )
      send( 'put sharn stocking', true )
    end, 1 )
  end
  send( 'rem agony', true )
  send( 'get sharn stocking', true )
  send( 'wear sharn', true )
  send( pickCommand, true )
end

-- Use a sequence of guaranteed commands to equip summoned minions with gear
function equipMinion( minion )
  minion                            = minion or trim( matches[2] )
  local minionGear                  = {}
  local holdCmd, lightCmd, wieldCmd = nil, nil, nil
  local boat                        = 'waterwalking'
  local gobletCmd                   = [[give goblet kaylee]]
  if minion == "nymph" then
    lightCmd   = 'hold hand'
    holdCmd    = 'hold drop'
    wieldCmd   = 'wield legend'
    minionGear = {
      "goblet",
      "hand",
      "eater",
      "eater",
      "xot",
      "xot",
      "reptilian",
      "idiocy",
      "oaken",
      "crocodile",
      "agony",
      "working",
      "lies",
      "fiend",
      "spiked",
      "freezing",
      "freezing",
      "legend",
      "drop",
    }
  elseif minion == 'troll' then
    lightCmd   = 'hold hand'
    holdCmd    = 'hold tooth'
    wieldCmd   = 'wield mace'
    minionGear = {
      "goblet",
      "hand",
      "onyx",
      "onyx",
      "claw",
      "claw",
      "rune",
      "idiocy",
      "oaken",
      "stone",
      "agony",
      "serpentine",
      "shield",
      "night",
      "order",
      "freezing",
      "freezing",
      "mace",
      "tooth",
    }
    send( f [[get 12 red {container}]] )
    send( f [[give 12 red troll]] )
  elseif minion == 'shade' then
    lightCmd   = 'hold fang'
    holdCmd    = 'hold sap'
    wieldCmd   = 'wield sickle'
    minionGear = {
      'goblet',
      "fang",
      "eater",
      "eater",
      "macabre",
      "macabre",
      "bodice",
      "helm",
      "zyca",
      "outer",
      "bloody",
      "hell",
      "shield",
      "fiend",
      "flesh",
      "outer",
      "outer",
      "sickle",
      "drop",
    }
    tempTrigger( [[shade minion wields]], function ()
      guaranteeOrder( minion, [[rem sap]], [[shade minion stops using]] )
      guaranteeOrder( minion, [[give sap kaylee]], [[gives you]] )
      guaranteeOrder( minion, [[hold drop]], MINION_HOLD )
    end, 1 )
  end
  -- Give all of the items to the minion
  for i, item in ipairs( minionGear ) do
    send( f 'get {item} {container}', true )
    send( f 'give {item} {minion}', true )
  end
  local getBoatCmd  = f [[get {boat} {container}]]
  local giveBoatCmd = f [[give {boat} {minion}]]
  -- Issue the orders to wear, wield, hold, and light

  tempTimer( 7, function ()
    guaranteeOrder( minion, [[wear all]], MINION_WEAR )
  end )
  tempTimer( 7.2, function ()
    guaranteeOrder( minion, holdCmd, MINION_HOLD )
  end )
  tempTimer( 7.4, function ()
    guaranteeOrder( minion, lightCmd, MINION_LIGHT )
  end )
  if wieldCmd then
    tempTimer( 7.6, function ()
      guaranteeOrder( minion, wieldCmd, MINION_WIELD )
    end )
  end
  tempTimer( 7.8, function ()
    guaranteeOrder( minion, gobletCmd, [[gives you]] )
    tempTrigger( [[gives you]], function ()
      send( getBoatCmd, true )
      send( giveBoatCmd, true )
    end, 1 )
  end )
end

-- Safer "look/sacrifice" combination that verifies minions are present before offing them
function sacMinion( minion )
  addTimedTrigger( 5, [[substring]], [[verify_sacrifice]], TROLL_PATTERN, [[sacrifice troll]], 1 )
  addTimedTrigger( 5, [[substring]], [[verify_sacrifice]], SHADE_PATTERN, [[sacrifice shade]], 1 )
end

-- Execute the actual sacrifice
function doSac( minion )
  send( f 'sacrifice {minion}', false )
  send( 'get all corpse', false )
  expandAlias( 'store' )
  send( 'get all corpse', false )
  killTrigger( sacTrigger )
  sacTrigger = nil
end

function triggerTargetArrived()
  if inCombat then
    iout( 'Target arrived at tick step: {NC}{tickStep}{RC}' )
    send( 'order troll rescue kaylee', false )
  end
end

-- Kill the specified target; called as an alias, the target will be in Mudlet's matches table,
-- otherwise we can pass a parameter.
function aliasKillCommand( target )
  markedTarget      = nil
  local killTarget  = matches[2] or target
  local killCmd     = f [[kill {killTarget}]]
  local killSuccess =
  [[(?:troll minion.*?\s(?:crush(?:es)?|hit(?:s)?|parries|dodges|mounts)|fails to hit a troll minion)]]
  guaranteeOrder( [[troll]], killCmd, killSuccess )
end

-- Use the global MINIONS table and CorpseIndex to make sure everyone gets a fair share
-- of yummy bodies to eat.
function orderEatCorpse()
  -- CorpseIndex determines whose turn it is to feast
  local minion = MINIONS[CorpseIndex]
  send( f [[order {minion} eat corpse]] )

  -- Increment CorpseIndex and return to the start of the list if we're past the end
  CorpseIndex = CorpseIndex + 1
  if CorpseIndex > #MINIONS then
    CorpseIndex = 1
  end
end

function aliasBansheeRecall()
  if AutoPathing then AutoPathing = false end
  if AutoLooking then AutoLooking = false end
  if AutoBuffing then AutoBuffing = false end
  if AutoStunning then AutoStunning = false end
  -- If we're fighting, we need to use a scroll; set temporary triggers in case we need
  -- to retrieve one from our container, and to verify that we retrieved a new one after
  -- we get home (if container is empty we get a warning).
  if inCombat then
    send( [[recall]], false )
  end
  -- In any case, we should return to the Shadowed Nexus and retrieve the minions
  guaranteeCast( 'death walk' )
  -- Regardless of how we got home, bring our minions back too
  tempTimer( 4, [[guaranteeCommand( TROLL_RECALL, TROLL_PATTERN, ORDER_FAIL, ORDER_ABORT )]] )
  tempTimer( 6, [[guaranteeCommand( SHADE_RECALL, SHADE_PATTERN, ORDER_FAIL, ORDER_ABORT )]] )
end

-- Called when our troll tank enters combat (or rescues someone) in order to assist
-- Issue a guaranteed order for the shade to join combat 1s later
LastEnrageTry = LastEnrageTry or getStopWatchTime( "timer" )
function triggerAssistTroll()
  -- local minion = MINIONS[CorpseIndex]
  -- if minion ~= "nymph" then
  --   send( f [[order nymph transfer energy {minion}]], true )
  --   tempTrigger( [[stubbornly refuses]], function ()
  --     send( "!", true )
  --   end, 1 )
  -- end
  -- Throttle attempts and skip if we're already in combat (or assisting)
  AssistDelay = true
  tempTimer( 2.8, [[AssistDelay = false]] )
  -- For the next 3s, respond to joining combat by issuing an assist order to the shade
  if ShadeAssistTrigger then killTrigger( ShadeAssistTrigger ) end
  ShadeAssistTrigger = tempTrigger( [[You join]], [[shadeAssist()]], 1 )
  tempTimer( 5, [[killTrigger( ShadeAssistTrigger )]] )
  local now = getStopWatchTime( "timer" )
  local elapsed = now - LastEnrageTry
  elapsed = round( elapsed, 0.05 )
  cout( f "Enrage timer: {NC}{elapsed}{RC}" )
  if elapsed > 120 then
    send( 'order shade enrage', true )
    LastEnrageTry = now
  end
  send( 'assist troll', true )
end

function shadeAssist()
  --guaranteeSong( 'shadow', 'cold steel, odor' )
  guaranteeOrder( 'nymph', 'assist troll', 'blood nymph assists' )
  guaranteeOrder( 'shade', 'assist troll', 'shade minion assists' )
end

-- Called after our shade minion backstabs; we want the troll to rescue and then assist as normal
function triggerBackstabRescue()
  guaranteeOrder( [[troll]], [[rescue shade]], [[rescues a shade]] )
end

-- We 'looked' and saw ourselves in combat, ask the troll to rescue us - then re-assist
function triggerTrollRescue()
  if not RescueDelay then
    RescueDelay = true
    tempTimer( 2.8, [[RescueDelay = false]] )
    guaranteeOrder( [[troll]], [[rescue kaylee]], [[You are rescued]] )
  end
end

-- Turn on (or switch to) Pummel mode on troll minion
function aliasTrollPummel()
  -- Don't try to swap more than once (flip this flag on success)
  if not TrollSwapping then
    TrollSwapping = true
    tempTimer( 15, [[TrollSwapping = false]] )
    guaranteeOrder( [[troll]], [[pummel]], [[attempt to pummel]] )
  else
    iout( [[Attempted <yellow>aliasTrollPummel<reset>() while TrollSwapping.]] )
  end
end

-- Turn on (or switch to) Defend mode on troll minion
function aliasTrollDefend()
  -- Don't try to swap more than once (flip this flag on success)
  if not TrollSwapping then
    TrollSwapping = true
    tempTimer( 15, [[TrollSwapping = false]] )
    guaranteeOrder( [[troll]], [[defend]], [[attempt to absorb]] )
  else
    iout( [[Attempted <green>aliasTrollDefend<reset>() while TrollSwapping.]] )
  end
end

SacTrigger = SacTrigger or nil
RecallTrigger = RecallTrigger or nil
function triggerEmergencySoft()
  if AutoPathing then AutoPathing = false end
  if AutoBuffing then AutoBuffing = false end
  if AutoStunning then AutoStunning = false end
  if AutoLooking then AutoLooking = false end
  cancelAndClearTriggers()
  --SacTrigger = tempTimer( 300, function () expandAlias( 'sacmin' ) end )
  --tempTimer( 360, function () send( 'save' ) end )
  --RecallTrigger = tempTimer( 420, function () send( 'recall' ) end )
  sendAlert( [[Soft emergency detected.]] )
end

function cancelEmergency()
  if SacTrigger then killTrigger( SacTrigger ) end
  if RecallTrigger then killTrigger( RecallTrigger ) end
end

function triggerEmergency()
  -- "Nuclear option" to cancel any pending queued commands to make room for a hasty retreat; this shouldn't be necessary
  -- but is a safety measure in case the queue is clogged or bugged.
  cancelAndClearTriggers()
  -- Abort any in-game commands in progress that haven't gone through yet and might lead to additional lag
  send( [[abort]], true )
  -- Utilize fame-based recall
  send( [[recall]], true )
  -- Return to undead Nexus with the Death Walk spell
  tempTimer( 5, function () guaranteeCast( 'death walk' ) end )
  -- Bring minions home one at a time ensuring they recall successfully with the guaranteeCommand function
  tempTimer( 8, function () guaranteeCommand( TROLL_RECALL, TROLL_PATTERN, ORDER_FAIL, ORDER_ABORT ) end )
  tempTimer( 10, function () guaranteeCommand( SHADE_RECALL, SHADE_PATTERN, ORDER_FAIL, ORDER_ABORT ) end )
  -- If we were AutoPathing, let's go ahead and call this a "win" and sacrifice the minions to recover gear/xp
  if AutoPathing then
    tempTimer( 30, function () expandAlias( 'sacmin' ) end )
  end
  if AutoPathing then AutoPathing = false end
  if AutoBuffing then AutoBuffing = false end
  if AutoStunning then AutoStunning = false end
  if AutoLooking then AutoLooking = false end
  iout( "{EC}~_-_~ eMeRgEnCy EgReSs TrIgGeReD {RC} ~_-_~" )
  sendAlert( [[~_-_~ eMeRgEnCy EgReSs TrIgGeReD {RC} ~_-_~]] )
end

function triggerEndCombat()
  local victim   = lowerArticles( trim( matches[2] ) )
  local headFame = fameData[victim]
  send( 'abort', false )
  --send( [[cast 'darkness']], true )
  useBeazor()
  send( 'get all corpse', false )
  if headFame ~= 0 then
    send( 'decapitate corpse', false )
    send( 'put head stocking', false )
  end
  orderEatCorpse()
  if AutoPathing then
    lookCheck()
  else
    tempTimer( 1, [[send( 'look', false )]] )
  end
end

-- The Minions table stores information about each minion including a status tracking
-- whether or not they have been summoned, a default behavior mode,
Minions = Minions or {
  ["shade"] = {summoned = false, default = "circle", mode = ""},
  ["troll"] = {summoned = false, default = "defend", mode = ""},
  ["nymph"] = {summoned = false, default = "transfer energy shade", mode = ""},
}
MinionEquipTrigger = MinionEquipTrigger or nil
-- Function called when a new minion is summoned in game to initialize their behavior and
-- trigger the commands to equip them with gear.
function triggerMinionSummoned( minion )
  if MinionEquipTrigger then killTrigger( MinionEquipTrigger ) end
  -- The shade minion must be turned "evil" by killing a large number of innocent enemies
  -- after summoning; delay for 6 seconds to allow for the summon song lag to expire, then
  -- group the shade and use an area ability to kill the mobs.
  if minion == "shade minion" then
    tempTimer( 6, [[send( 'group shade' )]] )
    tempTimer( 6.5, [[expandAlias( 'mm' )]] )
    -- Allow another delay for the area damage song to take affect, then proceed.
    tempTimer( 13, [[expandAlias( 'equip shade' )]] )
    -- This trigger waits until the shade is done "wearing" then ungroups it and sets its default
    -- behavior mode.
    MinionEquipTrigger = tempTrigger( [[A shade minion grabs a drop]], function ()
      send( 'group shade' )
      expandAlias( 'circle' )
    end, 1 )
  elseif minion == "troll minion" then
    tempTimer( 6, [[expandAlias( 'equip troll' )]] )
    MinionEquipTrigger = tempTrigger( [[A troll minion gives you a golden]], function ()
      expandAlias( 'def' )
    end, 1 )
  end
end

NymphTimer = NymphTimer or nil
function summonNymph()
  if NymphTimer then killTimer( NymphTimer ) end
  NymphTimer = tempTimer( 2, function ()
    send( [[song 'damaged']], true )
  end )
end

local function aliasThrow()
  send( 'get 6 ball bag' )
  expandAlias( 'unhold', true )
  for i = 1, 6 do
    send( f 'hold ball\n' )
    send( f 'throw ball {Target}\ni' )
  end
  expandAlias( 'rehold', true )
end

local function banshee1()
  send( 'w', true )
  send( 'w', true )
  send( 'n', true )
  send( 'n', true )
  send( 'n', true )
  send( 'w', true )
  send( 'w', true )
  send( 'n', true )
  send( 'e', true )
  send( 'get wire', true )
  send( 'w', true )
  send( 'w', true )
  send( 'get key', true )
  send( 'e', true )
  send( 'n', true )
  send( 'n', true )
  send( 'get key', true )
  send( 'e', true )
  send( 'e', true )
  send( 's', true )
  send( 'open panelling', true )
  send( 'd', true )
  send( 'use mechanism', true )
end

local function banshee2()
  send( 'u', true )
  send( 'n', true )
  send( 'e', true )
  send( 'e', true )
  send( 'e', true )
  send( 'e', true )
  send( 'e', true )
  send( 'e', true )
  send( 'open hatch', true )
  send( 'u', true )
  send( 'e', true )
  send( 'n', true )
  send( 'n', true )
  send( 'say Target rat!', true )
  expandAlias( 'targ rat', false )
end

local function banshee3()
  send( 's', true )
  send( 's', true )
  send( 'w', true )
  send( 'd', true )
  send( 'w', true )
  send( 'w', true )
  send( 'w', true )
  send( 'n', true )
  send( 'd', true )
  send( 'n', true )
  send( 'n', true )
  send( 'get key', true )
  send( 's', true )
  send( 's', true )
  send( 'u', true )
  send( 's', true )
  send( 'e', true )
  send( 'e', true )
  send( 'unlock gate', true )
  send( 'open gate', true )
  send( 's', true )
  send( 'open trapdoor', true )
  send( 'd', true )
  send( 'search chink', true )
  send( 'u', true )
  send( 'drop awl', true )
end

local function banshee4()
  send( 'n', true )
  send( 'w', true )
  send( 'w', true )
  send( 'w', true )
  send( 'w', true )
  send( 'unlock door', true )
  send( 'open door', true )
  send( 's', true )
  send( 'open trapdoor', true )
  send( 'd', true )
  send( 's', true )
  send( 'get ladder', true )
  send( 'n', true )
  send( 'u', true )
  send( 'n', true )
  send( 'e', true )
  send( 's', true )
  send( 's', true )
  send( 'w', true )
  send( 'open jars', true )
  send( 'get keys', true )
  send( 'e', true )
  send( 'n', true )
  send( 'n', true )
  send( 'w', true )
  send( 's', true )
  send( 'd', true )
  send( 's', true )
  send( 'drop ladder', true )
end

local function banshee5()
  send( 'n', true )
  send( 'u', true )
  send( 'n', true )
  send( 'w', true )
  send( 'w', true )
  send( 'w', true )
  send( 'w', true )
  send( 's', true )
  send( 's', true )
  send( 's', true )
  send( 's', true )
  send( 's', true )
  send( 'e', true )
  send( 's', true )
  send( 'w', true )
  send( 'w', true )
  send( 'w', true )
  send( 'w', true )
  send( 'unlock door', true )
  send( 'open door', true )
  send( 'n', true )
  send( 'n', true )
  send( 'get crowbar', true )
  send( 's', true )
  send( 's', true )
  send( 'e', true )
  send( 'unlock door', true )
  send( 'open door', true )
  send( 'n', true )
  send( 'search coils', true )
  send( 'n', true )
  send( 'get tongs', true )
end

local function banshee6()
  send( 's', true )
  send( 's', true )
  send( 'e', true )
  send( 'e', true )
  send( 'e', true )
  send( 'n', true )
  send( 'w', true )
  send( 'n', true )
  send( 'n', true )
  send( 'n', true )
  send( 'n', true )
  send( 'n', true )
  send( 'e', true )
  send( 'unlock gate', true )
  send( 'open gate', true )
  send( 's', true )
  send( 'search oven', true )
  send( 'drop tongs', true )
end

local function banshee7()
  send( 'n', true )
  send( 'e', true )
  send( 'e', true )
  send( 's', true )
  send( 'd', true )
  send( 'open doorway', true )
  send( 'drop crowbar', true )
  send( 'w', true )
  send( 'w', true )
  send( 'w', true )
  send( 'u', true )
  send( 'get dagger', true )
  send( 'say Time to kill Aeas!', true )
  expandAlias( 'targ Aeas', false )
  send( 'drop dagger', true )
end

local function banshee8()
  send( 'drop morningstar', true )
  send( 'drop mandible', true )
  send( 'drop gem', true )
  send( 'w', true )
  send( 'n', true )
  send( 'n', true )
  send( 'n', true )
  send( 'e', true )
  send( 'get key', true )
  send( 'w', true )
  send( 's', true )
  send( 's', true )
  send( 's', true )
  send( 'e', true )
  send( 'unlock trapdoor', true )
  send( 'open trapdoor', true )
  send( 'u', true )
  send( 'u', true )
  send( 'get key', true )
  send( 'get chimes', true )
  send( 'put chimes stocking', true )
  send( 'd', true )
  send( 'd', true )
  send( 'd', true )
  send( 'e', true )
  send( 'e', true )
  send( 'e', true )
  send( 'e', true )
  send( 'u', true )
  send( 'n', true )
  send( 'e', true )
  send( 'e', true )
  send( 'e', true )
  send( 'e', true )
  send( 'n', true )
  send( 'search rubbish', true )
  send( 's', true )
  send( 'w', true )
  send( 'unlock gate', true )
  send( 'open gate', true )
  send( 'n', true )
  send( 'open safe 321117', true )
  send( 'get all safe', true )
  send( 'drop gem', true )
end

local function banshee9()
  send( 's', true )
  send( 'w', true )
  send( 'w', true )
  send( 's', true )
  send( 's', true )
  send( 's', true )
  send( 'w', true )
  send( 'w', true )
  send( 'w', true )
  send( 'unlock door', true )
  send( 'open door', true )
  send( 's', true )
  send( 'search frame', true )
  send( 'n', true )
  send( 'w', true )
  send( 'n', true )
  send( 'n', true )
  send( 'unlock door', true )
  send( 'open door', true )
  send( 'w', true )
  send( 'l snifter', true )
  send( 'pour brandy out', true )
  send( 'e', true )
  send( 'n', true )
  send( 'e', true )
  send( 'e', true )
  send( 'e', true )
  send( 'e', true )
  send( 'e', true )
  send( 'e', true )
  send( 'e', true )
  send( 's', true )
  send( 'unlock cabinet', true )
  send( 'open cabinet', true )
  send( 'get violin cabinet', true )
  send( 'put violin stocking', true )
end

local function banshee10()
  send( 'n', true )
  send( 'e', true )
  send( 'u', true )
  send( 'e', true )
  send( 'n', true )
  send( 'search mud', true )
end

local function banshee11()
  send( 's', true )
  send( 'w', true )
  send( 'd', true )
  send( 'w', true )
  send( 'w', true )
  send( 'w', true )
  send( 'w', true )
  send( 's', true )
  send( 's', true )
  send( 's', true )
  send( 'e', true )
  send( 'unlock door', true )
  send( 'open door', true )
  send( 'n', true )
  send( 'l lectern', true )
  send( 'open case', true )
  send( 'get guitar', true )
  send( 'put guitar stocking', true )
end

local function banshee12()
  send( 's', true )
  send( 'w', true )
  send( 'w', true )
  send( 'w', true )
  send( 's', true )
  send( 's', true )
  send( 's', true )
  send( 'say Time to give instruments!', true )
end

local function banshee13()
  send( 'get violin stocking', true )
  send( 'give violin statue', true )
  send( 'get flute stocking', true )
  send( 'give flute statue', true )
  send( 'get horn stocking', true )
  send( 'give horn statue', true )
  send( 'get guitar stocking', true )
  send( 'give guitar statue', true )
  send( 'get chimes stocking', true )
  send( 'give chimes statue', true )
  send( 'get lyre stocking', true )
  send( 'give lyre statue', true )
end
