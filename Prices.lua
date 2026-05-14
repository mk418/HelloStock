local _, addon = ...

-- Phase 1 of the market-price integration (see DESIGN.md → Market-price
-- integration). Wraps Auctionator's public v1 API, maintains a small
-- per-cluster ring buffer of observed prices so we can report a robust
-- "typical" (median) alongside the current value, and times each sample
-- to Auctionator's actual scan event for accurate freshness reporting.
-- The integration is optional — every call gracefully returns nil when
-- Auctionator isn't installed or hasn't seen the item.

local RING_SIZE = 10  -- per-item history depth; ~10 samples is enough to
                      -- smooth Auctionator's lowest-currently-listed noise
                      -- without bloating SavedVariables for ~100 items.

-- Resolve Auctionator's public v1 API table. Looked up lazily on each
-- call because Auctionator's load timing can vary (OptionalDeps load
-- before us when installed, but the API table is populated during their
-- own init), and so the user enabling/disabling the addon between
-- sessions doesn't require a /reload to take effect.
local function API()
  if not (Auctionator and Auctionator.API and Auctionator.API.v1) then return nil end
  return Auctionator.API.v1
end

-- Compact margin string + colour triple for a craft margin. Used by
-- the by-character "Margin" column and the tooltip "Craft margin"
-- line so both surfaces format the same way. Rounds to a single unit
-- (silver under a gold, gold otherwise) — sub-gold precision isn't
-- useful for a "worth it?" decision. Appends "/cd" when the recipe is
-- cooldown-gated so cycle margins read distinct from per-craft ones.
function addon:FormatMargin(copper, hasCooldown)
  if not copper then return nil end
  local abs = math.abs(copper)
  local body
  if abs < 100 then
    body = "0"
  elseif abs < 10000 then
    body = ("%ds"):format(math.floor(abs / 100 + 0.5))
  else
    body = ("%dg"):format(math.floor(abs / 10000 + 0.5))
  end
  local prefix = copper >= 0 and "+" or "\226\136\146"  -- "−"
  if hasCooldown then body = body .. "/cd" end
  if copper >= 0 then
    return prefix .. body, 0.4, 1, 0.4
  else
    return prefix .. body, 1, 0.4, 0.4
  end
end

-- "8g 50s 25c" with the smallest non-zero unit always shown. Returns "—"
-- for nil/0 so display callers don't need a guard. Used by every price
-- display site (tooltip line, by-zone g/hr column, by-character margin).
-- UI.lua has its own elaborate `FormatGold` for the wallet footer that
-- renders coin-coloured g/s/c always; this version is the compact
-- right-hand-column flavour.
function addon:FormatPrice(copper)
  if not copper or copper <= 0 then return "\226\128\148" end
  copper = math.floor(copper + 0.5)
  local g = math.floor(copper / 10000)
  local s = math.floor((copper % 10000) / 100)
  local c = copper % 100
  if g > 0 then
    if s > 0 then return ("%dg %ds"):format(g, s) end
    return ("%dg"):format(g)
  elseif s > 0 then
    if c > 0 then return ("%ds %dc"):format(s, c) end
    return ("%ds"):format(s)
  end
  return ("%dc"):format(c)
end

-- Per-scope bucket for price history. Scoped on faction + connected-realm
-- cluster (addon:ScopeKey, the same key targets and stockpile aggregation
-- already use). Classic Era connected realms share an auction house, so
-- any cluster character's observations populate the same history.
local function PricesBucket()
  HelloStockDB = HelloStockDB or {}
  HelloStockDB.prices = HelloStockDB.prices or {}
  local key = addon:ScopeKey()
  HelloStockDB.prices[key] = HelloStockDB.prices[key] or {}
  return HelloStockDB.prices[key]
end

local function Median(arr)
  local n = #arr
  if n == 0 then return nil end
  local sorted = {}
  for i = 1, n do sorted[i] = arr[i] end
  table.sort(sorted)
  if n % 2 == 1 then return sorted[(n + 1) / 2] end
  return (sorted[n / 2] + sorted[n / 2 + 1]) / 2
end

-- Current AH price observation in copper, via Auctionator. Returns nil
-- when Auctionator isn't loaded, the API surface isn't present, or the
-- item simply hasn't been seen on the AH. Price 0 is treated as no-data
-- since it would only show up as a sentinel from a broken scanner.
function addon:GetMarketPrice(itemID)
  local api = API()
  if not api or not api.GetAuctionPriceByItemID then return nil end
  local p = api.GetAuctionPriceByItemID("HelloStock", itemID)
  if not p or p <= 0 then return nil end
  return p
end

-- Vendor cost for items the player can buy directly (Crystal Vials,
-- Imbued Vials, etc.). Used inside recursive ingredient-cost math so
-- those reagents don't get the AH median treatment.
function addon:GetVendorPrice(itemID)
  local api = API()
  if not api or not api.GetVendorPriceByItemID then return nil end
  local p = api.GetVendorPriceByItemID("HelloStock", itemID)
  if not p or p <= 0 then return nil end
  return p
end

-- The read API consumed by every price display site. Returns nil when
-- there's no signal at all (no Auctionator, no history, no current).
-- Otherwise:
--   current  → most recent live read (or last buffered value)
--   median   → robust headline used for "typical 11g"
--   newestTs → time() at the most recent scan; nil if pre-history first
--              session. Display sites use this for "last scanned 2h ago"
--   samples  → ring buffer depth, for "single observation" debug uses
function addon:GetMarketPriceTypical(itemID)
  local bucket = PricesBucket()
  local hist   = bucket[itemID]
  local current = self:GetMarketPrice(itemID)
  if not hist or #hist == 0 then
    if not current then return nil end
    return { current = current, median = current, newestTs = nil, samples = 0 }
  end
  local prices, newestTs = {}, 0
  for _, e in ipairs(hist) do
    prices[#prices + 1] = e.price
    if e.ts and e.ts > newestTs then newestTs = e.ts end
  end
  return {
    current  = current or hist[#hist].price,  -- fall back to last buffered
    median   = Median(prices),
    newestTs = newestTs > 0 and newestTs or nil,
    samples  = #prices,
  }
end

-- Walk the tracked-item set and append a fresh entry for each item whose
-- current price differs from the last stored sample. Called from
-- Auctionator's DB-update callback so the ts on each entry is "Auctionator
-- scanned at T" — the v1 API doesn't expose scan time directly on the
-- price queries, but RegisterForDBUpdate effectively gives it to us by
-- firing at the moment of update.
local function SamplePrices()
  if not addon.ITEMS then return end
  local bucket = PricesBucket()
  local now = time()
  for _, section in pairs(addon.ITEMS) do
    for _, group in ipairs(section) do
      for _, item in ipairs(group.items) do
        local id = item.id
        if id then
          local price = addon:GetMarketPrice(id)
          if price then
            local hist = bucket[id]
            if not hist then
              hist = {}
              bucket[id] = hist
            end
            local last = hist[#hist]
            if not last or last.price ~= price then
              hist[#hist + 1] = { price = price, ts = now }
              while #hist > RING_SIZE do
                table.remove(hist, 1)
              end
            end
          end
        end
      end
    end
  end
end

-- Register our callback with Auctionator once both addons are up. The
-- TOC's OptionalDeps line loads Auctionator before us when installed,
-- so the API table is available by PLAYER_LOGIN. We also take one
-- immediate sample so existing pre-installed scan data shows up in the
-- ring buffer right away (newestTs reflects "we noticed at T" for that
-- first read; later scans get true update-time stamps).
local function RegisterWithAuctionator()
  local api = API()
  if not api or not api.RegisterForDBUpdate then return end
  api.RegisterForDBUpdate("HelloStock", SamplePrices)
  SamplePrices()
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function() RegisterWithAuctionator() end)
