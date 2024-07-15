--[[ item_bot.lua
-- Module to implement an in-game idnetification "bot" to identify items provided by other players;
-- Will need to implement some basic error-handling and inventory management to ensure people get
-- their items back and the bot doesn't get confsed or overwhelmed.
--]]

runLuaFile( 'gizmo/data/Profanity.lua' )
runLuaFile( 'gizmo/eq/item_bot_data.lua' )

-- Time to pause between lines of dialog and two wait before processing subsequent commands
SpeechRate   = 1.25
CommandDelay = SpeechRate * 2

-- Variables to track whether and with whom we are currently engaged in dialog; this helps
-- drive player interactions and also prevents dialog/interaction overalpping.
Speaking     = Speaking or false
Speaker      = Speaker or "Kaylee"

function botHelp( topic )
  -- If topic is nil or an empty string, set it to HELP, otherwise HELP_TOPIC
  if not topic or topic == "" then
    topic = "HELP"
  else
    topic = "HELP_" .. topic:upper()
  end
  speak( topic )
end

-- This function will "speak" lines of dialog, one line at a time delayed by SpeechRate
-- Uses tempTimer( t, code ) to speak the lines using send( f" say {line}" )
-- Uses Speaking to prevent overlapping dialogs; set a final timer beyond the last line
-- to unset Speaking.
-- This function will "speak" lines of dialog, one line at a time delayed by SpeechRate
function speak( topic )
  print( topic )
  -- If we're already speaking, ignore commands that result in speech
  if Speaking then return end
  Speaking = true
  local dialog = BOT_DIALOG[topic]
  if not dialog then
    Speaking = false
    return
  end
  -- Otherwise, speak the appropriate dialog at SpeechRate until complete
  for i, msg in ipairs( dialog ) do
    tempTimer( i * SpeechRate, function ()
      send( "say " .. msg )
    end )
  end
  -- Leave a period of "silence" before re-enabling bot speech
  tempTimer( (#dialog * SpeechRate) + CommandDelay, function ()
    Speaking = false
  end )
end

-- Called when someone says something in the same room as the bot or sends it a tell
function triggerBotChat()
  -- The presence of semicolons in user input implies an attempt to "inject" commands
  -- into the Mudlet client; ignore them outright
  local function containsSemicolon( input )
    return input:find( ";" ) ~= nil
  end
  -- Trim the initial message
  local cmd, args = parseBotMessage( trim( matches[3] ) )
  -- If either cmd or args contains a semicolon, ignore it and add the Speaker to a table
  if containsSemicolon( cmd ) or containsSemicolon( args ) then
    issueDemerit( Speaker )
    speak( "SEMICOLON" )
    return
  end
  local cmdData = BOT_COMMANDS[cmd]
  -- Ignore empty/invalid commands or missing arguments
  if not cmdData or (cmdData.argsRequired and (not args or args == "")) then
    return
  end
  -- If the bot received a valid command, remember its Speaker then execute the command
  if cmdData.func then
    cmdData.func( args )
  end
end

-- Parses the command and arguments from the message
function parseBotMessage( msg )
  local cmd, args = msg:match( "^(%S+)%s*(.*)$" )
  if cmd then
    cmd = cmd:upper()
  end
  return cmd, trim( args )
end

-- Triggered by the "give" message in game, captures the item and the player
-- who contributed.
-- Pattern: ^(\w+) gives you (.+)\.$
function triggerItemReceived()
  local player = trim( matches[2] )
  local item = trimItemName( matches[3] )
  -- If we're already working on an item, inform the contributor and queue the item for return
  if ProcessingItem then
    tempTimer( 1, function ()
      local bs = f "{BusyString}"
      cecho( bs )
    end )
  end
  if Items[item] then
    cout( "rejected" )
  else
    cout( "need keyword" )
  end
end

-- Triggers off of chat messages in-game from other players asking about whether items exist
function botItemInquiry( itm )
  itm = trimItemName( itm )
  cecho( f "Item Query Received: {itm}\n" )
  local item = Items[itm]
  local answer = nil
  if item then
    local stats = item.statsString
    local affects = item.affectString
    local flags = item.flagString
    answer = f "I found {itm}: {stats} {affects} {flags}"
  else
    answer = f "I'm afraid {itm} isn't in my catalog."
  end
  send( f "say {answer}" )
end

BOT_COMMANDS = {
  ["ID"] = {argsRequired = true, func = botItemInquiry},
  ["HELP"] = {argsRequired = false, func = botHelp},
}
