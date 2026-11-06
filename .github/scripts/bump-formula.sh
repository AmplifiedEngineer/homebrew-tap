#!/usr/bin/env bash
# Update a formula to a release of the repo it installs from.
# The formula name picks the release asset suffix and the default source:
#   playbook            pragmatic-engineer/playbook, tags vX.Y.Z       raw binary
#   pbtop               pragmatic-engineer/playbook, tags vX.Y.Z       .tar.gz holding pbtop alone
# Since playbook 0.34.0 one v release ships every tool. playbook-telemetry is
# retired and replaced by pbtop, so it is no longer bumped.
# The playbook formula also installs pbdoc, from the release's pbdoc-<version>-<target>.tar.gz
# archives, as one resource per target next to the playbook binary. A release
# with no pbdoc archive (older versions) gets a formula without the resource.
# SOURCE_REPO and TAG_PREFIX override the source (latest-release.sh prints them),
# which lets a formula keep following a legacy repo until its first prefixed tag.
# A tool formula that does not exist yet is created from a template at its first release.
# Usage: bump-formula.sh <version-without-v> [formula-path]
# URLs and checksums come from the release's own SHA256SUMS. Nothing is hand-edited.
# The caveats of each formula end with one line that links the release notes of
# the installed version, built from #{version}, so the bump writes no caveats
# text (ADR 0037 in pragmatic-engineer/playbook).
set -euo pipefail

version="${1:?usage: bump-formula.sh <version> [formula-path]}"
formula="${2:-Formula/playbook.rb}"
name="$(basename "$formula" .rb)"
case "$name" in
  playbook) repo="playbook"; prefix="v"; suffix="" ;;
  playbook-telemetry)
    echo "::error::playbook-telemetry is retired; use pbtop" >&2
    exit 1
    ;;
  pbtop)
    repo="playbook"; prefix="v"; suffix=".tar.gz"
    class_name="Pbtop"; alias_bin=""
    conflicts="playbook"
    desc="Terminal dashboard of Claude Code token use and cost"
    ;;
  *)
    echo "::error::no release mapping for formula '${name}'" >&2
    exit 1
    ;;
esac
repo="${SOURCE_REPO:-$repo}"
prefix="${TAG_PREFIX:-$prefix}"
tag="${prefix}${version}"
base="https://github.com/pragmatic-engineer/${repo}/releases/download/${tag}"
# DOWNLOAD_BASE reads SHA256SUMS from another place,
# such as a file:// folder in a local test. The formula URLs keep the real base.
fetch_base="${DOWNLOAD_BASE:-$base}"
targets=(aarch64-apple-darwin x86_64-apple-darwin aarch64-unknown-linux-musl x86_64-unknown-linux-musl)

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "::error::refusing unexpected version '${version}'" >&2
  exit 1
fi

write_template() {
  local zero notes
  notes="Release notes: https://github.com/pragmatic-engineer/${repo}/releases/tag/${prefix}#{version}"
  zero="$(printf '0%.0s' $(seq 1 64))"
  {
    printf 'class %s < Formula\n' "$class_name"
    printf '  desc "%s"\n' "$desc"
    printf '  homepage "https://github.com/pragmatic-engineer/%s"\n' "$repo"
    printf '  license "Apache-2.0"\n\n'
    printf '  livecheck do\n    url :stable\n    strategy :github_releases\n    regex(/^%sv(\\d+(?:\\.\\d+)+)$/i)\n  end\n' "${prefix%v}"
    local os t_arm t_x
    for os in macos linux; do
      if [[ "$os" = macos ]]; then t_arm=aarch64-apple-darwin; t_x=x86_64-apple-darwin
      else t_arm=aarch64-unknown-linux-musl; t_x=x86_64-unknown-linux-musl; fi
      printf '\n  on_%s do\n    if Hardware::CPU.arm?\n' "$os"
      printf '      url "%s/%s-%s-%s%s"\n      sha256 "%s"\n' "$base" "$name" "$version" "$t_arm" "$suffix" "$zero"
      printf '    else\n'
      printf '      url "%s/%s-%s-%s%s"\n      sha256 "%s"\n' "$base" "$name" "$version" "$t_x" "$suffix" "$zero"
      printf '    end\n  end\n'
    done
    if [[ -n "${conflicts:-}" ]]; then
      printf '\n  conflicts_with "%s",\n' "$conflicts"
      printf '                because: "%s already provides %s. Run: brew uninstall %s, then brew reinstall %s"\n' "$conflicts" "$name" "$name" "$conflicts"
    fi
    if [[ -n "$alias_bin" ]]; then
      printf '\n  def install\n    bin.install "%s", "%s"\n  end\n' "$name" "$alias_bin"
      # shellcheck disable=SC2016 # the backticks are literal caveats text
      printf '\n  def caveats\n    <<~EOS\n      `%s` is a short alias for `%s`. Both are installed.\n' "$alias_bin" "$name"
      printf '      %s\n    EOS\n  end\n' "$notes"
      printf '\n  test do\n    assert_match version.to_s, shell_output("#{bin}/%s --version")\n' "$name"
      printf '    assert_match version.to_s, shell_output("#{bin}/%s --version")\n  end\nend\n' "$alias_bin"
    else
      printf '\n  def install\n    bin.install "%s"\n  end\n' "$name"
      # shellcheck disable=SC2016 # the backticks are literal caveats text
      printf '\n  def caveats\n    <<~EOS\n      Run `%s` to start.\n' "$name"
      if [[ -n "${conflicts:-}" ]]; then
        printf '      This formula is for a machine without %s. The %s formula links\n' "$conflicts" "$conflicts"
        printf '      `%s` to `%s`, so if you install %s later, run `brew uninstall %s` first.\n' "$name" "$conflicts" "$conflicts" "$name"
      fi
      printf '      %s\n    EOS\n  end\n' "$notes"
      printf '\n  test do\n    assert_match version.to_s, shell_output("#{bin}/%s --version")\n  end\nend\n' "$name"
    fi
  } >"$formula"
}

if [[ ! -f "$formula" ]]; then
  if [[ -z "${class_name:-}" ]]; then
    echo "::error::${formula} does not exist and '${name}' has no template" >&2
    exit 1
  fi
  write_template
fi

sums="$(curl -fsSL --retry 3 --retry-delay 5 "${fetch_base}/SHA256SUMS")"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
cp "$formula" "$tmp"

# pbdoc is bundled only into the playbook formula, and only when the release
# ships its archive for every target. Some but not all is a broken release.
pbdoc_shas=()
if [[ "$name" = playbook ]]; then
  for target in "${targets[@]}"; do
    pbdoc_shas+=("$(awk -v f="pbdoc-${version}-${target}.tar.gz" '$2 == f { print $1 }' <<<"$sums")")
  done
  found=0
  for sha in "${pbdoc_shas[@]}"; do
    [[ -z "$sha" ]] && continue
    found=$((found + 1))
    if [[ ! "$sha" =~ ^[0-9a-f]{64}$ ]]; then
      echo "::error::malformed pbdoc checksum in ${tag} SHA256SUMS. Refusing to write a partial formula." >&2
      exit 1
    fi
  done
  if [[ "$found" -ne 0 && "$found" -ne ${#targets[@]} ]]; then
    echo "::error::${tag} SHA256SUMS has pbdoc checksums for ${found} of ${#targets[@]} targets. Refusing to write a partial formula." >&2
    exit 1
  fi
  # Drop the pbdoc parts first, so a re-run on any release leaves one clean copy.
  awk '
    $0 == "      resource \"pbdoc\" do" { skip = 1; next }
    skip { if ($0 == "      end") skip = 0; next }
    $0 == "    resource(\"pbdoc\").stage do" { skip_install = 1; next }
    skip_install { if ($0 == "    end") skip_install = 0; next }
    index($0, "/pbdoc --version") { next }
    { print }
  ' "$tmp" >"${tmp}.new"
  mv "${tmp}.new" "$tmp"
fi

for i in "${!targets[@]}"; do
  target="${targets[$i]}"
  pbdoc_sha="${pbdoc_shas[$i]:-}"
  sha="$(awk -v f="${name}-${version}-${target}${suffix}" '$2 == f { print $1 }' <<<"$sums")"
  if [[ ! "$sha" =~ ^[0-9a-f]{64}$ ]]; then
    echo "::error::missing or malformed checksum for ${target} in ${tag} SHA256SUMS. Refusing to write a partial formula." >&2
    exit 1
  fi
  # Rewrite the url line for this target, and the sha256 line that follows it.
  awk -v target="$target" -v suffix="$suffix" -v url="      url \"${base}/${name}-${version}-${target}${suffix}\"" -v sha="      sha256 \"${sha}\"" \
    -v pbdoc_url="        url \"${base}/pbdoc-${version}-${target}.tar.gz\"" -v pbdoc_sha="${pbdoc_sha}" '
    $1 == "url" && index($0, "-" target suffix "\"") { print url; fix = 1; next }
    fix && $1 == "sha256" {
      print sha; fix = 0
      if (pbdoc_sha != "") {
        print "      resource \"pbdoc\" do"; print pbdoc_url
        print "        sha256 \"" pbdoc_sha "\""; print "      end"
      }
      next
    }
    { print }
  ' "$tmp" >"${tmp}.new"
  mv "${tmp}.new" "$tmp"
done

# The livecheck regex follows the tag prefix, so a formula that moves to a
# new tag prefix checks the right releases.
LIVECHECK_RE="    regex(/^${prefix}(\\d+(?:\\.\\d+)+)\$/i)" awk '
  $1 ~ /^regex\(\/\^/ { print ENVIRON["LIVECHECK_RE"]; next } { print }
' "$tmp" >"${tmp}.new"
mv "${tmp}.new" "$tmp"

# The release notes line in the caveats follows the repo and tag prefix too,
# so a formula that moves its source links the right release page.
NOTES_LINE="      Release notes: https://github.com/pragmatic-engineer/${repo}/releases/tag/${prefix}#{version}" awk '
  index($0, "      Release notes: https://github.com/") == 1 { print ENVIRON["NOTES_LINE"]; next } { print }
' "$tmp" >"${tmp}.new"
mv "${tmp}.new" "$tmp"

rewritten="$(grep -c "/download/${tag}/${name}-${version}-" "$tmp" || true)"
if [[ "$rewritten" -ne ${#targets[@]} ]]; then
  echo "::error::expected ${#targets[@]} url lines for ${tag} after the rewrite, found ${rewritten}. The formula layout changed. Refusing to write." >&2
  exit 1
fi

if [[ -n "${pbdoc_shas[0]:-}" ]]; then
  # Install pbdoc beside playbook: playbook finds it next to its own executable.
  awk '
    { print }
    index($0, "bin.install_symlink \"playbook\" => \"pb\"") {
      print "    resource(\"pbdoc\").stage do"
      print "      bin.install \"pbdoc\""
      print "      doc.install \"NOTICE-pbdoc\""
      print "    end"
    }
    index($0, "/pb --version") {
      print "    assert_match version.to_s, shell_output(\"#{bin}/pbdoc --version\")"
    }
  ' "$tmp" >"${tmp}.new"
  mv "${tmp}.new" "$tmp"
  pbdoc_count="$(grep -c "/download/${tag}/pbdoc-${version}-" "$tmp" || true)"
  if [[ "$pbdoc_count" -ne ${#targets[@]} ]] || ! grep -qxF '      bin.install "pbdoc"' "$tmp"; then
    echo "::error::expected ${#targets[@]} pbdoc resources and an install step for ${tag}, found ${pbdoc_count}. The formula layout changed. Refusing to write." >&2
    exit 1
  fi
fi

cp "$tmp" "$formula"
