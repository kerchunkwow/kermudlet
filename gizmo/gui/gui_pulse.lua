-- Default size & position of the pulse bar; adjust as desired
local pulseH        = 8       -- Height of bar; increase for more visibility
local pulseW        = "50%"   -- Default bar width (number for pixels, string for percentage)
local pulseY        = -pulseH -- Need -pulseH to see the full height of the bar (otherwise its off-screen)
local pulseX        = 0       -- Left edge of the main window

local pulseDuration = 2       -- Duration of each pulse (how long before the bar disappears)
local pulseRate     = 0.01    -- How many times per second to decrement the pulse (lower values will animate more smoothly)
PulseDecrement      = 100 / (pulseDuration / pulseRate)

-- Percentage of the pulse which must be complete before a new pulse can replace it; 100 will prevent overlaps,
-- 0 will trigger a new pulse on every line of output from the MUD (can be quite jumpy/jittery)
Sensitivity         = 25

-- ID of the timer responsible for decrementing the pulse
PulseTimer          = PulseTimer or nil

-- The value itself (each pulse "fills" this to 100 before decrementing)
PulseValue          = 0

-- The "maximum" and "minimum" color for the pulse bar; by default the bar will interpolate between these two colors
PulseColorMax       = color_table["hot_pink"]
PulseColorMin       = color_table["ansi_black"]

-- If true, the color of the pulse will be interpolated between the min and max colors; otherwise
-- it will just be "on" or "off"
UseInterpolation    = true

-- Create the gauge object and set its style(s)
PulseGauge          = Geyser.Gauge:new( {
  name        = "pulseRight",
  x           = pulseX,
  y           = pulseY,
  width       = pulseW,
  height      = pulseH,
  orientation = "horizontal",
} )

-- Initiate a pulse by setting each bar to 100 and starting a decrement timer
-- Kill any existing timer first (replace prior pulses)
function setPulse()
  -- Do not reset/set a new pulse if the current pulse is greater than the Sensitivity setting
  if PulseValue > Sensitivity then return end
  PulseValue = 100
  PulseGauge.front:setStyleSheet( f [[ background-color: {getPulseColor()}]] )
  PulseGauge:show()
  if PulseTimer then killTimer( PulseTimer ) end
  PulseTimer = tempTimer( pulseRate, [[decrementPulse()]], true )
end

-- Reduce each bar by PulseDecrement every pulseRate seconds until 0 or replaced
-- by the next pulse.
function decrementPulse()
  if PulseValue > 0 then
    PulseValue = PulseValue - PulseDecrement
    PulseGauge.front:setStyleSheet( f [[ background-color: {getPulseColor()}]] )
    PulseGauge:setValue( PulseValue, 100 )
  else
    PulseGauge:hide()
    killTimer( PulseTimer )
  end
end

-- Define the getPulseColor() function depending on whether or not you want to use interpolation
if UseInterpolation then
  -- Calculate a linerally interpolated color between the min and max colors based on the current PulseValue
  function getPulseColor()
    local r1, g1, b1 = unpack( PulseColorMin )
    local r2, g2, b2 = unpack( PulseColorMax )
    local ratio = PulseValue / 100

    -- Calculate the interpolation based on the adjusted logic
    local r = math.floor( r1 + (r2 - r1) * ratio + 0.5 )
    local g = math.floor( g1 + (g2 - g1) * ratio + 0.5 )
    local b = math.floor( b1 + (b2 - b1) * ratio + 0.5 )

    return string.format( "rgb(%d, %d, %d)", r, g, b )
  end

  PulseGauge.back:setStyleSheet( f [[ background-color: rgb(0,0,0)]] )
else
  -- Return the maximum or minimum color based on the current PulseValue
  function getPulseColor()
    if PulseValue >= 1 then
      return string.format( "rgb(%d, %d, %d)", unpack( PulseColorMax ) )
    else
      return string.format( "rgb(%d, %d, %d)", unpack( PulseColorMin ) )
    end
  end

  PulseGauge.back:setStyleSheet( f [[ background-color: {getPulseColor()}]] )
end
-- Create the trigger to initiate a pulse on any line of output from the MUD
PulseTrigger = PulseTrigger or nil
if PulseTrigger then killTrigger( PulseTrigger ) end
PulseTrigger = tempRegexTrigger( "^.*$", [[setPulse()]] )
