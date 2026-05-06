#!/usr/bin/env bash
DEVICE="$1"
cd espforge
git diff main... > "../${DEVICE}_changes.diff"
