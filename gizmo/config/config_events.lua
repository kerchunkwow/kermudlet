-- Raise event_session_x to "pass" commands to sessions. raiseEvent is heard by the raising
-- session; raiseGlobalEvent is heard by all OTHER sessions (you must use both if you want
-- everyone to get the event).
--
-- raiseGlobalEvent( "event_session_2", [[send( "say This is session 2." )]] )
--
-- raiseEvent( "event_session_all", [[send( "say We are all sessions." )]] )
-- raiseGlobalEvent( "event_session_all", [[send( "say We are all sessions." )]] )

-- Called by the alias when you type 'ses cmd' or 'all cmd'

-- Handle "event_session_command" from other sessions
function sessionCommand( eventType, cmd )
  -- If you want to be able to send aliases between sessions, you must add them to this table so the session_command
  -- function will use expandAlias() instead of send().
  local sharedAliases = {
    ["lua"]  = true,
    ["cls"]  = true,
    ["putt"] = true,
    ["gett"] = true,
  }
  s                   = string.find( cmd, " " )
  local isAlias       = sharedAliases[cmd] or (s and sharedAliases[string.sub( cmd, 1, s - 1 )])

  if isAlias then
    expandAlias( cmd, false )
  else
    send( cmd, false )
  end
end

-- Parses session commands being one of 'all' or one of the character-specific aliases and
-- raises the corresponding event. This raises events for 'everyone' regardless of the
-- intended recipient; there's no downside to unhandled events.
function aliasSessionCommand()
  -- If the command is not for 'all', raise an event corresponding to the target session
  local targetSession = (matches[2] == "all") and matches[2] or sessionNumbers[matches[2]]
  local cmd           = matches[3]
  local eventType     = "event_command_" .. targetSession
  raiseEvent( eventType, cmd )
  raiseGlobalEvent( eventType, cmd )
end

-- The event by which alts report their prompt status to the main pcStatus table.
function pcStatusPromptEvent( raised_event, pc, hpc, hpm, mnc, mnm, mvc, mvm, tnk, trg )
  pcStatusPrompt( tonumber( pc ), tonumber( hpc ), tonumber( hpm ), tonumber( mnc ), tonumber( mnm ), tonumber( mvc ),
    tonumber( mvm ), tnk, trg )
end

-- The event by which alts report their score information to the main pcStatus table.
function pcStatusScoreEvent( raised_event, pc, dam, maxHP, hit, mnm, arm, mvm, mac, aln, exp, exh, exl, gld )
  pcStatusScore( tonumber( pc ), tonumber( dam ),
    tonumber( maxHP ), tonumber( hit ),
    tonumber( mnm ), tonumber( arm ),
    tonumber( mvm ), tonumber( mac ),
    tonumber( aln ), tonumber( exp ),
    tonumber( exh ), tonumber( exl ),
    tonumber( gld ) )
end

-- Event alts use to report their room name to the main session/UI.
function pcStatusRoomEvent( raised_event, pc, room )
  pcStatusRoom( pc, room )
end

-- Handle events from other sessions to update affect states (i.e., buffs/debuffs).
function pcStatusAffectEvent( raised_event, pc, affect, ticks )
  updateAffect( pc, affect, ticks )
  refreshAffectLabels( pc )
end

-- Register event handlers (i.e., map event types to function names)
local function registerEventHandlers()
  -- Every session listens for "event_session_all" in addition to their own "event_command_#" event.
  -- By interpolating the SESSION number, we assign each session an exclusive listener
  registerAnonymousEventHandler( [[event_command_all]], [[sessionCommand]] )
  registerAnonymousEventHandler( f [[event_command_{SESSION}]], [[sessionCommand]] )

  -- Events that update the pcStatus table or interact with the UI are exclusive to the main session
  if SESSION ~= 1 then return end
  registerAnonymousEventHandler( [[eventWarn]], [[showWarning]] )
  registerAnonymousEventHandler( [[event_pcStatusPrompt]], [[pcStatusPromptEvent]] )
  registerAnonymousEventHandler( [[eventPCStatusAffect]], [[pcStatusAffectEvent]] )
  registerAnonymousEventHandler( [[event_pcStatus_score]], [[pcStatusScoreEvent]] )
  registerAnonymousEventHandler( [[event_pcStatus_room]], [[pcStatusRoomEvent]] )
  registerAnonymousEventHandler( [[eventProfilesLoaded]], [[createGizmoGUI]] )
end
registerEventHandlers()
