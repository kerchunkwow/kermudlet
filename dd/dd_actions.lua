-- Clear the main screen & info window
function clearScreen()
  clearUserWindow()
  clearUserWindow( "infoWindow" )
  -- For some reason secondary windows don't clear without output
  cecho( "infoWindow", "\n" )
end

function recite_recall()
  -- Check container if we didn't have a recall
  missingRecallTrigger = tempTrigger( "do not have that", [[sendAll('get recall skin', 'recite recall']], 1 )
  -- Restock recalls if we don't have one to re-hold
  restockRecallTrigger = tempTrigger( "skin does not contain the recall", [[restockRecall()]], 1 )

  send( 'recite recall' )
  tempTimer( 2, [[killTrigger( missingRecallTrigger )]] )
  tempTimer( 2, [[killTrigger( restockRecallTrigger )]] )
end

function restockRecall()
  send( 'w;s;w;w', false )
  for r = 1, 10 do
    send( 'buy recall' )
  end
  sendAll( 'hold recall', 'put all.recall skin' )
  sendAll( 'e;n;e;e', false )
end

-- Do a random command (useful for getting prompts between ticks)
function random_command()
  local idle_commands = { 'sc', 'inv', 'eq', 'time', 'realtime', 'save' }
  local random_command = idle_commands[math.random( #idle_commands )]
  send( random_command )
end

-- Use up some dese sweet cure serious scrolls
function heal_self()
  send( 'get serious skin;rec serious;get serious skin;rec serious', false )
end

-- Take advantage of a water source in game by refilling & drinking
function water_source( source )
  cecho( "info", f "\nWater source: {source}" )
end

function triggerMeleeHighlight()
  local damageString = matches[2]
  local firstWord = damageString:match( "(%w+)" )

  -- Dim the line, then highlight the juicy bits based on the first word
  selectString( line, 1 )
  fg( "dim_grey" )
  selectString( damageString, 1 )
  fg( meleeColor[firstWord] )
  resetFormat()
end
