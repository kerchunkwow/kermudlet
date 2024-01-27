-- Display a warning in the Info window; see Game Globals for a list of customizable messages
function show_warning( event_raised, session, warning_type, extra_info )
  local msg = warning_messages[warning_type]

  cecho( "info", f "\n{fill(1)}{pc_tags[session]} {msg}" )

  -- If the warning is critical, play a sound as well (not too often)
  if critical_warnings[warning_type] and not warning_delayed then
    warning_delayed = true
    tempTimer( 5, [[warning_delayed = false]] )
    playSoundFile( {name = "bloop.wav"} )
  end
end

-- Doubleclick the room name to summon that pc ([COLIN])
function roomClicked( pc, event )
  send( f [[cast 'super summon' {pc}]] )
end

-- Click the hitpoint gauge to heal that pc ([COLIN])
function healthClicked( pc, event )
  -- Emergency heal if hp is critical
  if pcStatus[pc]["percentHP"] <= 33 then
    local best_heal = getBestHeal( pcStatus[1]["currentMana"] )
    send( f "cast '{best_heal}' {pcNames[pc]}" )
    return
  end
  -- Otherwise, heal more casually based on health deficit
  local hpd = pcStatus[pc]["maxHP"] - pcStatus[pc]["currentHP"]

  if hpd <= 50 then
    send( f "cast 'cure critic' {pcNames[pc]}" )
  else
    send( f "cast 'heal' {pcNames[pc]}" )
  end
end

-- Click the move gauge to refresh that pc with the opimal caster
function movesClicked( pc, pc_name, event )
  local mvd = (pcStatus[pc]["maxMoves"] - pcStatus[pc]["currentMoves"])
  optimalRefresh( pc_name )
end

-- Click the combat icon to have Nandor attempt a rescue ([COLIN])
function combatClicked( pc, pc_name, event )
  if (pc ~= 4) then
    expandAlias( f "nan rescue {pc_name}" )
  end
end
