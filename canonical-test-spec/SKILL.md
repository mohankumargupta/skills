---
name: canonical-test-spec
description: Produce an internal Canonical Test Specification from a hardware chip specification for device <device>
---

# Context Variables

<original_pwd>:        run pwd, this is <original_pwd>
<outputs_dir>:         <original_pwd>/artifacts/<device>/outputs, will need to create
<output_spec_file>:    <outputs_dir>/test_spec_<device>.md
<feedback_dir>:        <original_pwd>/feedback/<device>, you will need to create this
<feedback_file>:       <feedback_dir>/prompt0b.md

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

<outputs_dir>: This contains esphome_component.txt with the name of the esphome 
component <name_of_esphome_component> for <device> which is not necessarily the same as <device>, it also contains
esphome docs markdown <name_of_esphome_component>.mdx and the esphome component source code
in directory <name_of_esphome_component> and spec_<device>.md 

---

# Output

Produce one Canonical Test Specification <output_spec_file> based on the inputs.

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

### The `default` value has two consumers, not one

`default` is not merely a plausible starting value for documentation
purposes. It is read by two different downstream skills for two different
purposes, and both MUST read this exact field rather than choosing their
own value:

1. **wokwi-customchip** encodes `default` as the value the simulated chip
   actually emits over the bus (e.g. the register word the sensor reports
   on first read).
2. **wokwi-test-harness** asserts this same numeric value as the ground
   truth the `qa_test` harness expects to see in serial output.

If a downstream skill cannot find this field, that is a defect to report,
not a gap to fill in with its own "sensible" number. Two independently
chosen defaults for the same observable will not conflict at build time —
they will conflict only at simulation time, as a test that either always
passes against a fabricated ground truth or always fails for a reason
invisible from either artifact alone. There is exactly one `default` per
observable in this specification; it is the single source of truth for
both the emitted value and the asserted value, full stop.



Avoid

- minimum values
- maximum values
- boundary conditions
- random values

The objective is deterministic behaviour.


### Units and typing conventions
- Use plain-ASCII unit abbreviations in `units:` (`C` not `°C`, `%` not `pct`)
  for consistency across devices; the `presentation.*.units` field may use the
  degree symbol if desired for display, but `observables.*.units` should stay
  plain-ASCII to avoid encoding issues in downstream code generation.
- Use `type: int` for observables whose native register/protocol value is a
  whole-number count with no fractional resolution (e.g. CO2 in ppm); use
  `type: float` only when the device has sub-unit resolution.


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

### Template notation is language-neutral — never copy verbatim

The `template` string (e.g. `"Temperature = {:.1f} C"`) specifies the
**wording, ordering, and numeric precision** of the presentation. It does
**not** specify the literal format-string syntax of whatever target
language a downstream generator happens to emit code in.

`{:.1f}` is Python/Rust-style notation, chosen here only because it is a
widely-understood way to say "one digit after the decimal point." It is
not valid printf syntax. Downstream generators that embed this value in
C/C++ (e.g. `ESP_LOGI`, `printf`, `sprintf`) MUST translate the precision
directive into that language's actual conversion specifier (`%.1f`), not
substitute the template text into the string literal unchanged. Copying
`{:.1f}` into an `ESP_LOGI` format string compiles without error but
silently prints the literal characters `{:.1f}` instead of the value,
because ESP_LOGI does no substitution on text it doesn't recognize as a
`%`-specifier.

Every downstream skill that consumes `template` must state, in its own
output, which literal format syntax it emitted so this translation step
is auditable rather than implicit.

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

## Finishing up

Before finishing, write a doc called `<feedback_file>` 
for comments about this skill 
including obstacles and improvements.
