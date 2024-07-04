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

-- List all fonts available in Mudlet.
function listFonts()
  local availableFonts = getAvailableFonts()

  ---@diagnostic disable-next-line: param-type-mismatch
  for k, v in pairs( availableFonts ) do
    print( k )
  end
end

FULL_HP_COLOR  = {125, 200, 25}
EMPTY_HP_COLOR = {200, 50, 25}
FULL_MN_COLOR  = {25, 100, 200}
EMPTY_MN_COLOR = {5, 25, 50}
-- Given max and min color values and a ratio, return a color linearly interpolated between the two
function interpolateColor( highColor, lowColor, ratio )
  local r1, g1, b1 = unpack( lowColor )
  local r2, g2, b2 = unpack( highColor )

  -- Calculate the interpolation based on the adjusted logic
  local r = math.floor( r1 + (r2 - r1) * ratio + 0.5 )
  local g = math.floor( g1 + (g2 - g1) * ratio + 0.5 )
  local b = math.floor( b1 + (b2 - b1) * ratio + 0.5 )

  return r, g, b
end

-- Print a horizontal divider to the main console of length n in color c; use
-- Gizmo standard format of dashes flanked by plus signs.
function hrule( n, c )
  -- Add <> characters here so they don't have to be included in function calls
  if not c then c = "<black>" end
  local fi = fill( n, '-', c )
  local line = f "\n{c}+{fi}{c}+<reset>"
  cecho( line )
end

-- Create and/or open a basic user window into which you can echo output; uses _G to
-- store the object in a variable of the same name
local function openBasicWindow( name, title, fontFace, fontSize )
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

-- Given an (r, g, b) set, return one d% darker or lighter
local function getModifiedColor( r, g, b, d )
  d = clamp( d, -100, 100 )
  local scale = 1 + (d / 100)

  -- Adjust the color components and round to the nearest integer
  local newR = math.floor( clamp( r * scale, 0, 255 ) + 0.5 )
  local newG = math.floor( clamp( g * scale, 0, 255 ) + 0.5 )
  local newB = math.floor( clamp( b * scale, 0, 255 ) + 0.5 )

  return newR, newG, newB
end
