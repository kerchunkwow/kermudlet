-- Invoked by an in-game alias to initiate the cloning process; combined with the triggers this should
-- handle the entire process of cloning items from storage.
function startCloning()
  -- Calculate total clones needed
  --if not CloneCount then

  if not CurrentClone then return end
  -- For each item, retrieve it from storage and start cloning
  for item, _ in pairs( CloneList ) do
    expandAlias( f "gett {item} stocking" )
  end
  -- Give it some time to get all the items out
  tempTimer( 5.2, function ()
    send( f "cast 'clone' {CurrentClone}", true )
  end )
end

-- Invoked once cloning is complete to free up resources
function endCloning()
  -- Clean up global variables
  CloneList    = nil
  CurrentClone = nil
  CloneCount   = nil
  CloneRate    = nil
  CloneRest    = nil

  -- Kill the triggers
  killTrigger( CloneSuccessTrigger )
  killTrigger( CloneFailTrigger )
  killTrigger( CloneRecoverTrigger )

  -- Undefine the functions
  startCloning = nil
  endCloning   = nil
end

function initCloning()
  -- Initialize CloneList, CloneCount, and CurrentClone
  CloneList    = CloneList or {
    ["kings"]        = 3,
    ["helm"]         = 1,
    ["lies"]         = 3,
    ["sickle"]       = 1,
    ["idiocy"]       = 2,
    ["stone"]        = 1,
    ["working"]      = 1,
    ["waterwalking"] = 5,
  }
  -- Set the current item to clone
  CurrentClone = next( CloneList )
  -- How long to wait between attempts to clone items
  CloneRate    = 2.6
  -- How long to rest when mana is needed
  CloneRest    = 182.6
  -- Figure out how many things need cloning
  if not CloneCount then
    CloneCount = 0
    for _, count in pairs( CloneList ) do
      CloneCount = CloneCount + count
    end
  end
  -- Handle successful cloning
  if CloneSuccessTrigger then killTrigger( CloneSuccessTrigger ) end
  CloneSuccessTrigger = tempTrigger( "You create a duplicate", function ()
    CloneList[CurrentClone] = CloneList[CurrentClone] - 1
    local remaining = CloneList[CurrentClone]
    if CloneList[CurrentClone] == 0 then
      CurrentClone = next( CloneList, CurrentClone )
    end
    if not CurrentClone then
      endCloning()
    else
      tempTimer( CloneRate, function ()
        send( f "cast 'clone' " .. CurrentClone, true )
      end )
    end
  end )

  -- Handle clone failure; attempt to clone the item again after a short delay
  if CloneFailTrigger then killTrigger( CloneFailTrigger ) end
  CloneFailTrigger = tempTrigger( "You lost your concentration", function ()
    tempTimer( CloneRate, function ()
      send( f "cast 'clone' " .. CurrentClone, true )
    end )
  end )

  -- Handle mana recovery
  if CloneRecoverTrigger then killTrigger( CloneRecoverTrigger ) end
  CloneRecoverTrigger = tempTrigger( "can't summon enough energy", function ()
    send( "rest", true )
    tempTimer( CloneRest, function ()
      send( "stand", true )
      send( f "cast 'clone' " .. CurrentClone, true )
    end )
  end )
end
