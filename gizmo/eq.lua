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

function do_clone()
  -- Check first/last call conditions
  if not nadja_clones then
    start_cloning()
  elseif #nadja_clones == 0 and #laszlo_clones == 0 then
    finish_cloning()
  end
  -- If Nadja has clone mana, try the next clone
  if pcStatus[2]["currentMana"] > 100 and #nadja_clones > 0 then
    expandAlias( "nad stand" )

    -- Refresh a trigger to remove the item on successful clone
    if nad_clone_trigger then killTrigger( nad_clone_trigger ) end
    nad_clone_trigger = tempTrigger( "Nadja creates a duplicate", [[table.remove( nadja_clones, 1 )]] )
    local next_item = nadja_clones[1]
    expandAlias( f [[nad cast 'clone' {next_item}]] )
  elseif pcStatus[3]["currentMana"] < 100 and #laszlo_clones > 0 then
    expandAlias( "nad rest" )
  end
  -- Repeat for Laszlo
  if pcStatus[3]["currentMana"] > 100 and #laszlo_clones > 0 then
    expandAlias( "las stand" )

    if las_clone_trigger then killTrigger( las_clone_trigger ) end
    las_clone_trigger = tempTrigger( "Laszlo creates a duplicate", [[table.remove( laszlo_clones, 1 )]] )
    local next_item = laszlo_clones[1]
    expandAlias( f [[las cast 'clone' {next_item}]] )
  elseif pcStatus[3]["currentMana"] < 100 and #laszlo_clones > 0 then
    expandAlias( "las rest" )
  end
end --function

function start_cloning()
  nadja_clones = { 'staff', 'staff', 'staff', 'transparent', 'transparent' }
  laszlo_clones = { 'crocodile', 'gloves', 'gloves', 'masoch', 'masoch' }

  -- And remove the items in question
  expandAlias( 'nad rem staff', false )
  expandAlias( 'las rem crocodile', false )
  expandAlias( 'nad rem transparent', false )
  expandAlias( 'las rem gloves', false )
  expandAlias( 'las rem masoch', false )
end

function finish_cloning()
  nadja_clones = nil
  laszlo_clones = nil

  if las_clone_trigger then killTrigger( las_clone_trigger ) end
  if nad_clone_trigger then killTrigger( nad_clone_trigger ) end
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

function swapGear( itemsWorn, itemsToWear, pc, container )
  -- Check if both lists have the same number of items
  if #itemsWorn ~= #itemsToWear then
    print( "Error: The lists of items to wear and remove do not match in size." )
    return
  end
  local swapper = short_names[pc]

  -- Iterating over both lists simultaneously
  for i = 1, #itemsWorn do
    expandAlias( f( "{swapper} remove {itemsWorn[i]}" ) )
    expandAlias( f( "{swapper} put {itemsWorn[i]} {container}" ) )
    expandAlias( f( "{swapper} get {itemsToWear[i]} {container}" ) )
    expandAlias( f( "{swapper} wear {itemsToWear[i]}" ) )
  end
end

function swapHand( itemHeld, itemToHold, pc, container, command )
  local holder = short_names[pc]
  expandAlias( f '{holder} rem {itemHeld}' )
  expandAlias( f '{holder} put {itemHeld} {container}' )
  expandAlias( f '{holder} get {itemToHold} {container}' )
  expandAlias( f '{holder} {command} {itemToHold}' )
end

function swapNandor()
  local dpsGear = { 'onyx', 'onyx', 'transparent', 'masoch', 'flaming' }
  local acGear = { 'one', 'emerald', 'vest', 'spider', 'glowing' }

  if nanMode == "dps" then
    nanMode = "tank"
    swapGear( dpsGear, acGear, 4, "bag" )
    swapHand( "scalpel", "bangle", 4, "bag", "hold" )
    swapHand( "cudgel", "cutlass", 4, "bag", "wield" )
  else
    nanMode = "dps"
    swapGear( acGear, dpsGear, 4, "bag" )
    swapHand( "bangle", "scalpel", 4, "bag", "hold" )
    swapHand( "cutlass", "cudgel", 4, "bag", "wield" )
  end
end
