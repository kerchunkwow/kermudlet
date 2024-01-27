-- Copy as gizmo/session/login.lua and edit to match your party
local first, second, third, fourth = pcNames[1], pcNames[2], pcNames[3], pcNames[4]
local password = 'yourpassword'

-- Temporary triggers to log each of your PCs in and proceed through to Reception
tempTrigger( [[By what name do you wish to be known?]], f [[send( "{myself}", false )]], 1 )
tempTrigger( [[Password:]], f [[send( "{password}", false )]], 1 )
tempTrigger( [[PRESS RETURN:]], [[send( "1", false )]], 1 )
tempTrigger( [[Enter the game]], [[send( "1", false )]], 1 )

-- Create a chain of follow commands starting when the last PC logs in
-- [TODO] Modify these two use createTemporaryTrigger so they don't stick around and fuck with relog after DCs
if session == 4 then
  tempTrigger( [[Welcome to the land of GizmoMUD]], f [[send( "follow {first}", false )]], 1 )
elseif session == 3 then
  tempTrigger( f [[{fourth} now follows {first}]], f [[send( "follow {first}", false )]], 1 )
elseif session == 2 then
  tempTrigger( f [[{third} now follows {first}]], f [[send( "follow {first}", false )]], 1 )
else
  tempTrigger( f [[{second} starts following you]], f [[send( "group all", false )]], 1 )
end
-- Should ideally synchronize the map with the Grunting Boar reception
createTemporaryTrigger( "loginMapSynch", "The Reception", [[setPlayerRoom(1115)]], 10 )