#!/usr/bin/env bash

if [[ -d components ]]; then
  exit 0
fi

mkdir -p components
cd components
npx -y degit -f https://github.com/esphome/esphome.io/src/content/docs/components
