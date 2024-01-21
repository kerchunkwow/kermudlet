cecho( f '\n  <olive_drab>map_ux.lua<reset>: define & maintain Map UX including colors, room styles, icons, etc.' )

TXT_COLOR = {
  default   = "<dim_grey>",
  roomName  = "<royal_blue>",
  roomDesc  = "<olive_drab>",
  basicExit = "<dark_slate_grey>",
  doorExit  = "<medium_sea_green>",
  death     = "<tomato>",
  area      = "<maroon>",
  noteLabel = "<yellow>",
  warnLabel = "<red>",
  dirLabel  = "<yellow>",
  key       = "<goldenrod>",
  number    = "<dark_orange>",
  string    = "<medium_orchid>",
  error     = "<ansi_light_magenta>",
}

NC        = TXT_COLOR['number']
RMNC      = TXT_COLOR['roomName']
RMDC      = TXT_COLOR['roomDesc']
ARC       = TXT_COLOR['area']
DTC       = TXT_COLOR['death']
ERRC      = TXT_COLOR['error']
KEYC      = TXT_COLOR['key']
DOORC     = TXT_COLOR['doorExit']
EXC       = TXT_COLOR['basicExit']
R         = "<reset>"


-- Select one of the predefined colors to display an Exit based on Door and Destination status
-- Prioritize colros and exit early as soon as the first condition is met
function getExitColor( to, dir )
  local isMissing = not roomExists( to )
  if isMissing then return ERRC end
  local toFlags = getRoomUserData( to, "roomFlags" )
  local isDT    = toFlags and toFlags:find( "DEATH" )
  if isDT then return DTC end
  local isDoor = doorData[currentRoomNumber] and doorData[currentRoomNumber][LDIR[dir]]
  local hasKey = isDoor and doorData[currentRoomNumber][LDIR[dir]].exitKey
  if hasKey then return KEYC elseif isDoor then return DOORC end
  local isBorder = currentAreaNumber ~= getRoomArea( to )
  if isBorder then return ARC else return EXC end
end
