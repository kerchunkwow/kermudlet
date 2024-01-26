-- Copy as gizmo/session/login.lua and edit to match your party
local first, second, third, fourth = 'Colin', 'Nandor', 'Laszlo', 'Nadja'
local password = 'yourpassword'

-- Temporary triggers to log each of your PCs in and proceed through to Reception
tempTrigger( [[By what name do you wish to be known?]], f [[send( "{myself}", false )]], 1 )
tempTrigger( [[Password:]], f [[send( "{password}", false )]], 1 )
tempTrigger( [[PRESS RETURN:]], [[send( "1", false )]], 1 )
tempTrigger( [[Enter the game]], [[send( "1", false )]], 1 )

-- Create a chain of follow commands starting when the last PC logs in
if session == 4 then
  tempTrigger( [[Welcome to the land of GizmoMUD]], f [[send( "follow {first}", false )]], 1 )
elseif session == 3 then
  tempTrigger( f [[{fourth} now follows {first}]], f [[send( "follow {first}", false )]], 1 )
elseif session == 2 then
  tempTrigger( f [[{third} now follows {first}]], f [[send( "follow {first}", false )]], 1 )
else
  tempTrigger( f [[{second} starts following you]], f [[send( "group all", false )]], 1 )
end
