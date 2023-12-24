-- The affects we want to track; set this to "save" in Variables to maintain durations between sessions
affectInfo = affectInfo or {
  ["Sanctuary"] = {duration = nil, cost = 50},
  ["Bless"] = {duration = nil, cost = 5},
  ["Fury"] = {duration = nil, cost = 60},
  ["Armor"] = {duration = nil, cost = 5},
}


-- "Up" and "down" messages for each affect
affectMessages = {
  ["You start glowing."]                     = {affect = "Sanctuary", state = true},
  ["The white aura around your body fades."] = {affect = "Sanctuary", state = false},
  ["You feel righteous."]                    = {affect = "Bless", state = true},
  ["You feel less righteous."]               = {affect = "Bless", state = false},
  ["You feel very angry."]                   = {affect = "Fury", state = true},
  ["You calm down."]                         = {affect = "Fury", state = false},
  ["You feel someone protecting you."]       = {affect = "Armor", state = true},
  ["You are not Armor."]                     = {affect = "Armor", state = false},
}

-- Highlights for console output
affColor       = "<gold>"
upColor        = "<chartreuse>"
downColor      = "<firebrick>"


-- Create the structures & triggers for tracking affects
function initializeAffectTracking()
  affectInfo = {}
  maxAffectNameLength = 0

  -- Create an affect "object" for each affect
  for _, affect in ipairs( affectInfo ) do
    affectInfo[affect] = {
      state     = false,
      startTime = nil,
      endTime   = nil,
      duration  = nil
    }
    -- Keep track of the longest affect name for formatting later
    maxAffectNameLength = math.max( maxAffectNameLength, #affect )
  end
  createStatusTriggers()
end

-- We captured an affect message; update the corresponding affectInfo entry
function updateAffectStatus( message )
  local msgData = affectMessages[message]

  if msgData then
    local affect, state = msgData.affect, msgData.state
    local currentTime = os.time()
    local fgc = "dim_grey"

    if state then
      -- Affect is applied
      affectInfo[affect].state = true
      affectInfo[affect].startTime = currentTime
      affectInfo[affect].endTime = nil
      fgc = "chartreuse"
    else
      -- Affect expired
      affectInfo[affect].endTime = currentTime
      local affectDuration = currentTime - affectInfo[affect].startTime
      affectInfo[affect].state = false
      affectInfo[affect].startTime = nil
      if not affectInfo[affect].duration then
        affectInfo[affect].duration = affectDuration
      end
      cecho( f " [<dark_orange>{affectDuration}<reset>s]" )
      fgc = "firebrick"
    end
    -- Highlight the message itself
    selectString( line, 1 )
    fg( fgc )
    resetFormat()
  end
end

-- At load, iterate the affectMessages table and create corresponding triggers for each message
function createStatusTriggers()
  for affectMessage, _ in pairs( affectMessages ) do
    -- Get a regex pattern for the status message
    local affectRegex = createLineRegex( affectMessage )

    -- Make a code string to invoke the update function w/ the message
    local affectCode = f "updateAffectStatus([[{affectMessage}]])"

    -- Create the alias
    tempRegexTrigger( affectRegex, affectCode )
  end
end

function displayAffectStatus()
  local affectStrings = {}
  local longestAffect = maxAffectNameLength + 5

  for affect, info in pairs( affectInfo ) do
    local statusText = info.state and f "{upColor}UP<reset>" or f "{downColor}down<reset>"
    local durationText = affectInfo[affect].duration and f " [<dark_orange>{affectInfo[affect].duration}<reset>s]" or ""
    local padding = string.rep( " ", maxAffectNameLength - #affect )
    table.insert( affectStrings, f "{affColor}{affect}{padding}<reset> : {statusText}{durationText}" )
  end
  displayBox( affectStrings, longestAffect )
end
