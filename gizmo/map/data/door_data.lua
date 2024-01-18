-- Data for all doors in the game indexed by room name & direction
-- doorData[id][dir] is each door;
--   state = 2 for closed, 3 for locked
--   key is the in-game obj id;
--   word interacts with the door
doorData = {
  [58] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [60] = {
    n = {
      state = 2,
      word = "door"
    },
    w = {
      key = 521,
      state = 3,
      word = "door"
    }
  },
  [61] = {
    e = {
      key = 521,
      state = 3,
      word = "door"
    }
  },
  [67] = {
    e = {
      key = 522,
      state = 3,
      word = "door"
    }
  },
  [68] = {
    w = {
      key = 522,
      state = 3,
      word = "door"
    }
  },
  [78] = {
    e = {
      key = 523,
      state = 3,
      word = "door"
    }
  },
  [79] = {
    w = {
      key = 523,
      state = 3,
      word = "door"
    }
  },
  [93] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [94] = {
    e = {
      key = 524,
      state = 3,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [95] = {
    w = {
      key = 524,
      state = 3,
      word = "cabindoor"
    }
  },
  [110] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [111] = {
    e = {
      key = 525,
      state = 3,
      word = "cabin"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [112] = {
    w = {
      key = 525,
      state = 3,
      word = "cabindoor"
    }
  },
  [133] = {
    e = {
      key = 526,
      state = 3,
      word = "cabindoor"
    }
  },
  [134] = {
    e = {
      state = 2,
      word = "door"
    },
    w = {
      key = 526,
      state = 3,
      word = "cabindoor"
    }
  },
  [135] = {
    e = {
      state = 2,
      word = "celldoor"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [214] = {
    w = {
      key = 1009,
      state = 3,
      word = "door"
    }
  },
  [245] = {
    s = {
      key = 1003,
      state = 3,
      word = "door"
    }
  },
  [282] = {
    n = {
      key = 1003,
      state = 3,
      word = "door"
    }
  },
  [319] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [320] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [333] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [343] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [344] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [346] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [457] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [461] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [464] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [465] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [477] = {
    s = {
      key = 1305,
      state = 3,
      word = "door"
    }
  },
  [478] = {
    n = {
      key = 1305,
      state = 3,
      word = "door"
    }
  },
  [555] = {
    n = {
      key = 1707,
      state = 3,
      word = "door"
    }
  },
  [559] = {
    s = {
      key = 1707,
      state = 3,
      word = "door"
    }
  },
  [569] = {
    n = {
      key = 1709,
      state = 3,
      word = "door"
    }
  },
  [582] = {
    s = {
      key = 1709,
      state = 3,
      word = "door"
    }
  },
  [623] = {
    n = {
      state = 2,
      word = "logs"
    }
  },
  [624] = {
    s = {
      state = 2,
      word = "logs"
    }
  },
  [648] = {
    n = {
      state = 2,
      word = "exit"
    }
  },
  [650] = {
    s = {
      state = 2,
      word = "exit"
    }
  },
  [654] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [657] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [667] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [668] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [674] = {
    e = {
      state = 2,
      word = "trapdoor"
    }
  },
  [678] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [682] = {
    e = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "trapdoor"
    }
  },
  [683] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [684] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [748] = {
    e = {
      key = 2026,
      state = 3,
      word = "You"
    }
  },
  [749] = {
    w = {
      key = 2026,
      state = 3,
      word = "door"
    }
  },
  [752] = {
    s = {
      key = 2027,
      state = 3,
      word = "You"
    }
  },
  [753] = {
    n = {
      key = 2027,
      state = 3,
      word = "door"
    }
  },
  [826] = {
    s = {
      key = 2115,
      state = 3,
      word = "door"
    }
  },
  [827] = {
    n = {
      key = 2115,
      state = 3,
      word = "door"
    }
  },
  [911] = {
    n = {
      key = 2501,
      state = 3,
      word = "door"
    }
  },
  [912] = {
    s = {
      key = 2501,
      state = 3,
      word = "door"
    }
  },
  [932] = {
    s = {
      key = 2601,
      state = 3,
      word = "gate"
    }
  },
  [946] = {
    n = {
      key = 2601,
      state = 3,
      word = "gate"
    }
  },
  [978] = {
    e = {
      state = 2,
      word = "oak"
    }
  },
  [982] = {
    e = {
      state = 2,
      word = "bookshelf"
    }
  },
  [983] = {
    w = {
      state = 2,
      word = "bookshelf"
    }
  },
  [984] = {
    n = {
      key = 2701,
      state = 3,
      word = "vault"
    }
  },
  [991] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [992] = {
    e = {
      state = 2,
      word = "coffin"
    }
  },
  [993] = {
    s = {
      key = 2701,
      state = 3,
      word = "vault"
    },
    w = {
      state = 2,
      word = "coffin"
    }
  },
  [1000] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [1002] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [1003] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [1004] = {
    n = {
      state = 2,
      word = "bush"
    }
  },
  [1009] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [1010] = {
    e = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [1011] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [1013] = {
    s = {
      state = 2,
      word = "bush"
    }
  },
  [1018] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [1019] = {
    e = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [1020] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [1103] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [1104] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [1105] = {
    e = {
      state = 2,
      word = "doors"
    }
  },
  [1106] = {
    w = {
      state = 2,
      word = "doors"
    }
  },
  [1217] = {
    e = {
      key = 3120,
      state = 3,
      word = "door"
    }
  },
  [1218] = {
    w = {
      key = 3120,
      state = 3,
      word = "door"
    }
  },
  [1225] = {
    e = {
      key = 3300,
      state = 3,
      word = "door"
    }
  },
  [1233] = {
    e = {
      key = 3301,
      state = 3,
      word = "door"
    }
  },
  [1236] = {
    s = {
      state = 2,
      word = "grate"
    }
  },
  [1276] = {
    w = {
      key = 3300,
      state = 3,
      word = "door"
    }
  },
  [1282] = {
    w = {
      key = 3399,
      state = 3,
      word = "teak"
    }
  },
  [1298] = {
    n = {
      state = 2,
      word = "grate"
    }
  },
  [1302] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [1303] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [1304] = {
    w = {
      key = 3411,
      state = 3,
      word = "door"
    }
  },
  [1305] = {
    n = {
      state = 2,
      word = "curtain"
    }
  },
  [1308] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [1309] = {
    n = {
      state = 2,
      word = "north"
    },
    s = {
      state = 2,
      word = "south"
    }
  },
  [1310] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [1317] = {
    s = {
      state = 2,
      word = "oak"
    },
    w = {
      key = 3410,
      state = 3,
      word = "stone"
    }
  },
  [1318] = {
    n = {
      state = 2,
      word = "oak"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [1319] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [1323] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [1324] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [1333] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [1345] = {
    e = {
      key = 3411,
      state = 3,
      word = "door"
    }
  },
  [1360] = {
    e = {
      state = 2,
      word = "secret"
    }
  },
  [1367] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [1374] = {
    n = {
      state = 2,
      word = "double"
    }
  },
  [1375] = {
    s = {
      state = 2,
      word = "double"
    }
  },
  [1378] = {
    n = {
      state = 2,
      word = "engraved"
    }
  },
  [1379] = {
    s = {
      state = 2,
      word = "engraved"
    }
  },
  [1381] = {
    e = {
      state = 2,
      word = "engraved"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [1382] = {
    w = {
      state = 2,
      word = "engraved"
    }
  },
  [1383] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [1385] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [1387] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [1390] = {
    s = {
      state = 2,
      word = "iron"
    }
  },
  [1391] = {
    e = {
      state = 2,
      word = "secret"
    },
    n = {
      state = 2,
      word = "iron"
    }
  },
  [1392] = {
    w = {
      state = 2,
      word = "secret"
    }
  },
  [1393] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [1394] = {
    e = {
      key = 1,
      state = 3,
      word = "door"
    },
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [1395] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [1396] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [1397] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [1398] = {
    w = {
      state = 2
    }
  },
  [1399] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [1400] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [1412] = {
    s = {
      state = 2,
      word = "secret"
    }
  },
  [1413] = {
    n = {
      state = 2,
      word = "secret"
    }
  },
  [1417] = {
    s = {
      state = 2,
      word = "steel"
    }
  },
  [1418] = {
    n = {
      state = 2,
      word = "steel"
    }
  },
  [1448] = {
    n = {
      state = 2,
      word = "oak"
    }
  },
  [1453] = {
    s = {
      state = 2,
      word = "oak"
    }
  },
  [1455] = {
    n = {
      key = 3702,
      state = 3,
      word = "door"
    }
  },
  [1456] = {
    s = {
      key = 3702,
      state = 3,
      word = "door"
    }
  },
  [1470] = {
    n = {
      state = 2,
      word = "locker"
    },
    s = {
      state = 2,
      word = "locker"
    }
  },
  [1471] = {
    s = {
      state = 2,
      word = "locker"
    }
  },
  [1473] = {
    n = {
      state = 2,
      word = "locker"
    }
  },
  [1639] = {
    w = {
      key = 4014,
      state = 3,
      word = "iron"
    }
  },
  [1640] = {
    w = {
      state = 2,
      word = "hidden"
    }
  },
  [1644] = {
    e = {
      state = 2,
      word = "hidden"
    }
  },
  [1646] = {
    e = {
      key = 4014,
      state = 3,
      word = "iron"
    }
  },
  [1686] = {
    s = {
      state = 2,
      word = "secret"
    }
  },
  [1687] = {
    n = {
      state = 2,
      word = "hidden"
    }
  },
  [1729] = {
    s = {
      state = 2,
      word = "shadow"
    }
  },
  [1731] = {
    n = {
      state = 2,
      word = "fire"
    }
  },
  [1744] = {
    s = {
      state = 2,
      word = "wood"
    }
  },
  [1757] = {
    s = {
      key = 4287,
      state = 3,
      word = "silver"
    }
  },
  [1775] = {
    n = {
      state = 2,
      word = "stone"
    }
  },
  [1857] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [1858] = {
    e = {
      state = 2,
      word = "desk"
    },
    n = {
      state = 2,
      word = "door"
    }
  },
  [1860] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [1862] = {
    e = {
      key = 4701,
      state = 3,
      word = "gate"
    }
  },
  [1863] = {
    e = {
      key = 4701,
      state = 3,
      word = "gate"
    }
  },
  [1866] = {
    w = {
      key = 4701,
      state = 3,
      word = "gate"
    }
  },
  [1867] = {
    w = {
      key = 4701,
      state = 3,
      word = "gate"
    }
  },
  [1874] = {
    e = {
      key = 4702,
      state = 3,
      word = "trunk"
    }
  },
  [1878] = {
    w = {
      key = 4702,
      state = 3,
      word = "trunk"
    }
  },
  [1884] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [1885] = {
    w = {
      key = 4703,
      state = 3,
      word = "door"
    }
  },
  [1886] = {
    e = {
      key = 4703,
      state = 3,
      word = "door"
    }
  },
  [1982] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [1983] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [1986] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [1987] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [1988] = {
    w = {
      state = 2,
      word = "gate"
    }
  },
  [1989] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [1990] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [1991] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [1993] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [1994] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [1995] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [1997] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [1998] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [1999] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2001] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2002] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2007] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2010] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2011] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2014] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [2015] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [2016] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [2017] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [2018] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2019] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2020] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [2024] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2025] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2026] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [2027] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [2028] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2039] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [2121] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [2129] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2141] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [2144] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2147] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2149] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2150] = {
    s = {
      state = 2,
      word = "curtain"
    }
  },
  [2151] = {
    n = {
      state = 2,
      word = "cage"
    }
  },
  [2152] = {
    s = {
      state = 2,
      word = "cage"
    }
  },
  [2155] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [2156] = {
    e = {
      state = 2,
      word = "door"
    },
    n = {
      state = 2,
      word = "curtain"
    }
  },
  [2160] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2161] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2166] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2167] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2175] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2176] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2182] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2183] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2191] = {
    e = {
      state = 2,
      word = "gate"
    }
  },
  [2198] = {
    w = {
      state = 2,
      word = "gate"
    }
  },
  [2200] = {
    e = {
      state = 2,
      word = "gate"
    }
  },
  [2209] = {
    w = {
      state = 2,
      word = "gate"
    }
  },
  [2230] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [2240] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2241] = {
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "south"
    }
  },
  [2242] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2243] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2244] = {
    n = {
      state = 2,
      word = "door"
    },
    s = {
      key = 5700,
      state = 3,
      word = "gate"
    }
  },
  [2245] = {
    n = {
      key = 5700,
      state = 3,
      word = "gate"
    }
  },
  [2286] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2287] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2407] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2409] = {
    n = {
      key = 6301,
      state = 3,
      word = "door"
    }
  },
  [2412] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [2413] = {
    s = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [2414] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2415] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [2416] = {
    n = {
      key = 6301,
      state = 3,
      word = "door"
    },
    s = {
      key = 6301,
      state = 3,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [2421] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2422] = {
    s = {
      key = 6301,
      state = 3,
      word = "door"
    }
  },
  [2440] = {
    e = {
      key = 6302,
      state = 3,
      word = "door"
    }
  },
  [2441] = {
    e = {
      key = 6302,
      state = 3,
      word = "door"
    },
    w = {
      key = 6302,
      state = 3,
      word = "door"
    }
  },
  [2442] = {
    w = {
      key = 6302,
      state = 3,
      word = "door"
    }
  },
  [2493] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2496] = {
    e = {
      state = 2,
      word = "door"
    },
    n = {
      state = 2,
      word = "door"
    }
  },
  [2497] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [2498] = {
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [2500] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2501] = {
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [2502] = {
    e = {
      state = 2,
      word = "door"
    },
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [2503] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2504] = {
    e = {
      state = 2,
      word = "door"
    },
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [2505] = {
    n = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [2506] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2507] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2530] = {
    w = {
      key = 6503,
      state = 3,
      word = "door"
    }
  },
  [2534] = {
    n = {
      key = 6503,
      state = 3,
      word = "door"
    }
  },
  [2535] = {
    s = {
      key = 6503,
      state = 3,
      word = "door"
    }
  },
  [2537] = {
    e = {
      key = 6514,
      state = 3,
      word = "door"
    }
  },
  [2538] = {
    e = {
      key = 6503,
      state = 3,
      word = "door"
    }
  },
  [2546] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2548] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2550] = {
    w = {
      key = 6514,
      state = 3,
      word = "door"
    }
  },
  [2556] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2557] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2561] = {
    e = {
      key = 6502,
      state = 3,
      word = "door"
    }
  },
  [2562] = {
    w = {
      key = 6502,
      state = 3,
      word = "door"
    }
  },
  [2565] = {
    n = {
      key = 6516,
      state = 3,
      word = "door"
    }
  },
  [2567] = {
    s = {
      key = 6516,
      state = 3,
      word = "door"
    }
  },
  [2607] = {
    e = {
      state = 2,
      word = "hedge"
    }
  },
  [2608] = {
    w = {
      state = 2
    }
  },
  [2676] = {
    e = {
      key = 6703,
      state = 3,
      word = "door"
    }
  },
  [2677] = {
    w = {
      state = 2
    }
  },
  [2700] = {
    n = {
      key = 6700,
      state = 3,
      word = "portal"
    }
  },
  [2712] = {
    n = {
      key = 6700,
      state = 3,
      word = "portal"
    },
    s = {
      key = 6700,
      state = 3,
      word = "portal"
    }
  },
  [2715] = {
    s = {
      key = 6700,
      state = 3,
      word = "portal"
    }
  },
  [2725] = {
    s = {
      key = 6701,
      state = 3,
      word = "portal"
    }
  },
  [2734] = {
    n = {
      key = 6701,
      state = 3,
      word = "portal"
    },
    s = {
      key = 6701,
      state = 3,
      word = "portal"
    }
  },
  [2737] = {
    n = {
      key = 6701,
      state = 3,
      word = "portal"
    }
  },
  [2746] = {
    n = {
      key = 6702,
      state = 3,
      word = "secret"
    }
  },
  [2753] = {
    n = {
      key = 6702,
      state = 3,
      word = "secret"
    },
    s = {
      key = 6702,
      state = 3,
      word = "secret"
    }
  },
  [2754] = {
    s = {
      key = 6702,
      state = 3,
      word = "secret"
    }
  },
  [2812] = {
    w = {
      key = 3301,
      state = 3,
      word = "door"
    }
  },
  [2819] = {
    n = {
      state = 2,
      word = "gate"
    }
  },
  [2820] = {
    e = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [2821] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [2822] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [2826] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [2833] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2854] = {
    n = {
      state = 2,
      word = "gate"
    }
  },
  [2855] = {
    s = {
      state = 2,
      word = "gate"
    }
  },
  [2859] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2860] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [2864] = {
    e = {
      state = 2,
      word = "cell"
    },
    w = {
      state = 2,
      word = "cell"
    }
  },
  [2865] = {
    e = {
      state = 2,
      word = "cell"
    },
    w = {
      state = 2,
      word = "cell"
    }
  },
  [2866] = {
    e = {
      state = 2,
      word = "cell"
    },
    w = {
      state = 2,
      word = "cell"
    }
  },
  [2868] = {
    n = {
      state = 2,
      word = "cell"
    }
  },
  [2869] = {
    n = {
      state = 2,
      word = "cell"
    },
    s = {
      state = 2,
      word = "cell"
    }
  },
  [2870] = {
    n = {
      state = 2,
      word = "cell"
    },
    s = {
      state = 2,
      word = "cell"
    }
  },
  [2871] = {
    n = {
      state = 2,
      word = "cell"
    },
    s = {
      state = 2,
      word = "cell"
    }
  },
  [2872] = {
    n = {
      state = 2,
      word = "cell"
    }
  },
  [2874] = {
    e = {
      state = 2,
      word = "cell"
    },
    w = {
      state = 2,
      word = "cell"
    }
  },
  [2875] = {
    e = {
      state = 2,
      word = "cell"
    },
    w = {
      state = 2,
      word = "cell"
    }
  },
  [2876] = {
    e = {
      state = 2,
      word = "cell"
    },
    w = {
      state = 2,
      word = "cell"
    }
  },
  [2880] = {
    e = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [2882] = {
    e = {
      state = 2,
      word = "door"
    },
    n = {
      key = 7119,
      state = 3,
      word = "secret"
    }
  },
  [2883] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [2884] = {
    s = {
      key = 7119,
      state = 3,
      word = "secret"
    }
  },
  [2885] = {
    e = {
      state = 2,
      word = "cell"
    }
  },
  [2886] = {
    w = {
      state = 2,
      word = "cell"
    }
  },
  [2887] = {
    e = {
      state = 2,
      word = "cell"
    }
  },
  [2888] = {
    w = {
      state = 2,
      word = "cell"
    }
  },
  [2889] = {
    e = {
      state = 2,
      word = "cell"
    }
  },
  [2890] = {
    w = {
      state = 2,
      word = "cell"
    }
  },
  [2891] = {
    s = {
      state = 2,
      word = "cell"
    }
  },
  [2892] = {
    s = {
      state = 2,
      word = "cell"
    }
  },
  [2893] = {
    n = {
      state = 2,
      word = "cell"
    }
  },
  [2894] = {
    s = {
      state = 2,
      word = "cell"
    }
  },
  [2895] = {
    n = {
      state = 2,
      word = "cell"
    }
  },
  [2896] = {
    s = {
      state = 2,
      word = "cell"
    }
  },
  [2897] = {
    n = {
      state = 2,
      word = "cell"
    }
  },
  [2898] = {
    s = {
      state = 2,
      word = "cell"
    }
  },
  [2899] = {
    w = {
      state = 2,
      word = "cell"
    }
  },
  [2900] = {
    e = {
      state = 2,
      word = "cell"
    }
  },
  [2901] = {
    w = {
      state = 2,
      word = "cell"
    }
  },
  [2902] = {
    e = {
      state = 2,
      word = "cell"
    }
  },
  [2903] = {
    w = {
      state = 2,
      word = "cell"
    }
  },
  [2904] = {
    e = {
      state = 2,
      word = "cell"
    }
  },
  [2911] = {
    s = {
      state = 2,
      word = "secret"
    }
  },
  [2912] = {
    n = {
      state = 2,
      word = "secret"
    }
  },
  [2922] = {
    n = {
      state = 2,
      word = "hole"
    }
  },
  [2923] = {
    s = {
      state = 2,
      word = "hole"
    }
  },
  [2927] = {
    w = {
      state = 2,
      word = "crack"
    }
  },
  [2928] = {
    e = {
      state = 2,
      word = "crack"
    }
  },
  [2937] = {
    e = {
      state = 2,
      word = "crack"
    }
  },
  [2938] = {
    w = {
      state = 2,
      word = "crack"
    }
  },
  [2942] = {
    e = {
      state = 2,
      word = "secret"
    }
  },
  [2946] = {
    w = {
      state = 2,
      word = "secret"
    }
  },
  [2953] = {
    n = {
      state = 2,
      word = "curtain"
    }
  },
  [2954] = {
    n = {
      state = 2,
      word = "gate"
    },
    s = {
      state = 2,
      word = "curtain"
    }
  },
  [2955] = {
    s = {
      state = 2,
      word = "gate"
    }
  },
  [2970] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [2975] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [3079] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [3080] = {
    n = {
      state = 2,
      word = "exit"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [3081] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [3086] = {
    w = {
      state = 2,
      word = "hidden"
    }
  },
  [3087] = {
    e = {
      state = 2,
      word = "hidden"
    }
  },
  [3109] = {
    s = {
      state = 2,
      word = "gate"
    }
  },
  [3110] = {
    e = {
      state = 2,
      word = "tarred"
    },
    n = {
      state = 2,
      word = "gate"
    },
    s = {
      state = 2,
      word = "large"
    },
    w = {
      state = 2,
      word = "tarred"
    }
  },
  [3111] = {
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [3114] = {
    e = {
      state = 2,
      word = "cell"
    },
    n = {
      state = 2,
      word = "cell"
    },
    s = {
      state = 2,
      word = "cell"
    }
  },
  [3115] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [3116] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [3117] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [3118] = {
    e = {
      state = 2,
      word = "door"
    },
    n = {
      state = 2,
      word = "door"
    }
  },
  [3119] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [3120] = {
    e = {
      state = 2,
      word = "wooden"
    },
    s = {
      state = 2,
      word = "metal"
    },
    w = {
      state = 2,
      word = "tarred"
    }
  },
  [3122] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [3124] = {
    e = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [3125] = {
    e = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [3126] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [3127] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [3128] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [3129] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [3130] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [3133] = {
    e = {
      key = 7519,
      state = 3,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [3134] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [3135] = {
    w = {
      key = 7519,
      state = 3,
      word = "door"
    }
  },
  [3202] = {
    n = {
      key = 7901,
      state = 3,
      word = "gate"
    }
  },
  [3203] = {
    e = {
      state = 2,
      word = "oak"
    },
    s = {
      key = 7901,
      state = 3,
      word = "gate"
    },
    w = {
      state = 2,
      word = "ashen"
    }
  },
  [3204] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [3205] = {
    w = {
      key = 7900,
      state = 3,
      word = "steel"
    }
  },
  [3206] = {
    e = {
      state = 2,
      word = "steel"
    },
    w = {
      state = 2,
      word = "aspen"
    }
  },
  [3207] = {
    e = {
      state = 2,
      word = "asp"
    }
  },
  [3208] = {
    e = {
      state = 2,
      word = "fridge"
    },
    n = {
      state = 2,
      word = "larder"
    }
  },
  [3209] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [3210] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [3212] = {
    e = {
      key = 7900,
      state = 3,
      word = "safe"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [3213] = {
    s = {
      state = 2,
      word = "doors"
    }
  },
  [3214] = {
    n = {
      state = 2,
      word = "doors"
    }
  },
  [3215] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [3242] = {
    n = {
      key = 8001,
      state = 3,
      word = "iron"
    }
  },
  [3243] = {
    s = {
      state = 2,
      word = "iron"
    }
  },
  [3512] = {
    n = {
      key = 8438,
      state = 3,
      word = "door"
    }
  },
  [3514] = {
    s = {
      key = 8438,
      state = 3,
      word = "prison"
    }
  },
  [3678] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [3687] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [3706] = {
    n = {
      key = 8801,
      state = 3,
      word = "door"
    }
  },
  [3707] = {
    n = {
      key = 8801,
      state = 3,
      word = "door"
    }
  },
  [3708] = {
    s = {
      key = 8801,
      state = 3,
      word = "door"
    }
  },
  [3711] = {
    n = {
      state = 2,
      word = "backdrop"
    }
  },
  [3714] = {
    s = {
      key = 8801,
      state = 3,
      word = "door"
    }
  },
  [3715] = {
    s = {
      state = 2,
      word = "backdrop"
    }
  },
  [3719] = {
    e = {
      state = 2,
      word = "wall"
    }
  },
  [3720] = {
    e = {
      state = 2,
      word = "wall"
    },
    w = {
      state = 2,
      word = "wall"
    }
  },
  [3722] = {
    n = {
      state = 2,
      word = "wall"
    }
  },
  [3725] = {
    n = {
      state = 2,
      word = "wall"
    },
    s = {
      state = 2,
      word = "wall"
    }
  },
  [3726] = {
    n = {
      state = 2,
      word = "wall"
    },
    s = {
      state = 2,
      word = "wall"
    }
  },
  [3727] = {
    s = {
      state = 2,
      word = "wall"
    }
  },
  [3728] = {
    w = {
      state = 2,
      word = "wall"
    }
  },
  [3729] = {
    w = {
      state = 2,
      word = "wall"
    }
  },
  [3730] = {
    e = {
      state = 2,
      word = "wall"
    }
  },
  [3731] = {
    s = {
      state = 2,
      word = "wall"
    },
    w = {
      key = 8803,
      state = 3,
      word = "wall"
    }
  },
  [3732] = {
    e = {
      key = 8803,
      state = 3,
      word = "wall"
    }
  },
  [3733] = {
    s = {
      state = 2,
      word = "wall"
    }
  },
  [3734] = {
    n = {
      state = 2,
      word = "wall"
    }
  },
  [3735] = {
    n = {
      state = 2,
      word = "wall"
    }
  },
  [3736] = {
    s = {
      state = 2,
      word = "wall"
    }
  },
  [3737] = {
    n = {
      state = 2,
      word = "wall"
    }
  },
  [3743] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [3744] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [3757] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [3758] = {
    n = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [3759] = {
    n = {
      key = 8909,
      state = 3,
      word = "door"
    }
  },
  [3760] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [3763] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [3764] = {
    s = {
      key = 8909,
      state = 3,
      word = "door"
    }
  },
  [3765] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [3773] = {
    e = {
      key = 8907,
      state = 3,
      word = "door"
    }
  },
  [3774] = {
    w = {
      key = 8907,
      state = 3,
      word = "door"
    }
  },
  [3775] = {
    e = {
      state = 2,
      word = "door"
    },
    n = {
      state = 2,
      word = "door"
    }
  },
  [3776] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [3780] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [3786] = {
    e = {
      key = 8914,
      state = 3,
      word = "door"
    }
  },
  [3787] = {
    w = {
      key = 8914,
      state = 3,
      word = "door"
    }
  },
  [3850] = {
    n = {
      key = 9109,
      state = 3,
      word = "gate"
    }
  },
  [3851] = {
    s = {
      key = 9109,
      state = 3,
      word = "gate"
    }
  },
  [3857] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [3858] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [3866] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [3867] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [3869] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [3870] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [3885] = {
    w = {
      state = 2,
      word = "gate"
    }
  },
  [3886] = {
    e = {
      state = 2,
      word = "gate"
    }
  },
  [3894] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [3895] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [3917] = {
    e = {
      state = 2,
      word = "gate"
    }
  },
  [3919] = {
    w = {
      state = 2,
      word = "gate"
    }
  },
  [3933] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [3934] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [4043] = {
    s = {
      key = 9518,
      state = 3,
      word = "cupboard"
    }
  },
  [4044] = {
    n = {
      state = 2,
      word = "cupboard"
    }
  },
  [4082] = {
    s = {
      key = 9632,
      state = 3,
      word = "gate"
    }
  },
  [4083] = {
    n = {
      key = 9632,
      state = 3,
      word = "gate"
    }
  },
  [4086] = {
    e = {
      state = 2,
      word = "drape"
    },
    s = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "drape"
    }
  },
  [4088] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [4090] = {
    e = {
      state = 2,
      word = "drape"
    }
  },
  [4091] = {
    w = {
      state = 2,
      word = "drape"
    }
  },
  [4103] = {
    n = {
      key = 10001,
      state = 3,
      word = "fireplace"
    }
  },
  [4131] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [4132] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [4151] = {
    s = {
      key = 10001,
      state = 3,
      word = "fireplace"
    }
  },
  [4167] = {
    n = {
      state = 2,
      word = "curtain"
    }
  },
  [4168] = {
    n = {
      state = 2,
      word = "curtain"
    },
    s = {
      state = 2,
      word = "curtain"
    }
  },
  [4169] = {
    n = {
      state = 2,
      word = "curtain"
    },
    s = {
      state = 2,
      word = "curtain"
    }
  },
  [4170] = {
    e = {
      state = 2,
      word = "curtain"
    },
    n = {
      state = 2,
      word = "curtain"
    }
  },
  [4171] = {
    e = {
      state = 2,
      word = "curtain"
    }
  },
  [4172] = {
    s = {
      state = 2,
      word = "curtain"
    }
  },
  [4173] = {
    s = {
      state = 2,
      word = "curtain"
    }
  },
  [4174] = {
    s = {
      state = 2,
      word = "curtain"
    }
  },
  [4175] = {
    s = {
      state = 2,
      word = "curtain"
    }
  },
  [4176] = {
    n = {
      state = 2,
      word = "curtain"
    }
  },
  [4177] = {
    n = {
      state = 2,
      word = "curtain"
    }
  },
  [4178] = {
    w = {
      state = 2,
      word = "curtain"
    }
  },
  [4179] = {
    w = {
      state = 2,
      word = "curtain"
    }
  },
  [4345] = {
    n = {
      state = 2,
      word = "brush"
    }
  },
  [4346] = {
    s = {
      state = 2,
      word = "brush"
    }
  },
  [4384] = {
    w = {
      key = 10701,
      state = 3,
      word = "door"
    }
  },
  [4385] = {
    e = {
      key = 10701,
      state = 3,
      word = "door"
    }
  },
  [4449] = {
    e = {
      key = 10839,
      state = 3,
      word = "secret"
    }
  },
  [4459] = {
    e = {
      key = 10832,
      state = 3,
      word = "gate"
    }
  },
  [4460] = {
    s = {
      state = 2,
      word = "secret"
    },
    w = {
      key = 10832,
      state = 3,
      word = "gate"
    }
  },
  [4467] = {
    w = {
      key = 10839,
      state = 3,
      word = "secret"
    }
  },
  [4469] = {
    e = {
      key = 10842,
      state = 3,
      word = "iron"
    }
  },
  [4470] = {
    w = {
      key = 10841,
      state = 3,
      word = "iron"
    }
  },
  [4476] = {
    n = {
      state = 2,
      word = "secret"
    }
  },
  [4479] = {
    e = {
      state = 2,
      word = "iron"
    }
  },
  [4501] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [4502] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [4503] = {
    w = {
      key = 10875,
      state = 3,
      word = "iron"
    }
  },
  [4511] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [4512] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [4513] = {
    e = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [4514] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [4515] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [4520] = {
    s = {
      key = 19893,
      state = 3,
      word = "oak"
    }
  },
  [4521] = {
    n = {
      key = 10893,
      state = 3,
      word = "oak"
    }
  },
  [4523] = {
    s = {
      key = 10896,
      state = 3,
      word = "brass"
    }
  },
  [4524] = {
    n = {
      key = 10896,
      state = 3,
      word = "brass"
    }
  },
  [4525] = {
    s = {
      key = 10898,
      state = 3,
      word = "iron"
    }
  },
  [4526] = {
    n = {
      key = 10898,
      state = 3,
      word = "iron"
    },
    s = {
      key = 10899,
      state = 3,
      word = "gate"
    }
  },
  [4527] = {
    n = {
      key = 10899,
      state = 3,
      word = "gate"
    }
  },
  [4601] = {
    w = {
      key = 10912,
      state = 3,
      word = "door"
    }
  },
  [4602] = {
    e = {
      key = 10912,
      state = 3,
      word = "door"
    }
  },
  [4619] = {
    n = {
      state = 2,
      word = "cellar"
    }
  },
  [4620] = {
    s = {
      state = 2,
      word = "cellar"
    }
  },
  [4624] = {
    w = {
      state = 2,
      word = "hidden"
    }
  },
  [4626] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [4728] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [4729] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [4730] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [4731] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [4742] = {
    n = {
      state = 2,
      word = "secret"
    }
  },
  [4744] = {
    s = {
      state = 2,
      word = "secret"
    }
  },
  [4748] = {
    w = {
      key = 11142,
      state = 3,
      word = "door"
    }
  },
  [4758] = {
    w = {
      state = 2,
      word = "wine"
    }
  },
  [4759] = {
    e = {
      state = 2,
      word = "rack"
    }
  },
  [4776] = {
    n = {
      state = 2,
      word = "cellar"
    }
  },
  [4778] = {
    s = {
      state = 2,
      word = "cellar"
    }
  },
  [4898] = {
    n = {
      state = 2,
      word = "gate"
    }
  },
  [4899] = {
    s = {
      state = 2,
      word = "gate"
    }
  },
  [4916] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [4918] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [4919] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [4920] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [4921] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [4922] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [4934] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [4938] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [4940] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [4943] = {
    e = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [4944] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [4946] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [4947] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [4948] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [4949] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [4955] = {
    e = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [4968] = {
    w = {
      key = 11512,
      state = 3,
      word = "door"
    }
  },
  [4970] = {
    e = {
      key = 11512,
      state = 3,
      word = "door"
    }
  },
  [4971] = {
    s = {
      key = 11512,
      state = 3,
      word = "door"
    }
  },
  [4979] = {
    s = {
      key = 11512,
      state = 3,
      word = "door"
    }
  },
  [4984] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [4986] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [4989] = {
    n = {
      key = 11522,
      state = 3,
      word = "door"
    }
  },
  [4990] = {
    s = {
      key = 11522,
      state = 3,
      word = "door"
    }
  },
  [4991] = {
    s = {
      key = 11551,
      state = 3,
      word = "door"
    }
  },
  [4992] = {
    n = {
      key = 11551,
      state = 3,
      word = "door"
    }
  },
  [5054] = {
    w = {
      state = 2,
      word = "stone"
    }
  },
  [5056] = {
    n = {
      key = 11620,
      state = 3,
      word = "gate"
    }
  },
  [5057] = {
    s = {
      key = 11620,
      state = 3,
      word = "gate"
    }
  },
  [5095] = {
    e = {
      state = 2,
      word = "stone"
    }
  },
  [5135] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5136] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5137] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5138] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5151] = {
    n = {
      state = 2,
      word = "lever"
    }
  },
  [5173] = {
    s = {
      state = 2,
      word = "lever"
    }
  },
  [5355] = {
    s = {
      state = 2,
      word = "mud"
    }
  },
  [5358] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5362] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5363] = {
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    },
    w = {
      key = 12013,
      state = 3,
      word = "door"
    }
  },
  [5365] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5366] = {
    e = {
      key = 12013,
      state = 3,
      word = "door"
    }
  },
  [5375] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [5378] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [5380] = {
    e = {
      key = 12014,
      state = 3,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [5393] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [5398] = {
    e = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [5403] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [5410] = {
    w = {
      key = 12014,
      state = 3,
      word = "door"
    }
  },
  [5412] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5413] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [5414] = {
    n = {
      state = 2,
      word = "mud"
    }
  },
  [5419] = {
    s = {
      state = 2,
      word = "crack"
    }
  },
  [5422] = {
    n = {
      state = 2,
      word = "crack"
    }
  },
  [5426] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5427] = {
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "secret"
    }
  },
  [5428] = {
    n = {
      state = 2,
      word = "secret"
    }
  },
  [5432] = {
    e = {
      state = 2,
      word = "riverbank"
    }
  },
  [5438] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [5439] = {
    e = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [5440] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [5453] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5454] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5459] = {
    e = {
      state = 2,
      word = "wall"
    }
  },
  [5460] = {
    s = {
      state = 2,
      word = "wall"
    }
  },
  [5461] = {
    w = {
      state = 2,
      word = "wall"
    }
  },
  [5471] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [5484] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [5494] = {
    s = {
      state = 2,
      word = "wall"
    }
  },
  [5495] = {
    n = {
      state = 2,
      word = "wall"
    }
  },
  [5508] = {
    n = {
      state = 2,
      word = "wall"
    }
  },
  [5622] = {
    n = {
      key = 12901,
      state = 3,
      word = "wooden"
    }
  },
  [5623] = {
    s = {
      key = 12901,
      state = 3,
      word = "wooden"
    }
  },
  [5632] = {
    n = {
      state = 2,
      word = "double"
    }
  },
  [5633] = {
    n = {
      state = 2,
      word = "double"
    }
  },
  [5634] = {
    s = {
      state = 2,
      word = "double"
    }
  },
  [5635] = {
    s = {
      state = 2,
      word = "double"
    }
  },
  [5654] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5658] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5662] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5663] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5672] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5673] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5674] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5675] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5677] = {
    n = {
      key = 12911,
      state = 3,
      word = "mahogany"
    }
  },
  [5678] = {
    n = {
      key = 12930,
      state = 3,
      word = "metal"
    },
    s = {
      key = 12911,
      state = 3,
      word = "mahogany"
    }
  },
  [5681] = {
    s = {
      key = 12930,
      state = 3,
      word = "metal"
    }
  },
  [5724] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5725] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5727] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5728] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5757] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5758] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5763] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5764] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5765] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5770] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5774] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5776] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5797] = {
    e = {
      state = 2,
      word = "door"
    },
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [5801] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5804] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5807] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [5808] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [5813] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5814] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5815] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5816] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5817] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5818] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5819] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [5820] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [5821] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [5876] = {
    e = {
      state = 2,
      word = "bole"
    }
  },
  [6006] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [6007] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [6011] = {
    e = {
      state = 2,
      word = "metal"
    }
  },
  [6013] = {
    w = {
      state = 2,
      word = "metal"
    }
  },
  [6024] = {
    s = {
      state = 2,
      word = "rock"
    }
  },
  [6053] = {
    n = {
      state = 2,
      word = "rock"
    }
  },
  [6056] = {
    s = {
      state = 2,
      word = "rock"
    }
  },
  [6057] = {
    n = {
      state = 2,
      word = "rock"
    }
  },
  [6068] = {
    n = {
      state = 2,
      word = "rock"
    }
  },
  [6069] = {
    s = {
      state = 2,
      word = "rock"
    }
  },
  [6074] = {
    n = {
      state = 2,
      word = "rock"
    }
  },
  [6075] = {
    s = {
      state = 2,
      word = "rock"
    }
  },
  [6090] = {
    n = {
      key = 13801,
      state = 3,
      word = "hut"
    }
  },
  [6097] = {
    s = {
      key = 13801,
      state = 3,
      word = "hut"
    }
  },
  [6114] = {
    w = {
      state = 2,
      word = "cave"
    }
  },
  [6115] = {
    e = {
      state = 2,
      word = "cave"
    }
  },
  [6136] = {
    n = {
      state = 2,
      word = "pool"
    }
  },
  [6137] = {
    s = {
      state = 2,
      word = "pool"
    }
  },
  [6142] = {
    e = {
      state = 2,
      word = "graveyard"
    }
  },
  [6154] = {
    w = {
      state = 2,
      word = "graveyard"
    }
  },
  [6157] = {
    n = {
      state = 2,
      word = "graveyard"
    }
  },
  [6158] = {
    s = {
      state = 2,
      word = "graveyard"
    }
  },
  [6251] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [6252] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [6254] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [6257] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [6258] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [6259] = {
    n = {
      state = 2,
      word = "rubble"
    }
  },
  [6260] = {
    n = {
      state = 2,
      word = "cell"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [6263] = {
    e = {
      state = 2,
      word = "rubble"
    }
  },
  [6264] = {
    w = {
      state = 2,
      word = "rubble"
    }
  },
  [6265] = {
    s = {
      state = 2,
      word = "rubble"
    }
  },
  [6266] = {
    s = {
      state = 2,
      word = "cell"
    }
  },
  [6269] = {
    e = {
      state = 2,
      word = "cage"
    }
  },
  [6270] = {
    w = {
      state = 2,
      word = "cage"
    }
  },
  [6277] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [6283] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [6289] = {
    e = {
      state = 2,
      word = "throne"
    }
  },
  [6290] = {
    w = {
      state = 2,
      word = "throne"
    }
  },
  [6308] = {
    n = {
      state = 2,
      word = "rock"
    }
  },
  [6314] = {
    s = {
      state = 2,
      word = "rock"
    }
  },
  [6315] = {
    n = {
      state = 2,
      word = "iron"
    }
  },
  [6320] = {
    s = {
      state = 2,
      word = "iron"
    }
  },
  [6327] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [6332] = {
    e = {
      state = 2,
      word = "wooden"
    }
  },
  [6333] = {
    s = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "wooden"
    }
  },
  [6347] = {
    e = {
      state = 2,
      word = "ward"
    },
    n = {
      state = 2,
      word = "ward"
    }
  },
  [6348] = {
    e = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "ward"
    }
  },
  [6350] = {
    e = {
      state = 2,
      word = "ward"
    },
    s = {
      state = 2,
      word = "ward"
    }
  },
  [6351] = {
    w = {
      state = 2,
      word = "ward"
    }
  },
  [6352] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [6353] = {
    e = {
      state = 2,
      word = "iron"
    }
  },
  [6354] = {
    w = {
      state = 2,
      word = "iron"
    }
  },
  [6355] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [6356] = {
    n = {
      state = 2,
      word = "oak"
    }
  },
  [6357] = {
    e = {
      state = 2,
      word = "snowman"
    }
  },
  [6358] = {
    w = {
      state = 2,
      word = "snowman"
    }
  },
  [6359] = {
    s = {
      state = 2,
      word = "oak"
    }
  },
  [6361] = {
    n = {
      state = 2,
      word = "grass"
    }
  },
  [6362] = {
    e = {
      state = 2,
      word = "flower"
    }
  },
  [6363] = {
    w = {
      state = 2,
      word = "flower"
    }
  },
  [6364] = {
    s = {
      state = 2,
      word = "grass"
    }
  },
  [6365] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [6366] = {
    e = {
      key = 14415,
      state = 3,
      word = "vault"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [6367] = {
    w = {
      key = 14415,
      state = 3,
      word = "vault"
    }
  },
  [6372] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [6373] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [6405] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [6406] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [6408] = {
    s = {
      state = 2,
      word = "wall"
    }
  },
  [6409] = {
    n = {
      state = 2,
      word = "wall"
    }
  },
  [6532] = {
    e = {
      state = 2,
      word = "wall"
    }
  },
  [6533] = {
    w = {
      state = 2,
      word = "wall"
    }
  },
  [6547] = {
    s = {
      key = 14602,
      state = 3,
      word = "wall"
    }
  },
  [6570] = {
    n = {
      key = 14602,
      state = 3,
      word = "wall"
    }
  },
  [6607] = {
    n = {
      key = 14603,
      state = 3,
      word = "door"
    }
  },
  [6621] = {
    s = {
      key = 14701,
      state = 3,
      word = "door"
    }
  },
  [6622] = {
    s = {
      key = 14702,
      state = 3,
      word = "door"
    }
  },
  [6623] = {
    n = {
      key = 14701,
      state = 3,
      word = "door"
    }
  },
  [6632] = {
    n = {
      key = 14702,
      state = 3,
      word = "door"
    }
  },
  [6641] = {
    s = {
      key = 14603,
      state = 3,
      word = "door"
    }
  },
  [6724] = {
    n = {
      state = 2,
      word = "gate"
    }
  },
  [6726] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [6727] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [6729] = {
    s = {
      state = 2,
      word = "gate"
    }
  },
  [6731] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [6732] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [6733] = {
    n = {
      state = 2,
      word = "double"
    }
  },
  [6735] = {
    e = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "double"
    }
  },
  [6736] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [6741] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [6742] = {
    n = {
      key = 15407,
      state = 3,
      word = "steel"
    }
  },
  [6743] = {
    e = {
      key = 15415,
      state = 3,
      word = "iron"
    },
    s = {
      key = 15407,
      state = 3,
      word = "steel"
    }
  },
  [6744] = {
    e = {
      key = 15401,
      state = 3,
      word = "wooden"
    },
    w = {
      key = 15415,
      state = 3,
      word = "iron"
    }
  },
  [6745] = {
    w = {
      key = 15401,
      state = 3,
      word = "wooden"
    }
  },
  [6746] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [6747] = {
    e = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [6748] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [6751] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [6752] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [6754] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [6755] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [6791] = {
    e = {
      key = 16625,
      state = 3,
      word = "Gateway"
    }
  },
  [6792] = {
    e = {
      state = 2,
      word = "Double"
    },
    w = {
      key = 16625,
      state = 3,
      word = "Gateway"
    }
  },
  [6793] = {
    e = {
      state = 2,
      word = "Gate"
    },
    w = {
      state = 2,
      word = "Double"
    }
  },
  [6794] = {
    w = {
      state = 2,
      word = "Gate"
    }
  },
  [6805] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [6808] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [6811] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [6817] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [6818] = {
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [6819] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [6820] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [6824] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [6825] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [6826] = {
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [6827] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [6833] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [6836] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [6839] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [6840] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [6841] = {
    e = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [6842] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [6853] = {
    s = {
      state = 2,
      word = "brush"
    }
  },
  [6858] = {
    n = {
      state = 2,
      word = "brush"
    }
  },
  [6875] = {
    e = {
      state = 2,
      word = "Tree"
    }
  },
  [6877] = {
    w = {
      state = 2,
      word = "Tree"
    }
  },
  [6889] = {
    s = {
      key = 17906,
      state = 3,
      word = "backdoor"
    }
  },
  [6891] = {
    n = {
      key = 17906,
      state = 3,
      word = "backdoor"
    }
  },
  [6907] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [6908] = {
    n = {
      state = 2,
      word = "door"
    },
    s = {
      key = 17904,
      state = 3,
      word = "bookcase"
    }
  },
  [6909] = {
    n = {
      key = 17904,
      state = 3,
      word = "bookcase"
    }
  },
  [6920] = {
    e = {
      state = 2,
      word = "double"
    }
  },
  [6921] = {
    w = {
      state = 2,
      word = "double"
    }
  },
  [6922] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [6927] = {
    e = {
      key = 18700,
      state = 3,
      word = "iron"
    }
  },
  [6928] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [6929] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [6931] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [6933] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [6934] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [6935] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [6936] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [6937] = {
    s = {
      key = 18701,
      state = 3,
      word = "door"
    }
  },
  [6940] = {
    n = {
      key = 18701,
      state = 3,
      word = "door"
    }
  },
  [6943] = {
    w = {
      key = 18700,
      state = 3,
      word = "door"
    }
  },
  [6944] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [6945] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [6946] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [6947] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [6948] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [6951] = {
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [6952] = {
    w = {
      state = 2,
      word = "double"
    }
  },
  [6953] = {
    e = {
      state = 2,
      word = "double"
    },
    n = {
      state = 2,
      word = "door"
    },
    s = {
      key = 18710,
      state = 3,
      word = "sarcophagus"
    }
  },
  [6954] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [6956] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [7006] = {
    e = {
      key = 19211,
      state = 3,
      word = "door"
    }
  },
  [7007] = {
    w = {
      key = 19211,
      state = 3,
      word = "door"
    }
  },
  [7119] = {
    s = {
      key = 20158,
      state = 3,
      word = "door"
    }
  },
  [7124] = {
    s = {
      key = 20152,
      state = 3,
      word = "door"
    }
  },
  [7125] = {
    n = {
      state = 2,
      word = "secret"
    }
  },
  [7127] = {
    n = {
      key = 20156,
      state = 3,
      word = "gate"
    }
  },
  [7128] = {
    s = {
      key = 20145,
      state = 3,
      word = "gate"
    }
  },
  [7129] = {
    n = {
      key = 20153,
      state = 3,
      word = "door"
    }
  },
  [7130] = {
    n = {
      key = 20150,
      state = 3,
      word = "door"
    }
  },
  [7132] = {
    s = {
      key = 20154,
      state = 3,
      word = "door"
    }
  },
  [7137] = {
    w = {
      key = 20151,
      state = 3,
      word = "door"
    }
  },
  [7139] = {
    s = {
      key = 20155,
      state = 3,
      word = "gate"
    }
  },
  [7148] = {
    n = {
      key = 20145,
      state = 3,
      word = "gate"
    }
  },
  [7151] = {
    s = {
      key = 20153,
      state = 3,
      word = "door"
    }
  },
  [7168] = {
    s = {
      state = 2,
      word = "secret"
    }
  },
  [7174] = {
    n = {
      key = 20152,
      state = 3,
      word = "door"
    }
  },
  [7181] = {
    n = {
      key = 20144,
      state = 3,
      word = "door"
    }
  },
  [7182] = {
    n = {
      key = 20149,
      state = 3,
      word = "door"
    }
  },
  [7183] = {
    s = {
      key = 20149,
      state = 3,
      word = "door"
    }
  },
  [7185] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [7224] = {
    n = {
      state = 2,
      word = "lever"
    }
  },
  [7226] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [7227] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [7228] = {
    e = {
      state = 2,
      word = "door"
    },
    n = {
      key = 11552,
      state = 3,
      word = "door"
    }
  },
  [7260] = {
    e = {
      state = 2,
      word = "lever"
    }
  },
  [7279] = {
    e = {
      key = 22404,
      state = 3,
      word = "stone"
    }
  },
  [7354] = {
    w = {
      key = 22404,
      state = 3,
      word = "stone"
    }
  },
  [7372] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [7379] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [7397] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [7398] = {
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [7399] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [7412] = {
    w = {
      state = 2,
      word = "Door"
    }
  },
  [7432] = {
    n = {
      state = 2,
      word = "gate"
    }
  },
  [7433] = {
    s = {
      state = 2,
      word = "gate"
    }
  },
  [7435] = {
    w = {
      key = 25050,
      state = 3,
      word = "door"
    }
  },
  [7436] = {
    e = {
      key = 25050,
      state = 3,
      word = "door"
    }
  },
  [7451] = {
    s = {
      key = 25051,
      state = 3,
      word = "door"
    }
  },
  [7452] = {
    s = {
      key = 25052,
      state = 3,
      word = "door"
    }
  },
  [7453] = {
    n = {
      key = 25052,
      state = 3,
      word = "door"
    }
  },
  [7456] = {
    e = {
      key = 25053,
      state = 3,
      word = "double"
    }
  },
  [7457] = {
    w = {
      key = 25053,
      state = 3,
      word = "double"
    }
  },
  [7459] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [7460] = {
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [7461] = {
    e = {
      key = 25054,
      state = 3,
      word = "metal"
    }
  },
  [7469] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [7470] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [7471] = {
    n = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [7472] = {
    e = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "ornate"
    }
  },
  [7473] = {
    e = {
      state = 2,
      word = "large"
    }
  },
  [7474] = {
    s = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [7475] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [7476] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [7477] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [7480] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [7481] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [7483] = {
    w = {
      state = 2,
      word = "wall"
    }
  },
  [7484] = {
    e = {
      state = 2,
      word = "wall"
    },
    s = {
      state = 2,
      word = "iron"
    }
  },
  [7485] = {
    n = {
      state = 2,
      word = "solid"
    }
  },
  [7486] = {
    e = {
      state = 2,
      word = "wall"
    }
  },
  [7487] = {
    e = {
      state = 2,
      word = "wall"
    }
  },
  [7529] = {
    n = {
      state = 2,
      word = "iron"
    }
  },
  [7530] = {
    s = {
      state = 2,
      word = "iron"
    }
  },
  [7548] = {
    n = {
      key = 25217,
      state = 3,
      word = "gate"
    }
  },
  [7552] = {
    s = {
      key = 25217,
      state = 3,
      word = "gate"
    }
  },
  [7579] = {
    n = {
      state = 2,
      word = "iron"
    }
  },
  [7580] = {
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "iron"
    }
  },
  [7587] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [7588] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [7599] = {
    s = {
      state = 2,
      word = "secret"
    }
  },
  [7600] = {
    n = {
      state = 2,
      word = "secret"
    }
  },
  [7618] = {
    n = {
      state = 2,
      word = "secret"
    }
  },
  [7619] = {
    s = {
      state = 2,
      word = "secret"
    }
  },
  [7639] = {
    n = {
      state = 2,
      word = "secret"
    }
  },
  [7640] = {
    s = {
      state = 2,
      word = "secret"
    }
  },
  [7673] = {
    n = {
      state = 2,
      word = "black"
    }
  },
  [7674] = {
    s = {
      state = 2,
      word = "black"
    }
  },
  [7701] = {
    n = {
      state = 2,
      word = "brush"
    }
  },
  [7704] = {
    s = {
      state = 2,
      word = "brush"
    }
  },
  [7783] = {
    e = {
      key = 26500,
      state = 3,
      word = "ward"
    }
  },
  [7786] = {
    s = {
      key = 26508,
      state = 3,
      word = "ward"
    },
    w = {
      key = 26500,
      state = 3,
      word = "ward"
    }
  },
  [7789] = {
    n = {
      state = 2,
      word = "secret"
    }
  },
  [7798] = {
    s = {
      state = 2,
      word = "secret"
    }
  },
  [7799] = {
    n = {
      state = 2,
      word = "secret"
    }
  },
  [7817] = {
    n = {
      key = 26508,
      state = 3,
      word = "ward"
    }
  },
  [7820] = {
    e = {
      state = 2,
      word = "secret"
    }
  },
  [7821] = {
    w = {
      state = 2,
      word = "secret"
    }
  },
  [7824] = {
    w = {
      key = 26502,
      state = 3,
      word = "ward"
    }
  },
  [7832] = {
    s = {
      key = 26503,
      state = 3,
      word = "ward"
    }
  },
  [7833] = {
    n = {
      key = 26503,
      state = 3,
      word = "ward"
    }
  },
  [7837] = {
    s = {
      key = 26501,
      state = 3,
      word = "ward"
    }
  },
  [7838] = {
    n = {
      key = 26501,
      state = 3,
      word = "ward"
    }
  },
  [7839] = {
    e = {
      key = 26502,
      state = 3,
      word = "ward"
    }
  },
  [7847] = {
    n = {
      key = 26505,
      state = 3,
      word = "ward"
    }
  },
  [7851] = {
    e = {
      key = 26506,
      state = 3,
      word = "ward"
    },
    s = {
      key = 26505,
      state = 3,
      word = "ward"
    }
  },
  [7852] = {
    e = {
      state = 2,
      word = "door"
    },
    s = {
      key = 26507,
      state = 3,
      word = "ward"
    }
  },
  [7853] = {
    n = {
      key = 26507,
      state = 3,
      word = "ward"
    },
    w = {
      key = 26506,
      state = 3,
      word = "ward"
    }
  },
  [7856] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [7857] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [7873] = {
    e = {
      key = 26611,
      state = 3,
      word = "sandstone"
    }
  },
  [7949] = {
    e = {
      key = 26612,
      state = 3,
      word = "copper"
    },
    w = {
      key = 26611,
      state = 3,
      word = "sandstone"
    }
  },
  [7950] = {
    e = {
      key = 26613,
      state = 3,
      word = "granite"
    },
    w = {
      key = 26612,
      state = 3,
      word = "copper"
    }
  },
  [7951] = {
    e = {
      key = 26614,
      state = 3,
      word = "iron"
    },
    w = {
      key = 26613,
      state = 3,
      word = "granite"
    }
  },
  [7952] = {
    e = {
      key = 26615,
      state = 3,
      word = "diamond"
    },
    w = {
      key = 26614,
      state = 3,
      word = "iron"
    }
  },
  [7953] = {
    w = {
      key = 26615,
      state = 3,
      word = "diamond"
    }
  },
  [7983] = {
    n = {
      state = 2,
      word = "gate"
    }
  },
  [7984] = {
    s = {
      state = 2,
      word = "gate"
    }
  },
  [7992] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [8028] = {
    s = {
      state = 2,
      word = "door"
    },
    w = {
      state = 2,
      word = "door"
    }
  },
  [8029] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [8034] = {
    n = {
      key = 28038,
      state = 3,
      word = "gate"
    }
  },
  [8053] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [8054] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [8085] = {
    s = {
      state = 2,
      word = "golden"
    }
  },
  [8089] = {
    n = {
      key = 28104,
      state = 3,
      word = "door"
    }
  },
  [8090] = {
    s = {
      key = 28104,
      state = 3,
      word = "door"
    }
  },
  [8093] = {
    e = {
      key = 28108,
      state = 3,
      word = "door"
    }
  },
  [8095] = {
    w = {
      key = 28109,
      state = 3,
      word = "door"
    }
  },
  [8097] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [8099] = {
    w = {
      key = 28108,
      state = 3,
      word = "door"
    }
  },
  [8109] = {
    s = {
      key = 28105,
      state = 3,
      word = "gateway"
    }
  },
  [8110] = {
    n = {
      key = 28105,
      state = 3,
      word = "gateway"
    }
  },
  [8111] = {
    e = {
      key = 28106,
      state = 3,
      word = "door"
    }
  },
  [8112] = {
    w = {
      state = 2,
      word = "grate"
    }
  },
  [8113] = {
    e = {
      state = 2,
      word = "grate"
    }
  },
  [8121] = {
    n = {
      key = 28106,
      state = 3,
      word = "cell"
    }
  },
  [8122] = {
    s = {
      key = 28106,
      state = 3,
      word = "cell"
    }
  },
  [8123] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [8126] = {
    e = {
      key = 28107,
      state = 3,
      word = "gateway"
    }
  },
  [8127] = {
    w = {
      key = 28107,
      state = 3,
      word = "gateway"
    }
  },
  [8151] = {
    e = {
      state = 2,
      word = "gates"
    }
  },
  [8154] = {
    w = {
      state = 2,
      word = "gates"
    }
  },
  [8159] = {
    s = {
      key = 28163,
      state = 3,
      word = "door"
    }
  },
  [8160] = {
    n = {
      key = 28163,
      state = 3,
      word = "door"
    }
  },
  [8163] = {
    e = {
      state = 2,
      word = "door"
    },
    n = {
      state = 2,
      word = "door"
    }
  },
  [8164] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [8166] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [8169] = {
    e = {
      key = 28162,
      state = 3,
      word = "door"
    }
  },
  [8170] = {
    w = {
      key = 28162,
      state = 3,
      word = "door"
    }
  },
  [8171] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [8172] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [8174] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [8175] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [8187] = {
    n = {
      key = 28201,
      state = 3,
      word = "gate"
    }
  },
  [8191] = {
    s = {
      key = 28201,
      state = 3,
      word = "gate"
    }
  },
  [8201] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [8202] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [8206] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [8207] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [8208] = {
    e = {
      state = 2,
      word = "door"
    },
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [8209] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [8210] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [8211] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [8217] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [8218] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [8221] = {
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [8222] = {
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [8223] = {
    n = {
      state = 2,
      word = "door"
    },
    s = {
      state = 2,
      word = "door"
    }
  },
  [8224] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [8225] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [8226] = {
    s = {
      state = 2,
      word = "door"
    }
  },
  [8227] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [8228] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [8229] = {
    n = {
      state = 2,
      word = "door"
    }
  },
  [8230] = {
    n = {
      key = 28202,
      state = 3,
      word = "door"
    }
  },
  [8232] = {
    s = {
      key = 28202,
      state = 3,
      word = "door"
    }
  },
  [8236] = {
    n = {
      key = 28204,
      state = 3,
      word = "door"
    }
  },
  [8238] = {
    s = {
      key = 28204,
      state = 3,
      word = "door"
    }
  },
  [8255] = {
    e = {
      state = 2,
      word = "door"
    }
  },
  [8256] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [8257] = {
    w = {
      state = 2,
      word = "door"
    }
  },
  [8258] = {
    e = {
      state = 2,
      word = "door"
    }
  }
}
