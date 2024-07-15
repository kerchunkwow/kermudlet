function addRejectedItem( item )
  table.insert( RejectedItems, item )
  FILE_STATUS.RejectedItems.mss = true
  FILE_STATUS.RejectedItems.msb = true
end

-- Insert a new ItemObject into the Items table (or RejectedItems if it exists)
function addItemObject( item )
  -- If an item with the same short already appears in the archives; do a deep compare to
  -- see if they are identical.
  local desc = item.shortDescription
  local foundItem = Items[desc]
  if foundItem then
    -- If the items are exactly identical, we don't want to store any data
    if deepCompare( foundItem, item ) then
      rejectDuplicate()
    end
    return
  end
  cout( f "\n<green_yellow>Accepted{RC}: {SC}{desc}{RC} added to Items" )
  insertData( "Items", desc, item )
  LastItem = desc
end

-- If we're in "bot" mode, we will need to make sure to return duplicate items to their owner(s)
function rejectDuplicate()
end

-- Delete an item by short description; epsecially useful during dev/testing when bad items are being added
function deleteItem( desc )
  if Items[desc] then
    Items[desc] = nil
    cout( f "\n<orange_red>Deleted{RC}: {SC}{desc}{RC} removed from Items" )
  else
    cout( f "\n<orange_red>Rejected{RC}: {SC}{desc}{RC} not found in Items" )
  end
end

-- Delete the most recently added item from the Items table (good for "undo" of badly captured items)
function deleteLastItem()
  if LastItem then
    deleteItem( LastItem )
  else
    cout( f "\n<orange_red>Rejected{RC}: No items to delete" )
  end
end

-- This function does a slightly more thorough comparison between an incoming item and existing items in
-- the database to help identify duplicates and potentially items with variable stats that could be merged
function itemKnown( newItem )
  local newItemName = newItem.shortDescription
  local existingItem = Items[newItemName]
  -- If there's another item with the same short description, evaluate true equality by comparing the
  -- longDescription, baseType, and worn location of both items.
  if existingItem then
    if existingItem.longDescription == newItem.longDescription and
        existingItem.baseType == newItem.baseType and
        existingItem.worn == newItem.worn then
      deepCompare( existingItem, newItem )
    end
  end
end

-- Compare two tables which might contain tables
function deepCompare( t1, t2 )
  -- tbl to hold diff
  local d = {}

  -- recursive compare
  local function compare( v1, v2, k )
    -- for tables; compare sub-pairs
    if type( v1 ) == "table" and type( v2 ) == "table" then
      for sk, sv1 in pairs( v1 ) do
        local sv2 = v2[sk]
        compare( sv1, sv2, k .. "." .. sk )
      end
      -- check for sub-keys in v2 not in v1
      for sk in pairs( v2 ) do
        if v1[sk] == nil then
          table.insert( d, k .. "." .. sk )
        end
      end
    else
      -- compare non-tables directly
      if v1 ~= v2 then
        table.insert( d, k )
      end
    end
  end

  -- compare pairs in t1 to t2
  for k, v1 in pairs( t1 ) do
    local v2 = t2[k]
    compare( v1, v2, k )
  end
  -- then check for keys in t2 not in t1
  for k in pairs( t2 ) do
    if t1[k] == nil then
      table.insert( d, k )
    end
  end
  -- For now, just return a boolean indicating whether the tables are identical; later
  -- it might be useful to do something with the differences
  if #d == 0 then
    return true
  else
    return false
  end
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

-- Simple helper to determine if an item falls into a consumable baseType
function consumable( type )
  return type == "POTION" or type == "SCROLL" or type == "WAND" or type == "STAFF"
end

-- Item names (short descriptions) in game include modifying strings which indicate additional properties of items
-- these are not relevant to our purpose and will not be stored in the database, so this function exists to trim & discard
-- e.g., The Sword of Truth (glowing) (humming) -> The Sword of Truth
function trimItemName( name )
  -- Look for known modifiers
  local flags = {"%(glowing%)", "%(humming%)", "%(invisible%)", "%(cloned%)", "%(lined%)", "%(blue%)"}

  -- Strip them off the end of the name
  for _, flag in ipairs( flags ) do
    name = string.gsub( name, flag, '' )
  end
  -- Item names can also vary when they are modified by jewelcrafting (e.g., with a buckle);
  -- here we trim that content so we can match the raw name in the database
  name = string.gsub( name, ' with %w+ %w+ buckle', '' )
  return trimCondense( name )
end
