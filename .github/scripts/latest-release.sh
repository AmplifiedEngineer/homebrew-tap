#!/usr/bin/env bash
# Print the latest published release for a formula as "<repo> <tag-prefix> <version>".
# Releases come from amplifiedengineer/playbook:
#   playbook            v            the raw binary
#   pbtop               v            from the first v release that carries its archive
# Since playbook 0.34.0 one v release ships every tool (ADR 0038 in
# amplifiedengineer/playbook), so a v release counts for a tool only when it
# has the tool's asset. Until a prefixed release exists in playbook, a formula
# keeps following the legacy repo it shipped from. A legacy repo that does not
# exist counts as no release, and any other failed lookup fails the script.
# Prints nothing when there is no release at all.
# Usage: latest-release.sh <formula-name>
set -euo pipefail

formula="${1:?usage: latest-release.sh <formula>}"
case "$formula" in
  playbook) candidates=("playbook v -") ;;
  pbtop) candidates=("playbook v asset") ;;
  *)
    echo "::error::no release mapping for formula '${formula}'" >&2
    exit 1
    ;;
esac

err="$(mktemp)"
trap 'rm -f "$err"' EXIT

for candidate in "${candidates[@]}"; do
  read -r repo prefix need <<<"$candidate"
  if ! tags="$(gh release list --repo "amplifiedengineer/${repo}" --limit 100 --json tagName,isDraft,isPrerelease \
    --jq "[.[] | select(.isDraft == false and .isPrerelease == false) | .tagName | select(test(\"^${prefix}[0-9]+\\\\.[0-9]+\\\\.[0-9]+\$\"))] | .[]" 2>"$err")"; then
    if [ "$repo" != playbook ] && grep -q "Could not resolve to a Repository" "$err"; then
      continue
    fi
    echo "::error::could not list the releases of amplifiedengineer/${repo}: $(cat "$err")" >&2
    exit 1
  fi
  # Only the five newest releases are checked for an asset, which bounds the
  # API calls of a scheduled run.
  checked=0
  while IFS= read -r tag; do
    [ -n "$tag" ] || continue
    version="${tag#"$prefix"}"
    if [ "$need" = asset ]; then
      checked=$((checked + 1))
      [ "$checked" -le 5 ] || break
      assets="$(gh release view "$tag" --repo "amplifiedengineer/${repo}" --json assets --jq '.assets[].name')"
      grep -qx "${formula}-${version}-x86_64-unknown-linux-musl.tar.gz" <<<"$assets" || continue
    fi
    printf '%s %s %s\n' "$repo" "$prefix" "$version"
    exit 0
  done <<<"$tags"
done
