--[[ items.lua
Main "umbrella" module that organizes and orchestrates the loading of scripts related to the
identification, searching, and display of Item data.
--]]

-- Each ItemObject represents a single identified item; once identified the item will be inserted into the parent Items
-- table after validation
ItemObject = ItemObject or {}

-- Keep track of the most recently added item in case we want to "undo" an addition to correct for some
-- error in the identification process
LastItem = LastItem or nil

-- We need to hold the keyword we used to identify the object in a global so we can issue commands like drop/get using
-- that keyword (this allows us to identify sword and 2.sword for example)
IDKeyword = IDKeyword or nil

-- A global string to hold the full ID block since it appears over multiple variable lines (see: appendID())
FullIDText = FullIDText or ""

-- Invoked from the Mudlet command line to identify multiple items in succession by holding keywords in a list and iterating
-- through them after each successful identify is completed.
IDQueue = IDQueue or nil

BusyString = "I'm busy with another item right now. Tell me RET {item} <keyword> to get your item back."

-- Boolean to track whether we're currenting processing an item contribution;
-- we will need to prevent other players from contributing while we're working
-- on an item.
ProcessingItem = ProcessingItem or true

-- The player responsible for the current/most recent item contribution.
Contributor = Contributor or nil

function loadItemDataModule()
  local itemScripts = {
    'gizmo/eq/item_const.lua',
    'gizmo/eq/item_data.lua',
    'gizmo/eq/item_capture.lua',
    'gizmo/eq/item_display.lua',
    'gizmo/eq/eq_db.lua',
    'gizmo/eq/item_bot.lua',
  }
  -- Run the various sub-scripts for the Items module
  runLuaFiles( itemScripts )
  -- Load all the data files
  loadDataFiles( true )
end

loadItemDataModule()
