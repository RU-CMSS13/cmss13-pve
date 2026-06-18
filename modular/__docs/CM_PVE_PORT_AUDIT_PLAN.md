# CM-PVE PORT AUDIT PLAN

Reproducible audit plan for the CM-PVE part of BandaTroopers PR #102.

This document is a plan, not a completion record. The status source of truth
remains [`CM_PVE_PORT_STATE.md`](CM_PVE_PORT_STATE.md). The cross-project map is
[`VARIOUS_FIXES_PORTING_MAP.md`](VARIOUS_FIXES_PORTING_MAP.md).

## Audit Target

- BandaTroopers PR: <https://github.com/ss220club/BandaTroopers/pull/102>
- Current observed PR head: `37590aa0dd5da5317d833b90ef0a7946bf67bd2e`
- CM-PVE upstream: <https://github.com/cmss13-devs/cmss13-pve>
- Local branch: `halo-pve-update-batch1-3b`

## Non-Goals

- Do not fix implementation during the audit-planning pass.
- Do not infer DMI parity from file presence alone.
- Do not mark a PR as fully audited until code paths, assets, maps/configs,
  docs, and relevant verification gates are checked.
- Do not treat compile success as proof that DMI states or sound references are
  correct.

## Source List Reconciliation

Before per-PR verification, build a single CM-PVE source list from:

1. PR #102 body.
2. `CM_PVE_PORT_STATE.md`.
3. `VARIOUS_FIXES_PORTING_MAP.md`.
4. GitHub changed-file list for PR #102.
5. Local `origin/master...HEAD` diff.
6. Upstream CM-PVE pull requests and merge commits.

Current known mismatch:

- `VARIOUS_FIXES_PORTING_MAP.md` still describes 21 CM-PVE PRs.
- `CM_PVE_PORT_STATE.md` currently lists 30 total entries.
- The audit must classify whether each extra entry is a later addition, legacy
  map-related PR, duplicate, or documentation drift.

## Audit Phases

### Phase 1: PR Manifest

For every CM-PVE PR in the reconciled source list:

- record upstream PR number, title, merge/head commit, and changed files;
- classify changed files as DM, DME, DMI, OGG/WAV, DMM, JSON, tgui, docs, or
  no-op;
- map upstream file paths to BandaTroopers target paths;
- record whether the target owner is `modular/cm_pve/**`, `code/**`, root
  `icons/**`, root `sound/**`, maps, map config, or tgui.

Acceptance:

- every claimed CM-PVE PR has one manifest row;
- every upstream binary asset has an expected local owner;
- every "already present" or "local fallback" claim has explicit evidence.

### Phase 2: Modularity and Include Graph

Check the modular split:

- pure CM-PVE implementation should live in `modular/cm_pve/**` when it is not
  required as shared glue;
- `code/**` changes must be limited to shared upstream diff, integration glue,
  or unavoidable root contracts;
- HALO-specific content must not live in `modular/cm_pve/**`;
- moved files must be included through `modular/modular.dme` and
  `modular/cm_pve/_cm_pve.dme`;
- no dead duplicate `code/**` implementation should remain reachable when a
  modular file owns the behavior.

Read-only commands to use:

```powershell
rg -n "modular/cm_pve|modular/halo|#include" colonialmarines.dme colonialmarines.test.dme modular/modular.dme modular/cm_pve/_cm_pve.dme modular/halo/_halo.dme
rg -n "SS220 EDIT" code map_config
rg -n "modular/halo" modular/cm_pve code/modules/vehicles/twe_tank code/modules/clothing/under/vai.dm
```

Acceptance:

- every included CM-PVE modular file is reachable once;
- every retained root `code/**` CM-PVE change has a reason and SS220 EDIT
  markers when required;
- `modular/cm_pve/**` has no HALO-only implementation.

### Phase 3: DMI File and State Parity

For every upstream DMI touched by a CM-PVE PR:

- compare upstream and local file ownership;
- record whether a byte-exact match is expected or a local superset/fallback is
  expected;
- dump upstream and local icon_state manifests;
- compare required icon_state presence, not only file presence;
- check states referenced by DM, DMM, JSON, overlay code, `item_state`,
  `worn_state`, `handful_state`, and HUD/radial code.

High-risk CM-PVE asset groups:

- PR #1280: Dog War clothing, MRE, ammo, attachments, fallback PMC/WY states.
- PR #1278: LARP/airsoft hand sprites and crosses.
- PR #1267/#1266/#1276: vehicle DMIs and hardpoint/interior states.
- PR #1257: `icons/mob/hud/screen2_full.dmi` local superset.
- PR #1255: UPP/CANC camouflage clothing and onmob states.
- Xeno PRs #1271/#1273/#1277: xeno caste DMIs and typecheck/caste state usage.

Acceptance:

- every upstream-required state is present in the local target DMI;
- every local fallback state is documented as fallback and not falsely
  attributed to upstream;
- root generic DMI modifications are justified as shared CM-PVE content or
  recorded as follow-up debt.

### Phase 4: Sound Parity

For every upstream sound touched by a CM-PVE PR:

- compare filename, expected local path, and reference path;
- verify every referenced sound path exists in the working tree;
- classify root sounds as shared upstream assets or forbidden port leaks;
- compare hashes where byte-exact parity is expected.

Known CM-PVE sound groups:

- PR #1288: SPNKR AA lock/crash/damage/fail sounds.
- PR #1282: TWE warcry sounds.
- PR #1280: dropship/gun-related sounds if referenced by ported code.

Acceptance:

- no sound reference points at a missing file;
- root sound additions are either documented shared assets or moved/remapped;
- duplicate root and modular copies are either justified or removed in a later
  implementation task.

### Phase 5: Maps and Configs

For every CM-PVE map/config PR:

- compare upstream DMM/JSON/map_config file presence;
- validate JSON keys that BT requires, including `nightmare_path`, map name,
  faction fields, weather/camouflage/webmap fields where applicable;
- check DMM references to icons, areas, turfs, decals, and templates;
- compare `map_config/maps.txt`, `map_config/shipmaps.txt`, and related ignore
  lists if map rotation/test matrix changes.

High-risk map PRs:

- #1284 Lazy Bunker Shipmaps.
- #1283 Movie-ish Sections.
- #1280 Dog War map.
- #1270 Featureless maps.
- #1253 Tethered USS Rover.

Acceptance:

- map configs reference existing JSON/DMM files;
- DMM referenced DMI/icon_state pairs exist;
- maplint/build verification is selected for every map-sensitive fix.

### Phase 6: Code Behavior and Review Threads

For every PR with DM/tgui behavior changes:

- compare upstream intent with local implementation;
- check callsites and side effects;
- verify any intentional divergence has a documented reason;
- review GitHub unresolved threads and local known warnings.

Current PR #102 review risk:

- unresolved SRS99 barrel detach thread in
  `modular/halo/code/modules/projectiles/guns/specialist/sniper/unsc.dm`.

Acceptance:

- every unresolved thread is either fixed in a later implementation task or
  explicitly accepted with evidence;
- every intentional divergence is recorded in `CM_PVE_PORT_STATE.md` or linked
  evidence.

### Phase 7: Final Gates

After audit fixes are implemented in a separate task, run:

```powershell
git diff --check
tools/bootstrap/python -m dmi.test
tools/bootstrap/python -m tools.maplint.source --github
tools/build/build --ci dm -DCIBUILDING -DANSICOLORS -Werror
```

For map-sensitive changes, add the relevant all-map compile stages from
`.AI_AGENT/WORKFLOW_RULES.md`.

## Completion Criteria

The CM-PVE audit is complete only when:

- the CM-PVE PR source list is reconciled and documented;
- every CM-PVE PR has a manifest row with target paths and asset ownership;
- all DMI files and required icon_states are verified;
- all sound files and references are verified;
- all map/config changes are verified;
- modularity and SS220 EDIT requirements are checked;
- unresolved PR comments are closed, accepted, or recorded as residual risk;
- verification gates are run or explicitly deferred with evidence.
