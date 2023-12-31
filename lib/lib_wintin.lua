cecho( f '\n\t<yellow_green>lib_string.lua<reset>: functions to translate & emulate WINTIN-style commands' )

-- Expand #WINTIN-style command strings
-- e.g., "#3 n;#2 u" = { "n", "n", "n", "u", "u" }
function expandWintin( wintinString )
  local commands = {}
  display( wintinString )
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

-- Parse a WINTIN-style action string into its component parts
-- "#ACTION {pattern} {command} {priority}" = { "pattern", "command", "priority" }
function parseWintinAction( actionString )
  local pattern, command, priority = "", "", ""
  local section = 1
  local braceDepth = 0
  local temp = ""

  for i = 1, #actionString do
    local char = actionString:sub( i, i )

    -- Do some ridiculous bullshit to deal with nested braces
    if char == "{" then
      braceDepth = braceDepth + 1
      if braceDepth == 1 then
        -- Open section
        temp = ""
      else
        temp = temp .. char
      end
    elseif char == "}" then
      braceDepth = braceDepth - 1
      if braceDepth == 0 then
        -- Close section
        if section == 1 then
          pattern = temp
        elseif section == 2 then
          command = temp
        elseif section == 3 then
          priority = temp
        end
        section = section + 1
      else
        temp = temp .. char
      end
    elseif braceDepth > 0 then
      temp = temp .. char
    end
  end
  return trim( pattern ), trim( command ), trim( priority )
end

-- Function to convert a list of directions into a WINTIN-style command string
function createWintin( directionList )
  local function shortDirection( direction )
    local shortMap = {
      north = "n",
      south = "s",
      east = "e",
      west = "w",
      up = "u",
      down = "d"
    }
    return shortMap[direction] or direction
  end

  if not directionList or #directionList == 0 then
    return ""
  end
  local wintinCommand = ""
  local currentDirection = shortDirection( directionList[1] )
  local count = 0

  for i, direction in ipairs( directionList ) do
    local shortDir = shortDirection( direction )
    if shortDir == currentDirection then
      count = count + 1
    else
      -- Append the previous direction and its count to the command string
      wintinCommand = wintinCommand .. (count > 1 and "#" .. count .. " " or "") .. currentDirection .. ";"
      -- Reset for the new direction
      currentDirection = shortDir
      count = 1
    end
  end
  -- Append the last direction and its count
  wintinCommand = wintinCommand .. (count > 1 and "#" .. count .. " " or "") .. currentDirection

  return wintinCommand
end

function importWintinActions()
  local testActions = {}
  -- Make an empty group to hold the imported triggers
  permRegexTrigger( "Imported", "", {"^#"}, "" )

  local triggerCounter = 1

  for _, actionString in ipairs( testActions ) do
    local triggerName = "Imported" .. triggerCounter
    local pattern, command, priority = parseWintinAction( actionString )

    command = f [[print("{command}")]]

    if isRegex( pattern ) then
      permRegexTrigger( triggerName, "Imported", {pattern}, command )
    else
      permSubstringTrigger( triggerName, "Imported", {pattern}, command )
    end
    triggerCounter = triggerCounter + 1
  end
end
