local _, addon = ...

local function TargetsStore()
  return addon:GetTargets().items
end

local function GetTarget(itemID)
  return TargetsStore()[itemID]
end

local targetsSendPending = false
local function SetTarget(itemID, val)
  local bucket = addon:GetTargets()
  if val and val > 0 then
    bucket.items[itemID] = val
  else
    bucket.items[itemID] = nil
  end
  bucket.updatedAt = time()
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
-- HIGH strata stays above lower-strata frames like the minimap, but bags
-- are HIGH-with-toplevel="true" so their auto-raise on show pops them in
-- front of us. The previous OnMouseDown:Raise() hook re-raised HelloStock
-- above bags on every click, which is the behavior we don't want anymore.
UI:SetFrameStrata("HIGH")
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

-- Bottom tabs in Blizzard's character-frame / spellbook style. The
-- PanelTabButtonTemplate gives the raised-tab graphic; we just feed it
-- text and let it auto-size to fit. PanelTemplates_SetTab handles the
-- "selected" raised state on whichever tab is active.
local bottomTabs = {}
local function MakeBottomTab(label, index)
  local b = CreateFrame("Button", "HelloStockBottomTab" .. index, UI, "CharacterFrameTabButtonTemplate")
  b:SetID(index)
  b:SetText(label)
  if PanelTemplates_TabResize then PanelTemplates_TabResize(b, 0) end
  if index == 1 then
    b:SetPoint("TOPLEFT", UI, "BOTTOMLEFT", 11, 2)
  else
    b:SetPoint("LEFT", bottomTabs[index - 1], "RIGHT", -16, 0)
  end
  b:SetScript("OnClick", function()
    UI:ClearAllFocus()
    currentTab = label
    UI:Refresh()
  end)
  b.label = label
  bottomTabs[#bottomTabs + 1] = b
  return b
end

MakeBottomTab("Consumables", 1)
MakeBottomTab("Ingredients", 2)
MakeBottomTab("To gather",   3)
MakeBottomTab("To craft",    4)
MakeBottomTab("Characters",  5)
PanelTemplates_SetNumTabs(UI, #bottomTabs)

local function UpdateBottomTabSelection()
  -- Call the tab-state helpers directly per-tab rather than going through
  -- PanelTemplates_SetTab → PanelTemplates_UpdateTabs, which expects tabs
  -- to be named `<frame>Tab<n>` and silently no-ops if they aren't.
  for _, b in ipairs(bottomTabs) do
    if b.label == currentTab then
      PanelTemplates_SelectTab(b)
    else
      PanelTemplates_DeselectTab(b)
    end
  end
end

-- Sync-in-progress spinner. Shown in the top-right corner only while
-- Comm:IsBusy() reports outbound packets queued or inbound chunks
-- reassembling. The ring texture is rotated by an AnimationGroup, polled
-- every 0.25s from OnUpdate (cheaper than animating per-frame and good
-- enough at a glance).
local syncSpinner = CreateFrame("Frame", nil, UI)
syncSpinner:SetSize(18, 18)
-- Sits at the left side of the footer row, sharing the row with the
-- right-justified gold total — same vertical band, opposite end.
syncSpinner:SetPoint("BOTTOMLEFT", UI, "BOTTOMLEFT", 6, 4)
syncSpinner:Hide()

syncSpinner.tex = syncSpinner:CreateTexture(nil, "ARTWORK")
syncSpinner.tex:SetTexture("Interface\\Common\\StreamCircle")
syncSpinner.tex:SetVertexColor(1, 0.82, 0)
syncSpinner.tex:SetAllPoints()

syncSpinner.anim = syncSpinner:CreateAnimationGroup()
syncSpinner.anim:SetLooping("REPEAT")
local rot = syncSpinner.anim:CreateAnimation("Rotation")
rot:SetDegrees(-360)
rot:SetDuration(1.2)

syncSpinner:SetScript("OnShow", function(self) self.anim:Play() end)
syncSpinner:SetScript("OnHide", function(self) self.anim:Stop() end)

syncSpinner:EnableMouse(true)
syncSpinner:SetScript("OnEnter", function(self)
  GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
  GameTooltip:AddLine("Syncing…", 1, 1, 1)
  GameTooltip:AddLine("Outbound packets are still in flight or inbound chunks are reassembling.", 0.7, 0.7, 0.7, true)
  GameTooltip:Show()
end)
syncSpinner:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Poll Comm busy state and toggle the spinner. UI:Refresh also updates this
-- so visible-state transitions track the live state without leaving the
-- spinner stuck when the addon UI is hidden.
local _spinnerTick = 0
syncSpinner:SetScript("OnUpdate", function(self, elapsed)
  _spinnerTick = _spinnerTick + elapsed
  if _spinnerTick < 0.25 then return end
  _spinnerTick = 0
  local active = addon.Comm and addon.Comm.IsReceiving and addon.Comm:IsReceiving()
  if not active then self:Hide() end
end)

-- A separate watcher that catches the *start* of inbound sync activity.
-- The spinner's own OnUpdate only runs while the spinner is shown; we need
-- this to flip it on when state goes idle → receiving.
local _busyWatcher = CreateFrame("Frame", nil, UI)
local _busyWatcherTick = 0
_busyWatcher:SetScript("OnUpdate", function(_, elapsed)
  _busyWatcherTick = _busyWatcherTick + elapsed
  if _busyWatcherTick < 0.25 then return end
  _busyWatcherTick = 0
  local active = addon.Comm and addon.Comm.IsReceiving and addon.Comm:IsReceiving()
  if active and not syncSpinner:IsShown() then syncSpinner:Show() end
end)

local searchQuery = ""
local targetsOnly = false
local inStockOnly = false
local underTargetOnly = false
local craftableOnly = false
-- Switches the "To gather" tab between the default per-item list and a
-- zones-to-farm aggregate view (see RenderFarmTab + ComputeFarmList).
local gatherByZone = false
-- Switches the "To craft" tab between the default per-item list and a
-- per-character grouping (see RenderCraftByCharacterTab).
local craftByCharacter = false
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
    inStock          = inStockOnly,
    withTarget       = targetsOnly,
    underTarget      = underTargetOnly,
    craftable        = craftableOnly,
    gatherByZone     = gatherByZone,
    craftByCharacter = craftByCharacter,
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
    inStockOnly      = f.inStock     and true or false
    targetsOnly      = f.withTarget  and true or false
    underTargetOnly  = f.underTarget and true or false
    craftableOnly    = f.craftable   and true or false
    gatherByZone     = f.gatherByZone     and true or false
    craftByCharacter = f.craftByCharacter and true or false
  end
  local cs = CharStore()
  classFilter       = cs.class
  pickedClass       = cs.pickedClass
  classFilterSource = cs.classSource or "picked"
end

local search = CreateFrame("EditBox", "HelloStockSearch", UI, "InputBoxTemplate")
search:SetSize(140, 20)
search:SetPoint("TOPLEFT", 38, -32)
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

-- "Craftable" filter. Only meaningful (and only shown) on the "To craft" tab:
-- when checked, rows are limited to those flagged green (fully craftable) or
-- yellow (≥50% craftable from current stocks + intermediates).
local craftableCheck = MakeFilterCheck("HelloStockCraftableCheck", "Craftable", underCheck, function(self)
  craftableOnly = self:GetChecked() and true or false
  SaveFilters()
  UI:Refresh()
end)

-- "By zone" toggle. Only shown on the "To gather" tab. When checked, the
-- gather list renders as a ranked set of zones (where to farm efficiently
-- given the current deficits) instead of a per-item list.
local byZoneCheck = MakeFilterCheck("HelloStockByZoneCheck", "By zone", craftableCheck, function(self)
  gatherByZone = self:GetChecked() and true or false
  SaveFilters()
  UI:Refresh()
end)
byZoneCheck:ClearAllPoints()
byZoneCheck:SetPoint("LEFT", searchClear, "RIGHT", 4, 0)

-- "By character" toggle. Only shown on the "To craft" tab. When checked,
-- the craft list groups items by which character can make them — useful
-- when crafts are spread across alts.
local byCharCheck = MakeFilterCheck("HelloStockByCharCheck", "By character", byZoneCheck, function(self)
  craftByCharacter = self:GetChecked() and true or false
  SaveFilters()
  UI:Refresh()
end)
-- On the "To craft" tab both "By character" and "Craftable" are visible;
-- order them left-to-right as searchClear → By character → Craftable.
byCharCheck:ClearAllPoints()
byCharCheck:SetPoint("LEFT", searchClear, "RIGHT", 4, 0)
craftableCheck:ClearAllPoints()
craftableCheck:SetPoint("LEFT", _G["HelloStockByCharCheckText"] or byCharCheck, "RIGHT", 6, 0)

-- Class filter dropdown. Filters items that carry a `classes` field (mostly
-- consumables); items without the field show regardless of selection.
-- Faction-restricted: Paladin only shown to Alliance, Shaman only to Horde.
local classDD = CreateFrame("Frame", "HelloStockClassDD", UI, "UIDropDownMenuTemplate")
classDD:SetPoint("TOPRIGHT", UI, "TOPRIGHT", 0, -26)
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
classToggleBtn:SetPoint("TOPRIGHT", UI, "TOPRIGHT", -14, -27)
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
  craftableCheck:SetChecked(craftableOnly)
  ApplyClassDDText()
end

local scroll = CreateFrame("ScrollFrame", "HelloStockScroll", UI, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 10, -58)
scroll:SetPoint("BOTTOMRIGHT", -30, 26)

-- Footer line showing aggregate gold across paired-account characters in the
-- same faction/connected-realm scope.
local moneyFooter = CreateFrame("Frame", nil, UI)
moneyFooter:SetPoint("BOTTOMLEFT",  UI, "BOTTOMLEFT",   12,  6)
moneyFooter:SetPoint("BOTTOMRIGHT", UI, "BOTTOMRIGHT", -12,  6)
moneyFooter:SetHeight(18)
moneyFooter.text = moneyFooter:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
moneyFooter.text:SetPoint("LEFT",  moneyFooter, "LEFT",  0, 0)
moneyFooter.text:SetPoint("RIGHT", moneyFooter, "RIGHT", 0, 0)
moneyFooter.text:SetJustifyH("RIGHT")
moneyFooter.text:SetJustifyV("MIDDLE")

local function FormatGold(copper)
  copper = math.floor(copper or 0)
  local g = math.floor(copper / 10000)
  local s = math.floor((copper % 10000) / 100)
  local c = copper % 100
  return ("|cffffd100%d|rg |cffc7c7cf%d|rs |cffeda55f%d|rc"):format(g, s, c)
end

-- Mouse-catcher sized to just the rendered gold text. Without this the whole
-- footer row (which extends to the left across the empty area where the
-- spinner now lives) would trigger the tooltip whenever the cursor crosses
-- the bottom of the frame.
moneyFooter.hover = CreateFrame("Frame", nil, moneyFooter)
moneyFooter.hover:SetPoint("BOTTOMRIGHT", moneyFooter, "BOTTOMRIGHT", 0, 0)
moneyFooter.hover:SetPoint("TOPRIGHT",    moneyFooter, "TOPRIGHT",    0, 0)
moneyFooter.hover:SetWidth(1)  -- resized to text width in RefreshMoney
moneyFooter.hover:EnableMouse(true)
moneyFooter.hover:SetScript("OnEnter", function(self)
  local total, breakdown = addon:GetTotalMoney()
  GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
  GameTooltip:AddLine("Total gold across paired characters", 1, 0.82, 0)
  GameTooltip:AddLine(FormatGold(total), 1, 1, 1)
  if #breakdown > 0 then
    GameTooltip:AddLine(" ")
    for _, b in ipairs(breakdown) do
      local label = b.isMine and b.name or (b.name .. " |cff888888(paired)|r")
      local right = FormatGold(b.copper)
      if b.transit and b.transit > 0 then
        right = right .. (" |cffd8b66f(%s in transit)|r"):format(FormatGold(b.transit))
      end
      if b.mail and b.mail > 0 then
        right = right .. (" |cff88aaee(%s in mail)|r"):format(FormatGold(b.mail))
      end
      GameTooltip:AddDoubleLine(label, right, 1, 1, 1, 1, 1, 1)
    end
  end
  GameTooltip:Show()
end)
moneyFooter.hover:SetScript("OnLeave", function() GameTooltip:Hide() end)

function UI:RefreshMoney()
  local total = addon.GetTotalMoney and addon:GetTotalMoney() or 0
  moneyFooter.text:SetText("Gold: " .. FormatGold(total))
  moneyFooter.hover:SetWidth(moneyFooter.text:GetStringWidth() + 4)
end

local content = CreateFrame("Frame", nil, scroll)
content:SetSize(520, 1)
scroll:SetScrollChild(content)

local rowPool, headerPool = {}, {}
local charRowPool = {}

-- Tab navigation between target-input boxes on the regular item tabs. Rows
-- are pooled and reused; the displayed-in-current-tab subset is whichever
-- `r:IsShown()`. Within that subset, pool index equals visual top-down
-- order because RenderCharactersTab / the item-tab renderer assign rows
-- in display order.
local function EnsureRowVisible(row)
  if not row or not row:IsShown() then return end
  local rowTop, rowBottom = row:GetTop(), row:GetBottom()
  local viewTop, viewBottom = scroll:GetTop(), scroll:GetBottom()
  if not rowTop or not viewTop then return end
  local currentScroll = scroll:GetVerticalScroll() or 0
  if rowTop > viewTop then
    -- Row sits above the viewport — scroll up just enough to bring its top
    -- flush with the viewport top.
    scroll:SetVerticalScroll(math.max(0, currentScroll - (rowTop - viewTop)))
  elseif rowBottom < viewBottom then
    -- Row sits below the viewport — scroll down so its bottom is flush with
    -- the viewport bottom. Clamp to the scroll frame's range.
    local maxScroll = scroll:GetVerticalScrollRange() or 0
    scroll:SetVerticalScroll(math.min(maxScroll, currentScroll + (viewBottom - rowBottom)))
  end
end

local function FocusAdjacentTargetBox(currentBox, reverse)
  local visible = {}
  for _, r in ipairs(rowPool) do
    if r:IsShown() and r.targetBox and r.targetBox:IsShown() then
      visible[#visible + 1] = r.targetBox
    end
  end
  if #visible == 0 then return end
  local idx
  for i, tb in ipairs(visible) do
    if tb == currentBox then idx = i; break end
  end
  if not idx then
    visible[1]:SetFocus()
    EnsureRowVisible(visible[1]:GetParent())
    return
  end
  local nextIdx
  if reverse then
    nextIdx = idx - 1; if nextIdx < 1 then nextIdx = #visible end
  else
    nextIdx = idx + 1; if nextIdx > #visible then nextIdx = 1 end
  end
  local nextBox = visible[nextIdx]
  nextBox:SetFocus()
  EnsureRowVisible(nextBox:GetParent())
end

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
  -- Tint behind a row, shown in the "To craft" view based on how much of the
  -- required craft amount we can actually produce from current stocks (raw
  -- ingredients + any intermediates we could craft from those). Green = full,
  -- yellow = half or more, hidden otherwise. Vendor reagents (vials) are
  -- treated as unlimited.
  row.craftableBg = row:CreateTexture(nil, "BACKGROUND")
  row.craftableBg:SetPoint("TOPLEFT",     row, "TOPLEFT",      2, -1)
  row.craftableBg:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -2,  1)
  row.craftableBg:Hide()
  -- Subtle highlight shown while this row's target editbox holds focus, so
  -- you can see at a glance which row you're typing into during Tab-walks.
  row.focusBg = row:CreateTexture(nil, "BACKGROUND")
  row.focusBg:SetColorTexture(1, 0.82, 0, 0.08)
  row.focusBg:SetPoint("TOPLEFT",     row, "TOPLEFT",      2, -1)
  row.focusBg:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -2,  1)
  row.focusBg:Hide()
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

  -- Columns used only by the "By zone" view (gather tab in zones mode).
  -- Five right-aligned numeric columns, evenly spaced 42px apart:
  --   Need / Drop % / Per node / Per hr / Hours.
  -- Drop % is filled for mob/dungeon sources, Per node for herb/mine/skin —
  -- splitting them avoids mixing two different units in one column.
  -- Hours is the estimate of how long it'd take to satisfy the deficit at
  -- the current Per hr rate. Hidden by default; visible only inside
  -- RenderFarmTab.
  local function _bzCol(rightOffset)
    local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("RIGHT", row, "RIGHT", rightOffset, 0)
    fs:SetWidth(42); fs:SetJustifyH("RIGHT"); fs:Hide()
    return fs
  end
  -- Five columns, 42px wide. Most gaps are 6px; the Drop%-to-Per node gap
  -- is widened to 18px so the wider "Per node" header label doesn't crowd
  -- "Drop %" on the left.
  row.bzNeed  = _bzCol(-218)
  row.bzDrop  = _bzCol(-170)
  row.bzYield = _bzCol(-110)
  row.bzRate  = _bzCol(-62)
  row.bzHours = _bzCol(-14)

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

    local function FormatNeed(id, need)
      local have    = (addon.GetTotals and addon:GetTotals(id)) or 0
      local missing = math.max(0, need - have)
      if missing > 0 then
        return ("%d  |cffff5555(short %d)|r"):format(need, missing)
      end
      return tostring(need)
    end

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
        GameTooltip:AddDoubleLine("  " .. name, FormatNeed(id, raw[id]), 1, 1, 1, 1, 1, 1)
      end
    elseif recipe and #recipe > 0 then
      for _, ing in ipairs(recipe) do
        local total = ing.count * crafts
        local name  = GetItemInfo(ing.id) or ("Item " .. ing.id)
        GameTooltip:AddDoubleLine("  " .. name, FormatNeed(ing.id, total), 1, 1, 1, 1, 1, 1)
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
    if row.focusBg then row.focusBg:Show() end
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
  row.targetBox:SetScript("OnTabPressed", function(self) FocusAdjacentTargetBox(self, IsShiftKeyDown()) end)
  -- Defer Refresh by one frame so Tab navigation can establish focus on the
  -- next box before the pool-hide pass runs (Refresh bails out if any
  -- target box still has focus).
  row.targetBox:SetScript("OnEditFocusLost", function()
    if row.focusBg then row.focusBg:Hide() end
    C_Timer.After(0, function() UI:Refresh() end)
  end)

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

-- One row of the Characters overview tab. Two-line layout: identity + stats
-- on top, full profession list with skill levels on a smaller second line.
-- Separate pool from MakeRow because the column layout is entirely different.
local CHAR_ROW_HEIGHT = 34
local function MakeCharRow(i)
  if charRowPool[i] then return charRowPool[i] end
  local row = CreateFrame("Button", nil, content)
  row:SetSize(520, CHAR_ROW_HEIGHT)
  row:RegisterForClicks("RightButtonUp")

  row.bg = row:CreateTexture(nil, "BACKGROUND")
  row.bg:SetAllPoints()
  row.bg:SetColorTexture(1, 1, 1, 0)

  row:SetScript("OnEnter", function(self)
    self.bg:SetColorTexture(1, 1, 1, 0.05)
  end)
  row:SetScript("OnLeave", function(self)
    self.bg:SetColorTexture(1, 1, 1, 0)
  end)

  -- Top line: name + last sync + gold + pending-incoming-mail count.
  row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.name:SetPoint("TOPLEFT",  row, "TOPLEFT",   8, -2)
  row.name:SetPoint("TOPRIGHT", row, "TOPRIGHT", -190, -2)
  row.name:SetHeight(16)
  row.name:SetJustifyH("LEFT")
  row.name:SetWordWrap(false)

  row.lastSync = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.lastSync:SetPoint("TOPRIGHT", row, "TOPRIGHT", -130, -3)
  row.lastSync:SetWidth(50)
  row.lastSync:SetHeight(16)
  row.lastSync:SetJustifyH("RIGHT")

  row.gold = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  row.gold:SetPoint("TOPRIGHT", row, "TOPRIGHT", -55, -2)
  row.gold:SetWidth(70)
  row.gold:SetHeight(16)
  row.gold:SetJustifyH("RIGHT")

  row.pending = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  row.pending:SetPoint("TOPRIGHT", row, "TOPRIGHT", -10, -2)
  row.pending:SetWidth(40)
  row.pending:SetHeight(16)
  row.pending:SetJustifyH("RIGHT")

  -- Second line: every profession with skill level, in trade-skill orange.
  row.professions = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.professions:SetPoint("BOTTOMLEFT",  row, "BOTTOMLEFT",  14, 4)
  row.professions:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -10, 4)
  row.professions:SetHeight(12)
  row.professions:SetJustifyH("LEFT")
  row.professions:SetWordWrap(false)

  charRowPool[i] = row
  return row
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

  -- Column labels for the "By zone" view, matching the bz* columns in
  -- MakeRow. Hidden by default; shown only when the byzone renderer
  -- explicitly enables them.
  local function _bzLabel(rightOffset, text)
    local fs = h:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("RIGHT", h, "RIGHT", rightOffset, 0)
    fs:SetText(text); fs:SetTextColor(0.85, 0.75, 0.5); fs:Hide()
    return fs
  end
  h.bzNeedLabel  = _bzLabel(-218, "Need")
  h.bzDropLabel  = _bzLabel(-170, "Drop %")
  h.bzYieldLabel = _bzLabel(-110, "Per node")
  h.bzRateLabel  = _bzLabel(-62,  "Per hr")
  h.bzHoursLabel = _bzLabel(-14,  "Hours")

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
  -- On hover: always brighten the label; additionally, if this header is
  -- showing the byzone column labels, show a GameTooltip explaining what
  -- each column means and the per-hour ceilings the rate column assumes.
  -- On leave: restore the natural color — for byzone headers we may have
  -- stashed a level-appropriate color in self._textColor (set per-render
  -- in RenderFarmTab); fall back to the default gold otherwise.
  h:SetScript("OnEnter", function(self)
    self.text:SetTextColor(1, 1, 1)
    if self.bzNeedLabel and self.bzNeedLabel:IsShown() then
      GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
      -- Force a wider tooltip so the column explanations breathe instead
      -- of wrapping mid-sentence at the default ~200px width.
      GameTooltip:SetMinimumWidth(440)
      GameTooltip:AddLine("Columns", 1, 0.82, 0)
      GameTooltip:AddLine(" ")
      GameTooltip:AddDoubleLine("Need",
        "items remaining in your gather list", 0.85, 0.75, 0.5, 1, 1, 1)
      GameTooltip:AddDoubleLine("Drop %",
        "chance per mob kill", 0.85, 0.75, 0.5, 1, 1, 1)
      GameTooltip:AddDoubleLine("Per node",
        "items per herb / mine / skin gather", 0.85, 0.75, 0.5, 1, 1, 1)
      GameTooltip:AddDoubleLine("Per hr",
        "Estimated farming rate", 0.85, 0.75, 0.5, 1, 1, 1)
      GameTooltip:AddLine(
        "  capped at 60 kills/hr (mobs), 30 gathers/hr (nodes),",
        0.7, 0.7, 0.7, true)
      GameTooltip:AddLine(
        "  or 2 dungeon clears/hr — reflects travel + kill + pickup time",
        0.7, 0.7, 0.7, true)
      GameTooltip:AddDoubleLine("Hours",
        "ETA to clear this item's deficit at the per hour rate",
        0.85, 0.75, 0.5, 1, 1, 1)
      GameTooltip:Show()
    end
  end)
  h:SetScript("OnLeave", function(self)
    local c = self._textColor
    if c then
      self.text:SetTextColor(c[1], c[2], c[3])
    else
      self.text:SetTextColor(1, 0.82, 0)
    end
    GameTooltip:Hide()
  end)
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
toggleAllBtn:SetPoint("TOPLEFT", 12, -35)
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

local function FormatRelTime(t)
  if not t or t == 0 then return "—" end
  local age = time() - t
  if age < 60      then return "now"               end
  if age < 3600    then return ("%dm"):format(math.floor(age / 60))    end
  if age < 86400   then return ("%dh"):format(math.floor(age / 3600))  end
  if age < 604800  then return ("%dd"):format(math.floor(age / 86400)) end
  return ("%dw"):format(math.floor(age / 604800))
end

local function RecencyColor(t)
  if not t or t == 0 then return 0.6, 0.6, 0.6 end
  local age = time() - t
  if age < 3600    then return 0.4, 1.0, 0.4 end  -- green   < 1h
  if age < 86400   then return 1.0, 1.0, 1.0 end  -- white   < 24h
  if age < 604800  then return 1.0, 0.82, 0.0 end -- yellow  < 7d
  return 1.0, 0.3, 0.3                            -- red     >= 7d
end

local function CompactGold(copper)
  copper = math.floor(copper or 0)
  if copper == 0 then return "—" end
  local g = math.floor(copper / 10000)
  if g >= 1000 then return ("%.1fkg"):format(g / 1000) end
  if g >= 1    then return g .. "g"                    end
  local s = math.floor((copper % 10000) / 100)
  if s >= 1 then return s .. "s" end
  return (copper % 100) .. "c"
end

local function ClassColorString(class)
  if not class then return "ffffffff" end
  local c = RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
  if not c then return "ffffffff" end
  return ("ff%02x%02x%02x"):format(c.r * 255, c.g * 255, c.b * 255)
end

-- Right-click context menu for a character row. EasyMenu has been flaky in
-- current Classic Era so we drive UIDropDownMenu directly. Items are
-- rebuilt each open so the enabled state of "force resync" / "claim"
-- reflects the current pairing state.
local charContextMenu = CreateFrame("Frame", "HelloStockCharContextMenu", UIParent, "UIDropDownMenuTemplate")
charContextMenu.items = {}

UIDropDownMenu_Initialize(charContextMenu, function(self, level)
  for _, info in ipairs(self.items or {}) do
    UIDropDownMenu_AddButton(info, level)
  end
end, "MENU")

local function ShowCharContextMenu(row)
  local entry = row.entry
  if not entry then return end

  local items = {}
  items[#items + 1] = { text = entry.name .. "-" .. entry.realm, isTitle = true, notCheckable = true }

  items[#items + 1] = {
    text = "Forget",
    notCheckable = true,
    func = function()
      if HelloStockDB and HelloStockDB.characters then
        HelloStockDB.characters[entry.key] = nil
        print(("|cffffd700HelloStock:|r removed %s-%s"):format(entry.name, entry.realm))
      end
      UI:Refresh()
    end,
  }
  items[#items + 1] = { text = "|cffffd100" .. CANCEL .. "|r", notCheckable = true, func = function() end }

  charContextMenu.items = items
  ToggleDropDownMenu(1, nil, charContextMenu, "cursor", 0, 0)
end

-- Trade-skill orange used by Blizzard for profession tooltip headers.
local PROF_COLOR_ORANGE = "ffd6873e"
local PROF_COLOR_YELLOW = "ffffd100"
local PROF_COLOR_GREEN  = "ff66ff66"

-- Profession skill caps at 300 in Classic Era regardless of rank, so green
-- means "truly maxed". 225 (Artisan rank trained, not yet maxed) is yellow,
-- everything below is orange — including low-rank caps like 75/75 (which
-- should read as "still has training to do" rather than "done").
local function ProfTierColor(p)
  local skill = p.skill or 0
  if skill >= 300 then return PROF_COLOR_GREEN  end
  if skill >= 225 then return PROF_COLOR_YELLOW end
  return PROF_COLOR_ORANGE
end

local function BindCharRow(row, entry)
  row.entry = entry
  -- Reset alphas: rows are pooled, and the out-of-scope footer dims its rows
  -- to 0.55 — without a reset that dimming sticks when the row is reused.
  row.name:SetAlpha(1)
  row.lastSync:SetAlpha(1)
  row.gold:SetAlpha(1)
  row.pending:SetAlpha(1)
  row.professions:SetAlpha(1)

  local classColor = ClassColorString(entry.class)
  local levelTag = entry.level and ("|cffaaaaaa%d|r "):format(entry.level) or ""
  row.name:SetText(("%s|c%s%s|r-%s%s"):format(
    levelTag, classColor, entry.name, entry.realm,
    entry.isMine and "" or "  |cff888888[paired]|r"))

  row.lastSync:SetText(entry.isPending and "pending" or FormatRelTime(entry.lastSync))
  row.lastSync:SetTextColor(RecencyColor(entry.isPending and 0 or entry.lastSync))

  row.gold:SetText(CompactGold(entry.copper))
  row.gold:SetTextColor(entry.copper > 0 and 1 or 0.6, entry.copper > 0 and 0.82 or 0.6, entry.copper > 0 and 0 or 0.6)

  -- Pending = items sitting in this char's inbox + items being mailed to
  -- them but not yet delivered. Anything they haven't taken into their bags.
  -- Inline texture (rather than a Unicode envelope glyph) because WoW's
  -- default fonts don't include U+2709 and render it as a tofu rectangle.
  local pend = entry.pendingMail or 0
  if pend > 0 then
    row.pending:SetText(("|TInterface\\MailFrame\\Mail-Icon:14:14:0:0|t %d"):format(pend))
    row.pending:SetTextColor(1, 0.82, 0)  -- yellow, attention-grabbing
  else
    row.pending:SetText("—")
    row.pending:SetTextColor(0.5, 0.5, 0.5)
  end

  if entry.professions and #entry.professions > 0 then
    local parts = {}
    for _, p in ipairs(entry.professions) do
      local color = ProfTierColor(p)
      if p.skill and p.skill > 0 then
        parts[#parts + 1] = ("|c%s%s %d|r"):format(color, p.name, p.skill)
      else
        parts[#parts + 1] = ("|c%s%s|r"):format(color, p.name)
      end
    end
    row.professions:SetText(table.concat(parts, " |cff666666·|r "))
  else
    row.professions:SetText("|cff666666(no professions scanned)|r")
  end

  row:SetScript("OnClick", function(self, button)
    if button == "RightButton" then ShowCharContextMenu(self) end
  end)
end

-- Pick a header text color for a zone based on the player's level vs the
-- zone's level range. Green for trivial (player significantly above the
-- zone), default gold for level-appropriate, orange for stretching above
-- your level, red for outright dangerous. "city" / unknown / unparseable
-- level strings fall through to default gold.
local function ZoneColor(levels)
  if not levels or levels == "city" or levels == "?-?" then
    return 1, 0.82, 0
  end
  local lo, hi = levels:match("(%d+)%s*-%s*(%d+)")
  if not lo then
    lo = levels:match("(%d+)")
    hi = lo
  end
  if not lo then return 1, 0.82, 0 end
  lo, hi = tonumber(lo), tonumber(hi)
  local pl = UnitLevel("player") or 60
  if     pl < lo - 5 then return 1.0, 0.30, 0.30   -- way too low
  elseif pl < lo     then return 1.0, 0.55, 0.30   -- stretch
  elseif pl > hi + 5 then return 0.50, 0.85, 0.50  -- trivial
  else                    return 1.0, 0.82, 0.0   end-- appropriate
end

-- "By zone" view of the gather tab: walks the gather list via
-- ComputeFarmList, suggests zones to visit ranked by total expected items.
-- Uses the same MakeHeader / MakeRow pool as the regular tabs so zones look
-- and behave like category headers (click to collapse, persisted across
-- reloads). Collapse state piggybacks on currentTab ("To gather") since
-- physical zone names don't collide with the Ingredient/Consumable
-- categories the by-item gather view doesn't actually collapse anyway.
local function RenderFarmTab()
  local list = addon:ComputeFarmList()
  local y = 0

  -- Search filters by zone name OR by any contributing item name — useful
  -- for "where can I get Mageweave?" style queries. Item names are resolved
  -- via GetItemInfo (uses Items.lua's name field as a fallback while the
  -- client cache fills in).
  if searchQuery ~= "" then
    local filtered = {}
    for _, zone in ipairs(list) do
      local match = zone.zone:lower():find(searchQuery, 1, true) ~= nil
      if not match then
        for _, info in ipairs(zone.items) do
          local nm = GetItemInfo(info.id)
          if nm and nm:lower():find(searchQuery, 1, true) then
            match = true; break
          end
        end
      end
      if match then filtered[#filtered + 1] = zone end
    end
    list = filtered
  end

  -- Empty state — no zones survived the gather-list / search filter.
  if #list == 0 then
    if not content.emptyMessage then
      local fs = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      fs:SetJustifyH("CENTER"); fs:SetWordWrap(true)
      content.emptyMessage = fs
    end
    content.emptyMessage:ClearAllPoints()
    content.emptyMessage:SetPoint("CENTER", scroll, "CENTER", 0, 0)
    content.emptyMessage:SetWidth(scroll:GetWidth() - 40)
    local hasTargets = false
    for _ in pairs(addon:GetTargets().items) do hasTargets = true; break end
    if hasTargets then
      content.emptyMessage:SetTextColor(0.4, 1, 0.4)
      content.emptyMessage:SetText("Nothing to farm right now — your targets are met.")
    else
      content.emptyMessage:SetTextColor(1, 0.82, 0)
      content.emptyMessage:SetText("Set target stock levels first; this view suggests zones to visit based on your gather list.")
    end
    content.emptyMessage:Show()
    content:SetHeight(math.max(scroll:GetHeight(), 1))
    return
  end

  -- Format an items-per-hour rate.
  local function fmtRate(r)
    if not r or r <= 0 then return nil end
    if r >= 10 then return ("~%d/hr"):format(math.floor(r + 0.5)) end
    return ("~%.1f/hr"):format(r)
  end

  local rIdx, hIdx = 0, 0
  for _, zone in ipairs(list) do
    -- Zone header: clickable to collapse, with level range + total expected
    -- shown on the right-hand side.
    hIdx = hIdx + 1
    local h = MakeHeader(hIdx)
    h.category = zone.zone
    h.text:SetText(zone.zone .. (zone.levels and ("  (" .. zone.levels .. ")") or ""))
    -- Tint the zone header by the player's level vs the zone's level range.
    -- _textColor is read by MakeHeader's OnLeave so the natural color is
    -- restored after a hover; reset to nil in the cleanup loop so headers
    -- reused on other tabs revert to the default gold.
    local cr, cg, cb = ZoneColor(zone.levels)
    h.text:SetTextColor(cr, cg, cb)
    h._textColor = { cr, cg, cb }
    local collapsed = IsCollapsed(currentTab, zone.zone)
    if collapsed then
      h.arrow:SetTexture("Interface\\Buttons\\UI-PlusButton-Up")
    else
      h.arrow:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
    end
    h.arrow:Show()
    -- Five column labels for the byzone layout. Hide the regular labels so
    -- they don't double-render.
    h.stockLabel:Hide()
    h.gatherMidLabel:Hide()
    h.targetLabel:Hide()
    h.bzNeedLabel:Show()
    h.bzDropLabel:Show()
    h.bzYieldLabel:Show()
    h.bzRateLabel:Show()
    h.bzHoursLabel:Show()
    h:ClearAllPoints()
    h:SetPoint("TOPLEFT", 0, -y)
    h:Show()
    y = y + 22

    if not collapsed then
      for _, info in ipairs(zone.items) do
        rIdx = rIdx + 1
        local row = MakeRow(rIdx)
        -- Reset row state to a clean baseline; this view doesn't use the
        -- target editbox / stock column.
        row.craftableBg:Hide(); row.focusBg:Hide()
        row.boundLock:Hide(); row.recipeKnown:Hide()
        row.connectorV:Hide(); row.connectorH:Hide()
        row.sep:Hide()
        if row.targetBox then row.targetBox:Hide() end
        row.count:SetText("")

        -- row.itemID drives the hover tooltip (set by MakeRow's OnEnter).
        -- Pooled rows retain the previous render's itemID — without this
        -- line, hovering shows whichever item was last bound to this row.
        row.itemID = info.id

        local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(info.id)
        row.icon:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark")
        row.icon:SetAlpha(1)  -- ApplyVisual on the regular tabs dims icons
        row.icon:Show()       -- for zero-stock + no-target items; reset.
        row.name:SetText(name or ("Item " .. info.id))
        row.name:SetTextColor(1, 1, 1)
        row.name:SetAlpha(1)

        -- Four right-aligned columns dedicated to the byzone view:
        --   bzNeed  = "need N"          (yellow)
        --   bzDrop  = drop % (mobs only)
        --   bzYield = items per gather  (nodes only)
        --   bzRate  = items per hour    (cyan)
        -- gather*/count/target columns stay hidden here so the previous
        -- per-item gather view's columns don't bleed through.
        row.gatherNeed:Hide(); row.gatherStock:Hide(); row.gatherCount:Hide()

        row.bzNeed:SetText(tostring(info.needed))
        row.bzNeed:SetTextColor(1, 0.82, 0)
        row.bzNeed:Show()

        if info.kind == "mob" or info.kind == "dungeon" then
          -- Drop % rounded to integer to keep the column compact (decimals
          -- on a single-digit rate aren't actionable enough to be worth
          -- the width). The full precision survives in info.source.
          local pct = info.source.avg_chance
          row.bzDrop:SetText(pct
            and (math.floor(pct + 0.5) .. "%") or "—")
          row.bzDrop:SetTextColor(1, 1, 1)
          row.bzYield:SetText("—")
          row.bzYield:SetTextColor(0.5, 0.5, 0.5)
        else
          row.bzDrop:SetText("—")
          row.bzDrop:SetTextColor(0.5, 0.5, 0.5)
          row.bzYield:SetText(info.source.avg_yield
            and tostring(info.source.avg_yield) or "—")
          row.bzYield:SetTextColor(1, 1, 1)
        end
        row.bzDrop:Show()
        row.bzYield:Show()

        -- Per-hour column shows just the number — the unit is in the header.
        local rateNum, hoursNum
        if info.per_hour and info.per_hour > 0 then
          if info.per_hour >= 10 then
            rateNum = tostring(math.floor(info.per_hour + 0.5))
          else
            rateNum = ("%.1f"):format(info.per_hour)
          end
          -- Estimated hours to satisfy this item's deficit alone in this
          -- zone. Useful as a back-of-envelope ETA — see ComputeFarmList
          -- for the per_hour model. Integer ≥10, one decimal otherwise.
          local h_est = info.needed / info.per_hour
          if h_est >= 10 then
            hoursNum = tostring(math.floor(h_est + 0.5))
          else
            hoursNum = ("%.1f"):format(h_est)
          end
        end
        row.bzRate:SetText(rateNum or "?")
        row.bzRate:SetTextColor(0.55, 0.85, 1)
        row.bzRate:Show()

        row.bzHours:SetText(hoursNum or "?")
        row.bzHours:SetTextColor(0.85, 0.85, 0.85)
        row.bzHours:Show()

        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 0, -y)
        row:Show()
        y = y + 20
      end
    end
    y = y + 4
  end

  content:SetHeight(math.max(y, scroll:GetHeight()))
end

-- "By character" view of the To-craft tab: walks the craft list, groups
-- entries by which character can make them via addon:GetCrafters, and
-- renders one collapsible header per character (mine first, then peers,
-- then a final "No known crafter" bucket if anything in the craft list
-- has no known maker). Items under each header use the same Need/Stock/
-- Craft column layout as the regular To-craft view.
local function RenderCraftByCharacterTab()
  local list = addon:ComputeCraftListByCharacter()
  local y, rIdx, hIdx, lblIdx = 0, 0, 0, 0
  content.profLabels = content.profLabels or {}

  if not list or #list == 0 then
    if not content.emptyMessage then
      local fs = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      fs:SetJustifyH("CENTER"); fs:SetWordWrap(true)
      content.emptyMessage = fs
    end
    content.emptyMessage:ClearAllPoints()
    content.emptyMessage:SetPoint("CENTER", scroll, "CENTER", 0, 0)
    content.emptyMessage:SetWidth(scroll:GetWidth() - 40)
    local hasTargets = false
    for _ in pairs(addon:GetTargets().items) do hasTargets = true; break end
    if hasTargets then
      content.emptyMessage:SetTextColor(0.4, 1, 0.4)
      content.emptyMessage:SetText("Nothing to craft — your targeted items are stocked or gather-only.")
    else
      content.emptyMessage:SetTextColor(1, 0.82, 0)
      content.emptyMessage:SetText("Set target stock levels first; this view groups the craft list by which character can make each item.")
    end
    content.emptyMessage:Show()
    content:SetHeight(math.max(scroll:GetHeight(), 1))
    return
  end

  for _, char in ipairs(list) do
    hIdx = hIdx + 1
    local h = MakeHeader(hIdx)
    h.category = char.name
    local collapsed = IsCollapsed(currentTab, char.name)
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
    h.text:SetText(char.name)
    -- Tint: own characters in gold, peer-account characters in grey, the
    -- "No known crafter" bucket in red so it reads as a problem column.
    if char.isUnknown then
      h.text:SetTextColor(1, 0.5, 0.5)
      h._textColor = { 1, 0.5, 0.5 }
    elseif char.isMine then
      h.text:SetTextColor(1, 0.82, 0)
      h._textColor = { 1, 0.82, 0 }
    else
      h.text:SetTextColor(0.7, 0.7, 0.7)
      h._textColor = { 0.7, 0.7, 0.7 }
    end
    h:ClearAllPoints()
    h:SetPoint("TOPLEFT", 0, -y)
    h:Show()
    y = y + 22

    if not collapsed then
      -- Items are pre-sorted by profession → section → craft count. Emit a
      -- small profession sub-label whenever the profession changes so the
      -- groups read as labeled blocks instead of one undifferentiated list.
      local lastProf
      for _, entry in ipairs(char.items) do
        local prof = addon:GetProfession(entry.id)
        if prof ~= lastProf then
          lblIdx = lblIdx + 1
          local lbl = content.profLabels[lblIdx]
          if not lbl then
            lbl = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            lbl:SetJustifyH("LEFT")
            content.profLabels[lblIdx] = lbl
          end
          lbl:SetText(prof)
          lbl:SetTextColor(0.85, 0.75, 0.5)
          lbl:ClearAllPoints()
          -- Align with the item icon column so the label visually sits
          -- directly above the icons of its group (icons start at LEFT 4).
          lbl:SetPoint("TOPLEFT", 4, -y)
          lbl:Show()
          y = y + 16
          lastProf = prof
        end
        rIdx = rIdx + 1
        local row = MakeRow(rIdx)
        local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(entry.id)
        row.itemID = entry.id
        row.sep:Hide()
        row.icon:Show()
        row.icon:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark")
        row.icon:SetAlpha(1)
        row.icon:ClearAllPoints()
        row.icon:SetPoint("LEFT", 4, 0)
        row.name:Show()
        row.name:SetAlpha(1)
        row.name:SetText(name or ("Item " .. entry.id))
        row.name:SetTextColor(1, 1, 1)
        row.count:Hide()
        if row.targetBox then row.targetBox:Hide() end
        row.gatherNeed:Show()
        row.gatherNeed:SetText(tostring(entry.needed))
        row.gatherNeed:SetTextColor(1, 0.82, 0)
        row.gatherStock:Show()
        row.gatherStock:SetText(tostring(entry.have))
        row.gatherStock:SetTextColor(1, 1, 1)
        row.gatherCount:Show()
        row.gatherCount:SetText(tostring(entry.craft))
        row.gatherCount:SetTextColor(1, 0.3, 0.3)
        if row.needHover  then row.needHover.qty  = entry.needed; row.needHover:Show()  end
        if row.stockHover then row.stockHover.qty = entry.have;   row.stockHover:Show() end
        if row.craftHover then row.craftHover.qty = entry.craft;  row.craftHover:Show() end
        row.boundLock:SetShown(addon:IsBoP(entry.id))
        if entry.craftLevel == "full" then
          row.craftableBg:SetColorTexture(0.2, 0.8, 0.2, 0.14)
          row.craftableBg:Show()
        elseif entry.craftLevel == "half" then
          row.craftableBg:SetColorTexture(1.0, 0.82, 0.0, 0.12)
          row.craftableBg:Show()
        else
          row.craftableBg:Hide()
        end
        row.recipeKnown:Hide()  -- redundant — every row here has a crafter
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

  -- Hide any profession labels left over from a longer previous render.
  for i = lblIdx + 1, #content.profLabels do
    content.profLabels[i]:Hide()
  end

  content:SetHeight(math.max(y, 1))
end

local function RenderCharactersTab()
  local inScope, outOfScope = addon:GetCharOverview()
  local y, rIdx, hIdx = 0, 0, 0

  -- Header: column titles.
  hIdx = hIdx + 1
  local h = MakeHeader(hIdx)
  h.category = nil
  h.arrow:Hide()
  h.text:SetText("Character")
  h.stockLabel:SetText("Last sync"); h.stockLabel:ClearAllPoints()
  h.stockLabel:SetPoint("RIGHT", h, "RIGHT", -130, 0); h.stockLabel:Show()
  h.gatherMidLabel:SetText("Gold"); h.gatherMidLabel:ClearAllPoints()
  h.gatherMidLabel:SetPoint("RIGHT", h, "RIGHT", -55, 0); h.gatherMidLabel:Show()
  h.targetLabel:SetText("Pending"); h.targetLabel:ClearAllPoints()
  h.targetLabel:SetPoint("RIGHT", h, "RIGHT", -10, 0); h.targetLabel:Show()
  h:ClearAllPoints()
  h:SetPoint("TOPLEFT", 0, -y)
  h:Show()
  y = y + 22

  if #inScope == 0 then
    if not content.emptyMessage then
      local fs = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      fs:SetJustifyH("CENTER"); fs:SetWordWrap(true)
      content.emptyMessage = fs
    end
    content.emptyMessage:ClearAllPoints()
    content.emptyMessage:SetPoint("CENTER", scroll, "CENTER", 0, 0)
    content.emptyMessage:SetWidth(scroll:GetWidth() - 40)
    content.emptyMessage:SetTextColor(1, 0.82, 0)
    content.emptyMessage:SetText("No tracked characters yet. Log into your alts (or pair an account) to populate this list.")
    content.emptyMessage:Show()
    content:SetHeight(math.max(scroll:GetHeight(), 1))
    return
  end

  for _, entry in ipairs(inScope) do
    rIdx = rIdx + 1
    local row = MakeCharRow(rIdx)
    BindCharRow(row, entry)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -y)
    row:Show()
    y = y + CHAR_ROW_HEIGHT + 2
  end

  -- Out-of-scope characters (different faction / non-connected realm) are
  -- deliberately hidden — when you're playing on a different cluster you
  -- shouldn't see your other-side alts. They still exist in the DB and will
  -- reappear when you log into a character that shares their scope.

  content:SetHeight(math.max(y, 1))
end

function UI:Refresh()
  UpdateToggleAllTexture()
  UpdateBottomTabSelection()
  self:RefreshMoney()

  -- Defer refresh if the user is actively editing a target box. Hiding rows
  -- during the refresh would steal keyboard focus and route keys to the action
  -- bar (i.e. cast spells when typing numbers).
  for _, r in ipairs(rowPool) do
    if r.targetBox and r.targetBox:HasFocus() then return end
  end

  for _, r in ipairs(rowPool)     do
    r:Hide()
    -- The byzone view shows row.bz* and hides the gather* / count / target
    -- columns. Reset bz* to hidden here so they don't leak through to a
    -- subsequent gather / regular-tab render that doesn't touch them.
    if r.bzNeed  then r.bzNeed:Hide()  end
    if r.bzDrop  then r.bzDrop:Hide()  end
    if r.bzYield then r.bzYield:Hide() end
    if r.bzRate  then r.bzRate:Hide()  end
    if r.bzHours then r.bzHours:Hide() end
  end
  for _, r in ipairs(charRowPool) do r:Hide() end
  for _, h in ipairs(headerPool)  do
    h:Hide()
    if h.bzNeedLabel  then h.bzNeedLabel:Hide()  end
    if h.bzDropLabel  then h.bzDropLabel:Hide()  end
    if h.bzYieldLabel then h.bzYieldLabel:Hide() end
    if h.bzRateLabel  then h.bzRateLabel:Hide()  end
    if h.bzHoursLabel then h.bzHoursLabel:Hide() end
    -- Clear any level-tint left over from the byzone view so headers reused
    -- on regular tabs restore to the default gold via MakeHeader's OnLeave.
    h._textColor = nil
    h.text:SetTextColor(1, 0.82, 0)
  end
  if content.emptyMessage then content.emptyMessage:Hide() end
  if content.farmLines then
    for _, fs in ipairs(content.farmLines) do fs:Hide() end
  end
  if content.profLabels then
    for _, fs in ipairs(content.profLabels) do fs:Hide() end
  end

  -- Filter checkboxes don't apply on the meta tabs (gather / craft / chars).
  -- The class dropdown / toggle button only makes sense on the Consumables
  -- tab. The "Craftable" checkbox is the inverse: only meaningful on craft.
  local listTab = currentTab == "To gather"
              or currentTab == "To craft"
              or currentTab == "Characters"
  stockCheck:SetShown(not listTab)
  targetsCheck:SetShown(not listTab)
  underCheck:SetShown(not listTab)
  craftableCheck:SetShown(currentTab == "To craft")
  byZoneCheck:SetShown(currentTab == "To gather")
  byZoneCheck:SetChecked(gatherByZone)
  byCharCheck:SetShown(currentTab == "To craft")
  byCharCheck:SetChecked(craftByCharacter)
  ApplyClassWidgetVisibility()

  if currentTab == "To gather" then
    if gatherByZone then
      RenderFarmTab()
      return
    end
    -- The gather view ignores the in-stock / with-target / under-target
    -- filter checkboxes (they don't make sense here — the list is built
    -- from deficits already) but does honor the search box: typing
    -- "mageweave" narrows the list to entries whose item name matches.
    local list = addon:ComputeGatheringList()
    if searchQuery ~= "" then
      local filtered = {}
      for _, entry in ipairs(list) do
        local nm = GetItemInfo(entry.id) or ""
        if nm:lower():find(searchQuery, 1, true) then
          filtered[#filtered + 1] = entry
        end
      end
      list = filtered
    end
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
      for _ in pairs(addon:GetTargets().items) do hasTargets = true; break end
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
          row.icon:SetAlpha(1)  -- pooled rows inherit ApplyVisual's dim
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
          row.craftableBg:Hide()
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
    if craftByCharacter then
      RenderCraftByCharacterTab()
      return
    end
    -- Mirrors the gather view but emits craftable items + a count of how many
    -- of each you'd need to make, including intermediates.
    local list = addon:ComputeCraftList()
    if craftableOnly then
      local filtered = {}
      for _, entry in ipairs(list) do
        if entry.craftLevel == "full" or entry.craftLevel == "half" then
          filtered[#filtered + 1] = entry
        end
      end
      list = filtered
    end
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
      for _ in pairs(addon:GetTargets().items) do hasTargets = true; break end
      if craftableOnly then
        content.emptyMessage:SetTextColor(1, 0.82, 0)
        content.emptyMessage:SetText("Nothing craftable right now — uncheck \"Craftable\" to see what's missing.")
      elseif hasTargets then
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
          row.icon:SetAlpha(1)  -- pooled rows inherit ApplyVisual's dim
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
          if entry.craftLevel == "full" then
            row.craftableBg:SetColorTexture(0.2, 0.8, 0.2, 0.14)  -- green
            row.craftableBg:Show()
          elseif entry.craftLevel == "half" then
            row.craftableBg:SetColorTexture(1.0, 0.82, 0.0, 0.12) -- yellow
            row.craftableBg:Show()
          else
            row.craftableBg:Hide()
          end
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

  if currentTab == "Characters" then
    RenderCharactersTab()
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
            row.craftableBg:Hide()
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
            row.craftableBg:Hide()
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

