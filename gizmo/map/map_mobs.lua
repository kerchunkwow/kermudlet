function getMob( rNumber )
  -- Convert rNumber to a number in case it's passed as a string
  rNumber = tonumber( rNumber )

  -- Find mob in mobData
  for _, mob in ipairs( mobData ) do
    if mob.rNumber == rNumber then
      return mob
    end
  end
  cecho( string.format( "\nMob with rNumber <orange>%d<reset> not found.", rNumber ) )
  return nil
end

-- Display mob details given a specific rNumber
function displayMob( rNumber )
  local mob = getMob( rNumber )
  if not mob then
    cecho( string.format( "\nMob with rNumber <orange>%d<reset> not found.", rNumber ) )
    return
  end
  local NC = "<dark_orange>"
  local SC = "<royal_blue>"
  local DC = "<gold>"
  local RC = "<reset>"
  local FC = "<maroon>"
  local PC = "<dark_violet>"

  local lng, shrt, kws = mob.longDescription, mob.shortDescription, mob.keywords
  cecho( string.format( "\n%s%s%s", SC, lng, RC ) )
  cecho( string.format( "\n  %s%s%s (%s%s%s)", SC, shrt, RC, SC, kws, RC ) )

  local hp, xp = mob.health, mob.xp
  cecho( string.format( "\n  HP: %s%s%s  XP: %s%s%s  (%s%.2f%s xp/hp)", NC, expandNumber( hp ), RC, NC,
    expandNumber( xp ),
    RC, DC, mob.xpPerHealth, RC ) )

  local gp = mob.gold
  cecho( string.format( "\n  Gold: %s%s%s  (%s%.2f%s gp/hp)", NC, expandNumber( gp ), RC, DC, mob.goldPerHealth, RC ) )

  local dn, ds, dm, hr = mob.damageDice, mob.damageSides, mob.damageModifier, mob.hitroll
  cecho( string.format( "\n  Dam: %s%dd%d+%d+%d%s  (%s%.2f%s avg)", NC, dn, ds, dm, hr, RC, DC, mob.averageDamage, RC ) )

  local flg, aff = mob.flags, mob.affects
  cecho( string.format( "\n  Flags: %s%s%s", FC, flg, RC ) )
  cecho( string.format( "\n  Affects: %s%s%s", FC, aff, RC ) )

  -- Printing special attacks
  if mob.specialAttacks and #mob.specialAttacks > 0 then
    cecho( "\n  Special Attacks:" )
    for _, attack in ipairs( mob.specialAttacks ) do
      local ac, ad, as, am, ah = attack.chance, attack.damageDice, attack.damageSides, attack.damageModifier,
          attack.hitroll
      local avd = ac * averageDice( ad, as, am ) / 100
      cecho( string.format( "\n    %s%d%% @ %dd%d+%d+%d%s (%s%.2f%s avg)", PC, ac, ad, as, am, ah, RC, DC, avd, RC ) )
    end
  end
end

function loadAllMobs()
  local sql = "SELECT * FROM Mob"
  local cursor, conn, env = getCursor( sql )

  if not cursor then
    print( "Error fetching mobs from database" )
    return
  end
  local mob = cursor:fetch( {}, "a" )
  while mob do
    -- Initialize the mob entry with database columns
    local mobEntry = {
      rNumber          = tonumber( mob.rNumber ),
      shortDescription = mob.shortDescription,
      longDescription  = mob.longDescription,
      keywords         = mob.keywords,
      level            = tonumber( mob.level ),
      health           = tonumber( mob.health ),
      ac               = tonumber( mob.ac ),
      gold             = tonumber( mob.gold ),
      xp               = tonumber( mob.xp ),
      alignment        = tonumber( mob.alignment ),
      flags            = mob.flags,
      affects          = mob.affects,
      damageDice       = tonumber( mob.damageDice ),
      damageSides      = tonumber( mob.damageSides ),
      damageModifier   = tonumber( mob.damageModifier ),
      hitroll          = tonumber( mob.hitroll ),
      roomVNumber      = tonumber( mob.roomVNumber ),
      specialProcedure = mob.specialProcedure,
      -- Calculated fields
      averageDamage    = nil, -- To be calculated
      xpPerHealth      = mob.xp / mob.health,
      goldPerHealth    = mob.gold / mob.health,
      -- Placeholder for special attacks
      specialAttacks   = {}
    }

    -- Calculate average damage
    mobEntry.averageDamage = averageDice( mobEntry.damageDice, mobEntry.damageSides, mobEntry.damageModifier )

    -- Load special attacks corresponding to this mob
    local saSql = string.format( "SELECT * FROM SpecialAttacks WHERE rNumber = %d", mobEntry.rNumber )
    local saCursor = conn:execute( saSql )
    if saCursor then
      local sa = saCursor:fetch( {}, "a" )
      while sa do
        table.insert( mobEntry.specialAttacks, {
          chance = tonumber( sa.chance ),
          damageDice = tonumber( sa.damageDice ),
          damageSides = tonumber( sa.damageSides ),
          damageModifier = tonumber( sa.damageModifier ),
          averageDamage = sa.chance * averageDice( sa.damageDice, sa.damageSides, sa.damageModifier ) / 100,
          hitroll = tonumber( sa.hitroll ),
          target = sa.target,
          type = sa.type,
          description = sa.description
        } )
        sa = saCursor:fetch( sa, "a" )
      end
      saCursor:close()
    end
    table.insert( mobData, mobEntry )
    mob = cursor:fetch( mob, "a" )
  end
  cursor:close()
  conn:close()
  env:close()
end

-- Global "master table" to hold all mob data
mobData = {}
-- Populate the table with all mob data including special attacks & derived values
loadAllMobs()
