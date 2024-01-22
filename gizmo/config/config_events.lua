cecho( f '\n  <coral>config_events.lua<dim_grey>: this is how sessions communicate with one another' )

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
  -- Use the isAlias table to allow sessions to pass aliases as commands
  s = string.find( cmd, " " )
  local isAlias_cmd = isAlias[cmd] or (s and isAlias[string.sub( cmd, 1, s - 1 )])

  if isAlias_cmd then
    expandAlias( cmd, false )
  else
    send( cmd, false )
  end
end

-- Parses session commands being one of 'all' or one of the character-specific aliases and
-- raises the corresponding event. This raises events for 'everyone' regardless of the
-- intended recipient; there's no downside to unhandled events.
function aliasSessionCommand()
  local targetSession = (matches[2] == "all") and matches[2] or session_numbers[matches[2]]
  local cmd           = matches[3]
  local eventType     = "event_command_" .. targetSession

  raiseEvent( eventType, cmd )
  raiseGlobalEvent( eventType, cmd )
end

-- The event by which alts report their prompt status to the main pcStatus table.
function pcStatusPromptEvent( raised_event, pc, hpc, mnc, mvc, tnk, trg )
  pcStatusPrompt( tonumber( pc ), tonumber( hpc ), tonumber( mnc ), tonumber( mvc ), tnk, trg )
end

-- The event by which alts report their score information to the main pcStatust able.
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
function pcStatusAffectEvent( raised_event, pc, affect, state )
  if state then
    applyAffect( affect, pc )
  else
    removeAffect( affect, pc )
  end
end
