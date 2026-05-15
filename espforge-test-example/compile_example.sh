#!/usr/bin/env bash

set -x

# Usage: $0 ssd1306


DEVICE="$1"
EXAMPLE="${DEVICE}_example"
EXAMPLE_YAML="${EXAMPLE}.yaml"
CURRENT_DIR=$(pwd)
ESPFORGE_PATH="$CURRENT_DIR/espforge"
ESPFORGE="${ESPFORGE_PATH}/target/debug/espforge"
mkdir -p examples
cd examples
$ESPFORGE example "$EXAMPLE"
cd "$EXAMPLE"
ESPFORGE_LOCAL_PATH="$ESPFORGE_PATH" $ESPFORGE compile "$EXAMPLE_YAML"
cargo build
