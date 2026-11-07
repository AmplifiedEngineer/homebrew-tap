# homebrew-tap

Homebrew tap for the [amplifiedengineer/playbook](https://github.com/amplifiedengineer/playbook) toolkit.

| Formula | Install | What it is |
|---|---|---|
| `playbook` | `brew install amplifiedengineer/tap/playbook` | The Claude Code plugin toolkit and its binary. It links `pbtop` to `playbook`. |
| `pbtop` | `brew install amplifiedengineer/tap/pbtop` | The token and cost dashboard, for a machine without `playbook`. |

## Install

```bash
brew install amplifiedengineer/tap/playbook
```

Upgrade with `brew upgrade playbook`. The formula links `pbtop` to `playbook`, so one upgrade updates both and you do not install `pbtop` separately.

The `pbtop` formula is for a machine without `playbook`, and the two formulas conflict because both own the `pbtop` file. If you installed `pbtop` before, run `brew uninstall pbtop` once, then `brew reinstall playbook`. Homebrew refuses to upgrade `playbook` while the old `pbtop` is installed, and its message names that command.

## Trust the tap

Homebrew 6.0.0 and later asks you to trust non-official taps. Installing a fully qualified name, as above, trusts only that formula.

The install records that trust, so a later `brew upgrade playbook` works by short name. Without it, Homebrew stops with `Refusing to load formula ... from untrusted tap` and names the command to run. To install by short name without the full name first, run `brew tap amplifiedengineer/tap`, then `brew trust --formula amplifiedengineer/tap/playbook`. For `pbtop`, trust `amplifiedengineer/tap/pbtop`.

The broader option is `brew trust amplifiedengineer/tap`. It covers every current and future formula in the tap.

Run `brew trust` to list what you trust. Run `brew untrust <target>` to remove an entry, with `--formula` for a formula.

## What the formulas do

Each formula downloads the prebuilt binary that the `amplifiedengineer/playbook` release workflow builds, attests and checksums. It does not build from source. It uses the same `SHA256SUMS` that `install.sh` checks.

Platforms: macOS (Apple Silicon and Intel) and Linux (x86_64 and arm64, static musl builds). Windows is not a Homebrew target. Use `install.sh` or WSL.

## Moved from the old tap

This repo was named `homebrew-playbook`, and the old command was `brew install pragmatic-engineer/playbook/playbook`. To switch, run `brew untap pragmatic-engineer/playbook`, then install from `amplifiedengineer/tap`. If `brew untap` refuses, uninstall `playbook` first.

## Moved to the amplifiedengineer org

The GitHub organization is now `amplifiedengineer`. It was `pragmatic-engineer`. The tap is `amplifiedengineer/tap`. To move an existing install, run these commands. Homebrew refuses `brew untap` while a formula from the tap is installed, so uninstall first, and add `pbtop` to the first command if you installed it:

```bash
brew uninstall playbook
brew untap pragmatic-engineer/tap
brew install amplifiedengineer/tap/playbook
```

To keep the installed formula and the old tap name, point the tap at the new address instead:

```bash
git -C "$(brew --repository pragmatic-engineer/tap)" remote set-url origin https://github.com/amplifiedengineer/homebrew-tap.git
brew update
```

`brew tap --repair` does not move a tap to a new organization. Your playbook data stays in `~/.config/playbook`.

## Keeping the formulas current

A release of `amplifiedengineer/playbook` opens a pull request here that updates `playbook` and `pbtop` together. A scheduled workflow is the fallback. The `playbook` formula also installs `pbdoc` into the same `bin` from per-target `pbdoc-<version>-<target>.tar.gz` resources when the release lists all four. Do not edit URLs or checksums by hand. See [docs/release-automation.md](docs/release-automation.md).

## Security

See [SECURITY.md](SECURITY.md).
