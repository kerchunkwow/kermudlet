-- Alts don't have direct access to the pcStatus table, but we give them a smaller table to check their "last status"
-- so we're not sending unnecessary update events when their stats haven't changed.
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
