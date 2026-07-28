---
name: collect-esphome-impl
description: Collect implementation details from the ESPHome source tree for component <component> and produce a normalized implementation summary for downstream skills.
---

# Purpose

Acquire implementation details from the ESPHome source code that are not reliably available from documentation.

This skill extracts the authoritative implementation behavior of an ESPHome component and produces a normalized summary that downstream skills may consume.

Examples:

- spec-from-datasheet
- canonical-test-spec
- generate-dut-yaml
- generate-test-rs
- generate-diagram-json

The ESPHome source code is considered authoritative over documentation when conflicts exist.

---

# Inputs

Required

- component name

Examples

```text
scd4x
bmp280
tmp102
sht31
```

---

# Context Variables

```text
<original_pwd>
<artifacts_dir>
<component>
```

Create

```text
<artifacts_dir>/esphome_impl
```

Output files

```text
<artifacts_dir>/esphome_impl/component_path.txt
<artifacts_dir>/esphome_impl/config_schema.md
<artifacts_dir>/esphome_impl/setup.md
<artifacts_dir>/esphome_impl/update.md
<artifacts_dir>/esphome_impl/dump_config.md
<artifacts_dir>/esphome_impl/esphome_impl_summary.md
```

---

# Step 1 Locate Component

Find component implementation.

Typical locations:

```text
esphome/components/<component>
```

Examples

```text
esphome/components/scd4x
esphome/components/bmp280
esphome/components/tmp102
```

Record discovered path in

```text
<artifacts_dir>/esphome_impl/component_path.txt
```

---

# Step 2 Collect Python Configuration Layer

Inspect

```text
esphome/components/<component>/sensor.py
esphome/components/<component>/__init__.py
```

Search for

```python
CONFIG_SCHEMA
cv.Schema
cv.Optional
cv.Required
polling_component_schema
```

Extract:

- required configuration keys
- optional configuration keys
- default values
- validation rules
- update interval defaults
- address defaults
- enum values
- supported modes

Write findings to

```text
<artifacts_dir>/esphome_impl/config_schema.md
```

---

# Step 3 Collect setup()

Inspect component implementation.

Typical files:

```text
component.cpp
sensor.cpp
*.cpp
```

Locate

```cpp
setup()
```

Summarize:

- initialization sequence
- transport initialization
- reset operations
- startup commands
- configuration commands
- measurement mode selection
- ordering requirements
- delays
- timing requirements

Do not copy source code.

Produce a behavioral summary.

Write

```text
<artifacts_dir>/esphome_impl/setup.md
```

---

# Step 4 Collect update()

Locate

```cpp
update()
```

Summarize:

- measurement flow
- polling behavior
- commands issued
- state transitions
- conversion formulas
- publish_state calls
- retry behavior
- timeout handling

For each published value record

```yaml
observable:
  publish_source:
  units:
```

Write

```text
<artifacts_dir>/esphome_impl/update.md
```

---

# Step 5 Collect dump_config()

Locate

```cpp
dump_config()
```

Summarize:

- reported configuration
- logged defaults
- diagnostic information
- reported modes
- reported addresses
- reported calibration settings

Write

```text
<artifacts_dir>/esphome_impl/dump_config.md
```

---

# Step 6 Build Implementation Summary

Create

```text
<artifacts_dir>/esphome_impl/esphome_impl_summary.md
```

using this template.

# ESPHome Implementation Summary

## Component

```yaml
component:
  name:
  path:
```

---

## Configuration

```yaml
configuration:

  required:

  optional:

  defaults:
```

---

## Published Observables

```yaml
observables:

  - name:
    units:
    published_by:
```

Example

```yaml
observables:

  - name: temperature
    units: C
    published_by: publish_state

  - name: humidity
    units: "%RH"
    published_by: publish_state
```

---

## Supported Modes

```yaml
modes:
```

Example

```yaml
modes:

  - periodic
  - low_power_periodic
```

---

## Initialization Behavior

Describe setup sequence in plain English.

---

## Measurement Behavior

Describe update sequence in plain English.

---

## ESPHome Defaults

Record only defaults discovered from implementation.

Example

```yaml
defaults:

  address: 0x62
  update_interval: 60s
  measurement_mode: periodic
  automatic_self_calibration: true
```

Never infer defaults.

Only record values explicitly present in source.

---

## Driver-Specific Notes

Record implementation details likely to affect

- generated YAML
- generated tests
- generated simulation fixtures

Examples

- first reading delay
- startup wait period
- polling requirements
- measurement cadence
- value publication timing

---

# Extraction Rules

Do not guess.

Do not infer behavior not present in source.

When behavior cannot be determined:

```yaml
status: unknown
```

Prefer implementation over documentation.

Prefer source code over comments.

Prefer explicit defaults over implied defaults.

---

# Success Criteria

The resulting summary must provide enough information for downstream skills to determine:

- which configuration options exist
- which defaults ESPHome actually uses
- which observables are published
- when values become available
- whether on_boot or on_value style testing is more appropriate
- how a minimal smoke test should interact with the component

without rereading the ESPHome source tree.

