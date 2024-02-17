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
    expandAlias( f [[{sessionAliases[battery]} cast 'mana transfer' Colin]] )
  end
end

function aliasSmartHeal()
  local wounded, wounded_percent = getMinStat( "percentHP", 1, 2, 3, 4 )

  -- Someone in party is <= 80%, deal with them first
  if wounded_percent <= 90 then
    local victim  = pcNames[wounded]
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
      expandAlias( f [[{sessionAliases[caster]} cast 'electric shock']] )
    elseif caster_mn >= 50 then
      expandAlias( f [[{sessionAliases[caster]} cast 'lethal fire']] )
    end
  end
end

-- Find the best refresher for the job, then ask them to refresh the target.
function optimalRefresh( target )
  -- Ensure the spell exists in the partySpells table and has assigned casters
  if partySpells['vitality'] and #partySpells['vitality'] > 0 then
    local caster, casterMana = getMaxStat( "currentMana", unpack( partySpells['vitality'] ) )
    if caster and casterMana >= 25 then
      cecho( "info", f "\n<yellow_green>Refreshing {target} with {sessionAliases[caster]}" )
      expandAlias( f [[{sessionAliases[caster]} cast 'vitality' {target}]] )
    end
  else
    cecho( "info", "Your party can't cast vitality." )
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

function aliasGetPath()
  local dst = matches[2]
  local pathString = nil
  if tonumber( dst ) then
    pathString = getFullDirs( currentRoomNumber, tonumber( dst ) )
  end
  if pathString then
    cecho( f "<yellow_green>{pathString}" )
  end
end

-- Cast the specified spell at a command-line target or myself by default
function aliasCastBuff( spell )
  local trg = matches[2] or pcName
  send( f [[cast '{spell}' {trg}]] )
end

-- Called by alias 'rr' to attempt a full recall & send a critical warning if no scrolls are available
function aliasReciteRecalls()
  local eventMethod = SESSION == 1 and 'raiseEvent' or 'raiseGlobalEvent'
  local noRecallCode = f "{eventMethod}( 'eventWarn', {SESSION}, 'norecall' )"
  createTemporaryTrigger( "norecalls", "does not contain", noRecallCode, 20 )
  send( 'recite recall' )
  send( f 'get recall {container}' )
end

-- Cycle through "item query" modes, modifying what level of detail to include in item queries (appended in game)
function toggleItemQueryMode()
  if not itemQueryMode then itemQueryMode = 0 else itemQueryMode = itemQueryMode + 1 end
  if itemQueryMode > 1 then itemQueryMode = 0 end
  cecho( "info", f "\n<orange>itemQueryMode toggled: {itemQueryMode}" )
end

function aliasSetPlayerRoom()
  setPlayerRoom( tonumber( matches[2] ) )
end

-- If you haven't installed a package with basic lib aliases, create the important ones
local function createLibAliasesOnce()
  if exists( 'lib', 'alias' ) == 0 then
    cecho( f "\n<medium_orchid>lib Alias group not found; creating...<reset>" )
    permAlias( 'lib', 'gizmudlet', '', '' )
    permAlias( 'Run Lua File (rf)', 'lib', '^rf (.+?)(?:\\.lua)?$', 'runLuaFile( matches[2] )' )
    permAlias( 'Run Lua (lua)', 'lib', '^lua (.*)$', 'runLuaLine( matches[2] )' )
    permAlias( 'Clear Screen (cls)', 'lib', '^cls$', 'clearScreen()' )
    permAlias( 'Simulate Output (sim)', 'lib', '^sim (.+)$', 'simulateOutput()' )
    permAlias( 'Save Layout (swl)', 'lib', '^swl$', 'saveWindowLayout()' )
    permAlias( 'List Fonts (lfonts)', 'lib', '^lfonts$', 'listFonts()' )
    permAlias( 'Print Variables (pvars)', 'lib', '^pvars$', 'printVariables()' )
    permAlias( 'Reload (reload)', 'lib', '^reload$', [[runLuaFile(f'mudlet_init.lua')]] )
    permAlias( 'Help (help)', 'lib', '^#help$', 'getHelp()' )
  end
end

createLibAliasesOnce()
