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


## 2. API & Widget Reference
You do not have the source code, so you MUST rely on this reference for valid NWG types and events.

### A. Controls (Requires `#[nwg_control(...)]`)
*   **Windows:** `Window`, `MessageWindow`
*   **Containers:** `Frame`, `TabsContainer`, `Tab`
*   **Buttons:** `Button`, `CheckBox`, `RadioButton`
*   **Text:** `Label`, `TextInput` (single-line), `TextBox` (multi-line), `RichLabel`, `RichTextBox`
*   **Lists/Choices:** `ComboBox<T>`, `ListBox<T>`, `ListView`, `TreeView`
*   **Visual/Feedback:** `ImageFrame`, `ProgressBar`, `TrackBar`, `StatusBar`, `Tooltip`
*   **Input:** `DatePicker`, `MonthCalendar`, `NumberSelect`, `TrackBar`
*   **Menus:** `Menu`, `MenuItem`, `MenuSeparator`
*   **Other:** `TrayNotification`, `AnimationTimer`, `Notice`

### B. Resources (Requires `#[nwg_resource(...)]`)
*   `Font` (attrs: `family`, `size`, `weight`)
*   `Icon`, `Bitmap`, `Cursor` (attrs: `source_file`, `source_bin`)
*   `FileDialog` (attrs: `title`, `action`, `filters`)
*   `ColorDialog`, `FontDialog`
*   `ImageList` (attrs: `size`)

### C. Layouts (Requires `#[nwg_layout(...)]`)
*   `GridLayout` (attrs: `parent`, `margin`, `spacing`, `max_column`, `max_row`)
    *   Items use: `#[nwg_layout_item(layout: grid, col: 0, row: 0, col_span: 1, row_span: 1)]`
*   `FlexboxLayout` (attrs: `parent`, `flex_direction`, `padding`, `justify_content`)
    *   Items use: `#[nwg_layout_item(layout: flex, size: Size { width: D::Auto, height: D::Points(30.0) })]`

### D. Common Events (Used in `#[nwg_events(...)]`)
*   **Lifecycle:** `OnInit`, `OnWindowClose`, `OnResize`
*   **Mouse:** `OnMousePress`, `OnMouseMove`, `OnMouseWheel`, `OnContextMenu`
*   **Keyboard:** `OnKeyPress`, `OnKeyRelease`, `OnChar`, `OnKeyEnter`, `OnKeyEsc`
*   **Interactions:** `OnButtonClick`, `OnButtonDoubleClick`, `OnLabelClick`, `OnTextInput`
*   **Lists:** `OnComboBoxClosed`, `OnComboxBoxSelection`, `OnListBoxSelect`, `OnListBoxDoubleClick`, `OnListViewItemChanged`, `OnTreeViewClick`
*   **Other:** `OnTimerTick`, `OnNotice`, `OnMenuItemSelected`, `OnFileDrop`

### E. Callback Arguments Syntax
If your handler needs context, use these exact keywords in the macro: `(SELF, RC_SELF, CTRL, HANDLE, EVT, EVT_DATA)`.
*   Example: `OnButtonClick: [MyApp::my_func(SELF, CTRL)]` maps to `fn my_func(&self, ctrl: &nwg::Button)`.

## 3. Common Pitfalls & Workarounds
*   **Colored Text:** Standard `nwg::Label` cannot change text color via macros. **Workaround:** Use `nwg::RichLabel` and set the color programmatically in the `OnInit` event handler using `self.my_label.set_char_format(0..self.my_label.len(), &nwg::CharFormat { text_color: Some([R, G, B]), ..Default::default() })`.
*   **Colored Backgrounds:** Standard `nwg::Label` *does* support `background_color: Some([R, G, B])` in the derive macro.
*   **Password Masking:** Use `nwg::TextInput`. To mask, use `password: Some('•')`. To toggle visibility at runtime, call `self.my_input.set_password_char(None)` or `Some('•')`.
*   **Infinite Event Loops:** When syncing two controls (e.g., two ListBoxes that mirror selections), updating one programmatically triggers its event handler, creating an infinite loop. **Workaround:** Use an `is_syncing: RefCell<bool>` flag to break the recursion.

