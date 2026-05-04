## Async crates

There are numerous crates used to reduce duplicate code between blocking/sync and async code.

Here is a list to them you might encounter:

- maybe-async-cfg
- nb




# maybe-async-cfg crate

The same method signatures exist in both sync and async variants. 
It uses macro expansion to achieve this.

When feature = "async" is enabled, all public methods become async fn and use embedded-hal-async traits
When using default (sync), methods are regular fn using embedded-hal traits
The constructor and config types are identical in both modes

