#!/usr/bin/env bash
# Update a formula to a release of the repo it installs from.
# The formula name picks the release asset suffix and the default source:
#   playbook            amplifiedengineer/playbook, tags vX.Y.Z       raw binary
#   pbtop               amplifiedengineer/playbook, tags vX.Y.Z       .tar.gz holding pbtop alone
#   helios              amplifiedengineer/helios, tags vX.Y.Z         .tar.gz holding helios alone
# Since playbook 0.34.0 one v release ships every tool.
# Helios has its own releases. Its asset is helios-<version>-<target>.tar.gz.
# The playbook formula also installs pbdoc and pbsync, from the release's
# pbdoc-<version>-<target>.tar.gz and pbsync-<version>-<target>.tar.gz archives,
# as one resource each per target next to the playbook binary. A release with
# no archive of a tool (older versions) gets a formula without that resource.
# SOURCE_REPO and TAG_PREFIX override the source (latest-release.sh prints them),
# which lets a formula keep following a legacy repo until its first prefixed tag.
# A tool formula that does not exist yet is created from a template at its first release.
# Usage: bump-formula.sh <version-without-v> [formula-path]
# URLs and checksums come from the release's own SHA256SUMS. Nothing is hand-edited.
# The caveats of each formula end with one line that links the release notes of
# the installed version, built from #{version}, so the bump writes no caveats
# text (ADR 0037 in amplifiedengineer/playbook).
set -euo pipefail

version="${1:?usage: bump-formula.sh <version> [formula-path]}"
formula="${2:-Formula/playbook.rb}"
name="$(basename "$formula" .rb)"
case "$name" in
  playbook) repo="playbook"; prefix="v"; suffix="" ;;
  pbtop)
    repo="playbook"; prefix="v"; suffix=".tar.gz"
    class_name="Pbtop"; alias_bin=""
    conflicts="playbook"
    desc="Terminal dashboard of Claude Code token use and cost"
    ;;
  helios)
    repo="helios"; prefix="v"; suffix=".tar.gz"
    class_name="Helios"; alias_bin=""
    desc="Keyboard-first terminal client for reviewing pull requests and watching CI across GitHub hosts"
    ;;
  *)
    echo "::error::no release mapping for formula '${name}'" >&2
    exit 1
    ;;
esac
repo="${SOURCE_REPO:-$repo}"
prefix="${TAG_PREFIX:-$prefix}"
tag="${prefix}${version}"
base="https://github.com/amplifiedengineer/${repo}/releases/download/${tag}"
# DOWNLOAD_BASE reads SHA256SUMS from another place,
# such as a file:// folder in a local test. The formula URLs keep the real base.
fetch_base="${DOWNLOAD_BASE:-$base}"
targets=(aarch64-apple-darwin x86_64-apple-darwin aarch64-unknown-linux-musl x86_64-unknown-linux-musl)

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "::error::refusing unexpected version '${version}'" >&2
  exit 1
fi

write_template() {
  # Writes the template to the file named by $1.
  local zero notes
  notes="Release notes: https://github.com/amplifiedengineer/${repo}/releases/tag/${prefix}#{version}"
  zero="$(printf '0%.0s' $(seq 1 64))"
  {
    printf 'class %s < Formula\n' "$class_name"
    printf '  desc "%s"\n' "$desc"
    printf '  homepage "https://github.com/amplifiedengineer/%s"\n' "$repo"
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
  } >"$1"
}

if [[ ! -f "$formula" && -z "${class_name:-}" ]]; then
  echo "::error::${formula} does not exist and '${name}' has no template" >&2
  exit 1
fi

sums="$(curl -fsSL --retry 3 --retry-delay 5 "${fetch_base}/SHA256SUMS")"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
# A new formula starts from the template in the temp file, so a refused
# release leaves no file behind.
if [[ -f "$formula" ]]; then cp "$formula" "$tmp"; else write_template "$tmp"; fi

# pbdoc and pbsync are bundled only into the playbook formula, and each only
# when the release ships its archive for every target. Some but not all is a
# broken release. A release with neither (older versions) gets neither.
pbdoc_shas=()
pbsync_shas=()
if [[ "$name" = playbook ]]; then
  for tool in pbdoc pbsync; do
    shas=()
    for target in "${targets[@]}"; do
      shas+=("$(awk -v f="${tool}-${version}-${target}.tar.gz" '$2 == f { print $1 }' <<<"$sums")")
    done
    found=0
    for sha in "${shas[@]}"; do
      [[ -z "$sha" ]] && continue
      found=$((found + 1))
      if [[ ! "$sha" =~ ^[0-9a-f]{64}$ ]]; then
        echo "::error::malformed ${tool} checksum in ${tag} SHA256SUMS. Refusing to write a partial formula." >&2
        exit 1
      fi
    done
    if [[ "$found" -ne 0 && "$found" -ne ${#targets[@]} ]]; then
      echo "::error::${tag} SHA256SUMS has ${tool} checksums for ${found} of ${#targets[@]} targets. Refusing to write a partial formula." >&2
      exit 1
    fi
    if [[ "$tool" = pbdoc ]]; then pbdoc_shas=("${shas[@]}"); else pbsync_shas=("${shas[@]}"); fi
  done
  # Drop the helper parts first, so a re-run on any release leaves one clean copy.
  awk '
    $0 == "      resource \"pbdoc\" do" || $0 == "      resource \"pbsync\" do" { skip = 1; next }
    skip { if ($0 == "      end") skip = 0; next }
    $0 == "    resource(\"pbdoc\").stage do" || $0 == "    resource(\"pbsync\").stage do" { skip_install = 1; next }
    skip_install { if ($0 == "    end") skip_install = 0; next }
    index($0, "/pbdoc --version") || index($0, "/pbsync --version") { next }
    { print }
  ' "$tmp" >"${tmp}.new"
  mv "${tmp}.new" "$tmp"
fi

for i in "${!targets[@]}"; do
  target="${targets[$i]}"
  pbdoc_sha="${pbdoc_shas[$i]:-}"
  pbsync_sha="${pbsync_shas[$i]:-}"
  sha="$(awk -v f="${name}-${version}-${target}${suffix}" '$2 == f { print $1 }' <<<"$sums")"
  if [[ ! "$sha" =~ ^[0-9a-f]{64}$ ]]; then
    echo "::error::missing or malformed checksum for ${target} in ${tag} SHA256SUMS. Refusing to write a partial formula." >&2
    exit 1
  fi
  # Rewrite the url line for this target, and the sha256 line that follows it.
  awk -v target="$target" -v suffix="$suffix" -v url="      url \"${base}/${name}-${version}-${target}${suffix}\"" -v sha="      sha256 \"${sha}\"" \
    -v pbdoc_url="        url \"${base}/pbdoc-${version}-${target}.tar.gz\"" -v pbdoc_sha="${pbdoc_sha}" \
    -v pbsync_url="        url \"${base}/pbsync-${version}-${target}.tar.gz\"" -v pbsync_sha="${pbsync_sha}" '
    $1 == "url" && index($0, "-" target suffix "\"") { print url; fix = 1; next }
    fix && $1 == "sha256" {
      print sha; fix = 0
      if (pbdoc_sha != "") {
        print "      resource \"pbdoc\" do"; print pbdoc_url
        print "        sha256 \"" pbdoc_sha "\""; print "      end"
      }
      if (pbsync_sha != "") {
        print "      resource \"pbsync\" do"; print pbsync_url
        print "        sha256 \"" pbsync_sha "\""; print "      end"
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
NOTES_LINE="      Release notes: https://github.com/amplifiedengineer/${repo}/releases/tag/${prefix}#{version}" awk '
  index($0, "      Release notes: https://github.com/") == 1 { print ENVIRON["NOTES_LINE"]; next } { print }
' "$tmp" >"${tmp}.new"
mv "${tmp}.new" "$tmp"

rewritten="$(grep -c "/download/${tag}/${name}-${version}-" "$tmp" || true)"
if [[ "$rewritten" -ne ${#targets[@]} ]]; then
  echo "::error::expected ${#targets[@]} url lines for ${tag} after the rewrite, found ${rewritten}. The formula layout changed. Refusing to write." >&2
  exit 1
fi

if [[ -n "${pbdoc_shas[0]:-}" || -n "${pbsync_shas[0]:-}" ]]; then
  # Install the helpers beside playbook: playbook finds them next to its own executable.
  has_pbdoc=0
  has_pbsync=0
  [[ -z "${pbdoc_shas[0]:-}" ]] || has_pbdoc=1
  [[ -z "${pbsync_shas[0]:-}" ]] || has_pbsync=1
  awk -v has_pbdoc="$has_pbdoc" -v has_pbsync="$has_pbsync" '
    { print }
    index($0, "bin.install_symlink \"playbook\" => \"pb\"") {
      if (has_pbdoc) {
        print "    resource(\"pbdoc\").stage do"
        print "      bin.install \"pbdoc\""
        print "      doc.install \"NOTICE-pbdoc\""
        print "    end"
      }
      if (has_pbsync) {
        print "    resource(\"pbsync\").stage do"
        print "      bin.install \"pbsync\""
        print "    end"
      }
    }
    index($0, "/pb --version") {
      if (has_pbdoc) print "    assert_match version.to_s, shell_output(\"#{bin}/pbdoc --version\")"
      if (has_pbsync) print "    assert_match version.to_s, shell_output(\"#{bin}/pbsync --version\")"
    }
  ' "$tmp" >"${tmp}.new"
  mv "${tmp}.new" "$tmp"
  for tool in pbdoc pbsync; do
    if [[ "$tool" = pbdoc ]]; then want="$has_pbdoc"; else want="$has_pbsync"; fi
    [[ "$want" -eq 1 ]] || continue
    tool_count="$(grep -c "/download/${tag}/${tool}-${version}-" "$tmp" || true)"
    if [[ "$tool_count" -ne ${#targets[@]} ]] || ! grep -qxF "      bin.install \"${tool}\"" "$tmp"; then
      echo "::error::expected ${#targets[@]} ${tool} resources and an install step for ${tag}, found ${tool_count}. The formula layout changed. Refusing to write." >&2
      exit 1
    fi
  done
fi

cp "$tmp" "$formula"
