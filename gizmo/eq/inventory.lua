cecho( f '\n\t<dark_violet>inventory.lua<reset>: inventory and equipment management, juggling, swapping, etc.' )

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
  nadjaClones = {'staff', 'staff', 'staff', 'transparent', 'transparent'}
  laszloClones = {'crocodile', 'gloves', 'gloves', 'masoch', 'masoch'}

  -- And remove the items to clone
  expandAlias( 'nad rem staff', false )
  expandAlias( 'las rem crocodile', false )
  expandAlias( 'nad rem transparent', false )
  expandAlias( 'las rem gloves', false )
  expandAlias( 'las rem masoch', false )
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
  if pcStatus[2]["currentMana"] > 100 and #nadjaClones > 0 then
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
  if pcStatus[3]["currentMana"] > 100 and #laszloClones > 0 then
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
  nadjaClones = nil
  laszloClones = nil

  if lasCloneTrigger then killTrigger( lasCloneTrigger ) end
  if nadCloneTrigger then killTrigger( nadCloneTrigger ) end
  expandAlias( 'col get staff', false )
  expandAlias( 'col get crocodile', false )
  expandAlias( 'col get gloves', false )
  expandAlias( 'col get masoch', false )
  expandAlias( 'las get transparent', false )
  expandAlias( 'las get staff', false )
  expandAlias( 'nan get staff', false )
  expandAlias( 'nan get transparent', false )
  expandAlias( 'nan get crocodile', false )
  expandAlias( 'nan get gloves', false )
  expandAlias( 'nan get masoch', false )
  expandAlias( 'nad hold staff', false )
  expandAlias( 'nad wear transparent', false )
  expandAlias( 'nad wear gloves', false )
  expandAlias( 'nad wear masoch', false )
  expandAlias( 'las wear crocodile', false )
  expandAlias( 'las wear transparent', false )
  expandAlias( 'las wear gloves', false )
  expandAlias( 'las wear masoch', false )
  expandAlias( 'las hold staff', false )
  expandAlias( 'col hold staff', false )
  expandAlias( 'col wear crocodile', false )
  expandAlias( 'col wear gloves', false )
  expandAlias( 'col wear masoch', false )
  expandAlias( 'nan hold staff', false )
  expandAlias( 'nan wear transparent', false )
  expandAlias( 'nan wear crocodile', false )
  expandAlias( 'nan wear gloves', false )
  expandAlias( 'nan wear masoch', false )
  expandAlias( 'all save', false )
end

-- Swap between lists of items worn/stored in container
function swapGear( itemsWorn, itemsToWear, bag, pc )
  -- Make sure both lists have the same number of items
  if #itemsWorn ~= #itemsToWear then
    cecho( "infoWindow", "\n<dark_orange>Unbalanced item lists in swapGear()" )
    return
  end
  -- Then walk the lists & swap the gear
  for i = 1, #itemsWorn do
    expandAlias( f( "{pc} remove {itemsWorn[i]}" ) )
    expandAlias( f( "{pc} put {itemsWorn[i]} {bag}" ) )
    expandAlias( f( "{pc} get {itemsToWear[i]} {bag}" ) )
    expandAlias( f( "{pc} wear {itemsToWear[i]}" ) )
  end
end

-- Swap items in hand (wielded/held)
function swapHand( itemHand, itemToHand, handCommand, bag, pc )
  expandAlias( f '{pc} rem {itemHand}' )
  expandAlias( f '{pc} put {itemHand} {bag}' )
  expandAlias( f '{pc} get {itemToHand} {bag}' )
  expandAlias( f '{pc} {handCommand} {itemToHold}' )
end

-- Switch Nandor from AC to DPS gear (and back)
function swapNandor()
  local dpsGear = {'onyx', 'onyx', 'transparent', 'masoch', 'flaming'}
  local acGear = {'one', 'emerald', 'vest', 'spider', 'glowing'}

  if nanMode == "dps" then
    nanMode = "tank"
    swapGear( dpsGear, acGear, "nan", "bag" )
    swapHand( "scalpel", "bangle", "hold", "bag", "nan" )
    swapHand( "cudgel", "cutlass", "wield", "bag", "nan" )
  else
    nanMode = "dps"
    swapGear( acGear, dpsGear, "nan", "bag" )
    swapHand( "bangle", "scalpel", "nan", "bag", "hold" )
    swapHand( "cutlass", "cudgel", "nan", "bag", "wield" )
  end
end
