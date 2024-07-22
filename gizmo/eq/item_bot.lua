--[[ item_bot.lua
-- Module to implement an in-game identification "bot" to identify items provided by other players;
-- Will need to implement some basic error-handling and inventory management to ensure people get
-- their items back and the bot doesn't get confsed or overwhelmed.
--]]

-- Global boolean and toggle to turn The Gizdex bot on and off
Gizdexing     = Gizdexing or false
GizdexVersion = "0.2"
function toggleGizdexing()
  Gizdexing = not Gizdexing
  if Gizdexing then
    cecho( "Gizdexing <yellow_green>ON<reset>" )
    enableTrigger( "Gizdex" )
  else
    cecho( "Gizdexing <orange_red>OFF<reset>" )
    disableTrigger( "Gizdex" )
  end
end

runLuaFile( 'gizmo/data/Profanity.lua' )
runLuaFile( 'gizmo/eq/item_bot_data.lua' )
runLuaFile( 'gizmo/eq/item_bot_id.lua' )
runLuaFile( 'gizmo/eq/item_bot_dialog.lua' )

function chatAd()
  local ads = {
    "I'm doing a thing and could use your help. Read about it. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "If you read this & feel compelled to help, tell me which part did the trick. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "Ever get the feeling like something awesome was about to happen? This isn't it, but you can help me while you wait. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "I think this might technically be against the rules, but it's probably just cool enough to get a pass. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "I can't do it without you. I probably can't do it with you either, but I definitely can't do it without you. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "I only had three reasons to get our of bed today and the other two are still in bed. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "You're not a wildcard. You're the card on the top of the deck with the instructions that I throw away. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "We were so poor, we used to use donkey dung for fuel and when the donkey dung ran out, we would have to burn the donkey. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "It's a big bloody stupid hat with a big bloody stupid curse on it. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "Be strong, sweet little one. Some day they will all be dead and you will do a shit on all of their graves. `ghttps://i.imgur.com/ToiR9Is.png`f",
    "How are you supposed to be a strong, thrilling, powerful warrior and love with a name like Jeff? `ghttps://i.imgur.com/ToiR9Is.png`f",
    "We have come up with a list of all the things we would like to change once the vampires are in charge. `ghttps://i.imgur.com/ToiR9Is.png`f",
  }
  -- Choose an ad at random
  local ad = ads[math.random( #ads )]
  -- Send the chosen ad
  send( "goss " .. ad )
end
