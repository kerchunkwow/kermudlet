-- Get a cursor into the Gizmo game database
function getCursor( sql, param )
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn, connerr = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  if not conn then
    cecho( f "\nDB Connect Err: {tostring( connerr )}" )
    return nil
  end
  if param then
    sql = string.format( sql, conn:escape( param ) )
  end
  local cursor, cursorerr = conn:execute( sql )
  if not cursor then
    cecho( f "\nSQL Err: {tostring( cursorerr )}" )
    conn:close()
    env:close()
    return nil
  end
  -- Return cursor and conn
  return cursor, conn, env
end

-- Keep track of how many mobs we've recorded fame for (for reporting purposes)
fameCount  = fameCount or 0
fameSum    = fameSum or 0

-- Timer & flag to throttle our goofy emotes
emoteTimer = emoteTimer or nil
emoteDelay = emoteDelay or nil

-- Load pre-existing fame data from the database at startup so we can verify incoming data without hitting the db
function loadFameData()
  -- Initialize table & counters
  fameCount               = 0
  fameSum                 = 0
  fameData                = {}

  local sql               = "SELECT shortDescription, fame FROM Mob WHERE fame IS NOT NULL"
  local cursor, conn, env = getCursor( sql )
  if not cursor then
    iout( "{EC}Failed to get cursor in loadFameData(){RC}" )
    return
  end
  -- For each row returned, add the fame data to our table and increment the count of recorded mobs
  local row = cursor:fetch( {}, "a" ) -- Fetch the first row
  while row do
    local description, fame = row.shortDescription, tonumber( row.fame )
    fameData[description] = fame
    fameCount = fameCount + 1
    fameSum = fameSum + fame

    row = cursor:fetch( row, "a" ) -- Fetch the next row
  end
  cursor:close()
  conn:close()
  env:close()

  -- Report some details of loading to the info window
  iout( f "Fame data loaded for {NC}{fameCount}{RC} mobs ({NC}{fameSum}{RC} total fame)." )
end

-- Called by Mudlet trigger when Venzu reports fame turn-ins
function triggerCaptureFame()
  -- A table of random emotes for a little cheeky fun
  local spyEmotes = {
    "peeks over your shoulder, scribbling furiously in her notebook.",
    "pretends to be absorbed in a good book, but she's clearly listening in.",
    "tries to act like she's tying her shoes, then remembers she's got no feet.",
    "practices one of her songs, but also definitely wrote that all down.",
    "is frankly doing a piss-poor job of pretending not to eavesdrop.",
    "thinks she's found a clever hiding spot, but you can definitely see her.",
    "pretends to get in line behind you while standing, like, WAY too close.",
    "is hanging around again being equal parts nosy and annoying.",
    "thinks this would easier if Venzu just published a newsletter.",
    "totally knew all of that already but can you say it again real quick?",
    "says, 'Did I catch a niner in there? Are you guys using walkie-talkies!?'",
    "is pretty sure you're the one who stole her sandwich from the break room.",
    "appreciates your dedication to the cause, but has no intention of paying.",
    "waves her quill in the air wildly, moaning 'Out of ink already?'",
    "does a fit check. 'Could anyone but me pull of tattered rags like this?'",
    "leans against a wall nearby, trying to look casual (it's not working).",
    "tries to swap her notebook with Venzu's when he's not looking.",
    "asks Venzu if he's busy later while twirling her gross old hair.",
    "tries to pretend she's part of a tour group. Like, lady you're alone.",
    "is apparently out of ink, scratching notes on the floor with her jagged ankle bone.",
    "tries to act like a statue as if you can't see straight through her.",
    "offers to sing you a song. Venzu winces visibly.",
    "does too have a boyfriend, but you wouldn't know him. He goes to another school."
  }
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

  -- Shortly after recording fame, send a silly emote (not more than once per 30s)
  --if not emoteDelay then
  if false then
    emoteDelay = true
    tempTimer( 30, [[emoteDelay = false]] )
    local randomEmote = spyEmotes[math.random( #spyEmotes )]
    tempTimer( 0.5, function () send( "emote " .. randomEmote .. f " [{fameCount}]" ) end )
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
  local sql = "SELECT fame FROM Mob WHERE shortDescription = '%s'"
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
