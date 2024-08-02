-- This table defines all of the dialog the item identification bot can speak; it is arranged
-- by topic and can be one of two varieties:
-- message: Multiple single-line messages which are chosen at random for variety
-- speech: Multiple lines of dialog which are spoken in sequence at a predefined rate

-- Define a limit to the number of items the bot will report stats on at any one time
MAX_QUERY  = 25

-- How long to wait before beginning to speak and between separate lines of dialog
SpeechRate = 0.5

-- Prevent overlapping speeches
Speaking   = false

-- Who is currently speaking to the bot
Speaker    = Speaker or nil

runLuaFile( "gizmo/data/bot_dialog.lua" )

function speak( topic, channel, recipient )
  local dialog = BOT_DIALOG[topic]

  -- Catchall for invalid attempts to speak
  if not dialog or (channel == "tell" and not recipient) or Speaking then
    cecho( f "{GDERR} Ignoring speak( {topic}, {channel}, {recipient} )" )
    return
  end
  local function speakLater( t, cmd )
    tempTimer( t, function ()
      send( cmd )
    end )
  end
  CI                = f "`g{CurrentItem}`q"   -- Current item the bot is examining
  CP                = f "`c{CurrentPlayer}`q" -- Current player the bot is interacting with
  -- Set the default channel if needed
  channel           = channel or "say"
  local isTell      = (channel == "tell" and recipient)
  local completeMsg = f "{GDOK} Finished speaking about {topic}"
  Speaking          = true

  if dialog.messages then
    -- For single-line messages, select one at random and send it after a pause
    local message = dialog.messages[math.random( #dialog.messages )]
    message       = f( message )
    local cmd     = f "send( [[tell {recipient} {message}]] )" and isTell or
        f "send( [[{channel} {message}]] )"
    tempTimer( SpeechRate, cmd )
    Speaking = false
  elseif dialog.speech then
    -- For speeches, queue each line of dialog with SpeechRate delays between each
    for i, message in ipairs( dialog.speech ) do
      message = f( message )
      local cmd = f "send( [[tell {recipient} {message}]] )" and isTell or
          f "send( [[{channel} {message}]] )"
      tempTimer( SpeechRate * i, cmd )
    end
    -- Queue a final timer to reset Speaking
    tempTimer( #dialog.speech * SpeechRate + SpeechRate, function ()
      Speaking = false
      cecho( completeMsg )
    end )
  end
end

-- Called when someone says something in the same room as the bot or sends it a tell
-- Pattern: ^(\w+) says 'GD\s*(.+)'$
function triggerBotChat()
  -- Trim the initial message
  Speaker       = trim( matches[2] )
  local cmd     = string.upper( trim( matches[3] ) )
  local args    = trim( matches[4] )
  local cmdData = BOT_COMMANDS[cmd]
  -- Ignore messages that:
  -- 1. Don't start with a valid command
  -- 2. Are received when we're already engaged with another Speaker
  -- 3. Are a valid command but missing required arguments
  if (not cmdData) or (cmdData.argsRequired and (not args or args == "")) then
    return
  end
  -- The presence of semicolons in user input implies an attempt to "inject" commands
  -- into the Mudlet client; ignore them outright
  local function containsSemicolon( input )
    return input:find( ";" ) ~= nil
  end
  -- If args contain a semicolon, ignore it
  if args and containsSemicolon( args ) then
    speak( "SEMICOLON" )
    return
  end
  -- Check for profanity in the input and respond accordingly
  if args and checkProfanity( string.lower( args ) ) then
    speak( "PROFANITY" )
    return
  end
  -- If the bot received a valid command, remember its Speaker then execute the command
  if cmdData.func then
    cmdData.func( args )
  end
end

-- Parses the command and arguments from the message
function parseBotChat( msg )
  local cmd, args = msg:match( "^(%S+)%s*(.*)$" )
  if cmd then
    cmd = cmd:upper()
  end
  return cmd, trim( args )
end

-- Respond to HELP commands which may be a general request or related to a specific command
function respondHelp( topic )
  -- If topic is nil or an empty string, set it to HELP, otherwise HELP_TOPIC
  if not topic or topic == "" then
    topic = "HELP"
  else
    topic = "HELP_" .. topic:upper()
  end
  speak( topic )
end

-- Function to speak the stats of a given item by its name
function speakItemStats( itemName )
  local item = Items[itemName]
  if not item then
    speak( "UNKNOWN_ITEM" )
    return
  end
  local itm   = itemName
  -- For each section of an item's ID message that exists, interpolate the global format string into a portion
  -- of the response msg.
  local stats = item.statsString and f( STS ) or ""
  echo( f "\nStats:{stats}" )
  local affects = item.affectString and f( AFF ) or ""
  echo( f "\nAffects:{affects}" )
  local flags = item.flagString and f( FLG ) or ""
  echo( f "\nFlags:{flags}" )
  local msg  = f( IDS )

  -- If we know where the item loads, get a list of the mob names who drop it
  local mobs = getItemMobList( itemName )
  if mobs and #mobs > 0 then
    msg = msg .. f " [{mobs}]"
  end
  -- CLONE_TAG & SPEC_TAG are non-ASCII; replace them with printable versions for game chat
  msg = string.gsub( msg, CLONE_TAG, CLONE_TAG_A )
  msg = string.gsub( msg, SPEC_TAG, SPEC_TAG_A )

  cecho( f( "{GDOK} ID Query: {SC}{itemName}{RC}" ) )

  echo( msg .. "\n" )
  msg = trimCondense( msg )
  echo( msg .. "\n" )
  msg = f( "say {msg}" )
  send( msg )
end

-- Response to the "ID" command, which queries the bot for information on an item
function respondItemInquiry( searchString )
  -- Make sure the string doesn't include any noise like (glowing) or (humming) flags
  searchString = trimItemName( searchString )
  -- Find all items that match the string
  local matchingItems = getMatchingItemNames( searchString )

  cecho( f "\nItem Query Received: {searchString}\n" )

  -- Report the stats of items matching the query string, stopping after MAX_QUERY
  if #matchingItems > MAX_QUERY then
    speak( "QUERY_LIMIT" )
  end
  if #matchingItems > 0 then
    for i = 1, math.min( #matchingItems, MAX_QUERY ) do
      tempTimer( i * SpeechRate, function ()
        speakItemStats( matchingItems[i] )
      end )
    end
  else
    speak( "UNKNOWN_ITEM" )
  end
end

-- Pass a string through a simple profanity filter to see if it should be excluded from output
function checkProfanity( inputString )
  for _, pattern in ipairs( ProfanePatterns ) do
    if string.match( inputString, pattern ) then
      return true
    end
  end
  return false
end

-- Occasionally as players arrive in the room, the bot will encourage them to contribute new items
-- Hold the last time the bot inquired so it doesn't get annoying/spammy
-- Occasionally as players arrive in the room, the bot will encourage them to contribute new items
-- Hold the last time the bot inquired so it doesn't get annoying/spammy
LastRequest = LastRequest or getStopWatchTime( "timer" )

function triggerInquireContribute()
  local now = getStopWatchTime( "timer" )
  if now - LastRequest >= 1200 then -- 1200 seconds = 20 minutes
    speak( "INQUIRE" )
    LastRequest = now
  end
end

-- This function examines the Items table and credits all of the contributors with addings items to the db
function countContributors()
  -- Table to hold the contributors & counts
  local contributors  = {}
  -- Count of total contributions for verification purposes
  local contributions = 0
  -- Keep track of the longest contributor name for formatting purposes
  local long          = 0
  -- For each item in the Items table, add the contributor to the contributors table
  -- Player names key to contribution counts; start with 1 and increment for each new item
  for _, item in pairs( Items ) do
    if not item.contributor then
      item.contributor = "Kaylee"
    end
    long = math.max( long, #item.contributor )
    contributions = contributions + 1
    if not contributors[item.contributor] then
      contributors[item.contributor] = 1
    else
      contributors[item.contributor] = contributors[item.contributor] + 1
    end
  end
  displayFramedTable( f "     <orchid>Contributors{RC}     ", contributors )
end

BOT_COMMANDS = {
  ["ID"] = {argsRequired = true, func = respondItemInquiry},
  ["FETCH"] = {argsRequired = false, func = requestLoad},
}
