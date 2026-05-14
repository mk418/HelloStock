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
        { kind = "herb", zone = "Silithus", levels = "55-60", spawn_count = 31, avg_yield = 1.0, respawn = 4060 },
        { kind = "herb", zone = "Winterspring", levels = "53-60", spawn_count = 31, avg_yield = 1.0, respawn = 4060 },
        { kind = "herb", zone = "Burning Steppes", levels = "50-58", spawn_count = 31, avg_yield = 1.0, respawn = 4060 },
      }},
      { id = 13467, name = "Icecap", sources = {
        { kind = "herb", zone = "Winterspring", levels = "53-60", spawn_count = 182, avg_yield = 2.0, respawn = 300 },
      }},
      { id = 13466, name = "Plaguebloom", sources = {
        { kind = "herb", zone = "Scholomance", levels = "55-60", spawn_count = 64, avg_yield = 2.0, respawn = 300 },
        { kind = "herb", zone = "Eastern Plaguelands", levels = "53-60", spawn_count = 64, avg_yield = 2.0, respawn = 300 },
        { kind = "herb", zone = "Western Plaguelands", levels = "51-58", spawn_count = 64, avg_yield = 2.0, respawn = 300 },
        { kind = "herb", zone = "Felwood", levels = "48-55", spawn_count = 64, avg_yield = 2.0, respawn = 300 },
      }},
      { id = 13465, name = "Mountain Silversage", sources = {
        { kind = "herb", zone = "Zul'Gurub", levels = "60", spawn_count = 12, avg_yield = 1.54, respawn = 259200 },
        { kind = "herb", zone = "Winterspring", levels = "53-60", spawn_count = 93, avg_yield = 1.54, respawn = 403 },
        { kind = "herb", zone = "Eastern Plaguelands", levels = "53-60", spawn_count = 93, avg_yield = 1.54, respawn = 403 },
        { kind = "herb", zone = "Felwood", levels = "48-55", spawn_count = 93, avg_yield = 1.54, respawn = 403 },
        { kind = "herb", zone = "Azshara", levels = "45-55", spawn_count = 93, avg_yield = 1.54, respawn = 403 },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55", spawn_count = 1, avg_chance = 5.3, respawn = 10800,
          mobs = { { name = "Simone the Inconspicuous", chance = 5.3 } } },
      }},
      { id = 13464, name = "Golden Sansam", sources = {
        { kind = "herb", zone = "Zul'Gurub", levels = "60", spawn_count = 17, avg_yield = 1.48, respawn = 259200 },
        { kind = "herb", zone = "Eastern Plaguelands", levels = "53-60", spawn_count = 124, avg_yield = 1.48, respawn = 399 },
        { kind = "herb", zone = "Un'Goro Crater", levels = "48-55", spawn_count = 124, avg_yield = 1.48, respawn = 399 },
        { kind = "herb", zone = "Felwood", levels = "48-55", spawn_count = 124, avg_yield = 1.48, respawn = 399 },
        { kind = "herb", zone = "Azshara", levels = "45-55", spawn_count = 124, avg_yield = 1.48, respawn = 399 },
        { kind = "vendor", zone = "Lhara (Elwynn Forest / Mulgore)" },
      }},
      { id = 13463, name = "Dreamfoil", sources = {
        { kind = "herb", zone = "Zul'Gurub", levels = "60", spawn_count = 17, avg_yield = 1.59, respawn = 259200 },
        { kind = "herb", zone = "Eastern Plaguelands", levels = "53-60", spawn_count = 158, avg_yield = 1.59, respawn = 389 },
        { kind = "herb", zone = "Un'Goro Crater", levels = "48-55", spawn_count = 158, avg_yield = 1.59, respawn = 389 },
        { kind = "herb", zone = "Felwood", levels = "48-55", spawn_count = 158, avg_yield = 1.59, respawn = 389 },
        { kind = "herb", zone = "Azshara", levels = "45-55", spawn_count = 158, avg_yield = 1.59, respawn = 389 },
        { kind = "herb", zone = "Dire Maul (East)", levels = "55-60", spawn_count = 8, avg_yield = 1.59, respawn = 7200 },
        { kind = "vendor", zone = "Lhara (Elwynn Forest / Mulgore)" },
      }},
      { id = 8846,  name = "Gromsblood", sources = {
        { kind = "herb", zone = "Felwood", levels = "48-55", spawn_count = 20, avg_yield = 2.0, respawn = 515 },
        { kind = "herb", zone = "Blasted Lands", levels = "45-55", spawn_count = 20, avg_yield = 2.0, respawn = 515 },
        { kind = "herb", zone = "Desolace", levels = "30-40", spawn_count = 20, avg_yield = 2.0, respawn = 515 },
        { kind = "herb", zone = "Ashenvale", levels = "18-30", spawn_count = 20, avg_yield = 2.0, respawn = 515 },
        { kind = "herb", zone = "Dire Maul (East)", levels = "55-60", spawn_count = 3, avg_yield = 2.0, respawn = 7200 },
        { kind = "vendor", zone = "Vi'el (Winterspring)" },
      }},
      { id = 8845,  name = "Ghost Mushroom", sources = {
        { kind = "herb", zone = "Alterac Valley", levels = "51-60", spawn_count = 12, avg_yield = 2.0, respawn = 300 },
        { kind = "herb", zone = "The Hinterlands", levels = "40-50", spawn_count = 12, avg_yield = 2.0, respawn = 300 },
        { kind = "herb", zone = "Desolace", levels = "30-40", spawn_count = 12, avg_yield = 2.0, respawn = 300 },
        { kind = "herb", zone = "Maraudon", levels = "40-50", spawn_count = 8, avg_yield = 2.0, respawn = 7200 },
        { kind = "herb", zone = "Dire Maul", levels = "55-60", spawn_count = 4, avg_yield = 2.0, respawn = 7200 },
        { kind = "vendor", zone = "Lhara (Elwynn Forest / Mulgore)" },
      }},
      { id = 8839,  name = "Blindweed", sources = {
        { kind = "herb", zone = "Alterac Valley", levels = "51-60", spawn_count = 92, avg_yield = 1.31, respawn = 408 },
        { kind = "herb", zone = "Un'Goro Crater", levels = "48-55", spawn_count = 92, avg_yield = 1.31, respawn = 408 },
        { kind = "herb", zone = "Swamp of Sorrows", levels = "35-45", spawn_count = 92, avg_yield = 1.31, respawn = 408 },
        { kind = "herb", zone = "Maraudon", levels = "40-50", spawn_count = 4, avg_yield = 1.31, respawn = 7200 },
      }},
      { id = 8838,  name = "Sungrass", sources = {
        { kind = "herb", zone = "Zul'Gurub", levels = "60", spawn_count = 7, avg_yield = 1.58, respawn = 259200 },
        { kind = "herb", zone = "Felwood", levels = "48-55", spawn_count = 118, avg_yield = 1.58, respawn = 376 },
        { kind = "herb", zone = "Azshara", levels = "45-55", spawn_count = 118, avg_yield = 1.58, respawn = 376 },
        { kind = "herb", zone = "Feralas", levels = "40-50", spawn_count = 118, avg_yield = 1.58, respawn = 376 },
        { kind = "herb", zone = "The Hinterlands", levels = "40-50", spawn_count = 118, avg_yield = 1.58, respawn = 376 },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55", spawn_count = 1, avg_chance = 5.3, respawn = 10800,
          mobs = { { name = "Simone the Inconspicuous", chance = 5.3 } } },
        { kind = "mob", zone = "Blasted Lands", levels = "45-55", spawn_count = 1, avg_chance = 6.1, respawn = 64800,
          mobs = { { name = "Teremus the Devourer", chance = 6.1 } } },
      }},
      { id = 8836,  name = "Arthas' Tears", sources = {
        { kind = "herb", zone = "Eastern Plaguelands", levels = "53-60", spawn_count = 43, avg_yield = 2.0, respawn = 374 },
        { kind = "herb", zone = "Western Plaguelands", levels = "51-58", spawn_count = 43, avg_yield = 2.0, respawn = 374 },
        { kind = "herb", zone = "Felwood", levels = "48-55", spawn_count = 43, avg_yield = 2.0, respawn = 374 },
        { kind = "herb", zone = "Razorfen Downs", levels = "30-45", spawn_count = 12, avg_yield = 2.0, respawn = 86400 },
      }},
      { id = 8831,  name = "Purple Lotus", sources = {
        { kind = "herb", zone = "Zul'Gurub", levels = "60", spawn_count = 9, avg_yield = 1.2, respawn = 259200 },
        { kind = "herb", zone = "Azshara", levels = "45-55", spawn_count = 168, avg_yield = 1.2, respawn = 420 },
        { kind = "herb", zone = "The Hinterlands", levels = "40-50", spawn_count = 168, avg_yield = 1.2, respawn = 420 },
        { kind = "herb", zone = "Feralas", levels = "40-50", spawn_count = 168, avg_yield = 1.2, respawn = 420 },
      }},
      { id = 4625,  name = "Firebloom", sources = {
        { kind = "herb", zone = "Blasted Lands", levels = "45-55", spawn_count = 85, avg_yield = 1.22, respawn = 415 },
        { kind = "herb", zone = "Searing Gorge", levels = "43-52", spawn_count = 85, avg_yield = 1.22, respawn = 415 },
        { kind = "herb", zone = "Tanaris", levels = "40-50", spawn_count = 85, avg_yield = 1.22, respawn = 415 },
      }},
      { id = 3819,  name = "Wintersbite", sources = {
        { kind = "herb", zone = "Alterac Mountains", levels = "30-40", spawn_count = 34, avg_yield = 2.0, respawn = 300 },
      }},
      { id = 3358,  name = "Khadgar's Whisker", sources = {
        { kind = "herb", zone = "Feralas", levels = "40-50", spawn_count = 252, avg_yield = 1.29, respawn = 419 },
        { kind = "herb", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 252, avg_yield = 1.29, respawn = 419 },
        { kind = "herb", zone = "Arathi Highlands", levels = "30-40", spawn_count = 252, avg_yield = 1.29, respawn = 419 },
        { kind = "vendor", zone = "Lhara (Elwynn Forest / Mulgore)" },
      }},
      { id = 3821,  name = "Goldthorn", sources = {
        { kind = "herb", zone = "Feralas", levels = "40-50", spawn_count = 264, avg_yield = 1.73, respawn = 341 },
        { kind = "herb", zone = "Dustwallow Marsh", levels = "35-45", spawn_count = 264, avg_yield = 1.73, respawn = 341 },
        { kind = "herb", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 264, avg_yield = 1.73, respawn = 341 },
      }},
      { id = 3818,  name = "Fadeleaf", sources = {
        { kind = "herb", zone = "Dustwallow Marsh", levels = "35-45", spawn_count = 202, avg_yield = 0.88, respawn = 471 },
        { kind = "herb", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 202, avg_yield = 0.88, respawn = 471 },
        { kind = "herb", zone = "Alterac Mountains", levels = "30-40", spawn_count = 202, avg_yield = 0.88, respawn = 471 },
        { kind = "herb", zone = "Scarlet Monastery (Library)", levels = "32-42", spawn_count = 1, avg_yield = 0.88, respawn = 7200 },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 23, avg_chance = 10.6, respawn = 300, per_hour = 29.2,
          mobs = { { name = "Kurzen Medicine Man", chance = 10.6 } } },
      }},
      { id = 3357,  name = "Liferoot", sources = {
        { kind = "herb", zone = "Dustwallow Marsh", levels = "35-45", spawn_count = 238, avg_yield = 1.05, respawn = 451 },
        { kind = "herb", zone = "Swamp of Sorrows", levels = "35-45", spawn_count = 238, avg_yield = 1.05, respawn = 451 },
        { kind = "herb", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 238, avg_yield = 1.05, respawn = 451 },
        { kind = "herb", zone = "Scarlet Monastery (Cathedral)", levels = "36-45", spawn_count = 1, avg_yield = 1.05, respawn = 7200 },
        { kind = "dungeon", zone = "Zul'Farrak", levels = "40-50", spawn_count = 1, avg_chance = 66.7, respawn = 86400,
          mobs = { { name = "Weegli Blastfuse", chance = 66.7 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 23, avg_chance = 10.3, respawn = 300, per_hour = 28.3,
          mobs = { { name = "Kurzen Medicine Man", chance = 10.3 } } },
      }},
      { id = 3356,  name = "Kingsblood", sources = {
        { kind = "herb", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 322, avg_yield = 0.81, respawn = 450 },
        { kind = "herb", zone = "Wetlands", levels = "20-30", spawn_count = 322, avg_yield = 0.81, respawn = 450 },
        { kind = "herb", zone = "Hillsbrad Foothills", levels = "20-30", spawn_count = 322, avg_yield = 0.81, respawn = 450 },
        { kind = "mob", zone = "Ashenvale", levels = "18-30", spawn_count = 29, avg_chance = 5.6, respawn = 300, per_hour = 19.5,
          mobs = { { name = "Shadethicket Stone Mover", chance = 5.6 } } },
      }},
      { id = 3369,  name = "Grave Moss", sources = {
        { kind = "herb", zone = "Desolace", levels = "30-40", spawn_count = 35, avg_yield = 2.0, respawn = 300 },
        { kind = "herb", zone = "Wetlands", levels = "20-30", spawn_count = 35, avg_yield = 2.0, respawn = 300 },
        { kind = "herb", zone = "Duskwood", levels = "18-30", spawn_count = 35, avg_yield = 2.0, respawn = 300 },
        { kind = "herb", zone = "Scarlet Monastery (Graveyard)", levels = "28-38", spawn_count = 2, avg_yield = 2.0, respawn = 7200 },
      }},
      { id = 3355,  name = "Wild Steelbloom", sources = {
        { kind = "herb", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 298, avg_yield = 1.18, respawn = 423 },
        { kind = "herb", zone = "Arathi Highlands", levels = "30-40", spawn_count = 298, avg_yield = 1.18, respawn = 423 },
        { kind = "herb", zone = "Stonetalon Mountains", levels = "15-30", spawn_count = 298, avg_yield = 1.18, respawn = 423 },
      }},
      { id = 2453,  name = "Bruiseweed", sources = {
        { kind = "herb", zone = "Duskwood", levels = "18-30", spawn_count = 415, avg_yield = 1.43, respawn = 401 },
        { kind = "herb", zone = "Stonetalon Mountains", levels = "15-30", spawn_count = 415, avg_yield = 1.43, respawn = 401 },
        { kind = "herb", zone = "Redridge Mountains", levels = "15-25", spawn_count = 415, avg_yield = 1.43, respawn = 401 },
        { kind = "herb", zone = "The Barrens", levels = "10-25", spawn_count = 415, avg_yield = 1.43, respawn = 401 },
        { kind = "mob", zone = "Wetlands", levels = "20-30", spawn_count = 3, avg_chance = 6.7, respawn = 300, per_hour = 2.4,
          mobs = { { name = "Fen Lord", chance = 6.7 } } },
      }},
      { id = 3820,  name = "Stranglekelp", sources = {
        { kind = "herb", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 181, avg_yield = 2.0, respawn = 354 },
        { kind = "herb", zone = "Wetlands", levels = "20-30", spawn_count = 181, avg_yield = 2.0, respawn = 354 },
        { kind = "herb", zone = "Westfall", levels = "10-20", spawn_count = 181, avg_yield = 2.0, respawn = 354 },
      }},
      { id = 2450,  name = "Briarthorn", sources = {
        { kind = "herb", zone = "Duskwood", levels = "18-30", spawn_count = 265, avg_yield = 1.13, respawn = 451 },
        { kind = "herb", zone = "Redridge Mountains", levels = "15-25", spawn_count = 265, avg_yield = 1.13, respawn = 451 },
        { kind = "herb", zone = "The Barrens", levels = "10-25", spawn_count = 265, avg_yield = 1.13, respawn = 451 },
        { kind = "herb", zone = "Silverpine Forest", levels = "10-20", spawn_count = 265, avg_yield = 1.13, respawn = 451 },
        { kind = "mob", zone = "Wetlands", levels = "20-30", spawn_count = 17, avg_chance = 5.1, respawn = 300, per_hour = 10.4,
          mobs = { { name = "Fen Dweller", chance = 5.1 } } },
      }},
      { id = 2452,  name = "Swiftthistle", sources = {
        { kind = "herb", zone = "Duskwood", levels = "18-30", spawn_count = 274, avg_yield = 0.42, respawn = 385 },
        { kind = "herb", zone = "Redridge Mountains", levels = "15-25", spawn_count = 274, avg_yield = 0.42, respawn = 385 },
        { kind = "herb", zone = "The Barrens", levels = "10-25", spawn_count = 274, avg_yield = 0.42, respawn = 385 },
        { kind = "herb", zone = "Silverpine Forest", levels = "10-20", spawn_count = 274, avg_yield = 0.42, respawn = 385 },
        { kind = "herb", zone = "Loch Modan", levels = "10-20", spawn_count = 274, avg_yield = 0.42, respawn = 385 },
        { kind = "herb", zone = "Westfall", levels = "10-20", spawn_count = 274, avg_yield = 0.42, respawn = 385 },
      }},
      { id = 785,   name = "Mageroyal", sources = {
        { kind = "herb", zone = "The Barrens", levels = "10-25", spawn_count = 262, avg_yield = 1.22, respawn = 431 },
        { kind = "herb", zone = "Silverpine Forest", levels = "10-20", spawn_count = 262, avg_yield = 1.22, respawn = 431 },
        { kind = "herb", zone = "Loch Modan", levels = "10-20", spawn_count = 262, avg_yield = 1.22, respawn = 431 },
        { kind = "herb", zone = "Westfall", levels = "10-20", spawn_count = 262, avg_yield = 1.22, respawn = 431 },
        { kind = "mob", zone = "Wetlands", levels = "20-30", spawn_count = 36, avg_chance = 6.9, respawn = 300, per_hour = 30.0,
          mobs = { { name = "Fen Creeper", chance = 7.8 }, { name = "Fen Dweller", chance = 6.0 } } },
      }},
      { id = 2449,  name = "Earthroot", sources = {
        { kind = "herb", zone = "The Barrens", levels = "10-25", spawn_count = 260, avg_yield = 0.99, respawn = 468 },
        { kind = "herb", zone = "Tirisfal Glades", levels = "1-10", spawn_count = 260, avg_yield = 0.99, respawn = 468 },
        { kind = "herb", zone = "Teldrassil", levels = "1-10", spawn_count = 260, avg_yield = 0.99, respawn = 468 },
        { kind = "herb", zone = "Dun Morogh", levels = "1-10", spawn_count = 260, avg_yield = 0.99, respawn = 468 },
        { kind = "mob", zone = "Wetlands", levels = "20-30", spawn_count = 20, avg_chance = 5.8, respawn = 300, per_hour = 13.9,
          mobs = { { name = "Fen Lord", chance = 6.2 }, { name = "Fen Dweller", chance = 5.7 } } },
        { kind = "mob", zone = "Teldrassil", levels = "1-10", spawn_count = 12, avg_chance = 5.5, respawn = 300, per_hour = 7.9,
          mobs = { { name = "Timberling Bark Ripper", chance = 5.5 } } },
      }},
      { id = 765,   name = "Silverleaf", sources = {
        { kind = "herb", zone = "The Barrens", levels = "10-25", spawn_count = 326, avg_yield = 1.39, respawn = 410 },
        { kind = "herb", zone = "Tirisfal Glades", levels = "1-10", spawn_count = 326, avg_yield = 1.39, respawn = 410 },
        { kind = "herb", zone = "Elwynn Forest", levels = "1-10", spawn_count = 326, avg_yield = 1.39, respawn = 410 },
        { kind = "herb", zone = "Teldrassil", levels = "1-10", spawn_count = 326, avg_yield = 1.39, respawn = 410 },
        { kind = "mob", zone = "Wetlands", levels = "20-30", spawn_count = 3, avg_chance = 5.2, respawn = 300, per_hour = 1.9,
          mobs = { { name = "Fen Lord", chance = 5.2 } } },
        { kind = "vendor", zone = "Maria Lumere (Stormwind City)" },
        { kind = "vendor", zone = "Hula'mahi (The Barrens)" },
        { kind = "vendor", zone = "Selina Weston (Tirisfal Glades)" },
      }},
      { id = 2447,  name = "Peacebloom", sources = {
        { kind = "herb", zone = "The Barrens", levels = "10-25", spawn_count = 238, avg_yield = 1.18, respawn = 447 },
        { kind = "herb", zone = "Durotar", levels = "1-10", spawn_count = 238, avg_yield = 1.18, respawn = 447 },
        { kind = "herb", zone = "Tirisfal Glades", levels = "1-10", spawn_count = 238, avg_yield = 1.18, respawn = 447 },
        { kind = "herb", zone = "Teldrassil", levels = "1-10", spawn_count = 238, avg_yield = 1.18, respawn = 447 },
        { kind = "mob", zone = "Wetlands", levels = "20-30", spawn_count = 17, avg_chance = 5.0, respawn = 300, per_hour = 10.2,
          mobs = { { name = "Fen Dweller", chance = 5.0 } } },
        { kind = "mob", zone = "Teldrassil", levels = "1-10", spawn_count = 12, avg_chance = 5.1, respawn = 300, per_hour = 7.4,
          mobs = { { name = "Timberling Bark Ripper", chance = 5.1 } } },
        { kind = "vendor", zone = "Maria Lumere (Stormwind City)" },
        { kind = "vendor", zone = "Hula'mahi (The Barrens)" },
        { kind = "vendor", zone = "Selina Weston (Tirisfal Glades)" },
      }},
    }},
    { category = "Ores & Bars", items = {
      { id = 12360, name = "Arcanite Bar", hasCooldown = true, recipe = {
        -- Alchemy transmute (4-day cooldown). One cast yields one bar.
        { id = 12363, count = 1 },  -- Arcane Crystal
        { id = 12359, count = 1 },  -- Thorium Bar
      } },
      { id = 12363, name = "Arcane Crystal", sources = {
        { kind = "mine", zone = "Zul'Gurub", levels = "60" },
        { kind = "mine", zone = "Ahn'Qiraj", levels = "60" },
        { kind = "mine", zone = "Silithus", levels = "55-60" },
        { kind = "mine", zone = "Ruins of Ahn'Qiraj", levels = "55-60" },
        { kind = "mine", zone = "Winterspring", levels = "53-60" },
        { kind = "mine", zone = "Eastern Plaguelands", levels = "53-60" },
        { kind = "mine", zone = "Azshara", levels = "45-55" },
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
        { kind = "mine", zone = "Alterac Valley", levels = "51-60", spawn_count = 28, avg_yield = 1.0, respawn = 300 },
        { kind = "mine", zone = "Burning Steppes", levels = "50-58", spawn_count = 28, avg_yield = 1.0, respawn = 300 },
        { kind = "mine", zone = "Searing Gorge", levels = "43-52", spawn_count = 28, avg_yield = 1.0, respawn = 300 },
        { kind = "mine", zone = "Blackrock Depths", levels = "52-60", spawn_count = 6, avg_yield = 1.0, respawn = 7200 },
        { kind = "dungeon", zone = "Blackrock Depths", levels = "52-60", spawn_count = 34, avg_chance = 15.9, respawn = 7200, per_hour = 2.7,
          mobs = { { name = "Warbringer Construct", chance = 17.0 }, { name = "Ragereaver Golem", chance = 16.1 }, { name = "Wrath Hammer Construct", chance = 15.6 } } },
      }},
      { id = 12359, name = "Thorium Bar", recipe = {
        { id = 10620, count = 1 },  -- Thorium Ore
      } },
      { id = 10620, name = "Thorium Ore", sources = {
        { kind = "mine", zone = "Zul'Gurub", levels = "60", spawn_count = 13, avg_yield = 1.0, respawn = 300 },
        { kind = "mine", zone = "Silithus", levels = "55-60", spawn_count = 13, avg_yield = 1.0, respawn = 300 },
        { kind = "mine", zone = "Winterspring", levels = "53-60", spawn_count = 13, avg_yield = 1.0, respawn = 300 },
        { kind = "mine", zone = "Eastern Plaguelands", levels = "53-60", spawn_count = 13, avg_yield = 1.0, respawn = 300 },
        { kind = "mine", zone = "Burning Steppes", levels = "50-58", spawn_count = 13, avg_yield = 1.0, respawn = 300 },
        { kind = "mine", zone = "Un'Goro Crater", levels = "48-55", spawn_count = 13, avg_yield = 1.0, respawn = 300 },
        { kind = "mine", zone = "Felwood", levels = "48-55", spawn_count = 13, avg_yield = 1.0, respawn = 300 },
        { kind = "mine", zone = "Blasted Lands", levels = "45-55", spawn_count = 13, avg_yield = 1.0, respawn = 300 },
        { kind = "mine", zone = "Azshara", levels = "45-55", spawn_count = 13, avg_yield = 1.0, respawn = 300 },
        { kind = "mine", zone = "Feralas", levels = "40-50", spawn_count = 13, avg_yield = 1.0, respawn = 300 },
        { kind = "mob", zone = "Burning Steppes", levels = "50-58", spawn_count = 1, avg_chance = 9.0, respawn = 10800,
          mobs = { { name = "Franklin the Friendly", chance = 9.0 } } },
      }},
      { id = 6037,  name = "Truesilver Bar", recipe = {
        { id = 7911,  count = 1 },  -- Truesilver Ore
      } },
      { id = 7911,  name = "Truesilver Ore", sources = {
        { kind = "mine", zone = "Silithus", levels = "55-60", spawn_count = 83, avg_yield = 0.69, respawn = 393 },
        { kind = "mine", zone = "Winterspring", levels = "53-60", spawn_count = 83, avg_yield = 0.69, respawn = 393 },
        { kind = "mine", zone = "Un'Goro Crater", levels = "48-55", spawn_count = 83, avg_yield = 0.69, respawn = 393 },
        { kind = "mine", zone = "Felwood", levels = "48-55", spawn_count = 83, avg_yield = 0.69, respawn = 393 },
        { kind = "mine", zone = "Azshara", levels = "45-55", spawn_count = 83, avg_yield = 0.69, respawn = 393 },
        { kind = "mine", zone = "Blasted Lands", levels = "45-55", spawn_count = 83, avg_yield = 0.69, respawn = 393 },
        { kind = "mine", zone = "The Hinterlands", levels = "40-50", spawn_count = 83, avg_yield = 0.69, respawn = 393 },
        { kind = "mine", zone = "Feralas", levels = "40-50", spawn_count = 83, avg_yield = 0.69, respawn = 393 },
      }},
      { id = 3860,  name = "Mithril Bar", recipe = {
        { id = 3858,  count = 1 },  -- Mithril Ore
      } },
      { id = 3858,  name = "Mithril Ore", sources = {
        { kind = "mine", zone = "Felwood", levels = "48-55", spawn_count = 132, avg_yield = 0.61, respawn = 418 },
        { kind = "mine", zone = "Azshara", levels = "45-55", spawn_count = 132, avg_yield = 0.61, respawn = 418 },
        { kind = "mine", zone = "Blasted Lands", levels = "45-55", spawn_count = 132, avg_yield = 0.61, respawn = 418 },
        { kind = "mine", zone = "The Hinterlands", levels = "40-50", spawn_count = 132, avg_yield = 0.61, respawn = 418 },
        { kind = "mine", zone = "Tanaris", levels = "40-50", spawn_count = 132, avg_yield = 0.61, respawn = 418 },
        { kind = "mine", zone = "Feralas", levels = "40-50", spawn_count = 132, avg_yield = 0.61, respawn = 418 },
        { kind = "mine", zone = "Thousand Needles", levels = "25-35", spawn_count = 132, avg_yield = 0.61, respawn = 418 },
        { kind = "mine", zone = "Uldaman", levels = "35-45", spawn_count = 2, avg_yield = 0.61, respawn = 7200 },
        { kind = "mine", zone = "Maraudon", levels = "40-50", spawn_count = 6, avg_yield = 0.61, respawn = 7200 },
      }},
      { id = 3577,  name = "Gold Bar", recipe = {
        { id = 2776,  count = 1 },  -- Gold Ore
      } },
      { id = 2776,  name = "Gold Ore", sources = {
        { kind = "mine", zone = "Felwood", levels = "48-55", spawn_count = 216, avg_yield = 0.76, respawn = 371 },
        { kind = "mine", zone = "Blasted Lands", levels = "45-55", spawn_count = 216, avg_yield = 0.76, respawn = 371 },
        { kind = "mine", zone = "Feralas", levels = "40-50", spawn_count = 216, avg_yield = 0.76, respawn = 371 },
        { kind = "mine", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 216, avg_yield = 0.76, respawn = 371 },
        { kind = "mine", zone = "Desolace", levels = "30-40", spawn_count = 216, avg_yield = 0.76, respawn = 371 },
        { kind = "mine", zone = "Arathi Highlands", levels = "30-40", spawn_count = 216, avg_yield = 0.76, respawn = 371 },
        { kind = "mine", zone = "Thousand Needles", levels = "25-35", spawn_count = 216, avg_yield = 0.76, respawn = 371 },
      }},
      { id = 3575,  name = "Iron Bar", recipe = {
        { id = 2772,  count = 1 },  -- Iron Ore
      } },
      { id = 2772,  name = "Iron Ore", sources = {
        { kind = "mine", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 465, avg_yield = 0.71, respawn = 388 },
        { kind = "mine", zone = "Arathi Highlands", levels = "30-40", spawn_count = 465, avg_yield = 0.71, respawn = 388 },
        { kind = "mine", zone = "Desolace", levels = "30-40", spawn_count = 465, avg_yield = 0.71, respawn = 388 },
        { kind = "mine", zone = "Uldaman", levels = "35-45", spawn_count = 2, avg_yield = 0.71, respawn = 7200 },
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
        { kind = "mine", zone = "Hillsbrad Foothills", levels = "20-30", spawn_count = 263, avg_yield = 0.64, respawn = 406 },
        { kind = "mine", zone = "Ashenvale", levels = "18-30", spawn_count = 263, avg_yield = 0.64, respawn = 406 },
        { kind = "mine", zone = "Redridge Mountains", levels = "15-25", spawn_count = 263, avg_yield = 0.64, respawn = 406 },
        { kind = "mine", zone = "The Barrens", levels = "10-25", spawn_count = 263, avg_yield = 0.64, respawn = 406 },
        { kind = "mine", zone = "Loch Modan", levels = "10-20", spawn_count = 263, avg_yield = 0.64, respawn = 406 },
        { kind = "dungeon", zone = "The Deadmines", levels = "15-25", spawn_count = 1, avg_chance = 99.3, respawn = 86400,
          mobs = { { name = "Defias Squallshaper", chance = 99.3 } } },
      }},
      { id = 2840,  name = "Copper Bar", recipe = {
        { id = 2770,  count = 1 },  -- Copper Ore
      } },
      { id = 2770,  name = "Copper Ore", sources = {
        { kind = "mine", zone = "Redridge Mountains", levels = "15-25", spawn_count = 548, avg_yield = 0.74, respawn = 382 },
        { kind = "mine", zone = "The Barrens", levels = "10-25", spawn_count = 548, avg_yield = 0.74, respawn = 382 },
        { kind = "mine", zone = "Dun Morogh", levels = "1-10", spawn_count = 548, avg_yield = 0.74, respawn = 382 },
        { kind = "mine", zone = "Elwynn Forest", levels = "1-10", spawn_count = 548, avg_yield = 0.74, respawn = 382 },
        { kind = "dungeon", zone = "The Deadmines", levels = "15-25", spawn_count = 13, avg_chance = 99.3, respawn = 7200, per_hour = 6.5,
          mobs = { { name = "Goblin Craftsman", chance = 99.3 } } },
      }},
    }},
    { category = "Stones", items = {
      { id = 12365, name = "Dense Stone", sources = {
        { kind = "mine", zone = "Zul'Gurub", levels = "60", spawn_count = 13, avg_yield = 0.8, respawn = 300 },
        { kind = "mine", zone = "Silithus", levels = "55-60", spawn_count = 13, avg_yield = 0.8, respawn = 300 },
        { kind = "mine", zone = "Winterspring", levels = "53-60", spawn_count = 13, avg_yield = 0.8, respawn = 300 },
        { kind = "mine", zone = "Eastern Plaguelands", levels = "53-60", spawn_count = 13, avg_yield = 0.8, respawn = 300 },
        { kind = "mine", zone = "Burning Steppes", levels = "50-58", spawn_count = 13, avg_yield = 0.8, respawn = 300 },
        { kind = "mine", zone = "Un'Goro Crater", levels = "48-55", spawn_count = 13, avg_yield = 0.8, respawn = 300 },
        { kind = "mine", zone = "Felwood", levels = "48-55", spawn_count = 13, avg_yield = 0.8, respawn = 300 },
        { kind = "mine", zone = "Blasted Lands", levels = "45-55", spawn_count = 13, avg_yield = 0.8, respawn = 300 },
        { kind = "mine", zone = "Azshara", levels = "45-55", spawn_count = 13, avg_yield = 0.8, respawn = 300 },
        { kind = "mine", zone = "Feralas", levels = "40-50", spawn_count = 13, avg_yield = 0.8, respawn = 300 },
      }},
      { id = 7912,  name = "Solid Stone", sources = {
        { kind = "mine", zone = "Felwood", levels = "48-55", spawn_count = 137, avg_yield = 0.59, respawn = 424 },
        { kind = "mine", zone = "Azshara", levels = "45-55", spawn_count = 137, avg_yield = 0.59, respawn = 424 },
        { kind = "mine", zone = "Blasted Lands", levels = "45-55", spawn_count = 137, avg_yield = 0.59, respawn = 424 },
        { kind = "mine", zone = "The Hinterlands", levels = "40-50", spawn_count = 137, avg_yield = 0.59, respawn = 424 },
        { kind = "mine", zone = "Tanaris", levels = "40-50", spawn_count = 137, avg_yield = 0.59, respawn = 424 },
        { kind = "mine", zone = "Feralas", levels = "40-50", spawn_count = 137, avg_yield = 0.59, respawn = 424 },
        { kind = "mine", zone = "Thousand Needles", levels = "25-35", spawn_count = 137, avg_yield = 0.59, respawn = 424 },
        { kind = "dungeon", zone = "Molten Core", levels = "60", spawn_count = 32, avg_chance = 7.6, respawn = 5130, per_hour = 3.2,
          mobs = { { name = "Lava Surger", chance = 10.2 }, { name = "Lava Annihilator", chance = 7.4 }, { name = "Lava Elemental", chance = 6.1 } } },
        { kind = "dungeon", zone = "Blackrock Depths", levels = "52-60", spawn_count = 36, avg_chance = 28.9, respawn = 40400, per_hour = 5.1,
          mobs = { { name = "Wrath Hammer Construct", chance = 30.4 }, { name = "Ragereaver Golem", chance = 30.2 }, { name = "Molten War Golem", chance = 30.1 } } },
        { kind = "dungeon", zone = "Maraudon (Inner)", levels = "40-50", spawn_count = 25, avg_chance = 33.6, respawn = 10080, per_hour = 4.1,
          mobs = { { name = "Primordial Behemoth", chance = 38.8 }, { name = "Theradrim Shardling", chance = 26.3 }, { name = "Theradrim Guardian", chance = 26.2 } } },
        { kind = "dungeon", zone = "Maraudon", levels = "40-50", spawn_count = 25, avg_chance = 28.0, respawn = 10080, per_hour = 3.4,
          mobs = { { name = "Primordial Behemoth", chance = 30.4 }, { name = "Theradrim Guardian", chance = 25.7 }, { name = "Princess Theradras", chance = 18.0 } } },
        { kind = "dungeon", zone = "Uldaman", levels = "35-45", spawn_count = 22, avg_chance = 32.4, respawn = 17018, per_hour = 2.8,
          mobs = { { name = "Stone Keeper", chance = 39.4 }, { name = "Stone Steward", chance = 35.6 }, { name = "Vault Warder", chance = 29.1 } } },
        { kind = "mob", zone = "Silithus", levels = "55-60", spawn_count = 32, avg_chance = 29.5, respawn = 3441, per_hour = 110.5,
          mobs = { { name = "Desert Rager", chance = 30.1 }, { name = "Desert Rumbler", chance = 29.6 }, { name = "Setis", chance = 23.5 } } },
        { kind = "mob", zone = "Burning Steppes", levels = "50-58", spawn_count = 41, avg_chance = 33.2, respawn = 6507, per_hour = 87.5,
          mobs = { { name = "War Reaver", chance = 37.9 }, { name = "Greater Obsidian Elemental", chance = 30.4 }, { name = "Obsidian Elemental", chance = 30.4 } } },
        { kind = "mob", zone = "Searing Gorge", levels = "43-52", spawn_count = 37, avg_chance = 39.5, respawn = 8616, per_hour = 93.8,
          mobs = { { name = "Tempered War Golem", chance = 43.2 }, { name = "Heavy War Golem", chance = 42.8 }, { name = "Faulty War Golem", chance = 27.0 } } },
        { kind = "mob", zone = "Badlands", levels = "35-45", spawn_count = 120, avg_chance = 25.8, respawn = 13580, per_hour = 303.9,
          mobs = { { name = "Stone Golem", chance = 45.0 }, { name = "Obsidian Golem", chance = 33.3 }, { name = "Fam'retor Guardian", chance = 28.8 } } },
        { kind = "mob", zone = "Arathi Highlands", levels = "30-40", spawn_count = 17, avg_chance = 22.8, respawn = 528, per_hour = 33.7,
          mobs = { { name = "Thenan", chance = 44.3 }, { name = "Rumbling Exile", chance = 23.2 }, { name = "Myzrael", chance = 18.0 } } },
      }},
      { id = 2838,  name = "Heavy Stone", sources = {
        { kind = "mine", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 466, avg_yield = 0.56, respawn = 389 },
        { kind = "mine", zone = "Arathi Highlands", levels = "30-40", spawn_count = 466, avg_yield = 0.56, respawn = 389 },
        { kind = "mine", zone = "Desolace", levels = "30-40", spawn_count = 466, avg_yield = 0.56, respawn = 389 },
        { kind = "mob", zone = "Alterac Mountains", levels = "30-40", spawn_count = 22, avg_chance = 28.5, respawn = 299, per_hour = 75.4,
          mobs = { { name = "Elemental Slave", chance = 28.5 } } },
        { kind = "mob", zone = "Thousand Needles", levels = "25-35", spawn_count = 15, avg_chance = 25.1, respawn = 400, per_hour = 43.4,
          mobs = { { name = "Thundering Boulderkin", chance = 25.6 }, { name = "Rok'Alim the Pounder", chance = 17.1 } } },
      }},
      { id = 2836,  name = "Coarse Stone", sources = {
        { kind = "mine", zone = "Hillsbrad Foothills", levels = "20-30", spawn_count = 263, avg_yield = 0.43, respawn = 406 },
        { kind = "mine", zone = "Ashenvale", levels = "18-30", spawn_count = 263, avg_yield = 0.43, respawn = 406 },
        { kind = "mine", zone = "Redridge Mountains", levels = "15-25", spawn_count = 263, avg_yield = 0.43, respawn = 406 },
        { kind = "mine", zone = "The Barrens", levels = "10-25", spawn_count = 263, avg_yield = 0.43, respawn = 406 },
        { kind = "mine", zone = "Loch Modan", levels = "10-20", spawn_count = 263, avg_yield = 0.43, respawn = 406 },
        { kind = "dungeon", zone = "The Deadmines", levels = "15-25", spawn_count = 1, avg_chance = 45.1, respawn = 86400,
          mobs = { { name = "Defias Squallshaper", chance = 45.1 } } },
        { kind = "dungeon", zone = "Ragefire Chasm", levels = "13-18", spawn_count = 13, avg_chance = 21.2, respawn = 7200, per_hour = 1.4,
          mobs = { { name = "Molten Elemental", chance = 21.2 } } },
        { kind = "mob", zone = "Stonetalon Mountains", levels = "15-30", spawn_count = 3, avg_chance = 35.2, respawn = 300, per_hour = 12.7,
          mobs = { { name = "Furious Stone Spirit", chance = 36.4 }, { name = "Enraged Stone Spirit", chance = 34.6 } } },
        { kind = "mob", zone = "Darkshore", levels = "10-20", spawn_count = 9, avg_chance = 44.2, respawn = 275, per_hour = 52.1,
          mobs = { { name = "Stone Behemoth", chance = 45.0 }, { name = "Cracked Golem", chance = 43.8 } } },
      }},
      { id = 2835,  name = "Rough Stone", sources = {
        { kind = "mine", zone = "Redridge Mountains", levels = "15-25", spawn_count = 528, avg_yield = 0.53, respawn = 375 },
        { kind = "mine", zone = "The Barrens", levels = "10-25", spawn_count = 528, avg_yield = 0.53, respawn = 375 },
        { kind = "mine", zone = "Dun Morogh", levels = "1-10", spawn_count = 528, avg_yield = 0.53, respawn = 375 },
        { kind = "mine", zone = "Elwynn Forest", levels = "1-10", spawn_count = 528, avg_yield = 0.53, respawn = 375 },
        { kind = "dungeon", zone = "The Deadmines", levels = "15-25", spawn_count = 13, avg_chance = 45.9, respawn = 7200, per_hour = 3.0,
          mobs = { { name = "Goblin Craftsman", chance = 45.9 } } },
      }},
    }},
    { category = "Leather & Hides", items = {
      { id = 8170,  name = "Rugged Leather", sources = {
        { kind = "dungeon", zone = "Zul'Gurub", levels = "60", spawn_count = 149, avg_chance = 2.5, respawn = 8360, per_hour = 1.8,
          mobs = { { name = "Razzashi Cobra", chance = 72.2 }, { name = "Bloodseeker Bat", chance = 1.0 }, { name = "Zulian Cub", chance = 0.5 } } },
        { kind = "dungeon", zone = "Blackrock Spire", levels = "55-60", spawn_count = 97, avg_chance = 1.5, respawn = 19588, per_hour = 0.5,
          mobs = { { name = "Gizrul the Slavener", chance = 4.7 }, { name = "Chromatic Whelp", chance = 4.1 }, { name = "Rookery Guardian", chance = 3.7 } } },
        { kind = "dungeon", zone = "Dire Maul", levels = "55-60", spawn_count = 77, avg_chance = 0.6, respawn = 7668, per_hour = 0.2,
          mobs = { { name = "Guard Slip'kik", chance = 4.1 }, { name = "Immol'thar", chance = 1.4 }, { name = "Eldreth Darter", chance = 0.7 } } },
        { kind = "dungeon", zone = "Blackrock Depths", levels = "52-60", spawn_count = 103, avg_chance = 0.2, respawn = 13002, per_hour = 0.1,
          mobs = { { name = "Verek", chance = 2.8 }, { name = "Eviscerator", chance = 1.1 }, { name = "Bloodhound Mastiff", chance = 0.3 } } },
        { kind = "dungeon", zone = "Maraudon (Inner)", levels = "40-50", spawn_count = 1, avg_chance = 5.3, respawn = 43200,
          mobs = { { name = "Rotgrip", chance = 5.3 } } },
        { kind = "mob", zone = "Silithus", levels = "55-60", spawn_count = 190, avg_chance = 0.1, respawn = 300, per_hour = 1.3,
          mobs = { { name = "Deathclasp", chance = 7.8 }, { name = "Stonelash Scorpid", chance = 0.06 }, { name = "Stonelash Pincer", chance = 0.06 } } },
        { kind = "mob", zone = "Winterspring", levels = "53-60", spawn_count = 394, avg_chance = 0.5, respawn = 1356, per_hour = 17.2,
          mobs = { { name = "Shy-Rotam", chance = 6.9 }, { name = "Sian-Rotam", chance = 6.0 }, { name = "Brumeran", chance = 5.1 } } },
        { kind = "mob", zone = "Burning Steppes", levels = "50-58", spawn_count = 124, avg_chance = 0.6, respawn = 1802, per_hour = 5.6,
          mobs = { { name = "Frenzied Black Drake", chance = 8.9 }, { name = "Flamescale Dragonspawn", chance = 2.0 }, { name = "Searscale Drake", chance = 1.4 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55", spawn_count = 177, avg_chance = 0.1, respawn = 2056, per_hour = 1.8,
          mobs = { { name = "Gruff", chance = 2.4 }, { name = "Uhk'loc", chance = 1.9 }, { name = "Un'Goro Gorilla", chance = 0.2 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 2, avg_chance = 4.2, respawn = 330, per_hour = 0.9,
          mobs = { { name = "King Bangalash", chance = 5.1 }, { name = "King Mukla", chance = 3.3 } } },
        { kind = "vendor", zone = "Lhara (Elwynn Forest / Mulgore)" },
      }},
      { id = 8171,  name = "Rugged Hide", sources = {
        { kind = "dungeon", zone = "Zul'Gurub", levels = "60", spawn_count = 13, avg_chance = 2.7, respawn = 7200, per_hour = 0.2,
          mobs = { { name = "Razzashi Cobra", chance = 5.6 }, { name = "Razzashi Serpent", chance = 1.4 } } },
        { kind = "dungeon", zone = "Blackwing Lair", levels = "60", spawn_count = 7, respawn = 14400,
          mobs = { { name = "Death Talon Wyrmguard", chance = 0.02 } } },
        { kind = "dungeon", zone = "Blackrock Spire", levels = "55-60", spawn_count = 44, avg_chance = 0.2, respawn = 10636,
          mobs = { { name = "Chromatic Dragonspawn", chance = 0.4 }, { name = "Chromatic Whelp", chance = 0.3 }, { name = "Rage Talon Captain", chance = 0.3 } } },
        { kind = "dungeon", zone = "Dire Maul", levels = "55-60", spawn_count = 1, avg_chance = 1.1, respawn = 43200,
          mobs = { { name = "Guard Slip'kik", chance = 1.1 } } },
        { kind = "mob", zone = "Winterspring", levels = "53-60", spawn_count = 46, avg_chance = 0.5, respawn = 455, per_hour = 1.6,
          mobs = { { name = "Cobalt Scalebane", chance = 1.1 }, { name = "Cobalt Mageweaver", chance = 1.1 }, { name = "Frostsaber Huntress", chance = 0.05 } } },
        { kind = "mob", zone = "Burning Steppes", levels = "50-58", spawn_count = 65, avg_chance = 1.5, respawn = 500, per_hour = 7.2,
          mobs = { { name = "Black Dragonspawn", chance = 1.7 }, { name = "Flamescale Wyrmkin", chance = 1.6 }, { name = "Flamescale Dragonspawn", chance = 1.6 } } },
        { kind = "mob", zone = "Azshara", levels = "45-55", spawn_count = 7, avg_chance = 1.3, respawn = 600, per_hour = 0.5,
          mobs = { { name = "Blue Dragonspawn", chance = 1.3 } } },
        { kind = "mob", zone = "Feralas", levels = "40-50", spawn_count = 1, avg_chance = 6.3, respawn = 600, per_hour = 0.4,
          mobs = { { name = "Dreamroarer", chance = 6.3 } } },
      }},
      { id = 4304,  name = "Thick Leather", sources = {
        { kind = "dungeon", zone = "Blackrock Spire", levels = "55-60", spawn_count = 66, avg_chance = 0.3, respawn = 9709, per_hour = 0.1,
          mobs = { { name = "Bloodaxe Worg Pup", chance = 0.7 }, { name = "Chromatic Whelp", chance = 0.6 }, { name = "Scarshield Worg", chance = 0.5 } } },
        { kind = "dungeon", zone = "Blackrock Depths", levels = "52-60", spawn_count = 103, avg_chance = 0.5, respawn = 13002, per_hour = 0.2,
          mobs = { { name = "Eviscerator", chance = 1.5 }, { name = "Dark Screecher", chance = 0.6 }, { name = "Burrowing Thundersnout", chance = 0.5 } } },
        { kind = "dungeon", zone = "Maraudon (Inner)", levels = "40-50", spawn_count = 32, avg_chance = 1.3, respawn = 8325, per_hour = 0.1,
          mobs = { { name = "Rotgrip", chance = 14.9 }, { name = "Subterranean Diemetradon", chance = 0.9 } } },
        { kind = "dungeon", zone = "Maraudon", levels = "40-50", spawn_count = 2, avg_chance = 2.7, respawn = 86400,
          mobs = { { name = "Weaver", chance = 6.5 }, { name = "Dreamscythe", chance = 6.5 }, { name = "Hazzas", chance = 5.4 } } },
        { kind = "dungeon", zone = "Zul'Farrak", levels = "40-50", spawn_count = 24, avg_chance = 0.5, respawn = 7200, per_hour = 0.1,
          mobs = { { name = "Gahz'rilla", chance = 2.8 }, { name = "Sul'lithuz Broodling", chance = 1.9 }, { name = "Sul'lithuz Abomination", chance = 0.8 } } },
        { kind = "mob", zone = "Winterspring", levels = "53-60", spawn_count = 173, avg_chance = 0.6, respawn = 729, per_hour = 11.0,
          mobs = { { name = "Mezzir the Howler", chance = 2.1 }, { name = "Spell Eater", chance = 1.7 }, { name = "Cobalt Whelp", chance = 1.5 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55", spawn_count = 93, avg_chance = 0.3, respawn = 4174, per_hour = 2.1,
          mobs = { { name = "Ravasaur Matriarch", chance = 3.1 }, { name = "Uhk'loc", chance = 2.5 }, { name = "Spiked Stegodon", chance = 0.6 } } },
        { kind = "mob", zone = "Feralas", levels = "40-50", spawn_count = 394, avg_chance = 0.2, respawn = 638, per_hour = 9.0,
          mobs = { { name = "Arash-ethis", chance = 3.4 }, { name = "Snarler", chance = 1.5 }, { name = "Lurking Feral Scar", chance = 1.1 } } },
        { kind = "mob", zone = "The Hinterlands", levels = "40-50", spawn_count = 91, avg_chance = 0.3, respawn = 1766, per_hour = 2.4,
          mobs = { { name = "Gammerita", chance = 8.8 }, { name = "Ironback", chance = 1.5 }, { name = "Old Cliff Jumper", chance = 1.3 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 74, avg_chance = 0.6, respawn = 2502, per_hour = 2.2,
          mobs = { { name = "Konda", chance = 35.0 }, { name = "Elder Saltwater Crocolisk", chance = 5.5 }, { name = "King Mukla", chance = 3.8 } } },
        { kind = "vendor", zone = "Lhara (Elwynn Forest / Mulgore)" },
      }},
      { id = 8169,  name = "Thick Hide", sources = {
        { kind = "dungeon", zone = "Blackrock Spire", levels = "55-60", spawn_count = 28, avg_chance = 0.1, respawn = 7457,
          mobs = { { name = "Spire Scorpid", chance = 0.1 }, { name = "Bloodaxe Worg Pup", chance = 0.1 }, { name = "Scarshield Worg", chance = 0.02 } } },
        { kind = "dungeon", zone = "Blackrock Depths", levels = "52-60", spawn_count = 97, respawn = 13361,
          mobs = { { name = "Verek", chance = 0.08 }, { name = "Burrowing Thundersnout", chance = 0.08 }, { name = "Bloodhound", chance = 0.04 } } },
        { kind = "dungeon", zone = "Maraudon", levels = "40-50", spawn_count = 2, avg_chance = 1.7, respawn = 86400,
          mobs = { { name = "Weaver", chance = 2.4 }, { name = "Dreamscythe", chance = 2.4 }, { name = "Hazzas", chance = 2.3 } } },
        { kind = "dungeon", zone = "Maraudon (Inner)", levels = "40-50", spawn_count = 42, avg_chance = 0.1, respawn = 7200,
          mobs = { { name = "Subterranean Diemetradon", chance = 0.08 }, { name = "Thessala Hydra", chance = 0.04 } } },
        { kind = "dungeon", zone = "Zul'Farrak", levels = "40-50", spawn_count = 28, avg_chance = 0.1, respawn = 7200,
          mobs = { { name = "Sandfury Guardian", chance = 0.1 }, { name = "Sul'lithuz Abomination", chance = 0.07 }, { name = "Sul'lithuz Sandcrawler", chance = 0.04 } } },
        { kind = "mob", zone = "Silithus", levels = "55-60", spawn_count = 190, respawn = 300, per_hour = 0.2,
          mobs = { { name = "Deathclasp", chance = 1.2 }, { name = "Stonelash Scorpid", chance = 0.01 }, { name = "Stonelash Pincer", chance = 0.01 } } },
        { kind = "mob", zone = "Winterspring", levels = "53-60", spawn_count = 214, respawn = 352, per_hour = 1.0,
          mobs = { { name = "Cobalt Whelp", chance = 0.2 }, { name = "Cobalt Broodling", chance = 0.1 }, { name = "Cobalt Wyrmkin", chance = 0.06 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55", spawn_count = 255, respawn = 300, per_hour = 0.3,
          mobs = { { name = "Venomhide Ravasaur", chance = 0.02 }, { name = "Lar'korwi Mate", chance = 0.02 }, { name = "Un'Goro Thunderer", chance = 0.01 } } },
        { kind = "mob", zone = "Feralas", levels = "40-50", spawn_count = 257, respawn = 300, per_hour = 0.5,
          mobs = { { name = "Lurking Feral Scar", chance = 0.08 }, { name = "Elder Rage Scar", chance = 0.06 }, { name = "Hulking Feral Scar", chance = 0.04 } } },
        { kind = "mob", zone = "Tanaris", levels = "40-50", spawn_count = 745, respawn = 299, per_hour = 1.1,
          mobs = { { name = "Glasshide Petrifier", chance = 0.03 }, { name = "Glasshide Gazer", chance = 0.02 }, { name = "Rabid Blisterpaw", chance = 0.02 } } },
      }},
      { id = 4234,  name = "Heavy Leather", sources = {
        { kind = "dungeon", zone = "Zul'Farrak", levels = "40-50", spawn_count = 4, avg_chance = 0.6, respawn = 7200,
          mobs = { { name = "Sul'lithuz Broodling", chance = 4.8 }, { name = "Sandfury Guardian", chance = 0.6 } } },
        { kind = "dungeon", zone = "Uldaman", levels = "35-45", spawn_count = 56, avg_chance = 0.6, respawn = 7200, per_hour = 0.2,
          mobs = { { name = "Cleft Scorpid", chance = 0.8 }, { name = "Shrike Bat", chance = 0.6 }, { name = "Jadespine Basilisk", chance = 0.6 } } },
        { kind = "dungeon", zone = "Scarlet Monastery", levels = "30-45", spawn_count = 7, avg_chance = 0.4, respawn = 7200,
          mobs = { { name = "Scarlet Tracking Hound", chance = 0.4 } } },
        { kind = "dungeon", zone = "Razorfen Downs", levels = "30-45", spawn_count = 10, avg_chance = 0.6, respawn = 7200,
          mobs = { { name = "Withered Battle Boar", chance = 0.6 }, { name = "Battle Boar Horror", chance = 0.5 } } },
        { kind = "dungeon", zone = "Razorfen Kraul", levels = "25-35", spawn_count = 23, avg_chance = 0.3, respawn = 7200,
          mobs = { { name = "Greater Kraul Bat", chance = 0.5 }, { name = "Kraul Bat", chance = 0.2 }, { name = "Rotting Agam'ar", chance = 0.1 } } },
        { kind = "mob", zone = "Feralas", levels = "40-50", spawn_count = 402, avg_chance = 0.1, respawn = 300, per_hour = 6.7,
          mobs = { { name = "Feral Scar Yeti", chance = 0.3 }, { name = "Hulking Feral Scar", chance = 0.3 }, { name = "Enraged Feral Scar", chance = 0.3 } } },
        { kind = "mob", zone = "Dustwallow Marsh", levels = "35-45", spawn_count = 474, avg_chance = 0.3, respawn = 355, per_hour = 15.5,
          mobs = { { name = "Firemane Flamecaller", chance = 0.8 }, { name = "Firemane Scout", chance = 0.7 }, { name = "Firemane Ash Tail", chance = 0.6 } } },
        { kind = "mob", zone = "Badlands", levels = "35-45", spawn_count = 242, avg_chance = 0.1, respawn = 315, per_hour = 3.8,
          mobs = { { name = "Ridge Stalker", chance = 0.2 }, { name = "Ridge Huntress", chance = 0.2 }, { name = "Feral Crag Coyote", chance = 0.2 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 391, avg_chance = 0.1, respawn = 316, per_hour = 6.6,
          mobs = { { name = "Konda", chance = 40.0 }, { name = "Enraged Silverback Gorilla", chance = 1.0 }, { name = "Kurzen War Tiger", chance = 0.8 } } },
        { kind = "mob", zone = "Thousand Needles", levels = "25-35", spawn_count = 325, avg_chance = 0.1, respawn = 300, per_hour = 2.9,
          mobs = { { name = "Highperch Patriarch", chance = 0.1 }, { name = "Saltstone Crystalhide", chance = 0.1 }, { name = "Saltstone Gazer", chance = 0.1 } } },
        { kind = "vendor", zone = "Lhara (Elwynn Forest / Mulgore)" },
      }},
      { id = 4235,  name = "Heavy Hide", sources = {
        { kind = "dungeon", zone = "Zul'Farrak", levels = "40-50", spawn_count = 4, avg_chance = 0.1, respawn = 7200,
          mobs = { { name = "Sul'lithuz Broodling", chance = 0.2 }, { name = "Sandfury Guardian", chance = 0.07 } } },
        { kind = "dungeon", zone = "Uldaman", levels = "35-45", spawn_count = 56, respawn = 7200,
          mobs = { { name = "Jadespine Basilisk", chance = 0.08 }, { name = "Deadly Cleft Scorpid", chance = 0.08 }, { name = "Shrike Bat", chance = 0.04 } } },
        { kind = "dungeon", zone = "Scarlet Monastery", levels = "30-45", spawn_count = 7, respawn = 7200,
          mobs = { { name = "Scarlet Tracking Hound", chance = 0.03 } } },
        { kind = "dungeon", zone = "Razorfen Downs", levels = "30-45", spawn_count = 10, respawn = 7200,
          mobs = { { name = "Battle Boar Horror", chance = 0.04 }, { name = "Withered Battle Boar", chance = 0.03 } } },
        { kind = "dungeon", zone = "Blackfathom Deeps", levels = "20-30", spawn_count = 7, avg_chance = 0.1, respawn = 7200,
          mobs = { { name = "Aku'mai Snapjaw", chance = 0.06 } } },
        { kind = "mob", zone = "Feralas", levels = "40-50", spawn_count = 312, respawn = 300, per_hour = 0.6,
          mobs = { { name = "Longtooth Howler", chance = 0.03 }, { name = "Longtooth Runner", chance = 0.02 }, { name = "Enraged Feral Scar", chance = 0.02 } } },
        { kind = "mob", zone = "Badlands", levels = "35-45", spawn_count = 217, avg_chance = 0.1, respawn = 317, per_hour = 1.2,
          mobs = { { name = "Scorched Guardian", chance = 1.5 }, { name = "Crag Coyote", chance = 0.01 }, { name = "Ridge Huntress", chance = 0.01 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 256, respawn = 300, per_hour = 0.3,
          mobs = { { name = "Konda", chance = 3.0 }, { name = "Kurzen War Tiger", chance = 0.2 }, { name = "Enraged Silverback Gorilla", chance = 0.04 } } },
        { kind = "mob", zone = "Thousand Needles", levels = "25-35", spawn_count = 264, respawn = 844, per_hour = 0.2,
          mobs = { { name = "Ironeye the Invincible", chance = 0.5 }, { name = "Saltstone Gazer", chance = 0.01 }, { name = "Scorpid Reaver", chance = 0.01 } } },
        { kind = "mob", zone = "Duskwood", levels = "18-30", spawn_count = 92, respawn = 300, per_hour = 0.5,
          mobs = { { name = "Nightbane Tainted One", chance = 0.1 }, { name = "Nightbane Vile Fang", chance = 0.07 }, { name = "Nightbane Dark Runner", chance = 0.01 } } },
      }},
      { id = 2319,  name = "Medium Leather", sources = {
        { kind = "dungeon", zone = "Uldaman", levels = "35-45", spawn_count = 30, avg_chance = 0.6, respawn = 7200, per_hour = 0.1,
          mobs = { { name = "Cleft Scorpid", chance = 0.6 } } },
        { kind = "dungeon", zone = "Razorfen Kraul", levels = "25-35", spawn_count = 54, avg_chance = 7.2, respawn = 7900, per_hour = 1.9,
          mobs = { { name = "Kraul Bat", chance = 22.2 }, { name = "Rotting Agam'ar", chance = 5.0 }, { name = "Greater Kraul Bat", chance = 3.7 } } },
        { kind = "dungeon", zone = "Shadowfang Keep", levels = "20-30", spawn_count = 80, avg_chance = 2.0, respawn = 8752, per_hour = 0.8,
          mobs = { { name = "Wolfguard Worg", chance = 9.2 }, { name = "Slavering Worg", chance = 3.9 }, { name = "Shadowfang Glutton", chance = 3.6 } } },
        { kind = "dungeon", zone = "Blackfathom Deeps", levels = "20-30", spawn_count = 23, avg_chance = 11.7, respawn = 14087, per_hour = 1.3,
          mobs = { { name = "Aku'mai Snapjaw", chance = 19.5 }, { name = "Aku'mai Fisher", chance = 10.0 }, { name = "Deep Pool Threshfin", chance = 8.2 } } },
        { kind = "dungeon", zone = "Wailing Caverns", levels = "15-25", spawn_count = 30, avg_chance = 1.0, respawn = 12480, per_hour = 0.1,
          mobs = { { name = "Skum", chance = 6.3 }, { name = "Deviate Moccasin", chance = 2.1 }, { name = "Deviate Guardian", chance = 2.1 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 149, avg_chance = 0.1, respawn = 300, per_hour = 1.9,
          mobs = { { name = "Young Stranglethorn Raptor", chance = 0.5 }, { name = "Kurzen War Panther", chance = 0.5 }, { name = "Young Lashtail Raptor", chance = 0.3 } } },
        { kind = "mob", zone = "Thousand Needles", levels = "25-35", spawn_count = 237, avg_chance = 0.2, respawn = 573, per_hour = 4.1,
          mobs = { { name = "Arikara", chance = 2.5 }, { name = "Enraged Panther", chance = 1.6 }, { name = "Vile Sting", chance = 0.8 } } },
        { kind = "mob", zone = "Hillsbrad Foothills", levels = "20-30", spawn_count = 332, avg_chance = 0.1, respawn = 443, per_hour = 5.3,
          mobs = { { name = "Big Samras", chance = 1.0 }, { name = "Cave Yeti", chance = 0.5 }, { name = "Ferocious Yeti", chance = 0.5 } } },
        { kind = "mob", zone = "Duskwood", levels = "18-30", spawn_count = 191, avg_chance = 1.0, respawn = 3113, per_hour = 18.3,
          mobs = { { name = "Nightbane Tainted One", chance = 3.1 }, { name = "Nightbane Vile Fang", chance = 2.3 }, { name = "Lupos", chance = 1.9 } } },
        { kind = "mob", zone = "The Barrens", levels = "10-25", spawn_count = 207, avg_chance = 0.3, respawn = 1233, per_hour = 5.5,
          mobs = { { name = "Deviate Coiler", chance = 4.3 }, { name = "Humar the Pridelord", chance = 3.8 }, { name = "Deviate Stalker", chance = 3.7 } } },
        { kind = "vendor", zone = "Lhara (Elwynn Forest / Mulgore)" },
      }},
      { id = 4232,  name = "Medium Hide", sources = {
        { kind = "dungeon", zone = "Uldaman", levels = "35-45", spawn_count = 30, avg_chance = 0.1, respawn = 7200,
          mobs = { { name = "Cleft Scorpid", chance = 0.07 } } },
        { kind = "dungeon", zone = "Razorfen Kraul", levels = "25-35", spawn_count = 50, avg_chance = 0.1, respawn = 7200,
          mobs = { { name = "Kraul Bat", chance = 0.1 }, { name = "Agam'ar", chance = 0.07 }, { name = "Raging Agam'ar", chance = 0.06 } } },
        { kind = "dungeon", zone = "Shadowfang Keep", levels = "20-30", spawn_count = 76, respawn = 7413,
          mobs = { { name = "Son of Arugal", chance = 0.09 }, { name = "Shadowfang Glutton", chance = 0.06 }, { name = "Shadowfang Wolfguard", chance = 0.05 } } },
        { kind = "dungeon", zone = "Blackfathom Deeps", levels = "20-30", spawn_count = 13, avg_chance = 0.1, respawn = 7200,
          mobs = { { name = "Aku'mai Snapjaw", chance = 0.1 }, { name = "Aku'mai Fisher", chance = 0.03 } } },
        { kind = "dungeon", zone = "Wailing Caverns", levels = "15-25", spawn_count = 51, respawn = 8753,
          mobs = { { name = "Deviate Moccasin", chance = 0.05 }, { name = "Deviate Adder", chance = 0.04 }, { name = "Skum", chance = 0.04 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 173, respawn = 300, per_hour = 0.2,
          mobs = { { name = "River Crocolisk", chance = 0.02 }, { name = "Stranglethorn Raptor", chance = 0.01 }, { name = "Young Panther", chance = 0.01 } } },
        { kind = "mob", zone = "Thousand Needles", levels = "25-35", spawn_count = 275, respawn = 300, per_hour = 0.4,
          mobs = { { name = "Sparkleshell Borer", chance = 0.05 }, { name = "Venomous Cloud Serpent", chance = 0.03 }, { name = "Highperch Consort", chance = 0.03 } } },
        { kind = "mob", zone = "Hillsbrad Foothills", levels = "20-30", spawn_count = 268, respawn = 300, per_hour = 0.4,
          mobs = { { name = "Cave Yeti", chance = 0.04 }, { name = "Feral Mountain Lion", chance = 0.04 }, { name = "Ferocious Yeti", chance = 0.03 } } },
        { kind = "mob", zone = "Wetlands", levels = "20-30", spawn_count = 242, respawn = 300, per_hour = 1.3,
          mobs = { { name = "Highland Scytheclaw", chance = 0.4 }, { name = "Sarltooth", chance = 0.03 }, { name = "Red Whelp", chance = 0.02 } } },
        { kind = "mob", zone = "Duskwood", levels = "18-30", spawn_count = 180, avg_chance = 0.1, respawn = 299, per_hour = 1.4,
          mobs = { { name = "Nightbane Tainted One", chance = 0.3 }, { name = "Nightbane Vile Fang", chance = 0.2 }, { name = "Nightbane Dark Runner", chance = 0.05 } } },
      }},
      { id = 2318,  name = "Light Leather", sources = {
        { kind = "dungeon", zone = "Razorfen Kraul", levels = "25-35", spawn_count = 30, avg_chance = 6.4, respawn = 7200, per_hour = 1.0,
          mobs = { { name = "Raging Agam'ar", chance = 10.3 }, { name = "Agam'ar", chance = 2.6 } } },
        { kind = "dungeon", zone = "Shadowfang Keep", levels = "20-30", spawn_count = 79, avg_chance = 1.4, respawn = 8316, per_hour = 0.5,
          mobs = { { name = "Wolfguard Worg", chance = 50.4 }, { name = "Fel Steed", chance = 6.4 }, { name = "Shadow Charger", chance = 3.0 } } },
        { kind = "dungeon", zone = "Blackfathom Deeps", levels = "20-30", spawn_count = 15, avg_chance = 5.2, respawn = 12480, per_hour = 0.4,
          mobs = { { name = "Aku'mai Fisher", chance = 6.3 }, { name = "Deep Pool Threshfin", chance = 4.6 }, { name = "Ghamoo-ra", chance = 2.8 } } },
        { kind = "dungeon", zone = "Wailing Caverns", levels = "15-25", spawn_count = 50, avg_chance = 1.0, respawn = 7200, per_hour = 0.2,
          mobs = { { name = "Deviate Moccasin", chance = 5.1 }, { name = "Deviate Dreadfang", chance = 3.1 }, { name = "Deviate Venomwing", chance = 2.9 } } },
        { kind = "mob", zone = "Redridge Mountains", levels = "15-25", spawn_count = 80, avg_chance = 0.2, respawn = 300, per_hour = 2.3,
          mobs = { { name = "Great Goretusk", chance = 0.3 }, { name = "Black Dragon Whelp", chance = 0.2 } } },
        { kind = "mob", zone = "The Barrens", levels = "10-25", spawn_count = 1278, avg_chance = 0.8, respawn = 388, per_hour = 138.2,
          mobs = { { name = "Gazelle", chance = 11.3 }, { name = "Deviate Coiler", chance = 8.7 }, { name = "Deviate Stalker", chance = 8.0 } } },
        { kind = "mob", zone = "Darkshore", levels = "10-20", spawn_count = 393, avg_chance = 1.1, respawn = 503, per_hour = 53.1,
          mobs = { { name = "Sickly Deer", chance = 6.1 }, { name = "Strider Clutchmother", chance = 4.7 }, { name = "Shadowclaw", chance = 4.7 } } },
        { kind = "mob", zone = "Loch Modan", levels = "10-20", spawn_count = 49, avg_chance = 0.4, respawn = 2235, per_hour = 1.5,
          mobs = { { name = "Large Loch Crocolisk", chance = 2.7 }, { name = "Ol' Sooty", chance = 2.6 }, { name = "Loch Crocolisk", chance = 0.3 } } },
        { kind = "mob", zone = "Dun Morogh", levels = "1-10", spawn_count = 337, avg_chance = 0.2, respawn = 579, per_hour = 8.4,
          mobs = { { name = "Bjarn", chance = 1.4 }, { name = "Timber", chance = 1.3 }, { name = "Vagash", chance = 1.1 } } },
      }},
      { id = 783,   name = "Light Hide", sources = {
        { kind = "dungeon", zone = "Razorfen Kraul", levels = "25-35", spawn_count = 30, respawn = 7200,
          mobs = { { name = "Raging Agam'ar", chance = 0.07 }, { name = "Agam'ar", chance = 0.03 } } },
        { kind = "dungeon", zone = "Shadowfang Keep", levels = "20-30", spawn_count = 78, avg_chance = 0.2, respawn = 7869, per_hour = 0.1,
          mobs = { { name = "Wolfguard Worg", chance = 11.8 }, { name = "Shadow Charger", chance = 0.1 }, { name = "Shadowfang Whitescalp", chance = 0.07 } } },
        { kind = "dungeon", zone = "Blackfathom Deeps", levels = "20-30", spawn_count = 8, avg_chance = 0.1, respawn = 7200,
          mobs = { { name = "Deep Pool Threshfin", chance = 0.06 } } },
        { kind = "dungeon", zone = "Wailing Caverns", levels = "15-25", spawn_count = 50, respawn = 7200,
          mobs = { { name = "Deviate Moccasin", chance = 0.1 }, { name = "Deviate Guardian", chance = 0.07 }, { name = "Deviate Ravager", chance = 0.05 } } },
        { kind = "mob", zone = "Wetlands", levels = "20-30", spawn_count = 199, respawn = 300, per_hour = 0.3,
          mobs = { { name = "Mottled Screecher", chance = 0.02 }, { name = "Wetlands Crocolisk", chance = 0.01 }, { name = "Young Wetlands Crocolisk", chance = 0.01 } } },
        { kind = "mob", zone = "Redridge Mountains", levels = "15-25", spawn_count = 80, respawn = 300, per_hour = 0.2,
          mobs = { { name = "Great Goretusk", chance = 0.02 }, { name = "Black Dragon Whelp", chance = 0.02 } } },
        { kind = "mob", zone = "The Barrens", levels = "10-25", spawn_count = 1257, respawn = 275, per_hour = 2.0,
          mobs = { { name = "Deviate Coiler", chance = 0.07 }, { name = "Deviate Stalker", chance = 0.03 }, { name = "Deviate Creeper", chance = 0.03 } } },
        { kind = "mob", zone = "Darkshore", levels = "10-20", spawn_count = 433, respawn = 275, per_hour = 0.6,
          mobs = { { name = "Moonstalker Matriarch", chance = 0.04 }, { name = "Moonstalker Sire", chance = 0.02 }, { name = "Moonstalker", chance = 0.02 } } },
        { kind = "mob", zone = "Loch Modan", levels = "10-20", spawn_count = 107, respawn = 300, per_hour = 0.2,
          mobs = { { name = "Loch Crocolisk", chance = 0.03 }, { name = "Grizzled Black Bear", chance = 0.01 }, { name = "Mangy Mountain Boar", chance = 0.01 } } },
      }},
    }},
    { category = "Cloth", items = {
      { id = 14342, name = "Mooncloth", hasCooldown = true, recipe = {
        -- Tailoring transmute: 2 Felcloth at a Moonwell, 4-day cooldown,
        -- requires the Mooncloth Tailoring book (Felcloth turn-in quest).
        { id = 14256, count = 2 },  -- Felcloth
      }, sources = {
        { kind = "craft", zone = "Tailoring transmute (2 Felcloth, 4-day CD at a Moonwell)" },
      }},
      { id = 14256, name = "Felcloth", sources = {
        { kind = "dungeon", zone = "Zul'Gurub", levels = "60", spawn_count = 14, avg_chance = 4.8, respawn = 13371, per_hour = 0.2,
          mobs = { { name = "Mad Servant", chance = 4.8 } } },
        { kind = "dungeon", zone = "Dire Maul", levels = "55-60", spawn_count = 106, avg_chance = 7.0, respawn = 44664, per_hour = 3.6,
          mobs = { { name = "Xorothian Dreadsteed", chance = 40.2 }, { name = "Wildspawn Felsworn", chance = 12.3 }, { name = "Wildspawn Hellcaller", chance = 12.3 } } },
        { kind = "dungeon", zone = "Stratholme", levels = "55-60", spawn_count = 1, avg_chance = 1.6, respawn = 604800,
          mobs = { { name = "Grand Crusader Dathrohan", chance = 1.6 } } },
        { kind = "dungeon", zone = "Blackrock Spire", levels = "55-60",
          mobs = { { name = "Burning Felguard", chance = 1.5 } } },
        { kind = "mob", zone = "Winterspring", levels = "53-60", spawn_count = 35, avg_chance = 8.2, respawn = 2434, per_hour = 17.1,
          mobs = { { name = "Hederine Initiate", chance = 8.5 }, { name = "Hederine Slayer", chance = 8.3 }, { name = "Lady Hederine", chance = 1.5 } } },
        { kind = "mob", zone = "Burning Steppes", levels = "50-58", spawn_count = 8, avg_chance = 4.3, respawn = 95400,
          mobs = { { name = "Terrorspark", chance = 4.3 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55", spawn_count = 106, avg_chance = 7.7, respawn = 516, per_hour = 99.3,
          mobs = { { name = "Xavathras", chance = 10.5 }, { name = "Salia", chance = 9.7 }, { name = "Rakaiah", chance = 9.4 } } },
        { kind = "mob", zone = "Azshara", levels = "45-55", spawn_count = 51, avg_chance = 9.1, respawn = 5925, per_hour = 48.7,
          mobs = { { name = "Legashi Satyr", chance = 9.6 }, { name = "Legashi Hellcaller", chance = 9.6 }, { name = "Legashi Rogue", chance = 9.0 } } },
        { kind = "mob", zone = "Blasted Lands", levels = "45-55", spawn_count = 87, avg_chance = 6.0, respawn = 5014, per_hour = 14.5,
          mobs = { { name = "Felcular", chance = 10.9 }, { name = "Felguard Sentry", chance = 10.3 }, { name = "Felguard Elite", chance = 6.2 } } },
        { kind = "vendor", zone = "Vi'el (Winterspring)" },
      }},
      { id = 14047, name = "Runecloth", sources = {
        { kind = "dungeon", zone = "Blackrock Spire", levels = "55-60", spawn_count = 435, avg_chance = 31.4, respawn = 19466, per_hour = 54.1,
          mobs = { { name = "Blackhand Dragon Handler", chance = 54.7 }, { name = "Blackhand Thug", chance = 53.4 }, { name = "Blackhand Assassin", chance = 51.8 } } },
        { kind = "dungeon", zone = "Stratholme", levels = "55-60", spawn_count = 379, avg_chance = 28.7, respawn = 22253, per_hour = 55.2,
          mobs = { { name = "Crimson Monk", chance = 51.8 }, { name = "Stratholme Courier", chance = 39.0 }, { name = "Ghostly Citizen", chance = 33.8 } } },
        { kind = "dungeon", zone = "Dire Maul", levels = "55-60", spawn_count = 285, avg_chance = 39.4, respawn = 27801, per_hour = 54.9,
          mobs = { { name = "Skeletal Highborne", chance = 67.3 }, { name = "Rotting Highborne", chance = 66.9 }, { name = "Wildspawn Imp", chance = 56.3 } } },
        { kind = "dungeon", zone = "Scholomance", levels = "55-60", spawn_count = 302, avg_chance = 25.3, respawn = 10490, per_hour = 37.5,
          mobs = { { name = "Risen Guardian", chance = 63.9 }, { name = "Scholomance Neophyte", chance = 32.4 }, { name = "Scholomance Acolyte", chance = 31.6 } } },
        { kind = "dungeon", zone = "Blackrock Depths", levels = "52-60", spawn_count = 628, avg_chance = 27.8, respawn = 17541, per_hour = 102.5,
          mobs = { { name = "Jaz", chance = 46.8 }, { name = "Watchman Doomgrip", chance = 45.5 }, { name = "Shill Dinger", chance = 45.4 } } },
        { kind = "mob", zone = "Silithus", levels = "55-60", spawn_count = 191, avg_chance = 53.9, respawn = 315, per_hour = 1184.0,
          mobs = { { name = "Shade of Ambermoon", chance = 70.4 }, { name = "Tortured Sentinel", chance = 58.3 }, { name = "Twilight Overlord", chance = 55.8 } } },
        { kind = "mob", zone = "Deadwind Pass", levels = "55-60", spawn_count = 101, avg_chance = 72.2, respawn = 584, per_hour = 449.7,
          mobs = { { name = "Deadwind Ogre Mage", chance = 77.6 }, { name = "Deadwind Warlock", chance = 76.6 }, { name = "Deadwind Brute", chance = 76.6 } } },
        { kind = "mob", zone = "Eastern Plaguelands", levels = "53-60", spawn_count = 315, avg_chance = 65.6, respawn = 4472, per_hour = 1524.8,
          mobs = { { name = "Quel'Lithien Protector", chance = 79.0 }, { name = "Ranger", chance = 77.2 }, { name = "Infected Mossflayer", chance = 77.2 } } },
        { kind = "mob", zone = "Western Plaguelands", levels = "51-58", spawn_count = 81, avg_chance = 61.8, respawn = 6636, per_hour = 520.3,
          mobs = { { name = "Cavalier Durgen", chance = 75.6 }, { name = "Scarlet Spellbinder", chance = 75.2 }, { name = "Huntsman Radley", chance = 74.8 } } },
        { kind = "mob", zone = "Burning Steppes", levels = "50-58", spawn_count = 75, avg_chance = 52.7, respawn = 14229, per_hour = 231.2,
          mobs = { { name = "Blackrock Raider", chance = 81.8 }, { name = "Blackrock Battlemaster", chance = 70.1 }, { name = "Thaurissan Spy", chance = 66.9 } } },
      }},
      { id = 4338,  name = "Mageweave Cloth", sources = {
        { kind = "dungeon", zone = "Sunken Temple", levels = "50-60", spawn_count = 73, avg_chance = 29.0, respawn = 8679, per_hour = 11.7,
          mobs = { { name = "Atal'ai Slave", chance = 35.1 }, { name = "Atal'ai Deathwalker", chance = 26.6 }, { name = "Atal'ai Warrior", chance = 26.5 } } },
        { kind = "dungeon", zone = "Maraudon", levels = "40-50", spawn_count = 178, avg_chance = 30.7, respawn = 7604, per_hour = 29.1,
          mobs = { { name = "Atal'ai Slave", chance = 72.9 }, { name = "Atal'ai Deathwalker", chance = 36.3 }, { name = "Atal'ai Warrior", chance = 36.0 } } },
        { kind = "dungeon", zone = "Zul'Farrak", levels = "40-50", spawn_count = 121, avg_chance = 4.0, respawn = 20113, per_hour = 0.4,
          mobs = { { name = "Murta Grimgut", chance = 35.9 }, { name = "Oro Eyegouge", chance = 34.1 }, { name = "Sandfury Executioner", chance = 26.9 } } },
        { kind = "dungeon", zone = "Uldaman", levels = "35-45", spawn_count = 292, avg_chance = 25.6, respawn = 7397, per_hour = 37.6,
          mobs = { { name = "Earthen Custodian", chance = 55.7 }, { name = "Earthen Guardian", chance = 53.0 }, { name = "Earthen Hallshaper", chance = 52.0 } } },
        { kind = "dungeon", zone = "Scarlet Monastery", levels = "30-45", spawn_count = 315, avg_chance = 2.8, respawn = 7069, per_hour = 4.6,
          mobs = { { name = "Scarlet Champion", chance = 5.0 }, { name = "Scarlet Sorcerer", chance = 4.9 }, { name = "Scarlet Abbot", chance = 4.8 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55", spawn_count = 122, avg_chance = 62.3, respawn = 300, per_hour = 911.6,
          mobs = { { name = "Jaedenar Guardian", chance = 69.4 }, { name = "Ur'dan", chance = 68.2 }, { name = "Jadefire Satyr", chance = 63.1 } } },
        { kind = "mob", zone = "Azshara", levels = "45-55", spawn_count = 117, avg_chance = 74.5, respawn = 935, per_hour = 935.5,
          mobs = { { name = "Timbermaw Pathfinder", chance = 77.7 }, { name = "Haldarr Felsworn", chance = 77.5 }, { name = "Timbermaw Shaman", chance = 76.9 } } },
        { kind = "mob", zone = "Searing Gorge", levels = "43-52", spawn_count = 140, avg_chance = 58.5, respawn = 1949, per_hour = 642.7,
          mobs = { { name = "Shadowsilk Poacher", chance = 72.7 }, { name = "Dark Iron Sentry", chance = 68.4 }, { name = "Clunk", chance = 64.5 } } },
        { kind = "mob", zone = "Feralas", levels = "40-50", spawn_count = 341, avg_chance = 52.2, respawn = 306, per_hour = 2122.6,
          mobs = { { name = "Gordunni Warlord", chance = 77.7 }, { name = "Northspring Roguefeather", chance = 59.2 }, { name = "Northspring Harpy", chance = 59.2 } } },
        { kind = "mob", zone = "Tanaris", levels = "40-50", spawn_count = 115, avg_chance = 66.7, respawn = 3318, per_hour = 894.5,
          mobs = { { name = "Dunemaul Ogre", chance = 76.2 }, { name = "Dunemaul Ogre Mage", chance = 74.7 }, { name = "Dunemaul Warlock", chance = 74.5 } } },
      }},
      { id = 4306,  name = "Silk Cloth", sources = {
        { kind = "dungeon", zone = "Uldaman", levels = "35-45", spawn_count = 288, avg_chance = 16.3, respawn = 7400, per_hour = 25.9,
          mobs = { { name = "Stonevault Ambusher", chance = 58.2 }, { name = "Shadowforge Geologist", chance = 41.0 }, { name = "Stonevault Cave Lurker", chance = 29.2 } } },
        { kind = "dungeon", zone = "Scarlet Monastery", levels = "30-45", spawn_count = 328, avg_chance = 32.4, respawn = 7889, per_hour = 55.6,
          mobs = { { name = "Unfettered Spirit", chance = 58.8 }, { name = "Haunting Phantasm", chance = 30.4 }, { name = "Scarlet Champion", chance = 29.7 } } },
        { kind = "dungeon", zone = "Razorfen Downs", levels = "30-45", spawn_count = 174, avg_chance = 36.7, respawn = 10853, per_hour = 33.3,
          mobs = { { name = "Splinterbone Centurion", chance = 59.1 }, { name = "Skeletal Frostweaver", chance = 50.9 }, { name = "Frozen Soul", chance = 50.5 } } },
        { kind = "dungeon", zone = "Gnomeregan", levels = "29-38", spawn_count = 245, avg_chance = 23.0, respawn = 7752, per_hour = 28.2,
          mobs = { { name = "Holdout Medic", chance = 31.3 }, { name = "Caverndeep Reaver", chance = 28.5 }, { name = "Holdout Technician", chance = 28.4 } } },
        { kind = "dungeon", zone = "Razorfen Kraul", levels = "25-35", spawn_count = 135, avg_chance = 22.1, respawn = 8547, per_hour = 14.5,
          mobs = { { name = "Ward Guardian", chance = 25.9 }, { name = "Razorfen Stalker", chance = 24.8 }, { name = "Razorfen Beast Trainer", chance = 24.7 } } },
        { kind = "mob", zone = "Badlands", levels = "35-45", spawn_count = 94, avg_chance = 51.9, respawn = 1963, per_hour = 472.1,
          mobs = { { name = "Shadowforge Warrior", chance = 64.1 }, { name = "Shadowforge Darkweaver", chance = 62.0 }, { name = "Shadowforge Tunneler", chance = 58.2 } } },
        { kind = "mob", zone = "Swamp of Sorrows", levels = "35-45", spawn_count = 63, avg_chance = 63.3, respawn = 300, per_hour = 478.3,
          mobs = { { name = "Lost One Hunter", chance = 66.0 }, { name = "Lost One Seer", chance = 65.9 }, { name = "Lost One Riftseeker", chance = 65.4 } } },
        { kind = "mob", zone = "Desolace", levels = "30-40", spawn_count = 263, avg_chance = 57.5, respawn = 908, per_hour = 1804.2,
          mobs = { { name = "Doomwarder", chance = 65.6 }, { name = "Undead Ravager", chance = 65.4 }, { name = "Maraudine Marauder", chance = 65.3 } } },
        { kind = "mob", zone = "Arathi Highlands", levels = "30-40", spawn_count = 179, avg_chance = 55.3, respawn = 19653, per_hour = 764.5,
          mobs = { { name = "Znort", chance = 66.9 }, { name = "Apothecary Jorell", chance = 65.3 }, { name = "Boulderfist Magus", chance = 65.0 } } },
        { kind = "mob", zone = "Ashenvale", levels = "18-30", spawn_count = 185, avg_chance = 50.0, respawn = 564, per_hour = 1079.2,
          mobs = { { name = "Uthil Mooncall", chance = 55.9 }, { name = "Horde Peon", chance = 54.2 }, { name = "Horde Scout", chance = 53.7 } } },
      }},
      { id = 2592,  name = "Wool Cloth", sources = {
        { kind = "dungeon", zone = "Razorfen Kraul", levels = "25-35", spawn_count = 128, avg_chance = 10.1, respawn = 8620, per_hour = 6.2,
          mobs = { { name = "Death's Head Sage", chance = 16.1 }, { name = "Razorfen Handler", chance = 15.5 }, { name = "Razorfen Dustweaver", chance = 10.5 } } },
        { kind = "dungeon", zone = "The Stockade", levels = "23-30", spawn_count = 28, avg_chance = 11.2, respawn = 58114, per_hour = 0.2,
          mobs = { { name = "Defias Captive", chance = 34.0 }, { name = "Targorr the Dread", chance = 19.6 }, { name = "Bruegal Ironknuckle", chance = 12.0 } } },
        { kind = "dungeon", zone = "Blackfathom Deeps", levels = "20-30", spawn_count = 103, avg_chance = 16.0, respawn = 11045, per_hour = 8.0,
          mobs = { { name = "Twilight Shadowmage", chance = 24.7 }, { name = "Twilight Loreseeker", chance = 23.5 }, { name = "Fallenroot Hellcaller", chance = 23.5 } } },
        { kind = "dungeon", zone = "Shadowfang Keep", levels = "20-30", spawn_count = 102, avg_chance = 9.5, respawn = 8082, per_hour = 4.6,
          mobs = { { name = "Deathstalker Adamant", chance = 39.2 }, { name = "Haunted Servitor", chance = 24.0 }, { name = "Sorcerer Ashcrombe", chance = 24.0 } } },
        { kind = "dungeon", zone = "The Deadmines", levels = "15-25", spawn_count = 146, avg_chance = 18.8, respawn = 15879, per_hour = 12.4,
          mobs = { { name = "Defias Wizard", chance = 24.7 }, { name = "Defias Strip Miner", chance = 19.5 }, { name = "Defias Miner", chance = 19.4 } } },
        { kind = "mob", zone = "Hillsbrad Foothills", levels = "20-30", spawn_count = 144, avg_chance = 43.8, respawn = 300, per_hour = 757.4,
          mobs = { { name = "Syndicate Watchman", chance = 47.4 }, { name = "Syndicate Rogue", chance = 47.2 }, { name = "Hillsbrad Farmhand", chance = 45.9 } } },
        { kind = "mob", zone = "Wetlands", levels = "20-30", spawn_count = 146, avg_chance = 46.1, respawn = 579, per_hour = 803.9,
          mobs = { { name = "Dragonmaw Scout", chance = 52.0 }, { name = "Dragonmaw Grunt", chance = 51.0 }, { name = "Mosshide Gnoll", chance = 49.4 } } },
        { kind = "mob", zone = "Ashenvale", levels = "18-30", spawn_count = 290, avg_chance = 37.9, respawn = 1043, per_hour = 1293.9,
          mobs = { { name = "Lesser Felguard", chance = 52.1 }, { name = "Dark Strand Assassin", chance = 51.1 }, { name = "Forsaken Seeker", chance = 50.6 } } },
        { kind = "mob", zone = "Stonetalon Mountains", levels = "15-30", spawn_count = 188, avg_chance = 39.6, respawn = 1152, per_hour = 889.7,
          mobs = { { name = "Son of Cenarius", chance = 53.2 }, { name = "Cenarion Botanist", chance = 52.5 }, { name = "Daughter of Cenarius", chance = 50.4 } } },
        { kind = "mob", zone = "The Barrens", levels = "10-25", spawn_count = 122, avg_chance = 38.3, respawn = 1779, per_hour = 595.4,
          mobs = { { name = "Bael'dun Excavator", chance = 52.4 }, { name = "Bael'dun Foreman", chance = 52.0 }, { name = "Lord Cyrik Blackforge", chance = 48.2 } } },
      }},
      { id = 2589,  name = "Linen Cloth", sources = {
        { kind = "dungeon", zone = "Scarlet Monastery", levels = "30-45", spawn_count = 5, avg_chance = 12.3, respawn = 3087, per_hour = 0.7,
          mobs = { { name = "Suffering Victim", chance = 12.3 } } },
        { kind = "dungeon", zone = "Blackfathom Deeps", levels = "20-30", spawn_count = 119, avg_chance = 4.7, respawn = 10528, per_hour = 2.8,
          mobs = { { name = "Fallenroot Hellcaller", chance = 8.6 }, { name = "Fallenroot Shadowstalker", chance = 8.4 }, { name = "Twilight Elementalist", chance = 8.2 } } },
        { kind = "dungeon", zone = "Shadowfang Keep", levels = "20-30", spawn_count = 102, avg_chance = 3.2, respawn = 8082, per_hour = 1.6,
          mobs = { { name = "Deathstalker Adamant", chance = 9.0 }, { name = "Tormented Officer", chance = 8.6 }, { name = "Wailing Guardsman", chance = 8.3 } } },
        { kind = "dungeon", zone = "The Deadmines", levels = "15-25", spawn_count = 146, avg_chance = 16.4, respawn = 15879, per_hour = 11.0,
          mobs = { { name = "Defias Strip Miner", chance = 18.8 }, { name = "Defias Miner", chance = 18.6 }, { name = "Defias Blackguard", chance = 15.1 } } },
        { kind = "dungeon", zone = "Wailing Caverns", levels = "15-25", spawn_count = 169, avg_chance = 6.8, respawn = 8606, per_hour = 5.6,
          mobs = { { name = "Druid of the Fang", chance = 17.6 }, { name = "Lord Cobrahn", chance = 13.0 }, { name = "Lord Pythas", chance = 13.0 } } },
        { kind = "mob", zone = "The Barrens", levels = "10-25", spawn_count = 483, avg_chance = 63.7, respawn = 362, per_hour = 3977.0,
          mobs = { { name = "Burning Blade Toxicologist", chance = 75.9 }, { name = "Venture Co. Mercenary", chance = 72.6 }, { name = "Burning Blade Crusher", chance = 72.0 } } },
        { kind = "mob", zone = "Westfall", levels = "10-20", spawn_count = 121, avg_chance = 57.8, respawn = 357, per_hour = 835.3,
          mobs = { { name = "Defias Raider", chance = 70.8 }, { name = "Defias Pathstalker", chance = 68.3 }, { name = "Defias Pillager", chance = 65.8 } } },
        { kind = "mob", zone = "Loch Modan", levels = "10-20", spawn_count = 151, avg_chance = 61.0, respawn = 302, per_hour = 1103.4,
          mobs = { { name = "Dark Iron Raider", chance = 71.7 }, { name = "Stonesplinter Bonesnapper", chance = 69.5 }, { name = "Saean", chance = 68.4 } } },
        { kind = "mob", zone = "Darkshore", levels = "10-20", spawn_count = 101, avg_chance = 54.6, respawn = 362, per_hour = 717.1,
          mobs = { { name = "Blackwood Windtalker", chance = 70.1 }, { name = "Blackwood Pathfinder", chance = 69.1 }, { name = "Deth'ryll Satyr", chance = 57.9 } } },
        { kind = "mob", zone = "Elwynn Forest", levels = "1-10", spawn_count = 189, avg_chance = 44.5, respawn = 679, per_hour = 1467.3,
          mobs = { { name = "Defias Ambusher", chance = 58.5 }, { name = "Defias Cutpurse", chance = 54.2 }, { name = "Defias Bodyguard", chance = 52.4 } } },
      }},
    }},
    { category = "Elemental", items = {
      { id = 7078,  name = "Essence of Fire", sources = {
        { kind = "dungeon", zone = "Molten Core", levels = "60", spawn_count = 62, avg_chance = 20.6, respawn = 97084, per_hour = 2.5,
          mobs = { { name = "Sulfuron Harbinger", chance = 83.8 }, { name = "Gehennas", chance = 79.4 }, { name = "Shazzrah", chance = 76.7 } } },
        { kind = "dungeon", zone = "Blackrock Spire", levels = "55-60", spawn_count = 1, avg_chance = 2.6, respawn = 1000000,
          mobs = { { name = "Pyroguard Emberseer", chance = 2.6 } } },
        { kind = "dungeon", zone = "Ruins of Ahn'Qiraj", levels = "55-60", spawn_count = 40, respawn = 7200,
          mobs = { { name = "Silicate Feeder", chance = 0.02 } } },
        { kind = "dungeon", zone = "Blackrock Depths", levels = "52-60", spawn_count = 79, avg_chance = 6.4, respawn = 30349, per_hour = 2.5,
          mobs = { { name = "Fireguard Destroyer", chance = 8.6 }, { name = "Fireguard", chance = 6.1 }, { name = "Ambassador Flamelash", chance = 4.6 } } },
        { kind = "mob", zone = "Silithus", levels = "55-60",
          mobs = { { name = "Prince Skaldrenox", chance = 84.0 }, { name = "The Duke of Cynders", chance = 8.1 }, { name = "Crimson Templar", chance = 4.3 } } },
        { kind = "mob", zone = "Burning Steppes", levels = "50-58", spawn_count = 1, avg_chance = 3.3, respawn = 129600,
          mobs = { { name = "Volchan", chance = 3.3 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55", spawn_count = 39, avg_chance = 4.4, respawn = 13569, per_hour = 9.8,
          mobs = { { name = "Baron Charr", chance = 83.0 }, { name = "Blazerunner", chance = 3.4 }, { name = "Living Blaze", chance = 2.3 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Entropic Horror", chance = 2.6 }, { name = "Entropic Beast", chance = 1.3 } } },
        { kind = "vendor", zone = "Lokhtos Darkbargainer (Blackrock Depths)" },
      }},
      { id = 7080,  name = "Essence of Water", sources = {
        { kind = "dungeon", zone = "Dire Maul", levels = "55-60", spawn_count = 1, avg_chance = 13.1, respawn = 1000000,
          mobs = { { name = "Hydrospawn", chance = 13.1 } } },
        { kind = "mob", zone = "Silithus", levels = "55-60",
          mobs = { { name = "Lord Skwol", chance = 80.6 }, { name = "The Duke of Fathoms", chance = 6.9 }, { name = "Azure Templar", chance = 4.5 } } },
        { kind = "mob", zone = "Eastern Plaguelands", levels = "53-60", spawn_count = 33, avg_chance = 2.6, respawn = 345, per_hour = 9.0,
          mobs = { { name = "Blighted Horror", chance = 3.1 }, { name = "Plague Monstrosity", chance = 2.8 }, { name = "Blighted Surge", chance = 2.4 } } },
        { kind = "mob", zone = "Winterspring", levels = "53-60", spawn_count = 4, avg_chance = 22.0, respawn = 129600,
          mobs = { { name = "Princess Tempestria", chance = 79.1 }, { name = "Watery Invader", chance = 3.0 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55", spawn_count = 12, avg_chance = 5.6, respawn = 300, per_hour = 8.0,
          mobs = { { name = "Toxic Horror", chance = 5.6 } } },
        { kind = "vendor", zone = "Lokhtos Darkbargainer (Blackrock Depths)" },
      }},
      { id = 7082,  name = "Essence of Air", sources = {
        { kind = "mob", zone = "Silithus", levels = "55-60", spawn_count = 63, avg_chance = 5.3, respawn = 8876, per_hour = 27.8,
          mobs = { { name = "High Marshal Whirlaxis", chance = 82.5 }, { name = "The Windreaver", chance = 80.2 }, { name = "The Duke of Zephyrs", chance = 6.9 } } },
        { kind = "vendor", zone = "Lokhtos Darkbargainer (Blackrock Depths)" },
      }},
      { id = 7076,  name = "Heart of Fire", sources = {
        { kind = "mine", zone = "Ahn'Qiraj", levels = "60" },
        { kind = "mine", zone = "Silithus", levels = "55-60" },
        { kind = "mine", zone = "Ruins of Ahn'Qiraj", levels = "55-60" },
        { kind = "dungeon", zone = "Molten Core", levels = "60", spawn_count = 56, avg_chance = 18.0, respawn = 41503, per_hour = 8.0,
          mobs = { { name = "Golemagg the Incinerator", chance = 81.0 }, { name = "Garr", chance = 68.3 }, { name = "Lava Surger", chance = 25.0 } } },
        { kind = "mob", zone = "Silithus", levels = "55-60",
          mobs = { { name = "Baron Kazum", chance = 85.7 }, { name = "The Duke of Shards", chance = 10.2 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55", spawn_count = 7, avg_chance = 6.2, respawn = 600, per_hour = 2.6,
          mobs = { { name = "Stone Guardian", chance = 6.2 } } },
        { kind = "mob", zone = "Azshara", levels = "45-55", spawn_count = 1, avg_chance = 83.0, respawn = 129600,
          mobs = { { name = "Avalanchion", chance = 83.0 } } },
        { kind = "vendor", zone = "Lokhtos Darkbargainer (Blackrock Depths)" },
      }},
      { id = 11382, name = "Blood of the Mountain", sources = {
        { kind = "dungeon", zone = "Molten Core", levels = "60", spawn_count = 68, avg_chance = 1.7, respawn = 16523, per_hour = 0.1,
          mobs = { { name = "Molten Destroyer", chance = 12.7 }, { name = "Molten Giant", chance = 0.02 }, { name = "Firewalker", chance = 0.02 } } },
        { kind = "dungeon", zone = "Blackrock Depths", levels = "52-60", spawn_count = 232, respawn = 7200,
          mobs = { { name = "Anvilrage Footman", chance = 0.02 }, { name = "Warbringer Construct", chance = 0.02 }, { name = "Fireguard Destroyer", chance = 0.02 } } },
        { kind = "vendor", zone = "Lokhtos Darkbargainer (Blackrock Depths)" },
      }},
      { id = 12803, name = "Living Essence", sources = {
        { kind = "dungeon", zone = "Dire Maul", levels = "55-60", spawn_count = 240, avg_chance = 6.4, respawn = 7215, per_hour = 7.6,
          mobs = { { name = "Ironbark Protector", chance = 18.4 }, { name = "Warpwood Crusher", chance = 18.3 }, { name = "Warpwood Stomper", chance = 16.6 } } },
        { kind = "mob", zone = "Western Plaguelands", levels = "51-58", spawn_count = 18, avg_chance = 10.8, respawn = 5098, per_hour = 11.4,
          mobs = { { name = "The Husk", chance = 94.9 }, { name = "Decaying Horror", chance = 6.3 }, { name = "Rotting Behemoth", chance = 5.8 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55", spawn_count = 58, avg_chance = 2.6, respawn = 300, per_hour = 18.3,
          mobs = { { name = "Tar Lurker", chance = 3.5 }, { name = "Tar Lord", chance = 3.4 }, { name = "Tar Creeper", chance = 1.9 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55", spawn_count = 61, avg_chance = 2.0, respawn = 1077, per_hour = 14.4,
          mobs = { { name = "Dessecus", chance = 5.1 }, { name = "Withered Protector", chance = 3.1 }, { name = "Warpwood Shredder", chance = 2.8 } } },
      }},
      { id = 12808, name = "Essence of Undeath", sources = {
        { kind = "dungeon", zone = "Zul'Gurub", levels = "60", spawn_count = 21, avg_chance = 7.3, respawn = 7200, per_hour = 0.8,
          mobs = { { name = "Withered Mistress", chance = 7.3 } } },
        { kind = "dungeon", zone = "Naxxramas", levels = "60", spawn_count = 257, avg_chance = 2.2, respawn = 4233, per_hour = 5.2,
          mobs = { { name = "Necro Knight", chance = 16.7 }, { name = "Unholy Axe", chance = 4.1 }, { name = "Bony Construct", chance = 3.6 } } },
        { kind = "dungeon", zone = "Stratholme", levels = "55-60", spawn_count = 271, avg_chance = 3.8, respawn = 15091, per_hour = 5.0,
          mobs = { { name = "Spectral Citizen", chance = 8.1 }, { name = "Ghostly Citizen", chance = 7.6 }, { name = "Wailing Banshee", chance = 5.7 } } },
        { kind = "dungeon", zone = "Scholomance", levels = "55-60", spawn_count = 90, avg_chance = 4.5, respawn = 16640, per_hour = 1.9,
          mobs = { { name = "Risen Warrior", chance = 8.1 }, { name = "Aspect of Malice", chance = 6.3 }, { name = "Splintered Skeleton", chance = 6.0 } } },
        { kind = "dungeon", zone = "Dire Maul", levels = "55-60", spawn_count = 120, avg_chance = 4.8, respawn = 12660, per_hour = 2.8,
          mobs = { { name = "Eldreth Seether", chance = 7.8 }, { name = "Eldreth Spectre", chance = 7.8 }, { name = "Eldreth Phantasm", chance = 6.9 } } },
        { kind = "mob", zone = "Eastern Plaguelands", levels = "53-60", spawn_count = 4, avg_chance = 5.7, respawn = 24175, per_hour = 1.6,
          mobs = { { name = "Nathanos Blightcaller", chance = 13.5 }, { name = "Fallen Hero", chance = 4.9 }, { name = "Horgus the Ravager", chance = 4.7 } } },
        { kind = "mob", zone = "Western Plaguelands", levels = "51-58", spawn_count = 7, avg_chance = 4.2, respawn = 364, per_hour = 3.0,
          mobs = { { name = "Araj the Summoner", chance = 4.7 }, { name = "Skeletal Warlord", chance = 4.1 } } },
      }},
      { id = 7067,  name = "Elemental Earth", sources = {
        { kind = "dungeon", zone = "Molten Core", levels = "60", spawn_count = 54, avg_chance = 1.3, respawn = 20640, per_hour = 0.5,
          mobs = { { name = "Molten Giant", chance = 1.9 }, { name = "Lava Surger", chance = 1.6 }, { name = "Lava Annihilator", chance = 1.2 } } },
        { kind = "dungeon", zone = "Blackrock Depths", levels = "52-60", spawn_count = 3, avg_chance = 1.7, respawn = 417600,
          mobs = { { name = "Bael'Gar", chance = 2.1 }, { name = "Lord Roccor", chance = 1.6 }, { name = "Magmus", chance = 1.5 } } },
        { kind = "dungeon", zone = "Maraudon (Inner)", levels = "40-50", spawn_count = 8, avg_chance = 3.6, respawn = 11700, per_hour = 0.1,
          mobs = { { name = "Theradrim Shardling", chance = 4.1 }, { name = "Theradrim Guardian", chance = 3.9 }, { name = "Landslide", chance = 1.8 } } },
        { kind = "dungeon", zone = "Maraudon", levels = "40-50", spawn_count = 7, avg_chance = 3.8, respawn = 7200, per_hour = 0.1,
          mobs = { { name = "Theradrim Guardian", chance = 3.8 } } },
        { kind = "mob", zone = "Silithus", levels = "55-60", spawn_count = 31, avg_chance = 5.0, respawn = 300, per_hour = 18.6,
          mobs = { { name = "Baron Kazum", chance = 7.7 }, { name = "Desert Rager", chance = 6.0 }, { name = "The Duke of Shards", chance = 5.4 } } },
        { kind = "mob", zone = "Burning Steppes", levels = "50-58", spawn_count = 16, avg_chance = 4.9, respawn = 8569, per_hour = 5.5,
          mobs = { { name = "Obsidian Elemental", chance = 5.3 }, { name = "Greater Obsidian Elemental", chance = 4.9 }, { name = "Volchan", chance = 2.6 } } },
        { kind = "mob", zone = "Badlands", levels = "35-45", spawn_count = 92, avg_chance = 7.1, respawn = 1304, per_hour = 76.7,
          mobs = { { name = "Rock Elemental", chance = 9.6 }, { name = "Lesser Rock Elemental", chance = 8.8 }, { name = "Enraged Rock Elemental", chance = 4.9 } } },
        { kind = "mob", zone = "Arathi Highlands", levels = "30-40", spawn_count = 16, avg_chance = 9.9, respawn = 400, per_hour = 14.2,
          mobs = { { name = "Rumbling Exile", chance = 9.9 }, { name = "Myzrael", chance = 3.0 } } },
        { kind = "mob", zone = "Alterac Mountains", levels = "30-40", spawn_count = 23, avg_chance = 7.1, respawn = 1303, per_hour = 18.7,
          mobs = { { name = "Stone Fury", chance = 8.4 }, { name = "Elemental Slave", chance = 7.1 } } },
      }},
      { id = 7068,  name = "Elemental Fire", sources = {
        { kind = "dungeon", zone = "Molten Core", levels = "60", spawn_count = 61, avg_chance = 1.7, respawn = 88761, per_hour = 0.2,
          mobs = { { name = "Baron Geddon", chance = 7.4 }, { name = "Shazzrah", chance = 6.2 }, { name = "Gehennas", chance = 5.9 } } },
        { kind = "dungeon", zone = "Blackrock Spire", levels = "55-60", spawn_count = 1, avg_chance = 0.7, respawn = 1000000,
          mobs = { { name = "Pyroguard Emberseer", chance = 0.7 } } },
        { kind = "dungeon", zone = "Blackrock Depths", levels = "52-60", spawn_count = 79, avg_chance = 4.6, respawn = 30349, per_hour = 1.8,
          mobs = { { name = "Blazing Fireguard", chance = 5.0 }, { name = "Fireguard", chance = 4.8 }, { name = "Fireguard Destroyer", chance = 4.6 } } },
        { kind = "mob", zone = "Un'Goro Crater", levels = "48-55", spawn_count = 39, avg_chance = 7.3, respawn = 13569, per_hour = 23.5,
          mobs = { { name = "Baron Charr", chance = 72.7 }, { name = "Blazerunner", chance = 6.5 }, { name = "Living Blaze", chance = 5.7 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55",
          mobs = { { name = "Entropic Horror", chance = 6.3 }, { name = "Entropic Beast", chance = 5.9 } } },
        { kind = "mob", zone = "Searing Gorge", levels = "43-52", spawn_count = 39, avg_chance = 5.5, respawn = 5367, per_hour = 14.4,
          mobs = { { name = "Scald", chance = 6.5 }, { name = "Magma Elemental", chance = 5.4 }, { name = "Inferno Elemental", chance = 5.4 } } },
        { kind = "mob", zone = "Arathi Highlands", levels = "30-40", spawn_count = 14, avg_chance = 11.1, respawn = 400, per_hour = 14.0,
          mobs = { { name = "Burning Exile", chance = 11.1 } } },
        { kind = "mob", zone = "Stonetalon Mountains", levels = "15-30", spawn_count = 20, avg_chance = 3.4, respawn = 300, per_hour = 8.1,
          mobs = { { name = "Burning Destroyer", chance = 4.8 }, { name = "Burning Ravager", chance = 3.2 }, { name = "Rogue Flame Spirit", chance = 2.2 } } },
      }},
      { id = 7070,  name = "Elemental Water", sources = {
        { kind = "dungeon", zone = "Dire Maul", levels = "55-60", spawn_count = 1, avg_chance = 22.0, respawn = 1000000,
          mobs = { { name = "Hydrospawn", chance = 22.0 } } },
        { kind = "dungeon", zone = "Maraudon (Inner)", levels = "40-50", spawn_count = 1, avg_chance = 2.1, respawn = 43200,
          mobs = { { name = "Noxxious Scion", chance = 4.8 }, { name = "Noxxion", chance = 2.1 } } },
        { kind = "dungeon", zone = "Gnomeregan", levels = "29-38", spawn_count = 1, avg_chance = 2.7, respawn = 86400,
          mobs = { { name = "Irradiated Horror", chance = 5.2 }, { name = "Viscous Fallout", chance = 2.7 } } },
        { kind = "dungeon", zone = "Blackfathom Deeps", levels = "20-30",
          mobs = { { name = "Aku'mai Servant", chance = 5.2 }, { name = "Baron Aquanis", chance = 1.8 } } },
        { kind = "mob", zone = "Eastern Plaguelands", levels = "53-60", spawn_count = 33, avg_chance = 5.9, respawn = 345, per_hour = 20.3,
          mobs = { { name = "Blighted Surge", chance = 6.0 }, { name = "Plague Ravager", chance = 5.9 }, { name = "Plague Monstrosity", chance = 5.8 } } },
        { kind = "mob", zone = "Felwood", levels = "48-55", spawn_count = 12, avg_chance = 5.5, respawn = 300, per_hour = 7.9,
          mobs = { { name = "Toxic Horror", chance = 5.5 } } },
        { kind = "mob", zone = "Feralas", levels = "40-50", spawn_count = 59, avg_chance = 6.6, respawn = 300, per_hour = 46.5,
          mobs = { { name = "Sea Elemental", chance = 7.1 }, { name = "Sea Spray", chance = 6.2 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 24, avg_chance = 9.1, respawn = 300, per_hour = 26.1,
          mobs = { { name = "Lesser Water Elemental", chance = 9.1 } } },
        { kind = "mob", zone = "Arathi Highlands", levels = "30-40", spawn_count = 14, avg_chance = 10.3, respawn = 400, per_hour = 13.0,
          mobs = { { name = "Cresting Exile", chance = 10.3 } } },
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
        { kind = "dungeon", zone = "Uldaman", levels = "35-45", spawn_count = 12, avg_chance = 4.6, respawn = 7200, per_hour = 0.3,
          mobs = { { name = "Jadespine Basilisk", chance = 4.8 }, { name = "Shrike Bat", chance = 4.5 } } },
        { kind = "dungeon", zone = "Scarlet Monastery", levels = "30-45", spawn_count = 7, avg_chance = 3.3, respawn = 7200, per_hour = 0.1,
          mobs = { { name = "Scarlet Tracking Hound", chance = 3.3 } } },
        { kind = "dungeon", zone = "Razorfen Downs", levels = "30-45",
          mobs = { { name = "Tomb Reaver", chance = 4.9 }, { name = "Tomb Fiend", chance = 4.6 }, { name = "Tuten'kash", chance = 2.0 } } },
        { kind = "dungeon", zone = "Razorfen Kraul", levels = "25-35", spawn_count = 21, avg_chance = 2.1, respawn = 9000, per_hour = 0.2,
          mobs = { { name = "Greater Kraul Bat", chance = 2.5 }, { name = "Kraul Bat", chance = 1.9 }, { name = "Blind Hunter", chance = 1.3 } } },
        { kind = "dungeon", zone = "Shadowfang Keep", levels = "20-30", spawn_count = 1, avg_chance = 0.6, respawn = 43200,
          mobs = { { name = "Fenrus the Devourer", chance = 0.6 } } },
        { kind = "mob", zone = "Badlands", levels = "35-45", spawn_count = 180, avg_chance = 5.0, respawn = 300, per_hour = 108.1,
          mobs = { { name = "Ridge Huntress", chance = 6.0 }, { name = "Elder Crag Coyote", chance = 5.1 }, { name = "Ridge Stalker", chance = 4.7 } } },
        { kind = "mob", zone = "Swamp of Sorrows", levels = "35-45", spawn_count = 136, avg_chance = 5.7, respawn = 312, per_hour = 90.0,
          mobs = { { name = "Dreaming Whelp", chance = 9.8 }, { name = "Adolescent Whelp", chance = 7.6 }, { name = "Shadow Panther", chance = 6.6 } } },
        { kind = "mob", zone = "Dustwallow Marsh", levels = "35-45", spawn_count = 275, avg_chance = 5.3, respawn = 1013, per_hour = 142.7,
          mobs = { { name = "Murk Thresher", chance = 7.1 }, { name = "Young Murk Thresher", chance = 6.3 }, { name = "Elder Murk Thresher", chance = 6.2 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 292, avg_chance = 4.2, respawn = 522, per_hour = 147.8,
          mobs = { { name = "Silverback Patriarch", chance = 6.2 }, { name = "Cold Eye Basilisk", chance = 5.4 }, { name = "Jungle Stalker", chance = 5.3 } } },
        { kind = "mob", zone = "Arathi Highlands", levels = "30-40", spawn_count = 360, avg_chance = 3.0, respawn = 399, per_hour = 96.6,
          mobs = { { name = "Giant Plains Creeper", chance = 4.3 }, { name = "Highland Fleshstalker", chance = 4.1 }, { name = "Highland Thrasher", chance = 3.1 } } },
      }},
      { id = 5635,  name = "Sharp Claw", sources = {
        { kind = "dungeon", zone = "Gnomeregan", levels = "29-38",
          mobs = { { name = "Chomper", chance = 6.9 } } },
        { kind = "dungeon", zone = "Razorfen Kraul", levels = "25-35", spawn_count = 21, avg_chance = 4.6, respawn = 9000, per_hour = 0.5,
          mobs = { { name = "Greater Kraul Bat", chance = 4.7 }, { name = "Kraul Bat", chance = 4.7 }, { name = "Blind Hunter", chance = 3.8 } } },
        { kind = "dungeon", zone = "Shadowfang Keep", levels = "20-30", spawn_count = 88, avg_chance = 5.1, respawn = 9020, per_hour = 2.4,
          mobs = { { name = "Son of Arugal", chance = 8.9 }, { name = "Shadowfang Ragetooth", chance = 7.7 }, { name = "Shadowfang Glutton", chance = 7.0 } } },
        { kind = "dungeon", zone = "Wailing Caverns", levels = "15-25", spawn_count = 5, avg_chance = 1.8, respawn = 23040,
          mobs = { { name = "Deviate Ravager", chance = 1.9 }, { name = "Deviate Guardian", chance = 1.8 }, { name = "Deviate Faerie Dragon", chance = 1.7 } } },
        { kind = "mob", zone = "Thousand Needles", levels = "25-35", spawn_count = 212, avg_chance = 6.1, respawn = 301, per_hour = 154.6,
          mobs = { { name = "Screeching Roguefeather", chance = 7.1 }, { name = "Screeching Windcaller", chance = 7.1 }, { name = "Screeching Harpy", chance = 7.0 } } },
        { kind = "mob", zone = "Wetlands", levels = "20-30", spawn_count = 257, avg_chance = 6.8, respawn = 859, per_hour = 209.9,
          mobs = { { name = "Flamesnorting Whelp", chance = 18.4 }, { name = "Crimson Whelp", chance = 13.2 }, { name = "Lost Whelp", chance = 8.4 } } },
        { kind = "mob", zone = "Duskwood", levels = "18-30", spawn_count = 291, avg_chance = 11.5, respawn = 1272, per_hour = 386.5,
          mobs = { { name = "Nightbane Dark Runner", chance = 20.0 }, { name = "Nightbane Shadow Weaver", chance = 19.7 }, { name = "Gutspill", chance = 19.7 } } },
        { kind = "mob", zone = "Stonetalon Mountains", levels = "15-30", spawn_count = 173, avg_chance = 4.9, respawn = 1628, per_hour = 99.1,
          mobs = { { name = "Wily Fey Dragon", chance = 6.1 }, { name = "Bloodfury Harpy", chance = 5.8 }, { name = "Bloodfury Storm Witch", chance = 5.7 } } },
        { kind = "mob", zone = "The Barrens", levels = "10-25", spawn_count = 768, avg_chance = 1.9, respawn = 386, per_hour = 188.9,
          mobs = { { name = "Takk the Leaper", chance = 4.3 }, { name = "Sister Rathtalon", chance = 4.0 }, { name = "Hecklefang Stalker", chance = 3.8 } } },
      }},
      { id = 4402,  name = "Small Flame Sac", sources = {
        { kind = "dungeon", zone = "Dire Maul", levels = "55-60", spawn_count = 9, avg_chance = 34.0, respawn = 7200, per_hour = 1.5,
          mobs = { { name = "Eldreth Darter", chance = 34.0 } } },
        { kind = "mob", zone = "Feralas", levels = "40-50", spawn_count = 38, avg_chance = 23.7, respawn = 300, per_hour = 108.3,
          mobs = { { name = "Sprite Dragon", chance = 41.0 }, { name = "Captured Sprite Darter", chance = 22.0 }, { name = "Sprite Darter", chance = 20.6 } } },
        { kind = "mob", zone = "Badlands", levels = "35-45", spawn_count = 40, avg_chance = 16.6, respawn = 390, per_hour = 67.0,
          mobs = { { name = "Scorched Guardian", chance = 17.6 }, { name = "Scalding Whelp", chance = 16.2 } } },
        { kind = "mob", zone = "Dustwallow Marsh", levels = "35-45", spawn_count = 59, avg_chance = 18.3, respawn = 1452, per_hour = 106.5,
          mobs = { { name = "Searing Hatchling", chance = 18.5 }, { name = "Searing Whelp", chance = 18.2 }, { name = "Brimgore", chance = 15.9 } } },
        { kind = "mob", zone = "Swamp of Sorrows", levels = "35-45", spawn_count = 13, avg_chance = 23.0, respawn = 300, per_hour = 35.9,
          mobs = { { name = "Dreaming Whelp", chance = 24.2 }, { name = "Adolescent Whelp", chance = 22.0 } } },
        { kind = "mob", zone = "Wetlands", levels = "20-30", spawn_count = 70, avg_chance = 13.8, respawn = 300, per_hour = 116.2,
          mobs = { { name = "Flamesnorting Whelp", chance = 23.2 }, { name = "Crimson Whelp", chance = 16.8 }, { name = "Lost Whelp", chance = 8.8 } } },
      }},
    }},
    { category = "Cooking Supplies", items = {
      { id = 21024, name = "Chimaerok Tenderloin", sources = {
        { kind = "mob", zone = "Feralas", levels = "40-50", spawn_count = 27, avg_chance = 23.9, respawn = 600, per_hour = 38.7,
          mobs = { { name = "Arcane Chimaerok", chance = 24.5 }, { name = "Chimaerok", chance = 24.3 }, { name = "Chimaerok Devourer", chance = 24.0 } } },
      }},
      { id = 21153, name = "Raw Greater Sagefish", sources = {
        { kind = "fish", zone = "Ashenvale (Greater Sagefish Schools)",       levels = "18-30" },
        { kind = "fish", zone = "Hillsbrad Foothills (Greater Sagefish Schools)", levels = "20-30" },
        { kind = "fish", zone = "Desolace (Greater Sagefish Schools)",        levels = "30-40" },
        { kind = "fish", zone = "Stranglethorn Vale (Greater Sagefish Schools)", levels = "30-45" },
      }},
      { id = 20424, name = "Sandworm Meat", sources = {
        { kind = "mob", zone = "Silithus", levels = "55-60", spawn_count = 134, avg_chance = 27.8, respawn = 300, per_hour = 447.3,
          mobs = { { name = "Dredge Striker", chance = 27.9 }, { name = "Dredge Crusher", chance = 27.8 } } },
      }},
      { id = 18255, name = "Runn Tum Tuber", sources = {
        { kind = "dungeon", zone = "Dire Maul", levels = "55-60", spawn_count = 467, avg_chance = 0.1, respawn = 9326, per_hour = 0.2,
          mobs = { { name = "Pusillin", chance = 4.8 }, { name = "Warpwood Crusher", chance = 0.8 }, { name = "Phase Lasher", chance = 0.4 } } },
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
        { kind = "dungeon", zone = "Molten Core", levels = "60", spawn_count = 33, avg_chance = 5.0, respawn = 23302, per_hour = 2.1,
          mobs = { { name = "Lava Surger", chance = 6.7 }, { name = "Garr", chance = 6.0 }, { name = "Lava Annihilator", chance = 5.3 } } },
        { kind = "dungeon", zone = "Blackrock Depths", levels = "52-60", spawn_count = 37, avg_chance = 18.8, respawn = 55654, per_hour = 3.4,
          mobs = { { name = "Wrath Hammer Construct", chance = 20.4 }, { name = "Molten War Golem", chance = 20.0 }, { name = "Ragereaver Golem", chance = 19.7 } } },
        { kind = "dungeon", zone = "Maraudon (Inner)", levels = "40-50", spawn_count = 25, avg_chance = 21.9, respawn = 10080, per_hour = 2.6,
          mobs = { { name = "Primordial Behemoth", chance = 26.0 }, { name = "Theradrim Shardling", chance = 16.2 }, { name = "Theradrim Guardian", chance = 15.4 } } },
        { kind = "dungeon", zone = "Maraudon", levels = "40-50", spawn_count = 25, avg_chance = 18.4, respawn = 10080, per_hour = 2.2,
          mobs = { { name = "Primordial Behemoth", chance = 20.0 }, { name = "Theradrim Guardian", chance = 16.8 }, { name = "Princess Theradras", chance = 13.0 } } },
        { kind = "dungeon", zone = "Uldaman", levels = "35-45", spawn_count = 22, avg_chance = 25.5, respawn = 17018, per_hour = 2.3,
          mobs = { { name = "Vault Warder", chance = 32.7 }, { name = "Stone Keeper", chance = 26.9 }, { name = "Stone Steward", chance = 26.2 } } },
        { kind = "mob", zone = "Silithus", levels = "55-60", spawn_count = 32, avg_chance = 18.6, respawn = 3441, per_hour = 70.7,
          mobs = { { name = "Desert Rumbler", chance = 19.1 }, { name = "Desert Rager", chance = 17.8 }, { name = "Setis", chance = 5.1 } } },
        { kind = "mob", zone = "Searing Gorge", levels = "43-52", spawn_count = 37, avg_chance = 26.2, respawn = 8616, per_hour = 61.8,
          mobs = { { name = "Tempered War Golem", chance = 28.7 }, { name = "Heavy War Golem", chance = 28.1 }, { name = "Smoldar", chance = 18.6 } } },
        { kind = "mob", zone = "Badlands", levels = "35-45", spawn_count = 120, avg_chance = 20.0, respawn = 13580, per_hour = 234.0,
          mobs = { { name = "Stone Golem", chance = 37.3 }, { name = "Obsidian Golem", chance = 27.8 }, { name = "Enraged Rock Elemental", chance = 19.3 } } },
        { kind = "mob", zone = "Arathi Highlands", levels = "30-40", spawn_count = 17, avg_chance = 19.3, respawn = 528, per_hour = 28.5,
          mobs = { { name = "Thenan", chance = 28.6 }, { name = "Rumbling Exile", chance = 19.7 }, { name = "Fozruk", chance = 12.7 } } },
        { kind = "mob", zone = "Alterac Mountains", levels = "30-40", spawn_count = 23, avg_chance = 20.1, respawn = 1303, per_hour = 53.5,
          mobs = { { name = "Elemental Slave", chance = 20.2 }, { name = "Stone Fury", chance = 17.7 } } },
      }},
      { id = 9061,  name = "Goblin Rocket Fuel", sources = {
        { kind = "dungeon", zone = "Blackrock Spire", levels = "55-60", spawn_count = 6, respawn = 8400,
          mobs = { { name = "Spirestone Ogre Magus", chance = 0.02 } } },
        { kind = "dungeon", zone = "Maraudon (Inner)", levels = "40-50", spawn_count = 1, avg_chance = 0.4, respawn = 43200,
          mobs = { { name = "Tinkerer Gizlock", chance = 0.4 } } },
        { kind = "mob", zone = "Badlands", levels = "35-45", spawn_count = 7, avg_chance = 2.0, respawn = 144000,
          mobs = { { name = "7:XT", chance = 2.0 } } },
      }},
      -- Sold by every cooking-supply / general-goods vendor; no need to list.
      { id = 3713,  name = "Soothing Spices" },
      { id = 159,   name = "Refreshing Spring Water", sources = {
        { kind = "mob", zone = "Elwynn Forest", levels = "1-10", spawn_count = 426, avg_chance = 7.5, respawn = 349, per_hour = 612.7,
          mobs = { { name = "Kobold Vermin", chance = 11.0 }, { name = "Kobold Worker", chance = 10.8 }, { name = "Kobold Laborer", chance = 10.7 } } },
        { kind = "mob", zone = "Tirisfal Glades", levels = "1-10", spawn_count = 598, avg_chance = 6.9, respawn = 356, per_hour = 654.0,
          mobs = { { name = "Daniel Ulfman", chance = 16.5 }, { name = "Karrel Grayves", chance = 16.3 }, { name = "Mindless Zombie", chance = 14.9 } } },
        { kind = "mob", zone = "Durotar", levels = "1-10", spawn_count = 415, avg_chance = 6.3, respawn = 686, per_hour = 343.1,
          mobs = { { name = "Vile Familiar", chance = 10.3 }, { name = "Razormane Scout", chance = 7.2 }, { name = "Razormane Quilboar", chance = 7.2 } } },
        { kind = "mob", zone = "Dun Morogh", levels = "1-10", spawn_count = 466, avg_chance = 9.3, respawn = 373, per_hour = 726.3,
          mobs = { { name = "Rockjaw Raider", chance = 15.0 }, { name = "Rockjaw Trogg", chance = 15.0 }, { name = "Burly Rockjaw Trogg", chance = 14.6 } } },
        { kind = "mob", zone = "Teldrassil", levels = "1-10", spawn_count = 431, avg_chance = 6.6, respawn = 352, per_hour = 340.1,
          mobs = { { name = "Agal", chance = 12.6 }, { name = "Gnarlpine Totemic", chance = 8.5 }, { name = "Minion of Sethir", chance = 8.3 } } },
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
        { kind = "dungeon", zone = "Blackrock Spire", levels = "55-60", spawn_count = 44, respawn = 10800,
          mobs = { { name = "Rage Talon Dragonspawn", chance = 0.02 }, { name = "Blackhand Iron Guard", chance = 0.02 }, { name = "Rage Talon Captain", chance = 0.02 } } },
        { kind = "dungeon", zone = "Stratholme", levels = "55-60", spawn_count = 17, respawn = 7200,
          mobs = { { name = "Thuzadin Shadowcaster", chance = 0.02 }, { name = "Crimson Conjuror", chance = 0.02 } } },
        { kind = "dungeon", zone = "Dire Maul", levels = "55-60", spawn_count = 23, respawn = 7200,
          mobs = { { name = "Gordok Warlock", chance = 0.02 }, { name = "Wildspawn Shadowstalker", chance = 0.02 } } },
        { kind = "dungeon", zone = "Gnomeregan", levels = "29-38", spawn_count = 7, avg_chance = 10.8, respawn = 41143, per_hour = 0.4,
          mobs = { { name = "Peacekeeper Security Suit", chance = 17.7 }, { name = "Mechano-Frostwalker", chance = 4.6 }, { name = "Mechano-Flamewalker", chance = 4.1 } } },
        { kind = "mob", zone = "Searing Gorge", levels = "43-52", spawn_count = 1, avg_chance = 17.8, respawn = 500, per_hour = 1.3,
          mobs = { { name = "Clunk", chance = 17.8 } } },
        { kind = "mob", zone = "Badlands", levels = "35-45", spawn_count = 7, avg_chance = 15.2, respawn = 144000,
          mobs = { { name = "7:XT", chance = 15.2 } } },
        { kind = "mob", zone = "Stranglethorn Vale", levels = "30-45", spawn_count = 2, avg_chance = 11.7, respawn = 300, per_hour = 2.8,
          mobs = { { name = "Venture Co. Shredder", chance = 11.7 } } },
      }},
    }},
    { category = "Enchanting", items = {
      -- Enchanting mats come from disenchanting items; the resulting mat depends
      -- on the disenchanted item's quality (green/blue/epic) and item level.
      -- Level bands below are the typical source-item ilvl range.
      { id = 20725, name = "Nexus Crystal", sources = {
        { kind = "disenchant", zone = "Any epic-quality item (purple)" },
      }},
      { id = 14344, name = "Large Brilliant Shard", sources = {
        { kind = "disenchant", zone = "Blue items, ilvl ~46-55+" },
      }},
      { id = 14343, name = "Small Brilliant Shard", sources = {
        { kind = "disenchant", zone = "Blue items, ilvl ~46-55" },
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
        { kind = "disenchant", zone = "Green/blue items, ilvl ~51-60" },
      }},
      { id = 16202, name = "Lesser Eternal Essence", sources = {
        { kind = "disenchant", zone = "Green items, ilvl ~51-60" },
      }},
      { id = 11175, name = "Greater Nether Essence", sources = {
        { kind = "disenchant", zone = "Green/blue items, ilvl ~41-50" },
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
        { kind = "mob", zone = "Winterspring", levels = "53-60", spawn_count = 60, avg_chance = 9.0, respawn = 1397, per_hour = 58.3,
          mobs = { { name = "High Chief Winterfall", chance = 79.2 }, { name = "Winterfall Totemic", chance = 8.2 }, { name = "Winterfall Pathfinder", chance = 8.0 } } },
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
        { kind = "dungeon", zone = "Scholomance", levels = "55-60", spawn_count = 25, avg_chance = 33.7, respawn = 12960, per_hour = 4.0,
          mobs = { { name = "Scholomance Necromancer", chance = 39.4 }, { name = "Scholomance Dark Summoner", chance = 33.9 }, { name = "Lady Illucia Barov", chance = 12.9 } } },
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
        { kind = "mob", zone = "Blasted Lands", levels = "45-55", spawn_count = 23, avg_chance = 36.3, respawn = 39561, per_hour = 38.5,
          mobs = { { name = "Ravage", chance = 36.9 }, { name = "Starving Snickerfang", chance = 35.6 }, { name = "Snickerfang Hyena", chance = 35.4 } } },
      }},
      { id = 8392, name = "Blasted Boar Lung", sources = {
        { kind = "mob", zone = "Blasted Lands", levels = "45-55", spawn_count = 24, avg_chance = 30.5, respawn = 48675, per_hour = 28.5,
          mobs = { { name = "Helboar", chance = 39.2 }, { name = "Ashmane Boar", chance = 38.8 }, { name = "Grunter", chance = 27.7 } } },
      }},
      { id = 8393, name = "Scorpok Pincer", sources = {
        { kind = "mob", zone = "Blasted Lands", levels = "45-55",
          mobs = { { name = "Scorpok Stinger", chance = 37.0 }, { name = "Clack the Reaver", chance = 30.7 } } },
      }},
      { id = 8396, name = "Vulture Gizzard", sources = {
        { kind = "mob", zone = "Blasted Lands", levels = "45-55",
          mobs = { { name = "Spiteflayer", chance = 35.5 }, { name = "Black Slayer", chance = 33.7 } } },
      }},
      { id = 8394, name = "Basilisk Brain", sources = {
        { kind = "mob", zone = "Blasted Lands", levels = "45-55", spawn_count = 16, avg_chance = 35.0, respawn = 77569, per_hour = 13.8,
          mobs = { { name = "Redstone Basilisk", chance = 38.1 }, { name = "Redstone Crystalhide", chance = 37.8 }, { name = "Deatheye", chance = 34.4 } } },
      }},
    }},
    { category = "Jujus", items = {
      { id = 12457, name = "Juju Chill",  recipe = { { id = 12434, count = 1 } } },
      { id = 12434, name = "Chillwind E'ko",   indent = "branch", roundUpTo = 3, sources = {
        { kind = "mob", zone = "Winterspring", levels = "53-60", spawn_count = 84, avg_chance = 6.6, respawn = 333, per_hour = 59.9,
          mobs = { { name = "Chillwind Ravager", chance = 8.8 }, { name = "Chillwind Chimaera", chance = 5.4 }, { name = "Fledgling Chillwind", chance = 3.1 } } },
      }},
      { id = 12455, name = "Juju Ember",  recipe = { { id = 12432, count = 1 } } },
      { id = 12432, name = "Shardtooth E'ko",  indent = "branch", roundUpTo = 3, sources = {
        { kind = "mob", zone = "Winterspring", levels = "53-60", spawn_count = 155, avg_chance = 7.7, respawn = 333, per_hour = 129.5,
          mobs = { { name = "Rabid Shardtooth", chance = 15.1 }, { name = "Elder Shardtooth", chance = 8.0 }, { name = "Shardtooth Mauler", chance = 7.1 } } },
      }},
      { id = 12459, name = "Juju Escape", recipe = { { id = 12435, count = 1 } } },
      { id = 12435, name = "Ice Thistle E'ko", indent = "branch", roundUpTo = 3, sources = {
        { kind = "mob", zone = "Winterspring", levels = "53-60", spawn_count = 97, avg_chance = 5.2, respawn = 333, per_hour = 54.5,
          mobs = { { name = "Ice Thistle Patriarch", chance = 9.5 }, { name = "Ice Thistle Matriarch", chance = 8.8 }, { name = "Ice Thistle Yeti", chance = 4.8 } } },
      }},
      { id = 12450, name = "Juju Flurry", recipe = { { id = 12430, count = 1 } } },
      { id = 12430, name = "Frostsaber E'ko",  indent = "branch", roundUpTo = 3, sources = {
        { kind = "mob", zone = "Winterspring", levels = "53-60", spawn_count = 115, avg_chance = 7.2, respawn = 333, per_hour = 88.9,
          mobs = { { name = "Frostsaber Cub", chance = 7.7 }, { name = "Frostsaber Huntress", chance = 7.6 }, { name = "Frostsaber Pride Watcher", chance = 7.5 } } },
      }},
      { id = 12458, name = "Juju Guile",  recipe = { { id = 12433, count = 1 } } },
      { id = 12433, name = "Wildkin E'ko",     indent = "branch", roundUpTo = 3, sources = {
        { kind = "mob", zone = "Winterspring", levels = "53-60", spawn_count = 130, avg_chance = 3.2, respawn = 333, per_hour = 44.8,
          mobs = { { name = "Berserk Owlbeast", chance = 4.2 }, { name = "Moontouched Owlbeast", chance = 4.1 }, { name = "Crazed Owlbeast", chance = 4.0 } } },
      }},
      { id = 12460, name = "Juju Might",  recipe = { { id = 12436, count = 1 } } },
      { id = 12436, name = "Frostmaul E'ko",   indent = "branch", roundUpTo = 3, sources = {
        { kind = "mob", zone = "Winterspring", levels = "53-60", spawn_count = 27, avg_chance = 40.2, respawn = 600, per_hour = 65.1,
          mobs = { { name = "Frostmaul Preserver", chance = 40.6 }, { name = "Frostmaul Giant", chance = 39.7 } } },
      }},
      { id = 12451, name = "Juju Power",  recipe = { { id = 12431, count = 1 } } },
      { id = 12431, name = "Winterfall E'ko",  indent = "branch", roundUpTo = 3, sources = {
        { kind = "mob", zone = "Winterspring", levels = "53-60", spawn_count = 59, avg_chance = 11.4, respawn = 323, per_hour = 78.7,
          mobs = { { name = "Winterfall Shaman", chance = 14.1 }, { name = "Winterfall Ursa", chance = 13.7 }, { name = "Winterfall Den Watcher", chance = 12.6 } } },
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
