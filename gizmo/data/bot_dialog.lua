-- Shorthand consts for common dialog components w/ color codes
DB                         = "`fThe Archive`q"     -- Name of the item/mob/etc. database
CI                         = "`g{CurrentItem}`q"   -- Current item the bot is examining
CP                         = "`c{CurrentPlayer}`q" -- Current player the bot is interacting with

-- Format for "item inquiry" responses; must conform to the names of local variables in
-- the function where you use them obviously.
AFF                        = " `e{item.affectString}"           -- Affects (Blue)
FLG                        = " `b{item.flagString}"             -- Flags (Red)
STS                        = " `c{item.statsString}"            -- Stats (Yellow)
IDS                        = "`g{itm}{stats}{affects}{flags}`q" -- Assembled inquiry response w/ Item (Cyan)

BOT_DIALOG                 = {
  -- Messages to broadcast to the entire MUD, advertising The Archive and sharing instructions
  BETA = {
    messages = {
      "I'm doing a thing and could use your help. Read about it. `ghttps://i.imgur.com/ToiR9Is.png`q",
      "If you read this & feel compelled to help, tell me which part did the trick. `ghttps://i.imgur.com/ToiR9Is.png`q",
      "Ever get the feeling like something awesome was about to happen? This isn't it, but you can help me while you wait. `ghttps://i.imgur.com/ToiR9Is.png`q",
      "I can't do it without you. I probably can't do it with you either, but I definitely can't do it without you. `ghttps://i.imgur.com/ToiR9Is.png`q",
      "I only had three reasons to get out of bed today and the other two are still in bed. `ghttps://i.imgur.com/ToiR9Is.png`q",
      "You're not a wildcard. You're the card on the top of the deck, with the instructions, that I throw away. `ghttps://i.imgur.com/ToiR9Is.png`q",
      "We were so poor, we used to use donkey dung for fuel. And when the donkey dung ran out, we would have to burn the donkey. `ghttps://i.imgur.com/ToiR9Is.png`q",
      "It's a big bloody stupid hat with a big bloody stupid curse on it. `ghttps://i.imgur.com/ToiR9Is.png`q",
      "Be strong, sweet little one. Some day they will all be dead and you will do a shit on all of their graves. `ghttps://i.imgur.com/ToiR9Is.png`q",
      "How are you supposed to be a strong, thrilling, powerful warrior and lover with a name like Jeff? `ghttps://i.imgur.com/ToiR9Is.png`q",
      "We have come up with a list of all the things we would like to change once the vampires are in charge. `ghttps://i.imgur.com/ToiR9Is.png`q",
    }
  },
  HELP = {
    speech = {
      "`qThanks for your interest in {DB}! I hope it will grow to become a useful catalog of Gizmo knowledge.",
      "`qThe focus for now is learning as much as I can about `gItems & Equipment`q.",
      "`qIf you `kgive`q me an item, I'll identify it and try to add it to {DB}. If it's new to the archives, I might reward you for the effort.",
      "`qYou can also ask me what I know about an item. Just `ksay gdid <string>`q and I'll see what I can find.",
      "`qWhile {DB} is in `bBETA`q, I'll also pay bounties for contributions that expose gaps in the logic behind the scenes."
    }
  },
  -- Thank-you messages for when a new item is recorded
  NEW = {
    messages = {
      "Your contribution to {DB} is duly noted and much appreciated, {CP}.",
      "Your continued efforts to build {DB} will be remembered, {CP}.",
      "{DB} depends on folks like you, {CP}. We're' in your debt. I mean not anymore 'cause I just paid you, but you get it.",
      "Another entry in {DB}! Adventurers like {CP} do the hard part. I just write stuff down (then take credit later).",
      "Thanks, {CP}. At this rate {DB} is going to need a second volume soon! {DB} 2: Electric Boogaloo.",
      "This is the first {CI} I've ever seen, and {DB} will remember {CP} as the one who found it.",
      "I'd heard rumors of {CI}, but never thought I would lay eyes on it.",
      "{DB} is eternal, as shall be our gratitude to {CP} for tracking down {CI}.",
      "The cityguards will want to know where you got {CI}. Let's get our stories straight.",
      "You seem like the cast-first-ask-questions-later type, {CP}, so I'm not surprised you got your hands on {CI}.",
      "I can't believe I'm holding {CI}. I mean, I'm not now but I was just a second ago. Thank you, {CP}.",
      "Wow {CP}, I honestly didn't think I'd ever see {CI} in person. You're an absolute legend!",
      "Honestly I thought I had seen it all, then {CP} shows up on my doorstep with {CI}.",
      "Surely that's not really {CI}, {CP}? Nah, it definitely is and I'm sorry I called you Shirley.",
      "{DB} wouldn't exist without dedicated and certifiably insane adventurers like you, {CP}.",
      "I'm just going to jot down 'salvaged from shipwreck', {CP}. That should discourage too many follow-up questions.",
      "Is that a little blood I see on {CI}? Let me just wipe that off (along with any pesky fingerprints).",
      "I used to read about {CI} in storybooks as a child. I had a pretty boring childhood, though.",
      "{DB} swells with knowledge of these strange lands thanks to strange lads like {CP}.",
      "Is that really {CI}? Well, that's the second time I shit my pants today! No follow-up questions.",
    }
  },
  -- Inform the player their recent contribution was an alternate version of an existing item
  ALTERNATE = {
    messages = {
      "{CI} was already in {DB}, but this one looks a little different.",
      "Well, it's definitely {CI}, but not quite like ones I've seen before.",
      "I've got an entry here for {CI} but there's something a little off about this one.",
      "It looks like {CI} comes in more flavors than one!",
    }
  },
  -- Inform the player their recent contribution was a duplicate of an existing item
  DUPLICATE = {
    speech = {
      "Your efforts are appreciated {CP}, but {CI} had already been recorded in {DB}.",
      "Remember, you can always `ksay id <keyword>`q to inquire about items.",
    }
  },
  MODIFIED = {
    messages = {
      "Thanks {CP}, but for now {DB} isn't recording cloned, crafted, or bonded equipment.",
    }
  },
  -- Occasionally ask arriving players to contribute to the database
  INQUIRE = {
    messages = {
      "If you `kgive`q me an item, I'll add it to the `k{ArchivedItems}`q already in {DB}. Don't worry, you'll get it right back!",
      "`kgive`q me something to add to {DB} and I'll pass it back when I'm done (along with a few coins for your trouble perhaps).",
      "Got anything interesting I could check out? I'm always trying to expand {DB}'s record of `k{ArchivedItems}`q items.",
      "{DB} has recorded `k{ArchivedItems}`q items so far. Any chance you could help me add another?",
      "Have anything I might add to {DB}? If it's a new addition, I could make it worth your time.",
      "All the cool kids are helping out with {DB}. We've got `k{ArchivedItems}`q items so far. Got anything to add?",
      "We've added `k{ArchivedItems}`q items and counting to {DB}. If you've got anything new, I would love to take a look!",
    }
  },
  UNKNOWN_ITEM = {
    messages = {
      "Sorry, {Speaker}, but I'm not familiar with that item.",
    }
  },
  QUERY_LIMIT = {
    messages = {
      "{DB} has a lot of items like that. Here are the first {MAX_QUERY} I found.",
    }
  },
  FETCH_QUEST = {
    messages = {
      "I would love to get my hands on `g{item}`q from {mobString}.",
      "See if you can bring me `g{item}`q from {mobString}.",
      "I would be most grateful if you could retrieve `g{item}`q from {mobString}.",
      "I'm desperately in need of `g{item}`q from {mobString}.",
      "I've really been lookin' for `g{item}`q from {mobString}.",
    }
  },
  SEMICOLON = {
    messages = {
      "A semicolon, really? That's not even my command character.",
    }
  },
  PROFANITY = {
    messages = {
      "Wow {CP}, do you kiss my mother with that mouth?",
    }
  },
}
local dropShadowCharacters = "╠╣╚═╝╚═╝╚═╝╚═╝╚═════╝╚═╝╚═╝╚═╝╚═══╝╚══════╝╔╗║THE"
local textCharacters       = "█"

ArchiveLogo                = [[
 ┌───┐                                                                                         ┌───┐
 │░▒▓├─────────────────────────────────────────────────────────────────────────────────────────┤▓▒░│
 │░▒▓│                    THE                                                                  │▓▒░│
 │░▒▓│                   █████╗ ██████╗  ██████╗██╗  ██╗██╗██╗   ██╗███████╗                   │▓▒░│
 │░▒▓│                  ██╔══██╗██╔══██╗██╔════╝██║  ██║██║██║   ██║██╔════╝                   │▓▒░│
 │░▒▓│                  ███████║██████╔╝██║     ███████║██║██║   ██║█████╗                     │▓▒░│
 │░▒▓│                  ██╔══██║██╔══██╗██║     ██╔══██║██║╚██╗ ██╔╝██╔══╝                     │▓▒░│
 │░▒▓│                  ██║  ██║██║  ██║╚██████╗██║  ██║██║ ╚████╔╝ ███████╗                   │▓▒░│
 │░▒▓│                  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝  ╚══════╝                   │▓▒░│
 │░▒▓│                 Interactive Knowledgebase for Gizmo DikuMUD     v0.1                    │▓▒░│
 │░▒▓├─────────────────────────────────────────────────────────────────────────────────────────┤▓▒░│
]]

ArchiveBottom              = [[

 <ansi_light_black>│░▒▓├─────────────────────────────────────────────────────────────────────────────────────────┤▓▒░│
 └───┘                                                                                         └───┘<reset>
]]

textColor                  = "<indian_red>"
dropShadowColor            = "<maroon>"
defaultColor               = "<ansi_light_black>"

-- Create a "colorized" version of The Archive Logo by iteratively replacing
-- characters with corresponding color codes (only when necessary to change from
-- one color to the next).
function createColorizedLogo()
  -- Helper function to iterate over UTF-8 characters
  local function utf8Iterator( s )
    local i = 1
    return function ()
      if i > #s then return nil end
      local c = s:sub( i, i )
      if c:byte() >= 128 then
        local charByteCount = 0
        if c:byte() >= 240 then
          charByteCount = 4
        elseif c:byte() >= 224 then
          charByteCount = 3
        elseif c:byte() >= 192 then
          charByteCount = 2
        end
        c = s:sub( i, i + charByteCount - 1 )
        i = i + charByteCount
      else
        i = i + 1
      end
      return c
    end
  end
  local colorMap = {}
  for char in utf8Iterator( dropShadowCharacters ) do
    colorMap[char] = dropShadowColor
  end
  for char in utf8Iterator( textCharacters ) do
    colorMap[char] = textColor
  end
  local currentColor = defaultColor
  local outputString = currentColor

  for char in utf8Iterator( ArchiveLogo ) do
    local charColor = colorMap[char] or defaultColor
    if charColor ~= currentColor then
      outputString = outputString .. charColor
      currentColor = charColor
    end
    outputString = outputString .. char
  end
  return outputString
end

-- Convert and print a colorized logo
function printColoredLogo()
  local taggedLogo = createColorizedLogo()
  cecho( taggedLogo )
end

-- This function is designed to add content between the logo above and the
-- bottom border below, this content will come from an external text file and
-- should be processed such that it "fits" within the design of the log.
function assembleArchiveInfo()
  -- This table is used by insertInfoPage while processing the info text file to
  -- add colorization to specific words or phrases. To add the highlight, this function
  -- should replace the keys with their values.
  local highlightSubstitutions = {
    ["The Archive"] = "<ansi_magenta>The Archive<reset>",
    ["Nadja"] = "<firebrick>Nadja<reset>",
    ["╔╝"] = "<gold><b>╔╝</b><reset>",
    ["THE WHAT%?"] = "<maroon>THE WHAT?<reset>",
    ["HOW DO%?"] = "<maroon>HOW DO?<reset>",
    ["AND THEN%?"] = "<maroon>AND THEN?<reset>",
    ["BUT WHY THO%?"] = "<maroon>BUT WHY THO?<reset>",
    ["say ID %<item%>"] = "<gold>say ID <item><reset>",
    ["│░▒▓│"] = "<ansi_light_black>│░▒▓│<reset>",
    ["│▓▒░│"] = "<ansi_light_black>│▓▒░│<reset>",
    ["bounty"] = "<gold>bounty<reset>",
    ["bounties"] = "<gold>bounties<reset>",
    ["%d"] = function ( d ) return "<gold>" .. d .. RC end
  }

  local function readInfoFile( filePath )
    local file = io.open( filePath, "r" )
    if not file then
      error( "Failed to open the file: " .. filePath )
    end
    local content = file:read( "*all" )
    file:close()
    return content
  end

  local function formatContent( content )
    local lcol = " │░▒▓│ "
    local lcoln = utf8.len( lcol )
    local rcol = " │▓▒░│"
    local rcoln = utf8.len( rcol )
    local formattedContent = {}
    for contentLine in content:gmatch( "([^\r\n]*)[\r\n]?" ) do
      local len = utf8.len( contentLine ) + lcoln + rcoln
      local pad = 100 - len
      local formattedLine = lcol .. contentLine .. string.rep( " ", pad ) .. rcol
      table.insert( formattedContent, formattedLine )
    end
    return table.concat( formattedContent, "\n" )
  end

  local function applySubstitutions( text, substitutions )
    for key, value in pairs( substitutions ) do
      text = text:gsub( key, value )
    end
    return text
  end

  -- Read the content from ArchiveInfo.lua
  local infoContent = readInfoFile( f "{DATA_PATH}/ArchiveInfo.txt" )

  -- Format lines
  infoContent = formatContent( infoContent )

  -- Apply highlight substitutions
  infoContent = applySubstitutions( infoContent, highlightSubstitutions )

  -- Print the content
  printColoredLogo()
  cecho( infoContent )
  cecho( ArchiveBottom )
end
