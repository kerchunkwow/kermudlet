cecho( f '\n\t<dark_violet>affect.lua<reset>: to maintain buffs/debuffs and track duration' )

-- The affects we want to track; set this to "save" in Variables to maintain durations between sessions
spellInfo = {
  ["Sanctuary"] = {duration = nil, cost = 50, color = "lavender_blush", char = "🌟"},
  ["Bless"]     = {duration = nil, cost = 5, color = "light_goldenrod", char = "🙏"},
  ["Fury"]      = {duration = nil, cost = 60, color = "tomato", char = "😡"},
  ["Armor"]     = {duration = nil, cost = 5, color = "steel_blue", char = "🛡️"},
}

affectStartTimes = {}

-- Initialize tables to track the status of each affect and their strings on all PCs
function initializeAffectTracking()
  affectStatus = {}
  affectStrings = {}
  affectStartTimes = {}

  for pc = 1, 4 do
    affectStatus[pc] = {}
    affectStrings[pc] = ""
    affectStartTimes[pc] = {}
    for spellName, _ in pairs( spellInfo ) do
      affectStatus[pc][spellName] = false
      affectStartTimes[pc][spellName] = nil
    end
  end
end

-- Update affect status to true and modify affect string
function applyAffect( spellName, pc )
  if affectStatus[pc] and spellInfo[spellName] then
    if not affectStatus[pc][spellName] then
      affectStatus[pc][spellName] = true
      affectStrings[pc] = affectStrings[pc] .. spellInfo[spellName].char
      affectStartTimes[pc][spellName] = getStopWatchTime( "timer" )
    end
  else
    cecho( f "\n<orange_red>Invalid applyAffect: {spellName} for PC{pc}<reset>" )
  end
end

function applyAffectTrigger()
  local keyword = matches[2]
  local appliedAffect = affectKeywords[keyword]
  local affectColor, affectEmoji = spellInfo[appliedAffect].color, spellInfo[appliedAffect].char
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

-- Update affect status to false and modify affect string; called by 'remove' triggers
function removeAffect( spellName, pc )
  if affectStatus[pc] and spellInfo[spellName] then
    if affectStatus[pc][spellName] then
      local endTime = getStopWatchTime( "timer" )
      local startTime = affectStartTimes[pc][spellName]
      if startTime then
        local duration = endTime - startTime
        spellInfo[spellName].duration = duration -- Update the duration in spellInfo
      end
      affectStatus[pc][spellName] = false
      local charToRemove = spellInfo[spellName].char
      affectStrings[pc] = affectStrings[pc]:gsub( charToRemove, '', 1 )
    end
  else
    cecho( f "\n<orange_red>Invalid removeAffect: {spellName} for PC{pc}<reset>" )
  end
end

function removeAffectTrigger()
  local keyword = matches[2]
  local removedAffect = affectKeywords[keyword]
  local affectColor, affectEmoji = spellInfo[removedAffect].color, spellInfo[removedAffect].char
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

initializeAffectTracking()

--[[
GitHub Copilot, ChatGPT notes:
Collaborate on Lua 5.1 scripts for Mudlet in VSCode. Use f-strings, camelCase, UPPER_CASE constants.
Prioritize performance, optimization, and modular design. Provide debugging output with cecho.
Be critical, suggest improvements, don't apologize for errors.
Respond concisely, treat me as a coworker.
]]
