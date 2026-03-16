
---
name: build_rust_nwg_gui
description: Builds Windows desktop GUI applications in Rust using native-windows-gui (NWG) and the native-windows-derive (NWD) macros.
---

# SKILL: Building Rust GUIs with Native Windows GUI (NWG)

## Objective
This skill teaches you how to translate visual UI mockups or descriptions into functional Rust applications using the `native-windows-gui` and `native-windows-derive` crates.

## ⚠️ CRITICAL CONSTRAINTS
*   **ALWAYS use `native-windows-derive`:** You MUST use the `#[derive(NwgUi)]` procedural macro pattern. Do NOT write manual `NativeUi` implementations or raw Win32 boilerplate unless explicitly requested.
*   **State Management:** Always wrap mutable application state in `std::cell::RefCell`. Event handlers in NWG take `&self`, meaning standard `&mut self` mutation is impossible.
*   **Console Window:** Always include `#![windows_subsystem = "windows"]` at the top of the main file to hide the terminal window on launch.

## 1. Cargo.toml Setup
Always ensure the correct dependencies and features are included. NWG heavily gates controls behind features to reduce compile times. If a specific control is used (like a rich text box or a grid layout), its feature must be enabled.

```toml
[dependencies]
native-windows-derive = { git = "https://github.com/kambo-1st/native-windows-gui" }
native-windows-gui = { git = "https://github.com/kambo-1st/native-windows-gui", default-features = true, features=["high-dpi"]  }

[build-dependencies]
embed-manifest = "1.5"

```

```rust
//build.rs
use embed_manifest::{embed_manifest, new_manifest};
use embed_manifest::manifest::{ActiveCodePage, DpiAwareness};

fn main() {
    if std::env::var_os("CARGO_CFG_WINDOWS").is_some() {
        embed_manifest(
            new_manifest("mqtt-keyboard")
                .active_code_page(ActiveCodePage::Utf8)
                .dpi_awareness(DpiAwareness::PerMonitorV2)
        ).expect("unable to embed manifest file");
    }
    println!("cargo:rerun-if-changed=build.rs");
}

```


## 2. Layout & Architecture Process
When generating a UI, follow this mental model:
1.  **Layout System:** Default to `nwg::GridLayout` for structured forms or dashboards. Use `col_span` and `row_span` for elements that need to stretch.
2.  **Resource Initialization Order:** In the struct, define resources (`nwg::Font`, `nwg::Icon`) *before* the controls that use them.
3.  **Parenting:** The derive macro automatically guesses the parent (usually the `nwg::Window` defined at the top). Only explicitly define `parent: my_parent` if nesting within things like `nwg::Frame`.

## 3. Common Pitfalls & Workarounds
*   **Colored Text:** Standard `nwg::Label` cannot change text color via macros. **Workaround:** Use `nwg::RichLabel` and set the color programmatically in the `OnInit` event handler using `self.my_label.set_char_format(...)`.
*   **Colored Backgrounds:** Standard `nwg::Label` *does* support `background_color: Some([R, G, B])` in the derive macro.
*   **Password Masking:** Use `nwg::TextInput`. To mask, use `password: Some('•')`. To toggle visibility at runtime, call `self.my_input.set_password_char(None)` or `Some('•')`.
*   **Infinite Event Loops:** When syncing two controls (e.g., two ListBoxes that mirror selections), updating one programmatically triggers its event handler, creating an infinite loop. **Workaround:** Use an `is_syncing: RefCell<bool>` flag to break the recursion.

## 4. Reference Pattern / Example
Use this complete, working example as your template for generating new NWG applications:

```rust
#![windows_subsystem = "windows"]

extern crate native_windows_gui as nwg;
extern crate native_windows_derive as nwd;

use nwd::NwgUi;
use nwg::NativeUi;
use std::cell::RefCell;

#[derive(Default, NwgUi)]
pub struct ExampleApp {
    // 1. Main Window
    #[nwg_control(size: (400, 300), position: (300, 300), title: "Example App", flags: "WINDOW|VISIBLE")]
    #[nwg_events( OnWindowClose:[nwg::stop_thread_dispatch()], OnInit: [ExampleApp::on_init] )]
    window: nwg::Window,

    // 2. Resources (Fonts, Icons)
    #[nwg_resource(family: "Segoe UI", size: 15)]
    default_font: nwg::Font,

    // 3. Layouts
    #[nwg_layout(parent: window, margin: [10, 10, 10, 10], spacing: 5)]
    grid: nwg::GridLayout,

    // 4. Controls
    #[nwg_control(text: "Enter Name:", font: Some(&data.default_font))]
    #[nwg_layout_item(layout: grid, col: 0, row: 0)]
    label_name: nwg::Label,

    #[nwg_control(text: "", font: Some(&data.default_font))]
    #[nwg_layout_item(layout: grid, col: 1, row: 0, col_span: 2)]
    input_name: nwg::TextInput,

    #[nwg_control(text: "Submit", font: Some(&data.default_font))]
    #[nwg_layout_item(layout: grid, col: 1, row: 1)]
    #[nwg_events( OnButtonClick: [ExampleApp::on_submit] )]
    btn_submit: nwg::Button,

    // 5. Mutable State
    click_count: RefCell<u32>,
}

impl ExampleApp {
    fn on_init(&self) {
        // Post-creation setup goes here
    }

    fn on_submit(&self) {
        let mut count = self.click_count.borrow_mut();
        *count += 1;
        
        let name = self.input_name.text();
        let msg = format!("Hello, {}! You clicked {} times.", name, count);
        
        nwg::modal_info_message(&self.window, "Success", &msg);
    }
}

fn main() {
    nwg::init().expect("Failed to init Native Windows GUI");
    nwg::Font::set_global_family("Segoe UI").expect("Failed to set default font");

    let _app = ExampleApp::build_ui(Default::default()).expect("Failed to build UI");

    nwg::dispatch_thread_events();
}
```
