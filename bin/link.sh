#!/usr/bin/env bash
# bin/link.sh — minimal GNU-stow-compatible linker.
#
# Only used as a fallback when the real `stow` binary isn't available
# (e.g. no sudo/package manager on a locked-down machine). Semantics:
# for every file under <dotfiles>/<package>/, create the same relative
# path under <target> as a symlink pointing back into the repo.
# Existing real files are backed up with a .bak-<timestamp> suffix.
#
# Usage: link.sh <dotfiles_dir> <package_name> <target_dir>

set -euo pipefail

dotfiles_dir=$1
package=$2
target_dir=$3
src_root="$dotfiles_dir/$package"
stamp=$(date +%Y%m%d%H%M%S)

if [ ! -d "$src_root" ]; then
    echo "link.sh: no such package dir: $src_root" >&2
    exit 1
fi

find "$src_root" -type f | while IFS= read -r src_file; do
    rel="${src_file#"$src_root"/}"
    dest="$target_dir/$rel"
    mkdir -p "$(dirname "$dest")"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src_file" ]; then
        continue # already correctly linked
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "link.sh: backing up existing $dest -> $dest.bak-$stamp"
        mv "$dest" "$dest.bak-$stamp"
    fi

    ln -s "$src_file" "$dest"
    echo "link.sh: linked $dest -> $src_file"
done
