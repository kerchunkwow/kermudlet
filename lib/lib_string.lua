-- Trim leading/trailing whitespace from a string
function trim( s )
  return s:match( "^%s*(.-)%s*$" )
end

-- Get a list of substrings by splitting a string at delimeter
function split( str, delimiter )
  local substrings = {}
  local from = 1
  local delimFrom, delimTo = string.find( str, delimiter, from )

  while delimFrom do
    table.insert( substrings, string.sub( str, from, delimFrom - 1 ) )
    from = delimTo + 1
    delimFrom, delimTo = string.find( str, delimiter, from )
  end
  table.insert( substrings, string.sub( str, from ) )

  return substrings
end

-- Given a large number as a string, return a abbreviated version like '1.2B'
function abbreviateNumber( numberString )
  local str = string.gsub( numberString, ",", "" )
  str = trim( str )
  local num = tonumber( str )

  -- Truncuate based on 10 power and add matching label
  if num >= 10 ^ 9 then
    return string.format( "%.1fB", num / 10 ^ 9 )
  elseif num >= 10 ^ 6 then
    return string.format( "%.1fM", num / 10 ^ 6 )
  elseif num >= 10 ^ 3 then
    return string.format( "%.1fK", num / 10 ^ 3 )
  else
    return tostring( num )
  end
end

-- Given a large number as number, return a string with commas for improved readability
function expandNumber( n )
  local result       = ""
  local counter      = 0
  local numberString = tostring( math.floor( n ) )

  for i = #numberString, 1, -1 do
    counter = counter + 1
    result = string.sub( numberString, i, i ) .. result

    if counter % 3 == 0 and i ~= 1 then
      result = "," .. result
    end
  end
  return result
end

-- Output number chars in a color; useful e.g., to add padding to formatted output by printing
-- a series of <black> characters.
function fill( number, char, color )
  if not color then color = "<black>" end
  if not char then char = "." end
  return f "{color}" .. string.rep( char, number ) .. "<reset>"
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

-- Returns the length of the longest string in a list
function getMaxStringLength( stringList )
  local maxLength = 0
  for _, str in ipairs( stringList ) do
    maxLength = math.max( maxLength, #str )
  end
  return maxLength
end

-- Given a raw string, return a regex that would match that string if it appears
-- as a standalone line of output.
function createLineRegex( rawString )
  -- Escape Perl regex tokens
  local escString = rawString:gsub( "([%(%)%.%%%+%-%*%?%[%]%^%$])", "\\%1" )

  -- Create regex pattern with start and end line matching; accounts for messages that
  -- sometimes appear on the same line as the prompt assuming your prompt ends with >
  local lineRegex = "(?:^|>)" .. escString .. "$"

  return lineRegex
end

-- Guess a string is regex if it starts with ^, ends with $, or contains a backslash
function isRegex( str )
  if string.sub( str, 1, 1 ) == '^' then
    return true
  end
  if string.sub( str, -1 ) == '$' then
    return true
  end
  if string.find( str, "\\" ) then
    return true
  end
  return false
end
