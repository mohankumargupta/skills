---
name: canonical-test-spec
description: Produce an internal Canonical Test Specification from a hardware chip specification for device <device>
---

# Context Variables

<original_pwd>: run pwd, this is <original_pwd>
<artifacts_dir>: directory is `<original_pwd>/artifacts/<device>/prompt2a`, you will need to create this.
<input_spec_file>: <original_pwd>/artifacts/<device>/prompt0/<device>.md
<output_spec_file>: <artifacts_dir>/test_spec_<device>.md
<feedback_dir>: <original_pwd>/feedback/<device>, you will need to create this
<feedback_file>: <feedback_dir>/prompt2a.md


# Skill: Canonical Test Specification

## Purpose

Produce a deterministic, implementation-independent specification describing
the smallest observable scenario that demonstrates the primary functionality of
a hardware device.

This specification is intended to be consumed by downstream code generation
skills.

It is **not** firmware.

It is **not** test code.

It is **not** simulator configuration.

It is **not** tied to ESPHome, Wokwi or any particular framework.

It is the single source of truth from which those artifacts are generated.

---

# Inputs

<input_spec_file>

---

# Output

Produce one Canonical Test Specification.

This specification is an intermediate artifact intended to be consumed by other
skills.

It is not intended to be edited manually.

---

# Design Goals

The Canonical Test Specification must be

- deterministic
- implementation independent
- framework independent
- unambiguous
- minimal
- machine readable
- human readable

Every value contained within the specification must have a traceable source.

Do not invent values.

When information cannot be determined from an authoritative source, explicitly
mark it as unknown instead of guessing.

---

# Philosophy

Describe **what should be observed**.

Do not describe **how it is implemented**.

Avoid

- protocol details
- driver implementation details
- framework specific concepts
- scheduler behaviour
- transport sequencing

The specification should describe observable behaviour only.

---

# Device

Describe the device.

Example

```yaml
device:

  name: TMP102

  manufacturer: Texas Instruments

  transport: I2C
```

---

# Primary Capability

Describe why somebody buys this device.

Examples

TMP102

```
Measure ambient temperature
```

BMP280

```
Measure ambient temperature

Measure atmospheric pressure
```

Focus only on the primary capabilities required for a deterministic smoke test.

---

# Primary Observables

For every primary observable include

- identifier
- data type
- units
- sensible deterministic default value

Example

```yaml
observables:

  - id: temperature
    type: float
    units: C
    default: 21.0
```

Example (multiple observables)

```yaml
observables:

  - id: temperature
    type: float
    units: C
    default: 21.0

  - id: pressure
    type: float
    units: hPa
    default: 1013.25
```

Choose sensible real-world defaults.

Avoid

- minimum values
- maximum values
- boundary conditions
- random values

The objective is deterministic behaviour.

---

# Assumptions

State the assumptions under which the canonical test operates.

Example

```yaml
assumptions:

  ideal_conditions: true

  calibration_complete: true

  deterministic_outputs: true

  hardware_faults_present: false
```

Assume

- ideal operating conditions
- calibration already complete
- stable environment
- deterministic outputs
- no communication failures

---

# Excluded Features

Explicitly list functionality intentionally excluded from the canonical test.

Typical exclusions

- calibration
- self calibration
- EEPROM
- power management
- alarm thresholds
- interrupt outputs
- diagnostics
- self tests
- fault injection
- low power modes

This prevents downstream skills from generating unnecessary complexity.

---

# Canonical Presentation

Define the canonical human-readable representation of each observable.

This section defines the presentation contract used by downstream generators.

Example

```yaml
presentation:

  temperature:

    label: Temperature

    precision: 1

    units: C

    template: "Temperature = {:.1f} C"
```

Example (multiple observables)

```yaml
presentation:

  temperature:

    label: Temperature

    precision: 1

    units: C

    template: "Temperature = {:.1f} C"

  pressure:

    label: Pressure

    precision: 2

    units: hPa

    template: "Pressure = {:.2f} hPa"
```

The presentation section owns

- labels
- wording
- capitalization
- spacing
- numeric precision
- units

Downstream generators must never invent or modify these.

---

# Hallucination Prevention

Never invent

- observable names
- labels
- formatting
- units
- precision
- default values

Every field must originate from

- datasheet
- hardware specification
- reference driver
- ESPHome component source
- explicit user instruction

If authoritative information does not exist, emit

```yaml
status: unknown
```

rather than guessing.

---

# Non Goals

Do not describe

- ESPHome
- Wokwi
- Rust
- diagram.json
- dut.yaml
- test.rs
- logger.log
- assert_serial!
- RFC2217
- polling
- callbacks
- state machines
- scheduling
- protocol timing

Those belong to downstream code generation skills.

---

# Success Criteria

A successful Canonical Test Specification provides enough information for
downstream skills to generate

- simulator fixtures
- firmware configuration
- host-side integration tests
- documentation

without making additional semantic decisions.

Every downstream artifact should agree because each is rendered from the same
Canonical Test Specification rather than independently inferred.

The specification should represent the smallest deterministic scenario that
demonstrates the device's primary capability under ideal operating conditions.

