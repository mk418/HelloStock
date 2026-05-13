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

-- Minimap button toggle
local minimapCheck = CreateFrame("CheckButton", "HelloStockOptMinimap", panel, "InterfaceOptionsCheckButtonTemplate")
minimapCheck:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -2, -12)
_G["HelloStockOptMinimapText"]:SetText("Show minimap button")
minimapCheck:SetScript("OnClick", function(self)
  if addon.SetMinimapHidden then
    addon:SetMinimapHidden(not self:GetChecked())
  end
end)

-- Auto-add paired-account characters to friends list. Off by default;
-- toggling on syncs immediately, and SyncPeerFriends also runs after
-- PLAYER_LOGIN and on each peer-snapshot receive.
local autoFriendCheck = CreateFrame("CheckButton", "HelloStockOptAutoFriend", panel, "InterfaceOptionsCheckButtonTemplate")
autoFriendCheck:SetPoint("TOPLEFT", minimapCheck, "BOTTOMLEFT", 0, -4)
_G["HelloStockOptAutoFriendText"]:SetText("Add paired-account characters to friends list automatically")
autoFriendCheck:SetScript("OnClick", function(self)
  HelloStockDB = HelloStockDB or {}
  HelloStockDB.autoFriendPeers = self:GetChecked() and true or false
  if HelloStockDB.autoFriendPeers and addon.SyncPeerFriends then
    local n = addon:SyncPeerFriends()
    if n > 0 then
      print(("|cffffd700HelloStock:|r added %d paired character(s) to your friends list."):format(n))
    end
  end
end)

-- Debug logging
local debugCheck = CreateFrame("CheckButton", "HelloStockOptDebug", panel, "InterfaceOptionsCheckButtonTemplate")
debugCheck:SetPoint("TOPLEFT", autoFriendCheck, "BOTTOMLEFT", 0, -4)
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

-- Window section
local windowHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
windowHeader:SetPoint("TOPLEFT", unpairBtn, "BOTTOMLEFT", 0, -20)
windowHeader:SetText("Window")

local resetPosBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
resetPosBtn:SetSize(130, 22)
resetPosBtn:SetPoint("TOPLEFT", windowHeader, "BOTTOMLEFT", 0, -8)
resetPosBtn:SetText("Reset position")
resetPosBtn:SetScript("OnClick", function()
  if addon.UI and addon.UI.ResetPosition then
    addon.UI:ResetPosition()
    print("|cffffd700HelloStock:|r window position reset to default.")
  end
end)

-- Data section
local dataHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
dataHeader:SetPoint("TOPLEFT", resetPosBtn, "BOTTOMLEFT", 0, -20)
dataHeader:SetText("Data")

local dataCount = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
dataCount:SetPoint("TOPLEFT", dataHeader, "BOTTOMLEFT", 0, -8)

-- Reset only the current (faction, connected-realm) scope: drops every
-- character snapshot and target on that scope, leaves the rest of the DB
-- untouched. Slash equivalent: /hs resetscope.
local resetScopeBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
resetScopeBtn:SetSize(150, 22)
resetScopeBtn:SetPoint("TOPLEFT", dataCount, "BOTTOMLEFT", 0, -12)
resetScopeBtn:SetText("Reset this scope")
resetScopeBtn:SetScript("OnClick", function() StaticPopup_Show("HELLOSTOCK_RESET_SCOPE") end)

local resetBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
resetBtn:SetSize(130, 22)
resetBtn:SetPoint("LEFT", resetScopeBtn, "RIGHT", 8, 0)
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
  autoFriendCheck:SetChecked(HelloStockDB and HelloStockDB.autoFriendPeers or false)
  minimapCheck:SetChecked(addon.IsMinimapHidden and not addon:IsMinimapHidden() or true)
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
