-- Create a local copy of this file named client_config.lua in this location; customize it to your
-- local environment and preference, and make sure it's in your .gitignore so we don't cross streams.

pcNames = {"Colin", "Nadja", "Laszlo", "Nandor"}

-- Make sure to keep these container names up to date
if session == 1 then
  container = "stocking"
elseif session == 2 then
  container = "sack"
elseif session == 3 then
  container = "bag"
elseif session == 4 then
  container = "bag"
end
waterskin = "waterskin"
food      = "bread"
