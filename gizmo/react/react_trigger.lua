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

  cecho( "info",
    f "\n<deep_sky_blue>Mana<reset> for <dark_orange>{miras}<reset> <sea_green>miracle(s)<reset> remaining!" )
end

-- Triggered when an incoming chat message is recognized to highlight and route the message
function triggerRouteChat()
  local speaker, channel, message = matches[2], matches[3], matches[4]
  -- Don't filter Nadja's chat; she's a special case
  if speaker == "Nadja" then return end
  deleteLine()

  if SESSION == 1 then
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
        speaker ..
        padl ..
        "<reset>  [" .. chat_color .. channel .. "<reset>] " .. padr .. message .. timeStamp .. "\n"

    cecho( "chat", chat_string )
  end
end

-- A room name has been captured; synchronize the map and update the status table
function triggerCaptureRoom()
  local matchedRoom = trim( matches[2] )
  if isUnique( matchedRoom ) and matchedRoom ~= CurrentRoomName then
    setPlayerRoom( UNIQUE_ROOMS
      [matchedRoom] )
  end
  if SESSION == 1 then
    pcStatusRoom( 1, matchedRoom )
  else
    raiseGlobalEvent( "event_pcStatus_room", SESSION, matchedRoom )
  end
end

function autoManaTransfer()
  cle_mn, mu_mn = pcStatus[1]["currentMana"],
      math.max( pcStatus[2]["currentMana"], pcStatus[3]["currentMana"] )

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
  enableTrigger( "Abbreviate Worn" )
  onNextPrompt( [[disableTrigger( "Abbreviate Worn" )]] )
  tempEnableTrigger( [[EQ Stats]], 5 )
  tempEnableTrigger( [[Missing EQ]], 5 )
  --tempEnableTrigger( [[Potion Affects]], 5 )
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

-- Triggered by lines returned from the 'locate object' spell; this function filters out items
-- carried by players and highlights others based on whether or not they have been identified in
-- the Items database.
-- Loaded items tracks items that are present in the game on a mob or in a room that have
-- not been ID'd; this can be used to assign "quests" to fetch items for the database.

-- Some tables to help keep track of which players use which containers (including containers held
-- inside other containers).
KnownContainers  = KnownContainers or {}
NestedContainers = NestedContainers or {}

InItems          = InItems or {}
CarriedItems     = CarriedItems or {}

function triggerLocateObject()
  -- If "line" contains "appears in the middle of the room", this is a false match; return
  -- without doing anything.
  if string.find( line, "appears in the middle of the room" ) then return end
  -- Increment the "index" for locating objects; this is used to remember where we are
  -- in the total list of items with a given keyword so we can string multiple locates
  -- together without losing track of the index.
  LocateIndex = (LocateIndex or 0) + 1
  cecho( f "\t({NC}{LocateIndex}{RC})" )

  -- The name (short description) of the located item
  local item = trim( matches.item )
  -- The "position" the item is in (equipped, carried, on ground)
  local pos  = trim( matches.pos )
  -- The location of the item (name of mob or room)
  local loc  = trim( matches.loc )

  if multipleIns( pos, loc ) then return end
  trackPlayerContainers( item, loc )

  -- Items in containers (including nested) or carried directly by players that are not yet identified
  -- are opportunities for player's to help expand the database.
  local inContainer = PlayerContainers[loc] or NestedContainers[loc]
  local playerHeld = inContainer or KnownPlayers[loc]
  if playerHeld and (not Items[item]) then
    selectString( item, 1 )
    fg( "medium_purple" )
    selectString( loc, 1 )
    fg( "dark_orange" )
    resetFormat()
    -- Insert the item into the Carried Items table uniquely keyed to the location
    CarriedItems[loc] = CarriedItems[loc] or {}
    if not table.contains( CarriedItems[loc], item ) then
      table.insert( CarriedItems[loc], item )
    end
    return
  elseif UnknownItems[item] or Items[item] then
    -- Ignore items that are already identified or have already been queued for identification
    deleteLine()
    return
  else
    selectString( item, 1 )
    fg( "maroon" )
    selectString( loc, 1 )
    -- Check if it's a room in our map
    local rooms = searchRoom( loc, true, true )
    ---@diagnostic disable-next-line: param-type-mismatch
    if next( rooms ) ~= nil then
      -- It's a room
      fg( "royal_blue" )
    else
      -- Unmapped room (or mob)
      fg( "indian_red" )
    end
    resetFormat()
  end
  -- If item contains any variation of the word "corpse" at any part of the string, set isCorpse true
  local isCorpse = string.find( item:lower(), "corpse" )
  -- If item contains any variation of the word "coins" at any part of the string, set isCoins true
  local isCoins = string.find( item:lower(), "coins" )
  local isLoaded = (pos == "equipped by" or pos == "carried by")
  local badLocs = {"shopkeeper", "armorer", "weaponsmith", "armourer", "someone", "corpse"}
  -- If loc contains any variation of any of the words in the badLocs list at any point in the loc string, set
  -- isBadLoc true
  local isBadLoc = false
  for _, badLoc in ipairs( badLocs ) do
    if string.find( loc:lower(), badLoc ) then
      isBadLoc = true
      break
    end
  end
  -- Add/update the item in either UnknownItems or ItemLoads tables (if they're not coins or corpses)
  if isLoaded and not isCorpse and not isCoins and not isBadLoc then
    -- If a keyword previously identified as "bad" successfully finds an item, remove it from the list
    if LocateTarget and BadLocates[LocateTarget] then
      BadLocates[LocateTarget] = nil
    end
    -- [TODO] Figure out how to handle items "in" Rooms or other locations; this will include a method
    -- to ignore or filter out static items like fountains and statues.
    addLoad( item, loc )
  end
end

-- Locate Object companion function to help keep track of player containers and the items within
function trackPlayerContainers( item, loc )
  if PlayerContainers[item] and KnownPlayers[loc] then
    -- Set loc, item as a pair in KnownContainers (this should be a table mapping players to a list
    -- of the containers they carry.
    KnownContainers[loc] = KnownContainers[loc] or {}
    if not table.contains( KnownContainers[loc], item ) then
      table.insert( KnownContainers[loc], item )
    end
  end
  -- If a container is located within a container, use KnownContainers to try and "guess" which player
  -- might be carrying the nested container
  if PlayerContainers[item] and PlayerContainers[loc] then
    -- Set loc, item as a pair in NestedContainers
    NestedContainers[loc] = NestedContainers[loc] or {}
    if not table.contains( NestedContainers[loc], item ) then
      table.insert( NestedContainers[loc], item )
    end
  end
end

-- Instances where an item is "in" a location and that location has multiple instances of "in"
-- represent an special edge case that will need to be handled separately (for now we skip it)
function multipleIns( pos, loc )
  -- If the item is "in" something, check for multiple occurrences of "in" within the location;
  -- this is indicative of a special case that will need to be handled separately.
  if pos == "in" then
    local firstIn = string.find( loc:lower(), " in " )
    if firstIn then
      local secondIn = string.find( loc:lower(), " in ", firstIn + 1 )
      if secondIn then
        selectString( line, 1 )
        fg( "ansi_magenta" )
        resetFormat()
        -- Insert the line into the InItems table for further processing
        table.insert( InItems, line )
        return true
      end
    end
  end
  return false
end

-- Triggered by "You are very confused" indicating there are more items by the same name
-- to locate; this function uses the item index to cast another locate command starting
-- at the last index.
function triggerContinueLocate()
  creplaceLine( f "<dim_grey>More {SC}{LocateTarget}<dim_grey>(s) to find...{RC}" )
  local nextIndex = LocateIndex + 1
  send( f [[cast 'locate object' {nextIndex}.{LocateTarget}]], true )
  triggerExtendLocate()
end

-- Companion function to extend the window of time in which the locate object triggers are active;
-- useful to "keep alive" the triggers when there is a delay (e.g., several lost concentrations)
function triggerExtendLocate()
  if LocateTimer then killTimer( LocateTimer ) end
  LocateTimer = tempTimer( 8, function ()
    LocateIndex = 0
    disableTrigger( [[Locate Triggers]] )
    LocateTimer = nil
  end )
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
    -- Clear the queue of un'id'd items on reconnection after reboot
    UnknownItems = {}
    send( "down", true )
    send( "west", true )
    send( "north", true )
    send( "save", true )
  end, 1 )
  tempTimer( t, function ()
    connectToServer( host, port )
  end )
  tempTimer( t + 10, function ()
    killTrigger( connectTrigger )
  end )
end
