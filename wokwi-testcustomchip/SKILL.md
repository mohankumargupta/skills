````markdown
---
name: generate_wokwi_smoke_test
description: |
  Given a Wokwi custom chip implementation (chip.zig), generate the minimal
  deterministic test harness required to prove the custom chip's primary
  functionality using ESPHome running inside the Wokwi VS Code extension.
---

# Skill: Generate Wokwi Smoke Test

## Purpose

This skill generates a **temporary test harness** for validating a Wokwi custom
chip implementation.

The generated artifacts are disposable.

The only artifact that matters is:

```
chip.zig
```

Everything else exists solely to exercise `chip.zig` and provide confidence that
the simulated device is capable of performing its primary purpose before it is
used by another firmware stack.

The goal is **not** exhaustive protocol verification.

The goal is **not** ESPHome testing.

The goal is **not** datasheet conformance.

The goal is to establish a deterministic known-good baseline.

---

# Inputs

Required

```
chip.zig
```

Optional

```
ESPHome source tree
component-api.md
datasheet
existing diagram.json
```

The ESPHome source tree is the authoritative reference for component behaviour
when available.

Documentation should only be used to supplement missing information.

---

# Outputs

Generate

```
dut.yaml
test.rs
diagram.json
```

These files are throwaway artifacts.

---

# Philosophy

The generated test should answer one question:

> Can this Wokwi custom chip successfully demonstrate the primary reason the
> real hardware exists?

Examples

TMP102

- Temperature measurement

BMP280

- Temperature
- Pressure

SCD40

- CO₂
- Temperature
- Relative Humidity

Ignore advanced functionality unless explicitly requested.

Examples

- calibration
- self calibration
- altitude compensation
- EEPROM persistence
- self tests
- fault injection
- power saving modes
- configuration persistence
- alarm thresholds

Assume

- ideal operating conditions
- calibration already complete
- deterministic sensor outputs
- no hardware faults

---

# Design Principle

The three generated artifacts must never invent information independently.

Instead, generation occurs in two phases.

## Phase 1 — Analysis

First analyse

- chip.zig
- ESPHome component
- component documentation

Produce an internal **Canonical Test Specification**.

This specification is the single source of truth.

It is an internal planning artifact and is not emitted.

Example

```yaml
device:
  name: TMP102

primary_observable:
  temperature

fixture:

  temperature:
    default: 21.0
    units: C

presentation:

  label: Temperature
  precision: 1
  serial_template: "Temperature = {:.1f} C"

yaml_strategy:

  trigger: on_boot
```

No code is generated during this phase.

No guessing is permitted during this phase.

If required information cannot be determined from the available inputs, state
the uncertainty instead of inventing values.

---

## Phase 2 — Rendering

Render every artifact from the Canonical Test Specification.

```
             Canonical Test Specification
                      │
      ┌───────────────┼───────────────┐
      │               │               │
 diagram.json      dut.yaml        test.rs
```

No renderer is permitted to invent

- labels
- default values
- formatting
- precision
- units
- serial strings

Every value must originate from the Canonical Test Specification.

---

# diagram.json

Generate deterministic fixture values.

Example

```text
temperature = 21.0
humidity = 50.0
pressure = 1013.25
co2 = 600
```

Choose sensible real-world defaults.

Avoid edge cases.

Avoid random values.

Avoid calibration.

diagram.json represents the simulated environment.

---

# dut.yaml

Generate the smallest possible ESPHome configuration that exercises the
component.

Requirements

- instantiate the correct component
- configure required buses
- read the primary observable(s)
- emit deterministic serial output

The skill should choose the most deterministic strategy supported by the
component.

Typically this will be

- on_boot
- on_value

The decision must be based on inspection of the ESPHome component rather than
guesswork.

Avoid unnecessary scheduling, polling or delays.

---

# test.rs

Generate host-side assertions against the ESPHome serial output.

The test communicates with Wokwi through the RFC2217 serial server.

Assertions must exactly match the generated serial output.

Never duplicate formatting logic.

Never independently reconstruct expected strings.

Expected serial output must be rendered from the same canonical template used to
generate the YAML logger output.

---

# Canonical Serial Messages

Serial output is the contract between

```
dut.yaml
```

and

```
test.rs
```

Therefore every observable serial message shall have exactly one canonical
definition.

Example

```
Template

Temperature = {:.1f} C

↓

YAML

logger.log

↓

Runtime

Temperature = 21.0 C

↓

test.rs

assert_serial!("Temperature = 21.0 C");
```

The YAML generator and Rust generator must never independently decide

- wording
- spacing
- capitalization
- units
- precision

Those are defined exactly once.

---

# Hallucination Prevention

This skill prioritizes eliminating ambiguity.

Generation is forbidden from inventing information.

Every generated value must have an identifiable source.

Examples

| Generated value | Source |
|-----------------|--------|
| default temperature | Canonical Test Specification |
| log label | Canonical Test Specification |
| decimal precision | Canonical Test Specification |
| serial string | Canonical Test Specification |
| assertion string | Rendered serial template |
| YAML trigger strategy | ESPHome component analysis |

If a renderer requires information not present in the Canonical Test
Specification, generation must stop and report the missing information instead
of guessing.

---

# Success Criteria

A successful generated test demonstrates that

- the Wokwi custom chip loads correctly
- ESPHome communicates with the custom chip
- the primary observable(s) can be read
- deterministic values flow from

```
diagram.json
    ↓
chip.zig
    ↓
ESPHome
    ↓
Serial Log
    ↓
test.rs
```

- every assertion passes

This establishes a deterministic baseline proving that the Wokwi custom chip
can perform its primary function under ideal conditions.
````
