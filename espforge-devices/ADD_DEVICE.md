---
name: espforge-add-device
description: Write a new device driver for the espforge ESP32 framework. Use this skill when a user asks to add a new sensor, display, or peripheral driver to espforge, given a Rust driver crate. Covers both the runtime device implementation (espforge_devices) and the host-side code-generation plugin (espforge_devices_builder).
---

This skill guides writing a complete espforge device driver from a Rust no_std driver crate. The output is two files: a runtime struct in `espforge_devices` and a builder plugin in `espforge_devices_builder`, plus an example. Read this entire document before writing any code — the Plugin API Reference and the annotated real implementations are the most important sections.

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

## Plugin API Reference

This is the most important section. These are the **exact** real signatures you will use when writing `generate_code()`. Do not invent alternatives.

### `espforge_configuration/src/plugin.rs` — key types

```rust
// The context passed to every generate_code() call
pub struct GenerationContext<'a> {
    pub instance_name: &'a str,                                    // e.g. "oled" or "display"
    pub properties: &'a serde_yaml_ng::Value,                      // raw YAML `with:` block
    pub model: &'a EspforgeConfiguration,                          // full parsed config
    pub resolved_deps: &'a HashMap<String, ResolvedDependency>,    // pre-resolved deps
}

impl GenerationContext<'_> {
    // Normalize a reference: strips leading '$' if present
    pub fn normalize_ref_name<'s>(&self, name: &'s str) -> &'s str

    // Retrieve a resolved dep and validate its kind; errors if kind is wrong
    pub fn dependency(&self, name: &str, expected: DependencyKind) -> Result<&ResolvedDependency>

    // Resolve AND parse the access path as a TokenStream in one call.
    // e.g. produces `components.i2c_master` or `registry.gpio5`
    // This is what you put inside quote! blocks.
    pub fn dependency_access(&self, name: &str, expected: DependencyKind) -> Result<TokenStream>
}

// What generate_code() must return
pub struct GeneratedCode {
    pub field: TokenStream,       // type declaration for the Devices struct field
    pub init: TokenStream,        // expression that constructs the device
    pub struct_init: TokenStream, // field name used in the struct literal
}

// Helper that wraps init in a block {} to isolate locals, preventing name collisions.
// Use this instead of building GeneratedCode manually.
pub fn codegen(instance_name: &str, field: TokenStream, init: TokenStream) -> GeneratedCode

// Dependency kinds — must match what you declare in resolve_dependencies()
pub enum DependencyKind {
    Component,   // a named component: I2cDevice, SpiDevice, etc.
    Device,      // a named device
    Peripheral,  // a raw hardware peripheral: i2c0, spi2, etc.
    Pin,         // a GPIO pin declared under esp32.gpio
}

// Constructors on Dependency
impl Dependency {
    pub fn component(name: impl Into<String>) -> Self
    pub fn pin(name: impl Into<String>) -> Self
    pub fn device(name: impl Into<String>) -> Self
    pub fn peripheral(name: impl Into<String>) -> Self

    // Convenience: build from a DeviceRef directly (strips '$' for you)
    pub fn component_ref(r: &DeviceRef<ComponentRef>) -> Self
    pub fn pin_ref(r: &DeviceRef<PinRef>) -> Self
}
```

### `espforge_configuration/src/refs.rs` — typed YAML references

```rust
// Marker types — used only as phantom type parameters
pub struct ComponentRef;  // reference to a component (I2cDevice, SpiDevice, …)
pub struct PinRef;        // reference to a GPIO pin under esp32.gpio

// DeviceRef<T> wraps a YAML reference like `$i2c_master` or `$pin_dc`
pub struct DeviceRef<T> {
    raw: String,              // already stripped of the leading '$' at deserialization
    _kind: PhantomData<T>,
}

impl<T> DeviceRef<T> {
    pub fn as_str(&self) -> &str   // returns the name without '$', e.g. "i2c_master"
}

// In your config struct, always use one of these two forms:
pub component: DeviceRef<ComponentRef>,   // enforces: must be a component reference
pub dc_pin: DeviceRef<PinRef>,            // enforces: must be a GPIO pin reference
```

**The `$` prefix is stripped automatically at YAML deserialization — never call `.strip_prefix('$')` on a `DeviceRef`.**

### `espforge_platform/src/delay/mod.rs` — delay injection

`Devices::new()` always receives `delay: &mut espforge_platform::delay::Delay`. If your driver constructor needs a delay object, use `*delay` to copy it (esp-hal's `Delay` is `Copy`).

```rust
// In your init token — pass a copy of the platform delay to the driver
let init = quote! {
    espforge_devices::devices::my_device::device::MyDevice::new(#bus_access, *delay)
};
```

---

## Canonical Reference Implementations

These are **real files from the codebase**. Use them as templates — read them before writing your own device.

### SSD1306 — simplest complete I2C device (with `.init()`)

This is your primary template for any I2C sensor or display.

**`espforge_devices_builder/src/ssd1306.rs` (builder):**

```rust
use espforge_macros::DevicePlugin;
use proc_macro2::TokenStream;
use quote::{format_ident, quote};
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct SSD1306Config {
    pub component: DeviceRef<ComponentRef>,
    pub address: Option<u8>,
    pub width: Option<u32>,
    pub height: Option<u32>,
}

#[derive(DevicePlugin)]
#[plugin(name = "ssd1306", features = "ssd1306", config = "SSD1306Config")]
pub struct SSD1306Plugin;

impl SSD1306Plugin {
    fn validate_config(&self, config: &SSD1306Config) -> Result<()> {
        // validate address is 7-bit, dimensions > 0, etc.
        Ok(())
    }

    fn resolve_dependencies(&self, config: &SSD1306Config) -> Result<Vec<Dependency>> {
        Ok(vec![Dependency::component(config.component.as_str())])
    }

    fn generate_code(&self, config: &SSD1306Config, ctx: &GenerationContext) -> Result<GeneratedCode> {
        let field_ident = format_ident!("{}", ctx.instance_name);
        let i2c_access = ctx
            .dependency_access(config.component.as_str(), DependencyKind::Component)?;

        let field = quote! {
            espforge_devices::devices::ssd1306::device::SSD1306Device<
                espforge_platform::bus::I2cDevice<'static>
            >
        };

        // .init() is called here in the init block, not inside SSD1306Device::new()
        let init = quote! {
            {
                let mut #field_ident =
                    espforge_devices::devices::ssd1306::device::SSD1306Device::new(#i2c_access);
                #field_ident.init();
                #field_ident
            }
        };

        Ok(codegen(ctx.instance_name, field, init))
    }
}
```

**`espforge_devices/src/devices/ssd1306/device.rs` (runtime):**

```rust
use embedded_hal::i2c::I2c;

pub struct SSD1306Device<I> {
    display: /* ssd1306 display type */,
}

impl<I: I2c> SSD1306Device<I> {
    pub fn new(i2c: I) -> Self {
        // wrap i2c in the driver's display struct
        Self { display: /* … */ }
    }

    // init() is called by the builder's generated code, not inside new()
    pub fn init(&mut self) {
        let _ = self.display.init();
    }

    pub fn clear(&mut self) { /* … */ }
    pub fn flush(&mut self) { /* … */ }
    pub fn print(&mut self, x: i32, y: i32, text: &str) { /* … */ }
}
```

Key points from this example:
- The struct is generic over `<I>` — never hard-code a concrete bus type in `device.rs`.
- `init()` is a separate public method; the builder calls it in the generated init block.
- No `std::` anywhere — use `core::` for anything from the standard library.

---

### FT6206 — I2C device with optional config fields and defaults

Use this as a template when your device has optional YAML configuration knobs.

**`espforge_devices_builder/src/ft6206.rs` (builder, key parts):**

```rust
#[derive(Debug, Deserialize)]
pub struct FT6206Config {
    pub component: DeviceRef<ComponentRef>,
    pub address: Option<u8>,        // default 0x38
    pub screen_width: Option<u16>,  // default 240
    pub screen_height: Option<u16>, // default 320
    pub x_min: Option<u16>,
    pub x_max: Option<u16>,
    pub y_min: Option<u16>,
    pub y_max: Option<u16>,
}

fn generate_code(&self, config: &FT6206Config, ctx: &GenerationContext) -> Result<GeneratedCode> {
    let address = config.address.unwrap_or(0x38);
    let screen_width = config.screen_width.unwrap_or(240);
    let screen_height = config.screen_height.unwrap_or(320);
    let x_min = config.x_min.unwrap_or(0);
    let x_max = config.x_max.unwrap_or(screen_width);

    let i2c_access = ctx.dependency_access(config.component.as_str(), DependencyKind::Component)?;

    let field = quote! {
        espforge_devices::devices::ft6206::device::FT6206<
            espforge_platform::bus::I2cDevice<'static>
        >
    };

    let init = quote! {
        espforge_devices::devices::ft6206::device::FT6206::new(
            #i2c_access, #address, #screen_width, #screen_height,
            #x_min, #x_max, #y_min, #y_max,
        )
    };

    Ok(codegen(ctx.instance_name, field, init))
}
```

---

### ILI9341 — SPI device with GPIO control pins

Use this as a template for any device that combines a component (SPI/I2C bus) with GPIO control pins (DC, RST, CS, etc.).

**`espforge_devices_builder/src/ili9341.rs` (builder, key parts):**

```rust
#[derive(Debug, Deserialize)]
pub struct ILI9341Config {
    pub spi: DeviceRef<ComponentRef>,   // the SpiDevice component
    pub dc:  DeviceRef<PinRef>,         // data/command GPIO pin
    pub rst: DeviceRef<PinRef>,         // reset GPIO pin
    pub cs:  DeviceRef<PinRef>,         // chip-select GPIO pin
}

fn resolve_dependencies(&self, config: &ILI9341Config) -> Result<Vec<Dependency>> {
    Ok(vec![
        Dependency::component_ref(&config.spi),
        Dependency::pin_ref(&config.dc),
        Dependency::pin_ref(&config.rst),
        Dependency::pin_ref(&config.cs),
    ])
}

fn generate_code(&self, config: &ILI9341Config, ctx: &GenerationContext) -> Result<GeneratedCode> {
    let spi_access = ctx.dependency_access(config.spi.as_str(), DependencyKind::Component)?;
    let dc_access  = ctx.dependency_access(config.dc.as_str(),  DependencyKind::Pin)?;
    let rst_access = ctx.dependency_access(config.rst.as_str(), DependencyKind::Pin)?;
    let cs_access  = ctx.dependency_access(config.cs.as_str(),  DependencyKind::Pin)?;

    // Use instance-name-prefixed locals to avoid collisions with other devices
    let cs_pin_ident  = format_ident!("{}_cs_pin",  ctx.instance_name);
    let dc_pin_ident  = format_ident!("{}_dc_pin",  ctx.instance_name);
    let rst_pin_ident = format_ident!("{}_rst_pin", ctx.instance_name);

    let field = quote! {
        espforge_devices::devices::ili9341::device::ILI9341Device<
            espforge_platform::bus::SpiDevice<'static>,
            espforge_platform::gpio::GPIOOutput,
            espforge_platform::gpio::GPIOOutput,
        >
    };

    // delay is passed in from Devices::new() — *delay copies the platform Delay
    let init = quote! {
        {
            let mut #cs_pin_ident  = #cs_access;
            let mut #dc_pin_ident  = #dc_access;
            let mut #rst_pin_ident = #rst_access;
            espforge_devices::devices::ili9341::device::ILI9341Device::new(
                #spi_access, #dc_pin_ident, #rst_pin_ident, delay
            )
        }
    };

    Ok(codegen(ctx.instance_name, field, init))
}
```

---

### What the generated output looks like

This is **`espforge_examples_generated/ssd1306_example/src/generated.rs`** — the actual Rust that espforge writes out. Reading this makes the `field` and `init` tokens legible.

```rust
// PeripheralRegistry — owns all hardware, initialised first
pub struct PeripheralRegistry {
    pub i2c0: RefCell<I2c<'static, Blocking>>,
    // gpio pins are RefCell<Option<AnyPin<'static>>>
}

// Components — takes a &'static mut PeripheralRegistry, consumes peripherals
pub struct Components {
    pub i2c_master: espforge_components::components::i2c::I2C<'static>,
}

// Devices — takes &'static mut Components and &mut Delay
pub struct Devices {
    // ← your `field` token goes here, e.g.:
    pub oled: espforge_devices::devices::ssd1306::device::SSD1306Device<
        espforge_platform::bus::I2cDevice<'static>
    >,
}

impl Devices {
    pub fn new(
        components: &'static mut Components,
        registry: &'static mut PeripheralRegistry,
        delay: &mut espforge_platform::delay::Delay,
    ) -> Self {
        // ← your `init` token is placed here, wrapped in a block by codegen()
        let oled = {
            let mut oled = espforge_devices::devices::ssd1306::device::SSD1306Device::new(
                components.i2c_master  // ← what dependency_access() returns
            );
            oled.init();
            oled
        };
        Self { oled }  // ← struct_init from codegen()
    }
}
```

**Takeaway:** `field` is a type; `init` is a block-expression that produces a value of that type; `struct_init` is just the field name. `codegen()` wraps `init` in `{ … }` automatically — do not add braces yourself.

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

