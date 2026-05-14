local _, addon = ...

local KIND_LABEL = {
  herb       = "Herb",
  mine       = "Mine",
  skin       = "Skin",
  fish       = "Fish",
  mob        = "Mob",
  dungeon    = "Dungeon",
  vendor     = "Vendor",
  disenchant = "Disenchant",
  craft      = "Craft",
  quest      = "Quest",
}

-- Returns true if the tooltip's current line list already contains our
-- "Stockpile (N total):" header. We scan rather than using a remembered flag
-- because GameTooltip can clear + rebuild its body mid-hover (item info
-- streaming in, other tooltip addons forcing a redraw, etc.) — a stale flag
-- would block re-adding the section after it was wiped.
local function HasStockpileSection(tooltip)
  local name = tooltip and tooltip.GetName and tooltip:GetName()
  if not name then return false end
  for i = 1, tooltip:NumLines() do
    local fs = _G[name .. "TextLeft" .. i]
    local text = fs and fs:GetText()
    if text and text:find("^Stockpile %(") then return true end
  end
  return false
end

local function AppendStockpile(tooltip)
  if not tooltip or not tooltip.GetItem then return end
  local _, link = tooltip:GetItem()
  if not link then return end
  local itemID = tonumber(link:match("item:(%d+)"))
  if not itemID or not addon:IsTracked(itemID) then return end
  if HasStockpileSection(tooltip) then return end

  local total, breakdown = addon:GetTotals(itemID)
  local bound = addon.IsBoP and addon:IsBoP(itemID)
  tooltip:AddLine(" ")
  tooltip:AddLine(
    ("Stockpile (%d total%s):"):format(total, bound and ", bound to character" or ""),
    1, 0.82, 0)
  if #breakdown == 0 then
    tooltip:AddLine("  none on any character", 0.6, 0.6, 0.6)
  else
    for _, b in ipairs(breakdown) do
      local r, g, bl = 1, 1, 1
      if not b.isMine then r, g, bl = 0.6, 0.6, 0.6 end
      local right = tostring(b.count)
      if b.transit and b.transit > 0 then
        right = right .. (" |cffd8b66f(%d in transit)|r"):format(b.transit)
      end
      if b.mail and b.mail > 0 then
        right = right .. (" |cff88aaee(%d in mail)|r"):format(b.mail)
      end
      tooltip:AddDoubleLine("  " .. b.name, right, r, g, bl, 1, 1, 1)
    end
  end

  -- "Sources:" — where the item can be obtained in the world (curated in
  -- Items.lua per leaf item). Entries are sorted so same-kind sources are
  -- contiguous; we emit one "<Kind>:" sub-header per group and indent the
  -- zone lines beneath it. By default we show only zone + level range;
  -- holding SHIFT expands each line with the mob list and drop chances.
  -- The modifier-state listener at the bottom of this file re-fires this
  -- function via SetHyperlink when SHIFT toggles so the tooltip updates
  -- live while it's open.
  local sources = addon.GetSources and addon:GetSources(itemID)
  if sources and #sources > 0 then
    local expand = IsShiftKeyDown()
    local anyMobs = false
    tooltip:AddLine(" ")
    tooltip:AddLine("Sources:", 1, 0.82, 0)
    local lastKind = nil
    for _, s in ipairs(sources) do
      if s.kind ~= lastKind then
        local kind = KIND_LABEL[s.kind] or s.kind or "?"
        tooltip:AddLine("  " .. kind .. ":", 1, 0.82, 0)
        lastKind = s.kind
      end
      local line = "    " .. (s.zone or "?")
      if s.levels then line = line .. " (" .. s.levels .. ")" end
      if s.mobs and #s.mobs > 0 then
        anyMobs = true
        if expand then
          local parts = {}
          for _, m in ipairs(s.mobs) do
            if m.chance then
              parts[#parts + 1] = ("%s (%s%%)"):format(m.name or "?", tostring(m.chance))
            else
              parts[#parts + 1] = m.name or "?"
            end
          end
          line = line .. " \226\128\148 " .. table.concat(parts, ", ")
        elseif s.spawn_count then
          -- Density + yield hint for mob/dungeon entries: approximate
          -- number of dropping mobs spawned in this zone at any time
          -- (summed from server-side spawn rows), plus the spawn-weighted
          -- average drop chance across those mobs. Lets the player size
          -- up a farming spot without expanding the mob list.
          local plural = s.spawn_count == 1 and "" or "s"
          if s.avg_chance then
            line = line .. (" \226\128\148 ~%d mob%s (avg %s%%)"):format(
              s.spawn_count, plural, tostring(s.avg_chance))
          else
            line = line .. (" \226\128\148 ~%d mob%s"):format(
              s.spawn_count, plural)
          end
        end
      elseif s.spawn_count then
        -- Node density + yield for herb / mine entries (no mob list).
        local plural = s.spawn_count == 1 and "" or "s"
        if s.avg_yield then
          line = line .. (" \226\128\148 ~%d node%s (%s/node)"):format(
            s.spawn_count, plural, tostring(s.avg_yield))
        else
          line = line .. (" \226\128\148 ~%d node%s"):format(s.spawn_count, plural)
        end
      end
      tooltip:AddLine(line, 1, 1, 1)
    end
    if anyMobs and not expand then
      tooltip:AddLine("  <Hold SHIFT for mob details>", 0.5, 0.5, 0.5)
    end
  end

  -- "Can craft:" — characters in scope that know the recipe (data is captured
  -- from the trade-skill / craft windows and synced between paired accounts).
  local crafters = addon.GetCrafters and addon:GetCrafters(itemID)
  if crafters and #crafters > 0 then
    tooltip:AddLine(" ")
    tooltip:AddLine("Can craft:", 1, 0.82, 0)
    for _, x in ipairs(crafters) do
      local r, g, b = 1, 1, 1
      if not x.isMine then r, g, b = 0.6, 0.6, 0.6 end
      tooltip:AddLine("  " .. x.name, r, g, b)
    end
  end

  -- "Made from:" — only set on craftable buff items in Items.lua.
  local recipe = addon.GetRecipe and addon:GetRecipe(itemID)
  if recipe and #recipe > 0 then
    tooltip:AddLine(" ")
    local yield = recipe.yield or 1
    local header = yield > 1 and ("Made from (yields %d):"):format(yield) or "Made from:"
    tooltip:AddLine(header, 1, 0.82, 0)
    for _, ing in ipairs(recipe) do
      local ingName = GetItemInfo(ing.id) or ("Item " .. ing.id)
      tooltip:AddDoubleLine("  " .. ingName, ing.count, 1, 1, 1, 1, 1, 1)
    end
  end

  -- "Needed for:" — buffs in Items.lua that (a) use this id as an ingredient
  -- and (b) are currently in the craft list (target unmet, has a recipe).
  -- Items we're not actively trying to craft are omitted; if nothing in our
  -- to-craft list needs this ingredient, the section doesn't render at all.
  local usedIn = addon.GetUsedIn and addon:GetUsedIn(itemID)
  if usedIn and #usedIn > 0 and addon.GetCraftSet then
    local craftSet = addon:GetCraftSet()
    local needed = {}
    for _, buffID in ipairs(usedIn) do
      if craftSet[buffID] then
        needed[#needed + 1] = buffID
      end
    end
    if #needed > 0 then
      tooltip:AddLine(" ")
      tooltip:AddLine("Needed for:", 1, 0.82, 0)
      for _, buffID in ipairs(needed) do
        local buffName = GetItemInfo(buffID) or ("Item " .. buffID)
        tooltip:AddLine("  " .. buffName, 1, 1, 1)
      end
    end
  end

  tooltip:Show()  -- recompute size after our appends
end

for _, tt in ipairs({ GameTooltip, ItemRefTooltip }) do
  if tt then tt:HookScript("OnTooltipSetItem", AppendStockpile) end
end

-- Refresh any open tracked-item tooltip when SHIFT presses/releases so the
-- Sources section toggles between collapsed and expanded without the user
-- having to re-hover. The mechanism differs by tooltip type:
--   GameTooltip is typically anchored to a bag slot, inventory slot,
--   merchant item, etc. SetHyperlink clobbers that anchor context, which
--   leads to Blizzard's UI hiding the tooltip. Calling the owner's OnEnter
--   handler instead rebuilds the tooltip in its proper context — OnEnter
--   knows how to call SetBagItem / SetInventoryItem / etc with the right
--   arguments. AppendStockpile then re-runs via OnTooltipSetItem with the
--   current SHIFT state.
--   ItemRefTooltip is the standalone chat-link popup with no owning frame,
--   so SetHyperlink is both safe and correct there.
local function RefreshOnShift(tt)
  if not (tt and tt:IsShown()) then return end
  local _, link = tt:GetItem()
  local itemID = link and tonumber(link:match("item:(%d+)"))
  if not (itemID and addon:IsTracked(itemID)) then return end
  local owner = tt:GetOwner()
  if owner and owner ~= UIParent and owner.GetScript then
    local onEnter = owner:GetScript("OnEnter")
    if onEnter then onEnter(owner) end
  elseif tt == ItemRefTooltip then
    tt:SetHyperlink(link)
  end
end

local modFrame = CreateFrame("Frame")
modFrame:RegisterEvent("MODIFIER_STATE_CHANGED")
modFrame:SetScript("OnEvent", function(_, _, key)
  if key ~= "LSHIFT" and key ~= "RSHIFT" then return end
  RefreshOnShift(GameTooltip)
  RefreshOnShift(ItemRefTooltip)
end)
