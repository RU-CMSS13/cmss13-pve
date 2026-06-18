# HALO PORT BACKLOG

Active tracking document for the HALO PVE update task on BandaTroopers.

## Current Track

- Source repositories:
  - `https://github.com/cmss13-devs/cmss13-pve-halo` (CM-PVE-HALO)
  - `https://github.com/cmss13-devs/cmss13-pve` (CM-PVE)
- Current merged BT master baseline: `upstream/master @ 5d2ad73b68727b88c7b02cf005a4af72f855babd` (PR #96)
- Target upstream master: `60dd61b32d`
- Active task: **COMPLETED** — Comprehensive upstream sync: all 48 must-port PRs from CM-PVE and CM-PVE-HALO ported into [`modular/halo`](modular/halo) and `code/**` (with SS220 EDIT markers)
- Completion PR: [#102](https://github.com/ss220club/BandaTroopers/pull/102) — `halo-pve-update-batch1-3b`
- Porting date: 2026-06-05
- Task-state contract: [`modular/__agents/.AI_AGENT/PLAN.md`](../../__agents/.AI_AGENT/PLAN.md), [`TODO.md`](../../__agents/.AI_AGENT/TODO.md), [`DECISIONS.md`](../../__agents/.AI_AGENT/DECISIONS.md), [`EVIDENCE.md`](../../__agents/.AI_AGENT/EVIDENCE.md)
- Current audit plans: [`HALO_PVE_PORT_AUDIT_PLAN.md`](HALO_PVE_PORT_AUDIT_PLAN.md) and [`CM_PVE_PORT_AUDIT_PLAN.md`](../../__docs/CM_PVE_PORT_AUDIT_PLAN.md)

## Historical Context

- Previous task: PR #94 refresh after PR #96 merge (completed, see git history)
- 2026-04-28 modular asset audit completed (HALO assets moved to `modular/halo/icons/**` and `modular/halo/sound/**`)
- PR #102 ported merged PRs from CM-PVE-HALO (#137, #153, #154, #170, #173, #162, #156 core preset/vendor/med file set)
- 2026-06-05: All 48 must-port PRs ported and validated (compile 0 errors, maplint OK, path audit OK)
- Current task: **COMPLETED** — upstream refresh to `60dd61b32d` with targeted residual fixes and validation
- 2026-06-18: Upstream refresh from `787d28227b` to `60dd61b32d`; post-target HALO PRs #152, #159, #180, #162, #185, #170, #173, and #172 rechecked. Residual gaps from #151 and #161 were fixed, and `gun_plasmarifle_triplefire.ogg` was imported as a byte-exact modular sound asset. `BUILD.cmd` passed with 0 errors and 0 warnings.

## Implementation Batches

### Batch 1: CM-PVE-HALO Priority 1 (Trivial/Small)
- **Status**: PORTED (2026-06-05, PR #102)
- **PRs**:
  - #167 Muzzle Flash Attach Fix (1 line)
  - #164 Titan rename to Voyager (7 lines)
  - #155 ODST Drop Pod Intro Blurb (12 lines)
  - #152 Fences (6 lines)
  - #171 Shipmap lighting verb (38 lines)
- **Dependencies**: None
- **Stop criteria**: ✅ All 5 PRs ported, compile check passes, no upstream path references remain

### Batch 2: CM-PVE-HALO Priority 2 (Medium)
- **Status**: PORTED (2026-06-05, PR #102)
- **PRs**:
  - #143 BR55 Recoil (gameplay fix)
  - #165 SPNKR A-A Random Outcome
  - #163 Halo Minimap Fix
  - #176 Thermite Grenades
  - #179 CE-like uniforms
  - #159 Shotgun & sniper ammo boxes (item/code only)
- **Dependencies**: Batch 1 complete
- **Stop criteria**: ✅ All 6 PRs ported, compile check passes, gameplay balance reviewed

### Batch 3: CM-PVE-HALO Priority 3 (Large)
- **Status**: PORTED (2026-06-05, PR #102)
- **PRs**:
  - #166 ODST VISR (163 lines)
  - #178 Chemlights & Flares (379 lines)
  - #174 UNSC loose-ammo packets (326 lines)
  - #158 Fire Support Binos Support (543 lines)
  - #157 UNSC Medals Enabled (688 lines)
  - #150 Loadout selection changes (686 lines)
  - #160 Holy Redoubts (3300 lines, map templates)
- **Dependencies**: Batch 2 complete
- **Stop criteria**: ✅ All 7 PRs ported, compile check passes, map validation for #160, loadout system tested

### Batch 4: CM-PVE Must-Port
- **Status**: PORTED (2026-06-05, PR #102)
- **PRs**:
  - #1289 Observer Faction Categories (+37/-1, QoL)
  - #1288 Anti Air - GM Choice (+143/-23, SPNKR AA)
  - #1287 Gas Mask Vision Impairment (+41/-3, balance)
- **Dependencies**: Batch 3 complete (to avoid conflicts with HALO changes)
- **Stop criteria**: ✅ All 3 PRs ported, compile check passes, GM verbs tested
- **Note**: These PRs modify `code/**` and require `SS220 EDIT` markers

### Batch 5: CM-PVE Full Port (Expanded)
- **Status**: PORTED (2026-06-05, PR #102)
- **PRs**:
  - #1284 Lazy Bunker Shipmaps (maps + code)
  - #1283 Movie-ish Sections (maps + code)
  - #1282 The Straya War (TWE warcry sounds)
  - #1280 Dog war atomized (maps + code)
  - #1278 Call ur hits (LARP items)
  - #1277 Movie-like Xeno Castes (buffed castes)
  - #1276 FV150 'Hobelar' (TWE tank)
  - #1275 Vanguard's Arrow (VAI clothing)
  - #1273 Gibson & Kloos (Bodyburster/Lanky)
  - #1272 Koishi's landmines (new mines)
  - #1271 Itsy Bitsy Buggers (Spider/Lizard)
  - #1270 Featueless (featureless maps)
  - #1269 Snowman (CANC presets)
  - #1268 Active prox_sensor (proximity sensor)
  - #1267 Wolfpack (Wolfpack APC)
  - #1266 D66-44 (Ridgeway tank)
  - #1265 Auriga's Folly (hybrid species)
  - #1264 Shipmap lighting GM verb
- **Dependencies**: Batch 4 complete
- **Stop criteria**: ✅ All 18 PRs ported, SS220 EDIT markers added, compile check passes

### Batch 6: Final Validation and Docs Sync
- **Status**: COMPLETED (2026-06-05, PR #102)
- **Actions**:
  - Full compile check with `BUILD.cmd` or `tools/build/build`
  - Update [`HALO_PORT_STATE.md`](HALO_PORT_STATE.md) with new baseline
  - Update [`CM_PVE_PORT_STATE.md`](../../__docs/CM_PVE_PORT_STATE.md) with new baseline
  - Update [`VARIOUS_FIXES_PORTING_MAP.md`](../../__docs/VARIOUS_FIXES_PORTING_MAP.md) with PR #102 context
  - Update task-state files with implementation status
  - Old path audit: verify no `modular_pve_halo/` or root `icons/halo/` references remain
  - Map validation for PR #160 (Holy Redoubts)
  - Loadout system test for PR #150
  - GM verb test for CM-PVE PRs #1288, #1289

## Previously Ported PRs (from PR #102)
- #137 Weapon Modularization (split/adapt)
- #153 `iscovenant` typecheck
- #154 New UNSC grenades
- #183 UNSC/ODST flags and banners
- #185 Specialist items indestructible
- #186 UNSC headsets default tracks
- #170 New covenant squads
- #173 Unggoy plasma grenade loadouts
- #162 Elite Hero subtypes
- #156 Presets/vendor/med updates (core file set)

## Path Remapping Rules
- All upstream `modular_pve_halo/` paths remap to [`modular/halo`](modular/halo)
- Root `icons/halo/` paths remap to [`modular/halo/icons/**`](../icons)
- Root HALO sound paths remap to [`modular/halo/sound/**`](../sound)
- Minimal glue changes in [`code/**`](../../code) require `SS220 EDIT` markers per [`SS220_DEVELOPMENT_RULES.md`](../../__docs/SS220_DEVELOPMENT_RULES.md)

## Explicit Non-Goals
- Do not replace split/adapt with wrapper, fallback, or compatibility patch
- Do not leave upstream `modular_pve_halo/` paths in ported code
- Do not use root `icons/halo/` or root HALO sound paths for new/ported assets
- Do not blindly duplicate existing covenant content
- Do not collapse HALO modular code back into `code/**`
- Do not reintroduce wholesale upstream layout just to mirror filenames
- Do not skip compile check after any batch
- Do not replace path remapping with runtime translation

## Known Technical Debt (from PR #102 review)

| # | Item | Path | Severity | Plan |
|---|------|------|----------|------|
| T1 | HALO `cov` icon_state in shared root DMI | [`icons/turf/areas.dmi`](../../icons/turf/areas.dmi) | Medium | Extract to separate modular DMI per [`HALO_PORT_STATE.md:30`](HALO_PORT_STATE.md:30) — "HALO-only states must not be injected into existing generic root .dmi files" |
| T2 | Legacy map imports use root `icons/turf/` | [`halo_imported_map_windows.dm`](../code/mixed/structures/halo_imported_map_windows.dm), [`halo_imported_map_turfs.dm`](../code/mixed/turfs/halo_imported_map_turfs.dm), [`halo_imported_map_walls.dm`](../code/mixed/turfs/halo_imported_map_walls.dm) | Low | New Varadero assets — not HALO-specific, shared with other maps. Migration requires cross-map coordination. |

## Remaining Root Glue To Watch
- `code/game/sound.dm`: routes shared sound keys to modular HALO voice files
- `code/modules/mob/living/carbon/human/{emote,human_attackhand,human_defense,human_helpers}.dm`: shared species/combat hooks
- `code/modules/projectiles/{gun,gun_helpers,projectile}.dm`: shared Gun Ho and Mjolnir integration hooks
- `code/modules/mob/living/carbon/human/ai/action_datums/{mg_nest,sniper_nest}.dm`: Game Master menu exposure
- `code/modules/mob/living/carbon/human/death.dm`: pre-existing shared Warthog death/ejection callsite
- `code/__DEFINES/bandamarines/halo_species_support.dm`: shared compile-time HALO constants

## Completion Check
- ✅ All must-port PRs are ported with correct path remapping
- ✅ No upstream `modular_pve_halo/` paths remain in ported code
- ✅ No root `icons/halo/` or root HALO sound paths are used for new/ported assets
- ✅ All `code/**` changes have `SS220 EDIT` markers
- ✅ All ported files compile cleanly (0 errors, 0 warnings)
- ✅ `HALO_PORT_STATE.md` reflects the new baseline
- ✅ `CM_PVE_PORT_STATE.md` reflects the new baseline
- ✅ `VARIOUS_FIXES_PORTING_MAP.md` updated with PR #102 context
- ✅ Task-state files are updated with implementation status
- ✅ Map validation passes for PR #160 (all 14 templates OK)
- ✅ Loadout system works after PR #150
- ✅ GM verbs work after CM-PVE PRs #1288, #1289

## PR Summary Table

### CM-PVE-HALO Must-Port (27 PRs)
| Priority | PR | Title | Lines | Risk | Status |
| --- | --- | --- | --- | --- | --- |
| 1 | #167 | Muzzle Flash Attach Fix | 1 | Low | PORTED (2026-06-05) |
| 1 | #164 | Titan rename to Voyager | 7 | Low | PORTED (2026-06-05) |
| 1 | #155 | ODST Drop Pod Intro Blurb | 12 | Low | PORTED (2026-06-05) |
| 1 | #152 | Fences | 6 | Low | PORTED (2026-06-05) |
| 1 | #171 | Shipmap lighting verb | 38 | Low-Medium | PORTED (2026-06-05) |
| 2 | #143 | BR55 Recoil | - | Medium | PORTED (2026-06-05) |
| 2 | #165 | SPNKR A-A Random Outcome | - | Medium | PORTED (2026-06-05) |
| 2 | #163 | Halo Minimap Fix | - | Medium | PORTED (2026-06-05) |
| 2 | #176 | Thermite Grenades | - | Medium | PORTED (2026-06-05) |
| 2 | #179 | CE-like uniforms | - | Medium | PORTED (2026-06-05) |
| 2 | #159 | Shotgun & sniper ammo boxes (item/code only) | - | Medium | PORTED (2026-06-05) |
| 3 | #166 | ODST VISR | 163 | High | PORTED (2026-06-05) |
| 3 | #178 | Chemlights & Flares | 379 | High | PORTED (2026-06-05) |
| 3 | #174 | UNSC loose-ammo packets | 326 | High | PORTED (2026-06-05) |
| 3 | #158 | Fire Support Binos Support | 543 | High | PORTED (2026-06-05) |
| 3 | #157 | UNSC Medals Enabled | 688 | High | PORTED (2026-06-05) |
| 3 | #150 | Loadout selection changes | 686 | High | PORTED (2026-06-05) |
| 3 | #160 | Holy Redoubts | 3300 | Very High | PORTED (2026-06-05) |
| 4 | #180 | Wort wort wort, lohbaba! | - | Low | PORTED (2026-06-05) |
| 4 | #172 | RTO-bag sprite issues | - | Low | PORTED (2026-06-05) |
| 4 | #169 | Featureless Biomes | - | Low | PORTED (2026-06-05) |
| 4 | #170 | New covenant squads | - | Medium | PORTED (2026-06-05) |
| 4 | #173 | Plasma grenade loadouts for Unggoy | - | Medium | PORTED (2026-06-05) |
| 4 | #162 | Elite "Hero" subtypes | - | Medium | PORTED (2026-06-05) |
| 4 | #156 | Presets updates, Vendor tweaks (core file set) | - | Medium | PORTED (2026-06-05) |
| 4 | #168 | Jumping and Leaping | - | Low | ALREADY PRESENT |
| 4 | #145 | bumblebee | - | Low | ALREADY PRESENT |

### CM-PVE Must-Port (21 PRs)
See [`CM_PVE_PORT_STATE.md`](../../__docs/CM_PVE_PORT_STATE.md) for full table.

| PR | Title | Lines | Risk | Status |
| --- | --- | --- | --- | --- |
| #1289 | Observer Faction Categories | +37/-1 | Low | PORTED (2026-06-05) |
| #1288 | Anti Air - GM Choice | +143/-23 | Medium | PORTED (2026-06-05) |
| #1287 | Gas Mask Vision Impairment | +41/-3 | Low-Medium | PORTED (2026-06-05) |
| #1284 | Lazy Bunker Shipmaps | - | Low | PORTED (2026-06-05) |
| #1283 | Movie-ish Sections | - | Medium | PORTED (2026-06-05) |
| #1282 | The Straya War | - | Low | PORTED (2026-06-05) |
| #1280 | Dog war atomized | - | High | PORTED (2026-06-05) |
| #1278 | Call ur hits | +104 | Low | PORTED (2026-06-05) |
| #1277 | Movie-like Xeno Castes | - | Medium | PORTED (2026-06-05) |
| #1276 | FV150 'Hobelar' | - | High | PORTED (2026-06-05) |
| #1275 | Vanguard's Arrow | - | Low | PORTED (2026-06-05) |
| #1273 | Gibson & Kloos | - | High | PORTED (2026-06-05) |
| #1272 | Koishi's landmines | - | Medium | PORTED (2026-06-05) |
| #1271 | Itsy Bitsy Buggers | - | Medium | PORTED (2026-06-05) |
| #1270 | Featueless | - | Low | PORTED (2026-06-05) |
| #1269 | Snowman | +565/-3 | Medium | PORTED (2026-06-05) |
| #1268 | Active prox_sensor | +16 | Low | PORTED (2026-06-05) |
| #1267 | Wolfpack | - | High | PORTED (2026-06-05) |
| #1266 | D66-44 | - | High | PORTED (2026-06-05) |
| #1265 | Auriga's Folly | - | Medium | PORTED (2026-06-05) |
| #1264 | Shipmap lighting GM verb | +28/-3 | Low | PORTED (2026-06-05) |
