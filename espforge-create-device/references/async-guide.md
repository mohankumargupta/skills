# How rust crates provide async and sync/blocking behaviour

1. Core Rule
The AI must NEVER assume:

* crate root type is blocking
* crate root type is async
* sync API is re-exported
* async API is re-exported
* identical type names refer to identical execution models

Instead it must discover execution model mechanically.


---

# 2. Mandatory Inspection Order

The skill should require this exact inspection sequence.

## Step 1 — Inspect Cargo.toml Features

Look for:

* `async`
* `blocking`
* `sync`
* `embedded-hal-async`
* `embedded-hal`
* `embedded-hal-nb`

Important:

* default features may select sync OR async
* enabling async may disable sync
* both may coexist

Example from BMP180 crate:

* `blocking`
* `async`
  features coexist. ([Docs.rs][1])

The skill should instruct:

> Never infer execution model from crate description alone.

---

## Step 2 — Inspect `src/lib.rs`

Search for:

```rust
pub mod blocking;
pub mod async;
pub mod asynch;
pub use ...
```

Critical distinction:

```rust
pub mod blocking;
```

DOES NOT mean:

```rust
pub use blocking::*;
```


> Presence of a module is not a re-export.

---

## Step 3 — Determine Which Types Exist At Crate Root

The AI should enumerate:

```rust
crate::Type
crate::blocking::Type
crate::asynch::Type
crate::async::Type
```

and determine whether they are:

* distinct structs
* type aliases
* cfg-gated
* wrappers
* same name in different modules

---

## Step 4 — Inspect Trait Bounds

This is the MOST reliable signal.

Blocking drivers usually bind:

```rust
I2C: embedded_hal::i2c::I2c
```

Async drivers usually bind:

```rust
I2C: embedded_hal_async::i2c::I2c
```


> Trait bounds override naming conventions.

Because naming is inconsistent across ecosystem.

Example from community discussion: 

```rust
impl<I2C> FS3000<Blocking, I2C>
where
    I2C: embedded_hal::i2c::I2c,
```

vs

```rust
impl<I2C> FS3000<Async, I2C>
where
    I2C: embedded_hal_async::i2c::I2c,
```

---

# 3. Common Patterns the Skill Must Detect


---

## Pattern A — Blocking in `blocking` Module

Example:

```rust
crate::blocking::BMP180
```

while root exports async.



---

## Pattern B — Async in `asynch` Module

Some crates avoid reserved keyword:

```rust
pub mod asynch;
```

BMP180 docs show:

* module named `asynch` ([Docs.rs][1])

The AI must check:

* `async`
* `asynch`
* `async_`
* `r#async`

---

## Pattern C — Same Struct Name in Different Modules

Example:

```rust
blocking::Sensor
async::Sensor
```

AI must preserve full path.

Never collapse to ambiguous `Sensor`.

---

## Pattern D — Feature-Gated Impl Blocks

Same struct:

```rust
pub struct Sensor<I2C> {}
```

but methods change based on features:

```rust
#[cfg(feature = "async")]
async fn read(...)
```

vs

```rust
#[cfg(feature = "blocking")]
fn read(...)
```


---

## Pattern E — Marker-Type Generic Strategy

Seen in newer drivers. 

Example:

```rust
Sensor<Blocking, I2C>
Sensor<Async, I2C>
```

Execution model encoded in generic parameter.

---

## Pattern F — Separate Crates

Examples:

* `embedded-hal`
* `embedded-hal-async`
* `embedded-hal-nb`

These are intentionally separate ecosystems. 

Some drivers expose:

* sync in one crate
* async adapter in another crate

---

## Pattern G — Constructor Differences

Example:

```rust
Sensor::new()
Sensor::new_async()
```

or:

```rust
Sensor::new_blocking()
```

Do not assume identical constructor semantics.

---

## Pattern H — Examples Reveal Intended API

Many embedded crates poorly document exports.

The skill should instruct:

Priority order:

1. examples/
2. tests/
3. docs.rs examples
4. lib.rs

Examples often reveal correct import path.

---

# 4. Required AI Validation Rules


## Before generating code

The AI must verify:

* import path
* feature flags
* whether methods are async
* whether `.await` is required
* whether executor is required
* whether HAL implementation matches trait family

---

# 5. Strong Heuristics Section



## Heuristic 1

If methods are `async fn`:

* driver is async
* HAL must implement `embedded-hal-async`

---

## Heuristic 2

If no `.await` appears in examples:

* likely blocking

---

# 6. Recommended “Execution Model Classification” Output



```markdown
Execution model analysis:

- Root type:
  - bmp180_embedded_hal::BMP180
  - async

- Blocking API:
  - bmp180_embedded_hal::blocking::BMP180

- Required features:
  - blocking
  - async

- Trait families:
  - blocking uses embedded_hal::i2c::I2c
  - async uses embedded_hal_async::i2c::I2c

- Recommended import for user request:
  - bmp180_embedded_hal::blocking::BMP180
```


---

# 7. Important Ecosystem Reality


> The embedded Rust ecosystem has NO universal convention for dual sync/async drivers.

Crates may:

* default to async
* default to blocking
* hide blocking in module
* hide async in module
* use feature-gated impls
* use marker traits
* use separate types
* use separate crates

So the AI must inspect actual source layout every time.

---

# 8. Recommended “Never Assume” Rules

Add a dedicated section:

```markdown
Never assume:

- crate root == blocking
- crate root == async
- pub mod == pub use
- same type name == same behavior
- embedded-hal implies blocking-only
- embedded-hal-async replaces embedded-hal
- examples cover all APIs
- default features match user intent
```

---

# 9. Best Sources to Scan First

For embedded drivers specifically:

1. Cargo.toml
2. src/lib.rs
3. examples/
4. tests/
5. docs.rs module tree
6. cfg(feature) sections
7. trait bounds

This ordering catches almost every edge case efficiently.

---

The most important insight for the skill is:

> In embedded Rust, execution model is determined by trait bounds and module structure — not by crate marketing text or root exports.

