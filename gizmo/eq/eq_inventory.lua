nanMode = nanMode or nil

function swapGear()
  -- Define the swappable gear sets; the last two items must be 'wield' and 'hold'
  local dpsGear = {"onyx", "onyx", "cape", "cape", "platemail", "masoch", "flaming", "flaming", "cudgel", "scalpel"}
  local tankGear = {"one", "one", "skin", "skin", "vest", "kings", "fanra", "fanra", "cutlass", "bangle"}
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
    expandAlias( f 'nan remove {currentGear[i]}', false )
    expandAlias( f 'col get {nextGear[i]} stocking', false )
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
    expandAlias( f 'col give {nextGear[i]} Nandor', false )
    expandAlias( f 'nan give {currentGear[i]} Colin', false )
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
    expandAlias( f 'col put {currentGear[i]} stocking', false )
    expandAlias( f 'nan {wearCommand} {nextGear[i]}', false )
  end
  -- Clean up globals we don't need anymore
  currentGear, nextGear, doReady, finishReady = nil, nil, nil, nil
end
