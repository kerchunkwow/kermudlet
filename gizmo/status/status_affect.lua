-- The affects we want to track; set this to "save" in Variables to maintain durations between sessions
affectInfo = affectInfo or {
  ["Sanctuary"]        = {duration = nil, cost = 50, color = "lavender_blush", char = "🌟"},
  ["Bless"]            = {duration = nil, cost = 5, color = "light_goldenrod", char = "🙏"},
  ["Fury"]             = {duration = nil, cost = 60, color = "tomato", char = "😡"},
  ["Armor"]            = {duration = nil, cost = 5, color = "steel_blue", char = "🛡️"},
  ["Detect Invisible"] = {duration = 60, cost = 5, color = "steel_blue", char = "🛡️"},
}

-- Initialize affect status, strings, and start times
affectStatus = {}
affectStrings = {}
affectStartTimes = {}

for pc = 1, 4 do
  affectStatus[pc] = {}
  affectStrings[pc] = ""
  affectStartTimes[pc] = {}
  for spellName, _ in pairs( affectInfo ) do
    affectStatus[pc][spellName] = false
    affectStartTimes[pc][spellName] = nil
  end
end
-- Update affect status to true and modify affect string
function applyAffect( spellName, pc )
  if affectStatus[pc] and affectInfo[spellName] then
    if not affectStatus[pc][spellName] then
      affectStatus[pc][spellName] = true
      updateAffectString( pc, spellName, true )
      affectStartTimes[pc][spellName] = getStopWatchTime( "timer" )
    end
  else
    cecho( f "\n<orange_red>Invalid applyAffect: {spellName} for PC{pc}<reset>" )
  end
end

-- Update affect status to false and modify affect string; called by 'remove' triggers
function removeAffect( spellName, pc )
  if affectStatus[pc] and affectInfo[spellName] then
    if affectStatus[pc][spellName] then
      --affectInfo[spellName].duration = calculateDuration( pc, spellName )
      affectStatus[pc][spellName] = false
      updateAffectString( pc, spellName, false )
    end
  else
    cecho( f "\n<orange_red>Invalid removeAffect: {spellName} for PC{pc}<reset>" )
  end
end

-- Function to update affect strings
function updateAffectString( pc, spellName, addChar )
  local char = affectInfo[spellName].char
  if addChar then
    affectStrings[pc] = affectStrings[pc] .. char
  else
    affectStrings[pc] = affectStrings[pc]:gsub( char, '', 1 )
  end
  affectLabel[pc]:echo( affectStrings[pc] )
end

-- Function to calculate duration
function calculateDuration( pc, spellName )
  local endTime = getStopWatchTime( "timer" )
  local startTime = affectStartTimes[pc][spellName]
  if startTime then
    local newDuration = endTime - startTime
    local existingDuration = affectInfo[spellName].duration

    if existingDuration then
      if math.abs( newDuration - existingDuration ) <= 60 then
        -- If there's already a duration stored for this spell, average the new and existing durations
        return math.floor( ((newDuration + existingDuration) / 2) / 10 ) * 10
      end
      -- If the calculated duration differs by more than +/- 60s, this was probably an error so discard
      return existingDuration
    else
      -- This is the first recorded duration
      return math.floor( newDuration / 10 ) * 10
    end
  end
  return nil
end

-- Called by affect apply triggers
function applyAffectTrigger()
  local keyword = matches[2]
  local appliedAffect = affectKeywords[keyword]
  local affectColor, affectEmoji = affectInfo[appliedAffect].color, affectInfo[appliedAffect].char
  selectString( keyword, 1 )
  fg( affectColor )
  resetFormat()
  cecho( affectEmoji )
  if session == 1 then
    applyAffect( appliedAffect, 1 )
  else
    raiseGlobalEvent( "eventPCStatusAffect", session, appliedAffect, true )
  end
end

-- Called by affect remove triggers
function removeAffectTrigger()
  local keyword = matches[2]
  local removedAffect = affectKeywords[keyword]
  local affectColor, affectEmoji = affectInfo[removedAffect].color, affectInfo[removedAffect].char
  selectString( keyword, 1 )
  fg( affectColor )
  resetFormat()
  cecho( affectEmoji )
  if session == 1 then
    removeAffect( removedAffect, 1 )
  else
    raiseGlobalEvent( "eventPCStatusAffect", session, removedAffect, false )
  end
end

-- Function to print affect strings for each PC
function printAffectStrings()
  for pc = 1, 4 do
    local affectString = affectStrings[pc]
    if #affectString > 0 then
      cecho( "info", f "\nAffects for {pc_tags[pc]}: {affectString}" )
    end
  end
end
