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
