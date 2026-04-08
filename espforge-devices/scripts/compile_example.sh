#!/usr/bin/env bash
example="$1"
cd "$example" || exit 1
yaml_file="${example}.yaml"
../espforge/target/debug/espforge example "$example"
ESPFORGE_LOCAL_PATH=../espforge ../espforge/target/debug/espforge compile "$yaml_file"



