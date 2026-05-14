local _, addon = ...

local BAG_IDS  = { 0, 1, 2, 3, 4 }
local BANK_IDS = { -1, 5, 6, 7, 8, 9, 10, 11 }

-- Vendor-purchasable reagents. Shortages of these don't block "can craft now"
-- highlighting, since you can grab them from an alchemy/trade-supply vendor.
local VENDOR_INGREDIENTS = {
  [8925]  = true, -- Crystal Vial
  [3372]  = true, -- Leaded Vial
  [3371]  = true, -- Empty Vial
  [22890] = true, -- Imbued Vial
}

local function CharKey(realm, faction, name)
  return realm .. ":" .. faction .. ":" .. name
end

local function MyKey()
  return CharKey(GetRealmName(), UnitFactionGroup("player") or "Neutral", UnitName("player"))
end

local function EnsureDB()
  HelloStockDB = HelloStockDB or {}
  HelloStockDB.characters = HelloStockDB.characters or {}
  local playerName  = UnitName("player")
  local playerRealm = GetRealmName()
  local key = (playerRealm or "") .. ":" ..
              (UnitFactionGroup("player") or "Neutral") .. ":" ..
              (playerName or "")
  local c = HelloStockDB.characters[key]
  if not c then
    c = {
      bags = {}, bank = {}, mail = {},
      bagsUpdated = 0, bankUpdated = 0, mailUpdated = 0,
      mailMoney = 0,
      money = 0,
    }
    HelloStockDB.characters[key] = c
  end
  -- Money is account-shared currency in spirit but per-character in storage.
  -- GetMoney returns copper; safe to call any time after login.
  if GetMoney then c.money = GetMoney() end
  if playerName  and playerName  ~= "" then c.name    = playerName  end
  if playerRealm and playerRealm ~= "" then c.realm   = playerRealm end
  c.faction      = UnitFactionGroup("player") or "Neutral"
  c.accountID    = addon:GetAccountID()
  c.source       = "self"
  c.sourceSecret = nil
  -- Class is captured for the Characters overview (class-coloured name) and
  -- isn't otherwise used by aggregation. Token form ("WARRIOR", "MAGE", ...)
  -- so it keys directly into RAID_CLASS_COLORS regardless of locale.
  local _, classToken = UnitClass("player")
  if classToken and classToken ~= "" then c.class = classToken end
  local lvl = UnitLevel("player")
  if lvl and lvl > 0 then c.level = lvl end
  return c
end

local trackedItems = nil
local function TrackedItemSet()
  if trackedItems then return trackedItems end
  trackedItems = {}
  if addon.ITEMS then
    for _, section in pairs(addon.ITEMS) do
      for _, group in ipairs(section) do
        for _, item in ipairs(group.items) do
          if item.id then trackedItems[item.id] = true end
        end
      end
    end
  end
  return trackedItems
end

function addon:IsTracked(itemID)
  return itemID and TrackedItemSet()[itemID] == true
end

-- Returns true if the item is Binds-on-Pickup. Auto-detected via GetItemInfo's
-- bindType field (1=BoP, 2=BoE, 3=BoU, 4=quest). Only BoP matters for our
-- stockpile case — BoE/BoU consumables can still be traded until used. Items
-- not yet in the client cache return false; PrimeItemCache on PLAYER_LOGIN
-- populates the cache for everything in addon.ITEMS up front.
function addon:IsBoP(itemID)
  if not itemID then return false end
  local _, _, _, _, _, _, _, _, _, _, _, _, _, bindType = GetItemInfo(itemID)
  return bindType == 1
end

-- Per-entry CRDT for the ignore list. Each entry stores the latest addedAt
-- and removedAt timestamps independently; state is "ignored" iff
-- addedAt > removedAt. Two-way sync merges max(local, peer) per field, so
-- concurrent ignores or unignores from either side compose without loss.
-- Keyed by case-insensitive "name-realm" so duplicate names across realms
-- can be ignored independently.
local function IgnoreKey(name, realm)
  if not name or name == "" then return nil end
  return name:lower() .. "-" .. addon:NormalizeRealm(realm or ""):lower()
end

-- Legacy entries (boolean true) migrate to a table form lazily. We use the
-- legacy whole-list `ignoredUpdatedAt` as the addedAt timestamp so the
-- entry's vintage is plausible; the user can re-ignore to refresh it.
local function NormalizeIgnoreEntry(e, fallbackTs)
  if type(e) == "table" then return e end
  return { addedAt = fallbackTs or 0, removedAt = 0 }
end

function addon:IsIgnored(name, realm)
  if not HelloStockDB or not HelloStockDB.ignored then return false end
  local key = IgnoreKey(name, realm)
  if not key then return false end
  local e = HelloStockDB.ignored[key]
  if not e then return false end
  if type(e) ~= "table" then
    e = NormalizeIgnoreEntry(e, HelloStockDB.ignoredUpdatedAt)
    HelloStockDB.ignored[key] = e
  end
  return (e.addedAt or 0) > (e.removedAt or 0)
end

-- Recipe lookups, built lazily from addon.ITEMS the first time anything asks.
-- recipeMap[buffID]   -> array of { id = ingredientID, count = N }
-- usedInMap[reagentID] -> array of buffIDs
local recipeMap, usedInMap
local function BuildRecipeMaps()
  if recipeMap then return end
  recipeMap, usedInMap = {}, {}
  if not addon.ITEMS then return end
  for _, section in pairs(addon.ITEMS) do
    for _, group in ipairs(section) do
      for _, item in ipairs(group.items) do
        if item.id and item.recipe then
          recipeMap[item.id] = item.recipe
          for _, ing in ipairs(item.recipe) do
            usedInMap[ing.id] = usedInMap[ing.id] or {}
            usedInMap[ing.id][#usedInMap[ing.id] + 1] = item.id
          end
        end
      end
    end
  end
end

function addon:GetRecipe(itemID)
  BuildRecipeMaps()
  return recipeMap[itemID]
end

function addon:GetUsedIn(itemID)
  BuildRecipeMaps()
  return usedInMap[itemID]
end

-- itemID -> array of source entries (see Items.lua for shape). Lazy.
-- Each entry: { kind = "herb"|"mine"|"skin"|"fish"|"mob"|"dungeon"
--                       |"vendor"|"disenchant"|"craft"|"quest",
--               zone = "Place name", levels = "x-y",
--               mobs = { { name = "Mob A", chance = 8 }, ... } }
--               -- levels/mobs optional; chance is a percent (number), also optional
--               -- For non-place kinds (vendor/disenchant/craft) the zone field
--               -- carries the descriptive context (vendor NPC, ilvl band, etc.).
local sourcesMap
local function BuildSourcesMap()
  if sourcesMap then return end
  sourcesMap = {}
  if not addon.ITEMS then return end
  for _, section in pairs(addon.ITEMS) do
    for _, group in ipairs(section) do
      for _, item in ipairs(group.items) do
        if item.id and item.sources then
          sourcesMap[item.id] = item.sources
        end
      end
    end
  end
end

function addon:GetSources(itemID)
  BuildSourcesMap()
  return sourcesMap[itemID]
end

-- itemID -> category name (the group it belongs to in Items.lua).
local categoryMap
local function BuildCategoryMap()
  if categoryMap then return end
  categoryMap = {}
  if not addon.ITEMS then return end
  for _, section in pairs(addon.ITEMS) do
    for _, group in ipairs(section) do
      for _, item in ipairs(group.items) do
        if item.id then categoryMap[item.id] = group.category end
      end
    end
  end
end

function addon:GetItemCategory(itemID)
  BuildCategoryMap()
  return categoryMap[itemID]
end

-- itemID -> roundUpTo (gather list rounds an item's deficit up to this step).
-- Used e.g. for E'kos that can only be turned in in groups of 3.
local roundUpMap
local function BuildRoundUpMap()
  if roundUpMap then return end
  roundUpMap = {}
  if not addon.ITEMS then return end
  for _, section in pairs(addon.ITEMS) do
    for _, group in ipairs(section) do
      for _, item in ipairs(group.items) do
        if item.id and item.roundUpTo and item.roundUpTo > 1 then
          roundUpMap[item.id] = item.roundUpTo
        end
      end
    end
  end
end

-- Compute what raw materials the user needs to gather to bring every targeted
-- item up to its target. Supports multi-level recipes (e.g. Flask of the Titans
-- needs Stonescale Oil which itself has a recipe) by:
--   1. Seeding `demand[id]` with every target's amount (no stock subtraction).
--   2. Topologically sorting items with recipes so consumers are processed
--      before their ingredients.
--   3. For each recipe item in that order, computing `net = max(0, demand − have)`
--      and propagating `net × ingredient.count` into each ingredient's demand.
--   4. Emitting a gather entry for every leaf (no-recipe) item whose demand
--      exceeds current stock.
-- The key correctness detail is step 1: if both a flask and the flask's own
-- Stonescale Oil have targets, the Stonescale Oil's demand accumulates fully
-- from both sources before stock is subtracted once.
function addon:ComputeGatheringList()
  local out = {}
  if not addon.ITEMS then return out end
  BuildRecipeMaps()
  BuildRoundUpMap()

  local targets = self:GetTargets().items
  local demand = {}
  for _, section in pairs(addon.ITEMS) do
    for _, group in ipairs(section) do
      for _, item in ipairs(group.items) do
        if item.id then
          local target = targets[item.id]
          if target and target > 0 then
            demand[item.id] = (demand[item.id] or 0) + target
          end
        end
      end
    end
  end

  -- Topological order of crafted items: consumers first, ingredients after.
  local order, visited = {}, {}
  local function visit(id)
    if visited[id] then return end
    visited[id] = true
    local r = recipeMap[id]
    if r then
      for _, ing in ipairs(r) do
        if recipeMap[ing.id] then visit(ing.id) end
      end
    end
    table.insert(order, 1, id)
  end
  for id in pairs(recipeMap) do visit(id) end

  for _, id in ipairs(order) do
    local have = self:GetTotals(id)
    local net  = math.max(0, (demand[id] or 0) - have)
    if net > 0 then
      local r      = recipeMap[id]
      local yield  = r.yield or 1
      local crafts = math.ceil(net / yield)
      for _, ing in ipairs(r) do
        demand[ing.id] = (demand[ing.id] or 0) + ing.count * crafts
      end
    end
  end

  for id, needed in pairs(demand) do
    if not recipeMap[id] then
      local rnd = roundUpMap[id]
      if rnd then needed = math.ceil(needed / rnd) * rnd end
      local have   = self:GetTotals(id)
      local gather = needed - have
      if gather > 0 then
        out[#out + 1] = {
          id       = id,
          gather   = gather,
          have     = have,
          needed   = needed,
          category = self:GetItemCategory(id),
        }
      end
    end
  end

  table.sort(out, function(a, b)
    if a.gather ~= b.gather then return a.gather > b.gather end
    return a.id < b.id
  end)
  return out
end

-- Sibling to ComputeGatheringList: same demand propagation, but emits the
-- recipe (craftable) items themselves rather than their raw ingredients.
-- Result: a list of every craft you'd need to perform to bring all targeted
-- items up to their levels (including intermediate crafts like Stonescale Oil
-- when a flask using it is under target).
function addon:ComputeCraftList()
  local out = {}
  if not addon.ITEMS then return out end
  BuildRecipeMaps()

  local targets = self:GetTargets().items
  local demand = {}
  for _, section in pairs(addon.ITEMS) do
    for _, group in ipairs(section) do
      for _, item in ipairs(group.items) do
        if item.id then
          local target = targets[item.id]
          if target and target > 0 then
            demand[item.id] = (demand[item.id] or 0) + target
          end
        end
      end
    end
  end

  local order, visited = {}, {}
  local function visit(id)
    if visited[id] then return end
    visited[id] = true
    local r = recipeMap[id]
    if r then
      for _, ing in ipairs(r) do
        if recipeMap[ing.id] then visit(ing.id) end
      end
    end
    table.insert(order, 1, id)
  end
  for id in pairs(recipeMap) do visit(id) end

  for _, id in ipairs(order) do
    local have = self:GetTotals(id)
    local net  = math.max(0, (demand[id] or 0) - have)
    if net > 0 then
      local r      = recipeMap[id]
      local yield  = r.yield or 1
      local crafts = math.ceil(net / yield)
      for _, ing in ipairs(r) do
        demand[ing.id] = (demand[ing.id] or 0) + ing.count * crafts
      end
    end
  end

  -- Max units of `id` we could end up with from current stocks, recursively
  -- crafting any intermediates whose recipes we know. Vendor ingredients are
  -- treated as unlimited. Per-row view: assumes nothing else competes for the
  -- same raw materials, which matches how the tooltip reads each row in
  -- isolation.
  local maxCache = {}
  local function MaxProducible(id)
    if VENDOR_INGREDIENTS[id] then return math.huge end
    if maxCache[id] ~= nil then return maxCache[id] end
    maxCache[id] = 0  -- cycle guard
    local have = self:GetTotals(id)
    local r    = recipeMap[id]
    if r then
      local yield  = r.yield or 1
      local crafts = math.huge
      for _, ing in ipairs(r) do
        local possible = math.floor(MaxProducible(ing.id) / ing.count)
        if possible < crafts then crafts = possible end
      end
      if crafts == math.huge then crafts = 0 end
      have = have + crafts * yield
    end
    maxCache[id] = have
    return have
  end

  for id, needed in pairs(demand) do
    if recipeMap[id] then
      local r      = recipeMap[id]
      local yield  = r.yield or 1
      local have   = self:GetTotals(id)
      local rawNet = needed - have
      if rawNet > 0 then
        local crafts = math.ceil(rawNet / yield)
        local craft  = crafts * yield

        local maxCrafts = math.huge
        for _, ing in ipairs(r) do
          if not VENDOR_INGREDIENTS[ing.id] then
            local possible = math.floor(MaxProducible(ing.id) / ing.count)
            if possible < maxCrafts then maxCrafts = possible end
          end
        end
        if maxCrafts == math.huge then maxCrafts = crafts end
        local doable = math.min(crafts, maxCrafts)
        local ratio  = crafts > 0 and doable / crafts or 0
        local craftLevel = "none"
        if ratio >= 1     then craftLevel = "full"
        elseif ratio >= 0.5 then craftLevel = "half" end

        out[#out + 1] = {
          id         = id,
          craft      = craft,
          crafts     = crafts,
          yield      = yield,
          have       = have,
          needed     = have + craft,
          doable     = doable,
          canCraft   = craftLevel == "full",
          craftLevel = craftLevel,
          category   = self:GetItemCategory(id),
        }
      end
    end
  end

  table.sort(out, function(a, b)
    if a.craft ~= b.craft then return a.craft > b.craft end
    return a.id < b.id
  end)
  return out
end

-- Set of item IDs we need to craft right now (target > stock and has a recipe).
-- Same demand-propagation logic as ComputeCraftList, returned as a set for
-- cheap membership tests from the tooltip ("Needed for:" filter).
function addon:GetCraftSet()
  local set = {}
  for _, entry in ipairs(self:ComputeCraftList()) do
    set[entry.id] = true
  end
  return set
end

-- Suggest farming zones based on the current gather list. For each item the
-- user needs (from ComputeGatheringList), walk its sources and aggregate
-- per-zone scores + per-hour throughput estimates.
--
-- Score: sum of "expected items per visit" across all needed items the zone
-- can supply, capped at each item's deficit so a zone that overdrops one
-- item doesn't out-rank one that hits multiple needs.
--
-- per_hour: realistic items-per-hour the zone delivers for each contributing
-- item. Two grounded models:
--   Open-world (respawn < 10min): capped at 60 kills/hr for mobs and
--   30 gathers/hr for nodes — travel/kill/pickup dominate over raw spawn
--   density, so the per-hour ceilings reflect realistic solo farming.
--   Dungeon (respawn >= 10min, instance reset): assume 2 clears/hour, with
--   per-clear yield = spawn_count × chance% (mob) or × yield (node).
--
-- Returns list sorted by score desc:
--   { { zone, levels, score, items = { { id, needed, expected, capped,
--       per_hour, kind, source } ... } }, ... }

local FARM_OPENWORLD_MOB_PER_HOUR  = 60   -- ceiling: 1 kill / minute
local FARM_OPENWORLD_NODE_PER_HOUR = 30   -- ceiling: 1 gather / 2 minutes
local FARM_DUNGEON_CLEARS_PER_HOUR = 2    -- one clear every 30 min

local function FarmYieldPerHour(s)
  if not s.spawn_count then return nil end
  local isInstance = (s.respawn and s.respawn >= 600)
  if s.kind == "mob" or s.kind == "dungeon" then
    if not s.avg_chance then return nil end
    local perClear = s.spawn_count * s.avg_chance / 100
    if isInstance then
      return perClear * FARM_DUNGEON_CLEARS_PER_HOUR
    end
    -- Open-world: cap killable mobs/hour at the ceiling.
    local effSpawns = math.min(s.spawn_count, FARM_OPENWORLD_MOB_PER_HOUR)
    return effSpawns * s.avg_chance / 100
  elseif s.kind == "herb" or s.kind == "mine" or s.kind == "skin" then
    if not s.avg_yield then return nil end
    local perClear = s.spawn_count * s.avg_yield
    if isInstance then
      return perClear * FARM_DUNGEON_CLEARS_PER_HOUR
    end
    local effSpawns = math.min(s.spawn_count, FARM_OPENWORLD_NODE_PER_HOUR)
    return effSpawns * s.avg_yield
  end
  return nil
end

function addon:ComputeFarmList()
  local out = {}
  local gather = self:ComputeGatheringList()
  if not gather or #gather == 0 then return out end

  local need = {}
  for _, entry in ipairs(gather) do
    need[entry.id] = entry.gather
  end

  local zones = {}
  for itemID, needed in pairs(need) do
    local sources = self:GetSources(itemID)
    if sources then
      for _, s in ipairs(sources) do
        local expected
        if s.kind == "mob" or s.kind == "dungeon" then
          if s.spawn_count and s.avg_chance then
            expected = s.spawn_count * s.avg_chance / 100
          end
        elseif s.kind == "herb" or s.kind == "mine" or s.kind == "skin" then
          if s.spawn_count and s.avg_yield then
            expected = s.spawn_count * s.avg_yield
          end
        end
        if expected and expected > 0 then
          local capped = math.min(expected, needed)
          local z = zones[s.zone]
          if not z then
            z = { zone = s.zone, levels = s.levels, score = 0, items = {} }
            zones[s.zone] = z
          end
          z.score = z.score + capped
          local perHour = FarmYieldPerHour(s)
          local existing = z.items[itemID]
          if not existing or expected > existing.expected then
            z.items[itemID] = {
              id = itemID,
              needed = needed,
              expected = expected,
              capped = capped,
              per_hour = perHour,
              kind = s.kind,
              source = s,
            }
          end
        end
      end
    end
  end

  for _, z in pairs(zones) do
    local items = {}
    for _, info in pairs(z.items) do items[#items + 1] = info end
    table.sort(items, function(a, b) return a.expected > b.expected end)
    z.items = items
    out[#out + 1] = z
  end
  table.sort(out, function(a, b)
    if a.score ~= b.score then return a.score > b.score end
    return a.zone < b.zone
  end)
  return out
end

-- Profession-recipe scanning. Tracks which tracked items each character can
-- craft, based on what the open trade-skill / craft window exposes. The data
-- is per-character (stored on HelloStockDB.characters[key].crafts) and is
-- included in sync snapshots so peer-account chars learn each other's recipes.
local function MarkCanCraft(itemID)
  if not itemID or not addon:IsTracked(itemID) then return false end
  local c = addon:GetSelf()
  if not c then return false end
  c.crafts = c.crafts or {}
  if c.crafts[itemID] then return false end
  c.crafts[itemID] = true
  return true
end

-- Reverse lookup: localized item name → tracked itemID. Built lazily because
-- GetItemInfo needs the item to be in the cache (PrimeItemCache on login
-- usually handles that). Used as a fallback when the trade-skill / craft
-- API returns an enchant/spell link instead of the expected item link —
-- which happens for Enchanting "produce an item" recipes like Wizard Oils.
local nameToID
local function NameToID()
  if nameToID then return nameToID end
  nameToID = {}
  if not addon.ITEMS then return nameToID end
  for _, section in pairs(addon.ITEMS) do
    for _, group in ipairs(section) do
      for _, item in ipairs(group.items) do
        if item.id then
          local n = GetItemInfo(item.id) or item.name
          if n and n ~= "" then nameToID[n] = item.id end
        end
      end
    end
  end
  return nameToID
end

local function ResolveItemID(link, skillName)
  if link then
    local id = tonumber(link:match("item:(%d+)"))
    if id then return id end
  end
  if skillName then
    return NameToID()[skillName]
  end
  return nil
end

local function ScanTradeSkillsNow()
  if not GetNumTradeSkills then return false end
  local changed = false
  -- Expand collapsed headers so every recipe becomes visible.
  for i = (GetNumTradeSkills() or 0), 1, -1 do
    local _, skillType = GetTradeSkillInfo(i)
    if skillType == "header" and ExpandTradeSkillSubClass then
      ExpandTradeSkillSubClass(i)
    end
  end
  for i = 1, (GetNumTradeSkills() or 0) do
    local skillName, skillType = GetTradeSkillInfo(i)
    if skillType and skillType ~= "header" then
      local link = GetTradeSkillItemLink and GetTradeSkillItemLink(i)
      local id   = ResolveItemID(link, skillName)
      if id and MarkCanCraft(id) then changed = true end
    end
  end
  return changed
end

local function ScanCraftsNow()
  if not GetNumCrafts then return false end
  local changed = false
  for i = (GetNumCrafts() or 0), 1, -1 do
    local _, _, craftType = GetCraftInfo(i)
    if craftType == "header" and ExpandCraftSkillLine then
      ExpandCraftSkillLine(i)
    end
  end
  for i = 1, (GetNumCrafts() or 0) do
    local craftName, _, craftType = GetCraftInfo(i)
    if craftType and craftType ~= "header" then
      local link = GetCraftItemLink and GetCraftItemLink(i)
      local id   = ResolveItemID(link, craftName)
      if id and MarkCanCraft(id) then changed = true end
    end
  end
  return changed
end

local function ScanRecipes()
  local a = ScanTradeSkillsNow()
  local b = ScanCraftsNow()
  if (a or b) and addon.Comm then addon.Comm:SendSnapshot() end
  if addon.UI and addon.UI:IsShown() then addon.UI:Refresh() end
end

local function ScanContainers(bagList)
  local counts = {}
  local tracked = TrackedItemSet()
  for _, bag in ipairs(bagList) do
    local slots = C_Container.GetContainerNumSlots(bag) or 0
    for slot = 1, slots do
      local info = C_Container.GetContainerItemInfo(bag, slot)
      if info and info.itemID and tracked[info.itemID] then
        counts[info.itemID] = (counts[info.itemID] or 0) + (info.stackCount or 1)
      end
    end
  end
  return counts
end

local function RefreshUI()
  if addon.UI and addon.UI:IsShown() then addon.UI:Refresh() end
end

local function Broadcast()
  if addon.Comm then addon.Comm:SendSnapshot() end
end

local function UpdateBags()
  local c = EnsureDB()
  c.bags = ScanContainers(BAG_IDS)
  c.bagsUpdated = time()
  RefreshUI()
  Broadcast()
end

local function UpdateBank()
  local c = EnsureDB()
  c.bank = ScanContainers(BANK_IDS)
  c.bankUpdated = time()
  RefreshUI()
  Broadcast()
end

local function UpdateMoney()
  local c = EnsureDB()
  c.money = GetMoney() or 0
  RefreshUI()
  Broadcast()
end

-- Profession identification has two failure modes worth dodging:
--  - The Apprentice spell ID isn't necessarily known at higher ranks
--    (Mining = 2575 is Apprentice; Artisan = 29354 replaces it).
--  - GetSpellInfo on the spell ID returns the *action* name, which can differ
--    from the *skill* name shown in the panel (e.g. "Herb Gathering" spell
--    vs "Herbalism" skill line).
-- So the primary signal is now the skill panel itself, walked by section
-- header. Spell-ID lookups are kept only as a localization-friendly seed for
-- known-name matching, in case the section header is also localized away.
local PROFESSION_APPRENTICE_SPELL_IDS = {
  2259,  -- Alchemy
  2018,  -- Blacksmithing
  2550,  -- Cooking
  7411,  -- Enchanting
  4036,  -- Engineering
  3273,  -- First Aid
  7620,  -- Fishing
  2366,  -- Herb Gathering  (note: spell name ≠ "Herbalism" skill name)
  2108,  -- Leatherworking
  2575,  -- Mining
  8613,  -- Skinning
  3908,  -- Tailoring
}

local PROFESSION_SKILL_NAMES_EN = {
  Alchemy = true, Blacksmithing = true, Cooking = true, Enchanting = true,
  Engineering = true, ["First Aid"] = true, Fishing = true, Herbalism = true,
  Leatherworking = true, Mining = true, Skinning = true, Tailoring = true,
}

local function ScanProfessions()
  -- Header strings that mark the *Professions* section specifically.
  -- "Secondary Skills" is deliberately excluded — it also contains Riding /
  -- racial mount skills which we don't want in the overview. Cooking, First
  -- Aid, and Fishing still get captured via the known-name allowlist below.
  local profHeaders = { ["Professions"] = true }
  if _G.TRADESKILLS then profHeaders[_G.TRADESKILLS] = true end

  -- Known-name set: English profession names + the localized action names
  -- pulled from spell IDs. Acts as a safety net so e.g. a German client with
  -- a non-matching section header still picks up Mining via its localized
  -- spell name.
  local knownNames = {}
  for n in pairs(PROFESSION_SKILL_NAMES_EN) do knownNames[n] = true end
  for _, id in ipairs(PROFESSION_APPRENTICE_SPELL_IDS) do
    local n = GetSpellInfo and GetSpellInfo(id)
    if n and n ~= "" then knownNames[n] = true end
  end

  local out, seen = {}, {}
  local inSection = false
  local total = (GetNumSkillLines and GetNumSkillLines()) or 0
  for i = 1, total do
    local name, isHeader, _, rank, _, _, maxRank = GetSkillLineInfo(i)
    if name then
      if isHeader then
        inSection = profHeaders[name] == true
      else
        if (inSection or knownNames[name]) and not seen[name] then
          seen[name] = true
          out[#out + 1] = { name = name, skill = rank or 0, max = maxRank or 0 }
        end
      end
    end
  end
  return out
end

local function UpdateProfessions()
  local c = EnsureDB()
  local result = ScanProfessions()
  -- Skip the write when the scan came back empty but a previous scan
  -- captured something — protects against transient spellbook-not-ready
  -- failures clobbering known data on /reload.
  if #result == 0 and c.professions and #c.professions > 0 then return end
  c.professions = result
  RefreshUI()
  Broadcast()
end

-- Scan the player's inbox for tracked items sitting in mail (received or
-- still-in-transit attachments) plus any copper attached but not yet taken.
-- Returns (counts, money): counts mirrors the { [itemID] = count } shape used
-- by bag/bank scans; money is total copper across all messages.
local function ScanMail()
  local counts = {}
  local money = 0
  local tracked = TrackedItemSet()
  local num = GetInboxNumItems and GetInboxNumItems() or 0
  local maxAttach = ATTACHMENTS_MAX_RECEIVE or 16
  for i = 1, num do
    local _, _, _, _, mailMoney = GetInboxHeaderInfo(i)
    money = money + (mailMoney or 0)
    for a = 1, maxAttach do
      local link = GetInboxItemLink and GetInboxItemLink(i, a)
      if link then
        local id = tonumber(link:match("item:(%d+)"))
        if id and tracked[id] then
          local _, _, _, count = GetInboxItem(i, a)
          counts[id] = (counts[id] or 0) + (count or 1)
        end
      end
    end
  end
  return counts, money
end

-- Outgoing mail. WoW puts mail "in transit" for an hour between send and
-- arrival; items are gone from the sender's bags but not yet in the
-- recipient's inbox. We capture sends to characters we already know about
-- (own account or paired peer, same faction) so the stockpile total doesn't
-- briefly drop while the items are on the wire.
local MAIL_TRANSIT_SECS  = 60 * 60        -- WoW's delivery delay
local OUTBOX_HARD_CAP    = 30 * 24 * 3600 -- WoW auto-returns mail after 30 days

local function FindCharByName(name, faction)
  if not name or name == "" then return nil end
  if not HelloStockDB or not HelloStockDB.characters then return nil end
  local bare = name:match("^([^%-]+)") or name
  for _, c in pairs(HelloStockDB.characters) do
    if c.name == bare and c.faction == faction then return c end
  end
  return nil
end

-- True if `name` matches a stored character on our current faction. Used to
-- decide whether a send is "internal" (worth tracking) or external (truly
-- gone from our pool).
local function IsKnownChar(name)
  return FindCharByName(name, UnitFactionGroup("player") or "Neutral") ~= nil
end

-- Drop a transit entry only after the recipient's own mail snapshot proves
-- they've scanned their inbox since the item arrived. Before that — even
-- past WoW's 1-hour delivery time — we keep showing it as in-transit so the
-- item never disappears from the addon's totals just because the recipient
-- hasn't logged in yet. A 30-day hard cap matches WoW's auto-return behavior
-- and keeps the list from accumulating forever in pathological cases.
local function ShouldExpire(entry, faction)
  if not entry.sentAt then return true end
  local age = time() - entry.sentAt
  if age >= OUTBOX_HARD_CAP then return true end
  if age < MAIL_TRANSIT_SECS then return false end
  local recipient = FindCharByName(entry.to, faction)
  if not recipient then return false end
  return (recipient.mailUpdated or 0) >= entry.sentAt + MAIL_TRANSIT_SECS
end

local function ExpireOutbox(outbox, faction)
  if not outbox then return outbox end
  local kept = {}
  for _, e in ipairs(outbox) do
    if not ShouldExpire(e, faction) then
      kept[#kept + 1] = e
    end
  end
  return kept
end

local function UpdateMail()
  local c = EnsureDB()
  local counts, money = ScanMail()
  c.mail = counts
  c.mailMoney = money
  c.mailUpdated = time()
  RefreshUI()
  Broadcast()
end

function addon:GetSelf()
  if not HelloStockDB or not HelloStockDB.characters then return nil end
  return HelloStockDB.characters[MyKey()]
end

-- Capture outgoing mail at the moment Send is clicked. Hooked lazily on the
-- first MAIL_SHOW because the SendMail UI lives in Blizzard_MailUI, which is
-- load-on-demand. PreClick reads GetSendMailItem before the action clears
-- the attachments; MAIL_SEND_SUCCESS commits the snapshot.
local mailHookInstalled = false
local pendingSend = nil

-- Note: Blizzard's "send mail to a stranger" warning lives on the
-- protected `SecureTransferDialog` frame. Addons can't auto-confirm it
-- without tainting the call stack (by design — it's an anti-abuse gate
-- for player-to-player transfers). The recipient picker below at least
-- makes the typing-the-name step easy; the popup itself is unavoidable.
local function InstallMailHooks()
  if mailHookInstalled then return end
  if not SendMailMailButton then return end
  mailHookInstalled = true
  SendMailMailButton:HookScript("PreClick", function()
    pendingSend = nil
    local recipient = SendMailNameEditBox and SendMailNameEditBox:GetText() or ""
    if not IsKnownChar(recipient) then return end
    local items = {}
    local tracked = TrackedItemSet()
    local maxSend = ATTACHMENTS_MAX_SEND or 12
    for slot = 1, maxSend do
      local link = GetSendMailItemLink and GetSendMailItemLink(slot)
      if link then
        local id = tonumber(link:match("item:(%d+)"))
        if id and tracked[id] then
          local _, _, _, count = GetSendMailItem(slot)
          items[#items + 1] = { id = id, count = count or 1 }
        end
      end
    end
    local money = 0
    if MoneyInputFrame_GetCopper and SendMailMoney then
      money = MoneyInputFrame_GetCopper(SendMailMoney) or 0
    end
    if #items > 0 or money > 0 then
      pendingSend = { to = recipient, items = items, money = money }
    end
  end)

  -- Recipient picker: a small "Alts" button next to the To: field that
  -- opens a menu of tracked characters in the current scope. Clicking a
  -- name fills SendMailNameEditBox so the user doesn't have to type names.
  if SendMailNameEditBox and not _G.HelloStock_MailRecipientPicker then
    -- Small icon-only button right next to the To: field. Compact enough
    -- not to collide with the Postage label on the same row. Tooltip on
    -- hover explains what it does.
    local btn = CreateFrame("Button", "HelloStock_MailRecipientPicker", SendMailFrame)
    btn:SetSize(16, 16)
    btn:SetPoint("LEFT", SendMailNameEditBox, "RIGHT", 2, 0)

    btn:SetNormalTexture("Interface\\Icons\\Achievement_Reputation_01")
    local nt = btn:GetNormalTexture()
    if nt then nt:SetTexCoord(0.08, 0.92, 0.08, 0.92) end
    btn:SetPushedTexture("Interface\\Icons\\Achievement_Reputation_01")
    local pt = btn:GetPushedTexture()
    if pt then pt:SetTexCoord(0.08, 0.92, 0.08, 0.92) end
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

    -- Subtle bevel border around the icon so it reads as clickable.
    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    border:SetTexCoord(0.2, 0.8, 0.2, 0.8)
    border:SetSize(22, 22)
    border:SetPoint("CENTER", 0, 0)

    btn:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetText("HelloStock: tracked characters", 1, 1, 1)
      GameTooltip:AddLine("Click to pick a recipient from your tracked characters.", 0.7, 0.7, 0.7, true)
      GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local menu = CreateFrame("Frame", "HelloStock_MailRecipientMenu", UIParent, "UIDropDownMenuTemplate")
    menu.items = {}
    UIDropDownMenu_Initialize(menu, function(self, level)
      for _, info in ipairs(self.items or {}) do
        UIDropDownMenu_AddButton(info, level)
      end
    end, "MENU")

    btn:SetScript("OnClick", function()
      local myFaction = UnitFactionGroup("player") or "Neutral"
      local realmSet  = addon:ConnectedRealmSet()
      local myID      = addon:GetAccountID()
      local myName    = UnitName("player")
      local myRealm   = GetRealmName() or ""

      local mine, peer = {}, {}
      for _, c in pairs(HelloStockDB and HelloStockDB.characters or {}) do
        local sameScope = c.faction == myFaction and c.realm
                       and realmSet[addon:NormalizeRealm(c.realm)]
        local notSelf   = not (c.name == myName and c.realm == myRealm)
        local notIgnored = not addon:IsIgnored(c.name, c.realm)
        if sameScope and notSelf and notIgnored and c.name and c.name ~= "" then
          local entry = { name = c.name, realm = c.realm }
          if c.accountID == myID then mine[#mine + 1] = entry
          else peer[#peer + 1] = entry end
        end
      end
      table.sort(mine, function(a, b) return a.name < b.name end)
      table.sort(peer, function(a, b) return a.name < b.name end)

      local items = {}
      items[#items + 1] = { text = "Mail to a tracked character", isTitle = true, notCheckable = true }
      local function addSection(label, list)
        if #list == 0 then return end
        items[#items + 1] = { text = label, isTitle = true, notCheckable = true }
        for _, c in ipairs(list) do
          local normalized = c.name .. "-" .. addon:NormalizeRealm(c.realm)
          items[#items + 1] = {
            text = c.name .. "-" .. c.realm,  -- pretty form for the menu
            notCheckable = true,
            func = function()
              -- Mail recipient lookup expects the realm with whitespace
              -- stripped (e.g. "OldBlanchy", not "Old Blanchy"), otherwise
              -- the server rejects the send with "No player named …".
              SendMailNameEditBox:SetText(normalized)
              SendMailNameEditBox:SetCursorPosition(#SendMailNameEditBox:GetText())
            end,
          }
        end
      end
      addSection("Your characters", mine)
      addSection("Paired account",  peer)
      if #mine == 0 and #peer == 0 then
        items[#items + 1] = { text = "(none in scope)", disabled = true, notCheckable = true }
      end
      items[#items + 1] = { text = "|cffffd100" .. CANCEL .. "|r", notCheckable = true, func = function() end }

      menu.items = items
      ToggleDropDownMenu(1, nil, menu, btn, 0, 0)
    end)
  end
end

function addon:ReceiveIgnoreList(snap)
  HelloStockDB = HelloStockDB or {}
  HelloStockDB.ignored = HelloStockDB.ignored or {}
  local merged = 0
  for _, e in ipairs(snap.entries or {}) do
    if e.key and e.key ~= "" then
      local localEntry = NormalizeIgnoreEntry(HelloStockDB.ignored[e.key], HelloStockDB.ignoredUpdatedAt)
      HelloStockDB.ignored[e.key] = {
        addedAt   = math.max(localEntry.addedAt or 0, e.addedAt or 0),
        removedAt = math.max(localEntry.removedAt or 0, e.removedAt or 0),
      }
      merged = merged + 1
    end
  end
  -- Prune characters that newly match the merged ignore list, mirroring
  -- the on-disk wipe that /hs ignore does locally.
  if HelloStockDB.characters then
    for k, c in pairs(HelloStockDB.characters) do
      if self:IsIgnored(c.name, c.realm) then
        HelloStockDB.characters[k] = nil
      end
    end
  end
  if HelloStockDB.debug then
    print(("|cff888888[HS recv]|r ignored merged (%d entries)"):format(merged))
  end
  if addon.UI and addon.UI:IsShown() then addon.UI:Refresh() end
end

function addon:ReceiveTargets(snap)
  HelloStockDB = HelloStockDB or {}
  -- Sync only ever reaches characters within the same scope (faction +
  -- connected-realm), so the incoming payload belongs in our current scope's
  -- target bucket. ScopeKey-on-snap could be carried in the payload for
  -- defense-in-depth, but the Comm layer already filters by faction+realm
  -- before the snapshot is delivered here.
  local bucket = self:GetTargets()
  local localTs = bucket.updatedAt or 0
  if (snap.ts or 0) <= localTs then
    if HelloStockDB.debug then
      print(("|cffaa3333[HS drop]|r targets: incoming ts %d not newer than %d"):format(snap.ts or 0, localTs))
    end
    return
  end
  bucket.items     = snap.targets or {}
  bucket.updatedAt = snap.ts
  if HelloStockDB.debug then
    local n = 0
    for _ in pairs(bucket.items) do n = n + 1 end
    print(("|cff888888[HS recv]|r targets (%d entries, ts %d)"):format(n, snap.ts))
  end
  if addon.UI and addon.UI:IsShown() then addon.UI:Refresh() end
end

function addon:ReceiveSnapshot(snap, senderHash)
  HelloStockDB = HelloStockDB or {}
  HelloStockDB.characters = HelloStockDB.characters or {}

  -- Drop snapshots from ignored characters before doing anything else.
  -- /hs ignore wiped their on-disk record; we don't want the next inbound
  -- broadcast to recreate it.
  if self:IsIgnored(snap.name, snap.realm) then
    if HelloStockDB.debug then
      print(("|cffaa3333[HS drop]|r %s-%s: character is on the ignore list")
        :format(tostring(snap.name), tostring(snap.realm)))
    end
    return
  end

  local key = CharKey(snap.realm, snap.faction, snap.name)
  local existing = HelloStockDB.characters[key]
  if existing and existing.bagsUpdated and snap.ts < existing.bagsUpdated then
    if HelloStockDB.debug then
      print(("|cffaa3333[HS drop]|r %s: incoming ts %d older than stored %d")
        :format(snap.name, snap.ts, existing.bagsUpdated))
    end
    return
  end
  local myID = self:GetAccountID()
  local incomingAcct = snap.accountID
  -- Defense: never let a peer claim our own accountID for a character we don't own.
  if existing and existing.accountID == myID and incomingAcct ~= myID then
    if HelloStockDB.debug then
      print(("|cffaa3333[HS drop]|r %s: peer tried to overwrite a self-owned char"):format(snap.name))
    end
    return
  end
  local isMine = (incomingAcct == myID)
  HelloStockDB.characters[key] = {
    name          = snap.name,
    realm         = snap.realm,
    faction       = snap.faction,
    accountID     = incomingAcct,
    bags          = snap.bags or {},
    bank          = snap.bank or {},
    mail          = snap.mail or (existing and existing.mail) or {},
    mailMoney     = snap.mailMoney or (existing and existing.mailMoney) or 0,
    outbox        = ExpireOutbox(snap.outbox or (existing and existing.outbox) or {}, snap.faction),
    moneyOutbox   = ExpireOutbox(snap.moneyOutbox or (existing and existing.moneyOutbox) or {}, snap.faction),
    class         = snap.class or (existing and existing.class) or nil,
    level         = snap.level or (existing and existing.level) or nil,
    professions   = snap.professions or (existing and existing.professions) or nil,
    crafts        = snap.crafts or {},
    money         = snap.money or (existing and existing.money) or 0,
    bagsUpdated   = snap.ts or 0,
    bankUpdated   = snap.ts or 0,
    mailUpdated   = snap.mailUpdated or (existing and existing.mailUpdated) or 0,
    outboxUpdated = snap.outboxUpdated or (existing and existing.outboxUpdated) or 0,
    source        = isMine and "self" or "sync",
    sourceSecret  = isMine and nil or senderHash,
  }
  RefreshUI()
  if self.RefreshOptions then self:RefreshOptions() end
  -- If auto-friend is on and we just learned about a peer character,
  -- nudge the friends list sync so they appear there too.
  if not isMine and HelloStockDB.autoFriendPeers and self.SyncPeerFriends then
    self:SyncPeerFriends()
  end
end

function addon:NormalizeRealm(name)
  return (name or ""):gsub("%s", "")
end

function addon:ConnectedRealmSet()
  local set = {}
  if GetAutoCompleteRealms then
    local realms = GetAutoCompleteRealms()
    if realms then
      for _, r in ipairs(realms) do set[self:NormalizeRealm(r)] = true end
    end
  end
  set[self:NormalizeRealm(GetRealmName())] = true
  return set
end

local function ConnectedRealmSet() return addon:ConnectedRealmSet() end

-- Scope key identifies the (faction, connected-realm-cluster) pair the
-- current character belongs to. Used to scope state (targets, etc.) so
-- logging onto a different cluster or the opposing faction doesn't leak
-- data across boundaries. Stable for as long as Blizzard keeps the cluster
-- composition stable; if a server merge changes the cluster, scope keys
-- shift and pre-merge targets appear in a now-orphan bucket — acceptable
-- given how rare that is.
function addon:ScopeKey()
  local faction = UnitFactionGroup("player") or "Neutral"
  local realms, seen = {}, {}
  for r in pairs(self:ConnectedRealmSet()) do
    if not seen[r] then
      seen[r] = true
      realms[#realms + 1] = r
    end
  end
  table.sort(realms)
  return faction .. "@" .. table.concat(realms, ",")
end

-- Lazy-migrating accessor for the current scope's target bucket. First call
-- after upgrading from a pre-scoped build moves the legacy flat
-- HelloStockDB.targets / .targetsUpdatedAt into the current scope's bucket
-- (the assumption being that whatever you set them to lives on this side).
function addon:GetTargets()
  HelloStockDB = HelloStockDB or {}
  HelloStockDB.targetsByScope = HelloStockDB.targetsByScope or {}
  if HelloStockDB.targets and next(HelloStockDB.targets) ~= nil then
    local key = self:ScopeKey()
    HelloStockDB.targetsByScope[key] = HelloStockDB.targetsByScope[key] or {
      items     = HelloStockDB.targets,
      updatedAt = HelloStockDB.targetsUpdatedAt or time(),
    }
    HelloStockDB.targets = nil
    HelloStockDB.targetsUpdatedAt = nil
  elseif HelloStockDB.targets then
    -- Empty legacy table — drop it without migrating.
    HelloStockDB.targets = nil
    HelloStockDB.targetsUpdatedAt = nil
  end
  local key = self:ScopeKey()
  local entry = HelloStockDB.targetsByScope[key]
  if not entry then
    entry = { items = {}, updatedAt = 0 }
    HelloStockDB.targetsByScope[key] = entry
  end
  entry.items = entry.items or {}
  return entry
end

-- List of characters (in same-faction + connected-realm scope) that know how
-- to craft itemID. Each entry: { name = "Char-Realm", isMine = bool }.
-- Sorted alphabetically. Used by the global tooltip hook.
function addon:GetCrafters(itemID)
  local out = {}
  if not HelloStockDB or not HelloStockDB.characters then return out end
  local myFaction = UnitFactionGroup("player") or "Neutral"
  local realmSet  = self:ConnectedRealmSet()
  local myID      = self:GetAccountID()
  for _, c in pairs(HelloStockDB.characters) do
    if c.faction == myFaction and c.realm and realmSet[self:NormalizeRealm(c.realm)]
       and c.crafts and c.crafts[itemID] then
      out[#out + 1] = {
        name   = (c.name or "?") .. "-" .. (c.realm or "?"),
        isMine = c.accountID == myID,
      }
    end
  end
  table.sort(out, function(a, b) return a.name < b.name end)
  return out
end

-- Sum a single item across every character on the same faction and connected-realm group.
function addon:GetTotals(itemID)
  local total, breakdown = 0, {}
  if not HelloStockDB or not HelloStockDB.characters then return 0, breakdown end

  local myFaction = UnitFactionGroup("player") or "Neutral"
  local realmSet  = ConnectedRealmSet()
  local myID      = self:GetAccountID()

  local function InScope(c)
    return c.faction == myFaction
       and c.realm
       and realmSet[addon:NormalizeRealm(c.realm)]
  end

  -- Build one entry per character lazily, so a recipient that holds nothing
  -- but is receiving an in-transit item still shows up as a row.
  local entries = {}
  local function EntryFor(c)
    local key = CharKey(c.realm, c.faction, c.name)
    local e = entries[key]
    if not e then
      e = {
        name    = (c.name or "?") .. "-" .. (c.realm or "?"),
        count   = 0,
        mail    = 0,
        transit = 0,
        isMine  = c.accountID == myID,
      }
      entries[key] = e
    end
    return e
  end

  for _, c in pairs(HelloStockDB.characters) do
    if InScope(c) and not self:IsIgnored(c.name, c.realm) then
      local bags = c.bags and c.bags[itemID] or 0
      local bank = c.bank and c.bank[itemID] or 0
      local mail = c.mail and c.mail[itemID] or 0
      if bags + bank + mail > 0 then
        local e = EntryFor(c)
        e.count = e.count + bags + bank + mail
        e.mail  = e.mail + mail
      end
    end
  end

  -- Outbox lives on the sender's record but the item is heading to someone
  -- else — attribute the in-transit count to the recipient instead. Falls
  -- back to the sender only when the recipient is out of scope (e.g. their
  -- snapshot hasn't been received yet, or they're on a connected realm we
  -- don't recognise), so the item never disappears from the totals.
  for _, sender in pairs(HelloStockDB.characters) do
    if sender.outbox and not self:IsIgnored(sender.name, sender.realm) then
      sender.outbox = ExpireOutbox(sender.outbox, sender.faction)
      for _, oe in ipairs(sender.outbox) do
        if oe.id == itemID then
          local recipient = FindCharByName(oe.to, sender.faction)
          local attribTo  = (recipient and InScope(recipient)) and recipient or sender
          if InScope(attribTo) and not self:IsIgnored(attribTo.name, attribTo.realm) then
            local e = EntryFor(attribTo)
            e.count   = e.count   + (oe.count or 0)
            e.transit = e.transit + (oe.count or 0)
          end
        end
      end
    end
  end

  for _, e in pairs(entries) do
    total = total + e.count
    breakdown[#breakdown + 1] = e
  end
  table.sort(breakdown, function(a, b) return a.count > b.count end)
  return total, breakdown
end

-- Sum copper across every character on the same faction and connected-realm
-- group. Wallet + gold sitting unclaimed in their inbox + gold in transit on
-- outgoing mail (attributed to the recipient, mirroring item GetTotals).
function addon:GetTotalMoney()
  local total, breakdown = 0, {}
  if not HelloStockDB or not HelloStockDB.characters then return 0, breakdown end

  local myFaction = UnitFactionGroup("player") or "Neutral"
  local realmSet  = ConnectedRealmSet()
  local myID      = self:GetAccountID()

  local function InScope(c)
    return c.faction == myFaction
       and c.realm
       and realmSet[addon:NormalizeRealm(c.realm)]
  end

  local entries = {}
  local function EntryFor(c)
    local key = CharKey(c.realm, c.faction, c.name)
    local e = entries[key]
    if not e then
      e = {
        name    = (c.name or "?") .. "-" .. (c.realm or "?"),
        copper  = 0,
        mail    = 0,
        transit = 0,
        isMine  = c.accountID == myID,
      }
      entries[key] = e
    end
    return e
  end

  for _, c in pairs(HelloStockDB.characters) do
    if InScope(c) and not self:IsIgnored(c.name, c.realm) then
      local wallet = tonumber(c.money)     or 0
      local mail   = tonumber(c.mailMoney) or 0
      if wallet + mail > 0 then
        local e = EntryFor(c)
        e.copper = e.copper + wallet + mail
        e.mail   = e.mail + mail
      end
    end
  end

  for _, sender in pairs(HelloStockDB.characters) do
    if sender.moneyOutbox and not self:IsIgnored(sender.name, sender.realm) then
      sender.moneyOutbox = ExpireOutbox(sender.moneyOutbox, sender.faction)
      for _, oe in ipairs(sender.moneyOutbox) do
        local recipient = FindCharByName(oe.to, sender.faction)
        local attribTo  = (recipient and InScope(recipient)) and recipient or sender
        if InScope(attribTo) and not self:IsIgnored(attribTo.name, attribTo.realm) then
          local e = EntryFor(attribTo)
          e.copper  = e.copper  + (oe.copper or 0)
          e.transit = e.transit + (oe.copper or 0)
        end
      end
    end
  end

  for _, e in pairs(entries) do
    total = total + e.copper
    breakdown[#breakdown + 1] = e
  end
  table.sort(breakdown, function(a, b) return a.copper > b.copper end)
  return total, breakdown
end

-- One row per stored character, with the stats the Characters tab needs.
-- Returns two lists: `inScope` (same faction + connected realm cluster as the
-- viewing player) and `outOfScope` (everything else, surfaced in a collapsed
-- footer for transparency). Each entry is a value-only table so the UI never
-- mutates the underlying DB record.
function addon:GetCharOverview()
  local inScope, outOfScope = {}, {}
  if not HelloStockDB or not HelloStockDB.characters then return inScope, outOfScope end

  local myFaction = UnitFactionGroup("player") or "Neutral"
  local realmSet  = ConnectedRealmSet()
  local myID      = self:GetAccountID()

  for _, c in pairs(HelloStockDB.characters) do
    if c.name and c.name ~= "" and not self:IsIgnored(c.name, c.realm) then
      local items = 0
      if c.bags   then for _, n in pairs(c.bags)   do items = items + n end end
      if c.bank   then for _, n in pairs(c.bank)   do items = items + n end end
      if c.mail   then for _, n in pairs(c.mail)   do items = items + n end end
      if c.outbox then for _, e in ipairs(c.outbox) do items = items + (e.count or 0) end end

      local transitGold = 0
      if c.moneyOutbox then
        for _, e in ipairs(c.moneyOutbox) do transitGold = transitGold + (e.copper or 0) end
      end

      local inboxItemCount = 0
      if c.mail then for _, n in pairs(c.mail) do inboxItemCount = inboxItemCount + n end end

      local lastSync = math.max(
        tonumber(c.bagsUpdated)   or 0,
        tonumber(c.bankUpdated)   or 0,
        tonumber(c.mailUpdated)   or 0,
        tonumber(c.outboxUpdated) or 0
      )
      local isMine    = c.accountID == myID
      local isPending = lastSync == 0
      local row = {
        key        = (c.realm or "") .. ":" .. (c.faction or "") .. ":" .. c.name,
        name       = c.name,
        realm      = c.realm or "?",
        faction    = c.faction or "?",
        class      = c.class,
        level      = c.level,
        accountID  = c.accountID,
        isMine     = isMine,
        isPending  = isPending,
        kind       = isPending and "pending" or (isMine and "self" or "paired"),
        lastSync   = lastSync,
        items      = items,
        copper     = (tonumber(c.money) or 0)
                  + (tonumber(c.mailMoney) or 0)
                  + transitGold,
        wallet     = tonumber(c.money) or 0,
        mailMoney  = tonumber(c.mailMoney) or 0,
        transit    = transitGold,
        inboxItems = inboxItemCount,
        outboxItems = c.outbox and #c.outbox or 0,
        pendingMail = inboxItemCount,  -- inbox items; in-transit added in pass 2
        crafts      = c.crafts,
        professions = c.professions,
      }
      local realmOK = c.realm and realmSet[addon:NormalizeRealm(c.realm)]
      if c.faction == myFaction and realmOK then
        inScope[#inScope + 1] = row
      else
        outOfScope[#outOfScope + 1] = row
      end
    end
  end

  -- Second pass: items in transit to each character (someone else's outbox
  -- entries naming this char as recipient). Together with the inbox count
  -- from pass 1 these form pendingMail — "things sent that the character
  -- hasn't taken into their bags yet."
  local byName = {}
  for _, row in ipairs(inScope)    do byName[row.name] = row end
  for _, row in ipairs(outOfScope) do byName[row.name] = row end
  for _, sender in pairs(HelloStockDB.characters) do
    if sender.outbox and not self:IsIgnored(sender.name, sender.realm) then
      for _, e in ipairs(sender.outbox) do
        if e.to and e.count then
          local bare = e.to:match("^([^%-]+)") or e.to
          local target = byName[bare]
          if target then
            target.pendingMail = (target.pendingMail or 0) + e.count
          end
        end
      end
    end
  end

  local function cmp(a, b)
    -- Pending placeholders sink to the bottom. Then: level desc, class asc,
    -- name asc as a stable tiebreaker.
    if a.isPending ~= b.isPending then return not a.isPending end
    local al, bl = a.level or 0, b.level or 0
    if al ~= bl then return al > bl end
    local ac, bc = a.class or "", b.class or ""
    if ac ~= bc then return ac < bc end
    return a.name < b.name
  end
  table.sort(inScope, cmp)
  table.sort(outOfScope, cmp)
  return inScope, outOfScope
end

local function PrimeItemCache()
  for _, section in pairs(addon.ITEMS) do
    for _, group in ipairs(section) do
      for _, item in ipairs(group.items) do
        if item.id then GetItemInfo(item.id) end
      end
    end
  end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("BAG_UPDATE_DELAYED")
f:RegisterEvent("BANKFRAME_OPENED")
f:RegisterEvent("BANKFRAME_CLOSED")
f:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
f:RegisterEvent("PLAYER_MONEY")
f:RegisterEvent("MAIL_SHOW")
f:RegisterEvent("MAIL_INBOX_UPDATE")
f:RegisterEvent("MAIL_SEND_SUCCESS")
f:RegisterEvent("MAIL_CLOSED")
f:RegisterEvent("GET_ITEM_INFO_RECEIVED")
f:RegisterEvent("TRADE_SKILL_SHOW")
f:RegisterEvent("TRADE_SKILL_UPDATE")
f:RegisterEvent("CRAFT_SHOW")
f:RegisterEvent("CRAFT_UPDATE")
f:RegisterEvent("SPELLS_CHANGED")
f:RegisterEvent("CHAT_MSG_SKILL")
f:RegisterEvent("PLAYER_LEVEL_UP")

local bankOpen = false
local pendingItemRefresh = false
local pendingProfRescan = false

f:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_LOGIN" then
    addon:GetAccountID()
    if HelloStockDB and HelloStockDB.characters then
      local tracked = TrackedItemSet()
      for k, c in pairs(HelloStockDB.characters) do
        -- Drop entries that are totally empty.
        if (not c.name or c.name == "") and (not c.realm or c.realm == "") then
          HelloStockDB.characters[k] = nil
        else
          -- Trim previously-stored bag/bank lists to only the tracked items, so
          -- broadcasts don't include payload bytes for items we never display.
          if c.bags then
            for id in pairs(c.bags) do
              if not tracked[id] then c.bags[id] = nil end
            end
          end
          if c.bank then
            for id in pairs(c.bank) do
              if not tracked[id] then c.bank[id] = nil end
            end
          end
          if c.mail then
            for id in pairs(c.mail) do
              if not tracked[id] then c.mail[id] = nil end
            end
          end
          if c.outbox then
            local kept = {}
            for _, e in ipairs(c.outbox) do
              if tracked[e.id] then kept[#kept + 1] = e end
            end
            c.outbox = ExpireOutbox(kept, c.faction)
          end
          if c.moneyOutbox then
            c.moneyOutbox = ExpireOutbox(c.moneyOutbox, c.faction)
          end
        end
      end
    end
    EnsureDB()
    PrimeItemCache()
    UpdateBags()
    UpdateProfessions()
    -- The spellbook isn't always populated by PLAYER_LOGIN; gathering
    -- professions in particular sometimes return nil from GetProfessions()
    -- at this point. Retry a few seconds in. SPELLS_CHANGED also fires
    -- when the book becomes ready, so this is a belt-and-braces.
    C_Timer.After(3, UpdateProfessions)
    -- Friends list is populated asynchronously after login; defer the
    -- auto-friend sync so the de-dup check against current friends is
    -- accurate.
    C_Timer.After(5, function()
      if HelloStockDB and HelloStockDB.autoFriendPeers and addon.SyncPeerFriends then
        addon:SyncPeerFriends()
      end
    end)
  elseif event == "BAG_UPDATE_DELAYED" then
    UpdateBags()
    if bankOpen then UpdateBank() end
  elseif event == "BANKFRAME_OPENED" then
    bankOpen = true
    C_Timer.After(0.1, UpdateBank)
  elseif event == "PLAYERBANKSLOTS_CHANGED" then
    if bankOpen then UpdateBank() end
  elseif event == "BANKFRAME_CLOSED" then
    bankOpen = false
  elseif event == "PLAYER_MONEY" then
    UpdateMoney()
  elseif event == "MAIL_SHOW" then
    InstallMailHooks()
    if CheckInbox then CheckInbox() end
    -- The inbox isn't ready immediately on MAIL_SHOW; MAIL_INBOX_UPDATE will
    -- fire when contents are populated. Defer a scan as a safety net in case
    -- the player opens an already-populated mailbox.
    C_Timer.After(0.2, UpdateMail)
  elseif event == "MAIL_INBOX_UPDATE" then
    UpdateMail()
  elseif event == "MAIL_SEND_SUCCESS" then
    if pendingSend then
      local c = EnsureDB()
      c.outbox      = ExpireOutbox(c.outbox or {}, c.faction)
      c.moneyOutbox = ExpireOutbox(c.moneyOutbox or {}, c.faction)
      local now = time()
      for _, m in ipairs(pendingSend.items) do
        c.outbox[#c.outbox + 1] = { id = m.id, count = m.count, to = pendingSend.to, sentAt = now }
      end
      if pendingSend.money and pendingSend.money > 0 then
        c.moneyOutbox[#c.moneyOutbox + 1] = {
          copper = pendingSend.money, to = pendingSend.to, sentAt = now,
        }
      end
      c.outboxUpdated = now
      pendingSend = nil
      RefreshUI()
      Broadcast()
    end
  elseif event == "MAIL_CLOSED" then
    -- Re-scan once on close: server may have processed take-attachment /
    -- return-message actions whose final state only stabilises here.
    UpdateMail()
  elseif event == "GET_ITEM_INFO_RECEIVED" then
    -- An item's localized name just became available. Drop the cached
    -- name→ID map so the next profession scan rebuilds it with the proper
    -- localized name for whatever item this was (non-English clients depend
    -- on this for recipe-name → item matching).
    nameToID = nil
    if not pendingItemRefresh then
      pendingItemRefresh = true
      C_Timer.After(0.5, function() pendingItemRefresh = false; RefreshUI() end)
    end
  elseif event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_UPDATE"
      or event == "CRAFT_SHOW"       or event == "CRAFT_UPDATE" then
    -- A small delay gives the client time to populate the recipe list.
    C_Timer.After(0.1, ScanRecipes)
    -- Refresh skill level too — opening a profession window is the most
    -- common moment after a skill-up.
    C_Timer.After(0.1, UpdateProfessions)
  elseif event == "SPELLS_CHANGED" then
    -- Fires when the spellbook is initialised after login and again any
    -- time a spell is learned/unlearned (which includes professions).
    UpdateProfessions()
  elseif event == "CHAT_MSG_SKILL" then
    -- Skill-up messages — caught here so Mining/Herbalism stay current
    -- without needing to open a trade-skill window. Debounced because a
    -- gathering session can spam these.
    if not pendingProfRescan then
      pendingProfRescan = true
      C_Timer.After(3, function()
        pendingProfRescan = false
        UpdateProfessions()
      end)
    end
  elseif event == "PLAYER_LEVEL_UP" then
    EnsureDB()  -- re-reads UnitLevel into c.level
    RefreshUI()
    Broadcast()
  end
end)

local function MyFaction()
  return UnitFactionGroup("player") or "Neutral"
end

-- ============================================================
-- Account ID. WoW exposes no per-WoW-account identifier (the BattleTag
-- is shared across all WoW licenses on the same Bnet), but SavedVariables
-- is per-account, so a one-time random ID stored there acts as one.
-- ============================================================

local function GenerateAccountID()
  local chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789abcdefghjkmnpqrstuvwxyz"
  local out = {}
  for i = 1, 16 do
    local r = math.random(1, #chars)
    out[i] = chars:sub(r, r)
  end
  return table.concat(out)
end

function addon:GetAccountID()
  HelloStockDB = HelloStockDB or {}
  if not HelloStockDB.accountID then
    HelloStockDB.accountID = GenerateAccountID()
  end
  return HelloStockDB.accountID
end

-- ============================================================
-- Shared secret. Both accounts use /hs secret <word>. Snapshots
-- include a hash of the secret; receivers only accept matching hashes.
-- ============================================================

local function HashSecret(s)
  if not s or s == "" then return "" end
  local h = 2166136261
  for i = 1, #s do
    h = bit.bxor(h, s:byte(i))
    h = (h * 16777619) % 4294967296
  end
  return string.format("%08x", h)
end

addon.HashSecret = HashSecret

-- Record a placeholder character entry for a peer we just paired with, so
-- GetWhisperTargets() can reach them before any actual sync data has flowed.
function addon:RecordPeerPlaceholder(name, realm, faction, accountID)
  if not name or name == "" or not realm or realm == "" then return end
  HelloStockDB = HelloStockDB or {}
  HelloStockDB.characters = HelloStockDB.characters or {}
  local key = CharKey(realm, faction or "Neutral", name)
  local c = HelloStockDB.characters[key]
  if not c then
    c = {
      name        = name,
      realm       = realm,
      faction     = faction or "Neutral",
      accountID   = accountID,
      bags        = {},
      bank        = {},
      bagsUpdated = 0,
      bankUpdated = 0,
      source      = "sync",
    }
    HelloStockDB.characters[key] = c
  else
    -- Refresh fields without disturbing existing bag/bank/timestamps.
    c.name      = name
    c.realm     = realm
    c.faction   = faction or c.faction or "Neutral"
    if accountID and accountID ~= "" then c.accountID = accountID end
  end
  if addon.UI and addon.UI:IsShown() then addon.UI:Refresh() end
end

-- Friends-list integration. Opt-in via HelloStockDB.autoFriendPeers: when
-- enabled, paired-account characters in the current scope are added to the
-- friends list automatically. Adding them as friends is a known workaround
-- for various Blizzard "interacting with a stranger" prompts (mail warnings,
-- whispers in restricted modes, etc.). Removal is manual via /hs unbefriend.
local function PeerCharsInScope()
  local out = {}
  if not HelloStockDB or not HelloStockDB.characters then return out end
  local myFaction = UnitFactionGroup("player") or "Neutral"
  local realmSet  = addon:ConnectedRealmSet()
  local myID      = addon:GetAccountID()
  for _, c in pairs(HelloStockDB.characters) do
    if c.faction == myFaction
       and c.realm and realmSet[addon:NormalizeRealm(c.realm)]
       and c.accountID and c.accountID ~= myID
       and c.name and c.name ~= "" then
      out[#out + 1] = c
    end
  end
  return out
end

local function CurrentFriendsSet()
  local set = {}
  if C_FriendList and C_FriendList.GetNumFriends then
    for i = 1, C_FriendList.GetNumFriends() do
      local info = C_FriendList.GetFriendInfoByIndex(i)
      if info and info.name then set[info.name:lower()] = true end
    end
  end
  return set
end

local function FullCharName(c)
  return c.name .. "-" .. addon:NormalizeRealm(c.realm)
end

local AUTOFRIEND_NOTE = "Paired (HelloStock)"

function addon:SyncPeerFriends()
  if not C_FriendList or not C_FriendList.AddFriend then return 0 end
  local friends = CurrentFriendsSet()
  local added = 0
  for _, c in ipairs(PeerCharsInScope()) do
    local full = FullCharName(c)
    if not friends[c.name:lower()] and not friends[full:lower()] then
      -- C_FriendList.AddFriend accepts an optional `notes` parameter so
      -- the addition is tagged in the friends panel without a separate
      -- SetFriendNotes round-trip. Existing friends added manually keep
      -- whatever note the user set themselves — we only stamp ours when
      -- *we* add the entry.
      C_FriendList.AddFriend(full, AUTOFRIEND_NOTE)
      added = added + 1
    end
  end
  return added
end

function addon:RemovePeerFriends()
  if not C_FriendList or not C_FriendList.RemoveFriend then return 0 end
  local friends = CurrentFriendsSet()
  local removed = 0
  for _, c in ipairs(PeerCharsInScope()) do
    local full = FullCharName(c)
    if friends[full:lower()] then
      C_FriendList.RemoveFriend(full)
      removed = removed + 1
    elseif friends[c.name:lower()] then
      C_FriendList.RemoveFriend(c.name)
      removed = removed + 1
    end
  end
  return removed
end

-- Whisper targets for solo sync: every character in the DB that belongs to a
-- different account than ours (i.e. came in via a previous paired sync).
function addon:GetWhisperTargets()
  local targets = {}
  if not HelloStockDB or not HelloStockDB.characters then return targets end
  local myID = self:GetAccountID()
  for _, c in pairs(HelloStockDB.characters) do
    if c.name and c.name ~= "" and c.realm and c.realm ~= ""
       and c.accountID and c.accountID ~= myID then
      local realm = self:NormalizeRealm(c.realm)
      targets[#targets + 1] = c.name .. "-" .. realm
    end
  end
  return targets
end

function addon:GetSecret()
  HelloStockDB = HelloStockDB or {}
  return HelloStockDB.secret
end

function addon:GetSecretHash()
  local s = self:GetSecret()
  if not s or s == "" then return "" end
  return HashSecret(s)
end

function addon:SetSecret(s)
  HelloStockDB = HelloStockDB or {}
  if s == "" or s == nil then
    HelloStockDB.secret = nil
  else
    HelloStockDB.secret = s
  end
  if self.RefreshOptions then self:RefreshOptions() end
  if self.UI and self.UI:IsShown() then self.UI:Refresh() end
end

function addon:IsTrustedHash(hash)
  if not hash or hash == "" then return false end
  return hash == self:GetSecretHash()
end

-- Clear the secret AND wipe every character belonging to a different account.
-- Uses accountID as the authoritative ownership signal: any char whose accountID
-- is explicitly set and doesn't match ours is from a peer.
function addon:Unpair()
  self:SetSecret(nil)
  local myID = self:GetAccountID()
  local removed = 0
  if HelloStockDB and HelloStockDB.characters then
    for k, c in pairs(HelloStockDB.characters) do
      if c.accountID and c.accountID ~= myID then
        HelloStockDB.characters[k] = nil
        removed = removed + 1
      end
    end
    -- Drop outbox entries on our remaining (own) chars that were addressed to
    -- a peer character we just removed. Otherwise those entries would linger
    -- as "in transit to <unknown char>" for up to 30 days, since the prune
    -- rule keeps entries while their recipient hasn't proven receipt — and
    -- with the recipient gone, that proof can never arrive.
    for _, c in pairs(HelloStockDB.characters) do
      if c.outbox then
        local kept = {}
        for _, e in ipairs(c.outbox) do
          if FindCharByName(e.to, c.faction) then
            kept[#kept + 1] = e
          end
        end
        c.outbox = kept
      end
      if c.moneyOutbox then
        local kept = {}
        for _, e in ipairs(c.moneyOutbox) do
          if FindCharByName(e.to, c.faction) then
            kept[#kept + 1] = e
          end
        end
        c.moneyOutbox = kept
      end
    end
  end
  if addon.UI and addon.UI:IsShown() then addon.UI:Refresh() end
  if self.RefreshOptions then self:RefreshOptions() end
  return removed
end

StaticPopupDialogs["HELLOSTOCK_PAIR_INVITE"] = {
  text         = "HelloStock: accept pair invite from %s?\nThis sets your shared secret to theirs.",
  button1      = ACCEPT,
  button2      = CANCEL,
  OnAccept     = function(_, data)
    if data and data.secret then
      addon:SetSecret(data.secret)
      print(("|cffffd700HelloStock:|r paired with %s. (secret hash %s)"):format(
        data.sender or "?", addon:GetSecretHash()))
      if data.sender and data.realm then
        addon:RecordPeerPlaceholder(data.sender, data.realm, data.faction, data.accountID)
        if addon.Comm and addon.Comm.SendPairReply then
          local sender = data.sender
          local realm  = addon:NormalizeRealm(data.realm)
          local target = (realm and realm ~= "") and (sender .. "-" .. realm) or sender
          addon.Comm:SendPairReply(target)
        end
      end
    end
  end,
  timeout      = 0,
  whileDead    = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

StaticPopupDialogs["HELLOSTOCK_UNPAIR"] = {
  text         = "HelloStock: clear the shared secret and remove all synced character data?",
  button1      = "Unpair",
  button2      = CANCEL,
  OnAccept     = function()
    local n = addon:Unpair()
    print(("|cffffd700HelloStock:|r unpaired. Removed %d synced character(s)."):format(n))
  end,
  timeout      = 30,
  whileDead    = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

StaticPopupDialogs["HELLOSTOCK_CLEAR_TARGETS"] = {
  text         = "HelloStock: clear every target stock level for this faction + realm cluster?\nThis only wipes the per-item targets for your current scope; bag/bank snapshots, pairing, and targets on the other faction or other clusters are unaffected. The empty target list will sync to any paired account on this scope.",
  button1      = "Clear",
  button2      = CANCEL,
  OnAccept     = function()
    local bucket = addon:GetTargets()
    bucket.items     = {}
    bucket.updatedAt = time()
    if addon.Comm and addon.Comm.SendTargets then addon.Comm:SendTargets() end
    if addon.UI and addon.UI:IsShown() then addon.UI:Refresh() end
    print("|cffffd700HelloStock:|r targets cleared for this scope.")
  end,
  timeout      = 30,
  whileDead    = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

StaticPopupDialogs["HELLOSTOCK_RESET"] = {
  text         = "HelloStock: erase all stored data?\nThis wipes character snapshots, targets, pairing keys, trusted list, and UI state. UI will reload.",
  button1      = "Reset",
  button2      = CANCEL,
  OnAccept     = function()
    HelloStockDB = nil
    ReloadUI()
  end,
  timeout      = 30,
  whileDead    = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

-- Wipe characters + targets that belong to the current (faction, cluster)
-- scope only. Pairing, other scopes' data, UI state, and the minimap stay
-- intact. Returns the number of characters removed.
function addon:ResetScope()
  if not HelloStockDB then return 0 end
  local myFaction = UnitFactionGroup("player") or "Neutral"
  local realmSet  = self:ConnectedRealmSet()
  local removed = 0
  if HelloStockDB.characters then
    for k, c in pairs(HelloStockDB.characters) do
      local realmOK = c.realm and realmSet[self:NormalizeRealm(c.realm)]
      if c.faction == myFaction and realmOK then
        HelloStockDB.characters[k] = nil
        removed = removed + 1
      end
    end
  end
  if HelloStockDB.targetsByScope then
    HelloStockDB.targetsByScope[self:ScopeKey()] = nil
  end
  if addon.UI and addon.UI:IsShown() then addon.UI:Refresh() end
  if self.RefreshOptions then self:RefreshOptions() end
  return removed
end

StaticPopupDialogs["HELLOSTOCK_RESET_SCOPE"] = {
  text         = "HelloStock: erase data for this faction + realm cluster?\nRemoves every character snapshot and target on the current scope. Pairing, other scopes' data, UI state, and the minimap are untouched.",
  button1      = "Reset scope",
  button2      = CANCEL,
  OnAccept     = function()
    local n = addon:ResetScope()
    print(("|cffffd700HelloStock:|r reset current scope (%d character(s) removed)."):format(n))
  end,
  timeout      = 30,
  whileDead    = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

SLASH_HELLOSTOCK1 = "/hellostock"
SLASH_HELLOSTOCK2 = "/hs"
SlashCmdList["HELLOSTOCK"] = function(msg)
  local cmd, rest = (msg or ""):match("^(%S*)%s*(.*)$")
  cmd = (cmd or ""):lower()

  if cmd == "" then
    if addon.UI then addon.UI:Toggle() end

  elseif cmd == "pair" then
    local target = rest
    if target == "" then
      if UnitExists("target") and UnitIsPlayer("target") then
        local tName, tRealm = UnitFullName("target")
        if tRealm and tRealm ~= "" then
          target = tName .. "-" .. tRealm
        else
          target = tName
        end
      else
        print("|cffffd700HelloStock:|r target a player and type /hs pair, or use /hs pair <CharName[-Realm]>")
        return
      end
    end
    local myName, myRealm = UnitFullName("player")
    local myFullName = (myRealm and myRealm ~= "") and (myName .. "-" .. myRealm) or myName
    if target == myName or target == myFullName then
      print("|cffffd700HelloStock:|r can't pair with yourself.")
      return
    end
    local s = addon:GetSecret()
    if not s then
      local chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789abcdefghjkmnpqrstuvwxyz"
      local out = {}
      for i = 1, 14 do
        local r = math.random(1, #chars)
        out[i] = chars:sub(r, r)
      end
      s = table.concat(out)
      addon:SetSecret(s)
      print(("|cffffd700HelloStock:|r generated a new secret (hash %s)."):format(addon:GetSecretHash()))
    end
    if addon.Comm and addon.Comm.SendPairInvite then
      addon.Comm:SendPairInvite(target, s)
      print(("|cffffd700HelloStock:|r pair invite sent to %s — they'll see a popup to accept."):format(target))
    end

  elseif cmd == "secret" then
    if rest == "" then
      local s = addon:GetSecret()
      if not s then
        print("|cffffd700HelloStock:|r no secret set. Use |cff00ff00/hs secret <word>|r — pick any word and type it on both accounts.")
      else
        print(("|cffffd700HelloStock:|r current secret: %s  (hash %s)"):format(s, addon:GetSecretHash()))
      end
    else
      addon:SetSecret(rest)
      print(("|cffffd700HelloStock:|r secret set (hash %s). Use the same word on the other account."):format(addon:GetSecretHash()))
    end

  elseif cmd == "unpair" then
    StaticPopup_Show("HELLOSTOCK_UNPAIR")

  elseif cmd == "sync" then
    local whisperTargets = addon:GetWhisperTargets()
    if #whisperTargets == 0 then
      print("|cffffd700HelloStock:|r no paired characters known — pair via /hs pair first.")
    elseif addon.Comm and addon.Comm.SendSnapshot then
      local pushed   = {}
      local myFaction = MyFaction()
      local myID      = addon:GetAccountID()
      local realmSet  = addon:ConnectedRealmSet()
      for _, c in pairs(HelloStockDB and HelloStockDB.characters or {}) do
        if c.accountID == myID and c.name and c.name ~= "" and c.realm and c.realm ~= ""
           and c.faction == myFaction
           and realmSet[addon:NormalizeRealm(c.realm)] then
          pushed[#pushed + 1] = c.name .. "-" .. c.realm
        end
      end
      addon.Comm:SendSnapshot(true)
      print(("|cffffd700HelloStock:|r pushing %d chars: %s"):format(#pushed, table.concat(pushed, ", ")))
    end

  elseif cmd == "forget" then
    if rest == "" then
      print("|cffffd700HelloStock:|r usage: /hs forget <CharName>")
    else
      local target = rest:lower()
      local removed = 0
      if HelloStockDB and HelloStockDB.characters then
        for key, c in pairs(HelloStockDB.characters) do
          if c.name and c.name:lower() == target then
            HelloStockDB.characters[key] = nil
            removed = removed + 1
            print(("|cffffd700HelloStock:|r removed %s-%s"):format(c.name, c.realm or "?"))
          end
        end
        -- Same orphan cleanup as Unpair: any outbox entry addressed to the
        -- character we just removed would otherwise linger for 30 days.
        if removed > 0 then
          for _, c in pairs(HelloStockDB.characters) do
            if c.outbox then
              local kept = {}
              for _, e in ipairs(c.outbox) do
                if FindCharByName(e.to, c.faction) then
                  kept[#kept + 1] = e
                end
              end
              c.outbox = kept
            end
            if c.moneyOutbox then
              local kept = {}
              for _, e in ipairs(c.moneyOutbox) do
                if FindCharByName(e.to, c.faction) then
                  kept[#kept + 1] = e
                end
              end
              c.moneyOutbox = kept
            end
          end
        end
      end
      if removed == 0 then
        print("|cffffd700HelloStock:|r no character named '" .. rest .. "' in the DB.")
      else
        RefreshUI()
      end
    end

  elseif cmd == "profs" then
    -- Diagnostic dump for profession capture. Run when professions look
    -- wrong in the Characters overview.
    print("|cffffd700HelloStock profs:|r")
    print(("  TRADESKILLS global: %s"):format(tostring(_G.TRADESKILLS)))
    print("  Skill panel (GetSkillLineInfo):")
    local n = (GetNumSkillLines and GetNumSkillLines()) or 0
    for i = 1, n do
      local name, isHeader, _, rank, _, _, maxRank = GetSkillLineInfo(i)
      if name then
        if isHeader then
          print(("    [header] %s"):format(name))
        else
          print(("      %s: %d/%d"):format(name, rank or 0, maxRank or 0))
        end
      end
    end
    print("  Spell-name lookups:")
    for _, spellID in ipairs(PROFESSION_APPRENTICE_SPELL_IDS) do
      local sname = GetSpellInfo and GetSpellInfo(spellID) or "?"
      print(("    %d → %s"):format(spellID, tostring(sname)))
    end
    UpdateProfessions()
    local me = addon:GetSelf()
    if me and me.professions and #me.professions > 0 then
      print("  Stored c.professions:")
      for _, p in ipairs(me.professions) do
        print(("    %s: %d/%d"):format(p.name, p.skill or 0, p.max or 0))
      end
    else
      print("  c.professions: empty / not set")
    end

  elseif cmd == "ignore" or cmd == "unignore" then
    if rest == "" then
      print(("|cffffd700HelloStock:|r usage: /hs %s <CharName[-Realm]>"):format(cmd))
    else
      -- Accept "Name-Realm" verbatim; default to the current realm if only
      -- a bare name was given. Stored key is lowercased and whitespace-
      -- stripped so it round-trips consistently.
      local name, realm = rest:match("^([^%-]+)%-(.+)$")
      if not name then name, realm = rest, GetRealmName() or "" end
      local key = IgnoreKey(name, realm)
      HelloStockDB = HelloStockDB or {}
      HelloStockDB.ignored = HelloStockDB.ignored or {}
      local entry = NormalizeIgnoreEntry(HelloStockDB.ignored[key], HelloStockDB.ignoredUpdatedAt)
      if cmd == "ignore" then
        entry.addedAt = time()
        HelloStockDB.ignored[key] = entry
        -- Wipe any stored data for this character — ignoring should leave
        -- no trace. Future snapshots from this character get dropped in
        -- ReceiveSnapshot, so the record stays gone until un-ignored.
        local removed = 0
        if HelloStockDB.characters then
          for k, c in pairs(HelloStockDB.characters) do
            if addon:IsIgnored(c.name, c.realm) then
              HelloStockDB.characters[k] = nil
              removed = removed + 1
            end
          end
        end
        print(("|cffffd700HelloStock:|r ignoring %s-%s (%d record(s) removed). Future snapshots from them will be dropped."):format(name, realm, removed))
      else
        entry.removedAt = time()
        HelloStockDB.ignored[key] = entry
        print(("|cffffd700HelloStock:|r no longer ignoring %s-%s. Their data will reappear after their next snapshot."):format(name, realm))
      end
      if addon.Comm and addon.Comm.SendIgnoreList then addon.Comm:SendIgnoreList() end
      if addon.UI and addon.UI:IsShown() then addon.UI:Refresh() end
    end

  elseif cmd == "ignored" then
    local any = false
    if HelloStockDB and HelloStockDB.ignored then
      for key, e in pairs(HelloStockDB.ignored) do
        local entry = NormalizeIgnoreEntry(e, HelloStockDB.ignoredUpdatedAt)
        if (entry.addedAt or 0) > (entry.removedAt or 0) then
          if not any then
            print("|cffffd700HelloStock:|r ignored characters:")
            any = true
          end
          print("  " .. key)
        end
      end
    end
    if not any then
      print("|cffffd700HelloStock:|r no characters are ignored. /hs ignore <CharName[-Realm]> to add one.")
    end

  elseif cmd == "autofriend" then
    HelloStockDB = HelloStockDB or {}
    local arg = rest:lower()
    if arg == "on" then
      HelloStockDB.autoFriendPeers = true
    elseif arg == "off" then
      HelloStockDB.autoFriendPeers = false
    else
      HelloStockDB.autoFriendPeers = not HelloStockDB.autoFriendPeers
    end
    print(("|cffffd700HelloStock:|r auto-add paired-account characters to friends list: %s")
      :format(HelloStockDB.autoFriendPeers and "ON" or "OFF"))
    if HelloStockDB.autoFriendPeers then
      local n = addon:SyncPeerFriends()
      if n > 0 then
        print(("|cffffd700HelloStock:|r added %d paired character(s) to your friends list."):format(n))
      end
    end
    if addon.RefreshOptions then addon:RefreshOptions() end

  elseif cmd == "unbefriend" then
    local n = addon:RemovePeerFriends()
    print(("|cffffd700HelloStock:|r removed %d paired character(s) from your friends list."):format(n))

  elseif cmd == "debug" then
    HelloStockDB = HelloStockDB or {}
    HelloStockDB.debug = not HelloStockDB.debug
    print("|cffffd700HelloStock:|r debug " .. (HelloStockDB.debug and "ON" or "OFF"))
    if addon.RefreshOptions then addon:RefreshOptions() end

  elseif cmd == "config" or cmd == "options" then
    if Settings and Settings.OpenToCategory and addon.OptionsCategoryID then
      Settings.OpenToCategory(addon.OptionsCategoryID)
    elseif InterfaceOptionsFrame_OpenToCategory and HelloStockOptionsPanel then
      InterfaceOptionsFrame_OpenToCategory(HelloStockOptionsPanel)
      InterfaceOptionsFrame_OpenToCategory(HelloStockOptionsPanel)
    else
      print("|cffffd700HelloStock:|r options panel not available.")
    end

  elseif cmd == "reset" then
    StaticPopup_Show("HELLOSTOCK_RESET")

  elseif cmd == "resetscope" then
    StaticPopup_Show("HELLOSTOCK_RESET_SCOPE")

  elseif cmd == "resetpos" then
    if addon.UI and addon.UI.ResetPosition then
      addon.UI:ResetPosition()
      print("|cffffd700HelloStock:|r window position reset to default.")
    end

  elseif cmd == "minimap" then
    if addon.SetMinimapHidden and addon.IsMinimapHidden then
      addon:SetMinimapHidden(not addon:IsMinimapHidden())
      print("|cffffd700HelloStock:|r minimap button " ..
        (addon:IsMinimapHidden() and "hidden" or "shown") .. ".")
      if addon.RefreshOptions then addon:RefreshOptions() end
    end

  elseif cmd == "cleartargets" then
    StaticPopup_Show("HELLOSTOCK_CLEAR_TARGETS")

  elseif cmd == "gather" then
    local list = addon:ComputeGatheringList()
    if #list == 0 then
      print("|cffffd700HelloStock:|r nothing to gather — every target met.")
    else
      print(("|cffffd700HelloStock gather list (%d reagent%s):|r")
        :format(#list, #list == 1 and "" or "s"))
      for _, entry in ipairs(list) do
        local name = GetItemInfo(entry.id) or ("Item " .. entry.id)
        print(("  %s — gather %d  (have %d, need %d)")
          :format(name, entry.gather, entry.have, entry.needed))
      end
    end

  elseif cmd == "chars" then
    local myID = addon:GetAccountID()
    local chars = HelloStockDB and HelloStockDB.characters or {}
    local list = {}
    for _, c in pairs(chars) do list[#list + 1] = c end
    table.sort(list, function(a, b)
      return (a.realm or "") .. (a.name or "") < (b.realm or "") .. (b.name or "")
    end)
    print(("|cffffd700HelloStock characters (%d):|r"):format(#list))
    for _, c in ipairs(list) do
      local tag = (c.accountID == myID) and "|cff80ff80mine|r"
        or (c.accountID and "|cff80c0ffpeer|r" or "|cff888888?|r")
      print(("  [%s] %s-%s (%s)"):format(
        tag,
        c.name or "(empty)",
        c.realm or "(empty)",
        c.faction or "?"))
    end

  elseif cmd == "claim" then
    if rest == "" then
      print("|cffffd700HelloStock:|r usage: /hs claim <CharName>  (re-stamp the entry with this account's ID so it gets broadcast on /hs sync)")
    else
      local target = rest:lower()
      local myID = addon:GetAccountID()
      local found = 0
      if HelloStockDB and HelloStockDB.characters then
        for _, c in pairs(HelloStockDB.characters) do
          if c.name and c.name:lower() == target then
            c.accountID = myID
            c.source = "self"
            c.sourceSecret = nil
            found = found + 1
          end
        end
      end
      print(("|cffffd700HelloStock:|r claimed %d character(s) named '%s' as belonging to this account."):format(found, rest))
      if addon.UI and addon.UI:IsShown() then addon.UI:Refresh() end
    end

  elseif cmd == "claimall" then
    local myID = addon:GetAccountID()
    local count = 0
    if HelloStockDB and HelloStockDB.characters then
      for _, c in pairs(HelloStockDB.characters) do
        if not c.accountID or c.accountID == "" then
          c.accountID = myID
          c.source = "self"
          count = count + 1
        end
      end
    end
    print(("|cffffd700HelloStock:|r claimed %d unowned character(s) as belonging to this account."):format(count))
    if addon.UI and addon.UI:IsShown() then addon.UI:Refresh() end

  elseif cmd == "whoami" then
    print(("|cffffd700HelloStock me:|r %s-%s (%s)  account=%s"):format(
      UnitName("player") or "?", GetRealmName() or "?",
      UnitFactionGroup("player") or "?",
      addon:GetAccountID():sub(1, 8) .. "..."))

  elseif cmd == "ping" then
    if addon.Comm and addon.Comm.SendPing then
      local ok, n = addon.Comm:SendPing()
      if ok then
        print(("|cffffd700HelloStock:|r ping queued to %d paired character(s)."):format(n))
      else
        print("|cffffd700HelloStock:|r no paired characters to ping.")
      end
    end

  elseif cmd == "status" then
    print("|cffffd700HelloStock status|r")
    print("  faction: " .. MyFaction() .. "   realm: " .. GetRealmName())
    local targets = addon:GetWhisperTargets()
    print(("  paired characters (whisper targets): %d"):format(#targets))
    for _, t in ipairs(targets) do print("    - " .. t) end
    local realms = GetAutoCompleteRealms and GetAutoCompleteRealms() or nil
    if realms and #realms > 0 then
      print("  connected realms: " .. table.concat(realms, ", "))
    else
      print("  connected realms: " .. GetRealmName() .. " (no connected group)")
    end
    local chars = HelloStockDB and HelloStockDB.characters or {}
    local n = 0
    for _ in pairs(chars) do n = n + 1 end
    local myID = addon:GetAccountID()
    print(("  my account ID: %s   characters in DB: %d"):format(myID:sub(1, 6) .. "...", n))
    for _, c in pairs(chars) do
      local age = c.bagsUpdated and (time() - c.bagsUpdated) or -1
      local tag
      if c.accountID == myID then
        tag = "mine"
      elseif c.accountID then
        tag = "peer " .. c.accountID:sub(1, 6) .. "..."
      else
        tag = "unknown"
      end
      print(("    %s (%s, %s) updated %ds ago [%s]"):format(
        c.name or "?", c.faction or "?", c.realm or "?", age, tag))
    end

  else
    print("|cffffd700HelloStock:|r commands: /hs, /hs pair [name], /hs secret [word], /hs unpair, /hs sync, /hs status, /hs whoami, /hs chars, /hs claim <name>, /hs claimall, /hs forget <name>, /hs ignore <name>, /hs unignore <name>, /hs ignored, /hs autofriend [on|off], /hs unbefriend, /hs debug, /hs config, /hs ping, /hs resetpos, /hs minimap, /hs gather, /hs cleartargets, /hs resetscope, /hs reset")
  end
end
