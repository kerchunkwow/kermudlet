-- A table to track demerits issued to players who violate bot etiquette such as
-- trying to get it to say dirty words or give away equipment belonging to others
Demerits = {}
table.load( f [[{DATA_PATH}/BotDemerits.lua]], Demerits )

-- A list of players the bot is currently ignoring due to repeated etiquette violations
Blacklist = Blacklist or {}

-- Issue a demerit to a player & write the data file
function issueDemerit( pc )
  if Demerits[pc] == nil then
    Demerits[pc] = 1
  else
    Demerits[pc] = Demerits[pc] + 1
  end
  table.save( f [[{DATA_PATH}/BotDemerits.lua]], Demerits )
end

-- Table to store the Gizmo in-game chat color codes; probably a better place for this later
CHAT_COLORS = {
  ['a'] = {"black"},
  ['b'] = {"red"},
  ['c'] = {"green"},
  ['d'] = {"yellow"},
  ['e'] = {"blue"},
  ['f'] = {"magenta"},
  ['g'] = {"cyan"},
  ['h'] = {"white"},
  ['i'] = {"light_red"},
  ['j'] = {"light_green"},
  ['k'] = {"light_yellow"},
  ['l'] = {"light_blue"},
  ['m'] = {"light_magenta"},
  ['n'] = {"light_cyan"},
  ['o'] = {"light_gray"},
  ['p'] = {"light_black"},
  ['q'] = {"reset"},
}

-- Pass a string through a simple profanity filter to see if it should be excluded from output
function checkProfanity( inputString )
  for _, pattern in ipairs( ProfanePatterns ) do
    if string.match( inputString, pattern ) then
      return true
    end
  end
  return false
end
