-- For now we're only using mobs in the Main session
if not mobData then
  -- Global "master table" to hold all mob data
  mobData = {}
  -- Global table to hold fame data (maps mob shorts to fame values)
  fameData = {}
  -- After scripts are loaded, call loadAllMobs to populate mobData
  tempTimer( 0, [[loadAllMobs()]] )
  tempTimer( 0, [[loadFameData()]] )
end
AreaMobs = AreaMobs or {}

-- A global table to store the IDs of the current area's temporary mob triggers
areaMobTriggers = areaMobTriggers or {}
-- Load all mobs from the Mob and SpecialAttacks Tables in the gizwrld.db database
function loadAllMobs()
  mobData = {}
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
      primaryKeyword   = nil, -- TBD calculated later
      uniqueKeyword    = nil,
      level            = tonumber( mob.level ),
      health           = tonumber( mob.health ),
      ac               = tonumber( mob.ac ),
      gold             = tonumber( mob.gold ),
      xp               = tonumber( mob.xp ),
      fame             = tonumber( mob.fame ) or 0,
      alignment        = tonumber( mob.alignment ),
      flags            = mob.flags,
      affects          = mob.affects,
      aggro            = string.find( mob.flags, "AGG" ) and true or false,
      damageDice       = tonumber( mob.damageDice ),
      damageSides      = tonumber( mob.damageSides ),
      damageModifier   = tonumber( mob.damageModifier ),
      hitroll          = tonumber( mob.hitroll ),
      roomVNumber      = tonumber( mob.roomVNumber ),
      specialProcedure = mob.specialProcedure,
      roomRNumber      = tonumber( mob.roomRNumber ) or -1,
      areaRNumber      = tonumber( mob.areaRNumber ) or -1,
      areaName         = mob.areaName or "Unknown",
      -- Fields to calculate or lookup later
      meleeDamage      = 0, -- TBD for average melee damage
      specDamage       = 0, -- TBD for damage from special attack (tables)
      xpPerHealth      = 0, -- TBD
      goldPerHealth    = 0, -- TBD
      -- Placeholder for special attacks
      specialAttacks   = {},
      --tag              = createMobTag( mob.flags, mob.affects ),
    }
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
    mobEntry.meleeDamage = averageDice( mobEntry.damageDice, mobEntry.damageSides,
      mobEntry.damageModifier )

    -- Load special attacks corresponding to this mob
    local saSql = string.format( "SELECT * FROM SpecialAttacks WHERE rNumber = %d", mobEntry.rNumber )
    local saCursor = conn:execute( saSql )
    if saCursor then
      local sa = saCursor:fetch( {}, "a" )
      while sa do
        local savd = sa.chance * averageDice( sa.damageDice, sa.damageSides, sa.damageModifier ) /
            100
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
  tempTimer( 0.1, [[setPrimaryKeyword()]] )
end

-- Populate AreaMobs with a subset of mobs from the mobData table; useful for functions that later
-- operate within an area so we don't have to iterate over the whole mobData table again
function loadAreaMobs( areaRNumber )
  --iout( f "Loading mobs for area {NC}{areaRNumber}{RC}" )
  -- Clear any existing AreaMobs table
  AreaMobs = nil
  AreaMobs = {}

  -- Populate AreaMobs with mobs from mobData where areaRNumber matches
  for _, mob in ipairs( mobData ) do
    if mob.areaRNumber == areaRNumber then
      table.insert( AreaMobs, mob )
    end
  end
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
  iout( [[{EC}getMob{RC}(): No mob {NC}{rNumber}{RC}]] )
  return nil
end

-- Function to find and display mobs matching a given string in their descriptions
-- Will display multiple mobs; searches against both short and long descriptions
function findMob( searchString, areaRNumber )
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
  cout( "{SC}{shrt}{RC} ({SC}{kws}{RC}) [{NC}{rNumber}{RC}]" )
  cout( "  Room <royal_blue>{rmid}<reset> in {SC}{arn}{RC} [{NC}{arid}{RC}]" )
  --cout( "  {SC}{lng}{RC}" )
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

-- Create a temporary trigger for all mobs in the current area, matching primaryKeyword to long descriptions
-- If a parameter is passed, it is a table where mobRNumbers[rNumber] = true for mobs we want to load
-- triggers for; if no parameter is passed triggers are created for all mobs in the current area
-- Alias: ^lam$ for all mobs in the area
-- Create a temporary trigger for all mobs in the current area, matching primaryKeyword to long descriptions
-- If a parameter is passed, it is a table where mobRNumbers[rNumber] = true for mobs we want to load
-- triggers for; if no parameter is passed triggers are created for all mobs in the current area
-- Alias: ^lam$ for all mobs in the area
function loadMobTriggers( mobRNumbers )
  -- Kill any existing triggers and reset the table
  resetMobTriggers()
  if CurrentAreaName == "Northern Midgaard" then
    iout( f "Skipping loadMobTriggers() for {SC}{CurrentAreaName}{RC}" )
    return
  end
  -- Determine whether we are loading triggers for all mobs in the area, or just a subset
  local isSubset = mobRNumbers and next( mobRNumbers ) ~= nil

  -- Create a temporary trigger for each mob in the current area
  for _, mob in ipairs( AreaMobs ) do
    local needTrigger = not isSubset or (isSubset and mobRNumbers[mob.rNumber])
    if needTrigger then
      -- Create a regex from the mob's long description
      local mobPattern = createLineRegex( mob.longDescription )

      -- Create a trigger that calls targetMatch with the mob's primary keyword and uniqueness when it fires
      local triggerID = tempRegexTrigger( mobPattern, function ()
        targetMatch( mob.primaryKeyword, mob.uniqueKeyword )
      end )

      -- Hold the ID so we can kill previous triggers before loading new areas
      table.insert( areaMobTriggers, triggerID )
    end
  end
end

-- Reset temporary mob triggers; use before loading new ones to avoid over-capping trigger limit
function resetMobTriggers()
  -- Kill any existing temporary mob triggers
  for _, id in ipairs( areaMobTriggers ) do
    killTrigger( id )
  end
  for _, id in ipairs( areaMobTriggers ) do
    killTrigger( id )
  end
  -- Re-initialize the tables
  areaMobTriggers = {}
  areaMobTriggers = {}
end

-- Called when a mob is encountered in the game which has a corresponding trigger
function targetMatch( keyword, uniqueKeyword )
  -- Count matched targets
  TargetCount = TargetCount + 1

  -- Highlight the mob's long description
  selectString( line, 1 )
  setFgColor( 160, 100, 130 )
  resetFormat()

  -- Determine the color for the keyword
  local color = uniqueKeyword and "<olive_drab>" or "<tomato>"

  -- Composite string with the colorized keyword and count
  local outputString = f " ({color}{keyword}<reset> {NC}{TargetCount}{RC})"

  -- Append the composite string to the line
  cecho( outputString )

  -- Update markedTarget to the parameter of the function (the keyword of the matched mob)
  markedTarget = keyword
end

function setPrimaryKeyword()
  local areaKeywordCounts = {}

  -- First pass: count keywords for each area
  for _, mob in ipairs( mobData ) do
    if mob.areaRNumber ~= -1 then
      local mobKeys = split( mob.keywords, " " )
      areaKeywordCounts[mob.areaRNumber] = areaKeywordCounts[mob.areaRNumber] or {}
      local keywordCounts = areaKeywordCounts[mob.areaRNumber]
      for _, keyword in ipairs( mobKeys ) do
        keywordCounts[keyword] = (keywordCounts[keyword] or 0) + 1
      end
    end
  end
  -- Debug output for keyword counts
  for area, keywords in pairs( areaKeywordCounts ) do
    for keyword, count in pairs( keywords ) do
      iout( f "Area {area} - Keyword {keyword} count: {count}" )
    end
  end
  -- Second pass: find the best keyword for each mob in each area
  for _, mob in ipairs( mobData ) do
    if mob.areaRNumber ~= -1 then
      local mobKeys = split( mob.keywords, " " )
      local keywordCounts = areaKeywordCounts[mob.areaRNumber]
      local bestKeyword, minCount = nil, math.huge

      for _, keyword in ipairs( mobKeys ) do
        if keywordCounts[keyword] < minCount then
          bestKeyword, minCount = keyword, keywordCounts[keyword]
        end
      end
      -- Set the primaryKeyword and uniqueKeyword for the mob
      mob.primaryKeyword = bestKeyword
      mob.uniqueKeyword = (minCount == 1)

      -- Debug output for each mob
      iout( f "Mob: {mob.shortDescription} - Primary Keyword: {bestKeyword} - Unique: {mob.uniqueKeyword}" )
    end
  end
  setPrimaryKeyword = nil
end

MobList = {
  628,
  816,
  855,
  878,
}
function circuitHelper( mobList )
  function circuitHelper( mobList )
    for i = 1, #mobList do
      -- Act on each number mobList[i] here
    end
  end
end

-- Update the Mob database with values captured from Venzu
function updateMobFame( description, fame )
  -- Check incoming data against preloaded table; avoid db access if possible
  if fameData[description] then
    local dbFame = tonumber( fameData[description] )
    if dbFame ~= fame then
      iout( f 'Fame {EC}mismatch{RC}: {SC}{description}{RC}: {NC}{fame}{RC} game vs. {NC}{dbFame}{RC} db' )
    else
      iout( f 'Fame <olive_drab>confirmed: {SC}{description}{RC}, {NC}{fame}{RC}' )
    end
    return
  end
  -- For new/unknown mobs, update the database with observed values
  local sql = "SELECT fame, areaRNumber FROM Mob WHERE shortDescription = '%s'"
  local cursor, conn, env = getCursor( sql, description )
  if not cursor then
    iout( '{EC}Connect failed{RC} in updateMobFame()' )
    return
  end
  local row = cursor:fetch( {}, "a" )
  local isUnique = row and not cursor:fetch( {}, "a" )

  if not row then
    iout( f '{EC}Missing mob{RC} for updateMobFame(): {SC}{description}{RC}' )
  elseif not isUnique then
    -- UPDATE HERE
    -- Instead of rejecting updates for non-unique mobs, check the areaRNumber for each mob sharing the same
    -- short description; if they are all within the same area, then update all of the rows with the fame value
    iout( f '{EC}Non-unique{RC} mob: {SC}{description}{RC}' )
  elseif row.fame == nil then
    local updateSql = "UPDATE Mob SET fame = %d WHERE shortDescription = '%s'"
    if conn:execute( string.format( updateSql, fame, conn:escape( description ) ) ) then
      iout( f "Fame <yellow_green>updated{RC}: {SC}{description}{RC}, {NC}{fame}{RC}" )
      -- Keep the local table & counters up to date as we collect new data
      fameData[description] = fame
      fameCount             = fameCount + 1
      fameSum               = fameSum + fame
    else
      iout( f "{EC}Update failed{RC} in updateMobFame()" )
    end
  end
  cursor:close()
  conn:close()
  env:close()
end

-- Called by Mudlet trigger when Venzu reports fame turn-ins; used to capture and record fame
-- values in the database (only needed when actively capturing new data)
function triggerCaptureFame()
  -- Grab the mob's description and fame (if present) from Venzu's chatter
  local mobShortDescription = trim( matches[2] )
  local fame = 0
  if matches[3] then
    fame = tonumber( matches[3] )
  end
  -- Highlight it in game for visual confirmation
  selectString( mobShortDescription, 1 )
  setFgColor( 176, 224, 230 ) -- powder blue
  if fame > 0 then
    selectString( matches[3], 1 )
    setFgColor( 255, 165, 0 ) -- orange
  end
  resetFormat()
  -- Update the table with new fame data
  updateMobFame( mobShortDescription, fame )
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

-- Function to identify possible duplicate mobs based on shortDescription
local function suggestDuplicates()
  -- Create a table to store mobs by their shortDescription
  local mobsByDescription = {}

  -- Populate the mobsByDescription table
  for _, mob in ipairs( mobData ) do
    local mobFlags = mob.flags
    if not mobsByDescription[mob.shortDescription] then
      mobsByDescription[mob.shortDescription] = {}
    end
    table.insert( mobsByDescription[mob.shortDescription], mob )
  end
  -- Iterate through mobsByDescription to find potential duplicates
  for description, mobs in pairs( mobsByDescription ) do
    if #mobs > 1 then
      for _, mob in ipairs( mobs ) do
        local sd = mob.shortDescription
        local id = mob.rNumber
        local ar = mob.areaName
        iout( f "{SC}{sd}{RC} ({NC}{id}{RC}) in <maroon>{ar}{RC}" )
      end
    end
  end
end

local function findBestKeywords( areaRNumber )
  local keywordCounts = {}

  -- First pass: count keywords in the specified area
  for _, mob in ipairs( mobData ) do
    if mob.areaRNumber == areaRNumber then
      local mobKeys = split( mob.keywords, " " )
      for _, keyword in ipairs( mobKeys ) do
        keywordCounts[keyword] = (keywordCounts[keyword] or 0) + 1
      end
    end
  end
  -- Second pass: find the best keyword for each mob in the area
  for _, mob in ipairs( mobData ) do
    if mob.areaRNumber == areaRNumber then
      local mobKeys = split( mob.keywords, " " )
      local bestKeyword, minCount = nil, math.huge

      for _, keyword in ipairs( mobKeys ) do
        if keywordCounts[keyword] < minCount then
          bestKeyword, minCount = keyword, keywordCounts[keyword]
        end
      end
      -- Determine the color for the optimal keyword
      local color = minCount == 1 and "<green_yellow>" or "<tomato>"

      -- Output the results
      iout( f "<royal_blue>{mob.shortDescription}<reset>: <cyan>{table.concat(mobKeys, ', ')}<reset> - Optimal Keyword: {color}{bestKeyword}<reset>" )
    end
  end
end

local function findBestKeywords()
  local keywordCounts = {}

  -- First pass: count keywords in the current area
  for _, mob in ipairs( AreaMobs ) do
    local mobKeys = split( mob.keywords, " " )
    for _, keyword in ipairs( mobKeys ) do
      keywordCounts[keyword] = (keywordCounts[keyword] or 0) + 1
    end
  end
  -- Second pass: find the best keyword for each mob in the area
  for _, mob in ipairs( AreaMobs ) do
    local mobKeys = split( mob.keywords, " " )
    local bestKeyword, minCount = nil, math.huge

    for _, keyword in ipairs( mobKeys ) do
      if keywordCounts[keyword] < minCount then
        bestKeyword, minCount = keyword, keywordCounts[keyword]
      end
    end
    -- Determine the color for the optimal keyword
    local color = minCount == 1 and "<green_yellow>" or "<tomato>"

    -- Output the results
    iout( f "<royal_blue>{mob.shortDescription}<reset>: <cyan>{table.concat(mobKeys, ', ')}<reset> - Optimal Keyword: {color}{bestKeyword}<reset>" )
  end
end

-- Using data in the mobData table, this function will label rooms on the map with emoji characters
-- based on the fame value and aggro status of mobs in those rooms.
local function setRoomCharByFame()
  local lowFame     = 3
  local mediumFame  = 6
  local highFame    = 10

  local safeChar    = "🐯"
  local lowChar     = "😠"
  local mediumChar  = "👿"
  local highChar    = "😡"
  local extremeChar = "👽"

  for _, mob in ipairs( mobData ) do
    local fame         = mob.fame
    local isAggressive = mob.aggro
    local room         = mob.roomRNumber

    -- For all mobs with non-zero fame and room IDs, add a label to the Mudlet map according to
    -- their fame value and aggro status
    if (fame and fame > 0) and (room and room > 0) then
      local char = ""
      if not isAggressive then
        char = safeChar
      elseif fame <= lowFame then
        char = lowChar
      elseif fame <= mediumFame then
        char = mediumChar
      elseif fame <= highFame then
        char = highChar
      else
        char = extremeChar
      end
      setRoomChar( room, char )
      --iout( f "{NC}{room}{RC}: {SC}{short}{RC} == {char})" )
    end
  end
end

-- Remove pre-existing mob labels which were based on some arbitrary stats
local function unlabelMapChars()
  local clearCount = 0
  local rooms = getRooms()
  for id, name in pairs( rooms ) do
    local char = getRoomChar( id )
    if char and #char > 0 and char == "😈" or char == "👽" then
      clearCount = clearCount + 1
      setRoomChar( id, "" )
    end
  end
  iout( f "Cleared {NC}{clearCount}{RC} mob labels" )
end

-- This function creates a "tag" designed to appear after a mob's long description when players encounter
-- the mob in game; the tag will identify flags and affects of the mob that are not typically visible but
-- help the player understand the mob's behavior and abilities.
local function createMobTag( flags, affects )
  local AC, FC, DC, SAC, SPC, STC = "<tomato>", "<orange_red>", "<dodger_blue>", "<gold>",
      "<deep_pink>", "<slate_grey>"
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
      tag = tag .. color .. flag:sub( 1, 1 ) .. RC
    end
  end
  -- Iterate through affect attributes and add them to the tag string
  for _, affect in ipairs( affectList ) do
    local color = affectAttributes[affect]
    if color then
      tag = tag .. color .. affect:sub( 1, 1 ) .. RC
    end
  end
  -- Wrap the tag string in square brackets (and add a leading space)
  if tag ~= "" then
    return " {" .. tag .. "}"
  else
    return ""
  end
end

-- Function to help in locating mobs that are within reach both geographically and difficulty-wise by searching
-- mobData and filtering based on a number of criteria
local function showMeTheMoney()
  local ignoredMobs = {
    185,  -- Sphen
    389,  -- Music Shopkeeper
    390,  -- Magic Shopkeeper
    391,  -- Bakery Shopkeeper
    392,  -- Grocer
    393,  -- Weaponsmith
    394,  -- Armorer
    396,  -- Boat Captain
    501,  -- Doljet (Treasure Vendor)
    503,  -- Heckkingrel the Alchemist
    1501, -- Oceanid
    1502, -- Oceanid
    1503, -- Oceanid
    1504, -- Oceanid
    2054, -- diamond ekitom lord
    2053, -- iron ekitom lord
    2052, -- granite ekitom lord
    2048, -- diamond ekitom extractor
    2047, -- diamond ekitom excavator
    2046, -- iron ekitom extractor
    2045, -- iron ekitom excavator
    1991, -- Frost King's wolves...
    1992,
    1993,
    1994,
  }
  local ignoredAreas = {
    125, -- Midgaard Tar Pit
  }

  for _, mob in ipairs( mobData ) do
    local mobRoom = mob.roomRNumber
    local mobID = mob.rNumber
    local mobName = mob.shortDescription
    local areaID = mob.areaRNumber
    local ignoredMob = contains( ignoredMobs, mobID ) or contains( ignoredAreas, areaID )
    if mobRoom and not ignoredMob then
      -- Reachable from Market Square
      local isPathable      = getPath( 1121, mobRoom )
      -- Has at least 250,000 coins
      local isWealthy       = mob.gold >= 250000
      -- Does not have some bullshit
      local noSpec          = not string.find( mob.flags, 'SPEC' )
      -- Won't take all f'ing day
      local effectiveHealth = mob.health
      if string.find( mob.affects, 'SANCTUARY' ) then
        effectiveHealth = effectiveHealth * 2
      end
      if isPathable and isWealthy and effectiveHealth < 25000 then
        displayMob( mob.rNumber )
      end
    else
      --piout( "No room data for mob {SC}{mobName}{RC} ({NC}{mobID}{RC})" )
    end
  end
end
