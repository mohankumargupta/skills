#!/usr/bin/env bash

# Usage: $0 ssd1306_example

example="$1"
mkdir -p test
cd test
yaml_file="${example}.yaml"
../espforge/target/debug/espforge example "$example"
cd "$example"
ESPFORGE_LOCAL_PATH=../../espforge ../../espforge/target/debug/espforge compile "$yaml_file"


