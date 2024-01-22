cecho( f '\n  <coral>create_gui.lua<dim_grey>: initial functions to build/create Gizmo GUI: info, chat, party console' )

function openOutputWindows()
  local chat_window_name  = "chat"
  local chat_window_title = "Gizmo Chat"
  local chat_font_face    = "Bitstream Vera Sans Mono"
  local chat_font_size    = 14

  local info_window_name  = "info"
  local info_window_title = "Gizmo Info"
  local info_font_face    = "Bitstream Vera Sans Mono"
  local info_font_size    = 14

  chat_window             = Geyser.UserWindow:new( {

    name          = chat_window_name,
    titleText     = chat_window_title,
    font          = chat_font_face,
    fontSize      = chat_font_size,
    wrapAt        = 80,
    scrollBar     = false,
    restoreLayout = true,

  } )

  info_window             = Geyser.UserWindow:new( {

    name          = info_window_name,
    titleText     = info_window_title,
    font          = info_font_face,
    fontSize      = info_font_size,
    wrapAt        = 80,
    scrollBar     = false,
    restoreLayout = true,

  } )

  info_window:disableScrollBar()
  chat_window:disableScrollBar()

  info_window:disableHorizontalScrollBar()
  chat_window:disableHorizontalScrollBar()

  info_window:disableCommandLine()
  chat_window:disableCommandLine()

  info_window:clear()
  chat_window:clear()

  local lft, rgt = fill( 33 ) .. ui_color, fill( 33 ) .. "<reset>"

  local chat_title = f "{ui_color}| <yellow_green>Gizmo Chat{ui_color} |"
  local info_title = f "{ui_color}| <dark_orange>Gizmo Info{ui_color} |"

  cecho( "chat", f "{lft}+------------+{rgt}" )
  cecho( "chat", f "{lft}{chat_title}{rgt}" )
  cecho( "chat", f "{lft}+------------+{rgt}\n" )

  cecho( "info", f "{lft}+------------+{rgt}" )
  cecho( "info", f "{lft}{info_title}{rgt}" )
  cecho( "info", f "{lft}+------------+{rgt}\n" )
end

-- Kind of an ugly version of #include
function createConsoleStyles()
  uiHeight = {
    ["label"]    = 24,
    ["hp_gauge"] = 50,
    ["mn_gauge"] = 18,
    ["mv_gauge"] = 18,
    ["gap"]      = 2,
    ["pc_tray"]  = 64,
  }


  font_face    = {
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

  ui_color     = {
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

  nameLabel    = {"Colin", "Nadja", "Laszlo", "Nandor"}

  gauge_border = [[
      border-width:  1px;
      border-style:  solid;
      border-radius: 2;
      padding:       2px;
    ]]


  CSS_gauge_bg = [[ background-color:    rgb( 30, 30, 30 );
                      border-color:        rgb( 50, 50, 50 );]] .. gauge_border

  CSS_hp_fg = f [[ background-color: {ui_color["hp_bg"]};
                    border-color:     {ui_color["hp_fg"]};]] .. gauge_border

  CSS_mn_fg = f [[ background-color: {ui_color["mn_bg"]};
                    border-color:     {ui_color["mn_fg"]};]] .. gauge_border

  CSS_mv_fg = f [[ background-color: {ui_color["mv_bg"]};
                    border-color:     {ui_color["mv_fg"]};]] .. gauge_border

  CSS_text_large = [[ padding-right:        10px;
                        qproperty-alignment: 'AlignVCenter';]]

  CSS_text_small = [[ padding-right:        10px;]]


  CSS_label = f [[background-color: {ui_color["lbl_bg"]};
                  border-width:      1px;
                  border-style:      solid;
                  border-radius:     2;]]

  CSS_affect = f [[background-color: #000000;padding-left: 2px;qproperty-alignment: 'AlignVCenter';]]

  CSS_label_left = f [[
      border-color:      {ui_color["lbl_bd"]};
      padding-left:     10px;]] .. CSS_label

  CSS_label_right = f [[
      border-color:      {ui_color["lbl_bd"]};
      padding-right:     10px;]] .. CSS_label
end

function deleteConsoleStyles()
  uiHeight        = nil
  font_face       = nil
  font_format     = nil
  ui_color        = nil
  nameLabel       = nil
  gauge_border    = nil
  CSS_gauge_bg    = nil
  CSS_hp_fg       = nil
  CSS_mn_fg       = nil
  CSS_mv_fg       = nil
  CSS_text_large  = nil
  CSS_text_small  = nil
  CSS_label       = nil
  CSS_label_left  = nil
  CSS_label_right = nil
  CSS_affect      = nil
end

function getLabelCSS( bg, border )
  local lbl = f [[
        background-color:    {bg};
        border-color:        {border};
        border-width:        2px;
        border-style:        solid;
        border-radius:       2;
        padding:             2px;
    ]]
end

function resetPartyConsole()
  party_console = nil
  createPartyConsole()
end

function createPartyConsole()
  createConsoleStyles()

  local win_font_face  = "Ubuntu"
  local win_font_size  = 10
  local win_font_style = [[bold 10pt "Ubuntu"]]
  local win_font_align = "center left"
  local border_r       = 4

  local win_w          = "25%"
  local win_h          = "100%"

  local icon_dim       = 32

  -- Each player "area" consists of:
  -- PC Name (Label)
  -- Current Room (Label)
  -- HP Gauge
  -- MN Gauge
  -- MV Gauge
  -- Item Tray (Label)
  local pc_area_h      = (uiHeight["label"] * 3) +
      (uiHeight["hp_gauge"]) +
      (uiHeight["mn_gauge"]) +
      (uiHeight["mv_gauge"]) +
      (3 * uiHeight["gap"]) +
      uiHeight["pc_tray"]

  local pc_total_h     = (pc_area_h * 4)

  local pc_y_top       = (pc_total_h - 500)
  local pc_y_pos       = {}

  party_console        = Geyser.UserWindow:new( {
    name          = "party_console",
    titleText     = "Party Console",
    width         = win_w,
    height        = win_h,
    restoreLayout = true,
  } )

  hpGauge              = {} -- HP Gauges
  manaGauge            = {} -- Mana Gauges
  movesGauge           = {} -- Move Gauges

  nameLabel            = {} -- Player names
  affectLabel          = {} -- Test for new combat label
  roomLabel            = {} -- Player rooms

  combatIcons          = {} -- Combat icons (labels)

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

    hpGauge[pc].text:setFont( font_face["gauge_lrg"] )
    hpGauge[pc].text:setFormat( font_format["gauge_lrg"] )
    hpGauge[pc].text:setFgColor( ui_color["hp_fg"] )

    hpGauge[pc]:setValue( 444, 444, "100%" )

    -- Call hp_clicked( pc_name ) when clicking the hp gauge
    setLabelClickCallback( hpGauge[pc].text.name, "hp_clicked", pc, pc_names[pc] )

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

    manaGauge[pc].text:setFont( font_face["gauge_sm"] )
    manaGauge[pc].text:setFormat( font_format["gauge_sm"] )
    manaGauge[pc].text:setFgColor( ui_color["mn_fg"] )

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

    movesGauge[pc].text:setFont( font_face["gauge_sm"] )
    movesGauge[pc].text:setFormat( font_format["gauge_sm"] )
    movesGauge[pc].text:setFgColor( ui_color["mv_fg"] )

    movesGauge[pc]:setValue( 420, 500, "420" )

    -- Call mv_clicked( pc_name ) when clicking the move gauge
    setLabelClickCallback( movesGauge[pc].text.name, "mv_clicked", pc, pc_names[pc] )

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
    affectLabel[pc]:echo( "❓" )

    local pc_label_border = ui_color[f "pc_{pc}"]
    local CSS_label_pc = CSS_label .. f [[border-color: {pc_label_border};padding-right: 14px;]]

    nameLabel[pc]:setFgColor( ui_color[f "pc_{pc}"] )
    nameLabel[pc]:setFont( font_face["label"] )
    nameLabel[pc]:setFormat( font_format["label"] )
    nameLabel[pc]:setStyleSheet( CSS_label_pc )

    local pc_name = pc_names[pc]
    nameLabel[pc]:echo( pc_name )

    -- Custom 'fury' icon for top pc
    if pc == 1 then
      fury_icon = Geyser.Label:new( {

        name   = "fury_icon",
        x      = (icon_dim * -1) - 6,
        y      = nameLabelY - uiHeight["label"] - 16,
        width  = 32,
        height = 32,

      }, party_console )

      fury_icon:setBackgroundImage( [[C:/Dev/mud/mudlet/gizmo/assets/img/fury.png]] )
      fury_icon:hide()
    end
    roomLabel[pc] = Geyser.Label:new( {

      name   = "rm_label_" .. pc,
      x      = 0,
      y      = rm_label_y,
      width  = "100%",
      height = uiHeight["label"],

    }, party_console )

    local rm_label_border = ui_color["rm"]
    local CSS_label_rm = CSS_label .. f [[border-color: {rm_label_border};]]

    roomLabel[pc]:setFgColor( "#6496fa" )
    roomLabel[pc]:setFont( font_face["room"] )
    roomLabel[pc]:setFormat( font_format["room"] )
    roomLabel[pc]:setStyleSheet( CSS_label_rm )

    roomLabel[pc]:echo( my_room )

    -- Call room_clicked( pc_name ) when double-clicking the room label
    setLabelDoubleClickCallback( roomLabel[pc].name, "room_clicked", pc_names[pc] )

    combatIcons[pc] = Geyser.Label:new( {
      name = "combat_icon_" .. pc,
      x = (icon_dim * -1) - 6,
      y = combat_icon_y,
      width = icon_dim,
      height = icon_dim
    }, party_console )


    -- Call combat_clicked( pc_name ) when clicking the combat icon
    setLabelClickCallback( combatIcons[pc].name, "combat_clicked", pc, pc_names[pc] )

    if pc == 4 then
      combatIcons[pc]:setBackgroundImage( [[C:/Dev/mud/mudlet/gizmo/assets/img/targeted.png]] )
    else
      combatIcons[pc]:setBackgroundImage( [[C:/Dev/mud/mudlet/gizmo/assets/img/combat.png]] )
    end
    combatIcons[pc]:hide()
  end
  deleteConsoleStyles()
end

function createGroupConsole()
  createConsoleStyles()

  group_console = Adjustable.Container:new( {
    name          = "group_console",
    titleText     = "Group Console",
    titleTxtColor = "orange",
  } )

  group_gauges = {}

  deleteConsoleStyles()
end
