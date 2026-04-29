#!/usr/bin/env bash

# This needs cargo install cargo-info before this will work

crate="$1"

cargo info -q "$crate"|grep repo|sed 's/^repository: //'
