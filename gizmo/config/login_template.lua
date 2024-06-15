-- Copy as gizmo/config/login.lua and edit to add your password
-- If you move login.lua, make sure you update .gitignore to avoid checking it in
local first, second, third, fourth = pcNames[1], pcNames[2], pcNames[3], pcNames[4]
local password                     = 'yourpass'

-- Substrings encountered at login
local namePattern                  = [[By what name do you wish to be known?]]
local passwordPattern              = [[Password:]]
local returnPattern                = [[PRESS RETURN:]]
local enterPattern                 = [[Enter the game]]

-- Code to execute when patterns are seen
local nameCode                     = f [[send( "{pcName}", false )]]
local passCode                     = f [[send( "{password}", false )]]
local returnCode                   = [[send( "1", false )]]
local enterCode                    = [[send( "1", false )]]

addTrigger( 'substring', 'login_name', namePattern, nameCode, 1 )
addTrigger( 'substring', 'login_pass', passwordPattern, passCode, 1 )
addTrigger( 'substring', 'login_return', returnPattern, returnCode, 1 )
addTrigger( 'substring', 'login_enter', enterPattern, enterCode, 1 )

-- If the map is loaded, set a trigger to synchronize with The Grunting Boar reception
if roomExists( 1115 ) then
  local roomPattern = [[The Reception]]
  local roomCode    = [[setPlayerRoom(1115)]]
  addTimedTrigger( 'substring', 'login_mapsynch', roomPattern, roomCode, 10 )
end
