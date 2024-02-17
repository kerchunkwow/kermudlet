-- From a list of raw directions, create a Wintin-style command string
-- e.g., { "n", "n", "n", "u", "u" } = "#3 n;#2 u"
-- [TODO] Add support for both short/long direction format, ordinal directions, etc.
function createWintinString( cmdList )
  if not cmdList or #cmdList == 0 then
    cecho( "\n<dark_orange>Empty command list in createWintinString()<reset>" )
    return ""
  end
  local wintinCommands = {}
  local currentDirection = nil
  local count = 0

  for _, direction in ipairs( cmdList ) do
    -- Convert directions to their "short" versions before adding to the path
    direction = SDIR[direction]
    -- [TODO] This should really just handle any "non-direction" item in a list
    -- [TODO] Everywhere door commands are used/referenced, we need to update w/ direction like 'open door north'
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

-- Create a list of individual commands by translating/expanding a Wintin-style string
-- e.g., "#3 n;#2 u" = { "n", "n", "n", "u", "u" }
function expandWintinString( wintinString )
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

-- Use expandWintinString to execute WINTIN-style command lists
-- Kind of just a generic "do command list" function
-- [TODO] Improve/clarify how this and similar functions interact with the command queue;
-- i.e., need a system to determine which commands should be queued vs. executed immediately
function doWintin( wintinString, echo )
  echo = echo or true
  local commands = expandWintinString( wintinString )
  for _, command in ipairs( commands ) do
    nextCmd( command, echo )
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
