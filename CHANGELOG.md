# Changelog

All notable changes to this project are documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-10-11

### Changed

- **BREAKING:** The minimum Node version is now `^22.18.0 || >=24.11.0`. Node 20 and Node 22 older than 22.18 are unsupported.
- **BREAKING:** Migrated to Babel 8. JSX is now compiled with the automatic runtime, so JSX consumers need React 17 or newer (`react/jsx-runtime`).
- Packages that declare no `engines` or browserslist now get Babel 8's default targets, so far less code is transpiled.
- `@babel/preset-env` `modules` is left at Babel 8's `auto` behavior except where packjs sets it explicitly (`false` for builds, `commonjs` for CommonJS test runs).
- With `type: module`, `targets.esmodules` now follows Babel 8 semantics.
- `.ts`, `.mts`, and `.cts` files no longer get JSX parsing; `.tsx` still does. This restores generic arrow functions such as `<T>(x: T) => x` in `.ts` files.
- The `@rollup/plugin-babel` ^7 peer dependency warning on `@babel/core` is expected and harmless.

### Removed

- `@babel/plugin-syntax-import-assertions`. Import attributes (`with { type: 'json' }`) are supported natively; the legacy `assert` keyword is not.
- The `@babel/plugin-transform-runtime` `corejs`, `helpers`, and `regenerator` options, which Babel 8 removed.

## [1.0.0]

### Fixed

- Tolerate a missing `package.json` when loading the Babel configuration; defaults are used instead of failing.
