-- Trim leading/trailing whitespace from a string
function trim( str )
  return str:match( "^%s*(.-)%s*$" )
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

-- Feed a line to the client as if it came from the MUD (great for testing triggers).
function simulateOutput()
  local string_to_feed = matches[2]

  string_to_feed = string.gsub( string_to_feed, "%$", "\n" )
  cfeedTriggers( string_to_feed )
end --function

-- Convert large numbers to abbreviated strings like '1.2B'
function abbreviateNumber( numberString )
  -- Strip commas & whitespace then convert
  local str = string.gsub( numberString, ",", "" )
  str = trim( str )
  local num = tonumber( str )

  -- Truncuate based on 10 powers and add a label
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

-- Add commas to a big number for better readability in prints/echos
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

-- Use this with e.g. cecho to add n copies of ch with color = co to an output string
-- Useful e.g. for adding a bunch of "empty" space using <black>...
function fill( number, char, color )
  if not color then color = "<black>" end
  if not char then char = "." end
  return f "{color}" .. string.rep( char, number ) .. "<reset>"
end

-- Enable a alias for the specified duration; useful for very complex triggers that
-- are only needed occasionally/briefly
function tempEnableTrigger( trigger, duration )
  enableTrigger( trigger )
  tempTimer( duration, f [[disableTrigger( "{alias}" )]] )
end

-- Opposite of tempEnableTrigger; turns a alias off temporarily; good for limiting
-- "spam" or suppressing a alias in a situation where it might fire unexpectedly.
function tempDisableTrigger( trigger, duration )
  disableTrigger( trigger )
  tempTimer( duration, f [[enableTrigger( "{alias}" )]] )
end

-- Expand #WINTIN-style command strings
-- e.g., "#3 n;#2 u" = { "n", "n", "n", "u", "u" }
-- [NOTE] Only tested on basic directions
function expandWintin( wintinString )
  local commands = {}

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

-- Use expandWintin to execute WINTIN-style command lists
function doWintin( wintinString )
  local commands = expandWintin( wintinString )
  for _, command in ipairs( commands ) do
    send( command, false )
  end
end

-- "Nuclear option" that kills all temporary timers and triggers; will probably interfere with
-- third party packages if you have any.
function killAllTemps()
  local topTrigger = tempTrigger( "dummy", function () end )
  local topTimer = tempTimer( 0, function () end )
  for i = 1, topTrigger do
    killTrigger( i )
  end
  for j = 1, topTimer do
    killTimer( j )
  end
end

-- Compile and execute a lua function directly from the command-line; used
-- throughout other scripts and in aliases as 'lua <command> <args>'
function runLuaLine()
  local args = matches[2]
  -- Try to compile an expression.
  local func, err = loadstring( "return " .. args )

  -- If that fails, try a statement.
  if not func then
    func, err = assert( loadstring( args ) )
  end
  -- If that fails, raise an error.
  if not func then
    error( err )
  end
  -- Create the function
  local runFunc =

      function ( ... )
        if not table.is_empty( { ... } ) then
          display( ... )
        end
      end

  -- Call it
  runFunc( func() )
end --function

-- Standard format/highlight for chat message; pass a window name to route chat there
function chatMessage( speaker, channel, message, window )
  local de, sh, ch = "<gainsboro>", "<yellow_green>", "<maroon>"

  deleteLine()
  if window then
    cecho( window, f "\n{sh}{speaker} {de}[{ch}{channel}{de}]<reset> {message}" )
  else
    cecho( f "\n{sh}{speaker} {de}[{ch}{channel}{de}]<reset> {message}" )
  end
end

-- Create and/or open a basic user window into which you can echo output; uses _G to
-- store the object in a variable of the same name
function openBasicWindow( name, title, fontFace, fontSize )
  _G[name] = Geyser.UserWindow:new( {

    name          = name,
    titleText     = title,
    font          = fontFace,
    fontSize      = fontSize,
    wrapAt        = 80,
    scrollBar     = false,
    restoreLayout = true,

  } )

  _G[name]:disableScrollBar()
  _G[name]:disableHorizontalScrollBar()
  _G[name]:disableCommandLine()
  _G[name]:clear()
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

-- Returns the length of the longest string in a list
function getMaxStringLength( stringList )
  local maxLength = 0
  for _, str in ipairs( stringList ) do
    maxLength = math.max( maxLength, #str )
  end
  return maxLength
end

-- Display a list of strings within a formatted "box"; supply a maxLength
-- to customize width, or let the function guess by finding the longest
-- string in your list.
function displayBox( stringList, maxLength, borderColor )
  maxLength = maxLength or getMaxStringLength( stringList )
  local bclr = borderColor or "<dark_slate_blue>"
  local margin = "  "

  local boxWidth = maxLength + 10
  local line = string.rep( '-', boxWidth )
  local blank = string.rep( ' ', boxWidth )
  local borderLine = f "\n{bclr}+{line}+<reset>"
  local blankLine = f "\n{bclr}|<reset>"

  cecho( borderLine )
  cecho( blankLine )

  -- Output each string
  for _, str in ipairs( stringList ) do
    cecho( f "\n{bclr}|<reset>{margin}{str}<reset>" )
  end
  cecho( blankLine )
  cecho( borderLine )
end

function repeatSend( cmd_string, count )
  for c = 1, count do
    send( cmd_string, false )
  end
end

-- Clear the main screen & info window
function clearScreen()
  clearUserWindow()
  clearUserWindow( "infoWindow" )
  -- For some reason secondary windows don't clear without output
  cecho( "infoWindow", "\n" )
end
