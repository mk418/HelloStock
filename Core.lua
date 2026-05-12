local _, addon = ...

local BAG_IDS  = { 0, 1, 2, 3, 4 }
local BANK_IDS = { -1, 5, 6, 7, 8, 9, 10, 11 }

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
      bags = {}, bank = {}, bagsUpdated = 0, bankUpdated = 0,
    }
    HelloStockDB.characters[key] = c
  end
  if playerName  and playerName  ~= "" then c.name    = playerName  end
  if playerRealm and playerRealm ~= "" then c.realm   = playerRealm end
  c.faction      = UnitFactionGroup("player") or "Neutral"
  c.accountID    = addon:GetAccountID()
  c.source       = "self"
  c.sourceSecret = nil
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

  local demand = {}
  for _, section in pairs(addon.ITEMS) do
    for _, group in ipairs(section) do
      for _, item in ipairs(group.items) do
        if item.id then
          local target = HelloStockDB and HelloStockDB.targets and HelloStockDB.targets[item.id]
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

  local demand = {}
  for _, section in pairs(addon.ITEMS) do
    for _, group in ipairs(section) do
      for _, item in ipairs(group.items) do
        if item.id then
          local target = HelloStockDB and HelloStockDB.targets and HelloStockDB.targets[item.id]
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

  for id, needed in pairs(demand) do
    if recipeMap[id] then
      local r      = recipeMap[id]
      local yield  = r.yield or 1
      local have   = self:GetTotals(id)
      local rawNet = needed - have
      if rawNet > 0 then
        local crafts = math.ceil(rawNet / yield)
        local craft  = crafts * yield
        out[#out + 1] = {
          id       = id,
          craft    = craft,
          crafts   = crafts,
          yield    = yield,
          have     = have,
          needed   = have + craft,
          category = self:GetItemCategory(id),
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
    local _, skillType = GetTradeSkillInfo(i)
    if skillType and skillType ~= "header" and GetTradeSkillItemLink then
      local link = GetTradeSkillItemLink(i)
      local id   = link and tonumber(link:match("item:(%d+)"))
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
    local _, _, craftType = GetCraftInfo(i)
    if craftType and craftType ~= "header" and GetCraftItemLink then
      local link = GetCraftItemLink(i)
      local id   = link and tonumber(link:match("item:(%d+)"))
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

function addon:GetSelf()
  if not HelloStockDB or not HelloStockDB.characters then return nil end
  return HelloStockDB.characters[MyKey()]
end

function addon:ReceiveTargets(snap)
  HelloStockDB = HelloStockDB or {}
  HelloStockDB.targets = HelloStockDB.targets or {}
  local localTs = HelloStockDB.targetsUpdatedAt or 0
  if (snap.ts or 0) <= localTs then
    if HelloStockDB.debug then
      print(("|cffaa3333[HS drop]|r targets: incoming ts %d not newer than %d"):format(snap.ts or 0, localTs))
    end
    return
  end
  HelloStockDB.targets = snap.targets or {}
  HelloStockDB.targetsUpdatedAt = snap.ts
  if HelloStockDB.debug then
    local n = 0
    for _ in pairs(HelloStockDB.targets) do n = n + 1 end
    print(("|cff888888[HS recv]|r targets (%d entries, ts %d)"):format(n, snap.ts))
  end
  if addon.UI and addon.UI:IsShown() then addon.UI:Refresh() end
end

function addon:ReceiveSnapshot(snap, senderHash)
  HelloStockDB = HelloStockDB or {}
  HelloStockDB.characters = HelloStockDB.characters or {}

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
    name         = snap.name,
    realm        = snap.realm,
    faction      = snap.faction,
    accountID    = incomingAcct,
    bags         = snap.bags or {},
    bank         = snap.bank or {},
    crafts       = snap.crafts or {},
    bagsUpdated  = snap.ts or 0,
    bankUpdated  = snap.ts or 0,
    source       = isMine and "self" or "sync",
    sourceSecret = isMine and nil or senderHash,
  }
  RefreshUI()
  if self.RefreshOptions then self:RefreshOptions() end
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

  for _, c in pairs(HelloStockDB.characters) do
    if c.faction == myFaction and c.realm and realmSet[addon:NormalizeRealm(c.realm)] then
      local n = (c.bags and c.bags[itemID] or 0) + (c.bank and c.bank[itemID] or 0)
      if n > 0 then
        total = total + n
        breakdown[#breakdown + 1] = {
          name   = (c.name or "?") .. "-" .. (c.realm or "?"),
          count  = n,
          isMine = c.accountID == myID,
        }
      end
    end
  end
  table.sort(breakdown, function(a, b) return a.count > b.count end)
  return total, breakdown
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
f:RegisterEvent("GET_ITEM_INFO_RECEIVED")
f:RegisterEvent("TRADE_SKILL_SHOW")
f:RegisterEvent("TRADE_SKILL_UPDATE")
f:RegisterEvent("CRAFT_SHOW")
f:RegisterEvent("CRAFT_UPDATE")

local bankOpen = false
local pendingItemRefresh = false

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
        end
      end
    end
    EnsureDB()
    PrimeItemCache()
    UpdateBags()
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
  elseif event == "GET_ITEM_INFO_RECEIVED" then
    if not pendingItemRefresh then
      pendingItemRefresh = true
      C_Timer.After(0.5, function() pendingItemRefresh = false; RefreshUI() end)
    end
  elseif event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_UPDATE"
      or event == "CRAFT_SHOW"       or event == "CRAFT_UPDATE" then
    -- A small delay gives the client time to populate the recipe list.
    C_Timer.After(0.1, ScanRecipes)
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
  text         = "HelloStock: clear every target stock level?\nThis only wipes the per-item targets; bag/bank snapshots and pairing are unaffected. The empty target list will sync to any paired account.",
  button1      = "Clear",
  button2      = CANCEL,
  OnAccept     = function()
    HelloStockDB = HelloStockDB or {}
    HelloStockDB.targets = {}
    HelloStockDB.targetsUpdatedAt = time()
    if addon.Comm and addon.Comm.SendTargets then addon.Comm:SendTargets() end
    if addon.UI and addon.UI:IsShown() then addon.UI:Refresh() end
    print("|cffffd700HelloStock:|r all targets cleared.")
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
      local pushed, skipped = {}, {}
      local myFaction = MyFaction()
      local myID      = addon:GetAccountID()
      local realmSet  = addon:ConnectedRealmSet()
      for _, c in pairs(HelloStockDB and HelloStockDB.characters or {}) do
        if c.accountID == myID and c.name and c.name ~= "" and c.realm and c.realm ~= "" then
          if c.faction ~= myFaction then
            skipped[#skipped + 1] = ("%s-%s: %s != my %s"):format(c.name, c.realm, c.faction or "?", myFaction)
          elseif not realmSet[addon:NormalizeRealm(c.realm)] then
            skipped[#skipped + 1] = ("%s-%s: realm not in connected cluster"):format(c.name, c.realm)
          else
            pushed[#pushed + 1] = c.name .. "-" .. c.realm
          end
        end
      end
      addon.Comm:SendSnapshot(true)
      print(("|cffffd700HelloStock:|r pushing %d chars: %s"):format(#pushed, table.concat(pushed, ", ")))
      if #skipped > 0 then
        print(("|cffaa3333  skipped %d (own chars not eligible to broadcast in this session):|r"):format(#skipped))
        for _, s in ipairs(skipped) do print("    " .. s) end
      end
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
      end
      if removed == 0 then
        print("|cffffd700HelloStock:|r no character named '" .. rest .. "' in the DB.")
      else
        RefreshUI()
      end
    end

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
    print("|cffffd700HelloStock:|r commands: /hs, /hs pair [name], /hs secret [word], /hs unpair, /hs sync, /hs status, /hs whoami, /hs chars, /hs claim <name>, /hs claimall, /hs forget <name>, /hs debug, /hs config, /hs ping, /hs resetpos, /hs minimap, /hs gather, /hs cleartargets, /hs reset")
  end
end
