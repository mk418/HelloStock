local _, addon = ...

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

  -- "Used in:" — reverse lookup: which buffs in Items.lua reference this id as an ingredient.
  local usedIn = addon.GetUsedIn and addon:GetUsedIn(itemID)
  if usedIn and #usedIn > 0 then
    tooltip:AddLine(" ")
    tooltip:AddLine("Used in:", 1, 0.82, 0)
    for _, buffID in ipairs(usedIn) do
      local buffName = GetItemInfo(buffID) or ("Item " .. buffID)
      tooltip:AddLine("  " .. buffName, 1, 1, 1)
    end
  end

  tooltip:Show()  -- recompute size after our appends
end

for _, tt in ipairs({ GameTooltip, ItemRefTooltip }) do
  if tt then tt:HookScript("OnTooltipSetItem", AppendStockpile) end
end
