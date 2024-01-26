function triggerAutoMira()
  if session ~= 1 then return end
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

function triggerRouteChat()
  deleteLine()

  if session == 1 then
    -- Assuming matches is previously defined and supposed to contain at least four elements...
    local speaker, channel, message = matches[2], matches[3], matches[4]

    -- Check if message is nil before proceeding
    if not message then
      print( "Error: 'message' is nil." )
      return
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
      if not sound_delayed and speaker ~= "You" then
        sound_delayed = true
        playSoundFile( {name = "msg.wav"} )
        tempTimer( 10, [[sound_delayed = false]] )
      end
    end
    local chat_color = msg_colors[channel] or "<sandy_brown>"

    -- Pad the message out to the length of the longest channel name (whisper == 7) for an even margin
    local padl = fill( 6 - #speaker )
    local padr = fill( 7 - #channel )

    local chat_string = "<spring_green>" ..
        speaker .. padl .. "<reset>  [" .. chat_color .. channel .. "<reset>] " .. padr .. message .. "\n"

    cecho( "chat", chat_string )
  end
end

-- A room name has been captured; synchronize the map and update the status table
function triggerCaptureRoom( room )
  if session == 1 then
    -- if isUnique and isUnique( room ) and mapQueue.isEmpty() then
    --   -- If our currentRoomNumber is out of synch, update our map location to reset it
    --   if currentRoomNumber ~= uniqueRooms[room] then
    --     updatePlayerLocation( uniqueRooms[room] )
    --   end
    -- end
    pcStatusRoom( 1, room )
  else
    raiseGlobalEvent( "event_pcStatus_room", session, room )
  end
end

function isAlternate( pc )
  return alt_pcs[pc]
end

function autoManaTransfer()
  cle_mn, mu_mn = pcStatus[1]["currentMana"], math.max( pcStatus[2]["currentMana"], pcStatus[3]["currentMana"] )

  if cle_mn < 150 and mu_mn > 50 then
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

  if session == 1 then
    send( f "get {food} stocking", false )
  else
    send( f "get {food} bag", false )
  end
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
  send( f 'get {resource}' )

  -- Keep track of what we collect just for fun
  if gathered[resource] then
    gathered[resource] = gathered[resource] + 1
  else
    gathered[resource] = 1
  end
end

function createTemporaryTrigger( trigger_name, pattern, code, duration )
  -- If the trigger already exists, kill it
  if temporary_triggers[trigger_name] then
    killTrigger( temporary_triggers[trigger_name] )
  end
  -- Create a new temporary trigger and store its reference in the table
  temporary_triggers[trigger_name] = tempTrigger( pattern, code, 1 )

  -- Schedule the trigger to be killed after the specified duration
  tempTimer( duration, function ()
    if temporary_triggers[trigger_name] then
      killTrigger( temporary_triggers[trigger_name] )
      temporary_triggers[trigger_name] = nil -- Clean up the reference
    end
  end )
end
