local _, addon = ...

local function MinimapStore()
  HelloStockDB = HelloStockDB or {}
  HelloStockDB.minimap = HelloStockDB.minimap or {}
  return HelloStockDB.minimap
end

local DEFAULT_ANGLE = 195  -- lower-left of the minimap, well clear of clock/zoom

local button = CreateFrame("Button", "HelloStockMinimapButton", Minimap)
button:SetFrameStrata("MEDIUM")
button:SetFrameLevel(8)
button:SetSize(31, 31)
button:RegisterForClicks("AnyUp")
button:RegisterForDrag("LeftButton")
button:SetMovable(true)
button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

local overlay = button:CreateTexture(nil, "OVERLAY")
overlay:SetSize(53, 53)
overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
overlay:SetPoint("TOPLEFT")

local bg = button:CreateTexture(nil, "BACKGROUND")
bg:SetSize(20, 20)
bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
bg:SetPoint("TOPLEFT", 7, -5)

local icon = button:CreateTexture(nil, "ARTWORK")
icon:SetSize(17, 17)
icon:SetTexture("Interface\\Icons\\INV_Misc_Bag_19")
icon:SetPoint("TOPLEFT", 7, -6)

local function UpdatePosition()
  local angle = math.rad(MinimapStore().angle or DEFAULT_ANGLE)
  -- Anchor the button just outside the minimap edge — most of the button
  -- sits clear of the minimap, with a slight overlap into the border.
  -- Computed from the live minimap width so it adapts if another addon
  -- resizes the minimap.
  local r = Minimap:GetWidth() / 2 + 5
  button:ClearAllPoints()
  button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * r, math.sin(angle) * r)
end

local function ApplyVisibility()
  button:SetShown(not MinimapStore().hide)
end

local function DraggingUpdate(self)
  local mx, my = Minimap:GetCenter()
  local px, py = GetCursorPosition()
  local scale = Minimap:GetEffectiveScale()
  px, py = px / scale, py / scale
  MinimapStore().angle = math.deg(math.atan2(py - my, px - mx))
  UpdatePosition()
end

button:SetScript("OnDragStart", function(self)
  self:LockHighlight()
  self:SetScript("OnUpdate", DraggingUpdate)
end)
button:SetScript("OnDragStop", function(self)
  self:UnlockHighlight()
  self:SetScript("OnUpdate", nil)
end)

button:SetScript("OnClick", function(_, btn)
  if btn == "RightButton" then
    if Settings and Settings.OpenToCategory and addon.OptionsCategoryID then
      Settings.OpenToCategory(addon.OptionsCategoryID)
    elseif InterfaceOptionsFrame_OpenToCategory and HelloStockOptionsPanel then
      InterfaceOptionsFrame_OpenToCategory(HelloStockOptionsPanel)
      InterfaceOptionsFrame_OpenToCategory(HelloStockOptionsPanel)
    end
  else
    if addon.UI then addon.UI:Toggle() end
  end
end)

button:SetScript("OnEnter", function(self)
  GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  GameTooltip:AddLine("HelloStock", 1, 0.82, 0)
  GameTooltip:AddLine("Left-click: open/close the stockpile window", 1, 1, 1)
  GameTooltip:AddLine("Right-click: open options",                    1, 1, 1)
  GameTooltip:AddLine("Drag: move around the minimap edge", 0.7, 0.7, 0.7)
  GameTooltip:Show()
end)
button:SetScript("OnLeave", function() GameTooltip:Hide() end)

function addon:SetMinimapHidden(hidden)
  MinimapStore().hide = hidden and true or false
  ApplyVisibility()
end

function addon:IsMinimapHidden()
  return MinimapStore().hide and true or false
end

-- HelloStockDB and Minimap are guaranteed populated by PLAYER_LOGIN, so defer
-- the first position/visibility apply until then.
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
  UpdatePosition()
  ApplyVisibility()
end)
