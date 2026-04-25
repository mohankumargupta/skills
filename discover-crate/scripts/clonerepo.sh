#!/usr/bin/env bash

BRANCH="feature/$1"
ESPFORGE="espforge" 
REPO="https://github.com/mohankumargupta/espforge"

[ -d $ESPFORGE ] && ( cd $ESPFORGE && git pull --ff-only && git clean -dfx ) || ( git clone $REPO )

cd "$ESPFORGE" || exit
git switch -c "$BRANCH"
