oldGear = {
  ["a Belt of Order (glowing)"]                      = 1,
  ["a Black Buckler"]                                = 2,
  ["a Black Onyx Ring"]                              = 2,
  ["a Demon Hair Belt(glowing)"]                     = 1,
  ["a drop of heart's blood(glowing)"]               = 1,
  ["a Flaming Bracelet"]                             = 2,
  ["a golden dwarven ring"]                          = 4,
  ["a jeweled cutlass"]                              = 1,
  ["a Long Cloth Skirt"]                             = 1,
  ["a malachite"]                                    = 3,
  ["a Mantle of Terror"]                             = 1,
  ["a pair of blackened gauntlets(humming)"]         = 1,
  ["a pair of dirty gloves"]                         = 1,
  ["a pair of silver sleeves(glowing)"]              = 1,
  ["a pair of stoned boots"]                         = 1,
  ["a pair of Zyca leg plates"]                      = 2,
  ["a Plate from Ygaddrozil"]                        = 4,
  ["a Reptilian Scaled Plate"]                       = 3,
  ["a Rune Covered Breast Plate"]                    = 1,
  ["a Serpentine Arm Coil(glowing)"]                 = 1,
  ["a shell of scaly spines"]                        = 1,
  ["a Silver Necklace"]                              = 4,
  ["a sooty vest"]                                   = 1,
  ["a spiked leather belt(glowing)"]                 = 1,
  ["a Talisman of X'ot"]                             = 2,
  ["a Tuning Key(humming)"]                          = 1,
  ["a Vampire Fang Necklace"]                        = 2,
  ["armbands of hell(humming)"]                      = 2,
  ["Boots of Harmony"]                               = 8,
  ["Boots of the Outer Planes(invisible)(humming)"]  = 2,
  ["Bracelet of Magic(glowing)"]                     = 6,
  ["Bracelet of the Outer Planes(humming)"]          = 4,
  ["cloak of the fiend"]                             = 3,
  ["Crown of Brod-Dorva"]                            = 1,
  ["Demon Horns(glowing)"]                           = 1,
  ["desecrated belt of holy symbols"]                = 1,
  ["Ettins cape(glowing)"]                           = 2,
  ["Gloves of Heroism(glowing)"]                     = 1,
  ["Lantern of the Outer Planes(glowing)"]           = 2,
  ["Oaken Greaves"]                                  = 1,
  ["Ozymar's sword(glowing)"]                        = 1,
  ["ring of the soul eater(humming)"]                = 8,
  ["small ring(glowing)"]                            = 2,
  ["Sword of Black Sun(humming)"]                    = 1,
  ["the Cloak of the Night(glowing)(humming)"]       = 1,
  ["the crown of infinite sorrow(glowing)(humming)"] = 1,
  ["the Gloves of Agony(glowing)(humming)"]          = 2,
  ["the Glowing Bracelet of Fa'n Ra(glowing)"]       = 2,
  ["the Hand of Glory(glowing)(humming)"]            = 2,
  ["the Huge Claw of Ygaddrozil(glowing)(humming)"]  = 2,
  ["the Mace of Legend"]                             = 4,
  ["the Mask of Tzeentch(humming)"]                  = 1,
  ["the Shock Whip(humming)"]                        = 1,
  ["the Tooth of Ygaddrozil"]                        = 1,
  ["Usulian Cape(humming)"]                          = 1,
}

local function printOldGear()
  for item, count in pairs( oldGear ) do
    local itemName = trimName( trim( item ) )
    cecho( f "\n<dim_grey>{count}x<reset> <dark_slate_grey>{itemName}" )
    itemQueryAppend( itemName )
  end
end

clearScreen()
printOldGear()
