function getCursor( sql, param )
  local luasql = require "luasql.sqlite3"
  local env = luasql.sqlite3()
  local conn, connerr = env:connect( 'C:/Dev/mud/gizmo/data/gizwrld.db' )

  if not conn then
    cecho( f "\nError connecting to database: {tostring( connerr )}" )
    return nil
  end
  -- Safely incorporating the parameter into the SQL query
  if param then
    sql = string.format( sql, conn:escape( param ) )
  end
  local cursor, cursorerr = conn:execute( sql )
  if not cursor then
    cecho( f "\nError executing SQL: {tostring( cursorerr )}" )
    conn:close()
    env:close()
    return nil
  end
  -- Return both cursor and conn to ensure the caller can close them
  return cursor, conn, env
end
