#!/usr/bin/env bash

ESPFORGE="espforge" 
REPO="https://github.com/mohankumargupta/espforge"

[ -d $ESPFORGE ] && ( cd $ESPFORGE && git pull --ff-only && git clean -dfx ) || ( git clone $REPO )
