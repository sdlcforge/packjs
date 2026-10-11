# @sdlcforge/packjs

Configures Babel and Rollup to support modern syntax and proposals in source code while producing optimized, backwards compatible output code.

## Install

```bash
npm i @sdlcforge/packjs
```

## Running

```bash
npx rollup $(npm explore @sdlcforge/packjs -- pwd)/dist/rollup/rollup.config.mjs
```

## Requirements

- **Node** `^22.18.0 || >=24.11.0` (the Babel 8 floor). Node 20 and Node 22 older than 22.18 are not supported.
- **React 17 or newer** for JSX consumers. JSX is compiled with the automatic runtime, which imports from `react/jsx-runtime`.
- **Targets.** Packages that declare no `engines` (and no browserslist) now get Babel 8's default targets, which transpile far less than before. Declare `engines` to target older runtimes.
- **Import attributes** (`with { type: 'json' }`) are supported. The legacy `assert` keyword is not.
- **Peer warning.** `@rollup/plugin-babel` ^7 declares a peer range for `@babel/core` that does not yet include Babel 8, so installs print a peer dependency warning. It is expected and harmless.

## Usage

### Polyfills

Unfortunately, it is currently necessary to include necessary polyfills for target engines manually. This is the only way to get optimized output.

After extensive experimentation with different settings, it appears that Babel cannot really produce optimized polyfills. Even with 'usage' based configurations, it may include polyfills that are in fact not used and the polyfill logic also seems to ignore the `targets` setting (e.g., even when the target platform supports a function natively, Babel will still include the polyfill for it). See the [polyfill configuration notes in DEVELOPER_NOTES.md](./DEVELOPER_NOTES#polyfill-configuration-notes) for further details.

## Releasing

Maintainers: see [RELEASING.md](./RELEASING.md) for the release procedure.
