# Babel 8 Migration and 2.0.0 Release

> **Ephemeral plan document.** This file is ephemeral and will be removed after the implementation is complete. Project documents must be updated or created to capture the context and information contained herein. Link only from other plan documents; do not link to this document from non-plan documents.

## Purpose and scope

Migrate packjs (`@sdlcforge/packjs`) from Babel 7 to Babel 8 and release it as **2.0.0** (stable, published to `latest`). Driven by a downstream need: format-and-lint's ESLint 10 upgrade requires `@babel/eslint-parser` 8, which requires `@babel/core` 8 and Node `^22.18.0 || >=24.11.0`. Out of scope: any format-and-lint change, replacing `@rollup/plugin-babel`, polyfill work.

## Current status

Planned; no task started. packjs is at 1.0.0 (released and published to `latest`); the earlier idea of a `1.0.0-beta.3` is obsolete. The missing-package.json tolerance (shared config catches the failed lookup and falls back to an empty package object; test 9 in `src/test/rollup.test.js`) is already merged and already released in 1.0.0; it must be kept unchanged.

## Overview

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
