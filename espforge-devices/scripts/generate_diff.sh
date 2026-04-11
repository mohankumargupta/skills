#!/usr/bin/env bash
DEVICE="$1"
cd espforge
git add .
git diff --cached > "../${DEVICE}_changes.diff"

