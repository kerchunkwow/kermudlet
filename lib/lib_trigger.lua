-- Constant patterns that indicate in-game events; used by our trigger/command management
-- to issue and validate the status of commands.

-- Commands to bring minions/followers home; since we're not in the room we need to use
-- a look to validate that the minions have arrived.
TROLL_RECALL      = [[order troll recall;;look]]
SHADE_RECALL      = [[order shade recall;;look]]
TROLL_PATTERN     = [[A hulking troll lurches around, obeying its banshee master\.$]]
SHADE_PATTERN     = [[A malicious shade flickers in and out of view, obeying its banshee master\.$]]

-- Short patterns indicating minions have successfully been equipped with gear; use to create
-- a "chain" of commands that fully outfit minions.
MINION_WEAR       = [[A (?:\w+ minion|blood nymph) wears]]
MINION_HOLD       = [[A (?:\w+ minion|blood nymph) grabs]]
MINION_LIGHT      = [[A (?:\w+ minion|blood nymph) uses]]
MINION_WIELD      = [[A (?:\w+ minion|blood nymph) wields]]

-- Troll minion is in combat; we can check our own inCombat status to decide if we want to join.
TROLL_COMBAT      = [[troll minion is here, fighting]]

GET_RECALL        = f [[get recall {container}]]

SPELL_FAIL        = [[lost your concentration]]
SPELL_ABORT       = [[(?:summon enough energy|No magic here|magic has been absorbed)]]
ORDER_FAIL        = [[(?:have enough energy|is still recovering|stubbornly refuses|fails the rescue)]]
ORDER_ABORT       = [[(?:person isn't here)]]
SONG_FAIL         = [[voice cracks]]
SONG_ABORT        = [[unknown abort pattern]]

NO_ITEM           = [[You do not have that item\.$]]
NEED_SUPPLY       = [[does not contain]]
OUT_OF_RECALLS    = [[showWarning( nil, 1, 'norecall' )]]

PROMPT_PATTERN    = [[^< \d+\(\d+\) \d+\(\d+\) \d+\(\d+\) > ]]
-- Module to manage the creation and monitoring of temporary triggers created by
-- tempTrigger() or tempRegexTrigger()

-- Table mapping trigger names to their data
TemporaryTriggers = TemporaryTriggers or {}

-- A command queue for queueing requests to guarantee commands (and a flag for controlling the queue)
CommandQueue      = CommandQueue or {}
ProcessingCommand = false

-- Create a new temporary trigger, storing details in the TemporaryTriggers table
-- type: 'substring' or 'regex' to indicate trigger type
-- pattern: the pattern that will trigger execution of the code; Perl regex when type is 'regex'
-- code: the code to execute when the trigger fires; pass as function() { code } for best results
-- once: passing 1 will create a one-time trigger; nil to create a trigger that will persist until killed
function addTrigger( type, name, pattern, code, once )
  -- Ignore requests to add triggers that already exist; for now we will try to enforce unique names and forego
  -- updating triggers that exist.
  if TemporaryTriggers[name] and exists( TemporaryTriggers[name].id, 'trigger' ) > 0 then return end
  local triggerId
  -- Create the indicated trigger type using Mudlet's native temp* functions
  if type == 'substring' then
    triggerId = tempTrigger( pattern, code, once )
  elseif type == 'regex' then
    triggerId = tempRegexTrigger( pattern, code, once )
  end
  -- Create the trigger and add it to the table keyed by name
  TemporaryTriggers[name] = {
    id      = triggerId,
    type    = type,
    pattern = pattern,
    code    = code
  }
end

-- Create a trigger, then start a timer to delete it after a certain duration; useful for one-time triggers
-- that respond to things which can take a variable amount of time to occur
function addTimedTrigger( duration, type, name, pattern, code, once )
  local expiredString = f [[<dim_grey>Deleted expired trigger: {SC}{name}{RC}]]
  addTrigger( type, name, pattern, code, once )
  tempTimer( duration, function ()
    -- Attempt to delete the trigger; if it still exists, that means it expired before
    -- firing, so we can report that for info and to flush the activity queue
    if deleteTrigger( name ) then cfeedTriggers( expiredString ) end
  end )
end

-- Print a formatted list of all triggers in the TemporaryTriggers table, regardless of status
function displayTriggers()
  iout( [[{VC}TemporaryTriggers{RC}:]] )
  local triggerCount = 0
  for name, details in pairs( TemporaryTriggers ) do
    print( name, details.id )
    local status      = exists( details.id, 'trigger' ) > 0 and 'active' or 'inactive'
    local statusColor = status == 'active' and '<chartreuse>' or '<tomato>'
    local pattern     = details.pattern
    iout( [[{SC}{name}{RC} - {FC}{pattern}{RC} - {statusColor}{status}{RC}]] )
    triggerCount = triggerCount + 1
  end
  if triggerCount == 0 then
    iout( [[<dim_grey>None{RC}]] )
  end
end

-- If exists(id, 'trigger') > 0 then stop the trigger with killTrigger(id)
-- We can verify killTrigger() was successful, but the trigger status will be 'active' until
-- the next line of output is received from the MUD;
-- For now we leave these "dying" triggers in the TemporaryTriggers table assuming they will
-- later get flushed in a purge.
function deleteTrigger( name )
  local details = TemporaryTriggers[name]
  if details and exists( details.id, 'trigger' ) > 0 then
    local triggerKilled = killTrigger( details.id )
    -- Verify the trigger was killed
    if not triggerKilled then
      iout( [[{EC}killTrigger{RC}() failed for deleteTrigger({name})]] )
      return false
    end
  end
  return true
end

-- Call deleteTrigger() for every trigger in the TemporaryTriggers table
function deleteAllTriggers()
  iout( [[Deleting all tempTriggers.]] )
  for name, _ in pairs( TemporaryTriggers ) do
    deleteTrigger( name )
  end
  -- Optionally clear TemporaryTriggers here if deleteTrigger doesn't
  --TemporaryTriggers = {}
end

-- Remove any trigger in TemporaryTriggers for which exists(id, 'trigger') == 0
-- Will clean up any one-time triggers that have fired, or triggers that were killed by deteleTrigger()
function purgeInactiveTriggers()
  for name, details in pairs( TemporaryTriggers ) do
    if exists( details.id, 'trigger' ) == 0 then
      iout( "Purged inactive trigger: {SC}{name}{RC}" )
      TemporaryTriggers[name] = nil
    end
  end
end

-- A full abort and reset of the temporary trigger system; useful for "oh shit" situations in game when
-- we want to prevent unnecessary commands interfering with our ability to flee or recall from combat
function cancelAndClearTriggers()
  deleteAllTriggers()
  -- Feed a line of text to the MUD for visibility but mostly to flush the trigger queue
  cfeedTriggers( f "<orange_red>Killing all temporary triggers and clearing command queue.{RC}" )
  -- Purge the (now inactive) triggers
  purgeInactiveTriggers()
  -- Cancel any pending commands
  CommandQueue = {}
  ProcessingCommand = false
end

TimeoutTimer = TimeoutTimer or nil
CommandTimer = CommandTimer or nil
-- A function intended to guarantee the success of a command (or its appropriate cancellation) by
-- issuing the command repeatedly until a success message or abort message is encountered; frequency
-- controls the rate at which the command is repeated to avoid "spamming" the game client; this function
-- is intended to guarantee one command at a time to avoid trigger conflicts or a command "backlog" which
-- can lead to an unresponsive player character (dangerous); if called while a command is in process,
-- the command will be queued to be processed after the current command completes.
function guaranteeCommand( cmd, successPattern, failPattern, abortPattern, frequency, successDelay )
  -- The rate at which abilities are retried upon failure; default to 2s
  frequency = frequency or 2
  -- Account for "command lag" by issuing a delay for abilities that confer long delays
  successDelay = successDelay or 0
  -- If no response condition is observed after 3x frequency, abort the command,
  -- This accounts for scenarios where the players is not around to observe the result, such as recalling
  local timeout = frequency * 3

  -- If we're already processing a command; queue this one until the current one succeeds or aborts,
  -- otherwise set ProcessingCommand so subsequent commands are queued
  if ProcessingCommand then
    table.insert( CommandQueue, {cmd, successPattern, failPattern, abortPattern, frequency, successDelay} )
    return
  else
    ProcessingCommand = true
  end
  -- Names for the three triggers required to guarantee the command's success (or appropriate cancellation)
  -- Use the current time to generate unique names for each trigger
  local timeStamp   = getStopWatchTime( "timer" )
  local successName = f [[cmd_success_{timeStamp}]]
  local failName    = f [[cmd_failure_{timeStamp}]]
  local abortName   = f [[cmd_abort_{timeStamp}]]

  -- Various status strings which can be enabled for debugging purposes
  -- local startInfo   = f "{EC}Q{RC}// <yellow_green>Start{RC}: {FC}{cmd}{RC}"
  -- local failInfo1   = f "{EC}Q{RC}// <orange>Fail Start{RC}:  {FC}{cmd}{RC}"
  -- local failInfo2   = f "{EC}Q{RC}// <orange>Fail Next{RC}:   {FC}{cmd}{RC}"
  -- local abortInfo   = f "{EC}Q{RC}// <tomato>Abort{RC}:       {FC}{cmd}{RC}"
  -- local successInfo = f "{EC}Q{RC}// <chartreuse>Success{RC}: {FC}{cmd}{RC}"
  local timeoutInfo = f "{EC}Q{RC}// <ansi_yellow>TIMEOUT{RC}: {FC}{cmd}{RC}"
  --iout( startInfo )

  local function deleteTriggersAndTimer()
    deleteTrigger( successName )
    deleteTrigger( failName )
    deleteTrigger( abortName )
    if TimeoutTimer then killTimer( TimeoutTimer ) end
    if CommandTimer then killTimer( CommandTimer ) end
  end

  local timeoutFunc   = function ()
    iout( timeoutInfo )
    deleteTriggersAndTimer()
    -- Process the next command after a frequency delay
    tempTimer( frequency, function ()
      ProcessingCommand = false
      processCommandQueue()
    end )
  end

  -- The function called upon failure should repeat the issued command after the specified frequency
  local failRetryFunc = function ()
    -- Kill the timeout timer since we've received a response
    killTimer( TimeoutTimer )
    -- After frequency, restart the timeout and re-issue the command
    CommandTimer = tempTimer( frequency, function ()
      TimeoutTimer = tempTimer( timeout, timeoutFunc )
      send( cmd, true )
    end )
  end

  -- Abort means the command is not possible, so give up and delete fail/success triggers and pending timers
  -- Abort is a one-time trigger and will delete itself
  local abortFunc     = function ()
    deleteTriggersAndTimer()
    -- Process the next command after a frequency delay
    tempTimer( frequency, function ()
      ProcessingCommand = false
      processCommandQueue()
    end )
  end

  -- We've completed the action successfully, so delete the fail/abort triggers and pending timers
  -- Success is a one-time trigger and will delete itself
  local successFunc   = function ()
    deleteTriggersAndTimer()
    -- Process the next command after any successDelay (default 0)
    tempTimer( successDelay, function ()
      ProcessingCommand = false
      processCommandQueue()
    end )
  end

  -- One time success trigger
  addTrigger( 'regex', successName, successPattern, successFunc, 1 )
  -- Persistent failure trigger (repeat command)
  addTrigger( 'regex', failName, failPattern, failRetryFunc )
  -- One time abort trigger (give up)
  addTrigger( 'regex', abortName, abortPattern, abortFunc, 1 )

  -- Initiate the timeout timer, then attempt the command
  TimeoutTimer = tempTimer( timeout, timeoutFunc )
  send( cmd, true )
end

-- Called when a command in progress suceeds or is aborted; checks for pending commands and sends
-- the oldest command (FIFO)
function processCommandQueue()
  if #CommandQueue > 0 then
    local command = table.remove( CommandQueue, 1 )
    guaranteeCommand( unpack( command ) )
  else
    ProcessingCommand = false
  end
end

--[[
Helper functions to implement specialized commands and triggers for specific, predictable game actions
--]]

-- Guarantee a song; song delays are very long, so delay 6.5s on success
function guaranteeSong( song, successPattern )
  local songCmd = f [[song '{song}']]
  guaranteeCommand( songCmd, successPattern, SONG_FAIL, SONG_ABORT, 1, 6.5 )
end

-- All "next prompt" triggers follow the same format so here's a helper function
function onNextPrompt( code )
  addTrigger( 'regex', 'next_prompt', PROMPT_PATTERN, code, 1 )
end

-- Spell casting follows a predictable pattern, so we can use a helper function to guarantee spell casting
function guaranteeCast( spell, successPattern )
  local castCmd = f [[cast '{spell}']]
  successPattern = successPattern or [[Ok\.$]]
  guaranteeCommand( castCmd, successPattern, SPELL_FAIL, SPELL_ABORT, 1 )
end

-- Issuing minions orders has a predictable pattern, so we can use a helper function to guarantee orders
function guaranteeOrder( minion, order, successPattern )
  local orderCmd = f [[order {minion} {order}]]
  guaranteeCommand( orderCmd, successPattern, ORDER_FAIL, ORDER_ABORT )
end

function crawlKillTriggers()
  local highestID = tempTrigger( [[dummy]], [[dummy]], 1 )
  cecho( f "\n<dim_grey>Killing all triggers between {FirstTempTrigger} and {highestID}{RC}" )
  for i = FirstTempTrigger, highestID do
    local killMsg = f "\n<dim_grey>Killing: {NC}{i}<reset>"
    cecho( killMsg )
    killTrigger( i )
  end
end

-- Generic function to limit the rate at which a command or task is executed; useful to limit repeated triggers
-- to events that can sometimes occur in rapid succession (e.g., the death of a mob).
-- For example, to ensure you only doTask() once every 5 seconds:
-- if not throttle( 'doTask', 5 ) then doTask() end
ThrottleFlags = ThrottleFlags or {}
function throttle( flag, delay )
  -- A task by this name is being throttled.
  if ThrottleFlags[flag] then
    return true
  else
    -- No task by this name is throttled; set a flag and start a timer to unset it.
    ThrottleFlags[flag] = true
    tempTimer( delay, function ()
      ThrottleFlags[flag] = nil
    end )
  end
end
