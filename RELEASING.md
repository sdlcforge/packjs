# Releasing @sdlcforge/packjs

Releases are cut with `scripts/release.sh`, the single entry point. Flow's release skills read this file by fixed name. Items that could not be confirmed are listed under [Open questions](#open-questions).

## Running a release

```sh
scripts/release.sh --dry-run <patch|minor|major|prerelease|X.Y.Z[-pre.N]>   # checks everything, changes nothing
scripts/release.sh <patch|minor|major|prerelease|X.Y.Z[-pre.N]>             # the real release
```

Agents never publish, push, or tag. They stop at the dry run; the real release is user-run from an interactive terminal because publishing may need a 2FA one-time code. Never put release actions in the `Makefile` or in `package.json` scripts.

The script:

1. Pre-flight: on `RELEASE_BRANCH` (default `main`), clean tree, remote `REMOTE` (default `origin`) configured, `bun` present, [credentials](#credential-pre-flight) valid, interactive terminal (real release only).
2. [Bumps](#bump-tool) the version, which runs test and lint through the `preversion` hook.
3. Runs `make build`. If the build modifies tracked files other than `package.json`, it reverts the bump and aborts.
4. Commits the bump (message is the bare version) and creates the annotated tag `v<version>`.
5. Pushes the branch, then the tag.
6. Publishes with `bun publish --access public --tag <dist-tag>`.
7. Creates the GitHub release with generated notes (marked prerelease for prerelease versions).

`--dry-run` performs the checks, bump, test, lint and build, runs `bun publish --dry-run`, then reverts the bump. It never commits, tags, pushes, publishes, or creates a release. Credential failures are warnings in a dry run and hard failures otherwise.

Resume: if a release stopped part-way, re-run with the explicit version (for example `scripts/release.sh 1.0.0-beta.3`) from the tagged commit. Steps whose result already exists (local tag, remote tag, published version, GitHub release) are skipped.

### Dist-tag

Stable versions publish under `latest`. A prerelease publishes under its first identifier, so `1.0.0-beta.3` gets `beta` and `latest` is not moved. Override with the `DIST_TAG` environment variable.

## Manifests

- `package.json` (`version` field) - primary (`bun.lock` does not record the root version)

## Bump tool

The script bumps with npm:

```sh
npm version <bump> --no-git-tag-version
```

The script takes the new version (or a `patch`/`minor`/`major`/`prerelease` keyword) as its argument and sets it itself; no manual edit is needed. The `preversion` script in `package.json` (`make test && make lint`) gates the bump, so it fails if either check fails.

npm is used only for `npm version`. Bun has no tag-free equivalent: `bun pm version` always creates a git tag. `bun.lock` does not record the root version, so only `package.json` changes.

The commit message is the bare version (for example `1.0.0-beta.3`, as in past releases). The tag is created by the script in the [tag push](#tag-push) step.

## Changelog

None. The project keeps no changelog file; no entry is inserted.

## Build

1. `bun install --frozen-lockfile`
2. `make build` (copies the config files from `src/` into `dist/`; also run automatically by `prepack`)
3. `make qa` (runs the unit test and lint; writes reports under `qa/`, which is git-ignored)

## Artifacts

`dist/` (the `files` list in `package.json` ships only `dist/`). Entry point `dist/index.cjs`.

## Tag prefix

`v`

## Tag push

Tags are annotated (`v<version>`) and sit on the version-bump commit on `main`. The script pushes the release commit to `origin` `main` before the tag.

## Registries

| Registry | Publish command |
|---|---|
| npm (`@sdlcforge/packjs`) | `bun publish --access public --tag <dist-tag>` |

See [Dist-tag](#dist-tag) for how `<dist-tag>` is chosen. If the npm account requires a one-time code on publish, the publish step is user-run: bun prompts for it in the user's own terminal.

## Credential pre-flight

`bun pm whoami` (run by the script; `gh auth status` is checked as well)

On failure, the user authenticates in their own terminal (`npm login`, which writes the registry credentials bun reads) and the script is re-run.

## Open questions

- The history shows releases made with an external tool (`liq`: "Merging auto-generated release branch", a QA-files commit and a removal commit around each bump). This repository does not document or configure that tool, so this procedure uses `npm version` for the bump. Confirm the intended tool.
- Confirm that `bun publish` (with the `--access public` and dist-tag choices above) is the actual publish path; no publish workflow, CI configuration, or `publishConfig` exists in the repository.
- Confirm whether `qa/` reports should be committed per release as past releases did, or stay git-ignored.
- Confirm the release branch convention; the default branch is `main`.
