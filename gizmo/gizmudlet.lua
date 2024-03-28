extractedPatterns = {
  ['Filters & Format'] = {},
  ['Soft Mute'] = {[[^\.\.\.\.\.\..*$]], [[^The Reaper appears and escorts .+ to the afterlife!$]], [[^Your blood freezes as you hear .+ death cry\.$]], [[(?:^|> )\w+ .*? water from a fountain\.$]], [[(?:^|> )\w+ gets some stuff from .+\.$]], [[^You turn your eyes away as you see .+ decapitate the corpse\.$]], [[^.+'s sword draws light from the surroundings, and darkens the world.$]], [[(?:^|> ).*You eat the.*\.$]], [[(?:^|> ).*You are full\.$]], [[(?:^|> )\w+ gets out his trusty comb.*$]], [[(?:^|> )There is no more room for it\.$]], [[(?:^|> )Your stomach can't contain anymore!$]], [[(?:^|> )You drink the water\.$]], [[(?:^|> )You do not feel thirsty\.$]], [[(?:^|> )You get a .*? from a .*?$]], [[(?:^|> )As the moonlight touches it.*$]], [[(?:^|> )\w+ is drained by \w+ Lantern!$]]},
  ['Misses & Avoidance'] = {[[\sdodges\s.+\sattack!$]], [[\smiss(?:es)?\s.+\with]], [[^\w+ parries .+ attack!$]]},
  ['Notable Errors'] = {[[^No way! You are fighting for your life!$]], [[^You can't summon enough energy to cast the spell.$]]},
  ['Mute Alternates'] = {[[(?:^|> )(\w+) (?:eats|drinks|fills|gets|puts|has arrived|sits|stops|wields|flies|rides|leaves).*$]]},
  ['Main Format'] = {},
  ['Capture Chat'] = {[[^(?:\*\* )?(\w+) (?:\[|\()?(auction|quest|gossip|says?|tells?|replies)(?: |\)|\])*(?:your group|\w+)?,? *(.+?)\.*$]]},
  ['Melee Hits'] = {[[^(?!.*\smiss(?:es)?\s)(.*\s(hits?|bruises?|crush(?:es)?|demonstrates?|dices?|pierces?|pounds?|slash(?:es)?|whips?)\W.*)$]], [[^(\w+) paints the walls(.*)$]]},
  ['Weak'] = {[[((very|extremely|incredibly) hard)]], [[(knocks? .+ back a few steps)]]},
  ['Moderate'] = {[[(massacres?|obliterates?|decimates?|utterly annihilates?|inflicts a flesh wound)]]},
  ['Strong'] = {[[(paints the walls|evokes a blood-curdling scream|seeing little birdies|crying for \w+ mommy|splatters chunks|starts seeing double|tissue paper|so darn hard)]]},
  ['Epic'] = {[[(the meaning of true suffering|rearranges .+ innards|into dark oblivion|REAL BAD|paints the walls|brink of death|Colin was here)]]},
  ['Ability Success'] = {[[^((\w+) pummels (.+) and \w+ is stunned!)$]], [[^((\w+) tumbles into (.+), knocking .+ across the room!)$]], [[^((\w+) attacked (.+) suddenly and took .+ by surprise\.)$]], [[^((\w+) takes (.+) and crushes .+ with .+ head\.\.\.Blood Everywhere!!)$]], [[^(You are amazed at (.+) skill as (.+) scores a riposte!)$]], [[^((.+) smashes .+ head against (.+)\.)$]], [[^((\w+)'s roundhouse kick hits (.+) in the.*)$]], [[^((\w+) kicks (.+) in the.*!)$]], [[^.+ fell into an ambush by .+\.$]]},
  ['Ability Failures'] = {[[^((.+) tries to kick (.+) in the (.+)\, but misses .*)$]], [[^((.+) tries to grab (.+) for a headbutt, but misses .*)$]], [[^((.+) tries to pummel (.+), but misses.*)$]], [[^((.+) tries to tumble into (.+), but misses horribly\.)$]], [[^(.+) tries to assault (.+), but fails!$]]},
  ['Incap'] = {[[^(.+) is mortally wounded, and will die soon, if not aided\.$]], [[^(.+) is stunned, but will probably regain consciousness again\.$]], [[^(.+) is incapacitated and will slowly die, if not aided\.$]]},
  ['Criticals!'] = {[[^(Without hesitation, (.+) drives? .*)$]], [[^(With well-honed perception, (.+) places? .*)$]], [[^(With superhuman accuracy, (.+) .*)$]], [[^(With cat-like battle instinct, (.+) .*)$]]},
  ['Noteworthy Procs'] = {[[^.+ doubles over in pain as .+ root chakra begins eating .+ crown chakra!]], [[^The act of witnessing the massive damage .+ inflicted drives .+ BERSERK!!$]], [[^The precision blow realigns .+\'s chakra!$]], [[^Learning by doing, .+ now hits with more precision!$]], [[^You have learned this opponent by rote, anticipating every move before it is made against you.$]]},
  ['Spell Casting'] = {[[^.+ screams loudly (?:as|when) .+$]], [[^.+ hands crackle with electricity\.$]], [[^.+ pitches a ball of magical ice at .+!$]], [[^\w+ disappears\.$]], [[^\w+ utters the words, '.+'$]], [[^.+ wavers under the impact of the lightning bolt sent by .+\.$]]},
  ['Rewards'] = {[[^\w+ splits (.+) coins to the group.$]], [[^You gained (\d+) experience points for the kill\.$]]},
  ['Alt Gags'] = {},
  ['Mute Hits'] = {[[^(?!.*\smiss(?:es)?\s)(.*\s(hits?|bruises?|crush(?:es)?|demonstrates?|dices?|pierces?|pounds?|slash(?:es)?|whips?)\W.*)$]]},
  ['Mute Chat'] = {[[^(?:\*\* )?(\w+) (?:\[|\()?(auction|quest|gossip|says?|tells?|replies)(?: |\)|\])*(?:your group|\w+)?,? *(.+?)\.*$]]},
  ['Mute Rewards'] = {[[^(.+) splits (.+) coins to the group.$]]},
  ['Mute Abilities'] = {[[^(\w+) pummels (.+) and \w+ is stunned!$]], [[^(\w+) tumbles into (.+), knocking .+ across the room!$]], [[^(\w+) attacked (.+) suddenly and took .+ by surprise\.$]], [[^(\w+) takes (.+) and crushes .+ with .+ head\.\.\.Blood Everywhere!!$]], [[^You are amazed at (.+) skill as (.+) scores a riposte!$]], [[^(.+) smashes .+ head against (.+)\.$]], [[^(.+) tries to kick (.+) in the (.+)\, but misses .*$]], [[^(.+) tries to grab (.+) for a headbutt, but misses .*$]], [[^(.+) tries to pummel (.+), but misses.*$]], [[^(.+) tries to tumble into (.+), but misses horribly\.$]], [[^(.+) tries to assault (.+), but fails!$]]},
  ['Mute Casting'] = {[[^(.+) screams loudly as (.+) burns .+ with blue fire!$]], [[^(.+) hands crackle with electricity\.$]], [[^(.+) screams loudly when (.+) touches him\.$]], [[^(.+) pitches a ball of magical ice at (.+)!$]], [[^(.+) screams loudly as magical ice freezes .+!$]], [[^(\w+) disappears\.$]], [[^(\w+) utters the words, '(.+)'$]]},
  ['Basic Reactions'] = {},
  ['hunger'] = {[[^You are hungry.$]]},
  ['thirst'] = {[[^You are thirsty.$]]},
  ['fountain'] = {[[^\[1\] A small white fountain is standing at the end of the road.$]]},
  ['gather'] = {[[^\[\d\] A bit of Labdanum (resin) clings to the edge of a shrub.]]},
  ['afk'] = {[[You are hereby removed, come again!$]]},
  ['Utility'] = {},
  ['PC Login'] = {[[Based on DikuMUD I (GAMMA 2.5) by]], [[Staerfeldt, Nyboe, Madsen,]], [[Seifert, and Hammer]]},
  ['status'] = {},
  ['Affects'] = {},
  ['AffectApllied'] = {[[(?:^|> )You start (glowing)\.$]], [[(?:^|> )You feel (righteous)\.$]], [[(?:^|> )You feel very (angry)\.$]], [[(?:^|> )You feel someone (protecting) you\.$]]},
  ['AffectExpired'] = {[[(?:^|> )You feel less (protected)\.$]], [[(?:^|> )You feel less (righteous)\.$]], [[(?:^|> )You (calm) down\.$]], [[(?:^|> )The white (aura) around your body fades\.$]]},
  ['Capture Affects'] = {},
  ['ResetAffects'] = {[[^You are not affected by any spell\.$]]},
  ['UpdateAffect'] = {[[^\s*(\w+)\s*expires in\s*(\d+) hours$]]},
  ['End Capture Affects'] = {[[^<]]},
  ['Prompt Filter'] = {[[^< \d+\(]]},
  ['Prompt Capture'] = {[[^<\s*(\d+)\((\d+)\)\s*(\d+)\((\d+)\)\s*(\d+)\((\d+)\)\s*(?:Buf\:(\w+))?\s*(?:Vic\:(\w+))?\s*>.*?$]]},
  ['Parse Score'] = {[[\s+Damroll:\s+([\d|.]+)\s+Hp:\s+(?:\()?(\d+).*$]], [[\s+Hitroll:\s+([\d|.]+)\s+Mp:\s+(?:\()?(\d+).*$]], [[\s+Armor:\s+(-?[\d|.]+)\s+Mv:\s+(?:\()?(\d+).*$]], [[\s+Min AC:\s+(-?[\d|.]+).*$]], [[\s+Align:\s+(-?[\d|.]+).*$]], [[\s+Exp:\s+(-?[\d|.|,]+).*$]], [[\s+Exp/Hour:\s+(-?[\d|.|,]+).*$]], [[\s+Exp TNL:\s+(-?[\d|.|,]+).*$]], [[\s+Gold:\s+(-?[\d|.|,]+).*$]]},
  ['Tick Messages'] = {[[(?:^|>\s*)The sky is getting cloudy\.$]], [[(?:^|>\s*)The sun slowly disappears in the west\.$]], [[(?:^|>\s*)The day has begun\.$]], [[(?:^|>\s*)The sun rises in the east\.$]], [[(?:^|>\s*)The night has begun\.$]]},
  ['Room Capture'] = {[[(?:^|> )([\w\s\,\-\']+)$]]},
  ['Spell Nullified'] = {[[^Your spell fails to penetrate his defenses.$]]},
  ['Group XP'] = {},
  ['autostand'] = {[[^(\w+) stops resting, and clambers.*$]]},
  ['autorest'] = {[[^(\w+) sits down and rests.$]], [[^(\w+) stops flying and rests.$]]},
  ['autoassist'] = {[[^\w+ assists (\w+).$]], [[^(\w+) attacked (.+) suddenly.*$]], [[^.+ fell into an ambush by Nordberg.$]], [[^(\w+) tries to assault (.+)\,.*$]]},
  ['autosplit'] = {[[^There was (\d+) coins.]]},
  ['EoC'] = {[[^.+ is dead! R\.I\.P\.$]]},
  ['Drebin Pummel'] = {[[^Nordberg tries to tumble.*$]], [[^Hocken tries to pummel.*$]], [[^Dillon tries to tumble.*$]], [[^Dillon tumbles.*$]]},
  ['Tank Condition (automira)'] = {[[\sBuf\:(\w+)\s]]},
  ['Backup Automira'] = {[[^Drebin utters the words, '(miracle)'$]], [[^Mac utters the words, '(miracle)'$]]},
  ['Target Condition'] = {[[\sVic\:(\w+)\s]]},
  ['autoconfig'] = {[[^You now follow (\w+)\.$]]},
  ['map'] = {},
  ['Locate Resin'] = {[[a small ball of Labdanum resin in (.+)\.+$]]},
  ['Validate Move (Exits)'] = {[[^\s*Obvious Exits:.*$]]},
  ['Validate Door (Ok)'] = {[[(?:^|>\s*)Ok\.$]]},
  ['Cancel Queue'] = {[[It seems to be locked\.$]], [[Alas, you cannot go that way\.$]], [[The guard humiliates you.*$]]},
  ['Home'] = {[[(?:^|>\s*)The Temple Of Midgaard$]]},
  ['eq'] = {},
  ['Disarmed'] = {[[^(\w+) grabs your weapon away and throws it on the floor!$]]},
  ['EQ Stats'] = {[[\[\d+\] (.+)$]], [[^<(?:worn|used|wielded|held).*>\s+(.+)$]]},
  ['Missing EQ'] = {[[-Nothing]]},
  ['_'] = {},
  ['Game'] = {},
  ['Combat & Group'] = {},
  ['Group Settings'] = {},
  ['Set Tank'] = {[[^stank ?(\w+)?$]]},
  ['Set Leader'] = {[[^sleader (\w+)$]]},
  ['Set Pummeler'] = {[[^spum (\w+)$]]},
  ['Set Mira'] = {[[^amira (.+)]]},
  ['ass'] = {[[^ass$]]},
  ['Basic PC Commands'] = {},
  ['Inventory'] = {[[^i$]]},
  ['Bakery Restock (food)'] = {[[^food$]]},
  ['Look'] = {[[^l$]]},
  ['Inspect EQ (insp)'] = {[[^insp (\w+)$]]},
  ['Save'] = {[[^save?$]]},
  ['Group'] = {[[^group$]]},
  ['Report'] = {[[^rep$]]},
  ['Stand'] = {[[^st$]]},
  ['Rest'] = {[[^rest?$]]},
  ['Score (sc)'] = {[[^sc$]]},
  ['Time'] = {[[^time$]]},
  ['Spells & Affects'] = {},
  ['MU Damage (mm)'] = {[[^mm$]]},
  ['ID Worn'] = {[[^idw (.+)$]]},
  ['Total Recall (wor)'] = {[[^wor$]]},
  ['All Rec Recall (rr)'] = {[[^rr$]]},
  ['UpdateAffects'] = {[[^aff$]]},
  ['Armor (arm)'] = {[[^arm ?(.+)?]]},
  ['Bless (bless)'] = {[[^bless ?(.+)?]]},
  ['Sanctuary (sanct)'] = {[[^sanct ?(.+)?]]},
  ['Fury'] = {[[^ff$]]},
  ['Endure (end)'] = {[[^end$]]},
  ['Restoration'] = {},
  ['Transfer Mana (mt)'] = {[[^mt$]]},
  ['Smart Heal (hh)'] = {[[^hh$]]},
  ['Miracle (mira)'] = {[[^mira$]]},
  ['session'] = {},
  ['Reload (reload)'] = {[[^reload$]]},
  ['Session Commands (*)'] = {[[^(all|col|nad|las|nan) (.+)$]]},
  ['lib'] = {},
  ['Run Lua File (rf)'] = {[[^rf (.+)$]]},
  ['Run Lua (lua)'] = {[[^lua (.*)$]]},
  ['Clear Screen (cls)'] = {[[^cls$]]},
  ['Save Layout (swl)'] = {[[^swl$]]},
  ['Simulate Output (sim)'] = {[[^sim (.+)$]]},
  ['List Fonts (lfonts)'] = {[[^lfonts$]]},
  ['Print Variables (pvars)'] = {[[^pvars$]]},
  ['Go Area (go)'] = {[[^go (.*)$]]},
  ['Map Sim'] = {},
  ['Fake Open'] = {[[^open (\w)$]]},
  ['Fake Close'] = {[[^close (\w+)$]]},
  ['Fake Unlock'] = {[[^unlock (\w+)]]},
  ['Look Full'] = {[[^ll$]]},
  ['Look Room'] = {[[^l$]]},
  ['Look Exit'] = {[[^l (n|s|e|w|u|d|\d+)$]]},
  ['Exits'] = {[[^ex$]]},
  ['Set Player Location (spl)'] = {[[^g (\d+)$]]},
  ['Virtual Recall'] = {[[^rr$]]},
  ['Cull Exit (ce)'] = {[[^ce (\w+)$]]},
  ['Set Room Char (src)'] = {[[^src (\w+)$]]},
  ['Add Label (lbl)'] = {[[^lbl(\w)? (\w+)(?: (.*))?$]]},
  ['Start Map Sim'] = {[[^mapsim$]]},
  ['Get Path (gp)'] = {[[^gp (.*)$]]},
  ['Look Direction'] = {[[^l (n|e|s|w|u|d)$]]},
  ['SetPlayerRoom (spr)'] = {[[^spr (\d+)$]]},
  ['EQ  Mode (eqm)'] = {[[^eqm$]]},
  ['Roll Dice (roll)'] = {[[^roll$]]},
  ['Nandor Gear Swap (nanswap)'] = {[[^nanswap$]]},
  ['Equipment (eq)'] = {[[^eq$]]},
  ['Super Put'] = {[[^putt (.+)$]]},
  ['Super Get'] = {[[^gett (.+)$]]},
  ['kermudlet_init'] = {},
  ['Movement (Map)'] = {},
  ['Num8: n'] = {},
  ['Num2: s'] = {},
  ['Num6: e'] = {},
  ['Num4: w'] = {},
  ['Num7: u'] = {},
  ['Num8: d'] = {},
  ['Num5: (stop)'] = {},
  ['Movement (Raw)'] = {},
  ['Labeling'] = {},
  ['Left (a)'] = {},
  ['Nudge Left (^a)'] = {},
  ['Right (d)'] = {},
  ['Nudge Right (^d)'] = {},
  ['Up (w)'] = {},
  ['Nudge Up (^w)'] = {},
  ['Down (s)'] = {},
  ['Down (^s)'] = {},
  ['Confirm (f)'] = {},
  ['Cancel (c)'] = {},
  ['Shift Rooms'] = {},
  ['Shift w'] = {},
  ['Shift e'] = {},
  ['Shift n'] = {},
  ['Shift s'] = {},
  ['Shift u'] = {},
  ['Shift d'] = {},
  ['Recenter (Num5)'] = {},
  ['Reset Map (CTRL-R)'] = {},
  ['Save Map (Num+)'] = {},
  ['Load Map (Num-)'] = {},
}

-- Soft Mute
deleteLine()

-- Misses & Avoidance
deleteLine()

-- Mute Alternates
triggerPCActivity()

-- Capture Chat
triggerRouteChat()

-- Strong
local subdmg = matches[2]
if subdmg == "crying for his mommy" then
  cecho( "👶🏻" )
elseif subdmg == "seeing little birdies" then
  cecho( "🕊️" )
elseif subdmg == "starts seeing double" then
  cecho( "👀" )
end
-- Epic
local subdmg = matches[2]
if subdmg == "brink of death" then
  cecho( "🪦" )
elseif subdmg == "paints the walls" then
  cecho( "🖌️" )
elseif subdmg == "into dark oblivion" then
  cecho( "🌀" )
end
-- Ability Failures


-- Incap
deleteLine()
incap_delay = true
tempTimer( 5, [[incap_delay = false]] )
cecho( f "\n<brown>{matches[2]} appears to be in need of urgent medical attention.<reset>" )

-- Criticals!
deleteLine()
cecho( f "\n<spring_green>{matches[3]} rolls a natural <deep_pink>20<reset>!" )

-- Mute Hits
deleteLine()

-- Mute Chat
deleteLine()

-- Mute Rewards
deleteLine()

-- Mute Abilities
deleteLine()

-- Mute Casting
deleteLine()

-- Basic Reactions
-- Triggers for basic PC reactions to common recurring events

-- hunger
triggerHunger()

-- thirst
triggerThirst()

-- fountain
triggerFountain()

-- gather
triggerGather()

-- afk
send( 'twiddle', false )

-- PC Login
runLuaFile( f "gizmo/config/login.lua" )

-- status
-- Triggers for capturing & updating data related to PC status such as health,
-- location, and spell affects

-- Affects
-- Keep track of spell effects through 'up' and 'down' messages

-- AffectApllied
triggerAffectApllied()

-- AffectExpired
triggerAffectExpired()

-- ResetAffects
triggerClearAffects()

-- UpdateAffect
triggerUpdateAffect()

-- End Capture Affects
disableTrigger( 'Capture Affects' )

-- Prompt Filter
-- Use a snippet of our prompt to enable the more complex pattern

-- Prompt Capture
triggerParsePrompt()

-- Parse Score
triggerParseScore()

-- Tick Messages
captureTick()

-- Room Capture
triggerCaptureRoom()

-- Spell Nullified
if SESSION == 2 or SESSION == 3 then
  send( "gt My magic doesn't seem very useful against this enemy." )
end
-- autostand
-- Editing & saving in-game causes sessions to inherit the enabled state; so adding some checks to the less frequent
-- patterns to re-disable it.
if SESSION ~= 1 then
  disableTrigger( "Group XP" )
  return
end
local stander = matches[2]

if (SESSION == 1) and (stander == gtank or stander == gleader) then
  expandAlias( "all stand", false )
end
-- autorest
-- Editing & saving in-game causes sessions to inherit the enabled state; so adding some checks to the less frequent
-- patterns to re-disable it.
if SESSION ~= 1 then
  disableTrigger( "Group XP" )
  return
end
if SESSION == 1 and matches[2] == gleader then
  expandAlias( "all rest", false )
end
--^(\w+) stops flying and rests.$
--^(\w+) sits down and rests.$

-- autoassist
local target_names = {
  ["a Threggi Worker"] = "threggi",
  ["a Frost Wyrm"] = "wyrm",
  ["Huge Purple Worm"] = "worm",
}

local immune = {
  ["Huge Purple Worm"] = true,
  ["a Frost Wyrm"] = true,
}


local target      = matches[3]
local target_name = target_names[target]

-- Editing & saving in-game causes sessions to inherit the enabled state; so adding some checks to the less frequent
-- patterns to re-disable it.
if SESSION ~= 1 then
  disableTrigger( "Group XP" )
  return
end
if not assist_delay then
  mu_mn = math.max( pcStatus[2]["currentMana"], pcStatus[3]["currentMana"] )

  assist_delay = true
  tempTimer( 2.7, [[assist_delay = false]] )
  expandAlias( f "all assist {gtank}", false )

  if not affectStatus[1]['Fury'] and pcStatus[1]["currentMana"] >= 150 then
    send( "cast 'fury'" )
  end
  -- If MU mana is high, open with a damage spell (unless the target is a cunt)
  if mu_mn >= 300 and not immune[target] then
    cecho( "info", "\n" .. f [[{target}]] )
    cecho( "info", "\n" .. f [[{immune[target]}]] )
    tempTimer( 2.6, [[aliasMUDps()]] )
  end
end
-- autosplit
if gleader then
  send( f "split {matches[2]}" )
end
-- EoC
autoManaTransfer()

-- Editing & saving in-game causes sessions to inherit the enabled state; so adding some checks to the less frequent
-- patterns to re-disable it.
if SESSION ~= 1 then
  disableTrigger( "Group XP" )
  return
end
-- Drebin Pummel
if SESSION == 1 then
  if pcStatus[4]["currentMana"] >= 150 then
    expandAlias( "nan cast 'barrage of blades'", false )
  elseif not pummeled then
    --else
    expandAlias( "nan pummel", false )
    pummeled = true
    tempTimer( 2.8, [[pummeled = false]] )
    --if pummel_timer then killTimer(pummel_timer) end
    --pummel_timer = tempTimer( 2.8, [[expandAlias( 'nan pummel', false )]] )
  end
end
-- Tank Condition (automira)
triggerAutoMira()

-- Backup Automira
if inCombat then
  backupMira = true
end
-- autoconfig
if SESSION == 1 then
  local newLeader = matches[2]
  expandAlias( f 'sleader {newLeader}', false )
  if newLeader == "Drebin" then
    expandAlias( 'stank Nordberg', false )
  elseif newLeader == "Billy" then
    expandAlias( 'stank Blain', false )
  end
  expandAlias( 'amira awful', false )
end
-- Locate Resin
local roomName = matches[2]
if isUnique( roomName ) then
  local id = UNIQUE_ROOMS[roomName]
  creplaceLine( f "<olive_drab>resin<reset>: {getRoomString( id, 2 )}" )
end
-- Validate Move (Exits)
if cmdPending then validateCmd( "move" ) end
displayExits( CurrentRoomNumber )

-- Validate Door (Ok)
if cmdPending then validateCmd() end
-- Cancel Queue
-- Cancel a walk in progress if something goes wrong.
clearQueue()

-- Home
setPlayerRoom( 1108 )
centerview( 1108 )

-- Disarmed
send( 'get all', false )

-- EQ Stats
itemQueryAppend()

-- _
--_

-- Set Tank
gtank = matches[2]

if gtank then
  -- Make sure tank is always capitalized.
  gtank = gtank:sub( 1, 1 ):upper() .. gtank:sub( 2 )
else
  gtank = "Nandor"
end
cecho( "info", "\n" .. f "[<slate_gray>Setting tank = <orange>{gtank}<reset>]" )

-- Set Leader
gleader = matches[2]

if gleader then
  -- Make sure tank is always capitalized.
  gleader = gleader:sub( 1, 1 ):upper() .. gleader:sub( 2 )
else
  gleader = "Colin"
end
cecho( "info", "\n" .. f "[<slate_gray>Setting leader = <royal_blue>{gleader}<reset>]" )

-- Set Pummeler
gpummeler = matches[2]
cecho( "info", f "\n[<slate_gray>Setting pummeler = <firebrick>{gpummeler}<reset>]" )

-- Set Mira
local miraSet = matches[2] or "bleeding"
miracleCondition = miraSet
cecho( "info", f "\n[<slate_gray>Setting mira = <cyan>{miracleCondition}<reset>]" )

-- ass
expandAlias( f "all assist {gtank}" )

-- Inventory
-- Before eq'ing; temporarily enable the eq database trigger family
expandAlias( [[all lua tempEnableTrigger( "EQDB", 5 )]], false )
expandAlias( "all inventory", false )
expandAlias( f "col examine stocking", false )
expandAlias( f "nad examine bag", false )
expandAlias( f "nan examine bag", false )
expandAlias( f "las examine bag", false )

-- Bakery Restock (food)
expandAlias( "all buy 21 bread", false )
expandAlias( "all eat bread", false )
expandAlias( "all putt all.bread", false )

-- Look
expandAlias( "all look", false )

-- Inspect EQ (insp)
tempEnableTrigger( "EQDB", 5 )
send( f "look {matches[2]}" )

-- Save
expandAlias( "all save", false )

-- Group
expandAlias( "all group", false )

-- Report
expandAlias( "all report", false )

-- Stand
expandAlias( "all stand", false )

-- Rest
expandAlias( "all rest", false )

-- Score (sc)
if SESSION == 1 then
  for pc = 1, 4 do
    pcStatus[pc]["currentHP"] = 1
    pcStatus[pc]["currentMana"] = 1
    pcStatus[pc]["currentMoves"] = 1
  end
end
-- Before scoring; temporarily enable the score-capture trigger.
expandAlias( [[all lua tempEnableTrigger( "Parse Score", 5 )]], false )
expandAlias( "all score", false )

-- Time
send( 'time', false )

-- MU Damage (mm)
aliasMUDps()

-- ID Worn
send( f "remove {matches[2]}" )
send( f "cast 'identify' {matches[2]}" )
send( f "wear {matches[2]}" )

-- Total Recall (wor)
send( [[cast 'total recall']], false )

-- All Rec Recall (rr)
expandAlias( [[all lua aliasReciteRecalls()]] )

-- UpdateAffects
aliasUpdateAffects()

-- Armor (arm)
aliasCastBuff( 'armor' )

-- Bless (bless)
aliasCastBuff( 'bless' )

-- Sanctuary (sanct)
aliasCastBuff( 'sanctuary' )

-- Fury
send( "cast 'fury'" )

-- Endure (end)
expandAlias( 'nan get milky bag', false )
expandAlias( 'nan quaff milky', false )

-- Transfer Mana (mt)
aliasManaTransfer()

-- Smart Heal (hh)
aliasSmartHeal()

-- Miracle (mira)
aliasMiracle()

-- Reload (reload)
reloadProfile()

-- Session Commands (*)
aliasSessionCommand()

-- Run Lua File (rf)
local luaFile = matches[2] .. '.lua'
runLuaFile( luaFile )

-- Run Lua (lua)
runLuaLine( matches[2] )

-- Clear Screen (cls)
clearScreen()

-- Save Layout (swl)
saveWindowLayout()

-- Simulate Output (sim)
simulateOutput()

-- List Fonts (lfonts)
listFonts()

-- Print Variables (pvars)
printVariables()

-- Go Area (go)
goArea( matches[2] )

-- Fake Open
local door = matches[2]
cecho( f "\n<ansi_light_magenta>open {door}" )

-- Fake Close
local door = matches[2]
cecho( f "\n<ansi_magenta>close {door}" )

-- Fake Unlock
local door = matches[2]
cecho( f "\n<gold>unlock {door}" )

-- Look Full
local desc = getRoomUserData( CurrentRoomNumber, 'roomDescription' )
local extra = getRoomUserData( CurrentRoomNumber, 'roomExtraKeyword' )
local flags = getRoomUserData( CurrentRoomNumber, 'roomFlags' )
cecho( f "\n\n{getRoomString(CurrentRoomNumber,2)}" )
cecho( f "\n<olive_drab>{desc}<reset>" )
cecho( f "\n<dim_grey>Extra keywords:<reset> <medium_orchid>{extra}<reset>" )
cecho( f "\n<dim_grey>Room flags:<reset> <gold>{flags}<reset>" )

-- Look Room
local desc = getRoomUserData( CurrentRoomNumber, 'roomDescription' )
cecho( f "\n\n<olive_drab>{desc}" )

-- Look Exit
trg = matches[2]
inspectExit( CurrentRoomNumber, trg )

-- Exits
local exitTable = getRoomExits( CurrentRoomNumber )
display( exitTable )

-- Set Player Location (spl)
local trgRoom = tonumber( matches[2] )
setPlayerRoom( trgRoom )
displayRoom()

-- Virtual Recall
virtualRecall()

-- Cull Exit (ce)
local cullDir = tostring( matches[2] )
cullExit( cullDir )

-- Set Room Char (src)
local char = matches[2]
if char then
  setRoomChar( CurrentRoomNumber, char )
  setRoomCharColor( CurrentRoomNumber, 0, 0, 0 )
  updateMap()
end
-- Add Label (lbl)
addLabel()

-- Start Map Sim
startMapSim()

-- Get Path (gp)
aliasGetPath()

-- Look Direction
local dir = matches[2]
send( f 'look {dir}', false )
inspectExit( CurrentRoomNumber, dir )

-- SetPlayerRoom (spr)
aliasSetPlayerRoom()

-- EQ  Mode (eqm)
toggleItemQueryMode()

-- Roll Dice (roll)
send( 'get dice {container}', false )
send( 'dice', false )
send( 'put dice {container}', false )

-- Nandor Gear Swap (nanswap)
swapGear()

-- Equipment (eq)
-- Before eq'ing; temporarily enable the eq database trigger family
expandAlias( [[all lua tempEnableTrigger( "EQ Stats", 5 )]], false )
expandAlias( [[all lua tempEnableTrigger( "Missing EQ", 5 )]], false )
expandAlias( "all eq", false )

-- Super Put
send( f 'put {matches[2]} {container}' )

-- Super Get
send( f 'get {matches[2]} {container}' )

-- kermudlet_init
function reloadProfile()
  -- Let Mudlet know we've got our own Map script
  mudlet = mudlet or {}; mudlet.mapper_script = true

  HOME_PATH = 'C:/dev/mud/mudlet/'
  luasql = require( "luasql.sqlite3" )
  -- Redefine this in your IDE for syntax checking
  function runLuaFile( file )
    local filePath = f '{homeDirectory}{file}'
    if lfs.attributes( filePath, "mode" ) == "file" then
      dofile( filePath )
    else
      cecho( f "\n{filePath}<reset> not found." )
    end
  end

  tempTimer( 0, [[runLuaFile("kermudlet_init.lua")]] )
end

reloadProfile()

-- Movement (Map)
-- Binds to send movement to the command queue.

-- Num8: n
send( 'north', false )

-- Num2: s
send( 'south', false )

-- Num6: e
send( 'east', false )

-- Num4: w
send( 'west', false )

-- Num7: u
send( 'up', false )

-- Num8: d
send( 'down', false )

-- Num5: (stop)
clearQueue()

-- Movement (Raw)
-- Binds to send movement to the command queue.

-- Labeling
-- Group to hold keys for adjusting labels post-placement.

-- Left (a)
adjustLabel( 'left' )

-- Nudge Left (^a)
adjustLabel( 'left', 0.025 )

-- Right (d)
adjustLabel( 'right' )

-- Nudge Right (^d)
adjustLabel( 'right', 0.025 )

-- Up (w)
adjustLabel( 'up' )

-- Nudge Up (^w)
adjustLabel( 'up', 0.025 )

-- Down (s)
adjustLabel( 'down' )

-- Down (^s)
adjustLabel( 'down', 0.025 )

-- Confirm (f)
finishLabel( true )

-- Cancel (c)
finishLabel( false )

-- Shift Rooms
-- Move rooms around manually when creating new ones or rearranging areas

-- Shift w
mX, mY, mZ = getRoomCoordinates( CurrentRoomNumber )
mX = mX - 1
setRoomCoordinates( CurrentRoomNumber, mX, mY, mZ )
updateMap()
centerview( CurrentRoomNumber )

-- Shift e
mX, mY, mZ = getRoomCoordinates( CurrentRoomNumber )
mX = mX + 1
setRoomCoordinates( CurrentRoomNumber, mX, mY, mZ )
updateMap()
centerview( CurrentRoomNumber )

-- Shift n
mX, mY, mZ = getRoomCoordinates( CurrentRoomNumber )
mY = mY + 1
setRoomCoordinates( CurrentRoomNumber, mX, mY, mZ )
updateMap()
centerview( CurrentRoomNumber )

-- Shift s
mX, mY, mZ = getRoomCoordinates( CurrentRoomNumber )
mY = mY - 1
setRoomCoordinates( CurrentRoomNumber, mX, mY, mZ )
updateMap()
centerview( CurrentRoomNumber )

-- Shift u
mX, mY, mZ = getRoomCoordinates( CurrentRoomNumber )
mZ = mZ + 1
setRoomCoordinates( CurrentRoomNumber, mX, mY, mZ )
updateMap()
centerview( CurrentRoomNumber )

-- Shift d
mX, mY, mZ = getRoomCoordinates( CurrentRoomNumber )
mZ = mZ - 1
setRoomCoordinates( CurrentRoomNumber, mX, mY, mZ )
updateMap()
centerview( CurrentRoomNumber )

-- Recenter (Num5)
centerview( currentRoomData.roomRNumber )

-- Reset Map (CTRL-R)
startExploration()

-- Save Map (Num+)
cecho( f "\n<yellow_green>Saving...<reset>" )
saveMap()

-- Load Map (Num-)
cecho( f "\n<dark_orange>Loading...<reset>" )
loadMap()
