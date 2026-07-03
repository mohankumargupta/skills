#!/usr/bin/env bash
set -x

DEVICE="$1"

destination="artifacts/prompt4a"
chipfolder="${destination}/chip"
qatest="$destination/qatest"
src="$qatest/src"
tests="$qatest/tests"
rustinput="artifacts/prompt2a/qa_test"
diagramjson="artifacts/prompt3/diagram.json"
wokwitoml="artifacts/prompt4/wokwi.toml"
esphomeyaml="artifacts/prompt2/$DEVICE.yaml"

mkdir -p $destination
mkdir -p $chipfolder
mkdir -p $qatest/src
mkdir -p $qatest/tests
cp artifacts/prompt1/{"$DEVICE.chip.json",dist/chip.wasm} $chipfolder
mv "$chipfolder/$DEVICE.chip.json" "$chipfolder/chip.json"
cp "artifacts/prompt2/$DEVICE.yaml" $destination
cp $rustinput/src/*.rs $qatest/src
cp $rustinput/tests/*.rs $qatest/tests
cp $rustinput/Cargo.toml $qatest
cp $diagramjson $destination
cp $wokwitoml $destination
cp $esphomeyaml $destination


