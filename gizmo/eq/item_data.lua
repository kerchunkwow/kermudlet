-- Parent table for ItemObjects; stored on disk for persistence between sessions
Items         = Items or {}
RejectedItems = RejectedItems or {}

-- Write the Items table to a datafile for session persistence
function saveItemData()
  table.save( f '{HOME_PATH}/gizmo/data/items.lua', Items )
  table.save( f '{HOME_PATH}/gizmo/data/rejected_items.lua', RejectedItems )
end

-- Load the Items data from the file on disk
function loadItemData()
  Items         = {}
  RejectedItems = {}
  ItemObject    = nil
  FullIDText    = nil
  table.load( f '{HOME_PATH}/gizmo/data/items.lua', Items )
  table.load( f '{HOME_PATH}/gizmo/data/rejected_items.lua', RejectedItems )
end

-- Make a backup copy of the Items data file as a safeguard
function backupItemData()
  local srcFile = [[C:\\Dev\\mud\\mudlet\\gizmo\\data\\items.lua]]
  local dstDir  = [[C:\\Dev\\mud\\gizmo\\data\\backup\\items]]
  backupFile( srcFile, dstDir )
  srcFile = [[C:\\Dev\\mud\\mudlet\\gizmo\\data\\rejected_items.lua]]
  tempTimer( 2, function ()
    backupFile( srcFile, dstDir )
  end )
end

-- Uses the ITEM_SCHEMA table including its order attribute to display details about the current item;
-- useful for validation and feedback during development
function displayItem( tier, desc )
  local item = Items[desc]
  -- A local function to sort the keys in the ITEM_SCHEMA by order for structured output
  local function getOrderedKeys( schema )
    local keys = {}
    for key in pairs( schema ) do
      table.insert( keys, key )
    end
    table.sort( keys, function ( a, b )
      return schema[a].order < schema[b].order
    end )
    return keys
  end

  -- Compose a "title card" for the item including its core stats, flags, and affects
  local sstr = compositeString( "", item.shortDescription, "<green_yellow>" )
  sstr       = compositeString( sstr, item.statsString, "<dark_slate_grey>" )
  sstr       = compositeString( sstr, item.affectString, "<ansi_cyan>" )
  sstr       = compositeString( sstr, item.flagString, "<firebrick>" )
  sstr       = string.gsub( sstr, "ƒ", "<gold>ƒ<reset>" )
  local slen = cLength( sstr ) + 2
  local dg   = "<dim_grey>"
  hrule( slen, dg )
  cout( f "{dg}| {sstr}{dg} |" )
  hrule( slen, dg )

  if tier == -1 then return end
  local op = "<indian_red> = <reset>"
  local keys = getOrderedKeys( ITEM_SCHEMA )
  -- Iterate through the ITEM_SCHEMA based on the defined tier
  for _, key in ipairs( keys ) do
    local properties = ITEM_SCHEMA[key]
    if tier == nil or properties.tier <= tier then
      local value = item[key]
      local typ = ITEM_SCHEMA[key].typ
      -- Boolean values are important even when they're false
      if value or typ == "boolean" then
        local ks = f "{SC}{key}{RC}"
        local vs = nil
        local isNumber = type( value ) == "number" and (value ~= 0 or key == "cloneable" or key == "holdable")
        local isString = type( value ) == "string" and value ~= ""
        local isBig = isNumber and (value >= 10000 or value <= -10000)
        if isNumber and isBig then value = expandNumber( value ) end
        if type( value ) == "table" and next( value ) ~= nil then
          vs = f "{dg}{table.concat(value, ', ')}{RC}"
        elseif isNumber or isString then
          vs = f "{dg}{value}{RC}"
        end
        if vs then
          cout( f "{ks}{op}{vs}" )
        end
      end
    end
  end
end

-- Using cout(), display some useful stats about the Items data
function displayItemDataStats()
  local totalItems     = 0
  local baseTypeCounts = {}
  local totalWeight    = 0
  local totalValue     = 0

  for _, item in pairs( Items ) do
    totalItems = totalItems + 1
    -- Aggregate count of item by type
    local baseType = item.baseType or "Unknown"
    baseTypeCounts[baseType] = (baseTypeCounts[baseType] or 0) + 1
  end
  cout( f "\nItems identified: {NC}{totalItems}{RC}" )
  cout( "Items by type:" )
  for baseType, count in pairs( baseTypeCounts ) do
    cout( f "  {baseType}: {NC}{count}{RC}" )
  end
end

-- Insert a new ItemObject into the Items table
function insertItemObject( item )
  -- If we try to insert when Items doesn't exist, try to load the table first
  if not Items then loadItemData() end
  -- Treat short descriptions are unique, but store duplicate data for review later
  -- Possible future functionality could be a "comparison"
  local desc = item.shortDescription
  if Items[desc] then
    cout( f "\n<orange_red>Rejected{RC}: {SC}{desc}{RC} already in Items" )
    table.insert( RejectedItems, item )
    table.save( f '{HOME_PATH}/gizmo/data/rejected_items.lua', RejectedItems )
    return
  end
  cout( f "\n<green_yellow>Accepted{RC}: {SC}{desc}{RC} added to Items" )
  Items[desc] = item
  saveItemData()
  displayItemDataStats()
end

-- Delete an item by short description; epsecially useful during dev/testing when bad items are being added
function deleteItem( desc )
  if Items[desc] then
    Items[desc] = nil
    saveItemData()
    cout( f "\n<orange_red>Deleted{RC}: {SC}{desc}{RC} removed from Items" )
  else
    cout( f "\n<orange_red>Rejected{RC}: {SC}{desc}{RC} not found in Items" )
  end
end

-- Function to "start from scratch"; useful during development to get a clean
-- slate when fundamental design changes are made.
function clearItemData()
  Items         = {}
  RejectedItems = {}
  ItemObject    = nil
  FullIDText    = nil
  saveItemData()
  clearScreen()
end

-- To help identify items on the ground that are not yet in the database, this function
-- iterates through the Items table and compares the parameter to each known item's longDescription,
-- returning true if a match is found.
function itemIsKnown( longDescription )
  for _, item in pairs( Items ) do
    if item.longDescription == longDescription then
      return true
    end
  end
  return false
end
