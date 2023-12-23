cecho( f '\n\t<dark_violet>config_alt.lua<reset>: define global tables & variables exclusive to alts' )

pc_last_status = {}
function resetLastStatus()
  pc_last_status["currentHP"]    = -1
  pc_last_status["currentMana"]  = -1
  pc_last_status["currentMoves"] = -1
  pc_last_status["tank"]         = "nil"
  pc_last_status["target"]       = "nil"
end

resetLastStatus()

disableTrigger( "Group XP" )
disableTrigger( "gather" )
disableTrigger( "Tank Condition (automira)" )
disableTrigger( "Main Format" )
enableTrigger( "Alt Gags" )
