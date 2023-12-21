timeStart = os.time()
math.randomseed( timeStart )

runLuaFile( "stdlib.lua" )
runLuaFile( "dd_actions.lua" )
runLuaFile( "dd_eq.lua" )

runLuaFile( "affects\\affect_h.lua" )
runLuaFile( "affects\\affect.lua" )
runLuaFile( "alias\\dd_alias.lua" )

runLuaFile( "map\\mapper.lua" )

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
initializeAffectTracking()
