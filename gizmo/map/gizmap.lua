runLuaFile( f "{rootDirectory}map/data/area_dirs.lua" )
runLuaFile( f "{rootDirectory}map/data/door_data.lua" )
runLuaFile( f "{rootDirectory}map/data/unique_rooms.lua" )
culledExits = {}
table.load( 'C:/Dev/mud/mudlet/gizmo/data/culledExits.lua', culledExits )

-- For all rooms globally delete any exit which leads to its own origin (and store that exit in culledExits)
function cullLoopedExits()
  local allRooms = getRooms()
  for id, name in pairs( allRooms ) do
    local exits = getRoomExits( id )
    for dir, dst in pairs( exits ) do
      if dst == id then
        culledExits[id] = culledExits[id] or {}
        setExit( id, -1, dir )
        culledExits[id][dir] = true
      end
    end
  end
end

-- Follow a list of directions; also used by the click-to-walk functionality from the Mapper
function doSpeedWalk()
  for _, dir in ipairs( speedWalkDir ) do
    if #dir > 1 then dir = SDIR[dir] end
    expandAlias( dir )
  end
end

-- Get a complete Wintin-compatible path between two rooms including door commands
function getFullDirs( srcID, dstID )
  -- Clear Mudlet's pathing globals
  speedWalkDir = nil
  speedWalkPath = nil

  -- Use Mudlet's built-in path finding to get the initial path
  local rm = srcID
  if getPath( srcID, dstID ) then
    -- Initialize a table to hold the full path
    local fullPathString1, fullPathString2 = "", ""
    local fullPath = {}
    for d = 1, #speedWalkDir do
      local dir = tostring( speedWalkDir[d] )
      local doors = getDoors( rm )
      if doors[dir] and doorData[rm] and doorData[rm][dir] then
        local doorInfo = doorData[rm][dir]
        -- If the door has a key associated with it; insert an unlock command into the path
        if doorInfo.key and doorInfo.key > 0 then
          table.insert( fullPath, "unlock " .. doorInfo.word )
        end
        -- All doors regardless of locked state need opening
        table.insert( fullPath, "open " .. doorInfo.word )
        table.insert( fullPath, dir )
        -- Close doors behind us to minimize wandering mobs
        table.insert( fullPath, "close " .. doorInfo.word )
      else
        -- With no door, just add the original direction
        table.insert( fullPath, dir )
      end
      -- "Step" to the next room along the path
      rm = tonumber( speedWalkPath[d] )
    end
    -- Convert the path to a Wintin-compatible command string
    fullPathString = createWintin( fullPath )
    return fullPathString
  end
  cecho( f "\n<firebrick>Failed to find a path between {srcID} and {dstID}<reset>" )
  return nil
end
