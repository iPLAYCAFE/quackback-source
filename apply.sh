#!/bin/sh
# Rebuild the modified Quackback source tree for one release of this bundle.
#
#   sh apply.sh <releaseId> <new-directory>
#
# Clones upstream Quackback, checks out the exact commit named in
# releases/<releaseId>/release.json, verifies the upstream lockfile, then applies
# every patch listed in releases/<releaseId>/series, in order, with `git apply`.
# Patches marked #WITHHELD are reported and skipped (see README.md, "Withheld
# patches"). Set QUACKBACK_UPSTREAM to use a local mirror instead of GitHub.
set -eu

release=${1:?usage: sh apply.sh <releaseId> <new-directory>}
target=${2:?usage: sh apply.sh <releaseId> <new-directory>}
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
rdir="$here/releases/$release"
upstream=${QUACKBACK_UPSTREAM:-https://github.com/QuackbackIO/quackback.git}

[ -f "$rdir/release.json" ] || { echo "unknown release: $release" >&2; exit 2; }
[ ! -e "$target" ] || { echo "target exists; choose a new directory" >&2; exit 2; }

field() { sed -n "s/.*\"$1\": \"\([^\"]*\)\".*/\1/p" "$rdir/release.json" | head -n 1; }
commit=$(field commit)
lock=$(field bunLockSha256)

(cd "$rdir" && sha256sum -c --quiet SHA256SUMS)

git clone --quiet --no-checkout "$upstream" "$target"
git -C "$target" config core.longpaths true
git -C "$target" checkout --quiet --detach "$commit"
[ "$(git -C "$target" rev-parse HEAD)" = "$commit" ] || { echo "commit mismatch" >&2; exit 1; }
[ "$(sha256sum "$target/bun.lock" | cut -d' ' -f1)" = "$lock" ] || { echo "bun.lock mismatch" >&2; exit 1; }

withheld=0
while IFS= read -r line; do
  case "$line" in
    ''|'# '*) continue ;;
    '#WITHHELD '*) withheld=$((withheld + 1)); echo "withheld: ${line#\#WITHHELD }" ;;
    *)
      patch="$rdir/patches/${line%% *}"
      (cd "$target" && git apply --check "$patch" && git apply "$patch")
      echo "applied:  ${line%% *}"
      ;;
  esac
done < "$rdir/series"

[ "$(sha256sum "$target/bun.lock" | cut -d' ' -f1)" = "$lock" ] || { echo "a patch changed bun.lock" >&2; exit 1; }
if [ "$withheld" -gt 0 ]; then
  echo "NOTE: $withheld patch(es) are withheld under coordinated disclosure; this tree is not yet the complete source of $release."
fi
echo "source ready: $target"
echo "build:        (cd \"$target\" && docker build --file apps/web/Dockerfile --tag quackback:$release .)"
