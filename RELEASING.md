# Releasing @sdlcforge/packjs

This procedure is written primarily for agents (Flow's release skills read it by fixed name) and secondarily for human operators running a release by hand. It was drafted from the project's tooling and git history; items that could not be confirmed are listed under [Open questions](#open-questions).

## Manifests

- `package.json` (`version` field) - primary (`bun.lock` does not record the root version)

## Bump tool

Bun has no `npm version` equivalent that skips the git tag: `bun pm version` always creates a git tag and has no documented opt-out. The bump is therefore manual:

1. Run `make test && make lint`; the bump must not proceed if either fails.
2. Set the `version` field in `package.json` to `<new_version>`.
3. Commit with the bare version as the message. Past releases (for example `1.0.0-beta.2`) are a bump commit whose message is the bare version.

The tag is created separately in the [tag push](#tag-push) step.

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

Tags are annotated and sit on the version-bump commit on `main`:

1. `git tag -a v<new_version> -m v<new_version>`
2. `git push origin refs/tags/v<new_version>`

Push the release commit to `origin` `main` before the tag.

## Registries

| Registry | Publish command |
|---|---|
| npm (`@sdlcforge/packjs`) | `bun publish --access public` |

For a prerelease version (for example `1.0.0-beta.3`), add `--tag beta` so `latest` is not moved. See [Open questions](#open-questions).

If the npm account requires a one-time code on publish, the publish step is user-run: the executor stops before it and the user runs the command in their own terminal.

## Credential pre-flight

`bun pm whoami`

On failure, the user authenticates in their own terminal (`npm login`, which writes the registry credentials bun reads) and the check is re-run.

## Open questions

- The history shows releases made with an external tool (`liq`: "Merging auto-generated release branch", a QA-files commit and a removal commit around each bump). This repository does not document or configure that tool, so this procedure uses a manual version bump. Confirm the intended tool.
- Confirm that `bun publish` (and the `--access public` and `--tag beta` choices above) is the actual publish path; no publish workflow, CI configuration, or `publishConfig` exists in the repository.
- Confirm whether `qa/` reports should be committed per release as past releases did, or stay git-ignored.
- Confirm the release branch convention; the default branch is `main`.
