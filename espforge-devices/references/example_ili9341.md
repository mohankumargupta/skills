# Example Device: ILI9341 TFT Display (SPI + GPIO)

This is the canonical SPI + control-pin device example in espforge.
Use this as a template when adding any device that needs a SPI bus **plus** extra GPIO lines.

---

## Crate used

`ili9341 = "0.6.0"` — embedded-hal v1 compatible SPI TFT driver.

---

## device.rs  (`espforge_devices/src/devices/ili9341/device.rs`)

```rust
use display_interface_spi::SPIInterface;
use embedded_hal::{delay::DelayNs, digital::OutputPin, spi::SpiDevice};
use ili9341::{DisplaySize240x320, Ili9341, Orientation};

pub struct ILI9341Device<SPI, DC, RST> {
    display: Ili9341<SPIInterface<SPI, DC>, RST>,
}

impl<SPI: SpiDevice, DC: OutputPin, RST: OutputPin> ILI9341Device<SPI, DC, RST> {
    pub fn new(spi: SPI, dc: DC, rst: RST, delay: &mut impl DelayNs) -> Self {
        let iface = SPIInterface::new(spi, dc);
        let display = Ili9341::new(iface, rst, delay, Orientation::Portrait, DisplaySize240x320)
            .unwrap();
        Self { display }
    }

    pub fn clear(&mut self) {
        use embedded_graphics::draw_target::DrawTarget;
        use embedded_graphics::pixelcolor::Rgb565;
        let _ = self.display.clear(Rgb565::BLACK);
    }

    pub fn print(&mut self, x: i32, y: i32, text: &str) {
        // uses embedded_graphics Text widget
    }
}
```

---

## Config struct (builder)

```rust
#[derive(Deserialize, Debug, Clone)]
pub struct ILI9341Config {
    pub spi: DeviceRef<ComponentRef>,   // SPI bus component
    pub dc:  DeviceRef<PinRef>,         // Data/Command pin
    pub rst: DeviceRef<PinRef>,         // Reset pin
    pub cs:  DeviceRef<PinRef>,         // Chip-select pin
}
```

## resolve_dependencies (builder)

```rust
fn resolve_dependencies(&self, config: &ILI9341Config) -> Result<Vec<Dependency>> {
    Ok(vec![
        Dependency::component_ref(&config.spi),
        Dependency::pin_ref(&config.dc),
        Dependency::pin_ref(&config.rst),
        Dependency::pin_ref(&config.cs),
    ])
}
```

---

## Cargo.toml additions

```toml
[dependencies]
ili9341 = { version = "0.6.0", optional = true }
display-interface-spi = { version = "0.5.0", optional = true }

[features]
ili9341 = ["dep:ili9341", "dep:display-interface-spi"]
```

---

## YAML usage

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
  display:
    using: ili9341
    with:
      spi: $main_spi
      dc: $pin_dc
      rst: $pin_rst
      cs: $pin_cs
```

---

## App usage

```rust
pub fn setup(ctx: &mut Context) {
    let display = device!(display);
    display.clear();
    display.print(10, 10, "Hello World");
}
```
