# homebrew-tap

Homebrew tap for the [pragmatic-engineer/playbook](https://github.com/pragmatic-engineer/playbook) toolkit.

| Formula | Install | What it is |
|---|---|---|
| `playbook` | `brew install pragmatic-engineer/tap/playbook` | The Claude Code plugin toolkit and its binary. It links `pbtop` to `playbook`. |
| `pbtop` | `brew install pragmatic-engineer/tap/pbtop` | The token and cost dashboard, for a machine without `playbook`. |
| `playbook-telemetry` | Retired. Install `pbtop` instead. | Replaced by `pbtop`. |

## Install

```bash
brew install pragmatic-engineer/tap/playbook
```

Upgrade with `brew upgrade playbook`. The formula links `pbtop` to `playbook`, so one upgrade updates both and you do not install `pbtop` separately.

The `pbtop` formula is for a machine without `playbook`, and the two formulas conflict because both own the `pbtop` file. If you installed `pbtop` before, run `brew uninstall pbtop` once, then `brew reinstall playbook`. Homebrew refuses to upgrade `playbook` while the old `pbtop` is installed, and its message names that command.

## Trust the tap

Homebrew 6.0.0 and later asks you to trust non-official taps. Installing a fully qualified name, as above, trusts only that formula.

The install records that trust, so a later `brew upgrade playbook` works by short name. Without it, Homebrew stops with `Refusing to load formula ... from untrusted tap` and names the command to run. To install by short name without the full name first, run `brew tap pragmatic-engineer/tap`, then `brew trust --formula pragmatic-engineer/tap/playbook`. For `pbtop`, trust `pragmatic-engineer/tap/pbtop`.

The broader option is `brew trust pragmatic-engineer/tap`. It covers every current and future formula in the tap.

Run `brew trust` to list what you trust. Run `brew untrust <target>` to remove an entry, with `--formula` for a formula.

## What the formulas do

Each formula downloads the prebuilt binary that the `pragmatic-engineer/playbook` release workflow builds, attests and checksums. It does not build from source. It uses the same `SHA256SUMS` that `install.sh` checks.

Platforms: macOS (Apple Silicon and Intel) and Linux (x86_64 and arm64, static musl builds). Windows is not a Homebrew target. Use `install.sh` or WSL.

## Retired: playbook-telemetry

`playbook-telemetry` is replaced by `pbtop`. Homebrew shows it as deprecated until 2026-11-16, then disabled. To switch:

```bash
brew uninstall playbook-telemetry && brew install pbtop
```

## Moved from the old tap

This repo was named `homebrew-playbook`, and the old command was `brew install pragmatic-engineer/playbook/playbook`. To switch, run `brew untap pragmatic-engineer/playbook`, then install from `pragmatic-engineer/tap`. If `brew untap` refuses, uninstall `playbook` first.

## Keeping the formulas current

A release of `pragmatic-engineer/playbook` opens a pull request here that updates `playbook` and `pbtop` together. A scheduled workflow is the fallback. The `playbook` formula also installs `pbdoc` into the same `bin` from per-target `pbdoc-<version>-<target>.tar.gz` resources when the release lists all four. Do not edit URLs or checksums by hand. See [docs/release-automation.md](docs/release-automation.md).

## Security

See [SECURITY.md](SECURITY.md).
