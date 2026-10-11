# Developer Notes

## Running tests

Tests require Bun >= 1.4.0. Babel 8's parser worker needs `worker_threads.SHARE_ENV`, which Bun 1.3.x lacks; on 1.3.x the tests fail and then hang.

## Policy configuration notes

As noted in the [README.md polyfilles section](./README.md#polyfills), we were unable to find a configuration that actually optimized polyfills. Polyfills were included for both unused and unnecessary functions (that were natively supported in the targets). Babel 8 did not change this, and it removed the `@babel/plugin-transform-runtime` `corejs`, `helpers`, and `regenerator` options, so the attempts listed below no longer apply as written (they are kept as a record of what was tried on Babel 7):

- if 'core-js' is found in the target package's runtime dependencies, we tried:
  - setting '[@babel/plugin-transform-runtime](https://babeljs.io/docs/babel-plugin-transform-runtime)' configuration `corejs` to the discovered version,
  - setting the '[@babel/preset-env](https://babeljs.io/docs/babel-preset-env)' `useBuiltIns` to `true` and `corejs` to the discover version,
  - adding '[babel-plugin-polyfill-corejs3](https://github.com/babel/babel-polyfills/blob/main/packages/babel-plugin-polyfill-corejs3/README.md)', setting `version` to the discovered version and trying `method` 'usage-global' and 'usage-pure'.
- we also attempted to set the rollup `plugins.babel().babelHelpers` to 'bundled' with various combinations of Babel configurations, but this either result in 'Error: You have declared using "bundled" babelHelpers, but transforming [the entry point] resulted in "runtime", or it failed to actually include the necessary polyfills.
