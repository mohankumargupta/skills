# Plugin API Reference

These are the **exact** real signatures used in `generate_code()`. Do not invent alternatives.

## `espforge_configuration/src/plugin.rs` — key types

```rust
// The context passed to every generate_code() call
pub struct GenerationContext<'a> {
    pub instance_name: &'a str,                                    // e.g. "oled" or "display"
    pub properties: &'a serde_yaml_ng::Value,                      // raw YAML `with:` block
    pub model: &'a EspforgeConfiguration,                          // full parsed config
    pub resolved_deps: &'a HashMap<String, ResolvedDependency>,    // pre-resolved deps
}

impl GenerationContext<'_> {
    /// Normalize a reference: strips leading '$' if present
    pub fn normalize_ref_name<'s>(&self, name: &'s str) -> &'s str

    /// Retrieve a resolved dep and validate its kind; errors if kind is wrong
    pub fn dependency(&self, name: &str, expected: DependencyKind) -> Result<&ResolvedDependency>

    /// Resolve AND parse the access path as a TokenStream in one call.
    /// e.g. produces `components.i2c_master` or `registry.gpio5`
    pub fn dependency_access(&self, name: &str, expected: DependencyKind) -> Result<TokenStream>
}

// What generate_code() must return
pub struct GeneratedCode {
    pub field: TokenStream,       // type declaration for the Devices struct field
    pub init: TokenStream,        // expression that constructs the device
    pub struct_init: TokenStream, // field name used in the struct literal
}

/// Wraps init in a block {} to isolate locals, preventing name collisions.
/// Use this instead of building GeneratedCode manually.
pub fn codegen(instance_name: &str, field: TokenStream, init: TokenStream) -> GeneratedCode

pub enum DependencyKind {
    Component,   // a named component: I2cDevice, SpiDevice, etc.
    Device,      // a named device
    Peripheral,  // a raw hardware peripheral: i2c0, spi2, etc.
    Pin,         // a GPIO pin declared under esp32.gpio
}

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

## `espforge_configuration/src/refs.rs` — typed YAML references

```rust
pub struct ComponentRef;  // marker: reference to a component (I2cDevice, SpiDevice, …)
pub struct PinRef;        // marker: reference to a GPIO pin under esp32.gpio

pub struct DeviceRef<T> {
    raw: String,              // already stripped of the leading '$' at deserialization
    _kind: PhantomData<T>,
}

impl<T> DeviceRef<T> {
    pub fn as_str(&self) -> &str   // returns the name without '$', e.g. "i2c_master"
}
```

> **The `$` prefix is stripped automatically at YAML deserialization — never call
> `.strip_prefix('$')` on a `DeviceRef`.**

## `espforge_platform/src/delay/mod.rs` — delay injection

`Devices::new()` always receives `delay: &mut espforge_platform::delay::Delay`.
Pass `*delay` to copy it (esp-hal's `Delay` is `Copy`).

```rust
let init = quote! {
    espforge_devices::devices::my_device::device::MyDevice::new(#bus_access, *delay)
};
```

---

## Builder Plugin Template

Use this as your starting point for every new `espforge_devices_builder/src/<device>.rs`:

```rust
use anyhow::Result;
use espforge_configuration::plugin::{
    codegen, Dependency, DependencyKind, DeviceRef, ComponentRef, PinRef,
    GeneratedCode, GenerationContext,
};
use espforge_macros::DevicePlugin;
use quote::{format_ident, quote};
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct MySensorConfig {
    pub component: DeviceRef<ComponentRef>,
    pub address: Option<u8>,
}

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
        let field_ident = format_ident!("{}", ctx.instance_name);   // ← always do this
        let i2c_access =
            ctx.dependency_access(config.component.as_str(), DependencyKind::Component)?;

        let field = quote! {
            espforge_devices::devices::my_sensor::device::MySensorDevice
                espforge_platform::bus::I2cDevice<'static>
            >
        };

        // If device needs init(), wrap in a block:
        let init = quote! {
            {
                let mut #field_ident =
                    espforge_devices::devices::my_sensor::device::MySensorDevice::new(
                        #i2c_access,
                        #address,
                    );
                #field_ident.init().expect("MySensor init failed");
                #field_ident
            }
        };

        Ok(codegen(ctx.instance_name, field, init))
    }
}
```

## What the Generated Output Looks Like

Understanding what `field` and `init` produce helps avoid mistakes:

```rust
pub struct Devices {
    // ← field token (a type expression)
    pub oled: espforge_devices::devices::ssd1306::device::SSD1306Device
        espforge_platform::bus::I2cDevice<'static>
    >,
}

impl Devices {
    pub fn new(components: &'static mut Components, delay: &mut Delay) -> Self {
        // ← init token (a block expression), wrapped by codegen()
        let oled = {
            let mut oled = espforge_devices::devices::ssd1306::device::SSD1306Device::new(
                components.i2c_master   // ← what dependency_access() returns
            );
            oled.init();
            oled
        };
        Self { oled }   // ← struct_init from codegen()
    }
}
```

**Rules:**
- `field` is a **type only** — not `pub <name>: <type>`
- `init` is a **block expression** producing a value of that type
- `codegen()` wraps `init` automatically — do **not** add extra braces yourself
- Always create `format_ident!` locals before `quote!` blocks; never interpolate `#ctx.field`

