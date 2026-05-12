HelloStock
==========

A lean, opinionated stockpile tracker for WoW Classic Era — counts crafting ingredients and consumables across every character on your account and across paired accounts, with per-item target stock levels and at-a-glance color coding.

> **Heads up** — this is a personal work in progress. I build and evolve it as I play, so features land when I need them, design choices reflect my play style, and things may change between releases. Feel free to give it a whirl and leave me some feedback, but don't expect changes that fit your play style if it doesn't fit mine.

Caveats
-------

*   Only works on Classic Era, no support for other game versions.
*   Curated default item list. Not user-extensible.
*   Cross-account sync uses addon whispers, gated by a shared secret.
*   Sync is scoped to the **same faction** and the **connected-realm cluster** you're currently logged in on.
*   Target stock levels sync between paired accounts. Last-write-wins by timestamp.
*   Pairing: target a player and `/hs pair`, or `/hs pair CharName[-Realm]`. The recipient sees a popup; on accept, both sides are wired up.
*   Opinionated defaults. One main window with two tabs and inline target editing.

License
-------

Released under the [MIT License](LICENSE).
