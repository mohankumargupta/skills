#!/usr/bin/env bash

set -x

if [[ -d components && -d esphome ]]; then
  exit 0
fi

rm -rf components esphome
mkdir -p components
cd components
npx -y degit -f https://github.com/esphome/esphome.io/src/content/docs/components
cd ..
git clone --depth 1 https://github.com/esphome/esphome

