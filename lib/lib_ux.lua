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

-- Print a formatted string to the "main" console; mainly used to report on in-game events or
-- alert the player to important events or necessary actions
function cout( s )
  cecho( "\n" .. f( s ) )
end

-- Print a formatted string to the "Info" console; used more like a status or debug window for Mudlet
-- to report on internal functionality and provide additional context for certain functions
function iout( s )
  cecho( "info", "\n" .. f( s ) )
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
  -- Default to black if no color is provided
  if not c then c = "<black>" end
  -- If color (c) is provided but is not surrounded with <>, add them
  if not string.match( c, "<" ) then c = f "<{c}>" end
  local fi = fill( n - 2, '-', c )
  local line = f "\n{c}+{fi}{c}+<reset>"
  cecho( line )
end

-- Delete the current line then any of the subsequent 3 lines that are either empty or "prompt only"
function deleteComplete()
  deleteLine()
  tempLineTrigger( 1, 3, [[completeDelete()]] )
end

-- Support deleteComplete() by deleteing the current line if it's empty or "prompt only"
function completeDelete()
  local justAPrompt = string.match( line, "< %d+%(%d+%) %d+%(%d+%) %d+%(%d+%) > $" )
  if justAPrompt or #line <= 0 then
    deleteLine()
  end
end

-- Function to output a framed/formatted table
function displayFramedTable( title, table, frameColor )
  -- Color to use for the frame; default to dark slate blue
  local fc = frameColor or "<dark_slate_blue>"
  -- Vertical rule (sidebar) for the table
  local vr = f "{fc}|{RC}"
  -- Local to hold the length of the longest key & value
  local longKey = 0
  title = f( "{vr} {title} {vr}" )
  -- Use cLength to get the length of the title w/o Mudlet color tags
  local width = cLength( title )
  -- Print the title with horizontal rules above and below
  hrule( width, fc )
  cecho( "\n" .. title )
  hrule( width, fc )
  for k, v in pairs( table ) do
    longKey = math.max( longKey, cLength( k ) )
  end
  for k, v in pairs( table ) do
    -- Align the values to the longest key
    local pad1 = fill( longKey - cLength( k ) )
    local tableLine = f "{vr} {SC}{k}{RC}{pad1} {NC}{v}{RC}"
    -- Align the right vertical rule with the width of the table
    local pad2 = fill( (width - cLength( tableLine )) - 1 )
    cecho( f "\n{tableLine}{pad2}{vr}" )
  end
  hrule( width, fc )
end

function displayColors()
  -- List of colors to display; a subset of Mudlet's built-in color_table
  local colorsToDisplay = {
    ansi_blue              = {0, 80, 250},
    ansi_cyan              = {0, 200, 210},
    ansi_green             = {80, 200, 0},
    ansi_light_black       = {125, 125, 125},
    ansi_light_blue        = {0, 125, 250},
    ansi_light_cyan        = {0, 240, 250},
    ansi_light_green       = {120, 240, 0},
    ansi_light_magenta     = {250, 0, 225},
    ansi_light_red         = {250, 0, 60},
    ansi_light_white       = {250, 250, 250},
    ansi_light_yellow      = {240, 250, 0},
    ansi_magenta           = {200, 0, 180},
    ansi_red               = {220, 0, 20},
    ansi_white             = {200, 200, 200},
    ansi_yellow            = {210, 220, 0},
    antique_white          = {250, 235, 215},
    aquamarine             = {127, 255, 212},
    azure                  = {240, 255, 255},
    beige                  = {245, 245, 220},
    bisque                 = {255, 228, 196},
    black                  = {0, 0, 0},
    blanched_almond        = {255, 235, 205},
    blue                   = {0, 0, 255},
    blue_violet            = {138, 43, 226},
    brown                  = {165, 42, 42},
    burlywood              = {222, 184, 135},
    cadet_blue             = {95, 158, 160},
    chartreuse             = {127, 255, 0},
    chocolate              = {210, 105, 30},
    coral                  = {255, 127, 80},
    cornflower_blue        = {100, 149, 237},
    cornsilk               = {255, 248, 220},
    cyan                   = {0, 255, 255},
    dark_goldenrod         = {184, 134, 11},
    dark_green             = {0, 100, 0},
    dark_khaki             = {189, 183, 107},
    dark_olive_green       = {85, 107, 47},
    dark_orange            = {255, 140, 0},
    dark_orchid            = {153, 50, 204},
    dark_salmon            = {233, 150, 122},
    dark_sea_green         = {143, 188, 143},
    dark_slate_blue        = {72, 61, 139},
    dark_slate_gray        = {47, 79, 79},
    dark_slate_grey        = {47, 79, 79},
    dark_turquoise         = {0, 206, 209},
    dark_violet            = {148, 0, 211},
    deep_pink              = {255, 20, 147},
    deep_sky_blue          = {0, 191, 255},
    dim_gray               = {105, 105, 105},
    dim_grey               = {105, 105, 105},
    dodger_blue            = {30, 144, 255},
    firebrick              = {178, 34, 34},
    floral_white           = {255, 250, 240},
    forest_green           = {34, 139, 34},
    gainsboro              = {220, 220, 220},
    ghost_white            = {248, 248, 255},
    gold                   = {255, 215, 0},
    goldenrod              = {218, 165, 32},
    gray                   = {190, 190, 190},
    green                  = {0, 255, 0},
    green_yellow           = {173, 255, 47},
    grey                   = {190, 190, 190},
    honeydew               = {240, 255, 240},
    hot_pink               = {255, 105, 180},
    indian_red             = {205, 92, 92},
    ivory                  = {255, 255, 240},
    khaki                  = {240, 230, 140},
    lavender               = {230, 230, 250},
    lavender_blush         = {255, 240, 245},
    lawn_green             = {124, 252, 0},
    lemon_chiffon          = {255, 250, 205},
    light_blue             = {173, 216, 230},
    light_coral            = {240, 128, 128},
    light_cyan             = {224, 255, 255},
    light_goldenrod        = {238, 221, 130},
    light_goldenrod_yellow = {250, 250, 210},
    light_gray             = {211, 211, 211},
    light_grey             = {211, 211, 211},
    light_pink             = {255, 182, 193},
    light_salmon           = {255, 160, 122},
    light_sea_green        = {32, 178, 170},
    light_sky_blue         = {135, 206, 250},
    light_slate_blue       = {132, 112, 255},
    light_slate_gray       = {119, 136, 153},
    light_slate_grey       = {119, 136, 153},
    light_steel_blue       = {176, 196, 222},
    light_yellow           = {255, 255, 224},
    lime_green             = {50, 205, 50},
    linen                  = {250, 240, 230},
    magenta                = {255, 0, 255},
    maroon                 = {176, 48, 96},
    medium_aquamarine      = {102, 205, 170},
    medium_blue            = {0, 0, 205},
    medium_orchid          = {186, 85, 211},
    medium_purple          = {147, 112, 219},
    medium_sea_green       = {60, 179, 113},
    medium_slate_blue      = {123, 104, 238},
    medium_spring_green    = {0, 250, 154},
    medium_turquoise       = {72, 209, 204},
    medium_violet_red      = {199, 21, 133},
    midnight_blue          = {25, 25, 112},
    mint_cream             = {245, 255, 250},
    misty_rose             = {255, 228, 225},
    moccasin               = {255, 228, 181},
    navajo_white           = {255, 222, 173},
    navy                   = {0, 0, 128},
    navy_blue              = {0, 0, 128},
    old_lace               = {253, 245, 230},
    olive_drab             = {107, 142, 35},
    orange                 = {255, 165, 0},
    orange_red             = {255, 69, 0},
    orchid                 = {218, 112, 214},
    pale_goldenrod         = {238, 232, 170},
    pale_green             = {152, 251, 152},
    pale_turquoise         = {175, 238, 238},
    pale_violet_red        = {219, 112, 147},
    papaya_whip            = {255, 239, 213},
    peach_puff             = {255, 218, 185},
    peru                   = {205, 133, 63},
    pink                   = {255, 192, 203},
    plum                   = {221, 160, 221},
    powder_blue            = {176, 224, 230},
    purple                 = {160, 32, 240},
    red                    = {255, 0, 0},
    rosy_brown             = {188, 143, 143},
    royal_blue             = {65, 105, 225},
    saddle_brown           = {139, 69, 19},
    salmon                 = {250, 128, 114},
    sandy_brown            = {244, 164, 96},
    sea_green              = {46, 139, 87},
    seashell               = {255, 245, 238},
    sienna                 = {160, 82, 45},
    sky_blue               = {135, 206, 235},
    slate_blue             = {106, 90, 205},
    slate_gray             = {112, 128, 144},
    slate_grey             = {112, 128, 144},
    snow                   = {255, 250, 250},
    spring_green           = {0, 255, 127},
    steel_blue             = {70, 130, 180},
    tan                    = {210, 180, 140},
    thistle                = {216, 191, 216},
    tomato                 = {255, 99, 71},
    transparent            = {255, 255, 255, 0},
    turquoise              = {64, 224, 208},
    violet                 = {238, 130, 238},
    violet_red             = {208, 32, 144},
    wheat                  = {245, 222, 179},
    white                  = {255, 255, 255},
    white_smoke            = {245, 245, 245},
    yellow                 = {255, 255, 0},
    yellow_green           = {154, 205, 50}
  }

  -- Local function to calculate the length of the longest color name
  -- in the colorsToDisplay table
  local function longestColor()
    local longest = 0
    for color, _ in pairs( colorsToDisplay ) do
      if #color > longest then
        longest = #color
      end
    end
    return longest
  end

  local longest = longestColor()

  -- Empty table to hold the strings to display
  local displayColors = {}

  -- For each color in the colorsToDisplay table, create a "display string" using the color name
  -- and rgb values, padding each so the columns are aligned
  for color, rgb in pairs( colorsToDisplay ) do
    -- Empty space padded to the length of the longest color
    local pad        = fill( longest - #color )
    local r1, r2, r3 = tostring( rgb[1] ), tostring( rgb[2] ), tostring( rgb[3] )
    l1, l2, l3       = string.len( r1 ), string.len( r2 ), string.len( r3 )
    local p1, p2, p3 = fill( 3 - l1 ), fill( 3 - l2 ), fill( 3 - l3 )
    local p          = "<orchid>"
    local n          = "<purple>"
    local op         = "<violet_red>"
    local c          = f "<{color}>"
    local ops        = f "{op} = {RC}"
    local cs         = f "{c}{color}{RC}"
    local rgbs       = f " {p}[ {n}{r1}{RC},{p1} {n}{r2}{RC},{p2} {n}{r3}{p3} {p}]{RC}"
    local display    = cs .. pad .. ops .. rgbs
    table.insert( displayColors, display )
  end
  -- Print the colors in a 3-column layout
  for i = 1, #displayColors, 3 do
    local line = ""
    for j = 0, 2 do
      if displayColors[i + j] then
        line = line .. displayColors[i + j] .. fill( 3 )
      end
    end
    cecho( line .. "\n" )
  end
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
