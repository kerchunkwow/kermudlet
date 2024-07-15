-- A set to keep track of items collected via auto-gathering, like resin
gathered = {}
AlertsMuted = false

-- Automatically cast 'miracle' on the tank under predefined conditions
function triggerAutoMira()
  if SESSION ~= 1 then return end
  if pcStatus[1]["currentMana"] < 100 then return end
  local tankCondition = matches[2]

  local needMiracle = (tankCondition == "bleeding") or (tankCondition == miracleCondition)

  if needMiracle and not castingDelayed then
    send( f "cast 'miracle' {gtank}" )
    castingDelayed = true
    tempTimer( 2.8, [[castingDelayed = false]] )
    checkMiraMana()
  end
end

function checkMiraMana()
  local mu_mn = pcStatus[2]["currentMana"] + pcStatus[3]["currentMana"]
  local cl_mn = pcStatus[1]["currentMana"]

  local mira_mn = cl_mn + (mu_mn * 0.6)

  local miras = math.floor( mira_mn / 100 )

  cecho( "info", f "\n<deep_sky_blue>Mana<reset> for <dark_orange>{miras}<reset> <sea_green>miracle(s)<reset> remaining!" )
end

-- Triggered when an incoming chat message is recognized to highlight and route the message
function triggerRouteChat()
  deleteLine()

  if SESSION == 1 then
    local speaker, channel, message = matches[2], matches[3], matches[4]

    -- Check if message is nil before proceeding
    if not message then
      print( "Error: 'message' is nil." )
      return
    end
    local normalizedMessage = string.lower( message )
    -- Send a message to my phone if we get a tell or a chat mentions my name
    local mentionsMe = string.find( normalizedMessage, "k[ae]yl?e+e?" )
    mentionsMe = mentionsMe or string.find( normalizedMessage, "colin" )
    mentionsMe = mentionsMe or string.find( normalizedMessage, "crimson" )
    mentionsMe = mentionsMe or string.find( normalizedMessage, "robyn" )
    local toMe = channel == "tells" or channel == "tell" or channel == "says" or channel == "say"
    if AFK and AutoPathing and not AlertsMuted and (mentionsMe or toMe) then
      local alertString = string.format( "%s [%s]: %s", speaker, channel, message )
      sendAlert( alertString )
      triggerEmergencySoft()
    end
    local spam_strings = {"expires in", "Sanct Out"}

    for _, spam_string in ipairs( spam_strings ) do
      if string.find( message, spam_string, 1, true ) then
        return
      end
    end
    if channel == "says" then
      channel = "say"
    elseif channel == "tells" or channel == "tell" then
      channel = "whisper"

      -- Play a sound when you receive a whisper (no more than once per 10s)
      if not whisperDelayed and speaker ~= "You" then
        whisperDelayed = true
        playSoundFile( {name = "msg.wav"} )
        tempTimer( 10, [[whisperDelayed = nil]] )
      end
    end
    local chat_color = messageColors[channel] or "<sandy_brown>"
    local timeStamp = getCurrentTime()
    timeStamp = "<dim_grey>  (<dark_slate_grey>" .. timeStamp .. ")<dim_grey><reset>"
    -- Pad the message out to the length of the longest channel name (whisper == 7) for an even margin
    local padl = fill( 6 - #speaker )
    local padr = fill( 7 - #channel )

    local chat_string = "<spring_green>" ..
        speaker .. padl .. "<reset>  [" .. chat_color .. channel .. "<reset>] " .. padr .. message .. timeStamp .. "\n"

    cecho( "chat", chat_string )
  end
end

-- A room name has been captured; synchronize the map and update the status table
function triggerCaptureRoom()
  local matchedRoom = trim( matches[2] )
  if isUnique( matchedRoom ) and matchedRoom ~= CurrentRoomName then setPlayerRoom( UNIQUE_ROOMS[matchedRoom] ) end
  if SESSION == 1 then
    pcStatusRoom( 1, matchedRoom )
  else
    raiseGlobalEvent( "event_pcStatus_room", SESSION, matchedRoom )
  end
end

function autoManaTransfer()
  cle_mn, mu_mn = pcStatus[1]["currentMana"], math.max( pcStatus[2]["currentMana"], pcStatus[3]["currentMana"] )

  if cle_mn < 250 and mu_mn > 50 then
    aliasManaTransfer()
  end
end

-- Eat when we're hungry
function triggerHunger()
  -- Code to send depending on whether we have food left
  local eat_code  = f [[send( 'eat {food}', false )]]
  local warn_code = warning_calls["food"]

  -- Strings to indicate whether we have food left
  local empty_str = "does not contain"
  local have_str  = f "get a {food}"

  -- Make temporary triggers to respond accordingly when we try to pull food
  createTemporaryTrigger( "no_food_trigger", empty_str, warn_code, 3 )
  createTemporaryTrigger( "have_food_trigger", have_str, eat_code, 3 )

  send( f "get {food} {container}", false )
end

-- Drink when we're thirsty
function triggerThirst()
  -- Code to send depending on whether we have water left
  local drink_code = f [[send( 'drink {waterskin}', false )]]
  local warn_code  = warning_calls["water"]

  -- String to indicate whether we have water left
  local empty_str  = "empty already"

  -- Create a temporary trigger to warn us when we're out of water
  createTemporaryTrigger( "no_water_trigger", empty_str, warn_code, 3 )

  send( f "drink {waterskin}", false )
end

-- Take advantage of fountains around the world to top off
function triggerFountain()
  expandAlias( "all drink fountain", false )
  expandAlias( f "all fill {waterskin} fountain", false )

  -- Disable this trigger for 5 minutes
  tempDisableTrigger( "fountain", 300 )
end

-- Gather random resources; ensure your pattern captures a keyword that works for 'get'
function triggerGather()
  local resource = matches[2]
  send( f 'get {resource}', false )
  send( f 'put {resource} {container}', false )
end

-- Create a one-time temporary trigger that also expires after a certain period of time
function createTemporaryTrigger( trigger_name, pattern, code, duration )
  -- If the trigger already exists, kill it
  if temporaryTriggers[trigger_name] then
    killTrigger( temporaryTriggers[trigger_name] )
  end
  -- Create a new temporary trigger and store its reference in the table
  temporaryTriggers[trigger_name] = tempTrigger( pattern, code, 1 )

  -- Schedule the trigger to be killed after the specified duration
  tempTimer( duration, function ()
    if temporaryTriggers[trigger_name] then
      killTrigger( temporaryTriggers[trigger_name] )
      temporaryTriggers[trigger_name] = nil -- Clean up the reference
    end
  end )
end

function triggerPCActivity()
  local actor = trim( matches[2] )
  --if ALT_PC[actor] then deleteLine() end
end

-- Triggered by messages that indicate in-game inspection of items, containers, players, etc.
-- Temporarily enable the triggers needed to append item stat strings to output from the game
function triggerEnableItemQuery()
  triggerHighlightLine( [[system]] )
  tempEnableTrigger( [[EQ Stats]], 5 )
  tempEnableTrigger( [[Missing EQ]], 5 )
  tempEnableTrigger( [[Potion Affects]], 5 )
end

function triggerValidateMove()
  if cmdPending then validateCmd( "move" ) end
  displayExits( CurrentRoomNumber )
end

function triggerHighlightCritical()
  local actor = matches[2]
  local critMsg = f "<spring_green>{actor} rolls a natural <dim_grey>[<deep_pink>20<dim_grey>]<reset>"
  creplaceLine( critMsg )
end

function triggerLocateObject()
  local obj = trim( matches[2] )
  local loc = trim( matches[3] )
  -- Ignore items already owned by players
  if PlayerContainers[loc] or KnownPlayers[loc] then
    deleteLine()
    selectString( line, 1 )
    fg( "dim_grey" )
    resetFormat()
    return
  end
  selectString( obj, 1 )
  -- Sought after item
  if DesirableItems[obj] then
    fg( "gold" )
    playSoundFile( {name = "whisper.wav"} )
    -- In our database
  elseif itemData[obj] then
    fg( "dark_slate_grey" )
    -- Unrecorded item
  else
    fg( "orchid" )
  end
  selectString( loc, 1 )
  -- Check if it's a room in our map
  local rooms = searchRoom( loc, true, true )
  if next( rooms ) ~= nil then
    -- It's a room
    fg( "royal_blue" )
  else
    -- Unmapped room (or mob)
    fg( "salmon" )
  end
  resetFormat()
end

-- Triggered when a mob is incapacitated in combat; a slight variant on "death" but still needs
-- to be handled somewhat like the end of combat.
function triggerMobIncap()
  -- Use the in-game abort command to cancel any actions in progress
  send( 'abort', false )
  -- Replace the various different incap messages with a single generic highlighted message.
  deleteLine()
  cecho( f "\n<brown>{matches[2]} is mortally wounded.<reset>" )

  -- Toggle this flag temporarily so other triggers know not to react to the sudden lack of tank.
  IncapDelay = true
  onNextPrompt( function ()
    IncapDelay = false
  end )
end

-- Highlights key milestones within a specific context such as an important quest

-- Define a table called QuestHighlights which is a table of strings; each string may be associated with
-- one or both of an info string and command string; define the table with a sample entry
QuestHighlights = {
  ["You see a rat"] = {info = "A rat is here!", code = "burp"},
}
function highlightQuest( string )
  -- Highlight the triggering string in bright orange on dark purple
  selectString( string, 1 )
  bg( "dark_slate_blue" )
  fg( "goldenrod" )

  -- If the string has info associated with it, use onNextPrompt() to create a trigger with function () that will
  -- cecho that content after the next prompt.
  if QuestHighlights[string].info then
    local info = QuestHighlights[string].info
    onNextPrompt( function ()
      cecho( "\n\t<:dark_slate_blue><goldenrod>" .. {QuestHighlights[string].info} )
      resetFormat()
    end )
  end
  -- If the string has an associated command, use iout to report on the triggered command incl. the triggering text,
  -- then send the command with send().
  if QuestHighlights[string].code then
    local command = QuestHighlights[string].code
    --iout( f "<deep_pink>{cmd} triggered on <royal_blue>{string}<reset>" )
    send( QuestHighlights[string].code, true )
  end
end

-- This function should start by populating tableOfPatterns with the triggering patterns from QuestHighlights
-- It should then use permRegexTrigger() to create a trigger that calls highlightQuest(string) when triggered.
-- The passed parameter should be the string from QuestHighlights.
function createQuestHighlightTriggers()
  local tableOfPatterns = {}

  -- Populate tableOfPatterns with the keys from QuestHighlights
  for pattern, _ in pairs( QuestHighlights ) do
    table.insert( tableOfPatterns, pattern )
  end
  -- Create a single permanent trigger for all patterns
  permRegexTrigger( "Quest Highlights", "", tableOfPatterns, [[
highlightQuest( matches[1] )
]] )
end

function queueReconnect( t )
  local host, port = getConnectionInfo()
  local connectTrigger = tempTrigger( "land of GizmoMUD", function ()
    send( "n", true )
    send( "save", true )
  end, 1 )
  tempTimer( t, function ()
    connectToServer( host, port )
  end )
  tempTimer( t + 10, function ()
    killTrigger( connectTrigger )
  end )
end
