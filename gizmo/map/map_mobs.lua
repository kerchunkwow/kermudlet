-- Retrieve data about a specific mob from the global mobData table
function getMob( rNumber )
  -- Convert in case the parameter arrives as a string
  rNumber = tonumber( rNumber )
  -- Look up the mob
  for _, mob in ipairs( mobData ) do
    if mob.rNumber == rNumber then
      return mob
    end
  end
  -- No such mob
  return nil
end

-- Load all mobs from the Mob and SpecialAttacks Tables in the gizwrld.db database
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
      averageDamage    = nil,       -- TBD
      xpPerHealth      = nil,       -- TBD
      goldPerHealth    = nil,       -- TBD
      area             = "Unknown", -- TBD
      -- Placeholder for special attacks
      specialAttacks   = {},
    }

    local roomRNumber = searchRoomUserData( "roomVNumber", tostring( mob.roomVNumber ) )[1]
    if roomRNumber then mobEntry.area = getRoomAreaName( getRoomArea( roomRNumber ) ) end
    -- Calculate experience and gold per health w/ SANCT = 2x Health
    local mhp = mob.health
    if string.find( mob.affects, 'SANCTUARY' ) then
      mobEntry.xpPerHealth = mob.xp / (mhp * 2)
      mobEntry.goldPerHealth = mob.gold / (mhp * 2)
    else
      mobEntry.xpPerHealth = mob.xp / mhp
      mobEntry.goldPerHealth = mob.gold / mhp
    end
    -- Calculate average damage
    mobEntry.averageDamage = averageDice( mobEntry.damageDice, mobEntry.damageSides, mobEntry.damageModifier )

    -- Load special attacks corresponding to this mob
    local saSql = string.format( "SELECT * FROM SpecialAttacks WHERE rNumber = %d", mobEntry.rNumber )
    local saCursor = conn:execute( saSql )
    if saCursor then
      local sa = saCursor:fetch( {}, "a" )
      while sa do
        local savd = sa.chance * averageDice( sa.damageDice, sa.damageSides, sa.damageModifier ) / 100
        mobEntry.averageDamage = mobEntry.averageDamage + savd
        table.insert( mobEntry.specialAttacks, {
          chance         = tonumber( sa.chance ),
          damageDice     = tonumber( sa.damageDice ),
          damageSides    = tonumber( sa.damageSides ),
          damageModifier = tonumber( sa.damageModifier ),
          averageDamage  = savd,
          hitroll        = tonumber( sa.hitroll ),
          target         = sa.target,
          type           = sa.type,
          description    = sa.description
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

-- Display the "best" mobs based on certain metrics; currently defaults to experience per health or xpph
function displayTopMobs( param )
  -- param is currently unused; later can be used to display different metrics

  table.sort( mobData, function ( a, b )
    return a.xpPerHealth > b.xpPerHealth
  end )

  -- Display sorted mobs
  for _, mob in ipairs( mobData ) do
    local mxp = mob.xp
    if mxp >= 150000 and mob.averageDamage <= 100 then
      local xpph = mxp / mob.health
      local xpphstr = string.format( "<orange>%.2f<reset>", xpph )
      local shortstr = string.format( "<royal_blue>%s<reset>", mob.shortDescription )
      local xpphmob = string.format( "\n%s (%s)", shortstr, xpphstr )
      cecho( xpphmob )
    end
  end
end

-- Function to find and display mobs matching a given string in their descriptions
function findMob( searchString )
  -- Ensure searchString is lowercased for case-insensitive matching
  local searchLower = string.lower( searchString )
  local found = false

  for _, mob in ipairs( mobData ) do
    -- Convert descriptions to lower case to make the search case-insensitive
    local shortLower = string.lower( mob.shortDescription or "" )
    local longLower = string.lower( mob.longDescription or "" )

    -- Check if searchString is found in either shortDescription or longDescription
    if string.find( shortLower, searchLower ) or string.find( longLower, searchLower ) then
      -- Display this mob's information
      displayMob( mob.rNumber )
      found = true
    end
  end
  if not found then
    iout( "No mob matches {EC}{searchString}{RC}" )
  end
end

-- Display mob data given a specific mob's R-Number
function displayMob( rNumber )
  local mob = getMob( rNumber )
  if not mob then
    iout( "No mob matches {EC}{rNumber}{RC}" )
    return
  end
  local lng, shrt, kws = mob.longDescription, mob.shortDescription, mob.keywords
  local hp, xp, gp     = mob.health, mob.xp, mob.gold
  local xpph, gpph     = round( mob.xpPerHealth, 0.01 ), round( mob.goldPerHealth, 0.01 )
  local dn, ds, dm, hr = mob.damageDice, mob.damageSides, mob.damageModifier, mob.hitroll
  local avd            = round( mob.averageDamage, 0.01 )
  local flg, aff       = mob.flags, mob.affects
  local area           = mob.area

  cout( "[{NC}{rNumber}{RC}]" )
  cout( "  {SC}{lng}{RC}" )
  cout( "  {SC}{shrt}{RC} ({SC}{kws}{RC})" )
  cout( "  Area: {SC}{area}{RC}" )
  cout( "  HP: {NC}{hp}{RC}  XP: {NC}{xp}{RC}  ({DC}{xpph}{RC} xp/hp)" )
  cout( "  GP: {NC}{gp}{RC}  ({DC}{gpph}{RC} gp/hp)" )
  cout( "  Dam: {NC}{dn}d{ds}+{dm}+{hr}{RC}  ({DC}{avd}{RC} avg)" )
  cout( "  Flags: {FC}{flg}{RC}" )
  cout( "  Affects: {FC}{aff}{RC}" )

  -- Printing special attacks
  if mob.specialAttacks and #mob.specialAttacks > 0 then
    cecho( "\n  Special Attacks:" )
    for _, attack in ipairs( mob.specialAttacks ) do
      local ac, ad, as = attack.chance, attack.damageDice, attack.damageSides
      local am, ah     = attack.damageModifier, attack.hitroll
      local savd       = attack.averageDamage
      cout( "    {SC}{ac}% @ {NC}{ad}d{as}+{am}+{ah}{RC} ({DC}{savd}{RC} avg)" )
    end
  end
end

function findMobsLike( rNumber, attr, scale )
  -- Retrieve the reference mob
  local referenceMob = getMob( rNumber )
  if not referenceMob then
    print( string.format( "Mob with rNumber %d not found.", rNumber ) )
    return
  end
  -- Determine the comparison value and range based on attr
  local referenceValue = referenceMob[attr]
  if not referenceValue then
    print( string.format( "Attribute %s not found for mob %d.", attr, rNumber ) )
    return
  end
  local minValue = referenceValue * (1 - scale)
  local maxValue = referenceValue * (1 + scale)

  -- Adjust for 'damage' attribute to use averageDamage
  if attr == 'damage' then
    referenceValue = referenceMob.averageDamage
    minValue = referenceValue * (1 - scale)
    maxValue = referenceValue * (1 + scale)
  end
  print( string.format( "Mobs similar to %d (%s) within scale factor %s:", rNumber, attr, scale ) )

  -- Find and display similar mobs
  for _, mob in ipairs( mobData ) do
    local mobValue = mob[attr]
    -- Adjust for 'damage' attribute
    if attr == 'damage' then
      mobValue = mob.averageDamage
    end
    if mobValue >= minValue and mobValue <= maxValue and mob.rNumber ~= rNumber then
      print( string.format( "Mob R-Number: %d, %s: %s, Area: %s", mob.rNumber, attr, mobValue, mob.area ) )
    end
  end
end

-- Global "master table" to hold all mob data
mobData = {}
-- Populate the table with all mob data including special attacks & derived values
loadAllMobs()

-- Print all mobs that have at least one entry in the SpecialAttacks table
local function displayAllSpecs()
  for _, mob in ipairs( mobData ) do
    if mob.specialAttacks and #mob.specialAttacks > 0 and mob.averageDamage <= 500 then
      displayMob( mob.rNumber )
    end
  end
end

-- Print all "Flags" and "Affects" for all mobs in the mobData table
local function printFlags()
  for _, mob in ipairs( mobData ) do
    cout( "{mob.affects}" )
  end
end
