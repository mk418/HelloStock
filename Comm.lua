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

-- Outbox records ("id:count:sentAt:to", comma-separated). The recipient name
-- is needed on the receiving peer so it can decide whether to keep showing
-- the entry as in-transit (recipient hasn't scanned mail yet) or drop it
-- (recipient's mailUpdated proves they've seen it). Character names in WoW
-- don't contain ':' or ',', so no escaping is required.
local function EncodeOutbox(list)
  if not list then return "" end
  local parts = {}
  for _, e in ipairs(list) do
    parts[#parts + 1] = (e.id or 0) .. ":" .. (e.count or 0) .. ":"
                     .. (e.sentAt or 0) .. ":" .. (e.to or "")
  end
  return table.concat(parts, ",")
end

local function DecodeOutbox(s)
  local out = {}
  if not s or s == "" then return out end
  for entry in s:gmatch("[^,]+") do
    local id, count, sentAt, to = entry:match("(%d+):(%d+):(%d+):(.*)")
    if id then
      out[#out + 1] = {
        id     = tonumber(id),
        count  = tonumber(count),
        sentAt = tonumber(sentAt),
        to     = to,
      }
    end
  end
  return out
end

-- Professions: "name:skill:max" triples. Name is localized so it can contain
-- non-ASCII bytes; ':' and ',' aren't used in any WoW profession name. Use a
-- non-greedy match in the decoder so multi-word names like "First Aid"
-- (if a future build adds it) parse cleanly.
local function EncodeProfessions(list)
  if not list then return "" end
  local parts = {}
  for _, p in ipairs(list) do
    parts[#parts + 1] = (p.name or "?") .. ":" .. (p.skill or 0) .. ":" .. (p.max or 0)
  end
  return table.concat(parts, ",")
end

local function DecodeProfessions(s)
  local out = {}
  if not s or s == "" then return out end
  for entry in s:gmatch("[^,]+") do
    local name, skill, max = entry:match("^(.-):(%d+):(%d+)$")
    if name and name ~= "" then
      out[#out + 1] = { name = name, skill = tonumber(skill), max = tonumber(max) }
    end
  end
  return out
end

-- Gold outbox: "copper:sentAt:to" triples. Parallel to EncodeOutbox; same
-- shape minus the itemID, so peers can run the same recipient-aware prune.
local function EncodeMoneyOutbox(list)
  if not list then return "" end
  local parts = {}
  for _, e in ipairs(list) do
    parts[#parts + 1] = (e.copper or 0) .. ":" .. (e.sentAt or 0) .. ":" .. (e.to or "")
  end
  return table.concat(parts, ",")
end

local function DecodeMoneyOutbox(s)
  local out = {}
  if not s or s == "" then return out end
  for entry in s:gmatch("[^,]+") do
    local copper, sentAt, to = entry:match("(%d+):(%d+):(.*)")
    if copper then
      out[#out + 1] = {
        copper = tonumber(copper),
        sentAt = tonumber(sentAt),
        to     = to,
      }
    end
  end
  return out
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
    "mail=" .. EncodeItems(c.mail),
    "mts="  .. (c.mailUpdated or 0),
    "mmny=" .. (c.mailMoney or 0),
    "out="  .. EncodeOutbox(c.outbox),
    "mout=" .. EncodeMoneyOutbox(c.moneyOutbox),
    "ots="  .. (c.outboxUpdated or 0),
    "crft=" .. EncodeIDs(c.crafts),
    "mny="  .. (c.money or 0),
    "cls="  .. (c.class or ""),
    "lvl="  .. (c.level or 0),
    "prof=" .. EncodeProfessions(c.professions),
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

  -- Also send targets + ignore list so both stay in sync.
  Comm:SendTargets()
  Comm:SendIgnoreList()
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

  local whisperTargets = addon:GetWhisperTargets()
  if #whisperTargets == 0 then return end

  local bucket = addon:GetTargets()
  local parts = {}
  for id, t in pairs(bucket.items) do
    parts[#parts + 1] = id .. ":" .. t
  end
  local payload = table.concat({
    "v=" .. PROTO_VERSION,
    "ts=" .. (bucket.updatedAt or 0),
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

function Comm:SendIgnoreList()
  local hash = addon:GetSecretHash()
  if hash == "" then return end
  local whisperTargets = addon:GetWhisperTargets()
  if #whisperTargets == 0 then return end

  -- Per-entry timestamps so both sides can merge ignores/unignores without
  -- losing data. Format per entry: "key:addedAt:removedAt", entries
  -- comma-separated. Tombstones (removedAt > addedAt) are included so the
  -- peer can apply removals too.
  local parts = {}
  if HelloStockDB and HelloStockDB.ignored then
    local fallbackTs = HelloStockDB.ignoredUpdatedAt or 0
    for key, value in pairs(HelloStockDB.ignored) do
      local addedAt, removedAt
      if type(value) == "table" then
        addedAt, removedAt = value.addedAt or 0, value.removedAt or 0
      else
        addedAt, removedAt = fallbackTs, 0
      end
      parts[#parts + 1] = key .. ":" .. addedAt .. ":" .. removedAt
    end
  end
  local payload = table.concat({
    "v="       .. PROTO_VERSION,
    "entries=" .. table.concat(parts, ","),
  }, FIELD_SEP)

  nextReqID = (nextReqID % 65535) + 1
  local reqID  = nextReqID
  local chunks = Chunk(payload)
  local total  = #chunks
  for i, ck in ipairs(chunks) do
    local msg = ("X|%d|%d|%d|%s|%s"):format(reqID, i, total, hash, ck)
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

-- True only while we're actively receiving (inbound chunks being assembled).
-- Used by the UI's sync-spinner: outbound queue drain happens whether or not
-- the peer is online, so polling that for a "syncing" indicator misleads the
-- user when the peer is offline. Inbound activity unambiguously means a peer
-- is talking back to us.
function Comm:IsReceiving()
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
    name          = fields.n,
    realm         = fields.r,
    faction       = fields.f,
    accountID     = (fields.a ~= "" and fields.a) or nil,
    ts            = tonumber(fields.ts) or 0,
    bags          = DecodeItems(fields.bag),
    bank          = DecodeItems(fields.bnk),
    mail          = fields.mail and DecodeItems(fields.mail) or nil,
    mailUpdated   = tonumber(fields.mts) or 0,
    mailMoney     = tonumber(fields.mmny),  -- nil if absent → preserve existing
    outbox        = fields.out and DecodeOutbox(fields.out) or nil,
    moneyOutbox   = fields.mout and DecodeMoneyOutbox(fields.mout) or nil,
    outboxUpdated = tonumber(fields.ots) or 0,
    crafts        = DecodeIDs(fields.crft),
    money         = tonumber(fields.mny) or 0,
    class         = (fields.cls ~= "" and fields.cls) or nil,
    level         = tonumber(fields.lvl),
    professions   = fields.prof and DecodeProfessions(fields.prof) or nil,
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

  elseif t == "X|" then
    local reqID, idx, total, senderHash, data =
      msg:match("^X|(%d+)|(%d+)|(%d+)|([^|]+)|(.*)$")
    if not reqID then return end
    if not addon:IsTrustedHash(senderHash) then return end
    reqID, idx, total = tonumber(reqID), tonumber(idx), tonumber(total)
    local bufKey = sender .. ":X:" .. reqID
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
        local entries = {}
        if fields.entries and fields.entries ~= "" then
          for chunk in fields.entries:gmatch("[^,]+") do
            -- Key may contain '-' (it's name-realm) but never ':'.
            local key, addedAt, removedAt = chunk:match("^(.-):(%d+):(%d+)$")
            if key then
              entries[#entries + 1] = {
                key       = key,
                addedAt   = tonumber(addedAt),
                removedAt = tonumber(removedAt),
              }
            end
          end
        elseif fields.keys and fields.keys ~= "" then
          -- Backward compat with the prior whole-list format. Use the
          -- payload's ts as addedAt; no tombstones in that protocol.
          local ts = tonumber(fields.ts) or 0
          for key in fields.keys:gmatch("[^,]+") do
            entries[#entries + 1] = { key = key, addedAt = ts, removedAt = 0 }
          end
        end
        addon:ReceiveIgnoreList({ entries = entries })
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
