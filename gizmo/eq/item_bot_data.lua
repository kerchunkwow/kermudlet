-- A table to track demerits issued to players who violate bot etiquette such as
-- trying to get it to say dirty words or give away equipment belonging to others
Demerits = {}
table.load( f [[{DATA_PATH}/BotDemerits.lua]], Demerits )

-- A list of players the bot is currently ignoring due to repeated etiquette violations
Blacklist = Blacklist or {}

-- Issue a demerit to a player & write the data file
function issueDemerit( pc )
  if Demerits[pc] == nil then
    Demerits[pc] = 1
  else
    Demerits[pc] = Demerits[pc] + 1
  end
  table.save( f [[{DATA_PATH}/BotDemerits.lua]], Demerits )
end

-- Dialog for the bot to use when responding to commands and interactions;
-- responses are singular responses of which one is picked at random, while
-- sequences are multiple lines of dialog spoken in order at SpeechRate
BOT_DIALOG = {
  ["SEMICOLON"] = {
    responses = {
      "A semicolon, {Speaker}, really? Keep that up and you're going to end up on my naughty list.",
      "Did you just try to semicolon me, {Speaker}? It's not 1996 and I'm not amused.",
      "Please refrain from including semicolons in dialog while near me.",
      "Semicolon isn't even my command character, but I'm still offended that you tried it.",
    }
  },
  ["HELP"] = {
    sequence = {
      "Generic help w/o arguments this will list other things people can get help on.",
      "Like xyz."
    }
  },
  ["HELP_COMMANDS"] = {
    responses = {
      "This is help for a specific command.",
      "This specific command will do specific things.",
    }
  }
}

function checkProfanity( inputString )
  for _, pattern in ipairs( ProfanePatterns ) do
    if string.match( inputString, pattern ) then
      return true
    end
  end
  return false
end

-- Evaluate our new profanity filter for false positivies
-- Evaluate our new profanity filter for false positives
function evaluateProfanityFilter()
  MatchedText = {}
  -- For every item in Items, check shortDescription, longDescription, and keywords for any non-zero profanity
  for _, item in ipairs( Items ) do
    local short           = item.shortDescription:lower()
    local long            = item.longDescription:lower()
    local keywords        = item.keywords:lower()
    local shortSeverity   = checkProfanity( short )
    local longSeverity    = checkProfanity( long )
    local keywordSeverity = checkProfanity( keywords )

    local txt             = "<dodger_blue>"
    local pro             = "<tomato>"
    local num             = "<dark_orange>"
    local res             = "<reset>"

    if shortSeverity > 0 then
      --cecho( f "\nItem {txt}{short}{res} @{num}{shortSeverity}{res}" )
    end
    if longSeverity > 0 then
      --cecho( f "\nItem {txt}{long}{res} @{num}{longSeverity}{res}" )
    end
    if keywordSeverity > 0 then
      --cecho( f "\nItem {txt}{keywords}{res} @{num}{keywordSeverity}{res}" )
    end
  end
  -- For every mob in mobData, check areaName, keywords, and longDescription for any non-zero profanity
  for _, mob in ipairs( mobData ) do
    local area            = mob.areaName:lower()
    local keywords        = mob.keywords:lower()
    local long            = mob.longDescription:lower()
    local areaSeverity    = checkProfanity( area )
    local keywordSeverity = checkProfanity( keywords )
    local longSeverity    = checkProfanity( long )

    local txt             = "<dodger_blue>"
    local pro             = "<tomato>"
    local num             = "<dark_orange>"
    local res             = "<reset>"

    if areaSeverity > 0 then
      --cecho( f "\nMob {txt}{area}{res} @{num}{areaSeverity}{res}" )
    end
    if keywordSeverity > 0 then
      --cecho( f "\nMob {txt}{keywords}{res} @{num}{keywordSeverity}{res}" )
    end
    if longSeverity > 0 then
      --cecho( f "\nMob {txt}{long}{res} @{num}{longSeverity}{res}" )
    end
  end
  local rooms = getRooms()
  for id, name in pairs( rooms ) do
    local desc         = getRoomUserData( id, "roomDescription" )
    -- Check all room names and descriptions for non-zero profanity
    local nameSeverity = checkProfanity( name )
    local descSeverity = checkProfanity( desc )

    local txt          = "<dodger_blue>"
    local pro          = "<tomato>"
    local num          = "<dark_orange>"
    local res          = "<reset>"

    if nameSeverity > 0 then
      --cecho( f "\nRoom {txt}{name}{res} @{num}{nameSeverity}{res}" )
    end
    if descSeverity > 0 then
      --cecho( f "\nRoom {txt}{desc}{res} @{num}{descSeverity}{res}" )
    end
  end
end

-- A table containing a variety of profanity designed to test my profane language filter
-- to ensure clean & healthy interactions with players.
TestStrings = {
  "fag", "f@g", "faggot", "fagg0t", "fag g0t", "fu ck", "f*ck", "f u ck", "g ay", "gay", "h0mo", "nigger", "n1gg3r",
  "nig ger", "orgasm", "0rgasm", "penis", "p3nis", "piss", "pi$$", "twat", "tw@t"
}

function checkProfanity( inputString )
  for _, pattern in ipairs( ProfanePatterns ) do
    if string.match( inputString, pattern ) then
      --cecho( "Matched pattern: " .. pattern )
      return true
    end
  end
  return false
end

-- Define a string with a regex pattern that will match both "word" and "wo  rd" -- i.e., it accounts for the optional presence
-- of an arbitrary number of whitespace characters at a certain point.

function testFilter()
  ProfanePatterns = nil
  clearScreen()
  runLuaFile( 'gizmo/data/Profanity.lua' )
  for _, testString in ipairs( TestStrings ) do
    if not checkProfanity( testString ) then
      cecho( "\nFailed to catch profane string: <tomato>" .. testString )
    end
  end
end
