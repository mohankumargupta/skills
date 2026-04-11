# Common Compile Errors and Fixes

## Runtime device (`espforge_devices`) errors

| Error | Cause | Fix |
|-------|-------|-----|
| `failed to resolve: use of undeclared crate or module std` | Used `std::` in `device.rs` | Replace with `core::` (or `alloc::` for heap types — add `extern crate alloc;`) |
| `cannot find type … in this scope` | Missing `use` for embedded-hal trait | Add `use embedded_hal::i2c::I2c;` (or `spi::SpiDevice`, etc.) |
| `the trait bound … is not satisfied` | Driver crate expects older embedded-hal | Confirm crate supports embedded-hal v1 via `references/crate-standards.md` |

## Builder plugin (`espforge_devices_builder`) errors

| Error | Cause | Fix |
|-------|-------|-----|
| `error: Unknown device driver: my_sensor` at compile time | `#[plugin(name = "...")]` doesn't match the `using:` value in YAML, **or** `pub mod my_sensor;` missing from `lib.rs` | Check both the `name` attribute and `lib.rs` registration |
| `dependency 'foo' not found` / wrong kind | Passed wrong `DependencyKind` to `dependency_access`, or forgot declaration in `resolve_dependencies` | Kind in `dependency_access` must match `resolve_dependencies`; component → `Component`, pin → `Pin` |
| Double-braces `{{ … }}` in generated code | Called `codegen()` **and** manually added `{ }` around the init expression | `codegen()` wraps the init automatically — pass the inner expression, not a block |
| Feature not propagated — missing trait impl in generated project | `#[plugin(features = "...")]` is missing or wrong | Must exactly match the feature name in `espforge_devices/Cargo.toml` |
| `quote!` expansion fails / garbled tokens | Tried to interpolate `#ctx.instance_name` directly | Bind to a local first: `let id = format_ident!("{}", ctx.instance_name);` |

## `espforge compile` / YAML errors

| Error | Cause | Fix |
|-------|-------|-----|
| Pin conflicts during `espforge compile` | Two entries in `esp32:` share the same physical pin number | Each physical pin can only be assigned once — fix the YAML |
| `component '$x' not found` | `using: $x` references a component that isn't declared | Check YAML component name and `$` prefix |

---

## no_std quick-reference

| Forbidden | Use instead |
|-----------|-------------|
| `std::fmt::Display` | `core::fmt::Display` |
| `std::string::String` | `alloc::string::String` (needs `extern crate alloc`) |
| `std::vec::Vec` | `alloc::vec::Vec` |
| `std::collections::HashMap` | not available; use `heapless` or restructure |
| `println!` | `log::info!` or `esp_println::println!` |
| `std::error::Error` | custom error types or `embedded_hal` error bounds |

> The builder (`espforge_devices_builder`) runs on the host — full `std` is available there.

