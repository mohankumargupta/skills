#!/usr/bin/env bash

set -x

# Usage: $0 ssd1306  
# Usage: $0 ssd1306 recompile 




DEVICE="$1"
RECOMPILE="$2"
EXAMPLE="${DEVICE}_example"
EXAMPLE_YAML="${EXAMPLE}.yaml"
CURRENT_DIR=$(pwd)
ESPFORGE_PATH="$CURRENT_DIR/espforge"
ESPFORGE="${ESPFORGE_PATH}/target/debug/espforge"

mkdir -p examples
cd examples

if [ -z "$RECOMPILE"  ];
then
$ESPFORGE example "$EXAMPLE"
fi

cd "$EXAMPLE"
ESPFORGE_LOCAL_PATH="$ESPFORGE_PATH" $ESPFORGE compile "$EXAMPLE_YAML"
cargo build
