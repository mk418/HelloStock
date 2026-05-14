local _, addon = ...

-- Class-group shortcuts used in `classes = ...` fields below. Items WITHOUT a
-- `classes` field show for every class (universal consumables like bandages,
-- protection pots, healing pots, etc.). When a class filter is active, only
-- items whose `classes` list contains that class are shown.
local MELEE  = { "Druid", "Hunter", "Paladin", "Rogue", "Shaman", "Warrior" }
local CASTER = { "Druid", "Mage", "Paladin", "Priest", "Shaman", "Warlock" }
local MANA   = { "Druid", "Hunter", "Mage", "Paladin", "Priest", "Shaman", "Warlock" }
local AGI    = { "Druid", "Hunter", "Rogue", "Shaman", "Warrior" }
local STR    = { "Druid", "Paladin", "Rogue", "Shaman", "Warrior" }
local TANK   = { "Druid", "Paladin", "Warrior" }

addon.ITEMS = {
  Ingredients = {
    { category = "Herbs", items = {
      { id = 13468, name = "Black Lotus", sources = {
        { kind = "herb", zone = "Azshara", levels = "45-55" },
        { kind = "herb", zone = "Un'Goro Crater", levels = "48-55" },
        { kind = "herb", zone = "Eastern Plaguelands", levels = "53-60" },
        { kind = "herb", zone = "Winterspring", levels = "53-60" },
        { kind = "herb", zone = "Western Plaguelands", levels = "51-58" },
        { kind = "herb", zone = "Scholomance", levels = "55-60" },
        { kind = "herb", zone = "Burning Steppes", levels = "50-58" },
        { kind = "herb", zone = "Silithus", levels = "55-60" },
        { kind = "herb", zone = "Felwood", levels = "48-55" },
        { kind = "mob", zone = "Feralas", levels = "40-50",
          mobs = { { name = "Mushgog", chance = 1.4 } } },
      }},
      { id = 13467, name = "Icecap", sources = {
        { kind = "herb", zone = "Winterspring", levels = "53-60" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Warpwood Guardian", chance = 0.9 }, { name = "Ironbark Protector", chance = 0.6 }, { name = "Warpwood Crusher", chance = 0.6 } } },
        { kind = "mob", zone = "Western Plaguelands", levels = "51-58",
          mobs = { { name = "Decaying Horror", chance = 1.3 } } },
        { kind = "mob", zone = "Winterspring", levels = "53-60",
          mobs = { { name = "Spellmaw", chance = 1.2 } } },
      }},
      { id = 13466, name = "Plaguebloom", sources = {
        { kind = "herb", zone = "Eastern Plaguelands", levels = "53-60" },
        { kind = "herb", zone = "Western Plaguelands", levels = "51-58" },
        { kind = "herb", zone = "Scholomance", levels = "55-60" },
        { kind = "herb", zone = "Felwood", levels = "48-55" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Fel Lash", chance = 0.4 }, { name = "Death Lash", chance = 0.3 }, { name = "Ironbark Protector", chance = 0.5 } } },
        { kind = "mob", zone = "Western Plaguelands", levels = "51-58",
          mobs = { { name = "Decaying Horror", chance = 1.5 } } },
      }},
      { id = 13465, name = "Mountain Silversage", sources = {
        { kind = "herb", zone = "Winterspring", levels = "53-60" },
        { kind = "herb", zone = "Eastern Plaguelands", levels = "53-60" },
        { kind = "herb", zone = "Azshara", levels = "45-55" },
        { kind = "herb", zone = "Felwood", levels = "48-55" },
        { kind = "herb", zone = "Zul'Gurub", levels = "60" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Death Lash", chance = 0.5 }, { name = "Fel Lash", chance = 0.4 }, { name = "Ironbark Protector", chance = 0.6 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Simone the Inconspicuous", chance = 5.3 } } },
        { kind = "mob", zone = "Feralas", levels = "40-50",
          mobs = { { name = "Mushgog", chance = 4.2 } } },
      }},
      { id = 13464, name = "Golden Sansam", sources = {
        { kind = "herb", zone = "Azshara", levels = "45-55" },
        { kind = "herb", zone = "Un'Goro Crater", levels = "48-55" },
        { kind = "herb", zone = "Eastern Plaguelands", levels = "53-60" },
        { kind = "herb", zone = "Felwood", levels = "48-55" },
        { kind = "herb", zone = "Zul'Gurub", levels = "60" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.8 }, { name = "Warpwood Tangler", chance = 0.8 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Tar Lord", chance = 0.8 }, { name = "Bloodpetal Flayer", chance = 0.5 }, { name = "Tar Lurker", chance = 0.7 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Irontree Stomper", chance = 0.9 }, { name = "Warpwood Shredder", chance = 0.5 }, { name = "Warpwood Moss Flayer", chance = 0.5 } } },
        { kind = "mob", zone = "Western Plaguelands", levels = "51-58",
          mobs = { { name = "Rotting Behemoth", chance = 1.2 }, { name = "Decaying Horror", chance = 1.1 } } },
        { kind = "mob", zone = "Silithus", levels = "55-60",
          mobs = { { name = "Nelson the Nice", chance = 2.8 } } },
        { kind = "vendor", zone = "Lhara (Elwynn Forest / Mulgore)" },
      }},
      { id = 13463, name = "Dreamfoil", sources = {
        { kind = "herb", zone = "Azshara", levels = "45-55" },
        { kind = "herb", zone = "Eastern Plaguelands", levels = "53-60" },
        { kind = "herb", zone = "Un'Goro Crater", levels = "48-55" },
        { kind = "herb", zone = "Felwood", levels = "48-55" },
        { kind = "herb", zone = "Zul'Gurub", levels = "60" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.7 }, { name = "Warpwood Tangler", chance = 1.0 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Tar Lurker", chance = 0.8 }, { name = "Tar Lord", chance = 0.8 }, { name = "Bloodpetal Flayer", chance = 0.5 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Irontree Stomper", chance = 0.9 }, { name = "Warpwood Moss Flayer", chance = 0.6 }, { name = "Warpwood Shredder", chance = 0.6 } } },
        { kind = "mob", zone = "Western Plaguelands", levels = "51-58",
          mobs = { { name = "Rotting Behemoth", chance = 1.3 }, { name = "Decaying Horror", chance = 0.8 } } },
        { kind = "mob", zone = "Eastern Plaguelands", levels = "53-60",
          mobs = { { name = "Duskwing", chance = 1.6 } } },
        { kind = "vendor", zone = "Lhara (Elwynn Forest / Mulgore)" },
      }},
      { id = 8846,  name = "Gromsblood", sources = {
        { kind = "herb", zone = "Blasted Lands", levels = "45-55" },
        { kind = "herb", zone = "Desolace", levels = "30-40" },
        { kind = "herb", zone = "Ashenvale", levels = "18-30" },
        { kind = "herb", zone = "Felwood", levels = "48-55" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.9 }, { name = "Fel Lash", chance = 0.4 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Bloodpetal Lasher", chance = 0.6 }, { name = "Tar Lurker", chance = 0.7 }, { name = "Bloodpetal Thresher", chance = 0.5 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Irontree Stomper", chance = 0.9 }, { name = "Warpwood Shredder", chance = 0.5 }, { name = "Warpwood Moss Flayer", chance = 0.5 } } },
        { kind = "mob", zone = "Tanaris", levels = "40-50",
          mobs = { { name = "Thistleshrub Dew Collector", chance = 0.6 }, { name = "Thistleshrub Rootshaper", chance = 1.5 }, { name = "Gnarled Thistleshrub", chance = 1.3 } } },
        { kind = "mob", zone = "Western Plaguelands", levels = "51-58",
          mobs = { { name = "Rotting Behemoth", chance = 1.4 }, { name = "Decaying Horror", chance = 1.5 } } },
        { kind = "vendor", zone = "Vi'el (Winterspring)" },
      }},
      { id = 8845,  name = "Ghost Mushroom", sources = {
        { kind = "herb", zone = "The Hinterlands", levels = "40-50" },
        { kind = "herb", zone = "Desolace", levels = "30-40" },
        { kind = "herb", zone = "Alterac Valley", levels = "51-60" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.8 }, { name = "Fel Lash", chance = 0.4 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Bloodpetal Thresher", chance = 0.6 }, { name = "Tar Lord", chance = 0.7 }, { name = "Bloodpetal Lasher", chance = 0.5 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Irontree Stomper", chance = 0.9 }, { name = "Warpwood Moss Flayer", chance = 0.6 }, { name = "Warpwood Shredder", chance = 0.6 } } },
        { kind = "mob", zone = "Tanaris", levels = "40-50",
          mobs = { { name = "Thistleshrub Dew Collector", chance = 0.7 }, { name = "Thistleshrub Rootshaper", chance = 1.6 }, { name = "Gnarled Thistleshrub", chance = 1.4 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Cavern Shambler", chance = 0.7 }, { name = "Spirit of Maraudos", chance = 1.9 }, { name = "Razorlash", chance = 0.4 } } },
        { kind = "vendor", zone = "Lhara (Elwynn Forest / Mulgore)" },
      }},
      { id = 8839,  name = "Blindweed", sources = {
        { kind = "herb", zone = "Swamp of Sorrows", levels = "35-45" },
        { kind = "herb", zone = "Un'Goro Crater", levels = "48-55" },
        { kind = "herb", zone = "Alterac Valley", levels = "51-60" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.8 }, { name = "Fel Lash", chance = 0.5 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Tar Lord", chance = 0.8 }, { name = "Bloodpetal Lasher", chance = 0.6 }, { name = "Bloodpetal Flayer", chance = 0.5 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Irontree Stomper", chance = 0.8 }, { name = "Warpwood Shredder", chance = 0.5 }, { name = "Warpwood Moss Flayer", chance = 0.5 } } },
        { kind = "mob", zone = "Tanaris", levels = "40-50",
          mobs = { { name = "Thistleshrub Dew Collector", chance = 0.7 }, { name = "Thistleshrub Rootshaper", chance = 1.3 }, { name = "Gnarled Thistleshrub", chance = 1.3 } } },
        { kind = "mob", zone = "Western Plaguelands", levels = "51-58",
          mobs = { { name = "Rotting Behemoth", chance = 1.3 }, { name = "Decaying Horror", chance = 1.1 } } },
      }},
      { id = 8838,  name = "Sungrass", sources = {
        { kind = "herb", zone = "Feralas", levels = "40-50" },
        { kind = "herb", zone = "Azshara", levels = "45-55" },
        { kind = "herb", zone = "The Hinterlands", levels = "40-50" },
        { kind = "herb", zone = "Felwood", levels = "48-55" },
        { kind = "herb", zone = "Zul'Gurub", levels = "60" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.8 }, { name = "Warpwood Stomper", chance = 2.0 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Bloodpetal Lasher", chance = 0.6 }, { name = "Bloodpetal Thresher", chance = 0.5 }, { name = "Tar Lurker", chance = 0.7 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Irontree Stomper", chance = 0.8 }, { name = "Warpwood Shredder", chance = 0.5 }, { name = "Warpwood Moss Flayer", chance = 0.5 } } },
        { kind = "mob", zone = "Tanaris", levels = "40-50",
          mobs = { { name = "Thistleshrub Dew Collector", chance = 0.7 }, { name = "Thistleshrub Rootshaper", chance = 1.5 }, { name = "Gnarled Thistleshrub", chance = 1.4 } } },
        { kind = "mob", zone = "Western Plaguelands", levels = "51-58",
          mobs = { { name = "Rotting Behemoth", chance = 1.3 }, { name = "Decaying Horror", chance = 1.3 }, { name = "The Husk", chance = 2.0 } } },
      }},
      { id = 8836,  name = "Arthas' Tears", sources = {
        { kind = "herb", zone = "Eastern Plaguelands", levels = "53-60" },
        { kind = "herb", zone = "Western Plaguelands", levels = "51-58" },
        { kind = "herb", zone = "Razorfen Downs", levels = "30-45" },
        { kind = "herb", zone = "Felwood", levels = "48-55" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.8 }, { name = "Warpwood Crusher", chance = 0.9 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Deeprot Stomper", chance = 1.1 }, { name = "Constrictor Vine", chance = 0.9 }, { name = "Deeprot Tangler", chance = 1.1 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Bloodpetal Thresher", chance = 0.6 }, { name = "Tar Lord", chance = 0.7 }, { name = "Bloodpetal Lasher", chance = 0.5 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Irontree Stomper", chance = 0.8 }, { name = "Warpwood Shredder", chance = 0.5 }, { name = "Warpwood Moss Flayer", chance = 0.5 } } },
        { kind = "mob", zone = "Tanaris", levels = "40-50",
          mobs = { { name = "Thistleshrub Dew Collector", chance = 0.6 }, { name = "Gnarled Thistleshrub", chance = 1.9 }, { name = "Thistleshrub Rootshaper", chance = 1.6 } } },
      }},
      { id = 8831,  name = "Purple Lotus", sources = {
        { kind = "herb", zone = "Azshara", levels = "45-55" },
        { kind = "herb", zone = "The Hinterlands", levels = "40-50" },
        { kind = "herb", zone = "Feralas", levels = "40-50" },
        { kind = "herb", zone = "Zul'Gurub", levels = "60" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.8 }, { name = "Warpwood Guardian", chance = 0.9 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Deeprot Stomper", chance = 1.1 }, { name = "Constrictor Vine", chance = 0.9 }, { name = "Deeprot Tangler", chance = 1.1 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Bloodpetal Thresher", chance = 0.6 }, { name = "Bloodpetal Lasher", chance = 0.6 }, { name = "Tar Lord", chance = 0.8 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Irontree Stomper", chance = 0.8 }, { name = "Warpwood Moss Flayer", chance = 0.5 }, { name = "Warpwood Shredder", chance = 0.5 } } },
        { kind = "mob", zone = "Tanaris", levels = "40-50",
          mobs = { { name = "Thistleshrub Dew Collector", chance = 0.6 }, { name = "Gnarled Thistleshrub", chance = 1.6 }, { name = "Thistleshrub Rootshaper", chance = 1.6 } } },
      }},
      { id = 4625,  name = "Firebloom", sources = {
        { kind = "herb", zone = "Searing Gorge", levels = "43-52" },
        { kind = "herb", zone = "Tanaris", levels = "40-50" },
        { kind = "herb", zone = "Blasted Lands", levels = "45-55" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.9 }, { name = "Warpwood Tangler", chance = 1.1 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Deeprot Tangler", chance = 1.6 }, { name = "Constrictor Vine", chance = 1.0 }, { name = "Deeprot Stomper", chance = 1.0 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Tar Lord", chance = 0.8 }, { name = "Bloodpetal Lasher", chance = 0.5 }, { name = "Bloodpetal Thresher", chance = 0.5 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Irontree Stomper", chance = 0.8 }, { name = "Warpwood Shredder", chance = 0.5 }, { name = "Warpwood Moss Flayer", chance = 0.5 } } },
        { kind = "mob", zone = "Tanaris", levels = "40-50",
          mobs = { { name = "Thistleshrub Dew Collector", chance = 0.7 }, { name = "Gnarled Thistleshrub", chance = 1.5 }, { name = "Thistleshrub Rootshaper", chance = 1.5 } } },
      }},
      { id = 3819,  name = "Wintersbite", sources = {
        { kind = "herb", zone = "Alterac Mountains", levels = "30-40" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.8 }, { name = "Fel Lash", chance = 0.4 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Deeprot Stomper", chance = 1.2 }, { name = "Constrictor Vine", chance = 0.9 }, { name = "Deeprot Tangler", chance = 1.1 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Bloodpetal Lasher", chance = 0.6 }, { name = "Tar Lurker", chance = 0.8 }, { name = "Bloodpetal Flayer", chance = 0.6 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Irontree Stomper", chance = 0.8 }, { name = "Warpwood Shredder", chance = 0.6 }, { name = "Warpwood Moss Flayer", chance = 0.6 } } },
        { kind = "mob", zone = "Tanaris", levels = "40-50",
          mobs = { { name = "Thistleshrub Dew Collector", chance = 0.6 }, { name = "Gnarled Thistleshrub", chance = 1.7 }, { name = "Thistleshrub Rootshaper", chance = 1.7 } } },
      }},
      { id = 3358,  name = "Khadgar's Whisker", sources = {
        { kind = "herb", zone = "Stranglethorn Vale", levels = "30-45" },
        { kind = "herb", zone = "Feralas", levels = "40-50" },
        { kind = "herb", zone = "Arathi Highlands", levels = "30-40" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Death Lash", chance = 1.9 }, { name = "Warpwood Treant", chance = 0.8 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Deeprot Stomper", chance = 1.1 }, { name = "Constrictor Vine", chance = 0.9 }, { name = "Deeprot Tangler", chance = 1.1 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Bloodpetal Lasher", chance = 0.6 }, { name = "Tar Lurker", chance = 0.7 }, { name = "Tar Lord", chance = 0.7 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45",
          mobs = { { name = "Kurzen Medicine Man", chance = 2.6 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Irontree Stomper", chance = 0.9 }, { name = "Warpwood Moss Flayer", chance = 0.5 }, { name = "Warpwood Shredder", chance = 0.5 } } },
        { kind = "vendor", zone = "Lhara (Elwynn Forest / Mulgore)" },
      }},
      { id = 3821,  name = "Goldthorn", sources = {
        { kind = "herb", zone = "Stranglethorn Vale", levels = "30-45" },
        { kind = "herb", zone = "Feralas", levels = "40-50" },
        { kind = "herb", zone = "Dustwallow Marsh", levels = "35-45" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.8 }, { name = "Death Lash", chance = 0.4 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Deeprot Stomper", chance = 1.1 }, { name = "Constrictor Vine", chance = 0.9 }, { name = "Deeprot Tangler", chance = 1.1 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Bloodpetal Thresher", chance = 0.5 }, { name = "Bloodpetal Flayer", chance = 0.5 }, { name = "Tar Lord", chance = 0.7 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Irontree Stomper", chance = 0.9 }, { name = "Warpwood Shredder", chance = 0.5 }, { name = "Warpwood Moss Flayer", chance = 0.5 } } },
        { kind = "mob", zone = "Tanaris", levels = "40-50",
          mobs = { { name = "Thistleshrub Dew Collector", chance = 0.7 }, { name = "Gnarled Thistleshrub", chance = 1.7 }, { name = "Thistleshrub Rootshaper", chance = 1.5 } } },
      }},
      { id = 3818,  name = "Fadeleaf", sources = {
        { kind = "herb", zone = "Dustwallow Marsh", levels = "35-45" },
        { kind = "herb", zone = "Alterac Mountains", levels = "30-40" },
        { kind = "herb", zone = "Stranglethorn Vale", levels = "30-45" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.8 }, { name = "Ironbark Protector", chance = 0.7 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45",
          mobs = { { name = "Kurzen Medicine Man", chance = 10.6 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Deeprot Stomper", chance = 1.0 }, { name = "Constrictor Vine", chance = 0.9 }, { name = "Deeprot Tangler", chance = 1.0 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Tar Lurker", chance = 0.8 }, { name = "Bloodpetal Lasher", chance = 0.5 }, { name = "Tar Lord", chance = 0.7 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Irontree Stomper", chance = 0.9 }, { name = "Warpwood Shredder", chance = 0.5 }, { name = "Warpwood Moss Flayer", chance = 0.5 } } },
      }},
      { id = 3357,  name = "Liferoot", sources = {
        { kind = "herb", zone = "Dustwallow Marsh", levels = "35-45" },
        { kind = "herb", zone = "Stranglethorn Vale", levels = "30-45" },
        { kind = "herb", zone = "Swamp of Sorrows", levels = "35-45" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.8 }, { name = "Warpwood Tangler", chance = 1.0 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45",
          mobs = { { name = "Kurzen Medicine Man", chance = 10.3 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Deeprot Stomper", chance = 1.3 }, { name = "Constrictor Vine", chance = 1.0 }, { name = "Deeprot Tangler", chance = 1.3 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Bloodpetal Lasher", chance = 0.6 }, { name = "Bloodpetal Thresher", chance = 0.5 }, { name = "Bloodpetal Flayer", chance = 0.5 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Irontree Stomper", chance = 0.9 }, { name = "Warpwood Shredder", chance = 0.6 }, { name = "Warpwood Moss Flayer", chance = 0.5 } } },
      }},
      { id = 3356,  name = "Kingsblood", sources = {
        { kind = "herb", zone = "Stranglethorn Vale", levels = "30-45" },
        { kind = "herb", zone = "Wetlands", levels = "20-30" },
        { kind = "herb", zone = "Hillsbrad Foothills", levels = "20-30" },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45",
          mobs = { { name = "Kurzen Medicine Man", chance = 2.6 } } },
        { kind = "mob", zone = "Wetlands", levels = "20-30",
          mobs = { { name = "Fen Creeper", chance = 3.9 }, { name = "Black Ooze", chance = 0.8 }, { name = "Crimson Ooze", chance = 0.9 } } },
        { kind = "mob", zone = "Stonetalon Mountains", levels = "15-30",
          mobs = { { name = "Sap Beast", chance = 1.0 }, { name = "Corrosive Sap Beast", chance = 1.2 }, { name = "Charred Ancient", chance = 3.5 } } },
        { kind = "mob", zone = "Ashenvale", levels = "18-30",
          mobs = { { name = "Shadethicket Wood Shaper", chance = 3.8 }, { name = "Shadethicket Raincaller", chance = 4.1 }, { name = "Shadethicket Moss Eater", chance = 3.9 } } },
        { kind = "mob", zone = "Gnomeregan", levels = "29-38",
          mobs = { { name = "Corrosive Lurker", chance = 0.8 }, { name = "Irradiated Slime", chance = 0.8 } } },
      }},
      { id = 3369,  name = "Grave Moss", sources = {
        { kind = "herb", zone = "Desolace", levels = "30-40" },
        { kind = "herb", zone = "Duskwood", levels = "18-30" },
        { kind = "herb", zone = "Wetlands", levels = "20-30" },
      }},
      { id = 3355,  name = "Wild Steelbloom", sources = {
        { kind = "herb", zone = "Stranglethorn Vale", levels = "30-45" },
        { kind = "herb", zone = "Stonetalon Mountains", levels = "15-30" },
        { kind = "herb", zone = "Arathi Highlands", levels = "30-40" },
      }},
      { id = 2453,  name = "Bruiseweed", sources = {
        { kind = "herb", zone = "Stonetalon Mountains", levels = "15-30" },
        { kind = "herb", zone = "Redridge Mountains", levels = "15-25" },
        { kind = "herb", zone = "Duskwood", levels = "18-30" },
        { kind = "herb", zone = "The Barrens", levels = "10-25" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.7 }, { name = "Fel Lash", chance = 0.4 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Deeprot Stomper", chance = 1.2 }, { name = "Constrictor Vine", chance = 1.0 }, { name = "Deeprot Tangler", chance = 1.1 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Bloodpetal Flayer", chance = 0.6 }, { name = "Bloodpetal Lasher", chance = 0.5 }, { name = "Tar Lurker", chance = 0.7 } } },
        { kind = "mob", zone = "Wailing Caverns", levels = "15-25",
          mobs = { { name = "Deviate Shambler", chance = 3.1 }, { name = "Deviate Lasher", chance = 0.8 }, { name = "Verdan the Everliving", chance = 1.0 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Irontree Stomper", chance = 0.9 }, { name = "Warpwood Shredder", chance = 0.7 }, { name = "Warpwood Moss Flayer", chance = 0.6 } } },
      }},
      { id = 3820,  name = "Stranglekelp", sources = {
        { kind = "herb", zone = "Stranglethorn Vale", levels = "30-45" },
        { kind = "herb", zone = "Westfall", levels = "10-20" },
        { kind = "herb", zone = "Wetlands", levels = "20-30" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.7 }, { name = "Death Lash", chance = 0.5 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Deeprot Stomper", chance = 1.1 }, { name = "Constrictor Vine", chance = 1.0 }, { name = "Deeprot Tangler", chance = 1.2 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Bloodpetal Thresher", chance = 0.6 }, { name = "Bloodpetal Lasher", chance = 0.5 }, { name = "Tar Lurker", chance = 0.7 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Irontree Stomper", chance = 0.9 }, { name = "Warpwood Moss Flayer", chance = 0.6 }, { name = "Warpwood Shredder", chance = 0.5 } } },
        { kind = "mob", zone = "Tanaris", levels = "40-50",
          mobs = { { name = "Thistleshrub Dew Collector", chance = 0.7 }, { name = "Gnarled Thistleshrub", chance = 1.6 }, { name = "Thistleshrub Rootshaper", chance = 1.4 } } },
      }},
      { id = 2450,  name = "Briarthorn", sources = {
        { kind = "herb", zone = "Redridge Mountains", levels = "15-25" },
        { kind = "herb", zone = "Duskwood", levels = "18-30" },
        { kind = "herb", zone = "Silverpine Forest", levels = "10-20" },
        { kind = "herb", zone = "The Barrens", levels = "10-25" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.8 }, { name = "Death Lash", chance = 0.4 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Constrictor Vine", chance = 1.0 }, { name = "Deeprot Stomper", chance = 1.1 }, { name = "Deeprot Tangler", chance = 1.2 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Bloodpetal Lasher", chance = 0.6 }, { name = "Tar Lurker", chance = 0.8 }, { name = "Bloodpetal Thresher", chance = 0.6 } } },
        { kind = "mob", zone = "Wailing Caverns", levels = "15-25",
          mobs = { { name = "Deviate Shambler", chance = 2.8 }, { name = "Deviate Lasher", chance = 0.8 }, { name = "Verdan the Everliving", chance = 0.8 } } },
        { kind = "mob", zone = "Wetlands", levels = "20-30",
          mobs = { { name = "Fen Creeper", chance = 4.0 }, { name = "Black Ooze", chance = 0.7 }, { name = "Fen Dweller", chance = 5.1 } } },
      }},
      { id = 2452,  name = "Swiftthistle", sources = {
        { kind = "herb", zone = "Silverpine Forest", levels = "10-20" },
        { kind = "herb", zone = "Loch Modan", levels = "10-20" },
        { kind = "herb", zone = "Westfall", levels = "10-20" },
        { kind = "herb", zone = "Redridge Mountains", levels = "15-25" },
        { kind = "herb", zone = "Duskwood", levels = "18-30" },
        { kind = "herb", zone = "The Barrens", levels = "10-25" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.7 }, { name = "Warpwood Tangler", chance = 1.1 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Deeprot Stomper", chance = 1.3 }, { name = "Constrictor Vine", chance = 1.0 }, { name = "Deeprot Tangler", chance = 1.2 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Bloodpetal Lasher", chance = 0.6 }, { name = "Tar Lurker", chance = 0.8 }, { name = "Bloodpetal Thresher", chance = 0.5 } } },
        { kind = "mob", zone = "Wailing Caverns", levels = "15-25",
          mobs = { { name = "Deviate Shambler", chance = 2.6 }, { name = "Deviate Lasher", chance = 0.7 }, { name = "Verdan the Everliving", chance = 1.0 } } },
        { kind = "mob", zone = "Wetlands", levels = "20-30",
          mobs = { { name = "Fen Creeper", chance = 4.1 }, { name = "Black Ooze", chance = 0.7 }, { name = "Monstrous Ooze", chance = 1.1 } } },
      }},
      { id = 785,   name = "Mageroyal", sources = {
        { kind = "herb", zone = "Silverpine Forest", levels = "10-20" },
        { kind = "herb", zone = "Loch Modan", levels = "10-20" },
        { kind = "herb", zone = "Westfall", levels = "10-20" },
        { kind = "herb", zone = "The Barrens", levels = "10-25" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 0.8 }, { name = "Death Lash", chance = 0.4 } } },
        { kind = "mob", zone = "Teldrassil", levels = "1-10",
          mobs = { { name = "Timberling", chance = 3.9 }, { name = "Timberling Trampler", chance = 4.5 }, { name = "Elder Timberling", chance = 4.6 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Constrictor Vine", chance = 1.0 }, { name = "Deeprot Stomper", chance = 1.1 }, { name = "Deeprot Tangler", chance = 1.2 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Bloodpetal Thresher", chance = 0.6 }, { name = "Bloodpetal Lasher", chance = 0.5 }, { name = "Tar Lurker", chance = 0.7 } } },
        { kind = "mob", zone = "Wailing Caverns", levels = "15-25",
          mobs = { { name = "Deviate Shambler", chance = 2.9 }, { name = "Deviate Lasher", chance = 0.8 }, { name = "Verdan the Everliving", chance = 1.0 } } },
      }},
      { id = 2449,  name = "Earthroot", sources = {
        { kind = "herb", zone = "Tirisfal Glades", levels = "1-10" },
        { kind = "herb", zone = "Teldrassil", levels = "1-10" },
        { kind = "herb", zone = "Dun Morogh", levels = "1-10" },
        { kind = "herb", zone = "The Barrens", levels = "10-25" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 1.0 }, { name = "Death Lash", chance = 0.6 } } },
        { kind = "mob", zone = "Teldrassil", levels = "1-10",
          mobs = { { name = "Timberling", chance = 3.8 }, { name = "Timberling Trampler", chance = 4.3 }, { name = "Timberling Mire Beast", chance = 3.7 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Deeprot Stomper", chance = 1.2 }, { name = "Constrictor Vine", chance = 0.9 }, { name = "Deeprot Tangler", chance = 1.1 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Bloodpetal Lasher", chance = 0.6 }, { name = "Bloodpetal Thresher", chance = 0.6 }, { name = "Tar Lord", chance = 0.7 } } },
        { kind = "mob", zone = "Wailing Caverns", levels = "15-25",
          mobs = { { name = "Deviate Shambler", chance = 2.7 }, { name = "Deviate Lasher", chance = 0.9 }, { name = "Verdan the Everliving", chance = 1.2 } } },
      }},
      { id = 765,   name = "Silverleaf", sources = {
        { kind = "herb", zone = "Tirisfal Glades", levels = "1-10" },
        { kind = "herb", zone = "Elwynn Forest", levels = "1-10" },
        { kind = "herb", zone = "Teldrassil", levels = "1-10" },
        { kind = "herb", zone = "The Barrens", levels = "10-25" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Warpwood Treant", chance = 1.1 }, { name = "Fel Lash", chance = 0.5 } } },
        { kind = "mob", zone = "Teldrassil", levels = "1-10",
          mobs = { { name = "Timberling", chance = 3.8 }, { name = "Timberling Trampler", chance = 4.7 }, { name = "Elder Timberling", chance = 4.4 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Deeprot Stomper", chance = 1.3 }, { name = "Constrictor Vine", chance = 1.0 }, { name = "Deeprot Tangler", chance = 1.2 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Bloodpetal Thresher", chance = 0.5 }, { name = "Tar Lurker", chance = 0.8 }, { name = "Bloodpetal Lasher", chance = 0.5 } } },
        { kind = "mob", zone = "Wailing Caverns", levels = "15-25",
          mobs = { { name = "Deviate Shambler", chance = 2.9 }, { name = "Deviate Lasher", chance = 0.8 }, { name = "Verdan the Everliving", chance = 1.1 } } },
        { kind = "vendor", zone = "Maria Lumere (Stormwind City)" },
        { kind = "vendor", zone = "Hula'mahi (The Barrens)" },
        { kind = "vendor", zone = "Selina Weston (Tirisfal Glades)" },
      }},
      { id = 2447,  name = "Peacebloom", sources = {
        { kind = "herb", zone = "Durotar", levels = "1-10" },
        { kind = "herb", zone = "Tirisfal Glades", levels = "1-10" },
        { kind = "herb", zone = "Teldrassil", levels = "1-10" },
        { kind = "herb", zone = "The Barrens", levels = "10-25" },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.4 }, { name = "Death Lash", chance = 1.4 }, { name = "Warpwood Treant", chance = 0.8 } } },
        { kind = "mob", zone = "Teldrassil", levels = "1-10",
          mobs = { { name = "Timberling", chance = 4.0 }, { name = "Timberling Trampler", chance = 4.5 }, { name = "Elder Timberling", chance = 4.8 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Deeprot Stomper", chance = 1.2 }, { name = "Constrictor Vine", chance = 0.9 }, { name = "Deeprot Tangler", chance = 1.2 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Bloodpetal Lasher", chance = 0.6 }, { name = "Tar Lord", chance = 0.8 }, { name = "Bloodpetal Thresher", chance = 0.5 } } },
        { kind = "mob", zone = "Wailing Caverns", levels = "15-25",
          mobs = { { name = "Deviate Shambler", chance = 2.9 }, { name = "Deviate Lasher", chance = 0.7 }, { name = "Verdan the Everliving", chance = 0.9 } } },
        { kind = "vendor", zone = "Maria Lumere (Stormwind City)" },
        { kind = "vendor", zone = "Hula'mahi (The Barrens)" },
        { kind = "vendor", zone = "Selina Weston (Tirisfal Glades)" },
      }},
    }},
    { category = "Ores & Bars", items = {
      { id = 12360, name = "Arcanite Bar", recipe = {
        -- Alchemy transmute (4-day cooldown). One cast yields one bar.
        { id = 12363, count = 1 },  -- Arcane Crystal
        { id = 12359, count = 1 },  -- Thorium Bar
      } },
      { id = 12363, name = "Arcane Crystal", sources = {
        -- Roughly 1/8 chance from a Rich Thorium Vein.
        { kind = "mine", zone = "Silithus",            levels = "55-60" },
        { kind = "mine", zone = "Winterspring",        levels = "53-60" },
        { kind = "mine", zone = "Un'Goro Crater",      levels = "48-55" },
        { kind = "mine", zone = "Eastern Plaguelands", levels = "53-60" },
        { kind = "mine", zone = "Burning Steppes",     levels = "50-58" },
      }},
      { id = 12655, name = "Enchanted Thorium Bar", recipe = {
        -- Enchanting recipe (Recipe: Enchanted Thorium Bar, Felwood vendor).
        { id = 12359, count = 1 },  -- Thorium Bar
        { id = 16202, count = 1 },  -- Lesser Eternal Essence
      } },
      { id = 11371, name = "Dark Iron Bar", recipe = {
        -- Smelt Dark Iron requires the Dark Iron Forge in BRD; one bar
        -- costs 8 ore (only smelt recipe in classic where the ratio
        -- isn't 1:1).
        { id = 11370, count = 8 },  -- Dark Iron Ore
      } },
      { id = 11370, name = "Dark Iron Ore", sources = {
        { kind = "mob", zone = "Blackrock Mountain", levels = "50-60",
          mobs = { { name = "Warbringer Construct", chance = 17.0 }, { name = "Ragereaver Golem", chance = 16.1 }, { name = "Wrath Hammer Construct", chance = 15.6 } } },
      }},
      { id = 12359, name = "Thorium Bar", recipe = {
        { id = 10620, count = 1 },  -- Thorium Ore
      } },
      { id = 10620, name = "Thorium Ore", sources = {
        { kind = "mob", zone = "Burning Steppes", levels = "50-58",
          mobs = { { name = "Franklin the Friendly", chance = 9.0 } } },
        { kind = "mob", zone = "Blasted Lands", levels = "45-55",
          mobs = { { name = "Doomguard Commander", chance = 0.8 }, { name = "Teremus the Devourer", chance = 0.8 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Baron Charr", chance = 1.1 } } },
      }},
      { id = 6037,  name = "Truesilver Bar", recipe = {
        { id = 7911,  count = 1 },  -- Truesilver Ore
      } },
      { id = 7911,  name = "Truesilver Ore", sources = {
        { kind = "mine", zone = "Un'Goro Crater",   levels = "48-55" },
        { kind = "mine", zone = "Burning Steppes",  levels = "50-58" },
        { kind = "mine", zone = "Western Plaguelands", levels = "51-58" },
        { kind = "mine", zone = "Felwood",          levels = "48-55" },
        { kind = "mine", zone = "Searing Gorge",    levels = "43-52" },
      }},
      { id = 3860,  name = "Mithril Bar", recipe = {
        { id = 3858,  count = 1 },  -- Mithril Ore
      } },
      { id = 3858,  name = "Mithril Ore", sources = {
        { kind = "mob", zone = "Desolace", levels = "30-40",
          mobs = { { name = "Spirit of Kolk", chance = 3.7 } } },
        { kind = "mob", zone = "Burning Steppes", levels = "50-58",
          mobs = { { name = "Franklin the Friendly", chance = 2.5 } } },
        { kind = "mob", zone = "Blasted Lands", levels = "45-55",
          mobs = { { name = "Teremus the Devourer", chance = 2.3 } } },
        { kind = "mob", zone = "Eastern Plaguelands", levels = "53-60",
          mobs = { { name = "Nathanos Blightcaller", chance = 1.4 } } },
      }},
      { id = 3577,  name = "Gold Bar", recipe = {
        { id = 2776,  count = 1 },  -- Gold Ore
      } },
      { id = 2776,  name = "Gold Ore", sources = {
        { kind = "mob", zone = "Desolace", levels = "30-40",
          mobs = { { name = "Spirit of Kolk", chance = 1.5 } } },
      }},
      { id = 3575,  name = "Iron Bar", recipe = {
        { id = 2772,  count = 1 },  -- Iron Ore
      } },
      { id = 2772,  name = "Iron Ore", sources = {
        { kind = "mob", zone = "Badlands", levels = "35-45",
          mobs = { { name = "Shadowforge Digger", chance = 1.0 }, { name = "Shadowforge Surveyor", chance = 1.1 }, { name = "Zaricotl", chance = 1.1 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45",
          mobs = { { name = "Venture Co. Strip Miner", chance = 1.0 }, { name = "Venture Co. Miner", chance = 1.1 } } },
        { kind = "mob", zone = "Hillsbrad Foothills", levels = "20-30",
          mobs = { { name = "Hillsbrad Miner", chance = 1.3 }, { name = "Miner Hackett", chance = 1.3 } } },
        { kind = "mob", zone = "The Deadmines", levels = "15-25",
          mobs = { { name = "Defias Miner", chance = 0.2 }, { name = "Defias Strip Miner", chance = 0.3 } } },
        { kind = "mob", zone = "Westfall", levels = "10-20",
          mobs = { { name = "Defias Digger", chance = 0.7 } } },
      }},
      { id = 2841,  name = "Bronze Bar", recipe = {
        -- Bronze is the only smelt that consumes bars (not ore): one
        -- copper + one tin produces one bronze.
        { id = 2840,  count = 1 },  -- Copper Bar
        { id = 3576,  count = 1 },  -- Tin Bar
      } },
      { id = 3576,  name = "Tin Bar", recipe = {
        { id = 2771,  count = 1 },  -- Tin Ore
      } },
      { id = 2771,  name = "Tin Ore", sources = {
        { kind = "mob", zone = "The Deadmines", levels = "15-25",
          mobs = { { name = "Defias Miner", chance = 1.3 }, { name = "Defias Strip Miner", chance = 1.3 }, { name = "Miner Johnson", chance = 0.2 } } },
        { kind = "mob", zone = "Westfall", levels = "10-20",
          mobs = { { name = "Defias Digger", chance = 3.7 }, { name = "Kobold Digger", chance = 2.0 }, { name = "Riverpaw Miner", chance = 1.0 } } },
        { kind = "mob", zone = "Badlands", levels = "35-45",
          mobs = { { name = "Shadowforge Digger", chance = 1.1 }, { name = "Shadowforge Surveyor", chance = 1.0 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45",
          mobs = { { name = "Venture Co. Strip Miner", chance = 0.9 }, { name = "Venture Co. Miner", chance = 1.1 } } },
        { kind = "mob", zone = "Hillsbrad Foothills", levels = "20-30",
          mobs = { { name = "Hillsbrad Miner", chance = 1.4 }, { name = "Miner Hackett", chance = 0.9 } } },
      }},
      { id = 2840,  name = "Copper Bar", recipe = {
        { id = 2770,  count = 1 },  -- Copper Ore
      } },
      { id = 2770,  name = "Copper Ore", sources = {
        { kind = "mob", zone = "Elwynn Forest", levels = "1-10",
          mobs = { { name = "Kobold Tunneler", chance = 3.2 }, { name = "Kobold Miner", chance = 2.1 }, { name = "Goldtooth", chance = 2.3 } } },
        { kind = "mob", zone = "The Deadmines", levels = "15-25",
          mobs = { { name = "Defias Miner", chance = 1.0 }, { name = "Defias Strip Miner", chance = 1.0 }, { name = "Miner Johnson", chance = 1.8 } } },
        { kind = "mob", zone = "Mulgore", levels = "1-10",
          mobs = { { name = "Venture Co. Worker", chance = 4.4 }, { name = "Bael'dun Digger", chance = 3.3 }, { name = "Venture Co. Laborer", chance = 4.6 } } },
        { kind = "mob", zone = "Westfall", levels = "10-20",
          mobs = { { name = "Defias Digger", chance = 2.8 }, { name = "Kobold Digger", chance = 2.2 }, { name = "Riverpaw Miner", chance = 1.2 } } },
        { kind = "mob", zone = "Dun Morogh", levels = "1-10",
          mobs = { { name = "Grik'nir the Cold", chance = 4.4 } } },
      }},
    }},
    { category = "Stones", items = {
      { id = 12365, name = "Dense Stone", sources = {
        { kind = "mob", zone = "Burning Steppes", levels = "50-58",
          mobs = { { name = "Franklin the Friendly", chance = 2.5 } } },
        { kind = "mob", zone = "Blasted Lands", levels = "45-55",
          mobs = { { name = "Lady Sevine", chance = 1.1 }, { name = "Teremus the Devourer", chance = 0.8 } } },
        { kind = "mob", zone = "Winterspring", levels = "53-60",
          mobs = { { name = "Manaclaw", chance = 0.7 }, { name = "Princess Tempestria", chance = 0.6 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Baron Charr", chance = 1.1 } } },
      }},
      { id = 7912,  name = "Solid Stone", sources = {
        { kind = "mob", zone = "Badlands", levels = "35-45",
          mobs = { { name = "Rock Elemental", chance = 24.2 }, { name = "Lesser Rock Elemental", chance = 22.4 }, { name = "Greater Rock Elemental", chance = 26.6 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Theradrim Shardling", chance = 26.3 }, { name = "Theradrim Guardian", chance = 26.2 }, { name = "Primordial Behemoth", chance = 38.8 } } },
        { kind = "mob", zone = "Silithus", levels = "55-60",
          mobs = { { name = "Desert Rumbler", chance = 29.6 }, { name = "Desert Rager", chance = 30.1 }, { name = "Setis", chance = 23.5 } } },
        { kind = "mob", zone = "Searing Gorge", levels = "43-52",
          mobs = { { name = "Heavy War Golem", chance = 42.8 }, { name = "Tempered War Golem", chance = 43.2 }, { name = "Obsidion", chance = 15.7 } } },
        { kind = "mob", zone = "Arathi Highlands", levels = "30-40",
          mobs = { { name = "Rumbling Exile", chance = 23.2 }, { name = "Fozruk", chance = 16.2 }, { name = "Thenan", chance = 44.3 } } },
      }},
      { id = 2838,  name = "Heavy Stone", sources = {
        { kind = "mob", zone = "Alterac Mountains", levels = "30-40",
          mobs = { { name = "Elemental Slave", chance = 28.5 } } },
        { kind = "mob", zone = "The Deadmines", levels = "15-25",
          mobs = { { name = "Defias Miner", chance = 1.2 }, { name = "Defias Strip Miner", chance = 1.4 }, { name = "Miner Johnson", chance = 0.6 } } },
        { kind = "mob", zone = "Thousand Needles", levels = "25-35",
          mobs = { { name = "Thundering Boulderkin", chance = 25.6 }, { name = "Rok'Alim the Pounder", chance = 17.1 }, { name = "Gravelsnout Digger", chance = 1.4 } } },
        { kind = "mob", zone = "Westfall", levels = "10-20",
          mobs = { { name = "Defias Digger", chance = 3.7 } } },
        { kind = "mob", zone = "Badlands", levels = "35-45",
          mobs = { { name = "Shadowforge Digger", chance = 1.1 }, { name = "Shadowforge Surveyor", chance = 1.0 } } },
      }},
      { id = 2836,  name = "Coarse Stone", sources = {
        { kind = "mob", zone = "Ragefire Chasm", levels = "13-18",
          mobs = { { name = "Molten Elemental", chance = 21.2 } } },
        { kind = "mob", zone = "Darkshore", levels = "10-20",
          mobs = { { name = "Cracked Golem", chance = 43.8 }, { name = "Stone Behemoth", chance = 45.0 } } },
        { kind = "mob", zone = "The Deadmines", levels = "15-25",
          mobs = { { name = "Defias Miner", chance = 1.2 }, { name = "Defias Strip Miner", chance = 1.3 }, { name = "Miner Johnson", chance = 2.1 } } },
        { kind = "mob", zone = "Westfall", levels = "10-20",
          mobs = { { name = "Defias Digger", chance = 3.6 }, { name = "Kobold Digger", chance = 2.2 }, { name = "Riverpaw Miner", chance = 1.2 } } },
        { kind = "mob", zone = "Stonetalon Mountains", levels = "15-30",
          mobs = { { name = "Furious Stone Spirit", chance = 36.4 }, { name = "Enraged Stone Spirit", chance = 34.6 } } },
      }},
      { id = 2835,  name = "Rough Stone", sources = {
        { kind = "mob", zone = "Elwynn Forest", levels = "1-10",
          mobs = { { name = "Kobold Tunneler", chance = 3.2 }, { name = "Kobold Miner", chance = 2.2 }, { name = "Goldtooth", chance = 2.4 } } },
        { kind = "mob", zone = "Mulgore", levels = "1-10",
          mobs = { { name = "Venture Co. Worker", chance = 4.5 }, { name = "Bael'dun Digger", chance = 3.3 }, { name = "Venture Co. Laborer", chance = 4.5 } } },
        { kind = "mob", zone = "Westfall", levels = "10-20",
          mobs = { { name = "Kobold Digger", chance = 2.1 }, { name = "Riverpaw Miner", chance = 1.4 } } },
        { kind = "mob", zone = "Silverpine Forest", levels = "10-20",
          mobs = { { name = "Dalaran Miner", chance = 2.2 } } },
      }},
    }},
    { category = "Leather & Hides", items = {
      { id = 8170,  name = "Rugged Leather", sources = {
        { kind = "mob", zone = "Blackrock Spire", levels = "55-60",
          mobs = { { name = "Chromatic Whelp", chance = 4.1 }, { name = "Chromatic Dragonspawn", chance = 2.7 }, { name = "Gizrul the Slavener", chance = 4.7 } } },
        { kind = "mob", zone = "Zul'Gurub", levels = "60",
          mobs = { { name = "Zulian Crocolisk", chance = 0.3 }, { name = "Bloodseeker Bat", chance = 1.0 }, { name = "Razzashi Adder", chance = 0.4 } } },
        { kind = "mob", zone = "Winterspring", levels = "53-60",
          mobs = { { name = "Ice Thistle Yeti", chance = 0.2 }, { name = "Cobalt Scalebane", chance = 0.8 }, { name = "Cobalt Broodling", chance = 1.5 } } },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Gordok Mastiff", chance = 0.6 }, { name = "Guard Slip'kik", chance = 4.1 }, { name = "Immol'thar", chance = 1.4 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Rotgrip", chance = 5.3 } } },
        { kind = "vendor", zone = "Lhara (Elwynn Forest / Mulgore)" },
      }},
      { id = 8171,  name = "Rugged Hide", sources = {
        { kind = "mob", zone = "Zul'Gurub", levels = "60",
          mobs = { { name = "Razzashi Serpent", chance = 1.4 }, { name = "Razzashi Cobra", chance = 5.6 } } },
        { kind = "mob", zone = "Blackrock Spire", levels = "55-60",
          mobs = { { name = "Chromatic Whelp", chance = 0.3 }, { name = "Chromatic Dragonspawn", chance = 0.4 }, { name = "Rage Talon Dragon Guard", chance = 0.2 } } },
        { kind = "mob", zone = "Burning Steppes", levels = "50-58",
          mobs = { { name = "Black Dragonspawn", chance = 1.7 }, { name = "Black Wyrmkin", chance = 1.3 }, { name = "Flamescale Wyrmkin", chance = 1.6 } } },
        { kind = "mob", zone = "Winterspring", levels = "53-60",
          mobs = { { name = "Cobalt Mageweaver", chance = 1.1 }, { name = "Cobalt Scalebane", chance = 1.1 }, { name = "Frostsaber Huntress", chance = 0.05 } } },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Guard Slip'kik", chance = 1.1 } } },
      }},
      { id = 4304,  name = "Thick Leather", sources = {
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Rotgrip", chance = 14.9 }, { name = "Subterranean Diemetradon", chance = 0.9 } } },
        { kind = "mob", zone = "Blackrock Mountain", levels = "50-60",
          mobs = { { name = "Bloodhound", chance = 0.5 }, { name = "Dark Screecher", chance = 0.6 }, { name = "Burrowing Thundersnout", chance = 0.5 } } },
        { kind = "mob", zone = "Maraudon", levels = "40-50",
          mobs = { { name = "Nightmare Whelp", chance = 4.3 }, { name = "Hazzas", chance = 5.4 }, { name = "Nightmare Wyrmkin", chance = 2.5 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45",
          mobs = { { name = "Elder Saltwater Crocolisk", chance = 5.5 }, { name = "Enraged Silverback Gorilla", chance = 1.3 }, { name = "Tethis", chance = 2.4 } } },
        { kind = "mob", zone = "Feralas", levels = "40-50",
          mobs = { { name = "Ferocious Rage Scar", chance = 0.4 }, { name = "Feral Scar Yeti", chance = 0.3 }, { name = "Rage Scar Yeti", chance = 0.5 } } },
        { kind = "vendor", zone = "Lhara (Elwynn Forest / Mulgore)" },
      }},
      { id = 8169,  name = "Thick Hide", sources = {
        { kind = "mob", zone = "Maraudon", levels = "40-50",
          mobs = { { name = "Hazzas", chance = 2.3 }, { name = "Weaver", chance = 2.4 }, { name = "Dreamscythe", chance = 2.4 } } },
        { kind = "mob", zone = "Blackrock Mountain", levels = "50-60",
          mobs = { { name = "Bloodhound", chance = 0.04 }, { name = "Burrowing Thundersnout", chance = 0.08 }, { name = "Dark Screecher", chance = 0.03 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Subterranean Diemetradon", chance = 0.08 }, { name = "Thessala Hydra", chance = 0.04 } } },
        { kind = "mob", zone = "Blackrock Spire", levels = "55-60",
          mobs = { { name = "Spire Scorpid", chance = 0.1 }, { name = "Bloodaxe Worg Pup", chance = 0.1 }, { name = "Scarshield Worg", chance = 0.02 } } },
        { kind = "mob", zone = "Feralas", levels = "40-50",
          mobs = { { name = "Feral Scar Yeti", chance = 0.02 }, { name = "Ferocious Rage Scar", chance = 0.03 }, { name = "Enraged Feral Scar", chance = 0.03 } } },
      }},
      { id = 4234,  name = "Heavy Leather", sources = {
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45",
          mobs = { { name = "Jungle Stalker", chance = 0.2 }, { name = "Elder Mistvale Gorilla", chance = 0.2 }, { name = "Enraged Silverback Gorilla", chance = 1.0 } } },
        { kind = "mob", zone = "Uldaman", levels = "35-45",
          mobs = { { name = "Cleft Scorpid", chance = 0.8 }, { name = "Shrike Bat", chance = 0.6 }, { name = "Deadly Cleft Scorpid", chance = 0.4 } } },
        { kind = "mob", zone = "Dustwallow Marsh", levels = "35-45",
          mobs = { { name = "Bloodfen Lashtail", chance = 0.3 }, { name = "Bloodfen Screecher", chance = 0.2 }, { name = "Mudrock Tortoise", chance = 0.1 } } },
        { kind = "mob", zone = "Feralas", levels = "40-50",
          mobs = { { name = "Feral Scar Yeti", chance = 0.3 }, { name = "Longtooth Runner", chance = 0.1 }, { name = "Enraged Feral Scar", chance = 0.3 } } },
        { kind = "mob", zone = "Thousand Needles", levels = "25-35",
          mobs = { { name = "Scorpid Reaver", chance = 0.09 }, { name = "Saltstone Crystalhide", chance = 0.1 }, { name = "Sparkleshell Snapper", chance = 0.1 } } },
        { kind = "vendor", zone = "Lhara (Elwynn Forest / Mulgore)" },
      }},
      { id = 4235,  name = "Heavy Hide", sources = {
        { kind = "mob", zone = "Badlands", levels = "35-45",
          mobs = { { name = "Scorched Guardian", chance = 1.5 }, { name = "Crag Coyote", chance = 0.01 }, { name = "Elder Crag Coyote", chance = 0.0 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45",
          mobs = { { name = "Jungle Stalker", chance = 0.01 }, { name = "Crystal Spine Basilisk", chance = 0.01 }, { name = "Elder Mistvale Gorilla", chance = 0.01 } } },
        { kind = "mob", zone = "Thousand Needles", levels = "25-35",
          mobs = { { name = "Scorpid Reaver", chance = 0.01 }, { name = "Sparkleshell Snapper", chance = 0.01 }, { name = "Saltstone Gazer", chance = 0.01 } } },
        { kind = "mob", zone = "Uldaman", levels = "35-45",
          mobs = { { name = "Deadly Cleft Scorpid", chance = 0.08 }, { name = "Cleft Scorpid", chance = 0.02 }, { name = "Shrike Bat", chance = 0.04 } } },
        { kind = "mob", zone = "Feralas", levels = "40-50",
          mobs = { { name = "Longtooth Runner", chance = 0.02 }, { name = "Feral Scar Yeti", chance = 0.02 }, { name = "Frayfeather Stagwing", chance = 0.01 } } },
      }},
      { id = 2319,  name = "Medium Leather", sources = {
        { kind = "mob", zone = "Shadowfang Keep", levels = "20-30",
          mobs = { { name = "Slavering Worg", chance = 3.9 }, { name = "Bleak Worg", chance = 1.9 }, { name = "Shadowfang Moonwalker", chance = 1.9 } } },
        { kind = "mob", zone = "Razorfen Kraul", levels = "25-35",
          mobs = { { name = "Kraul Bat", chance = 22.2 }, { name = "Agam'ar", chance = 3.6 }, { name = "Greater Kraul Bat", chance = 3.7 } } },
        { kind = "mob", zone = "Blackfathom Deeps", levels = "20-30",
          mobs = { { name = "Aku'mai Snapjaw", chance = 19.5 }, { name = "Aku'mai Fisher", chance = 10.0 }, { name = "Ghamoo-ra", chance = 5.1 } } },
        { kind = "mob", zone = "Wailing Caverns", levels = "15-25",
          mobs = { { name = "Deviate Guardian", chance = 2.1 }, { name = "Skum", chance = 6.3 }, { name = "Deviate Dreadfang", chance = 1.3 } } },
        { kind = "mob", zone = "Duskwood", levels = "18-30",
          mobs = { { name = "Nightbane Vile Fang", chance = 2.3 }, { name = "Nightbane Tainted One", chance = 3.1 }, { name = "Nightbane Dark Runner", chance = 0.6 } } },
        { kind = "vendor", zone = "Lhara (Elwynn Forest / Mulgore)" },
      }},
      { id = 4232,  name = "Medium Hide", sources = {
        { kind = "mob", zone = "Duskwood", levels = "18-30",
          mobs = { { name = "Nightbane Vile Fang", chance = 0.2 }, { name = "Nightbane Tainted One", chance = 0.3 }, { name = "Nightbane Dark Runner", chance = 0.05 } } },
        { kind = "mob", zone = "Thousand Needles", levels = "25-35",
          mobs = { { name = "Highperch Consort", chance = 0.03 }, { name = "Sparkleshell Snapper", chance = 0.01 }, { name = "Highperch Wyvern", chance = 0.02 } } },
        { kind = "mob", zone = "Shadowfang Keep", levels = "20-30",
          mobs = { { name = "Son of Arugal", chance = 0.09 }, { name = "Shadowfang Ragetooth", chance = 0.04 }, { name = "Shadowfang Darksoul", chance = 0.03 } } },
        { kind = "mob", zone = "Wailing Caverns", levels = "15-25",
          mobs = { { name = "Deviate Ravager", chance = 0.03 }, { name = "Deviate Guardian", chance = 0.02 }, { name = "Deviate Adder", chance = 0.04 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45",
          mobs = { { name = "Crystal Spine Basilisk", chance = 0.01 }, { name = "Stranglethorn Raptor", chance = 0.01 }, { name = "Young Stranglethorn Tiger", chance = 0.01 } } },
      }},
      { id = 2318,  name = "Light Leather", sources = {
        { kind = "mob", zone = "Wailing Caverns", levels = "15-25",
          mobs = { { name = "Deviate Dreadfang", chance = 3.1 }, { name = "Deviate Venomwing", chance = 2.9 }, { name = "Deviate Adder", chance = 2.6 } } },
        { kind = "mob", zone = "The Barrens", levels = "10-25",
          mobs = { { name = "Deviate Coiler", chance = 8.7 }, { name = "Deviate Stalker", chance = 8.0 }, { name = "Sunscale Scytheclaw", chance = 0.2 } } },
        { kind = "mob", zone = "Razorfen Kraul", levels = "25-35",
          mobs = { { name = "Raging Agam'ar", chance = 10.3 }, { name = "Agam'ar", chance = 2.6 } } },
        { kind = "mob", zone = "Shadowfang Keep", levels = "20-30",
          mobs = { { name = "Shadowfang Ragetooth", chance = 1.9 }, { name = "Fel Steed", chance = 6.4 }, { name = "Shadowfang Glutton", chance = 2.9 } } },
        { kind = "mob", zone = "Redridge Mountains", levels = "15-25",
          mobs = { { name = "Great Goretusk", chance = 0.3 }, { name = "Black Dragon Whelp", chance = 0.2 } } },
      }},
      { id = 783,   name = "Light Hide", sources = {
        { kind = "mob", zone = "Shadowfang Keep", levels = "20-30",
          mobs = { { name = "Slavering Worg", chance = 0.04 }, { name = "Shadowfang Whitescalp", chance = 0.07 }, { name = "Shadowfang Moonwalker", chance = 0.04 } } },
        { kind = "mob", zone = "Wailing Caverns", levels = "15-25",
          mobs = { { name = "Deviate Guardian", chance = 0.07 }, { name = "Deviate Ravager", chance = 0.05 }, { name = "Deviate Python", chance = 0.05 } } },
        { kind = "mob", zone = "The Barrens", levels = "10-25",
          mobs = { { name = "Sunscale Scytheclaw", chance = 0.02 }, { name = "Zhevra Runner", chance = 0.01 }, { name = "Sunscale Screecher", chance = 0.01 } } },
        { kind = "mob", zone = "Redridge Mountains", levels = "15-25",
          mobs = { { name = "Great Goretusk", chance = 0.02 }, { name = "Black Dragon Whelp", chance = 0.02 } } },
        { kind = "mob", zone = "Darkshore", levels = "10-20",
          mobs = { { name = "Moonstalker", chance = 0.02 }, { name = "Foreststrider Fledgling", chance = 0.02 }, { name = "Moonstalker Sire", chance = 0.02 } } },
      }},
    }},
    { category = "Cloth", items = {
      { id = 14342, name = "Mooncloth", sources = {
        -- Tailoring transmute: 2 Felcloth at a Moonwell, 4-day cooldown,
        -- requires the Mooncloth Tailoring book (Felcloth turn-in quest).
        { kind = "craft", zone = "Tailoring transmute (2 Felcloth, 4-day CD at a Moonwell)" },
      }},
      { id = 14256, name = "Felcloth", sources = {
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Jadefire Felsworn", chance = 7.1 }, { name = "Jadefire Trickster", chance = 7.6 }, { name = "Jadefire Betrayer", chance = 7.7 } } },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Wildspawn Shadowstalker", chance = 12.1 }, { name = "Wildspawn Imp", chance = 7.0 }, { name = "Zevrim Thornhoof", chance = 4.2 } } },
        { kind = "mob", zone = "Azshara", levels = "45-55",
          mobs = { { name = "Legashi Hellcaller", chance = 9.6 }, { name = "Legashi Rogue", chance = 9.0 }, { name = "Legashi Satyr", chance = 9.6 } } },
        { kind = "mob", zone = "Winterspring", levels = "53-60",
          mobs = { { name = "Hederine Slayer", chance = 8.3 }, { name = "Hederine Initiate", chance = 8.5 }, { name = "Lady Hederine", chance = 1.5 } } },
        { kind = "mob", zone = "Zul'Gurub", levels = "60",
          mobs = { { name = "Mad Servant", chance = 4.8 } } },
        { kind = "vendor", zone = "Vi'el (Winterspring)" },
      }},
      { id = 14047, name = "Runecloth", sources = {
        { kind = "mob", zone = "Silithus", levels = "55-60",
          mobs = { { name = "Twilight Avenger", chance = 52.9 }, { name = "Twilight Geolord", chance = 53.0 }, { name = "Twilight Stonecaller", chance = 51.9 } } },
        { kind = "mob", zone = "Eastern Plaguelands", levels = "53-60",
          mobs = { { name = "Scarlet Warder", chance = 65.4 }, { name = "Unliving Mossflayer", chance = 76.6 }, { name = "Scarlet Enchanter", chance = 64.8 } } },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Wildspawn Shadowstalker", chance = 49.3 }, { name = "Wildspawn Imp", chance = 56.3 }, { name = "Wildspawn Rogue", chance = 36.7 } } },
        { kind = "mob", zone = "Deadwind Pass", levels = "55-60",
          mobs = { { name = "Deadwind Mauler", chance = 76.4 }, { name = "Deadwind Warlock", chance = 76.6 }, { name = "Deadwind Ogre Mage", chance = 77.6 } } },
        { kind = "mob", zone = "Western Plaguelands", levels = "51-58",
          mobs = { { name = "Scarlet Spellbinder", chance = 75.2 }, { name = "Cavalier Durgen", chance = 75.6 }, { name = "Scarlet Sentinel", chance = 66.3 } } },
      }},
      { id = 4338,  name = "Mageweave Cloth", sources = {
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Jadefire Felsworn", chance = 61.8 }, { name = "Deadwood Warrior", chance = 59.2 }, { name = "Jadefire Satyr", chance = 63.1 } } },
        { kind = "mob", zone = "Feralas", levels = "40-50",
          mobs = { { name = "Gordunni Brute", chance = 54.0 }, { name = "Grimtotem Naturalist", chance = 41.8 }, { name = "Gordunni Warlock", chance = 53.8 } } },
        { kind = "mob", zone = "Searing Gorge", levels = "43-52",
          mobs = { { name = "Dark Iron Lookout", chance = 62.8 }, { name = "Dark Iron Steamsmith", chance = 60.0 }, { name = "Dark Iron Slaver", chance = 62.7 } } },
        { kind = "mob", zone = "Tanaris", levels = "40-50",
          mobs = { { name = "Dunemaul Brute", chance = 73.4 }, { name = "Dunemaul Enforcer", chance = 73.2 }, { name = "Dunemaul Ogre Mage", chance = 74.7 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Poison Sprite", chance = 31.5 }, { name = "Putridus Satyr", chance = 24.6 }, { name = "Putridus Shadowstalker", chance = 26.2 } } },
      }},
      { id = 4306,  name = "Silk Cloth", sources = {
        { kind = "mob", zone = "Desolace", levels = "30-40",
          mobs = { { name = "Undead Ravager", chance = 65.4 }, { name = "Magram Stormer", chance = 52.3 }, { name = "Kolkar Mauler", chance = 49.5 } } },
        { kind = "mob", zone = "Arathi Highlands", levels = "30-40",
          mobs = { { name = "Dabyrie Laborer", chance = 60.7 }, { name = "Drywhisker Surveyor", chance = 49.7 }, { name = "Hammerfall Grunt", chance = 60.9 } } },
        { kind = "mob", zone = "Scarlet Monastery", levels = "30-45",
          mobs = { { name = "Unfettered Spirit", chance = 58.8 } } },
        { kind = "mob", zone = "Badlands", levels = "35-45",
          mobs = { { name = "Shadowforge Surveyor", chance = 40.9 }, { name = "Shadowforge Warrior", chance = 64.1 }, { name = "Stonevault Shaman", chance = 46.3 } } },
        { kind = "mob", zone = "Swamp of Sorrows", levels = "35-45",
          mobs = { { name = "Lost One Hunter", chance = 66.0 }, { name = "Lost One Muckdweller", chance = 65.1 }, { name = "Lost One Riftseeker", chance = 65.4 } } },
      }},
      { id = 2592,  name = "Wool Cloth", sources = {
        { kind = "mob", zone = "Ashenvale", levels = "18-30",
          mobs = { { name = "Thistlefur Avenger", chance = 46.2 }, { name = "Foulweald Warrior", chance = 49.8 }, { name = "Thistlefur Totemic", chance = 45.8 } } },
        { kind = "mob", zone = "Hillsbrad Foothills", levels = "20-30",
          mobs = { { name = "Syndicate Watchman", chance = 47.4 }, { name = "Hillsbrad Farmhand", chance = 45.9 }, { name = "Hillsbrad Footman", chance = 42.2 } } },
        { kind = "mob", zone = "Stonetalon Mountains", levels = "15-30",
          mobs = { { name = "Windshear Digger", chance = 46.5 }, { name = "Bloodfury Harpy", chance = 34.1 }, { name = "Bloodfury Ambusher", chance = 34.2 } } },
        { kind = "mob", zone = "The Barrens", levels = "10-25",
          mobs = { { name = "Bael'dun Excavator", chance = 52.4 }, { name = "Venture Co. Overseer", chance = 29.0 }, { name = "Bael'dun Rifleman", chance = 32.3 } } },
        { kind = "mob", zone = "Wetlands", levels = "20-30",
          mobs = { { name = "Mosshide Gnoll", chance = 49.4 }, { name = "Mosshide Mongrel", chance = 49.4 }, { name = "Dragonmaw Scout", chance = 52.0 } } },
      }},
      { id = 2589,  name = "Linen Cloth", sources = {
        { kind = "mob", zone = "The Barrens", levels = "10-25",
          mobs = { { name = "Kolkar Wrangler", chance = 55.4 }, { name = "Theramore Marine", chance = 53.0 }, { name = "Southsea Brigand", chance = 68.0 } } },
        { kind = "mob", zone = "Westfall", levels = "10-20",
          mobs = { { name = "Defias Looter", chance = 63.9 }, { name = "Defias Pillager", chance = 65.8 }, { name = "Riverpaw Gnoll", chance = 54.5 } } },
        { kind = "mob", zone = "Loch Modan", levels = "10-20",
          mobs = { { name = "Stonesplinter Skullthumper", chance = 66.1 }, { name = "Stonesplinter Seer", chance = 66.1 }, { name = "Stonesplinter Shaman", chance = 67.4 } } },
        { kind = "mob", zone = "Elwynn Forest", levels = "1-10",
          mobs = { { name = "Kobold Miner", chance = 43.7 }, { name = "Defias Bandit", chance = 46.1 }, { name = "Defias Rogue Wizard", chance = 43.6 } } },
        { kind = "mob", zone = "Darkshore", levels = "10-20",
          mobs = { { name = "Writhing Highborne", chance = 56.4 }, { name = "Wailing Highborne", chance = 57.0 }, { name = "Blackwood Pathfinder", chance = 69.1 } } },
      }},
    }},
    { category = "Elemental", items = {
      { id = 7078,  name = "Essence of Fire", sources = {
        { kind = "mob", zone = "Molten Core", levels = "60",
          mobs = { { name = "Sulfuron Harbinger", chance = 83.8 }, { name = "Lucifron", chance = 74.6 }, { name = "Golemagg the Incinerator", chance = 76.6 } } },
        { kind = "mob", zone = "Blackrock Mountain", levels = "50-60",
          mobs = { { name = "Fireguard Destroyer", chance = 8.6 }, { name = "Fireguard", chance = 6.1 }, { name = "Blazing Fireguard", chance = 2.0 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Living Blaze", chance = 2.3 }, { name = "Scorching Elemental", chance = 2.3 }, { name = "Blazing Invader", chance = 1.7 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Entropic Beast", chance = 1.3 }, { name = "Entropic Horror", chance = 2.6 } } },
        { kind = "mob", zone = "Silithus", levels = "55-60",
          mobs = { { name = "Prince Skaldrenox", chance = 84.0 }, { name = "Crimson Templar", chance = 4.3 }, { name = "The Duke of Cynders", chance = 8.1 } } },
        { kind = "vendor", zone = "Lokhtos Darkbargainer (Blackrock Mountain)" },
      }},
      { id = 7080,  name = "Essence of Water", sources = {
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Toxic Horror", chance = 5.6 } } },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Hydrospawn", chance = 13.1 } } },
        { kind = "mob", zone = "Eastern Plaguelands", levels = "53-60",
          mobs = { { name = "Blighted Surge", chance = 2.4 }, { name = "Plague Ravager", chance = 2.3 }, { name = "Blighted Horror", chance = 3.1 } } },
        { kind = "mob", zone = "Silithus", levels = "55-60",
          mobs = { { name = "Lord Skwol", chance = 80.6 }, { name = "Azure Templar", chance = 4.5 }, { name = "The Duke of Fathoms", chance = 6.9 } } },
        { kind = "mob", zone = "Winterspring", levels = "53-60",
          mobs = { { name = "Watery Invader", chance = 3.0 }, { name = "Princess Tempestria", chance = 79.1 } } },
        { kind = "vendor", zone = "Lokhtos Darkbargainer (Blackrock Mountain)" },
      }},
      { id = 7082,  name = "Essence of Air", sources = {
        { kind = "mob", zone = "Silithus", levels = "55-60",
          mobs = { { name = "Dust Stormer", chance = 3.9 }, { name = "Whirling Invader", chance = 5.1 }, { name = "High Marshal Whirlaxis", chance = 82.5 } } },
        { kind = "vendor", zone = "Lokhtos Darkbargainer (Blackrock Mountain)" },
      }},
      { id = 7076,  name = "Heart of Fire", sources = {
        { kind = "mob", zone = "Molten Core", levels = "60",
          mobs = { { name = "Golemagg the Incinerator", chance = 81.0 }, { name = "Garr", chance = 68.3 }, { name = "Lava Annihilator", chance = 18.7 } } },
        { kind = "mob", zone = "Silithus", levels = "55-60",
          mobs = { { name = "Desert Rumbler", chance = 2.2 }, { name = "Baron Kazum", chance = 85.7 }, { name = "Earthen Templar", chance = 4.3 } } },
        { kind = "mob", zone = "Burning Steppes", levels = "50-58",
          mobs = { { name = "Greater Obsidian Elemental", chance = 3.1 }, { name = "Obsidian Elemental", chance = 1.2 }, { name = "Volchan", chance = 3.2 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Stone Guardian", chance = 6.2 } } },
        { kind = "mob", zone = "Azshara", levels = "45-55",
          mobs = { { name = "Thundering Invader", chance = 1.9 }, { name = "Avalanchion", chance = 83.0 } } },
        { kind = "vendor", zone = "Lokhtos Darkbargainer (Blackrock Mountain)" },
      }},
      { id = 11382, name = "Blood of the Mountain", sources = {
        { kind = "mob", zone = "Molten Core", levels = "60",
          mobs = { { name = "Molten Destroyer", chance = 12.7 } } },
        { kind = "vendor", zone = "Lokhtos Darkbargainer (Blackrock Mountain)" },
      }},
      { id = 12803, name = "Living Essence", sources = {
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Whip Lasher", chance = 0.6 }, { name = "Warpwood Treant", chance = 16.1 }, { name = "Death Lash", chance = 10.4 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Tar Lurker", chance = 3.5 }, { name = "Tar Lord", chance = 3.4 }, { name = "Tar Creeper", chance = 1.9 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Warpwood Shredder", chance = 2.8 }, { name = "Irontree Stomper", chance = 2.0 }, { name = "Warpwood Moss Flayer", chance = 1.3 } } },
        { kind = "mob", zone = "Western Plaguelands", levels = "51-58",
          mobs = { { name = "Rotting Behemoth", chance = 5.8 }, { name = "Decaying Horror", chance = 6.3 }, { name = "The Husk", chance = 94.9 } } },
      }},
      { id = 12808, name = "Essence of Undeath", sources = {
        { kind = "mob", zone = "Stratholme", levels = "55-60",
          mobs = { { name = "Plague Ghoul", chance = 4.9 }, { name = "Mangled Cadaver", chance = 4.5 }, { name = "Ghoul Ravener", chance = 5.1 } } },
        { kind = "mob", zone = "Scholomance", levels = "55-60",
          mobs = { { name = "Risen Guard", chance = 5.4 }, { name = "Diseased Ghoul", chance = 4.1 }, { name = "Spectral Tutor", chance = 4.8 } } },
        { kind = "mob", zone = "Zul'Gurub", levels = "60",
          mobs = { { name = "Withered Mistress", chance = 7.3 } } },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Eldreth Spectre", chance = 7.8 }, { name = "Eldreth Spirit", chance = 6.5 }, { name = "Eldreth Apparition", chance = 6.4 } } },
        { kind = "mob", zone = "Naxxramas", levels = "60",
          mobs = { { name = "Necro Knight", chance = 16.7 }, { name = "Plagued Ghoul", chance = 1.7 }, { name = "Stoneskin Gargoyle", chance = 1.2 } } },
      }},
      { id = 7067,  name = "Elemental Earth", sources = {
        { kind = "herb", zone = "Stranglethorn Vale", levels = "30-45" },
        { kind = "herb", zone = "Stonetalon Mountains", levels = "15-30" },
        { kind = "herb", zone = "Arathi Highlands", levels = "30-40" },
        { kind = "herb", zone = "Dustwallow Marsh", levels = "35-45" },
        { kind = "herb", zone = "Swamp of Sorrows", levels = "35-45" },
        { kind = "herb", zone = "Feralas", levels = "40-50" },
        { kind = "mob", zone = "Badlands", levels = "35-45",
          mobs = { { name = "Rock Elemental", chance = 9.6 }, { name = "Lesser Rock Elemental", chance = 8.8 }, { name = "Greater Rock Elemental", chance = 4.8 } } },
        { kind = "mob", zone = "Arathi Highlands", levels = "30-40",
          mobs = { { name = "Rumbling Exile", chance = 9.9 }, { name = "Myzrael", chance = 3.0 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Theradrim Shardling", chance = 4.1 }, { name = "Theradrim Guardian", chance = 3.9 }, { name = "Landslide", chance = 1.8 } } },
        { kind = "mob", zone = "Silithus", levels = "55-60",
          mobs = { { name = "Desert Rumbler", chance = 4.9 }, { name = "Earthen Templar", chance = 3.9 }, { name = "The Duke of Shards", chance = 5.4 } } },
        { kind = "mob", zone = "Molten Core", levels = "60",
          mobs = { { name = "Lava Annihilator", chance = 1.2 }, { name = "Lava Surger", chance = 1.6 }, { name = "Lava Elemental", chance = 1.0 } } },
      }},
      { id = 7068,  name = "Elemental Fire", sources = {
        { kind = "herb", zone = "Searing Gorge", levels = "43-52" },
        { kind = "herb", zone = "Tanaris", levels = "40-50" },
        { kind = "herb", zone = "Blasted Lands", levels = "45-55" },
        { kind = "herb", zone = "Feralas", levels = "40-50" },
        { kind = "herb", zone = "Azshara", levels = "45-55" },
        { kind = "herb", zone = "The Hinterlands", levels = "40-50" },
        { kind = "herb", zone = "Felwood", levels = "48-55" },
        { kind = "mob", zone = "Molten Core", levels = "60",
          mobs = { { name = "Baron Geddon", chance = 7.4 }, { name = "Lucifron", chance = 5.9 }, { name = "Sulfuron Harbinger", chance = 5.9 } } },
        { kind = "mob", zone = "Arathi Highlands", levels = "30-40",
          mobs = { { name = "Burning Exile", chance = 11.1 } } },
        { kind = "mob", zone = "Blackrock Mountain", levels = "50-60",
          mobs = { { name = "Fireguard Destroyer", chance = 4.6 }, { name = "Fireguard", chance = 4.8 }, { name = "Blazing Fireguard", chance = 5.0 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55",
          mobs = { { name = "Living Blaze", chance = 5.7 }, { name = "Scorching Elemental", chance = 5.5 }, { name = "Blazing Invader", chance = 4.9 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Entropic Beast", chance = 5.9 }, { name = "Entropic Horror", chance = 6.3 } } },
      }},
      { id = 7070,  name = "Elemental Water", sources = {
        { kind = "herb", zone = "Stranglethorn Vale", levels = "30-45" },
        { kind = "herb", zone = "Westfall", levels = "10-20" },
        { kind = "herb", zone = "Wetlands", levels = "20-30" },
        { kind = "herb", zone = "Eastern Plaguelands", levels = "53-60" },
        { kind = "herb", zone = "Western Plaguelands", levels = "51-58" },
        { kind = "herb", zone = "Razorfen Downs", levels = "30-45" },
        { kind = "herb", zone = "Felwood", levels = "48-55" },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45",
          mobs = { { name = "Lesser Water Elemental", chance = 9.1 } } },
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Hydrospawn", chance = 22.0 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Toxic Horror", chance = 5.5 } } },
        { kind = "mob", zone = "Feralas", levels = "40-50",
          mobs = { { name = "Sea Elemental", chance = 7.1 }, { name = "Sea Spray", chance = 6.2 } } },
        { kind = "mob", zone = "Eastern Plaguelands", levels = "53-60",
          mobs = { { name = "Blighted Surge", chance = 6.0 }, { name = "Plague Ravager", chance = 5.9 }, { name = "Plague Monstrosity", chance = 5.8 } } },
      }},
    }},
    { category = "Alchemy Supplies", items = {
      -- Vials are sold by basically every alchemy / general-goods vendor in
      -- the world; no Sources section needed on these.
      { id = 8925,  name = "Crystal Vial" },
      { id = 3372,  name = "Leaded Vial" },
      { id = 3371,  name = "Empty Vial" },
      { id = 13423, name = "Stonescale Oil", recipe = {
        { id = 13422, count = 1 },  -- Stonescale Eel
        { id = 3372,  count = 1 },  -- Leaded Vial
      } },
      { id = 6371,  name = "Fire Oil", recipe = {
        { id = 6359, count = 2 },  -- Firefin Snapper
        { id = 3371, count = 1 },  -- Empty Vial
      } },
      { id = 6370,  name = "Blackmouth Oil", recipe = {
        { id = 6358, count = 2 },  -- Oily Blackmouth
        { id = 3371, count = 1 },  -- Empty Vial
      } },
      { id = 13422, name = "Stonescale Eel", sources = {
        { kind = "fish", zone = "Azshara (Stonescale Eel Swarm pools)", levels = "45-55" },
        { kind = "fish", zone = "Hinterlands (coastal pools)",          levels = "40-50" },
        { kind = "fish", zone = "Stranglethorn Vale (coastal pools)",   levels = "30-45" },
      }},
      { id = 6359,  name = "Firefin Snapper", sources = {
        { kind = "fish", zone = "Stranglethorn Vale (Firefin Snapper Schools)", levels = "30-45" },
        { kind = "fish", zone = "Tanaris (coastal schools)",                    levels = "40-50" },
        { kind = "fish", zone = "Feralas (coastal schools)",                    levels = "40-50" },
        { kind = "fish", zone = "Azshara (coastal schools)",                    levels = "45-55" },
      }},
      { id = 6358,  name = "Oily Blackmouth", sources = {
        { kind = "fish", zone = "Stranglethorn Vale (Oily Blackmouth Schools)", levels = "30-45" },
        { kind = "fish", zone = "Wetlands (coastal schools)",                   levels = "20-30" },
        { kind = "fish", zone = "Desolace (coastal schools)",                   levels = "30-40" },
        { kind = "fish", zone = "Hillsbrad Foothills (coastal schools)",        levels = "20-30" },
      }},
      { id = 5637,  name = "Large Fang", sources = {
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45",
          mobs = { { name = "Elder Mistvale Gorilla", chance = 5.3 }, { name = "Jungle Stalker", chance = 5.3 }, { name = "Lashtail Raptor", chance = 4.2 } } },
        { kind = "mob", zone = "Badlands", levels = "35-45",
          mobs = { { name = "Elder Crag Coyote", chance = 5.1 }, { name = "Crag Coyote", chance = 4.5 }, { name = "Feral Crag Coyote", chance = 4.4 } } },
        { kind = "mob", zone = "Swamp of Sorrows", levels = "35-45",
          mobs = { { name = "Dreaming Whelp", chance = 9.8 }, { name = "Swamp Jaguar", chance = 5.7 }, { name = "Adolescent Whelp", chance = 7.6 } } },
        { kind = "mob", zone = "Dustwallow Marsh", levels = "35-45",
          mobs = { { name = "Darkmist Spider", chance = 4.1 }, { name = "Darkmist Recluse", chance = 3.8 }, { name = "Bloodfen Screecher", chance = 4.6 } } },
        { kind = "mob", zone = "Arathi Highlands", levels = "30-40",
          mobs = { { name = "Highland Fleshstalker", chance = 4.1 }, { name = "Highland Strider", chance = 2.2 }, { name = "Plains Creeper", chance = 3.0 } } },
      }},
      { id = 5635,  name = "Sharp Claw", sources = {
        { kind = "mob", zone = "Duskwood", levels = "18-30",
          mobs = { { name = "Nightbane Dark Runner", chance = 20.0 }, { name = "Nightbane Vile Fang", chance = 17.0 }, { name = "Starving Dire Wolf", chance = 3.7 } } },
        { kind = "mob", zone = "Thousand Needles", levels = "25-35",
          mobs = { { name = "Saltstone Basilisk", chance = 5.3 }, { name = "Highperch Wyvern", chance = 5.8 }, { name = "Highperch Consort", chance = 5.9 } } },
        { kind = "mob", zone = "Shadowfang Keep", levels = "20-30",
          mobs = { { name = "Shadowfang Moonwalker", chance = 5.5 }, { name = "Shadowfang Darksoul", chance = 6.0 }, { name = "Son of Arugal", chance = 8.9 } } },
        { kind = "mob", zone = "The Barrens", levels = "10-25",
          mobs = { { name = "Sunscale Scytheclaw", chance = 2.3 }, { name = "Witchwing Slayer", chance = 2.4 }, { name = "Witchwing Roguefeather", chance = 2.5 } } },
        { kind = "mob", zone = "Stonetalon Mountains", levels = "15-30",
          mobs = { { name = "Twilight Runner", chance = 4.6 }, { name = "Bloodfury Harpy", chance = 5.8 }, { name = "Bloodfury Ambusher", chance = 5.5 } } },
      }},
      { id = 4402,  name = "Small Flame Sac", sources = {
        { kind = "mob", zone = "Badlands", levels = "35-45",
          mobs = { { name = "Scalding Whelp", chance = 16.2 }, { name = "Scorched Guardian", chance = 17.6 } } },
        { kind = "mob", zone = "Dustwallow Marsh", levels = "35-45",
          mobs = { { name = "Searing Hatchling", chance = 18.5 }, { name = "Searing Whelp", chance = 18.2 }, { name = "Brimgore", chance = 15.9 } } },
        { kind = "mob", zone = "Swamp of Sorrows", levels = "35-45",
          mobs = { { name = "Dreaming Whelp", chance = 24.2 }, { name = "Adolescent Whelp", chance = 22.0 } } },
        { kind = "mob", zone = "Feralas", levels = "40-50",
          mobs = { { name = "Sprite Darter", chance = 20.6 }, { name = "Sprite Dragon", chance = 41.0 }, { name = "Captured Sprite Darter", chance = 22.0 } } },
        { kind = "mob", zone = "Wetlands", levels = "20-30",
          mobs = { { name = "Crimson Whelp", chance = 16.8 }, { name = "Red Whelp", chance = 8.7 }, { name = "Flamesnorting Whelp", chance = 23.2 } } },
      }},
    }},
    { category = "Cooking Supplies", items = {
      { id = 21024, name = "Chimaerok Tenderloin", sources = {
        { kind = "mob", zone = "Feralas", levels = "40-50",
          mobs = { { name = "Arcane Chimaerok", chance = 24.5 }, { name = "Chimaerok Devourer", chance = 24.0 }, { name = "Chimaerok", chance = 24.3 } } },
      }},
      { id = 21153, name = "Raw Greater Sagefish", sources = {
        { kind = "fish", zone = "Ashenvale (Greater Sagefish Schools)",       levels = "18-30" },
        { kind = "fish", zone = "Hillsbrad Foothills (Greater Sagefish Schools)", levels = "20-30" },
        { kind = "fish", zone = "Desolace (Greater Sagefish Schools)",        levels = "30-40" },
        { kind = "fish", zone = "Stranglethorn Vale (Greater Sagefish Schools)", levels = "30-45" },
      }},
      { id = 20424, name = "Sandworm Meat", sources = {
        { kind = "mob", zone = "Silithus", levels = "55-60",
          mobs = { { name = "Dredge Striker", chance = 27.9 }, { name = "Dredge Crusher", chance = 27.8 } } },
      }},
      { id = 18255, name = "Runn Tum Tuber", sources = {
        { kind = "mob", zone = "Dire Maul", levels = "55-60",
          mobs = { { name = "Pusillin", chance = 4.8 } } },
      }},
      { id = 13759, name = "Raw Nightfin Snapper", sources = {
        -- Schools spawn at night only.
        { kind = "fish", zone = "Hinterlands (Nightfin pools, night)",  levels = "40-50" },
        { kind = "fish", zone = "Feralas (Nightfin pools, night)",      levels = "40-50" },
        { kind = "fish", zone = "Azshara (Nightfin pools, night)",      levels = "45-55" },
      }},
      { id = 13755, name = "Winter Squid", sources = {
        { kind = "fish", zone = "Azshara (Winter Squid Schools)",     levels = "45-55" },
        { kind = "fish", zone = "Hinterlands (Winter Squid Schools)", levels = "40-50" },
        { kind = "fish", zone = "Feralas (Winter Squid Schools)",     levels = "40-50" },
      }},
      { id = 8150,  name = "Deeprock Salt", sources = {
        { kind = "mob", zone = "Badlands", levels = "35-45",
          mobs = { { name = "Rock Elemental", chance = 19.1 }, { name = "Lesser Rock Elemental", chance = 19.2 }, { name = "Greater Rock Elemental", chance = 18.7 } } },
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Theradrim Shardling", chance = 16.2 }, { name = "Theradrim Guardian", chance = 15.4 }, { name = "Primordial Behemoth", chance = 26.0 } } },
        { kind = "mob", zone = "Silithus", levels = "55-60",
          mobs = { { name = "Desert Rumbler", chance = 19.1 }, { name = "Desert Rager", chance = 17.8 }, { name = "Setis", chance = 5.1 } } },
        { kind = "mob", zone = "Arathi Highlands", levels = "30-40",
          mobs = { { name = "Rumbling Exile", chance = 19.7 }, { name = "Fozruk", chance = 12.7 }, { name = "Thenan", chance = 28.6 } } },
        { kind = "mob", zone = "Searing Gorge", levels = "43-52",
          mobs = { { name = "Heavy War Golem", chance = 28.1 }, { name = "Tempered War Golem", chance = 28.7 }, { name = "Obsidion", chance = 10.0 } } },
      }},
      { id = 9061,  name = "Goblin Rocket Fuel", sources = {
        { kind = "mob", zone = "Maraudon (Inner)", levels = "40-50",
          mobs = { { name = "Tinkerer Gizlock", chance = 0.4 } } },
        { kind = "mob", zone = "Badlands", levels = "35-45",
          mobs = { { name = "7:XT", chance = 2.0 } } },
      }},
      -- Sold by every cooking-supply / general-goods vendor; no need to list.
      { id = 3713,  name = "Soothing Spices" },
      { id = 159,   name = "Refreshing Spring Water", sources = {
        { kind = "mob", zone = "Elwynn Forest", levels = "1-10",
          mobs = { { name = "Defias Thug", chance = 9.7 }, { name = "Kobold Worker", chance = 10.8 }, { name = "Kobold Laborer", chance = 10.7 } } },
        { kind = "mob", zone = "Tirisfal Glades", levels = "1-10",
          mobs = { { name = "Scarlet Convert", chance = 8.5 }, { name = "Rattlecage Skeleton", chance = 13.1 }, { name = "Mindless Zombie", chance = 14.9 } } },
        { kind = "mob", zone = "Durotar", levels = "1-10",
          mobs = { { name = "Vile Familiar", chance = 10.3 }, { name = "Kul Tiras Sailor", chance = 5.7 }, { name = "Burning Blade Fanatic", chance = 5.9 } } },
        { kind = "mob", zone = "Dun Morogh", levels = "1-10",
          mobs = { { name = "Frostmane Troll Whelp", chance = 14.1 }, { name = "Burly Rockjaw Trogg", chance = 14.6 }, { name = "Rockjaw Skullthumper", chance = 5.8 } } },
        { kind = "mob", zone = "Teldrassil", levels = "1-10",
          mobs = { { name = "Gnarlpine Defender", chance = 7.1 }, { name = "Grell", chance = 7.6 }, { name = "Gnarlpine Shaman", chance = 6.6 } } },
      }},
    }},
    { category = "Parts", items = {
      { id = 10560, name = "Unstable Trigger", recipe = {
        { id = 3860,  count = 1 }, -- Mithril Bar
        { id = 4338,  count = 1 }, -- Mageweave Cloth
        { id = 10505, count = 1 }, -- Solid Blasting Powder
      } },
      { id = 15992, name = "Dense Blasting Powder", recipe = {
        { id = 12365, count = 2 }, -- Dense Stone
      } },
      { id = 10505, name = "Solid Blasting Powder", recipe = {
        { id = 7912,  count = 2 }, -- Solid Stone
      } },
      { id = 4357,  name = "Coarse Blasting Powder", sources = {
        -- Crafted by Engineers from 1 Coarse Stone.
        { kind = "craft", zone = "Crafted by Engineers (1 Coarse Stone per cast, Apprentice recipe)" },
      }},
      { id = 7191,  name = "Fused Wiring", sources = {
        { kind = "mob", zone = "Gnomeregan", levels = "29-38",
          mobs = { { name = "Peacekeeper Security Suit", chance = 17.7 }, { name = "Mechanized Guardian", chance = 4.0 }, { name = "Arcane Nullifier X-21", chance = 3.2 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45",
          mobs = { { name = "Venture Co. Shredder", chance = 11.7 } } },
        { kind = "mob", zone = "Searing Gorge", levels = "43-52",
          mobs = { { name = "Clunk", chance = 17.8 } } },
        { kind = "mob", zone = "Badlands", levels = "35-45",
          mobs = { { name = "7:XT", chance = 15.2 } } },
      }},
    }},
    { category = "Enchanting", items = {
      -- Enchanting mats come from disenchanting items; the resulting mat depends
      -- on the disenchanted item's quality (green/blue/epic) and item level.
      -- Level bands below are the typical source-item ilvl range.
      { id = 20725, name = "Nexus Crystal", sources = {
        { kind = "mob", zone = "Blackrock Spire", levels = "55-60",
          mobs = { { name = "Razorgore the Untamed", chance = 1.5 } } },
      }},
      { id = 14344, name = "Large Brilliant Shard", sources = {
        { kind = "disenchant", zone = "Blue items, ilvl ~46-55+" },
      }},
      { id = 14343, name = "Small Brilliant Shard", sources = {
        { kind = "mob", zone = "Desolace", levels = "30-40",
          mobs = { { name = "Spirit of Kolk", chance = 2.2 } } },
      }},
      { id = 11178, name = "Large Radiant Shard", sources = {
        { kind = "disenchant", zone = "Blue items, ilvl ~36-45" },
      }},
      { id = 11177, name = "Small Radiant Shard", sources = {
        { kind = "disenchant", zone = "Blue items, ilvl ~36-45" },
      }},
      { id = 11139, name = "Large Glowing Shard", sources = {
        { kind = "disenchant", zone = "Blue items, ilvl ~26-35" },
      }},
      { id = 11138, name = "Small Glowing Shard", sources = {
        { kind = "disenchant", zone = "Blue items, ilvl ~26-35" },
      }},
      { id = 10978, name = "Small Glimmering Shard", sources = {
        { kind = "disenchant", zone = "Blue items, ilvl ~11-25" },
      }},
      { id = 16203, name = "Greater Eternal Essence", sources = {
        { kind = "mob", zone = "Zul'Gurub", levels = "60",
          mobs = { { name = "Gri'lek", chance = 1.2 } } },
        { kind = "mob", zone = "Naxxramas", levels = "60",
          mobs = { { name = "Maexxna", chance = 1.0 } } },
        { kind = "mob", zone = "Eastern Plaguelands", levels = "53-60",
          mobs = { { name = "Nathanos Blightcaller", chance = 2.7 } } },
      }},
      { id = 16202, name = "Lesser Eternal Essence", sources = {
        { kind = "disenchant", zone = "Green items, ilvl ~51-60" },
      }},
      { id = 11175, name = "Greater Nether Essence", sources = {
        { kind = "mob", zone = "Western Plaguelands", levels = "51-58",
          mobs = { { name = "Weldon Barov", chance = 2.2 } } },
      }},
      { id = 11174, name = "Lesser Nether Essence", sources = {
        { kind = "disenchant", zone = "Green items, ilvl ~41-50" },
      }},
      { id = 11135, name = "Greater Mystic Essence", sources = {
        { kind = "disenchant", zone = "Green/blue items, ilvl ~31-40" },
      }},
      { id = 11134, name = "Lesser Mystic Essence", sources = {
        { kind = "disenchant", zone = "Green items, ilvl ~31-40" },
      }},
      { id = 11082, name = "Greater Astral Essence", sources = {
        { kind = "disenchant", zone = "Green/blue items, ilvl ~21-30" },
      }},
      { id = 10998, name = "Lesser Astral Essence", sources = {
        { kind = "disenchant", zone = "Green items, ilvl ~21-30" },
      }},
      { id = 10939, name = "Greater Magic Essence", sources = {
        { kind = "disenchant", zone = "Green/blue items, ilvl ~6-20" },
      }},
      { id = 10938, name = "Lesser Magic Essence", sources = {
        { kind = "disenchant", zone = "Green items, ilvl ~6-20" },
      }},
      { id = 16204, name = "Illusion Dust", sources = {
        { kind = "disenchant", zone = "Green items, ilvl ~51-60" },
      }},
      { id = 11176, name = "Dream Dust", sources = {
        { kind = "disenchant", zone = "Green items, ilvl ~41-50" },
      }},
      { id = 11137, name = "Vision Dust", sources = {
        { kind = "disenchant", zone = "Green items, ilvl ~31-40" },
      }},
      { id = 11083, name = "Soul Dust", sources = {
        { kind = "disenchant", zone = "Green items, ilvl ~21-30" },
      }},
      { id = 10940, name = "Strange Dust", sources = {
        { kind = "disenchant", zone = "Green items, ilvl ~5-20" },
      }},
    }},
  },

  Consumables = {
    { category = "Utility", items = {
      { id = 184937, name = "Chronoboon Displacer", sources = {
        { kind = "vendor", zone = "Chromie (Western Plaguelands)" },
      }},
      { id = 18232,  name = "Field Repair Bot 74A", recipe = {
        { id = 12359, count = 12 }, -- Thorium Bar
        { id = 8170,  count = 4 },  -- Rugged Leather
        { id = 7191,  count = 1 },  -- Fused Wiring
        { id = 7067,  count = 2 },  -- Elemental Earth
        { id = 7068,  count = 1 },  -- Elemental Fire
      } },
    }},
    { category = "Flasks", items = {
      { id = 13510, name = "Flask of the Titans", classes = TANK, recipe = {
        { id = 8846,  count = 30 }, -- Gromsblood
        { id = 13423,  count = 10 }, -- Stonescale Oil
        { id = 13468, count = 1 },  -- Black Lotus
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 13511, name = "Flask of Distilled Wisdom", classes = CASTER, recipe = {
        { id = 13463, count = 30 }, -- Dreamfoil
        { id = 13467, count = 10 }, -- Icecap
        { id = 13468, count = 1 },  -- Black Lotus
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 13512, name = "Flask of Supreme Power", classes = CASTER, recipe = {
        { id = 13463, count = 30 }, -- Dreamfoil
        { id = 13465, count = 10 }, -- Mountain Silversage
        { id = 13468, count = 1 },  -- Black Lotus
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 13513, name = "Flask of Chromatic Resistance", recipe = {
        { id = 13467, count = 30 }, -- Icecap
        { id = 13465, count = 10 }, -- Mountain Silversage
        { id = 13468, count = 1 },  -- Black Lotus
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 13506, name = "Flask of Petrification", recipe = {
        { id = 13423, count = 30 }, -- Stonescale Oil
        { id = 13465, count = 10 }, -- Mountain Silversage
        { id = 13468, count = 1 },  -- Black Lotus
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
    }},
    { category = "Battle Elixirs", items = {
      { id = 13452, name = "Elixir of the Mongoose", classes = AGI, recipe = {
        { id = 13465, count = 2 },  -- Mountain Silversage
        { id = 13466, count = 2 },  -- Plaguebloom
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 9187,  name = "Elixir of Greater Agility", classes = AGI, recipe = {
        { id = 8838, count = 1 },  -- Sungrass
        { id = 3821, count = 1 },  -- Goldthorn
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 2457,  name = "Elixir of Minor Agility", classes = AGI, recipe = {
        { id = 2452, count = 1 },  -- Swiftthistle
        { id = 765,  count = 1 },  -- Silverleaf
        { id = 3371, count = 1 },  -- Empty Vial
      } },
      { id = 9206,  name = "Elixir of Giants", classes = STR, recipe = {
        { id = 8838, count = 1 },  -- Sungrass
        { id = 8846, count = 1 },  -- Gromsblood
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 13453, name = "Elixir of Brute Force", classes = STR, recipe = {
        { id = 8846,  count = 2 }, -- Gromsblood
        { id = 13466, count = 2 }, -- Plaguebloom
        { id = 8925,  count = 1 }, -- Crystal Vial
      } },
      { id = 3391,  name = "Elixir of Ogre's Strength", classes = STR, recipe = {
        { id = 2449, count = 1 },  -- Earthroot
        { id = 3356, count = 1 },  -- Kingsblood
        { id = 3372, count = 1 },  -- Leaded Vial
      } },
      { id = 12820, name = "Winterfall Firewater", classes = MELEE, sources = {
        { kind = "mob", zone = "Winterspring", levels = "53-60",
          mobs = { { name = "High Chief Winterfall", chance = 79.2 }, { name = "Winterfall Den Watcher", chance = 8.0 }, { name = "Winterfall Ursa", chance = 7.1 } } },
      }},
      { id = 13454, name = "Greater Arcane Elixir", classes = CASTER, recipe = {
        { id = 13463, count = 3 },  -- Dreamfoil
        { id = 13465, count = 1 },  -- Mountain Silversage
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 9155,  name = "Arcane Elixir", classes = CASTER, recipe = {
        { id = 8839, count = 1 },  -- Blindweed
        { id = 3821, count = 1 },  -- Goldthorn
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 21546, name = "Elixir of Greater Firepower", classes = { "Mage", "Warlock" }, recipe = {
        { id = 6371, count = 3 },  -- Fire Oil
        { id = 4625, count = 3 },  -- Firebloom
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 6373,  name = "Elixir of Fire Power", classes = { "Mage", "Warlock" }, recipe = {
        { id = 6371, count = 2 },  -- Fire Oil
        { id = 3356, count = 1 },  -- Kingsblood
        { id = 3372, count = 1 },  -- Leaded Vial
      } },
      { id = 17708, name = "Elixir of Frost Power", classes = { "Mage" }, recipe = {
        { id = 3819, count = 2 },  -- Wintersbite
        { id = 3358, count = 1 },  -- Khadgar's Whisker
        { id = 3372, count = 1 },  -- Leaded Vial
      } },
      { id = 9264,  name = "Elixir of Shadow Power", classes = { "Priest", "Warlock" }, recipe = {
        { id = 8845, count = 3 },  -- Ghost Mushroom
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 9224,  name = "Elixir of Demonslaying", classes = MELEE, recipe = {
        { id = 8846, count = 1 },  -- Gromsblood
        { id = 8845, count = 1 },  -- Ghost Mushroom
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
    }},
    { category = "Guardian Elixirs", items = {
      { id = 13445, name = "Elixir of Superior Defense", classes = TANK, recipe = {
        { id = 13423, count = 2 },  -- Stonescale Oil
        { id = 8838,  count = 1 },  -- Sungrass
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 3389,  name = "Elixir of Defense", classes = TANK, recipe = {
        { id = 3355, count = 1 },  -- Wild Steelbloom
        { id = 3820, count = 1 },  -- Stranglekelp
        { id = 3372, count = 1 },  -- Leaded Vial
      } },
      { id = 3825,  name = "Elixir of Fortitude", recipe = {
        { id = 3355, count = 1 },  -- Wild Steelbloom
        { id = 3821, count = 1 },  -- Goldthorn
        { id = 3372, count = 1 },  -- Leaded Vial
      } },
      { id = 13447, name = "Elixir of the Sages", classes = CASTER, recipe = {
        { id = 13463, count = 1 },  -- Dreamfoil
        { id = 13466, count = 2 },  -- Plaguebloom
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 9088,  name = "Gift of Arthas", recipe = {
        { id = 8839, count = 3 },  -- Blindweed
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 20007, name = "Mageblood Potion", classes = MANA, recipe = {
        { id = 13463, count = 1 },  -- Dreamfoil
        { id = 13466, count = 2 },  -- Plaguebloom
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 20004, name = "Major Troll's Blood Potion", classes = TANK, recipe = {
        { id = 8846,  count = 1 },  -- Gromsblood
        { id = 13466, count = 2 },  -- Plaguebloom
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 3826,  name = "Mighty Troll's Blood Potion", classes = TANK, recipe = {
        { id = 3357, count = 1 },  -- Liferoot
        { id = 2453, count = 1 },  -- Bruiseweed
        { id = 3372, count = 1 },  -- Leaded Vial
      } },
    }},
    { category = "Combat Potions", items = {
      { id = 13446, name = "Major Healing Potion", recipe = {
        { id = 13464, count = 2 },  -- Golden Sansam
        { id = 13465, count = 1 },  -- Mountain Silversage
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 3928,  name = "Superior Healing Potion", recipe = {
        { id = 8838, count = 1 },  -- Sungrass
        { id = 3358, count = 1 },  -- Khadgar's Whisker
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 1710,  name = "Greater Healing Potion", recipe = {
        { id = 3357, count = 1 },  -- Liferoot
        { id = 3356, count = 1 },  -- Kingsblood
        { id = 3372, count = 1 },  -- Leaded Vial
      } },
      { id = 929,   name = "Healing Potion", recipe = {
        { id = 2453, count = 1 },  -- Bruiseweed
        { id = 2450, count = 1 },  -- Briarthorn
        { id = 3372, count = 1 },  -- Leaded Vial
      } },
      { id = 858,   name = "Lesser Healing Potion", recipe = {
        { id = 118,  count = 1 },  -- Minor Healing Potion
        { id = 2450, count = 1 },  -- Briarthorn
      } },
      { id = 118,   name = "Minor Healing Potion", recipe = {
        { id = 2447, count = 1 },  -- Peacebloom
        { id = 765,  count = 1 },  -- Silverleaf
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 13444, name = "Major Mana Potion", classes = MANA, recipe = {
        { id = 13463, count = 3 },  -- Dreamfoil
        { id = 13467, count = 2 },  -- Icecap
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 13443, name = "Superior Mana Potion", classes = MANA, recipe = {
        { id = 8838, count = 2 },  -- Sungrass
        { id = 8839, count = 2 },  -- Blindweed
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 6149,  name = "Greater Mana Potion", classes = MANA, recipe = {
        { id = 3358, count = 1 },  -- Khadgar's Whisker
        { id = 3821, count = 1 },  -- Goldthorn
        { id = 3372, count = 1 },  -- Leaded Vial
      } },
      { id = 3827,  name = "Mana Potion", classes = MANA, recipe = {
        { id = 3820, count = 1 },  -- Stranglekelp
        { id = 3356, count = 1 },  -- Kingsblood
        { id = 3372, count = 1 },  -- Leaded Vial
      } },
      { id = 3385,  name = "Lesser Mana Potion", classes = MANA, recipe = {
        { id = 785,  count = 1 },  -- Mageroyal
        { id = 3820, count = 1 },  -- Stranglekelp
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 2455,  name = "Minor Mana Potion", classes = MANA, recipe = {
        { id = 785, count = 1 },   -- Mageroyal
        { id = 765, count = 1 },   -- Silverleaf
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 13442, name = "Mighty Rage Potion", classes = { "Warrior", "Druid" }, recipe = {
        { id = 8846, count = 3 },  -- Gromsblood
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 5633,  name = "Great Rage Potion", classes = { "Warrior", "Druid" }, recipe = {
        { id = 5637, count = 1 },  -- Large Fang
        { id = 3356, count = 1 },  -- Kingsblood
        { id = 3372, count = 1 },  -- Leaded Vial
      } },
      { id = 5631,  name = "Rage Potion", classes = { "Warrior", "Druid" }, recipe = {
        { id = 5635, count = 2 },  -- Sharp Claw
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 13455, name = "Greater Stoneshield Potion", classes = TANK, recipe = {
        { id = 13423, count = 2 },  -- Stonescale Oil
        { id = 10620, count = 1 },  -- Thorium Ore
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 4623,  name = "Lesser Stoneshield Potion", classes = TANK, recipe = {
        { id = 3858, count = 1 },  -- Mithril Ore
        { id = 3821, count = 1 },  -- Goldthorn
        { id = 3372, count = 1 },  -- Leaded Vial
      } },
      { id = 20520, name = "Dark Rune", classes = MANA, sources = {
        { kind = "mob", zone = "Scholomance", levels = "55-60",
          mobs = { { name = "Scholomance Necromancer", chance = 39.4 }, { name = "Scholomance Dark Summoner", chance = 33.9 }, { name = "The Ravenian", chance = 12.4 } } },
      }},
      { id = 20008, name = "Living Action Potion", recipe = {
        { id = 13467, count = 2 },  -- Icecap
        { id = 13465, count = 1 },  -- Mountain Silversage
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 5634,  name = "Free Action Potion", recipe = {
        { id = 6370, count = 2 },  -- Blackmouth Oil
        { id = 3820, count = 1 },  -- Stranglekelp
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 9030,  name = "Restorative Potion", recipe = {
        { id = 7067, count = 1 },  -- Elemental Earth
        { id = 3821, count = 1 },  -- Goldthorn
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 3387,  name = "Limited Invulnerability Potion", recipe = {
        { id = 8839, count = 2 },  -- Blindweed
        { id = 8845, count = 1 },  -- Ghost Mushroom
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 2459,  name = "Swiftness Potion", recipe = {
        { id = 2452, count = 1 },  -- Swiftthistle
        { id = 2450, count = 1 },  -- Briarthorn
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
    }},
    { category = "Protection Potions", items = {
      { id = 13461, name = "Greater Arcane Protection Potion", recipe = {
        { id = 11176, count = 1 },  -- Dream Dust
        { id = 13463, count = 1 },  -- Dreamfoil
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 13457, name = "Greater Fire Protection Potion", recipe = {
        { id = 7068,  count = 1 },  -- Elemental Fire
        { id = 13463, count = 1 },  -- Dreamfoil
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 6049,  name = "Fire Protection Potion", recipe = {
        { id = 4402, count = 1 },  -- Small Flame Sac
        { id = 6371, count = 1 },  -- Fire Oil
        { id = 3372, count = 1 },  -- Leaded Vial
      } },
      { id = 13456, name = "Greater Frost Protection Potion", recipe = {
        { id = 7070,  count = 1 },  -- Elemental Water
        { id = 13463, count = 1 },  -- Dreamfoil
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 6050,  name = "Frost Protection Potion", recipe = {
        { id = 3819, count = 1 },  -- Wintersbite / Dragon's Teeth
        { id = 3821, count = 1 },  -- Goldthorn
        { id = 3372, count = 1 },  -- Leaded Vial
      } },
      { id = 6051,  name = "Holy Protection Potion", recipe = {
        { id = 2453, count = 1 },  -- Bruiseweed
        { id = 2452, count = 1 },  -- Swiftthistle
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 13458, name = "Greater Nature Protection Potion", recipe = {
        { id = 7067,  count = 1 },  -- Elemental Earth
        { id = 13463, count = 1 },  -- Dreamfoil
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 6052,  name = "Nature Protection Potion", recipe = {
        { id = 3357, count = 1 },  -- Liferoot
        { id = 3820, count = 1 },  -- Stranglekelp
        { id = 3372, count = 1 },  -- Leaded Vial
      } },
      { id = 13459, name = "Greater Shadow Protection Potion", recipe = {
        { id = 13463, count = 1 },  -- Dreamfoil
        { id = 3824,  count = 1 },  -- Shadow Oil
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 6048,  name = "Shadow Protection Potion", recipe = {
        { id = 3369, count = 1 },  -- Grave Moss
        { id = 3356, count = 1 },  -- Kingsblood
        { id = 3372, count = 1 },  -- Leaded Vial
      } },
    }},
    { category = "Food & Drink", items = {
      { id = 20452, name = "Smoked Desert Dumplings", classes = STR, recipe = {
        { id = 20424, count = 1 },  -- Sandworm Meat
      } },
      { id = 13931, name = "Nightfin Soup", classes = MANA, recipe = {
        { id = 13759, count = 1 },  -- Raw Nightfin Snapper
        { id = 159,   count = 1 },  -- Refreshing Spring Water
      } },
      { id = 13928, name = "Grilled Squid", classes = AGI, recipe = {
        { id = 13755, count = 1 },  -- Winter Squid
      } },
      { id = 21217, name = "Sagefish Delight", classes = MANA, recipe = {
        { id = 21153, count = 1 },  -- Raw Greater Sagefish
      } },
      { id = 18254, name = "Runn Tum Tuber Surprise", classes = MANA, recipe = {
        { id = 18255, count = 1 },  -- Runn Tum Tuber
      } },
      { id = 13810, name = "Blessed Sunfruit",       classes = STR, sources = {
        { kind = "vendor", zone = "Argent Quartermaster Hasana (Tirisfal Glades)" },
        { kind = "vendor", zone = "Argent Quartermaster Lightspark (Western Plaguelands)" },
        { kind = "vendor", zone = "Quartermaster Miranda Breechlock (Eastern Plaguelands)" },
      }},
      { id = 13813, name = "Blessed Sunfruit Juice", classes = MANA, sources = {
        { kind = "vendor", zone = "Argent Quartermaster Hasana (Tirisfal Glades)" },
        { kind = "vendor", zone = "Argent Quartermaster Lightspark (Western Plaguelands)" },
        { kind = "vendor", zone = "Quartermaster Miranda Breechlock (Eastern Plaguelands)" },
      }},
      { id = 21023, name = "Dirge's Kickin' Chimaerok Chops", recipe = {
        { id = 9061,  count = 1 },  -- Goblin Rocket Fuel
        { id = 8150,  count = 1 },  -- Deeprock Salt
        { id = 21024, count = 1 },  -- Chimaerok Tenderloin
      } },
      { id = 21151, name = "Rumsey Rum Black Label", sources = {               -- drop, universal
        { kind = "mob", zone = "World drop from Bloodsail / Southsea pirates", levels = "30-55",
          mobs = { { name = "Bloodsail Sea Dog / Southsea Pirate", chance = 1 } } },
        { kind = "vendor", zone = "Brewfest event vendor (autumn world event)" },
      }},
      { id = 18284, name = "Kreeg's Stout Beatdown", classes = MANA, sources = {
        { kind = "vendor", zone = "Stomper Kreeg (Dire Maul)" },
      }},
      { id = 18269, name = "Gordok Green Grog", sources = {
        { kind = "vendor", zone = "Stomper Kreeg (Dire Maul)" },
      }},
    }},
    { category = "Blasted Lands Buffs", items = {
      { id = 8410, name = "R.O.I.D.S.", classes = STR, recipe = {
        { id = 8391, count = 3 },  -- Snickerfang Jowl
        { id = 8392, count = 2 },  -- Blasted Boar Lung
        { id = 8393, count = 1 },  -- Scorpok Pincer
      } },
      { id = 8412, name = "Ground Scorpok Assay", classes = AGI, recipe = {
        { id = 8393, count = 3 },  -- Scorpok Pincer
        { id = 8396, count = 2 },  -- Vulture Gizzard
        { id = 8392, count = 1 },  -- Blasted Boar Lung
      } },
      { id = 8411, name = "Lung Juice Cocktail", recipe = {
        { id = 8392, count = 3 },  -- Blasted Boar Lung
        { id = 8393, count = 2 },  -- Scorpok Pincer
        { id = 8394, count = 1 },  -- Basilisk Brain
      } },
      { id = 8423, name = "Cerebral Cortex Compound", classes = MANA, recipe = {
        { id = 8394, count = 10 }, -- Basilisk Brain
        { id = 8396, count = 2 },  -- Vulture Gizzard
      } },
      { id = 8424, name = "Gizzard Gum", classes = MANA, recipe = {
        { id = 8396, count = 10 }, -- Vulture Gizzard
        { id = 8391, count = 2 },  -- Snickerfang Jowl
      } },
      { separator = true },
      { id = 8391, name = "Snickerfang Jowl", sources = {
        { kind = "mob", zone = "Blasted Lands", levels = "45-55",
          mobs = { { name = "Starving Snickerfang", chance = 35.6 }, { name = "Snickerfang Hyena", chance = 35.4 }, { name = "Ravage", chance = 36.9 } } },
      }},
      { id = 8392, name = "Blasted Boar Lung", sources = {
        { kind = "mob", zone = "Blasted Lands", levels = "45-55",
          mobs = { { name = "Ashmane Boar", chance = 38.8 }, { name = "Helboar", chance = 39.2 }, { name = "Grunter", chance = 27.7 } } },
      }},
      { id = 8393, name = "Scorpok Pincer", sources = {
        { kind = "mob", zone = "Blasted Lands", levels = "45-55",
          mobs = { { name = "Scorpok Stinger", chance = 37.0 }, { name = "Clack the Reaver", chance = 30.7 } } },
      }},
      { id = 8396, name = "Vulture Gizzard", sources = {
        { kind = "mob", zone = "Blasted Lands", levels = "45-55",
          mobs = { { name = "Black Slayer", chance = 33.7 }, { name = "Spiteflayer", chance = 35.5 } } },
      }},
      { id = 8394, name = "Basilisk Brain", sources = {
        { kind = "mob", zone = "Blasted Lands", levels = "45-55",
          mobs = { { name = "Redstone Basilisk", chance = 38.1 }, { name = "Redstone Crystalhide", chance = 37.8 }, { name = "Deatheye", chance = 34.4 } } },
      }},
    }},
    { category = "Jujus", items = {
      { id = 12457, name = "Juju Chill",  recipe = { { id = 12434, count = 1 } } },
      { id = 12434, name = "Chillwind E'ko",   indent = "branch", roundUpTo = 3, sources = {
        { kind = "mob", zone = "Winterspring", levels = "53-60",
          mobs = { { name = "Chillwind Ravager", chance = 8.8 }, { name = "Chillwind Chimaera", chance = 5.4 }, { name = "Fledgling Chillwind", chance = 3.1 } } },
      }},
      { id = 12455, name = "Juju Ember",  recipe = { { id = 12432, count = 1 } } },
      { id = 12432, name = "Shardtooth E'ko",  indent = "branch", roundUpTo = 3, sources = {
        { kind = "mob", zone = "Winterspring", levels = "53-60",
          mobs = { { name = "Elder Shardtooth", chance = 8.0 }, { name = "Rabid Shardtooth", chance = 15.1 }, { name = "Shardtooth Mauler", chance = 7.1 } } },
      }},
      { id = 12459, name = "Juju Escape", recipe = { { id = 12435, count = 1 } } },
      { id = 12435, name = "Ice Thistle E'ko", indent = "branch", roundUpTo = 3, sources = {
        { kind = "mob", zone = "Winterspring", levels = "53-60",
          mobs = { { name = "Ice Thistle Yeti", chance = 4.8 }, { name = "Ice Thistle Patriarch", chance = 9.5 }, { name = "Ice Thistle Matriarch", chance = 8.8 } } },
      }},
      { id = 12450, name = "Juju Flurry", recipe = { { id = 12430, count = 1 } } },
      { id = 12430, name = "Frostsaber E'ko",  indent = "branch", roundUpTo = 3, sources = {
        { kind = "mob", zone = "Winterspring", levels = "53-60",
          mobs = { { name = "Frostsaber Stalker", chance = 7.0 }, { name = "Frostsaber Huntress", chance = 7.6 }, { name = "Frostsaber Cub", chance = 7.7 } } },
      }},
      { id = 12458, name = "Juju Guile",  recipe = { { id = 12433, count = 1 } } },
      { id = 12433, name = "Wildkin E'ko",     indent = "branch", roundUpTo = 3, sources = {
        { kind = "mob", zone = "Winterspring", levels = "53-60",
          mobs = { { name = "Moontouched Owlbeast", chance = 4.1 }, { name = "Berserk Owlbeast", chance = 4.2 }, { name = "Crazed Owlbeast", chance = 4.0 } } },
      }},
      { id = 12460, name = "Juju Might",  recipe = { { id = 12436, count = 1 } } },
      { id = 12436, name = "Frostmaul E'ko",   indent = "branch", roundUpTo = 3, sources = {
        { kind = "mob", zone = "Winterspring", levels = "53-60",
          mobs = { { name = "Frostmaul Giant", chance = 39.7 }, { name = "Frostmaul Preserver", chance = 40.6 } } },
      }},
      { id = 12451, name = "Juju Power",  recipe = { { id = 12431, count = 1 } } },
      { id = 12431, name = "Winterfall E'ko",  indent = "branch", roundUpTo = 3, sources = {
        { kind = "mob", zone = "Winterspring", levels = "53-60",
          mobs = { { name = "Winterfall Den Watcher", chance = 12.6 }, { name = "Winterfall Ursa", chance = 13.7 }, { name = "Winterfall Shaman", chance = 14.1 } } },
      }},
    }},
    { category = "Weapon Buffs", items = {
      { id = 18262, name = "Elemental Sharpening Stone", classes = MELEE, recipe = {
        { id = 7067,  count = 2 },  -- Elemental Earth
        { id = 12365, count = 3 },  -- Dense Stone
      } },
      { id = 12404, name = "Dense Sharpening Stone", classes = MELEE, recipe = {
        { id = 12365, count = 1 },  -- Dense Stone
      } },
      { id = 7964,  name = "Solid Sharpening Stone", classes = MELEE, recipe = {
        { id = 7912, count = 1 },  -- Solid Stone
      } },
      { id = 2871,  name = "Heavy Sharpening Stone", classes = MELEE, recipe = {
        { id = 2838, count = 1 },  -- Heavy Stone
      } },
      { id = 2863,  name = "Coarse Sharpening Stone", classes = MELEE, recipe = {
        { id = 2836, count = 1 },  -- Coarse Stone
      } },
      { id = 2862,  name = "Rough Sharpening Stone", classes = MELEE, recipe = {
        { id = 2835, count = 1 },  -- Rough Stone
      } },
      { id = 12643, name = "Dense Weightstone", classes = MELEE, recipe = {
        { id = 12365, count = 1 },  -- Dense Stone
        { id = 14047, count = 1 },  -- Runecloth
      } },
      { id = 7965,  name = "Solid Weightstone", classes = MELEE, recipe = {
        { id = 7912, count = 1 },  -- Solid Stone
        { id = 4306, count = 1 },  -- Silk Cloth
      } },
      { id = 3241,  name = "Heavy Weightstone", classes = MELEE, recipe = {
        { id = 2838, count = 1 },  -- Heavy Stone
        { id = 2592, count = 1 },  -- Wool Cloth
      } },
      { id = 3240,  name = "Coarse Weightstone", classes = MELEE, recipe = {
        { id = 2836, count = 1 },  -- Coarse Stone
        { id = 2592, count = 1 },  -- Wool Cloth
      } },
      { id = 3239,  name = "Rough Weightstone", classes = MELEE, recipe = {
        { id = 2835, count = 1 },  -- Rough Stone
        { id = 2589, count = 1 },  -- Linen Cloth
      } },
      { id = 20749, name = "Brilliant Wizard Oil", classes = CASTER, recipe = {
        { id = 14344, count = 2 },  -- Large Brilliant Shard
        { id = 4625,  count = 3 },  -- Firebloom
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 20750, name = "Wizard Oil", classes = CASTER, recipe = {
        { id = 16204, count = 3 },  -- Illusion Dust
        { id = 4625,  count = 2 },  -- Firebloom
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 20746, name = "Lesser Wizard Oil", classes = CASTER, recipe = {
        { id = 11137, count = 3 },  -- Vision Dust
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 20748, name = "Brilliant Mana Oil", classes = CASTER, recipe = {
        { id = 14344, count = 2 },  -- Large Brilliant Shard
        { id = 8831,  count = 3 },  -- Purple Lotus
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 20747, name = "Lesser Mana Oil", classes = CASTER, recipe = {
        { id = 11176, count = 3 },  -- Dream Dust
        { id = 8831,  count = 2 },  -- Purple Lotus
        { id = 8925,  count = 1 },  -- Crystal Vial
      } },
      { id = 3829,  name = "Frost Oil", classes = MELEE, recipe = {
        { id = 3358, count = 4 },  -- Khadgar's Whisker
        { id = 3819, count = 2 },  -- Wintersbite / Dragon's Teeth
        { id = 8925, count = 1 },  -- Crystal Vial
      } },
      { id = 3824,  name = "Shadow Oil", classes = MELEE, recipe = {
        { id = 3818, count = 4 },  -- Fadeleaf
        { id = 3369, count = 4 },  -- Grave Moss
        { id = 3372, count = 1 },  -- Leaded Vial
      } },
    }},
    { category = "Bandages", items = {
      { id = 14530, name = "Heavy Runecloth Bandage", recipe = {
        { id = 14047, count = 2 },  -- Runecloth
      } },
      { id = 14529, name = "Runecloth Bandage", recipe = {
        { id = 14047, count = 1 },  -- Runecloth
      } },
      { id = 8545,  name = "Heavy Mageweave Bandage", recipe = {
        { id = 4338, count = 2 },  -- Mageweave Cloth
      } },
      { id = 8544,  name = "Mageweave Bandage", recipe = {
        { id = 4338, count = 1 },  -- Mageweave Cloth
      } },
      { id = 6451,  name = "Heavy Silk Bandage", recipe = {
        { id = 4306, count = 2 },  -- Silk Cloth
      } },
      { id = 6450,  name = "Silk Bandage", recipe = {
        { id = 4306, count = 1 },  -- Silk Cloth
      } },
      { id = 3531,  name = "Heavy Wool Bandage", recipe = {
        { id = 2592, count = 2 },  -- Wool Cloth
      } },
      { id = 3530,  name = "Wool Bandage", recipe = {
        { id = 2592, count = 1 },  -- Wool Cloth
      } },
      { id = 2581,  name = "Heavy Linen Bandage", recipe = {
        { id = 2589, count = 2 },  -- Linen Cloth
      } },
      { id = 1251,  name = "Linen Bandage", recipe = {
        { id = 2589, count = 1 },  -- Linen Cloth
      } },
    }},
    { category = "Explosives", items = {
      { id = 18641, name = "Dense Dynamite", recipe = {
        yield = 2,
        { id = 15992, count = 2 }, -- Dense Blasting Powder
        { id = 14047, count = 2 }, -- Runecloth
      } },
      { id = 18588, name = "EZ-Thro Dynamite II", recipe = {
        { id = 10505, count = 1 }, -- Solid Blasting Powder
        { id = 4338,  count = 2 }, -- Mageweave Cloth
      } },
      { id = 6714,  name = "EZ-Thro Dynamite", recipe = {
        { id = 4357,  count = 4 }, -- Coarse Blasting Powder
        { id = 2592,  count = 1 }, -- Wool Cloth
      } },
      { id = 10646, name = "Goblin Sapper Charge", recipe = {
        { id = 4338,  count = 1 }, -- Mageweave Cloth
        { id = 10505, count = 3 }, -- Solid Blasting Powder
        { id = 10560, count = 1 }, -- Unstable Trigger
      } },
    }},
  },
}
