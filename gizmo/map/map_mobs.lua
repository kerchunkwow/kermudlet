function displayMob( rNumber )
  local NC = "<dark_orange>"
  local SC = "<royal_blue>"
  local DC = "<gold>"
  mob = getMob( rNumber )
  local lng, shrt, kws = mob.longDescription, mob.shortDescription, mob.keywords
  cecho( f "\n{SC}{lng}{R}" )
  cecho( f "\n  {SC}{shrt}{R} ({SC}{kws}{R})" )
  local hp, xp = mob.health, mob.xp
  local xpph = round( (xp / hp), 0.05 )
  cecho( f "\n  HP: {NC}{expandNumber(hp)}{R}  XP: {NC}{expandNumber(xp)}{R}  ({DC}{xpph}{R} xp/hp)" )
  local gp = mob.gold
  local gpph = round( (gp / hp), 0.05 )
  cecho( f "\n  Gold: {NC}{expandNumber(gp)}{R}  ({DC}{gpph}{R} gp/hp)" )
  local dn, ds, dm, hr = mob.damageDice, mob.damageSides, mob.damageModifier, mob.hitroll
  local da = averageDice( dn, ds, dm )
  cecho( f "\n  Damage: {NC}{dn}d{ds}+{dm}+{hr}{R} ({DC}{da}{R} avg)" )
  local flg, aff = mob.flags, mob.affects
  cecho( f "\n  Flags: <maroon>{flg}{R}" )
  cecho( f "\n  Affects: <maroon>{aff}{R}" )
end

function getMob( rNumber )
  local sql = string.format( "SELECT * FROM Mob WHERE rNumber = %d", rNumber )
  local cursor, conn, env = getCursor( sql )

  if not cursor then
    cecho( f "\nError fetching mob with rNumber: {rNumber}\n" )
    return nil
  end
  local mob = {}
  local row = cursor:fetch( {}, "a" )

  if row then
    mob.rNumber          = tonumber( row.rNumber )
    mob.shortDescription = row.shortDescription
    mob.longDescription  = row.longDescription
    mob.keywords         = row.keywords
    mob.level            = tonumber( row.level )
    mob.health           = tonumber( row.health )
    mob.ac               = tonumber( row.ac )
    mob.gold             = tonumber( row.gold )
    mob.xp               = tonumber( row.xp )
    mob.alignment        = tonumber( row.alignment )
    mob.flags            = row.flags
    mob.affects          = row.affects
    mob.damageDice       = tonumber( row.damageDice )
    mob.damageSides      = tonumber( row.damageSides )
    mob.damageModifier   = tonumber( row.damageModifier )
    mob.hitroll          = tonumber( row.hitroll )
    mob.roomVNumber      = tonumber( row.roomVNumber )
    mob.specialProcedure = row.specialProcedure
  else
    cecho( f "\nNo mob found with rNumber: {rNumber}\n" )
  end
  -- Don't forget to close the cursor and connection
  cursor:close()
  conn:close()
  env:close()

  return mob
end
