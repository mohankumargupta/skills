#!/usr/bin/env bash
# clone_espforge.sh
# Clones the espforge repo in current directory
# If already cloned, pulls latest changes from the default branch.

REPO_URL="https://github.com/mohankumargupta/espforge.git"
DEST="espforge"

if [ -d "$DEST/.git" ]; then
  echo "espforge repo already present at $DEST — pulling latest..."
  git -C "$DEST" pull --ff-only
  git clean -dfx
else
  echo "Cloning espforge into $DEST ..."
  git clone --depth=1 "$REPO_URL" "$DEST"
fi

echo "Done. espforge is at: $DEST"

