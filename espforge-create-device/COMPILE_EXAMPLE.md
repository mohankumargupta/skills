# SKILL: Compile espforge example

Run `bash ~/.config/opencode/skills/espforge-create-device/scripts/compile_example.sh <device>` from 
current working directory.

This script will attempt to(not exact, just pseudocode follows):
1.  make a directory called examples, 
2.  `cd examples`, 
3.  call `espforge example <device>_example`
4.  `cd <device>_example`,
5. call `espforge compile <device>_example.yaml` 
6. call `cargo build`

If there is an error, you will need to edit espforge source code and recompile.
What you need to do after that depends on whether changes need to be made to espforge_examples
or espforge_devices/espforge_devices_builder. If it is former, then examples folder needs to be
deleted and this sub-skill need to be re-run. If it is the latter, you would be able
cd to `examples/<device>_example` and 
rerun `espforge compile <device>_example.yaml` then `cargo build`


