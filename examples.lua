-- One of the most important elements of Lua is the table. Tables hold data and allow you to access
-- and update it while you play. Tables in Lua can take on many forms, each with their own use
-- cases. This module looks at the most basic type of table in Lua: the indexed list, or Array.

-- Defining an Array is as simple as providing a list of strings or values:
local GroupMembers = {"Kaylee", "Wash", "River", "Jayne", "Malcolm"}

-- To access a value, you use its index; Lua uses 1-based Arrays, so to see the first element:
print( GroupMembers[1] ) -- Kaylee

-- Using = you can directly reassign values at specific indices within an Array:
GroupMembers[4] = "Simon"
print( GroupMembers[4] ) -- Simon

-- With table.insert, you can add a new value to the end of an Array:
table.insert( GroupMembers, "Zoe" )
print( GroupMembers[6] ) -- Zoe

-- To keep track of the contents of your table, you can use Mudlet's built-in display function:
display( GroupMembers ) -- { "Kaylee", "Wash", "River", "Simon", "Malcolm", "Zoe" }

-- For simple tables (like Arrays), you can also use Lua's print in conjunction with table.concat
-- to print quick formatted lists.
print( table.concat( GroupMembers, ", " ) ) -- Kaylee, Wash, River, Simon, Malcolm, Zoe

-- Lua's # operator will tell you the "length" of the Array, or how many members it has:
local numMembers = #GroupMembers
print( numMembers ) -- 6

if numMembers >= 5 then
  print( f "{numMembers} in group enables xp bonus!" )
end
-- You can also remove elements from an array; notably, this will shift all other elements "left"
-- to fill the gap:
table.remove( GroupMembers, 2 )
print( table.concat( GroupMembers, ", " ) ) -- Kaylee, River, Simon, Malcolm, Zoe

-- Alternatively, you can use the # operator to add an item to a list "just beyond the last item"
GroupMembers[#GroupMembers + 1] = "Book"

-- You can sort tables:
table.sort( GroupMembers )
print( table.concat( GroupMembers, ", " ) ) -- Book, Kaylee, Malcolm, River, Simon, Zoe

-- One of the most common use cases for arrays of all types, but especially indexed arrays, is
-- iterating through each member in the list in order to perform an action or verify some
-- condition.

-- This for loop starts at the first index (1) and increments by 1 until it reaches the last index.

-- If you need a value from the table several times, it's usually better to store it in a local variable.
-- Although the difference on modern PCs is rarely important, it's technically faster to access a local
-- variable than to "retrieve" an element from a table.

-- Get used to the visual and conceptual relationship between "local" and indentation. Here, 'member' only
-- has meaning within this for loop. Once the loop ends, this local definition ceases to exist; the variable
-- will be nil or take the meaning it had outside the loop. Put another way, local variables temporarily
-- "override" the meaning of variables with the same name in the higher scope. This is why it's important to
-- use locals any time you only need a variable within a specific context, to avoid conflict with variables
-- of the same name in higher scopes.

ship = "Serenity"
for i = 1, #GroupMembers do
  local ship = "Firefly"
  local member = GroupMembers[i]
  print( f "Greetings, {member}." )
  if member == "River" then
    -- Locally, ship is 'Firefly'
    print( f "Hey {member}! I remember you from {ship}." )
  end
end
print( f "Here, member == {member} since we're past the scope of the loop." )
-- Globally, ship is 'Serenity' again
print( f "But ship == {ship}, since it has meaning in the 'larger' scope outside the loop." )
-- To delete a variable, like this unwanted globa, set it to nil; this also works for tables
-- and functions.
ship = nil

-- Another common application for iteration with Arrays is to test for membership of a certain value.
local function isMember( list, member )
  -- For each item in the list, see if it matches the member parameter
  for i = 1, #list do
    if list[i] == member then
      print( f "{member} in Group at position {i}." )
      return -- Exit early once we have a match.
    end
  end
  -- If we never exited, the member wasn't found.
  print( f "{member} not in Group." )
end

isMember( GroupMembers, "Simon" ) -- Simon in Group at position 5.
isMember( GroupMembers, "Inara" ) -- Inara not in Group.

-- For a slightly more advanced use of Arrays, its easy to use them as a Stack or a Queue. Each of these
-- involves adding items to the list and removing them sequentially.

-- For a stack, you add and remove items from the top, also known as Last In, First Out or LIFO:
local Food      = {"bread"}
local Container = "bag"

-- Using send() instead of cecho(), this function could store food in your container, then add
-- it to your data stack; in stack parlance this is called "pushing" an item onto the stack.
local function storeFood( food )
  cecho( f "put {food} {container}\n" )
  table.insert( Food, food )
end

-- The opposite of push, this function "pops" an item off the top of the stack. In this case,
-- you could eat the most recent item you added to your stack with send() instead of cecho().
local function eatFood()
  local food = table.remove( Food )
  cecho( f "eat {food}\n" )
  if #Food == 0 then
    cecho( "You're out of food, time to hit the grocer.\n" )
  end
end

storeFood( "apple" )
storeFood( "cheese" )
print( table.concat( Food, ", " ) )
eatFood()
eatFood()
eatFood()

-- Queues are very similar to Stacks, but instead of LIFO they use a First In, First Out or FIFO
-- strategy, meaning the item removed will be the one that has been in the list the longest.

-- If for instance, you want to manage the turnin of quest items and the quest giver cares about
-- receiving them in the order they were collected, you could use a Queue:
local QuestItems = {}

-- Picking up a new item, you can put it in your container and then "enqueue" it in your list.
local function collectQuestItem( item )
  cecho( f "put {item} {Container}\n" )
  -- Enqueue the item
  table.insert( QuestItems, item )
end

-- When it's time to turn them in, you can use your Queue to unpack and hand them over.
local function completeQuest( questGiver )
  for i = 1, #QuestItems do
    -- Dequeue the item; by specifing "1" here, we're taking the item from the front of
    -- the list to create the FIFO behavior.
    local item = table.remove( QuestItems, 1 )
    cecho( f "get {item} {Container}\n" )
    cecho( f "give {item} {questGiver}\n" )
  end
end

collectQuestItem( 'key' )
collectQuestItem( 'scroll' )
collectQuestItem( 'gem' )
completeQuest( 'Fido' )
