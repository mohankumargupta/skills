# Adding a New Device to Espforge

This document is the authoritative reference for the `espforge-devices` skill.
It summarises every file that must be created or modified when integrating a new device.

---

## Architecture recap

```
Application (app.rs)
      ↓
Device layer  (espforge_devices)        ← runtime, compiled for ESP32
      ↓
Component layer (espforge_components)   ← runtime, compiled for ESP32
      ↓
Hardware (PeripheralRegistry)           ← runtime, compiled for ESP32

Device builder (espforge_devices_builder) ← host-side, generates Rust code
```

A **device** always takes a **component** (I2cDevice, SpiDevice, etc.) as its bus,
and optionally takes GPIO pins for control signals (DC, RST, CS).

---

## File checklist

| # | File | Action |
|---|------|--------|
| 1 | `espforge_devices/src/devices/<device>/device.rs` | **Create** – runtime device struct |
| 2 | `espforge_devices/src/devices/<device>/mod.rs` | **Create** – `pub mod device;` |
| 3 | `espforge_devices/src/devices/mod.rs` | **Modify** – add `#[cfg(feature="<device>")] pub mod <device>;` |
| 4 | `espforge_devices/Cargo.toml` | **Modify** – add optional dep + feature |
| 5 | `espforge_devices_builder/src/<device>.rs` | **Create** – host plugin |
| 6 | `espforge_devices_builder/src/lib.rs` | **Modify** – `pub mod <device>;` |

---

## File 1 – device.rs (runtime)

Rules:
- Must be `no_std` compatible. Use `core::` not `std::`.
- Wrap the upstream driver struct. Do not expose upstream types directly.
- Implement a simple API: `new()`, `init()`, and the key user-facing methods.
- Keep generics minimal – prefer concrete espforge platform types in the builder.

### I2C pattern

```rust
use embedded_hal::i2c::I2c;
use some_driver::SomeDriver;

pub struct MyDevice<I> {
    inner: SomeDriver<I>,
}

impl<I: I2c> MyDevice<I> {
    pub fn new(i2c: I) -> Self {
        Self { inner: SomeDriver::new(i2c) }
    }
    pub fn init(&mut self) -> Result<(), I::Error> {
        self.inner.init()
    }
}
```

### SPI pattern

```rust
use embedded_hal::spi::SpiDevice;
use some_driver::SomeDriver;

pub struct MyDevice<SPI> {
    inner: SomeDriver<SPI>,
}

impl<SPI: SpiDevice> MyDevice<SPI> {
    pub fn new(spi: SPI) -> Self {
        Self { inner: SomeDriver::new(spi) }
    }
}
```

### SPI + GPIO pins pattern

```rust
use embedded_hal::{digital::OutputPin, spi::SpiDevice};
use some_driver::SomeDriver;

pub struct MyDevice<SPI, DC, RST> {
    inner: SomeDriver<SPI, DC, RST>,
}

impl<SPI: SpiDevice, DC: OutputPin, RST: OutputPin> MyDevice<SPI, DC, RST> {
    pub fn new(spi: SPI, dc: DC, rst: RST) -> Self {
        Self { inner: SomeDriver::new(spi, dc, rst) }
    }
}
```

---

## File 4 – Cargo.toml (runtime)

Add inside `[dependencies]`:
```toml
some-driver = { version = "x.y.z", optional = true }
```

Add inside `[features]`:
```toml
my_device = ["dep:some-driver"]
```

The feature name must exactly match the `#[plugin(features = "...")]` attribute in the builder.

---

## File 5 – builder plugin

Rules:
- Lives in `espforge_devices_builder` — runs on the host, full `std` available.
- The `#[derive(DevicePlugin)]` macro registers the plugin automatically via `inventory`.
- The `#[plugin(name = "...")]` attribute is the string used in YAML `using:`.
- Use `DeviceRef<ComponentRef>` for bus references, `DeviceRef<PinRef>` for GPIO references.
- `resolve_dependencies()` must list every resource the device consumes.
- `generate_code()` must return `GeneratedCode` with `field`, `init`, and `struct_init`.

### Key helper methods on GenerationContext

```rust
// Validate + get access TokenStream for a component reference
let bus = ctx.dependency_access("my_bus", DependencyKind::Component)?;

// Validate + get access TokenStream for a GPIO pin reference
let dc_pin = ctx.dependency_access("pin_dc", DependencyKind::Pin)?;
```

### Dependency declarations

```rust
fn resolve_dependencies(&self, config: &MyConfig) -> Result<Vec<Dependency>> {
    Ok(vec![
        Dependency::component_ref(&config.bus),   // I2C or SPI component
        Dependency::pin_ref(&config.dc),           // GPIO control pin
        Dependency::pin_ref(&config.rst),
    ])
}
```

---

## YAML example (I2C device)

```yaml
esp32:
  i2c:
    i2c0: { i2c: 0, sda: 6, scl: 5, frequency_khz: 100 }

components:
  i2c_bus:
    using: I2cDevice
    with:
      i2c: $i2c0

devices:
  my_sensor:
    using: my_device
    with:
      component: $i2c_bus
      address: 0x48
```

## YAML example (SPI + GPIO device)

```yaml
esp32:
  spi:
    spi2: { spi: 2, sck: 3, mosi: 4, frequency_kHz: 10000 }
  gpio:
    pin_dc:  { pin: 6, direction: output }
    pin_rst: { pin: 7, direction: output }
    pin_cs:  { pin: 5, direction: output }

components:
  main_spi:
    using: SpiDevice
    with:
      spi: $spi2

devices:
  my_display:
    using: my_device
    with:
      spi: $main_spi
      dc: $pin_dc
      rst: $pin_rst
      cs: $pin_cs
```

---

## no_std rules (CRITICAL)

The runtime device lives in `espforge_devices` which is compiled for ESP32 (`no_std`).

| Forbidden | Use instead |
|-----------|-------------|
| `std::fmt::Display` | `core::fmt::Display` |
| `std::string::String` | `alloc::string::String` (needs `extern crate alloc`) |
| `std::vec::Vec` | `alloc::vec::Vec` |
| `std::collections::HashMap` | not available; restructure or use heapless |
| `println!` | `log::info!` or `esp_println::println!` |
| `std::error::Error` | custom error types or `embedded_hal` error bounds |

The builder (`espforge_devices_builder`) runs on the host — full `std` is available there.

