--[[ item_bot.lua
-- Module to implement an in-game idnetification "bot" to identify items provided by other players;
-- Will need to implement some basic error-handling and inventory management to ensure people get
-- their items back and the bot doesn't get confsed or overwhelmed.
--]]

runLuaFile( 'gizmo/data/Profanity.lua' )
runLuaFile( 'gizmo/eq/item_bot_data.lua' )

-- Time to pause between lines of dialog and two wait before processing subsequent commands
SpeechRate   = 0.25
CommandDelay = SpeechRate * 0

-- Variables to track whether and with whom we are currently engaged in dialog; this helps
-- drive player interactions and also prevents dialog/interaction overalpping.
Speaking     = Speaking or false
Speaker      = nil

-- Dialog for the bot to use when responding to commands and interactions;
-- responses are singular responses of which one is picked at random, while
-- sequences are multiple lines of dialog spoken in order at SpeechRate
BOT_DIALOG   = {
  ["SEMICOLON"] = {
    responses = {
      "A semicolon, {Speaker}, really? Don't try that again. [`i+Demerit`q]",
      "Did you just try to semicolon me, {Speaker}? It's not 1996 and I'm not amused. [`i+Demerit`q]",
      "Please refrain from including semicolons in our dialogs. [`i+Demerit`q]",
      "Semicolon isn't even my command character, but I'm still offended that you tried it. [`i+Demerit`q]",
    }
  },
  ["PROFANITY"] = {
    responses = {
      "I'm not sure that's language you should be using, {Speaker}. [`i+Demerit`q]",
      "Why, I never. Do you kiss my mother with that mouth? [`i+Demerit`q]",
      "How rude. I'm not going to repeat that, {Speaker}. [`i+Demerit`q]",
    }
  },
  ["HELP"] = {
    sequence = {
      "Thanks for your interest in `fThe Archive`q, {Speaker}.",
      "We're just getting started, so our services are somewhat limited at the moment.",
      "For instance, I'll only work with people in the room. Someday soon I'll respond to `dtells`q and `fgossip`q.",
      "If you ask me to `gID <item>`q, I'll tell you what I know about it.",
      --"If I'm holding an item of yours and you need it back, try RETURN <keyword>.",
      "For details on any of our services, use `gHELP <command>`q.",
    }
  },
  ["HELP_ID"] = {
    responses = {
      "Once I've added an item to The Archive, I can look up its stats with the ID command.",
      "Until I improve my filing system, you'll need to provide an exact short description.",
      "Core stats will appear in `cgreen`q, permanent affects in `eblue`q, and anti-flags in `bred`q.",
    }
  },
  ["BUSY_RECEIVE"] = {
    responses = {
      "I'm already working on an item, {Speaker}. Please wait a moment.",
      "I'm currently processing an item, {Speaker}. Please be patient.",
    }
  },
  ["REQUEST_KEYWORD"] = {
    responses = {
      "I guess you'll be wanting me to identify this. Just say KEYWORD <word>.",
    }
  }
}

-- This function will "speak" lines of dialog, one line at a time delayed by SpeechRate
-- Uses tempTimer( t, code ) to speak the lines using send( f" say {line}" )
-- Uses Speaking to prevent overlapping dialogs; set a final timer beyond the last line
-- to unset Speaking.
function speak( topic )
  -- If we're already speaking, ignore commands that result in speech
  if Speaking then return end
  Speaking = true
  local dialog = BOT_DIALOG[topic]
  if not dialog then
    Speaking = false
    return
  end
  if dialog.responses then
    -- Pick a random response
    local response = dialog.responses[math.random( #dialog.responses )]
    response = f( response )
    tempTimer( SpeechRate, function ()
      send( "say " .. response )
      -- Re-enable bot speech after the command delay
      tempTimer( CommandDelay, function ()
        Speaking = false
      end )
    end )
  elseif dialog.sequence then
    -- Speak each line in sequence
    for i, msg in ipairs( dialog.sequence ) do
      tempTimer( i * SpeechRate, function ()
        send( "say " .. f( msg ) )
      end )
    end
    -- Leave a period of "silence" before re-enabling bot speech
    tempTimer( (#dialog.sequence * SpeechRate) + CommandDelay, function ()
      Speaking = false
    end )
  else
    Speaking = false
  end
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

-- Response to the "ID" command, which queries the bot for information on an item
function respondItemInquiry( itm )
  itm = trimItemName( itm )
  cecho( f "Item Query Received: {itm}\n" )
  local item = Items[itm]
  local answer = nil
  if item then
    local stats = item.statsString
    local affects = item.affectString
    local flags = item.flagString
    speak( "ID_SUCCESS" )
    answer = f "`g{itm}`h `c{stats} `e{affects} `b{flags}`h"
  else
    answer = f "I can't seem to find `g{itm}`h in The Archive."
  end
  send( f "say {answer}" )
end

-- Called when someone says something in the same room as the bot or sends it a tell
function triggerBotChat()
  -- Trim the initial message
  local cmd, args = parseBotChat( trim( matches[3] ) )

  -- Don't respond to messages that don't begin with a valid recognized command
  local cmdData = BOT_COMMANDS[cmd]

  -- Ignore messages that:
  -- 1. Don't start with a valid command
  -- 2. Are received when we're already engaged with another Speaker
  -- 3. Are a valid command but missing required arguments
  if (not cmdData) or Speaker or (cmdData.argsRequired and (not args or args == "")) then
    return
  end
  -- We know it's a valid command, set Speaker to the player who issued it
  Speaker = trim( matches[2] )
  print( f "Speaker: {Speaker}" )

  -- The presence of semicolons in user input implies an attempt to "inject" commands
  -- into the Mudlet client; ignore them outright
  local function containsSemicolon( input )
    return input:find( ";" ) ~= nil
  end

  -- If args contain a semicolon, ignore it and add the Speaker to a table
  if containsSemicolon( args ) then
    issueDemerit( Speaker )
    speak( "SEMICOLON" )
    return
  end
  -- Check for profanity in the input and respond accordingly
  if checkProfanity( string.lower( args ) ) then
    issueDemerit( Speaker )
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

-- Triggered by the "give" message in game, captures the item and the player
-- who contributed.
-- Pattern: ^(\w+) gives you (.+)\.$
function triggerItemReceived()
  local player = trim( matches[2] )
  local item = trimItemName( matches[3] )
  -- If we're already working on an item, inform the contributor and queue the item for return
  if ProcessingItem then
    speak( "BUSY_RECEIVE" )
  end
  if Items[item] then
    cout( "rejected" )
  else
    cout( "need keyword" )
  end
end

BOT_COMMANDS = {
  ["ID"] = {argsRequired = true, func = respondItemInquiry},
  ["HELP"] = {argsRequired = false, func = respondHelp},
}
