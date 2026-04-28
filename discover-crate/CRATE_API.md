# SKILL: Create API Documentation

> **Prerequisite:** REPO_EXAMPLES.md must have run first.
> The crate source is expected at `artifacts/<crate>/` relative to the working directory.

---

## Step 1 — Read `Cargo.toml`

Open `artifacts/<crate>/Cargo.toml` and record:

- The crate name and version.
- Any feature flags (look for `[features]`). Note which features are default and which are
  additive (e.g. `async`, `blocking`, `defmt`).
- Key dependencies — especially `embedded-hal`, `embedded-hal-async`, `embedded-io`.
  Record the version requirement for each.

---

## Step 2 — Read `src/lib.rs` (and any sub-modules)

Open `artifacts/<crate>/src/lib.rs`. Work through it top-to-bottom:

1. **Module layout** — list every `pub mod` and `mod` declaration.
   For each `mod foo`, also read `artifacts/<crate>/src/foo.rs` (or
   `artifacts/<crate>/src/foo/mod.rs`) so the full tree is covered.

2. **Public types** — for every `pub struct`, `pub enum`, and `pub trait`:
   - Record the name, generic parameters, and any `#[derive(...)]` attributes.
   - Note which embedded-hal traits it implements (scan `impl` blocks).

3. **Public API surface** — for every `pub fn`, `pub async fn`, and trait `fn`:
   - Record the full signature (name, parameters with types, return type).
   - Note whether it is `async` and whether it is behind a feature flag
     (look for `#[cfg(feature = "...")]` above the item).
   - Group methods under their parent struct or trait.

4. **Error types** — find the crate's error enum(s) and list their variants.

5. **Re-exports** — note any `pub use` statements that expose items at the crate root.

---

## Step 3 — Read the examples

Open every file under `artifacts/<crate>/examples/`.

For each example file:

- Record the filename and infer its purpose from the name and imports.
- Note which struct/driver is instantiated and how (constructor call + arguments).
- Note the initialisation sequence (bus setup → driver construction → config calls).
- Distinguish **blocking** examples (use `embedded-hal` traits, no `.await`) from
  **async** examples (use `embedded-hal-async` traits, `.await` present).
- Copy or paraphrase the most illustrative 10–20 lines that show typical usage.

---

## Step 4 — Synthesise and write `<device>_api.md`

Combine everything above into `<device>_api.md` using the structure below.

```markdown
# <CRATE_NAME> API Reference

## Crate metadata
- **Version:** x.y.z
- **Features:** list all feature flags and what each enables
- **embedded-hal version:** e.g. `^1.0`
- **Async support:** yes / no

## Public types

### `StructName<...>`
Brief one-line description inferred from doc comments or usage.

**Constructor(s)**
```rust
pub fn new(bus: I2C, address: u8) -> Self
```

**Methods**
```rust
pub fn read_temperature(&mut self) -> Result<f32, Error<E>>
pub async fn read_temperature(&mut self) -> Result<f32, Error<E>>   // feature = "async"
```

*(Repeat for every public struct/enum/trait.)*

## Error types

```rust
pub enum Error<E> {
    Bus(E),
    InvalidData,
    // ...
}
```

## Usage examples

### Blocking
*(Paste or paraphrase the key lines from the blocking example.)*

### Async
*(Paste or paraphrase the key lines from the async example, if present.)*

## Notes
- Any caveats, known limitations, or feature-flag interactions worth flagging.
```

If no examples directory was present (REPO_EXAMPLES.md exited 1), write
`"No upstream examples available."` in the Usage examples section and derive
usage solely from the source code.
