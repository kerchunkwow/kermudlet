-- Standard format/highlight for chat message; defaults to main console if you don't pass a window
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

-- Clear all user windows
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

-- Send a generic error message to the main console window
function gizError( msg )
  cecho( f "\n\t<dim_grey>[<dark_orange>err<dim_grey>]: {msg}" )
end

-- List all fonts available in Mudlet.
function listFonts()
  local availableFonts = getAvailableFonts()

  ---@diagnostic disable-next-line: param-type-mismatch
  for k, v in pairs( availableFonts ) do
    print( k )
  end
end

-- Display a list of strings within a formatted "box"; supply a maxLength
-- to customize width, or let the function guess by finding the longest
-- string in your list.
local function displayBox( stringList, maxLength, borderColor )
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

-- Given a color (r, g, b), return a new color scaled to be d% lighter or darker
local function getModifiedColor( r, g, b, d )
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
