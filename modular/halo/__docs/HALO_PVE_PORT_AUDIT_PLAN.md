# HALO PVE PORT AUDIT PLAN

Reproducible audit plan for the CM-PVE-HALO part of BandaTroopers PR #102.

This document is a plan, not a completion record. The status source of truth is
[`HALO_PORT_STATE.md`](HALO_PORT_STATE.md). Historical batch context lives in
[`HALO_PORT_BACKLOG.md`](HALO_PORT_BACKLOG.md) and
[`../../__docs/VARIOUS_FIXES_PORTING_MAP.md`](../../__docs/VARIOUS_FIXES_PORTING_MAP.md).

## Audit Target

- BandaTroopers PR: <https://github.com/ss220club/BandaTroopers/pull/102>
- Current observed local branch head before the 2026-06-18 refresh worktree edits:
  `5454f313cc436822c605a8bbcc98cba1e6a8c85d`
- HALO upstream: <https://github.com/cmss13-devs/cmss13-pve-halo>
- Current HALO audit source from state doc:
  `cmss13-devs/cmss13-pve-halo/master @ 60dd61b32df3c9f4b6ed0f646743ce8884399e43`
- Local branch: `halo-pve-update-batch1-3b`

## Non-Goals

- Do not fix implementation during the audit-planning pass.
- Do not add HALO-only states to generic root `.dmi` files unless a later task
  explicitly accepts that debt.
- Do not treat `BUILD.cmd` success as proof of DMI state or sound reference
  parity.
- Do not treat a file rename as proof that every DM/DMM reference was remapped.

## Source List Reconciliation

Before per-PR verification, build a single HALO source list from:

1. PR #102 body.
2. `HALO_PORT_STATE.md`.
3. `HALO_PORT_BACKLOG.md`.
4. `VARIOUS_FIXES_PORTING_MAP.md`.
5. GitHub changed-file list for PR #102.
6. Local `origin/master...HEAD` diff.
7. Upstream CM-PVE-HALO pull requests and merge commits.

The source list must cover:

- baseline HALO PRs from earlier PR #96/#94 context when still present in the
  current branch;
- PR #102 table entries such as #145, #150, #152, #155-#182;
- backlog-only entries such as #137, #143, #153, #154, and #156 core;
- later PR body extension entries #183, #185, #186, and repeated #159;
- every "ALREADY PRESENT" claim.

Current known mismatch:

- older docs describe 27 CM-PVE-HALO PRs;
- the PR body now also mentions #183, #185, #186, and #159 as newly ported;
- local commits after `5f1e274056` changed DMI/sound/modularity state.

2026-06-18 refresh note:

- upstream `cm-pve-halo/master` now resolves to `60dd61b32d`;
- post-`787d28227b` PRs #152, #159, #180, #162, #185, #170, #173, and #172 were rechecked against modular BT paths;
- residual implementation gaps from #151 and #161 were fixed in the refresh worktree;
- upstream `sound/weapons/halo/gun_plasmarifle_triplefire.ogg` was imported to `modular/halo/sound/weapons/gun_plasmarifle_triplefire.ogg` as byte-exact parity, although no live DM/DMM/JSON reference currently uses it.

## Audit Phases

### Phase 1: HALO Manifest

For every HALO upstream PR in the reconciled list:

- record upstream PR number, title, merge/head commit, and changed files;
- classify changed files as DM, DME, DMI, OGG/WAV, DMM, JSON, tgui, docs, or
  no-op;
- map upstream `modular_pve_halo/**`, `icons/halo/**`, root HALO sound paths,
  and root map/template paths to BandaTroopers target owners;
- record intentional local divergence and dependency on CM-PVE content.

Acceptance:

- every claimed HALO PR has one manifest row;
- every upstream binary asset has an expected local path;
- every deferred/changed map portion has explicit status and reason.

### Phase 2: Modularity Gates

HALO ownership rules:

- HALO code and assets live in `modular/halo/**` by default.
- Root `code/**` contains only explicit shared glue and required compile-time
  contracts.
- Root `icons/halo/**` is forbidden for new/ported HALO assets.
- Root HALO-only sounds are forbidden unless explicitly classified as shared
  upstream content.
- HALO-only states must not be injected into generic root `.dmi` files without
  a documented exception.
- `modular/cm_pve/**` must not own HALO-specific behavior.

Required path gates:

```powershell
rg -n "modular_pve_halo" code modular maps map_config colonialmarines.dme colonialmarines.test.dme
rg -n "'icons/halo/|\"icons/halo/" code modular maps map_config -g "*.dm" -g "*.dmm" -g "*.json"
rg -n "sound/weapons/halo|sound/voice/(sangheili|unggoy|ruuhtian)|sound/vehicles/warthog" code modular maps -g "*.dm" -g "*.dmm"
git diff --name-status origin/master...HEAD -- .codex_tmp .roo modular/halo/HALO_PORT_BACKLOG.md sound
```

Known gate candidates from the first execution pass:

- `.codex_tmp/**` and `.roo/**` appear in the current PR diff.
- Both `modular/halo/HALO_PORT_BACKLOG.md` and
  `modular/halo/__docs/HALO_PORT_BACKLOG.md` appear in the current PR diff.
- 6 root `sound/weapons/fire_support/spnkr_aa_*.ogg` files appeared in the PR
  diff before cleanup; runtime references use
  `modular/halo/sound/weapons/spnkr_locking/**`.
- `sound/weapons/gun_dropship_minigun.ogg` appears in the PR diff and is a
  referenced CM-PVE/Dog War root sound, not a HALO-owned duplicate.
- Matching modular SPNKR AA files exist under
  `modular/halo/sound/weapons/spnkr_locking/`.
- `HALO_PORT_STATE.md` had a typo mentioning
  `modular/halo/modular/halo/sound/...`; the audit pass corrected it to the
  actual `sound/weapons/halo/**` -> `modular/halo/sound/**` migration.

Acceptance:

- no forbidden path remains in final diff or runtime references;
- every root exception is documented and justified;
- duplicate docs/tooling artifacts are removed in a later implementation task
  or explicitly accepted.

### Phase 3: DMI File and State Parity

For every upstream HALO DMI:

- compare upstream and local file ownership;
- record whether a byte-exact match, local superset, or local fallback is
  expected;
- dump upstream and local icon_state manifests;
- compare required icon_state presence;
- scan DM/DMM/JSON for `icon`, `icon_state`, `base_icon_state`, `item_state`,
  `worn_state`, overlay/radial/HUD state names, and generated state strings.

High-risk HALO asset groups:

- #183: UNSC/ODST flags and banners, including `banners.dmi`.
- #150: loadout items, `devices.dmi`, `unsc_melee.dmi`, VISR/loadout states.
- #174: loose-ammo packets and `packets.dmi`.
- #159: shotgun/sniper ammo boxes, `boxes_and_lids.dmi`,
  `magazines.dmi`, `handful.dmi`, and `handful_state` values; treat this as
  item/code evidence unless a concrete map file is added to the audit.
- #158: fire support radial/HUD/sound icon assets.
- #160: Holy Redoubts map templates and template DMI references.
- #179/#172/#166: uniforms, RTO bag, VISR states.
- New Varadero and `areas_covenant.dmi` modularized turf/area states.

Acceptance:

- every HALO DMI required by upstream/local code exists in the correct owner
  path;
- every referenced state exists in the selected local DMI;
- root generic DMI changes are either shared, extracted, or recorded as debt;
- local fallbacks are clearly documented and not misattributed to upstream.

### Phase 4: Sound Parity

For every upstream HALO OGG/WAV:

- compare source path, local target path, and local references;
- verify every referenced local sound exists;
- verify no HALO-only reference points at root `sound/weapons/halo/**`,
  `sound/voice/{sangheili,unggoy,ruuhtian}/`, or root Warthog sound paths;
- compare hashes where byte-exact parity is expected;
- classify intentionally shared root sounds separately from HALO-only sounds.

High-risk HALO sound groups:

- covenant race pain/warcry sounds;
- UNSC/Covenant gun sounds;
- SPNKR AA sounds;
- fire support aircraft/flyby/impact sounds;
- ODST pod sounds;
- Pelican and Phantom gun sounds;
- dropship hover looping sounds;
- Warthog sounds.

Acceptance:

- no sound reference points at a missing file;
- duplicate root/modular copies are justified or removed in a later task;
- path ownership matches `HALO_PORT_STATE.md`.

### Phase 5: Maps, Templates, and Configs

For every HALO map/template PR:

- compare upstream DMM, JSON, template, and map config file presence;
- verify template paths and all referenced area/turf/obj icon states;
- check map config and JSON references;
- run targeted maplint for templates before broader all-map checks;
- document deferred map changes as explicit deviations only when still true.

High-risk HALO map groups:

- #160 Holy Redoubts templates.
- #169/#182 featureless biomes.
- #150/#174 map placements if they were deferred or later ported; do not carry
  a deferred-map note for #159 without a concrete map file.
- New Irvine/New Varadero imported map asset ownership.

Acceptance:

- every included HALO map/template compiles and references existing assets;
- docs no longer claim a map portion is deferred if it was later ported;
- deferred map portions have current evidence and owner approval.

### Phase 6: Code, DME, and Review Threads

For every HALO DM/DME change:

- compare upstream intent with local modular implementation;
- verify DME include reachability through `modular/halo/_halo.dme`;
- verify `code/**` glue has SS220 EDIT markers and minimal scope;
- verify HALO-specific code was not placed in `modular/cm_pve/**`;
- review unresolved GitHub threads.

Current PR #102 review risk:

- unresolved SRS99 barrel detach thread in
  `modular/halo/code/modules/projectiles/guns/specialist/sniper/unsc.dm`.

Acceptance:

- every moved HALO file is reachable once;
- every shared root glue change is marked and justified;
- every unresolved review thread is fixed in a later implementation task or
  explicitly accepted with evidence.

### Phase 7: Final Verification Gates

After audit fixes are implemented in a separate task, run:

```powershell
git diff --check
tools/bootstrap/python -m dmi.test
tools/bootstrap/python -m tools.maplint.source --github
tools/build/build --ci dm -DCIBUILDING -DANSICOLORS -Werror
```

For map-sensitive HALO work, add the relevant all-map compile stages from
`.AI_AGENT/WORKFLOW_RULES.md`. For runtime-sensitive HALO behavior, add focused
unit/runtime checks rather than relying on compile only.

## Completion Criteria

The HALO PVE audit is complete only when:

- the HALO PR source list is reconciled and documented;
- every HALO PR has a manifest row with target paths and asset ownership;
- every HALO DMI file and required icon_state is verified;
- every HALO sound file and reference is verified;
- all maps/templates/configs are verified;
- forbidden root and duplicate paths are cleared or explicitly justified;
- unresolved PR comments are closed, accepted, or recorded as residual risk;
- verification gates are run or explicitly deferred with evidence.
