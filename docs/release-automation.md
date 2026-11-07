# Release automation

This page explains how the formulas follow releases of `amplifiedengineer/playbook`. Do not edit the URLs or checksums in `Formula/` by hand.

## Overview

One `v` release of `amplifiedengineer/playbook` ships `playbook` and `pbtop` with the same version. The `playbook` formula links `pbtop` to `playbook`, which starts the dashboard when it runs under that name. The `pbtop` formula installs the standalone binary and conflicts with `playbook`. Two paths update the formulas:

1. The playbook release workflow opens a pull request here. This is the normal path.
2. The `release` workflow here checks on a schedule. This is the fallback.

## Normal path: the playbook release

1. The playbook release workflow opens a `release/vX.Y.Z` pull request here.
2. It updates both formulas with `.github/scripts/bump-formula.sh` and turns on auto-merge.
3. When the pull request merges, the `release-tag` workflow tags the merge commit `vX.Y.Z`.
4. It then publishes a release that lists the formula versions.

The `release-tag` workflow acts only on a merged pull request that meets all of these:

- It comes from the `igorjs[bot]` app.
- Its branch is `release/v*`, in this repository.
- It changes only `Formula/*.rb` files.
- The merge commit is on `main`.

It uses only `GITHUB_TOKEN`. Retired, disabled and deprecated formulas are left out of the release notes.

## Fallback: the `release` workflow

Triggers:

- A schedule, every 30 minutes. It needs no secret.
- `workflow_dispatch`, by hand. The `bump` workflow is the same job and shares the concurrency group.
- A `tool-released` `repository_dispatch` event. The sender needs its own token.

For each formula (`playbook`, then `pbtop`, one at a time) the job does this:

1. Reads the latest release with `.github/scripts/latest-release.sh`.
2. Compares it with the version in the formula. It never downgrades.
3. Stops if the playbook release path owns the update. That is the case while the `release/vX.Y.Z` pull request is open. A run that was not started by hand also waits for the first hour after the release.
4. Rewrites the URLs and checksums from that release's `SHA256SUMS`. `bump-formula.sh` refuses to write a formula when a checksum is missing.
5. Commits to a `bump/<formula>-v<version>` branch through the GitHub API, so GitHub signs the commit.
6. Opens a pull request, approves the held `tests` run, and waits for it to pass.
7. Squash merges the pull request through the API. The `protect-main` ruleset allows this because the required checks passed.

An open bump pull request is left alone by later runs.

The workflows use only the built-in `GITHUB_TOKEN`. No secret is stored.

## Caveats text

The caveats of each formula end with one line that links the release notes of the installed version. It is built from `#{version}`. The bump writes no caveats text.

## Tests

The `tests` workflow runs on every push to `main`, every pull request, weekly, and by hand. It has three jobs:

- `syntax`: `brew test-bot --only-tap-syntax`.
- `bump-script`: runs `.github/scripts/test-bump-formula.sh`, then a style check of the `pbtop` formula a release writes.
- `install`: `brew audit --strict --online`, `brew install` and `brew test` on Linux and macOS (arm64 and x86_64).

A disabled or deprecated formula is only audited. Bottles are not built, because the formulas install prebuilt binaries.

## If a formula is behind

Check the latest `release` run in this repo.
