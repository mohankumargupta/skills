# Decision Guide for Common Cases

## Which bus type?

| Driver constructor takes… | YAML `component` references… | `DependencyKind` |
|---|---|---|
| `embedded_hal::i2c::I2c` | `I2cDevice` component | `DependencyKind::Component` |
| `embedded_hal::spi::SpiDevice` | `SpiDevice` component | `DependencyKind::Component` |
| GPIO pin directly | pin under `esp32.gpio` | `DependencyKind::Pin` |

## Which DeviceRef marker type?

```rust
pub component: DeviceRef<ComponentRef>,  // must reference a component (I2cDevice, SpiDevice, …)
pub dc_pin:    DeviceRef<PinRef>,        // must reference a GPIO pin under esp32.gpio
```

---

## Does the driver need `.init()`?

Do **not** call `init()` inside `new()`. Expose it as a separate public method and call it
from the builder's init block:

```rust
// device.rs
pub fn init(&mut self) {
    self.inner.init().expect("init failed");
}

// builder generate_code() — init block pattern
let init = quote! {
    {
        let mut #field_ident = MyDevice::new(#bus_access);
        #field_ident.init().expect("MyDevice init failed");
        #field_ident
    }
};
```

When you use `codegen()`, supply this whole block as the `init` argument — `codegen()` does
**not** add another wrapping block; it uses the expression as-is.

---

## Does the driver need a `delay` argument?

`Devices::new()` always receives `delay: &mut espforge_platform::delay::Delay`. Pass `*delay`
to copy it (esp-hal `Delay` is `Copy`):

```rust
let init = quote! {
    espforge_devices::devices::my_device::device::MyDevice::new(#bus_access, *delay)
};
```

---

## Does the driver need optional config fields with defaults?

Add `Option<T>` fields to the config struct and resolve defaults in `generate_code()`:

```rust
#[derive(Debug, Deserialize)]
pub struct MySensorConfig {
    pub component: DeviceRef<ComponentRef>,
    pub oversampling: Option<u8>,   // default applied below
}

fn generate_code(&self, config: &MySensorConfig, ctx: &GenerationContext) -> Result<GeneratedCode> {
    let oversampling = config.oversampling.unwrap_or(1u8);
    let init = quote! {
        MySensor::new(#i2c_access, #oversampling)
    };
    // ...
}
```

---

## Guardrails for `generate_code()`

**Never** interpolate `ctx` fields directly inside `quote!`:

```rust
// ❌ WRONG — quote! cannot interpolate struct field access
let init = quote! { let mut #ctx.instance_name = ...; };

// ✅ CORRECT — bind to a local ident first
let field_ident = format_ident!("{}", ctx.instance_name);
let init = quote! { let mut #field_ident = ...; };
```

**Checklist before finishing a plugin:**
1. `field` is a type only — not `pub <name>: <type>`
2. `init` is an expression (or block) that produces the device value
3. `codegen(ctx.instance_name, field, init)` is used — not manual `GeneratedCode { … }`
4. Every mutable local in `quote!` comes from `format_ident!`
5. `cargo check -p espforge_devices_builder` passes clean

