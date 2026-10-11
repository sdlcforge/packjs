# Migrate Dependencies and Babel Config to Babel 8

> **Ephemeral plan document.** This file is ephemeral and will be removed after the implementation is complete. Project documents must be updated or created to capture the context and information contained herein. Link only from other plan documents; do not link to this document from non-plan documents.

## Purpose and scope

Move packjs to Babel 8 with the automatic JSX runtime. Touches `package.json`, `bun.lock`, `src/babel/babel-shared.config.cjs`, `src/test/typescript-features.ts`. Does not touch docs (task 3) or add new fixtures (task 2). Keep the missing-package.json try/catch fallback in the shared config exactly as is.

## Requirements

1. Work in the plan worktree. Obtain Bun >= 1.4.0 first (system Bun is 1.3.14, which fails the Babel 8 parser worker and hangs); e.g. run it via `npx bun@1.4.3`/an installed binary on PATH. Record the Bun version used.
2. Read [the research summary](../notes/babel-8-research-summary.md) and apply its dependency changes to `package.json`; add `"engines": { "node": "^22.18.0 || >=24.11.0" }`. Verify the range: `npm view` each bumped Babel package's `engines.node` and confirm the range is a subset of each; if a package declares something narrower, stop and report.
3. Edit `src/babel/babel-shared.config.cjs`: `@babel/plugin-transform-runtime` with no options; delete `@babel/plugin-syntax-import-assertions`; replace the plain `@babel/preset-react` entry with the `jsxPreset` override function (excludes `.ts`/`.mts`/`.cts`, automatic runtime, not classic). Update the explanatory comments accordingly. `babelPresets`/`babelPlugins` stay plain array exports.
4. In `src/test/typescript-features.ts` add the `identityArrow` generic arrow function and use it in the generics step.
5. Regenerate the lockfile: `rm bun.lock && bun install` (Bun >= 1.4.0). Keep `@rollup/plugin-babel ^7.0.0`.
6. Run `make build`.

## Validation

- `package.json` contains the Babel 8 ranges, the engines field, and no `@babel/plugin-syntax-import-assertions`.
- `grep -n "corejs\|regenerator\|import-assertions\|classic" src/babel/babel-shared.config.cjs` shows no stale options (comments aside).
- `rm -f qa/.unit-test.passed && make test` passes under Bun >= 1.4.0 (all rollup tests, including "Babel config without package.json" and the TypeScript tests using the generic arrow).
- `make build` succeeds; `dist/` contains the updated config.

## Assumptions

- No other Babel 7 usage exists elsewhere in the repo (`grep -rn "@babel" src scripts`).

## Metadata

architectural_impact: false

## Status

- Outcome: succeeded (2026-10-11). Bun 1.4.3, Node v26.5.0.
- Validation: package.json has Babel 8 ranges, engines field, no import-assertions plugin; stale-option grep matches comments only; `make test` passes (all rollup tests); `make build` succeeds, `dist/` contains `jsxPreset`.
- Engines verified via `npm view`: cli, core, throw-expressions, transform-runtime, preset-env, preset-react, preset-typescript declare `^22.18.0 || >=24.11.0`; `@babel/runtime` and `babel-plugin-transform-import-meta` declare none.
- Files: `package.json`, `bun.lock`, `src/babel/babel-shared.config.cjs`, `src/test/typescript-features.ts`.
