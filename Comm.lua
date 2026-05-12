local _, addon = ...

local PREFIX        = "HSTOCK"
local PROTO_VERSION = 1
local CHUNK_SIZE    = 220
local MIN_SEND_GAP  = 3
local SEND_INTERVAL = 0.5
local FIELD_SEP     = ";"

local Comm = CreateFrame("Frame")
addon.Comm = Comm

local incoming     = {}
local lastSentAt   = 0
local pendingTimer = nil
local nextReqID    = 0
local sendQueue    = {}
local sendTimer    = nil

local function MyContext()
  return UnitName("player"), GetRealmName(), UnitFactionGroup("player")
end

local function EncodeItems(t)
  if not t then return "" end
  local parts = {}
  for id, count in pairs(t) do
    parts[#parts + 1] = id .. ":" .. count
  end
  return table.concat(parts, ",")
end

local function DecodeItems(s)
  local t = {}
  if not s or s == "" then return t end
  for pair in s:gmatch("[^,]+") do
    local id, count = pair:match("(%d+):(%d+)")
    if id then t[tonumber(id)] = tonumber(count) end
  end
  return t
end

local function EncodeIDs(set)
  if not set then return "" end
  local parts = {}
  for id in pairs(set) do parts[#parts + 1] = tostring(id) end
  return table.concat(parts, ",")
end

local function DecodeIDs(s)
  local t = {}
  if not s or s == "" then return t end
  for id in s:gmatch("%d+") do t[tonumber(id)] = true end
  return t
end

local function BuildPayload(c)
  return table.concat({
    "v="    .. PROTO_VERSION,
    "n="    .. (c.name or ""),
    "r="    .. (c.realm or ""),
    "f="    .. (c.faction or "Neutral"),
    "a="    .. (c.accountID or ""),
    "ts="   .. (c.bagsUpdated or 0),
    "bag="  .. EncodeItems(c.bags),
    "bnk="  .. EncodeItems(c.bank),
    "crft=" .. EncodeIDs(c.crafts),
  }, FIELD_SEP)
end

local function OwnedChars()
  local out = {}
  if not HelloStockDB or not HelloStockDB.characters then return out end
  local _, _, myFaction = MyContext()
  myFaction = myFaction or "Neutral"
  local realmSet = addon:ConnectedRealmSet()
  local myID = addon:GetAccountID()
  for _, c in pairs(HelloStockDB.characters) do
    if c.accountID == myID
       and c.name and c.name ~= ""
       and c.realm and c.realm ~= ""
       and c.faction == myFaction
       and realmSet[addon:NormalizeRealm(c.realm)] then
      out[#out + 1] = c
    end
  end
  return out
end

local function Chunk(s)
  local out = {}
  for i = 1, #s, CHUNK_SIZE do
    out[#out + 1] = s:sub(i, i + CHUNK_SIZE - 1)
  end
  return out
end

local function FlushQueue()
  sendTimer = nil
  local item = table.remove(sendQueue, 1)
  if not item then return end
  local ok
  if item.channel == "WHISPER" then
    ok = C_ChatInfo.SendAddonMessage(PREFIX, item.msg, "WHISPER", item.target)
  else
    ok = C_ChatInfo.SendAddonMessage(PREFIX, item.msg, item.channel)
  end
  if #sendQueue > 0 then
    sendTimer = C_Timer.NewTimer(SEND_INTERVAL, FlushQueue)
  end
end

local function Queue(msg, channel, target)
  sendQueue[#sendQueue + 1] = { msg = msg, channel = channel, target = target }
  if not sendTimer then
    sendTimer = C_Timer.NewTimer(0, FlushQueue)
  end
end

local function DoSend()
  pendingTimer = nil
  lastSentAt = GetTime()

  local hash = addon:GetSecretHash()
  if hash == "" then
    if HelloStockDB and HelloStockDB.debug then
      print("|cffaa3333[HS send]|r aborted: no shared secret set. Use /hs secret <word>")
    end
    return
  end

  local chars = OwnedChars()
  if #chars == 0 then return end

  local whisperTargets = addon:GetWhisperTargets()
  if #whisperTargets == 0 then
    if HelloStockDB and HelloStockDB.debug then
      print("|cffaa3333[HS send]|r aborted: no paired characters in DB yet.")
    end
    return
  end

  for _, c in ipairs(chars) do
    local payload = BuildPayload(c)
    nextReqID = (nextReqID % 65535) + 1
    local reqID  = nextReqID
    local chunks = Chunk(payload)
    local total  = #chunks
    for i, ck in ipairs(chunks) do
      local msg = ("S|%d|%d|%d|%s|%s"):format(reqID, i, total, hash, ck)
      for _, target in ipairs(whisperTargets) do
        Queue(msg, "WHISPER", target)
      end
    end
  end

  -- Also send targets so target stock levels stay in sync.
  Comm:SendTargets()
end

function Comm:SendSnapshot(force)
  if #addon:GetWhisperTargets() == 0 then return end
  if force then
    if pendingTimer then pendingTimer:Cancel(); pendingTimer = nil end
    DoSend()
    return
  end
  local wait = MIN_SEND_GAP - (GetTime() - lastSentAt)
  if wait <= 0 then
    DoSend()
  elseif not pendingTimer then
    pendingTimer = C_Timer.NewTimer(wait, DoSend)
  end
end

function Comm:SendTargets()
  local hash = addon:GetSecretHash()
  if hash == "" then return end
  HelloStockDB = HelloStockDB or {}
  HelloStockDB.targets = HelloStockDB.targets or {}

  local whisperTargets = addon:GetWhisperTargets()
  if #whisperTargets == 0 then return end

  local parts = {}
  for id, t in pairs(HelloStockDB.targets) do
    parts[#parts + 1] = id .. ":" .. t
  end
  local payload = table.concat({
    "v=" .. PROTO_VERSION,
    "ts=" .. (HelloStockDB.targetsUpdatedAt or 0),
    "tgts=" .. table.concat(parts, ","),
  }, FIELD_SEP)

  nextReqID = (nextReqID % 65535) + 1
  local reqID  = nextReqID
  local chunks = Chunk(payload)
  local total  = #chunks
  for i, ck in ipairs(chunks) do
    local msg = ("T|%d|%d|%d|%s|%s"):format(reqID, i, total, hash, ck)
    for _, target in ipairs(whisperTargets) do
      Queue(msg, "WHISPER", target)
    end
  end
end

function Comm:SendPing()
  local targets = addon:GetWhisperTargets()
  if #targets == 0 then return false end
  local msg = "Z|" .. (UnitName("player") or "?")
  for _, t in ipairs(targets) do Queue(msg, "WHISPER", t) end
  return true, #targets
end

local function MyPairInfo(secret)
  local name, realm, faction = MyContext()
  return ("%s|%s|%s|%s|%s"):format(
    name or "?",
    realm or "?",
    faction or "Neutral",
    addon:GetAccountID() or "",
    secret or "")
end

function Comm:SendPairInvite(targetName, secret)
  Queue("I|" .. MyPairInfo(secret), "WHISPER", targetName)
end

function Comm:SendPairReply(targetName)
  -- No secret in the reply; just our identity so the initiator can record us as a peer.
  Queue("J|" .. MyPairInfo(""), "WHISPER", targetName)
end

function Comm:PendingSends()
  return #sendQueue
end

-- True if any sync activity is currently in flight: outbound packets queued or
-- scheduled, or inbound chunks waiting to be reassembled.
function Comm:IsBusy()
  if #sendQueue > 0 or sendTimer or pendingTimer then return true end
  for _ in pairs(incoming) do return true end
  return false
end

local function DebugDrop(name, reason)
  if HelloStockDB and HelloStockDB.debug then
    print(("|cffaa3333[HS drop]|r %s: %s"):format(tostring(name), reason))
  end
end

local function HandleSnapshot(buf, senderHash)
  local fields = {}
  for line in buf:gmatch("[^;]+") do
    local k, v = line:match("^(%w+)=(.*)$")
    if k then fields[k] = v end
  end
  if tonumber(fields.v or "") ~= PROTO_VERSION then
    DebugDrop(fields.n, "wrong protocol version (got '" .. tostring(fields.v) .. "')")
    return
  end
  if not fields.n or fields.n == ""
     or not fields.r or fields.r == ""
     or not fields.f then
    DebugDrop(fields.n, "missing required fields (n='" .. tostring(fields.n) ..
      "', r='" .. tostring(fields.r) .. "')")
    return
  end

  local myName, myRealm, myFaction = MyContext()
  local myAccountID  = addon:GetAccountID()
  local incomingAcct = fields.a or ""
  if fields.n == myName
     and addon:NormalizeRealm(fields.r) == addon:NormalizeRealm(myRealm or "")
     and incomingAcct == myAccountID then
    DebugDrop(fields.n, "matches my own current character on this account")
    return
  end
  if fields.f ~= (myFaction or "Neutral") then
    DebugDrop(fields.n, "faction mismatch (snap=" .. fields.f .. ", mine=" .. tostring(myFaction) .. ")")
    return
  end
  if not addon:ConnectedRealmSet()[addon:NormalizeRealm(fields.r)] then
    DebugDrop(fields.n, "realm " .. fields.r .. " not in my connected set")
    return
  end

  local snap = {
    name      = fields.n,
    realm     = fields.r,
    faction   = fields.f,
    accountID = (fields.a ~= "" and fields.a) or nil,
    ts        = tonumber(fields.ts) or 0,
    bags      = DecodeItems(fields.bag),
    bank      = DecodeItems(fields.bnk),
    crafts    = DecodeIDs(fields.crft),
  }
  if HelloStockDB and HelloStockDB.debug then
    print(("|cff888888[HS recv]|r %s-%s"):format(tostring(snap.name), tostring(snap.realm)))
  end
  addon:ReceiveSnapshot(snap, senderHash)
end

local function OnAddonMessage(prefix, msg, channel, sender)
  if prefix ~= PREFIX then return end
  local t = msg:sub(1, 2)

  if t == "S|" then
    local reqID, idx, total, senderHash, data =
      msg:match("^S|(%d+)|(%d+)|(%d+)|([^|]+)|(.*)$")
    if not reqID then
      if HelloStockDB and HelloStockDB.debug then
        print(("|cffaa3333[HS chunk]|r regex failed from %s"):format(tostring(sender)))
      end
      return
    end
    if not addon:IsTrustedHash(senderHash) then
      if HelloStockDB and HelloStockDB.debug then
        print(("|cffaa3333[HS chunk]|r secret mismatch from %s (theirs %s, mine %s)"):format(
          tostring(sender), senderHash, addon:GetSecretHash()))
      end
      return
    end
    reqID, idx, total = tonumber(reqID), tonumber(idx), tonumber(total)

    local bufKey = sender .. ":" .. reqID
    local buf = incoming[bufKey]
    if not buf then
      buf = { chunks = {}, total = total, received = 0, firstSeen = GetTime(), senderHash = senderHash }
      incoming[bufKey] = buf
    end
    if not buf.chunks[idx] then
      buf.chunks[idx] = data
      buf.received = buf.received + 1
    end
    if HelloStockDB and HelloStockDB.debug then
      print(("|cff888888[HS chunk]|r req=%d %d/%d (have %d) from %s"):format(
        reqID, idx, total, buf.received, tostring(sender)))
    end
    if buf.received >= buf.total then
      incoming[bufKey] = nil
      local full = {}
      for i = 1, buf.total do full[i] = buf.chunks[i] or "" end
      HandleSnapshot(table.concat(full), buf.senderHash)
    end

    -- Drop stale (incomplete) reassembly buffers, and report them.
    local now = GetTime()
    for k, b in pairs(incoming) do
      if b.firstSeen and (now - b.firstSeen) > 30 then
        if HelloStockDB and HelloStockDB.debug then
          print(("|cffaa3333[HS stale]|r %s incomplete %d/%d, dropping"):format(k, b.received, b.total))
        end
        incoming[k] = nil
      end
    end

  elseif t == "T|" then
    local reqID, idx, total, senderHash, data =
      msg:match("^T|(%d+)|(%d+)|(%d+)|([^|]+)|(.*)$")
    if not reqID then return end
    if not addon:IsTrustedHash(senderHash) then return end
    reqID, idx, total = tonumber(reqID), tonumber(idx), tonumber(total)
    local bufKey = sender .. ":T:" .. reqID
    local buf = incoming[bufKey]
    if not buf then
      buf = { chunks = {}, total = total, received = 0, firstSeen = GetTime() }
      incoming[bufKey] = buf
    end
    if not buf.chunks[idx] then
      buf.chunks[idx] = data
      buf.received = buf.received + 1
    end
    if buf.received >= buf.total then
      incoming[bufKey] = nil
      local full = table.concat({ unpack(buf.chunks, 1, buf.total) })
      local fields = {}
      for line in full:gmatch("[^;]+") do
        local k, v = line:match("^(%w+)=(.*)$")
        if k then fields[k] = v end
      end
      if tonumber(fields.v or "") == PROTO_VERSION then
        local tgts = {}
        if fields.tgts and fields.tgts ~= "" then
          for pair in fields.tgts:gmatch("[^,]+") do
            local id, val = pair:match("(%d+):(%d+)")
            if id then tgts[tonumber(id)] = tonumber(val) end
          end
        end
        addon:ReceiveTargets({ ts = tonumber(fields.ts) or 0, targets = tgts })
      end
    end

  elseif t == "Z|" then
    local senderName = msg:match("^Z|(.+)$") or "?"
    print(("|cffffd700HelloStock:|r ping from %s (channel=%s)"):format(senderName, tostring(channel)))

  elseif t == "I|" then
    -- New format: I|name|realm|faction|accountID|secret
    local n, r, f, a, s = msg:match("^I|([^|]+)|([^|]+)|([^|]+)|([^|]*)|(.+)$")
    if n and r and f and s then
      StaticPopup_Show("HELLOSTOCK_PAIR_INVITE", n, nil,
        { sender = n, realm = r, faction = f, accountID = (a ~= "" and a) or nil, secret = s })
      return
    end
    -- Legacy format: I|name|secret
    local senderName, secret = msg:match("^I|([^|]+)|(.+)$")
    if not senderName or not secret then return end
    StaticPopup_Show("HELLOSTOCK_PAIR_INVITE", senderName, nil,
      { sender = senderName, secret = secret })

  elseif t == "J|" then
    -- Pair-accept reply: J|name|realm|faction|accountID|
    local n, r, f, a = msg:match("^J|([^|]+)|([^|]+)|([^|]+)|([^|]*)|?")
    if not n or not r or not f then return end
    addon:RecordPeerPlaceholder(n, r, f, (a ~= "" and a) or nil)
  end
end

-- Swallow "No player named 'X' is currently playing." system messages when X
-- is one of our paired-account sync targets. Offline peers are routine after
-- login (PLAYER_ENTERING_WORLD triggers a snapshot broadcast to every peer
-- character); manual whispers from the user stay visible because we only
-- suppress when the named player matches a known sync target.
local notFoundPattern do
  local fmt = ERR_CHAT_PLAYER_NOT_FOUND_S or "No player named '%s' is currently playing."
  local templated = fmt:gsub("%%s", "\1")  -- placeholder safe from pattern escaping
  local escaped   = templated:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
  notFoundPattern = "^" .. escaped:gsub("\1", "(.+)") .. "$"
end

local function BaseName(s)
  return (s and s:match("^([^%-]+)")) or s
end

local function IsKnownSyncTarget(name)
  if not addon.GetWhisperTargets then return false end
  local base = BaseName(name)
  for _, target in ipairs(addon:GetWhisperTargets()) do
    if target == name or BaseName(target) == base then return true end
  end
  return false
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, message)
  local missing = message and message:match(notFoundPattern)
  if missing and IsKnownSyncTarget(missing) then
    return true  -- suppress
  end
end)

C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
Comm:RegisterEvent("CHAT_MSG_ADDON")
Comm:RegisterEvent("PLAYER_ENTERING_WORLD")

Comm:SetScript("OnEvent", function(_, event, ...)
  if event == "CHAT_MSG_ADDON" then
    OnAddonMessage(...)
  elseif event == "PLAYER_ENTERING_WORLD" then
    if #addon:GetWhisperTargets() > 0 then
      C_Timer.After(2, function() Comm:SendSnapshot() end)
    end
  end
end)
