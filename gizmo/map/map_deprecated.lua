function fixMinimumRoomNumbers()
  local aid = 0
  while worldData[aid] do
    local roomsData = worldData[aid].rooms
    local minRoom = nil
    for _, room in pairs( roomsData ) do
      local roomRNumber = tonumber( room.roomRNumber )
      if roomRNumber and (not minRoom or minRoom > roomRNumber) then
        minRoom = roomRNumber
      end
    end
    if minRoom and minRoom ~= worldData[aid].areaMinRoomRNumber then
      setMinimumRoomNumber( aid, minRoom )
    end
    aid = aid + 1
    -- Skip area 107
    if aid == 107 then aid = aid + 1 end
  end
end

-- Globally update room labels from orange-ish to royal_blue
function updateAllRoomLabels()
  local areaID = 0
  local modCount = 0
  while worldData[areaID] do
    modCount = modCount + updateLabelStyle( areaID, 255, 140, 0, 65, 105, 225, 8 )
    areaID = areaID + 1
    -- Skip area 107; it's missing from our database
    if areaID == 107 then areaID = areaID + 1 end
  end
  cecho( f "\n<dark_orange>{modCount}<reset> room labels updated." )
end

-- For a given area, update labels from an old color to a new color and size
function updateLabelStyle( id, oR, oG, oB, nR, nG, nB, nS )
  local areaLabels = getMapLabels( id )
  local labelCount = #areaLabels
  local modCount = 0
  -- Ignore missing areas and ones w/ no labels
  if areaLabels and labelCount > 0 then
    -- getMapLabels is zero-based
    for lbl = 0, labelCount do
      local labelData = getMapLabel( id, lbl )
      if labelData then
        local lR = labelData.FgColor.r
        local lG = labelData.FgColor.g
        local lB = labelData.FgColor.b
        -- Check for labels w/ old color
        if lR == oR and lG == oG and lB == oB then
          local lT = labelData.Text
          -- Round the coordinates to the nearest 0.025
          local lX = round( labelData.X )
          local lY = round( labelData.Y )
          local lZ = round( labelData.Z )
          -- Delete existing label and create a new one in its place using the new color & size
          deleteMapLabel( id, lbl )
          createMapLabel( id, lT, lX, lY, lZ, nR, nG, nB, 0, 0, 0, 0, nS, true, true, "Bitstream Vera Sans Mono", 255, 0 )
          modCount = modCount + 1
        end
      end
    end
    updateMap()
  end
  return modCount
end
