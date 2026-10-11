const readFileSync = require('node:fs').readFileSync
const join = require('node:path').join

const findRoot = require('find-root')
const semver = require('semver')

let pkgJSON
try {
  const npmRoot = findRoot(process.cwd())
  pkgJSON = JSON.parse(readFileSync(join(npmRoot, 'package.json'), { encoding : 'utf8' }))
}
catch (e) { // no package.json above cwd (or unreadable); fall back to defaults
  pkgJSON = {}
}

const NODE_ENV = process.env.NODE_ENV

const presetEnvOptions = {}
if (NODE_ENV !== 'test' || pkgJSON.type === 'module') {
  // for prod, rollup handles imports so it can do tree shaking and such; this disables Babel transforms
  presetEnvOptions.modules = false
  // for explicit es module targets, we need to set the targets to esmodules as well
  if (pkgJSON.type === 'module') {
    presetEnvOptions.targets = { esmodules : true }
  }
}
else { // it's a test environment and we are not explicitly targeting es modules
  Object.assign(presetEnvOptions, { modules : 'commonjs' })
}

const engineSpec = pkgJSON.engines || {}
const engineTargets = {}
for (const engine of Object.keys(engineSpec)) {
  const targetVer = semver.minVersion(engineSpec[engine]).raw
  engineTargets[engine] = targetVer
}
if (Object.keys(engineTargets).length > 0) {
  Object.assign(presetEnvOptions, { targets : engineTargets })
}

const pkgOverrides = (pkgJSON._sdlc && pkgJSON._sdlc.babel && pkgJSON._sdlc.babel['preset-env']) || {}
Object.assign(presetEnvOptions, pkgOverrides)

// Babel 8 no longer drops the JSX syntax plugin for '.ts' files, so with '@babel/preset-react' active a generic arrow
// function (`<T>(x: T) => x`) in a '.ts' file is parsed as JSX and fails. Apply the JSX preset to everything except
// '.ts', '.mts', and '.cts' ('.tsx' still gets it). The 'automatic' JSX runtime (Babel 8's default) is set explicitly.
const jsxPreset = () => ({
  overrides : [{ exclude : /\.[cm]?ts$/, presets : [['@babel/preset-react', { runtime : 'automatic' }]] }]
})

const babelPresets = [
  // in testing, we output each file, so we need to convert 'imports', in production, we let rollup handle the imports
  ['@babel/preset-env', presetEnvOptions],
  jsxPreset,
  // TypeScript support - Babel strips types without type checking, which is ideal for transpilation
  '@babel/preset-typescript'
]

const babelPlugins = [
  '@babel/plugin-proposal-throw-expressions',
  // helps save on codesize by re-using injected helper code; Babel 8 removed the 'corejs', 'helpers', and 'regenerator'
  // options (helpers are always imported from @babel/runtime and there's no polyfilling here)
  '@babel/plugin-transform-runtime',
  // note: import attributes ('with') parse by default in Babel 8, so no import-assertions syntax plugin is needed
  'inline-json-import'
]

// Only lower `import.meta.url` when babel itself is lowering modules to CJS
// (i.e. the Jest test transpile of a non-module package). In ESM output it is
// native, and in rollup-produced CJS output rollup handles it — in both of
// those cases the transform would inject a `require('url')...__filename`
// expression that either crashes an ESM bundle or collides with user-declared
// `__filename` locals in a CJS bundle.
if (presetEnvOptions.modules === 'commonjs') {
  babelPlugins.push('babel-plugin-transform-import-meta')
}

if (process.env.NODE_ENV === 'test') {
  babelPlugins.push([
    'module-resolver',
    {
      // root: [process.cwd() + '/test-staging/'],
      alias : {
        // the examples in the plugin docs are relative paths, the transpiled code was always one '..' too few when we
        // did it that way, so we use the absolute path
        _lib : join(process.cwd(), 'test-staging', 'lib'),
        _cli : join(process.cwd(), 'test-staging', 'cli')
      },
      extensions : ['.js', '.jsx', '.es', '.es6', '.mjs', '.cjs', '.ts', '.tsx']
    }
  ])
}

module.exports.babelPresets = babelPresets
module.exports.babelPlugins = babelPlugins
