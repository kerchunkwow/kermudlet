-- Send profiles through a shared init to establish consistency and avoid deuplicating common/shared tasks
timeStart = os.time()
math.randomseed( timeStart )

if not timer then
  timer = createStopWatch( "timer", true )
  setStopWatchPersistence( "timer", true )
end
runLuaFile( "lib\\stdlib.lua" )

-- Fork depending on which game we're playing
local profileName = getProfileName()

if profileName == "IMM" then -- Gizmo IMM
  rootDirectory = rootDirectory .. "gizmo\\mal\\"
  runLuaFile( "mal.lua" )
elseif profileName == "DD" then -- Death's Domain
  rootDirectory = rootDirectory .. "dd\\"
  runLuaFile( "dd_init.lua" )
else -- Gizmo
  rootDirectory = rootDirectory .. "gizmo\\"
  runLuaFile( "giz_init.lua" )
end
