#!/usr/bin/env bash
# Tests bump-formula.sh against release folders built here and read through
# DOWNLOAD_BASE, so nothing touches the network. It checks the release notes
# line in the caveats, the pbtop template
# and latest-release.sh against a stub gh.
# Usage: test-bump-formula.sh [--keep]
# With --keep, Formula/pbtop.rb and a Formula/playbook.rb with pbdoc are left as a release writes it, so a style and
# audit run can check it.
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
script="$root/.github/scripts/bump-formula.sh"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
failures=0

pass() { printf 'PASS %s\n' "$1"; }
fail() { printf 'FAIL %s\n' "$1"; failures=$((failures + 1)); }

notes='      Release notes: https://github.com/amplifiedengineer/playbook/releases/tag/v#{version}'

# release VERSION: builds a release folder with the playbook binaries.
release() {
  local dir="$work/rel-$1" t
  rm -rf "$dir"
  mkdir -p "$dir"
  for t in aarch64-apple-darwin x86_64-apple-darwin aarch64-unknown-linux-musl x86_64-unknown-linux-musl; do
    printf 'bin %s\n' "$t" >"$dir/playbook-$1-$t"
  done
  (cd "$dir" && shasum -a 256 playbook-* >SHA256SUMS)
  printf '%s' "$dir"
}

mkdir -p "$work/f"
cp "$root/Formula/playbook.rb" "$work/f/playbook.rb"
dir="$(release 9.0.0)"
if DOWNLOAD_BASE="file://$dir" bash "$script" 9.0.0 "$work/f/playbook.rb" >/dev/null 2>"$work/err" \
  && [[ "$(grep -c '/download/v9.0.0/playbook-9.0.0-' "$work/f/playbook.rb")" -eq 4 ]] \
  && [[ "$(grep -cxF "$notes" "$work/f/playbook.rb")" -eq 1 ]] \
  && ! grep -qi 'breaking' "$work/f/playbook.rb" \
  && ruby -c "$work/f/playbook.rb" >/dev/null; then
  pass "a bump keeps the release notes line and writes no breaking block"
else
  fail "a bump keeps the release notes line and writes no breaking block"
fi

# A notes line that points elsewhere is rewritten to the current repo and prefix.
sed 's#releases/tag/v\#{version}#releases/tag/old-v\#{version}#' "$root/Formula/playbook.rb" >"$work/f/playbook.rb"
dir="$(release 9.1.0)"
if grep -q 'tag/old-v#{version}' "$work/f/playbook.rb" \
  && DOWNLOAD_BASE="file://$dir" bash "$script" 9.1.0 "$work/f/playbook.rb" >/dev/null 2>"$work/err" \
  && [[ "$(grep -cxF "$notes" "$work/f/playbook.rb")" -eq 1 ]] \
  && ! grep -q 'old-v' "$work/f/playbook.rb"; then
  pass "a bump rewrites the release notes line to the current repo and prefix"
else
  fail "a bump rewrites the release notes line to the current repo and prefix"
fi

# pbdoc_release VERSION [SKIP_TARGET] [TOOL]: a release folder with the playbook
# binaries and the pbdoc and pbsync archives, leaving out one target of TOOL
# (pbdoc by default) when given.
pbdoc_release() {
  local dir="$work/pbdoc-$1" t
  rm -rf "$dir"
  mkdir -p "$dir"
  for t in aarch64-apple-darwin x86_64-apple-darwin aarch64-unknown-linux-musl x86_64-unknown-linux-musl; do
    printf 'bin %s\n' "$t" >"$dir/playbook-$1-$t"
    [[ "$t" = "${2:-}" && "${3:-pbdoc}" = pbdoc ]] || printf 'pbdoc %s\n' "$t" >"$dir/pbdoc-$1-$t.tar.gz"
    [[ "$t" = "${2:-}" && "${3:-pbdoc}" = pbsync ]] || printf 'pbsync %s\n' "$t" >"$dir/pbsync-$1-$t.tar.gz"
  done
  (cd "$dir" && shasum -a 256 playbook-* pbdoc-* pbsync-* >SHA256SUMS)
  printf '%s' "$dir"
}

mkdir -p "$work/b"
pbf="$work/b/playbook.rb"
cp "$root/Formula/playbook.rb" "$pbf"
dir="$(pbdoc_release 9.2.0)"
if DOWNLOAD_BASE="file://$dir" bash "$script" 9.2.0 "$pbf" >/dev/null 2>"$work/err" \
  && [[ "$(grep -c 'resource "pbdoc" do' "$pbf")" -eq 4 ]] \
  && [[ "$(grep -c '/download/v9.2.0/pbdoc-9.2.0-.*\.tar\.gz"' "$pbf")" -eq 4 ]] \
  && [[ "$(grep -c '/download/v9.2.0/playbook-9.2.0-' "$pbf")" -eq 4 ]] \
  && grep -qx '      bin.install "pbdoc"' "$pbf" \
  && [[ "$(grep -c 'resource "pbsync" do' "$pbf")" -eq 4 ]] \
  && [[ "$(grep -c '/download/v9.2.0/pbsync-9.2.0-.*\.tar\.gz"' "$pbf")" -eq 4 ]] \
  && grep -qx '      bin.install "pbsync"' "$pbf" \
  && grep -qF '"#{bin}/pbsync --version"' "$pbf" \
  && ! grep -q '0\{64\}' "$pbf" \
  && ruby -c "$pbf" >/dev/null; then
  pass "a bump with pbdoc archives writes one pbdoc and one pbsync resource per target and installs them"
else
  fail "a bump with pbdoc archives writes one pbdoc resource per target and installs it"
fi

# The pbtop link and the conflict stay as they are, and the pbdoc step goes after the pb link.
if grep -qx '    bin.install_symlink "playbook" => "pbtop"' "$pbf" \
  && grep -q '^  conflicts_with "pbtop"' "$pbf" \
  && grep -qF '"#{bin}/pbtop --version"' "$pbf" \
  && [[ "$(grep -n 'install_symlink "playbook" => "pb"' "$pbf" | cut -d: -f1)" -lt "$(grep -n 'resource("pbdoc").stage' "$pbf" | cut -d: -f1)" ]]; then
  pass "a bump keeps the pbtop link and the conflict and puts pbdoc after the pb link"
else
  fail "a bump keeps the pbtop link and the conflict and puts pbdoc after the pb link"
fi

# Running it again, and then on a release without pbdoc, leaves a valid formula.
cp "$pbf" "$work/b/first.rb"
if DOWNLOAD_BASE="file://$dir" bash "$script" 9.2.0 "$pbf" >/dev/null 2>"$work/err" \
  && cmp -s "$pbf" "$work/b/first.rb"; then
  pass "a second bump of the same release changes nothing"
else
  fail "a second bump of the same release changes nothing"
fi
dir="$(release 9.3.0)"
if DOWNLOAD_BASE="file://$dir" bash "$script" 9.3.0 "$pbf" >/dev/null 2>"$work/err" \
  && ! grep -q 'pbdoc' "$pbf" \
  && ! grep -q 'resource.*pbsync\|pbsync --version' "$pbf" \
  && [[ "$(grep -c '/download/v9.3.0/playbook-9.3.0-' "$pbf")" -eq 4 ]] \
  && ruby -c "$pbf" >/dev/null; then
  pass "a bump to a release without pbdoc removes the pbdoc and pbsync parts"
else
  fail "a bump to a release without pbdoc removes the pbdoc and pbsync parts"
fi

mkdir -p "$work/b/partial"
cp "$root/Formula/playbook.rb" "$work/b/partial/playbook.rb"
dir="$(pbdoc_release 9.4.0 x86_64-unknown-linux-musl)"
if ! DOWNLOAD_BASE="file://$dir" bash "$script" 9.4.0 "$work/b/partial/playbook.rb" >/dev/null 2>"$work/err" \
  && grep -q 'pbdoc checksums for 3 of 4' "$work/err" \
  && cmp -s "$root/Formula/playbook.rb" "$work/b/partial/playbook.rb"; then
  pass "a release with pbdoc for only some targets is refused and the formula is unchanged"
else
  fail "a release with pbdoc for only some targets is refused and the formula is unchanged"
fi

mkdir -p "$work/b/partial-sync"
cp "$root/Formula/playbook.rb" "$work/b/partial-sync/playbook.rb"
dir="$(pbdoc_release 9.4.1 x86_64-unknown-linux-musl pbsync)"
if ! DOWNLOAD_BASE="file://$dir" bash "$script" 9.4.1 "$work/b/partial-sync/playbook.rb" >/dev/null 2>"$work/err" \
  && grep -q 'pbsync checksums for 3 of 4' "$work/err" \
  && cmp -s "$root/Formula/playbook.rb" "$work/b/partial-sync/playbook.rb"; then
  pass "a release with pbsync for only some targets is refused and the formula is unchanged"
else
  fail "a release with pbsync for only some targets is refused and the formula is unchanged"
fi

# tool_release NAME VERSION: a release folder with the archives of one tool.
tool_release() {
  local dir="$work/tool-$1-$2" t
  rm -rf "$dir"
  mkdir -p "$dir"
  for t in aarch64-apple-darwin x86_64-apple-darwin aarch64-unknown-linux-musl x86_64-unknown-linux-musl; do
    printf 'archive %s\n' "$t" >"$dir/$1-$2-$t.tar.gz"
  done
  (cd "$dir" && shasum -a 256 -- *.tar.gz >SHA256SUMS)
  printf '%s' "$dir"
}

mkdir -p "$work/p"
pbtop="$work/p/pbtop.rb"
dir="$(tool_release pbtop 9.7.0)"
if DOWNLOAD_BASE="file://$dir" bash "$script" 9.7.0 "$pbtop" >/dev/null 2>"$work/err" \
  && grep -qx '    bin.install "pbtop"' "$pbtop" \
  && [[ "$(grep -c '/download/v9.7.0/pbtop-9.7.0-' "$pbtop")" -eq 4 ]] \
  && ! grep -q '0\{64\}' "$pbtop" \
  && ruby -c "$pbtop" >/dev/null; then
  pass "the pbtop formula is written from its template"
else
  fail "the pbtop formula is written from its template"
fi
if grep -q '^  conflicts_with "playbook",$' "$pbtop" \
  && grep -q '^                because: ".*brew uninstall pbtop' "$pbtop" \
  && [[ "$(grep -cxF "$notes" "$pbtop")" -eq 1 ]] \
  && [[ "$(grep -A1 -xF "$notes" "$pbtop" | tail -n1)" = '    EOS' ]]; then
  pass "the pbtop template conflicts with playbook and ends its caveats with the release notes line"
else
  fail "the pbtop template conflicts with playbook and ends its caveats with the release notes line"
fi

# latest-release.sh against a stub gh. GH_RELEASES is the release list as
# JSON, and GH_ASSETS_<version with _> the asset names of a release.
latest="$root/.github/scripts/latest-release.sh"
mkdir -p "$work/bin"
cat >"$work/bin/gh" <<'STUB'
#!/usr/bin/env bash
repo=""; jq_filter=""; tag=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo) repo="$2"; shift ;;
    --jq) jq_filter="$2"; shift ;;
    release|list|view|--json|--limit) ;;
    tagName,isDraft,isPrerelease|assets|100) ;;
    *) tag="$1" ;;
  esac
  shift
done
if [ "$repo" != amplifiedengineer/playbook ]; then
  echo "GraphQL: Could not resolve to a Repository with the name '${repo}'." >&2
  exit 1
fi
if [ -z "$tag" ]; then
  jq -r "$jq_filter" <<<"$GH_RELEASES"
else
  var="GH_ASSETS_${tag//./_}"
  printf '%s\n' ${!var:-}
fi
STUB
chmod +x "$work/bin/gh"
releases='[{"tagName":"v9.1.0","isDraft":false,"isPrerelease":false},
  {"tagName":"v9.0.0","isDraft":false,"isPrerelease":false},
  {"tagName":"telemetry-v0.2.0","isDraft":false,"isPrerelease":false}]'
lookup() { PATH="$work/bin:$PATH" GH_RELEASES="$releases" bash "$latest" "$1" 2>"$work/err"; }

if [[ "$(GH_ASSETS_v9_1_0="playbook-9.1.0-x86_64-unknown-linux-musl" \
  GH_ASSETS_v9_0_0="pbtop-9.0.0-x86_64-unknown-linux-musl.tar.gz" lookup pbtop)" = "playbook v 9.0.0" ]]; then
  pass "pbtop skips a v release without its archive"
else
  fail "pbtop skips a v release without its archive"
fi
if [[ "$(lookup playbook)" = "playbook v 9.1.0" ]]; then
  pass "playbook takes the newest v release"
else
  fail "playbook takes the newest v release"
fi

if [[ "${1:-}" = "--keep" ]]; then
  cp "$pbtop" "$root/Formula/pbtop.rb"
  cp "$work/b/first.rb" "$root/Formula/playbook.rb"
  printf 'Left Formula/pbtop.rb as a release writes it, for the style check.\n'
fi

if [[ "$failures" -ne 0 ]]; then
  printf '%d failed\n' "$failures"
  exit 1
fi
printf 'all passed\n'
