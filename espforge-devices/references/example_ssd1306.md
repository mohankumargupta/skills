# Example Device: SSD1306 OLED (I2C)

This is the canonical I2C device example in espforge.
Use this as a template when adding any I2C-connected device.

---

## Crate used

`ssd1306 = "0.10.0"` — an `embedded-hal v1` compatible I2C OLED driver.

---

## device.rs  (`espforge_devices/src/devices/ssd1306/device.rs`)

```rust
use embedded_hal::i2c::I2c;

// Wraps the upstream driver; re-exports nothing from it.
pub struct SSD1306Device<I> {
    display: ssd1306::Ssd1306<
        display_interface_i2c::I2CInterface<I>,
        ssd1306::size::DisplaySize128x64,
        ssd1306::mode::BufferedGraphicsMode<ssd1306::size::DisplaySize128x64>,
    >,
}

impl<I: I2c> SSD1306Device<I> {
    pub fn new(i2c: I) -> Self {
        let interface = display_interface_i2c::I2CInterface::new(i2c, 0x3C, 0x40);
        let display = ssd1306::Ssd1306::new(
            interface,
            ssd1306::size::DisplaySize128x64,
            ssd1306::rotation::DisplayRotation::Rotate0,
        )
        .into_buffered_graphics_mode();
        Self { display }
    }

    pub fn init(&mut self) {
        let _ = self.display.init();
    }

    pub fn clear(&mut self) {
        let _ = self.display.clear(embedded_graphics::pixelcolor::BinaryColor::Off);
    }

    pub fn flush(&mut self) {
        let _ = self.display.flush();
    }

    pub fn print(&mut self, x: i32, y: i32, text: &str) {
        // uses embedded_graphics Text widget
    }
}
```

---

## mod.rs  (`espforge_devices/src/devices/ssd1306/mod.rs`)

```rust
pub mod device;
```

---

## devices/mod.rs patch

```rust
#[cfg(feature = "ssd1306")]
pub mod ssd1306;
```

---

## Cargo.toml additions

```toml
[dependencies]
ssd1306 = { version = "0.10.0", optional = true }
display-interface-i2c = { version = "0.5.0", optional = true }

[features]
ssd1306 = ["dep:ssd1306", "dep:display-interface-i2c"]
```

---

## Builder plugin  (`espforge_devices_builder/src/ssd1306.rs`)

Key points:
- Config has `component: DeviceRef<ComponentRef>`, `address: Option<u8>`, `width`, `height`.
- `resolve_dependencies` returns `vec![Dependency::component(config.component.as_str())]`.
- `generate_code` uses `ctx.dependency_access(component, DependencyKind::Component)` for the bus.
- The generated `init` block creates `SSD1306Device::new(I2cDevice::new(&bus))`.

---

## YAML usage

```yaml
esp32:
  i2c:
    i2c0: { i2c: 0, sda: 6, scl: 5, frequency_khz: 100 }

components:
  i2c_master:
    using: I2cDevice
    with:
      i2c: $i2c0

devices:
  oled:
    using: ssd1306
    with:
      component: $i2c_master
      address: 0x3C
      width: 128
      height: 64
```

---

## App usage

```rust
pub fn setup(ctx: &mut Context) {
    let oled = device!(oled);
    oled.init();
    oled.clear();
    oled.print(0, 0, "Hello Espforge!");
    oled.flush();
}
```

