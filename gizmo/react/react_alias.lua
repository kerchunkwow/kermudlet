cecho( f '\n  ' )

-- Get the optimal Magic-User for a cast
function getCasterMU( mana_cost )
  local nad_mn = pcStatus[2] and pcStatus[2]["currentMana"] or 0
  local las_mn = pcStatus[3] and pcStatus[3]["currentMana"] or 0

  if nad_mn < mana_cost and las_mn < mana_cost then
    cecho( "info", f "\n<dark_orange>Not enough mana." )
    return nil, 0
  elseif nad_mn >= las_mn then
    return "nad", nad_mn
  else
    return "las", las_mn
  end
end

-- Given a mana cost, return the most eligible caster
function getCaster( mana_cost )
  local col_mn = pcStatus[1] and pcStatus[1]["currentMana"] or 0

  local mu_caster, mu_mn = getCasterMU( mana_cost )

  if not mu_caster and col_mn < mana_cost then
    cecho( "info", f "\n<dark_orange>Not enough mana." )
    return nil, 0
  elseif mu_mn >= col_mn then
    return mu_caster, mu_mn
  else
    return "col", col_mn
  end
end

--Get the most powerful possible heal given an amount of mana
function getBestHeal( mana )
  -- Cure Critic [25]
  -- Heal        [50]
  -- Miracle     [100]

  if mana >= 100 then
    return "miracle"
  elseif mana >= 50 then
    return "heal"
  elseif mana >= 25 then
    return "cure critic"
  end
end

function aliasMiracle()
  send( f "cast 'miracle' {gtank}" )
end

function aliasManaTransfer()
  local battery, battery_mana = getMaxStat( "currentMana", 2, 3 )

  -- Transfer mana from the mage with the most mana to Colin
  if battery and battery_mana >= 50 then
    expandAlias( f [[{short_names[battery]} cast 'mana transfer' Colin]] )
  end
end

function aliasSmartHeal()
  local wounded, wounded_percent = getMinStat( "percentHP", 1, 2, 3, 4 )

  -- Someone in party is <= 80%, deal with them first
  if wounded_percent <= 90 then
    local victim  = pc_names[wounded]
    local deficit = pcStatus[wounded]["maxHP"] - pcStatus[wounded]["currentHP"]

    -- If they're missing <= 50hp, use cure critic to conserve mana
    if deficit <= 50 then
      send( f "cast 'cure critic' {victim}" )
    else
      send( f "cast 'heal' {victim}" )
    end
    -- Party's fine; check for tank
  elseif gtank then
    send( f "cast 'heal' {gtank}", false )
  end
end

-- Spend some MU mana -- pick the best caster and the best spell they can afford
function aliasMUDps()
  local caster, caster_mn = getMaxStat( "currentMana", 2, 3 )

  if caster then
    if caster_mn >= 100 then
      expandAlias( f [[{short_names[caster]} cast 'electric shock']] )
    elseif caster_mn >= 50 then
      expandAlias( f [[{short_names[caster]} cast 'lethal fire']] )
    end
  end
end

-- Find the best refresher for the job, then ask them to refresh the target.
function optimalRefresh( target )
  local caster, caster_mn = getMaxStat( "currentMana", 1, 2, 3 )

  if caster and caster_mn >= 25 then
    expandAlias( f [[{short_names[caster]} cast 'vitality' {target}]] )
  end
end

-- Given a stat string from the pcStatus table and an arbitrary set of pc indices,
-- figure out who has the most of that stat; e.g., get_max_stat( "currentMana", 1, 2, 3, 4 )
-- will return the pc with the most mana (and how much they have)
function getMaxStat( stat, ... )
  -- Initialize result
  local max_stat = -1
  local max_pc

  -- Iterate over the passed pc's, remembering the max
  for _, pc in ipairs( {...} ) do
    local next_stat = pcStatus[pc][stat]

    if next_stat > max_stat then
      max_stat = next_stat
      max_pc   = pc
    end
  end
  -- Return the pc index and stat value
  return max_pc, max_stat
end

-- Given a stat string from the pcStatus table and an arbitrary set of pc indices,
-- figure out who has the least of that stat; e.g., get_max_stat( "percentHP", 1, 2, 3, 4 )
-- will return the pc with the lowest health percentage
function getMinStat( stat, ... )
  -- Initialize results
  local min_stat
  local min_pc

  -- Iterate over the passed pc's, remembering the min
  for _, pc in ipairs( {...} ) do
    local next_stat = pcStatus[pc][stat]

    -- First pc is always the minimum
    if min_stat == nil then
      min_stat = next_stat
      min_pc   = pc
    else
      if next_stat < min_stat then
        min_stat = next_stat
        min_pc   = pc
      end
    end
  end
  -- Return the pc index and stat value
  return min_pc, min_stat
end

-- Create the party console, open chat & info windows
function aliasPlayGizmo()
  tempTimer( 0.5, [[openOutputWindows()]] )
  tempTimer( 1.5, [[createPartyConsole()]] )
end
