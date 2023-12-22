-- Send profiles through a shared init to establish consistency and avoid deuplicating common/shared tasks

timeStart = os.time()
math.randomseed( timeStart )

if not timer then
  timer = createStopWatch( "timer", true )
  setStopWatchPersistence( "timer", true )
end
-- Redefine this here so VSCode recognizes it
function runLuaFile( luaFile )
  local filePath = rootDirectory .. luaFile
  if lfs.attributes( filePath, "mode" ) == "file" then
    dofile( filePath )
  else
    error( filePath .. " not found." )
  end
end

runLuaFile( "stdlib.lua" )

-- Fork depending on which game we're playing
local profileName = getProfileName()

if profileName == "IMM" then -- Gizmo IMM
  rootDirectory = rootDirectory .. "gizmo\\mal\\"
  runLuaFile( "mal.lua" )
elseif profileName == "1" then -- Gizmo
  rootDirectory = rootDirectory .. "gizmo\\"
  runLuaFile( "giz_init.lua" )
elseif profileName == "DD" then -- Death's Domain
  rootDirectory = rootDirectory .. "dd\\"
  runLuaFile( "dd_init.lua" )
end
