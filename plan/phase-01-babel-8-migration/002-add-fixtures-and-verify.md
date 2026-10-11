# Add JSX and Import-Attribute Fixtures and Run Full Verification

> **Ephemeral plan document.** This file is ephemeral and will be removed after the implementation is complete. Project documents must be updated or created to capture the context and information contained herein. Link only from other plan documents; do not link to this document from non-plan documents.

## Purpose and scope

Close the coverage gaps the research found (no JSX or JSON-import coverage) and run the complete verification. Depends on [task 1](./001-migrate-deps-and-config.md). Touches `src/test/` only, plus the Makefile only if needed for fixture retriggering.

## Requirements

1. Use Bun >= 1.4.0 (see task 1).
2. Read `src/test/rollup.test.js` to learn how existing cases build a fixture project and assert on output. Add a JSX case: a small `.jsx` fixture built through the rollup config; assert the output uses the automatic runtime (imports from `react/jsx-runtime` or `react/jsx-dev-runtime`, no `React.createElement`), and that a `.tsx` fixture also builds. Treat `react` as external/peer so no React install is required if the existing config allows; otherwise add it as a devDependency.
3. Add an import-attributes case: `import data from './data.json' with { type: 'json' }` builds and the JSON is inlined.
4. If editing `src/test/*.ts` fixtures does not retrigger `make test` (the Makefile prerequisite list excludes them), add the fixture globs to the test prerequisites in the `Makefile`.
5. Run the full set: `make test`, `make lint`, `make qa` (remove `qa/.unit-test.passed` and `qa/.lint.passed` first). Fix test-file lint findings.
6. Pack check: `npm pack` into a scratch directory outside the repo (use the session scratchpad), `npm install` the tarball into an empty project, confirm exit 0, a single `@babel/core@8`, and that the only warning is the `@rollup/plugin-babel` peer (`@babel/core ^7`) override. Capture the warning text for the docs task. Remove the tarball from the repo.

## Validation

- New JSX and import-attribute tests print PASSED lines; all earlier cases still pass.
- `make test`, `make lint`, `make qa` exit 0 on a forced rerun.
- The npm install check exits 0 with only the accepted peer warning.
- `git status` shows no stray artifacts (tarball, scratch projects).

## Status

- Outcome: succeeded (2026-10-11).
- Validation: `make test`, `make lint`, `make qa` exit 0 after removing the QA markers; the new JSX, TSX, and import-attribute cases print PASSED alongside all earlier cases. `npm pack` plus `npm install` of the tarball into an empty project exits 0 with a single `@babel/core@8.0.7`.
- Pack-check warning: the only peer warning is `ERESOLVE overriding peer dependency` for `@rollup/plugin-babel@7.1.0` (peer `@babel/core ^7.0.0`, found `@babel/core@8.0.7`). npm also printed an unrelated `deprecated glob@9.3.5` notice from a transitive dependency.
- Files: `src/test/rollup.test.js`, `src/test/jsx-features.jsx`, `src/test/tsx-features.tsx`, `src/test/import-attributes.mjs`, `src/test/data.json`, `Makefile`.
- Notes: `Makefile` gains `TEST_FIXTURES_SRC` as a test prerequisite and ignores `src/test/import-attributes.mjs` in lint (ESLint 8 cannot parse `with` import attributes). In this nested worktree ESLint also needs `ESLINT="bunx eslint --no-eslintrc -c .eslintrc.js"` because the parent `.eslintrc.js` duplicates the `import` plugin.
