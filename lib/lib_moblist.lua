cecho( f '\n\t<yellow_green>lib_moblist.lua<reset>: functions to maintain & update a list of mobs w/ counts' )

mobList = {
  ["A Yeti stares at your flesh with a hunger."] = {count = 1, color = "<maroon>"},
}

-- Update the mobList; pass modify true to insert/remove strings
function updateMobList( str, number, modify )
  -- By default, don't add or remove any strings
  modify = modify or false

  if mobList[str] then
    -- Update the mob's count value
    mobList[str].count = mobList[str].count + number
    -- If modify is true and count falls below 0, remove the mob
    if modify and mobList[str].count <= 0 then
      mobList[str] = nil
    end
  else
    -- If the mob isn't in the table, add it when modify is true
    if modify and number > 0 then
      mobList[str] = {count = number}
    else
      cecho( f "Mob {str} not found in mobList for updateMobList()" )
    end
  end
end

-- Fetch a mob's count and color from the mobList
function getMobListData( str )
  if mobList[str] then
    return mobList[str].count, mobList[str].color
  else
    cecho( f "Mob {str} not found in mobList for getMobListData()" )
    return nil, nil
  end
end

-- Change the color value of a mob in the mobList
function setMobColor( str, newColor )
  if mobList[str] then
    mobList[str].color = newColor
  else
    cecho( f "Mob {str} not found in mobList for updateColor()" )
  end
end

-- Print the mobList
function printMobList()
  for str, info in pairs( mobList ) do
    cecho( f "Mob: <orange>{str}<reset>, Count: <orange>{info.count}<reset>, Color: <orange>{info.color}<reset>\n" )
  end
end

-- Reset/initialize the mobList
function resetMobList()
  for str in pairs( mobList ) do
    mobList[str].count = 0
  end
end

--[[
GitHub Copilot, ChatGPT notes:
Collaborate on Lua 5.1 scripts for Mudlet in VSCode. Use f-strings, camelCase, UPPER_CASE constants.
Prioritize performance, optimization, and modular design. Provide debugging output with cecho.
Be critical, suggest improvements, don't apologize for errors.
Respond concisely, treat me as a coworker.
]]
