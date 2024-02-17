-- Wrap all of the GUI creation in a larger function and define the individual functions locally
-- 'cause none of them are needed once the UI is created
function createGizmoGUI()
  local function openOutputWindows()
    local chatWindowName  = "chat"
    local chatWindowTitle = "Gizmo Chat"
    local chatFontFace    = customChatFontFace or "Bitstream Vera Sans Mono"
    local chatFontSize    = customChatFontSize or 14

    local infoWindowName  = "info"
    local infoWindowTitle = "Gizmo Info"
    local infoFontFace    = customInfoFontFace or "Bitstream Vera Sans Mono"
    local infoFontSize    = customInfoFontSize or 14

    chatWindow            = Geyser.UserWindow:new( {

      name          = chatWindowName,
      titleText     = chatWindowTitle,
      font          = chatFontFace,
      fontSize      = chatFontSize,
      wrapAt        = customChatWrap or 80,
      scrollBar     = false,
      restoreLayout = true,

    } )

    infoWindow            = Geyser.UserWindow:new( {

      name          = infoWindowName,
      titleText     = infoWindowTitle,
      font          = infoFontFace,
      fontSize      = infoFontSize,
      wrapAt        = customInfoWrap or 80,
      scrollBar     = false,
      restoreLayout = true,

    } )

    infoWindow:disableScrollBar()
    chatWindow:disableScrollBar()

    infoWindow:disableHorizontalScrollBar()
    chatWindow:disableHorizontalScrollBar()

    infoWindow:disableCommandLine()
    chatWindow:disableCommandLine()

    infoWindow:clear()
    chatWindow:clear()
  end

  -- Kind of an ugly version of #include
  local function createConsoleStyles()
    uiHeight     = {
      ["label"]    = 24,
      ["hp_gauge"] = 50,
      ["mn_gauge"] = 18,
      ["mv_gauge"] = 18,
      ["gap"]      = 2,
      ["pc_tray"]  = 64,
    }

    consoleFonts = customConsoleFonts or {
      ["label"]     = "Ebrima",
      ["gauge_sm"]  = "Bitstream Vera Sans Mono",
      ["gauge_lrg"] = "Montserrat",
      ["room"]      = "Consolas",
    }

    font_format  = {
      ["label"]     = "rb12",
      ["gauge_sm"]  = "c10",
      ["gauge_lrg"] = "rb16",
      ["room"]      = "c12",
      ["affect"]    = "l12",
    }

    uiColor      = {
      ["rm"]     = "#444444",
      ["pc_1"]   = "#78e6f0",
      ["pc_2"]   = "#c80a4b",
      ["pc_3"]   = "#8c28cd",
      ["pc_4"]   = "#fa7814",
      ["hp_bg"]  = "#3c6419",
      ["hp_fg"]  = "#ADFF2F",
      ["mn_bg"]  = "#2F4F4F",
      ["mn_fg"]  = "#00BFFF",
      ["mv_bg"]  = "#646400",
      ["mv_fg"]  = "#FFD700",
      ["lbl_bg"] = "#202020",
      ["lbl_bd"] = "#707070",
    }

    gauge_border = [[
        border-width:  1px;
        border-style:  solid;
        border-radius: 2;
        padding:       2px;
      ]]


    CSS_gauge_bg = [[ background-color:    rgb( 30, 30, 30 );
                        border-color:        rgb( 50, 50, 50 );]] .. gauge_border

    CSS_hp_fg = f [[ background-color: {uiColor["hp_bg"]};
                      border-color:     {uiColor["hp_fg"]};]] .. gauge_border

    CSS_mn_fg = f [[ background-color: {uiColor["mn_bg"]};
                      border-color:     {uiColor["mn_fg"]};]] .. gauge_border

    CSS_mv_fg = f [[ background-color: {uiColor["mv_bg"]};
                      border-color:     {uiColor["mv_fg"]};]] .. gauge_border

    CSS_text_large = [[ padding-right:        10px;
                          qproperty-alignment: 'AlignVCenter';]]

    CSS_text_small = [[ padding-right:        10px;]]


    CSS_label = f [[background-color: {uiColor["lbl_bg"]};
                    border-width:      1px;
                    border-style:      solid;
                    border-radius:     2;]]

    CSS_affect = f [[background-color: #000000;padding-left: 2px;qproperty-alignment: 'AlignVCenter';]]

    CSS_label_left = f [[
        border-color:      {uiColor["lbl_bd"]};
        padding-left:     10px;]] .. CSS_label

    CSS_label_right = f [[
        border-color:      {uiColor["lbl_bd"]};
        padding-right:     10px;]] .. CSS_label
  end

  -- Delete all the stuff created by createConsoleStyles()
  -- [TODO] This probably (?) is redundant now that all of this is local to createGizmoGUI()
  local function deleteConsoleStyles()
    uiHeight           = nil
    consoleFonts       = nil
    font_format        = nil
    uiColor            = nil
    nameLabel          = nil
    gauge_border       = nil
    CSS_gauge_bg       = nil
    CSS_hp_fg          = nil
    CSS_mn_fg          = nil
    CSS_mv_fg          = nil
    CSS_text_large     = nil
    CSS_text_small     = nil
    CSS_label          = nil
    CSS_label_left     = nil
    CSS_label_right    = nil
    CSS_affect         = nil
    customConsoleFonts = nil
    customChatFontFace = nil
    customChatFontSize = nil
    customInfoFontFace = nil
    customInfoFontSize = nil
    customChatWrap     = nil
    customInfoWrap     = nil
  end

  -- Create the party console (gauges, labels, etc.)
  local function createPartyConsole()
    createConsoleStyles()

    local win_w      = "25%"
    local win_h      = "100%"

    local icon_dim   = 32

    -- Each player "area" consists of:
    --   Spell Affects Label / PC Name (Label)
    --   Current Room (Label)
    --   HP Gauge
    --   MN Gauge
    --   MV Gauge
    --   Combat Icon (Label)
    local pc_area_h  = (uiHeight["label"] * 3) +
        (uiHeight["hp_gauge"]) +
        (uiHeight["mn_gauge"]) +
        (uiHeight["mv_gauge"]) +
        (3 * uiHeight["gap"]) +
        uiHeight["pc_tray"]

    -- The total height of the entire party inclusive of all UI components
    local pc_total_h = (pc_area_h * 4)

    -- Position the party console 500 pixels above the bottom of the console
    local pc_y_top   = (pc_total_h - 500)
    local pc_y_pos   = {}

    party_console    = Geyser.UserWindow:new( {
      name          = "party_console",
      titleText     = "Party Console",
      width         = win_w,
      height        = win_h,
      restoreLayout = true,
    } )

    hpGauge          = {} -- HP Gauges
    manaGauge        = {} -- Mana Gauges
    movesGauge       = {} -- Move Gauges

    nameLabel        = {} -- Player names
    affectLabel      = {} -- Test for new combat label
    roomLabel        = {} -- Player rooms

    combatIcons      = {} -- Combat icons (labels)

    for pc = 1, 4 do
      local nameLabelY = pc_y_top + (pc_area_h * (pc - 1))
      local affectLabelY = nameLabelY - 2
      local rm_label_y = nameLabelY + uiHeight["label"] + uiHeight["gap"]

      local hp_gauge_y = rm_label_y + uiHeight["label"] + uiHeight["gap"]
      local mn_gauge_y = (hp_gauge_y + uiHeight["hp_gauge"] + uiHeight["gap"])
      local mv_gauge_y = (mn_gauge_y + uiHeight["mn_gauge"] + uiHeight["gap"])

      local combat_icon_y = mv_gauge_y + uiHeight["mv_gauge"] + uiHeight["gap"] + 6

      -- HP Gauge
      hpGauge[pc] = Geyser.Gauge:new( {

        name   = "hp_gauge_" .. pc,
        x      = 0,
        y      = hp_gauge_y,
        width  = "100%",
        height = uiHeight["hp_gauge"],

      }, party_console )

      hpGauge[pc].front:setStyleSheet( CSS_hp_fg )
      hpGauge[pc].back:setStyleSheet( CSS_gauge_bg )
      hpGauge[pc].text:setStyleSheet( CSS_text_large )

      hpGauge[pc].text:setFont( consoleFonts["gauge_lrg"] )
      hpGauge[pc].text:setFormat( font_format["gauge_lrg"] )
      hpGauge[pc].text:setFgColor( uiColor["hp_fg"] )

      hpGauge[pc]:setValue( 444, 444, "100%" )

      -- Call healthClicked( pc_name ) when clicking the hp gauge
      setLabelClickCallback( hpGauge[pc].text.name, "healthClicked", pc, pcNames[pc] )

      -- MN Gauge
      manaGauge[pc] = Geyser.Gauge:new( {

        name   = "mn_gauge_" .. pc,
        x      = 0,
        y      = mn_gauge_y,
        width  = "100%",
        height = uiHeight["mn_gauge"],

      }, party_console )

      manaGauge[pc].front:setStyleSheet( CSS_mn_fg )
      manaGauge[pc].back:setStyleSheet( CSS_gauge_bg )

      manaGauge[pc].text:setFont( consoleFonts["gauge_sm"] )
      manaGauge[pc].text:setFormat( font_format["gauge_sm"] )
      manaGauge[pc].text:setFgColor( uiColor["mn_fg"] )

      manaGauge[pc]:setValue( 69, 100, "69" )


      -- MV Gauge
      movesGauge[pc] = Geyser.Gauge:new( {

        name   = "mv_gauge_" .. pc,
        x      = 0,
        y      = mv_gauge_y,
        width  = "100%",
        height = uiHeight["mv_gauge"],

      }, party_console )

      movesGauge[pc].front:setStyleSheet( CSS_mv_fg )
      movesGauge[pc].back:setStyleSheet( CSS_gauge_bg )

      movesGauge[pc].text:setFont( consoleFonts["gauge_sm"] )
      movesGauge[pc].text:setFormat( font_format["gauge_sm"] )
      movesGauge[pc].text:setFgColor( uiColor["mv_fg"] )

      movesGauge[pc]:setValue( 420, 500, "420" )

      -- Call movesClicked( pc_name ) when clicking the move gauge
      setLabelClickCallback( movesGauge[pc].text.name, "movesClicked", pc, pcNames[pc] )

      nameLabel[pc] = Geyser.Label:new( {

        name   = "pc_label_" .. pc,
        x      = "66%",
        y      = nameLabelY,
        width  = "34%",
        height = uiHeight["label"],

      }, party_console )

      affectLabel[pc] = Geyser.Label:new( {

        name   = "affectLabel" .. pc,
        x      = 0,
        y      = affectLabelY,
        width  = "66%",
        height = uiHeight["label"],

      }, party_console )

      affectLabel[pc]:setFormat( font_format["affect"] )
      affectLabel[pc]:setStyleSheet( CSS_affect )
      affectLabel[pc]:setFont( 'Dubai Medium' )
      affectLabel[pc]:setFontSize( 14 )
      affectLabel[pc]:echo( "❓" )

      -- Call affectsClicked( pc_name ) when clicking the spell affects label
      setLabelClickCallback( affectLabel[pc].name, "affectsClicked", pc, pcNames[pc] )

      local pc_label_border = uiColor[f "pc_{pc}"]
      local CSS_label_pc = CSS_label .. f [[border-color: {pc_label_border};padding-right: 14px;]]

      nameLabel[pc]:setFgColor( uiColor[f "pc_{pc}"] )
      nameLabel[pc]:setFont( consoleFonts["label"] )
      nameLabel[pc]:setFormat( font_format["label"] )
      nameLabel[pc]:setStyleSheet( CSS_label_pc )

      local pcName = pcNames[pc]
      nameLabel[pc]:echo( pcName )

      roomLabel[pc] = Geyser.Label:new( {

        name   = "rm_label_" .. pc,
        x      = 0,
        y      = rm_label_y,
        width  = "100%",
        height = uiHeight["label"],

      }, party_console )

      local rm_label_border = uiColor["rm"]
      local CSS_label_rm = CSS_label .. f [[border-color: {rm_label_border};]]

      roomLabel[pc]:setFgColor( "#6496fa" )
      roomLabel[pc]:setFont( consoleFonts["room"] )
      roomLabel[pc]:setFormat( font_format["room"] )
      roomLabel[pc]:setStyleSheet( CSS_label_rm )

      roomLabel[pc]:echo( "Bob's Pizza" )

      -- Call roomClicked( pc_name ) when double-clicking the room label
      setLabelDoubleClickCallback( roomLabel[pc].name, "roomClicked", pc, pcNames[pc] )

      combatIcons[pc] = Geyser.Label:new( {
        name = "combat_icon_" .. pc,
        x = (icon_dim * -1) - 6,
        y = combat_icon_y,
        width = icon_dim,
        height = icon_dim
      }, party_console )


      -- Call combatClicked( pc_name ) when clicking the combat icon
      setLabelClickCallback( combatIcons[pc].name, "combatClicked", pc, pcNames[pc] )

      if pc == 4 then
        combatIcons[pc]:setBackgroundImage( [[C:/Dev/mud/mudlet/gizmo/assets/img/targeted.png]] )
      else
        combatIcons[pc]:setBackgroundImage( [[C:/Dev/mud/mudlet/gizmo/assets/img/combat.png]] )
      end
      combatIcons[pc]:hide()
    end
    deleteConsoleStyles()
  end

  openOutputWindows()
  createPartyConsole()
end

-- Work in progress to develop a console similar to the party status window to report
-- on group member status
local function createGroupConsole()
  --createConsoleStyles()

  group_console = Adjustable.Container:new( {
    name          = "group_console",
    titleText     = "Group Console",
    titleTxtColor = "orange",
  } )

  group_gauges = {}

  --deleteConsoleStyles()
end

local function getLabelCSS( bg, border )
  local lbl = f [[
        background-color:    {bg};
        border-color:        {border};
        border-width:        2px;
        border-style:        solid;
        border-radius:       2;
        padding:             2px;
    ]]
end
