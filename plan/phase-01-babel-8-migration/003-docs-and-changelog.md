# Write README Notes, CHANGELOG, and Update Developer and Releasing Docs

> **Ephemeral plan document.** This file is ephemeral and will be removed after the implementation is complete. Project documents must be updated or created to capture the context and information contained herein. Link only from other plan documents; do not link to this document from non-plan documents.

## Purpose and scope

Hand-author the documentation for the 2.0.0 release. Depends on [task 1](./001-migrate-deps-and-config.md); parallel-eligible with [task 2](./002-add-fixtures-and-verify.md). Touches `README.md`, new `CHANGELOG.md`, `DEVELOPER_NOTES.md`, `RELEASING.md`. Do not modify `scripts/release.sh` or `package.json` version (task 4 owns the bump).

## Requirements

1. `README.md`: add a requirements section stating Node `^22.18.0 || >=24.11.0` (Babel 8 floor); the automatic JSX runtime, so React 17 or newer is required for JSX consumers (`react/jsx-runtime`); that consumers declaring no `engines`/browserslist now get Babel 8's default targets (far less transpilation); the `@rollup/plugin-babel` ^7 peer warning on `@babel/core` is expected and harmless; and that import attributes (`with { type: 'json' }`) are supported and the legacy `assert` keyword is not. Keep the existing Polyfills section accurate.
2. Create `CHANGELOG.md` (Keep-a-Changelog style) with a `2.0.0` entry dated the release date (use a placeholder date the user confirms at release, or today's date) listing: BREAKING - Node floor now `^22.18.0 || >=24.11.0` (Node 20 and Node 22 < 22.18 unsupported); BREAKING - Babel 8 migration and automatic JSX runtime (React 17+); behavior notes (default targets, `modules` auto, `targets.esmodules` semantics, `.ts` files no longer get JSX parsing); removed `@babel/plugin-syntax-import-assertions`; transform-runtime options removed; the accepted peer warning. Also include a brief 1.0.0 entry noting the already-released tolerance for a missing package.json, if appropriate.
3. `DEVELOPER_NOTES.md`: state that tests require Bun >= 1.4.0 (Babel 8's parser worker needs `worker_threads.SHARE_ENV`; 1.3.x fails then hangs). Update line 5 ("Hopefully the situation will be improved in Babel 8"): Babel 8 did not change the polyfill situation and removed the transform-runtime `corejs`, `helpers`, `regenerator` options, so the attempts listed there no longer apply as written.
4. `RELEASING.md`: replace the "Changelog" section ("None...") with the new convention: `CHANGELOG.md` is hand-authored before the release and not touched by `scripts/release.sh`; update the Open questions if now answered. Leave the rest.

## Validation

- README names the Node floor and the React 17+ requirement; CHANGELOG 2.0.0 entry states both.
- DEVELOPER_NOTES states Bun >= 1.4.0; line 5 no longer promises Babel 8 will fix polyfills.
- RELEASING.md no longer says the project keeps no changelog.
- `git diff --stat` shows only the four docs changed; `make lint` still passes.
