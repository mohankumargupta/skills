#!/usr/bin/env bash
#set -x 
# Usage: ./check_crate_source.sh owner/repo device
GH_REPO="$1"
#OWNER="${GH_REPO%%/*}"
REPOSITORY="${GH_REPO#*/}"

#git clone --no-checkout --filter=blob:none https://github.com/marti157/bmp085-180-rs
#git sparse-checkout set --no-cone  "Cargo.toml" "src/" "examples/"
#git checkout

if [ -z "$GH_REPO" ]; then
    echo "Usage: $0 owner/repo"
    exit 1
fi

GITHUB_REPOSITORY="https://github.com/${GH_REPO}"
mkdir -p "artifacts"
cd artifacts
git clone --no-checkout --filter=blob:none "$GITHUB_REPOSITORY"
cd "$REPOSITORY"
git sparse-checkout set --no-cone  "Cargo.toml" "src/" "examples/"
git checkout


