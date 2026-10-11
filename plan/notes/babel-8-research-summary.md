# Babel 8 Research Summary

> **Ephemeral plan document.** This file is ephemeral and will be removed after the implementation is complete. Project documents must be updated or created to capture the context and information contained herein. Link only from other plan documents; do not link to this document from non-plan documents.

## Purpose and scope

Condensed, verified-for-planning findings from the format-and-lint scratch research (`/Users/zane/playground/sdlcforge/format-and-lint/.flow/research/babel-8-migration.md` and `babel8-packjs.diff`). Scratch output: executors must verify each change.

## Findings

- Babel 8 packages all declare `engines.node: ^22.18.0 || >=24.11.0` (core 8.0.7, preset-env 8.0.7, preset-react 8.0.1, preset-typescript 8.0.7, transform-runtime 8.0.6, cli 8.0.6, throw-expressions 8.0.1).
- Dependency changes: bump `@babel/cli ^8.0.6`, `@babel/core ^8.0.7`, `@babel/plugin-proposal-throw-expressions ^8.0.1`, `@babel/plugin-transform-runtime ^8.0.6`, `@babel/preset-env ^8.0.7`, `@babel/preset-react ^8.0.1`, `@babel/preset-typescript ^8.0.7`, `@babel/runtime ^8.0.7`, `babel-plugin-transform-import-meta ^3.0.0`; remove `@babel/plugin-syntax-import-assertions` (import attributes parse by default); keep `@rollup/plugin-babel ^7.0.0` (peer `@babel/core ^7`: works with an npm ERESOLVE-override warning, accepted), `babel-plugin-module-resolver`, `babel-plugin-inline-json-import`. Add `engines`.
- `@babel/plugin-transform-runtime` throws on the old `corejs`/`helpers`/`regenerator` options: list it with no options.
- Babel 8 preset-react defaults to the automatic runtime (and `jsxDEV` unless NODE_ENV is production). Owner chose automatic. Babel 8 also no longer drops JSX syntax for `.ts` files, so `<T>(x: T): T => x` in a `.ts` file fails to parse with preset-react active. Fix: apply preset-react via an override excluding `.ts`, `.mts`, `.cts`:
  `const jsxPreset = () => ({ overrides : [{ exclude : /\.[cm]?ts$/, presets : ['@babel/preset-react'] }] })` (research used `runtime: 'classic'`; here use the automatic runtime, optionally written explicitly as `{ runtime : 'automatic' }`). Keep `babelPresets` a plain array so `babel.config.cjs` and `rollup.config.mjs` need no change.
- Regression case: in `src/test/typescript-features.ts` add `const identityArrow = <T>(value: T): T => value;` and use it in the generics step (`identityArrow<number>(42)`).
- Behavior changes to document: default `targets` becomes browserslist defaults when a consumer declares no `engines`/browserslist (much less transpilation); `modules: 'auto'` now assumes ESM; `targets.esmodules: true` is now "intersect" semantics; Node 20 and Node 22 < 22.18 unsupported.
- Files needing no change: `src/babel/babel.config.cjs`, `src/index.cjs`, `src/rollup/rollup.config.mjs`, `src/test/rollup.test.js` assertions, `.eslintrc.js`.
- Test gap: the suite has no JSX or JSON coverage; `make test` depends on `src/**/*.{js,mjs,cjs}` only, so editing `src/test/*.ts` does not retrigger tests (remove `qa/.unit-test.passed` to force).
- The research's diff base predates 1.0.0; `babel-shared.config.cjs` is unchanged since, so the diff applies, with the JSX runtime edited to automatic.
