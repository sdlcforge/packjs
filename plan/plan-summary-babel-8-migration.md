# Plan Summary: babel-8-migration

## What was planned and why

Migrate packjs (`@sdlcforge/packjs`) from Babel 7 to Babel 8 and release it as **2.0.0** (stable, published to `latest`). Driven by a downstream need: format-and-lint's ESLint 10 upgrade requires `@babel/eslint-parser` 8, which requires `@babel/core` 8 and Node `^22.18.0 || >=24.11.0`. Out of scope: any format-and-lint change, replacing `@rollup/plugin-babel`, polyfill work.

Single phase, four tasks. Version decision: 2.0.0, because the Node floor, Babel 8 and the automatic JSX runtime are breaking for 1.x users.

Hard constraints (owner):

- Automatic JSX runtime (not classic); consumers need React 17+ for JSX. Document in README and CHANGELOG.
- `engines.node` = `^22.18.0 || >=24.11.0`; verify against the installed Babel 8 packages' `engines.node`.
- Bun >= 1.4.0 required to run tests (Babel 8 parser worker needs `worker_threads.SHARE_ENV`; Bun 1.3.x fails then hangs). The host's system Bun is 1.3.14, so the executor must obtain Bun >= 1.4.0 first.
- Accept the `@rollup/plugin-babel` ^7 peer warning on `@babel/core` and note it in docs.
- CHANGELOG entry states the Node floor change and the automatic JSX runtime. `scripts/release.sh` is not modified.
- Run the full test and lint targets. Agents never publish (see `RELEASING.md`): the final task stops after the dry run; the user runs the real release.
- After the user releases, the manager must tell the format-and-lint owner: its `@sdlcforge/packjs` devDependency range must become `^2.0.0` (the followup text said `^1.0.0-beta.3`; its current `^1.0.0-beta.2` range resolves only to 1.x).

Research input (scratch, verify each change, do not apply blindly): [Babel 8 migration research summary](./notes/babel-8-research-summary.md).

Tasks:

1. [Migrate dependencies and Babel config](./phase-01-babel-8-migration/001-migrate-deps-and-config.md) - package.json, shared config, TS regression case, bun.lock.
2. [Add fixtures and verify](./phase-01-babel-8-migration/002-add-fixtures-and-verify.md) - JSX and import-attribute fixtures, full test/lint/qa, pack-and-install check. Depends on 1.
3. [Docs and changelog](./phase-01-babel-8-migration/003-docs-and-changelog.md) - README, CHANGELOG.md, DEVELOPER_NOTES.md, RELEASING.md. Depends on 1; parallel-eligible with 2.
4. [Release dry run and handoff](./phase-01-babel-8-migration/004-release-2-0-0-dry-run.md) - depends on 2 and 3.

## What shipped

### Phase 01 — Babel 8 Migration and 2.0.0 Release

1. **Migrate Dependencies and Babel Config to Babel 8** (`001-migrate-deps-and-config.md`, tier `sonnet-med`) — Migrated deps to Babel 8 with an engines field, removed the import-assertions plugin, and used a plain @babel/plugin-transform-runtime. preset-react is applied through an override excluding .ts/.mts/.cts with the automatic runtime. Added an identityArrow generic arrow regression case to src/test/typescript-features.ts. Lockfile regenerated; make test and make build pass on Bun 1.4.3.
   Commit `d8bc158`, merged at `e26489234ce99a67717663595e9eba935d18a31a`.

2. **Add JSX and Import-Attribute Fixtures and Run Full Verification** (`002-add-fixtures-and-verify.md`, tier `sonnet-med`) — Added JSX, TSX and import-attribute fixtures and tests, a Makefile retrigger prerequisite for fixtures and a lint ignore for the import-attribute fixture. make test, lint and qa pass, and the npm pack/install check is green with only the expected @rollup/plugin-babel ^7 peer-override warning.
   Commit `3bd0b79`, merged at `78ebeeddce624665bee2217b20bc3a2b246a7647`.

3. **Write README Notes, CHANGELOG, and Update Developer and Releasing Docs** (`003-docs-and-changelog.md`, tier `sonnet-med`) — Wrote the 2.0.0 docs: README Requirements section, new CHANGELOG.md (2.0.0 dated 2026-10-11), DEVELOPER_NOTES Bun >= 1.4.0 and polyfill note, RELEASING changelog convention. Docs only.
   Commit `5882c60`, merged at `722b520bbc5730e9b3fff199c32c5c7c20e6c623`.

4. **Release 2.0.0 via Dry Run and User Handoff** (`004-release-2-0-0-dry-run.md`, tier `sonnet-low`) — **Not done.** _No digest recorded for **Release 2.0.0 via Dry Run and User Handoff** — its outcome is in `plan/phase-01-babel-8-migration/004-release-2-0-0-dry-run.md`._
   No commit or merge SHA recorded.

## Key decisions

_No `## Why this shape` section is recorded in `plan/overview.md`, so this plan's cross-task rationale was never written down. Per-task outcomes are under "What shipped" above._

## Findings

- **`xpgB`** — **RELEASING.md lacks Bun >= 1.4.0 minimum** — promoted — ref: `xpgB` — 2026-10-11

- **`MCMF`** — **Strengthen TSX types-stripped test** — promoted — ref: `MCMF` — 2026-10-11

- **`lK34`** — **Review refreshed lockfile dependencies** — promoted — ref: `lK34` — 2026-10-11

## Final Task State

# TODO

## Purpose and scope

Tracking document for the active plan.

## Tasks

### Phase 01 — Babel 8 Migration and 2.0.0 Release

- [x] [001-migrate-deps-and-config.md](./phase-01-babel-8-migration/001-migrate-deps-and-config.md) — tier `sonnet-med` · branch `plan/babel-8-migration-01-001` · commit `d8bc158` · merge `e26489234ce99a67717663595e9eba935d18a31a`
- [x] [002-add-fixtures-and-verify.md](./phase-01-babel-8-migration/002-add-fixtures-and-verify.md) — tier `sonnet-med` · branch `plan/babel-8-migration-01-002` · commit `3bd0b79` · merge `78ebeeddce624665bee2217b20bc3a2b246a7647`
- [x] [003-docs-and-changelog.md](./phase-01-babel-8-migration/003-docs-and-changelog.md) — tier `sonnet-med` · branch `plan/babel-8-migration-01-003` · commit `5882c60` · merge `722b520bbc5730e9b3fff199c32c5c7c20e6c623`
- [ ] [004-release-2-0-0-dry-run.md](./phase-01-babel-8-migration/004-release-2-0-0-dry-run.md) — tier `sonnet-low` · branch `…` · commit `…` · merge `…`
