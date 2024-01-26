nadjaClones = nil
laszloClones = nil

-- A set to keep track of items collected via auto-gathering, like resin
gathered = {}

sound_delayed = false

-- Send a warning if session [#] falls below [low%]
-- or loses more than [big%] in a single round.
hp_monitor = {
  --[#] = {low%, big%}
  [1] = {50, 20},
  [2] = {80, 10},
  [3] = {80, 10},
  [4] = {25, 20},
}

-- Raise 'eventWarn' to send warning messages to the info window
registerAnonymousEventHandler( [[eventWarn]], [[show_warning]] )

-- Raise these events to update the pcStatus table from alternate sessions
registerAnonymousEventHandler( [[event_pcStatus_prompt]], [[pcStatusPromptEvent]] )
registerAnonymousEventHandler( [[eventPCStatusAffect]], [[pcStatusAffectEvent]] )
registerAnonymousEventHandler( [[event_pcStatus_score]], [[pcStatusScoreEvent]] )
registerAnonymousEventHandler( [[event_pcStatus_room]], [[pcStatusRoomEvent]] )

-- Initial Trigger & Alias States
enableTrigger( "Group XP" )
enableTrigger( "gather" )
enableTrigger( "Tank Condition (automira)" )
enableTrigger( "Main Format" )
disableTrigger( "Alt Gags" )
