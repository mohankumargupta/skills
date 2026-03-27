#!/usr/bin/env bash

FOLDER="/home/pi/.picoclaw/workspace/outputs"
ESPFORGE="$FOLDER/espforge" 
REPO="https://github.com/mohankumargupta/espforge"

[ -d $ESPFORGE ] && ( cd $ESPFORGE && git pull --ff-only && git clean -dfx ) || ( cd $FOLDER && git clone $REPO )
