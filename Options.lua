local _, addon = ...

local panel = CreateFrame("Frame", "HelloStockOptionsPanel")
panel.name = "HelloStock"

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("HelloStock")

local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetWidth(560)
subtitle:SetJustifyH("LEFT")
subtitle:SetText("Track crafting ingredients and consumables across all your characters and any paired account.")

-- Debug logging
local debugCheck = CreateFrame("CheckButton", "HelloStockOptDebug", panel, "InterfaceOptionsCheckButtonTemplate")
debugCheck:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -2, -16)
_G["HelloStockOptDebugText"]:SetText("Enable debug logging in chat")
debugCheck:SetScript("OnClick", function(self)
  HelloStockDB = HelloStockDB or {}
  HelloStockDB.debug = self:GetChecked() and true or false
end)

-- Pairing info section header
local pairHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
pairHeader:SetPoint("TOPLEFT", debugCheck, "BOTTOMLEFT", 2, -20)
pairHeader:SetText("Pairing")

local pairHint = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
pairHint:SetPoint("TOPLEFT", pairHeader, "BOTTOMLEFT", 0, -4)
pairHint:SetWidth(560)
pairHint:SetJustifyH("LEFT")
pairHint:SetText("Target a player and type /hs pair, or use /hs secret <word> on both accounts.")

local accountLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
accountLabel:SetPoint("TOPLEFT", pairHint, "BOTTOMLEFT", 0, -12)

local secretLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
secretLabel:SetPoint("TOPLEFT", accountLabel, "BOTTOMLEFT", 0, -8)

local unpairBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
unpairBtn:SetSize(130, 22)
unpairBtn:SetPoint("TOPLEFT", secretLabel, "BOTTOMLEFT", 0, -12)
unpairBtn:SetText("Unpair")
unpairBtn:SetScript("OnClick", function() StaticPopup_Show("HELLOSTOCK_UNPAIR") end)

-- Data section
local dataHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
dataHeader:SetPoint("TOPLEFT", unpairBtn, "BOTTOMLEFT", 0, -20)
dataHeader:SetText("Data")

local dataCount = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
dataCount:SetPoint("TOPLEFT", dataHeader, "BOTTOMLEFT", 0, -8)

local resetBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
resetBtn:SetSize(130, 22)
resetBtn:SetPoint("TOPLEFT", dataCount, "BOTTOMLEFT", 0, -12)
resetBtn:SetText("Reset everything")
resetBtn:SetScript("OnClick", function() StaticPopup_Show("HELLOSTOCK_RESET") end)

local function CountChars()
  if not HelloStockDB or not HelloStockDB.characters then return 0, 0, 0 end
  local myID = addon:GetAccountID()
  local mine, peer, unknown = 0, 0, 0
  for _, c in pairs(HelloStockDB.characters) do
    if c.accountID == myID then
      mine = mine + 1
    elseif c.accountID then
      peer = peer + 1
    else
      unknown = unknown + 1
    end
  end
  return mine, peer, unknown
end

local function Refresh()
  debugCheck:SetChecked(HelloStockDB and HelloStockDB.debug or false)
  accountLabel:SetText("Account ID: " .. (addon:GetAccountID() or "?"))
  local hash = addon:GetSecretHash()
  if hash == "" then
    secretLabel:SetText("Shared secret: |cffaa3333not set|r")
  else
    secretLabel:SetText(("Shared secret hash: |cff00ff00%s|r"):format(hash))
  end
  local mine, peer, unknown = CountChars()
  dataCount:SetText(("Characters in DB: %d mine, %d from paired account(s), %d unknown")
    :format(mine, peer, unknown))
end

panel:SetScript("OnShow", Refresh)

function addon:RefreshOptions()
  if panel and panel:IsShown() then Refresh() end
end

if Settings and Settings.RegisterCanvasLayoutCategory then
  local category = Settings.RegisterCanvasLayoutCategory(panel, "HelloStock")
  category.ID = "HelloStock"
  Settings.RegisterAddOnCategory(category)
  addon.OptionsCategoryID = category:GetID()
elseif InterfaceOptions_AddCategory then
  InterfaceOptions_AddCategory(panel)
end
