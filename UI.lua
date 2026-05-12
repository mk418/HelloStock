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
UI:SetSize(560, 520)
UI:SetMovable(true)
UI:EnableMouse(true)
UI:RegisterForDrag("LeftButton")
UI:SetClampedToScreen(true)
UI:SetFrameStrata("HIGH")
UI:SetScript("OnMouseDown", function(self) self:Raise() end)
-- Opt out of WoW's per-character layout-cache (layout-local.txt). Position is
-- managed by us via HelloStockDB.ui.point so it lives per-account instead.
UI:SetUserPlaced(false)

local function UIStore()
  HelloStockDB = HelloStockDB or {}
  HelloStockDB.ui = HelloStockDB.ui or {}
  return HelloStockDB.ui
end

local function RestoreUIPosition()
  UI:ClearAllPoints()
  local p = UIStore().point
  if p and p.point then
    UI:SetPoint(p.point, UIParent, p.relPoint or p.point, p.x or 0, p.y or 0)
  else
    UI:SetPoint("RIGHT", UIParent, "RIGHT", -20, 0)
  end
end

local function SaveUIPosition()
  local point, _, relPoint, x, y = UI:GetPoint(1)
  if point then
    UIStore().point = { point = point, relPoint = relPoint, x = x, y = y }
  end
end

UI:SetScript("OnDragStart", UI.StartMoving)
UI:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  self:SetUserPlaced(false)
  SaveUIPosition()
end)

function UI:ResetPosition()
  UIStore().point = nil
  RestoreUIPosition()
  self:SetUserPlaced(false)
end

RestoreUIPosition()
UI:Hide()

UI.TitleText:SetText("HelloStock")

local currentTab = "Consumables"

local function MakeTab(label, anchor)
  local b = CreateFrame("Button", nil, UI, "UIPanelButtonTemplate")
  b:SetSize(108, 22)
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

local tabCons   = MakeTab("Consumables", nil)
local tabIng    = MakeTab("Ingredients", tabCons)
local tabGather = MakeTab("To gather", tabIng)
local tabCraft  = MakeTab("To craft", tabGather)

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

-- Disable the button while a sync (outbound packets queued or inbound chunks
-- reassembling) is in flight. OnUpdate only fires while the button is shown,
-- and it's shown only when paired, so this is otherwise cheap.
local _syncBtnTick = 0
syncBtn:SetScript("OnUpdate", function(self, elapsed)
  _syncBtnTick = _syncBtnTick + elapsed
  if _syncBtnTick < 0.25 then return end
  _syncBtnTick = 0
  local busy = addon.Comm and addon.Comm.IsBusy and addon.Comm:IsBusy()
  if busy then self:Disable() else self:Enable() end
end)

-- Tooltip explaining why the button is greyed out. Motion scripts on a
-- disabled button only fire if we opt in explicitly.
syncBtn:SetMotionScriptsWhileDisabled(true)
syncBtn:HookScript("OnEnter", function(self)
  if not self:IsEnabled() then
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("Sync in progress…", 1, 1, 1)
    GameTooltip:AddLine("Wait for the current sync to finish before pushing again.", 0.7, 0.7, 0.7, true)
    GameTooltip:Show()
  end
end)
syncBtn:HookScript("OnLeave", function() GameTooltip:Hide() end)

local searchQuery = ""
local targetsOnly = false
local inStockOnly = false
local underTargetOnly = false
local classFilter = nil  -- currently active filter (nil = "All classes", otherwise class name)
local pickedClass = nil  -- last explicit dropdown choice (for the text-click toggle)
local classFilterSource = "picked"  -- "picked" (dropdown / default) or "toggled" (text-clicked to player class)

local CLASSES = {
  "Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior",
}

local function PlayerClass()
  local _, token = UnitClass("player")
  if not token or token == "" then return nil end
  return token:sub(1,1) .. token:sub(2):lower()
end

local function AvailableClasses()
  -- Faction-restricted in Classic Era: Paladin is Alliance-only, Shaman is Horde-only.
  local faction = UnitFactionGroup("player") or "Neutral"
  local out = {}
  for _, cls in ipairs(CLASSES) do
    if cls == "Paladin" and faction ~= "Alliance" then
      -- skip
    elseif cls == "Shaman" and faction ~= "Horde" then
      -- skip
    else
      out[#out + 1] = cls
    end
  end
  return out
end

local function CharStore()
  HelloStockCharDB = HelloStockCharDB or {}
  return HelloStockCharDB
end

local function SaveFilters()
  -- Generic filters are shared across all characters on the account.
  UIStore().filters = {
    inStock     = inStockOnly,
    withTarget  = targetsOnly,
    underTarget = underTargetOnly,
  }
  -- Class filter is per-character: each toon picks the class context that
  -- matches whoever is logged in, not whatever an alt last set.
  local cs = CharStore()
  cs.class       = classFilter
  cs.pickedClass = pickedClass
  cs.classSource = classFilterSource
end

-- Deliberately not loaded here: at file-load time HelloStockDB has not been
-- populated from disk yet, so UIStore().filters reads back nil. We load (and
-- re-apply) lazily from OnShow, by which point SavedVariables are restored.
local function LoadFilters()
  local f = UIStore().filters
  if f then
    inStockOnly     = f.inStock     and true or false
    targetsOnly     = f.withTarget  and true or false
    underTargetOnly = f.underTarget and true or false
  end
  local cs = CharStore()
  classFilter       = cs.class
  pickedClass       = cs.pickedClass
  classFilterSource = cs.classSource or "picked"
end

local search = CreateFrame("EditBox", "HelloStockSearch", UI, "InputBoxTemplate")
search:SetSize(140, 20)
search:SetPoint("TOPLEFT", 38, -58)
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

-- Forward declaration so the "With target" callback can cascade into "Under target".
local underCheck

local stockCheck = MakeFilterCheck("HelloStockStockCheck", "In stock", searchClear, function(self)
  inStockOnly = self:GetChecked() and true or false
  SaveFilters()
  UI:Refresh()
end)

local targetsCheck = MakeFilterCheck("HelloStockTargetsCheck", "With target", stockCheck, function(self)
  targetsOnly = self:GetChecked() and true or false
  -- "Under target" only makes sense when "With target" is on.
  if not targetsOnly and underCheck then
    underCheck:SetChecked(false)
    underTargetOnly = false
  end
  SaveFilters()
  UI:Refresh()
end)
-- Push the second checkbox past the first one's label so they don't overlap.
targetsCheck:ClearAllPoints()
targetsCheck:SetPoint("LEFT", _G["HelloStockStockCheckText"] or stockCheck, "RIGHT", 6, 0)

underCheck = MakeFilterCheck("HelloStockUnderCheck", "Under target", targetsCheck, function(self)
  underTargetOnly = self:GetChecked() and true or false
  if underTargetOnly then
    targetsCheck:SetChecked(true)
    targetsOnly = true
  end
  SaveFilters()
  UI:Refresh()
end)
underCheck:ClearAllPoints()
underCheck:SetPoint("LEFT", _G["HelloStockTargetsCheckText"] or targetsCheck, "RIGHT", 6, 0)

-- Class filter dropdown. Filters items that carry a `classes` field (mostly
-- consumables); items without the field show regardless of selection.
-- Faction-restricted: Paladin only shown to Alliance, Shaman only to Horde.
local classDD = CreateFrame("Frame", "HelloStockClassDD", UI, "UIDropDownMenuTemplate")
classDD:SetPoint("TOPRIGHT", UI, "TOPRIGHT", 0, -52)
UIDropDownMenu_SetWidth(classDD, 80)

local function ClassDD_Init(_, level)
  local info = UIDropDownMenu_CreateInfo()
  info.text     = "All classes"
  info.value    = nil
  info.checked  = (classFilter == nil)
  info.func     = function()
    classFilter       = nil
    pickedClass       = nil
    classFilterSource = "picked"
    UIDropDownMenu_SetSelectedValue(classDD, nil)
    UIDropDownMenu_SetText(classDD, "All classes")
    SaveFilters()
    UI:Refresh()
  end
  UIDropDownMenu_AddButton(info, level)
  for _, cls in ipairs(AvailableClasses()) do
    info = UIDropDownMenu_CreateInfo()
    info.text    = cls
    info.value   = cls
    info.checked = (classFilter == cls)
    info.func    = function(self)
      classFilter       = self.value
      pickedClass       = self.value
      classFilterSource = "picked"
      UIDropDownMenu_SetSelectedValue(classDD, self.value)
      UIDropDownMenu_SetText(classDD, self.value)
      SaveFilters()
      UI:Refresh()
    end
    UIDropDownMenu_AddButton(info, level)
  end
end
UIDropDownMenu_Initialize(classDD, ClassDD_Init)

local function ApplyClassDDText()
  UIDropDownMenu_SetSelectedValue(classDD, classFilter)
  UIDropDownMenu_SetText(classDD, classFilter or "All classes")
end

-- A real Blizzard-styled button that replaces the dropdown when the user
-- toggles to "player class" mode. Click the dropdown's text area to swap to
-- the button; click the button to swap back to the dropdown.
local classToggleBtn = CreateFrame("Button", "HelloStockClassToggleBtn", UI, "UIPanelButtonTemplate")
classToggleBtn:SetSize(100, 25)
classToggleBtn:SetPoint("TOPRIGHT", UI, "TOPRIGHT", -14, -53)
classToggleBtn:SetText("")
classToggleBtn:Hide()

local function ApplyClassWidgetVisibility()
  -- Visible only on Consumables tab; within that, either the dropdown or the
  -- toggle button is shown depending on classFilterSource.
  local onCons = currentTab == "Consumables"
  local toggled = onCons and classFilterSource == "toggled" and classFilter
  classDD:SetShown(onCons and not toggled)
  classToggleBtn:SetShown(toggled and true or false)
  if toggled then classToggleBtn:SetText(classFilter or "") end
end

local _origApplyText = ApplyClassDDText
ApplyClassDDText = function()
  _origApplyText()
  ApplyClassWidgetVisibility()
end

-- Clickable overlay over the dropdown's text area. Clicking swaps to the
-- toggle button (which shows the player's class).
local classDDClickArea = CreateFrame("Button", nil, classDD)
local _classArrow  = _G[classDD:GetName() .. "Button"]
classDDClickArea:SetHeight(20)
classDDClickArea:SetPoint("LEFT", classDD, "LEFT", 20, 0)
if _classArrow then
  classDDClickArea:SetPoint("RIGHT", _classArrow, "LEFT", 0, 0)
else
  classDDClickArea:SetPoint("RIGHT", classDD, "RIGHT", -28, 0)
end
classDDClickArea:RegisterForClicks("LeftButtonUp")
classDDClickArea:SetScript("OnClick", function()
  local me = PlayerClass()
  if not me then return end
  classFilter       = me
  classFilterSource = "toggled"
  classToggleBtn:SetText(me)
  ApplyClassDDText()
  SaveFilters()
  UI:Refresh()
end)

classToggleBtn:SetScript("OnClick", function()
  classFilter       = pickedClass
  classFilterSource = "picked"
  ApplyClassDDText()
  SaveFilters()
  UI:Refresh()
end)

local function ApplyFilterCheckboxes()
  stockCheck:SetChecked(inStockOnly)
  targetsCheck:SetChecked(targetsOnly)
  underCheck:SetChecked(underTargetOnly)
  ApplyClassDDText()
end

local scroll = CreateFrame("ScrollFrame", "HelloStockScroll", UI, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 10, -84)
scroll:SetPoint("BOTTOMRIGHT", -30, 10)

local content = CreateFrame("Frame", nil, scroll)
content:SetSize(520, 1)
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
  row:SetSize(520, 20)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(16, 16)
  row.icon:SetPoint("LEFT", 4, 0)
  -- BoP lock overlay on the bottom-right of the item icon. Shown only for
  -- Binds-on-Pickup items: their per-character stocks can't actually be
  -- pooled, so the row total alone hides that constraint.
  row.boundLock = row:CreateTexture(nil, "OVERLAY")
  row.boundLock:SetSize(10, 10)
  row.boundLock:SetPoint("BOTTOMRIGHT", row.icon, "BOTTOMRIGHT", 3, -3)
  row.boundLock:SetTexture("Interface\\Buttons\\LockButton-Locked-Up")
  row.boundLock:Hide()

  -- "Recipe known" overlay on the top-right of the item icon. Used only on
  -- the "To craft" view to flag rows where at least one character in the
  -- paired-account scope knows the recipe.
  row.recipeKnown = row:CreateTexture(nil, "OVERLAY")
  row.recipeKnown:SetSize(12, 12)
  row.recipeKnown:SetPoint("TOPRIGHT", row.icon, "TOPRIGHT", 4, 4)
  row.recipeKnown:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
  row.recipeKnown:Hide()

  -- L-bracket connector for indented (E'ko-style) rows. The vertical leg fills
  -- the top half of this row, aligned with the parent's (non-indented) icon
  -- column at x=12 (parent icon spans 4..20, center 12). The horizontal leg
  -- runs from there to the indented icon's left edge at x=20. Both hidden
  -- unless the item carries indent=true.
  row.connectorV = row:CreateTexture(nil, "ARTWORK")
  row.connectorV:SetColorTexture(0.5, 0.5, 0.5, 0.7)
  row.connectorV:SetSize(1, 10)
  row.connectorV:SetPoint("CENTER", row, "LEFT", 12, 5)
  row.connectorV:Hide()

  row.connectorH = row:CreateTexture(nil, "ARTWORK")
  row.connectorH:SetColorTexture(0.5, 0.5, 0.5, 0.7)
  row.connectorH:SetSize(8, 1)
  row.connectorH:SetPoint("CENTER", row, "LEFT", 16, 0)
  row.connectorH:Hide()

  -- Separator: a thin centred line, used when an item entry carries
  -- { separator = true } in Items.lua. Visible elements of a normal item row
  -- are hidden when this is shown so the row reads as a divider.
  row.sep = row:CreateTexture(nil, "ARTWORK")
  row.sep:SetColorTexture(0.5, 0.5, 0.5, 0.4)
  row.sep:SetHeight(1)
  row.sep:SetPoint("LEFT",  row, "LEFT",  20, 0)
  row.sep:SetPoint("RIGHT", row, "RIGHT", -20, 0)
  row.sep:Hide()
  row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.name:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
  row.name:SetPoint("RIGHT", row, "RIGHT", -115, 0)
  row.name:SetJustifyH("LEFT")
  row.name:SetWordWrap(false)
  row.count = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  row.count:SetPoint("RIGHT", row, "RIGHT", -76, 0)
  row.count:SetWidth(34)
  row.count:SetJustifyH("RIGHT")

  -- Extra columns used only by the "To gather" tab: Need / Stock / Gather.
  -- Hidden on the regular tabs (where row.count + row.targetBox are used).
  row.gatherNeed = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  row.gatherNeed:SetPoint("RIGHT", row, "RIGHT", -130, 0)
  row.gatherNeed:SetWidth(40)
  row.gatherNeed:SetJustifyH("RIGHT")
  row.gatherNeed:Hide()

  row.gatherStock = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  row.gatherStock:SetPoint("RIGHT", row, "RIGHT", -73, 0)
  row.gatherStock:SetWidth(40)
  row.gatherStock:SetJustifyH("RIGHT")
  row.gatherStock:Hide()

  row.gatherCount = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  row.gatherCount:SetPoint("RIGHT", row, "RIGHT", -16, 0)
  row.gatherCount:SetWidth(40)
  row.gatherCount:SetJustifyH("RIGHT")
  row.gatherCount:Hide()

  -- Hover overlays on the three craft-view numbers. Each shows a tooltip with
  -- the per-row recipe scaled to that number's quantity. Hold SHIFT to
  -- recursively expand sub-recipes down to raw ingredients.
  local function HasSubRecipes(itemID)
    if not addon.GetRecipe then return false end
    local recipe = addon:GetRecipe(itemID)
    if not recipe then return false end
    for _, ing in ipairs(recipe) do
      if addon:GetRecipe(ing.id) then return true end
    end
    return false
  end

  local function ExpandIngredients(itemID, qty, acc)
    local recipe = addon.GetRecipe and addon:GetRecipe(itemID)
    if not recipe then
      acc[itemID] = (acc[itemID] or 0) + qty
      return
    end
    local crafts = math.ceil(qty / (recipe.yield or 1))
    for _, ing in ipairs(recipe) do
      ExpandIngredients(ing.id, ing.count * crafts, acc)
    end
  end

  local function RenderCraftTooltip(hover)
    if not row.itemID then return end
    local qty    = hover.qty or 0
    local recipe = addon.GetRecipe and addon:GetRecipe(row.itemID)
    local subs   = HasSubRecipes(row.itemID)
    local shift  = IsShiftKeyDown()
    local yield  = (recipe and recipe.yield) or 1
    local crafts = math.ceil(qty / yield)

    GameTooltip:SetOwner(hover, "ANCHOR_RIGHT")
    local header = ("Ingredients for %d"):format(qty)
    if yield > 1 then header = header .. (" (%d crafts)"):format(crafts) end
    if shift and subs then header = header .. " (raw)" end
    GameTooltip:AddLine(header .. ":", 1, 0.82, 0)

    if shift and subs then
      local raw = {}
      ExpandIngredients(row.itemID, qty, raw)
      local ids = {}
      for id in pairs(raw) do ids[#ids + 1] = id end
      table.sort(ids, function(a, b)
        return (GetItemInfo(a) or tostring(a)) < (GetItemInfo(b) or tostring(b))
      end)
      for _, id in ipairs(ids) do
        local name = GetItemInfo(id) or ("Item " .. id)
        GameTooltip:AddDoubleLine("  " .. name, raw[id], 1, 1, 1, 1, 1, 1)
      end
    elseif recipe and #recipe > 0 then
      for _, ing in ipairs(recipe) do
        local total = ing.count * crafts
        local name  = GetItemInfo(ing.id) or ("Item " .. ing.id)
        GameTooltip:AddDoubleLine("  " .. name, total, 1, 1, 1, 1, 1, 1)
      end
      if subs then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Hold SHIFT to see raw ingredients.", 1, 0.82, 0)
      end
    else
      GameTooltip:AddLine("  No recipe data.", 0.7, 0.7, 0.7)
    end

    GameTooltip:Show()
  end

  local function MakeCraftHover(fs)
    local f = CreateFrame("Frame", nil, row)
    -- Hover fills the column "cell": full row height vertically, and the
    -- FontString's horizontal extent plus a small bit on each side so the
    -- user can target the whole area, not only the digits.
    f:SetPoint("LEFT",   fs,  "LEFT",   -6, 0)
    f:SetPoint("RIGHT",  fs,  "RIGHT",   6, 0)
    f:SetPoint("TOP",    row, "TOP",     0, 0)
    f:SetPoint("BOTTOM", row, "BOTTOM",  0, 0)
    f:EnableMouse(true)
    f:SetFrameLevel(row:GetFrameLevel() + 5)
    f:Hide()
    f:SetScript("OnEnter", function(self)
      self.isHovered = true
      self.shiftWas  = IsShiftKeyDown()
      RenderCraftTooltip(self)
    end)
    f:SetScript("OnLeave", function(self)
      self.isHovered = false
      GameTooltip:Hide()
    end)
    f:SetScript("OnUpdate", function(self)
      if not self.isHovered then return end
      local now = IsShiftKeyDown()
      if now ~= self.shiftWas then
        self.shiftWas = now
        RenderCraftTooltip(self)
      end
    end)
    return f
  end
  row.needHover  = MakeCraftHover(row.gatherNeed)
  row.stockHover = MakeCraftHover(row.gatherStock)
  row.craftHover = MakeCraftHover(row.gatherCount)

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
    -- Stockpile section is appended by the global OnTooltipSetItem hook in
    -- Tooltip.lua, so bag/vendor/AH/chat-link tooltips show the same info.
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
  h:SetSize(520, 22)
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

  -- Used only on the "To gather" tab. Hidden by default.
  h.gatherMidLabel = h:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  h.gatherMidLabel:SetPoint("RIGHT", h, "RIGHT", -73, 0)
  h.gatherMidLabel:SetText("Stock")
  h.gatherMidLabel:SetTextColor(0.85, 0.75, 0.5)
  h.gatherMidLabel:Hide()

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

-- Toggle-all button: collapses every category in the current tab if any is
-- expanded, otherwise expands all. Categories come from addon.ITEMS so the
-- action works the same on the "To gather" tab (whose visible categories are
-- a subset of the regular tabs').
local function AllCategories()
  local cats, seen = {}, {}
  for _, section in pairs(addon.ITEMS) do
    for _, group in ipairs(section) do
      if not seen[group.category] then
        cats[#cats + 1] = group.category
        seen[group.category] = true
      end
    end
  end
  return cats
end

local toggleAllBtn = CreateFrame("Button", nil, UI)
toggleAllBtn:SetSize(14, 14)
toggleAllBtn:SetPoint("TOPLEFT", 12, -61)
toggleAllBtn:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
toggleAllBtn:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-Down")
toggleAllBtn:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")

local function AnyExpanded()
  for _, cat in ipairs(AllCategories()) do
    if not IsCollapsed(currentTab, cat) then return true end
  end
  return false
end

local function UpdateToggleAllTexture()
  if AnyExpanded() then
    toggleAllBtn:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
    toggleAllBtn:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-Down")
  else
    toggleAllBtn:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
    toggleAllBtn:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-Down")
  end
end

toggleAllBtn:SetScript("OnClick", function()
  UI:ClearAllFocus()
  local tab  = currentTab
  local cats = AllCategories()
  local collapse = AnyExpanded()
  local store    = CollapseStore()
  for _, cat in ipairs(cats) do
    store[CategoryKey(tab, cat)] = collapse and true or nil
  end
  UpdateToggleAllTexture()
  UI:Refresh()
end)

function UI:Refresh()
  syncBtn:SetShown(addon.GetSecret and addon:GetSecret() ~= nil)
  UpdateToggleAllTexture()

  -- Defer refresh if the user is actively editing a target box. Hiding rows
  -- during the refresh would steal keyboard focus and route keys to the action
  -- bar (i.e. cast spells when typing numbers).
  for _, r in ipairs(rowPool) do
    if r.targetBox and r.targetBox:HasFocus() then return end
  end

  for _, r in ipairs(rowPool)    do r:Hide() end
  for _, h in ipairs(headerPool) do h:Hide() end
  if content.emptyMessage then content.emptyMessage:Hide() end

  -- Filter checkboxes don't apply on the gather or craft tabs. The class
  -- dropdown / toggle button only makes sense on the Consumables tab.
  local listTab = currentTab == "To gather" or currentTab == "To craft"
  stockCheck:SetShown(not listTab)
  targetsCheck:SetShown(not listTab)
  underCheck:SetShown(not listTab)
  ApplyClassWidgetVisibility()

  if currentTab == "To gather" then
    -- The gather view deliberately ignores the filter state from other tabs
    -- (inStockOnly / targetsOnly / underTargetOnly / searchQuery). The list
    -- shows every target with a deficit, regardless of those switches.
    local list = addon:ComputeGatheringList()
    local y, rIdx, hIdx = 0, 0, 0

    if #list == 0 then
      -- Empty divider header (just the horizontal line at its bottom)…
      hIdx = 1
      local h = MakeHeader(hIdx)
      h.category = nil
      h.arrow:Hide()
      h.stockLabel:Hide()
      h.gatherMidLabel:Hide()
      h.targetLabel:Hide()
      h.text:SetText("")
      h:ClearAllPoints()
      h:SetPoint("TOPLEFT", 0, -y)
      h:Show()
      y = y + 22

      -- …with the hint message below.
      if not content.emptyMessage then
        local fs = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        fs:SetJustifyH("CENTER")
        fs:SetJustifyV("TOP")
        fs:SetWordWrap(true)
        content.emptyMessage = fs
      end
      content.emptyMessage:ClearAllPoints()
      content.emptyMessage:SetPoint("CENTER", scroll, "CENTER", 0, 0)
      content.emptyMessage:SetWidth(scroll:GetWidth() - 40)
      local hasTargets = false
      if HelloStockDB and HelloStockDB.targets then
        for _ in pairs(HelloStockDB.targets) do hasTargets = true; break end
      end
      if hasTargets then
        content.emptyMessage:SetTextColor(0.4, 1, 0.4)  -- green
        content.emptyMessage:SetText("You have reached your target stock levels.")
      else
        content.emptyMessage:SetTextColor(1, 0.82, 0)  -- yellow
        content.emptyMessage:SetText("Set or update your target stock levels for ingredients or consumables to generate a gather list here.")
      end
      content.emptyMessage:Show()
      content:SetHeight(math.max(scroll:GetHeight(), 1))
      return
    end

    -- Group entries by category; preserve Items.lua first-occurrence order.
    -- Also build a per-item position so we can sort entries within each
    -- category to match the regular tab's order (instead of gather-count desc).
    local catEntries = {}
    for _, entry in ipairs(list) do
      local cat = entry.category or "Uncategorized"
      catEntries[cat] = catEntries[cat] or {}
      catEntries[cat][#catEntries[cat] + 1] = entry
    end
    local catOrder, seen, positionInCat = {}, {}, {}
    for _, section in pairs(addon.ITEMS) do
      for _, group in ipairs(section) do
        for i, item in ipairs(group.items) do
          if item.id then positionInCat[item.id] = i end
        end
        if catEntries[group.category] and not seen[group.category] then
          catOrder[#catOrder + 1] = group.category
          seen[group.category] = true
        end
      end
    end
    if catEntries["Uncategorized"] and not seen["Uncategorized"] then
      catOrder[#catOrder + 1] = "Uncategorized"
    end
    for _, entries in pairs(catEntries) do
      table.sort(entries, function(a, b)
        return (positionInCat[a.id] or 0) < (positionInCat[b.id] or 0)
      end)
    end

    for _, cat in ipairs(catOrder) do
      local entries = catEntries[cat]
      hIdx = hIdx + 1
      local h = MakeHeader(hIdx)
      local collapsed = IsCollapsed(currentTab, cat)
      h.category = cat
      h.arrow:SetTexture(collapsed
        and "Interface\\Buttons\\UI-PlusButton-Up"
        or  "Interface\\Buttons\\UI-MinusButton-Up")
      h.arrow:Show()
      -- Three-column gather header: Need (left) / Stock (middle) / Gather (right)
      h.stockLabel:ClearAllPoints()
      h.stockLabel:SetPoint("RIGHT", h, "RIGHT", -130, 0)
      h.stockLabel:SetText("Need")
      h.stockLabel:Show()
      h.gatherMidLabel:Show()
      h.targetLabel:ClearAllPoints()
      h.targetLabel:SetPoint("RIGHT", h, "RIGHT", -16, 0)
      h.targetLabel:SetText("Gather")
      h.targetLabel:Show()
      h.text:SetText(cat)
      h.text:SetTextColor(1, 0.82, 0)
      h:ClearAllPoints()
      h:SetPoint("TOPLEFT", 0, -y)
      h:Show()
      y = y + 22

      if not collapsed then
        for _, entry in ipairs(entries) do
          rIdx = rIdx + 1
          local row = MakeRow(rIdx)
          local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(entry.id)
          row.itemID = entry.id
          row.sep:Hide()
          row.icon:Show()
          row.icon:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark")
          row.icon:ClearAllPoints()
          row.icon:SetPoint("LEFT", 4, 0)
          row.name:Show()
          row.name:SetAlpha(1)
          row.name:SetText(name or ("Item " .. entry.id))
          row.count:Hide()
          row.targetBox:Hide()
          row.gatherNeed:Show()
          row.gatherNeed:SetText(tostring(entry.needed))
          row.gatherNeed:SetTextColor(1, 0.82, 0)        -- yellow
          row.gatherStock:Show()
          row.gatherStock:SetText(tostring(entry.have))
          row.gatherStock:SetTextColor(1, 1, 1)          -- white
          row.gatherCount:Show()
          row.gatherCount:SetText(tostring(entry.gather))
          row.gatherCount:SetTextColor(1, 0.3, 0.3)      -- red
          row.needHover:Hide()
          row.stockHover:Hide()
          row.craftHover:Hide()
          row.boundLock:SetShown(addon:IsBoP(entry.id))
          row.recipeKnown:Hide()
          row.connectorV:Hide()
          row.connectorH:Hide()
          row:ClearAllPoints()
          row:SetPoint("TOPLEFT", 0, -y)
          row:Show()
          y = y + 20
        end
        y = y + 8  -- breathing room after each section
      end
    end

    content:SetHeight(math.max(y, 1))
    return
  end

  if currentTab == "To craft" then
    -- Mirrors the gather view but emits craftable items + a count of how many
    -- of each you'd need to make, including intermediates.
    local list = addon:ComputeCraftList()
    local y, rIdx, hIdx = 0, 0, 0

    if #list == 0 then
      hIdx = 1
      local h = MakeHeader(hIdx)
      h.category = nil
      h.arrow:Hide()
      h.stockLabel:Hide()
      h.gatherMidLabel:Hide()
      h.targetLabel:Hide()
      h.text:SetText("")
      h:ClearAllPoints()
      h:SetPoint("TOPLEFT", 0, -y)
      h:Show()
      y = y + 22

      if not content.emptyMessage then
        local fs = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        fs:SetJustifyH("CENTER")
        fs:SetJustifyV("TOP")
        fs:SetWordWrap(true)
        content.emptyMessage = fs
      end
      content.emptyMessage:ClearAllPoints()
      content.emptyMessage:SetPoint("CENTER", scroll, "CENTER", 0, 0)
      content.emptyMessage:SetWidth(scroll:GetWidth() - 40)
      local hasTargets = false
      if HelloStockDB and HelloStockDB.targets then
        for _ in pairs(HelloStockDB.targets) do hasTargets = true; break end
      end
      if hasTargets then
        content.emptyMessage:SetTextColor(0.4, 1, 0.4)
        content.emptyMessage:SetText("Nothing to craft — your targeted items are stocked or gather-only.")
      else
        content.emptyMessage:SetTextColor(1, 0.82, 0)
        content.emptyMessage:SetText("Set or update your target stock levels for ingredients or consumables to generate a craft list here.")
      end
      content.emptyMessage:Show()
      content:SetHeight(math.max(scroll:GetHeight(), 1))
      return
    end

    local catEntries = {}
    for _, entry in ipairs(list) do
      local cat = entry.category or "Uncategorized"
      catEntries[cat] = catEntries[cat] or {}
      catEntries[cat][#catEntries[cat] + 1] = entry
    end
    local catOrder, seen, positionInCat = {}, {}, {}
    for _, section in pairs(addon.ITEMS) do
      for _, group in ipairs(section) do
        for i, item in ipairs(group.items) do
          if item.id then positionInCat[item.id] = i end
        end
        if catEntries[group.category] and not seen[group.category] then
          catOrder[#catOrder + 1] = group.category
          seen[group.category] = true
        end
      end
    end
    if catEntries["Uncategorized"] and not seen["Uncategorized"] then
      catOrder[#catOrder + 1] = "Uncategorized"
    end
    for _, entries in pairs(catEntries) do
      table.sort(entries, function(a, b)
        return (positionInCat[a.id] or 0) < (positionInCat[b.id] or 0)
      end)
    end

    for _, cat in ipairs(catOrder) do
      local entries = catEntries[cat]
      hIdx = hIdx + 1
      local h = MakeHeader(hIdx)
      local collapsed = IsCollapsed(currentTab, cat)
      h.category = cat
      h.arrow:SetTexture(collapsed
        and "Interface\\Buttons\\UI-PlusButton-Up"
        or  "Interface\\Buttons\\UI-MinusButton-Up")
      h.arrow:Show()
      h.stockLabel:ClearAllPoints()
      h.stockLabel:SetPoint("RIGHT", h, "RIGHT", -130, 0)
      h.stockLabel:SetText("Need")
      h.stockLabel:Show()
      h.gatherMidLabel:Show()
      h.targetLabel:ClearAllPoints()
      h.targetLabel:SetPoint("RIGHT", h, "RIGHT", -16, 0)
      h.targetLabel:SetText("Craft")
      h.targetLabel:Show()
      h.text:SetText(cat)
      h.text:SetTextColor(1, 0.82, 0)
      h:ClearAllPoints()
      h:SetPoint("TOPLEFT", 0, -y)
      h:Show()
      y = y + 22

      if not collapsed then
        for _, entry in ipairs(entries) do
          rIdx = rIdx + 1
          local row = MakeRow(rIdx)
          local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(entry.id)
          row.itemID = entry.id
          row.sep:Hide()
          row.icon:Show()
          row.icon:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark")
          row.icon:ClearAllPoints()
          row.icon:SetPoint("LEFT", 4, 0)
          row.name:Show()
          row.name:SetAlpha(1)
          row.name:SetText(name or ("Item " .. entry.id))
          row.count:Hide()
          row.targetBox:Hide()
          row.gatherNeed:Show()
          row.gatherNeed:SetText(tostring(entry.needed))
          row.gatherNeed:SetTextColor(1, 0.82, 0)        -- yellow
          row.gatherStock:Show()
          row.gatherStock:SetText(tostring(entry.have))
          row.gatherStock:SetTextColor(1, 1, 1)          -- white
          row.gatherCount:Show()
          row.gatherCount:SetText(tostring(entry.craft))
          row.gatherCount:SetTextColor(1, 0.3, 0.3)      -- red
          row.needHover.qty  = entry.needed
          row.stockHover.qty = entry.have
          row.craftHover.qty = entry.craft
          row.needHover:Show()
          row.stockHover:Show()
          row.craftHover:Show()
          row.boundLock:SetShown(addon:IsBoP(entry.id))
          local crafters = addon.GetCrafters and addon:GetCrafters(entry.id)
          row.recipeKnown:SetShown(crafters and #crafters > 0 or false)
          row.connectorV:Hide()
          row.connectorH:Hide()
          row:ClearAllPoints()
          row:SetPoint("TOPLEFT", 0, -y)
          row:Show()
          y = y + 20
        end
        y = y + 8
      end
    end

    content:SetHeight(math.max(y, 1))
    return
  end

  local section = addon.ITEMS[currentTab]
  if not section then return end

  local searching = searchQuery ~= ""
  local y, rIdx, hIdx = 0, 0, 0
  for _, group in ipairs(section) do
    local headerY   = y
    local h         = MakeHeader(hIdx + 1)
    local groupHit  = false
    local collapsed = IsCollapsed(currentTab, group.category) and not searching

    -- Pass 1: compute filter match for every non-separator item in this group.
    local matches, cached = {}, {}
    for i, item in ipairs(group.items) do
      if not item.separator then
        local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(item.id)
        local displayName = name or item.name or ""
        local target = GetTarget(item.id)
        local total = addon:GetTotals(item.id)
        cached[i] = { name = name, link = link, texture = texture, target = target, total = total }

        local matchSearch = not searching or displayName:lower():find(searchQuery, 1, true)
        local matchTarget = not targetsOnly or target ~= nil
        local matchStock  = not inStockOnly or total > 0
        local matchUnder  = not underTargetOnly or (target ~= nil and total < target)
        local matchClass  = true
        if classFilter and item.classes then
          matchClass = false
          for _, c in ipairs(item.classes) do
            if c == classFilter then matchClass = true; break end
          end
        end

        matches[i] = (matchSearch and matchTarget and matchStock and matchUnder and matchClass) and true or false
        if matches[i] then groupHit = true end
      end
    end

    -- Pass 2: decide separator rows. A separator is only useful when it has
    -- at least one matching item on each side; otherwise filtering would
    -- leave a stray divider line above/below unrelated content.
    for i, item in ipairs(group.items) do
      if item.separator then
        local hasAbove, hasBelow = false, false
        for j = i - 1, 1, -1 do if matches[j] then hasAbove = true; break end end
        for j = i + 1, #group.items do if matches[j] then hasBelow = true; break end end
        matches[i] = hasAbove and hasBelow
      end
    end

    y = y + 22  -- reserved for the header; rolled back below if groupHit is false

    if not collapsed then
      for i, item in ipairs(group.items) do
        if matches[i] then
          rIdx = rIdx + 1
          local row = MakeRow(rIdx)
          if item.separator then
            row.itemID = nil
            row.icon:Hide()
            row.name:Hide()
            row.count:Hide()
            row.targetBox:Hide()
            row.boundLock:Hide()
            row.recipeKnown:Hide()
            row.connectorV:Hide()
            row.connectorH:Hide()
            row.gatherNeed:Hide()
            row.gatherStock:Hide()
            row.gatherCount:Hide()
            row.sep:Show()
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, -y)
            row:Show()
            y = y + 12
          else
            local c = cached[i]
            row.itemID = item.id
            row.sep:Hide()
            row.icon:Show()
            row.name:Show()
            row.count:Show()
            row.targetBox:Show()
            row.gatherNeed:Hide()
            row.gatherStock:Hide()
            row.gatherCount:Hide()
            row.needHover:Hide()
            row.stockHover:Hide()
            row.craftHover:Hide()
            row.icon:SetTexture(c.texture or "Interface\\Icons\\INV_Misc_QuestionMark")
            row.icon:ClearAllPoints()
            row.icon:SetPoint("LEFT", item.indent and 20 or 4, 0)
            row.boundLock:SetShown(addon:IsBoP(item.id))
            row.recipeKnown:Hide()
            local showBracket = item.indent == "branch"
            row.connectorV:SetShown(showBracket)
            row.connectorH:SetShown(showBracket)
            row.name:SetText(c.link or c.name or item.name)

            row.targetBox.itemID = item.id
            local boxText = c.target and tostring(c.target) or ""
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
    end

    if groupHit then
      hIdx = hIdx + 1
      h.category = group.category
      h.arrow:SetTexture(collapsed
        and "Interface\\Buttons\\UI-PlusButton-Up"
        or  "Interface\\Buttons\\UI-MinusButton-Up")
      h.arrow:Show()
      -- Reset header labels to regular-tab layout (in case last render was gather).
      h.stockLabel:ClearAllPoints()
      h.stockLabel:SetPoint("RIGHT", h, "RIGHT", -76, 0)
      h.stockLabel:SetText("Stock")
      h.stockLabel:Show()
      h.gatherMidLabel:Hide()
      h.targetLabel:ClearAllPoints()
      h.targetLabel:SetPoint("RIGHT", h, "RIGHT", -16, 0)
      h.targetLabel:SetText("Target")
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

  if rIdx == 0 then
    hIdx = hIdx + 1
    local h = MakeHeader(hIdx)
    h.category = nil
    h.arrow:Hide()
    h.stockLabel:Hide()
    h.gatherMidLabel:Hide()
    h.targetLabel:Hide()
    h.text:SetText("")
    h:ClearAllPoints()
    h:SetPoint("TOPLEFT", 0, 0)
    h:Show()

    if not content.emptyMessage then
      local fs = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      fs:SetJustifyH("CENTER")
      fs:SetJustifyV("TOP")
      fs:SetWordWrap(true)
      content.emptyMessage = fs
    end
    content.emptyMessage:ClearAllPoints()
    content.emptyMessage:SetPoint("CENTER", scroll, "CENTER", 0, 0)
    content.emptyMessage:SetWidth(scroll:GetWidth() - 40)
    content.emptyMessage:SetTextColor(1, 0.82, 0)  -- yellow
    content.emptyMessage:SetText("No items match your filters.")
    content.emptyMessage:Show()
    content:SetHeight(math.max(scroll:GetHeight(), 1))
    return
  end

  content:SetHeight(math.max(y, 1))
end

function UI:Toggle()
  if self:IsShown() then self:Hide() else self:Show() end
end

UI:SetScript("OnShow", function(self)
  -- Re-apply position now that SavedVariables are guaranteed loaded. The
  -- file-load RestoreUIPosition() call may have run before HelloStockDB
  -- was populated, in which case it picked the default anchor.
  RestoreUIPosition()
  LoadFilters()
  ApplyFilterCheckboxes()
  self:Refresh()
end)

addon.UI = UI

