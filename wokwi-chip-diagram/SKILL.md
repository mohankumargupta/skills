name: wokwi-chip-diagram
description: Create both wokwi chip.json and diagram.json from canonical test specification for device <device>
---

# Context Variables

- `<original_pwd>`:   run pwd, this is `<original_pwd>`
- `<artifacts_dir>`: `<original_pwd>/artifacts/<device>/prompt2a`, need to create this directory
- `<outputs_dir>`:   `<original_pwd>/artifacts/<device>/outputs`
- `<test_spec>`:     `<original_pwd>/artifacts/<device>/outputs/test_spec_<device>.md`, this is the Canonical Test Specification.
- `<spec>`:          `<original_pwd>/artifacts/<device>/outputs/spec_<device>.md`
- `<chip_json>`:     `<outputs_dir>/chip.json`
- `<diagram_json>`:  `<outputs_dir>/diagram.json`
- `<feedback_dir>`:  `<original_pwd>/feedback/<device>`, you will need to create this
- `<feedback_file>`: `<feedback_dir>/prompt2a.md`

## Assets & Schemas
1. **chip.schema.json**: Find the wokwi chip json schema file in this skill under `assets/chip.schema.json`. Copy this file to `<artifacts_dir>`.
2. **diagram.json**:     Find `assets/diagram.json` in this skill. Copy it to `<diagram_json>`. This serves as the template for diagram.json. Build on it; don't remove anything from it. It has the correct microcontroller, custom chip, and serial connections.
3. **esp32c3.yaml**:     Read `assets/esp32c3.yaml` from this skill to use the pin numbers suggested here for buses and other pins.
4. **attributes.md**:    If `<original_pwd>/artifacts/<device>/prompt2d/attributes.md` (produced by the wokwi-customchip skill) exists, read it in full before touching `attrs`. It is authoritative for which chip inputs are genuinely overridable (environmental) versus fixed/wiring-derived (never overridable) — see the category column.
---

## Phase 1: Generate chip.json

### Example chip json
```json
{
  "name": "chip",
  "author": "Raspberry Pi",
  "pins": [
    "SDA",
    "SCL"
  ],
  "controls": []
}
```

### Parts to add to template
First read `<spec>` and `<test_spec>` in full. Your `chip.json` will need to comply 100% with this specification.

Keep structure like the example, only modify pins and controls:
- **controls**: These will be environment controls that normally the sensor or device will pick up, such as temperature.
- **pin names**: Use `<spec>` to define the pin names.


Save the generated JSON to `<artifacts_dir>/chip.json`.

### Validation (chip.json)
```sh
check-jsonschema --schemafile <artifacts_dir>/chip.schema.json <artifacts_dir>/chip.json
```
Then copy `<artifacts_dir>/chip.json` to `<chip_json>` in the outputs directory.

---

## Phase 2: Generate diagram.json

### Source of Truth
| Information   | Source    |
| ------------- | --------- |
| protocol      | test_spec |
| address       | test_spec |
| chip pins     | chip_json |
| attrs         | chip_json |
| MCU           | template  |
| serial wiring | template  |

### Rules
- **Wire colors**: Use standard colors: `red` for VCC, `black` for GND, `green` for data/signal, `blue` for secondary signals, `orange` for control.
- **Connections format**: Use empty `[]` for wire routing connections. The first two entries MUST be the source and target component pins.
- **Build on it**: Don't remove anything from the template `diagram.json`. It has the correct microcontroller and custom chip, as well as serial connections.
- **Only override attributes marked "environmental" in `attributes.md`.**
  Anything marked "fixed / wiring" (e.g. an I2C address selected by an
  ADD0 strap pin) must NEVER get an `attrs` entry, no matter how tempting
  it looks — it does not behave like a live sensor input on the real chip,
  and adding one invites silent misconfiguration (as happened when an
  address override parsed to `0` and made the chip stop responding on the
  bus entirely, with no error). If a wiring parameter genuinely needs a
  non-default value for a specific test, that belongs in how the *pin* is
  wired in `diagram.json`'s `connections` array, not in `attrs`.
- **When an attribute IS environmental**, write its `attrs` value as plain
  decimal per `attributes.md`'s format column.

### Workflow
1. **Connect to MCU**: Wokwi custom chip needs to be connected to the microcontroller. Wokwi custom chip pin names must match those from `<chip_json>`.
2. **Add attrs**: Add attributes to the existing wokwi custom chip in the diagram, sourced from `attributes.md`'s environmental rows only (not `<chip_json>` — `chip.json`'s `controls` array is a separate UI-slider mechanism, and should itself only ever expose environmental attributes per the classification rule above).3. **Build the Connections Array**: Connect the ESP32-C3 microcontroller to the wokwi custom chip using the specified pin numbers and wire colors.
4. **Output the JSON**: Produce a complete, valid `<diagram_json>` object and save it.

### Validation (diagram.json)
```sh
cd <outputs_dir>
wokwi-cli lint
```
