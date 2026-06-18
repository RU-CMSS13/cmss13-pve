# VARIOUS FIXES PORTING MAP

Master porting map for all upstream PRs ported into BandaTroopers from CM-PVE and CM-PVE-HALO repositories.

## Document Hierarchy

- [`CM_PVE_PORT_STATE.md`](CM_PVE_PORT_STATE.md) — canonical tracking for CM-PVE PRs (21 PRs, all PORTED)
- [`HALO_PORT_STATE.md`](../halo/__docs/HALO_PORT_STATE.md) — canonical tracking for CM-PVE-HALO PRs (27 PRs, all PORTED)
- [`HALO_PORT_BACKLOG.md`](../halo/__docs/HALO_PORT_BACKLOG.md) — implementation batches and backlog for HALO content
- [`CM_PVE_PORT_AUDIT_PLAN.md`](CM_PVE_PORT_AUDIT_PLAN.md) — reproducible CM-PVE parity, asset, sound, map, and modularity audit plan
- [`HALO_PVE_PORT_AUDIT_PLAN.md`](../halo/__docs/HALO_PVE_PORT_AUDIT_PLAN.md) — reproducible CM-PVE-HALO parity, asset, sound, map, and modularity audit plan
- **This file** — historical context, split decisions, and cross-references

---

## PR #102: Comprehensive Upstream Sync (`halo-pve-update-batch1-3b`)

### Scope

- **CM-PVE**: 21 PRs (#1264–#1289) — all PORTED
- **CM-PVE-HALO**: 27 PRs (#137–#180) — all PORTED
- **Branch**: `halo-pve-update-batch1-3b`
- **PR**: https://github.com/ss220club/BandaTroopers/pull/102
- **Last sync commit**: `5f1e274056` (2026-06-09)
- **Latest HALO upstream refresh**: `cmss13-devs/cmss13-pve-halo/master @ 60dd61b32df3c9f4b6ed0f646743ce8884399e43` (2026-06-18)

### CM-PVE PRs (21)

| PR | Title | Type | Key Changes |
|----|-------|------|-------------|
| #1289 | Observer Faction Categories | Code | Orbit menu faction categories |
| #1288 | Anti Air - GM Choice | Code | GM verb for AA launcher |
| #1287 | Gas Mask Vision Impairment | Code | Vision impair + scope allowance |
| #1284 | Lazy Bunker Shipmaps | Maps | uscm_bunker, upp_bunker |
| #1283 | Movie-ish Sections | Code + Maps | chapaev_movie, golden_arrow_movie, new roles |
| #1282 | The Straya War | Code | TWE warcry sounds |
| #1280 | Dog war atomized | Code + Maps | golden_arrow_dog_war, M38 ammo, dog war MRE; local-fallback DMI states are documented in `CM_PVE_PORT_STATE.md` |
| #1278 | Call ur hits | Code | LARP/airsoft items |
| #1277 | Movie-like Xeno Castes | Code | Buffed Runner/Drone/Soldier/Lurker/Crusher |
| #1276 | FV150 'Hobelar' | Code | TWE tank/APC |
| #1275 | Vanguard's Arrow | Code | VAI faction clothing |
| #1273 | Gibson & Kloos | Code | Bodyburster/Lanky castes |
| #1272 | Koishi's landmines | Code | New mine types |
| #1271 | Itsy Bitsy Buggers | Code | Spider/Lizard castes |
| #1270 | Featueless | Maps | Featureless biomes |
| #1269 | Snowman | Code | CANC presets |
| #1268 | Active prox_sensor | Code | Proximity sensor UI |
| #1267 | Wolfpack | Code | Wolfpack APC |
| #1266 | D66-44 | Code | Ridgeway tank |
| #1265 | Auriga's Folly | Code | Hybrid species |
| #1264 | Shipmap lighting GM verb | Code | GM lighting verb |

### CM-PVE-HALO PRs (27)

See [`HALO_PORT_STATE.md`](../halo/__docs/HALO_PORT_STATE.md) for full table.

2026-06-18 refresh:

- Fresh post-`787d28227b` CM-PVE-HALO PRs #152, #159, #180, #162, #185, #170, #173, and #172 were rechecked against BT modular paths.
- Residual gaps from #151 and #161 were fixed in BT.
- `sound/weapons/halo/gun_plasmarifle_triplefire.ogg` was imported to `modular/halo/sound/weapons/gun_plasmarifle_triplefire.ogg` as a byte-exact upstream sound asset; it has no live reference at the time of import.

### Path Remapping Rules

- All upstream `modular_pve_halo/` paths → `modular/halo/`
- Root `icons/halo/` paths → `modular/halo/icons/**`
- Root HALO sound paths → `modular/halo/sound/**`
- All `code/**` changes require `SS220 EDIT` markers

### Validation

- **Compile**: `BUILD.cmd` — 0 errors, 0 warnings
- **SS220 EDIT audit (code/)**: All files properly marked
- **modular_pve_halo/ path audit**: 0 occurrences
- **Root icons/halo/ path audit**: 0 occurrences
- **Binary assets**: 12 .dmi icons + 9 .ogg sounds downloaded from upstream
- **Files changed**: 56 files, +4541/-312 lines

---

## Historical: HALO Follow-up Apr2026 (PR #94 / PR #96)

### Source of Truth

- Upstream repo: `https://github.com/cmss13-devs/cmss13-pve-halo`
- Latest historical PR94 verification fetch: `cm-pve-halo/master` at `2ec6b82a5b` (2026-04-27)
- Latest PR102/HALO refresh fetch: `cm-pve-halo/master` at `60dd61b32df3c9f4b6ed0f646743ce8884399e43` (2026-06-18)
- Merged BT baseline: `ss220club/BandaTroopers#93`
- Base main-wave branch: `ss220club/master` at `66bf244f0ecf925736d9081053d35abb59fb6c6e`

### Main Wave Scope (PR #96)

1. `cmss13-pve-halo#46` — Mackay lighting tail, ONI Digsite shuttle IDs
2. `cmss13-pve-halo#126` — r_wall/bunker/hull, New Irvine auto-turfs
3. `cmss13-pve-halo#134` — ONI Shield Base
4. `cmss13-pve-halo#135` — Valorous Chant
5. `cmss13-pve-halo#136` — 686 Regretful Flame
6. `cmss13-pve-halo#139` — Covenant landmines
7. `cmss13-pve-halo#140` — Weapon sprite/state wave
8. `cmss13-pve-halo#141` — Shrapnel/projectile follow-up
9. `cmss13-pve-halo#143` — BR55 recoil follow-up
10. `cmss13-pve-halo#145` — Bumblebee escape pod
11. `cmss13-pve-halo#146` — UNSC helmet motion sensor HUD
12. `cmss13-pve-halo#137` — Audit-only modularization
13. `cmss13-pve-halo#113` — Prime rolling removal
14. `cmss13-pve-halo#118` — Flavor fixes
15. `cmss13-pve-halo#129` — Covenant HAI/faction split
16. `cmss13-pve-halo#132` — Covenant AI rate-of-fire limits
17. `cmss13-pve-halo#138` — Covenant gear update
18. `cmss13-pve-halo#142` — Pelican roof fix (audited)
19. `cmss13-pve-halo#144` — CODEOWNERS/changelog (no-op)

### PR94 Update Scope

Branch `halo_jackal_spartan_wave_apr2026`:
- Kig-Yar/Unggoy tail from `PR #97`
- Spartan base from `#100`
- Branch-local gameplay completion for Kig-Yar, Sangheili, Unggoy, Spartan
- Preset/HumanAI/squad coverage

### Follow-up Ports (2026-05-02)

- `PR #149` — RTO and ODST SL fixes (modular proc overrides)
- `PR #146/#150` — Motion sensor refresh, universal naming refresh
- `PR #148` — Grenade throwback rules (brain capability flag)

### Key Hotspots

1. HALO UNSC guns/magazines are owned by granular files under `modular/halo/code/modules/projectiles/guns/{rifle,smg,pistol,shotgun,specialist,magazines}/`; legacy aggregate files were removed.
2. `modular/halo/code/game/objects/items/weapons/halo_shields.dm`
3. `modular/halo/code/modules/gear_presets/Halo/{ruuhtian,unggoy}.dm`
4. `code/game/objects/items/explosives/mine.dm`
5. `code/datums/ammo/shrapnel.dm`
6. `code/modules/projectiles/projectile.dm`
7. `code/modules/mob/living/carbon/human/ai/defense_creator.dm`
8. `maps/map_files/halo_new_irvine_covenant/`
9. `maps/shuttles/bumblebee_west.dmm`
10. `modular/halo/code/modules/shuttle/halo/bumblebee.dm`
11. `code/_onclick/hud/human.dm`
12. `modular/halo/code/mixed/components/halo_motion_sensor.dm`

---

## Update Protocol

- When new upstream PRs are ported, update this file with the batch context.
- If this file disagrees with older port notes, [`CM_PVE_PORT_STATE.md`](CM_PVE_PORT_STATE.md) and [`HALO_PORT_STATE.md`](../halo/__docs/HALO_PORT_STATE.md) win.
