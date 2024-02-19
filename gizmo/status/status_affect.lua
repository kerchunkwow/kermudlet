-- Initiate the affect status table for all four PCs
local function initAffectStatus()
  affectStatus = {}
  for pc = 1, 4 do
    affectStatus[pc] = {
      ['Sanctuary']            = {active = false, ticksRemaining = -1},
      ['Armor']                = {active = false, ticksRemaining = -1},
      ['Bless']                = {active = false, ticksRemaining = -1},
      ['Fury']                 = {active = false, ticksRemaining = -1},
      ['Endure']               = {active = false, ticksRemaining = -1},
      ['Protection from evil'] = {active = false, ticksRemaining = -1},
    }
  end
end
initAffectStatus()

-- Update the specified affect for a given pc; duration -1 removes an affect
-- Only available to the Main session; Alts raise events as with the prompt
function updateAffect( pc, affectName, ticks )
  if affectStatus[pc] and affectStatus[pc][affectName] then
    local affect = affectStatus[pc][affectName]
    if affect.active == (ticks >= 0) and affect.ticksRemaining == ticks then
      -- Skip update if the affect status is unchanged
      return
    end
    -- Update the affect status based on the ticks value
    if ticks >= 0 then
      affectStatus[pc][affectName].active = true
      affectStatus[pc][affectName].ticksRemaining = ticks
    else
      affectStatus[pc][affectName].active = false
      affectStatus[pc][affectName].ticksRemaining = -1
    end
    refreshAffectLabels( pc )
  else
    cecho( "info", f "\n<dark_orange>err<reset> invalid updateAffect: {pc}, {affectName}" )
  end
end

-- On 'aff' this turns on the trigger group responsible for updating affects
function aliasUpdateAffects()
  -- Reset the affect table so missing affects are properly dropped
  resetAffects()
  -- Turn on the Capture Affects trigger group (it turns itself off at next prompt); consume
  -- and discard the return value so it doesn't print on screen.
  expandAlias( [[all lua dummyvar = enableTrigger( 'Capture Affects' )]], false )
  expandAlias( [[all lua dummyvar = nil]], false )
  -- Issue 'aff' in all profiles
  expandAlias( 'all affect', false )
end

-- Called when capture triggers match an 's expires in d' pattern
function triggerUpdateAffect()
  local affectName = trim( matches[2] )
  local ticks = tonumber( matches[3] )
  selectString( affectName, 1 )
  setFgColor( unpack( color_table['maroon'] ) )
  selectString( ticks, 1 )
  setFgColor( unpack( color_table['orange'] ) )
  resetFormat()
  if affectName == "Poison" then
    local poisoned = pcNames[SESSION]
    expandAlias( f [[col cast 'remove poison' {poisoned}]], false )
    return
  end
  if SESSION == 1 then
    updateAffect( 1, affectName, ticks )
    refreshAffectLabels( 1 )
  else
    raiseGlobalEvent( "eventPCStatusAffect", SESSION, affectName, ticks )
  end
end

-- When 'aff' is done refreshing data, update the labels in the Party Console
function refreshAffectLabels( pc )
  affectLabel[pc]:echo( getAffectsString( pc ) )
end

-- Called when an affect application message is matched in game
function triggerAffectApllied()
  local keyword = matches[2]
  local affectApplied = affectKeywords[keyword]
  local ac = color_table[affectInfo[affectApplied].color]
  local acr, acg, acb = ac[1], ac[2], ac[3]
  -- Highlight the application keyword in the affect's color
  selectString( keyword, 1 )
  setFgColor( acr, acg, acb )
  resetFormat()
  cecho( affectInfo[affectApplied].char )
  if SESSION == 1 then
    updateAffect( 1, affectApplied, affectInfo[affectApplied].duration )
    refreshAffectLabels( 1 )
  else
    raiseGlobalEvent( "eventPCStatusAffect", SESSION, affectApplied, affectInfo[affectApplied].duration )
  end
end

-- Called when an affect expiration message is matched in game
function triggerAffectExpired()
  local affectRemoved = affectKeywords[matches[2]]
  if SESSION == 1 then
    updateAffect( 1, affectRemoved, -1 )
    refreshAffectLabels( 1 )
  else
    raiseGlobalEvent( "eventPCStatusAffect", SESSION, affectRemoved, -1 )
  end
end

-- This resets/clears all affects; used before an aff to ensure a clean slate
function resetAffects()
  for pc = 1, 4 do
    for affectName in pairs( affectStatus[pc] ) do
      affectStatus[pc][affectName].active = false
      affectStatus[pc][affectName].ticksRemaining = -1
    end
  end
end

function triggerClearAffects()
  for affectName in pairs( affectStatus[SESSION] ) do
    if SESSION == 1 then
      affectStatus[1][affectName].active = false
      affectStatus[1][affectName].ticksRemaining = -1
      refreshAffectLabels( 1 )
    else
      raiseGlobalEvent( "eventPCStatusAffect", SESSION, affectName, -1 )
    end
  end
end

-- Get a string representation of the given PCs active affects w/ duration
function getAffectsString( pc )
  local affectString = ""
  for affectName, affectData in pairs( affectStatus[pc] ) do
    if affectData.active then
      local char = affectInfo[affectName].char
      local maxDuration = affectInfo[affectName].duration
      local ticksRemaining = affectData.ticksRemaining
      local durationColor

      -- Determine the durationColor based on ticksRemaining compared to maxDuration
      if ticksRemaining >= maxDuration / 2 then
        durationColor = affectDuration['high']
      elseif ticksRemaining >= 2 then
        durationColor = affectDuration['med']
      else
        durationColor = affectDuration['low']
      end
      -- Construct the affect string with the appropriate color
      affectString = f "{affectString}{char}<span style='color:{durationColor};'>{ticksRemaining}</span> "
    end
  end
  return trim( affectString )
end

-- During an 'aff' command, gag output related to permanent affects until the 'Spells:' line;
-- Disable the entire affects capture group shortly afterward
function triggerGagPermanents()
  enableTrigger( "GagPermanents" )
  tempRegexTrigger( "^Spells:", "disableTrigger( 'GagPermanents' )", 1 )
  tempRegexTrigger( "^Spells:", "deleteLine()", 1 )
  tempTimer( 1, [[disableTrigger( 'Capture Affects' )]] )
end
