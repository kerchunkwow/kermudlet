-- If the doorData hasn't been initialized, load it once other scripts have finished loading
if not doorData then
  doorData = {}
  table.load( f '{HOME_PATH}/gizmo/map/data/door_data.lua', doorData )
end
-- Retrieve data about the specified room's doors; if dir is supplied get that direction only
function getDoorData( id, dir )
  local roomDoorData = doorData[id]

  -- No doors present in this room
  if not roomDoorData then
    return nil
  end
  -- Return all of the door data or just the requested direction's; convert to LONG direction first
  if dir then
    return roomDoorData[LDIR[dir]] or nil
  else
    return roomDoorData
  end
end

-- If a door exists in the direction the player is attempting to move, open it
function openDoor( dir, keyword, key )
  local closeDir  = REVERSE[dir]
  local closeCode = f( [[send('close {keyword} {closeDir}', true)]] )
  if key then
    send( f( 'unlock {keyword} {dir}' ) )
  end
  send( f( 'open {keyword} {dir}' ), true )
  -- One-time trigger to close the door on the other side
  local testId = tempTrigger( [[Obvious Exits]], closeCode, 1 )
end
