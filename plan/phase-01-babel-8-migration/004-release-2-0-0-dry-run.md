# Release 2.0.0 via Dry Run and User Handoff

> **Ephemeral plan document.** This file is ephemeral and will be removed after the implementation is complete. Project documents must be updated or created to capture the context and information contained herein. Link only from other plan documents; do not link to this document from non-plan documents.

## Purpose and scope

Final task. Prepare and dry-run the 2.0.0 release per `RELEASING.md`. Agents never publish, push, or tag; the real release is user-run from an interactive terminal (may need a 2FA code). Depends on [task 2](./002-add-fixtures-and-verify.md) and [task 3](./003-docs-and-changelog.md), both merged into the branch the release runs from.

## Requirements

1. Read `RELEASING.md` and `scripts/release.sh`. Use Bun >= 1.4.0. The release must run from `main` with a clean tree; if the plan branch is not yet merged, report that instead of forcing it.
2. Run `scripts/release.sh --dry-run 2.0.0`. Do not run it without `--dry-run`. Credential failures are warnings in a dry run; report them.
3. Confirm the dry run reverted the bump (`git status` clean, `package.json` version still 1.0.0).
4. Report to the manager: dry-run result, the exact command for the user (`scripts/release.sh 2.0.0`, expected to publish to dist-tag `latest`), and the post-release step: the manager must notify the format-and-lint owner that its `@sdlcforge/packjs` devDependency range must become `^2.0.0` so its dependency bump task can start.

## Validation

- Dry run exits 0 (test, lint, build, `bun publish --dry-run` all succeed) or the failure is reported verbatim.
- Working tree clean and version unchanged afterwards.
- Nothing was committed, tagged, pushed or published.
