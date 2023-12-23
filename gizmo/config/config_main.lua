cecho( f '\n\t<dark_violet>config_main.lua<reset>: globals & tables exclusive to the main session' )

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

nadjaClones = nil
laszloClones = nil

-- Raise to send warning messages to the info window
registerAnonymousEventHandler( [[eventWarn]], [[show_warning]] )

-- Other sessions use this event to pass their data into the pcStatus table


registerAnonymousEventHandler( [[event_pcStatus_prompt]], [[pcStatusPromptEvent]] )



registerAnonymousEventHandler( [[event_pcStatus_score]], [[pcStatusScoreEvent]] )
registerAnonymousEventHandler( [[event_pcStatus_room]], [[pcStatusRoomEvent]] )

enableTrigger( "Group XP" )
enableTrigger( "gather" )
enableTrigger( "Tank Condition (automira)" )
enableTrigger( "Main Format" )
disableTrigger( "Alt Gags" )
