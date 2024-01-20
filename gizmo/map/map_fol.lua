-- An object to house data related to the room we are currently in
pcRoom = {
  doors  = {},
  exits  = {},
  coords = {},
  name   = "",
  desc   = "",
  flags  = "",
  type   = "",
  extra  = "",
  number = -1,
  spec   = -1
}

-- Update the player's location on the map; optionally including the direction traveled to arrive
function setPCRoom( id, dir )
  pcRoom.number = tonumber( id )
  pcRoom.name   = getRoomName( pcRoom.number )
  pcRoom.type   = getRoomUserData( pcRoom.number, "roomType" )
  pcRoom.flags  = getRoomUserData( pcRoom.number, "roomFlags" )
  pcRoom.spec   = getRoomUserData( pcRoom.number, "roomSpec" )
end
