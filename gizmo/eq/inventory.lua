cecho( f '\n\t<dark_violet>inventory.lua<reset>: inventory and equipment management, juggling, swapping, etc.' )

nanMode = nanMode or nil

function laswield()
  expandAlias( 'las rem ring', false )
  expandAlias( 'las rem leg', false )
  expandAlias( 'las rem gloves', false )
  expandAlias( 'las get sky bag', false )
  expandAlias( 'las get gauntlets bag', false )
  expandAlias( 'las get bionic bag', false )
  expandAlias( 'las wear sky', false )
  expandAlias( 'las wear gauntlets', false )
  expandAlias( 'las wear bionic', false )
  expandAlias( 'las wield spirit', false )
  expandAlias( 'las rem sky', false )
  expandAlias( 'las rem gauntlets', false )
  expandAlias( 'las rem bionic', false )
  expandAlias( 'las give sky nandor', false )
  expandAlias( 'las give gauntlets nandor', false )
  expandAlias( 'las give bionic nadja', false )
  expandAlias( 'las wear gloves', false )
  expandAlias( 'las wear ring', false )
  expandAlias( 'las wear leg', false )
end

function nanwield()
  expandAlias( 'nan rem onyx', false )
  expandAlias( 'nan wear gauntlets', false )
  expandAlias( 'nan wear sky', false )
  expandAlias( 'nan wield cudgel', false )
  expandAlias( 'nan hold scalpel', false )
  expandAlias( 'nan rem sky', false )
  expandAlias( 'nan rem gauntlets', false )
  expandAlias( 'nan give sky nadja', false )
  expandAlias( 'nan give gauntlets nadja', false )
  expandAlias( 'nan wear onyx', false )
  expandAlias( 'nan wear gloves', false )
end

function nadwield()
  expandAlias( 'nad rem ring', false )
  expandAlias( 'nad rem gloves', false )
  expandAlias( 'nad rem leg', false )
  expandAlias( 'nad wear sky', false )
  expandAlias( 'nad wear gauntlets', false )
  expandAlias( 'nad wear bionic', false )
  expandAlias( 'nad wield spirit', false )
  expandAlias( 'nad hold malachite', false )
  expandAlias( 'nad rem sky', false )
  expandAlias( 'nad rem gauntlets', false )
  expandAlias( 'nad rem bionic', false )
  expandAlias( 'nad give sky colin', false )
  expandAlias( 'nad give gauntlets colin', false )
  expandAlias( 'nad give bionic colin', false )
  expandAlias( 'nad wear ring', false )
  expandAlias( 'nad wear gloves', false )
  expandAlias( 'nad wear leg', false )
end

function colwield()
  expandAlias( 'col rem ring', false )
  expandAlias( 'col rem greaves', false )
  expandAlias( 'col wear sky', false )
  expandAlias( 'col wear bionic', false )
  expandAlias( 'col wear gauntlets', false )
  expandAlias( 'col wield hammer', false )
  expandAlias( 'col hold malachite', false )
  expandAlias( 'col rem sky', false )
  expandAlias( 'col rem gauntlets', false )
  expandAlias( 'col rem bionic', false )
  expandAlias( 'col give sky laszlo', false )
  expandAlias( 'col give gauntlets laszlo', false )
  expandAlias( 'col give bionic laszlo', false )
  expandAlias( 'col wear onyx', false )
  expandAlias( 'col wear greaves', false )
end

-- Prepare cloning sequence with gear assignments
function startClone()
  nadjaClones = {'cuffs', 'skin'}
  laszloClones = {'halo'}

  expandAlias( "nan rem halo", false )
  expandAlias( "nan give halo laszlo", false )
  send( 'get skin stocking', false )
  send( 'give skin nadja', false )

  -- And remove the items to clone
  expandAlias( 'nad rem cuffs', false )
end

-- Called repeatedly to iterate each list of cloning assignments until complete
function doClone()
  -- First/last call condition
  if not nadjaClones then
    startClone()
  elseif #nadjaClones == 0 and #laszloClones == 0 then
    endClone()
  end
  -- If Nadja has clone mana, try the next clone
  if pcStatus[2]["currentMana"] > 100 and nadjaClones and #nadjaClones > 0 then
    -- Stand up & attempt to clone after setting a fresh success trigger
    expandAlias( "nad stand" )
    if nadCloneTrigger then killTrigger( nadCloneTrigger ) end
    nadCloneTrigger = tempTrigger( "Nadja creates a duplicate", [[table.remove( nadjaClones, 1 )]] )
    local nextClone = nadjaClones[1]
    expandAlias( f [[nad cast 'clone' {nextClone}]] )
  elseif pcStatus[2]["currentMana"] < 100 and #nadjaClones > 0 then
    expandAlias( "nad rest" )
  end
  -- Repeat for Laszlo
  if pcStatus[3]["currentMana"] > 100 and laszloClones and #laszloClones > 0 then
    expandAlias( "las stand" )
    if lasCloneTrigger then killTrigger( lasCloneTrigger ) end
    lasCloneTrigger = tempTrigger( "Laszlo creates a duplicate", [[table.remove( laszloClones, 1 )]] )
    local nextClone = laszloClones[1]
    expandAlias( f [[las cast 'clone' {nextClone}]] )
  elseif pcStatus[3]["currentMana"] < 100 and #laszloClones > 0 then
    expandAlias( "las rest" )
  end
end

function endClone()
  if lasCloneTrigger then killTrigger( lasCloneTrigger ) end
  if nadCloneTrigger then killTrigger( nadCloneTrigger ) end
  if nadjaClones then nadjaClones = nil end
  if laszloClones then laszloClones = nil end
  expandAlias( 'col get staff', false )
  expandAlias( 'col get halo', false )
  expandAlias( 'col get cuffs', false )
  expandAlias( 'col hold staff', false )
  expandAlias( 'col wear halo', false )
  expandAlias( 'col wear cuffs', false )

  expandAlias( 'las get staff', false )
  expandAlias( 'las get cuffs', false )
  expandAlias( 'las hold staff', false )
  expandAlias( 'las wear cuffs', false )
  expandAlias( 'las wear crocodile', false )

  expandAlias( 'nan get staff', false )
  expandAlias( 'nan get crocodile', false )
  expandAlias( 'nan hold staff', false )
  expandAlias( 'nan wear crocodile', false )

  expandAlias( 'nad hold staff', false )
  expandAlias( 'nad wear cuffs', false )

  expandAlias( "las give halo nandor", false )
  tempTimer( 1, [[expandAlias( "nan wear halo", false )]] )

  expandAlias( 'all save', false )
end

function swapGear()
  -- Define the swappable gear sets; the last two items must be 'wield' and 'hold'
  local dpsGear = {"onyx", "onyx", "cape", "cape", "transparent", "masoch", "flaming", "flaming", "cudgel", "scalpel"}
  local tankGear = {"one", "emerald", "skin", "skin", "vest", "kings", "fanra", "fanra", "cutlass", "bangle"}
  local held, toHold = "", ""

  -- These need to be global temporarily so subsequent swap functions can access them
  currentGear, nextGear = {}, {}
  doReady, finishReady = 0, 0

  -- Figure out what we're swapping to/from
  if nanMode == "dps" then
    held, toHold = "a bloody scalpel", "a metal bangle"
    nanMode = "tank"
    currentGear = dpsGear
    nextGear = tankGear
  else
    toHold, held = "a bloody scalpel", "a metal bangle"
    nanMode = "dps"
    currentGear = tankGear
    nextGear = dpsGear
  end
  -- Set triggers to watch the swap and trigger next steps as each one completes
  tempRegexTrigger( f [[Nandor stops using ]] .. held .. [[\.$]], [[doSwap()]], 1 )
  tempRegexTrigger( f [[You get ]] .. toHold .. [[ from a Christmas Stocking\.$]], [[doSwap()]], 1 )
  tempRegexTrigger( f [[Nandor gives you ]] .. held .. [[\.$]], [[finishSwap()]], 1 )
  prepSwap()
end

-- Prepare the swap by removing the current gear set and getting the next set from storage
function prepSwap()
  for i = 1, #currentGear do
    expandAlias( f 'nan remove {currentGear[i]}' )
    expandAlias( f 'col get {nextGear[i]} stocking' )
  end
end

-- Perform the swap through the sensual art of mutual giving
function doSwap()
  -- Ignore the first call of this function so we only proceed when both swappers are prepped
  doReady = doReady + 1
  if doReady < 2 then return end
  -- Count "Ok." which indicates an item was given to the receiver; make sure we get one for every item before proceeding
  tempRegexTrigger( [[Ok\.$]], [[finishSwap()]], #nextGear )
  for i = 1, #nextGear do
    expandAlias( f 'col give {nextGear[i]} Nandor' )
    expandAlias( f 'nan give {currentGear[i]} Colin' )
  end
end

function finishSwap()
  -- Ignore calls to this function until all items have been given (and Nandor's holdable has been removed which is why +1)
  finishReady = finishReady + 1
  if finishReady < (#nextGear + 1) then return end
  -- Most items need to be worn
  local wearCommand = "wear"
  for i = 1, #nextGear do
    -- But use wield/hold for the last two
    if i == #nextGear - 1 then wearCommand = "wield" elseif i == #nextGear then wearCommand = "hold" end
    expandAlias( f 'col put {currentGear[i]} stocking' )
    expandAlias( f 'nan {wearCommand} {nextGear[i]}' )
  end
  -- Clean up globals we don't need anymore
  currentGear, nextGear, doReady, finishReady = nil, nil, nil, nil
end
