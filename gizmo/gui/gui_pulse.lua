-- Module to implement a visual indicator of how much time has passed since the
-- most recent output was received from the MUD.

function createPulseGauge()
  local gaugeBorder = [[
        border-width:  1px;
        border-style:  solid;
        border-radius: 2;
        padding:       2px;]]

  local gaugeBg = [[ background-color:    #303030;
                   border-color:        #505050;]] .. gaugeBorder

  local gaugeFg = [[ background-color: #646400;
                  border-color:     #FFD700;]] .. gaugeBorder

  PulseGauge = Geyser.Gauge:new( {
    name   = "pulseGauge",
    x      = 0,
    y      = -20,
    width  = "100%",
    height = 80,
  } )

  PulseGauge.text:setFont( "Bitstream Vera Sans Mono" )
  PulseGauge.text:setFormat( "l10" )
  PulseGauge.text:setFgColor( "#00BFFF" )
end
