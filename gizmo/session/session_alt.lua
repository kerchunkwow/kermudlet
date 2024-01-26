pc_last_status = {}
function resetLastStatus()
  pc_last_status["currentHP"]    = -1
  pc_last_status["currentMana"]  = -1
  pc_last_status["currentMoves"] = -1
  pc_last_status["tank"]         = "nil"
  pc_last_status["target"]       = "nil"
end

resetLastStatus()

enableTrigger( "Alt Gags" )

disableTrigger( "Group XP" )

disableTrigger( "Tank Condition (automira)" )
disableTrigger( "Main Format" )
disableTrigger( "gather" )
disableTrigger( 'Locate Resin' )
disableTrigger( 'Exits Line' )

-- Aliases that Alts don't need (and might not work)
disableAlias( 'Clone Gear (doclone)' )
disableAlias( 'Roll Dice (roll)' )
disableAlias( 'Nandor Gear Swap (nanswap)' )
disableAlias( 'Play Gizmo (giz)' )
