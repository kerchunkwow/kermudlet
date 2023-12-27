-- Common to all sessions
local commonScripts = {
  "dd_actions.lua",
  "dd_eq.lua",
  "alias\\dd_alias.lua",
}

runLuaFiles( commonScripts )

developerMode = true

water         = "wineskin"

foodBag       = "tube"
scrollBag     = "skin"
potBag        = "skin"

if not developerMode then
  disableAlias( "Dev & QA" )
else
  enableAlias( "Dev & QA" )
end
-- Melee Highlights
meleeColor = {
  ["barely"]     = "light_grey",
  ["lightly"]    = "gainsboro",
  ["wound"]      = "tan",
  ["deeply"]     = "sandy_brown",
  ["really"]     = "light_coral",
  ["critically"] = "coral",
  ["totally"]    = "firebrick",
  ["decimate"]   = "tomato",
  ["massacre"]   = "orange_red"
}

-- infoWindow here gets defined via _G so IDEs won't recognize it
if not infoWindow then openBasicWindow( "infoWindow", "Info", "Bitstream Vera Sans Mono", 14 ) end
