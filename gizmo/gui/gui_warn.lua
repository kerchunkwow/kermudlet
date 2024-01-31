-- This local function helps create "code strings" from the messages in the warning_messages
-- table (session_common) for later posting to the Info window
local function createWarningCalls()
  local calls = {}
  local warningMethod = nil

  if SESSION == 1 then
    warningMethod = "showWarning"
  else
    warningMethod = "raiseGlobalEvent"
  end
  for item, _ in pairs( warningMessages ) do
    calls[item] = f [[{warningMethod}( "eventWarn", {SESSION}, "{item}" )]]
  end
  return calls
end
--Create session-custom warning messages so they don't need to be created on demand
warning_calls = createWarningCalls()

-- Display a warning in the Info window; see Game Globals for a list of customizable messages
function showWarning( event_raised, pc, warning_type, extra_info )
  local msg = warningMessages[warning_type]

  cecho( "info", f "\n{fill(1)}{pcTags[pc]} {msg}" )

  -- If the warning is critical, play a sound as well (not too often)
  if not warningsDelayed and criticalWarnings[warning_type] then
    warningsDelayed = true
    tempTimer( 5, [[warningsDelayed = nil]] )
    playSoundFile( {name = "bloop.wav"} )
  end
end
