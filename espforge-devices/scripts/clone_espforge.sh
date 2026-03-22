#!/usr/bin/env sh
# clone_espforge.sh
# Clones the espforge repo into ~/.picoclaw/workspace/assets/espforge/
# If already cloned, pulls latest changes from the default branch.

REPO_URL="https://github.com/mohankumargupta/espforge.git"
DEST="$HOME/.picoclaw/workspace/assets/espforge"

if [ -d "$DEST/.git" ]; then
  echo "espforge repo already present at $DEST — pulling latest..."
  git -C "$DEST" pull --ff-only
else
  echo "Cloning espforge into $DEST ..."
  mkdir -p "$(dirname "$DEST")"
  git clone --depth=1 "$REPO_URL" "$DEST"
fi

echo "Done. espforge is at: $DEST"

