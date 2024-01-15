cecho( f '\n\t<yellow_green>lib_gui.lua<reset>: core GUI functions for windows, output, chat, etc.' )

-- Use with cecho etc. to colorize output without massively long f-strings
function ec( s, c )
  local colors = {
    err  = "orange_red",   -- Error
    dbg  = "dodger_blue",  -- Debug
    val  = "blue_violet",  -- Value
    var  = "dark_orange",  -- Variable Name
    func = "green_yellow", -- Function Name
    info = "sea_green",    -- Info/Data
  }
  local sc = colors[c] or "ivory"
  if c ~= 'func' then
    return "<" .. sc .. ">" .. s .. "<reset>"
  else
    return "<" .. sc .. ">" .. s .. "<reset>()"
  end
end

-- Standard format/highlight for chat message; pass a window name to route chat there
function chatMessage( speaker, channel, message, window )
  local de, sh, ch = "<gainsboro>", "<yellow_green>", "<maroon>"

  deleteLine()
  if window then
    cecho( window, f "\n{sh}{speaker} {de}[{ch}{channel}{de}]<reset> {message}" )
  else
    cecho( f "\n{sh}{speaker} {de}[{ch}{channel}{de}]<reset> {message}" )
    cecho( f "{ec('DB connect failed','err')} in {ec('loadAreaList','func')}" )
  end
end

-- Create and/or open a basic user window into which you can echo output; uses _G to
-- store the object in a variable of the same name
function openBasicWindow( name, title, fontFace, fontSize )
  _G[name] = Geyser.UserWindow:new( {
    name          = name,
    titleText     = title,
    font          = fontFace,
    fontSize      = fontSize,
    wrapAt        = 80,
    scrollBar     = false,
    restoreLayout = true,
  } )

  _G[name]:disableScrollBar()
  _G[name]:disableHorizontalScrollBar()
  _G[name]:disableCommandLine()
  _G[name]:clear()
end

-- Display a list of strings within a formatted "box"; supply a maxLength
-- to customize width, or let the function guess by finding the longest
-- string in your list.
function displayBox( stringList, maxLength, borderColor )
  maxLength        = maxLength or getMaxStringLength( stringList )
  local bclr       = borderColor or "<dark_slate_blue>"
  local margin     = "  "
  local boxWidth   = maxLength + 10
  local line       = string.rep( '-', boxWidth )
  local blank      = string.rep( ' ', boxWidth )
  local borderLine = f "\n{bclr}+{line}+<reset>"
  local blankLine  = f "\n{bclr}|<reset>"

  cecho( borderLine )
  cecho( blankLine )

  -- Output each string
  for _, str in ipairs( stringList ) do
    cecho( f "\n{bclr}|<reset>{margin}{str}<reset>" )
  end
  cecho( blankLine )
  cecho( borderLine )
end

-- Clear the main user window, or a sub/child window
function clearScreen()
  -- Clear the main user/console window
  clearUserWindow()

  -- For each sub/child window, clear it and then print a newline to "flush" the buffer
  local userWindows = Geyser.windows
  for _, window in ipairs( userWindows ) do
    -- The Geyser.windows list appends 'Container' to window names but still seems to be the shortest/simplest way to get a list of all windows
    local trimmedName = window:gsub( "Container", "" )
    clearUserWindow( trimmedName )
    cecho( trimmedName, "\n" )
  end
end

function gizErr( msg )
  cecho( f "\n{ec('Error','err')}: {msg}" )
end

-- Given a color (r, g, b), return a new color scaled to be d% lighter or darker
function getModifiedColor( r, g, b, d )
  -- Ensure d is clamped between -100 and 100
  d = clamp( d, -100, 100 )

  -- Calculate the scaling factor (ranging from 0 to 2)
  local scale = 1 + (d / 100)

  -- Adjust the color components and round to the nearest integer
  local newR = math.floor( clamp( r * scale, 0, 255 ) + 0.5 )
  local newG = math.floor( clamp( g * scale, 0, 255 ) + 0.5 )
  local newB = math.floor( clamp( b * scale, 0, 255 ) + 0.5 )

  return newR, newG, newB
end

--[[
GitHub Copilot, ChatGPT notes:
Collaborate on Lua 5.1 scripts for Mudlet in VSCode. Use f-strings, camelCase, UPPER_CASE constants.
Prioritize performance, optimization, and modular design. Provide debugging output with cecho.
Be critical, suggest improvements, don't apologize for errors.
Respond concisely, treat me as a coworker.
]]
