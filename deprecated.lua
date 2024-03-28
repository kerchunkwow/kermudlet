function getFullDirs( srcID, dstID )
  -- Clear Mudlet's pathing globals
  speedWalkDir = nil
  speedWalkPath = nil

  -- Use Mudlet's built-in path finding to get the initial path
  local rm = srcID
  if getPath( srcID, dstID ) then
    -- Initialize a table to hold the full path
    local fullPathString1, fullPathString2 = "", ""
    local fullPath = {}
    for d = 1, #speedWalkDir do
      local dir = LDIR[tostring( speedWalkDir[d] )]
      local doors = getDoors( rm )
      if doors[dir] and doorData[rm] and doorData[rm][dir] then
        local doorInfo = doorData[rm][dir]
        -- If the door has a key associated with it; insert an unlock command into the path
        if doorInfo.exitKEy and doorInfo.exitKey > 0 then
          table.insert( fullPath, "unlock " .. doorInfo.exitKeyword )
        end
        -- All doors regardless of locked state need opening
        table.insert( fullPath, "open " .. doorInfo.exitKeyword )
        table.insert( fullPath, dir )
        -- Close doors behind us to minimize wandering mobs
        table.insert( fullPath, "close " .. doorInfo.exitKeyword )
      else
        -- With no door, just add the original direction
        table.insert( fullPath, dir )
      end
      -- "Step" to the next room along the path
      rm = tonumber( speedWalkPath[d] )
    end
    -- Convert the path to a Wintin-compatible command string
    fullPathString = createWintinString( fullPath )
    return fullPathString
  end
  cecho( f "\n<firebrick>Failed to find a path between {srcID} and {dstID}<reset>" )
  return nil
end

-- Display one or more mobs whose keywords include the specified string(s)
function displayMobByKeyword( keywords )
  local NC = "<dark_orange>"
  local SC = "<royal_blue>"
  local DC = "<gold>"
  local RC = "<reset>"

  -- Split the keywords string into a table of individual keywords
  local keywordsTable = split( keywords, ' ' )
  local sqlCondition = ""

  -- Construct SQL condition for each keyword
  for i, keyword in ipairs( keywordsTable ) do
    if i > 1 then sqlCondition = sqlCondition .. " AND " end
    sqlCondition = sqlCondition .. string.format( "keywords LIKE '%%%s%%'", keyword )
  end
  local sql = "SELECT * FROM Mob WHERE " .. sqlCondition
  local cursor, conn, env = getCursor( sql )

  if not cursor then
    cecho( string.format( "\nError fetching mobs with keywords: %s\n", keywords ) )
    return nil
  end
  local mob = cursor:fetch( {}, "a" )
  while mob do
    local lng, shrt, kws = mob.longDescription, mob.shortDescription, mob.keywords
    cecho( string.format( "\n%s%s%s", SC, lng, RC ) )
    cecho( string.format( "\n  %s%s%s (%s%s%s)", SC, shrt, RC, SC, kws, RC ) )
    local hp, xp = mob.health, mob.xp
    local xpph = round( (xp / hp), 0.05 )
    cecho( string.format( "\n  HP: %s%s%s  XP: %s%s%s  (%s%s%s xp/hp)", NC, expandNumber( hp ), RC, NC,
      expandNumber( xp ),
      RC, DC, xpph, RC ) )
    local gp = mob.gold
    local gpph = round( (gp / hp), 0.05 )
    cecho( string.format( "\n  Gold: %s%s%s  (%s%s%s gp/hp)", NC, expandNumber( gp ), RC, DC, gpph, RC ) )
    local dn, ds, dm, hr = mob.damageDice, mob.damageSides, mob.damageModifier, mob.hitroll
    local da = averageDice( dn, ds, dm )
    cecho( string.format( "\n  Damage: %s%sd%s+%s+%s%s (%s%s%s avg)", NC, dn, ds, dm, hr, RC, DC, da, RC ) )
    local flg, aff = mob.flags, mob.affects
    cecho( string.format( "\n  Flags: <maroon>%s%s", flg, RC ) )
    cecho( string.format( "\n  Affects: <maroon>%s%s", aff, RC ) )

    -- Fetch the next mob
    mob = cursor:fetch( mob, "a" )
  end
  -- Don't forget to close the cursor and connection
  cursor:close()
  conn:close()
  env:close()
end

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

function populateMobAreas()
  local luasql     = require "luasql.sqlite3"
  local env        = luasql.sqlite3()
  local conn, cerr = env:connect( "C:/Dev/mud/gizmo/data/gizwrld.db" )

  if not conn then
    print( "Error connecting to database:", cerr )
    return
  end
end

function getMobArea( rn )
  local sql = string.format( "SELECT * FROM Mob WHERE rnumber = %d", rn )
  local dbpath = "C:/Dev/mud/gizmo/data/gizwrld.db"
  local cursor, conn, env = getCursor( dbpath, sql )
  local mobAreaName = "Unknown Area"

  if not cursor then
    return mobAreaName
  end
  local mob = cursor:fetch( {}, "a" )
  cursor:close()

  if mob then
    local mobRoomVNumber = tonumber( mob.roomVNumber )
    local mobRoomRNumber = searchRoomUserData( "roomVNumber", tostring( mobRoomVNumber ) )[1]
    if roomExists( mobRoomRNumber ) then
      local mobAreaRNumber = getRoomArea( mobRoomRNumber )
      mobAreaName = getRoomAreaName( mobAreaRNumber )
    end
  end
  conn:close()
  env:close()

  return mobAreaName
end

function calculateMobDamage( rn )
  local DC, SC, R = "<maroon>", "<medium_violet_red>", "<reset>"
  local dbpath = "C:/Dev/mud/gizmo/data/gizwrld.db"
  -- SQL statement to select the mob by rnumber
  local mobSql = string.format( "SELECT * FROM Mob WHERE rnumber = %d", rn )
  local mobCursor, mobConn, mobEnv = getCursor( dbpath, mobSql )

  if mobCursor then
    local mob = mobCursor:fetch( {}, "a" )
    mobCursor:close()

    if mob then
      local mobShort = mob.shortDescription
      local totalAverage = 0
      cecho( f "\nDamage for {DC}{mobShort}{R}:" )
      local bn, bs, bm = mob.damageDice, mob.damageSides, mob.damroll
      local ba = averageDice( bn, bs, bm )
      cecho( f "\n  Base: {DC}{bn}d{bs} +{bm}{R} (~{DC}{ba}{R})" )
      totalAverage = totalAverage + ba

      -- Now fetch special attacks for this mob
      local specSql = string.format( "SELECT * FROM SpecialAttack WHERE rnumber = %d", rn )
      local specCursor, _, _ = getCursor( dbpath, specSql )

      if specCursor then
        local specNumber = 1
        local spec = specCursor:fetch( {}, "a" )
        while spec do
          local sc, sn, ss, sm = spec.chance, spec.damageDice, spec.damageSides, spec.damageModifier
          local sa = averageDice( sn, ss, sm ) * (sc / 100)
          cecho( f "\n  Spec {specNumber}: {SC}{sc}{R}% chance of {SC}{sn}d{ss}{R} +{SC}{sm}{R} ({SC}{sa}{R} ave)" )
          totalAverage = totalAverage + sa
          specNumber = specNumber + 1
          spec = specCursor:fetch( spec, "a" )
        end
        specCursor:close()
      end
      cecho( f "\n  Total: ~<dark_orange>{totalAverage}<reset>" )
    end
    mobConn:close()
    mobEnv:close()
  end
end

function listMobsWithSpecialAttacks()
  local dbpath = "C:/Dev/mud/gizmo/data/gizwrld.db"
  local sql = [[
    SELECT DISTINCT Mob.shortDescription
    FROM Mob
    JOIN SpecialAttack ON Mob.rNumber = SpecialAttack.rNumber
  ]]

  local cursor, conn, env = getCursor( dbpath, sql )
  if not cursor then
    cecho( "\n<red>Failed to query database for mobs with special attacks.<reset>" )
    return
  end
  local mob = cursor:fetch( {}, "a" ) -- Initialize mob to fetch in loop
  if not mob then
    cecho( "\n<green>No mobs with special attacks found.<reset>" )
  else
    cecho( "\n<green>Mobs with Special Attacks:<reset>" )
    while mob do
      cecho( f( "\n- {mob.shortDescription}" ) )
      mob = cursor:fetch( mob, "a" ) -- Fetch next row into mob
    end
  end
  -- It's important to close the cursor and connection
  cursor:close()
  conn:close()
  env:close()
end

-- Special Attacks:
-- ^\s*(\d+)\s*(\d+)D\s*(\d+)\s*\+(\d+)\s*(-?\d+)\s*(\d+)\s*(\d+) (.+?)$

specialAttacks = {
  [810] = {{40, 6, 7, 1, 0, 0, 2, "impale/impales"}},
  [817] = {{10, 10, 20, 5, 3, 0, 6, "bite/bites"}},
  [997] = {{100, 100, 10, 0, 0, 0, 236, ""}, {100, 100, 10, 0, 0, 0, 236, ""}},
  [1008] = {{100, 10, 10, 0, 0, 0, 236, ""}, {100, 10, 10, 0, 0, 0, 236, ""}},
  [1496] = {{25, 75, 3, 0, 10, 6, 6, "bite/bites"}, {50, 100, 2, 0, 10, 0, 6, "bite/bites"}, {75, 125, 2, 0, 10, 0, 6, "bite/bites"}, {100, 150, 2, 0, 10, 0, 6, "bite/bites"}, {100, 200, 2, 0, 10, 0, 6, "bite/bites"}, {100, 200, 2, 0, 10, 0, 6, "bite/bites"}},
  [1497] = {{50, 50, 10, 50, 0, 0, 0, "ferocious splash/sends a ferocious splash towards"}, {75, 10, 45, 0, 10, 0, 0, ""}, {100, 3, 125, 0, 10, 0, 0, ""}, {100, 3, 125, 0, 10, 0, 0, ""}},
  [1500] = {{25, 1, 50, 20, 10, 3, 4, "tail thrash/thrashes it's tail at"}, {100, 2, 30, 20, 0, 0, 8, "stomp/stomps on"}},
  [1503] = {{100, 24, 10, 100, 0, 0, 0, "thick jet of saltwater/shoots a thick jet of saltwater at"}, {100, 24, 10, 100, 0, 0, 0, "thick jet of saltwater/shoots a thick jet of saltwater at"}},
  [1504] = {{100, 24, 10, 100, 0, 0, 0, "thick jet of saltwater/shoots a thick jet of saltwater at"}, {100, 24, 10, 100, 0, 0, 0, "thick jet of saltwater/shoots a thick jet of saltwater at"}},
  [1505] = {{50, 75, 3, 50, 10, 6, 4, ""}, {75, 150, 4, 50, 10, 0, 0, ""}, {100, 200, 5, 50, 10, 0, 0, ""}, {100, 44, 4, 50, 10, 0, 0, "thick jet of saltwater/shoots a thick jet of saltwater at"}},
  [1552] = {{100, 10, 10, 20, 20, 1, 1, "atomic hammer/atomizes with its warhammer"}, {100, 4, 10, 10, 10, 1, 1, ""}, {80, 10, 4, 20, 5, 1, 1, "harpoon/harpoons"}, {90, 10, 3, 10, 10, 1, 1, "warglove/crushes with its warglove"}, {80, 10, 5, 20, 5, 1, 1, "silver chakra/hurls its chakra at"}},
  [1615] = {{5, 50, 25, 0, 0, 1, 236, ""}, {100, 20, 39, 10, 0, 0, 236, ""}},
  [1620] = {{25, 20, 20, 0, 0, 6, 236, "ringing bell/rings his bell at"}, {50, 30, 20, 0, 0, 5, 236, "bell cord/wraps his bell cord around"}, {100, 20, 40, 0, 0, 0, 236, ""}},
  [1623] = {{25, 22, 100, 0, 0, 5, 236, "assaulting salt/assaults"}, {100, 17, 100, 0, 0, 0, 236, ""}},
  [1624] = {{25, 11, 100, 0, 0, 6, 236, "pepper shaker/peppers"}, {100, 17, 100, 0, 0, 0, 236, ""}},
  [1627] = {{50, 100, 5, 0, 0, 6, 236, "a shower of sparks/showers sparks on"}, {100, 60, 50, 0, 0, 0, 236, ""}},
  [1629] = {{15, 26, 25, 0, 0, 1, 236, "honed blade/swings his honed blade at"}, {100, 12, 39, 10, 0, 0, 236, ""}},
  [1635] = {{25, 52, 50, 0, 0, 1, 236, "sharp spur/digs his sharp spur at"}, {100, 40, 40, 0, 0, 6, 236, ""}},
  [1641] = {{5, 100, 50, 0, 0, 1, 236, "fury/shares his fury"}, {10, 20, 50, 10, 0, 1542, 236, "whirl/whirls"}, {100, 100, 80, 0, 0, 0, 236, ""}},
  [1655] = {{35, 4, 110, 25, 14, 0, 3, "razor fin/swings a razor fin and shaves"}, {50, 4, 60, 25, 16, 0, 1, "tail/tail slaps"}, {80, 4, 20, 25, 18, 0, 8, "thump/body thumps"}, {100, 4, 10, 25, 20, 0, 6, ""}},
  [1673] = {{40, 8, 6, 0, 0, 0, 2, "gore/gores"}, {90, 8, 6, 0, 0, 0, 8, ""}},
  [1674] = {{40, 8, 6, 0, 0, 0, 2, "headbutt/headbutts"}, {90, 8, 6, 0, 0, 0, 8, ""}},
  [1675] = {{30, 11, 8, 0, 0, 0, 6, ""}, {90, 10, 8, 0, 0, 0, 5, ""}},
  [1676] = {{5, 4, 10, 0, 0, 2, 1, ""}, {90, 4, 10, 0, 0, 0, 8, ""}},
  [1677] = {{100, 4, 10, 0, 0, 0, 6, ""}},
  [1678] = {{5, 10, 4, 0, 0, 2, 2, "gore/gores"}, {90, 3, 20, 0, 0, 0, 8, ""}},
  [1679] = {{5, 10, 4, 0, 0, 2, 8, "trample/tramples"}, {100, 4, 10, 0, 0, 0, 8, ""}},
  [1680] = {{30, 4, 8, 0, 0, 0, 6, ""}, {90, 4, 8, 0, 0, 0, 8, ""}},
  [1681] = {{4, 4, 6, 0, 0, 2, 3, ""}, {90, 4, 6, 0, 0, 0, 3, ""}},
  [1682] = {{100, 4, 6, 0, 0, 0, 2, ""}},
  [1683] = {{5, 3, 8, 0, 0, 2, 0, "flurry/flurries"}, {90, 3, 8, 0, 0, 0, 0, "kick/kicks"}},
  [1684] = {{100, 4, 10, 0, 0, 0, 8, "tramples/tramples"}},
  [1685] = {{100, 4, 9, 0, 0, 0, 3, ""}},
  [1686] = {{10, 4, 13, 0, 0, 2, 8, "trample/tramples"}, {90, 4, 14, 0, 0, 0, 2, "gore/gores"}},
  [1687] = {{10, 11, 10, 0, 0, 0, 5, ""}, {90, 10, 10, 0, 0, 0, 6, ""}},
  [1688] = {{100, 100, 100, 0, 0, 2, 1, ""}},
  [1705] = {{20, 5, 20, 0, 20, 1, 1, ""}, {30, 30, 11, 0, 10, 2, 0, ""}, {100, 100, 9, 0, 0, 0, 0, ""}},
  [1786] = {{100, 80, 6, 0, 0, 0, 1, "sting/stings"}},
  [1935] = {{35, 4, 110, 25, 14, 1, 8, "unholy shockwave/unleashes an unholy shockwave down upon"}, {50, 4, 60, 25, 16, 1, 8, "hair raising war cry/screams a hair raising war cry at"}, {80, 4, 20, 25, 18, 1, 2, "flesh shredding bite/takes a flesh shredding bite out of"}, {100, 4, 10, 25, 20, 1, 8, "rib smashing bloody fist/throws a rib smashing, bloody fist at"}},
  [2006] = {{25, 1, 1, 20, 0, 1, 1, "poison spit/spits poison on"}, {100, 2, 2, 0, 0, 0, 1, "claw/claws"}},
  [2007] = {{25, 1, 1, 20, 10, 1, 1, "poison spit/spits poison on"}, {100, 2, 2, 0, 0, 0, 1, "claw/claws"}},
  [2008] = {{5, 5, 5, 20, 0, 1, 1, "stomp/stomps"}, {35, 1, 1, 10, 0, 1, 1, "tail lash/tail lashes"}, {100, 4, 4, 0, 0, 0, 1, "bite/bites"}},
  [2010] = {{30, 30, 8, 0, 10, 2, 1, "bite/bites"}, {100, 40, 9, 0, 0, 2, 1, "claw/claws"}, {100, 30, 10, 0, 0, 1, 1, "pound/pounds"}},
  [2011] = {{100, 3, 6, 0, 0, 1, 1, "gnaw/gnaws"}},
  [2012] = {{30, 4, 6, 6, 6, 1, 1, "tailbat/tailbats"}, {100, 6, 6, 0, 0, 1, 1, "gnaw/gnaws"}},
  [2013] = {{35, 6, 10, 10, 10, 1, 1, "tailsmash/tailsmashes"}, {100, 8, 10, 0, 0, 1, 1, "gnaw/gnaws"}},
  [2049] = {{50, 20, 30, 0, 0, 6, 236, "tailwhip/tailwhips"}, {75, 20, 30, 0, 0, 5, 236, "scratch/scratches"}, {100, 30, 30, 0, 0, 0, 236, ""}},
  [2050] = {{50, 50, 7, 0, 0, 0, 8, ""}, {100, 50, 7, 0, 0, 0, 8, ""}},
  [2051] = {{50, 50, 13, 0, 0, 0, 8, ""}, {100, 50, 13, 0, 0, 0, 8, ""}},
  [2052] = {{50, 50, 9, 0, 0, 0, 8, ""}, {100, 50, 9, 0, 0, 0, 8, ""}},
  [2053] = {{50, 50, 15, 0, 0, 0, 8, ""}, {100, 50, 15, 0, 0, 0, 8, ""}},
  [2054] = {{50, 10, 55, 0, 0, 0, 8, ""}, {100, 10, 55, 0, 0, 0, 8, ""}},
  [2055] = {{50, 50, 20, 0, 0, 5, 236, "stomp/stomps"}, {50, 50, 20, 0, 0, 0, 8, ""}, {100, 50, 20, 0, 0, 0, 8, ""}},
  [2059] = {{50, 50, 2, 50, 0, 5, 236, ""}},
  [2060] = {{1, 99, 99, 99, 99, 1, 0, ""}, {2, 99, 20, 50, 0, 1, 0, ""}, {7, 99, 10, 50, 0, 1, 0, ""}, {90, 99, 4, 50, 0, 1, 0, ""}},
  [2070] = {{3, 99, 25, 50, 0, 4, 0, ""}, {6, 99, 3, 50, 0, 6, 0, ""}, {12, 75, 3, 50, 0, 6, 0, ""}, {25, 50, 3, 50, 0, 6, 0, ""}},
  [2075] = {{15, 0, 0, 210, 50, 0, 236, "dragon punch/punches"}, {100, 20, 8, 55, 20, 0, 236, ""}},
  [2076] = {{5, 5, 8, 25, -10, 0, 236, "hasted strike/flurry of attacks hits"}, {10, 10, 8, 25, -5, 0, 236, "lunging pierce/flurry of attacks hits"}, {20, 20, 8, 25, 0, 0, 236, "rakish lunge/flurry of attacks hits"}, {30, 30, 8, 25, 5, 0, 236, "targeted attack/flurry of attacks hits"}, {100, 40, 8, 25, 15, 0, 236, ""}},
  [2077] = {{15, 5, 5, 120, 5, 1, 236, ""}, {100, 5, 5, 120, 5, 0, 236, ""}},
  [2079] = {{5, 20, 9, 25, 2, 0, 236, "draining touch/draining touch grasps"}, {15, 30, 14, 15, 7, 0, 236, "chilling touch/chilling touch grasps"}, {100, 50, 7, 15, 12, 0, 236, "chilling touch/chilling touch grasps"}},
  [2080] = {{5, 15, 50, 0, 2, 1, 236, "spiritual hammer/spiritual hammer strikes"}, {15, 15, 15, 0, 7, 1, 236, "holy strike/holy strike hits"}, {100, 15, 30, 30, 12, 0, 236, ""}},
  [2085] = {{100, 4, 8, 18, 2, 0, 236, "chilling touch/chilling touch hits"}},
  [2086] = {{10, 0, 0, 20, 4, 0, 236, "blast of acid/acid blasts"}, {100, 8, 6, 20, 4, 0, 236, "chilling touch/chilling touch hits"}},
  [2087] = {{5, 4, 8, 55, 4, 0, 236, "blast of acid/acid blasts"}, {100, 4, 8, 105, 4, 0, 236, "blast of acid/acid blasts"}},
  [2088] = {{5, 100, 2, 50, 10, 0, 236, "lashing tentacle/lashing tentacle"}, {100, 50, 5, 50, 10, 0, 236, "blast of acid/acid blasts"}},
  [2089] = {{100, 4, 8, 18, 2, 0, 236, "cyclone/cyclone hits"}},
  [2090] = {{100, 8, 6, 20, 4, 0, 236, "cyclone/cyclone hits"}},
  [2091] = {{5, 4, 8, 55, 4, 0, 236, "debris cloud/debris cloud"}, {100, 4, 8, 105, 4, 0, 236, "cyclone/cyclone hits"}},
  [2092] = {{5, 100, 2, 50, 50, 0, 236, "debris cloud/debris cloud"}, {100, 50, 5, 50, 10, 0, 236, "cyclone/cyclone hits"}},
  [2093] = {{100, 4, 8, 18, 2, 0, 236, "burning hands/burning hands"}},
  [2094] = {{100, 8, 6, 20, 4, 0, 236, "burning hands/burning hands"}},
  [2095] = {{5, 4, 8, 105, 5, 0, 236, "scathing wind/scathing wind"}, {100, 4, 8, 105, 5, 0, 236, "burning hands/burning hands"}},
  [2096] = {{5, 100, 2, 50, 10, 1, 236, "breath of fire/breathes fire on"}, {100, 50, 5, 50, 10, 0, 236, "burning hands/burning hands"}},
  [2097] = {{100, 4, 8, 18, 2, 0, 236, "stone fist/stone fist hits"}},
  [2098] = {{100, 8, 6, 20, 4, 0, 236, "stone fist/stone fist hits"}},
  [2099] = {{15, 4, 8, 55, 4, 0, 236, "boulder/boulder"}, {100, 4, 8, 105, 4, 0, 236, "stone fist/stone fist"}},
  [2100] = {{5, 100, 2, 100, 80, 0, 236, "avalanche/avalanche hits"}, {10, 50, 5, 50, 0, 2, 236, "earthquake/earthquake shakes"}, {100, 50, 5, 50, 5, 0, 236, "clenched fist/clenched fist hits"}},
  [2104] = {{25, 2, 6, 200, 30, 2, 7, "swarming mist/swarming mists"}, {33, 25, 7, 75, 0, 0, 236, ""}, {100, 25, 7, 75, 0, 0, 236, ""}},
  [2106] = {{10, 2, 6, 200, 5, 0, 7, "spectral grasp/spectral grasp"}, {25, 2, 6, 200, 80, 1, 0, "prismatic spray/prismatic spray"}, {80, 25, 9, 70, 0, 0, 236, ""}, {100, 25, 9, 70, 0, 0, 236, ""}},
  [2107] = {{10, 1, 1, 250, 0, 0, 0, "soul rending pierce/soul rending pierce"}, {25, 5, 10, 75, 0, 1, 0, "acrobatic kick/acrobatic kick"}, {80, 25, 10, 75, 0, 0, 236, ""}, {100, 25, 10, 75, 0, 0, 236, ""}},
  [2108] = {{5, 25, 16, 50, 0, 2, 0, "spray of green gas/spray of green gas"}, {20, 25, 12, 100, 0, 0, 236, ""}, {100, 25, 12, 100, 0, 0, 236, ""}},
  [2109] = {{5, 1, 1, 200, 0, 1, 6, "barb covered tentacle/barb covered tentacle"}, {10, 25, 16, 25, 0, 0, 8, "spine covered psuedopod/spine covered psuedopod"}, {100, 25, 15, 50, 0, 0, 236, ""}},
  [2120] = {{25, 25, 20, 100, 0, 0, 236, ""}, {100, 25, 20, 100, 0, 0, 236, ""}},
  [2121] = {{25, 25, 24, 100, 0, 0, 236, ""}, {100, 25, 24, 100, 0, 0, 236, ""}},
  [2124] = {{10, 1, 1, 500, 50, 2, 0, "swirling firestorm/swirling firestorm"}, {20, 20, 19, 25, 5, 0, 8, "flaming clenched fist/flaming clenched fist"}, {25, 30, 29, 150, 0, 0, 236, ""}, {100, 30, 29, 150, 0, 0, 236, ""}},
  [2125] = {{10, 1, 1, 400, 0, 1, 4, "firey tentacle/firey tentacle"}, {25, 1, 1, 400, 0, 1, 4, "firey tentacle/firey tentacle"}, {25, 21, 29, 50, 0, 0, 4, ""}, {100, 21, 29, 50, 0, 0, 4, ""}},
  [2126] = {{5, 100, 3, 150, 0, 1, 3, "demonic black claws/demonic black claws"}, {40, 28, 20, 70, 0, 0, 8, ""}, {100, 28, 20, 70, 0, 0, 8, ""}},
  [2127] = {{5, 1, 1, 800, 0, 0, 6, "crushing grasp/crushing grasp"}, {10, 1, 1, 500, 0, 0, 0, "massive stomp/massive stomp"}, {20, 25, 24, 75, 0, 0, 5, ""}, {100, 25, 24, 75, 0, 0, 5, ""}},
  [2128] = {{30, 35, 14, 100, 0, 0, 0, ""}, {100, 35, 14, 100, 0, 0, 0, ""}},
  [2129] = {{30, 28, 29, 100, 0, 0, 236, ""}, {100, 28, 29, 100, 0, 0, 236, ""}},
  [2132] = {{100, 2, 88, 25, 10, 0, 236, ""}},
  [2133] = {{5, 25, 19, 100, 0, 0, 3, ""}, {20, 25, 19, 100, 0, 0, 3, ""}, {45, 25, 19, 100, 0, 0, 3, ""}, {100, 25, 19, 100, 0, 0, 3, ""}},
  [2134] = {{100, 25, 10, 100, 0, 0, 2, ""}},
  [2135] = {{100, 25, 13, 100, 0, 0, 8, ""}},
  [2136] = {{100, 25, 24, 125, 0, 0, 2, ""}},
  [2137] = {{10, 25, 16, 100, 0, 0, 0, ""}, {40, 25, 16, 100, 0, 0, 0, ""}, {100, 25, 16, 100, 0, 0, 0, ""}},
  [2138] = {{100, 25, 10, 100, 0, 0, 236, ""}},
  [2139] = {{100, 25, 13, 100, 0, 0, 8, ""}},
  [2140] = {{100, 25, 13, 100, 0, 0, 2, ""}},
  [2141] = {{100, 25, 14, 100, 0, 0, 2, ""}, {100, 25, 14, 100, 0, 0, 3, ""}},
  [2142] = {{100, 25, 19, 100, 0, 0, 3, ""}},
  [2143] = {{100, 100, 9, 500, 10, 0, 236, ""}},
  [2152] = {{100, 8, 6, 10, 24, 0, 5, ""}},
  [2153] = {{100, 8, 6, 10, 24, 0, 5, ""}},
  [2154] = {{100, 8, 4, 15, 25, 0, 5, ""}},
  [2155] = {{100, 8, 6, 10, 24, 0, 5, ""}},
  [2156] = {{100, 8, 4, 15, 25, 0, 5, ""}},
  [2157] = {{100, 5, 5, 50, 20, 0, 0, "draining touch/drains"}},
  [2158] = {{10, 20, 15, 50, 50, 0, 5, ""}, {35, 20, 15, 50, 50, 0, 5, ""}, {100, 20, 15, 100, 50, 0, 5, ""}},
  [2159] = {{20, 30, 15, 10, 50, 0, 5, ""}, {100, 30, 15, 200, 50, 0, 5, ""}},
  [2160] = {{5, 30, 5, 50, 50, 0, 0, ""}, {100, 30, 15, 50, 50, 0, 0, ""}},
  [2161] = {{100, 20, 10, 85, 30, 0, 5, "savage kick/savagely kicks"}},
  [2203] = {{15, 30, 30, 80, 5, 257, 236, "claw/claws"}, {100, 25, 25, 80, 10, 0, 5, ""}},
  [2206] = {{20, 40, 45, 100, 10, 257, 4, "whip/whips"}, {100, 20, 60, 100, 15, 0, 5, ""}}
}

function insertSpecialAttacks()
  for rNumber, mob in pairs( specialAttacks ) do
    for _, spec in pairs( mob ) do
      local chance            = spec[1]
      local damageDice        = spec[2]
      local damageSides       = spec[3]
      local damageModifier    = spec[4]
      local hitroll           = spec[5]
      local target            = spec[6]
      local type              = spec[7]
      local description       = spec[8]

      local sql               = string.format( [[
        INSERT INTO SpecialAttacks (
          rNumber, chance, damageDice, damageSides, damageModifier, hitroll, target, type, description
        ) VALUES (
          %d, %d, %d, %d, %d, %d, %d, %d, '%s'
        )]], rNumber, chance, damageDice, damageSides, damageModifier, hitroll, target, type, description )

      local cursor, conn, env = getCursor( sql )
      if cursor then
        cecho( f "Special attack inserted successfully for rNumber: {rNumber}\n" )
      end
      -- Make sure to close the cursor, connection, and environment when done
      if conn then conn:close() end
      if env then env:close() end
    end
  end
end


-- Triggered by a "multi-line match" as a result of the 'stat' command to trap all mob stats
function parseStatBlock()
  local statBlock = {}
  for l = 1, #multimatches do
    for m = 2, #multimatches[l] do
      local value = multimatches[l][m]
      local numberValue = tonumber( value )
      if numberValue then
        table.insert( statBlock, numberValue )
      else
        table.insert( statBlock, trim( value ) )
      end
    end
  end
  -- Mob rnumbers are unique, so don't store stats for the same rnumber twice
  local rnumber = statBlock[4]
  if mobsCaptured[rnumber] then return end
  currentKey = rnumber
  mobsCaptured[currentKey] = {}
  if #statBlock == 78 then
    local mob             = mobsCaptured[currentKey]
    mob.short_description = statBlock[7]
    mob.long_description  = statBlock[9]
    mob.keywords          = statBlock[3]
    mob.rnumber           = statBlock[4]
    mob.vnumber           = statBlock[6]
    mob.level             = statBlock[11]
    mob.health            = statBlock[42]
    -- Combine damage numbers, sides, and damroll into a list like '4d3+20' = {4, 3, 20}
    mob.damage            = {statBlock[61], statBlock[62], statBlock[51]}
    -- Directly copy the special attacks table from the statBlock table
    mob.proc              = statBlock[60]
    mob.special_attacks   = {}
    mob.ac                = statBlock[47]
    mob.xp                = statBlock[49]
    mob.gold              = statBlock[52]
    mob.alignment         = statBlock[12]
    mob.flags             = statBlock[58]
    mob.affects           = statBlock[78]
    mob.health_regen      = statBlock[43]
    mob.hitroll           = statBlock[50]
    mob.inventory         = statBlock[65]
    mob.equipped          = statBlock[66]
    -- Combine saving throws into a single list
    mob.saves             = {statBlock[67], statBlock[68], statBlock[69], statBlock[70],
      statBlock[71]}
    mob.room              = statBlock[5]
  else
    cecho( "info", f "\nFailed to parse stats for: <orange_red>{currentKey}<reset>" )
  end
end
-- Return the area name of a captured/scanned mob (or string version of room number for unknown areas)
function getWhereArea( number )
  for _, area in ipairs( whereMap ) do
    local startNum, endNum, name = unpack( area )
    if number >= startNum and number <= endNum then
      return name
    end
  end
  -- For areas outside the ranges of the map, return a string representation of the room number
  return tostring( number )
end

function loadMobsIntoDatabase()
  local luasql     = require "luasql.sqlite3"
  local env        = luasql.sqlite3()
  local conn, cerr = env:connect( "C:/Dev/mud/gizmo/data/gizwrld.db" )

  if not conn then
    print( "Error connecting to database:", cerr )
    return
  end
  local insertedCount = 0
  local skippedCount = 0

  for rnumber, mob in pairs( mobsCaptured ) do
    local specialProcedureFlag = (mob.proc == 'Exists') and 1 or 0

    local mobInsertCmd = string.format( [[
      INSERT INTO Mob (rnumber, shortDescription, longDescription, keywords, level, health, ac, gold, xp, alignment, flags, affects, damageDice, damageSides, damroll, hitroll, room, specialProcedure)
      VALUES (%d, '%s', '%s', '%s', %d, %d, %d, %d, %d, %d, '%s', '%s', %d, %d, %d, %d, %d, %d)
    ]],
      rnumber,
      mob.short_description:gsub( "'", "''" ), -- Escape single quotes
      mob.long_description:gsub( "'", "''" ),
      mob.keywords:gsub( "'", "''" ),
      mob.level,
      mob.health,
      mob.ac,
      mob.gold,
      mob.xp,
      mob.alignment,
      mob.flags:gsub( "'", "''" ),
      mob.affects:gsub( "'", "''" ),
      mob.damage[1], -- damageDice
      mob.damage[2], -- damageSides
      mob.damage[3], -- damroll, assuming 3rd value in damage is damroll
      mob.hitroll,
      mob.room,
      specialProcedureFlag
    )

    local res, serr = conn:execute( mobInsertCmd )
    if not res then
      print( string.format( "Failed to insert mob rnumber %d: %s", rnumber, serr ) )
      skippedCount = skippedCount + 1
    else
      insertedCount = insertedCount + 1
    end
    -- Insert special attack data
    for _, attack in ipairs( mob.special_attacks ) do
      local specialAttackInsertCmd = string.format( [[
        INSERT INTO SpecialAttack (rnumber, chance, damageDice, damageSides, damageModifier, hitroll, strings, target, type)
        VALUES (%d, %d, %d, %d, %d, %d, '%s', %d, %d)
      ]],
        rnumber,
        attack.chance,
        attack.damage.n,
        attack.damage.s,
        attack.damage.m,
        attack.hitRoll,
        attack.strings:gsub( "'", "''" ),
        attack.target,
        attack.type
      )
      local saRes, saSerr = conn:execute( specialAttackInsertCmd )
      if not saRes then
        print( string.format( "Failed to insert special attack for mob rnumber %d: %s", rnumber, saSerr ) )
        -- Not incrementing skippedCount here as the mob insert is the critical part
      end
    end
  end
  print( string.format( "Data loading complete. Inserted: %d, Skipped: %d", insertedCount, skippedCount ) )
  conn:close()
  env:close()
end

-- The last 'where' command returned 'Couldn't find that entity'; log the error
function badKeyword()
  local errorString = f( "{currentMobKeyword} ({currentMobIndex-1}) returned no entities from 'where'" )
  cecho( "info", f "\n<orange_red>{errorString}<reset>" )
end
-- Some mobs have a special attack table that lists the chance, damage, and other data about special attacks
-- a mob can perform; here we parse them and store them in the capturedMobs table; an example special attacks table:
--[[
CHANCE DAMAGE HITROLL TARGET TYPE STRINGS
-------------------------------------------
  5   25D16+50    0       2     0  spray of green gas/spray of green gas
 20   25D12+100    0       0   236
100   25D12+100    0       0   236
--]]
function parseSpecialAttack()
  local chance, diceNum, diceSides, diceModifier = tonumber( matches[2] ), tonumber( matches[3] ), tonumber( matches[4] ),
      tonumber( matches[5] )
  local hitRoll, target, type = tonumber( matches[6] ), tonumber( matches[7] ), tonumber( matches[8] )
  local strings = matches[9] and trim( matches[9] ) or ""

  -- Constructing the special attack table
  local specialAttack = {
    chance  = chance,
    damage  = {n = diceNum, s = diceSides, m = diceModifier},
    hitRoll = hitRoll,
    target  = target,
    type    = type,
    strings = strings
  }

  -- Ensure currentKey is valid and the mob exists in mobsCaptured
  if mobsCaptured[currentKey] then
    -- Initialize the special_attacks table if it doesn't exist
    mobsCaptured[currentKey].special_attacks = mobsCaptured[currentKey].special_attacks or {}
    -- Append the new special attack
    table.insert( mobsCaptured[currentKey].special_attacks, specialAttack )
  else
    cecho( "info", f "\nSpec parsed for unknown or invalid key: <orange_red>{currentKey}<reset>" )
  end
end

-- The goal of this module will be to issue a 'where <mob>' command for each entry in the mobKeywords list and capture the resulting output

-- The 'where' command returns a list of mobs throughout the world in the following format:
-- [index] short_description - room_name [room_vnum]
-- Here is an example of a 'where' command output:
-- [ 3] the ace of clubs              - A Shallow Recess in the Tower  [2355]
-- To parse these lines, consider:
-- 1. There is a variable amount of whitespace in several areas
-- 2. The hyphen acts as a separator, but hyphens may also appear in both mob and room names
-- 3. Room numbers are vnums while our map data generally uses rnums, we have to translate if we want to compare
-- 4. Short description are NOT unique and therefore we must combine this w/ area information to get a unique mob

-- Table to hold all (unique) mobs and the stats captured from 'where' and 'stat' commands
mobsCaptured = {}
table.load( f '{homeDirectory}gizmo/map/data/mob_data.lua', mobsCaptured )
-- An index to traverse the mobKeywords table in order until complete
currentMobIndex   = 1
-- The current keyword from mobKeywords, subject of the current 'where' command
currentMobKeyword = ""
-- Keep track of the current stat key so we can match it in functions beyond parseStatBlock
currentKey        = ""

-- mobKeywords is a predefined list of comprehensive keywords designed to cover as many mobs as possible;
-- This function will issue a 'where' command for each keyword in the list, the output from which should
-- trigger the capture and 'stat'ing of each mob
function whereNextMob()
  if mobKeywords[currentMobIndex] then
    currentMobKeyword = mobKeywords[currentMobIndex]
    whereMob( currentMobKeyword )
    currentMobIndex = currentMobIndex + 1
  else
    -- Once all keywords have been scanned, write the table and logout of the game (currently printing a fake logout)
    cecho( "info", f "\nMob scan completed @ index <orange>{currentMobIndex}<reset>." )
    --table.save( f '{homeDirectory}gizmo/map/data/mob_data.lua', mobsCaptured )
    tempTimer( 5, [[send( 'quit' )]] )
    tempTimer( 7, [[send( '0' )]] )
  end
end

-- Issue a 'where' command to find all mobs matching the specified keyword
function whereMob( keyword )
  -- Use a temporary regex to match the next prompt indicating the 'where' is complete and we can stat any
  -- new mobs.
  tempRegexTrigger( "\\s*^<", statCapturedMobs, 1 )
  send( f 'where {keyword}', false )
end

-- This function is triggered once for each line of 'where' output in order to capture the mob on that line
-- A unique key is created by combining the mobs short description and area; unique mobs are queued for 'stat'ing
function captureWhereMobs()
  -- windex is the position within the 'where' command itself and must be saved for subsequent 'stat' command;
  -- note that this is NOT a static value so 'stat' must be issued shortly after where or this may change
  local windex = trim( matches[2] )
  windex       = tonumber( windex )
  local sdesc  = trim( matches[3] )
  if playerNames[sdesc] then return end -- Don't stat players
  local rmvnum = trim( matches[5] )

  -- Create a unique key by combining the mob's short name and rmvnum
  local uniqueKey = sdesc .. "_" .. rmvnum

  -- If a mob with this short description has been seen in this room, assume we can skip it
  if not mobsToStat[uniqueKey] then
    mobsToStat[uniqueKey] = {} -- Initialize the table before assigning properties
    mobsToStat[uniqueKey].index = windex
    mobsToStat[uniqueKey].keyword = currentMobKeyword
    mobsToStat[uniqueKey].stated = false
  end
end

-- Immediately after a 'where' command concludes, we want to 'stat' any newly added mobs due to the dynamic nature
-- of the index number which can change as new mobs spawn/areas reset; for any mobs in the mobsCaptured that have
-- not been 'stat'ed, this function queues a stat command at a rate of 0.5 seconds per mob
function statCapturedMobs()
  local statRate   = 0.75 -- Time to delay between each stat command
  local statOffset = 0    -- Start with no offset and increase for each mob
  for uniqueKey, mob in pairs( mobsToStat ) do
    if not mob.stated then
      tempTimer( statOffset, f [[send( 'stat c ]] .. mob.index .. [[.]] .. mob.keyword .. [[', false )]] )
      mob.stated = true -- Update this in mobsToStat
      statOffset = statOffset + statRate
    end
  end
  -- Optionally, schedule the next step after all stat commands are issued
  local whereOffset = statOffset + 2
  tempTimer( whereOffset, whereNextMob )
end


playerNames = {
  ['Hayla']    = true,
  ['Apollo']   = true,
  ['Glory']    = true,
  ['Anima']    = true,
  ['Cyrus']    = true,
  ['Vassago']  = true,
  ['Malcolm']  = true,
  ['Blain']    = true,
  ['Dillon']   = true,
  ['Mac']      = true,
  ['Anna']     = true,
  ['Rax']      = true,
  ['Sly']      = true,
  ['Tzu']      = true,
  ['Organ']    = true,
  ['Trachea']  = true,
  ['Manwe']    = true,
  ['Turambar'] = true,
  ['Finarfin'] = true,
  ['Irelia']   = true,
  ['Elbryan']  = true,
  ['Qxuilur']  = true,
  ['Germ']     = true,
  ['Digest']   = true,
  ['Ace']      = true,
}

mobKeywords = {
  'aaron',
  'abbess',
  'abel',
  'abigail',
  'abom',
  'abomination',
  'ace',
  'acid',
  'acolyte',
  'actor',
  'adamantite',
  'adatha',
  'adrin',
  'adult',
  'adv',
  'adventurer',
  'adviser',
  'aeacus',
  'aello',
  'african',
  'agannar',
  'agb',
  'agent',
  'air',
  'aisha',
  'akinra',
  'alchemical',
  'alchemist',
  'alecto',
  'aleja',
  'alien',
  'alligator',
  'alsatian',
  'alys',
  'amazon',
  'american',
  'amizir',
  'amon',
  'anaconda',
  'anc',
  'ancient',
  'andara',
  'anderson',
  'andre',
  'andrew',
  'andro',
  'andromeda',
  'andronym',
  'angel',
  'angry',
  'animal',
  'anne',
  'ant',
  'anti',
  'antip',
  'antipaladin',
  'antithief',
  'anua',
  'anubis',
  'ap',
  'ape',
  'apollo',
  'apple',
  'apprentice',
  'aquarius',
  'arachnid',
  'arch',
  'archivist',
  'archmagi',
  'arena',
  'argot',
  'ariel',
  'aries',
  'arkel',
  'arknos',
  'armand',
  'armourer',
  'ashdra',
  'ashmedai',
  'aspiring',
  'ass',
  'assassin',
  'assistant',
  'astrasi',
  'astrologer',
  'atlag',
  'attendant',
  'auctioneer',
  'automaton',
  'avatar',
  'averland',
  'axean',
  'baatezu',
  'baby',
  'bad',
  'baggins',
  'baker',
  'balash',
  'baleful',
  'ballerina',
  'bamboo',
  'bander',
  'bandersnatch',
  'bandit',
  'banker',
  'bard',
  'barker',
  'baron',
  'barrack',
  'bartender',
  'bartholemew',
  'basalt',
  'basilisk',
  'basket',
  'basking',
  'bassist',
  'bat',
  'bath',
  'batherington',
  'battle',
  'baug',
  'bautzan',
  'beagle',
  'bear',
  'beast',
  'beastman',
  'beaten',
  'beauty',
  'beaver',
  'bed',
  'bedbug',
  'bee',
  'beest',
  'beetle',
  'beggar',
  'begger',
  'begli',
  'behemoth',
  'being',
  'believer',
  'bellied',
  'belt',
  'berric',
  'berserker',
  'bert',
  'bertram',
  'big',
  'bigbird',
  'bilbo',
  'billows',
  'biped',
  'bird',
  'bishop',
  'bittering',
  'bittersteel',
  'black',
  'blacksmith',
  'blade',
  'blademaster',
  'blithering',
  'blob',
  'blossom',
  'blue',
  'bluebird',
  'boa',
  'board',
  'body',
  'bodyguard',
  'bone',
  'bones',
  'bony',
  'boofo',
  'book',
  'bookkeeper',
  'boris',
  'boss',
  'boulder',
  'boy',
  'branches',
  'brat',
  'brewer',
  'brian',
  'bride',
  'brien',
  'bright',
  'broker',
  'bronze',
  'brother',
  'brown',
  'brownie',
  'brughal',
  'brute',
  'buffalo',
  'bug',
  'bull',
  'bumpkin',
  'bunny',
  'buquet',
  'burgonmaster',
  'burmese',
  'bush',
  'bushboogie',
  'butcher',
  'butler',
  'bv',
  'bylos',
  'calf',
  'camel',
  'cancer',
  'candle',
  'cannibal',
  'canopy',
  'cape',
  'capricorn',
  'captain',
  'captive',
  'cara',
  'card',
  'caretaker',
  'carlotta',
  'carrion',
  'cassiopeia',
  'castle',
  'cat',
  'caveman',
  'cavern',
  'cedar',
  'celeborn',
  'celeno',
  'celeste',
  'celestial',
  'cellist',
  'centaur',
  'centipede',
  'ceo',
  'cepheus',
  'cesar',
  'chak',
  'cham',
  'champion',
  'chandelier',
  'channeler',
  'chaos',
  'charybdis',
  'chatundah',
  'chazegreth',
  'che',
  'check',
  'chef',
  'cherry',
  'chest',
  'chi',
  'chia',
  'chic',
  'chicken',
  'chief',
  'chieftain',
  'child',
  'chimera',
  'chinese',
  'chirugeon',
  'chirurgeon',
  'choir',
  'choker',
  'chorlach',
  'chorlachtogna',
  'christian',
  'christine',
  'chronicleer',
  'citizen',
  'city',
  'cityguard',
  'cl',
  'clae',
  'claegon',
  'clay',
  'cleaner',
  'cleaning',
  'cleric',
  'climber',
  'clive',
  'cloak',
  'clock',
  'cloud',
  'club',
  'clubs',
  'clyde',
  'coach',
  'coachman',
  'coat',
  'coatrack',
  'cobra',
  'cochineal',
  'codys',
  'collins',
  'colonel',
  'comet',
  'commander',
  'commando',
  'commoner',
  'company',
  'condor',
  'conductor',
  'conductors',
  'confessor',
  'conger',
  'conglomerate',
  'constrictor',
  'cook',
  'copper',
  'corpse',
  'count',
  'country',
  'cousin',
  'cow',
  'cowering',
  'coyle',
  'crab',
  'craftsman',
  'crank',
  'crawdad',
  'crazed',
  'crazy',
  'creature',
  'creeper',
  'crested',
  'crew',
  'cricket',
  'crier',
  'crimson',
  'critic',
  'cro',
  'crocodile',
  'crone',
  'crotus',
  'crow',
  'crowd',
  'cruel',
  'crusa',
  'crystalline',
  'cur',
  'curator',
  'cute',
  'cuttlefish',
  'cyclops',
  'cyprine',
  'd',
  'daae',
  'daemon',
  'dagrat',
  'daigure',
  'dalzn',
  'dancer',
  'dap',
  'dark',
  'darklord',
  'darkness',
  'darst',
  'daughter',
  'daunting',
  'david',
  'dawnman',
  'death',
  'decay',
  'deceit',
  'deer',
  'deformed',
  'della',
  'demented',
  'demi',
  'demiwolf',
  'demon',
  'demonic',
  'demonologist',
  'desade',
  'desert',
  'despina',
  'destroyer',
  'devil',
  'devotee',
  'dg',
  'diamond',
  'diamonds',
  'dick',
  'dif',
  'difwife',
  'dignitary',
  'dire',
  'director',
  'dirty',
  'disembodied',
  'displacer',
  'diumbra',
  'dock',
  'dockhand',
  'dockmaster',
  'doctor',
  'doe',
  'dog',
  'doljet',
  'dolphin',
  'dolt',
  'donna',
  'door',
  'doorkeeper',
  'doorman',
  'dopple',
  'doppleganger',
  'dorek',
  'dra',
  'draco',
  'dragon',
  'dragonfly',
  'dragonmaster',
  'dragonmistress',
  'dragonrider',
  'drake',
  'dralogh',
  'dranum',
  'dreia',
  'driver',
  'dromaer',
  'dromedary',
  'drone',
  'drow',
  'druid',
  'druj',
  'drunk',
  'drunken',
  'dryad',
  'dtam',
  'duck',
  'duckling',
  'ducky',
  'duergar',
  'dummy',
  'durban',
  'durgathel',
  'durnan',
  'durso',
  'durzagon',
  'dust',
  'duty',
  'dwarf',
  'dwarven',
  'dwell',
  'dweller',
  'dylanis',
  'dynzee',
  'earth',
  'eater',
  'ed',
  'eddie',
  'edgar',
  'edrin',
  'efreet',
  'efreeti',
  'eight',
  'ekaziel',
  'ekitom',
  'elder',
  'ele',
  'element',
  'elemental',
  'elephant',
  'elf',
  'elite',
  'elk',
  'elven',
  'emaciated',
  'emerald',
  'emissary',
  'empress',
  'enchanter',
  'enchantress',
  'energy',
  'english',
  'eniera',
  'enormous',
  'enraged',
  'enri',
  'ent',
  'erik',
  'erinyes',
  'erratic',
  'erudite',
  'erzuli',
  'escaped',
  'escort',
  'esmira',
  'estelle',
  'et',
  'etcher',
  'ether',
  'etheral',
  'ethereal',
  'etienne',
  'ett',
  'ettin',
  'eunuch',
  'european',
  'euryale',
  'evil',
  'ewe',
  'excavator',
  'excommunicated',
  'executioner',
  'explorer',
  'extractor',
  'eye',
  'fadh',
  'faerie',
  'faeryn',
  'fairy',
  'faith',
  'fallen',
  'familiar',
  'fan',
  'fanatical',
  'farh',
  'farmer',
  'father',
  'feline',
  'felnor',
  'fem',
  'female',
  'ferocious',
  'ferry',
  'ferryman',
  'fido',
  'fiel',
  'fiend',
  'fighter',
  'figure',
  'filthy',
  'fire',
  'firedrake',
  'firmin',
  'first',
  'fish',
  'five',
  'flake',
  'flame',
  'flaming',
  'flesh',
  'floor',
  'floorboard',
  'florist',
  'flowering',
  'fly',
  'flying',
  'flytrap',
  'fog',
  'fool',
  'foreman',
  'forest',
  'form',
  'formless',
  'fountain',
  'four',
  'fox',
  'frebjin',
  'frenal',
  'french',
  'friend',
  'fronds',
  'frost',
  'frump',
  'fungi',
  'furies',
  'furious',
  'fury',
  'gabrielle',
  'galadriel',
  'gamgee',
  'ganger',
  'ganth',
  'ganymede',
  'garat',
  'gardener',
  'gargantuan',
  'gargon',
  'gargoyle',
  'gaston',
  'gate',
  'gateguard',
  'gatekeeper',
  'gatemaster',
  'gator',
  'gaunt',
  'gaz',
  'gazelle',
  'gecko',
  'gelatinous',
  'gemini',
  'gen',
  'general',
  'genevieve',
  'genius',
  'gertrute',
  'ghast',
  'ghizyon',
  'ghost',
  'ghostly',
  'ghoul',
  'ghuz',
  'giant',
  'gigantic',
  'gilded',
  'giraffe',
  'girl',
  'giry',
  'githyaddi',
  'gladiator',
  'glaucus',
  'glavius',
  'glowworm',
  'gnash',
  'gnoll',
  'gnome',
  'goat',
  'goblin',
  'god',
  'golaud',
  'gold',
  'golden',
  'golem',
  'goliathus',
  'gonjin',
  'good',
  'goose',
  'goracka',
  'gorgon',
  'gorilla',
  'gorth',
  'gossip',
  'goth',
  'graceful',
  'graff',
  'grand',
  'grandfather',
  'granite',
  'granny',
  'grazz',
  'green',
  'gremlin',
  'grey',
  'griffin',
  'griffon',
  'grizzled',
  'grizzly',
  'grocer',
  'ground',
  'gruesome',
  'grumbiter',
  'grytha',
  'gryttefel',
  'guard',
  'guarddog',
  'guardian',
  'guerrilla',
  'guest',
  'guide',
  'guildmaster',
  'gull',
  'gulth',
  'gurundi',
  'gwark',
  'gypsy',
  'gyrnath',
  'hades',
  'hag',
  'haggard',
  'halfbreed',
  'halfling',
  'hand',
  'hands',
  'hans',
  'harlan',
  'harlans',
  'harpy',
  'hashaii',
  'hat',
  'hatamoto',
  'hatchling',
  'haughty',
  'hayden',
  'head',
  'headmaster',
  'healer',
  'heap',
  'hearts',
  'heather',
  'hecate',
  'heckkingrel',
  'hedge',
  'hekkezth',
  'hell',
  'herakleous',
  'herald',
  'hercules',
  'hermit',
  'hero',
  'hideous',
  'high',
  'hippo',
  'hippocamp',
  'hippopotamus',
  'hobgoblin',
  'hoeur',
  'hog',
  'holy',
  'horn',
  'horned',
  'horror',
  'horse',
  'horsehead',
  'houdini',
  'hound',
  'hovering',
  'hrandor',
  'huge',
  'human',
  'humanoid',
  'hunchback',
  'hunter',
  'hunting',
  'hurricane',
  'hydra',
  'hyena',
  'hyokki',
  'hypnos',
  'hyrum',
  'ice',
  'id',
  'idiot',
  'ikelian',
  'illusionist',
  'imp',
  'impala',
  'impaled',
  'incalae',
  'infant',
  'ingenue',
  'injured',
  'ink',
  'inmate',
  'innkeeper',
  'innocent',
  'insane',
  'inscect',
  'insect',
  'instrument',
  'inventor',
  'iron',
  'isha',
  'ix',
  'ixthian',
  'jack',
  'jacques',
  'jaguar',
  'jail',
  'jailor',
  'james',
  'janitor',
  'janus',
  'jao',
  'japanese',
  'jastil',
  'jaw',
  'jaws',
  'jeanette',
  'jellyfish',
  'jenny',
  'jerry',
  'jester',
  'jeweler',
  'jim',
  'jimbo',
  'jochem',
  'joe',
  'john',
  'joseph',
  'josh',
  'jubi',
  'judge',
  'juggernaut',
  'jungle',
  'junior',
  'justine',
  'kadrym',
  'kafkefoni',
  'kalas',
  'kalek',
  'kalten',
  'kamila',
  'karen',
  'kasumi',
  'kazic',
  'keeper',
  'keg',
  'kegroch',
  'kelezir',
  'kendal',
  'keris',
  'keseth',
  'kestirin',
  'khun',
  'ki',
  'kid',
  'kikyo',
  'kimuran',
  'kindly',
  'kineyer',
  'king',
  'kingfisher',
  'kingsnake',
  'kirhea',
  'kirin',
  'kitten',
  'kitty',
  'klath',
  'klizgisin',
  'knight',
  'knives',
  'kobold',
  'komodo',
  'kosseth',
  'kraken',
  'kranch',
  'kretz',
  'krynel',
  'krytun',
  'kuo',
  'laborer',
  'lac',
  'lachenel',
  'ladder',
  'lady',
  'lahac',
  'lamia',
  'lanky',
  'lao',
  'large',
  'larger',
  'laurana',
  'lava',
  'layman',
  'lazlo',
  'lead',
  'leader',
  'leaf',
  'leather',
  'leayr',
  'lecturer',
  'leech',
  'legend',
  'lehamic',
  'leo',
  'leopard',
  'lestat',
  'lgp',
  'liantao',
  'libra',
  'librarian',
  'lich',
  'lifeguard',
  'light',
  'lightning',
  'lil',
  'lilith',
  'linave',
  'lingula',
  'lion',
  'lioness',
  'lithe',
  'lizard',
  'llama',
  'local',
  'loci',
  'loftwick',
  'lohar',
  'lookout',
  'lord',
  'lorelei',
  'lorin',
  'lormick',
  'lost',
  'lostgod',
  'lotharian',
  'lotus',
  'louis',
  'lucretia',
  'lumberjack',
  'lunar',
  'lunatic',
  'luriel',
  'm',
  'macaw',
  'machine',
  'mackerel',
  'mad',
  'madame',
  'madeleine',
  'maestro',
  'mage',
  'magi',
  'magic',
  'magician',
  'magister',
  'magneto',
  'magus',
  'maharajah',
  'maid',
  'maiden',
  'main',
  'maintenance',
  'major',
  'malachite',
  'malann',
  'malcontent',
  'male',
  'malgorath',
  'malthus',
  'mamba',
  'mammal',
  'mammoth',
  'man',
  'manticore',
  'mantok',
  'marauder',
  'mari',
  'mariko',
  'marisa',
  'marisothil',
  'marsh',
  'marshall',
  'martos',
  'masoch',
  'masochist',
  'mass',
  'master',
  'mastersmith',
  'mastodon',
  'mate',
  'matriarch',
  'matron',
  'matsyansana',
  'matt',
  'mature',
  'mayor',
  'mazekeeper',
  'Mazer',
  'meager',
  'medium',
  'medusa',
  'meek',
  'meg',
  'megaera',
  'mel',
  'melane',
  'melisande',
  'member',
  'meng',
  'mengoroth',
  'mentor',
  'mephesteus',
  'mercenary',
  'merchant',
  'mercier',
  'mermaid',
  'metal',
  'metaman',
  'metaphysician',
  'michael',
  'mick',
  'middenheim',
  'mighty',
  'migo',
  'mill',
  'miller',
  'mimic',
  'mindless',
  'mine',
  'miner',
  'mineworker',
  'minion',
  'minos',
  'minotaur',
  'minstrel',
  'mir',
  'mirissa',
  'mirror',
  'mist',
  'mistress',
  'mizir',
  'mme',
  'mod',
  'moira',
  'mole',
  'mongrel',
  'monk',
  'monkey',
  'monoceros',
  'monsieur',
  'monster',
  'monstrosity',
  'moose',
  'moray',
  'mored',
  'mos',
  'mosquito',
  'moss',
  'mother',
  'mountain',
  'mountainclimber',
  'mred',
  'mud',
  'mudder',
  'muglo',
  'mummy',
  'murex',
  'mus',
  'muse',
  'mushroom',
  'music',
  'musician',
  'muskelounge',
  'musky',
  'mutant',
  'myree',
  'mysterious',
  'mystic',
  'naga',
  'nalsureii',
  'nameless',
  'nasty',
  'nebula',
  'necro',
  'necromancer',
  'nectromanticus',
  'neptune',
  'nether',
  'neutral',
  'neutrality',
  'new',
  'newt',
  'ni',
  'nice',
  'nicolas',
  'night',
  'nightgaunt',
  'nightmare',
  'nil',
  'nile',
  'nine',
  'ninja',
  'nix',
  'noble',
  'nomad',
  'nothing',
  'nurse',
  'nursemaid',
  'nyarlathotep',
  'oak',
  'oaken',
  'observer',
  'oceanid',
  'octalon',
  'ocypete',
  'odei',
  'odif',
  'of',
  'off',
  'offduty',
  'officer',
  'oggas',
  'ogre',
  'ogress',
  'ogun',
  'oil',
  'old',
  'older',
  'oldman',
  'olga',
  'olvan',
  'omen',
  'omnai',
  'one',
  'onyx',
  'opera',
  'orak',
  'orc',
  'orchestra',
  'orexis',
  'orion',
  'ornithopter',
  'ostermark',
  'ostrich',
  'outpost',
  'overlord',
  'owl',
  'owner',
  'ox',
  'pack',
  'packrat',
  'page',
  'paladin',
  'pale',
  'paltro',
  'panua',
  'paperboy',
  'parisian',
  'parrot',
  'particle',
  'paste',
  'patient',
  'patriarch',
  'patron',
  'paxman',
  'peacock',
  'pebble',
  'peddler',
  'pegasus',
  'pel',
  'pelican',
  'pelleas',
  'penny',
  'peon',
  'peppery',
  'percussist',
  'periwinkle',
  'perluna',
  'pern',
  'pernicious',
  'perry',
  'persian',
  'persimmons',
  'pet',
  'pete',
  'peter',
  'petrified',
  'phantom',
  'phauryal',
  'philosopher',
  'physician',
  'physicist',
  'piangi',
  'piano',
  'pierre',
  'pig',
  'pilgrim',
  'piotr',
  'pirate',
  'pirates',
  'pisces',
  'pit',
  'pitch',
  'pitchblack',
  'pitcher',
  'pixie',
  'plant',
  'plaster',
  'player',
  'playerpiano',
  'pleiades',
  'po',
  'poisonous',
  'polar',
  'polaris',
  'pony',
  'poor',
  'portal',
  'portrait',
  'postman',
  'pot',
  'pound',
  'poxman',
  'prairie',
  'preserver',
  'pretentious',
  'priest',
  'priestess',
  'prima',
  'prince',
  'princess',
  'prison',
  'prisoner',
  'prophet',
  'proserpina',
  'protector',
  'psemapod',
  'ptilol',
  'puddle',
  'pupil',
  'puppy',
  'pureblood',
  'purple',
  'pussy',
  'pyr',
  'pyruleth',
  'pyrver',
  'python',
  'quartz',
  'queen',
  'questmaster',
  'quickling',
  'quintor',
  'rabbit',
  'rabit',
  'racehorse',
  'rack',
  'Rackham',
  'radamanthus',
  'radiant',
  'rahin',
  'raider',
  'rainbow',
  'rakjak',
  'raoul',
  'rat',
  'rattlesnake',
  'raven',
  'reaper',
  'receptionist',
  'recruit',
  'red',
  'redmonton',
  'regal',
  'reina',
  'reptile',
  'reptilian',
  'republican',
  'research',
  'researcher',
  'retired',
  'retiree',
  'reton',
  'rewey',
  'rezlan',
  'rhabyn',
  'rhino',
  'rhinoceros',
  'rider',
  'rin',
  'ring',
  'ripper',
  'risen',
  'robin',
  'robot',
  'roc',
  'rock',
  'roe',
  'rogue',
  'romnian',
  'ron',
  'rook',
  'rose',
  'roshan',
  'rostrai',
  'rot',
  'rottweiler',
  'rotund',
  'rotworm',
  'rover',
  'royal',
  'rubber',
  'rubberducky',
  'ruler',
  'run',
  'rust',
  'rygor',
  'sabastian',
  'sabre',
  'sacrifice',
  'sadist',
  'saeyrk',
  'safari',
  'sag',
  'sage',
  'sagely',
  'sagittarius',
  'sagreth',
  'sagrethi',
  'sailor',
  'saint',
  'sal',
  'salamander',
  'sales',
  'salt',
  'salty',
  'salvatore',
  'salvia',
  'salvias',
  'sammael',
  'samurai',
  'sandstone',
  'santiago',
  'sapphire',
  'sas',
  'sasquatch',
  'saule',
  'savant',
  'scabri',
  'scar',
  'scavenger',
  'scene',
  'scholar',
  'school',
  'scientist',
  'scorpat',
  'scorpio',
  'scorpion',
  'scout',
  'scullery',
  'scylla',
  'sea',
  'seal',
  'seasoned',
  'secretary',
  'security',
  'seeker',
  'seelie',
  'seeress',
  'sen',
  'senior',
  'sennyo',
  'sentinel',
  'sentry',
  'seraphim',
  'sergeant',
  'serkhet',
  'serpent',
  'servant',
  'servitor',
  'seth',
  'seven',
  'sewing',
  'sexton',
  'shade',
  'shadow',
  'shadowdancer',
  'shadowman',
  'shadowmaster',
  'shadows',
  'shadowy',
  'shaiyn',
  'shaman',
  'shamble',
  'shambling',
  'shantak',
  'shargugh',
  'shark',
  'she',
  'sheep',
  'sheepherder',
  'shepherd',
  'shev',
  'shifter',
  'shimmering',
  'shiragiku',
  'shiriff',
  'shopkeeper',
  'shopsmith',
  'shullush',
  'siana',
  'sidewinder',
  'silver',
  'silverback',
  'silvery',
  'simeon',
  'singer',
  'siren',
  'sirlth',
  'sirrin',
  'sister',
  'six',
  'skeletal',
  'skeleton',
  'slave',
  'slavedriver',
  'slayer',
  'slimy',
  'sloth',
  'slug',
  'small',
  'smilodon',
  'smith',
  'snail',
  'snake',
  'snap',
  'snapper',
  'snatch',
  'snob',
  'snow',
  'snowcat',
  'snowflake',
  'snowman',
  'snowrabbit',
  'snowshoe',
  'socialite',
  'soldier',
  'son',
  'sondereel',
  'songbird',
  'sorcerer',
  'sorelli',
  'soul',
  'souls',
  'sous',
  'spades',
  'spark',
  'sparrow',
  'speckled',
  'specter',
  'spectral',
  'spectre',
  'speedy',
  'spellcaster',
  'sphen',
  'sphere',
  'sphinx',
  'spi',
  'spider',
  'spindly',
  'spiny',
  'spiral',
  'spirit',
  'spitting',
  'splendid',
  'spoldovian',
  'squid',
  'squigglywig',
  'squire',
  'squirrel',
  'sslessi',
  'stable',
  'stableboy',
  'stablehand',
  'stacia',
  'stage',
  'stair',
  'staircase',
  'stairs',
  'stalker',
  'standing',
  'stanislaw',
  'star',
  'statue',
  'stefan',
  'steverph',
  'stheno',
  'stirge',
  'stockbroker',
  'stone',
  'stoned',
  'storekeeper',
  'storm',
  'stranger',
  'stray',
  'street',
  'strength',
  'succubi',
  'succubus',
  'sui',
  'suithiess',
  'sulfur',
  'sultan',
  'sundew',
  'sunyo',
  'super',
  'supergiant',
  'superior',
  'supervisor',
  'surveyor',
  'swab',
  'swallow',
  'swamp',
  'swan',
  'sweeper',
  'swordpupil',
  'sxuvu',
  'sylph',
  'tako',
  'talkinghorse',
  'tall',
  'tam',
  'taninniver',
  'taskmaster',
  'taurus',
  'teacher',
  'teller',
  'templar',
  'ten',
  'tentacled',
  'tephanis',
  'terror',
  'terroroxulus',
  'tester',
  'teyrdok',
  'th',
  'thad',
  'thain',
  'the',
  'theatre',
  'thessen',
  'thief',
  'thiess',
  'thieved',
  'thrag',
  'three',
  'threggi',
  'thule',
  'thusk',
  'tiarella',
  'tiefling',
  'tiger',
  'tim',
  'timber',
  'timid',
  'tiny',
  'tirag',
  'tisiphone',
  'titan',
  'toa',
  'toad',
  'todd',
  'toddler',
  'togna',
  'toktok',
  'tom',
  'tome',
  'tomoko',
  'topiary',
  'tordek',
  'tortoise',
  'tortured',
  'toucan',
  'touen',
  'tower',
  'townsperson',
  'toy',
  'tracker',
  'trader',
  'trainee',
  'trainer',
  'trainingmaster',
  'traveler',
  'traz',
  'treant',
  'treasure',
  'treasurer',
  'tree',
  'treebeard',
  'treeman',
  'trien',
  'troll',
  'trollkin',
  'trout',
  'trouth',
  'trylan',
  'tsetse',
  'tuptim',
  'tur',
  'turimalga',
  'twilo',
  'two',
  'tymora',
  'tyrand',
  'tyrant',
  'tythox',
  'tzeentch',
  'tzyr',
  'ugishka',
  'ugly',
  'undead',
  'unholy',
  'unicorn',
  'unseelie',
  'unspeakable',
  'unwanted',
  'ura',
  'urbanite',
  'urchin',
  'ursa',
  'usher',
  'usiel',
  'usuvia',
  'utter',
  'vadhb',
  'vadhp',
  'vadir',
  'vadpb',
  'vadpr',
  'vadser',
  'vaisyo',
  'vald',
  'valmont',
  'vamp',
  'vampire',
  'vanyel',
  'varimthrax',
  'varka',
  'vault',
  'vaultdweller',
  'vedder',
  'vendor',
  'vengeful',
  'venzu',
  'veteran',
  'vicar',
  'vicious',
  'victim',
  'vile',
  'villager',
  'vine',
  'vintner',
  'viola',
  'violin',
  'viper',
  'virgo',
  'vizier',
  'vlad',
  'volunteer',
  'vorn',
  'voskian',
  'vulture',
  'vyman',
  'vyrinth',
  'waiter',
  'waiting',
  'waitress',
  'walker',
  'wall',
  'wandering',
  'war',
  'warden',
  'warder',
  'wardrobe',
  'warg',
  'warlock',
  'warrior',
  'wart',
  'warthog',
  'wasp',
  'water',
  'waterbaby',
  'waurk',
  'weak',
  'weaponsmaster',
  'weaponsmith',
  'weary',
  'weasel',
  'weaver',
  'weeds',
  'welmar',
  'wen',
  'westenra',
  'wet',
  'whale',
  'wheels',
  'whi',
  'whirlpool',
  'white',
  'wife',
  'wight',
  'wil',
  'wild',
  'wildebeest',
  'winged',
  'winter',
  'wiseman',
  'witch',
  'withered',
  'wizard',
  'wolf',
  'wolven',
  'woman',
  'wooden',
  'woolly',
  'worker',
  'world',
  'worlds',
  'worm',
  'wormwood',
  'worshipper',
  'wraith',
  'wynona',
  'wyrm',
  'wyvern',
  'xandian',
  'xandolap',
  'xavier',
  'xerui',
  'xfxqrfmwfgjp',
  'xia',
  'xist',
  'yabon',
  'yadeth',
  'yathos',
  'yeti',
  'yevaud',
  'ygaddrozil',
  'yltsaeb',
  'ymymry',
  'ynoild',
  'young',
  'younger',
  'youngster',
  'yousei',
  'youth',
  'yrgroch',
  'yssa',
  'yul',
  'yulmazil',
  'yvie',
  'zartug',
  'zealot',
  'zebra',
  'zombie',
  'zoo',
  'zookeeper',
  'zovanak',
  'zyca',
  'zyekian',
  'zylas',
}

whereMap = {
  {1,     399,   [[The Shrines]]},
  {401,   499,   [[The Etheral Plane]]},
  {501,   599,   [[The Maritime Museum]]},
  {800,   899,   [[The Dragon Caves]]},
  {901,   999,   [[The Spirit Woods]]},
  {1000,  1099,  [[Allemonde]]},
  {1100,  1199,  [[The Shire]]},
  {1200,  1399,  [[The Canticle]]},
  {1401,  1499,  [[God Rooms]]},
  {1701,  1799,  [[The Garden]]},
  {1801,  1820,  [[The Death Tower]]},
  {1821,  1999,  [[The Lands]]},
  {2001,  2078,  [[The Galaxy]]},
  {2101,  2199,  [[Zhalur the Golden]]},
  {2301,  2399,  [[The Warring Roses]]},
  {2501,  2599,  [[The New Graveyard]]},
  {2600,  2699,  [[The Zoo]]},
  {2701,  2799,  [[The Chateau of the Dead]]},
  {2801,  2899,  [[The Ivory Tower]]},
  {2900,  2950,  [[The Newt Caves]]},
  {3000,  3099,  [[Northern Midgaard]]},
  {3100,  3199,  [[Southern Midgaard]]},
  {3200,  3299,  [[The River and Tower of Sorcery]]},
  {3300,  3399,  [[The Buildings of Midgaard]]},
  {3400,  3499,  [[The Graveyard Plus]]},
  {3551,  3599,  [[Le Chateau d'Angoisse]]},
  {3601,  3623,  [[The Martial Arts Dojo]]},
  {3701,  3799,  [[The Mayor's House]]},
  {3801,  3899,  [[The Pixies' Garden]]},
  {3901,  3999,  [[The Cathedral of Mortal Heroes]]},
  {4000,  4099,  [[Mt. Durgathel]]},
  {4100,  4299,  [[The House of Horror]]},
  {4501,  4520,  [[The Goblin Kingdom]]},
  {4601,  4699,  [[The Evil Palace]]},
  {4701,  4799,  [[The Myree Orchard]]},
  {4801,  4899,  [[The Halfing Village]]},
  {5001,  5099,  [[The Lost City]]},
  {5100,  5199,  [[Drow City]]},
  {5200,  5299,  [[The City of Thalos]]},
  {5301,  5350,  [[The Deserted Village]]},
  {5400,  5499,  [[The Wasteland]]},
  {5601,  5699,  [[Piotrsgrad]]},
  {5700,  5799,  [[The Great Pyramid]]},
  {6000,  6099,  [[Haon Dor Light~]]},
  {6100,  6199,  [[Haon Dor Dark]]},
  {6201,  6299,  [[Ozymar's City]]},
  {6301,  6399,  [[The Arachnid Archives]]},
  {6401,  6499,  [[The Ghost Ship]]},
  {6500,  6599,  [[The Dwarven Kingdom]]},
  {6600,  6699,  [[Gurundi Forest]]},
  {6700,  6799,  [[The Threggi Pit]]},
  {6801,  6899,  [[The Alien's Den]]},
  {6900,  6999,  [[Quifael's Shop]]},
  {7000,  7099,  [[The Evil Outpost]]},
  {7101,  7199,  [[The Midgaard Asylum]]},
  {7201,  7299,  [[Vadir Temple]]},
  {7301,  7399,  [[The Battlefield]]},
  {7401,  7499,  [[The Battlefield Village]]},
  {7500,  7599,  [[The Pirate Ship]]},
  {7601,  7699,  [[The Hall of the Lost Gods]]},
  {7900,  7999,  [[Redferne's Residence]]},
  {8001,  8099,  [[Cei'Arda]]},
  {8104,  8199,  [[The Ocean]]},
  {8201,  8299,  [[The Sea of Love]]},
  {8301,  8399,  [[The Beach]]},
  {8401,  8499,  [[The Festival of Antiquity]]},
  {8501,  8599,  [[The Desert and Lake]]},
  {8600,  8699,  [[The Quest for the Holy Grail]]},
  {8800,  8899,  [[Le Theatre des Vampyres]]},
  {8901,  8955,  [[The King's Castle]]},
  {9101,  9199,  [[Cloud City]]},
  {9301,  9399,  [[Loftwick]]},
  {9401,  9460,  [[The Elemental Canyon]]},
  {9501,  9550,  [[The Wolves Cave]]},
  {9600,  9699,  [[Morgoth]]},
  {10001, 10099, [[The Dark Cathedral]]},
  {10300, 10399, [[The Monk Monastary]]},
  {10401, 10449, [[QuickLand]]},
  {10501, 10599, [[The Great Desert]]},
  {10601, 10699, [[Blackpool Swamp]]},
  {10701, 10799, [[The Golem Kingdom]]},
  {10801, 10899, [[Chaos Lands]]},
  {10900, 10999, [[Zyca City]]},
  {11000, 11299, [[The UnderWorld]]},
  {11300, 11369, [[The Village of Romnia]]},
  {11401, 11440, [[The Castle of Despair]]},
  {11500, 11599, [[Phantom I]]},
  {11601, 11699, [[Lorien]]},
  {11700, 11799, [[Phantom II]]},
  {11800, 11899, [[Straits of Messia]]},
  {12000, 12200, [[The Swamp]]},
  {12201, 12300, [[The Swamp and Secret Caves]]},
  {12801, 12899, [[The Nightmare]]},
  {12901, 12999, [[The Prison of Souls]]},
  {13001, 13099, [[The Roc Aviary]]},
  {13100, 13199, [[The Templars Mercador]]},
  {13200, 13299, [[Rainforest of Janus]]},
  {13600, 13699, [[The Gnoll Fortress]]},
  {13700, 13799, [[The Cave of the Sag'rethi]]},
  {13800, 13899, [[The Safari]]},
  {14201, 14299, [[Slaadi Jungle]]},
  {14301, 14399, [[Dark Kingdom I]]},
  {14400, 14499, [[Dark Kingdom II]]},
  {14501, 14599, [[Forgotten Valley]]},
  {14601, 14699, [[The Dwarven Lunar Mines I]]},
  {14700, 14799, [[The Dwarven Lunar Mines II]]},
  {15400, 15499, [[Dark Kingdom III]]},
  {16601, 16645, [[The Heour]]},
  {17601, 17699, [[The Gladiator Arena]]},
  {17900, 17993, [[The Wood of Ngai]]},
  {18700, 18799, [[The Midgaard Museum]]},
  {19200, 19299, [[Castle Mistamere]]},
  {20001, 20099, [[Undead Realm]]},
  {20100, 20199, [[The Undead Realm II]]},
  {22000, 22052, [[Phantom III]]},
  {22401, 22499, [[The DarkFall]]},
  {24456, 24999, [[The Hospital]]},
  {25000, 25099, [[The Abyss]]},
  {25201, 25299, [[FrostHolme]]},
  {25301, 25399, [[UtterFrost Cavern]]},
  {25501, 25599, [[Wyvern Wood]]},
  {26500, 26583, [[The Druid Grove of Gyrnath]]},
  {26601, 26699, [[The Ekitom Mines]]},
  {26701, 26799, [[Midgaard Tar Pit]]},
  {28000, 28099, [[MirIsland]]},
  {28100, 28199, [[Mir Crusade]]},
  {28200, 28299, [[KoboldsI]]}
}

-- This function is triggered once for each line of 'where' output in order to capture the mob on that line
-- A unique key is created by combining the mobs short description and area; unique mobs are queued for 'stat'ing
function captureWhereMobs()
  -- windex is the position within the 'where' command itself and must be saved for subsequent 'stat' command;
  -- note that this is NOT a static value so 'stat' must be issued shortly after where or this may change
  local windex = trim( matches[2] )
  windex       = tonumber( windex )
  local sdesc  = trim( matches[3] )
  if playerNames[sdesc] then return end -- Don't stat players
  local rmvnum    = trim( matches[5] )
  -- Get the area name by translating vnum->rnum->area; unknown areas are represented by the room number
  rmvnum          = tonumber( rmvnum )
  local rmarea    = getWhereArea( rmvnum )

  -- Create a unique key by combining the mob's short name and rmvnum
  local uniqueKey = sdesc .. "_" .. rmvnum

  -- If a mob with this short description has been seen in this room, assume we can skip it
  if not mobsToStat[uniqueKey] then
    mobsToStat[uniqueKey].index   = windex
    mobsToStat[uniqueKey].keyword = currentMobKeyword
    mobsToStat[uniqueKey].stated  = false
  end
  if not mobsCaptured[uniqueKey] then
    mobsCaptured[uniqueKey] = {
      stated            = false,
      short_description = sdesc,
      index             = windex,
      area              = rmarea,
      special_attacks   = {},
      stats             = {},
      known_rooms       = {rmvnum}
    }
  else
    -- If the mob/area combination is known, update its list of known rooms if this room is new
    if not table.contains( mobsCaptured[uniqueKey].known_rooms, rmvnum ) then
      table.insert( mobsCaptured[uniqueKey].known_rooms, rmvnum )
    end
  end
end
-- Function to initiate stat command for the next unstated mob
function statNextMob()
  cecho( f "\n<yellow_green>statNextMob()<reset>" )
  local foundUnstated = false

  for uniqueKey, mob in pairs( mobsCaptured ) do
    if not mob.stated then
      cecho( f "\nstatNextMob() found mob to stat: <yellow_green>{uniqueKey}<reset>" )
      -- Issue the stat command for the current mob
      send( f 'stat c {mob.index}.{currentMobKeyword}', false )
      -- Mark the mob as stated to avoid re-stat'ing
      mob.stated    = true
      foundUnstated = true
      -- Set up the temporary trigger for the next prompt to call statNextMob again
      tempRegexTrigger( "\\s*^<", statNextMob, 1 )
      break -- Exit the loop after scheduling a stat for one mob
    end
  end
  -- If no unstated mob was found, all mobs have been processed; call whereNextMob
  if not foundUnstated then
    cecho( f "\n<maroon>No unstated mobs found<reset>, moving to <royal_blue>whereNextMob()<reset>" )
    whereNextMob()
  end
end
-- Stat block seen with "PC" type; remove this entry from the capturedMobs table
function removeCapturedPC( pcName )
  cecho( "info", f "\nRemoving <royal_blue>{pcName}<reset> from capturedMobs" )
  for i = #capturedMobs, 1, -1 do
    if capturedMobs[i].short == pcName then
      table.remove( capturedMobs, i )
      break
    end
  end
end

-- I already have a trim() function; you don't need to implement one.
-- Triggered by lines returned by the 'where' command; add or update mob data in the capturedMobs list
function captureWhereMob()
  local mobIndex = tonumber( matches[2] )
  local mobShort = trim( matches[3] )
  local roomID   = tonumber( matches[5] )

  local mobFound = false
  for _, mob in ipairs( capturedMobs ) do
    if mob.short == mobShort then
      mobFound = true
      -- Update the rooms list for this mob in the capturedMobs table
      -- Every mob should end up with a list of rooms in which it was "seen"
      if not table.contains( mob.rooms, roomID ) then
        table.insert( mob.rooms, roomID )
      end
      break
    end
  end
  if not mobFound then
    -- Add the newly-discovered mob to the capturedMobs table with an empty stat block
    table.insert( capturedMobs, {
      short = mobShort, -- Match against this when inserting stat blocks
      stats = {},
      specials = {},
      rooms = {roomID}
    } )
    -- Add index to mobIndicesToStat table for new mobs
    -- We'll iterate over this later issuing stat commands like 'stat c 1.arachnid'
    table.insert( mobIndicesToStat, {index = mobIndex, keyword = currentMobKeyword} )
  end
end
-- Mudlet has a built-in table.contains() function, you don't need to implement one.
-- Print the content of the capturedMobs table filtered by the first letter of the mob's name
function displayCapturedMobsByLetter( letter )
  local filterLetter = letter:lower() -- To handle case insensitivity
  cecho( "\n<green>--- Captured Mobs Starting with '" .. letter .. "' ---<reset>" )

  for _, mob in ipairs( capturedMobs ) do
    local mobFirstLetter = mob.short:sub( 1, 1 ):lower()
    if mobFirstLetter == filterLetter then
      cecho( f( "\n<yellow>Mob: <reset>{mob.short}" ) )
      cecho( f( "\n<yellow>Rooms: <reset>{table.concat(mob.rooms, ', ')}" ) )

      if #mob.specials > 0 then
        cecho( "\n<yellow>Special Attacks:<reset>" )
        for _, special in ipairs( mob.specials ) do
          local attackDetails = f(
            "Chance: {special.chance}, Damage: {special.damage.n}D{special.damage.s}+{special.damage.m}, HitRoll: {special.hitRoll}, Target: {special.target}, Type: {special.type}, Strings: {special.strings}" )
          cecho( f( "\n\t{attackDetails}" ) )
        end
      end
      if next( mob.stats ) ~= nil then
        cecho( "\n<yellow>Stats:<reset>" )
        -- Assuming stats are stored as a sequence of values; adjust based on actual structure
        for i, stat in ipairs( mob.stats ) do
          cecho( f( "\n\tStat {i}: {stat}" ) )
        end
      end
    end
  end
end
-- Function to calculate duration
function calculateDuration( pc, spellName )
  local endTime = getStopWatchTime( "timer" )
  local startTime = affectStartTimes[pc][spellName]
  if startTime then
    local newDuration = endTime - startTime
    local existingDuration = affectInfo[spellName].duration

    if existingDuration then
      if math.abs( newDuration - existingDuration ) <= 60 then
        -- If there's already a duration stored for this spell, average the new and existing durations
        return math.floor( ((newDuration + existingDuration) / 2) / 10 ) * 10
      end
      -- If the calculated duration differs by more than +/- 60s, this was probably an error so discard
      return existingDuration
    else
      -- This is the first recorded duration
      return math.floor( newDuration / 10 ) * 10
    end
  end
  return nil
end

function feedFile()
  local testRate = 0.01
  local filePath = "C:\\Dev\\mud\\mudlet\\wheres.txt" -- Update the path as necessary
  local file = io.open( filePath, "r" )               -- Open the file for reading

  local lines = file:lines() -- Get an iterator over lines in the file

  local function feedLine()
    local nextLine = lines()          -- Read the next line
    if nextLine then                  -- Continue if there's a line to read
      cfeedTriggers( nextLine )       -- Feed the line to Mudlet's trigger processing
      tempTimer( testRate, feedLine ) -- Schedule the next call
    else
      file:close()                    -- Close the file when done
    end
  end

  feedLine() -- Start the process
end

---@diagnostic disable: cast-local-type

-- Parse prompt components and trigger an update if anything has changed; ignore maximum values
function triggerParsePrompt()
  -- Grab current HP, MANA, MOVE from prompt
  local hpc, mnc, mvc = tonumber( matches[2] ), tonumber( matches[3] ), tonumber( matches[4] )

  -- Tank & Target conditions (if present)
  local tnk, trg = matches[5], matches[6]

  -- Store a 'localilzed' combat status for convenience
  if trg and #trg > 0 then
    in_combat = true
  else
    in_combat = false
  end
  -- Compare new values to local prior values
  local needs_update = hpc ~= pcLastStatus["currentHP"] or
      mnc ~= pcLastStatus["currentMana"] or
      mvc ~= pcLastStatus["currentMoves"] or
      tnk ~= pcLastStatus["tank"] or
      trg ~= pcLastStatus["target"]

  -- Exit early if nothing has changed
  if not needs_update then
    return
  else
    -- If something changed, update the prior-value table
    pcLastStatus["currentHP"]    = hpc
    pcLastStatus["currentMana"]  = mnc
    pcLastStatus["currentMoves"] = mvc
    pcLastStatus["tank"]         = tnk
    pcLastStatus["target"]       = trg

    -- Then pass the updated values to the main session
    raiseGlobalEvent( "event_pcStatus_prompt", SESSION, hpc, mnc, mvc, tnk, trg )
  end
end

-- Parse score components and send them to the main session
function triggerParseScore()
  -- Just need this to fire once each time we 'score'
  disableTrigger( "Parse Score" )

  -- The multimatches table holds the values from score in a 2-dimensional array
  -- in the order they appear in score, so multimatches[l][n] = nth value on line l
  local dam, maxHP = multimatches[1][2], multimatches[1][3]
  local hit, mnm   = multimatches[2][2], multimatches[2][3]
  local arm, mvm   = multimatches[3][2], multimatches[3][3]
  local mac        = multimatches[4][2]
  local aln        = multimatches[5][2]

  -- For the numbers that get "big" we need to strip commas & convert to numbers
  local exp        = string.gsub( multimatches[6][2], ",", "" )
  local exh        = string.gsub( multimatches[7][2], ",", "" )
  local exl        = string.gsub( multimatches[8][2], ",", "" )
  local gld        = string.gsub( multimatches[9][2], ",", "" )

  exp              = tonumber( exp )
  exh              = tonumber( exh )
  exl              = tonumber( exl )
  gld              = tonumber( gld )

  raiseGlobalEvent( "event_pcStatus_score", SESSION, dam, maxHP, hit, mnm, arm, mvm, mac, aln, exp, exh, exl, gld )
end

---@diagnostic disable: cast-local-type
-- Pull stats from the prompt and update status & status table
function triggerParsePromptOld()
  -- Get current HP, MANA, MOVE from prompt
  local hpc, mnc, mvc = tonumber( matches[2] ), tonumber( matches[3] ), tonumber( matches[4] )

  -- Tank & Target conditions (if present)
  local tnk, trg = matches[5], matches[6]

  if (backupMira and tnk ~= "full") and (gtank) then
    send( f "cast 'miracle' {gtank}" )
  end
  backupMira = false

  -- Store a 'localilzed' combat status for convenience
  if trg and #trg > 0 then
    in_combat = true
  else
    in_combat = false
  end
  -- Main session can compare directly to the existing values in the master status table
  local needs_update = hpc ~= pcStatus[1]["currentHP"] or
      mnc ~= pcStatus[1]["currentMana"] or
      mvc ~= pcStatus[1]["currentMoves"] or
      tnk ~= pcStatus[1]["tank"] or
      trg ~= pcStatus[1]["target"]

  if not needs_update then
    return
  else
    pcStatusPrompt( SESSION, hpc, mnc, mvc, tnk, trg )
  end
end

-- Items to ignore when checking to see whether something has been added to the database;
-- this is going to get way too long and needs another solution eventually.
ignoredItems     = {
  ["a vanity chit"]                        = true,
  ["potion of healing"]                    = true,
  ["Cradle of the Forest"]                 = true,
  ["a brilliant blue aquamarine"]          = true,
  ["a beazor"]                             = true,
  ["a brilliant red ruby"]                 = true,
  ["a small pile of precious metals"]      = true,
  ["a piece of diamond"]                   = true,
  ["a delicate pair of lapidary's pliers"] = true,
  ["a shimmering filament of gold"]        = true,
  ["a lavish opium pipe"]                  = true,
  ["a durable mining helmet"]              = true,
  ["a piece of Commiphora wightii bark"]   = true,
  ["a scroll of healing"]                  = true,
  ["an Amber Elixir"]                      = true,
  ["a bottle of greenish ooze"]            = true,
  ["a Delicate Daisy"]                     = true,
  ["a pair of dice"]                       = true,
  ["the trust flag"]                       = true,
  ["a bread"]                              = true,
  ["a waterskin"]                          = true,
  ["glowing potion"]                       = true,
  ["transparent potion"]                   = true,
  ["a yellow potion of see invisible"]     = true,
  ["a snowball"]                           = true,
  ["a golden goblet"]                      = true,
  ["a scroll of recall"]                   = true,
  ["an olive branch"]                      = true,
  ["a small ball of Labdanum resin"]       = true,
  ["a raft"]                               = true,
  ["a Seawater Potion"]                    = true,
  ["a bag"]                                = true,
  ["a bottle of red potion"]               = true,
  ["a pouch of irridescent pollen"]        = true,
  ["a Frosty Potion"]                      = true,
  ["a bloody brew"]                        = true,
  ["a strong-smelling brew"]               = true,
  ["a five cheesecake chit"]               = true,
  ["a five brownie chit"]                  = true,
  ["a milky orange potion"]                = true,
  ["a small ice opal"]                     = true,
  ["a Christmas Stocking"]                 = true,
}

function isIgnoredItem( item )
  local ignoredItemPatterns = {
    ["^.*chit$"] = true,
    ["^.*[Pp]otion.*$"] = true,
    ["^.*scroll of.*$"] = true,
  }
  for pattern in pairs( ignoredItemPatterns ) do
    if item:match( pattern ) then
      return true
    end
  end
  return false
end

-- Virtually traverse an exit from the players' current location to an adjoining room;
-- This is the primary function used to "follow" the PCs position in the Map; it is synchronized
-- with the MUD through the use of the mapQueue
function moveExit( direction )
  -- Make sure direction is long-version like 'north' to align with getRoomExits()
  local dir = LDIR[direction]
  local exits = getRoomExits( currentRoomNumber )

  if not exits[dir] then
    cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
    return false
  end
  local dst = tonumber( exits[dir] )
  if roomExists( dst ) then
    updatePlayerLocation( dst, direction )
    return true
  end
  cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
  return false
end
v
function laswield()
  expandAlias( 'las rem ring', false )
  expandAlias( 'las rem leg', false )
  expandAlias( 'las rem gloves', false )
  expandAlias( 'las get sky bag', false )
  expandAlias( 'las get gauntlets bag', false )
  expandAlias( 'las get bionic bag', false )
  expandAlias( 'las wear sky', false )
  expandAlias( 'las wear gauntlets', false )
  expandAlias( 'las wear bionic', false )
  expandAlias( 'las wield spirit', false )
  expandAlias( 'las rem sky', false )
  expandAlias( 'las rem gauntlets', false )
  expandAlias( 'las rem bionic', false )
  expandAlias( 'las give sky nandor', false )
  expandAlias( 'las give gauntlets nandor', false )
  expandAlias( 'las give bionic nadja', false )
  expandAlias( 'las wear gloves', false )
  expandAlias( 'las wear ring', false )
  expandAlias( 'las wear leg', false )
end

function nanwield()
  expandAlias( 'nan rem onyx', false )
  expandAlias( 'nan wear gauntlets', false )
  expandAlias( 'nan wear sky', false )
  expandAlias( 'nan wield cudgel', false )
  expandAlias( 'nan hold scalpel', false )
  expandAlias( 'nan rem sky', false )
  expandAlias( 'nan rem gauntlets', false )
  expandAlias( 'nan give sky nadja', false )
  expandAlias( 'nan give gauntlets nadja', false )
  expandAlias( 'nan wear onyx', false )
  expandAlias( 'nan wear gloves', false )
end
-- Called repeatedly to iterate each list of cloning assignments until complete
function doClone()
  -- First/last call condition
  if not nadjaClones then
    startClone()
  elseif #nadjaClones == 0 and #laszloClones == 0 then
    endClone()
  end
  -- If Nadja has clone mana, try the next clone
  if pcStatus[2]["currentMana"] > 100 and nadjaClones and #nadjaClones > 0 then
    -- Stand up & attempt to clone after setting a fresh success trigger
    expandAlias( "nad stand" )
    if nadCloneTrigger then killTrigger( nadCloneTrigger ) end
    nadCloneTrigger = tempTrigger( "Nadja creates a duplicate", [[table.remove( nadjaClones, 1 )]] )
    local nextClone = nadjaClones[1]
    expandAlias( f [[nad cast 'clone' {nextClone}]] )
  elseif pcStatus[2]["currentMana"] < 100 and #nadjaClones > 0 then
    expandAlias( "nad rest" )
  end
  -- Repeat for Laszlo
  if pcStatus[3]["currentMana"] > 100 and laszloClones and #laszloClones > 0 then
    expandAlias( "las stand" )
    if lasCloneTrigger then killTrigger( lasCloneTrigger ) end
    lasCloneTrigger = tempTrigger( "Laszlo creates a duplicate", [[table.remove( laszloClones, 1 )]] )
    local nextClone = laszloClones[1]
    expandAlias( f [[las cast 'clone' {nextClone}]] )
  elseif pcStatus[3]["currentMana"] < 100 and #laszloClones > 0 then
    expandAlias( "las rest" )
  end
end

function endClone()
  if lasCloneTrigger then killTrigger( lasCloneTrigger ) end
  if nadCloneTrigger then killTrigger( nadCloneTrigger ) end
  if nadjaClones then nadjaClones = nil end
  if laszloClones then laszloClones = nil end
  expandAlias( 'col get staff', false )
  expandAlias( 'col get halo', false )
  expandAlias( 'col get cuffs', false )
  expandAlias( 'col hold staff', false )
  expandAlias( 'col wear halo', false )
  expandAlias( 'col wear cuffs', false )

  expandAlias( 'las get staff', false )
  expandAlias( 'las get cuffs', false )
  expandAlias( 'las hold staff', false )
  expandAlias( 'las wear cuffs', false )
  expandAlias( 'las wear crocodile', false )

  expandAlias( 'nan get staff', false )
  expandAlias( 'nan get crocodile', false )
  expandAlias( 'nan hold staff', false )
  expandAlias( 'nan wear crocodile', false )

  expandAlias( 'nad hold staff', false )
  expandAlias( 'nad wear cuffs', false )

  expandAlias( "las give halo nandor", false )
  tempTimer( 1, [[expandAlias( "nan wear halo", false )]] )

  expandAlias( 'all save', false )
end

-- Prepare cloning sequence with gear assignments
function startClone()
  nadjaClones = {'cuffs', 'skin'}
  laszloClones = {'halo'}

  expandAlias( "nan rem halo", false )
  expandAlias( "nan give halo laszlo", false )
  send( 'get skin stocking', false )
  send( 'give skin nadja', false )

  -- And remove the items to clone
  expandAlias( 'nad rem cuffs', false )
end

function nadwield()
  expandAlias( 'nad rem ring', false )
  expandAlias( 'nad rem gloves', false )
  expandAlias( 'nad rem leg', false )
  expandAlias( 'nad wear sky', false )
  expandAlias( 'nad wear gauntlets', false )
  expandAlias( 'nad wear bionic', false )
  expandAlias( 'nad wield spirit', false )
  expandAlias( 'nad hold malachite', false )
  expandAlias( 'nad rem sky', false )
  expandAlias( 'nad rem gauntlets', false )
  expandAlias( 'nad rem bionic', false )
  expandAlias( 'nad give sky colin', false )
  expandAlias( 'nad give gauntlets colin', false )
  expandAlias( 'nad give bionic colin', false )
  expandAlias( 'nad wear ring', false )
  expandAlias( 'nad wear gloves', false )
  expandAlias( 'nad wear leg', false )
end

function colwield()
  expandAlias( 'col rem ring', false )
  expandAlias( 'col rem greaves', false )
  expandAlias( 'col wear sky', false )
  expandAlias( 'col wear bionic', false )
  expandAlias( 'col wear gauntlets', false )
  expandAlias( 'col wield hammer', false )
  expandAlias( 'col hold malachite', false )
  expandAlias( 'col rem sky', false )
  expandAlias( 'col rem gauntlets', false )
  expandAlias( 'col rem bionic', false )
  expandAlias( 'col give sky laszlo', false )
  expandAlias( 'col give gauntlets laszlo', false )
  expandAlias( 'col give bionic laszlo', false )
  expandAlias( 'col wear onyx', false )
  expandAlias( 'col wear greaves', false )
end


-- Use with cecho etc. to colorize output without massively long f-strings
function ec( s, c )
  local colors = {
    err  = "orange_red",   -- Error
    dbg  = "dodger_blue",  -- Debug
    val  = "blue_violet",  -- Value
    var  = "dark_orange",  -- Variable Name
    func = "green_yellow", -- Function Name
    info = "sea_green",    -- Info/Data
  }
  local sc = colors[c] or "ivory"
  if c ~= 'func' then
    return "<" .. sc .. ">" .. s .. "<reset>"
  else
    return "<" .. sc .. ">" .. s .. "<reset>()"
  end
end

-- Some rooms are currently unmappable (i.e., I couldn't reach them on my IMM.)
ignoredRooms = {
  [0] = true,
  [8284] = true,
  [6275] = true,
  [2276] = true,
  [2223] = true,
  [1290] = true,
  [979] = true,
  [1284] = true, -- Alchemist's Shoppe after an explosion?
  [1285] = true, -- Temple Avenue outside the Alchemist's Shoppe after an explosion?
}

-- Group related areas into a contiguous group for labeling purposes
function getLabelArea()
  if currentAreaNumber == 21 or currentAreaNumber == 30 or currentAreaNumber == 24 or currentAreaNumber == 22 or currentAreaData == 110 then
    return 21
  elseif currentAreaNumber == 89 or currentAreaNumber == 116 or currentAreaNumber == 87 then
    return 87
  elseif currentAreaNumber == 108 or currentAreaNumber == 103 or currentAreaNumber == 102 then
    return 102
  else
    return tonumber( currentAreaNumber )
  end
end

-- Prototype/beta function for importing Wintin commands from an external file
function importWintinActions()
  local testActions = {}
  -- Make an empty group to hold the imported triggers
  permRegexTrigger( "Imported", "", {"^#"}, "" )

  local triggerCounter = 1

  for _, actionString in ipairs( testActions ) do
    local triggerName = "Imported" .. triggerCounter
    local pattern, command, priority = parseWintinAction( actionString )

    command = f [[print("{command}")]]

    if isRegex( pattern ) then
      permRegexTrigger( triggerName, "Imported", {pattern}, command )
    else
      permSubstringTrigger( triggerName, "Imported", {pattern}, command )
    end
    triggerCounter = triggerCounter + 1
  end
end

-- Create a new room in the Mudlet; by default operates on the "current" room being the one you just arrived in;
-- passing dir and id will create a room offset from the current room (which no associated user data)
function createRoom( dir, id )
  if not customColorsDefined then defineCustomEnvColors() end
  local newRoomNumber = id or currentRoomNumber
  local nX, nY, nZ = mX, mY, mZ
  if dir == "east" then
    nX = nX + 1
  elseif dir == "west" then
    nX = nX - 1
  elseif dir == "north" then
    nY = nY + 1
  elseif dir == "south" then
    nY = nY - 1
  elseif dir == "up" then
    nZ = nZ + 1
  elseif dir == "down" then
    nZ = nZ - 1
  end
  -- Create a new room in the Mudlet mapper in the Area we're currently mapping
  addRoom( newRoomNumber )
  if currentAreaNumber == 115 or currentAreaNumber == 116 then
    currentAreaNumber = 115
    currentAreaName = 'Undead Realm'
  end
  setRoomArea( newRoomNumber, currentAreaName )
  setRoomCoordinates( currentRoomNumber, nX, nY, nZ )

  if not dir and not id then
    setRoomName( newRoomNumber, currentRoomData.roomName )
    setRoomUserData( newRoomNumber, "roomVNumber", currentRoomData.roomVNumber )
    setRoomUserData( newRoomNumber, "roomType", currentRoomData.roomType )
    setRoomUserData( newRoomNumber, "roomSpec", currentRoomData.roomSpec )
    setRoomUserData( newRoomNumber, "roomFlags", currentRoomData.roomFlags )
    setRoomUserData( newRoomNumber, "roomDescription", currentRoomData.roomDescription )
    setRoomUserData( newRoomNumber, "roomExtraKeyword", currentRoomData.roomExtraKeyword )
  else
    setRoomName( newRoomNumber, tostring( id ) )
  end
  setRoomStyle()
end

-- Clean up minimum room numbers corrupted by my dumb ass
function fixMinimumRoomNumbers()
  local aid = 0
  while worldData[aid] do
    local roomsData = worldData[aid].rooms
    local minRoom = nil
    for _, room in pairs( roomsData ) do
      local roomRNumber = tonumber( room.roomRNumber )
      if roomRNumber and (not minRoom or minRoom > roomRNumber) then
        minRoom = roomRNumber
      end
    end
    if minRoom and minRoom ~= worldData[aid].areaMinRoomRNumber then
      setMinimumRoomNumber( aid, minRoom )
    end
    aid = aid + 1
    -- Skip area 107
    if aid == 107 then aid = aid + 1 end
  end
end

-- One-Time Load all of the door data into the doorData table and save it
function loadDoorData()
  local doorCount = 0
  local allRooms = getRooms()
  doorData = {} -- Initialize the doorData table

  for id, name in pairs( allRooms ) do
    --id = tonumber( r )
    if not id then
      cecho( f "\nFailed to convert{r} to number." )
    else
      local doors = getDoors( id )
      if next( doors ) then               -- Check if there are doors in the room
        doorData[id] = doorData[id] or {} -- Initialize the table for the room

        for dir, status in pairs( doors ) do
          local doorString, keyNumber = getDoorData( id, tostring( dir ) )
          doorData[id][dir] = {}           -- Initialize the table for the direction
          doorData[id][dir].state = status -- 1 for regular, 2 for locked
          doorData[id][dir].word = doorString

          if keyNumber and keyNumber > 0 then
            doorData[id][dir].key = keyNumber
          end
          doorCount = doorCount + 1
        end
      end
    end
  end
  cecho( f "\nLoaded <maroon>{doorCount}<reset> doors.\n" )
  table.save( "C:/Dev/mud/mudlet/gizmo/data/doorData.lua", doorData )
end

-- Help create the master door data table (one time load)
function getDoorData( id, dir )
  local exitData = worldData[roomToAreaMap[id]].rooms[id].exits
  for _, exit in pairs( exitData ) do
    if SDIR[exit.exitDirection] == dir then
      local kw = exit.exitKeyword:match( "%w+" )
      local kn = tonumber( exit.exitKey )
      return kw, kn
    end
  end
end

-- Run some checks on the doorData table/file to make sure it's valid
function validateDoorData()
  --loadTable( "doorData" ) -- Load the doorData table from file
  local errorCount = 0
  local verifiedCount = 0

  for id, doors in pairs( doorData ) do
    local mudletDoors = getDoors( id )
    local roomExits = getRoomExits( id )

    for dir, doorInfo in pairs( doors ) do
      -- 1.1 Verify doorData[x][dir] matches an entry in the table returned by getDoors(x)
      if not mudletDoors[dir] then
        cecho( f "\nError: Door in room {id} direction {dir} not found in Mudlet door data." )
        errorCount = errorCount + 1
      end
      -- 1.2 Verify the room has a full valid exit leading that direction
      local fullDir = LDIR[dir] or dir
      if not roomExits[fullDir] then
        cecho( f "\nError: No valid exit {fullDir} in room {id}." )
        errorCount = errorCount + 1
      end
      -- 1.3 Verify that the door has a keyword string with 1 or more characters
      if not doorInfo.word or #doorInfo.word == 0 then
        cecho( f "\nError: Door in room {id} direction {dir} has no keyword." )
        errorCount = errorCount + 1
      end
      -- 1.4 Verify door state and key if locked
      if doorInfo.state == 3 and (not doorInfo.key or doorInfo.key <= 0) then
        cecho( f "\nError: Locked door in room {id} direction {dir} has invalid key." )
        errorCount = errorCount + 1
      end
      if errorCount == 0 then
        verifiedCount = verifiedCount + 1
      end
    end
  end
  if errorCount == 0 then
    cecho( f "\nSuccessfully verified {verifiedCount} doors." )
  else
    cecho( f "\nCompleted validation with {errorCount} errors found." )
  end
end

-- Original function to instantiate an empty world
function createEmptyAreas()
  for _, areaData in pairs( worldData ) do
    local areaName, areaID = areaData.areaName, areaData.areaRNumber
    if areaID ~= 0 then
      addAreaName( areaName )
    end
  end
  for _, areaData in pairs( worldData ) do
    local areaName, areaID = areaData.areaName, areaData.areaRNumber
    if areaID ~= 0 then
      setAreaName( areaID, areaName )
    end
  end
end

-- Given a list of room numbers, traverse them virtually while looking for doors in our path; add
-- open commands as needed and produce a WINTIN-compatible command list including opens and moves.
function traverseRooms( roomList )
  -- Check if the room list is valid
  if not roomList or #roomList == 0 then
    cecho( "\nError: Invalid room list provided." )
    return {}
  end
  local directionsTaken = {} -- This will store all the directions and 'open' commands

  -- Iterate through each room in the path
  for i = 1, #roomList - 1 do
    local currentRoom = tonumber( roomList[i] )  -- Current room in the iteration
    local nextRoom = tonumber( roomList[i + 1] ) -- The next room in the path

    local found = false                          -- Flag to check if a valid exit is found for the next room

    -- Search for the current room in the worldData
    for areaRNumber, areaData in pairs( worldData ) do
      if areaData.rooms[currentRoom] then
        local roomData = areaData.rooms[currentRoom]

        -- Iterate through exits of the current room
        for _, exit in pairs( roomData.exits ) do
          -- Check if the exit leads to the next room
          if exit.exitDest == nextRoom then
            found = true

            -- Check if the exit is a door and add 'open' command to directions
            -- This is for offline/virtual movement, so the command isn't executed
            if exit.exitFlags ~= -1 and exit.exitKeyword and exit.exitKeyword ~= "" then
              local doorString = ""
              local keyword = exit.exitKeyword:match( "%w+" )
              local keynum = exit.exitKey
              -- A door with a key number but no keyword to unlock might be a problem in the data
              if keynum > 0 and (not keyword or keyword == "") then
                gizErr( "Key with no keyword found in room " .. currentRoom )
              end
              -- If the door has a key number, unlock it before opening
              if keyword and keynum > 0 then
                doorString = "unlock " .. keyword .. ";open " .. keyword
              elseif keyword and (not keynum or keynum < 0) then
                doorString = "open " .. keyword
              end
              table.insert( directionsTaken, doorString )
            end
            -- Use moveExit to update the virtual location in the map
            moveExit( exit.exitDirection )
            table.insert( directionsTaken, exit.exitDirection )
            break -- Exit found, no need to continue checking other exits
          end
        end
        if found then
          break -- Exit found, no need to continue checking other areas
        end
      end
    end
    -- If no valid exit is found, report an error
    if not found then
      cecho( "\nError: Path broken at room " .. currentRoom .. " to " .. nextRoom )
      return {}
    end
  end
  return directionsTaken -- Return the list of directions and 'open' commands
end

-- Replaced by getFullPath/getAreaDirs
function getMSPath()
  -- Clear the path globals
  local dirString = nil
  speedWalkDir = nil
  speedWalkPath = nil

  -- Calculate the path to our current room from Market Square
  getPath( 1121, currentRoomNumber )
  if speedWalkDir then
    dirString = traverseRooms( speedWalkPath )
    -- Add an entry to the entryRooms table that maps currentAreaNumber to currentRoomNumber and the path to that room from Market Square
    cecho( f "\nAdding or updating path from MS to {getRoomString(currentRoomNumber,1)}" )
    entryRooms[currentAreaNumber] = {
      roomNumber = currentRoomNumber,
      path = dirString
    }
  else
    cecho( "\nUnable to find a path from Market Square to the current room." )
  end
  saveTable( 'entryRooms' )
end

-- Original function to populate areaDirs table
function getAreaDirs()
  local fullDirs = getFullDirs( 1121, currentRoomNumber )
  local roomArea = getRoomArea( currentRoomNumber )
  if fullDirs then
    areaDirs[roomArea]            = {}
    -- Store our Wintin-compatible path string along with the raw output from Mudlet's pathing
    areaDirs[roomArea].dirs       = fullDirs
    areaDirs[roomArea].rawDirs    = speedWalkDir
    -- Store the name & number of the destination room (the area entry room)
    areaDirs[roomArea].roomNumber = currentRoomNumber
    areaDirs[roomArea].roomName   = getRoomName( currentRoomNumber )
    -- The cost to walk the path is two times the length
    areaDirs[roomArea].cost       = (#speedWalkDir * 2)
    cecho( f "\nAdded <dark_orange>{nextArea}<reset> to the areaDirs table" )
  end
end

-- Not as good an attempt to do getAreaDirs()
function getAreaDirs()
  for _, roomID in ipairs( areaFirstRooms ) do
    local pathString = getFullDirs( 1121, roomID ) -- Assuming 1121 is your starting room (e.g., Market Square)
    if pathString then
      cecho( f( "\nPath from <dark_orange>1121<reset> to room <dark_orange>{roomID}<reset>:\n\t<olive_drab>{pathString}" ) )
    else
      cecho( f( "\nNo path found from <dark_orange>1121<reset> to room <dark_orange>{roomID}<reset>" ) )
    end
  end
end

--Brute force find the room that's closest to our current location that belongs to the given area
function findArea( id )
  local allRooms           = getRooms()
  local shortestDirsLength = 750000 -- Initialize to a very high number
  local shortestDirs       = nil
  local nearestRoom        = nil

  for r, n in pairs( allRooms ) do -- Use pairs for iteration
    local roomID = tonumber( r )
    if getRoomArea( roomID ) == id then
      if getPath( 1121, roomID ) then -- Check if path is found
        local currentPathLength = #speedWalkDir
        if currentPathLength < shortestDirsLength then
          shortestDirsLength = currentPathLength
          nearestRoom        = getRoomString( roomID, 2 )
          shortestDirs       = getFullDirs( 1121, roomID )
        end
      end
    end
  end
  if shortestDirs then
    doWintin( shortestDirs )
    return true
  else
    cecho( f "\nFailed to find a room in area <dark_orange>{id}<reset>" )
    return false
  end
end

function buildAreaMap()
  areaMap = {}
  for areaID in pairs( areaDirs ) do
    local areaName = getRoomAreaName( areaID )
    if areaName then
      -- Cleanse & normalize the names
      print( areaName )
      areaName = areaName:gsub( "^The%s+", "" ):gsub( "%s+", "" ):lower()
      print( areaName )
      areaMap[areaName] = areaID
    end
  end
end

function clearCharacters()
  allRooms = getRooms()
  for id, name in pairs( allRooms ) do
    setRoomChar( id, "" )
  end
end

function combinePhantom()
  local phantom1 = worldData[102].rooms
  local phantom2 = worldData[103].rooms
  local phantom3 = worldData[108].rooms
  local movedRooms = 0
  for _, room in pairs( phantom2 ) do
    local id = room.roomRNumber
    if roomExists( id ) and getRoomArea( id ) ~= 102 then
      setRoomArea( id, 102 )
      movedRooms = movedRooms + 1
    end
  end
  for _, room in pairs( phantom3 ) do
    local id = room.roomRNumber
    if roomExists( id ) and getRoomArea( id ) ~= 102 then
      setRoomArea( id, 102 )
      movedRooms = movedRooms + 1
    end
  end
  cecho( f "\n{movedRooms} rooms moved to Phantom Zone." )
end

function areaHunt()
  local rooms = getRooms()
  local areaID = 1
  for areaID = 1, 128 do
    if areaID == 107 then areaID = areaID + 1 end
    local areaData = worldData[areaID]
    local roomData = areaData.rooms
    for _, room in pairs( roomData ) do
      local id = room.roomRNumber
      if roomExists( id ) then
        exitData = room.exits
        for _, exit in pairs( exitData ) do
          local dir = exit.exitDirection
          local to = exit.exitDest
          if not roomExists( to ) and not ignoredRooms[to] then
            cecho( f "\n<firebrick>{to}<reset> is <cyan>{dir}<reset> from <dark_orange>{id}" )
          end
        end
      end
    end
  end
end

-- Report on Rooms which have been moved in the Mudlet client to an Area other than their original
-- Area from the database.
function movedRoomsReport()
  local ac = MAP_COLOR["area"]
  for areaID = 1, 128 do
    -- Skip Area 107; it's missing from our database
    if areaID == 107 then areaID = areaID + 1 end
    local areaData = worldData[areaID]
    local roomData = areaData.rooms
    for _, room in pairs( roomData ) do
      local id = room.roomRNumber
      local mudletArea = getRoomArea( id )
      local dataArea = roomToAreaMap[id]
      if mudletArea and dataArea and (mudletArea ~= dataArea) then
        cecho( f "\n{getRoomString(id,1)} from {ac}{dataArea}<reset> has moved to {ac}{mudletArea}<reset>" )
      end
    end
  end
end

-- Like findNewRoom(), but globally; search every Area in the MUD for a Room that has an Exit leading
-- to a Room that hasn't been mapped yet.
function findNewLand()
  local ac = MAP_COLOR["area"]
  -- getRooms() dumps a global list of mapped Room Names & IDs with no other detail
  for id, name in pairs( getRooms() ) do
    -- getRoomArea tells us which Area a Room is in
    local areaID = getRoomArea( id )
    -- While worldData was derived from the database and may contain unmapped Areas and Rooms
    if worldData[areaID] and worldData[areaID].rooms[id] then
      local roomData = worldData[areaID].rooms[id]
      local exitData = roomData.exits
      -- Check the destination of each Exit and report back of there's a Room that doesn't exist
      -- and hasn't been flagged unmappable.
      for _, exit in pairs( exitData ) do
        local dir = exit.exitDirection
        local to = exit.exitDest
        if not roomExists( to ) and not contains( unmappable, to ) then
          -- Uncomment this to immediately walk to the first unmapped Room
          --expandAlias( f 'goto {rnum}' );return
          cecho( f "\n<firebrick>{to}<reset> is <cyan>{dir}<reset> from <dark_orange>{id}" )
        end
      end
    end
  end
end

-- Search every room in the current Area for one that has an Exit to a room we haven't mapped yet.
function findNewRoom()
  -- Get a list of every Room in the area
  local allRooms = getAreaRooms( currentAreaNumber )
  -- Which is zero-based for some godforsaken reason...
  local r = 0
  while allRooms[r] do
    local rnum = allRooms[r]
    -- Verify the Room exists
    if worldData[currentAreaNumber].rooms[rnum] then
      -- Then check all of its Exits to see if any lead to an unmapped room
      local exitData = worldData[currentAreaNumber].rooms[rnum].exits
      for _, exit in pairs( exitData ) do
        local dir = exit.exitDirection
        local to = exit.exitDest
        if not roomExists( to ) then
          -- Uncomment this to immediately walk to the first unmapped Room
          --expandAlias( f 'goto {rnum}' );return
          cecho( f "\n(<firebrick>{to}<reset>) is <cyan>{dir}<reset> from (<dark_orange>{rnum}<reset>)" )
          return
        end
      end
    end
    r = r + 1
  end
  -- If we didn't find any unmapped rooms, run a report to verify
  cecho( "\n<green_yellow>No unmapped rooms found at this time.<reset>" )
end

function areaReport()
  local nc = MAP_COLOR["number"]
  local ac = MAP_COLOR["area"]
  mapInfo( f "Map report for {ac}{currentAreaName}<reset> [{ac}{currentAreaNumber}<reset>]" )
  local areaData = worldData[currentAreaNumber]
  local dbCount = areaData.areaRoomCount
  local mudletCount = 0
  local roomData = areaData.rooms
  for _, room in pairs( roomData ) do
    local id = room.roomRNumber
    if not roomExists( id ) and not ignoredRooms[id] then
      mapInfo( f "<firebrick>Missing<reset>: {getRoomString(id,2)}" )
    else
      mudletCount = mudletCount + 1
    end
  end
  local unmappedCount = dbCount - mudletCount
  mapInfo( f '<yellow_green>Database<reset> rooms: {nc}{dbCount}<reset>' )
  mapInfo( f '<olive_drab>Mudlet<reset> rooms: {nc}{mudletCount}<reset>' )
end

function worldReport()
  local nc          = MAP_COLOR["number"]
  local ac          = MAP_COLOR["area"]
  local worldCount  = 0
  local mappedCount = 0
  local missedCount = 0
  for areaID = 1, 128 do
    -- Skip Area 107; it's missing from our database
    if areaID == 107 then areaID = areaID + 1 end
    local areaData = worldData[areaID]
    local roomData = areaData.rooms
    for _, room in pairs( roomData ) do
      local id = room.roomRNumber
      worldCount = worldCount + 1
      if roomExists( id ) or ignoredRooms[id] then
        mappedCount = mappedCount + 1
      else
        local roomArea = roomToAreaMap[id]
        local roomAreaName = worldData[areaID].areaName
        cecho( f "\n{getRoomString(id,2)} in {ac}{roomAreaName}<reset>" )
        missedCount = missedCount + 1
        if missedCount > 5 then return end
      end
    end
  end
  local unmappedCount = worldCount - mappedCount
  mapInfo( f '<yellow_green>World<reset> total: {nc}{worldCount}<reset>' )
  mapInfo( f '<olive_drab>Mapped<reset> total: {nc}{mappedCount}<reset>' )
  mapInfo( f '<orange_red>Unmapped<reset> total: {nc}{unmappedCount}<reset>' )
end

-- Basically just getPathAlias but automatically follow the route.
function gotoAlias()
  getPathAlias()
  doSpeedWalk()
end

-- Use built-in Mudlet path finding to get a path to the specified room.
function getPathAlias()
  -- Clear the path globals
  speedWalkDir = nil
  speedWalkPath = nil

  local dstRoomName = nil
  local dstRoomNumber = tonumber( matches[2] )
  local dstRoomString = getRoomString( dstRoomNumber )
  local dirString = nil

  local nc, rc = MAP_COLOR["number"], MAP_COLOR["roomNameU"]

  if currentRoomNumber == dstRoomNumber then
    cecho( f "\nYou're already in {rc}{currentRoomName}<reset> [{nc}{dstRoomNumber}<reset>]" )
  elseif not roomExists( dstRoomNumber ) then
    cecho( f "\nRoom {nc}{dstRoomNumber}<reset> doesn't exist yet." )
  else
    getPath( currentRoomNumber, dstRoomNumber )
    if speedWalkDir then
      dstRoomName = getRoomName( dstRoomNumber )
      dirString1 = createWintin( speedWalkDir )
      dirString2 = createWintinGPT( speedWalkDir )
      cecho( f "\n\nPath from {getRoomString(currentRoomNumber)} to {getRoomString(dstRoomNumber)}:" )
      cecho( f "\n\t<orange>{dirString1}<reset>" )
      cecho( f "\n\t<yellow_green>{dirString2}<reset>" )
      walkPath = dirString
    end
  end
end

-- Iterate over all rooms in the map; for any room with an up/down exit, add a gradient highlight circle;
-- uses getModifiedColor() to create a highlight based off the room's current color (terrain type)
function highlightStairs()
  -- Map room types to their respective environment IDs (color table index)
  local TYPE_MAP = {
    ['Forest']    = COLOR_FOREST,
    ['Mountains'] = COLOR_MOUNTAINS,
    ['City']      = COLOR_CITY,
    ['Water']     = COLOR_WATER,
    ['Field']     = COLOR_FIELD,
    ['Hills']     = COLOR_HILLS,
    ['Deepwater'] = COLOR_DEEPWATER,
    ['Inside']    = COLOR_INSIDE,
  }

  -- For all rooms in the map, check exits for up/down and highlight accordingly
  local roomsChecked = 0
  for id, name in pairs( getRooms() ) do
    roomsChecked = roomsChecked + 1
    local exits = getRoomExits( id )
    if exits['up'] or exits['down'] then
      unHighlightRoom( id )
      local roomName = getRoomName( id )
      local roomType = getRoomUserData( id, "roomType" )
      local roomEnv = roomColors[TYPE_MAP[roomType]]

      if roomEnv then
        local br, bg, bb = roomEnv[1], roomEnv[2], roomEnv[3]
        -- Highlight with colors -33% and +66% off baseline (makes a little "cone" effect)
        local h1r, h1g, h1b = getModifiedColor( br, bg, bb, -20 )
        local h2r, h2g, h2b = getModifiedColor( br, bg, bb, 80 )
        highlightRoom( id, h1r, h1g, h1b, h2r, h2g, h2b, 0.45, 255, 255 )
      end
    end
  end
  cecho( f "\nChecked {roomsChecked} rooms." )
end

function alignLabels( id )
  local nc = MAP_COLOR["number"]
  local areaLabels = getMapLabels( id )
  local labelCount = #areaLabels
  local modCount = 0
  -- Ignore missing areas and ones w/ no labels
  if areaLabels and labelCount > 0 then
    -- getMapLabels is zero-based
    for lbl = 0, labelCount do
      local labelData = getMapLabel( id, lbl )
      if labelData then
        lT = labelData.Text
        lX = labelData.X
        lY = labelData.Y
        cecho( f "\n<royal_blue>{lT}<reset>: {nc}{lX}<reset>, {nc}{lY}<reset>" )
      end
    end
  end
end

-- Globally update area labels from deep_pink to medium_violet_red
function updateAllAreaLabels()
  local areaID = 1
  local modCount = 0
  while worldData[areaID] do
    modCount = modCount + updateLabelStyle( areaID, 255, 69, 0, 255, 99, 71, 10 )
    areaID = areaID + 1
    -- Skip area 107; it's missing from our database
    if areaID == 107 then areaID = areaID + 1 end
  end
  cecho( f "\n<dark_orange>{modCount}<reset> room labels updated." )
end

-- Globally update room labels from orange-ish to royal_blue
function updateAllRoomLabels()
  local areaID = 1
  local modCount = 0
  while worldData[areaID] do
    modCount = modCount + updateLabelStyle( areaID, 255, 140, 0, 65, 105, 225, 8 )
    areaID = areaID + 1
    -- Skip area 107; it's missing from our database
    if areaID == 107 then areaID = areaID + 1 end
  end
  cecho( f "\n<dark_orange>{modCount}<reset> room labels updated." )
end

-- For a given area, update labels from an old color to a new color and size
function updateLabelStyle( id, oR, oG, oB, nR, nG, nB, nS )
  local areaLabels = getMapLabels( id )
  local labelCount = #areaLabels
  local modCount = 0
  -- Ignore missing areas and ones w/ no labels
  if areaLabels and labelCount > 0 then
    -- getMapLabels is zero-based
    for lbl = 0, labelCount do
      local labelData = getMapLabel( id, lbl )
      if labelData then
        local lR = labelData.FgColor.r
        local lG = labelData.FgColor.g
        local lB = labelData.FgColor.b
        -- Check for labels w/ old color
        if lR == oR and lG == oG and lB == oB then
          local lT = labelData.Text
          -- Round the coordinates to the nearest 0.025
          local lX = round( labelData.X )
          local lY = round( labelData.Y )
          local lZ = round( labelData.Z )
          -- Delete existing label and create a new one in its place using the new color & size
          deleteMapLabel( id, lbl )
          createMapLabel( id, lT, lX, lY, lZ, nR, nG, nB, 0, 0, 0, 0, nS, true, true, "Bitstream Vera Sans Mono", 255, 0 )
          modCount = modCount + 1
        end
      end
    end
    updateMap()
  end
  return modCount
end

function viewLabelData()
  local areaLabels = getMapLabels( currentAreaNumber )
  for lbl = 0, #areaLabels do
    local labelData = getMapLabel( currentAreaNumber, lbl )
    if labelData then
      local lT = labelData.Text
      local lR = labelData.FgColor.r
      local lG = labelData.FgColor.g
      local lB = labelData.FgColor.b
      cecho( f "\n<royal_blue>{lT}<reset>: ({lR}, {lG}, {lB})" )
    end
  end
end

function showAreaPaths()
  cecho( f "\nGlobal Area Paths:\n" )
  for areaID, entryData in pairs( entryRooms ) do
    local roomNumber = entryData.roomNumber
    local areaName = getRoomAreaName( getRoomArea( roomNumber ) )
    local path = entryData.path
    cecho( f [[
<medium_violet_red>{areaName}<reset> <dim_grey>[<reset><maroon>{areaID}<reset><dim_grey>]<reset>
    <dim_grey>Entrance: {getRoomString(roomNumber,1)}
    <dim_grey>Dirs: <olive_drab>{path}<reset>
]] )
  end
end

function updateAreaPaths()
  cecho( f "\nGlobal Area Paths:\n" )
  for areaID, entryData in pairs( entryRooms ) do
    local roomNumber = entryData.roomNumber
    local oldPath = entryData.path
    local areaName = getRoomAreaName( getRoomArea( roomNumber ) )
    print( f "Looking for path to: {roomNumber}" )
    --getPath( 1121, roomNumber )
    --display( speedWalkPath )
    local newPath = getFullDirs( 1121, tonumber( roomNumber ) )
    --<dim_grey>New Dirs: <yellow_green>{display(newPath)}<reset>
    cecho( f [[
<medium_violet_red>{areaName}<reset> <dim_grey>[<reset><maroon>{areaID}<reset><dim_grey>]<reset>
    <dim_grey>Entrance: {getRoomString(roomNumber,1)}
    <dim_grey>Dirs: <olive_drab>{oldPath}<reset>
]] )
  end
end

-- For all rooms globally delete any exit which leads to its own origin (and store that exit in culledExits)
function cullLoopedExits()
  local cullCount = 0
  local allRooms = getRooms()
  for id, name in pairs( allRooms ) do
    local exits = getRoomExits( id )
    for dir, dst in pairs( exits ) do
      if dst == id then
        cullCount = cullCount + 1
        culledExits[id] = culledExits[id] or {}
        setExit( id, -1, dir )
        culledExits[id][dir] = true
        cecho( f "\n<dim_grey>Culled looping <cyan>{dir}<dim_grey> exit from <dark_orange>{id}<reset>" )
      end
    end
  end
  cecho( f "\n<dim_grey>Culled <dark_orange>{cullCount}<dim_grey> total exits<reset>" )
  updateMap()
  table.save( 'C:/Dev/mud/mudlet/gizmo/data/culledExits.lua', culledExits )
end

function combineArea( dstArea, srcArea )
  local srcRooms = getAreaRooms( srcArea )
  for _, srcRoom in ipairs( srcRooms ) do
    setRoomArea( srcRoom, dstArea )
  end
  updateMap()
end

function getRoomStringOld( id, detail )
  detail = detail or 1
  local specTag = ""
  local roomString = nil
  local roomData = worldData[roomToAreaMap[id]].rooms[id]
  local roomName = roomData.roomName
  local nc = MAP_COLOR["number"]
  local rc = nil

  if roomData.roomSpec > 0 then
    specTag = f " ~<ansi_light_yellow>{roomData.roomSpec}<reset>~"
  end
  if uniqueRooms[roomName] then
    rc = MAP_COLOR['roomNameU']
  else
    rc = MAP_COLOR['roomName']
  end
  -- Detail 1 is name and number
  if detail == 1 then
    roomString = f "{rc}{roomName}<reset> ({MAP_COLOR['number']}{id}<reset>){specTag}"
    return roomString
  end
  -- Add room type for detail level 2
  local roomType = roomData.roomType
  local tc = MAP_COLOR[roomType]
  if detail == 2 then
    roomString = f "{rc}{roomName}<reset> [{tc}{roomType}<reset>] ({nc}{id}<reset>){specTag}"
    return roomString
  end
  -- Add map coordinates at level 3
  local uc = MAP_COLOR["mapui"]
  local cX = nil
  local cY = nil
  local cZ = nil
  cX, cY, cZ = getRoomCoordinates( id )
  local cString = f "{uc}{cX}<reset>, {uc}{cY}<reset>, {uc}{cZ}<reset>"
  roomString = f "{rc}{roomName}<reset> [{tc}{roomType}<reset>] ({nc}{id}<reset>) ({cString}){specTag}"
  return roomString
end

-- Attempt a "virtual move"; on success report on area transitions and update virtual coordinates.
function moveExitOld( direction )
  local nc = MAP_COLOR["number"]
  -- Guard against variations in the Exit data by searching for the Exit in question
  for _, exit in pairs( currentRoomData.exits ) do
    if exit.exitDirection == direction then
      if not roomToAreaMap[exit.exitDest] then
        cecho( f "\n<dim_grey>err: Room {nc}{exit.exitDest}<reset><dim_grey> has no area mapping.<reset>" )
        return
      end
      -- Update coordinates for the new Room (and possibly Area)
      updatePlayerLocation( exit.exitDest, direction )
      displayRoom()
      return true
    end
  end
  cecho( "\n<dim_grey>Alas, you cannot go that way.<reset>" )
  return false
end

exitData = exitData or {}

-- Load all Exit data from the gizwrld.db database into a Lua table
function loadExitData()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  if not conn then
    gizErr( "Error connecting to gizwrld.db." )
    return nil
  end
  local cursor = conn:execute( "SELECT * FROM Exit" )

  local row = cursor:fetch( {}, "a" )
  while row do
    local roomID = tonumber( row.roomRNumber )
    local dir = row.exitDirection
    local keyword = row.exitKeyword

    -- Only store exits with a keyword that is not nil and not an empty string
    if keyword and #keyword > 0 then
      -- Extract only the first word from the keyword
      local firstWord = keyword:match( "^(%w+)" )
      exitData[roomID] = exitData[roomID] or {}
      exitData[roomID][dir] = {
        exitDest = tonumber( row.exitDest ),
        exitKeyword = firstWord,
        exitFlags = tonumber( row.exitFlags ),
        exitDescription = row.exitDescription
      }

      -- Only store keys when exitKey is not nil and greater than 0
      local key = tonumber( row.exitKey )
      if key and key > 0 then
        exitData[roomID][dir].exitKey = key
      end
    end
    row = cursor:fetch( row, "a" )
  end
  cursor:close()
  conn:close()
  env:close()

  table.save( 'C:/Dev/mud/mudlet/gizmo/data/exitData.lua', exitData )
end

-- Load all Exit data from the gizwrld.db database into a Lua table
function loadExitData()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  if not conn then
    gizErr( "Error connecting to gizwrld.db." )
    return nil
  end
  local cursor = conn:execute( "SELECT * FROM Exit" )

  local row = cursor:fetch( {}, "a" )
  while row do
    local roomID = tonumber( row.roomRNumber )
    local dir = row.exitDirection
    local keyword = row.exitKeyword

    -- Only store exits with a keyword that is not nil and not an empty string
    if keyword and #keyword > 0 then
      -- Extract only the first word from the keyword
      local firstWord = keyword:match( "^(%w+)" )
      exitData[roomID] = exitData[roomID] or {}
      exitData[roomID][dir] = {
        exitDest = tonumber( row.exitDest ),
        exitKeyword = firstWord,
        exitFlags = tonumber( row.exitFlags ),
        exitDescription = row.exitDescription
      }

      -- Only store keys when exitKey is not nil and greater than 0
      local key = tonumber( row.exitKey )
      if key and key > 0 then
        exitData[roomID][dir].exitKey = key
      end
    end
    row = cursor:fetch( row, "a" )
  end
  cursor:close()
  conn:close()
  env:close()

  table.save( 'C:/Dev/mud/mudlet/gizmo/data/exitData.lua', exitData )
end

-- Display the properties of an exit for mapping and validation purposes; displayed when I issue a virtual "look <direction>" command
function inspectExit( direction )
  local fullDirection
  for dir, num in pairs( DIRECTIONS ) do
    if DIRECTIONS[direction] == num and #dir > 1 then
      fullDirection = dir
      break
    end
  end
  for _, exit in ipairs( currentRoomData.exits ) do
    if exit.exitDirection == fullDirection then
      local ec      = MAP_COLOR["exitDir"]
      local es      = MAP_COLOR["exitStr"]
      local esp     = MAP_COLOR["exitSpec"]
      local nc      = MAP_COLOR["number"]

      local exitStr = f "The {ec}{fullDirection}<reset> exit: "
      if exit.exitKeyword and #exit.exitKeyword > 0 then
        exitStr = exitStr .. f "\n  keywords: {es}{exit.exitKeyword}<reset>"
      end
      local isSpecial = false
      if (exit.exitFlags and exit.exitFlags ~= -1) or (exit.exitKey and exit.exitKey ~= -1) then
        isSpecial = true
        exitStr = exitStr ..
            (exit.exitFlags and exit.exitFlags ~= -1 and f "\n  flags: {esp}{exit.exitFlags}<reset>" or "") ..
            (exit.exitKey and exit.exitKey ~= -1 and f "\n  key: {nc}{exit.exitKey}<reset>" or "")
        if exit.exitKey and exit.exitKey > 0 then
          lastKey = exit.exitKey
        end
      end
      if exit.exitDescription and #exit.exitDescription > 0 then
        exitStr = exitStr .. f "\n  description: {es}{exit.exitDescription}<reset>"
      end
      cecho( f "\n{exitStr}" )
      return
    end
  end
  cecho( f "\n{MAP_COLOR['roomDesc']}You see no exit in that direction.<reset>" )
end

-- Get the Area data for a given areaRNumber
function getAreaData( areaRNumber )
  return worldData[areaRNumber]
end

-- Get the Room data for a given roomRNumber
function getRoomData( roomRNumber )
  local areaRNumber = roomToAreaMap[roomRNumber]
  if areaRNumber and worldData[areaRNumber] then
    return worldData[areaRNumber].rooms[roomRNumber]
  end
end

-- Get Exits from room with the given roomRNumber
function getExitData( roomRNumber )
  local roomData = getRoomData( roomRNumber )
  return roomData and roomData.exits
end

function getAreaByRoom( roomRNumber )
  local areaRNumber = roomToAreaMap[roomRNumber]
  return getAreaData( areaRNumber )
end

function getAllRoomsByArea( areaRNumber )
  local areaData = getAreaData( areaRNumber )
  return areaData and areaData.rooms or {}
end

-- Use a breadth-first-search (BFS) to find the shortest path between two rooms
function findShortestPath( srcRoom, dstRoom )
  if srcRoom == dstRoom then return {srcRoom} end
  -- Table for visisted rooms to avoid revisiting
  local visitedRooms = {}

  -- The search queue, seeded with the srcRoom
  local pathQueue    = {{srcRoom}}

  -- As long as there are paths in the queue, "pop" one off and explore it fully
  while #pathQueue > 0 do
    local path = table.remove( pathQueue, 1 )
    local lastRoom = path[#path]

    -- Only visit unvisited rooms (this path)
    if not visitedRooms[lastRoom] then
      -- Mark the room visited
      visitedRooms[lastRoom] = true

      -- Look up the room in the worldData table
      for _, areaData in pairs( worldData ) do
        local roomData = areaData.rooms[lastRoom]

        -- For the love of St. Christopher (patron saint of bachelors and travel), don't add DTs to paths
        if roomData and not roomData.roomFlags:find( "DEATH" ) then
          -- Examine each exit from the room
          for _, exit in pairs( roomData.exits ) do
            local nextRoom = exit.exitDest

            -- If one of the exits is dstRoom; constrcut and return the path
            if nextRoom == dstRoom then
              local shortestPath = {unpack( path )}
              table.insert( shortestPath, nextRoom )
              return shortestPath
            end
            -- Otherwise, extend the path and queue
            if not visitedRooms[nextRoom] then
              local newPath = {unpack( path )}
              table.insert( newPath, nextRoom )
              pathQueue[#pathQueue + 1] = newPath
            end
          end
        end
      end
    end
  end
  -- Couldn't find a path to the destination
  return nil
end

function roomsReport()
  local minRoom = worldData[currentAreaNumber].areaMinRoomRNumber
  local maxRoom = worldData[currentAreaNumber].areaMaxRoomRNumber
  local roomsMapped = 0
  for r = minRoom, maxRoom do
    if roomExists( r ) then roomsMapped = roomsMapped + 1 end
  end
  --local mappedRooms = getAreaRooms( currentAreaNumber )
  --local roomsMapped = #mappedRooms + 1
  local roomsTotal = worldData[currentAreaNumber].areaRoomCount
  local roomsLeft = roomsTotal - roomsMapped
  local ac = MAP_COLOR["area"]
  local nc = MAP_COLOR["number"]
  local rc = MAP_COLOR["roomName"]
  mapInfo( f 'Found <yellow_green>{roomsMapped}<reset> of <dark_orange>{roomsTotal}<reset> rooms in {areaTag()}<reset>.' )

  -- Check if there are 10 or fewer rooms left to map
  if roomsLeft == 0 then
    mapInfo( "<yellow_green>Area Complete!<reset>" )
  elseif roomsLeft > 0 and roomsLeft <= 10 then
    mapInfo( "\n<orange>Unmapped<reset>:\n" )
    for roomRNumber, roomData in pairs( worldData[currentAreaNumber].rooms ) do
      if not contains( roomsMapped, roomRNumber, true ) then
        local roomName = roomData.roomName
        local exitsInfo = ""

        -- Iterate through exits using pairs
        for _, exit in pairs( roomData.exits ) do
          exitsInfo = exitsInfo .. exit.exitDirection .. f " to {nc}" .. exit.exitDest .. "<reset>; "
        end
        cecho( f '[+   Room: {rc}{roomName}<reset> (ID: {nc}{roomRNumber}<reset>)\n    Exits: {exitsInfo}\n' )
      end
    end
  end
  local worldRooms = getRooms()
  local worldRoomsCount = 0

  for _ in pairs( worldRooms ) do
    worldRoomsCount = worldRoomsCount + 1
  end
  mapInfo( f '<olive_drab>World<reset> total: {nc}{worldRoomsCount}<reset>' )
end

function roomTag()
  return f "<light_steel_blue>currentRoomName<reset> [<royal_blue>currentRoomNumber<reset>]"
end

-- Function to find all neighboring rooms with exits leading to a specific roomRNumber
function findNeighbors( targetRoomRNumber )
  local neighbors = {}
  local nc = MAP_COLOR["number"]
  local minR, maxR = currentAreaData.areaMinRoomRNumber, currentAreaData.areaMaxRoomRNumber
  for r = minR, maxR do
    local roomData = currentAreaData.rooms[r]
    local exitData = roomData.exits
    for _, exit in pairs( exitData ) do
      if exit.exitDest == targetRoomRNumber then
        table.insert( neighbors, r )
      end
    end
  end
  mapInfo( f ' Neighbors for {nc}{targetRoomRNumber}<reset>:\n' )
  display( neighbors )
end

function setMinimumRoomNumber( areaID, newMinimum )
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )
  local nc = MAP_COLOR["number"]
  local ac = MAP_COLOR["area"]
  if not conn then
    gizErr( 'Error connecting to gizwrld.db.' )
    return
  end
  -- Fetch the current minimum room number for the area
  local cursor, err = conn:execute( f( "SELECT areaMinRoomRNumber FROM Area WHERE areaRNumber = {areaID}" ) )
  if not cursor then
    gizErr( f( "Error fetching data for {ac}{areaID}<reset>: {err}" ) )
    return
  end
  local row = cursor:fetch( {}, "a" )
  if not row then
    gizErr( f "Area {ac}{areaID}<reset> not found." )
    return
  end
  local currentMinRoomNumber = tonumber( row.areaMinRoomRNumber )
  if currentMinRoomNumber == newMinimum then
    cecho( f "\nFirst room for {ac}{areaID}<reset> already {nc}{newMinimum}<reset>" )
  else
    -- Update the minimum room number
    local update_stmt = f( "UPDATE Area SET areaMinRoomRNumber = {newMinimum} WHERE areaRNumber = {areaID}" )
    local res, upd_err = conn:execute( update_stmt )
    if not res then
      gizErr( f( "Error updating data for {ac}{areaID}<reset>: {upd_err}" ) )
      return
    end
    cecho( f "\nUpdated first room for {ac}{areaID}<reset> from {nc}{currentMinRoomNumber}<reset> to {nc}{newMinimum}<reset>" )
  end
  -- Clean up
  if cursor then cursor:close() end
  conn:close()
  env:close()
end

-- From the current room, search for neighboring rooms in this Area;
-- Good neighbors are those that have a corresponding return/reverse exit back to our current room; reposition those rooms near us
-- Bad neighbors have no return/reverse exit; cull those exits (remove them from the map and store them in the culledExits table)
function findNearestNeighbors()
  local currentExits = getRoomExits( currentRoomNumber )
  local rc = MAP_COLOR["number"]

  for dir, roomNumber in pairs( currentExits ) do
    if roomExists( roomNumber ) and roomNumber ~= currentRoomNumber then
      local reverseDir = REVERSE[dir]
      local neighborExits = getRoomExits( roomNumber )

      if neighborExits and neighborExits[reverseDir] == currentRoomNumber then
        -- Good neighbor: reposition
        repositionRoom( roomNumber, dir )
        local path = createWintin( {dir} )
        --cecho( f( "\n<cyan>{path}<reset> to room {rc}{roomNumber}<reset>" ) )
      elseif neighborExits and (not neighborExits[reverseDir] or neighborExits[reverseDir] ~= currentRoomNumber) then
        cecho( f "\nRoom {rc}{roomNumber}<reset> is bad neighbor to our <cyan>{dir}<reset>, consider <firebrick>culling<reset> it" )
        --cullExit( dir )
      end
    end
  end
end

-- Move a room to a location relative to our current location (mX, mY, mZ)
function repositionRoom( id, relativeDirection )
  if not id or not relativeDirection then return end
  local rc = MAP_COLOR["number"]
  local mc = "<medium_orchid>"
  local rX, rY, rZ = mX, mY, mZ
  if relativeDirection == "north" then
    rY = rY + 1
  elseif relativeDirection == "south" then
    rY = rY - 1
  elseif relativeDirection == "east" then
    rX = rX + 1
  elseif relativeDirection == "west" then
    rX = rX - 1
  elseif relativeDirection == "up" then
    rZ = rZ + 1
  elseif relativeDirection == "down" then
    rZ = rZ - 1
  end
  cecho( f "\nRoom {rc}{id}<reset> is good neighbor to our <cyan>{relativeDirection}<reset>, moving to {mc}{rX}<reset>, {mc}{rY}<reset>, {mc}{rZ}<reset>" )
  setRoomCoordinates( id, rX, rY, rZ )
  updateMap()
end

function auditAreaCoordinates()
  local nc = MAP_COLOR["number"]
  local areaCoordinates = {}
  local minRoom = worldData[currentAreaNumber].areaMinRoomRNumber
  local maxRoom = worldData[currentAreaNumber].areaMaxRoomRNumber

  for r = minRoom, maxRoom do
    if roomExists( r ) then
      local roomX, roomY, roomZ = getRoomCoordinates( r )
      local coordKey = roomX .. ":" .. roomY .. ":" .. roomZ

      if areaCoordinates[coordKey] then
        -- Found overlapping rooms
        cecho( f(
          "\nRooms {nc}{areaCoordinates[coordKey]}<reset> and {nc}{r}<reset> overlap at coordinates ({roomX}, {roomY}, {roomZ})." ) )
      else
        -- Store the coordinate key with its room number
        areaCoordinates[coordKey] = r
      end
    end
  end
end

function countRooms()
  local areaCounts = {}
  local allRooms = getRooms()
  for id, name in pairs( allRooms ) do
    local area = getRoomArea( id )
    local areaName = getRoomAreaName( area )
    areaCounts[areaName] = (areaCounts[areaName] or 0) + 1
  end
  display( areaCounts )
end

-- The "main" display function to print the current room as if we just moved into it or looked at it
-- in the game; prints the room name, description, and exits.
function displayRoom( brief )
  brief = brief or true
  local rd = MAP_COLOR["roomDesc"]
  cecho( f "\n\n{getRoomString(currentRoomNumber, 2)}" )
  if not brief then
    cecho( f "\n{rd}{currentRoomData.roomDescription}<reset>" )
  end
  if currentRoomData.roomSpec > 0 then
    local renv = getRoomEnv( currentRoomNumber )
    if renv ~= COLOR_PROC then
      setRoomStyle()
    end
    cecho( f "\n\tThis room has a ~<ansi_light_yellow>special procedure<reset>~.\n" )
  end
  displayExits()
end

function setCurrentRoomxx( id )
  -- If this is the first Area or the id is outside the current Area, update Area before Room
  if currentAreaNumber < 0 or (not worldData[currentAreaNumber].rooms[id]) then
    setCurrentArea( roomToAreaMap[id] )
  end
  -- Save our lastRoomNumber for back-linking
  if currentRoomNumber > 0 then
    lastRoomNumber = currentRoomNumber
  end
  currentRoomData   = currentAreaData.rooms[id]
  currentRoomNumber = currentRoomData.roomRNumber
  currentRoomName   = currentRoomData.roomName
end

function setCurrentRoom( id )
  local roomNumber = tonumber( id )
  local roomArea = getRoomArea( roomNumber )
  roomArea = tonumber( roomArea )
  -- If this is the first Area or the id is outside the current Area, update Area before Room
  if currentAreaNumber ~= roomArea then
    setCurrentArea( roomArea )
  end
  --currentRoomData   = currentAreaData.rooms[id]
  currentRoomNumber = roomNumber                       -- currentRoomData.roomRNumber
  currentRoomName   = getRoomName( currentRoomNumber ) -- currentRoomData.roomName
  roomExits         = getRoomExits( currentRoomNumber )
end

function setCurrentAreax( id )
  currentAreaData   = worldData[id]
  currentAreaNumber = tonumber( currentAreaData.areaRNumber )
  currentAreaName   = tostring( currentAreaData.areaName )
end

function setCurrentArea( id )
  -- Store the room number of the "entrance" so we can easily reset to the start of an area when mapping
  -- firstAreaRoomNumber = id
  -- If we're leaving an Area, store information and report on the transition
  if currentAreaNumber > 0 then
    lastAreaNumber = currentAreaNumber
    lastAreaName   = currentAreaName
    mapInfo( f "Left: {areaTag()}" )
  end
  -- currentAreaData   = worldData[id]
  -- currentAreaNumber = tonumber( currentAreaData.areaRNumber )
  -- currentAreaName   = tostring( currentAreaData.areaName )
  currentAreaNumber = getRoomArea( id )
  currentAreaName   = getRoomAreaName( id )
  mapInfo( f "Entered {areaTag()}" )
  setMapZoom( 28 )
end

function setCurrentRoomNew( id )
  if currentAreaNumber < 0 or getRoomArea( id ) ~= currentAreaNumber then
    setCurrentArea( getRoomArea( id ) )
  end
end

function setCurrentAreaNew( id )
  -- If we're leaving an Area, store information and report on the transition
  if currentAreaNumber > 0 then
    lastAreaNumber = currentAreaNumber
    lastAreaName   = currentAreaName
    mapInfo( f "Left: {areaTag()}" )
  end
  currentAreaNumber = getRoomArea( id )
  currentAreaName   = getRoomAreaName( id )
  mapInfo( f "Entered {areaTag()}" )
  setMapZoom( 28 )
end

function setCurrentRoomxx( id )
  -- If this is the first Area or the id is outside the current Area, update Area before Room
  if currentAreaNumber < 0 or (not worldData[currentAreaNumber].rooms[id]) then
    setCurrentArea( roomToAreaMap[id] )
  end
  -- Save our lastRoomNumber for back-linking
  if currentRoomNumber > 0 then
    lastRoomNumber = currentRoomNumber
  end
  currentRoomData   = currentAreaData.rooms[id]
  currentRoomNumber = currentRoomData.roomRNumber
  currentRoomName   = currentRoomData.roomName
end

-- Display all exits of the current room as they might appear in the MUD
function displayExits( id )
  local exitData = currentRoomData.exits
  local exitString = ""
  local isFirstExit = true

  local minRNumber = currentAreaData.areaMinRoomRNumber
  local maxRNumber = currentAreaData.areaMaxRoomRNumber

  for _, exit in pairs( exitData ) do
    local dir = exit.exitDirection
    local to = exit.exitDest
    local ec = MAP_COLOR["exitDir"]
    local nc

    -- Determine the color based on exit properties
    if to == currentRoomNumber or (culledExits[currentRoomNumber] and culledExits[currentRoomNumber][dir]) then
      -- "Dim" the exit if it leads to the same room or has been culled (because several exits lead to the same destination)
      nc = "<dim_grey>"
    elseif not isInArea( to, currentAreaNumber ) then --to < minRNumber or to > maxRNumber then
      -- The room leads to a different area
      nc = MAP_COLOR["area"]
    else
      local destRoom = currentAreaData.rooms[to]
      if destRoom and destRoom.roomFlags:find( "DEATH" ) then
        nc = MAP_COLOR["death"]
      elseif (exit.exitFlags and exit.exitFlags ~= -1) or (exit.exitKey and exit.exitKey ~= -1) then
        nc = MAP_COLOR["exitSpec"]
      else
        nc = MAP_COLOR["number"]
      end
    end
    --local nextExit = f "{ec}{dir}<reset> ({nc}{to}<reset>)"
    local nextExit = f "{nc}{dir}<reset>)"
    if isFirstExit then
      exitString = f "{MAP_COLOR['exitStr']}Exits:  [" .. nextExit .. f "{MAP_COLOR['exitStr']}]<reset>"
      isFirstExit = false
    else
      exitString = exitString .. f " {MAP_COLOR['exitStr']}[<reset>" .. nextExit .. f "{MAP_COLOR['exitStr']}]<reset>"
    end
  end
  cecho( f "\n   {exitString}" )
end

-- A function to determine whether a Room belongs to a given Area
function isInArea( roomID, areaID )
  local roomArea = getRoomArea( roomID )
  -- If the Room exists (i.e., it has been mapped), then use Mudlet as our source of truth
  if roomArea == areaID or roomArea == getRoomArea( currentRoomNumber ) then
    return true
    -- If the Room has not been mapped, see if it is a member of the Area's room table in the worldData table
  elseif not roomExists( roomID ) and worldData[areaID].rooms[roomID] then
    return true
  end
  return false
end

-- From the gizwrld database, load the Area, Room, and Exit data into a Lua table
function loadWorldData()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  if not conn then
    gizErr( f 'Error connecting to gizwrld.db.' )
    return nil
  end
  local areas = {}
  local cursor

  -- Load Areas
  cursor = conn:execute( "SELECT * FROM Area" )
  local row = cursor:fetch( {}, "a" )
  while row do
    areas[row.areaRNumber] = {
      areaRNumber = row.areaRNumber,
      areaName = row.areaName,
      areaResetType = row.areaResetType,
      areaFirstRoomName = row.areaFirstRoomName,
      areaMinRoomRNumber = row.areaMinRoomRNumber,
      areaMaxRoomRNumber = row.areaMaxRoomRNumber,
      areaMinVNumber = row.areaMinVNumber,
      areaMaxVNumberActual = row.areaMaxVNumberActual,
      areaMaxVNumberAllowed = row.areaMaxVNumberAllowed,
      areaRoomCount = row.areaRoomCount,
      rooms = {}
    }
    row = cursor:fetch( row, "a" )
  end
  cursor:close()

  -- Load Rooms
  cursor = conn:execute( "SELECT * FROM Room" )
  row = cursor:fetch( {}, "a" )
  while row do
    if areas[row.areaRNumber] then
      areas[row.areaRNumber].rooms[row.roomRNumber] = {
        roomRNumber = row.roomRNumber,
        roomName = row.roomName,
        roomType = row.roomType,
        roomSpec = row.roomSpec,
        roomFlags = row.roomFlags,
        roomDescription = row.roomDescription,
        roomExtraKeyword = row.roomExtraKeyword,
        roomVNumber = row.roomVNumber,
        exits = {}
      }
    else
      cecho( f '{{Unmatched Room: {row.roomRNumber} in Area: {row.areaRNumber}\n' )
    end
    row = cursor:fetch( row, "a" )
  end
  cursor:close()

  -- Load Exits
  cursor = conn:execute( "SELECT * FROM Exit" )
  row = cursor:fetch( {}, "a" )
  while row do
    for _, area in pairs( areas ) do
      if area.rooms[row.roomRNumber] then
        table.insert( area.rooms[row.roomRNumber].exits, {
          exitID = row.exitID,
          exitDirection = row.exitDirection,
          exitDest = row.exitDest,
          exitKeyword = row.exitKeyword,
          exitFlags = row.exitFlags,
          exitKey = row.exitKey,
          exitDescription = row.exitDescription
        } )
        break -- Exit found and added, no need to continue looping through areas
      end
    end
    row = cursor:fetch( row, "a" )
  end
  -- Create a lookup table that maps roomRNumber(s) to areaRNumber(s)
  for areaID, area in pairs( areas ) do
    for roomID, _ in pairs( area.rooms ) do
      roomToAreaMap[roomID] = areaID
    end
  end
  cursor:close()
  conn:close()
  env:close()
  return areas
end

--[[
Functions to load, query, and interact with data from the database: 'C:/Dev/mud/gizmo/data/gizwrld.db'

Table Structure:
  Area Table:
  areaRNumber INTEGER; A unique identifier and primary key for Area
  areaName TEXT; The name of the Area in the MUD
  areaResetType TEXT; A string describing how and when the area repopulates
  areaFirstRoomName TEXT; The name of the first Room in the Area; usually the Room with areaMinRoomRNumber
  areaMinRoomRNumber INTEGER; The lowest value of roomRNumber for Rooms in the Area
  areaMaxRoomRNumber INTEGER; The highest value of roomRNumber for Rooms in the Area
  areaMinVNumber INTEGER; The lowest value of roomVNumber for Rooms in the Area; usually the same room as areaMinRoomRNumber
  areaMaxVNumberActual INTEGER; The highest value for Rooms that actually exist in the Area
  areaMaxVNumberAllowed INTEGER; The highest value that a Room could theoretically have in the Area
  areaRoomCount INTEGER; How many Rooms are in the Area

  Room Table:
  roomName TEXT; The name of the Room in the MUD
  roomVNumber INTEGER; The VNumber of the Room; an alternative identifier
  roomRNumber INTEGER; The RNumber of the Room; the primary unique identifier
  roomType TEXT; The "Terrain" or "Sector" type of the Room; will be used for color selection
  roomSpec BOOLEAN; Boolean value identifying Rooms with "special procedures" which will affect players in the Room
  roomFlags TEXT; A list of flags that identify special properties of the Room
  roomDescription TEXT; A long description of the Room that players see in game
  roomExtraKeyword TEXT; A list of one or more words that identify things in the room players can examine or interact with
  areaRNumber INTEGER; Foreign key to the Area in which this Room exists

  Exit Table:
  exitDirection TEXT; The direction the player must travel to use this Exit
  exitDest INTEGER; The roomRNumber of the Room the player travels to when using this Exit
  exitKeyword TEXT; Keywords Players use to interact with an Exit such as 'door' or 'gate'
  exitFlags INTEGER; A list of flags that identify special properties of an Exit, usually a door
  exitKey INTEGER; For Exits that require keys to lock/unlock, this is the in-game ID for the key
  exitDescription TEXT; A short description of the Exit such as 'A gravel path leading west.'
  roomRNumber INTEGER; Foreign key to the Room in which this Exit belongs
--]]
-- From the gizwrld database, load the Area, Room, and Exit data into a Lua table
function loadFollowData()
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  if not conn then
    gizErr( f 'Error connecting to gizwrld.db.' )
    return nil
  end
  local areas = {}
  local cursor

  -- Load Areas
  cursor = conn:execute( "SELECT * FROM Area" )
  local row = cursor:fetch( {}, "a" )
  while row do
    areas[row.areaRNumber] = {
      areaRNumber = row.areaRNumber,
      areaName = row.areaName,
      rooms = {}
    }
    row = cursor:fetch( row, "a" )
  end
  cursor:close()

  -- Load Rooms
  cursor = conn:execute( "SELECT * FROM Room" )
  row = cursor:fetch( {}, "a" )
  while row do
    if areas[row.areaRNumber] then
      areas[row.areaRNumber].rooms[row.roomRNumber] = {
        roomRNumber = row.roomRNumber,
        roomName = row.roomName,
        exits = {}
      }
    else
      cecho( f '{{Unmatched Room: {row.roomRNumber} in Area: {row.areaRNumber}\n' )
    end
    row = cursor:fetch( row, "a" )
  end
  cursor:close()

  -- Load Exits
  cursor = conn:execute( "SELECT * FROM Exit" )
  row = cursor:fetch( {}, "a" )
  while row do
    for _, area in pairs( areas ) do
      if area.rooms[row.roomRNumber] then
        table.insert( area.rooms[row.roomRNumber].exits, {
          exitDirection = row.exitDirection,
          exitDest = row.exitDest,
        } )
        break -- Exit found and added, no need to continue looping through areas
      end
    end
    row = cursor:fetch( row, "a" )
  end
  -- Create a lookup table that maps roomRNumber(s) to areaRNumber(s)
  for areaID, area in pairs( areas ) do
    for roomID, _ in pairs( area.rooms ) do
      roomToAreaMap[roomID] = areaID
    end
  end
  cursor:close()
  conn:close()
  env:close()
  -- Create a lookup table that maps roomRNumber(s) to areaRNumber(s)
  for areaID, area in pairs( areas ) do
    for roomID, _ in pairs( area.rooms ) do
      roomToAreaMap[roomID] = areaID
    end
  end
  return areas
end

roomToAreaMap = {}
worldData = {}
currentAreaData = {}
currentRoomData = {}
currentAreaNumber = -1
currentAreaName = ""
currentRoomNumber = -1
currentRoomName = ""
roomExits = {}

-- Basically just getPathAlias but automatically follow the route.
function gotoAlias()
  getPathAlias()
  doWintin( walkPath )
end

-- Use built-in Mudlet path finding to get a path to the specified room.
function getPathAlias()
  -- Clear the pathing globals
  speedWalkDir = nil
  speedWalkPath = nil

  local nc = MAP_COLOR["number"]
  local rc = MAP_COLOR["roomNameU"]
  local dirs = nil
  local dstRoomName = nil
  local dstRoomNumber = tonumber( matches[2] )
  if currentRoomNumber == dstRoomNumber then
    cecho( f "\nYou're already in {rc}{currentRoomName}<reset>." )
  elseif not roomExists( dstRoomNumber ) then
    cecho( f "\nRoom {nc}{dstRoomNumber}<reset> doesn't exist yet." )
  else
    getPath( currentRoomNumber, dstRoomNumber )
    if speedWalkDir then
      dstRoomName = getRoomName( dstRoomNumber )
      dirs = createWintin( speedWalkDir )
      cecho( f "\n\nPath from {rc}{currentRoomName}<reset> [{nc}{currentRoomNumber}<reset>] to {rc}{dstRoomName}<reset> [{nc}{dstRoomNumber}<reset>]:" )
      cecho( f "\n<green_yellow>{dirs}<reset>" )
      walkPath = dirs
    end
  end
end

worldData = loadFollowData()
-- Create all Exits, Exit Stubs, and/or Doors from the Current Room to adjacent Rooms
function updateExits()
  if true then return end
  for _, exit in ipairs( currentRoomData.exits ) do
    local exitDirection = exit.exitDirection
    if (not culledExits[currentRoomNumber]) or (not culledExits[currentRoomNumber][exitDirection]) then
      local exitDest = tonumber( exit.exitDest )
      local exitKeyword = exit.exitKeyword
      local exitFlags = exit.exitFlags
      local exitKey = tonumber( exit.exitKey )
      local exitDescription = exit.exitDescription

      -- Skip any exits that lead to the room we're already in
      if exitDest ~= currentRoomNumber then
        -- If the destination room is already mapped, remove any existing exit stub and create a "real" exit in that direction
        if roomExists( exitDest ) then
          setExitStub( currentRoomNumber, exitDirection, false )
          setExit( currentRoomNumber, exitDest, exitDirection )

          -- If the destination room we just linked links back to the current room, create the corresponding reverse exit
          local reverseDir = EXIT_MAP[REVERSE[exitDirection]]
          local destStubs = getExitStubs1( exitDest )
          if contains( destStubs, reverseDir, false ) then
            setExitStub( exitDest, reverseDir, false )
            setExit( exitDest, currentRoomNumber, reverseDir )
          end
          -- With all exits presumably created, call optimizeExits to remove superfluous or redundant exits
          -- (e.g., if room A has e/w exits to room B but room B only has an e exit to room A, we'll eliminate the w exit from A)
          --optimizeExits( currentRoomNumber )
        else
          -- If the destination room hasn't been mapped yet, create a stub for later
          setExitStub( currentRoomNumber, exitDirection, true )
        end
        -- The presence of exitFlags indicates a door; a non-zero key value indicates locked status
        if exitFlags and exitFlags ~= -1 then
          local doorStatus = (exitKey and exitKey > 0) and 3 or 2
          local shortExit = exitDirection:match( '%w' )
          setDoor( currentRoomNumber, shortExit, doorStatus )
          if exitKey and exitKey > 0 then
            setRoomUserData( currentRoomNumber, f "key_{shortExit}", exitKey )
          end
        end
      end
    end
  end
end

-- Get new coordinates based on the existing global coordinates and the recent direction of travel
function getNextCoordinates( direction )
  local nextX, nextY, nextZ = mX, mY, mZ
  -- Increment by 2 to provide a buffer on the Map for moving rooms around (don't buffer in the Z dimension)
  if direction == "north" then
    nextY = nextY + 2
  elseif direction == "south" then
    nextY = nextY - 2
  elseif direction == "east" then
    nextX = nextX + 2
  elseif direction == "west" then
    nextX = nextX - 2
  elseif direction == "up" then
    nextZ = nextZ + 1
  elseif direction == "down" then
    nextZ = nextZ - 1
  end
  return nextX, nextY, nextZ
end

function setRoomStyleAlias()
  local roomStyle = matches[2]
  if roomStyle == "mana" then
    unHighlightRoom( currentRoomNumber )
    setRoomEnv( currentRoomNumber, COLOR_CLUB )
    setRoomChar( currentRoomNumber, "💤" )
  elseif roomStyle == "shop" then
    unHighlightRoom( currentRoomNumber )
    setRoomEnv( currentRoomNumber, COLOR_SHOP )
    setRoomChar( currentRoomNumber, "💰" )
    --setRoomCharColor( currentRoomNumber, 140, 130, 15, 255 )
  elseif roomStyle == "death" then
    unHighlightRoom( currentRoomNumber )
    setRoomEnv( currentRoomNumber, COLOR_DEATH )
    setRoomChar( currentRoomNumber, "💀 " )
    lockRoom( currentRoomNumber, true )
  elseif roomStyle == "proc" then
    unHighlightRoom( id )
    setRoomEnv( id, COLOR_PROC )
    setRoomChar( id, "📁 " )
  end
end

-- Cull redundant (leading to the same room) exits from a given room
function cullRedundantExits( roomID )
  local roomExits = getRoomExits( roomID )
  local exitCounts = {}

  -- Count the number of exits leading to each destination
  for dir, destID in pairs( roomExits ) do
    if not exitCounts[destID] then
      exitCounts[destID] = {}
    end
    table.insert( exitCounts[destID], dir )
  end
  for destID, exits in pairs( exitCounts ) do
    -- Proceed only if there are multiple exits leading to the same destination
    if #exits > 1 then
      culledExits[roomID] = culledExits[roomID] or {}

      -- If the destination room has a "reverse" (return) of the exit, keep that one
      local destExits = getRoomExits( destID )
      local reverseExit = nil
      for destDir, backDestID in pairs( destExits ) do
        if backDestID == roomID then
          reverseExit = destDir
          break
        end
      end
      -- Find the corresponding exit to keep
      local exitToKeep = nil
      if reverseExit then
        for _, exitDir in pairs( exits ) do
          exitToKeep = exitDir
          break
        end
      end
    end
    -- If there's no matching 'return' exit, prefer exits in this order
    if not exitToKeep then
      local dirOrder = {"north", "south", "east", "west", "up", "down"}
      for _, dir in ipairs( dirOrder ) do
        if contains( exits, dir, true ) then
          exitToKeep = dir
          break
        end
      end
    end
    -- Remove all exits except the one to keep
    for _, exitDir in pairs( exits ) do
      if exitDir ~= exitToKeep then
        cullExit( exitDir )
      end
    end
  end
end

-- Set & update the player's location, updating coordinates & creating rooms as necessary
function updatePlayerLocationyy( roomRNumber, direction )
  -- Store data about where we "came from" to get here
  if direction then
    lastDir = direction
  end
  -- Update the current Room (this function updates Area as needed)
  setCurrentRoom( roomRNumber )
  -- If the room exists already, set coordinates, otherwise calculate new ones based on the direction of travel
  if roomExists( currentRoomNumber ) then
    mX, mY, mZ = getRoomCoordinates( currentRoomNumber )
  else
    mX, mY, mZ = getNextCoordinates( direction )
    createRoom()
  end
  --updateExits()
  centerview( currentRoomNumber )
end

function splitPrint( str, delimiter )
  local substrings = split( str, delimiter )
  for _, substring in ipairs( substrings ) do
    print( substring )
  end
end

-- Create a local copy of this file named client_config.lua in this location; customize it to your
-- local environment and preference, and make sure it"s in your .gitignore so we don"t cross streams.

-- Localized project paths
ASSETS_DIR     = 'C:/Dev/mud/mudlet/gizmo/assets'
DB_PATH        = 'C:/Dev/mud/gizmo/data/gizwrld.db'
HOME_PATH      = 'C:/Dev/mud/mudlet'
pcNames        = {"Colin", "Nadja", "Laszlo", "Nandor"}
containers     = {"stocking", "cradle", "cradle", "cradle"}
waterskin      = "waterskin"
food           = "bread"

-- These should be the abbreviations you use to issue commands to session windows; they're used by the
-- aliasSessionCommand function in config_events.lua to raise the event matching the desired session.
-- e.g., issuing 'col command' will raise event_command_1
sessionAliases = {"col", "nad", "las", "nan"}
sessionNumbers = {
  ["col"] = 1, ["nad"] = 2, ["las"] = 3, ["nan"] = 4
}


-- Using this table, define which spells are castable from specific player positions within your party;
-- use this table anywhere you need to select from among a set of possible casters (e.g., when rebuffing).
partySpells        = {
  ['vitality'] = {1, 2, 3}
}

-- Local customization options for GUI windows; expand this list for more GUI customizations later
-- These are only needed to create the GUI/console and will be nil'd in deleteConsoleStyles()
customChatFontFace = "Bitstream Vera Sans Mono"
customChatFontSize = 14
customInfoFontFace = "Bitstream Vera Sans Mono"
customInfoFontSize = 14
customChatWrap     = 60
customInfoWrap     = 60
customConsoleFonts = {
  ["label"]     = "Ebrima",
  ["gauge_sm"]  = "Bitstream Vera Sans Mono",
  ["gauge_lrg"] = "Montserrat",
  ["room"]      = "Consolas",
}

-- Global color-code definitions for use throughout the project; use in conjunction with cout() and iout() to
-- avoid overly-long lines incorporating specific color codes and <reset> flags
NC                 = "<orange>"          -- Numbers
RC                 = "<reset>"           -- Reset Color
EC                 = "<deep_pink>"       -- Errors & Warnings
DC                 = "<ansi_yellow>"     -- Derived or Calculated Values
FC                 = "<maroon>"          -- Flags & Effects
SC                 = "<cornflower_blue>" -- String Literals

-- Used when updating the pcStatus table to decide whether to send a warning about someone's health
-- A warning will be sent if the health falls below low% or loses more than big% in a single update
-- Make sure to align these values with the order of your party (same as in pcNames, etc.)
healthMonitor      = {
  --[#] = {low%, big%}
  [1] = {50, 20},
  [2] = {80, 10},
  [3] = {80, 10},
  [4] = {25, 20},
}

-- Customize colors for your PCs; local for now 'cause it's only used to make the tags below
local pcColors     = {
  "<cornflower_blue>",
  "<medium_violet_red>",
  "<dark_violet>",
  "<dark_orange>",
}

-- Customized nametags for each player; primarily useful for warnings echoed to the info window
pcTags             = {
  f "<reset>[{pcColors[1]}{pcNames[1]}<reset>]",
  f "<reset>[{pcColors[2]}{pcNames[2]}<reset>]",
  f "<reset>[{pcColors[3]}{pcNames[3]}<reset>]",
  f "<reset>[{pcColors[4]}{pcNames[4]}<reset>]",
}

-- Customize chat output colors
messageColors      = {
  ["auction"] = "<navajo_white>",
  ["debug"]   = "<dodger_blue>",
  ["say"]     = "<cyan>",
  ["gossip"]  = "<chartreuse>",
  ["replies"] = "<pale_violet_red>",
  ["quest"]   = "<gold>",
  ["whisper"] = "<deep_pink>",
}

-- You can send these messages to the "Info" window with the showWarning function; this
-- window belongs to session 1, so other sessions must raise eventWarn to pass warnings
warningMessages    = {
  ["water"]     = "Needs <powder_blue>Water<reset>",
  ["mvs"]       = "Low <gold>Moves<reset>",
  ["food"]      = "Needs <olive_drab>Food<reset>",
  ["whacked"]   = "🩸 <medium_violet_red>.w.h.A.C.K.e.d.<reset>",
  ["switched"]  = "👿 Targeted",
  ["hp"]        = "🤕 Critical <tomato>HP<reset> ",
  ["exhausted"] = "👟 No Moves",
  ["norecall"]  = "🌀 Out of Recalls"
}

-- Critical warnings will play bloop.wav when sent.
criticalWarnings   = {
  ["whacked"]   = true,
  ["exhausted"] = true,
  ["hp"]        = true,
  ["switched"]  = true,
  ["norecall"]  = true,
}
-- Customize your affect info to match the duration of your own buffs and desired colors & characters
affectInfo         = {
  ["Sanctuary"]            = {duration = 7, color = "lavender_blush", char = "🌟"},
  ["Bless"]                = {duration = 6, color = "light_goldenrod", char = "🙏"},
  ["Fury"]                 = {duration = 2, color = "tomato", char = "😡"},
  ["Armor"]                = {duration = 24, color = "steel_blue", char = "🛡️"},
  ["Endure"]               = {duration = 24, color = "orange", char = "💪"},
  ["Protection from evil"] = {duration = 24, color = "gold", char = "🧿"},
  ["Achilles' last stand"] = {duration = 4, color = "medium_violet_red", char = "⚔️"}
}
-- Colors to use in the Party Console labels to indicate duration of affects
affectDuration     = {
  ['high'] = "YellowGreen",
  ['med']  = "Orange",
  ['low']  = "Crimson",
}
-- These keywords are captured in trigger phrases to indicate which spell has been applied or removed.
-- They are used to map to the spell name in applyAffect() and removeAffect().
affectKeywords     = {
  ["glowing"]           = "Sanctuary",
  ["aura"]              = "Sanctuary",
  ["righteous"]         = "Bless",
  ["angry"]             = "Fury",
  ["calm"]              = "Fury",
  ["protecting"]        = "Armor",
  ["protected"]         = "Armor",
  ["righteous feeling"] = "Protection from evil"
}

-- Affects that do not need to be tracked or displayed on the Party/Player Console (and don't print a warning)
IGNORED_AFFECTS    = {
  ['Strength'] = true,
  ['Invulnerability'] = true,
  ['Darkness'] = true,
}
-- How many "steps" does the tick clock have (i.e., how many individual images make up the animation)
TICK_STEPS         = 120

-- Select which ANTI-FLAGS to include in stat output from eq/eq_db.lua
function customizeAntiString( antis )
  local includedFlags = {
    ["!NEU"] = true,
    ["!GOO"] = true,
    ["!EVI"] = true,
    --["!MU"] = true,
    --["!CL"] = true,
    --["!CO"] = true,
    ["!BA"] = true,
    ["!WA"] = true,
    ["!TH"] = true,
    ["!FEM"] = true,
    --["!MAL"] = true,
    ["!RENT"] = true
  }

  -- Match & replace any flag that isn't in the included table
  antis = antis:gsub( "!%w+", function ( flag )
    if not includedFlags[flag] then
      return ""
    else
      return flag
    end
  end )

  -- Trim and condense
  return antis:gsub( "%s+", " " ):trim()
end

-- Table & following function sets the initial state for Triggers, Keys, and Aliases; localizing this
-- should allow for some personalization (e.g., if you don't want Map-related stuff enabled by default).
-- This list does not need to be exhaustive, but it should include anything you want to guarantee is in
-- a certain state at startup (e.g., this is a good time to make sure temporary triggers start disabled).
local initialReactionState = {
  -- ++ON for everyone
  {name = "PC Login",                  type = "trigger", state = true,  scope = 'All'},
  {name = "Total Recall (wor)",        type = "alias",   state = true,  scope = 'All'},
  {name = "All Rec Recall (rr)",       type = "alias",   state = true,  scope = 'All'},
  -- --OFF for everyone
  {name = "hunger",                    type = "trigger", state = false, scope = 'All'},
  {name = "thirst",                    type = "trigger", state = false, scope = 'All'},
  {name = "fountain",                  type = "trigger", state = false, scope = 'All'},
  {name = "Group XP",                  type = "trigger", state = false, scope = 'All'},
  {name = "Solo XP",                   type = "trigger", state = false, scope = 'All'},
  {name = "EQ Stats",                  type = "trigger", state = false, scope = 'All'},
  {name = "Missing EQ",                type = "trigger", state = false, scope = 'All'},
  {name = "Parse Score",               type = "trigger", state = false, scope = 'All'},
  {name = "List Fonts (lfonts)",       type = "alias",   state = false, scope = 'All'},
  {name = "Print Variables (pvars)",   type = "alias",   state = false, scope = 'All'},
  -- ++ON for Main session
  {name = "Main Format",               type = "trigger", state = true,  scope = 'Main'},
  {name = "gather",                    type = "trigger", state = true,  scope = 'Main'},
  {name = "Tank Condition (automira)", type = "trigger", state = true,  scope = 'Main'},
  {name = "map",                       type = "trigger", state = true,  scope = 'Main'},
  {name = "Movement (Map)",            type = "key",     state = true,  scope = 'Main'},
  -- --OFF for Main session
  {name = "Alt Gags",                  type = "trigger", state = false, scope = 'Main'},
  -- ++ON for Alts
  {name = "Movement (Raw)",            type = "key",     state = true,  scope = 'Alts'},
  {name = "Alt Gags",                  type = "trigger", state = true,  scope = 'Alts'},
  -- --OFF for Alts
  {name = "gather",                    type = "trigger", state = false, scope = 'Alts'},
  {name = "Tank Condition (automira)", type = "trigger", state = false, scope = 'Alts'},
  {name = "Main Format",               type = "trigger", state = false, scope = 'Alts'},
  {name = "map",                       type = "trigger", state = false, scope = 'Alts'},
  {name = "Movement (Map)",            type = "key",     state = false, scope = 'Alts'},
}

local function initializeReactions()
  cecho( "\nInitial Trigger, Alias, and Key states\n" )
  cecho( "______________________________________\n" )

  local function formatReactionState( reaction, isEnabled )
    local typeTag = reaction.type == "trigger" and "<hot_pink>T<reset>" or
        (reaction.type == "key" and "<dark_turquoise>K<reset>" or "<ansi_yellow>A<reset>")
    local nameState = isEnabled and f "<olive_drab>+{reaction.name}<reset>" or f "<brown>-{reaction.name}<reset>"
    return string.format( "%-5s %-5s %-35s", reaction.scope, typeTag, nameState )
  end

  for _, reaction in ipairs( initialReactionState ) do
    if reaction.scope == "All" or (reaction.scope == "Main" and SESSION == 1) or (reaction.scope == "Alts" and SESSION ~= 1) then
      local isEnabled = false
      if reaction.type == "trigger" then
        if reaction.state then
          enableTrigger( reaction.name )
          isEnabled = true
        else
          disableTrigger( reaction.name )
        end
      elseif reaction.type == "alias" then
        if reaction.state then
          enableAlias( reaction.name )
          isEnabled = true
        else
          disableAlias( reaction.name )
        end
      elseif reaction.type == "key" then
        if reaction.state then
          enableKey( reaction.name )
          isEnabled = true
        else
          disableKey( reaction.name )
        end
      end
      local formattedReaction = formatReactionState( reaction, isEnabled )
      cecho( f "\n{formattedReaction}" )
    end
  end
end

initializeReactions()
