#!/usr/bin/env bash
# Release @sdlcforge/packjs: bump, test, lint, build, commit, tag, push, bun publish, GitHub release.
#
# Usage: scripts/release.sh [--dry-run] <patch|minor|major|prerelease|X.Y.Z[-pre.N]>
#
# --dry-run runs every check, the version bump (npm's preversion hook runs test and lint) and the
# build, runs `bun publish --dry-run`, then reverts the bump. It never commits, tags, pushes,
# publishes, or creates a release.
# Safe to re-run: pass the explicit version of a partly finished release and every step whose
# result already exists (tag, remote tag, published version, GitHub release) is skipped.
# Dist-tag: stable -> latest; prerelease -> its first identifier (1.0.0-beta.3 -> beta).
# Environment overrides: RELEASE_BRANCH (default main), REMOTE (default origin), DIST_TAG.
# Secrets are never read or accepted by this script; bun prompts for any one-time code itself.
set -euo pipefail

DRY_RUN=0
BUMP=''
RELEASE_BRANCH="${RELEASE_BRANCH:-main}"
REMOTE="${REMOTE:-origin}"

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    -*) echo "Unknown option: $arg" >&2; exit 2 ;;
    *) [[ -z "$BUMP" ]] || { echo "Only one bump argument allowed." >&2; exit 2; }; BUMP="$arg" ;;
  esac
done
[[ -n "$BUMP" ]] || { echo "Usage: $0 [--dry-run] <patch|minor|major|prerelease|X.Y.Z[-pre.N]>" >&2; exit 2; }

cd "$(git rev-parse --show-toplevel)"
say() { echo "==> $*"; }
warn() { echo "WARNING: $*" >&2; }
preflight_fail() {
  if (( DRY_RUN )); then warn "$1 (a real release would stop here)"; else echo "$1" >&2; exit 1; fi
}

# --- pre-flight ---------------------------------------------------------------
say "Pre-flight"
command -v bun >/dev/null 2>&1 || { echo "bun not found on PATH; install bun (https://bun.sh)." >&2; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "npm not found on PATH (needed for 'npm version')." >&2; exit 1; }
PKG_NAME=$(node -p "require('./package.json').name")
CURRENT=$(node -p "require('./package.json').version")
[[ "$(git rev-parse --abbrev-ref HEAD)" == "$RELEASE_BRANCH" ]] \
  || { echo "Must be on branch '$RELEASE_BRANCH' (override with RELEASE_BRANCH)." >&2; exit 1; }
[[ -z "$(git status --porcelain)" ]] || { echo "Working tree is not clean." >&2; exit 1; }
git remote get-url "$REMOTE" >/dev/null || { echo "Remote '$REMOTE' not configured." >&2; exit 1; }
bun pm whoami >/dev/null 2>&1 || preflight_fail "Not logged in to npm. Run 'npm login' in your own terminal, then re-run."
gh auth status >/dev/null 2>&1 || preflight_fail "Not logged in to GitHub. Run 'gh auth login' in your own terminal, then re-run."
if (( ! DRY_RUN )) && [[ ! -t 0 ]]; then
  echo "Publishing may need a one-time code; run this script from an interactive terminal." >&2; exit 1
fi

# --- resolve version / resume -------------------------------------------------
RESUME=0
if [[ "$BUMP" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then NEW="$BUMP"; else NEW=''; fi
if [[ -n "$NEW" && "$NEW" != "$CURRENT" ]] && git rev-parse -q --verify "refs/tags/v$NEW" >/dev/null; then
  echo "Tag v$NEW already exists but package.json is at $CURRENT; refusing (resume only from the tagged commit)." >&2; exit 1
fi
if [[ "$NEW" == "$CURRENT" ]] && git rev-parse -q --verify "refs/tags/v$NEW" >/dev/null; then
  [[ "$(git rev-parse "v$NEW^{commit}")" == "$(git rev-parse HEAD)" ]] \
    || { echo "Tag v$NEW exists but is not at HEAD." >&2; exit 1; }
  RESUME=1
  say "Resuming release of v$NEW (commit and tag already exist)"
fi

# --- bump, test, lint, build, commit, tag -------------------------------------
if (( ! RESUME )); then
  say "Bumping version (the preversion hook runs 'make test && make lint'; output streams below)"
  npm version "${NEW:-$BUMP}" --no-git-tag-version
  NEW=$(node -p "require('./package.json').version")
  if git rev-parse -q --verify "refs/tags/v$NEW" >/dev/null; then
    echo "Tag v$NEW already exists." >&2; git checkout -- package.json; exit 1
  fi
  say "Building"
  make build
  DIRTY=$(git status --porcelain | grep -v -E ' package\.json$' || true)
  if [[ -n "$DIRTY" ]]; then
    echo "Build modified tracked files other than package.json; commit or fix these first:" >&2
    echo "$DIRTY" >&2
    git checkout -- package.json
    exit 1
  fi
  if (( ! DRY_RUN )); then
    git add package.json
    git commit -m "$NEW"
    git tag -a "v$NEW" -m "v$NEW"
  fi
fi
TAG="v$NEW"

# --- dist-tag -----------------------------------------------------------------
PRERELEASE_FLAG=()
if [[ "$NEW" == *-* ]]; then
  PRE=${NEW#*-}
  DIST_TAG=${DIST_TAG:-${PRE%%.*}}
  PRERELEASE_FLAG=(--prerelease)
else
  DIST_TAG=${DIST_TAG:-latest}
fi

# --- push ---------------------------------------------------------------------
BRANCH=$(git rev-parse --abbrev-ref HEAD)
say "Pushing $BRANCH and $TAG to $REMOTE"
if (( DRY_RUN )); then
  echo "[dry-run] would run: git push $REMOTE refs/heads/$BRANCH refs/tags/$TAG"
else
  git push "$REMOTE" "refs/heads/$BRANCH"
  git ls-remote --exit-code --tags "$REMOTE" "refs/tags/$TAG" >/dev/null 2>&1 \
    || git push "$REMOTE" "refs/tags/$TAG"
fi

# --- publish ------------------------------------------------------------------
say "Publishing $PKG_NAME@$NEW (dist-tag: $DIST_TAG)"
if (( DRY_RUN )); then
  bun publish --dry-run --access public --tag "$DIST_TAG"
  git checkout -- package.json   # revert the bump; nothing was committed in a dry run
elif [[ -n "$(npm view "$PKG_NAME@$NEW" version 2>/dev/null)" ]]; then
  echo "Already published; skipping."
else
  bun publish --access public --tag "$DIST_TAG"   # bun prompts for any one-time code itself (user-run)
fi

# --- GitHub release -----------------------------------------------------------
say "Creating GitHub release $TAG"
SLUG=$(git remote get-url "$REMOTE" | sed -E 's#^.*[:/]([^/:]+/[^/]+)$#\1#; s#\.git$##')
if (( DRY_RUN )); then
  echo "[dry-run] would run: gh release create $TAG --repo $SLUG --title $TAG --generate-notes --verify-tag ${PRERELEASE_FLAG[*]:-}"
elif gh release view "$TAG" --repo "$SLUG" >/dev/null 2>&1; then
  echo "Release exists; skipping."
else
  gh release create "$TAG" --repo "$SLUG" --title "$TAG" --generate-notes --verify-tag ${PRERELEASE_FLAG[@]+"${PRERELEASE_FLAG[@]}"}
fi

say "Done$( (( DRY_RUN )) && echo " (dry run)"): $TAG"
