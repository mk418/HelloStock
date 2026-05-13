# HelloStock — Design Document

A lean, opinionated stockpile tracker for WoW Classic Era. Counts crafting ingredients and consumables across every character on your account and across one paired secondary account, with per-item target stock levels, at-a-glance color coding, and a stockpile breakdown appended to every item tooltip in the game.

---

## Design philosophy

1. **Curated, not customizable.** The tracked-item list is hand-picked and lives in `Items.lua`. Users can't add items. The set is what the author actually stockpiles; if you don't like it, fork it.
2. **One window, two tabs, inline editing.** No second screen, no popups for setting a target — type the number in the row. The settings panel is for pairing and a few visual toggles, nothing else.
3. **State is per-account.** Frame position, filter state, collapsed sections, targets, minimap visibility — all in the shared `HelloStockDB` so logging onto an alt picks up where you left off. The only per-character data is which character owns which bag/bank snapshot.
4. **No library dependencies.** Minimap button, tooltip hook, settings panel — all native. Libraries are a future-day-patch breakage surface; for an addon this small they're not worth it.
5. **Reliability over features.** Bag/bank scans run on Blizzard events (`BAG_UPDATE_DELAYED`, `BANKFRAME_OPENED`, `PLAYERBANKSLOTS_CHANGED`), tooltip extensions hook `OnTooltipSetItem`, sync goes over addon whispers. No frame walking, no monkey-patching, no polling.

---

## Layout

```
┌─ HelloStock ───────────────────────────────────────── × ┐
│ [Consumables] [Ingredients]                       [Sync]│
│                                                         │
│  ╭─ Search items... ─╮  [×]  ☐ In stock  ☐ With target  │
│  ╰───────────────────╯       ☐ Under target             │
│                                                         │
│  ▽ Flasks                                Stock   Target │
│  ──────────────────────────────────────────────────────┤│
│   🧪 Flask of the Titans                  3      [ 5 ]  │
│   🧪 Flask of Distilled Wisdom            0       [ ]   │
│                                                         │
│  ▽ Battle Elixirs                                       │
│  ──────────────────────────────────────────────────────┤│
│   🧪 Elixir of the Mongoose              22     [ 20 ]  │
│   🧪 Elixir of Greater Agility            5       [ ]   │
│   ...                                                   │
│                                                         │
│  ▷ Combat Potions                                       │
│                                                         │
└─────────────────────────────────────────────────────────┘
                                                  [⊙] ← minimap button
                                                       (toggleable)
```

- **Main frame:** 460×520, anchored to the right edge of the screen by default, draggable, position saved per-account.
- **Tabs:** Consumables (default) and Ingredients. Tab choice is session-local — no persistence — because it changes often during play.
- **Filter checkboxes:** "In stock", "With target", "Under target". Checked state persists. Cascade rule: checking "Under target" implies "With target"; unchecking "With target" clears "Under target".
- **Search:** substring match on item name (post-`GetItemInfo`). When a search is active, collapsed sections expand automatically for the search duration.
- **Categories:** rendered as collapsible group headers with arrow + "Stock"/"Target" column labels. Collapsed state persists per-tab.
- **Sync button:** only shown when a shared secret is set. Pushes a fresh snapshot to all paired-account characters.

---

## Per-row anatomy

```
┌──────────────────────────────────────────────────────────┐
│ 🧪 Item Name                          stock     [target] │
└──────────────────────────────────────────────────────────┘
```

| Element | Behavior |
|---|---|
| Icon | `GetItemInfo`-supplied texture; falls back to question-mark icon while async |
| Name | Game-supplied link with quality color; falls back to plain name |
| Stock count | Total across every owned + peer character on same faction + connected-realm cluster |
| Stock color | **green** ≥ target, **red** < target, **white** when no target set, **grey "-"** when no items and no target |
| Name/icon dimming | Both fade to ~50% alpha when count is zero *and* no target — quiet rows that don't matter |
| Target editbox | Numeric, 6 digits max. Empty = no target. Edits debounce a sync push 2s later |
| Tooltip on hover | Standard item tooltip + appended Stockpile section (driven by the same global hook below, so identical everywhere) |

### Stockpile tooltip section

Shown on every tooltip for tracked items — bag, bank, vendor, AH, trade window, chat link, mailbox, recipe reagent list, anywhere `GameTooltip:SetItem...` runs.

```
…item info…

Stockpile (47 total):
  Brokk-Greymane              22
  Thargas-Greymane            15
  Cor-Greymane                10    ← peer-account rows in grey
```

- Sorted by count descending.
- Mine-account rows in white, peer-account rows in grey (same `GameTooltipText` font for both, color is the only distinguisher).
- Rendered by hooking `OnTooltipSetItem` on `GameTooltip` and `ItemRefTooltip`. Re-applied on every tooltip rebuild — robust against item-info async loads and other tooltip addons that clear/redraw mid-hover.

---

## Sync model

Two-account sync designed for the common case: a primary account and one alt-army account, both on the same connected realm cluster, same faction.

```
   Account A                          Account B
┌──────────────┐                   ┌──────────────┐
│ accountID:Aa │                   │ accountID:Bb │
│ secret: "x"  │  ─── /hs pair ──▶ │ secret: "x"  │
│ hash: 1f3..  │                   │ hash: 1f3..  │
└──────┬───────┘                   └──────┬───────┘
       │                                  │
       │  ◀── addon whisper, hash ──▶     │
       │      snapshot { bags, bank,      │
       │                ts, accountID }   │
       │                                  │
       ▼                                  ▼
  HelloStockDB                       HelloStockDB
  characters[A's chars]              characters[A's chars]
  characters[B's chars]   ◀── sync ──▶ characters[B's chars]
```

### Pairing flow

1. `A` types `/hs pair <name-realm>` (or targets a player and types `/hs pair`).
2. `A`'s addon generates a 14-char secret if one isn't already set, then sends a pair-invite whisper to the target.
3. `B` sees a popup: *"HelloStock: accept pair invite from A? This sets your shared secret to theirs."*
4. On accept, `B`'s addon stores the secret and replies with a placeholder character entry so `A` knows where to send snapshots before `B` has scanned anything.
5. Both accounts now hash the shared secret with FNV-1a and stamp every outgoing message with that hash. Receivers drop messages whose hash doesn't match.

### Snapshot flow

- Bag scan runs on `BAG_UPDATE_DELAYED`; bank scan on `BANKFRAME_OPENED` + `PLAYERBANKSLOTS_CHANGED`.
- Each successful scan triggers a snapshot broadcast to every known peer character on the same faction + connected-realm cluster.
- Snapshots include only the curated tracked-item subset of bag contents — no general inventory exfiltration.
- Conflict resolution: incoming snapshots are dropped if their timestamp is older than the stored one. A defense-in-depth check also drops snapshots where a peer claims our own accountID for a char we own.
- Targets sync separately via a small `{ targets, ts }` payload, debounced 2s after edits, last-write-wins by timestamp.

### Scope rules

- **Same connected-realm cluster** — `GetAutoCompleteRealms()` defines the set.
- **Same faction** — `UnitFactionGroup("player")`.
- **Trusted hash** — message hash must match locally-stored `HashSecret(secret)`.

A character that satisfies all three is included in `GetTotals()` aggregation; a snapshot from such a peer is accepted.

---

## Slash commands

```
/hs                      open/close the window
/hs pair [name-realm]    send a pair invite (defaults to current target)
/hs secret [word]        view or set the shared secret directly
/hs unpair               clear secret + remove all peer-account characters
/hs sync                 force-push snapshots of every owned character
/hs status               print pairing state, peers, account ID
/hs whoami               print current character's identity for sanity
/hs chars                list every character in the DB with mine/peer tag
/hs claim <name>         re-stamp a character's accountID to mine
/hs claimall             claim every unowned character
/hs forget <name>        delete a character from the DB
/hs ping                 send a ping to every paired character
/hs minimap              toggle the minimap button
/hs resetpos             reset the window to default position
/hs config               open the options panel
/hs debug                toggle debug logging
/hs reset                wipe all stored data (popup confirm)
```

Both `/hs` and `/hellostock` are registered.

---

## Storage schema

Everything in one account-wide `HelloStockDB`. No per-character SV.

```lua
HelloStockDB = {
  accountID = "Hf7gB2nKp4MqR3xa",        -- random 16-char, stands in for the
                                          -- per-WoW-account ID Blizzard doesn't expose
  secret = "ChosenWord12",                -- shared with paired account (plain)
  debug = false,

  characters = {
    -- key: realm .. ":" .. faction .. ":" .. name
    ["Greymane:Horde:Brokk"] = {
      name = "Brokk", realm = "Greymane", faction = "Horde",
      accountID = "Hf7gB2nKp4MqR3xa",     -- whose char this is
      source = "self",                    -- or "sync"
      sourceSecret = nil,                 -- hash of secret that delivered it (peers only)
      bags = { [13510] = 5, [13511] = 12, ... },
      bank = { [13468] = 3, ... },
      bagsUpdated = 1715534512,
      bankUpdated = 1715534400,
    },
    ...
  },

  targets = { [13510] = 20, [13468] = 5, ... },
  targetsUpdatedAt = 1715534601,

  ui = {
    point      = { point="RIGHT", relPoint="RIGHT", x=-20, y=0 },
    collapsed  = { ["Consumables/Combat Potions"] = true, ... },
    filters    = { inStock=false, withTarget=true, underTarget=false },
  },

  minimap = { angle = 195, hide = false },
}
```

| Field | Notes |
|---|---|
| `accountID` | Generated once on first login. WoW exposes no per-license ID (BattleTag is shared across all WoW licenses on the same Bnet), so a random ID stored in SavedVariables substitutes. |
| `characters[key].source` | `"self"` if this char's accountID matches ours, `"sync"` if it arrived via addon whisper. |
| `characters[key].sourceSecret` | The hash of the secret in effect when this peer snapshot was received — defense in case the user rotates secrets. |
| `ui.collapsed[k]` | Key is `tab .. "/" .. category` (e.g. `Consumables/Flasks`). Renames of category strings orphan old keys, but they're harmless bytes. |
| `targets` | Account-wide, sync'd with peer. Last-write-wins by `targetsUpdatedAt`. |

### Why per-account, not per-character

Frame position, target levels, filter state, collapsed sections, pairing — none of these change meaningfully when you log onto an alt. Per-character storage would mean re-configuring every time, and the per-account scope is exactly what the cross-character aggregation needs to make sense. The only data with a per-character flavor is the bag/bank snapshot, which is keyed inside `characters[realm:faction:name]` rather than living in a separate `HelloStockCharDB`.

---

## Tooltip integration

```
GameTooltip:SetBagItem(bag, slot)
        │
        ▼  (Blizzard adds standard item lines)
        │
        ▼  fires OnTooltipSetItem
        │
        ▼  our hook: AppendStockpile(tooltip)
            │
            ├─ tooltip:GetItem() → link → itemID
            ├─ addon:IsTracked(itemID)?
            ├─ HasStockpileSection(tooltip)?  ← scan existing lines for our header
            │                                   to avoid duplicate append on rebuild
            ├─ append "Stockpile (N total):" + breakdown
            └─ tooltip:Show()   ← recompute size
```

Hooks both `GameTooltip` (bag/bank/vendor/AH/trade window/recipe reagents/etc.) and `ItemRefTooltip` (chat link clicks). The `HasStockpileSection` scan is the key reliability piece: tooltips get rebuilt mid-hover (item info finishes loading, other addons force a redraw, `OnUpdate` refresh) and our previously-appended lines get cleared. A naive "skip if itemID matches last seen" guard would block re-adding the section after a clear, producing a flicker. Scanning the live line list for our `Stockpile (N total):` header instead means: if the section is there, we skip; if it isn't (cleared by a rebuild), we re-add. Works regardless of hook ordering with other tooltip addons.

---

## File structure

```
HelloStock/
├── HelloStock.toc
├── Items.lua       -- curated tracked-item list (no other state)
├── Comm.lua        -- addon-whisper protocol: pair, snapshot, targets, ping
├── Core.lua        -- DB shape, bag/bank scan, account ID, secret hash,
│                   -- slash commands, GetTotals aggregation
├── Tooltip.lua     -- OnTooltipSetItem hook for GameTooltip + ItemRefTooltip
├── UI.lua          -- main window, tabs, rows, filters, target editing
├── Minimap.lua     -- native minimap button (no LibDBIcon)
└── Options.lua     -- Blizzard options panel
```

Each file owns one concern. `Core.lua` is the only one that touches `HelloStockDB` keys other than the file's own (UI owns `ui.*`, Minimap owns `minimap.*`, Core owns `characters` / `targets` / `secret` / `accountID` / `debug`).

---

## Item list

Lives in `Items.lua` as `addon.ITEMS = { Ingredients = { ... }, Consumables = { ... } }`. Two tabs, each a list of `{ category, items }` groups, each item `{ id, name }`. The `name` field is only a fallback for the brief window before `GetItemInfo` resolves the real game name; once resolved, the real name takes over. (This means an incorrect `id` will silently show the wrong item — flag and re-`/reload` if rows look off after edits.)

### Ordering convention

Within each group, items are ordered **greatest tier first, smallest tier last**. For paired-tier items (Heavy Runecloth + Runecloth, Greater Frost Protection + Frost Protection, Mithril Bar + Mithril Ore), the higher/refined member comes first. Items without a tier ladder (different schools, different stats) are grouped by their type and that type's items appear contiguously. Protection Potions specifically are alphabetised by school (Arcane → Shadow), with Greater + regular adjacent per school.

This is the only ordering rule. There's no alphabetical sort, no auto-detection of tier — the order in `Items.lua` is the order in the UI.

---

## Boot sequence

```
1. .toc loads SavedVariables (HelloStockDB) from disk into the global
2. Items.lua    → addon.ITEMS populated
3. Comm.lua     → registers C_ChatInfo prefix, addon-whisper dispatch
4. Core.lua     → bag/bank event frame, slash commands; defers DB
                  initialisation to PLAYER_LOGIN
5. Tooltip.lua  → hooks OnTooltipSetItem on GameTooltip + ItemRefTooltip
6. UI.lua       → creates the (hidden) main frame; defers position +
                  filter restore to OnShow
7. Minimap.lua  → creates the button; defers position + visibility
                  to PLAYER_LOGIN
8. Options.lua  → registers options category
9. ADDON_LOADED fires (after all files)
10. PLAYER_LOGIN fires (later) → addon:GetAccountID(), EnsureDB(),
                                 PrimeItemCache(), UpdateBags(),
                                 Minimap position+visibility, Options.Refresh
11. User types /hs → UI:Show → OnShow → RestoreUIPosition + LoadFilters +
                     ApplyFilterCheckboxes + Refresh
```

### Why state restores happen at `OnShow` / `PLAYER_LOGIN`, not at file load

In Classic Era, SavedVariables for an addon are *not* fully populated by the time the addon's `.lua` files run. Initial reads of `HelloStockDB.ui.point` / `.filters` at file-load time return `nil`, because the SV restore happens between file load and `ADDON_LOADED`. The same caused a real bug in development: filter checkbox state appeared not to persist across `/reload`. The fix was to read at `OnShow` (UI) and `PLAYER_LOGIN` (Minimap), both of which are guaranteed-after-SV-restore points.

`UIStore()` and `MinimapStore()` are written defensively (`HelloStockDB = HelloStockDB or {}`) so writes during file-load still go to the right table — the SV-restored data merges into the lazily-created `{}` and `HelloStockDB` ends up pointing to the merged table.

---

## Window position handling

WoW has a built-in per-character layout cache (`WTF/Account/<acct>/<realm>/<char>/layout-local.txt`) that automatically persists positions of named frames parented to `UIParent` that move via `StartMoving`/`StopMovingOrSizing`. This is *not* what we want here — the per-account UI state should follow you to alts. So:

```lua
UI:SetUserPlaced(false)        -- once at init
UI:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  self:SetUserPlaced(false)    -- reset after each drag (Blizzard sets it true on stop)
  SaveUIPosition()             -- → HelloStockDB.ui.point
end)
```

`SetUserPlaced(false)` opts out of Blizzard's layout cache; our own save/restore takes over. `RestoreUIPosition()` runs on every `OnShow` so a fresh login picks up the saved coordinates.

---

## Minimap button

Native implementation, no LibDBIcon. 31×31 button parented to `Minimap`, anchored by angle (degrees, default `195` = lower-left). Radius computed live as `Minimap:GetWidth() / 2 + 5`, so the button sits just outside the minimap edge regardless of minimap size (other addons may have rescaled it).

- Left-click toggles the main window.
- Right-click opens the options panel.
- Drag re-positions around the edge (angle persisted to `HelloStockDB.minimap.angle`).
- Visibility toggled by checkbox in the options panel or `/hs minimap`. Default: shown.

LibDBIcon would have been the standard choice but adds a library dependency for ~50 lines of avoidable logic and a minimap-shape lookup table we don't need (only round minimaps are supported).

---

## Reliability practices

- **Curated item set, not user-extensible.** No runtime mutation of the item list means no risk of corrupt entries, no schema migration, and a much smaller test surface.
- **No frame walking, no method patching.** The addon never reaches into `_G.SomeFrame.something` or overrides Blizzard methods. The tooltip hook uses `HookScript`, not `SetScript`-replacement.
- **All tooltip lines self-identified.** Our header text (`"Stockpile (N total):"`) is unique enough that scanning for it as a duplicate-append guard works reliably even when other tooltip addons coexist.
- **All sync inputs validated.**
  - Timestamps compared (older snapshots dropped).
  - Secret hashes compared (mismatched-hash messages dropped).
  - Ownership-protection check (peers can't overwrite a char we marked as ours).
- **Defense-in-depth around accountID.** A character entry has an `accountID` field that survives unpair → re-pair cycles; mine/peer ownership reads from this rather than from the live secret, so changing the secret doesn't reclassify existing characters.
- **No combat-restricted operations.** No `SecureFrame` mutation, no protected attributes. The addon is purely informational; the UI can be opened, closed, and dragged mid-pull without issue.

---

## Install

```sh
ln -s /Users/Drikk/code/Drikk/HelloStock \
  ~/Applications/World\ of\ Warcraft/_classic_era_/Interface/AddOns/HelloStock
```

Adjust the WoW path for your install. If the addon shows "Out of Date," check `/dump (select(4, GetBuildInfo()))` in-game and update `## Interface:` in the TOC.

---

## Implemented

### Core
- [x] Bag + bank scan, tracked-item filter, per-character snapshot storage
- [x] Connected-realm + faction-scoped aggregation (`GetTotals`)
- [x] Random per-account ID generation (BattleTag-decoupled)
- [x] FNV-1a secret hash (`HashSecret`)
- [x] Slash command suite (pair / secret / unpair / sync / status / whoami / chars / claim / claimall / forget / ping / debug / minimap / resetpos / config / reset)

### UI
- [x] Main window with Consumables/Ingredients tabs (Consumables default)
- [x] Per-row icon / name / count / target editbox with color-coded count
- [x] Inline target editing with 2s-debounced sync push
- [x] Collapsible category groups, per-tab persisted collapsed state
- [x] Search box (substring match on item name)
- [x] Filter checkboxes: In stock / With target / Under target; persisted; under-target ⇄ with-target cascade
- [x] Sync button (visible only when paired)
- [x] Frame draggable, position persisted account-wide, layout-cache opt-out
- [x] `OnShow` lazy-load for position + filters (works around SV-restore timing)
- [x] Right-anchored default position with `Reset position` button + `/hs resetpos`

### Tooltips
- [x] Stockpile section appended to every tracked-item tooltip via `OnTooltipSetItem` on `GameTooltip` + `ItemRefTooltip`
- [x] Header-scan dedup that re-adds after tooltip rebuilds (item-info async, other addons forcing redraws)
- [x] Mine-account rows in white, peer-account rows in grey, sorted by count descending

### Sync
- [x] Pair invite + popup accept flow (`/hs pair`)
- [x] Snapshot broadcast on every bag/bank scan, scoped to faction + connected realms
- [x] Targets sync (debounced) with last-write-wins by timestamp
- [x] Peer placeholder records so a fresh paired char becomes reachable before its first snapshot
- [x] `/hs sync` force-push, `/hs ping` reachability test
- [x] Ownership defense: peer cannot overwrite a self-owned character

### Minimap button
- [x] Native 31×31 button, angle-based anchor adapting to live minimap width
- [x] Left-click toggle, right-click options, drag to re-position
- [x] Visibility + angle persisted; toggle via options panel or `/hs minimap`

### Options panel
- [x] Blizzard-integrated panel (new Settings API + legacy fallback)
- [x] "Show minimap button" and "Enable debug logging" toggles
- [x] "Reset position" button (window position)
- [x] "Reset everything" button (full DB wipe via popup confirm)
- [x] Live secret-hash + account ID + DB stats display

### Items
- [x] Curated Ingredients tab: Herbs, Ores & Bars, Leather & Hides, Cloth, Elemental, Enchanting
- [x] Curated Consumables tab: Utility, Flasks, Battle Elixirs, Guardian Elixirs, Combat Potions, Protection Potions, Food & Drink, Jujus, Weapon Buffs, Bandages
- [x] Greatest-tier-first ordering throughout, with paired Heavy/Greater + regular variants

### Mail & money
- [x] Inbox scan via `MAIL_SHOW` / `MAIL_INBOX_UPDATE` / `MAIL_CLOSED`: items into `c.mail`, attached gold (not-yet-taken) into `c.mailMoney`
- [x] Outgoing-mail capture via `PreClick` on `SendMailMailButton` + `MAIL_SEND_SUCCESS`: items into `c.outbox`, gold into `c.moneyOutbox`. Scoped to recipients matching a stored character (`IsKnownChar`); sends to non-tracked names leave the pool normally
- [x] Recipient-aware prune: in-transit entries kept until `recipient.mailUpdated >= sentAt + 60min` (proof of receipt), 30-day hard cap matching WoW's auto-return-to-sender window
- [x] Recipient attribution: tooltip / breakdown rows show in-transit on the receiving character, not the sender
- [x] Wallet tracker (`c.money`) updated on `PLAYER_MONEY`; `GetTotalMoney` aggregates wallet + inbox + transit
- [x] Sync extends the snapshot payload with `mail=`/`mts=`/`mmny=` and `out=`/`mout=`/`ots=`; missing fields preserve existing buckets so older peers don't blow away your data
- [x] `Unpair` and `/hs forget` drop orphaned outbox entries pointing to removed characters
- [x] Footer line in the main window with formatted gold total + per-character breakdown tooltip (in-mail / in-transit annotations)

### Packaging
- [x] `.toc` with `## SavedVariables: HelloStockDB` and `## X-Curse-Project-ID`
- [x] BigWigs packager `.pkgmeta` for CurseForge release
- [x] GitHub release workflow

---

## Deliberately out of scope

### Auction-house listings

Items you list on the AH are intentionally treated as gone from the stockpile. The mental model is **intent**: listing is a declaration of "I don't want this anymore, get me gold instead." The bag count dropping is the correct signal — folding listings back into the totals would make the addon nag you to re-stock items you've explicitly decided to sell.

This is also why mail between own characters *is* tracked: mailing to an alt is moving the stockpile around, not exiting it. The transience is similar but the intent is opposite.

A reasonable counter-argument is "what about raw ingredients listed speculatively that I'd cancel and use if a craft demands them?" — but that workflow is rare, and the clean exit-on-list signal serves the common case (selling surplus past your target levels) much better than a per-tab toggle would. If you want listed items back in your pool, cancel the auction.

---

## TODO

### Items
- [ ] Verify all item IDs against current Classic Era item DB (several IDs in this design were typed from memory and corrected after `/reload` testing — there may be a few that haven't been hit yet)

### Reliability
- [ ] First-load schema migration logic if anything in `HelloStockDB` ever needs renaming (currently stale keys are harmless but accumulate)
- [ ] PTR smoke test before each Classic Era patch (load, scan, sync handshake, tooltip extension, minimap drag, /reload mid-edit)

---

## Known issues

### Item ID typos surface as the wrong row name

`Items.lua` ships `{ id = ..., name = "..." }` pairs. The `name` field is only a *fallback* for the brief window between `/reload` and `GetItemInfo` resolving. Once the cache has the real game name for that ID, that's what renders — so a typo'd ID silently displays whatever item that ID actually is. (We hit this with the regular-tier Frost/Shadow/Holy Protection Potions: the visual list looked "mixed-up" because three IDs each pointed at a different school than labelled. Diagnosis was straightforward once we realised `name = "..."` is cosmetic.)

Fix path: when a row's text doesn't match the label after `/reload`, look up the correct ID on Wowhead Classic and swap.

### Per-character layout-cache may pre-pollute new installs

Users upgrading from a pre-`SetUserPlaced(false)` version of HelloStock may have a stale entry in `WTF/Account/<acct>/<realm>/<char>/layout-local.txt`. Our code overwrites the position on `OnShow`, so the stale cache entry never visibly takes effect, but the file still carries the bytes. Harmless; deleting the file is optional.

### No way to ignore a single character

`/hs forget <name>` removes a character from the DB, but if the character is still logged in elsewhere and pushing snapshots over sync, it'll re-appear within seconds. The intended workflow is `/hs forget` *after* the character has been logged off, or `/hs unpair` if you want to drop everything from the peer account.
