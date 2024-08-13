-- Split a string into a list of substrings at each occurrence of a delimiter
-- @param s The string to be split
-- @param delim The delimiter to split the string at
-- @return A table containing the substrings
function split( s, delim )
  local substrings = {}
  local from = 1
  local delimFrom, delimTo = string.find( s, delim, from )

  while delimFrom do
    table.insert( substrings, string.sub( s, from, delimFrom - 1 ) )
    from = delimTo + 1
    delimFrom, delimTo = string.find( s, delim, from )
  end
  table.insert( substrings, string.sub( s, from ) )

  return substrings
end

-- Trim leading and trailing whitespace from a string
-- @param s The string to be trimmed
-- @return The trimmed string
function trim( s )
  if not s then return end
  return s:match( "^%s*(.-)%s*$" )
end

-- Trim leading and trailing whitespace & condense internal whitespace
-- @param s The string to be trimmed and condensed
-- @return The trimmed and condensed string
function trimCondense( s )
  if not s then return "" end
  return trim( s ):gsub( "%s+", " " )
end

-- Trim an article ("a", "an", "the") from the start of a string
-- @param s The string to be processed
-- @return The string without the leading article
function trimArticle( s )
  s = trim( s )
  local patterns = {"^a%s+", "^an%s+", "^the%s+"}
  for _, pattern in ipairs( patterns ) do
    local matchStart, matchEnd = s:lower():find( pattern )
    if matchStart == 1 then
      s = s:sub( matchEnd + 1 )
      break
    end
  end
  return trim( s )
end

-- Convert the first word of a string to lowercase if it is an article ("a", "an", "the")
-- @param str The string to be processed
-- @return The string with the first article converted to lowercase
function lowerArticles( str )
  for _, article in ipairs( ARTICLES ) do
    local articleLength = #article
    if str:sub( 1, articleLength ):lower() == article:lower() then
      return article:lower() .. str:sub( articleLength + 1 )
    end
  end
  return str
end

-- Abbreviate a large number as a string with a suffix (K, M, B)
-- @param numberString The number as a string to be abbreviated
-- @return The abbreviated number string
function abbreviateNumber( numberString )
  local str = trim( (numberString:gsub( ",", "" )) )
  local num = tonumber( str )

  local function formatNumber( n, unit )
    if n % 1 == 0 then
      return string.format( "%d%s", n, unit )
    else
      return string.format( "%.1f%s", n, unit )
    end
  end

  if num >= 10 ^ 9 then
    return formatNumber( num / 10 ^ 9, "B" )
  elseif num >= 10 ^ 6 then
    return formatNumber( num / 10 ^ 6, "M" )
  elseif num >= 10 ^ 3 then
    return formatNumber( num / 10 ^ 3, "K" )
  else
    return tostring( num )
  end
end

-- Format a number with commas as thousands separators
-- @param n The number to be formatted
-- @return The formatted number string
function expandNumber( n )
  local commaNumber  = ""
  local counter      = 0
  local numberString = tostring( math.floor( n ) )

  for i = #numberString, 1, -1 do
    counter = counter + 1
    commaNumber = string.sub( numberString, i, i ) .. commaNumber

    if counter % 3 == 0 and i ~= 1 then
      commaNumber = "," .. commaNumber
    end
  end
  return commaNumber
end

-- Generate a string composed of a repeated character in a specified color
-- @param number The number of characters to generate
-- @param char The character to repeat (default is ".")
-- @param color The color code to apply (default is "<black>")
-- @return The generated string
function fill( number, char, color )
  char = char or "."
  color = color or "<black>"
  return f "{color}" .. string.rep( char, number ) .. RC
end

-- Get the length of the longest string in a list
-- @param stringList The list of strings
-- @return The length of the longest string
function getMaxStringLength( stringList )
  local maxLength = 0
  for _, str in ipairs( stringList ) do
    maxLength = math.max( maxLength, #str )
  end
  return maxLength
end

-- Create a regex pattern to match a string as a standalone line of output
-- @param rawString The string to be matched
-- @return The regex pattern
-- [TODO] Is this redundant with utf8.patternEscape( str )?
function createLineRegex( rawString )
  local escString = rawString:gsub( "([%(%)%.%%%+%-%*%?%[%]%^%$])", "\\%1" )
  return [[(?:^.*?)]] .. escString .. "$"
end

-- Get a string representation of a number with a sign (+ or -)
-- @param num The number to be converted
-- @return The signed string
function getSignedString( num )
  if not num then
    return ""
  elseif num > 0 then
    return "+" .. tostring( num )
  else
    return tostring( num )
  end
end

-- Concatenate a string with a colored substring, separated by a space; this mainly supports
-- the creation of display strings for MUD items but could be useful elsewhere.
-- @param str The base string
-- @param substring The substring to be appended
-- @param color The color code for the substring
-- @return The concatenated string
function compositeString( str, substring, color )
  if not substring or substring == "" then
    return str
  elseif not str or str == "" then
    return color .. substring .. RC
  else
    return str .. " " .. color .. substring .. RC
  end
end

-- Calculate the length of a string excluding Mudlet color tags and adjusting for special characters
-- @param s The input string to be measured
-- @return The adjusted length of the string
-- [TODO] This may be redundant with utf8.len( s )
function cLength( s )
  -- Remove Mudlet color tags, which can include underscores
  local strippedString = s:gsub( "<[%a_]+>", "" )

  -- Initialize the length counter
  local length = 0

  -- Iterate over each character in the string
  for _ in strippedString:gmatch( "[%z\1-\127\194-\244][\128-\191]*" ) do
    length = length + 1
  end
  return length
end

-- Create a Wintin-style command string from a list of raw directions
-- @param cmdList Table containing individual direction commands
-- @return A string in Wintin-style format (e.g., "#3 n;#2 u")
function createWintinString( cmdList )
  if not cmdList or #cmdList == 0 then
    cecho( "\n<dark_orange>Empty command list in createWintinString()<reset>" )
    return ""
  end
  local wintinCommands = {}
  local currentDirection, count = nil, 0

  for _, direction in ipairs( cmdList ) do
    direction = SDIR[direction]
    if direction:match( "^open [%w]+" ) or direction:match( "^close [%w]+" ) or direction:match( "^unlock [%w]+" ) then
      if currentDirection then
        table.insert( wintinCommands, (count > 1 and "#" .. count .. " " or "") .. currentDirection )
      end
      table.insert( wintinCommands, direction )
      currentDirection, count = nil, 0
    else
      if direction == currentDirection then
        count = count + 1
      else
        if currentDirection then
          table.insert( wintinCommands, (count > 1 and "#" .. count .. " " or "") .. currentDirection )
        end
        currentDirection, count = direction, 1
      end
    end
  end
  if currentDirection then
    table.insert( wintinCommands, (count > 1 and "#" .. count .. " " or "") .. currentDirection )
  end
  return table.concat( wintinCommands, ";" )
end

-- Create a list of individual commands by translating/expanding a Wintin-style string
-- @param wintinString A string in Wintin-style format (e.g., "#3 n;#2 u")
-- @return A table containing individual direction commands
function expandWintinString( wintinString )
  local commands = {}

  for command in wintinString:gmatch( "[^;]+" ) do
    local count, cmd = command:match( "#(%d+)%s*(.+)" )
    count = tonumber( count ) or 1
    cmd = cmd or command

    for _ = 1, count do
      table.insert( commands, cmd )
    end
  end
  return commands
end

function parseDateString( dateString )
  local pattern = "(%a+) (%a+) (%d+) (%d+):(%d+):(%d+) (%d+) (%a+)"
  local _, _, month, day, hour, min, sec, year, tz = dateString:find( pattern )
  local monthTable = {
    Jan = 1,
    Feb = 2,
    Mar = 3,
    Apr = 4,
    May = 5,
    Jun = 6,
    Jul = 7,
    Aug = 8,
    Sep = 9,
    Oct = 10,
    Nov = 11,
    Dec = 12
  }
  local timeTable = {
    year = tonumber( year ),
    month = monthTable[month],
    day = tonumber( day ),
    hour = tonumber( hour ),
    min = tonumber( min ),
    sec = tonumber( sec )
  }
  return os.time( timeTable )
end
