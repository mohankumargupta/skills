# Example Device: FT6206 Capacitive Touch Controller (I2C with optional config)

Use this as a template when your device has **optional YAML configuration fields with defaults**.

---

## Crate used

`ft6206` — embedded-hal v1 compatible I2C capacitive touch driver.

---

## device.rs (`espforge_devices/src/devices/ft6206/device.rs`)

```rust
use embedded_hal::i2c::I2c;

pub struct FT6206<I> {
    inner: ft6206::FT6206<I>,
    screen_width: u16,
    screen_height: u16,
}

impl<I: I2c> FT6206<I> {
    pub fn new(
        i2c: I,
        address: u8,
        screen_width: u16,
        screen_height: u16,
        x_min: u16,
        x_max: u16,
        y_min: u16,
        y_max: u16,
    ) -> Self {
        Self {
            inner: ft6206::FT6206::new(i2c, address),
            screen_width,
            screen_height,
        }
    }

    pub fn read_touch(&mut self) -> Option<(u16, u16)> {
        self.inner.read_touch().ok().flatten()
    }
}
```

---

## Config struct (builder)

```rust
#[derive(Deserialize, Debug, Clone)]
pub struct FT6206Config {
    pub component: DeviceRef<ComponentRef>,
    pub address: Option<u8>,         // default 0x38
    pub screen_width: Option<u16>,   // default 240
    pub screen_height: Option<u16>,  // default 320
    pub x_min: Option<u16>,
    pub x_max: Option<u16>,
    pub y_min: Option<u16>,
    pub y_max: Option<u16>,
}
```

## generate_code (builder) — key pattern: resolve defaults before `quote!`

```rust
fn generate_code(&self, config: &FT6206Config, ctx: &GenerationContext) -> Result<GeneratedCode> {
    // Resolve all optional fields to concrete values BEFORE entering quote!
    let address      = config.address.unwrap_or(0x38u8);
    let screen_width = config.screen_width.unwrap_or(240u16);
    let screen_height= config.screen_height.unwrap_or(320u16);
    let x_min        = config.x_min.unwrap_or(0u16);
    let x_max        = config.x_max.unwrap_or(screen_width);
    let y_min        = config.y_min.unwrap_or(0u16);
    let y_max        = config.y_max.unwrap_or(screen_height);

    let i2c_access = ctx.dependency_access(config.component.as_str(), DependencyKind::Component)?;

    let field = quote! {
        espforge_devices::devices::ft6206::device::FT6206
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

> **Key lesson**: All `Option<T>` defaults must be resolved to concrete literals before
> entering `quote!`. You cannot call `.unwrap_or()` inside a `quote!` block.

---

## YAML usage

```yaml
devices:
  touch:
    using: ft6206
    with:
      component: $i2c_master
      # All fields below are optional — shown here with their defaults
      address: 0x38
      screen_width: 240
      screen_height: 320
```

