-- lib_gui.lua
-- Functions related to basic/core GUI functionality like creating basic windows and formatting output

-- Standard format/highlight for chat message; pass a window name to route chat there
function chatMessage( speaker, channel, message, window )
  local de, sh, ch = "<gainsboro>", "<yellow_green>", "<maroon>"

  deleteLine()
  if window then
    cecho( window, f "\n{sh}{speaker} {de}[{ch}{channel}{de}]<reset> {message}" )
  else
    cecho( f "\n{sh}{speaker} {de}[{ch}{channel}{de}]<reset> {message}" )
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

-- Clear the main screen & info window
function clearScreen()
  clearUserWindow()
  clearUserWindow( "infoWindow" )
  -- For some reason secondary windows don't clear without output
  cecho( "infoWindow", "\n" )
end
