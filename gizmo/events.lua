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
function sessionCommand( event_name, cmd )
  -- Use the is_alias table to allow sessions to pass aliases as commands
  s = string.find( cmd, " " )
  local is_alias_cmd = is_alias[cmd] or (s and is_alias[string.sub( cmd, 1, s - 1 )])

  if is_alias_cmd then
    expandAlias( cmd, false )
  else
    send( cmd, false )
  end
end --function

-- Parses session commands being one of 'all' or one of the character-specific aliases and
-- raises the corresponding event. This raises events for 'everyone' regardless of the
-- intended recipient; there's no downside to unhandled events.
function aliasSessionCommand()
  local cmd_trg      = (matches[2] == "all") and matches[2] or session_numbers[matches[2]]
  local cmd_to_raise = matches[3]
  local evt_to_raise = "event_command_" .. cmd_trg

  raiseEvent( evt_to_raise, cmd_to_raise )
  raiseGlobalEvent( evt_to_raise, cmd_to_raise )
end --function

-- The event by which alts report their prompt status to the main pcStatus table.
function PCStatusPromptEvent( raised_event, pc, hpc, mnc, mvc, tnk, trg )
  pcStatusPrompt( tonumber( pc ), tonumber( hpc ), tonumber( mnc ), tonumber( mvc ), tnk, trg )
end

-- The event by which alts report their score information to the main pcStatust able.
function PCStatusScoreEvent( raised_event, pc, dam, maxHP, hit, mnm, arm, mvm, mac, aln, exp, exh, exl, gld )
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
