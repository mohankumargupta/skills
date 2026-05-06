
---

## Key Facts About `esp_hal::delay::Delay`

```rust
#[derive(Clone, Copy, Default)]  // ← Critical: Delay is Copy + zero-sized
#[non_exhaustive]
pub struct Delay;

impl embedded_hal::delay::DelayNs for Delay {
    fn delay_ns(&mut self, ns: u32) { ... }
    
}
impl Delay {
    ...
    pub fn delay_millis(&self, ms: u32) {...}
    pub fn delay_micros(&self, us: u32) {...}
    pub fn delay_nanos(&self, ns: u32) {...}
```

**What this means for device wrappers:**

1. `Delay` is **zero-sized** — it has no fields, no allocation, no state
2. `Delay` is **`Copy`** — passing `*delay` creates a bitwise copy; the original is untouched
3. `Delay` implements **`DelayNs`** — any generic `D: DelayNs` bound accepts it

---




## Model A Revisited: Stored Delay (e.g. `bmp085-180-rs`)

### Why `*delay` works

`Devices::new()` receives `delay: &mut Delay`. Because `Delay` is `Copy`:

```rust
// builder init block
let init = quote! {
    let mut dev = espforge_devices::BMP180Device::new(#i2c_access, *delay);
    //                    ^^^^^^^^^^^^^^^
    //                    Copy of Delay is moved into the device
    dev.init().expect("BMP180 init failed");
    dev
};
```

After `*delay`, the original `&mut Delay` is **still valid** because `Delay` was copied, not moved. The next device can also use `*delay`:

```rust
let init2 = quote! {
    let mut other = espforge_devices::OtherDevice::new(#spi_access, *delay);
    other
};
```

### The device struct

```rust
pub struct BMP180Device<I, D> {
    sensor: BMP<I, D>,  // D will be inferred as Delay
}

impl<I: I2c, D: DelayNs> BMP180Device<I, D> {
    pub fn new(i2c: I, delay: D) -> Self {  // ← takes delay by value, not &mut
        Self { sensor: BMP::new(i2c, delay, Config::default()) }
    }
}
```

Note: the constructor takes `delay: D` (by value), not `&mut D`. This is possible because the upstream `BMP::new()` takes `D` by value.

### App code

```rust
pub fn forever(ctx: &mut Context) {
    let bmp180 = device!(bmp180);
    if let Some(t) = bmp180.read_temperature() { ... }  // ← no delay parameter!
}
```

---

## Model B Revisited: Per-Call Delay (e.g. `edrv-bmp180`)

### Why `&mut delay` is required

The upstream driver takes `delay: &mut D`:

```rust
// edrv-bmp180
pub fn read_temperature<D: DelayNs>(&mut self, delay: &mut D) -> Result<f32, ...> {
    delay.delay_ms(5);  // ← requires &mut self on DelayNs
    ...
}
```

In the app:

```rust
pub fn forever(ctx: &mut Context) {
    let mut delay = ctx.delay;   // ← reborrow: delay is Copy, so this copies it
    let bmp180 = device!(bmp180);
    if let Some(t) = bmp180.read_temperature(&mut delay) { ... }
}
```

**Wait — why `let mut delay = ctx.delay` and not `&mut ctx.delay`?**

Because `ctx.delay` **is** a `Delay` value (not `&mut Delay`). It's already owned by the `Context` struct. Since `Delay` is `Copy`, `let mut delay = ctx.delay` creates a mutable local copy. You then borrow that local copy with `&mut delay` for the method call.

If you tried `bmp180.read_temperature(&mut ctx.delay)`, you'd get a borrow checker error because you can't mutably borrow a field through a shared reference to `ctx` while also using other `ctx` fields (like `logger`).

---

## Delay Decision Steps

### Step 1: Check the upstream constructor

| Upstream `new()` signature | Action |
|---------------------------|--------|
| `new(i2c, delayer: D, ...)` where `D: DelayNs` | **Model A — Stored** |
| `new(i2c, ...)` only | **Model B — Per-call** or **Model C — None** |

### Step 2: Check upstream measurement methods

| Method signature | Action |
|-----------------|--------|
| `read_foo(&mut self) -> ...` | No delay needed at call time |
| `read_foo(&mut self, delay: &mut D) -> ...` | App must pass `&mut delay` per call |

### Step 3: Write the device wrapper

**Model A (Stored — e.g. `bmp085-180-rs`)**

```rust
pub struct MyDevice<I, D> {
    inner: UpstreamDriver<I, D>,
}

impl<I: I2c, D: DelayNs> MyDevice<I, D> {
    pub fn new(i2c: I, delay: D) -> Self {  // ← by value
        Self { inner: UpstreamDriver::new(i2c, delay, ...) }
    }
}
```

**Model B (Per-call — e.g. `edrv-bmp180`)**

```rust
pub struct MyDevice<I: I2c> {
    inner: UpstreamDriver<I>,
}

impl<I: I2c> MyDevice<I> {
    pub fn read_foo<D: DelayNs>(&mut self, delay: &mut D) -> Option<f32> {
        self.inner.read_foo(delay).ok()
    }
}
```

### Step 4: Write the builder

**Model A builder**

```rust
let init = quote! {
    let mut dev = espforge_devices::MyDevice::new(#i2c_access, *delay);
    dev.init().expect("MyDevice init failed");
    dev
};
```

**Model B builder**

```rust
let init = quote! {
    let mut dev = espforge_devices::MyDevice::new(#i2c_access);
    dev.init().expect("MyDevice init failed");
    dev
};
```

### Step 5: Write the app

**Model A app**

```rust
pub fn forever(ctx: &mut Context) {
    let sensor = device!(sensor);
    if let Some(v) = sensor.read_foo() { ... }  // no delay parameter
}
```

**Model B app**

```rust
pub fn forever(ctx: &mut Context) {
    let mut delay = ctx.delay;  // ← mutable local copy
    let sensor = device!(sensor);
    if let Some(v) = sensor.read_foo(&mut delay) { ... }
}
```

---

## Why This Matters for `bmp085-180-rs` vs `edrv-bmp180`

| | `bmp085-180-rs` | `edrv-bmp180` |
|---|---|---|
| **Constructor** | `BMP::new(i2c, delayer, config)` | `BMP180::new(i2c, addr)` |
| **Delay storage** | Owned by driver | Not stored |
| **Read methods** | `read_temperature(&mut self)` | `read_temperature(&mut self, delay: &mut D)` |
| **Device generics** | `BMP180Device<I, D>` | `BMP180Device<I>` |
| **App code** | Clean, no delay juggling | Must pass `&mut delay` per call |
| **Builder init** | `*delay` passed to constructor | No delay in constructor |

