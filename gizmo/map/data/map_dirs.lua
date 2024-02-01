-- Retrieve then follow the path to an area; this uses the Wintin string but should
-- probably skip this and iterate over the rawDirs
function goArea( area )
  local path = getDirs( area )
  local commands = expandWintinString( path )
  cecho( f "\n<dim_grey>Path: <green_yellow>{path}<reset>" )
  for _, cmd in ipairs( commands ) do
    send( cmd, false )
  end
end

-- Retrieve a Wintin-compatible dirs string leading to the specified area
-- Will accept areas as full or partial strings or ID numbers
function getDirs( area )
  local areaID = tonumber( area )

  -- If conversion fails, try a name lookup
  if not areaID then
    local normalizedAreaName = normalizeAreaName( area )

    -- Check exact match first
    areaID = areaMap[normalizedAreaName]

    -- Otherwise, try for a partial match
    if not areaID then
      -- Drop the 's' so things like 'ekitoms' will match 'ekitommines'
      normalizedAreaName = normalizedAreaName:gsub( 's$', '' )
      for key, id in pairs( areaMap ) do
        if key:find( normalizedAreaName ) then
          areaID = id
          break
        end
      end
    end
  end
  if areaID and areaDirs[areaID] then
    -- Return the Wintin-compatible dirs string;
    -- Here we could also retrieve the cost to compare to our moves or verify keys
    return areaDirs[areaID].dirs
  else
    cecho( f "\n<firebrick>Area {area} not found in areaDirs.<reset>" )
    return nil
  end
end

-- Normalize area names before lookup, so e.g., 'Maritime Museum' and 'maritimemuseum' will work
function normalizeAreaName( area )
  return area:gsub( "^The%s+", "" ):gsub( "%s+", "" ):lower()
end

-- This table maps area names and nicknames to their respective IDs for lookup in areaDirs
areaMap = {
  abyss                = 119,
  aliensden            = 52,
  allemonde            = 6,
  arachnidarchives     = 47,
  spiders              = 47,
  battlefield          = 57,
  bfield               = 57,
  battlefieldvillage   = 58,
  beach                = 65,
  blackpoolswamp       = 80,
  bswamp               = 80,
  canticle             = 8,
  castlemistamere      = 113,
  castleofdespair      = 86,
  caveofthesagrethi    = 99,
  ceiarda              = 62,
  chaoslands           = 82,
  clands               = 82,
  chateauofthedead     = 18,
  cityofthalos         = 39,
  cloudcity            = 71,
  darkcathedral        = 76,
  darkfall             = 117,
  darkkingdom          = 102,
  deathtower           = 11,
  desertandlake        = 67,
  desertedvillage      = 40,
  dragoncaves          = 4,
  dcaves               = 4,
  drowcity             = 38,
  druidgroveofgyrnath  = 123,
  dwarvenkingdom       = 49,
  dwarvenlunarmines    = 105,
  ekitommines          = 124,
  elementalcanyon      = 73,
  eviloutpost          = 54,
  evilpalace           = 34,
  festivalofantiquity  = 66,
  forgottenvalley      = 104,
  valley               = 104,
  frostholme           = 120,
  galaxy               = 13,
  garden               = 10,
  gnollfortress        = 98,
  goblinkingdom        = 33,
  golemkingdom         = 81,
  graveyardplus        = 25,
  greatdesert          = 79,
  greatpyramid         = 43,
  gurundiforest        = 50,
  halfingvillage       = 36,
  hallofthelostgods    = 60,
  haondordark          = 45,
  haondorlight         = 44,
  heour                = 109,
  hospital             = 118,
  houseofhorror        = 32,
  ivorytower           = 19,
  kingscastle          = 70,
  lechateaudangoisse   = 26,
  letheatredesvampyres = 69,
  vampires             = 69,
  loftwick             = 72,
  lorien               = 88,
  lostcity             = 37,
  maritimemuseum       = 3,
  martialartsdojo      = 27,
  mayorshouse          = 28,
  midgaardasylum       = 55,
  museum               = 112,
  midgaardtarpit       = 125,
  mirisland            = 126,
  monkmonastary        = 77,
  morgoth              = 75,
  durgathel            = 31,
  myreeorchard         = 35,
  newgraveyard         = 16,
  newtcaves            = 20,
  ocean                = 63,
  ozymarscity          = 46,
  piotrsgrad           = 42,
  pirateship           = 59,
  pixiesgarden         = 29,
  prisonofsouls        = 94,
  questfortheholygrail = 68,
  quickland            = 78,
  rainforestofjanus    = 97,
  redfernesresidence   = 61,
  rocaviary            = 95,
  safari               = 100,
  seaoflove            = 64,
  shire                = 7,
  slaadijungle         = 101,
  spiritwoods          = 5,
  straitsofmessia      = 90,
  swamp                = 91,
  swampandsecretcaves  = 92,
  ettins               = 92, -- I think?
  templarsmercador     = 96,
  threggipit           = 51,
  underworld           = 84,
  utterfrostcavern     = 121,
  yetis                = 121,
  vadirtemple          = 56,
  villageofromnia      = 85,
  warringroses         = 15,
  wasteland            = 41,
  wolvescave           = 74,
  woodofngai           = 111,
  wyvernwood           = 122,
  zhalurthegolden      = 14,
  zoo                  = 17,
  zycacity             = 83
}

-- Data for pathing to areas indexed by area ID
-- [TODO]: Add key name & number if paths include doors
areaDirs = {
  [3] = {
    cost = 56,
    dirs = "#14 w;s;#8 w;s;w;s;d;w",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "s", "d", "w"},
    roomName = "The Entrance",
    roomNumber = 49
  },
  [4] = {
    cost = 46,
    dirs = "#12 w;#2 s;w;s;e;#2 s;#4 w",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "s", "s", "w", "s", "e", "s", "s", "w", "w", "w", "w"},
    roomName = "A Path Through the Valley",
    roomNumber = 138
  },
  [5] = {
    cost = 24,
    dirs = "#8 e;#4 n",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "e", "n", "n", "n", "n"},
    roomName = "Entrance to The Spirit Woods",
    roomNumber = 187
  },
  [6] = {
    cost = 16,
    dirs = "#3 w;#5 n",
    rawDirs = {"w", "w", "w", "n", "n", "n", "n", "n"},
    roomName = "Opera House",
    roomNumber = 212
  },
  [7] = {
    cost = 18,
    dirs = "#8 w;n",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "n"},
    roomName = "A Dimly Lit Path",
    roomNumber = 309
  },
  [8] = {
    cost = 32,
    dirs = "#8 w;#4 n;#3 e;n",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "n", "n", "n", "n", "e", "e", "e", "n"},
    roomName = "The Moor",
    roomNumber = 449
  },
  [10] = {
    cost = 14,
    dirs = "#6 w;n",
    rawDirs = {"w", "w", "w", "w", "w", "w", "n"},
    roomName = "Cobble Stone Path",
    roomNumber = 531
  },
  [11] = {
    cost = 14,
    dirs = "#6 e;s",
    rawDirs = {"e", "e", "e", "e", "e", "e", "s"},
    roomName = "The Entrance of the Death Tower",
    roomNumber = 585
  },
  [13] = {
    cost = 8,
    dirs = "#3 n;u",
    rawDirs = {"n", "n", "n", "u"},
    roomName = "A Long Stair",
    roomNumber = 761
  },
  [14] = {
    cost = 24,
    dirs = "s;#2 e;#2 s;#2 e;#5 s",
    rawDirs = {"s", "e", "e", "s", "s", "e", "e", "s", "s", "s", "s", "s"},
    roomName = "The Docks Along the River",
    roomNumber = 768
  },
  [15] = {
    cost = 68,
    dirs = "#14 w;s;#10 w;#3 s;#4 w;s;u",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "s", "s", "s", "w", "w", "w", "w", "s", "u"},
    roomName = "A Sheltered Enclave",
    roomNumber = 832
  },
  [16] = {
    cost = 24,
    dirs = "#7 e;#4 n;w",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "n", "n", "n", "n", "w"},
    roomName = "A Path to the Graveyard",
    roomNumber = 891
  },
  [17] = {
    cost = 18,
    dirs = "s;#3 w;#5 s",
    rawDirs = {"s", "w", "w", "w", "s", "s", "s", "s", "s"},
    roomName = "Midgaard's Zoo Entrance",
    roomNumber = 927
  },
  [18] = {
    cost = 12,
    dirs = "#5 w;n",
    rawDirs = {"w", "w", "w", "w", "w", "n"},
    roomName = "A Sunlit Path",
    roomNumber = 980
  },
  [19] = {
    cost = 92,
    dirs = "#14 w;s;#8 w;s;w;s;d;#5 s;w;#6 s;#3 e;#2 s;#2 e",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "s", "d", "s", "s", "s", "s", "s", "w", "s", "s", "s", "s", "s", "s", "e", "e", "e", "s", "s", "e", "e"},
    roomName = "Entrance to the Ivory Tower",
    roomNumber = 1027
  },
  [20] = {
    cost = 20,
    dirs = "#7 e;#2 s;e",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "s", "s", "e"},
    roomName = "Obsidian Hills",
    roomNumber = 1075
  },
  [25] = {
    cost = 22,
    dirs = "s;#3 w;#4 s;#2 e;open grate;s;close grate",
    rawDirs = {"s", "w", "w", "w", "s", "s", "s", "s", "e", "e", "s"},
    roomName = "A Gravel Road on the Graveyard",
    roomNumber = 1298
  },
  [26] = {
    cost = 46,
    dirs = "s;#2 e;#2 s;#2 e;#4 s;#4 w;n;#5 w;d;n",
    rawDirs = {"s", "e", "e", "s", "s", "e", "e", "s", "s", "s", "s", "w", "w", "w", "w", "n", "w", "w", "w", "w", "w", "d", "n"},
    roomName = "Pathway to the Chateau",
    roomNumber = 1372
  },
  [27] = {
    cost = 4,
    dirs = "#2 s",
    rawDirs = {"s", "s"},
    roomName = "Entrance To The Anything Goes Martial Arts Dojo",
    roomNumber = 1419
  },
  [28] = {
    cost = 16,
    dirs = "#7 w;n",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "n"},
    roomName = "A Well Tended Path",
    roomNumber = 1442
  },
  [29] = {
    cost = 84,
    dirs = "#14 w;s;#8 w;s;w;s;d;#5 s;w;#9 s",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "s", "d", "s", "s", "s", "s", "s", "w", "s", "s", "s", "s", "s", "s", "s", "s", "s"},
    roomName = "At a Winding Iron Gate",
    roomNumber = 1477
  },
  [31] = {
    cost = 20,
    dirs = "#7 e;#3 n",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "n", "n", "n"},
    roomName = "The Hills",
    roomNumber = 1600
  },
  [32] = {
    cost = 26,
    dirs = "s;#3 w;#4 s;#2 e;open grate;s;close grate;s;w",
    rawDirs = {"s", "w", "w", "w", "s", "s", "s", "s", "e", "e", "s", "s", "w"},
    roomName = "Outside a Forgotten Garden",
    roomNumber = 1720
  },
  [33] = {
    cost = 30,
    dirs = "#14 w;n",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "n"},
    roomName = "A Path to a Dark Cave",
    roomNumber = 1777
  },
  [34] = {
    cost = 48,
    dirs = "#7 e;#4 n;#5 w;#2 n;#3 w;#2 d;s",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "n", "n", "n", "n", "w", "w", "w", "w", "w", "n", "n", "w", "w", "w", "d", "d", "s"},
    roomName = "Guard of Spirit",
    roomNumber = 1794
  },
  [35] = {
    cost = 38,
    dirs = "#8 e;#3 s;#7 e;s",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "e", "s", "s", "s", "e", "e", "e", "e", "e", "e", "e", "s"},
    roomName = "A Clearing",
    roomNumber = 1847
  },
  [36] = {
    cost = 16,
    dirs = "#8 e",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "e"},
    roomName = "A Small Forest",
    roomNumber = 1926
  },
  [37] = {
    cost = 16,
    dirs = "s;#2 e;#2 s;#3 e",
    rawDirs = {"s", "e", "e", "s", "s", "e", "e", "e"},
    roomName = "The Pool",
    roomNumber = 1955
  },
  [38] = {
    cost = 18,
    dirs = "s;#2 e;#2 s;#3 w;d",
    rawDirs = {"s", "e", "e", "s", "s", "w", "w", "w", "d"},
    roomName = "City Entrance",
    roomNumber = 1978
  },
  [39] = {
    cost = 24,
    dirs = "s;#2 e;#2 s;#2 e;#4 s;w",
    rawDirs = {"s", "e", "e", "s", "s", "e", "e", "s", "s", "s", "s", "w"},
    roomName = "The Grand Gate of Thalos",
    roomNumber = 2029
  },
  [40] = {
    cost = 16,
    dirs = "#7 w;s",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "s"},
    roomName = "On a Short Path to a Deserted Village",
    roomNumber = 2083
  },
  [41] = {
    cost = 48,
    dirs = "#6 e;#2 s;d;w;#11 s;#2 e;n",
    rawDirs = {"e", "e", "e", "e", "e", "e", "s", "s", "d", "w", "s", "s", "s", "s", "s", "s", "s", "s", "s", "s", "s", "e", "e", "n"},
    roomName = "The Landing",
    roomNumber = 2105
  },
  [42] = {
    cost = 64,
    dirs = "#7 e;#6 n;#2 u;#3 n;u;w;#2 n;d;#3 n;u;#5 n",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "n", "n", "n", "n", "n", "n", "u", "u", "n", "n", "n", "u", "w", "n", "n", "d", "n", "n", "n", "u", "n", "n", "n", "n", "n"},
    roomName = "Gravel Road",
    roomNumber = 2185
  },
  [43] = {
    cost = 62,
    dirs = "s;#2 e;#2 s;#2 e;#11 s;w;#2 s;e;#4 s;e;s;#2 e;u",
    rawDirs = {"s", "e", "e", "s", "s", "e", "e", "s", "s", "s", "s", "s", "s", "s", "s", "s", "s", "s", "w", "s", "s", "e", "s", "s", "s", "s", "e", "s", "e", "e", "u"},
    roomName = "The Rope to the Pyramid",
    roomNumber = 2226
  },
  [44] = {
    cost = 12,
    dirs = "#6 w",
    rawDirs = {"w", "w", "w", "w", "w", "w"},
    roomName = "The Edge of The Forest",
    roomNumber = 2277
  },
  [45] = {
    cost = 22,
    dirs = "#11 w",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w"},
    roomName = "A Narrow Trail Through the Deep, Dark Forest",
    roomNumber = 2305
  },
  [46] = {
    cost = 54,
    dirs = "#14 w;s;#2 w;#2 s;w;s;#3 w;n;#2 w",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "w", "s", "s", "w", "s", "w", "w", "w", "n", "w", "w"},
    roomName = "The Real Entrance to Ozymar's City",
    roomNumber = 2348
  },
  [47] = {
    cost = 44,
    dirs = "#14 w;s;#3 w;u;#2 w;n",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "w", "w", "u", "w", "w", "n"},
    roomName = "An Open Plain",
    roomNumber = 2392
  },
  [49] = {
    cost = 16,
    dirs = "#7 e;d",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "d"},
    roomName = "Path to Dwarven Village",
    roomNumber = 2525
  },
  [50] = {
    cost = 26,
    dirs = "#5 n;#2 w;#6 n",
    rawDirs = {"n", "n", "n", "n", "n", "w", "w", "n", "n", "n", "n", "n", "n"},
    roomName = "The Forest Path",
    roomNumber = 2575
  },
  [51] = {
    cost = 58,
    dirs = "#5 n;#2 w;#12 n;#2 e;n;e;#2 n;open hedge;e;close hedge;#3 e",
    rawDirs = {"n", "n", "n", "n", "n", "w", "w", "n", "n", "n", "n", "n", "n", "n", "n", "n", "n", "n", "n", "e", "e", "n", "e", "n", "n", "e", "e", "e", "e"},
    roomName = "By the Steaming Pit",
    roomNumber = 2678
  },
  [52] = {
    cost = 96,
    dirs = "#14 w;s;#8 w;s;w;s;d;#5 s;w;#6 s;#2 w;s;w;#2 s;#3 e",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "s", "d", "s", "s", "s", "s", "s", "w", "s", "s", "s", "s", "s", "s", "w", "w", "s", "w", "s", "s", "e", "e", "e"},
    roomName = "Outside the Black Hole",
    roomNumber = 2759
  },
  [54] = {
    cost = 30,
    dirs = "#7 w;#2 s;#2 e;s;e;s;e",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "s", "s", "e", "e", "s", "e", "s", "e"},
    roomName = "Seldom Used Trail",
    roomNumber = 2847
  },
  [55] = {
    cost = 32,
    dirs = "s;#3 w;#4 s;#2 e;#6 n",
    rawDirs = {"s", "w", "w", "w", "s", "s", "s", "s", "e", "e", "n", "n", "n", "n", "n", "n"},
    roomName = "Gate to the Asylum",
    roomNumber = 2854
  },
  [56] = {
    cost = 44,
    dirs = "s;#3 w;#3 s;#4 e;d;#5 w;n;#2 w;n;e",
    rawDirs = {"s", "w", "w", "w", "s", "s", "s", "e", "e", "e", "e", "d", "w", "w", "w", "w", "w", "n", "w", "w", "n", "e"},
    roomName = "A dark tunnel",
    roomNumber = 2980
  },
  [57] = {
    cost = 24,
    dirs = "#7 e;#2 s;e;#2 n",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "s", "s", "e", "n", "n"},
    roomName = "The Entrance to the Battlefield",
    roomNumber = 3021
  },
  [58] = {
    cost = 82,
    dirs = "#7 e;#2 s;e;#7 n;#8 e;#2 u;#2 e;#2 d;#4 e;#6 s",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "s", "s", "e", "n", "n", "n", "n", "n", "n", "n", "e", "e", "e", "e", "e", "e", "e", "e", "u", "u", "e", "e", "d", "d", "e", "e", "e", "e", "s", "s", "s", "s", "s", "s"},
    roomName = "The Dark Gates",
    roomNumber = 3109
  },
  [59] = {
    cost = 30,
    dirs = "s;#3 e;s;#4 e;#2 s;#2 e;#2 s",
    rawDirs = {"s", "e", "e", "e", "s", "e", "e", "e", "e", "s", "s", "e", "e", "s", "s"},
    roomName = "The Main Deck of Pirate Sloop",
    roomNumber = 3131
  },
  [60] = {
    cost = 24,
    dirs = "#3 n;#7 u;n;e",
    rawDirs = {"n", "n", "n", "u", "u", "u", "u", "u", "u", "u", "n", "e"},
    roomName = "Tunnel near the Tavern of the Universe",
    roomNumber = 3148
  },
  [61] = {
    cost = 28,
    dirs = "s;#3 w;#4 s;e;#2 n;e;n;u",
    rawDirs = {"s", "w", "w", "w", "s", "s", "s", "s", "e", "n", "n", "e", "n", "u"},
    roomName = "On the Huge Chain",
    roomNumber = 3216
  },
  [62] = {
    cost = 38,
    dirs = "#14 w;s;#4 w",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "w", "w", "w"},
    roomName = "The Entrance to Cei'Arda",
    roomNumber = 3222
  },
  [63] = {
    cost = 18,
    dirs = "s;#3 e;s;#4 e",
    rawDirs = {"s", "e", "e", "e", "s", "e", "e", "e", "e"},
    roomName = "Entrance to the Ocean",
    roomNumber = 3303
  },
  [64] = {
    cost = 54,
    dirs = "#14 w;s;#8 w;s;w;s;d",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "s", "d"},
    roomName = "Wharf",
    roomNumber = 3343
  },
  [65] = {
    cost = 64,
    dirs = "#14 w;s;#8 w;s;w;s;d;#4 s;w",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "s", "d", "s", "s", "s", "s", "w"},
    roomName = "Near A Strange Shore",
    roomNumber = 3437
  },
  [66] = {
    cost = 50,
    dirs = "#14 w;s;#10 w",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w"},
    roomName = "The Entrance to the Festival of Antiquity",
    roomNumber = 3478
  },
  [67] = {
    cost = 86,
    dirs = "#14 w;s;#8 w;s;w;s;d;#5 s;w;#6 s;#4 w",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "s", "d", "s", "s", "s", "s", "s", "w", "s", "s", "s", "s", "s", "s", "w", "w", "w", "w"},
    roomName = "Desert",
    roomNumber = 3541
  },
  [68] = {
    cost = 82,
    dirs = "#14 w;s;#10 w;#4 n;#8 w;#3 s;w",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "n", "n", "n", "n", "w", "w", "w", "w", "w", "w", "w", "w", "s", "s", "s", "w"},
    roomName = "The Entrance to The Quest for the Holy Grail.",
    roomNumber = 3613
  },
  [69] = {
    cost = 30,
    dirs = "s;#3 w;#4 s;#2 e;#3 n;e;n",
    rawDirs = {"s", "w", "w", "w", "s", "s", "s", "s", "e", "e", "n", "n", "n", "e", "n"},
    roomName = "Outside The Theatre Des Vampyres",
    roomNumber = 3677
  },
  [70] = {
    cost = 36,
    dirs = "#18 e",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "e", "e", "e", "e", "e", "e", "e", "e", "e", "e", "e"},
    roomName = "The King's Road",
    roomNumber = 3738
  },
  [71] = {
    cost = 16,
    dirs = "#3 n;#4 u;n",
    rawDirs = {"n", "n", "n", "u", "u", "u", "u", "n"},
    roomName = "A Fluffy White Cloud",
    roomNumber = 3792
  },
  [72] = {
    cost = 82,
    dirs = "s;#2 e;#2 s;#2 e;#11 s;w;#2 s;e;#4 s;e;#5 s;n;#2 s;e;n;e;n;e;d",
    rawDirs = {"s", "e", "e", "s", "s", "e", "e", "s", "s", "s", "s", "s", "s", "s", "s", "s", "s", "s", "w", "s", "s", "e", "s", "s", "s", "s", "e", "s", "s", "s", "s", "s", "n", "s", "s", "e", "n", "e", "n", "e", "d"},
    roomName = "Entrance to the Lost City of Loftwick",
    roomNumber = 3872
  },
  [73] = {
    cost = 22,
    dirs = "#7 e;#2 s;e;n",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "s", "s", "e", "n"},
    roomName = "A Mountain Path",
    roomNumber = 3961
  },
  [74] = {
    cost = 30,
    dirs = "s;#2 e;#2 s;#3 w;#6 s;e",
    rawDirs = {"s", "e", "e", "s", "s", "w", "w", "w", "s", "s", "s", "s", "s", "s", "e"},
    roomName = "The River",
    roomNumber = 4021
  },
  [75] = {
    cost = 22,
    dirs = "#7 e;#3 n;e",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "n", "n", "n", "e"},
    roomName = "Between Two Hills",
    roomNumber = 4050
  },
  [76] = {
    cost = 14,
    dirs = "#6 e;n",
    rawDirs = {"e", "e", "e", "e", "e", "e", "n"},
    roomName = "Rutted Path",
    roomNumber = 4100
  },
  [77] = {
    cost = 24,
    dirs = "#11 w;n",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "n"},
    roomName = "Path through The Forest",
    roomNumber = 4159
  },
  [78] = {
    cost = 28,
    dirs = "#8 w;#2 s;e;s;#2 e",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "s", "s", "e", "s", "e", "e"},
    roomName = "The Sinister Forest Path",
    roomNumber = 4210
  },
  [79] = {
    cost = 54,
    dirs = "s;#2 e;#2 s;#2 e;#11 s;w;#2 s;e;#4 s;e",
    rawDirs = {"s", "e", "e", "s", "s", "e", "e", "s", "s", "s", "s", "s", "s", "s", "s", "s", "s", "s", "w", "s", "s", "e", "s", "s", "s", "s", "e"},
    roomName = "Great Desert",
    roomNumber = 4231
  },
  [80] = {
    cost = 18,
    dirs = "s;#2 e;#2 s;#3 w;s",
    rawDirs = {"s", "e", "e", "s", "s", "w", "w", "w", "s"},
    roomName = "On the River",
    roomNumber = 4340
  },
  [81] = {
    cost = 44,
    dirs = "s;#2 e;#2 s;#3 w;#2 s;#2 w;n;#2 w;s;#3 w;s;#2 w",
    rawDirs = {"s", "e", "e", "s", "s", "w", "w", "w", "s", "s", "w", "w", "n", "w", "w", "s", "w", "w", "w", "s", "w", "w"},
    roomName = "A Dark Passage",
    roomNumber = 4377
  },
  [82] = {
    cost = 44,
    dirs = "s;#2 e;#2 s;#3 w;#2 s;#2 w;s;#2 w;#5 s;#2 w",
    rawDirs = {"s", "e", "e", "s", "s", "w", "w", "w", "s", "s", "w", "w", "s", "w", "w", "s", "s", "s", "s", "s", "w", "w"},
    roomName = "Deep in a Dark and Deadly Swamp",
    roomNumber = 4431
  },
  [83] = {
    cost = 38,
    dirs = "#14 w;#5 n",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "n", "n", "n", "n", "n"},
    roomName = "A Beautiful Path",
    roomNumber = 4528
  },
  [84] = {
    cost = 24,
    dirs = "s;#3 w;#3 s;#4 e;d",
    rawDirs = {"s", "w", "w", "w", "s", "s", "s", "e", "e", "e", "e", "d"},
    roomName = "The Lit Trail",
    roomNumber = 4661
  },
  [85] = {
    cost = 20,
    dirs = "#7 e;#3 s",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "s", "s", "s"},
    roomName = "The Road",
    roomNumber = 4838
  },
  [86] = {
    cost = 48,
    dirs = "#7 e;#4 s;n;#8 w;s;#3 w",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "s", "s", "s", "s", "n", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "w", "w"},
    roomName = "The Stezja Road",
    roomNumber = 4892
  },
  [88] = {
    cost = 26,
    dirs = "#7 e;#5 n;e",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "n", "n", "n", "n", "n", "e"},
    roomName = "The Oak Forest",
    roomNumber = 5023
  },
  [90] = {
    cost = 102,
    dirs = "s;#2 e;#2 s;#3 w;#2 s;#2 w;n;#2 w;s;#3 w;s;#4 w;#2 s;#5 w;#3 n;#2 w;#2 n;w;#2 n;#2 d;#2 n;#2 e;#3 n;w",
    rawDirs = {"s", "e", "e", "s", "s", "w", "w", "w", "s", "s", "w", "w", "n", "w", "w", "s", "w", "w", "w", "s", "w", "w", "w", "w", "s", "s", "w", "w", "w", "w", "w", "n", "n", "n", "w", "w", "n", "n", "w", "n", "n", "d", "d", "n", "n", "e", "e", "n", "n", "n", "w"},
    roomName = "Entering the Straits of Messia",
    roomNumber = 5204
  },
  [91] = {
    cost = 22,
    dirs = "#10 w;n",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "n"},
    roomName = "On the Edge of the Huge Dreadful Swamp",
    roomNumber = 5304
  },
  [92] = {
    cost = 76,
    dirs = "#10 w;n;w;#2 n;w;n;w;n;#2 e;#2 n;w;#2 n;#2 e;s;e;s;e;d;#3 e;n;#2 d",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "n", "w", "n", "n", "w", "n", "w", "n", "e", "e", "n", "n", "w", "n", "n", "e", "e", "s", "e", "s", "e", "d", "e", "e", "e", "n", "d", "d"},
    roomName = "Large Tunnel",
    roomNumber = 5437
  },
  [94] = {
    cost = 58,
    dirs = "#8 e;#3 n;#7 e;#3 n;w;#5 n;e;n",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "e", "n", "n", "n", "e", "e", "e", "e", "e", "e", "e", "n", "n", "n", "w", "n", "n", "n", "n", "n", "e", "n"},
    roomName = "A Path Through Barren Woods",
    roomNumber = 5605
  },
  [95] = {
    cost = 28,
    dirs = "#7 e;#2 s;e;#2 s;e;n",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "s", "s", "e", "s", "s", "e", "n"},
    roomName = "The Tree Trunk",
    roomNumber = 5686
  },
  [96] = {
    cost = 84,
    dirs = "s;#2 e;#2 s;#2 e;#11 s;w;#2 s;e;#4 s;e;#5 s;n;s;#2 e;n;#2 e;n;w;e",
    rawDirs = {"s", "e", "e", "s", "s", "e", "e", "s", "s", "s", "s", "s", "s", "s", "s", "s", "s", "s", "w", "s", "s", "e", "s", "s", "s", "s", "e", "s", "s", "s", "s", "s", "n", "s", "e", "e", "n", "e", "e", "n", "w", "e"},
    roomName = "Great Desert",
    roomNumber = 5732
  },
  [97] = {
    cost = 150,
    dirs =
    "s;#2 e;#2 s;#2 e;#11 s;w;#2 s;e;#4 s;e;#5 s;n;s;#2 e;n;#2 e;n;w;#2 e;n;e;#3 s;w;n;w;#2 s;#4 e;s;w;n;#2 e;d;#2 n;d;#2 e;d;open door;s;close door;#2 s;e;d;e",
    rawDirs = {"s", "e", "e", "s", "s", "e", "e", "s", "s", "s", "s", "s", "s", "s", "s", "s", "s", "s", "w", "s", "s", "e", "s", "s", "s", "s", "e", "s", "s", "s", "s", "s", "n", "s", "e", "e", "n", "e", "e", "n", "w", "e", "e", "n", "e", "s", "s", "s", "w", "n", "w", "s", "s", "e", "e", "e", "e", "s", "w", "n", "e", "e", "d", "n", "n", "d", "e", "e", "d", "s", "s", "s", "e", "d", "e"},
    roomName = "A Tepid River",
    roomNumber = 5831
  },
  [98] = {
    cost = 68,
    dirs = "#7 w;#2 s;#2 e;s;e;s;e;#2 s;e;#5 n;open gate;n;close gate;#2 n;d;#4 n;#2 d;s",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "s", "s", "e", "e", "s", "e", "s", "e", "s", "s", "e", "n", "n", "n", "n", "n", "n", "n", "n", "d", "n", "n", "n", "n", "d", "d", "s"},
    roomName = "Entrance to a Dark Cave",
    roomNumber = 5931
  },
  [99] = {
    cost = 86,
    dirs = "#7 w;#2 s;#2 e;s;e;s;e;#2 s;e;#5 n;open gate;n;close gate;#2 n;d;#4 n;#2 d;#3 s;w;n;w;#3 s;d",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "s", "s", "e", "e", "s", "e", "s", "e", "s", "s", "e", "n", "n", "n", "n", "n", "n", "n", "n", "d", "n", "n", "n", "n", "d", "d", "s", "s", "s", "w", "n", "w", "s", "s", "s", "d"},
    roomName = "A Path in a Darkened Cave",
    roomNumber = 6019
  },
  [100] = {
    cost = 34,
    dirs = "#5 n;#2 w;#4 n;#5 e;n",
    rawDirs = {"n", "n", "n", "n", "n", "w", "w", "n", "n", "n", "n", "e", "e", "e", "e", "e", "n"},
    roomName = "A Grassy Trail",
    roomNumber = 6085
  },
  [101] = {
    cost = 36,
    dirs = "#7 e;#2 s;e;#2 s;e;#3 s;#2 e",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "s", "s", "e", "s", "s", "e", "s", "s", "s", "e", "e"},
    roomName = "Near the Jungle",
    roomNumber = 6173
  },
  [102] = {
    cost = 74,
    dirs = "#14 w;s;#8 w;s;w;s;d;#4 s;#4 w;#2 s",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "s", "d", "s", "s", "s", "s", "w", "w", "w", "w", "s", "s"},
    roomName = "A Cold Plateau",
    roomNumber = 6214
  },
  [104] = {
    cost = 56,
    dirs = "#7 e;#2 s;e;#9 n;e;n;#2 e;n;e;n;#2 e",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "s", "s", "e", "n", "n", "n", "n", "n", "n", "n", "n", "n", "e", "n", "e", "e", "n", "e", "n", "e", "e"},
    roomName = "A Narrow Gulley",
    roomNumber = 6410
  },
  [105] = {
    cost = 32,
    dirs = "#7 e;d;#3 n;e;unlock door;open door;e;close door;#2 d;n",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "d", "n", "n", "n", "e", "e", "d", "d", "n"},
    roomName = "A Small, Clandestine Chamber",
    roomNumber = 6507
  },
  [109] = {
    cost = 22,
    dirs = "s;#2 e;#2 s;#3 w;#3 s",
    rawDirs = {"s", "e", "e", "s", "s", "w", "w", "w", "s", "s", "s"},
    roomName = "Bay Isle",
    roomNumber = 6760
  },
  [111] = {
    cost = 110,
    dirs =
    "s;#2 e;#2 s;#3 w;#2 s;#2 w;n;#2 w;s;#3 w;s;#4 w;#2 s;#5 w;#3 n;#2 w;#2 n;w;#2 n;#2 d;#2 n;#2 e;#3 n;s;e;n;e;s",
    rawDirs = {"s", "e", "e", "s", "s", "w", "w", "w", "s", "s", "w", "w", "n", "w", "w", "s", "w", "w", "w", "s", "w", "w", "w", "w", "s", "s", "w", "w", "w", "w", "w", "n", "n", "n", "w", "w", "n", "n", "w", "n", "n", "d", "d", "n", "n", "e", "e", "n", "n", "n", "s", "e", "n", "e", "s"},
    roomName = "An Eldritch Path",
    roomNumber = 6843
  },
  [112] = {
    cost = 28,
    dirs = "s;#3 w;#4 s;#2 e;#4 n",
    rawDirs = {"s", "w", "w", "w", "s", "s", "s", "s", "e", "e", "n", "n", "n", "n"},
    roomName = "On a Well Made Stone Road",
    roomNumber = 6917
  },
  [113] = {
    cost = 26,
    dirs = "#7 e;#5 n;w",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "n", "n", "n", "n", "n", "w"},
    roomName = "The Rolling Hills",
    roomNumber = 6959
  },
  [117] = {
    cost = 20,
    dirs = "#6 e;#2 s;#2 d",
    rawDirs = {"e", "e", "e", "e", "e", "e", "s", "s", "d", "d"},
    roomName = "An Ancient Touen to the DarkFall",
    roomNumber = 7261
  },
  [118] = {
    cost = 30,
    dirs = "s;#3 w;#4 s;#2 e;#4 n;u",
    rawDirs = {"s", "w", "w", "w", "s", "s", "s", "s", "e", "e", "n", "n", "n", "n", "u"},
    roomName = "Hospital Entry",
    roomNumber = 7367
  },
  [119] = {
    cost = 74,
    dirs = "s;#2 e;#2 s;#3 w;#2 s;#2 w;n;#2 w;s;#3 w;s;#4 w;#2 s;#5 w;#3 n;#2 w;n",
    rawDirs = {"s", "e", "e", "s", "s", "w", "w", "w", "s", "s", "w", "w", "n", "w", "w", "s", "w", "w", "w", "s", "w", "w", "w", "w", "s", "s", "w", "w", "w", "w", "w", "n", "n", "n", "w", "w", "n"},
    roomName = "The Mountain Path",
    roomNumber = 7402
  },
  [120] = {
    cost = 82,
    dirs = "#7 e;#6 n;#2 u;#3 n;u;w;#2 n;d;#3 n;u;#8 n;#3 u;#3 w",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "n", "n", "n", "n", "n", "n", "u", "u", "n", "n", "n", "u", "w", "n", "n", "d", "n", "n", "n", "u", "n", "n", "n", "n", "n", "n", "n", "n", "u", "u", "u", "w", "w", "w"},
    roomName = "On The Side of The Glacier.",
    roomNumber = 7491
  },
  [121] = {
    cost = 68,
    dirs = "#7 e;#6 n;#2 u;#3 n;u;w;#2 n;d;#3 n;u;#7 n",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "n", "n", "n", "n", "n", "n", "u", "u", "n", "n", "n", "u", "w", "n", "n", "d", "n", "n", "n", "u", "n", "n", "n", "n", "n", "n", "n"},
    roomName = "At The Base of The Glacier",
    roomNumber = 7590
  },
  [122] = {
    cost = 66,
    dirs = "#8 e;#3 n;#7 e;#3 n;w;#11 n",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "e", "n", "n", "n", "e", "e", "e", "e", "e", "e", "e", "n", "n", "n", "w", "n", "n", "n", "n", "n", "n", "n", "n", "n", "n", "n"},
    roomName = "A Light Pine Forest",
    roomNumber = 7681
  },
  [123] = {
    cost = 24,
    dirs = "#5 n;#2 w;#4 n;e",
    rawDirs = {"n", "n", "n", "n", "n", "w", "w", "n", "n", "n", "n", "e"},
    roomName = "A Forest Path",
    roomNumber = 7775
  },
  [124] = {
    cost = 30,
    dirs = "#7 e;#3 n;#2 e;#3 n",
    rawDirs = {"e", "e", "e", "e", "e", "e", "e", "n", "n", "n", "e", "e", "n", "n", "n"},
    roomName = "Tunnel Opening",
    roomNumber = 7859
  },
  [125] = {
    cost = 36,
    dirs = "s;#3 w;#4 s;#2 e;#5 n;#2 e;n",
    rawDirs = {"s", "w", "w", "w", "s", "s", "s", "s", "e", "e", "n", "n", "n", "n", "n", "e", "e", "n"},
    roomName = "Beside the Midgaard Museum",
    roomNumber = 7982
  },
  [126] = {
    cost = 56,
    dirs = "#14 w;s;#8 w;s;w;s;d;e",
    rawDirs = {"w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "w", "w", "w", "w", "w", "w", "w", "s", "w", "s", "d", "e"},
    roomName = "The Mir Island Wharf",
    roomNumber = 8083
  }
}
