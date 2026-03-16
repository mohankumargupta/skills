


Here is a generalized `SKILL.md` designed to train an AI on how to effectively build and troubleshoot Rust GUIs using the `native-windows-gui` (NWG) and `native-windows-derive` (NWD) crates.

***

# SKILL: Building Rust GUIs with Native Windows GUI (NWG)

## Objective
This document outlines the systematic approach, mental models, and specific workarounds required to successfully translate a visual UI mockup into a functional Rust application using `native-windows-gui` and `native-windows-derive`.

## Phase 1: Visual Analysis & Layout Planning
Before writing code, you must analyze the target GUI and mentally map it to NWG components.

1.  **Identify the Layout System:** 
    *   For forms, settings, or structured dashboards, default to `nwg::GridLayout`. 
    *   Mentally overlay a grid on the mockup. Identify the maximum number of columns.
    *   Note where controls need `col_span` or `row_span`.
2.  **Identify Resources:**
    *   Are there custom fonts? (Requires `nwg::Font`).
    *   Are there icons or images? (Requires `nwg::Icon` or `nwg::Bitmap`).
3.  **Identify Controls:**
    *   Standard text -> `nwg::Label`
    *   Input fields -> `nwg::TextInput`
    *   Lists -> `nwg::ListBox`
    *   Toggles -> `nwg::CheckBox` or `nwg::RadioButton`


## Phase 3: Structuring the `NwgUi`
When using `native-windows-derive`, the application is defined as a struct with `#[derive(Default, NwgUi)]`. 

**Order of Definition Matters:**
While not strictly enforced by the compiler, organizing the struct logically prevents borrowing and initialization order bugs:
1.  **Main Window:** Define the `nwg::Window` first.
2.  **Resources:** Define `nwg::Font`, `nwg::Icon`, etc. (These are initialized before controls, so controls can reference them).
3.  **Layouts:** Define `nwg::GridLayout` or `nwg::FlexboxLayout`.
4.  **Controls:** Define the actual UI elements.
5.  **State Variables:** Define application state using `std::cell::RefCell`.

**Macro Syntax Rules:**
*   Control setup: `#[nwg_control(text: "Hello", size: (100, 20))]`
*   Layout positioning: `#[nwg_layout_item(layout: my_grid, col: 0, row: 1, col_span: 2)]`
*   Event binding: `#[nwg_events(OnButtonClick: [MyApp::my_function])]`

## Phase 4: Tricky Problems & Workarounds

When building NWG apps, you will encounter limitations in the native Win32 API. Here is how to work around them.

### Problem 1: Colored Text
*   **The Trap:** You might try to set `text_color` on a standard `nwg::Label`. This will fail because standard Win32 static controls don't easily support text color changes via simple properties.
*   **The Workaround:** Use `nwg::RichLabel` (requires the `rich-textbox` feature). You must apply the color programmatically in the `OnInit` event handler using `set_char_format`.
    ```rust
    // In struct:
    #[nwg_control(text: "My Colored Text")]
    my_label: nwg::RichLabel,

    // In OnInit handler:
    self.my_label.set_char_format(0..self.my_label.len(), &nwg::CharFormat {
        text_color: Some([0, 128, 0]), // RGB Array
        ..Default::default()
    });
    ```

### Problem 2: Background Colors on Labels
*   **The Trap:** Trying to use RichLabel for background colors.
*   **The Workaround:** Standard `nwg::Label` *does* support `background_color` directly in the derive macro.
    ```rust
    #[nwg_control(text: "Status", background_color: Some([0, 128, 0]))]
    status_label: nwg::Label,
    ```

### Problem 3: Password Masking and Toggling
*   **The Trap:** Looking for a specific `PasswordInput` control.
*   **The Workaround:** Use `nwg::TextInput` and utilize the `password` attribute. To toggle visibility at runtime, pass `Some('•')` or `None` to `set_password_char()`.
    ```rust
    // To mask:
    self.my_input.set_password_char(Some('•'));
    // To unmask:
    self.my_input.set_password_char(None);
    ```

### Problem 4: Infinite Event Loops (The "Syncing" Problem)
*   **The Trap:** When you have two controls that must mirror each other (e.g., two `ListBox` controls where clicking one selects the corresponding item in the other). 
    *   Clicking List A fires `OnListBoxSelect`.
    *   The handler updates List B.
    *   Updating List B programmatically fires List B's `OnListBoxSelect`.
    *   List B's handler updates List A... resulting in a stack overflow/infinite loop.
*   **The Workaround:** Use a recursion guard via `RefCell<bool>`.
    ```rust
    // In struct:
    is_syncing: RefCell<bool>,

    // In handler:
    fn sync_lists(&self) {
        if *self.is_syncing.borrow() { return; } // Break recursion
        
        *self.is_syncing.borrow_mut() = true;    // Lock
        self.list_b.set_selection(self.list_a.selection());
        *self.is_syncing.borrow_mut() = false;   // Unlock
    }
    ```

## Phase 5: State Management & Event Handlers

Because NWG event handlers take `&self` (an immutable reference to the UI struct), you cannot mutate standard struct fields directly.

**Things to Avoid:**
*   Do not use `&mut self` in your event handler definitions. The NWG event loop does not support it.
*   Do not use standard `Mutex` or `RwLock` unless you are actually doing multithreading. Single-threaded GUI state should use `RefCell`.

**Best Practice:**
Wrap all mutable application state in `std::cell::RefCell`.
```rust
struct MyApp {
    // UI components...
    counter: std::cell::RefCell<u32>,
}

impl MyApp {
    fn on_button_click(&self) {
        let mut count = self.counter.borrow_mut();
        *count += 1;
        self.my_label.set_text(&format!("Count: {}", count));
    }
}
```

## Final Checklist for AI
When generating an NWG application:
1. Did I include `#![windows_subsystem = "windows"]` at the top of `main.rs` to hide the console?
2. Did I include the necessary features in the `Cargo.toml` dependency block?
3. Did I reference resources (like fonts) correctly using `&data.font_name` in the `nwg_control` macro?
4. Did I use `RefCell` for any state that changes at runtime?
5. Did I hook up the `OnWindowClose` event to `nwg::stop_thread_dispatch()` so the app actually exits?

