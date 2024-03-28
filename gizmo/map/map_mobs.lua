-- For now we're only using mobs in the Main session
if SESSION == 1 and not mobData then
  -- Global "master table" to hold all mob data
  mobData = {}
  -- Global table to hold fame data (maps mob shorts to fame values)
  fameData = {}
  -- After scripts are loaded, call loadAllMobs to populate mobData
  tempTimer( 0, [[loadAllMobs()]] )
  tempTimer( 0, [[loadFameData()]] )
end
-- A global table to store the IDs of the current area's temporary mob triggers
areaMobTriggers = areaMobTriggers or {}

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
      specialProcedure = mob.specialProcedure,
      -- Fields to calculate or lookup later
      meleeDamage      = 0,   -- TBD for average melee damage
      specDamage       = 0,   -- TBD for damage from special attack (tables)
      xpPerHealth      = 0,   -- TBD
      goldPerHealth    = 0,   -- TBD
      roomRNumber      = nil, -- TBD
      areaRNumber      = nil, -- TBD
      areaName         = "Unknown",
      -- Placeholder for special attacks
      specialAttacks   = {},
      --tag              = createMobTag( mob.flags, mob.affects ),
    }
    -- See if the mob's logged R-Number corresponds to a mapped room and set Area data if so
    mobEntry.roomRNumber = getRoomRbyV( mobEntry.roomVNumber )
    if mobEntry.roomRNumber then
      mobEntry.areaRNumber = getRoomArea( mobEntry.roomRNumber )
      mobEntry.areaName    = getRoomAreaName( mobEntry.areaRNumber )
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
    mobEntry.meleeDamage = averageDice( mobEntry.damageDice, mobEntry.damageSides, mobEntry.damageModifier )

    -- Load special attacks corresponding to this mob
    local saSql = string.format( "SELECT * FROM SpecialAttacks WHERE rNumber = %d", mobEntry.rNumber )
    local saCursor = conn:execute( saSql )
    if saCursor then
      local sa = saCursor:fetch( {}, "a" )
      while sa do
        local savd = sa.chance * averageDice( sa.damageDice, sa.damageSides, sa.damageModifier ) / 100
        mobEntry.specDamage = mobEntry.specDamage + savd
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
  -- This function is only needed once at startup
  loadAllMobs = nil
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

-- Display mob data given a specific mob's R-Number
function displayMob( rNumber )
  local SPC = "<medium_orchid>" -- put this in config eventually
  local mob = getMob( rNumber )
  if not mob then
    iout( "No mob matches {EC}{rNumber}{RC}" )
    return
  end
  local lng, shrt, kws = mob.longDescription, mob.shortDescription, mob.keywords
  local hp, xp, gp     = mob.health, expandNumber( mob.xp ), expandNumber( mob.gold )
  local xpph, gpph     = round( mob.xpPerHealth, 0.01 ), round( mob.goldPerHealth, 0.01 )
  local dn, ds, dm, hr = mob.damageDice, mob.damageSides, mob.damageModifier, mob.hitroll
  local mavd           = round( mob.meleeDamage, 0.01 )
  local savd           = round( mob.specDamage, 0.01 )
  local tavd           = round( mob.meleeDamage + mob.specDamage, 0.01 )
  local flg, aff       = mob.flags, mob.affects
  local arn, arid      = mob.areaName, mob.areaRNumber
  local rmid           = mob.roomRNumber

  -- Format bonus special attack damage if it's present
  if savd > 0 then
    savd = f " + {SPC}{savd}{RC}"
  else
    savd = ""
  end
  cout( "[{NC}{rNumber}{RC}], (<royal_blue>{rmid}<reset>)" )
  cout( "  {SC}{lng}{RC}" )
  cout( "  {SC}{shrt}{RC} ({SC}{kws}{RC})" )
  cout( "  Area: {SC}{arn}{RC} ({NC}{arid}{RC})" )
  cout( "  HP: {NC}{hp}{RC}  XP: {NC}{xp}{RC}  ({DC}{xpph}{RC} xp/hp)" )
  cout( "  GP: {NC}{gp}{RC}  ({DC}{gpph}{RC} gp/hp)" )
  cout( "  Dam: {NC}{dn}d{ds} +{dm} +<medium_sea_green>{hr}{RC}{savd}{RC} ({DC}{tavd}{RC} avg)" )
  cout( "  Flags: {FC}{flg}{RC}" )
  cout( "  Affects: {FC}{aff}{RC}" )

  -- Printing special attacks
  if mob.specialAttacks and #mob.specialAttacks > 0 then
    cecho( "\n  Special Attacks:" )
    for _, attack in ipairs( mob.specialAttacks ) do
      local ac, ad, as = attack.chance, attack.damageDice, attack.damageSides
      local am, ah     = attack.damageModifier, attack.hitroll
      local savdd      = attack.averageDamage
      cout( "    {NC}{ac}%{RC} @ {SPC}{ad}d{as} +{am} +{ah}{RC} ({SPC}{savdd}{RC} avg)" )
    end
  end
end

-- Display mobs within a given area as determined by input parameters
-- mobRNumber will display other mobs in the same area as the reference mob
-- areaRNumber will display all mobs in the specified area
-- deadliness will filter mobs to only display those that are deadly
function displayAreaMobs( mobRNumber, areaRNumber, deadliness )
  local referenceAreaRNumber

  -- Determine the display area
  if areaRNumber then
    referenceAreaRNumber = areaRNumber
  elseif mobRNumber then
    local mob = getMob( mobRNumber )
    if mob then
      referenceAreaRNumber = mob.areaRNumber
    else
      iout( "No mob found with id {NC}{mobRNumber}{RC} in displayMobArea()" )
      return
    end
  else
    referenceAreaRNumber = getRoomArea( CurrentRoomNumber )
  end
  -- Display mobs based on the determined area
  for _, mob in ipairs( mobData ) do
    if mob.areaRNumber == referenceAreaRNumber then
      if deadliness then
        if isMobDeadly( mob, 60 ) then
          displayMob( mob.rNumber )
        end
      else
        displayMob( mob.rNumber )
      end
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
    local mobDam = mob.meleeDamage + mob.specDamage
    local mobValue = mob[attr]
    -- Adjust for 'damage' attribute to use averageDamage
    if attr == 'damage' then
      mobValue = mobDam
    end
    -- Check against minValue and maxValue for the specified attribute
    local withinRange = (mobValue >= minValue and mobValue <= maxValue)
    -- For 'xp' attribute, compare directly; for others, ensure mob's xp is also above the xpMinValue
    local xpCondition = (attr == 'xp') or (mob.xp >= xpMinValue)

    if withinRange and xpCondition and mob.rNumber ~= rNumber and mobDam < 100 then
      displayMob( mob.rNumber )
    end
  end
end

-- Deadly mobs are aggressive and exceed the specified damage threshold
function isMobDeadly( mob, threshold )
  local aggro = string.find( mob.flags, "AGGRESSIVE" )
  local dam   = mob.meleeDamage
  -- If the mob is FURIED, double it's melee damage
  if string.find( mob.affects, 'FURY' ) then
    dam = dam * 2
  end
  -- For mobs with DUAL, fudge another ~20%
  if string.find( mob.affects, 'DUAL' ) then
    dam = dam * 1.2
  end
  -- Then add any special attack damage into the mix
  dam = dam + mob.specDamage
  return aggro and dam > threshold
end

-- Create a temporary trigger for all mobs in the current area, matching keywords to long descriptions
function loadMobTriggers()
  -- Kill any existing triggers and reset the table
  resetMobTriggers()

  -- Create a temporary trigger for each mob in the current area
  for _, mob in ipairs( mobData ) do
    if mob.areaRNumber == CurrentAreaNumber then
      -- Mob's in-game appearance
      local mobLong, mobShort = mob.longDescription, mob.shortDescription
      -- Keywords for interacting with mobs
      local mobKeys = split( mob.keywords, " " )
      local keywordFound = false

      -- Iterate through the keywords looking for one that appears in the mob's long description
      for _, keyword in ipairs( mobKeys ) do
        -- Keywords are case insensitive, but we need to preserve the original case for the trigger pattern
        local foundStart, foundEnd = mobLong:lower():find( keyword:lower() )
        if foundStart then
          local actualMatch = mobLong:sub( foundStart, foundEnd )

          -- Create a regex from the mob's long description, then surround the matched keyword with parentheses so it can be captured
          local mobPattern = createLineRegex( mobLong )
          local escapedActualMatch = actualMatch:gsub( "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1" )
          mobPattern = mobPattern:gsub( escapedActualMatch, "(" .. escapedActualMatch .. ")", 1 )

          -- Pass the mob's tag to the matching trigger so it can be appended in-game
          local triggerID = tempRegexTrigger( mobPattern, [[targetMatch()]] )

          -- Hold the ID so we can kill previous triggers before loading new areas
          table.insert( areaMobTriggers, triggerID )

          keywordFound = true
          -- To validate triggers, feed the mob's long description
          --cfeedTriggers( mobLong )
          break
        end
      end
      if not keywordFound then
        -- Report on mob's whose long description does not include one of its keywords
        iout( "{EC}Missing keyword{RC}: {SC}{mobShort}{RC}" )
      end
    end
  end
end

-- This function creates a "tag" designed to appear after a mob's long description when players encounter
-- the mob in game; the tag will identify flags and affects of the mob that are not typically visible but
-- help the player understand the mob's behavior and abilities.
function createMobTag( flags, affects )
  local AC, FC, DC, SAC, SPC, STC = "<tomato>", "<orange_red>", "<dodger_blue>", "<gold>", "<deep_pink>", "<slate_grey>"
  local flagAttributes = {AGGRESSIVE = AC, FURY = FC, SANCTUARY = SAC, SPEC = SPC}
  local affectAttributes = {FURY = FC, DUAL = DC, SANCTUARY = SAC, STATUE = STC}

  local flagList = {}
  local affectList = {}

  -- Split the flags and affects strings into lists of attributes
  if flags then
    flagList = split( flags, " " )
  end
  if affects then
    affectList = split( affects, " " )
  end
  local tag = ""

  -- Iterate through flag attributes and add them to the tag string
  for _, flag in ipairs( flagList ) do
    local color = flagAttributes[flag]
    if color then
      tag = tag .. color .. flag:sub( 1, 1 ) .. "<reset>"
    end
  end
  -- Iterate through affect attributes and add them to the tag string
  for _, affect in ipairs( affectList ) do
    local color = affectAttributes[affect]
    if color then
      tag = tag .. color .. affect:sub( 1, 1 ) .. "<reset>"
    end
  end
  -- Wrap the tag string in square brackets (and add a leading space)
  if tag ~= "" then
    return " {" .. tag .. "}"
  else
    return ""
  end
end

-- Reset temporary mob triggers; use before loading new ones to avoid over-capping trigger limit
function resetMobTriggers()
  -- Kill any existing temporary mob triggers
  for _, id in ipairs( areaMobTriggers ) do
    killTrigger( id )
  end
  -- Re-initialize the table
  areaMobTriggers = {}
end

-- Called when a mob is encountered in the game which has a corresponding trigger
function targetMatch()
  -- Update markedTarget global which can be used elsewhere to interact with mobs (i.e., attacking, etc.)
  markedTarget = matches[2]

  -- Highlight the matching keyword on screen for visual distinction and to validate the trigger
  selectString( matches[2], 1 )
  setFgColor( 205, 92, 92 )
end

-- Use Mudlet's built-in Map search functionality and character/highlighting to identify
-- deadly aggressive sentinel mobs and mark them on the map.
local function flagDeadlyMobs()
  for _, mob in ipairs( mobData ) do
    -- Sentinels don't wander and are always in the same room
    local sentinel = string.find( mob.flags, "SENTINEL" )
    -- Define deadlieness with appropriate criteria
    local deadly   = isMobDeadly( mob, 100 )
    -- Deadly aggressive sentinel mobs can be treated as a property of the room and marked on the map
    if sentinel and deadly then
      -- Find the room the mob is in
      local room = mob.roomRNumber
      -- If the room is found, display the mob
      if room then
        local roomChar = getRoomChar( room )
        if roomChar and #roomChar > 0 and #roomChar ~= "" then
          setRoomChar( room, "👽" )
        else
          setRoomChar( room, "😈" )
        end
      end
    end
  end
  updateMap()
end
