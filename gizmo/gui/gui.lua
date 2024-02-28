-- Doubleclick the room name to summon that pc
function roomClicked( pc, pcName, event )
  cecho( "info", f "\nGot double-click on <royal_blue>Room<reset> @ {pcTags[pc]}" )
  send( f [[cast 'super summon' {pcName}]] )
end

-- Click the hitpoint gauge to heal that pc ([COLIN])
function healthClicked( pc, pcName, event )
  cecho( "info", f "\nGot click on <olive_drab>Health<reset> @ {pcTags[pc]}" )
  -- Emergency heal if hp is critical
  if pcStatus[pc]["percentHP"] <= 33 then
    local optimalHealingSpell = getBestHeal( pcStatus[1]["currentMana"] )
    send( f "cast '{optimalHealingSpell}' {pcNames[pc]}" )
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
function movesClicked( pc, pcName, event )
  cecho( "info", f "\nGot click on <gold>Moves<reset> @ {pcTags[pc]}" )
  local mvd = (pcStatus[pc]["maxMoves"] - pcStatus[pc]["currentMoves"])
  optimalRefresh( pcName )
end

-- Click the combat icon to have Nandor attempt a rescue ([COLIN])
function combatClicked( pc, pcName, event )
  if (pc ~= 4) then
    expandAlias( f "nan rescue {pcName}" )
  end
end

function affectsClicked( pc, pcName, event )
  cecho( "info", f "\nGot click on <violet>Affects<reset> @ {pcTags[pc]}" )
end
