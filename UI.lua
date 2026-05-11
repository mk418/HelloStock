local _, addon = ...

local function TargetsStore()
  HelloStockDB = HelloStockDB or {}
  HelloStockDB.targets = HelloStockDB.targets or {}
  return HelloStockDB.targets
end

local function GetTarget(itemID)
  return TargetsStore()[itemID]
end

local targetsSendPending = false
local function SetTarget(itemID, val)
  local store = TargetsStore()
  if val and val > 0 then
    store[itemID] = val
  else
    store[itemID] = nil
  end
  HelloStockDB.targetsUpdatedAt = time()
  if addon.Comm and addon.Comm.SendTargets and not targetsSendPending then
    targetsSendPending = true
    C_Timer.After(2, function()
      targetsSendPending = false
      addon.Comm:SendTargets()
    end)
  end
end

local UI = CreateFrame("Frame", "HelloStockFrame", UIParent, "BasicFrameTemplateWithInset")
UI:SetSize(380, 520)
UI:SetPoint("CENTER")
UI:SetMovable(true)
UI:EnableMouse(true)
UI:RegisterForDrag("LeftButton")
UI:SetScript("OnDragStart", UI.StartMoving)
UI:SetScript("OnDragStop", UI.StopMovingOrSizing)
UI:SetClampedToScreen(true)
UI:SetFrameStrata("HIGH")
UI:SetScript("OnMouseDown", function(self) self:Raise() end)
UI:Hide()

UI.TitleText:SetText("HelloStock")

local currentTab = "Ingredients"

local function MakeTab(label, anchor)
  local b = CreateFrame("Button", nil, UI, "UIPanelButtonTemplate")
  b:SetSize(120, 22)
  b:SetText(label)
  if anchor then
    b:SetPoint("LEFT", anchor, "RIGHT", 4, 0)
  else
    b:SetPoint("TOPLEFT", 10, -28)
  end
  b:SetScript("OnClick", function()
    UI:ClearAllFocus()
    currentTab = label
    UI:Refresh()
  end)
  return b
end

local tabIng  = MakeTab("Ingredients", nil)
local tabCons = MakeTab("Consumables", tabIng)

local syncBtn = CreateFrame("Button", nil, UI, "UIPanelButtonTemplate")
syncBtn:SetSize(80, 22)
syncBtn:SetPoint("TOPRIGHT", -8, -28)
syncBtn:SetText("Sync")
syncBtn:Hide()
syncBtn:SetScript("OnClick", function()
  UI:ClearAllFocus()
  local targets = addon.GetWhisperTargets and addon:GetWhisperTargets() or {}
  if #targets == 0 then
    print("|cffffd700HelloStock:|r no paired characters known — pair via /hs pair first.")
    return
  end
  if addon.Comm and addon.Comm.SendSnapshot then
    addon.Comm:SendSnapshot(true)
    print("|cffffd700HelloStock:|r snapshot pushed.")
  end
end)

local searchQuery = ""
local targetsOnly = false
local inStockOnly = false

local search = CreateFrame("EditBox", "HelloStockSearch", UI, "InputBoxTemplate")
search:SetSize(140, 20)
search:SetPoint("TOPLEFT", 18, -58)
search:SetAutoFocus(false)
search:SetMaxLetters(40)
search:SetScript("OnTextChanged", function(self)
  searchQuery = (self:GetText() or ""):lower()
  UI:Refresh()
end)
search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
search:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

local searchLabel = search:CreateFontString(nil, "OVERLAY", "GameFontDisable")
searchLabel:SetPoint("LEFT", search, "LEFT", 4, 0)
searchLabel:SetText("Search items...")
search:HookScript("OnTextChanged", function(self)
  searchLabel:SetShown((self:GetText() or "") == "")
end)
search:HookScript("OnEditFocusGained", function() searchLabel:Hide() end)
search:HookScript("OnEditFocusLost", function(self)
  searchLabel:SetShown((self:GetText() or "") == "")
end)

local searchClear = CreateFrame("Button", nil, search, "UIPanelCloseButton")
searchClear:SetSize(20, 20)
searchClear:SetPoint("LEFT", search, "RIGHT", -2, 0)
searchClear:SetScript("OnClick", function()
  UI:ClearAllFocus()
  search:SetText("")
end)

local function MakeFilterCheck(name, label, anchor, onClick)
  local cb = CreateFrame("CheckButton", name, UI, "UICheckButtonTemplate")
  cb:SetPoint("LEFT", anchor, "RIGHT", 4, 0)
  cb:SetSize(22, 22)
  local lbl = _G[name .. "Text"]
  if not lbl then
    lbl = cb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("LEFT", cb, "RIGHT", 0, 1)
  end
  lbl:SetText(label)
  cb:SetScript("OnClick", function(self, ...)
    UI:ClearAllFocus()
    onClick(self, ...)
  end)
  return cb
end

local stockCheck = MakeFilterCheck("HelloStockStockCheck", "In stock", searchClear, function(self)
  inStockOnly = self:GetChecked() and true or false
  UI:Refresh()
end)

local targetsCheck = MakeFilterCheck("HelloStockTargetsCheck", "With target", stockCheck, function(self)
  targetsOnly = self:GetChecked() and true or false
  UI:Refresh()
end)
-- Push the second checkbox past the first one's label so they don't overlap.
targetsCheck:ClearAllPoints()
targetsCheck:SetPoint("LEFT", _G["HelloStockStockCheckText"] or stockCheck, "RIGHT", 6, 0)

local scroll = CreateFrame("ScrollFrame", "HelloStockScroll", UI, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 10, -84)
scroll:SetPoint("BOTTOMRIGHT", -30, 10)

local content = CreateFrame("Frame", nil, scroll)
content:SetSize(330, 1)
scroll:SetScrollChild(content)

local rowPool, headerPool = {}, {}

function UI:ClearAllFocus()
  if search and search:HasFocus() then search:ClearFocus() end
  for _, r in ipairs(rowPool) do
    if r.targetBox and r.targetBox:HasFocus() then
      r.targetBox:ClearFocus()
    end
  end
end

local function MakeRow(i)
  if rowPool[i] then return rowPool[i] end
  local row = CreateFrame("Frame", nil, content)
  row:SetSize(330, 20)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(16, 16)
  row.icon:SetPoint("LEFT", 4, 0)
  row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.name:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
  row.name:SetPoint("RIGHT", row, "RIGHT", -115, 0)
  row.name:SetJustifyH("LEFT")
  row.name:SetWordWrap(false)
  row.count = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  row.count:SetPoint("RIGHT", row, "RIGHT", -76, 0)
  row.count:SetWidth(34)
  row.count:SetJustifyH("RIGHT")

  row.targetBox = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
  row.targetBox:SetSize(46, 20)
  row.targetBox:SetPoint("RIGHT", row, "RIGHT", -16, 0)
  row.targetBox:SetAutoFocus(false)
  row.targetBox:SetNumeric(true)
  row.targetBox:SetMaxLetters(6)
  row.targetBox:SetJustifyH("RIGHT")
  row.targetBox:SetTextInsets(4, 4, 0, 0)
  row.targetBox:EnableMouse(true)
  row.targetBox:SetFrameLevel(row:GetFrameLevel() + 5)
  row.targetBox:SetScript("OnMouseDown", function(self) self:SetFocus() end)
  row.targetBox:SetScript("OnEditFocusGained", function(self)
    -- Defer one frame so WoW's internal cursor-positioning (which runs after
    -- this event) can't clobber our selection.
    C_Timer.After(0, function() self:HighlightText(0, -1) end)
  end)
  row.targetBox:SetScript("OnTextChanged", function(self, userInput)
    if not userInput or not self.itemID then return end
    SetTarget(self.itemID, tonumber(self:GetText()))
    if row.ApplyVisual then row:ApplyVisual() end
  end)
  row.targetBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  row.targetBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  row.targetBox:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
  row.targetBox:SetScript("OnEditFocusLost", function() UI:Refresh() end)

  function row:ApplyVisual()
    if not self.itemID then return end
    local target = GetTarget(self.itemID)
    local total  = addon:GetTotals(self.itemID)
    if target then
      self.count:SetText(tostring(total))
      if total >= target then
        self.count:SetTextColor(0.4, 1, 0.4)
      else
        self.count:SetTextColor(1, 0.3, 0.3)
      end
      self.name:SetAlpha(1)
      self.icon:SetAlpha(1)
    elseif total > 0 then
      self.count:SetText(tostring(total))
      self.count:SetTextColor(1, 1, 1)
      self.name:SetAlpha(1)
      self.icon:SetAlpha(1)
    else
      self.count:SetText("-")
      self.count:SetTextColor(0.5, 0.5, 0.5)
      self.name:SetAlpha(0.55)
      self.icon:SetAlpha(0.45)
    end
  end

  row:EnableMouse(true)
  row:SetScript("OnEnter", function(self)
    if not self.itemID then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink("item:" .. self.itemID)
    local total, breakdown = addon:GetTotals(self.itemID)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Stockpile (" .. total .. " total):", 1, 0.82, 0)
    if #breakdown == 0 then
      GameTooltip:AddLine("  none on any character", 0.6, 0.6, 0.6)
    else
      for _, b in ipairs(breakdown) do
        GameTooltip:AddDoubleLine("  " .. b.name, b.count, 1, 1, 1, 1, 1, 1)
      end
    end
    GameTooltip:Show()
  end)
  row:SetScript("OnLeave", function() GameTooltip:Hide() end)
  rowPool[i] = row
  return row
end

local function CollapseStore()
  HelloStockDB = HelloStockDB or {}
  HelloStockDB.ui = HelloStockDB.ui or {}
  HelloStockDB.ui.collapsed = HelloStockDB.ui.collapsed or {}
  return HelloStockDB.ui.collapsed
end

local function CategoryKey(tab, category)
  return tab .. "/" .. category
end

local function IsCollapsed(tab, category)
  return CollapseStore()[CategoryKey(tab, category)] == true
end

local function ToggleCollapsed(tab, category)
  local store = CollapseStore()
  local k = CategoryKey(tab, category)
  store[k] = not store[k] or nil
end

local function MakeHeader(i)
  if headerPool[i] then return headerPool[i] end
  local h = CreateFrame("Button", nil, content)
  h:SetSize(330, 22)
  h.arrow = h:CreateTexture(nil, "OVERLAY")
  h.arrow:SetSize(14, 14)
  h.arrow:SetPoint("LEFT", 2, 0)
  h.text = h:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  h.text:SetPoint("LEFT", h.arrow, "RIGHT", 4, 0)
  h.text:SetTextColor(1, 0.82, 0)

  h.stockLabel = h:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  h.stockLabel:SetPoint("RIGHT", h, "RIGHT", -76, 0)
  h.stockLabel:SetText("Stock")
  h.stockLabel:SetTextColor(0.85, 0.75, 0.5)

  h.targetLabel = h:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  h.targetLabel:SetPoint("RIGHT", h, "RIGHT", -16, 0)
  h.targetLabel:SetText("Target")
  h.targetLabel:SetTextColor(0.85, 0.75, 0.5)

  h.line = h:CreateTexture(nil, "BACKGROUND")
  h.line:SetColorTexture(1, 1, 1, 0.08)
  h.line:SetPoint("BOTTOMLEFT", 0, 0)
  h.line:SetPoint("BOTTOMRIGHT", 0, 0)
  h.line:SetHeight(1)
  h:SetScript("OnClick", function(self)
    UI:ClearAllFocus()
    if self.category then
      ToggleCollapsed(currentTab, self.category)
      UI:Refresh()
    end
  end)
  h:SetScript("OnEnter", function(self) self.text:SetTextColor(1, 1, 1) end)
  h:SetScript("OnLeave", function(self) self.text:SetTextColor(1, 0.82, 0) end)
  headerPool[i] = h
  return h
end

function UI:Refresh()
  syncBtn:SetShown(addon.GetSecret and addon:GetSecret() ~= nil)

  -- Defer refresh if the user is actively editing a target box. Hiding rows
  -- during the refresh would steal keyboard focus and route keys to the action
  -- bar (i.e. cast spells when typing numbers).
  for _, r in ipairs(rowPool) do
    if r.targetBox and r.targetBox:HasFocus() then return end
  end

  for _, r in ipairs(rowPool)    do r:Hide() end
  for _, h in ipairs(headerPool) do h:Hide() end

  local section = addon.DEFAULT_ITEMS[currentTab]
  if not section then return end

  local searching = searchQuery ~= ""
  local y, rIdx, hIdx = 0, 0, 0
  for _, group in ipairs(section) do
    local headerY   = y
    local h         = MakeHeader(hIdx + 1)
    local groupHit  = false
    local collapsed = IsCollapsed(currentTab, group.category) and not searching

    y = y + 22

    for _, item in ipairs(group.items) do
      local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(item.id)
      local displayName = name or item.name or ""
      local target = GetTarget(item.id)
      local total = addon:GetTotals(item.id)

      local matchSearch = not searching or displayName:lower():find(searchQuery, 1, true)
      local matchTarget = not targetsOnly or target ~= nil
      local matchStock  = not inStockOnly or total > 0

      if matchSearch and matchTarget and matchStock then
        groupHit = true
        if not collapsed then
          rIdx = rIdx + 1
          local row = MakeRow(rIdx)
          row.itemID = item.id
          row.icon:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark")
          row.name:SetText(link or name or item.name)

          row.targetBox.itemID = item.id
          local boxText = target and tostring(target) or ""
          if not row.targetBox:HasFocus() and row.targetBox:GetText() ~= boxText then
            row.targetBox:SetText(boxText)
          end

          row:ApplyVisual()

          row:ClearAllPoints()
          row:SetPoint("TOPLEFT", 0, -y)
          row:Show()
          y = y + 20
        end
      end
    end

    if groupHit then
      hIdx = hIdx + 1
      h.category = group.category
      h.arrow:SetTexture(collapsed
        and "Interface\\Buttons\\UI-PlusButton-Up"
        or  "Interface\\Buttons\\UI-MinusButton-Up")
      h.arrow:Show()
      h.stockLabel:Show()
      h.targetLabel:Show()
      h.text:SetTextColor(1, 0.82, 0)
      h.text:SetText(group.category)
      h:ClearAllPoints()
      h:SetPoint("TOPLEFT", 0, -headerY)
      h:Show()
      y = y + 8
    else
      y = headerY
    end
  end

  if rIdx == 0 and searching then
    hIdx = hIdx + 1
    local h = MakeHeader(hIdx)
    h.category = nil
    h.arrow:Hide()
    h.stockLabel:Hide()
    h.targetLabel:Hide()
    h.text:SetText("No matches")
    h.text:SetTextColor(0.6, 0.6, 0.6)
    h:ClearAllPoints()
    h:SetPoint("TOPLEFT", 0, -8)
    h:Show()
    y = 30
  end

  content:SetHeight(math.max(y, 1))
end

function UI:Toggle()
  if self:IsShown() then self:Hide() else self:Show() end
end

UI:SetScript("OnShow", function(self) self:Refresh() end)

addon.UI = UI

