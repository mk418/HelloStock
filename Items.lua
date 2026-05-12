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
      { id = 13468, name = "Black Lotus" },
      { id = 13467, name = "Icecap" },
      { id = 13466, name = "Plaguebloom" },
      { id = 13465, name = "Mountain Silversage" },
      { id = 13464, name = "Golden Sansam" },
      { id = 13463, name = "Dreamfoil" },
      { id = 8846,  name = "Gromsblood" },
      { id = 8845,  name = "Ghost Mushroom" },
      { id = 8839,  name = "Blindweed" },
      { id = 8838,  name = "Sungrass" },
      { id = 8836,  name = "Arthas' Tears" },
      { id = 8831,  name = "Purple Lotus" },
      { id = 4625,  name = "Firebloom" },
      { id = 3819,  name = "Wintersbite" },
      { id = 3358,  name = "Khadgar's Whisker" },
      { id = 3821,  name = "Goldthorn" },
      { id = 3818,  name = "Fadeleaf" },
      { id = 3357,  name = "Liferoot" },
      { id = 3356,  name = "Kingsblood" },
      { id = 3369,  name = "Grave Moss" },
      { id = 3355,  name = "Wild Steelbloom" },
      { id = 2453,  name = "Bruiseweed" },
      { id = 3820,  name = "Stranglekelp" },
      { id = 2450,  name = "Briarthorn" },
      { id = 2452,  name = "Swiftthistle" },
      { id = 785,   name = "Mageroyal" },
      { id = 2449,  name = "Earthroot" },
      { id = 765,   name = "Silverleaf" },
      { id = 2447,  name = "Peacebloom" },
    }},
    { category = "Ores & Bars", items = {
      { id = 12360, name = "Arcanite Bar" },
      { id = 12655, name = "Enchanted Thorium Bar" },
      { id = 11371, name = "Dark Iron Bar" },
      { id = 11370, name = "Dark Iron Ore" },
      { id = 12359, name = "Thorium Bar" },
      { id = 10620, name = "Thorium Ore" },
      { id = 6037,  name = "Truesilver Bar" },
      { id = 7911,  name = "Truesilver Ore" },
      { id = 3860,  name = "Mithril Bar" },
      { id = 3858,  name = "Mithril Ore" },
      { id = 3577,  name = "Gold Bar" },
      { id = 2776,  name = "Gold Ore" },
      { id = 3575,  name = "Iron Bar" },
      { id = 2772,  name = "Iron Ore" },
      { id = 2841,  name = "Bronze Bar" },
      { id = 3576,  name = "Tin Bar" },
      { id = 2771,  name = "Tin Ore" },
      { id = 2840,  name = "Copper Bar" },
      { id = 2770,  name = "Copper Ore" },
    }},
    { category = "Stones", items = {
      { id = 12365, name = "Dense Stone" },
      { id = 7912,  name = "Solid Stone" },
      { id = 2838,  name = "Heavy Stone" },
      { id = 2836,  name = "Coarse Stone" },
      { id = 2835,  name = "Rough Stone" },
    }},
    { category = "Leather & Hides", items = {
      { id = 8170,  name = "Rugged Leather" },
      { id = 8171,  name = "Rugged Hide" },
      { id = 4304,  name = "Thick Leather" },
      { id = 8169,  name = "Thick Hide" },
      { id = 4234,  name = "Heavy Leather" },
      { id = 4235,  name = "Heavy Hide" },
      { id = 2319,  name = "Medium Leather" },
      { id = 4232,  name = "Medium Hide" },
      { id = 2318,  name = "Light Leather" },
      { id = 783,   name = "Light Hide" },
    }},
    { category = "Cloth", items = {
      { id = 14342, name = "Mooncloth" },
      { id = 14256, name = "Felcloth" },
      { id = 14047, name = "Runecloth" },
      { id = 4338,  name = "Mageweave Cloth" },
      { id = 4306,  name = "Silk Cloth" },
      { id = 2592,  name = "Wool Cloth" },
      { id = 2589,  name = "Linen Cloth" },
    }},
    { category = "Elemental", items = {
      { id = 7078,  name = "Essence of Fire" },
      { id = 7080,  name = "Essence of Water" },
      { id = 7082,  name = "Essence of Air" },
      { id = 7076,  name = "Heart of Fire" },
      { id = 11382, name = "Blood of the Mountain" },
      { id = 12803, name = "Living Essence" },
      { id = 12808, name = "Essence of Undeath" },
      { id = 7067,  name = "Elemental Earth" },
      { id = 7068,  name = "Elemental Fire" },
      { id = 7070,  name = "Elemental Water" },
    }},
    { category = "Alchemy Supplies", items = {
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
      { id = 13422, name = "Stonescale Eel" },
      { id = 6359,  name = "Firefin Snapper" },
      { id = 6358,  name = "Oily Blackmouth" },
      { id = 5637,  name = "Large Fang" },
      { id = 5635,  name = "Sharp Claw" },
      { id = 4402,  name = "Small Flame Sac" },
    }},
    { category = "Cooking Supplies", items = {
      { id = 21024, name = "Chimaerok Tenderloin" },
      { id = 21153, name = "Raw Greater Sagefish" },
      { id = 20424, name = "Sandworm Meat" },
      { id = 18255, name = "Runn Tum Tuber" },
      { id = 13759, name = "Raw Nightfin Snapper" },
      { id = 13755, name = "Winter Squid" },
      { id = 8150,  name = "Deeprock Salt" },
      { id = 9061,  name = "Goblin Rocket Fuel" },
      { id = 3713,  name = "Soothing Spices" },
      { id = 159,   name = "Refreshing Spring Water" },
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
      { id = 4357,  name = "Coarse Blasting Powder" },
      { id = 7191,  name = "Fused Wiring" },
    }},
    { category = "Enchanting", items = {
      { id = 20725, name = "Nexus Crystal" },
      { id = 14344, name = "Large Brilliant Shard" },
      { id = 14343, name = "Small Brilliant Shard" },
      { id = 11178, name = "Large Radiant Shard" },
      { id = 11177, name = "Small Radiant Shard" },
      { id = 11139, name = "Large Glowing Shard" },
      { id = 11138, name = "Small Glowing Shard" },
      { id = 10978, name = "Small Glimmering Shard" },
      { id = 16203, name = "Greater Eternal Essence" },
      { id = 16202, name = "Lesser Eternal Essence" },
      { id = 11175, name = "Greater Nether Essence" },
      { id = 11174, name = "Lesser Nether Essence" },
      { id = 11135, name = "Greater Mystic Essence" },
      { id = 11134, name = "Lesser Mystic Essence" },
      { id = 11082, name = "Greater Astral Essence" },
      { id = 10998, name = "Lesser Astral Essence" },
      { id = 10939, name = "Greater Magic Essence" },
      { id = 10938, name = "Lesser Magic Essence" },
      { id = 16204, name = "Illusion Dust" },
      { id = 11176, name = "Dream Dust" },
      { id = 11137, name = "Vision Dust" },
      { id = 11083, name = "Soul Dust" },
      { id = 10940, name = "Strange Dust" },
    }},
  },

  Consumables = {
    { category = "Utility", items = {
      { id = 184937, name = "Chronoboon Displacer" },
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
      { id = 12820, name = "Winterfall Firewater", classes = MELEE },
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
      { id = 20520, name = "Dark Rune", classes = MANA },  -- drop / quest reward, no recipe
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
      { id = 13810, name = "Blessed Sunfruit",       classes = STR },   -- vendor (Argent Dawn)
      { id = 13813, name = "Blessed Sunfruit Juice", classes = MANA },  -- vendor (Argent Dawn)
      { id = 21023, name = "Dirge's Kickin' Chimaerok Chops", recipe = {
        { id = 9061,  count = 1 },  -- Goblin Rocket Fuel
        { id = 8150,  count = 1 },  -- Deeprock Salt
        { id = 21024, count = 1 },  -- Chimaerok Tenderloin
      } },
      { id = 21151, name = "Rumsey Rum Black Label" },               -- drop, universal
      { id = 18284, name = "Kreeg's Stout Beatdown", classes = MANA }, -- DMW vendor
      { id = 18269, name = "Gordok Green Grog" },                    -- DMN tribute vendor, universal
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
      { id = 8391, name = "Snickerfang Jowl" },
      { id = 8392, name = "Blasted Boar Lung" },
      { id = 8393, name = "Scorpok Pincer" },
      { id = 8396, name = "Vulture Gizzard" },
      { id = 8394, name = "Basilisk Brain" },
    }},
    { category = "Jujus", items = {
      { id = 12457, name = "Juju Chill",  recipe = { { id = 12434, count = 1 } } },
      { id = 12434, name = "Chillwind E'ko",   indent = "branch", roundUpTo = 3 },
      { id = 12455, name = "Juju Ember",  recipe = { { id = 12432, count = 1 } } },
      { id = 12432, name = "Shardtooth E'ko",  indent = "branch", roundUpTo = 3 },
      { id = 12459, name = "Juju Escape", recipe = { { id = 12435, count = 1 } } },
      { id = 12435, name = "Ice Thistle E'ko", indent = "branch", roundUpTo = 3 },
      { id = 12450, name = "Juju Flurry", recipe = { { id = 12430, count = 1 } } },
      { id = 12430, name = "Frostsaber E'ko",  indent = "branch", roundUpTo = 3 },
      { id = 12458, name = "Juju Guile",  recipe = { { id = 12433, count = 1 } } },
      { id = 12433, name = "Wildkin E'ko",     indent = "branch", roundUpTo = 3 },
      { id = 12460, name = "Juju Might",  recipe = { { id = 12436, count = 1 } } },
      { id = 12436, name = "Frostmaul E'ko",   indent = "branch", roundUpTo = 3 },
      { id = 12451, name = "Juju Power",  recipe = { { id = 12431, count = 1 } } },
      { id = 12431, name = "Winterfall E'ko",  indent = "branch", roundUpTo = 3 },
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
