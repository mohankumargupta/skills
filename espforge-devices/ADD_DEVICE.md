---
name: espforge-add-device
description: Write a new device driver for the espforge ESP32 framework. Use this skill when a user asks to add a new sensor, display, or peripheral driver to espforge, given a Rust driver crate. Covers both the runtime device implementation (espforge_devices) and the host-side code-generation plugin (espforge_devices_builder).
---

This skill guides writing a complete espforge device driver from a Rust no_std driver crate. The output is two files: a runtime struct in `espforge_devices` and a builder plugin in `espforge_devices_builder`, plus an example. Read this entire document before writing any code — the Plugin API Reference and the annotated real implementations are the most important sections.

**Before writing any code, read these reference documents in full:**
- `references/plugin_api.md` — exact types, signatures, and helpers used in `generate_code()`
- `references/adding_device.md` — file checklist and no_std rules
- `references/example_ssd1306.md` — canonical I2C device template
- `references/example_ili9341.md` — canonical SPI + GPIO device template
- `references/decision_guide.md` — which bus type, DeviceRef, delay, init patterns
- `references/compile_errors.md` — common errors and fixes


## What You Are Building

An espforge device driver has two distinct halves that live in separate crates:

| Half | Crate | Runs on | Purpose |
|------|-------|---------|---------|
| **Runtime device** | `espforge_devices` | ESP32 chip (no_std) | Wraps the driver crate, exposes a friendly API |
| **Builder plugin** | `espforge_devices_builder` | Dev machine (std) | Parses YAML config, declares deps, generates Rust tokens |

Never mix std/no_std — `espforge_devices` must be `#![no_std]`. The builder crate has full std.

---

## Step 0 — Research the Driver Crate

Before writing a single line, answer these questions by reading the driver crate's docs/source:

1. **Bus type** — does the driver take `embedded_hal::i2c::I2c`, `embedded_hal::spi::SpiDevice`, or something else?
2. **Constructor signature** — what arguments does `new()` take besides the bus? Does it need a `delay`? Does it need a `config` struct?
3. **Key methods** — what will app code call? (e.g. `read_temperature()`, `read_pressure()`)
4. **Init required?** — does the driver need an explicit `.init()` call after construction?
5. **Cargo feature flags** — does the crate gate functionality behind features?

---


## Step 1 — Runtime Device (`espforge_devices`)

### 1a. Create the module files

```
espforge_devices/src/devices/
  my_sensor/
    mod.rs       ← pub mod device;
    device.rs    ← the actual struct
```

### 1b. Write `device.rs`

Rules:
- Generic over the bus type `<I>` — never hard-code a concrete bus.
- Use `core::` not `std::` for anything from the standard library.
- If heap is needed: `extern crate alloc;` and use `alloc::string::String`, `alloc::vec::Vec`.
- Keep the public API minimal: `new()`, and one method per reading.
- If `.init()` is required, make it a separate public method — the builder calls it in the init block.

```rust
// espforge_devices/src/devices/my_sensor/device.rs

use embedded_hal::i2c::I2c;                 // always embedded_hal, never a concrete type

pub struct MySensorDevice<I> {
    sensor: some_driver_crate::Driver<I>,
}

impl<I: I2c> MySensorDevice<I> {
    pub fn new(i2c: I) -> Self {
        Self { sensor: some_driver_crate::Driver::new(i2c) }
    }

    // Called from generated code when init is required
    pub fn init(&mut self) {
        self.sensor.init().expect("MySensor init failed");
    }

    pub fn read_temperature(&mut self) -> Option<f32> {
        self.sensor.read_temperature().ok()
    }
}
```

### 1c. Register in `espforge_devices/src/devices/mod.rs`

```rust
#[cfg(feature = "my_sensor")]
pub mod my_sensor;
```

### 1d. Add Cargo dependency and feature to `espforge_devices/Cargo.toml`

```toml
[dependencies]
some-driver-crate = { version = "x.y", optional = true }

[features]
my_sensor = ["dep:some-driver-crate"]
```

The feature name **must match** the directory name exactly — `build.rs` auto-generates re-exports keyed to directory names.

---

## Step 2 — Builder Plugin (`espforge_devices_builder`)

### 2a. Create `espforge_devices_builder/src/my_sensor.rs`

```rust
use anyhow::Result;
use espforge_configuration::plugin::{
    codegen, ComponentRef, Dependency, DependencyKind, DeviceRef, GeneratedCode,
    GenerationContext, PinRef,
};
use espforge_macros::DevicePlugin;
use quote::quote;
use serde::Deserialize;

// ── Config struct ─────────────────────────────────────────────────────────────
// One field per YAML `with:` key.
// DeviceRef<ComponentRef> → must reference a component.
// DeviceRef<PinRef>       → must reference a GPIO pin.
// Option<T>              → optional field with a default applied in generate_code.

#[derive(Debug, Deserialize)]
pub struct MySensorConfig {
    pub component: DeviceRef<ComponentRef>,
    pub address: Option<u8>,          // optional with default
}

// ── Plugin struct ─────────────────────────────────────────────────────────────
// name     = the string used in YAML under `using:`
// features = the Cargo feature(s) added to espforge_devices in the generated Cargo.toml
// config   = the config struct to auto-deserialize before each method call

#[derive(DevicePlugin)]
#[plugin(name = "my_sensor", features = "my_sensor", config = "MySensorConfig")]
pub struct MySensorPlugin;

impl MySensorPlugin {
    fn validate_config(&self, config: &MySensorConfig) -> Result<()> {
        if let Some(addr) = config.address {
            anyhow::ensure!(addr <= 0x7F, "address must be 7-bit (0x00–0x7F)");
        }
        Ok(())
    }

    fn resolve_dependencies(&self, config: &MySensorConfig) -> Result<Vec<Dependency>> {
        Ok(vec![Dependency::component(config.component.as_str())])
    }

    fn generate_code(
        &self,
        config: &MySensorConfig,
        ctx: &GenerationContext,
    ) -> Result<GeneratedCode> {
        let address = config.address.unwrap_or(0x77u8);

        // dependency_access() validates kind AND returns the access path as a TokenStream,
        // e.g. `components.i2c_master`
        let i2c_access =
            ctx.dependency_access(config.component.as_str(), DependencyKind::Component)?;

        let field = quote! {
            espforge_devices::devices::my_sensor::device::MySensorDevice<
                espforge_platform::bus::I2cDevice<'static>
            >
        };

        let init = quote! {
            espforge_devices::devices::my_sensor::device::MySensorDevice::new(
                #i2c_access,
                #address,
            )
        };

        // codegen() wraps init in { … } and names the result after instance_name
        Ok(codegen(ctx.instance_name, field, init))
    }
}
```

### 2b. Register in `espforge_devices_builder/src/lib.rs`

```rust
pub mod my_sensor;   // ← add this line

pub fn init() {
    let _ = std::hint::black_box(&ft6206::FT6206Plugin);
    let _ = std::hint::black_box(&ili9341::ILI9341Plugin);
    let _ = std::hint::black_box(&ssd1306::SSD1306Plugin);
    let _ = std::hint::black_box(&my_sensor::MySensorPlugin);  // ← add this line
}
```

---

## Step 3 — Write a YAML Example

Create `espforge_examples/examples/04.Communication/my_sensor_example/example.yaml`:

```yaml
espforge:
  name: my_sensor_example
  platform: esp32c3

esp32:
  i2c:
    i2c0: { i2c: 0, sda: 6, scl: 7, frequency_kHz: 100 }

components:
  i2c_master:
    using: I2cDevice
    with:
      i2c: $i2c0

devices:
  sensor:
    using: my_sensor       # must match #[plugin(name = "my_sensor")]
    with:
      component: $i2c_master
      address: 0x77        # optional if you have a default
```

And the matching `app.rs`:

```rust
use crate::{device, Context};

pub fn setup(ctx: &mut Context) {
    ctx.logger.info("MySensor example");
}

pub fn forever(ctx: &mut Context) {
    let sensor = device!(sensor);

    if let Some(temp) = sensor.read_temperature() {
        ctx.logger.info(format_args!("Temp: {:.1} C", temp));
    }

    ctx.delay.delay_ms(2000);
}
```

---

## Guardrails for `generate_code()` in device builder plugins

When writing `espforge_devices_builder/src/<device>.rs`, avoid interpolating `ctx` fields directly
inside `quote!` with `#ctx...`. `quote!` interpolation only accepts Rust identifiers/expressions,
so `#ctx.instance_name` is invalid and can generate broken code.

### ✅ Correct pattern

Always create identifiers before the `quote!` block:

```rust
use quote::format_ident;

let field_ident = format_ident!("{}", ctx.instance_name);

let init = quote! {
    {
        let mut #field_ident = espforge_devices::devices::bmp180::device::BMP180Device::new(
            #i2c_access,
            #address,
            #oversampling,
            #sea_level_pressure,
        );
        #field_ident.init().expect("BMP180 initialization failed");
        #field_ident
    }
};
```

### ❌ Incorrect pattern

Do **not** do this:

```rust
let init = quote! {
    let mut #ctx.instance_name = ...;
    #ctx.instance_name
};
```

### Additional checks

Before finishing a new device plugin, verify:

1. `field` is only a **type**, not `pub <name>: <type>`.
2. `init` is an **expression** producing the device value.
3. `codegen(ctx.instance_name, field, init)` is used instead of constructing `GeneratedCode` manually.
4. Any mutable local used in `quote!` is introduced via `format_ident!`.
5. `cargo check -p espforge_devices_builder` succeeds.




## Decision Guide for Common Cases

### Which bus type?

| Driver constructor takes… | YAML `component` references… | `DependencyKind` in `dependency_access` |
|---|---|---|
| `embedded_hal::i2c::I2c` | `I2cDevice` component | `DependencyKind::Component` |
| `embedded_hal::spi::SpiDevice` | `SpiDevice` component | `DependencyKind::Component` |
| GPIO pin directly | pin under `esp32.gpio` | `DependencyKind::Pin` |

### Which DeviceRef marker type?

```rust
pub component: DeviceRef<ComponentRef>,  // references a component (I2cDevice, SpiDevice, …)
pub dc_pin:    DeviceRef<PinRef>,        // references a GPIO pin under esp32.gpio
```

### Does the driver need `.init()`?

If yes, do **not** call it inside `device.rs`'s `new()`. Instead write `init()` as a public method and call it from the builder's init block:

```rust
// In generate_code():
let init = quote! {
    {
        let mut dev = espforge_devices::..::MyDevice::new(#bus_access);
        dev.init().expect("MyDevice init failed");
        dev
    }
};
```

When you use the `codegen()` helper, supply this whole block as the `init` argument — `codegen()` does **not** add another wrapping block around it, it uses the expression as-is for the init and wraps the whole thing cleanly.

### Does the driver need a `delay` argument?

`Devices::new()` always receives `delay: &mut espforge_platform::delay::Delay`. Pass `*delay` to copy it (esp-hal `Delay` is `Copy`):

```rust
let init = quote! {
    espforge_devices::..::MyDevice::new(#bus_access, *delay)
};
```

### Does the driver need a runtime config struct?

Add extra fields to the YAML config struct and pass them as literals:

```rust
#[derive(Debug, Deserialize)]
pub struct MySensorConfig {
    pub component: DeviceRef<ComponentRef>,
    pub oversampling: Option<u8>,   // optional, default applied in generate_code
}

// In generate_code():
let oversampling = config.oversampling.unwrap_or(1u8);
let init = quote! {
    espforge_devices::..::MySensor::new(#i2c_access, #oversampling)
};
```

---

## Checklist

- [ ] `espforge_devices/src/devices/<name>/device.rs` — no_std struct, generic over bus
- [ ] `espforge_devices/src/devices/<name>/mod.rs` — `pub mod device;`
- [ ] `espforge_devices/src/devices/mod.rs` — `#[cfg(feature = "<name>")] pub mod <name>;`
- [ ] `espforge_devices/Cargo.toml` — optional dep + `<name> = ["dep:..."]` feature
- [ ] `espforge_devices_builder/src/<name>.rs` — config struct + `#[derive(DevicePlugin)]` impl
- [ ] `espforge_devices_builder/src/lib.rs` — `pub mod <name>;` + entry in `init()`
- [ ] Example YAML under `espforge_examples/examples/`
- [ ] Example `app.rs` that calls the device methods
- [ ] Make sure that root workspace Cargo.toml remains untouched

---

## Common Compile Errors and Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `error[E0433]: failed to resolve: use of undeclared crate or module std` | Used `std::` in `device.rs` | Replace with `core::` (or `alloc::` for heap types) |
| `error: Unknown device driver: my_sensor` at compile time | `#[plugin(name = "...")]` doesn't match the `using:` value in YAML, OR `pub mod my_sensor;` missing from `lib.rs` | Check both the plugin name attribute and the `lib.rs` registration |
| `dependency 'foo' not found` / wrong kind error | Passed wrong `DependencyKind` to `dependency_access`, or forgot to declare it in `resolve_dependencies` | The kind in `dependency_access` must match what you declared in `resolve_dependencies`; component → `DependencyKind::Component`, pin → `DependencyKind::Pin` |
| Double-braces in generated code `{{ … }}` | Called `codegen()` and also manually added `{ }` around the init expression | `codegen()` wraps the init in a block automatically — pass the inner expression, not a block |
| Feature not propagated — missing trait impl in generated project | `#[plugin(features = "...")]` is missing or wrong | Must exactly match the feature name declared in `espforge_devices/Cargo.toml` |
| Pin conflicts during `espforge compile` | Two entries in `esp32:` share the same physical pin number | Fix the YAML — each physical pin can only be assigned once |

