-- Trim leading/trailing whitespace from a string
function trim( s )
  if not s then return end
  return s:match( "^%s*(.-)%s*$" )
end

-- Trim leading/trailing whitespace and condense multiple whitespace characters to a single space
function trimCondense( s )
  if not s then return end
  local trimmedString = trim( s )
  -- Replace multiple whitespace characters with a single space
  local condensedString = trimmedString:gsub( "%s+", " " )
  return condensedString
end

-- Output number char(s) in a color; useful e.g., to add padding to formatted output by printing
-- a series of <black> characters.
function fill( number, char, color )
  if not color then color = "<black>" end
  if not char then char = "." end
  return f "{color}" .. string.rep( char, number ) .. "<reset>"
end

-- Returns the length of the longest string in a list
function getMaxStringLength( stringList )
  local maxLength = 0
  for _, str in ipairs( stringList ) do
    maxLength = math.max( maxLength, #str )
  end
  return maxLength
end

-- Get a list of substrings by splitting a string at delimeter
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

-- Print a formatted string to the "main" console; mainly used to report on in-game events or
-- alert the player to important events or necessary actions
function cout( s )
  cecho( "\n" .. f( s ) )
end

-- Print a formatted string to the "Info" console; used more like a status or debug window for Mudlet
-- to report on internal functionality and provide additional context for certain functions
function iout( s )
  cecho( "info", "\n" .. f( s ) )
end

-- "To lower" a string beginning with an article; useful for mobs whose short descriptions
-- contain an article which changes capitalization depending on where it appears in game.
-- e.g., "A large orc is here." vs. "You get coins from the corpse of a large orc."
function lowerArticles( str )
  for _, article in ipairs( ARTICLES ) do
    local articleLength = #article
    -- Check if the start of the string matches an article (case insensitive)
    if str:sub( 1, articleLength ):lower() == article:lower() then
      -- Lower only the article portion then concatenate the remainder
      return article:lower() .. str:sub( articleLength + 1 )
    end
  end
  return str
end

-- Trim an article from the start of a string; useful for cleaning up mob names or item descriptions
function trimArticle( s )
  -- First, trim the input string
  s = trim( s )

  -- Define a pattern to match "a", "an", or "the" at the start of the string (case insensitive)
  local patterns = {"^a%s+", "^an%s+", "^the%s+"}

  -- Convert the input string to lower case for case insensitive matching
  local lowerS = s:lower()

  -- Iterate over the patterns and remove the matching article from the start of the string
  for _, pattern in ipairs( patterns ) do
    local matchStart, matchEnd = lowerS:find( pattern )
    if matchStart == 1 then
      s = s:sub( matchEnd + 1 )
      break
    end
  end
  return trim( s )
end

-- From a list of raw directions, create a Wintin-style command string
-- e.g., { "n", "n", "n", "u", "u" } = "#3 n;#2 u"
-- [TODO] Add support for both short/long direction format, ordinal directions, etc.
function createWintinString( cmdList )
  if not cmdList or #cmdList == 0 then
    cecho( "\n<dark_orange>Empty command list in createWintinString()<reset>" )
    return ""
  end
  local wintinCommands = {}
  local currentDirection = nil
  local count = 0

  for _, direction in ipairs( cmdList ) do
    -- Convert directions to their "short" versions before adding to the path
    direction = SDIR[direction]
    -- [TODO] This should really just handle any "non-direction" item in a list
    -- [TODO] Everywhere door commands are used/referenced, we need to update w/ direction like 'open door north'
    if direction:match( "^open [%w]+" ) or direction:match( "^close [%w]+" ) or direction:match( "^unlock [%w]+" ) then
      if currentDirection then
        table.insert( wintinCommands, (count > 1 and "#" .. count .. " " or "") .. currentDirection )
      end
      table.insert( wintinCommands, direction )
      currentDirection = nil
      count = 0
    else
      if direction == currentDirection then
        count = count + 1
      else
        if currentDirection then
          table.insert( wintinCommands, (count > 1 and "#" .. count .. " " or "") .. currentDirection )
        end
        currentDirection = direction
        count = 1
      end
    end
  end
  if currentDirection then
    table.insert( wintinCommands, (count > 1 and "#" .. count .. " " or "") .. currentDirection )
  end
  return table.concat( wintinCommands, ";" )
end

-- Create a list of individual commands by translating/expanding a Wintin-style string
-- e.g., "#3 n;#2 u" = { "n", "n", "n", "u", "u" }
function expandWintinString( wintinString )
  local commands = {}
  display( wintinString )
  -- Break on semi-colons
  for command in wintinString:gmatch( "[^;]+" ) do
    -- Insert 'command' '#' times
    local count, cmd = command:match( "#(%d+)%s*(.+)" )
    count = count or 1
    cmd = cmd or command

    for i = 1, tonumber( count ) do
      table.insert( commands, cmd )
    end
  end
  return commands
end

-- Given a large number as str, return an abbreviated version like '1.2B'
function abbreviateNumber( numberString )
  local str = string.gsub( numberString, ",", "" )
  str = trim( str )
  local num = tonumber( str )

  local function formatNumber( n, unit )
    if n % 1 == 0 then
      return string.format( "%d%s", n, unit )
    else
      return string.format( "%.1f%s", n, unit )
    end
  end

  -- Truncate based on 10 power and add matching label
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

-- Given a large number as n, return a comma-delimited string like '1,234,567'
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

-- Given a raw string, return a regex that would match that string if it appears
-- as a standalone line of output. Useful for dynamically creating triggers.
function createLineRegex( rawString )
  -- Escape Perl regex tokens
  local escString = rawString:gsub( "([%(%)%.%%%+%-%*%?%[%]%^%$])", "\\%1" )

  -- Create regex pattern with start and end line matching; accounts for messages that
  -- sometimes appear on the same line as the prompt assuming your prompt ends with >
  local lineRegex = [[(?:^.*?)]] .. escString .. "$"

  return lineRegex
end

-- Given a number, return a string with an appropriate + or - sign included
function getSignedString( num )
  if not num then
    print( "Empty string" )
    return ""
  elseif num > 0 then
    return "+" .. tostring( num )
  else
    return tostring( num )
  end
end

-- Calculate the length of a string without Mudlet color tags
function cLength( s )
  -- Remove Mudlet color tags, which can include underscores
  local strippedString = s:gsub( "<[%a_]+>", "" )
  local result = #strippedString
  -- Account for characters that evaluate as length two but only take up one space
  if string.find( strippedString, SPEC_TAG ) then
    result = result - 1
  end
  if string.find( strippedString, CLONE_TAG ) then
    result = result - 2
  end
  return result
end

-- Given a string, substring, and color, return a new string with the substring and
-- color code appended, separated by a space (if the substring is not empty or nil)
function compositeString( string, substring, color )
  if not substring or substring == "" then
    return string
  elseif not string or string == "" then
    return color .. substring .. "<reset>"
  else
    return string .. " " .. color .. substring .. "<reset>"
  end
end

-- Guess a string is regex if it starts with ^, ends with $, or contains a backslash
local function isRegex( str )
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

-- Parse a WINTIN-style action/trigger definition into a table of its components
-- "#ACTION {pattern} {command} {priority}" = { "pattern", "command", "priorisy" }
-- Intended as part of a solution for importing WINTIN/TINTIN files into a Mudlet project
local function parseWintinAction( actionString )
  local pattern, command, priority = "", "", ""
  local section = 1
  local braceDepth = 0
  local temp = ""

  for i = 1, #actionString do
    local char = actionString:sub( i, i )

    -- Do some ridiculous bullshit to deal with nested braces
    if char == "{" then
      braceDepth = braceDepth + 1
      if braceDepth == 1 then
        -- Open section
        temp = ""
      else
        temp = temp .. char
      end
    elseif char == "}" then
      braceDepth = braceDepth - 1
      if braceDepth == 0 then
        -- Close section
        if section == 1 then
          pattern = temp
        elseif section == 2 then
          command = temp
        elseif section == 3 then
          priority = temp
        end
        section = section + 1
      else
        temp = temp .. char
      end
    elseif braceDepth > 0 then
      temp = temp .. char
    end
  end
  return trim( pattern ), trim( command ), trim( priority )
end
