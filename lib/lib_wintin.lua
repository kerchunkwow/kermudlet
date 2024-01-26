-- From a list of raw directions, create a Wintin-style command string
-- e.g., { "n", "n", "n", "u", "u" } = "#3 n;#2 u"
-- [TODO] Add support for both short/long direction format, ordinal directions, etc.
function createWintin( directionList )
  if not directionList or #directionList == 0 then
    return ""
  end
  local wintinCommands = {}
  local currentDirection = nil
  local count = 0

  for _, direction in ipairs( directionList ) do
    -- Convert directions to their "short" versions before adding to the path
    direction = SDIR[direction]
    -- [TODO] This should really just handle any "non-direction" item in a list
    if direction:match( "^open [%w]+" ) or direction:match( "^close [%w]+" ) or direction:match( "^unlock [%w]+" ) then
      if currentDirection then
        table.insert( wintinCommands, (count > 1 and "#" .. count .. " " or "") .. currentDirection )
      end
      table.insert( wintinCommands, direction )
      currentDirection = nil
      count = 0
    else
      if direction == currentDirection then
        count = count + 1
      else
        if currentDirection then
          table.insert( wintinCommands, (count > 1 and "#" .. count .. " " or "") .. currentDirection )
        end
        currentDirection = direction
        count = 1
      end
    end
  end
  if currentDirection then
    table.insert( wintinCommands, (count > 1 and "#" .. count .. " " or "") .. currentDirection )
  end
  return table.concat( wintinCommands, ";" )
end

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
-- Kind of just a generic "do command list" function
function doWintin( wintinString, echo )
  echo = echo or true
  local commands = expandWintin( wintinString )
  for _, command in ipairs( commands ) do
    send( command, echo )
  end
end

-- Parse a WINTIN-style action/trigger definition into a table of its components
-- "#ACTION {pattern} {command} {priority}" = { "pattern", "command", "priorisy" }
-- Intended as part of a solution for importing WINTIN/TINTIN files into a Mudlet project
local function parseWintinAction( actionString )
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
