-- For now we're only using mobs in the Main session
if SESSION == 1 then
  -- Global "master table" to hold all mob data
  mobData = {}
  -- Populate the table with all mob data including special attacks & derived values (after all scripts are done loading)
  tempTimer( 0, [[loadAllMobs()]] )
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
    local roomUserData = searchRoomUserData( "roomVNumber", tostring( mob.roomVNumber ) )
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
      -- If the room the mob was in exists in our Map, we can look up it's R-Number (-1 if it's not Mapped yet)
      roomRNumber      = (roomUserData and roomUserData[1]) or nil,
      areaRNumber      = nil,
      areaName         = "Unknown",
      specialProcedure = mob.specialProcedure,
      -- Calculated fields
      averageDamage    = nil,       -- TBD
      xpPerHealth      = nil,       -- TBD
      goldPerHealth    = nil,       -- TBD
      area             = "Unknown", -- TBD
      -- Placeholder for special attacks
      specialAttacks   = {},
    }
    if mobEntry.roomRNumber then
      mobEntry.areaName, mobEntry.areaRNumber = getRoomAreaTrue( mobEntry.roomVNumber )
    end
    -- Calculate experience and gold per health w/ SANCT = 2x Health
    local mhp = mob.health
    if string.find( mob.affects, 'SANCTUARY' ) then
      mobEntry.xpPerHealth   = mob.xp / (mhp * 2)
      mobEntry.goldPerHealth = mob.gold / (mhp * 2)
    else
      mobEntry.xpPerHealth   = mob.xp / mhp
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

-- Function to find and display mobs matching a given string in their descriptions
-- Will display multiple mobs; searches against both short and long descriptions
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

-- In 'stat' blocks, mob rooms are given as V-Number; we convert that to the corresponding R-Number by searching the map's user
-- data; the Room's R-Number gives us the R-Number of the Area it's in which we use to look up the Area's name
function getRoomAreaTrue( roomVNumber )
  local roomRNumber = searchRoomUserData( "roomVNumber", tostring( roomVNumber ) )[1]
  if roomRNumber then
    local areaRNumber = getRoomArea( roomRNumber )
    local areaName    = getRoomAreaName( areaRNumber )
    return areaName, areaRNumber
  end
  return "Unknown", -1
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
  local arn, arid      = mob.areaName, mob.areaRNumber

  cout( "[{NC}{rNumber}{RC}]" )
  cout( "  {SC}{lng}{RC}" )
  cout( "  {SC}{shrt}{RC} ({SC}{kws}{RC})" )
  cout( "  Area: {SC}{arn}{RC} ({NC}{arid}{RC})" )
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

-- Given the rNumber of a reference mob, print all other known mobs in the same Area
function displayMobArea( rNumber )
  referenceArea = getMob( rNumber ).areaRNumber
  for _, mob in ipairs( mobData ) do
    if mob.area == referenceArea then
      displayMob( mob.rNumber )
    end
  end
end

-- Display all mobs similar to the specified reference mob relative to a given attribute;
-- Scale determines the degree of similarity to display (e.g., 0.2 = +/- 20% of the reference value)
function findMobsLike( rNumber, attr, scale )
  -- Retrieve the reference mob
  local referenceMob = getMob( rNumber )
  if not referenceMob then
    iout( "No mob with rNumber {EC}" .. rNumber .. "{RC}" )
    return
  end
  -- Determine the comparison value and range based on attr
  local referenceValue = referenceMob[attr]
  local minValue = referenceValue * (1 - scale)
  local maxValue = referenceValue * (1 + scale)

  -- Additional XP criteria for non-'xp' attributes
  local xpMinValue = referenceMob.xp * (1 - scale)

  -- Find and display similar mobs
  for _, mob in ipairs( mobData ) do
    local mobValue = mob[attr]
    -- Adjust for 'damage' attribute to use averageDamage
    if attr == 'damage' then
      mobValue = mob.averageDamage
    end
    -- Check against minValue and maxValue for the specified attribute
    local withinRange = (mobValue >= minValue and mobValue <= maxValue)
    -- For 'xp' attribute, compare directly; for others, ensure mob's xp is also above the xpMinValue
    local xpCondition = (attr == 'xp') or (mob.xp >= xpMinValue)

    if withinRange and xpCondition and mob.rNumber ~= rNumber then
      displayMob( mob.rNumber )
    end
  end
end

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

-- Display the "best" mobs based on certain metrics; currently defaults to experience per health or xpph
-- Kind of built on an older design of mob data management; definitely a better way to do this
local function displayTopMobs( param )
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
