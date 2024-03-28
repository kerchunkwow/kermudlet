-- If the doorData hasn't been initialized, load it once other scripts have finished loading
if not doorData then
  doorData = {}
  tempTimer( 0, [[loadAllDoors()]] )
end
-- Retrieve data about the specified room's doors; if dir is supplied get that direction only
function getDoorData( id, dir )
  local roomDoorData = doorData[id]

  -- No doors present in this room
  if not roomDoorData then
    return nil
  end
  -- Return all of the door data or just the requested direction's; convert to LONG direction first
  if dir then
    return roomDoorData[LDIR[dir]] or nil
  else
    return roomDoorData
  end
end

-- Load data about all the doors in the game
function loadAllDoors()
  doorData = {
    [58] = {
      south = {
        exitDest = 60,
        exitKeyword = "door"
      }
    },
    [60] = {
      north = {
        exitDest = 58,
        exitKeyword = "door"
      },
      west = {
        exitDest = 61,
        exitKey = 521,
        exitKeyword = "door"
      }
    },
    [61] = {
      east = {
        exitDest = 60,
        exitKey = 521,
        exitKeyword = "door"
      }
    },
    [64] = {
      down = {
        exitDest = 67,
        exitKeyword = "trapdoor"
      }
    },
    [67] = {
      east = {
        exitDest = 68,
        exitKey = 522,
        exitKeyword = "door"
      },
      up = {
        exitDest = 64,
        exitKeyword = "trapdoor"
      }
    },
    [68] = {
      west = {
        exitDest = 67,
        exitKey = 522,
        exitKeyword = "door"
      }
    },
    [74] = {
      down = {
        exitDest = 78,
        exitKeyword = "trapdoor"
      }
    },
    [78] = {
      east = {
        exitDest = 79,
        exitKey = 523,
        exitKeyword = "door"
      },
      up = {
        exitDest = 74,
        exitKeyword = "trapdoor"
      }
    },
    [79] = {
      west = {
        exitDest = 78,
        exitKey = 523,
        exitKeyword = "door"
      }
    },
    [87] = {
      down = {
        exitDest = 94,
        exitKeyword = "trapdoor"
      }
    },
    [93] = {
      east = {
        exitDest = 94,
        exitKeyword = "door"
      }
    },
    [94] = {
      east = {
        exitDest = 95,
        exitKey = 524,
        exitKeyword = "door"
      },
      up = {
        exitDest = 87,
        exitKeyword = "trapdoor"
      },
      west = {
        exitDest = 93,
        exitKeyword = "door"
      }
    },
    [95] = {
      west = {
        exitDest = 94,
        exitKey = 524,
        exitKeyword = "cabindoor"
      }
    },
    [103] = {
      down = {
        exitDest = 110,
        exitKeyword = "trapdoor"
      }
    },
    [110] = {
      east = {
        exitDest = 111,
        exitKeyword = "door"
      },
      up = {
        exitDest = 103,
        exitKeyword = "trapdoor"
      }
    },
    [111] = {
      east = {
        exitDest = 112,
        exitKey = 525,
        exitKeyword = "cabin"
      },
      west = {
        exitDest = 110,
        exitKeyword = "door"
      }
    },
    [112] = {
      west = {
        exitDest = 111,
        exitKey = 525,
        exitKeyword = "cabindoor"
      }
    },
    [124] = {
      down = {
        exitDest = 135,
        exitKeyword = "trapdoor"
      }
    },
    [133] = {
      east = {
        exitDest = 134,
        exitKey = 526,
        exitKeyword = "cabindoor"
      }
    },
    [134] = {
      east = {
        exitDest = 135,
        exitKeyword = "door"
      },
      west = {
        exitDest = 133,
        exitKey = 526,
        exitKeyword = "cabindoor"
      }
    },
    [135] = {
      east = {
        exitDest = 136,
        exitKeyword = "celldoor"
      },
      up = {
        exitDest = 124,
        exitKeyword = "trapdoor"
      },
      west = {
        exitDest = 134,
        exitKeyword = "door"
      }
    },
    [214] = {
      west = {
        exitDest = 253,
        exitKey = 1009,
        exitKeyword = "door"
      }
    },
    [245] = {
      south = {
        exitDescription = "There is a door to the south.",
        exitDest = 282,
        exitKey = 1003,
        exitKeyword = "door"
      }
    },
    [282] = {
      north = {
        exitDest = 245,
        exitKey = 1003,
        exitKeyword = "door"
      }
    },
    [319] = {
      east = {
        exitDescription = "A door offers passage to the office of the Thain.",
        exitDest = 320,
        exitKeyword = "door"
      }
    },
    [320] = {
      west = {
        exitDescription = "A door offers passage to the Shiriff Post.",
        exitDest = 319,
        exitKeyword = "door"
      }
    },
    [333] = {
      south = {
        exitDescription = "A wooden door leads to the rear of the watermill.",
        exitDest = 334,
        exitKeyword = "door"
      }
    },
    [343] = {
      north = {
        exitDescription =
        "A large, magnificent house meets your steady gaze. Above the round door a sign reads 'Bag End'.",
        exitDest = 344,
        exitKeyword = "door"
      }
    },
    [344] = {
      east = {
        exitDescription = "Through the keyhole you see what looks like a well stocked pantry.",
        exitDest = 346,
        exitKeyword = "door"
      }
    },
    [346] = {
      west = {
        exitDescription = "Beyond the door you see the main room of Bag End.",
        exitDest = 344,
        exitKeyword = "door"
      }
    },
    [457] = {
      west = {
        exitDescription = "The Scullery",
        exitDest = 458,
        exitKeyword = "door"
      }
    },
    [461] = {
      south = {
        exitDescription = "The Jitney",
        exitDest = 462,
        exitKeyword = "door"
      }
    },
    [464] = {
      east = {
        exitDescription = "Blue Cube",
        exitDest = 465,
        exitKeyword = "door"
      }
    },
    [465] = {
      west = {
        exitDescription = "Dark Blue Hall",
        exitDest = 464,
        exitKeyword = "door"
      }
    },
    [477] = {
      south = {
        exitDescription = "The Keep",
        exitDest = 478,
        exitKey = 1305,
        exitKeyword = "door"
      }
    },
    [478] = {
      north = {
        exitDescription = "Entrance to the Keep",
        exitDest = 477,
        exitKey = 1305,
        exitKeyword = "door"
      }
    },
    [544] = {
      down = {
        exitDescription = "The trapdoor is built into the floor in the center of the room.",
        exitDest = 556,
        exitKeyword = "trapdoor"
      }
    },
    [555] = {
      north = {
        exitDescription = "The hole seems to be in the shape of a keyhole.",
        exitDest = 559,
        exitKey = 1707,
        exitKeyword = "door"
      }
    },
    [556] = {
      up = {
        exitDescription = "The only exit is back up through the trapdoor.",
        exitDest = 544,
        exitKeyword = "trapdoor"
      }
    },
    [559] = {
      south = {
        exitDescription = "The large bee hive is to the south.",
        exitDest = 555,
        exitKey = 1707,
        exitKeyword = "door"
      }
    },
    [569] = {
      north = {
        exitDescription = "There is a door on the front of the house.",
        exitDest = 582,
        exitKey = 1709,
        exitKeyword = "door"
      }
    },
    [582] = {
      south = {
        exitDescription = "Perhaps you should leave the wizard to his studies and return to the garden.",
        exitDest = 569,
        exitKey = 1709,
        exitKeyword = "door"
      }
    },
    [623] = {
      north = {
        exitDest = 624,
        exitKeyword = "logs"
      }
    },
    [624] = {
      south = {
        exitDest = 623,
        exitKeyword = "logs"
      }
    },
    [643] = {
      down = {
        exitDest = 649,
        exitKeyword = "cover"
      }
    },
    [648] = {
      north = {
        exitDest = 650,
        exitKeyword = "exit"
      }
    },
    [650] = {
      south = {
        exitDest = 648,
        exitKeyword = "exit"
      }
    },
    [654] = {
      east = {
        exitDest = 657,
        exitKeyword = "door"
      }
    },
    [657] = {
      west = {
        exitDest = 654,
        exitKeyword = "door"
      }
    },
    [667] = {
      west = {
        exitDest = 668,
        exitKeyword = "door"
      }
    },
    [668] = {
      east = {
        exitDest = 667,
        exitKeyword = "door"
      }
    },
    [674] = {
      east = {
        exitDest = 682,
        exitKeyword = "trapdoor"
      }
    },
    [676] = {
      down = {
        exitDest = 687,
        exitKey = 1980,
        exitKeyword = "trapdoor"
      }
    },
    [678] = {
      west = {
        exitDest = 682,
        exitKeyword = "door"
      }
    },
    [682] = {
      east = {
        exitDest = 678,
        exitKeyword = "door"
      },
      west = {
        exitDest = 674,
        exitKeyword = "trapdoor"
      }
    },
    [683] = {
      north = {
        exitDest = 684,
        exitKeyword = "door"
      }
    },
    [684] = {
      south = {
        exitDest = 683,
        exitKeyword = "door"
      }
    },
    [687] = {
      up = {
        exitDest = 676,
        exitKey = 1980,
        exitKeyword = "trapdoor"
      }
    },
    [693] = {
      down = {
        exitDest = 695,
        exitKey = 1939,
        exitKeyword = "throne"
      }
    },
    [695] = {
      up = {
        exitDest = 693,
        exitKey = 1939,
        exitKeyword = "throne"
      }
    },
    [730] = {
      up = {
        exitDescription = "force field spring",
        exitDest = 743,
        exitKey = 2024,
        exitKeyword = "You"
      }
    },
    [743] = {
      down = {
        exitDest = 730,
        exitKey = 2024,
        exitKeyword = "door"
      },
      up = {
        exitDescription = "force field",
        exitDest = 744,
        exitKey = 2025,
        exitKeyword = "You"
      }
    },
    [744] = {
      down = {
        exitDest = 743,
        exitKey = 2025,
        exitKeyword = "door"
      }
    },
    [748] = {
      east = {
        exitDescription = "force field",
        exitDest = 749,
        exitKey = 2026,
        exitKeyword = "You"
      }
    },
    [749] = {
      west = {
        exitDest = 748,
        exitKey = 2026,
        exitKeyword = "door"
      }
    },
    [752] = {
      south = {
        exitDescription = "force field",
        exitDest = 753,
        exitKey = 2027,
        exitKeyword = "You"
      }
    },
    [753] = {
      north = {
        exitDest = 752,
        exitKey = 2027,
        exitKeyword = "door"
      }
    },
    [826] = {
      south = {
        exitDescription = "Inside the tower.",
        exitDest = 827,
        exitKey = 2115,
        exitKeyword = "door"
      }
    },
    [827] = {
      north = {
        exitDescription = "The courtyard of the great temple.",
        exitDest = 826,
        exitKey = 2115,
        exitKeyword = "door"
      }
    },
    [911] = {
      north = {
        exitDest = 912,
        exitKey = 2501,
        exitKeyword = "door"
      }
    },
    [912] = {
      south = {
        exitDest = 911,
        exitKey = 2501,
        exitKeyword = "door"
      }
    },
    [932] = {
      south = {
        exitDescription = "Perhaps you should try to find someone with the key.",
        exitDest = 946,
        exitKey = 2601,
        exitKeyword = "gate"
      }
    },
    [946] = {
      north = {
        exitDescription = "This leads to the more gentle areas of the zoo.",
        exitDest = 932,
        exitKey = 2601,
        exitKeyword = "gate"
      }
    },
    [978] = {
      east = {
        exitDescription = "A large knot in the oak appears as though it might swing out, serving as a door.",
        exitDest = 979,
        exitKeyword = "oak"
      }
    },
    [982] = {
      east = {
        exitDescription = "A large bookshelf blocks the passage here.",
        exitDest = 983,
        exitKeyword = "bookshelf"
      }
    },
    [983] = {
      west = {
        exitDescription = "A large bookshelf blocks the passage here.",
        exitDest = 982,
        exitKeyword = "bookshelf"
      }
    },
    [984] = {
      north = {
        exitDescription = "A heavy-set steel door blocks the doorway.",
        exitDest = 993,
        exitKey = 2701,
        exitKeyword = "vault"
      }
    },
    [991] = {
      north = {
        exitDescription = "A small door leads into the next room.",
        exitDest = 1000,
        exitKeyword = "door"
      }
    },
    [992] = {
      east = {
        exitDescription = "A large coffin lid blocks the entryway here.",
        exitDest = 993,
        exitKeyword = "coffin"
      }
    },
    [993] = {
      south = {
        exitDescription = "A large steel door blocks the way south.",
        exitDest = 984,
        exitKey = 2701,
        exitKeyword = "vault"
      },
      west = {
        exitDescription = "A large coffin lid blocks the passage here.",
        exitDest = 992,
        exitKeyword = "coffin"
      }
    },
    [1000] = {
      south = {
        exitDescription = "A small door blocks the passage to the kitchen.",
        exitDest = 991,
        exitKeyword = "door"
      }
    },
    [1002] = {
      east = {
        exitDescription = "You can make out a large courtyard through the window in the door.",
        exitDest = 1003,
        exitKeyword = "door"
      }
    },
    [1003] = {
      west = {
        exitDest = 1002,
        exitKeyword = "door"
      }
    },
    [1004] = {
      north = {
        exitDest = 1013,
        exitKeyword = "bush"
      }
    },
    [1009] = {
      east = {
        exitDest = 1010,
        exitKeyword = "door"
      }
    },
    [1010] = {
      east = {
        exitDest = 1011,
        exitKeyword = "door"
      },
      west = {
        exitDest = 1009,
        exitKeyword = "door"
      }
    },
    [1011] = {
      west = {
        exitDest = 1010,
        exitKeyword = "door"
      }
    },
    [1013] = {
      south = {
        exitDest = 1004,
        exitKeyword = "bush"
      }
    },
    [1018] = {
      east = {
        exitDest = 1019,
        exitKeyword = "door"
      }
    },
    [1019] = {
      east = {
        exitDest = 1020,
        exitKeyword = "door"
      },
      west = {
        exitDest = 1018,
        exitKeyword = "door"
      }
    },
    [1020] = {
      west = {
        exitDest = 1019,
        exitKeyword = "door"
      }
    },
    [1092] = {
      south = {
        exitDescription = "You see the bottom of the shaft.",
        exitDest = 1091,
        exitFlags = -1
      }
    },
    [1098] = {
      west = {
        exitDescription = "You see the entrance to the town hall.",
        exitDest = 1099,
        exitFlags = -1
      }
    },
    [1103] = {
      east = {
        exitDescription = "You see the door, that leads to the inside of the temple.",
        exitDest = 1104,
        exitKeyword = "door"
      }
    },
    [1104] = {
      west = {
        exitDescription = "You see the door that leads to the temple entrance.",
        exitDest = 1103,
        exitKeyword = "door"
      }
    },
    [1105] = {
      east = {
        exitDescription = "You see two large doors.",
        exitDest = 1106,
        exitKeyword = "doors"
      }
    },
    [1106] = {
      west = {
        exitDescription = "You see two large doors.",
        exitDest = 1105,
        exitKeyword = "doors"
      }
    },
    [1147] = {
      west = {
        exitDescription = "The city gate is to the west.",
        exitDest = 1159,
        exitFlags = -1,
        exitKeyword = "gate"
      }
    },
    [1148] = {
      east = {
        exitDescription = "You see the city gate.",
        exitDest = 1160,
        exitFlags = -1,
        exitKeyword = "gate"
      }
    },
    [1159] = {
      east = {
        exitDescription = "The city gate is to the east.",
        exitDest = 1147,
        exitFlags = -1,
        exitKeyword = "gate"
      }
    },
    [1160] = {
      west = {
        exitDescription = "You see the city gate.",
        exitDest = 1148,
        exitFlags = -1,
        exitKeyword = "gate"
      }
    },
    [1217] = {
      east = {
        exitDescription = "You see the park road.",
        exitDest = 1218,
        exitKey = 3120,
        exitKeyword = "door"
      }
    },
    [1218] = {
      west = {
        exitDescription = "You see the cityguard head quarters.",
        exitDest = 1217,
        exitKey = 3120,
        exitKeyword = "door"
      }
    },
    [1225] = {
      east = {
        exitDescription = "You see a small cottage with an oaken door. A name plate has been set on it.",
        exitDest = 1276,
        exitKey = 3300,
        exitKeyword = "door"
      }
    },
    [1233] = {
      east = {
        exitDescription = "A heavy oaken door is to the east.",
        exitDest = 2812,
        exitKey = 3301,
        exitKeyword = "door"
      }
    },
    [1236] = {
      south = {
        exitDescription = "Through the solid iron bars you see the graveyard.",
        exitDest = 1298,
        exitKeyword = "grate"
      }
    },
    [1276] = {
      west = {
        exitDest = 1225,
        exitKey = 3300,
        exitKeyword = "door"
      }
    },
    [1282] = {
      west = {
        exitDest = 1290,
        exitKey = 3399,
        exitKeyword = "teak"
      }
    },
    [1298] = {
      north = {
        exitDescription = "Through the solid iron bars you see the Concourse.",
        exitDest = 1236,
        exitKeyword = "grate"
      }
    },
    [1302] = {
      south = {
        exitDescription = "The chapel door is made of dark wood.",
        exitDest = 1303,
        exitKeyword = "door"
      }
    },
    [1303] = {
      down = {
        exitDest = 1317,
        exitKeyword = "altar"
      },
      north = {
        exitDescription = "The chapel door is made of dark wood.",
        exitDest = 1302,
        exitKeyword = "door"
      }
    },
    [1304] = {
      west = {
        exitDest = 1345,
        exitKey = 3411,
        exitKeyword = "door"
      }
    },
    [1305] = {
      north = {
        exitDescription = "You see a curtain to the north",
        exitDest = 1333,
        exitKeyword = "curtain"
      }
    },
    [1308] = {
      south = {
        exitDescription = "A door to the south",
        exitDest = 1309,
        exitKeyword = "door"
      }
    },
    [1309] = {
      north = {
        exitDest = 1308,
        exitKeyword = "north"
      },
      south = {
        exitDest = 1310,
        exitKeyword = "south"
      }
    },
    [1310] = {
      north = {
        exitDest = 1309,
        exitKeyword = "door"
      }
    },
    [1312] = {
      up = {
        exitDest = 1314,
        exitKeyword = "tunnel"
      }
    },
    [1314] = {
      down = {
        exitDest = 1312,
        exitKeyword = "stone"
      }
    },
    [1317] = {
      south = {
        exitDescription = "Finely polished oak doors stand in your way to the south.",
        exitDest = 1318,
        exitKeyword = "oak"
      },
      west = {
        exitDescription =
        "You see a large set of stone stairs leading upwards to a small stone door at the top. But they lead more west for some reason than up.",
        exitDest = 1303,
        exitKey = 3410,
        exitKeyword = "stone"
      }
    },
    [1318] = {
      north = {
        exitDest = 1317,
        exitKeyword = "oak"
      },
      south = {
        exitDescription =
        'The door has written above it : "May all the lands thank Crotus the Victor Without his guidance this kingdom would not have stood"',
        exitDest = 1319,
        exitKeyword = "door"
      }
    },
    [1319] = {
      north = {
        exitDest = 1318,
        exitKeyword = "door"
      }
    },
    [1323] = {
      south = {
        exitDest = 1324,
        exitKeyword = "door"
      }
    },
    [1324] = {
      north = {
        exitDest = 1323,
        exitKeyword = "door"
      }
    },
    [1325] = {
      down = {
        exitDescription =
        "There seems to be a handle on the top though you can't figure out why you didn't see it before.",
        exitDest = 1332,
        exitKeyword = "trapdoor"
      }
    },
    [1333] = {
      north = {
        exitDest = 1305,
        exitKeyword = "door"
      }
    },
    [1345] = {
      east = {
        exitDest = 1304,
        exitKey = 3411,
        exitKeyword = "door"
      }
    },
    [1356] = {
      down = {
        exitDescription = "A jet black coffin...who knows what lurks beneath.",
        exitDest = 1371,
        exitKey = 3419,
        exitKeyword = "coffin"
      }
    },
    [1360] = {
      east = {
        exitDescription = "there seems to be a faint outline of something here...maybe a secret door",
        exitDest = 1366,
        exitKeyword = "secret"
      }
    },
    [1367] = {
      west = {
        exitDescription = "Hmm...a small wooden door is this way.",
        exitDest = 1365,
        exitKeyword = "door"
      }
    },
    [1371] = {
      up = {
        exitDest = 1356,
        exitKey = 3419,
        exitKeyword = "lid"
      }
    },
    [1374] = {
      north = {
        exitDescription = "Inside the house",
        exitDest = 1375,
        exitKeyword = "double"
      }
    },
    [1375] = {
      south = {
        exitDescription = "Le Chateau d'Angoisse",
        exitDest = 1374,
        exitKeyword = "double"
      }
    },
    [1377] = {
      down = {
        exitDescription = "The Dungeon",
        exitDest = 1385,
        exitKeyword = "trapdoor"
      }
    },
    [1378] = {
      north = {
        exitDescription = "Hallway",
        exitDest = 1379,
        exitKeyword = "engraved"
      }
    },
    [1379] = {
      south = {
        exitDescription = "The West Hall",
        exitDest = 1378,
        exitKeyword = "engraved"
      }
    },
    [1381] = {
      east = {
        exitDescription = "The East Hall",
        exitDest = 1382,
        exitKeyword = "engraved"
      },
      south = {
        exitDescription = "Grimy hallway",
        exitDest = 1383,
        exitKeyword = "door"
      }
    },
    [1382] = {
      west = {
        exitDescription = "Hallway",
        exitDest = 1381,
        exitKeyword = "engraved"
      }
    },
    [1383] = {
      north = {
        exitDescription = "Hallway",
        exitDest = 1381,
        exitKeyword = "door"
      }
    },
    [1385] = {
      east = {
        exitDescription = "Small passage",
        exitDest = 1387,
        exitKeyword = "door"
      },
      up = {
        exitDescription = "The Library",
        exitDest = 1377,
        exitKeyword = "trapdoor"
      }
    },
    [1387] = {
      west = {
        exitDescription = "The Dungeon",
        exitDest = 1385,
        exitKeyword = "door"
      }
    },
    [1390] = {
      south = {
        exitDescription = "Torture Chamber",
        exitDest = 1391,
        exitKeyword = "iron"
      }
    },
    [1391] = {
      east = {
        exitDescription = "Resting room of the Baron",
        exitDest = 1392,
        exitKeyword = "secret"
      },
      north = {
        exitDescription = "Resting Room",
        exitDest = 1390,
        exitKeyword = "iron"
      }
    },
    [1392] = {
      west = {
        exitDescription = "The Torture Chamber",
        exitDest = 1391,
        exitKeyword = "secret"
      }
    },
    [1393] = {
      south = {
        exitDescription = "Bedroom",
        exitDest = 1397,
        exitKeyword = "door"
      }
    },
    [1394] = {
      east = {
        exitDescription = "Stairs",
        exitDest = 1398,
        exitKey = 1,
        exitKeyword = "door"
      },
      north = {
        exitDescription = "Bedroom",
        exitDest = 1395,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "Bedroom",
        exitDest = 1396,
        exitKeyword = "door"
      }
    },
    [1395] = {
      south = {
        exitDescription = "Hallway",
        exitDest = 1394,
        exitKeyword = "door"
      }
    },
    [1396] = {
      north = {
        exitDescription = "Hallway",
        exitDest = 1394,
        exitKeyword = "door"
      }
    },
    [1397] = {
      north = {
        exitDescription = "Hallway",
        exitDest = 1393,
        exitKeyword = "door"
      }
    },
    [1399] = {
      south = {
        exitDescription = "White Room",
        exitDest = 1400,
        exitKeyword = "door"
      }
    },
    [1400] = {
      north = {
        exitDescription = "The Closet",
        exitDest = 1399,
        exitKeyword = "door"
      }
    },
    [1412] = {
      south = {
        exitDescription = "The Long Hall",
        exitDest = 1413,
        exitKeyword = "secret"
      }
    },
    [1413] = {
      north = {
        exitDescription = "The Master Bedroom",
        exitDest = 1412,
        exitKeyword = "secret"
      }
    },
    [1417] = {
      south = {
        exitDescription = "The Cell of the Marquis de Sade",
        exitDest = 1418,
        exitKeyword = "steel"
      }
    },
    [1418] = {
      north = {
        exitDescription = "The Long Hallway",
        exitDest = 1417,
        exitKeyword = "steel"
      }
    },
    [1448] = {
      north = {
        exitDescription = "A Massive Oak Door",
        exitDest = 1453,
        exitKeyword = "oak"
      }
    },
    [1453] = {
      south = {
        exitDescription = "A Massive Oak Door.",
        exitDest = 1448,
        exitKeyword = "oak"
      }
    },
    [1455] = {
      north = {
        exitDescription = "The Door to the Bedroom",
        exitDest = 1456,
        exitKey = 3702,
        exitKeyword = "door"
      }
    },
    [1456] = {
      south = {
        exitDescription = "The Door to the Sitting Room",
        exitDest = 1455,
        exitKey = 3702,
        exitKeyword = "door"
      }
    },
    [1470] = {
      down = {
        exitDescription = "You think you see a trap door.",
        exitDest = 1474,
        exitKey = 3798,
        exitKeyword = "trapdoor"
      },
      north = {
        exitDescription = "You see a meat locker.",
        exitDest = 1471,
        exitKeyword = "locker"
      },
      south = {
        exitDescription = "You see a meat locker.",
        exitDest = 1473,
        exitKeyword = "locker"
      }
    },
    [1471] = {
      south = {
        exitDescription = "You see a locker door.",
        exitDest = 1470,
        exitKeyword = "locker"
      }
    },
    [1473] = {
      north = {
        exitDescription = "You see a locker door.",
        exitDest = 1470,
        exitKeyword = "locker"
      }
    },
    [1474] = {
      up = {
        exitDescription = "You see a door in the ceiling.",
        exitDest = 1470,
        exitKey = 3798,
        exitKeyword = "trapdoor"
      }
    },
    [1493] = {
      down = {
        exitDest = 1514,
        exitKeyword = "entryway"
      }
    },
    [1514] = {
      up = {
        exitDest = 1493,
        exitKeyword = "entryway"
      }
    },
    [1639] = {
      west = {
        exitDescription = "You see a strong iron door.",
        exitDest = 1646,
        exitKey = 4014,
        exitKeyword = "iron"
      }
    },
    [1640] = {
      west = {
        exitDescription = "You see a rock wall with a stream coming out from between the rocks.",
        exitDest = 1644,
        exitKeyword = "hidden"
      }
    },
    [1644] = {
      east = {
        exitDescription = "You see an exit to the mountain side.",
        exitDest = 1640,
        exitKeyword = "hidden"
      }
    },
    [1646] = {
      east = {
        exitDescription = "You see an iron door.",
        exitDest = 1639,
        exitKey = 4014,
        exitKeyword = "iron"
      }
    },
    [1686] = {
      south = {
        exitDescription = "You see a rock wall.",
        exitDest = 1687,
        exitKeyword = "secret"
      }
    },
    [1687] = {
      north = {
        exitDescription = "You see a rock wall.",
        exitDest = 1686,
        exitKeyword = "hidden"
      }
    },
    [1729] = {
      south = {
        exitDest = 1730,
        exitKeyword = "shadow"
      }
    },
    [1731] = {
      north = {
        exitDest = 1736,
        exitKeyword = "fire"
      }
    },
    [1744] = {
      south = {
        exitDest = 1748,
        exitKeyword = "wood"
      }
    },
    [1746] = {
      up = {
        exitDescription = "The Balcony.",
        exitDest = 1751,
        exitKeyword = "door"
      }
    },
    [1757] = {
      south = {
        exitDest = 1762,
        exitKey = 4287,
        exitKeyword = "silver"
      }
    },
    [1764] = {
      down = {
        exitDest = 1765,
        exitKeyword = "iron"
      }
    },
    [1765] = {
      up = {
        exitDest = 1764,
        exitKeyword = "iron"
      }
    },
    [1775] = {
      north = {
        exitDest = 1776,
        exitKeyword = "stone"
      }
    },
    [1857] = {
      south = {
        exitDescription = "The wooden door leads south.",
        exitDest = 1858,
        exitKeyword = "door"
      }
    },
    [1858] = {
      east = {
        exitDescription = "The desk doesn't appear to be pushed firmly against the wall.",
        exitDest = 1860,
        exitKeyword = "desk"
      },
      north = {
        exitDescription = "With the door open, you can see the path.",
        exitDest = 1857,
        exitKeyword = "door"
      }
    },
    [1860] = {
      west = {
        exitDescription = "The desk out of the way, you are free to return to the main room.",
        exitDest = 1858,
        exitKeyword = "door"
      }
    },
    [1862] = {
      east = {
        exitDescription = "The bramble blocks your view, but it seems darker on the other side.",
        exitDest = 1866,
        exitKey = 4701,
        exitKeyword = "gate"
      }
    },
    [1863] = {
      east = {
        exitDescription = "The bramble blocks your view, but it seems darker on the other side.",
        exitDest = 1867,
        exitKey = 4701,
        exitKeyword = "gate"
      }
    },
    [1866] = {
      west = {
        exitDescription = "The gate is tall and made of iron.",
        exitDest = 1862,
        exitKey = 4701,
        exitKeyword = "gate"
      }
    },
    [1867] = {
      west = {
        exitDescription = "The gate is tall and made of iron.",
        exitDest = 1863,
        exitKey = 4701,
        exitKeyword = "gate"
      }
    },
    [1874] = {
      east = {
        exitDescription = "You study the trunk with diligence and see a piece missing.",
        exitDest = 1878,
        exitKey = 4702,
        exitKeyword = "trunk"
      }
    },
    [1878] = {
      west = {
        exitDescription = "The small 'door' is just a part of the tree trunk.",
        exitDest = 1874,
        exitKey = 4702,
        exitKeyword = "trunk"
      }
    },
    [1884] = {
      west = {
        exitDescription = "You can just fit through the small door.",
        exitDest = 1878,
        exitKeyword = "door"
      }
    },
    [1885] = {
      west = {
        exitDescription = "The door is locked.",
        exitDest = 1886,
        exitKey = 4703,
        exitKeyword = "door"
      }
    },
    [1886] = {
      east = {
        exitDest = 1886,
        exitKey = 4703,
        exitKeyword = "door"
      }
    },
    [1932] = {
      down = {
        exitDest = 1952,
        exitKeyword = "trapdoor"
      }
    },
    [1944] = {
      down = {
        exitDest = 1954,
        exitKeyword = "trapdoor"
      }
    },
    [1947] = {
      down = {
        exitDest = 1953,
        exitKeyword = "trapdoor"
      }
    },
    [1978] = {
      west = {
        exitDescription = "A huge gate opens to the west allowing entrance into the city.",
        exitDest = 1979,
        exitFlags = -1,
        exitKeyword = "gate"
      }
    },
    [1982] = {
      south = {
        exitDest = 1983,
        exitKeyword = "door"
      }
    },
    [1983] = {
      north = {
        exitDest = 1982,
        exitKeyword = "door"
      }
    },
    [1986] = {
      west = {
        exitDest = 1987,
        exitKeyword = "door"
      }
    },
    [1987] = {
      east = {
        exitDest = 1986,
        exitKeyword = "door"
      }
    },
    [1988] = {
      west = {
        exitDescription = "A large gate lies to the west.",
        exitDest = 1989,
        exitKeyword = "gate"
      }
    },
    [1989] = {
      east = {
        exitDest = 1988,
        exitKeyword = "door"
      }
    },
    [1990] = {
      north = {
        exitDest = 1991,
        exitKeyword = "door"
      }
    },
    [1991] = {
      south = {
        exitDest = 1990,
        exitKeyword = "door"
      }
    },
    [1993] = {
      west = {
        exitDest = 1994,
        exitKeyword = "door"
      }
    },
    [1994] = {
      east = {
        exitDest = 1993,
        exitKeyword = "door"
      }
    },
    [1995] = {
      north = {
        exitDescription = "The entrance to the temple of Illizeth, the mother of serpents.",
        exitDest = 1997,
        exitKeyword = "door"
      }
    },
    [1997] = {
      south = {
        exitDest = 1995,
        exitKeyword = "door"
      }
    },
    [1998] = {
      south = {
        exitDest = 1999,
        exitKeyword = "door"
      }
    },
    [1999] = {
      north = {
        exitDest = 1998,
        exitKeyword = "door"
      }
    },
    [2001] = {
      north = {
        exitDest = 2002,
        exitKeyword = "door"
      }
    },
    [2002] = {
      south = {
        exitDest = 2001,
        exitKeyword = "door"
      }
    },
    [2007] = {
      north = {
        exitDest = 2028,
        exitKeyword = "door"
      }
    },
    [2010] = {
      south = {
        exitDest = 2011,
        exitKeyword = "door"
      }
    },
    [2011] = {
      north = {
        exitDest = 2009,
        exitKeyword = "door"
      }
    },
    [2014] = {
      east = {
        exitDest = 2015,
        exitKeyword = "door"
      }
    },
    [2015] = {
      west = {
        exitDest = 2014,
        exitKeyword = "door"
      }
    },
    [2016] = {
      west = {
        exitDest = 2017,
        exitKeyword = "door"
      }
    },
    [2017] = {
      east = {
        exitDest = 2016,
        exitKeyword = "door"
      }
    },
    [2018] = {
      north = {
        exitDest = 2019,
        exitKeyword = "door"
      }
    },
    [2019] = {
      south = {
        exitDest = 2018,
        exitKeyword = "door"
      }
    },
    [2020] = {
      east = {
        exitDest = 2024,
        exitKeyword = "door"
      }
    },
    [2024] = {
      north = {
        exitDest = 2025,
        exitKeyword = "door"
      }
    },
    [2025] = {
      south = {
        exitDest = 2024,
        exitKeyword = "door"
      }
    },
    [2026] = {
      west = {
        exitDest = 2027,
        exitKeyword = "door"
      }
    },
    [2027] = {
      east = {
        exitDest = 2026,
        exitKeyword = "door"
      }
    },
    [2028] = {
      south = {
        exitDest = 2007,
        exitKeyword = "door"
      }
    },
    [2039] = {
      east = {
        exitDescription = "A small doorway leads into a partially collapsed house.",
        exitDest = 2073,
        exitKeyword = "door"
      }
    },
    [2114] = {
      down = {
        exitDescription = "The cover is heavy, but can be moved.",
        exitDest = 2142,
        exitKeyword = "cover"
      }
    },
    [2121] = {
      west = {
        exitDest = 2141,
        exitKeyword = "door"
      }
    },
    [2129] = {
      north = {
        exitDest = 2144,
        exitKeyword = "door"
      }
    },
    [2131] = {
      down = {
        exitDest = 2161,
        exitKeyword = "plate"
      }
    },
    [2136] = {
      up = {
        exitDest = 2141,
        exitKeyword = "grate"
      }
    },
    [2141] = {
      down = {
        exitDest = 2136,
        exitKeyword = "grate"
      },
      east = {
        exitDest = 2121,
        exitKeyword = "door"
      }
    },
    [2142] = {
      up = {
        exitDest = 2114,
        exitKeyword = "cover"
      }
    },
    [2144] = {
      south = {
        exitDest = 2129,
        exitKeyword = "door"
      }
    },
    [2147] = {
      south = {
        exitDest = 2149,
        exitKeyword = "door"
      }
    },
    [2149] = {
      north = {
        exitDest = 2147,
        exitKeyword = "door"
      }
    },
    [2150] = {
      south = {
        exitDest = 2156,
        exitKeyword = "curtain"
      }
    },
    [2151] = {
      north = {
        exitDest = 2152,
        exitKeyword = "cage"
      }
    },
    [2152] = {
      south = {
        exitDest = 2151,
        exitKeyword = "cage"
      }
    },
    [2155] = {
      west = {
        exitDest = 2156,
        exitKeyword = "door"
      }
    },
    [2156] = {
      east = {
        exitDest = 2155,
        exitKeyword = "door"
      },
      north = {
        exitDest = 2150,
        exitKeyword = "curtain"
      }
    },
    [2160] = {
      south = {
        exitDest = 2161,
        exitKeyword = "door"
      }
    },
    [2161] = {
      north = {
        exitDest = 2160,
        exitKeyword = "door"
      },
      up = {
        exitDescription = "There appears to be a moveable plate covering a hole in the ceiling.",
        exitDest = 2131,
        exitKeyword = "plate"
      }
    },
    [2165] = {
      south = {
        exitDest = 2166,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [2166] = {
      south = {
        exitDest = 2167,
        exitKeyword = "door"
      }
    },
    [2167] = {
      north = {
        exitDest = 2166,
        exitKeyword = "door"
      }
    },
    [2175] = {
      north = {
        exitDest = 2176,
        exitKeyword = "door"
      }
    },
    [2176] = {
      south = {
        exitDest = 2175,
        exitKeyword = "door"
      }
    },
    [2181] = {
      down = {
        exitDescription = "You look into what seems to be a deep pit.",
        exitDest = 2184,
        exitKey = 5452,
        exitKeyword = "grate"
      }
    },
    [2182] = {
      north = {
        exitDest = 2183,
        exitKeyword = "door"
      }
    },
    [2183] = {
      south = {
        exitDest = 2182,
        exitKeyword = "door"
      }
    },
    [2184] = {
      up = {
        exitDescription = "It is a long way up, but you can make it.",
        exitDest = 2181,
        exitKey = 5452,
        exitKeyword = "grate"
      }
    },
    [2191] = {
      east = {
        exitDescription = "You see the gates of the post.",
        exitDest = 2198,
        exitKeyword = "gate"
      }
    },
    [2198] = {
      west = {
        exitDescription = "You see a barracks and the gates leading to the lake shore.",
        exitDest = 2191,
        exitKeyword = "gate"
      }
    },
    [2200] = {
      east = {
        exitDescription = "You see the gates to the encampment beyond.",
        exitDest = 2209,
        exitKeyword = "gate"
      }
    },
    [2209] = {
      west = {
        exitDescription = "You see the gate to the trading post.",
        exitDest = 2200,
        exitKeyword = "gate"
      }
    },
    [2222] = {
      down = {
        exitDescription = "You see a secret door.",
        exitDest = 2223,
        exitKeyword = "secret"
      }
    },
    [2227] = {
      up = {
        exitDest = 2230,
        exitKey = 5704,
        exitKeyword = "coffin"
      }
    },
    [2230] = {
      down = {
        exitDest = 2227,
        exitKeyword = "Coffin"
      },
      east = {
        exitDescription = "You see a door here with no apparent keyhole. I trust you have a mage or thief with you.",
        exitDest = 2234,
        exitKeyword = "door"
      },
      up = {
        exitDescription = "Something or someone has magically blocked your way",
        exitDest = 2228,
        exitKeyword = "nothing"
      }
    },
    [2240] = {
      south = {
        exitDest = 2241,
        exitKeyword = "door"
      }
    },
    [2241] = {
      north = {
        exitDest = 2240,
        exitKeyword = "door"
      },
      south = {
        exitDest = 2242,
        exitKeyword = "south"
      }
    },
    [2242] = {
      north = {
        exitDest = 2241,
        exitKeyword = "door"
      }
    },
    [2243] = {
      south = {
        exitDest = 2244,
        exitKeyword = "door"
      }
    },
    [2244] = {
      north = {
        exitDest = 2243,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "you see a large iron gate to the south.",
        exitDest = 2245,
        exitKey = 5700,
        exitKeyword = "gate"
      }
    },
    [2245] = {
      north = {
        exitDest = 2244,
        exitKey = 5700,
        exitKeyword = "gate"
      }
    },
    [2246] = {
      down = {
        exitDescription =
        "The iron door looks unopenable without the proper key. The eyes of the horned devil glow slightly.",
        exitDest = 2260,
        exitKey = 5701,
        exitKeyword = "iron"
      }
    },
    [2260] = {
      up = {
        exitDest = 2246,
        exitKey = 5701,
        exitKeyword = "iron"
      }
    },
    [2270] = {
      up = {
        exitDest = 4234,
        exitKeyword = "door"
      }
    },
    [2286] = {
      north = {
        exitDescription = "The wooden door is quite sturdy but does not appear to be equipped with a lock.",
        exitDest = 2287,
        exitKeyword = "door"
      }
    },
    [2287] = {
      south = {
        exitDescription = "The wooden door leads south.",
        exitDest = 2286,
        exitKeyword = "door"
      }
    },
    [2407] = {
      north = {
        exitDest = 2413,
        exitKeyword = "door"
      }
    },
    [2409] = {
      north = {
        exitDest = 2416,
        exitKey = 6301,
        exitKeyword = "door"
      }
    },
    [2412] = {
      east = {
        exitDest = 2413,
        exitKeyword = "door"
      }
    },
    [2413] = {
      south = {
        exitDest = 2407,
        exitKeyword = "door"
      },
      west = {
        exitDest = 2412,
        exitKeyword = "door"
      }
    },
    [2414] = {
      north = {
        exitDest = 2421,
        exitKeyword = "door"
      }
    },
    [2415] = {
      east = {
        exitDest = 2416,
        exitKeyword = "door"
      }
    },
    [2416] = {
      north = {
        exitDest = 2422,
        exitKey = 6301,
        exitKeyword = "door"
      },
      south = {
        exitDest = 2409,
        exitKey = 6301,
        exitKeyword = "door"
      },
      west = {
        exitDest = 2415,
        exitKeyword = "door"
      }
    },
    [2421] = {
      south = {
        exitDest = 2414,
        exitKeyword = "door"
      }
    },
    [2422] = {
      south = {
        exitDest = 2416,
        exitKey = 6301,
        exitKeyword = "door"
      }
    },
    [2440] = {
      east = {
        exitDest = 2441,
        exitKey = 6302,
        exitKeyword = "door"
      }
    },
    [2441] = {
      east = {
        exitDest = 2442,
        exitKey = 6302,
        exitKeyword = "door"
      },
      west = {
        exitDest = 2440,
        exitKey = 6302,
        exitKeyword = "door"
      }
    },
    [2442] = {
      west = {
        exitDest = 2441,
        exitKey = 6302,
        exitKeyword = "door"
      }
    },
    [2493] = {
      south = {
        exitDest = 2498,
        exitKeyword = "door"
      }
    },
    [2496] = {
      east = {
        exitDest = 2497,
        exitKeyword = "door"
      },
      north = {
        exitDest = 2491,
        exitKeyword = "door"
      }
    },
    [2497] = {
      west = {
        exitDest = 2496,
        exitKeyword = "door"
      }
    },
    [2498] = {
      north = {
        exitDest = 2493,
        exitKeyword = "door"
      },
      south = {
        exitDest = 2502,
        exitKeyword = "door"
      }
    },
    [2500] = {
      south = {
        exitDest = 2504,
        exitKeyword = "door"
      }
    },
    [2501] = {
      north = {
        exitDest = 2496,
        exitKeyword = "door"
      },
      south = {
        exitDest = 2505,
        exitKeyword = "door"
      }
    },
    [2502] = {
      east = {
        exitDest = 2503,
        exitKeyword = "door"
      },
      north = {
        exitDest = 2498,
        exitKeyword = "door"
      },
      south = {
        exitDest = 2506,
        exitKeyword = "door"
      }
    },
    [2503] = {
      south = {
        exitDest = 2507,
        exitKeyword = "door"
      }
    },
    [2504] = {
      east = {
        exitDest = 2505,
        exitKeyword = "door"
      },
      north = {
        exitDest = 2500,
        exitKeyword = "door"
      },
      south = {
        exitDest = 2507,
        exitKeyword = "door"
      }
    },
    [2505] = {
      north = {
        exitDest = 2501,
        exitKeyword = "door"
      },
      west = {
        exitDest = 2504,
        exitKeyword = "door"
      }
    },
    [2506] = {
      north = {
        exitDest = 2502,
        exitKeyword = "door"
      }
    },
    [2507] = {
      north = {
        exitDest = 2504,
        exitKeyword = "door"
      }
    },
    [2530] = {
      west = {
        exitDest = 2538,
        exitKey = 6503,
        exitKeyword = "door"
      }
    },
    [2534] = {
      north = {
        exitDest = 2535,
        exitKey = 6503,
        exitKeyword = "door"
      }
    },
    [2535] = {
      south = {
        exitDest = 2534,
        exitKey = 6503,
        exitKeyword = "door"
      }
    },
    [2537] = {
      east = {
        exitDest = 2550,
        exitKey = 6514,
        exitKeyword = "door"
      }
    },
    [2538] = {
      east = {
        exitDescription = "The path leads outside the entrance.",
        exitDest = 2530,
        exitKey = 6503,
        exitKeyword = "door"
      }
    },
    [2546] = {
      south = {
        exitDest = 2548,
        exitKeyword = "door"
      }
    },
    [2548] = {
      north = {
        exitDest = 2546,
        exitKeyword = "door"
      }
    },
    [2550] = {
      west = {
        exitDest = 2537,
        exitKey = 6514,
        exitKeyword = "door"
      }
    },
    [2551] = {
      down = {
        exitDest = 2552,
        exitKeyword = "trapdoor"
      }
    },
    [2552] = {
      up = {
        exitDest = 2551,
        exitKeyword = "trapdoor"
      }
    },
    [2556] = {
      north = {
        exitDest = 2557,
        exitKeyword = "door"
      }
    },
    [2557] = {
      south = {
        exitDest = 2556,
        exitKeyword = "door"
      }
    },
    [2561] = {
      east = {
        exitDest = 2562,
        exitKey = 6502,
        exitKeyword = "door"
      }
    },
    [2562] = {
      west = {
        exitDest = 2561,
        exitKey = 6502,
        exitKeyword = "door"
      }
    },
    [2565] = {
      north = {
        exitDest = 2567,
        exitKey = 6516,
        exitKeyword = "door"
      }
    },
    [2567] = {
      south = {
        exitDest = 2565,
        exitKey = 6516,
        exitKeyword = "door"
      }
    },
    [2607] = {
      east = {
        exitDescription = "A dark disused trail",
        exitDest = 2608,
        exitKeyword = "hedge"
      }
    },
    [2676] = {
      east = {
        exitDescription = "The Offering Chamber",
        exitDest = 2677,
        exitKey = 6703,
        exitKeyword = "door"
      }
    },
    [2700] = {
      north = {
        exitDescription = "The Outer/Inner Portal",
        exitDest = 2712,
        exitKey = 6700,
        exitKeyword = "portal"
      }
    },
    [2712] = {
      north = {
        exitDescription = "The Inner Ring",
        exitDest = 2715,
        exitKey = 6700,
        exitKeyword = "portal"
      },
      south = {
        exitDescription = "The Outer Ring",
        exitDest = 2700,
        exitKey = 6700,
        exitKeyword = "portal"
      }
    },
    [2715] = {
      south = {
        exitDescription = "The Outer/Inner portal",
        exitDest = 2712,
        exitKey = 6700,
        exitKeyword = "portal"
      }
    },
    [2725] = {
      south = {
        exitDescription = "The Inner/Center Portal",
        exitDest = 2734,
        exitKey = 6701,
        exitKeyword = "portal"
      }
    },
    [2734] = {
      north = {
        exitDescription = "At the Entrance to the Center Ring",
        exitDest = 2725,
        exitKey = 6701,
        exitKeyword = "portal"
      },
      south = {
        exitDescription = "In the Center Ring",
        exitDest = 2737,
        exitKey = 6701,
        exitKeyword = "portal"
      }
    },
    [2737] = {
      north = {
        exitDescription = "The Inner/Center portal",
        exitDest = 2734,
        exitKey = 6701,
        exitKeyword = "portal"
      }
    },
    [2746] = {
      north = {
        exitDescription = "The Hidden Passage",
        exitDest = 2753,
        exitKey = 6702,
        exitKeyword = "secret"
      }
    },
    [2753] = {
      north = {
        exitDescription = "The Hidden Passage",
        exitDest = 2754,
        exitKey = 6702,
        exitKeyword = "secret"
      },
      south = {
        exitDescription = "The Center Ring",
        exitDest = 2746,
        exitKey = 6702,
        exitKeyword = "secret"
      }
    },
    [2754] = {
      south = {
        exitDescription = "The Hidden Passage",
        exitDest = 2753,
        exitKey = 6702,
        exitKeyword = "secret"
      }
    },
    [2812] = {
      west = {
        exitDescription = "The front door leads to Park Road.",
        exitDest = 1233,
        exitKey = 3301,
        exitKeyword = "door"
      }
    },
    [2815] = {
      up = {
        exitDescription = "OSU's humble abode",
        exitDest = 2846,
        exitKeyword = "door"
      }
    },
    [2819] = {
      north = {
        exitDescription = "Entrance to outpost",
        exitDest = 2820,
        exitKeyword = "gate"
      }
    },
    [2820] = {
      east = {
        exitDescription = "Weapons room",
        exitDest = 2821,
        exitKeyword = "door"
      },
      west = {
        exitDescription = "closet",
        exitDest = 2822,
        exitKeyword = "door"
      }
    },
    [2821] = {
      west = {
        exitDescription = "Entrance to outpost",
        exitDest = 2820,
        exitKeyword = "door"
      }
    },
    [2822] = {
      east = {
        exitDescription = "Entrance to outpost",
        exitDest = 2820,
        exitKeyword = "door"
      }
    },
    [2826] = {
      west = {
        exitDescription = "bedroom",
        exitDest = 2832,
        exitKeyword = "door"
      }
    },
    [2833] = {
      north = {
        exitDest = 2836,
        exitKeyword = "door"
      }
    },
    [2846] = {
      down = {
        exitDest = 2815,
        exitKeyword = "door"
      }
    },
    [2854] = {
      north = {
        exitDest = 2855,
        exitKeyword = "gate"
      }
    },
    [2855] = {
      south = {
        exitDest = 2854,
        exitKeyword = "gate"
      }
    },
    [2859] = {
      north = {
        exitDest = 2860,
        exitKeyword = "door"
      }
    },
    [2860] = {
      south = {
        exitDest = 2859,
        exitKeyword = "door"
      }
    },
    [2864] = {
      east = {
        exitDest = 2886,
        exitKeyword = "cell"
      },
      west = {
        exitDest = 2885,
        exitKeyword = "cell"
      }
    },
    [2865] = {
      east = {
        exitDest = 2888,
        exitKeyword = "cell"
      },
      west = {
        exitDest = 2887,
        exitKeyword = "cell"
      }
    },
    [2866] = {
      east = {
        exitDest = 2890,
        exitKeyword = "cell"
      },
      west = {
        exitDest = 2889,
        exitKeyword = "cell"
      }
    },
    [2868] = {
      north = {
        exitDest = 2891,
        exitKeyword = "cell"
      }
    },
    [2869] = {
      north = {
        exitDest = 2892,
        exitKeyword = "cell"
      },
      south = {
        exitDest = 2893,
        exitKeyword = "cell"
      }
    },
    [2870] = {
      north = {
        exitDest = 2894,
        exitKeyword = "cell"
      },
      south = {
        exitDest = 2895,
        exitKeyword = "cell"
      }
    },
    [2871] = {
      north = {
        exitDest = 2896,
        exitKeyword = "cell"
      },
      south = {
        exitDest = 2897,
        exitKeyword = "cell"
      }
    },
    [2872] = {
      north = {
        exitDest = 2898,
        exitKeyword = "cell"
      }
    },
    [2874] = {
      east = {
        exitDest = 2899,
        exitKeyword = "cell"
      },
      west = {
        exitDest = 2900,
        exitKeyword = "cell"
      }
    },
    [2875] = {
      east = {
        exitDest = 2901,
        exitKeyword = "cell"
      },
      west = {
        exitDest = 2902,
        exitKeyword = "cell"
      }
    },
    [2876] = {
      east = {
        exitDest = 2903,
        exitKeyword = "cell"
      },
      west = {
        exitDest = 2904,
        exitKeyword = "cell"
      }
    },
    [2880] = {
      east = {
        exitDest = 2883,
        exitKeyword = "door"
      },
      west = {
        exitDest = 2882,
        exitKeyword = "door"
      }
    },
    [2881] = {
      down = {
        exitDescription = "The trapdoor seems to cover a hole leading to caverns under the Asylum.",
        exitDest = 2905,
        exitKey = 7118,
        exitKeyword = "trapdoor"
      }
    },
    [2882] = {
      east = {
        exitDest = 2880,
        exitKeyword = "door"
      },
      north = {
        exitDescription = "There is a secret false wall leading north here.",
        exitDest = 2884,
        exitKey = 7119,
        exitKeyword = "secret"
      }
    },
    [2883] = {
      west = {
        exitDest = 2880,
        exitKeyword = "door"
      }
    },
    [2884] = {
      south = {
        exitDescription = "The secret false wall leads to the south.",
        exitDest = 2882,
        exitKey = 7119,
        exitKeyword = "secret"
      }
    },
    [2885] = {
      east = {
        exitDest = 2864,
        exitKeyword = "cell"
      }
    },
    [2886] = {
      west = {
        exitDest = 2864,
        exitKeyword = "cell"
      }
    },
    [2887] = {
      east = {
        exitDest = 2865,
        exitKeyword = "cell"
      }
    },
    [2888] = {
      west = {
        exitDest = 2865,
        exitKeyword = "cell"
      }
    },
    [2889] = {
      east = {
        exitDest = 2866,
        exitKeyword = "cell"
      }
    },
    [2890] = {
      west = {
        exitDest = 2866,
        exitKeyword = "cell"
      }
    },
    [2891] = {
      south = {
        exitDest = 2868,
        exitKeyword = "cell"
      }
    },
    [2892] = {
      south = {
        exitDest = 2869,
        exitKeyword = "cell"
      }
    },
    [2893] = {
      north = {
        exitDest = 2869,
        exitKeyword = "cell"
      }
    },
    [2894] = {
      south = {
        exitDest = 2870,
        exitKeyword = "cell"
      }
    },
    [2895] = {
      north = {
        exitDest = 2870,
        exitKeyword = "cell"
      }
    },
    [2896] = {
      south = {
        exitDest = 2871,
        exitKeyword = "cell"
      }
    },
    [2897] = {
      north = {
        exitDest = 2871,
        exitKeyword = "cell"
      }
    },
    [2898] = {
      south = {
        exitDest = 2872,
        exitKeyword = "cell"
      }
    },
    [2899] = {
      west = {
        exitDest = 2874,
        exitKeyword = "cell"
      }
    },
    [2900] = {
      east = {
        exitDest = 2874,
        exitKeyword = "cell"
      }
    },
    [2901] = {
      west = {
        exitDest = 2875,
        exitKeyword = "cell"
      }
    },
    [2902] = {
      east = {
        exitDest = 2875,
        exitKeyword = "cell"
      }
    },
    [2903] = {
      west = {
        exitDest = 2876,
        exitKeyword = "cell"
      }
    },
    [2904] = {
      east = {
        exitDest = 2876,
        exitKeyword = "cell"
      }
    },
    [2905] = {
      up = {
        exitDest = 2881,
        exitKey = 7118,
        exitKeyword = "trapdoor"
      }
    },
    [2911] = {
      south = {
        exitDescription = "You think you can see a secret opening to the south.",
        exitDest = 2912,
        exitKeyword = "secret"
      }
    },
    [2912] = {
      north = {
        exitDescription = "You can see a secret opening to the north.",
        exitDest = 2911,
        exitKeyword = "secret"
      }
    },
    [2922] = {
      north = {
        exitDescription = "There is a small hole to the north you think you could squeeze through.",
        exitDest = 2923,
        exitKeyword = "hole"
      }
    },
    [2923] = {
      south = {
        exitDest = 2922,
        exitKeyword = "hole"
      }
    },
    [2927] = {
      west = {
        exitDescription = "There's a small crack to the west here.",
        exitDest = 2928,
        exitKeyword = "crack"
      }
    },
    [2928] = {
      east = {
        exitDescription = "There's a small crack to the east here.",
        exitDest = 2927,
        exitKeyword = "crack"
      }
    },
    [2937] = {
      east = {
        exitDescription = "There is a large crack to the east.",
        exitDest = 2938,
        exitKeyword = "crack"
      }
    },
    [2938] = {
      west = {
        exitDescription = "There is a large crack to the west.",
        exitDest = 2937,
        exitKeyword = "crack"
      }
    },
    [2942] = {
      east = {
        exitDescription = "You think you can see a secret opening to the east.",
        exitDest = 2946,
        exitKeyword = "secret"
      }
    },
    [2946] = {
      west = {
        exitDescription = "There appears to be a secret opening to the west.",
        exitDest = 2942,
        exitKeyword = "secret"
      }
    },
    [2953] = {
      north = {
        exitDescription = "The way to the altar.",
        exitDest = 2954,
        exitKeyword = "curtain"
      }
    },
    [2954] = {
      north = {
        exitDescription = "A small gate keeping the Vadir away from the High Priest.",
        exitDest = 2955,
        exitKeyword = "gate"
      },
      south = {
        exitDescription = "A curtain leading to the High Priest's private chamber.",
        exitDest = 2953,
        exitKeyword = "curtain"
      }
    },
    [2955] = {
      south = {
        exitDescription = "A small gate stops you from going south to the altar.",
        exitDest = 2954,
        exitKeyword = "gate"
      }
    },
    [2970] = {
      north = {
        exitDest = 2975,
        exitKeyword = "door"
      }
    },
    [2975] = {
      south = {
        exitDest = 2970,
        exitKeyword = "door"
      }
    },
    [3079] = {
      south = {
        exitDescription = "The small and disgusting hut.",
        exitDest = 3080,
        exitKeyword = "door"
      }
    },
    [3080] = {
      north = {
        exitDescription = "An exit to less nose taxing world.",
        exitDest = 3079,
        exitKeyword = "exit"
      },
      west = {
        exitDescription = "You see a dark room, you think its a workroom.",
        exitDest = 3081,
        exitKeyword = "door"
      }
    },
    [3081] = {
      east = {
        exitDescription = "The smelly kitchen.",
        exitDest = 3080,
        exitKeyword = "door"
      }
    },
    [3086] = {
      west = {
        exitDescription = "You see a hidden door.",
        exitDest = 3087,
        exitKeyword = "hidden"
      }
    },
    [3087] = {
      east = {
        exitDescription = "You see A Dark Tunnel",
        exitDest = 3086,
        exitKeyword = "hidden"
      }
    },
    [3102] = {
      down = {
        exitDescription = "You see a trapdoor downwards to somewhere.",
        exitDest = 3103,
        exitKeyword = "trapdoor"
      }
    },
    [3103] = {
      up = {
        exitDescription = "An exit upwards.",
        exitDest = 3102,
        exitKeyword = "exit"
      }
    },
    [3109] = {
      south = {
        exitDescription = "Through the gates to a dim courtyard.",
        exitDest = 3110,
        exitKeyword = "gate"
      }
    },
    [3110] = {
      east = {
        exitDescription = "A tarred door leads into the house.",
        exitDest = 3120,
        exitKeyword = "tarred"
      },
      north = {
        exitDescription = "You see the dark gates, outside is blindingly bright.",
        exitDest = 3109,
        exitKeyword = "gate"
      },
      south = {
        exitDescription = "A large tarred door leads into the house, above is a dark window.",
        exitDest = 3111,
        exitKeyword = "large"
      },
      west = {
        exitDescription = "A tarred door leads into the house.",
        exitDest = 3113,
        exitKeyword = "tarred"
      }
    },
    [3111] = {
      north = {
        exitDescription = "A tar covered door leads out of the house.",
        exitDest = 3110,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "A wide double door made of panelled wood leads somewhere.",
        exitDest = 3118,
        exitKeyword = "door"
      }
    },
    [3114] = {
      east = {
        exitDescription = "You see a cell door.",
        exitDest = 3116,
        exitKeyword = "cell"
      },
      north = {
        exitDescription = "You see a cell door.",
        exitDest = 3115,
        exitKeyword = "cell"
      },
      south = {
        exitDescription = "You see a cell door.",
        exitDest = 3117,
        exitKeyword = "cell"
      }
    },
    [3115] = {
      south = {
        exitDescription = "The way out!!",
        exitDest = 3114,
        exitKeyword = "door"
      }
    },
    [3116] = {
      west = {
        exitDescription = "The way out!!",
        exitDest = 3114,
        exitKeyword = "door"
      }
    },
    [3117] = {
      north = {
        exitDescription = "The way out!!",
        exitDest = 3114,
        exitKeyword = "door"
      }
    },
    [3118] = {
      east = {
        exitDescription = "A small door.",
        exitDest = 3119,
        exitKeyword = "door"
      },
      north = {
        exitDescription = "A set of Large double doors.",
        exitDest = 3111,
        exitKeyword = "door"
      }
    },
    [3119] = {
      west = {
        exitDescription = "The only door out of this strange place.",
        exitDest = 3118,
        exitKeyword = "door"
      }
    },
    [3120] = {
      east = {
        exitDescription = "A heavy wooden door.",
        exitDest = 3122,
        exitKeyword = "wooden"
      },
      south = {
        exitDescription = "A heavy metal door standing ajar.",
        exitDest = 3121,
        exitKeyword = "metal"
      },
      west = {
        exitDescription = "A heavy tarred door.",
        exitDest = 3110,
        exitKeyword = "tarred"
      }
    },
    [3122] = {
      west = {
        exitDescription = "A solid wooden door.",
        exitDest = 3120,
        exitKeyword = "door"
      }
    },
    [3124] = {
      east = {
        exitDescription = "A grubby door to a room.",
        exitDest = 3126,
        exitKeyword = "door"
      },
      west = {
        exitDescription = "A grubby door to a room.",
        exitDest = 3130,
        exitKeyword = "door"
      }
    },
    [3125] = {
      east = {
        exitDescription = "A grubby door to a room.",
        exitDest = 3127,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "A smashed door leading to a dark room.",
        exitDest = 3128,
        exitKeyword = "door"
      },
      west = {
        exitDescription = "A grubby door to a room.",
        exitDest = 3129,
        exitKeyword = "door"
      }
    },
    [3126] = {
      west = {
        exitDescription = "A dark corridor.",
        exitDest = 3124,
        exitKeyword = "door"
      }
    },
    [3127] = {
      west = {
        exitDescription = "A dark corridor.",
        exitDest = 3125,
        exitKeyword = "door"
      }
    },
    [3128] = {
      north = {
        exitDescription = "A dark corridor.",
        exitDest = 3125,
        exitKeyword = "door"
      }
    },
    [3129] = {
      east = {
        exitDescription = "A dark corridor.",
        exitDest = 3125,
        exitKeyword = "door"
      }
    },
    [3130] = {
      east = {
        exitDescription = "A door leading to the dark corridor.",
        exitDest = 3124,
        exitKeyword = "door"
      }
    },
    [3131] = {
      down = {
        exitDescription = "You see a wooden trapdoor on the deck.",
        exitDest = 3133,
        exitKeyword = "trapdoor"
      }
    },
    [3133] = {
      east = {
        exitDescription = "You see a small wooden door.",
        exitDest = 3135,
        exitKey = 7519,
        exitKeyword = "door"
      },
      up = {
        exitDescription = "You see a wooden trapdoor on the ceiling.",
        exitDest = 3131,
        exitKeyword = "trapdoor"
      },
      west = {
        exitDescription = "You can see a large wooden door with a sign on it.",
        exitDest = 3134,
        exitKeyword = "door"
      }
    },
    [3134] = {
      east = {
        exitDescription = "You can see a large wooden door.",
        exitDest = 3133,
        exitKeyword = "door"
      }
    },
    [3135] = {
      west = {
        exitDescription = "You see a small wooden door.",
        exitDest = 3133,
        exitKey = 7519,
        exitKeyword = "door"
      }
    },
    [3202] = {
      north = {
        exitDescription = "You see a HUGE arched gate leading into this magnificent building.",
        exitDest = 3203,
        exitKey = 7901,
        exitKeyword = "gate"
      }
    },
    [3203] = {
      east = {
        exitDescription =
        "You see there a tall oak door. It looks quite tightly closed to you. On it little runes are chiseled into the wood.",
        exitDest = 3212,
        exitKeyword = "oak"
      },
      south = {
        exitDescription =
        "Here you see a REAL door. It would be more proper to call this a \"GATE\", rather than a \"door\". It's really HUGE! On it hangs a large sign with very large letters spelling : \"EMERGENCY EXIT\".",
        exitDest = 3202,
        exitKey = 7901,
        exitKeyword = "gate"
      },
      west = {
        exitDescription =
        'This looks like a "door" in the meaning of the word. The ashen wood is painted in a peculiar yellow colour. Small letters are written with black on it.',
        exitDest = 3204,
        exitKeyword = "ashen"
      }
    },
    [3204] = {
      east = {
        exitDescription = "You can see an old ashen door, painted in a peculiar yellow colour.",
        exitDest = 3203,
        exitKeyword = "door"
      }
    },
    [3205] = {
      west = {
        exitDescription = "You see only the back of a safe's steel door.",
        exitDest = 3212,
        exitKey = 7900,
        exitKeyword = "steel"
      }
    },
    [3206] = {
      east = {
        exitDescription =
        'You see a huge metal door. From it a foul stench emanates. The smell is the most awful experience in your entire life. A thought seeps through this terrible stench and into your mind : "Monsters", you feel BAD about opening that door.',
        exitDest = 3215,
        exitKeyword = "steel"
      },
      west = {
        exitDescription =
        'The door has "SITTING ROOM" written on it. It is made from Aspenwood and is beautifully carven with small elves as main issue of sculpture.',
        exitDest = 3207,
        exitKeyword = "aspen"
      }
    },
    [3207] = {
      east = {
        exitDescription = "The door seems to be a very HEAVY door, carved completely from the trunk of an Aspen tree.",
        exitDest = 3206,
        exitKeyword = "asp"
      }
    },
    [3208] = {
      east = {
        exitDescription = "You can see the fridge from here. In it are drinks all over.",
        exitDest = 3210,
        exitKeyword = "fridge"
      },
      north = {
        exitDescription =
        "It's dark in there. But the sounds from there are unmistakable. The rats are here to your information.",
        exitDest = 3209,
        exitKeyword = "larder"
      }
    },
    [3209] = {
      south = {
        exitDest = 3208,
        exitKeyword = "door"
      }
    },
    [3210] = {
      west = {
        exitDest = 3208,
        exitKeyword = "door"
      }
    },
    [3212] = {
      east = {
        exitDest = 3205,
        exitKey = 7900,
        exitKeyword = "safe"
      },
      west = {
        exitDescription = "You see a tall oak door.",
        exitDest = 3203,
        exitKeyword = "door"
      }
    },
    [3213] = {
      south = {
        exitDescription = "The suns seems to shine out there, warmly and comforting.",
        exitDest = 3214,
        exitKeyword = "doors"
      }
    },
    [3214] = {
      north = {
        exitDescription = "You see the comfortable bedroom of Naris, the mansion of Redferne the Greater God.",
        exitDest = 3213,
        exitKeyword = "doors"
      }
    },
    [3215] = {
      west = {
        exitDescription = "This looks like the only exit from here.",
        exitDest = 3206,
        exitKeyword = "door"
      }
    },
    [3242] = {
      north = {
        exitDescription = "There is a huge iron door",
        exitDest = 3243,
        exitKey = 8001,
        exitKeyword = "iron"
      }
    },
    [3243] = {
      south = {
        exitDescription = "There is a huge iron door.",
        exitDest = 3242,
        exitKeyword = "iron"
      }
    },
    [3250] = {
      down = {
        exitDescription = "The carpet is made of wool.",
        exitDest = 3252,
        exitKeyword = "secret"
      }
    },
    [3252] = {
      up = {
        exitDescription = "You see a secret door",
        exitDest = 3250,
        exitKeyword = "secret"
      }
    },
    [3461] = {
      down = {
        exitDescription = "The light outline of a trapdoor is underneath some dust.",
        exitDest = 3512,
        exitKeyword = "trapdoor"
      }
    },
    [3512] = {
      north = {
        exitDescription = "The old prison door is almost rusted shut.",
        exitDest = 3514,
        exitKey = 8438,
        exitKeyword = "door"
      },
      up = {
        exitDescription = "A rope hangs downward from the trapdoor.",
        exitDest = 3461,
        exitKeyword = "trapdoor"
      }
    },
    [3514] = {
      south = {
        exitDescription = "The old prison door is almost rusted shut.",
        exitDest = 3512,
        exitKey = 8438,
        exitKeyword = "prison"
      }
    },
    [3678] = {
      north = {
        exitDest = 3687,
        exitKeyword = "door"
      }
    },
    [3683] = {
      up = {
        exitDescription =
        "This ornate door was constructed in the shape of a mouth, with two fangs hanging down from the lips.",
        exitDest = 3684,
        exitKey = 8805,
        exitKeyword = "door"
      }
    },
    [3684] = {
      down = {
        exitDest = 3683,
        exitKey = 8805,
        exitKeyword = "door"
      }
    },
    [3685] = {
      up = {
        exitDescription =
        "This ornate door was created in the shape of a mouth with two large fangs hanging down from the lip.",
        exitDest = 3686,
        exitKey = 8804,
        exitKeyword = "door"
      }
    },
    [3686] = {
      down = {
        exitDest = 3685,
        exitKey = 8804,
        exitKeyword = "door"
      }
    },
    [3687] = {
      south = {
        exitDest = 3678,
        exitKeyword = "door"
      }
    },
    [3706] = {
      north = {
        exitDest = 3714,
        exitKey = 8801,
        exitKeyword = "door"
      }
    },
    [3707] = {
      north = {
        exitDest = 3708,
        exitKey = 8801,
        exitKeyword = "door"
      }
    },
    [3708] = {
      south = {
        exitDest = 3707,
        exitKey = 8801,
        exitKeyword = "door"
      }
    },
    [3711] = {
      north = {
        exitDest = 3715,
        exitKeyword = "backdrop"
      }
    },
    [3714] = {
      south = {
        exitDest = 3706,
        exitKey = 8801,
        exitKeyword = "door"
      }
    },
    [3715] = {
      down = {
        exitDest = 3716,
        exitKey = 8802,
        exitKeyword = "trapdoor"
      },
      south = {
        exitDest = 3711,
        exitKeyword = "backdrop"
      }
    },
    [3716] = {
      up = {
        exitDest = 3715,
        exitKey = 8802,
        exitKeyword = "trapdoor"
      }
    },
    [3719] = {
      east = {
        exitDest = 3728,
        exitKeyword = "wall"
      }
    },
    [3720] = {
      east = {
        exitDest = 3729,
        exitKeyword = "wall"
      },
      west = {
        exitDest = 3730,
        exitKeyword = "wall"
      }
    },
    [3722] = {
      north = {
        exitDest = 3731,
        exitKeyword = "wall"
      }
    },
    [3725] = {
      north = {
        exitDest = 3736,
        exitKeyword = "wall"
      },
      south = {
        exitDest = 3737,
        exitKeyword = "wall"
      }
    },
    [3726] = {
      north = {
        exitDest = 3733,
        exitKeyword = "wall"
      },
      south = {
        exitDest = 3734,
        exitKeyword = "wall"
      }
    },
    [3727] = {
      south = {
        exitDest = 3735,
        exitKeyword = "wall"
      }
    },
    [3728] = {
      west = {
        exitDest = 3719,
        exitKeyword = "wall"
      }
    },
    [3729] = {
      west = {
        exitDest = 3720,
        exitKeyword = "wall"
      }
    },
    [3730] = {
      east = {
        exitDest = 3720,
        exitKeyword = "wall"
      }
    },
    [3731] = {
      south = {
        exitDest = 3722,
        exitKeyword = "wall"
      },
      west = {
        exitDest = 3732,
        exitKey = 8803,
        exitKeyword = "wall"
      }
    },
    [3732] = {
      east = {
        exitDest = 3731,
        exitKey = 8803,
        exitKeyword = "wall"
      }
    },
    [3733] = {
      south = {
        exitDest = 3726,
        exitKeyword = "wall"
      }
    },
    [3734] = {
      north = {
        exitDest = 3726,
        exitKeyword = "wall"
      }
    },
    [3735] = {
      north = {
        exitDest = 3727,
        exitKeyword = "wall"
      }
    },
    [3736] = {
      south = {
        exitDest = 3725,
        exitKeyword = "wall"
      }
    },
    [3737] = {
      north = {
        exitDest = 3725,
        exitKeyword = "wall"
      }
    },
    [3741] = {
      north = {
        exitDescription =
        "The gate has huge, but intricately carved hinges. As the Castle itself, it seems designed not only for strength, but also for beauty.",
        exitDest = 3744,
        exitFlags = -1,
        exitKeyword = "gate"
      }
    },
    [3743] = {
      east = {
        exitDescription = "The door is small and uninteresting.",
        exitDest = 3744,
        exitKeyword = "door"
      }
    },
    [3744] = {
      south = {
        exitDescription = "To the south, there is a gate, that leads to the Drawbridge.",
        exitDest = 3741,
        exitFlags = -1,
        exitKeyword = "gate"
      },
      west = {
        exitDescription = "The door is small and uninteresting.",
        exitDest = 3743,
        exitKeyword = "door"
      }
    },
    [3757] = {
      east = {
        exitDescription = "The door is quite small and unobtrusive.",
        exitDest = 3758,
        exitKeyword = "door"
      }
    },
    [3758] = {
      north = {
        exitDescription = "There is door there!!!",
        exitDest = 3763,
        exitKeyword = "door"
      },
      west = {
        exitDescription = "The door is made out of wood.",
        exitDest = 3757,
        exitKeyword = "door"
      }
    },
    [3759] = {
      north = {
        exitDescription = "The door leads to a room intended for the butler.",
        exitDest = 3764,
        exitKey = 8909,
        exitKeyword = "door"
      }
    },
    [3760] = {
      north = {
        exitDescription = "The door is large and heavy.",
        exitDest = 3765,
        exitKeyword = "door"
      }
    },
    [3763] = {
      south = {
        exitDescription = "The door is made out of wood.",
        exitDest = 3758,
        exitKeyword = "door"
      }
    },
    [3764] = {
      south = {
        exitDescription = "You see the corridor.",
        exitDest = 3759,
        exitKey = 8909,
        exitKeyword = "door"
      }
    },
    [3765] = {
      south = {
        exitDescription = "The door is large and heavy.",
        exitDest = 3760,
        exitKeyword = "door"
      }
    },
    [3773] = {
      east = {
        exitDescription = "You see a large steel door.",
        exitDest = 3774,
        exitKey = 8907,
        exitKeyword = "door"
      }
    },
    [3774] = {
      west = {
        exitDescription = "You see a large steel door.",
        exitDest = 3773,
        exitKey = 8907,
        exitKeyword = "door"
      }
    },
    [3775] = {
      east = {
        exitDescription = "You see the guest suite behind the door.",
        exitDest = 3776,
        exitKeyword = "door"
      },
      north = {
        exitDescription = "The door seems to lead to a guest room.",
        exitDest = 3780,
        exitKeyword = "door"
      }
    },
    [3776] = {
      west = {
        exitDescription = "Behind the door you see the entrance to the Guest Wing.",
        exitDest = 3775,
        exitKeyword = "door"
      }
    },
    [3780] = {
      south = {
        exitDescription = "Behind the door, you see the entrance to the Guest Wing.",
        exitDest = 3775,
        exitKeyword = "door"
      }
    },
    [3786] = {
      east = {
        exitDescription = "The door is large and made out of oak.",
        exitDest = 3787,
        exitKey = 8914,
        exitKeyword = "door"
      }
    },
    [3787] = {
      west = {
        exitDescription = "The door is large, and made out of oak.",
        exitDest = 3786,
        exitKey = 8914,
        exitKeyword = "door"
      }
    },
    [3850] = {
      north = {
        exitDest = 3851,
        exitKey = 9109,
        exitKeyword = "gate"
      }
    },
    [3851] = {
      south = {
        exitDest = 3850,
        exitKey = 9109,
        exitKeyword = "gate"
      }
    },
    [3857] = {
      west = {
        exitDest = 3858,
        exitKeyword = "door"
      }
    },
    [3858] = {
      east = {
        exitDest = 3857,
        exitKeyword = "door"
      }
    },
    [3866] = {
      west = {
        exitDest = 3867,
        exitKeyword = "door"
      }
    },
    [3867] = {
      east = {
        exitDest = 3866,
        exitKeyword = "door"
      }
    },
    [3869] = {
      east = {
        exitDest = 3870,
        exitKeyword = "door"
      }
    },
    [3870] = {
      west = {
        exitDest = 3869,
        exitKeyword = "door"
      }
    },
    [3885] = {
      west = {
        exitDest = 3886,
        exitKeyword = "gate"
      }
    },
    [3886] = {
      east = {
        exitDest = 3885,
        exitKeyword = "gate"
      }
    },
    [3894] = {
      west = {
        exitDest = 3895,
        exitKeyword = "door"
      }
    },
    [3895] = {
      east = {
        exitDest = 3894,
        exitKeyword = "door"
      }
    },
    [3915] = {
      down = {
        exitDescription = "One of the paving stones appears to be loose.",
        exitDest = 3916,
        exitKeyword = "stone"
      }
    },
    [3916] = {
      up = {
        exitDest = 3915,
        exitKeyword = "stone"
      }
    },
    [3917] = {
      east = {
        exitDescription = "The Palace Gates",
        exitDest = 3919,
        exitKeyword = "gate"
      }
    },
    [3919] = {
      west = {
        exitDescription = "The Palace Gates",
        exitDest = 3917,
        exitKeyword = "gate"
      }
    },
    [3925] = {
      up = {
        exitDescription = "You see some sort of trapdoor set in the ceiling here.",
        exitDest = 3954,
        exitKey = 9335,
        exitKeyword = "trapdoor"
      }
    },
    [3933] = {
      south = {
        exitDescription = "The door leads to a small storage room.",
        exitDest = 3934,
        exitKeyword = "door"
      }
    },
    [3934] = {
      north = {
        exitDescription = "The door leads back out to the kitchen.",
        exitDest = 3933,
        exitKeyword = "door"
      }
    },
    [3943] = {
      down = {
        exitDest = 3926,
        exitKeyword = "trapdoor"
      }
    },
    [3954] = {
      down = {
        exitDescription = "There is some sort of ancient wooden trapdoor here in the floor.",
        exitDest = 3925,
        exitKey = 9335,
        exitKeyword = "trapdoor"
      }
    },
    [4037] = {
      down = {
        exitDescription = "It is too dark down there, you can't see anything!",
        exitDest = 4038,
        exitKey = 9517,
        exitKeyword = "coffin"
      }
    },
    [4038] = {
      up = {
        exitDescription = "The ancient temple is up there.",
        exitDest = 4037,
        exitKey = 9517,
        exitKeyword = "coffin"
      }
    },
    [4043] = {
      south = {
        exitDescription = "There is a cupboard over there. You may be able to move this cupboard.",
        exitDest = 4044,
        exitKey = 9518,
        exitKeyword = "cupboard"
      }
    },
    [4044] = {
      north = {
        exitDescription = "You see the cupboard's back.",
        exitDest = 4043,
        exitKeyword = "cupboard"
      }
    },
    [4072] = {
      down = {
        exitDescription = "A loose floorboard that looks like it could be forced up.",
        exitDest = 4081,
        exitKeyword = "floorboard"
      }
    },
    [4081] = {
      down = {
        exitDescription = "A dusty rack full of wine barrels.",
        exitDest = 4082,
        exitKeyword = "winerack"
      },
      up = {
        exitDescription = "A loose floorboard that looks like it could be forced up.",
        exitDest = 4072,
        exitKeyword = "floorboard"
      }
    },
    [4082] = {
      south = {
        exitDescription = "The gate is made of pure platinum and has a large padlock.",
        exitDest = 4083,
        exitKey = 9632,
        exitKeyword = "gate"
      },
      up = {
        exitDescription = "A rack with many aged wine barrels",
        exitDest = 4081,
        exitKeyword = "winerack"
      }
    },
    [4083] = {
      north = {
        exitDescription = "A large gate made of pure platinum, it has a large padlock.",
        exitDest = 4082,
        exitKey = 9632,
        exitKeyword = "gate"
      }
    },
    [4086] = {
      east = {
        exitDescription = "A large drape",
        exitDest = 4091,
        exitKeyword = "drape"
      },
      south = {
        exitDescription = "A large door leading into the sanctuary",
        exitDest = 4088,
        exitKeyword = "door"
      },
      west = {
        exitDescription = "A large drape",
        exitDest = 4090,
        exitKeyword = "drape"
      }
    },
    [4088] = {
      north = {
        exitDescription = "A large door leading into the foyer",
        exitDest = 4086,
        exitKeyword = "door"
      }
    },
    [4090] = {
      east = {
        exitDescription = "A large heavy drape",
        exitDest = 4086,
        exitKeyword = "drape"
      }
    },
    [4091] = {
      west = {
        exitDescription = "A large heavy drape",
        exitDest = 4086,
        exitKeyword = "drape"
      }
    },
    [4096] = {
      down = {
        exitDescription = "The Altar",
        exitDest = 4098,
        exitKey = 9646,
        exitKeyword = "altar"
      }
    },
    [4098] = {
      up = {
        exitDescription = "The altar",
        exitDest = 4096,
        exitKey = 9646,
        exitKeyword = "altar"
      }
    },
    [4103] = {
      north = {
        exitDescription = "A vollamite fireplace.",
        exitDest = 4151,
        exitKey = 10001,
        exitKeyword = "fireplace"
      }
    },
    [4131] = {
      east = {
        exitDescription = "Door to the confessional.",
        exitDest = 4132,
        exitKeyword = "door"
      }
    },
    [4132] = {
      west = {
        exitDescription = "Door to the eastern aisle.",
        exitDest = 4131,
        exitKeyword = "door"
      }
    },
    [4151] = {
      south = {
        exitDescription = "The fireplace.",
        exitDest = 4103,
        exitKey = 10001,
        exitKeyword = "fireplace"
      }
    },
    [4167] = {
      north = {
        exitDest = 4172,
        exitKeyword = "curtain"
      }
    },
    [4168] = {
      north = {
        exitDest = 4173,
        exitKeyword = "curtain"
      },
      south = {
        exitDest = 4176,
        exitKeyword = "curtain"
      }
    },
    [4169] = {
      north = {
        exitDest = 4174,
        exitKeyword = "curtain"
      },
      south = {
        exitDest = 4177,
        exitKeyword = "curtain"
      }
    },
    [4170] = {
      east = {
        exitDest = 4178,
        exitKeyword = "curtain"
      },
      north = {
        exitDest = 4175,
        exitKeyword = "curtain"
      }
    },
    [4171] = {
      east = {
        exitDest = 4179,
        exitKeyword = "curtain"
      }
    },
    [4172] = {
      south = {
        exitDest = 4167,
        exitKeyword = "curtain"
      }
    },
    [4173] = {
      south = {
        exitDest = 4168,
        exitKeyword = "curtain"
      }
    },
    [4174] = {
      south = {
        exitDest = 4169,
        exitKeyword = "curtain"
      }
    },
    [4175] = {
      south = {
        exitDest = 4170,
        exitKeyword = "curtain"
      }
    },
    [4176] = {
      north = {
        exitDest = 4168,
        exitKeyword = "curtain"
      }
    },
    [4177] = {
      north = {
        exitDest = 4169,
        exitKeyword = "curtain"
      }
    },
    [4178] = {
      west = {
        exitDest = 4170,
        exitKeyword = "curtain"
      }
    },
    [4179] = {
      west = {
        exitDest = 4171,
        exitKeyword = "curtain"
      }
    },
    [4186] = {
      down = {
        exitDest = 4187,
        exitKeyword = "trapdoor"
      }
    },
    [4187] = {
      up = {
        exitDest = 4186,
        exitKeyword = "trapdoor"
      }
    },
    [4345] = {
      north = {
        exitDescription = "Deep in the swamp.",
        exitDest = 4346,
        exitKeyword = "brush"
      }
    },
    [4346] = {
      south = {
        exitDescription = "A small clearing.",
        exitDest = 4345,
        exitKeyword = "brush"
      }
    },
    [4384] = {
      west = {
        exitDest = 4385,
        exitKey = 10701,
        exitKeyword = "door"
      }
    },
    [4385] = {
      east = {
        exitDest = 4384,
        exitKey = 10701,
        exitKeyword = "door"
      }
    },
    [4393] = {
      down = {
        exitDest = 4412,
        exitKey = 10702,
        exitKeyword = "trapdoor"
      }
    },
    [4412] = {
      down = {
        exitDest = 4413,
        exitKey = 10703,
        exitKeyword = "trapdoor"
      },
      up = {
        exitDest = 4393,
        exitKey = 10702,
        exitKeyword = "trapdoor"
      }
    },
    [4413] = {
      down = {
        exitDest = 4414,
        exitKey = 10704,
        exitKeyword = "trapdoor"
      },
      up = {
        exitDest = 4412,
        exitKey = 10703,
        exitKeyword = "trapdoor"
      }
    },
    [4414] = {
      up = {
        exitDest = 4413,
        exitKey = 10704,
        exitKeyword = "trapdoor"
      }
    },
    [4449] = {
      east = {
        exitDescription = "A jagged crystal spire blocks your path.",
        exitDest = 4467,
        exitKey = 10839,
        exitKeyword = "secret"
      }
    },
    [4459] = {
      east = {
        exitDescription = "You see the ancient gates.",
        exitDest = 4460,
        exitKey = 10832,
        exitKeyword = "gate"
      }
    },
    [4460] = {
      south = {
        exitDescription = "You see some scratches on the stone.",
        exitDest = 4476,
        exitKeyword = "secret"
      },
      west = {
        exitDescription = "You see the ancient gate.",
        exitDest = 4459,
        exitKey = 10832,
        exitKeyword = "gate"
      }
    },
    [4467] = {
      west = {
        exitDescription = "A jagged crsytal spire blocks your path.",
        exitDest = 4449,
        exitKey = 10839,
        exitKeyword = "secret"
      }
    },
    [4469] = {
      east = {
        exitDescription = "You see an impressive iron door with a very strong lock.",
        exitDest = 4470,
        exitKey = 10842,
        exitKeyword = "iron"
      }
    },
    [4470] = {
      west = {
        exitDescription = "You see an impressive iron door with a strong lock.",
        exitDest = 4469,
        exitKey = 10841,
        exitKeyword = "iron"
      }
    },
    [4476] = {
      north = {
        exitDescription = "You see a secret door.",
        exitDest = 4460,
        exitKeyword = "secret"
      }
    },
    [4479] = {
      east = {
        exitDescription = "You see a large iron door.",
        exitDest = 4503,
        exitKeyword = "iron"
      }
    },
    [4501] = {
      south = {
        exitDescription = "You see a strong door.",
        exitDest = 4502,
        exitKeyword = "door"
      }
    },
    [4502] = {
      north = {
        exitDescription = "You see a strong door.",
        exitDest = 4501,
        exitKeyword = "door"
      }
    },
    [4503] = {
      west = {
        exitDescription = "You see a large iron door.",
        exitDest = 4479,
        exitKey = 10875,
        exitKeyword = "iron"
      }
    },
    [4511] = {
      west = {
        exitDescription = "You see a strong door.",
        exitDest = 4512,
        exitKeyword = "door"
      }
    },
    [4512] = {
      east = {
        exitDescription = "You see a strong door.",
        exitDest = 4511,
        exitKeyword = "door"
      }
    },
    [4513] = {
      east = {
        exitDescription = "You see a strong door.",
        exitDest = 4515,
        exitKeyword = "door"
      },
      west = {
        exitDescription = "You see a strong door.",
        exitDest = 4514,
        exitKeyword = "door"
      }
    },
    [4514] = {
      east = {
        exitDescription = "You see a strong door.",
        exitDest = 4513,
        exitKeyword = "door"
      }
    },
    [4515] = {
      west = {
        exitDescription = "You see a strong door.",
        exitDest = 4513,
        exitKeyword = "door"
      }
    },
    [4520] = {
      south = {
        exitDescription = "You see a strong oak door.",
        exitDest = 4521,
        exitKey = 19893,
        exitKeyword = "oak"
      }
    },
    [4521] = {
      north = {
        exitDescription = "You see a strong oak door.",
        exitDest = 4520,
        exitKey = 10893,
        exitKeyword = "oak"
      }
    },
    [4523] = {
      south = {
        exitDescription = "You see a massive brass bound door.",
        exitDest = 4524,
        exitKey = 10896,
        exitKeyword = "brass"
      }
    },
    [4524] = {
      north = {
        exitDescription = "You see a strong brass door leading to a guard room.",
        exitDest = 4523,
        exitKey = 10896,
        exitKeyword = "brass"
      }
    },
    [4525] = {
      south = {
        exitDescription = "You see the arch to the great chamber.",
        exitDest = 4526,
        exitKey = 10898,
        exitKeyword = "iron"
      }
    },
    [4526] = {
      north = {
        exitDescription = "You see the iron door to the ante-chamber.",
        exitDest = 4525,
        exitKey = 10898,
        exitKeyword = "iron"
      },
      south = {
        exitDescription = "You see a strange gate. It is made of golden metal but fresh blood seeps from it.",
        exitDest = 4527,
        exitKey = 10899,
        exitKeyword = "gate"
      }
    },
    [4527] = {
      north = {
        exitDest = 4526,
        exitKey = 10899,
        exitKeyword = "gate"
      }
    },
    [4566] = {
      down = {
        exitDest = 4595,
        exitKeyword = "oven"
      }
    },
    [4595] = {
      up = {
        exitDest = 4566,
        exitKeyword = "oven"
      }
    },
    [4601] = {
      west = {
        exitDest = 4602,
        exitKey = 10912,
        exitKeyword = "door"
      }
    },
    [4602] = {
      east = {
        exitDest = 4601,
        exitKey = 10912,
        exitKeyword = "door"
      }
    },
    [4615] = {
      up = {
        exitDest = 4722,
        exitKeyword = "trap"
      }
    },
    [4619] = {
      north = {
        exitDest = 4620,
        exitKeyword = "cellar"
      }
    },
    [4620] = {
      south = {
        exitDest = 4619,
        exitKeyword = "cellar"
      }
    },
    [4624] = {
      west = {
        exitDescription = "You see a shiny spot on the wall. It could be a door.",
        exitDest = 4626,
        exitKeyword = "hidden"
      }
    },
    [4626] = {
      east = {
        exitDest = 4624,
        exitKeyword = "door"
      }
    },
    [4650] = {
      south = {
        exitDescription = "You might get lost if you go there; it doesn't look at all familiar.",
        exitDest = 4648,
        exitFlags = -1
      }
    },
    [4653] = {
      east = {
        exitDescription = "The cavern continues.",
        exitDest = 4654,
        exitFlags = -1
      }
    },
    [4722] = {
      down = {
        exitDescription = "A trap door!",
        exitDest = 4615,
        exitKeyword = "trap"
      }
    },
    [4728] = {
      west = {
        exitDescription = "There is a door.",
        exitDest = 4729,
        exitKeyword = "door"
      }
    },
    [4729] = {
      east = {
        exitDescription = "The door to the drawbridge.",
        exitDest = 4728,
        exitKeyword = "door"
      }
    },
    [4730] = {
      east = {
        exitDescription = "A closet. door closet",
        exitDest = 4731,
        exitKeyword = "door"
      }
    },
    [4731] = {
      west = {
        exitDescription = "The hall. door closet",
        exitDest = 4730,
        exitKeyword = "door"
      }
    },
    [4742] = {
      north = {
        exitDescription = "The shelves seem to move a bit.",
        exitDest = 4744,
        exitKeyword = "secret"
      }
    },
    [4744] = {
      south = {
        exitDescription = "The back of the book-case.",
        exitDest = 4742,
        exitKeyword = "secret"
      }
    },
    [4748] = {
      west = {
        exitDescription = "The door has writing on it.",
        exitDest = 4749,
        exitKey = 11142,
        exitKeyword = "door"
      }
    },
    [4758] = {
      west = {
        exitDest = 4759,
        exitKeyword = "wine"
      }
    },
    [4759] = {
      east = {
        exitDescription = "The wine rack doesn't exactly appear stationary.",
        exitDest = 4758,
        exitKeyword = "rack"
      }
    },
    [4762] = {
      north = {
        exitDest = 4761,
        exitFlags = -1
      }
    },
    [4776] = {
      north = {
        exitDest = 4778,
        exitKeyword = "cellar"
      }
    },
    [4778] = {
      south = {
        exitDest = 4776,
        exitKeyword = "cellar"
      }
    },
    [4792] = {
      east = {
        exitDescription = "You see a creature looking remarkably like YOU!",
        exitDest = 4787,
        exitFlags = -1
      },
      north = {
        exitDescription = "You see yourself reflected off the highly polished walls",
        exitDest = 4789,
        exitFlags = -1
      }
    },
    [4898] = {
      north = {
        exitDest = 4899,
        exitKeyword = "gate"
      }
    },
    [4899] = {
      north = {
        exitDest = 4900,
        exitFlags = -1,
        exitKeyword = "gate"
      },
      south = {
        exitDest = 4898,
        exitKeyword = "gate"
      }
    },
    [4900] = {
      north = {
        exitDest = 4901,
        exitFlags = -1,
        exitKeyword = "gate"
      }
    },
    [4916] = {
      east = {
        exitDest = 4922,
        exitKeyword = "door"
      }
    },
    [4918] = {
      east = {
        exitDest = 4916,
        exitFlags = -1,
        exitKeyword = "Door"
      },
      north = {
        exitDest = 4921,
        exitKeyword = "door"
      }
    },
    [4919] = {
      east = {
        exitDest = 4918,
        exitFlags = -1,
        exitKeyword = "door"
      },
      north = {
        exitDest = 4920,
        exitKeyword = "door"
      }
    },
    [4920] = {
      south = {
        exitDest = 4919,
        exitKeyword = "door"
      }
    },
    [4921] = {
      south = {
        exitDest = 4918,
        exitKeyword = "door"
      }
    },
    [4922] = {
      west = {
        exitDest = 4916,
        exitKeyword = "door"
      }
    },
    [4923] = {
      west = {
        exitDest = 4922,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [4934] = {
      south = {
        exitDescription = "You see a barn-like door.",
        exitDest = 4938,
        exitKeyword = "door"
      }
    },
    [4938] = {
      north = {
        exitDescription = "You look out onto the street and see an intersection.",
        exitDest = 4934,
        exitKeyword = "door"
      }
    },
    [4940] = {
      north = {
        exitDescription = "A small wooden door. There seems to be some commotion on the other side.",
        exitDest = 4943,
        exitKeyword = "door"
      }
    },
    [4943] = {
      east = {
        exitDescription = "You see a door.",
        exitDest = 4944,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "The Foyer",
        exitDest = 4940,
        exitKeyword = "door"
      }
    },
    [4944] = {
      west = {
        exitDest = 4943,
        exitKeyword = "door"
      }
    },
    [4946] = {
      west = {
        exitDescription = "You look out into the hallway.",
        exitDest = 4955,
        exitKeyword = "door"
      }
    },
    [4947] = {
      east = {
        exitDescription = "You look out into the hallway.",
        exitDest = 4955,
        exitKeyword = "door"
      }
    },
    [4948] = {
      west = {
        exitDescription = "Slightly more noticeable on this side.",
        exitDest = 4949,
        exitKeyword = "door"
      }
    },
    [4949] = {
      east = {
        exitDescription = "A door is built into the wall.",
        exitDest = 4948,
        exitKeyword = "door"
      }
    },
    [4955] = {
      east = {
        exitDescription = "You see a small door which says, 'Library'.",
        exitDest = 4946,
        exitKeyword = "door"
      },
      west = {
        exitDescription = "You see a small door which says, 'Museum'.",
        exitDest = 4947,
        exitKeyword = "door"
      }
    },
    [4968] = {
      west = {
        exitDescription = "You notice that the door is locked. Maybe some kind of guard has a key.",
        exitDest = 4979,
        exitKey = 11512,
        exitKeyword = "door"
      }
    },
    [4970] = {
      east = {
        exitDescription = "You notice that the door is locked... maybe some kind of guard has a key.",
        exitDest = 4971,
        exitKey = 11512,
        exitKeyword = "door"
      }
    },
    [4971] = {
      south = {
        exitDescription = "You see a door.",
        exitDest = 4970,
        exitKey = 11512,
        exitKeyword = "door"
      }
    },
    [4979] = {
      south = {
        exitDescription = "The door proclaims loudly in writing, 'Main Floor'.",
        exitDest = 4968,
        exitKey = 11512,
        exitKeyword = "door"
      }
    },
    [4984] = {
      north = {
        exitDescription = "A rickety, old wooden door labeled, 'Prop Storage'.",
        exitDest = 4986,
        exitKeyword = "door"
      }
    },
    [4986] = {
      south = {
        exitDescription = "You look for an escape before the rats have a chance to chew off your toes.",
        exitDest = 4984,
        exitKeyword = "door"
      }
    },
    [4989] = {
      north = {
        exitDescription = "This door is especially large, to accommodate large instruments.",
        exitDest = 4990,
        exitKey = 11522,
        exitKeyword = "door"
      }
    },
    [4990] = {
      south = {
        exitDescription = "This door is especially large, to accommodate larger instruments.",
        exitDest = 4989,
        exitKey = 11522,
        exitKeyword = "door"
      }
    },
    [4991] = {
      south = {
        exitDescription = "This door leads to the sitting room.",
        exitDest = 4992,
        exitKey = 11551,
        exitKeyword = "door"
      }
    },
    [4992] = {
      north = {
        exitDescription = "This door leads to the office.",
        exitDest = 4991,
        exitKey = 11551,
        exitKeyword = "door"
      }
    },
    [5051] = {
      down = {
        exitDest = 5089,
        exitKeyword = "door"
      }
    },
    [5054] = {
      west = {
        exitDest = 5095,
        exitKeyword = "stone"
      }
    },
    [5056] = {
      north = {
        exitDest = 5057,
        exitKey = 11620,
        exitKeyword = "gate"
      }
    },
    [5057] = {
      south = {
        exitDest = 5056,
        exitKey = 11620,
        exitKeyword = "gate"
      }
    },
    [5089] = {
      up = {
        exitDest = 5051,
        exitKeyword = "door"
      }
    },
    [5095] = {
      east = {
        exitDest = 5054,
        exitKeyword = "stone"
      }
    },
    [5135] = {
      north = {
        exitDescription = "It appears to be Madame Giry's office.",
        exitDest = 5138,
        exitKeyword = "door"
      }
    },
    [5136] = {
      north = {
        exitDescription = "Madame Giry's sitting room.",
        exitDest = 5137,
        exitKeyword = "door"
      }
    },
    [5137] = {
      south = {
        exitDescription = "The rehearsal hall echoes with the sounds of toe shoes sweeping the floor.",
        exitDest = 5136,
        exitKeyword = "door"
      }
    },
    [5138] = {
      south = {
        exitDescription = "The ballet school.",
        exitDest = 5135,
        exitKeyword = "door"
      }
    },
    [5151] = {
      north = {
        exitDescription = "You look into the mirror and see how handsome you are.",
        exitDest = 5173,
        exitKeyword = "lever"
      }
    },
    [5173] = {
      south = {
        exitDescription = "You look closely at the spring and discover the lever on this side of the mirror.",
        exitDest = 5151,
        exitKeyword = "lever"
      }
    },
    [5183] = {
      down = {
        exitDescription =
        "You try to avoid looking at the body, but there looks to be room for you to fit though if you moved the scene.",
        exitDest = 5184,
        exitKeyword = "scene"
      }
    },
    [5184] = {
      up = {
        exitDescription = "You can't seem to see the scene from down here.",
        exitDest = 5183,
        exitKeyword = "scene"
      }
    },
    [5327] = {
      down = {
        exitDest = 5357,
        exitKeyword = "secret"
      }
    },
    [5331] = {
      up = {
        exitDest = 5381,
        exitKeyword = "tree"
      }
    },
    [5332] = {
      down = {
        exitDest = 5402,
        exitKeyword = "trapdoor"
      },
      up = {
        exitDest = 5333,
        exitKey = 12011,
        exitKeyword = "gate"
      }
    },
    [5333] = {
      down = {
        exitDest = 5332,
        exitKey = 12011,
        exitKeyword = "gate"
      }
    },
    [5340] = {
      down = {
        exitDescription =
        "Down is the lair of the Queen Ant. You surely don't want to go down there, she's known to devastate entire groups of adventurers within a couple of minutes.",
        exitDest = 5367,
        exitKeyword = "trapdoor"
      }
    },
    [5355] = {
      down = {
        exitDest = 5368,
        exitKeyword = "secret"
      },
      south = {
        exitDest = 5414,
        exitKeyword = "mud"
      }
    },
    [5357] = {
      up = {
        exitDest = 5327,
        exitKeyword = "secret"
      }
    },
    [5358] = {
      north = {
        exitDest = 5357,
        exitKeyword = "door"
      }
    },
    [5361] = {
      down = {
        exitDest = 5415,
        exitKeyword = "secret"
      }
    },
    [5362] = {
      south = {
        exitDest = 5363,
        exitKeyword = "door"
      }
    },
    [5363] = {
      north = {
        exitDest = 5362,
        exitKeyword = "door"
      },
      south = {
        exitDest = 5365,
        exitKeyword = "door"
      },
      west = {
        exitDest = 5366,
        exitKey = 12013,
        exitKeyword = "door"
      }
    },
    [5365] = {
      north = {
        exitDest = 5363,
        exitKeyword = "door"
      }
    },
    [5366] = {
      east = {
        exitDest = 5363,
        exitKey = 12013,
        exitKeyword = "door"
      }
    },
    [5367] = {
      up = {
        exitDest = 5340,
        exitKeyword = "trapdoor"
      }
    },
    [5368] = {
      up = {
        exitDest = 5355,
        exitKeyword = "secret"
      }
    },
    [5375] = {
      east = {
        exitDest = 5413,
        exitKeyword = "door"
      }
    },
    [5378] = {
      east = {
        exitDest = 5380,
        exitKeyword = "door"
      }
    },
    [5380] = {
      east = {
        exitDest = 5410,
        exitKey = 12014,
        exitKeyword = "door"
      },
      west = {
        exitDest = 5378,
        exitKeyword = "door"
      }
    },
    [5381] = {
      down = {
        exitDest = 5331,
        exitKeyword = "tree"
      }
    },
    [5393] = {
      east = {
        exitDest = 5398,
        exitKeyword = "door"
      }
    },
    [5398] = {
      east = {
        exitDest = 5403,
        exitKeyword = "door"
      },
      west = {
        exitDest = 5393,
        exitKeyword = "door"
      }
    },
    [5402] = {
      up = {
        exitDest = 5332,
        exitKeyword = "trapdoor"
      }
    },
    [5403] = {
      west = {
        exitDest = 5398,
        exitKeyword = "door"
      }
    },
    [5404] = {
      down = {
        exitDest = 5411,
        exitKeyword = "ladder"
      }
    },
    [5410] = {
      west = {
        exitDest = 5380,
        exitKey = 12014,
        exitKeyword = "door"
      }
    },
    [5411] = {
      up = {
        exitDest = 5404,
        exitKeyword = "ladder"
      }
    },
    [5412] = {
      north = {
        exitDest = 5411,
        exitKeyword = "door"
      }
    },
    [5413] = {
      west = {
        exitDest = 5375,
        exitKeyword = "door"
      }
    },
    [5414] = {
      north = {
        exitDest = 5355,
        exitKeyword = "mud"
      }
    },
    [5416] = {
      down = {
        exitDest = 5418,
        exitKeyword = "trapdoor"
      }
    },
    [5418] = {
      up = {
        exitDest = 5416,
        exitKeyword = "trapdoor"
      }
    },
    [5419] = {
      south = {
        exitDest = 5422,
        exitKeyword = "crack"
      }
    },
    [5421] = {
      up = {
        exitDest = 5366,
        exitKeyword = "floor"
      }
    },
    [5422] = {
      north = {
        exitDest = 5419,
        exitKeyword = "crack"
      }
    },
    [5424] = {
      up = {
        exitDest = 5362,
        exitKeyword = "floor"
      }
    },
    [5426] = {
      south = {
        exitDest = 5427,
        exitKeyword = "door"
      },
      up = {
        exitDest = 5365,
        exitKeyword = "floor"
      }
    },
    [5427] = {
      north = {
        exitDest = 5426,
        exitKeyword = "door"
      },
      south = {
        exitDest = 5428,
        exitKeyword = "secret"
      }
    },
    [5428] = {
      north = {
        exitDest = 5427,
        exitKeyword = "secret"
      }
    },
    [5432] = {
      east = {
        exitDest = 5433,
        exitKeyword = "riverbank"
      }
    },
    [5433] = {
      down = {
        exitDest = 5435,
        exitKeyword = "mud"
      }
    },
    [5434] = {
      up = {
        exitDest = 5414,
        exitKeyword = "floor"
      }
    },
    [5435] = {
      up = {
        exitDest = 5433,
        exitKeyword = "mud"
      }
    },
    [5436] = {
      up = {
        exitDescription = "You see small square in the village.",
        exitDest = 5373,
        exitKeyword = "door"
      }
    },
    [5438] = {
      east = {
        exitDescription = "You see a huge door.",
        exitDest = 5439,
        exitKeyword = "door"
      }
    },
    [5439] = {
      east = {
        exitDescription = "You see a huge wooden door.",
        exitDest = 5440,
        exitKeyword = "door"
      },
      west = {
        exitDescription = "You see a huge door.",
        exitDest = 5438,
        exitKeyword = "door"
      }
    },
    [5440] = {
      west = {
        exitDescription = "You see huge wooden door.",
        exitDest = 5439,
        exitKeyword = "door"
      }
    },
    [5453] = {
      north = {
        exitDescription = "You see a big door.",
        exitDest = 5454,
        exitKeyword = "door"
      }
    },
    [5454] = {
      south = {
        exitDescription = "You see a big door.",
        exitDest = 5453,
        exitKeyword = "door"
      }
    },
    [5459] = {
      east = {
        exitDescription = "You see a big wall.",
        exitDest = 5461,
        exitKeyword = "wall"
      }
    },
    [5460] = {
      south = {
        exitDescription = "You see a big wall.",
        exitDest = 5508,
        exitKeyword = "wall"
      }
    },
    [5461] = {
      west = {
        exitDescription = "You see a big wall.",
        exitDest = 5459,
        exitKeyword = "wall"
      }
    },
    [5471] = {
      east = {
        exitDescription = "You see a door.",
        exitDest = 5484,
        exitKeyword = "door"
      }
    },
    [5484] = {
      west = {
        exitDescription = "You see a door.",
        exitDest = 5471,
        exitKeyword = "door"
      }
    },
    [5494] = {
      south = {
        exitDescription = "You see a wall.",
        exitDest = 5495,
        exitKeyword = "wall"
      }
    },
    [5495] = {
      north = {
        exitDescription = "You see a wall.",
        exitDest = 5494,
        exitKeyword = "wall"
      }
    },
    [5496] = {
      down = {
        exitDescription = "You see a trapdoor.",
        exitDest = 5517,
        exitKeyword = "trapdoor"
      }
    },
    [5508] = {
      north = {
        exitDescription = "You see a wall.",
        exitDest = 5460,
        exitKeyword = "wall"
      }
    },
    [5517] = {
      up = {
        exitDescription = "You see a trapdoor.",
        exitDest = 5496,
        exitKeyword = "trapdoor"
      }
    },
    [5622] = {
      north = {
        exitDescription = "A splintered wooden door muffles the din of clashing metal to the north.",
        exitDest = 5623,
        exitKey = 12901,
        exitKeyword = "wooden"
      }
    },
    [5623] = {
      south = {
        exitDescription = "A splintered wooden door leads into a hallway full of flickering light.",
        exitDest = 5622,
        exitKey = 12901,
        exitKeyword = "wooden"
      }
    },
    [5632] = {
      north = {
        exitDescription = "Oaken double doors separate the library from the hallway.",
        exitDest = 5634,
        exitKeyword = "double"
      }
    },
    [5633] = {
      north = {
        exitDescription = "Oaken double doors separate the library from the hallway.",
        exitDest = 5635,
        exitKeyword = "double"
      }
    },
    [5634] = {
      south = {
        exitDescription = "Oaken double doors separate the library from the hallway.",
        exitDest = 5632,
        exitKeyword = "double"
      }
    },
    [5635] = {
      south = {
        exitDescription = "Oaken double doors separate the library from the hallway.",
        exitDest = 5633,
        exitKeyword = "double"
      }
    },
    [5654] = {
      north = {
        exitDescription = "A plain wooden door separates this hallway from a bedroom.",
        exitDest = 5663,
        exitKeyword = "door"
      }
    },
    [5658] = {
      north = {
        exitDescription = "A plain wooden door separates this hallway from a bedroom.",
        exitDest = 5662,
        exitKeyword = "door"
      }
    },
    [5662] = {
      south = {
        exitDescription = "A plain wooden door separates this bedroom from the hallway.",
        exitDest = 5658,
        exitKeyword = "door"
      }
    },
    [5663] = {
      south = {
        exitDescription = "A plain wooden door separates this bedroom from the hallway.",
        exitDest = 5654,
        exitKeyword = "door"
      }
    },
    [5672] = {
      north = {
        exitDescription = "A plain wooden door separates this hallway from a bedroom.",
        exitDest = 5673,
        exitKeyword = "door"
      }
    },
    [5673] = {
      south = {
        exitDescription = "A plain wooden door separates this bedroom from the hallway.",
        exitDest = 5672,
        exitKeyword = "door"
      }
    },
    [5674] = {
      north = {
        exitDescription = "A plain wooden door separates this hallway from a bedroom.",
        exitDest = 5675,
        exitKeyword = "door"
      }
    },
    [5675] = {
      south = {
        exitDescription = "A plain wooden door separates this bedroom from the hallway.",
        exitDest = 5674,
        exitKeyword = "door"
      }
    },
    [5677] = {
      north = {
        exitDescription = "A solid mahogany door pulses with some rhythm from within.",
        exitDest = 5678,
        exitKey = 12911,
        exitKeyword = "mahogany"
      }
    },
    [5678] = {
      north = {
        exitDescription = "A massive slab of metal separates the northern room from this pulsing hallway.",
        exitDest = 5681,
        exitKey = 12930,
        exitKeyword = "metal"
      },
      south = {
        exitDescription = "A solid mahogany door pulses with the rhythm of this mansion's heart.",
        exitDest = 5677,
        exitKey = 12911,
        exitKeyword = "mahogany"
      }
    },
    [5681] = {
      south = {
        exitDescription = "A thick metal door vanishes into the wall...",
        exitDest = 5678,
        exitKey = 12930,
        exitKeyword = "metal"
      }
    },
    [5700] = {
      up = {
        exitDescription = "A knotting of branches blocks the light.",
        exitDest = 5701,
        exitKey = 13001,
        exitKeyword = "branches"
      }
    },
    [5701] = {
      down = {
        exitDescription = "A long part of the trunk.",
        exitDest = 5700,
        exitKey = 13001,
        exitKeyword = "branches"
      }
    },
    [5724] = {
      north = {
        exitDescription = "The den of the Matriarch",
        exitDest = 5725,
        exitKeyword = "door"
      }
    },
    [5725] = {
      south = {
        exitDescription = "The antechamber of the Matriarch",
        exitDest = 5724,
        exitKeyword = "door"
      }
    },
    [5727] = {
      north = {
        exitDescription = "The lair of the Patriarch.",
        exitDest = 5728,
        exitKeyword = "door"
      }
    },
    [5728] = {
      south = {
        exitDescription = "The antechamber.",
        exitDest = 5727,
        exitKeyword = "door"
      }
    },
    [5757] = {
      south = {
        exitDest = 5758,
        exitKeyword = "door"
      }
    },
    [5758] = {
      north = {
        exitDest = 5757,
        exitKeyword = "door"
      }
    },
    [5760] = {
      down = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5762,
        exitKeyword = "door"
      }
    },
    [5762] = {
      up = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5760,
        exitKeyword = "door"
      }
    },
    [5763] = {
      north = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5774,
        exitKeyword = "door"
      }
    },
    [5764] = {
      down = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5797,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5765,
        exitKeyword = "door"
      }
    },
    [5765] = {
      north = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5764,
        exitKeyword = "door"
      }
    },
    [5770] = {
      south = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5776,
        exitKeyword = "door"
      }
    },
    [5774] = {
      south = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5763,
        exitKeyword = "door"
      }
    },
    [5776] = {
      north = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5770,
        exitKeyword = "door"
      }
    },
    [5782] = {
      down = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5784,
        exitKeyword = "door"
      }
    },
    [5783] = {
      down = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5787,
        exitKeyword = "door"
      }
    },
    [5784] = {
      up = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5782,
        exitKeyword = "door"
      }
    },
    [5787] = {
      up = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5783,
        exitKeyword = "door"
      }
    },
    [5797] = {
      east = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5821,
        exitKeyword = "door"
      },
      north = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5820,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5804,
        exitKeyword = "door"
      },
      up = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5764,
        exitKeyword = "door"
      }
    },
    [5801] = {
      north = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5816,
        exitKeyword = "door"
      }
    },
    [5804] = {
      north = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5797,
        exitKeyword = "door"
      }
    },
    [5807] = {
      west = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5808,
        exitKeyword = "door"
      }
    },
    [5808] = {
      east = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5807,
        exitKeyword = "door"
      }
    },
    [5813] = {
      south = {
        exitDest = 5817,
        exitKeyword = "door"
      }
    },
    [5814] = {
      south = {
        exitDest = 5818,
        exitKeyword = "door"
      }
    },
    [5815] = {
      south = {
        exitDest = 5819,
        exitKeyword = "door"
      }
    },
    [5816] = {
      south = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5801,
        exitKeyword = "door"
      }
    },
    [5817] = {
      north = {
        exitDest = 5813,
        exitKeyword = "door"
      }
    },
    [5818] = {
      north = {
        exitDest = 5814,
        exitKeyword = "door"
      }
    },
    [5819] = {
      north = {
        exitDest = 5815,
        exitKeyword = "door"
      }
    },
    [5820] = {
      south = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5797,
        exitKeyword = "door"
      }
    },
    [5821] = {
      west = {
        exitDescription = "The heavy, soundproof door has been set in a stone doorframe.",
        exitDest = 5797,
        exitKeyword = "door"
      }
    },
    [5876] = {
      east = {
        exitDest = 5888,
        exitKeyword = "bole"
      }
    },
    [6006] = {
      north = {
        exitDest = 6007,
        exitKeyword = "door"
      }
    },
    [6007] = {
      south = {
        exitDest = 6006,
        exitKeyword = "door"
      }
    },
    [6011] = {
      east = {
        exitDest = 6013,
        exitKeyword = "metal"
      }
    },
    [6013] = {
      west = {
        exitDest = 6011,
        exitKeyword = "metal"
      }
    },
    [6024] = {
      south = {
        exitDest = 6053,
        exitKeyword = "rock"
      }
    },
    [6053] = {
      north = {
        exitDest = 6024,
        exitKeyword = "rock"
      }
    },
    [6056] = {
      south = {
        exitDest = 6057,
        exitKeyword = "rock"
      }
    },
    [6057] = {
      north = {
        exitDest = 6056,
        exitKeyword = "rock"
      }
    },
    [6060] = {
      down = {
        exitDest = 6083,
        exitKey = 13799,
        exitKeyword = "trapdoor"
      }
    },
    [6068] = {
      north = {
        exitDest = 6069,
        exitKeyword = "rock"
      }
    },
    [6069] = {
      south = {
        exitDest = 6068,
        exitKeyword = "rock"
      }
    },
    [6074] = {
      north = {
        exitDest = 6075,
        exitKeyword = "rock"
      }
    },
    [6075] = {
      south = {
        exitDest = 6074,
        exitKeyword = "rock"
      }
    },
    [6083] = {
      up = {
        exitDest = 6060,
        exitKey = 13799,
        exitKeyword = "trapdoor"
      }
    },
    [6090] = {
      north = {
        exitDescription = "There looks like a large field just beyond the hut.",
        exitDest = 6097,
        exitKey = 13801,
        exitKeyword = "hut"
      }
    },
    [6097] = {
      south = {
        exitDescription = "The hut lies at your back to the south.",
        exitDest = 6090,
        exitKey = 13801,
        exitKeyword = "hut"
      }
    },
    [6114] = {
      west = {
        exitDest = 6115,
        exitKeyword = "cave"
      }
    },
    [6115] = {
      east = {
        exitDest = 6114,
        exitKeyword = "cave"
      }
    },
    [6136] = {
      north = {
        exitDest = 6137,
        exitKeyword = "pool"
      }
    },
    [6137] = {
      south = {
        exitDest = 6136,
        exitKeyword = "pool"
      }
    },
    [6142] = {
      east = {
        exitDest = 6154,
        exitKeyword = "graveyard"
      }
    },
    [6154] = {
      west = {
        exitDest = 6142,
        exitKeyword = "graveyard"
      }
    },
    [6157] = {
      north = {
        exitDest = 6158,
        exitKeyword = "graveyard"
      }
    },
    [6158] = {
      south = {
        exitDest = 6157,
        exitKeyword = "graveyard"
      }
    },
    [6251] = {
      east = {
        exitDest = 6252,
        exitKeyword = "door"
      }
    },
    [6252] = {
      west = {
        exitDest = 6251,
        exitKeyword = "door"
      }
    },
    [6254] = {
      north = {
        exitDest = 6260,
        exitKeyword = "door"
      }
    },
    [6257] = {
      east = {
        exitDest = 6258,
        exitKeyword = "door"
      }
    },
    [6258] = {
      west = {
        exitDest = 6257,
        exitKeyword = "door"
      }
    },
    [6259] = {
      north = {
        exitDest = 6265,
        exitKeyword = "rubble"
      }
    },
    [6260] = {
      north = {
        exitDest = 6266,
        exitKeyword = "cell"
      },
      south = {
        exitDest = 6254,
        exitKeyword = "door"
      }
    },
    [6263] = {
      east = {
        exitDest = 6264,
        exitKeyword = "rubble"
      }
    },
    [6264] = {
      west = {
        exitDest = 6263,
        exitKeyword = "rubble"
      }
    },
    [6265] = {
      south = {
        exitDest = 6259,
        exitKeyword = "rubble"
      }
    },
    [6266] = {
      south = {
        exitDest = 6260,
        exitKeyword = "cell"
      }
    },
    [6269] = {
      east = {
        exitDest = 6270,
        exitKeyword = "cage"
      }
    },
    [6270] = {
      west = {
        exitDest = 6269,
        exitKeyword = "cage"
      }
    },
    [6277] = {
      north = {
        exitDest = 6283,
        exitKeyword = "door"
      }
    },
    [6283] = {
      south = {
        exitDest = 6277,
        exitKeyword = "door"
      }
    },
    [6289] = {
      east = {
        exitDest = 6290,
        exitKeyword = "throne"
      }
    },
    [6290] = {
      west = {
        exitDest = 6289,
        exitKeyword = "throne"
      }
    },
    [6308] = {
      north = {
        exitDest = 6314,
        exitKeyword = "rock"
      }
    },
    [6314] = {
      south = {
        exitDest = 6308,
        exitKeyword = "rock"
      }
    },
    [6315] = {
      north = {
        exitDest = 6320,
        exitKeyword = "iron"
      }
    },
    [6320] = {
      south = {
        exitDest = 6315,
        exitKeyword = "iron"
      }
    },
    [6327] = {
      north = {
        exitDest = 6333,
        exitKeyword = "door"
      }
    },
    [6332] = {
      east = {
        exitDest = 6333,
        exitKeyword = "wooden"
      }
    },
    [6333] = {
      south = {
        exitDest = 6327,
        exitKeyword = "door"
      },
      west = {
        exitDest = 6332,
        exitKeyword = "wooden"
      }
    },
    [6338] = {
      down = {
        exitDest = 6344,
        exitKeyword = "trapdoor"
      }
    },
    [6344] = {
      up = {
        exitDest = 6338,
        exitKeyword = "trapdoor"
      }
    },
    [6347] = {
      east = {
        exitDest = 6348,
        exitKeyword = "ward"
      },
      north = {
        exitDest = 6350,
        exitKeyword = "ward"
      }
    },
    [6348] = {
      east = {
        exitDest = 6349,
        exitKeyword = "door"
      },
      west = {
        exitDest = 6347,
        exitKeyword = "ward"
      }
    },
    [6350] = {
      east = {
        exitDest = 6351,
        exitKeyword = "ward"
      },
      south = {
        exitDest = 6347,
        exitKeyword = "ward"
      }
    },
    [6351] = {
      west = {
        exitDest = 6350,
        exitKeyword = "ward"
      }
    },
    [6352] = {
      north = {
        exitDest = 6355,
        exitKeyword = "door"
      }
    },
    [6353] = {
      east = {
        exitDest = 6354,
        exitKeyword = "iron"
      }
    },
    [6354] = {
      west = {
        exitDest = 6353,
        exitKeyword = "iron"
      }
    },
    [6355] = {
      south = {
        exitDest = 6352,
        exitKeyword = "door"
      }
    },
    [6356] = {
      north = {
        exitDest = 6359,
        exitKeyword = "oak"
      }
    },
    [6357] = {
      east = {
        exitDest = 6358,
        exitKeyword = "snowman"
      }
    },
    [6358] = {
      west = {
        exitDest = 6357,
        exitKeyword = "snowman"
      }
    },
    [6359] = {
      south = {
        exitDest = 6356,
        exitKeyword = "oak"
      }
    },
    [6361] = {
      north = {
        exitDest = 6364,
        exitKeyword = "grass"
      }
    },
    [6362] = {
      east = {
        exitDest = 6363,
        exitKeyword = "flower"
      }
    },
    [6363] = {
      west = {
        exitDest = 6362,
        exitKeyword = "flower"
      }
    },
    [6364] = {
      south = {
        exitDest = 6361,
        exitKeyword = "grass"
      }
    },
    [6365] = {
      east = {
        exitDest = 6366,
        exitKeyword = "door"
      }
    },
    [6366] = {
      east = {
        exitDest = 6367,
        exitKey = 14415,
        exitKeyword = "vault"
      },
      west = {
        exitDest = 6365,
        exitKeyword = "door"
      }
    },
    [6367] = {
      west = {
        exitDest = 6366,
        exitKey = 14415,
        exitKeyword = "vault"
      }
    },
    [6372] = {
      east = {
        exitDest = 6373,
        exitKeyword = "door"
      }
    },
    [6373] = {
      west = {
        exitDest = 6372,
        exitKeyword = "door"
      }
    },
    [6405] = {
      east = {
        exitDest = 6406,
        exitKeyword = "door"
      }
    },
    [6406] = {
      west = {
        exitDest = 6405,
        exitKeyword = "door"
      }
    },
    [6408] = {
      south = {
        exitDest = 6409,
        exitKeyword = "wall"
      }
    },
    [6409] = {
      north = {
        exitDest = 6408,
        exitKeyword = "wall"
      }
    },
    [6522] = {
      up = {
        exitDescription = "A trapdoor has been carved into the smooth stone ceiling, in style too plain to be dwarven.",
        exitDest = 6523,
        exitKey = 14601,
        exitKeyword = "trapdoor"
      }
    },
    [6523] = {
      down = {
        exitDescription = "A narrow trapdoor has been cleanly hewn into the smooth stone floor.",
        exitDest = 6522,
        exitKey = 14601,
        exitKeyword = "trapdoor"
      }
    },
    [6532] = {
      east = {
        exitDescription = "The coloration of the stone on the eastern wall seems different.",
        exitDest = 6533,
        exitKeyword = "wall"
      }
    },
    [6533] = {
      west = {
        exitDescription = "The coloration of the stone in the western wall seems different.",
        exitDest = 6532,
        exitKeyword = "wall"
      }
    },
    [6547] = {
      south = {
        exitDescription = "The smooth southern wall of the crater bears features of a retractible door.",
        exitDest = 6570,
        exitKey = 14602,
        exitKeyword = "wall"
      }
    },
    [6570] = {
      north = {
        exitDescription = "The smooth northern wall of the cavern bears the features of a retractible door.",
        exitDest = 6547,
        exitKey = 14602,
        exitKeyword = "wall"
      }
    },
    [6607] = {
      north = {
        exitDescription = "A large metal portal looms in the northern exit.",
        exitDest = 6641,
        exitKey = 14603,
        exitKeyword = "door"
      }
    },
    [6621] = {
      south = {
        exitDescription = "A securely fastened door bars you from the massive, imposing southern building.",
        exitDest = 6623,
        exitKey = 14701,
        exitKeyword = "door"
      }
    },
    [6622] = {
      south = {
        exitDescription = "A securely fastened door bars you from entered the imposing southern building.",
        exitDest = 6632,
        exitKey = 14702,
        exitKeyword = "door"
      }
    },
    [6623] = {
      north = {
        exitDescription = "A securely fastened door seperates you from a long flight of stairs.",
        exitDest = 6621,
        exitKey = 14701,
        exitKeyword = "door"
      }
    },
    [6632] = {
      north = {
        exitDescription = "A securely fastened door seperates you from a long flight of stairs.",
        exitDest = 6622,
        exitKey = 14702,
        exitKeyword = "door"
      }
    },
    [6641] = {
      south = {
        exitDescription = "An odd door of solid metal looms in the southern exit.",
        exitDest = 6607,
        exitKey = 14603,
        exitKeyword = "door"
      }
    },
    [6724] = {
      north = {
        exitDest = 6729,
        exitKeyword = "gate"
      }
    },
    [6726] = {
      east = {
        exitDest = 6727,
        exitKeyword = "door"
      }
    },
    [6727] = {
      west = {
        exitDest = 6726,
        exitKeyword = "door"
      }
    },
    [6729] = {
      south = {
        exitDest = 6724,
        exitKeyword = "gate"
      }
    },
    [6731] = {
      east = {
        exitDest = 6732,
        exitKeyword = "door"
      }
    },
    [6732] = {
      west = {
        exitDest = 6731,
        exitKeyword = "door"
      }
    },
    [6733] = {
      north = {
        exitDest = 6735,
        exitKeyword = "double"
      }
    },
    [6735] = {
      east = {
        exitDest = 6736,
        exitKeyword = "door"
      },
      south = {
        exitDest = 6733,
        exitKeyword = "double"
      }
    },
    [6736] = {
      west = {
        exitDest = 6735,
        exitKeyword = "door"
      }
    },
    [6741] = {
      north = {
        exitDest = 6747,
        exitKeyword = "door"
      }
    },
    [6742] = {
      north = {
        exitDest = 6743,
        exitKey = 15407,
        exitKeyword = "steel"
      }
    },
    [6743] = {
      east = {
        exitDest = 6744,
        exitKey = 15415,
        exitKeyword = "iron"
      },
      south = {
        exitDest = 6742,
        exitKey = 15407,
        exitKeyword = "steel"
      }
    },
    [6744] = {
      east = {
        exitDest = 6745,
        exitKey = 15401,
        exitKeyword = "wooden"
      },
      west = {
        exitDest = 6743,
        exitKey = 15415,
        exitKeyword = "iron"
      }
    },
    [6745] = {
      west = {
        exitDest = 6744,
        exitKey = 15401,
        exitKeyword = "wooden"
      }
    },
    [6746] = {
      east = {
        exitDest = 6747,
        exitKeyword = "door"
      }
    },
    [6747] = {
      east = {
        exitDest = 6748,
        exitKeyword = "door"
      },
      south = {
        exitDest = 6741,
        exitKeyword = "door"
      },
      west = {
        exitDest = 6746,
        exitKeyword = "door"
      }
    },
    [6748] = {
      west = {
        exitDest = 6747,
        exitKeyword = "door"
      }
    },
    [6751] = {
      east = {
        exitDest = 6752,
        exitKeyword = "door"
      }
    },
    [6752] = {
      west = {
        exitDest = 6751,
        exitKeyword = "door"
      }
    },
    [6754] = {
      east = {
        exitDest = 6755,
        exitKeyword = "door"
      }
    },
    [6755] = {
      west = {
        exitDest = 6754,
        exitKeyword = "door"
      }
    },
    [6791] = {
      east = {
        exitDescription = "The Doorway to the unknown",
        exitDest = 6792,
        exitKey = 16625,
        exitKeyword = "Gateway"
      }
    },
    [6792] = {
      east = {
        exitDescription = "The Dark maze",
        exitDest = 6793,
        exitKeyword = "Double"
      },
      west = {
        exitDescription = "The Dark Doorway",
        exitDest = 6791,
        exitKey = 16625,
        exitKeyword = "Gateway"
      }
    },
    [6793] = {
      east = {
        exitDescription = "The Guardians of the Maze",
        exitDest = 6794,
        exitKeyword = "Gate"
      },
      west = {
        exitDescription = "The Drow Outpost",
        exitDest = 6792,
        exitKeyword = "Double"
      }
    },
    [6794] = {
      down = {
        exitDescription = "A tunnel sloping downwards",
        exitDest = 6795,
        exitKeyword = "door"
      },
      west = {
        exitDescription = "The mini maze",
        exitDest = 6793,
        exitKeyword = "Gate"
      }
    },
    [6795] = {
      up = {
        exitDescription = "The Guardians of the Maze",
        exitDest = 6794,
        exitKeyword = "door"
      }
    },
    [6805] = {
      north = {
        exitDest = 6808,
        exitKeyword = "door"
      }
    },
    [6808] = {
      south = {
        exitDest = 6805,
        exitKeyword = "door"
      }
    },
    [6811] = {
      north = {
        exitDest = 6818,
        exitKeyword = "door"
      }
    },
    [6817] = {
      north = {
        exitDest = 6826,
        exitKeyword = "door"
      }
    },
    [6818] = {
      north = {
        exitDest = 6827,
        exitKeyword = "door"
      },
      south = {
        exitDest = 6811,
        exitKeyword = "door"
      }
    },
    [6819] = {
      east = {
        exitDest = 6820,
        exitKeyword = "door"
      }
    },
    [6820] = {
      west = {
        exitDest = 6819,
        exitKeyword = "door"
      }
    },
    [6824] = {
      east = {
        exitDest = 6825,
        exitKeyword = "door"
      }
    },
    [6825] = {
      west = {
        exitDest = 6824,
        exitKeyword = "door"
      }
    },
    [6826] = {
      north = {
        exitDest = 6833,
        exitKeyword = "door"
      },
      south = {
        exitDest = 6817,
        exitKeyword = "door"
      }
    },
    [6827] = {
      south = {
        exitDest = 6818,
        exitKeyword = "door"
      }
    },
    [6833] = {
      south = {
        exitDest = 6826,
        exitKeyword = "door"
      }
    },
    [6836] = {
      north = {
        exitDest = 6839,
        exitKeyword = "door"
      }
    },
    [6839] = {
      south = {
        exitDest = 6836,
        exitKeyword = "door"
      }
    },
    [6840] = {
      east = {
        exitDest = 6841,
        exitKeyword = "door"
      }
    },
    [6841] = {
      east = {
        exitDest = 6842,
        exitKeyword = "door"
      },
      west = {
        exitDest = 6840,
        exitKeyword = "door"
      }
    },
    [6842] = {
      west = {
        exitDest = 6841,
        exitKeyword = "door"
      }
    },
    [6853] = {
      south = {
        exitDescription = "You see a unusual thickness of brush to the south.",
        exitDest = 6858,
        exitKeyword = "brush"
      }
    },
    [6855] = {
      down = {
        exitDescription = "You see a loose floorboard.",
        exitDest = 6856,
        exitKeyword = "floor"
      }
    },
    [6856] = {
      up = {
        exitDescription = "You can see the false floorboard above you.",
        exitDest = 6855,
        exitKeyword = "floor"
      }
    },
    [6858] = {
      north = {
        exitDescription = "There is some underbrush here.",
        exitDest = 6853,
        exitKeyword = "brush"
      }
    },
    [6875] = {
      east = {
        exitDescription = "There seems to be an irregularity in the tree's bark.",
        exitDest = 6877,
        exitKeyword = "Tree"
      }
    },
    [6877] = {
      west = {
        exitDescription = "You can see the cut of the door more easily from the inside.",
        exitDest = 6875,
        exitKeyword = "Tree"
      }
    },
    [6889] = {
      south = {
        exitDest = 6891,
        exitKey = 17906,
        exitKeyword = "backdoor"
      }
    },
    [6891] = {
      north = {
        exitDescription = "You see a latched door.",
        exitDest = 6889,
        exitKey = 17906,
        exitKeyword = "backdoor"
      }
    },
    [6904] = {
      down = {
        exitDescription = "You see faces blank from the impact of nameless horror through the bars.",
        exitDest = 6905,
        exitKeyword = "cage"
      }
    },
    [6905] = {
      up = {
        exitDest = 6904,
        exitKeyword = "cage"
      }
    },
    [6907] = {
      south = {
        exitDescription = "This door has an ugly, evil looking symbol on it.",
        exitDest = 6908,
        exitKeyword = "door"
      }
    },
    [6908] = {
      north = {
        exitDest = 6907,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "You see a bookcase.",
        exitDest = 6909,
        exitKey = 17904,
        exitKeyword = "bookcase"
      }
    },
    [6909] = {
      north = {
        exitDest = 6908,
        exitKey = 17904,
        exitKeyword = "bookcase"
      }
    },
    [6920] = {
      east = {
        exitDescription = "You see a wooden double door which is reinforced with iron bars.",
        exitDest = 6921,
        exitKeyword = "double"
      }
    },
    [6921] = {
      west = {
        exitDescription = "You see a wooden double door which is reinforced with iron bars.",
        exitDest = 6920,
        exitKeyword = "double"
      }
    },
    [6922] = {
      east = {
        exitDescription = "You see a wooden door.",
        exitDest = 6933,
        exitKeyword = "door"
      }
    },
    [6927] = {
      east = {
        exitDescription = "This iron door looks extremely strong.",
        exitDest = 6943,
        exitKey = 18700,
        exitKeyword = "iron"
      }
    },
    [6928] = {
      west = {
        exitDescription = "You see a wooden door.",
        exitDest = 6935,
        exitKeyword = "door"
      }
    },
    [6929] = {
      east = {
        exitDescription = "You see a wooden door.",
        exitDest = 6944,
        exitKeyword = "door"
      }
    },
    [6931] = {
      south = {
        exitDescription = "You can see a wooden door which has marks of clawing.",
        exitDest = 6945,
        exitKeyword = "door"
      }
    },
    [6933] = {
      west = {
        exitDescription = "You see a wooden door.",
        exitDest = 6922,
        exitKeyword = "door"
      }
    },
    [6934] = {
      south = {
        exitDescription = "You see a glass door and through that you can see many plants.",
        exitDest = 6936,
        exitKeyword = "door"
      }
    },
    [6935] = {
      east = {
        exitDescription = "You see a wooden door.",
        exitDest = 6928,
        exitKeyword = "door"
      }
    },
    [6936] = {
      north = {
        exitDescription = "You see a glass door and through it you can see to the Insect and Reptile exhibition.",
        exitDest = 6934,
        exitKeyword = "door"
      }
    },
    [6937] = {
      south = {
        exitDescription = "You can see a wooden door and a text on it: Storeroom.",
        exitDest = 6940,
        exitKey = 18701,
        exitKeyword = "door"
      }
    },
    [6940] = {
      north = {
        exitDescription = "You see a wooden door.",
        exitDest = 6937,
        exitKey = 18701,
        exitKeyword = "door"
      }
    },
    [6943] = {
      west = {
        exitDescription = "You see an iron door.",
        exitDest = 6927,
        exitKey = 18700,
        exitKeyword = "door"
      }
    },
    [6944] = {
      west = {
        exitDescription = "You see a wooden door.",
        exitDest = 6929,
        exitKeyword = "door"
      }
    },
    [6945] = {
      north = {
        exitDescription = "You can see a wooden door which has marks of clawing.",
        exitDest = 6931,
        exitKeyword = "door"
      }
    },
    [6946] = {
      north = {
        exitDescription = "You can see a wooden door.",
        exitDest = 6947,
        exitKeyword = "door"
      }
    },
    [6947] = {
      south = {
        exitDescription = "You see a wooden door.",
        exitDest = 6946,
        exitKeyword = "door"
      }
    },
    [6948] = {
      east = {
        exitDescription = "You can see a reinforced wooden door.",
        exitDest = 6956,
        exitKeyword = "door"
      }
    },
    [6951] = {
      north = {
        exitDescription = "You can see a wooden door and a sign on it where reads: Hall of Knights.",
        exitDest = 6954,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "You can see a wooden door where reads: Egyptology.",
        exitDest = 6953,
        exitKeyword = "door"
      }
    },
    [6952] = {
      west = {
        exitDescription = "You can see a large double doors. There is a plate on the door.",
        exitDest = 6953,
        exitKeyword = "double"
      }
    },
    [6953] = {
      east = {
        exitDescription = "You can see the large double doors.",
        exitDest = 6952,
        exitKeyword = "double"
      },
      north = {
        exitDescription = "You can see a wooden door.",
        exitDest = 6951,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "You can see an ancient sarcophagus.",
        exitDest = 6958,
        exitKey = 18710,
        exitKeyword = "sarcophagus"
      }
    },
    [6954] = {
      south = {
        exitDescription = "You can see a wooden door.",
        exitDest = 6951,
        exitKeyword = "door"
      }
    },
    [6956] = {
      up = {
        exitDescription = "You can see a hatch.",
        exitDest = 6957,
        exitKeyword = "hatch"
      },
      west = {
        exitDescription = "You see a reinforced wooden door.",
        exitDest = 6948,
        exitKeyword = "door"
      }
    },
    [6962] = {
      north = {
        exitDescription = "The doors are made of iron and seem to have undergone a large amount of beating",
        exitDest = 6963,
        exitFlags = -1,
        exitKeyword = "doors"
      }
    },
    [6963] = {
      east = {
        exitDest = 6965,
        exitFlags = -1,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "The doors of the castle are stained with blood and have large nicks in them",
        exitDest = 6962,
        exitFlags = -1,
        exitKeyword = "doors"
      },
      west = {
        exitDest = 6964,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6964] = {
      east = {
        exitDest = 6963,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6965] = {
      west = {
        exitDest = 6963,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6966] = {
      north = {
        exitDest = 6968,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6967] = {
      north = {
        exitDest = 6978,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6968] = {
      north = {
        exitDest = 6974,
        exitFlags = -1,
        exitKeyword = "door"
      },
      south = {
        exitDest = 6966,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6969] = {
      north = {
        exitDest = 6979,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6970] = {
      east = {
        exitDest = 6984,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6971] = {
      west = {
        exitDescription = "You see a large oaken door..",
        exitDest = 6980,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6973] = {
      north = {
        exitDescription = "You see the hallway..",
        exitDest = 6971,
        exitFlags = -1,
        exitKeyword = "secret"
      }
    },
    [6974] = {
      east = {
        exitDescription = "You see a large oak door..",
        exitDest = 6998,
        exitFlags = -1,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "You see a heavy oak door..",
        exitDest = 6968,
        exitFlags = -1,
        exitKeyword = "door"
      },
      west = {
        exitDescription = "You see a heavy oak door..",
        exitDest = 7001,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6975] = {
      east = {
        exitDescription = "You see a large oak door",
        exitDest = 6997,
        exitFlags = -1,
        exitKeyword = "door"
      },
      north = {
        exitDescription = "You see a large oak door..",
        exitDest = 6976,
        exitFlags = -1,
        exitKeyword = "door"
      },
      west = {
        exitDescription = "You see a large oak door..",
        exitDest = 6999,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6976] = {
      north = {
        exitDescription = "You see a heavy oaken door..",
        exitDest = 6977,
        exitFlags = -1,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "You see the courtyard through the windows..",
        exitDest = 6975,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6977] = {
      north = {
        exitDescription = "You see a heavy oak door..",
        exitDest = 7012,
        exitFlags = -1,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "You see a heavy oak door..",
        exitDest = 6976,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6978] = {
      south = {
        exitDescription = "You see the hallway..",
        exitDest = 6967,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6979] = {
      south = {
        exitDescription = "You see a heavy oak door leading back into the hallway..",
        exitDest = 6969,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6980] = {
      east = {
        exitDescription = "You see the hallway..",
        exitDest = 6971,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6981] = {
      east = {
        exitDescription = "You see the hallway..",
        exitDest = 6982,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6982] = {
      west = {
        exitDescription = "You see a heavy oak door..",
        exitDest = 6981,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6983] = {
      west = {
        exitDescription = "You see a heavy oak door..",
        exitDest = 7003,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6984] = {
      west = {
        exitDescription = "You see a heavy oak door..",
        exitDest = 6970,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6985] = {
      east = {
        exitDescription = "You see a heavy oak door..",
        exitDest = 6986,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6986] = {
      west = {
        exitDescription = "The hallway lies west..",
        exitDest = 6985,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6987] = {
      west = {
        exitDescription = "The hallway lies west..",
        exitDest = 6988,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6988] = {
      east = {
        exitDescription = "You see a heavy oak door..",
        exitDest = 6987,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6989] = {
      east = {
        exitDescription = "You see a heavy oak door..",
        exitDest = 6990,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6990] = {
      west = {
        exitDescription = "The hallway lies west..",
        exitDest = 6989,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6991] = {
      east = {
        exitDescription = "You see a heavy oak door..",
        exitDest = 6992,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6992] = {
      west = {
        exitDescription = "The hallway lies to the west..",
        exitDest = 6991,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6995] = {
      north = {
        exitDescription = "You see a heavy oak door..",
        exitDest = 7002,
        exitFlags = -1,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "You see a heavy oaken door..",
        exitDest = 6996,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6996] = {
      north = {
        exitDescription = "The hallway lies north..",
        exitDest = 6995,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6997] = {
      west = {
        exitDescription = "the courtyard lies west..",
        exitDest = 6975,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6998] = {
      west = {
        exitDescription = "The courtyard lies west..",
        exitDest = 6974,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [6999] = {
      east = {
        exitDescription = "The courtyard lies east..",
        exitDest = 6975,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [7000] = {
      north = {
        exitDescription = "You see a heavy oaken door..",
        exitDest = 7010,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [7001] = {
      east = {
        exitDescription = "The courtyard lies east..",
        exitDest = 6974,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [7002] = {
      south = {
        exitDescription = "The hallway lies south..",
        exitDest = 6995,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [7003] = {
      east = {
        exitDescription = "The hallway lies east..",
        exitDest = 6983,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [7004] = {
      west = {
        exitDescription = "You see a heavy oaken door..",
        exitDest = 7005,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [7005] = {
      east = {
        exitDescription = "The hallway lies east..",
        exitDest = 7004,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [7006] = {
      east = {
        exitDescription = "The hallway lies east..",
        exitDest = 7007,
        exitKey = 19211,
        exitKeyword = "door"
      }
    },
    [7007] = {
      west = {
        exitDescription = "You see a heavy oaken door..",
        exitDest = 7006,
        exitKey = 19211,
        exitKeyword = "door"
      }
    },
    [7010] = {
      north = {
        exitDescription = "You see a heavy oak door..",
        exitDest = 7011,
        exitFlags = -1,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "You see a heavy oak door..",
        exitDest = 7000,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [7011] = {
      south = {
        exitDest = 7010,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [7012] = {
      south = {
        exitDescription = "The hallway lies south..",
        exitDest = 6977,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [7119] = {
      south = {
        exitDest = 7205,
        exitKey = 20158,
        exitKeyword = "door"
      }
    },
    [7124] = {
      south = {
        exitDest = 7174,
        exitKey = 20152,
        exitKeyword = "door"
      }
    },
    [7125] = {
      north = {
        exitDest = 7168,
        exitKeyword = "secret"
      }
    },
    [7127] = {
      north = {
        exitDest = 7154,
        exitKey = 20156,
        exitKeyword = "gate"
      }
    },
    [7128] = {
      south = {
        exitDest = 7148,
        exitKey = 20145,
        exitKeyword = "gate"
      }
    },
    [7129] = {
      down = {
        exitDest = 7141,
        exitKeyword = "straw"
      },
      north = {
        exitDest = 7151,
        exitKey = 20153,
        exitKeyword = "door"
      },
      up = {
        exitDest = 7140,
        exitKeyword = "hatch"
      }
    },
    [7130] = {
      north = {
        exitDest = 7172,
        exitKey = 20150,
        exitKeyword = "door"
      }
    },
    [7132] = {
      south = {
        exitDest = 7201,
        exitKey = 20154,
        exitKeyword = "door"
      }
    },
    [7137] = {
      west = {
        exitDest = 7202,
        exitKey = 20151,
        exitKeyword = "door"
      }
    },
    [7139] = {
      south = {
        exitDest = 7204,
        exitKey = 20155,
        exitKeyword = "gate"
      }
    },
    [7140] = {
      down = {
        exitDest = 7129,
        exitKeyword = "hatch"
      }
    },
    [7148] = {
      down = {
        exitDest = 7149,
        exitKeyword = "trapdoor"
      },
      north = {
        exitDest = 7128,
        exitKey = 20145,
        exitKeyword = "gate"
      }
    },
    [7151] = {
      south = {
        exitDest = 7129,
        exitKey = 20153,
        exitKeyword = "door"
      }
    },
    [7160] = {
      down = {
        exitDest = 7159,
        exitKey = 20147,
        exitKeyword = "door"
      }
    },
    [7165] = {
      down = {
        exitDest = 7169,
        exitKeyword = "grate"
      }
    },
    [7168] = {
      south = {
        exitDest = 7125,
        exitKeyword = "secret"
      }
    },
    [7174] = {
      down = {
        exitDest = 7177,
        exitKeyword = "trapdoor"
      },
      north = {
        exitDest = 7124,
        exitKey = 20152,
        exitKeyword = "door"
      }
    },
    [7181] = {
      north = {
        exitDest = 7184,
        exitKey = 20144,
        exitKeyword = "door"
      }
    },
    [7182] = {
      north = {
        exitDest = 7183,
        exitKey = 20149,
        exitKeyword = "door"
      }
    },
    [7183] = {
      south = {
        exitDest = 7182,
        exitKey = 20149,
        exitKeyword = "door"
      }
    },
    [7185] = {
      east = {
        exitDest = 7177,
        exitKeyword = "door"
      }
    },
    [7206] = {
      down = {
        exitDest = 7208,
        exitKeyword = "panelling"
      }
    },
    [7220] = {
      down = {
        exitDescription = "It looks as though you could open it like a door.",
        exitDest = 7221,
        exitKeyword = "hatch"
      }
    },
    [7221] = {
      up = {
        exitDescription = "You ponder the possibility of getting sand in your eyes if you open the hatch from this side.",
        exitDest = 7220,
        exitKeyword = "hatch"
      }
    },
    [7224] = {
      north = {
        exitDescription = "You can't seem to find the mechanism to open the mirror from this side.",
        exitDest = 7260,
        exitKeyword = "lever"
      }
    },
    [7226] = {
      west = {
        exitDescription = "The door has shut behind you.",
        exitDest = 7228,
        exitKeyword = "door"
      }
    },
    [7227] = {
      west = {
        exitDescription = "There is a strange door here, with no handles.",
        exitDest = 7228,
        exitKeyword = "door"
      }
    },
    [7228] = {
      east = {
        exitDescription = "You cannot seem to open the door from this side.",
        exitDest = 4627,
        exitKeyword = "door"
      },
      north = {
        exitDescription = "A small door, you can hear Christine crying from the other side.",
        exitDest = 7226,
        exitKey = 11552,
        exitKeyword = "door"
      }
    },
    [7260] = {
      east = {
        exitDescription = "If it weren't for the smudge on the mirror, you would have never spotted the lever.",
        exitDest = 7224,
        exitKeyword = "lever"
      }
    },
    [7271] = {
      down = {
        exitDescription = "Looking down, you see the Tomb of the Flayed.",
        exitDest = 7344,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7272] = {
      down = {
        exitDescription = "Looking down, you see the House of Abacination.",
        exitDest = 7345,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7273] = {
      down = {
        exitDescription = "Looking down, you see the Room of the Judgment Tattoo.",
        exitDest = 7346,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7274] = {
      down = {
        exitDescription = "Looking down, you see the House of Slow Incineration.",
        exitDest = 7347,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7275] = {
      down = {
        exitDescription = "If you go down, YOU'LL BE SORRY!",
        exitDest = 7348,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7279] = {
      east = {
        exitDescription = "To the east, you see the blackened hall of the Vicar.",
        exitDest = 7354,
        exitKey = 22404,
        exitKeyword = "stone"
      }
    },
    [7283] = {
      down = {
        exitDescription = "Looking down, you see the Ant Farm.",
        exitDest = 7353,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7284] = {
      down = {
        exitDescription = "Looking down, you see the Ant Farm.",
        exitDest = 7352,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7285] = {
      down = {
        exitDescription = "Looking down, you see the Tomb of Amputations.",
        exitDest = 7351,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7286] = {
      down = {
        exitDescription = "Looking down, you see the Dwelling of Slow Evisceration.",
        exitDest = 7350,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7287] = {
      down = {
        exitDescription = "Looking down, you see the Sepulcher of Nine Inch Nails.",
        exitDest = 7349,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7344] = {
      up = {
        exitDescription = "Looking up, you see a mausoleum.",
        exitDest = 7271,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7345] = {
      up = {
        exitDescription = "Looking up, you see a mausoleum.",
        exitDest = 7272,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7346] = {
      up = {
        exitDescription = "Looking up, you see a mausoleum.",
        exitDest = 7273,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7347] = {
      up = {
        exitDescription = "Looking up, you see a mausoleum.",
        exitDest = 7274,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7348] = {
      up = {
        exitDescription = "Looking up, you see a mausoleum.",
        exitDest = 7275,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7349] = {
      up = {
        exitDescription = "Looking up, you see a mausoleum.",
        exitDest = 7287,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7350] = {
      up = {
        exitDescription = "Looking up, you see a mausoleum.",
        exitDest = 7286,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7351] = {
      up = {
        exitDescription = "Looking up, you see a mausoleum.",
        exitDest = 7285,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7352] = {
      up = {
        exitDescription = "Looking up, you see a mausoleum.",
        exitDest = 7284,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7353] = {
      up = {
        exitDescription = "Looking up, you see a mausoleum.",
        exitDest = 7283,
        exitKey = 22404,
        exitKeyword = "tomb"
      }
    },
    [7354] = {
      west = {
        exitDescription = "The hall empties into a darkness teeming with the dead.",
        exitDest = 7279,
        exitKey = 22404,
        exitKeyword = "stone"
      }
    },
    [7358] = {
      north = {
        exitDescription = "You see a laboratory.",
        exitDest = 7361,
        exitFlags = -1,
        exitKeyword = "door"
      }
    },
    [7368] = {
      west = {
        exitDescription = "The hospital entry.",
        exitDest = 7367,
        exitFlags = -1,
        exitKeyword = "Entry"
      }
    },
    [7369] = {
      east = {
        exitDescription = "The hospital entry.",
        exitDest = 7367,
        exitFlags = -1,
        exitKeyword = "Entry"
      },
      north = {
        exitDescription = "This leads into the hospital itself.",
        exitDest = 7370,
        exitFlags = -1,
        exitKeyword = "Hospital"
      }
    },
    [7370] = {
      east = {
        exitDescription = "You see a cot.",
        exitDest = 7373,
        exitFlags = -1,
        exitKeyword = "cot"
      },
      north = {
        exitDescription = "The aisle continues.",
        exitDest = 7371,
        exitFlags = -1,
        exitKeyword = "aisle"
      },
      south = {
        exitDescription = "You see a waiting room.",
        exitDest = 7369,
        exitFlags = -1,
        exitKeyword = "waiting"
      },
      west = {
        exitDescription = "You see a cot.",
        exitDest = 7374,
        exitFlags = -1,
        exitKeyword = "cot"
      }
    },
    [7371] = {
      east = {
        exitDescription = "You see a cot.",
        exitDest = 7378,
        exitFlags = -1,
        exitKeyword = "cot"
      },
      north = {
        exitDescription = "More Aisle.",
        exitDest = 7372,
        exitFlags = -1,
        exitKeyword = "aisle"
      },
      south = {
        exitDescription = "More aisle.",
        exitDest = 7370,
        exitFlags = -1,
        exitKeyword = "aisle"
      },
      west = {
        exitDescription = "You see a cot.",
        exitDest = 7375,
        exitFlags = -1,
        exitKeyword = "cot"
      }
    },
    [7372] = {
      east = {
        exitDescription = "You see a cot.",
        exitDest = 7376,
        exitFlags = -1,
        exitKeyword = "cot"
      },
      north = {
        exitDescription = "You see the healing room.",
        exitDest = 7379,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "The aisle.",
        exitDest = 7371,
        exitFlags = -1,
        exitKeyword = "aisle"
      },
      west = {
        exitDescription = "The stench of evil almost drives you to your knees.",
        exitDest = 7377,
        exitFlags = -1,
        exitKeyword = "archway"
      }
    },
    [7373] = {
      west = {
        exitDescription = "The aisle",
        exitDest = 7370,
        exitFlags = -1,
        exitKeyword = "aisle"
      }
    },
    [7374] = {
      east = {
        exitDescription = "The aisle.",
        exitDest = 7370,
        exitFlags = -1,
        exitKeyword = "aisle"
      }
    },
    [7375] = {
      east = {
        exitDescription = "The aisle",
        exitDest = 7371,
        exitFlags = -1,
        exitKeyword = "aisle"
      }
    },
    [7376] = {
      west = {
        exitDescription = "The aisle",
        exitDest = 7372,
        exitFlags = -1,
        exitKeyword = "aisle"
      }
    },
    [7377] = {
      down = {
        exitDescription = "You see stone steps heading down into the darkness.",
        exitDest = 7380,
        exitFlags = -1,
        exitKeyword = "stairs"
      },
      east = {
        exitDescription = "The aisle.",
        exitDest = 7372,
        exitFlags = -1,
        exitKeyword = "aisle"
      }
    },
    [7379] = {
      south = {
        exitDescription = "The aisle.",
        exitDest = 7372,
        exitKeyword = "door"
      }
    },
    [7380] = {
      down = {
        exitDescription = "It's too dark to make anything out...",
        exitDest = 7381,
        exitKeyword = "Door"
      },
      up = {
        exitDescription = "You see the narrow stone corridor.",
        exitDest = 7377,
        exitFlags = -1,
        exitKeyword = "corridor"
      }
    },
    [7397] = {
      north = {
        exitDescription = "A Corridor",
        exitDest = 7398,
        exitKeyword = "door"
      }
    },
    [7398] = {
      north = {
        exitDescription = "You see several figures in there.",
        exitDest = 7399,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "The landing.",
        exitDest = 7397,
        exitKeyword = "door"
      }
    },
    [7399] = {
      south = {
        exitDescription = "You see a short corridor.",
        exitDest = 7398,
        exitKeyword = "door"
      }
    },
    [7412] = {
      west = {
        exitDest = 7414,
        exitKeyword = "Door"
      }
    },
    [7432] = {
      north = {
        exitDest = 7433,
        exitKeyword = "gate"
      }
    },
    [7433] = {
      south = {
        exitDest = 7432,
        exitKeyword = "gate"
      }
    },
    [7435] = {
      west = {
        exitDest = 7436,
        exitKey = 25050,
        exitKeyword = "door"
      }
    },
    [7436] = {
      east = {
        exitDest = 7435,
        exitKey = 25050,
        exitKeyword = "door"
      }
    },
    [7451] = {
      south = {
        exitDest = 7452,
        exitKey = 25051,
        exitKeyword = "door"
      }
    },
    [7452] = {
      south = {
        exitDest = 7453,
        exitKey = 25052,
        exitKeyword = "door"
      }
    },
    [7453] = {
      north = {
        exitDest = 7452,
        exitKey = 25052,
        exitKeyword = "door"
      }
    },
    [7456] = {
      east = {
        exitDest = 7457,
        exitKey = 25053,
        exitKeyword = "double"
      }
    },
    [7457] = {
      west = {
        exitDest = 7456,
        exitKey = 25053,
        exitKeyword = "double"
      }
    },
    [7459] = {
      south = {
        exitDest = 7460,
        exitKeyword = "door"
      }
    },
    [7460] = {
      north = {
        exitDest = 7459,
        exitKeyword = "door"
      },
      south = {
        exitDest = 7461,
        exitKeyword = "door"
      }
    },
    [7461] = {
      east = {
        exitDest = 7462,
        exitKey = 25054,
        exitKeyword = "metal"
      }
    },
    [7469] = {
      west = {
        exitDest = 7470,
        exitKeyword = "door"
      }
    },
    [7470] = {
      east = {
        exitDest = 7469,
        exitKeyword = "door"
      }
    },
    [7471] = {
      north = {
        exitDest = 7474,
        exitKeyword = "door"
      },
      west = {
        exitDest = 7472,
        exitKeyword = "door"
      }
    },
    [7472] = {
      east = {
        exitDest = 7471,
        exitKeyword = "door"
      },
      west = {
        exitDest = 7473,
        exitKeyword = "ornate"
      }
    },
    [7473] = {
      east = {
        exitDest = 7472,
        exitKeyword = "large"
      }
    },
    [7474] = {
      south = {
        exitDest = 7471,
        exitKeyword = "door"
      },
      west = {
        exitDest = 7475,
        exitKeyword = "door"
      }
    },
    [7475] = {
      east = {
        exitDest = 7474,
        exitKeyword = "door"
      }
    },
    [7476] = {
      south = {
        exitDest = 7477,
        exitKeyword = "door"
      }
    },
    [7477] = {
      north = {
        exitDest = 7476,
        exitKeyword = "door"
      }
    },
    [7480] = {
      west = {
        exitDest = 7481,
        exitKeyword = "door"
      }
    },
    [7481] = {
      east = {
        exitDest = 7480,
        exitKeyword = "door"
      }
    },
    [7483] = {
      west = {
        exitDest = 7484,
        exitKeyword = "wall"
      }
    },
    [7484] = {
      east = {
        exitDest = 7483,
        exitKeyword = "wall"
      },
      south = {
        exitDest = 7485,
        exitKeyword = "iron"
      }
    },
    [7485] = {
      north = {
        exitDest = 7484,
        exitKeyword = "solid"
      }
    },
    [7486] = {
      east = {
        exitDest = 7487,
        exitKeyword = "wall"
      }
    },
    [7487] = {
      east = {
        exitDest = 7486,
        exitKeyword = "wall"
      }
    },
    [7529] = {
      north = {
        exitDescription = "You see massive iron gates.",
        exitDest = 7530,
        exitKeyword = "iron"
      }
    },
    [7530] = {
      south = {
        exitDescription = "You see massive iron gates.",
        exitDest = 7529,
        exitKeyword = "iron"
      }
    },
    [7548] = {
      north = {
        exitDescription = "You see a giant wooden gate.",
        exitDest = 7552,
        exitKey = 25217,
        exitKeyword = "gate"
      }
    },
    [7552] = {
      south = {
        exitDescription = "You see a giant wooden gate.",
        exitDest = 7548,
        exitKey = 25217,
        exitKeyword = "gate"
      }
    },
    [7579] = {
      north = {
        exitDescription = "Inside the fortress.",
        exitDest = 7580,
        exitKeyword = "iron"
      }
    },
    [7580] = {
      north = {
        exitDescription = "The great hall.",
        exitDest = 7581,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "Outside the great gates.",
        exitDest = 7579,
        exitKeyword = "iron"
      }
    },
    [7587] = {
      east = {
        exitDescription = "The doorway leading to the king's chamber.",
        exitDest = 7588,
        exitKeyword = "door"
      }
    },
    [7588] = {
      west = {
        exitDescription = "The doorway leading to the hall.",
        exitDest = 7587,
        exitKeyword = "door"
      }
    },
    [7599] = {
      south = {
        exitDest = 7600,
        exitKeyword = "secret"
      }
    },
    [7600] = {
      north = {
        exitDest = 7599,
        exitKeyword = "secret"
      }
    },
    [7618] = {
      north = {
        exitDest = 7619,
        exitKeyword = "secret"
      }
    },
    [7619] = {
      south = {
        exitDest = 7618,
        exitKeyword = "secret"
      }
    },
    [7639] = {
      north = {
        exitDest = 7640,
        exitKeyword = "secret"
      }
    },
    [7640] = {
      south = {
        exitDest = 7639,
        exitKeyword = "secret"
      }
    },
    [7659] = {
      down = {
        exitDest = 7660,
        exitKeyword = "trapdoor"
      }
    },
    [7660] = {
      up = {
        exitDest = 7659,
        exitKeyword = "trapdoor"
      }
    },
    [7673] = {
      north = {
        exitDest = 7674,
        exitKeyword = "black"
      }
    },
    [7674] = {
      south = {
        exitDest = 7673,
        exitKeyword = "black"
      }
    },
    [7701] = {
      north = {
        exitDescription = "You see a lot of pine trees and some thick brush.",
        exitDest = 7704,
        exitKeyword = "brush"
      }
    },
    [7704] = {
      south = {
        exitDescription = "You see a lot of pine trees and some thick brush.",
        exitDest = 7701,
        exitKeyword = "brush"
      }
    },
    [7783] = {
      east = {
        exitDescription = "The clearing",
        exitDest = 7786,
        exitKey = 26500,
        exitKeyword = "ward"
      }
    },
    [7786] = {
      south = {
        exitDescription = "A bright path",
        exitDest = 7817,
        exitKey = 26508,
        exitKeyword = "ward"
      },
      west = {
        exitDescription = "At the warded clearing",
        exitDest = 7783,
        exitKey = 26500,
        exitKeyword = "ward"
      }
    },
    [7789] = {
      north = {
        exitDescription = "A hidden path",
        exitDest = 7857,
        exitKeyword = "secret"
      }
    },
    [7798] = {
      south = {
        exitDescription = "A hidden path",
        exitDest = 7799,
        exitKeyword = "secret"
      }
    },
    [7799] = {
      north = {
        exitDescription = "A clay path",
        exitDest = 7798,
        exitKeyword = "secret"
      }
    },
    [7815] = {
      down = {
        exitDescription = "In the mossy hole",
        exitDest = 7816,
        exitKey = 26509,
        exitKeyword = "ward"
      }
    },
    [7816] = {
      up = {
        exitDescription = "A mossy hole",
        exitDest = 7815,
        exitKey = 26509,
        exitKeyword = "ward"
      }
    },
    [7817] = {
      north = {
        exitDescription = "The clearing",
        exitDest = 7786,
        exitKey = 26508,
        exitKeyword = "ward"
      }
    },
    [7820] = {
      east = {
        exitDescription = "A hidden grove",
        exitDest = 7821,
        exitKeyword = "secret"
      }
    },
    [7821] = {
      west = {
        exitDescription = "A dirt path",
        exitDest = 7820,
        exitKeyword = "secret"
      }
    },
    [7824] = {
      west = {
        exitDescription = "The traveler's rest",
        exitDest = 7839,
        exitKey = 26502,
        exitKeyword = "ward"
      }
    },
    [7832] = {
      south = {
        exitDescription = "Through the dark ward",
        exitDest = 7833,
        exitKey = 26503,
        exitKeyword = "ward"
      }
    },
    [7833] = {
      down = {
        exitDescription = "Down the dark hole",
        exitDest = 7834,
        exitKey = 26504,
        exitKeyword = "ward"
      },
      north = {
        exitDescription = "A dusty path",
        exitDest = 7832,
        exitKey = 26503,
        exitKeyword = "ward"
      }
    },
    [7834] = {
      up = {
        exitDescription = "Through the dark ward",
        exitDest = 7833,
        exitKey = 26504,
        exitKeyword = "ward"
      }
    },
    [7837] = {
      south = {
        exitDescription = "The tree of the Faerie Mistress",
        exitDest = 7838,
        exitKey = 26501,
        exitKeyword = "ward"
      }
    },
    [7838] = {
      north = {
        exitDescription = "A grass path",
        exitDest = 7837,
        exitKey = 26501,
        exitKeyword = "ward"
      }
    },
    [7839] = {
      east = {
        exitDescription = "A grass path",
        exitDest = 7824,
        exitKey = 26502,
        exitKeyword = "ward"
      }
    },
    [7847] = {
      north = {
        exitDescription = "In the dark tunnel",
        exitDest = 7851,
        exitKey = 26505,
        exitKeyword = "ward"
      }
    },
    [7851] = {
      east = {
        exitDescription = "A dark tunnel",
        exitDest = 7853,
        exitKey = 26506,
        exitKeyword = "ward"
      },
      south = {
        exitDescription = "In the dark pit",
        exitDest = 7847,
        exitKey = 26505,
        exitKeyword = "ward"
      }
    },
    [7852] = {
      east = {
        exitDescription = "The chamber of Queen Gyrnath",
        exitDest = 7856,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "A dark tunnel",
        exitDest = 7853,
        exitKey = 26507,
        exitKeyword = "ward"
      }
    },
    [7853] = {
      north = {
        exitDescription = "The chamber of Ganymede the Vengeful",
        exitDest = 7852,
        exitKey = 26507,
        exitKeyword = "ward"
      },
      west = {
        exitDescription = "A dark tunnel",
        exitDest = 7851,
        exitKey = 26506,
        exitKeyword = "ward"
      }
    },
    [7856] = {
      west = {
        exitDescription = "The chamber of Ganymede the Vengeful",
        exitDest = 7852,
        exitKeyword = "door"
      }
    },
    [7857] = {
      south = {
        exitDescription = "A brilliant path",
        exitDest = 7789,
        exitKeyword = "door"
      }
    },
    [7873] = {
      east = {
        exitDescription = "There is a carefully carved slot in the smooth sandstone wall.",
        exitDest = 7949,
        exitKey = 26611,
        exitKeyword = "sandstone"
      }
    },
    [7949] = {
      east = {
        exitDescription = "There is a carefully molded slot in the solid copper wall.",
        exitDest = 7950,
        exitKey = 26612,
        exitKeyword = "copper"
      },
      west = {
        exitDescription = "There is a carefully carved slot in the smooth sandstone wall.",
        exitDest = 7873,
        exitKey = 26611,
        exitKeyword = "sandstone"
      }
    },
    [7950] = {
      east = {
        exitDescription = "There is a delicately carved slot in the polished granite wall.",
        exitDest = 7951,
        exitKey = 26613,
        exitKeyword = "granite"
      },
      west = {
        exitDescription = "There is a carefully molded slot in the solid copper wall.",
        exitDest = 7949,
        exitKey = 26612,
        exitKeyword = "copper"
      }
    },
    [7951] = {
      east = {
        exitDescription = "There is a delicately molded slot in the hammered iron wall.",
        exitDest = 7952,
        exitKey = 26614,
        exitKeyword = "iron"
      },
      west = {
        exitDescription = "There is a delicately carved slot in the polished granite wall.",
        exitDest = 7950,
        exitKey = 26613,
        exitKeyword = "granite"
      }
    },
    [7952] = {
      east = {
        exitDescription = "There is an intricately cut slot in the sparkling diamond wall.",
        exitDest = 7953,
        exitKey = 26615,
        exitKeyword = "diamond"
      },
      west = {
        exitDescription = "There is a delicately molded slot in the hammered iron wall.",
        exitDest = 7951,
        exitKey = 26614,
        exitKeyword = "iron"
      }
    },
    [7953] = {
      west = {
        exitDescription = "There is an intricately cut slot in the sparkling diamond wall.",
        exitDest = 7952,
        exitKey = 26615,
        exitKeyword = "diamond"
      }
    },
    [7983] = {
      north = {
        exitDescription = "Before the Tar Pit",
        exitDest = 7984,
        exitKeyword = "gate"
      }
    },
    [7984] = {
      south = {
        exitDescription = "A Locked Gate",
        exitDest = 7983,
        exitKeyword = "gate"
      }
    },
    [7992] = {
      north = {
        exitDescription = "To the north, you see the fabled Yawning Portal Inn.",
        exitDest = 8028,
        exitKeyword = "door"
      }
    },
    [8028] = {
      south = {
        exitDescription = "To the south, you can see outside the inn to the beaches beyond.",
        exitDest = 7992,
        exitKeyword = "door"
      },
      west = {
        exitDescription = "To the west, you can see a large lavish office.",
        exitDest = 8029,
        exitKeyword = "door"
      }
    },
    [8029] = {
      east = {
        exitDescription = "To the east, you see the entrance to the inn.",
        exitDest = 8028,
        exitKeyword = "door"
      }
    },
    [8034] = {
      north = {
        exitDescription = "To the north, a long hallway leads into darkness.",
        exitDest = 8085,
        exitKey = 28038,
        exitKeyword = "gate"
      }
    },
    [8053] = {
      east = {
        exitDescription = "To the east, you can see inside an old stone tower.",
        exitDest = 8054,
        exitKeyword = "door"
      }
    },
    [8054] = {
      west = {
        exitDescription = "To the west, a cobblestone path leads away from the tower.",
        exitDest = 8053,
        exitKeyword = "door"
      }
    },
    [8085] = {
      south = {
        exitDescription = "To the south you can see the etrance to the dungeons.",
        exitDest = 8034,
        exitKeyword = "golden"
      }
    },
    [8089] = {
      north = {
        exitDescription = "To the north the hall opens into a large, darkened cavern.",
        exitDest = 8090,
        exitKey = 28104,
        exitKeyword = "door"
      }
    },
    [8090] = {
      south = {
        exitDescription = "To the south is a room with a 'V' engraved on the floor.",
        exitDest = 8089,
        exitKey = 28104,
        exitKeyword = "door"
      }
    },
    [8093] = {
      east = {
        exitDescription = "To the east, a golden-red hallway continues.",
        exitDest = 8099,
        exitKey = 28108,
        exitKeyword = "door"
      }
    },
    [8095] = {
      west = {
        exitDescription = "To the west, a hallway leads through a thick cloud of mist.",
        exitDest = 8111,
        exitKey = 28109,
        exitKeyword = "door"
      }
    },
    [8097] = {
      north = {
        exitDescription = "To the north you see a golden bridge over a dark chasm.",
        exitDest = 8123,
        exitKeyword = "door"
      }
    },
    [8099] = {
      west = {
        exitDescription = "The dark, damp cavern continues to the west.",
        exitDest = 8093,
        exitKey = 28108,
        exitKeyword = "door"
      }
    },
    [8109] = {
      south = {
        exitDescription = "To the south, the golden red hallway continues.",
        exitDest = 8110,
        exitKey = 28105,
        exitKeyword = "gateway"
      }
    },
    [8110] = {
      north = {
        exitDescription = "To the north, you see a chamber burning with lurid flames.",
        exitDest = 8109,
        exitKey = 28105,
        exitKeyword = "gateway"
      }
    },
    [8111] = {
      east = {
        exitDescription = "Tha dark, damp cavern continues to the east.",
        exitDest = 8095,
        exitKey = 28106,
        exitKeyword = "door"
      }
    },
    [8112] = {
      west = {
        exitDescription = "To the west, the rancid stentch of decaying flesh is almost unbearable.",
        exitDest = 8113,
        exitKeyword = "grate"
      }
    },
    [8113] = {
      east = {
        exitDescription = "To the east, the misty hallway continues.",
        exitDest = 8112,
        exitKeyword = "grate"
      }
    },
    [8121] = {
      north = {
        exitDescription = "To the north, you see a large, roughly cut room in the mountain.",
        exitDest = 8122,
        exitKey = 28106,
        exitKeyword = "cell"
      }
    },
    [8122] = {
      south = {
        exitDescription = "To the south, the roughly cut stone tunnel leads back into the mist.",
        exitDest = 8121,
        exitKey = 28106,
        exitKeyword = "cell"
      }
    },
    [8123] = {
      south = {
        exitDescription = "The dark, damp cavern continues to the south.",
        exitDest = 8097,
        exitKeyword = "door"
      }
    },
    [8126] = {
      east = {
        exitDescription = "To the east, there is a large circular chamber.",
        exitDest = 8127,
        exitKey = 28107,
        exitKeyword = "gateway"
      }
    },
    [8127] = {
      west = {
        exitDescription = "To the west, the golden gateway leads out to the golden bridge.",
        exitDest = 8126,
        exitKey = 28107,
        exitKeyword = "gateway"
      }
    },
    [8151] = {
      east = {
        exitDescription = "To the east you can see inside the ruined castle.",
        exitDest = 8154,
        exitKeyword = "gates"
      }
    },
    [8154] = {
      west = {
        exitDescription = "To the west you can see a large drawbridge before the castle.",
        exitDest = 8151,
        exitKeyword = "gates"
      }
    },
    [8159] = {
      south = {
        exitDescription = "To the south there is a heavily barricaded door.",
        exitDest = 8160,
        exitKey = 28163,
        exitKeyword = "door"
      }
    },
    [8160] = {
      north = {
        exitDescription = "To the north the hallway continues through the castle.",
        exitDest = 8159,
        exitKey = 28163,
        exitKeyword = "door"
      }
    },
    [8163] = {
      east = {
        exitDescription = "To the east the hallway continues through the castle.",
        exitDest = 8166,
        exitKeyword = "door"
      },
      north = {
        exitDescription = "To the north the hallway continues through the castle.",
        exitDest = 8164,
        exitKeyword = "door"
      }
    },
    [8164] = {
      south = {
        exitDescription = "To the south you see a landing before some stone stairs.",
        exitDest = 8163,
        exitKeyword = "door"
      }
    },
    [8166] = {
      west = {
        exitDescription = "To the west the hallway continues through the castle.",
        exitDest = 8163,
        exitKeyword = "door"
      }
    },
    [8169] = {
      east = {
        exitDescription = "To the east you can see the second floor foyer.",
        exitDest = 8170,
        exitKey = 28162,
        exitKeyword = "door"
      }
    },
    [8170] = {
      west = {
        exitDescription = "To the west you can see what appears to be the king's living quarter.",
        exitDest = 8169,
        exitKey = 28162,
        exitKeyword = "door"
      }
    },
    [8171] = {
      south = {
        exitDescription = "To the south you can see the burned out remains of a royal bedroom.",
        exitDest = 8172,
        exitKeyword = "door"
      }
    },
    [8172] = {
      north = {
        exitDescription = "To the north the hallway continues through the castle.",
        exitDest = 8171,
        exitKeyword = "door"
      }
    },
    [8174] = {
      east = {
        exitDescription = "To the east you can see the burned out remains of a royal bedroom.",
        exitDest = 8175,
        exitKeyword = "door"
      }
    },
    [8175] = {
      west = {
        exitDescription = "To the west the hallway continues through the castle.",
        exitDest = 8174,
        exitKeyword = "door"
      }
    },
    [8187] = {
      north = {
        exitDescription = "To the north a path leads into the center of a village.",
        exitDest = 8191,
        exitKey = 28201,
        exitKeyword = "gate"
      }
    },
    [8191] = {
      south = {
        exitDescription = "To the south a path follows alongside a wooden fence.",
        exitDest = 8187,
        exitKey = 28201,
        exitKeyword = "gate"
      }
    },
    [8201] = {
      east = {
        exitDescription = "To the east you see a cluttered office.",
        exitDest = 8202,
        exitKeyword = "door"
      }
    },
    [8202] = {
      west = {
        exitDescription = "To the west you see a guard's shack.",
        exitDest = 8201,
        exitKeyword = "door"
      }
    },
    [8206] = {
      south = {
        exitDescription = "To the south you see a large wooden building.",
        exitDest = 8207,
        exitKeyword = "door"
      }
    },
    [8207] = {
      north = {
        exitDescription = "To the north you see a small pond.",
        exitDest = 8206,
        exitKeyword = "door"
      }
    },
    [8208] = {
      east = {
        exitDescription = "To the east you see a small kobold dwelling.",
        exitDest = 8210,
        exitKeyword = "door"
      },
      north = {
        exitDescription = "To the north you see a small kobold dwelling.",
        exitDest = 8211,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "To the south you see a small kobold dwelling.",
        exitDest = 8209,
        exitKeyword = "door"
      }
    },
    [8209] = {
      north = {
        exitDescription = "To the north you can see a common square in the village.",
        exitDest = 8208,
        exitKeyword = "door"
      }
    },
    [8210] = {
      west = {
        exitDescription = "To the west you can see a common square in the village.",
        exitDest = 8208,
        exitKeyword = "door"
      }
    },
    [8211] = {
      south = {
        exitDescription = "To the south you can see a common square in the village.",
        exitDest = 8208,
        exitKeyword = "door"
      }
    },
    [8217] = {
      east = {
        exitDescription = "To the east is a huge wooden building.",
        exitDest = 8218,
        exitKeyword = "door"
      }
    },
    [8218] = {
      west = {
        exitDescription = "To the west a path leads through the village.",
        exitDest = 8217,
        exitKeyword = "door"
      }
    },
    [8221] = {
      north = {
        exitDescription = "To the north you see a guest room.",
        exitDest = 8224,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "To the south you see a guest room.",
        exitDest = 8227,
        exitKeyword = "door"
      }
    },
    [8222] = {
      north = {
        exitDescription = "To the north you see a guest room.",
        exitDest = 8225,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "To the south you see a guest room.",
        exitDest = 8228,
        exitKeyword = "door"
      }
    },
    [8223] = {
      north = {
        exitDescription = "To the north you see a guest room.",
        exitDest = 8226,
        exitKeyword = "door"
      },
      south = {
        exitDescription = "To the south you see a guest room.",
        exitDest = 8229,
        exitKeyword = "door"
      }
    },
    [8224] = {
      south = {
        exitDescription = "To the south the hallway leads past the guest rooms.",
        exitDest = 8221,
        exitKeyword = "door"
      }
    },
    [8225] = {
      south = {
        exitDescription = "To the south the hallway leads past the guest rooms.",
        exitDest = 8222,
        exitKeyword = "door"
      }
    },
    [8226] = {
      south = {
        exitDescription = "To the south the hallway leads past the guest rooms.",
        exitDest = 8223,
        exitKeyword = "door"
      }
    },
    [8227] = {
      north = {
        exitDescription = "To the north the hallway leads past the guest rooms.",
        exitDest = 8221,
        exitKeyword = "door"
      }
    },
    [8228] = {
      north = {
        exitDescription = "To the north the hallway leads past the guest rooms.",
        exitDest = 8222,
        exitKeyword = "door"
      }
    },
    [8229] = {
      north = {
        exitDescription = "To the north the hallway leads past the guest rooms.",
        exitDest = 8223,
        exitKeyword = "door"
      }
    },
    [8230] = {
      north = {
        exitDescription = "To the north you see a large wooden building.",
        exitDest = 8232,
        exitKey = 28202,
        exitKeyword = "door"
      }
    },
    [8232] = {
      south = {
        exitDescription = "To the south a path leads through the village.",
        exitDest = 8230,
        exitKey = 28202,
        exitKeyword = "door"
      }
    },
    [8233] = {
      down = {
        exitDescription = "Down the crumbling stone stairs you see a dark tunnel leading into darkness.",
        exitDest = 8259,
        exitKey = 28202,
        exitKeyword = "rug"
      }
    },
    [8236] = {
      north = {
        exitDescription = "To the north you see a small wooden building.",
        exitDest = 8238,
        exitKey = 28204,
        exitKeyword = "door"
      }
    },
    [8238] = {
      south = {
        exitDescription = "To the south a path leads through the village.",
        exitDest = 8236,
        exitKey = 28204,
        exitKeyword = "door"
      }
    },
    [8248] = {
      down = {
        exitDescription = "Down the stairs you can hear the distant echoes of miners working.",
        exitDest = 8249,
        exitKey = 28203,
        exitKeyword = "door"
      }
    },
    [8249] = {
      up = {
        exitDescription = "Up the stairs you see the entrance to the kobold mines.",
        exitDest = 8248,
        exitKey = 28203,
        exitKeyword = "door"
      }
    },
    [8255] = {
      east = {
        exitDescription = "To the east you see a small wooden building in the mines.",
        exitDest = 8256,
        exitKeyword = "door"
      }
    },
    [8256] = {
      west = {
        exitDescription = "To the west the dark tunnel in the kobold mines continues.",
        exitDest = 8255,
        exitKeyword = "door"
      }
    },
    [8257] = {
      west = {
        exitDescription = "To the west you see a small wooden building in the mines.",
        exitDest = 8258,
        exitKeyword = "door"
      }
    },
    [8258] = {
      east = {
        exitDescription = "To the east the dark tunnel in the kobold mines continues.",
        exitDest = 8257,
        exitKeyword = "door"
      }
    },
    [8259] = {
      up = {
        exitDescription = "Up the crumbling stone stairs you see a candle lit workshop.",
        exitDest = 8233,
        exitKey = 28202,
        exitKeyword = "wooden"
      }
    }
  }

  local roomsWithDoors = 0
  local totalDoors = 0
  local lockedDoors = 0

  for _, doorsInRoom in pairs( doorData ) do
    local hasDoors = false
    for _, doorInfo in pairs( doorsInRoom ) do
      totalDoors = totalDoors + 1
      hasDoors = true

      if doorInfo.exitKey then
        lockedDoors = lockedDoors + 1
      end
    end
    if hasDoors then
      roomsWithDoors = roomsWithDoors + 1
    end
  end
  -- Only needed once at load/relaod
  loadAllDoors = nil
end

-- If a door exists in the direction the player is attempting to move, open it
function openDoor( dir )
  local data = doorData[CurrentRoomNumber][dir]
  if data then
    local door     = data['exitKeyword']
    local key      = data['exitKey']
    local closeDir = REVERSE[dir]
    closeCmd       = f 'close {door} {closeDir}'
    if key then
      send( f 'unlock {door} {dir}' )
    end
    send( f 'open {door} {dir}', true )
    tempTimer( 1, [[send( closeCmd, true )]] )
  end
end
