---
name: espforge-devices
description: >
  Given a sensor or device name (e.g. ds18b20, bme280, mpu6050), finds a suitable
  embedded-hal v1 compatible Rust crate from crates.io and generates a complete git diff
  to add that device to the espforge framework. Use when the user asks to 
  "add device X to espforge", 
  "integrate device Y into espforge", 
  or "create an espforge driver for Z".
---

# Skill: espforge-devices

Adds support for a new hardware device to the espforge ESP32 framework.

**For every request, the skill MUST:**

1. Finding a suitable `embedded-hal v1` driver crate from crates.io.
2. Analysing the crate's API to understand its constructor and key methods.
3. Generating a complete `git diff` patch that wires the device into all required espforge layers.
4. Modify the diff to replace todo section with method calls from understanding of crates's API.
---

## Prerequisites

The espforge repository must be available locally.
Run the setup script once before using this skill:

```sh
bash scripts/clone_espforge.sh
```

This clones the repo into `~/.picoclaw/workspace/assets/espforge/`.

All scripts must be run from `~/.picoclaw/workspace/skills/espforge-devices` directory.

---

## Workflow

### Step 1 – Find a suitable crate

Search crates.io for candidates:

```sh
bash scripts/search.sh {device_name}
```

This returns up to 100 candidate crate names. Take the most relevant ones (top 5–10) and
check each for embedded-hal v1 compatibility:

```sh
bash scripts/check_crate.sh {crate_name}
```

Repeat for each candidate. Present a shortlist table:

| Crate | Version | EHv1 | Async |
|-------|---------|------|-------|
| ...   | ...     | ...  | ...   |

- Mark crates with version >= 1.0.0 with ★ (stable/mature).
- Flag crates with version < 1.0.0 as potentially unstable.

**Crate selection criteria (in priority order):**
- Compatible with embedded-hal **v1** (`EHv1: true`) — **required**
- `no_std` compatible — **required** (runtime code runs on ESP32)
- Highest stable version / most recent activity — preferred
- Async support optional but worth noting

Record: `CRATE_NAME`, `CRATE_VERSION`.

---

### Step 2 – Fetch crate metadata

```sh
bash scripts/fetch_crate_info.sh {CRATE_NAME}
```

Prints the crate description, repository URL, and latest stable version.

```sh
bash scripts/fetch_crate_deps.sh {CRATE_NAME} {CRATE_VERSION}
```

Prints all dependencies so you can confirm `embedded-hal` v1 and identify the interface
type (`I2c`, `SpiDevice`, `OutputPin`, etc.).


---

### Step 3 – Identify the device interface

### 3a. Explore the crate API via docs.rs using agent-browser
agent-browser is already installed.
MUST use the agent-browser skill(already installed) to navigate to https://docs.rs/{CRATE_NAME}/latest/{rust_identifier}/all.html
Actively browse the crate's documentation pages to thoroughly understand the interface:
Find all exposed structs, enums, and traits.
Find all public methods inside the primary structs.

From the combined output, Determine:
- **Bus type**: `I2c`, `SpiDevice`, `OutputPin`, or combination
- **Constructor signature**: e.g. `MyDevice::new(i2c: I, address: u8) -> Self`
- **Rust struct name**: the exact `pub struct` name exported by the crate.
  This is needed for `--device-struct` below. It is often **not** identical to the crate
  name (e.g. crate `bmp085-180-rs` exports struct `Bmp085`).
- **Key methods**: e.g. `.init()`, `.read_temperature()`, `.clear()`, `.flush()`
- **Required config fields**: I2C address, display dimensions, operating mode, etc.

> **Crate name vs Rust identifier**: Cargo allows hyphens in crate names (e.g. `bmp085-180-rs`)
> but Rust `use` statements require underscores (`bmp085_180_rs`).
> `generate_diff.py` handles this conversion automatically for `use` statements while keeping
> the hyphenated form in `Cargo.toml`. You do not need to do anything special.

Consult `references/adding_device.md` for espforge layer conventions.
Consult `references/example_ssd1306.md` (I2C) or `references/example_ili9341.md` (SPI + GPIO)
for concrete patterns to follow.

---

### Step 4 – Generate the git diff

Run the generation script:

```sh
python3 scripts/generate_diff.py \
  --device {device_name} \
  --crate  {CRATE_NAME} \
  --version {CRATE_VERSION} \
  --bus    {i2c|spi|gpio|spi+gpio|i2c+gpio} \
  --device-struct {RustStructName} \
  --espforge-root ~/.picoclaw/workspace/assets/espforge
```

**`--device-struct` is important**: if the crate's exported struct name differs from the
PascalCase of `--device`, you must pass it explicitly.

Examples:
```sh
# crate 'bmp085-180-rs' exports struct 'Bmp085'
python3 scripts/generate_diff.py --device bmp180 --crate bmp085-180-rs \
  --version 1.0.0 --bus i2c --device-struct Bmp085

# crate 'sht3x' exports struct 'SHT3x'
python3 scripts/generate_diff.py --device sht3x --crate sht3x \
  --version 0.2.0 --bus i2c --device-struct SHT3x
```

The script writes a patch to:
```
~/.picoclaw/workspace/outputs/{device_name}_espforge.diff
```

Once the file is written, you can modify the diff file and fill in the api you learnt from step 3 to add
api from the crate api to espforge through this diff.

Save this change to

```
~/.picoclaw/workspace/outputs/{device_name}_espforge_complete.diff
```


---

### Step 5 – Review and present

Display a summary of files changed in the diff:

| File | Change |
|------|--------|
| `espforge_devices/src/devices/{device}/device.rs` | New – runtime device struct |
| `espforge_devices/src/devices/{device}/mod.rs` | New – module declaration |
| `espforge_devices/src/devices/mod.rs` | Modified – register new module |
| `espforge_devices/Cargo.toml` | Modified – add optional dep + feature |
| `espforge_devices_builder/src/{device}.rs` | New – host-side plugin |
| `espforge_devices_builder/src/lib.rs` | Modified – register plugin module |

Tell the user:

> "The patch has been saved to `~/.picoclaw/workspace/outputs/{device_name}_espforge.patch`.
> Apply it with:
> ```sh
> cd ~/.picoclaw/workspace/assets/espforge
> git apply ~/.picoclaw/workspace/outputs/{device_name}_espforge.patch
> ```
> Then review the generated `device.rs` — you will likely need to update the constructor
> arguments and add device-specific methods based on the crate's actual API."

---

### Step 6 – Offer follow-up actions

Always ask if the user wants to:
- Generate an example YAML config for the new device.
- Generate a Wokwi diagram JSON stub.
- Create a complete example in `espforge_examples/examples/`.

---

## Output location

| Artifact | Path |
|----------|------|
| Git diff patch | `~/.picoclaw/workspace/outputs/{device_name}_espforge.patch` |
| Git diff patch complete | `~/.picoclaw/workspace/outputs/{device_name}_espforge_complete.patch` |
| espforge repo | `~/.picoclaw/workspace/assets/espforge/` |

---

## Template method signatures

The generated builder plugin uses the **raw-value** pattern documented in
`DEVELOPER_GUIDE.md`. The `DevicePlugin` macro (without a `config = "..."` attribute) expects
these exact method names on the impl block:

| Method | Signature |
|--------|-----------|
| `validate_properties` | `(&self, properties: &serde_yaml_ng::Value) -> Result<()>` |
| `resolve_dependencies` | `(&self, properties: &serde_yaml_ng::Value) -> Result<Vec<Dependency>>` |
| `generate_code` | `(&self, ctx: &GenerationContext) -> Result<GeneratedCode>` |

> If you see a "method not found" compile error after applying the patch, verify the method
> names match exactly. The alternative typed-config pattern (used in the built-in
> `ssd1306`/`ft6206` builders) requires `#[plugin(config = "MyConfig")]` and different
> method signatures — do not mix the two patterns.

---

## Troubleshooting

### No crate found
Broaden the search term (e.g. search `"temperature"` instead of `"ds18b20"`).

### Crate uses embedded-hal v0.2
Not usable as-is. Inform the user and suggest looking for a fork or alternative that targets
embedded-hal v1.

### `generate_diff.py` fails with "unknown bus type"
Re-run with `--bus` set explicitly to one of:
`i2c`, `spi`, `gpio`, `spi+gpio`, `i2c+gpio`.

### Patch does not apply cleanly
The local espforge clone may be stale. Run `bash scripts/clone_espforge.sh` to update.

### Generated `device.rs` fails to compile
1. Verify the struct name (`--device-struct`): check `https://docs.rs/{CRATE_NAME}` for the
   exact exported public struct name.
2. Verify the constructor signature: the template assumes `Device::new(bus)`. If the crate
   requires additional arguments (delay, address, mode), edit `device.rs` and the `init`
   block in the builder accordingly.
3. Verify the crate is `no_std` compatible: some crates require `std` and cannot be used in
   `espforge_devices`.

### `use` statement has hyphens (e.g. `use my-crate::...`)
This is a Rust syntax error — hyphens are not allowed in identifiers.
The `generate_diff.py` script converts them automatically. If you edited the crate name
manually, ensure you are using the underscore form in any Rust source files.

