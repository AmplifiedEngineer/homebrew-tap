# Release automation

This page explains how the formulas follow releases of `amplifiedengineer/playbook` and `amplifiedengineer/helios`. Do not edit the URLs or checksums in `Formula/` by hand.

## Overview

There are two tracks. The playbook release workflow owns the `playbook` and `pbtop` formulas. The scheduled `release` workflow bumps Helios from its own releases, and the playbook release workflow does not touch it.

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

For each formula (`playbook`, `pbtop`, then `helios`, one at a time) the job does this:

1. Reads the latest release with `.github/scripts/latest-release.sh`.
2. Compares it with the version in the formula. It never downgrades.
3. Stops if the playbook release path owns the update (`playbook` and `pbtop` only). That is the case while the `release/vX.Y.Z` pull request is open. A run that was not started by hand also waits for the first hour after the release.
4. Rewrites the URLs and checksums from that release's `SHA256SUMS`. `bump-formula.sh` refuses to write a formula when a checksum is missing.
5. Commits to a `bump/<formula>-v<version>` branch through the GitHub API, so GitHub signs the commit.
6. Opens a pull request, approves the held `tests` run, and waits for it to pass.
7. Squash merges the pull request through the API. The `protect-main` ruleset allows this because the required checks passed.

An open bump pull request is left alone by later runs.

The workflows use only the built-in `GITHUB_TOKEN`. No secret is stored.

## Helios track

Helios publishes its own releases in `amplifiedengineer/helios`. A release uses the tag `vX.Y.Z`. It has one `helios-<version>-<target>.tar.gz` asset per target, each holding the single `helios` binary, and a `SHA256SUMS` asset. The four targets are `aarch64-apple-darwin`, `x86_64-apple-darwin`, `aarch64-unknown-linux-musl` and `x86_64-unknown-linux-musl`.

The scheduled `release` workflow handles `helios` like any other formula in its matrix, with these differences:

- It has no `release/vX.Y.Z` pull request to wait for, so it does not defer to the playbook release path.
- It opens a `bump/helios-vX.Y.Z` pull request titled `chore(deps): bump helios to X.Y.Z`.
- The `release-tag` workflow ignores that branch, so a Helios bump does not tag or publish a tap release. The tap release notes leave `helios` out.
- Until Helios has a release with its archive, the run prints that there is no release yet and passes.
- At the first release there is no `Formula/helios.rb`. `bump-formula.sh` creates it from its template and fills in the checksums from `SHA256SUMS`.

The `helios` formula test runs `helios --version`, so Helios must support that flag before its first release.

## Caveats text

The caveats of each formula end with one line that links the release notes of the installed version. It is built from `#{version}`. The bump writes no caveats text.

## Tests

The `tests` workflow runs on every push to `main`, every pull request, weekly, and by hand. It has three jobs:

- `syntax`: `brew test-bot --only-tap-syntax`.
- `bump-script`: runs `.github/scripts/test-bump-formula.sh`, then a style check of the `pbtop` formula a release writes.
- `install`: `brew audit --strict --online`, `brew install` and `brew test` on Linux and macOS (arm64 and x86_64).

The `install` job also runs `pbtop --version` and `helios --version` after the test. A disabled or deprecated formula is only audited. Bottles are not built, because the formulas install prebuilt binaries.

## If a formula is behind

Check the latest `release` run in this repo.
