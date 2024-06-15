--- Simulate the output of a 'group' command for testing triggers
function simulate_group()
  cfeedTriggers( f [[
Your group consists of:
[43 Mu][ 779( 779)h  660( 765)m  396( 430)v] Billy (Leader)
[30 Cl][ 209( 209)h  189( 189)m  326( 380)v] Drebin
[30 Mu][ 158( 158)h  182( 199)m  346( 380)v] Ludwig
[30 Co][ 347( 347)h  126( 167)m  346( 380)v] Hocken
[30 No][ 560( 560)h  100( 100)m  246( 280)v] Nordberg
[25 Cl][ 200( 200)h  204( 204)m  250( 250)v] Colin
[25 Mu][ 105( 105)h  224( 224)m  250( 250)v] Nadja
[25 Mu][ 115( 115)h  173( 173)m  230( 230)v] Laszlo
[25 Co][ 261( 261)h  158( 158)m  220( 220)v] Nandor
[43 Cl][ 743( 743)h  494( 544)m  366( 400)v] Mac
[44 Co][ 750( 750)h  453( 453)m  456( 490)v] Dillon
[44 Wa][ 595(1025)h  155( 155)m  490( 490)v] Blain
    ]] )
end

--- Simulate the output from a 'score' command for testing tirggers
function simulateScore()
  if not statsSimmed then
    cecho( f "\n<deep_pink>Run a simulated prompt first to generate core stats." )
    return
  end
  local pcStatus = pcStatus[SESSION]

  -- Turn this on (it will be disabled again by the trigger)
  enableTrigger( "Parse Score" )

  -- Lua randomization seems so bizarre, so do some weird shit to confuse it
  local randomizer = math.random( 1, 1000 )

  local maxHP = pcStatus["maxHP"]
  local mnm = pcStatus["maxMana"]
  local mvm = pcStatus["maxMoves"]

  -- Generate otherwise random stats for the rest of our score sheet
  local lev, dam, hit, arm = math.random( 10, 30 ), math.random( 10, 30 ), math.random( 10, 30 ),
      math.random( -200, -50 )
  local mac = -250
  local ali = math.random( -1000, 1000 )

  local exp = math.random( 1000000, 9999999 )
  exp = expandNumber( exp )
  local exh = math.random( 499999, 4999999 )
  exh = expandNumber( exh )
  local exl = math.random( 1, 9999999 )
  exl = expandNumber( exl )
  local gld = math.random( 1000000, 9999999 )
  gld = expandNumber( gld )

  cfeedTriggers( f [[
  +---------------------------------------------------------+
  |  Colin the Arch Bishop                                  |
  |  Level {lev}                                       Cleric  |
  +---------------------------------------------------------+
  |  Str: (18)13/20    damageRoll:     {dam}    Hp:          {maxHP}  |
  |  Int: (17)13       hitRoll:     {hit}    Mp:          {mnm}  |
  |  Wis: (18)16       Armor:      {arm}    Mv:          {mvm}  |
  |  Dex: (16)12       Min AC:    {mac}    Wimpy: True Hero  |
  |  Con: (15)13       Align:     {ali}                      |
  +---------------------------------------------------------+
  |  Fame:                 0     Exp:            {exp}  |
  |  Branches:             4     Exp/Hour:               {exh}  |
  |  Age:                 39     Exp TNL:           {exl}  |
  |  Height cm:          163     Gold:           {gld}  |
  |  Weight lbs:         132     Caster's Fans Club         |
  |  Deaths:               0                                |
  |  Carried:       164/2182                                |
  |  Playtime: 4 days and 0 hours                           |
  |  Channels: GOSSIP AUCTION QUEST                         |
  |  Flags:    NOKILL                                       |
  +---------------------------------------------------------+
  ]] )
end

--- Populate the pcStatus table with simulated stats for offline testing
function generate_sim_stats()
  local combatConditions = {
    "full",
    "fine",
    "good",
    "fair",
    "wounded",
    "bad",
    "awful",
    "bleeding",
  }
  for pc = 1, pcCount do
    local tnk, trg = nil, nil
    local maxHP, hpc, mnm, mnc, mvm, mvc = 0, 0, 0, 0, 0, 0

    -- Generate random numbers for hp, mana, and moves
    if pc ~= 4 then
      maxHP = math.random( 250, 500 )
    else
      maxHP = math.random( 500, 800 )
    end
    hpc = maxHP

    if pc ~= 4 then
      mnm = math.random( 400, 800 )
    else
      mnm = math.random( 250, 500 )
    end
    mnc = mnm
    mvm = math.random( 300, 400 )
    mvc = mvm

    -- 80% of the time, sim as in-combat
    if math.random() < 0.80 then
      trg = combatConditions[math.random( 1, #combatConditions )]

      -- 75% of in-combat sim w/ tank
      if math.random() < 0.75 then
        tnk = combatConditions[math.random( 1, #combatConditions )]
      end
    end
    pcStatus[pc] = {

      currentHP    = hpc,
      maxHP        = maxHP,
      percentHP    = (hpc / maxHP) * 100, -- Multiply by 100
      currentMana  = mnc,
      maxMana      = mnm,
      currentMoves = mvc,
      maxMoves     = mvm,
      tank         = tnk,
      target       = trg,

    }
  end
end

-- Generate and feed a randomized prompt to trigger player console updates
-- Syntax: ^rp ?(-?\d+)? ?(-?\d+)? ?(-?\d+)? ?(-?\d+)?$
function simulate_prompt()
  local pc, hpd, mnd, mvd = matches[2] or SESSION, matches[3] or 0, matches[4] or 0, matches[5] or 0

  local prompt_str, left_str, right_str = "", "", ""

  -- Lua randomization seems so bizarre, so do some weird stuff to confuse it
  local randomizer = math.random( 1, 1000 )

  -- If stats haven't been simulated, generate them
  if not statsSimmed then
    statsSimmed = true
    generate_sim_stats()
  end
  local myStatus = pcStatus[tonumber( pc )]

  local hpc = myStatus["currentHP"] + hpd
  local mnc = myStatus["currentMana"] + mnd
  local mvc = myStatus["currentMoves"] + mvd

  left_str = "< " .. hpc .. "(" .. myStatus["maxHP"] .. ") " ..
      mnc .. "(" .. myStatus["maxMana"] .. ") " ..
      mvc .. "(" .. myStatus["maxMoves"] .. ") "


  if myStatus["tank"] and myStatus["target"] then
    right_str = "Buf:" .. myStatus["tank"] .. " Vic:" .. myStatus["target"] .. " >"
  elseif pcStatus["target"] then
    right_str = "Vic:" .. myStatus["target"] .. " >"
  else
    right_str = ">"
  end
  prompt_str = left_str .. right_str

  local sim_session = sessionNumbers[tonumber( pc )]

  expandAlias( f "{sim_session} sim " .. prompt_str, true )
end
