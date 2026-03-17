#![windows_subsystem = "windows"]

extern crate native_windows_gui as nwg;
extern crate native_windows_derive as nwd;

use nwd::NwgUi;
use nwg::NativeUi;
use std::cell::RefCell;

#[derive(Default, NwgUi)]
pub struct MqttKeyboardApp {
    #[nwg_control(size: (850, 480), position: (300, 300), title: "MQTT Keyboard", flags: "WINDOW|VISIBLE")]
    #[nwg_events( OnWindowClose:[nwg::stop_thread_dispatch()], OnInit: [MqttKeyboardApp::on_init] )]
    window: nwg::Window,

    // --- Resources ---
    #[nwg_resource(family: "Segoe UI", size: 15)]
    font_normal: nwg::Font,

    #[nwg_resource(family: "Segoe UI", size: 15, weight: 700)]
    font_bold: nwg::Font,

    #[nwg_resource(family: "Segoe UI", size: 17)]
    font_large: nwg::Font,

    #[nwg_layout(parent: window, margin:[10, 10, 10, 10], spacing: 5)]
    grid: nwg::GridLayout,

    // --- Menu Bar ---
    #[nwg_control(parent: window, text: "&File")]
    menu_file: nwg::Menu,

    #[nwg_control(parent: window, text: "&Help")]
    menu_help: nwg::Menu,

    #[nwg_control(parent: window, text: "&About")]
    menu_about: nwg::Menu,

    // --- Top Left Section (App Launching) ---
    #[nwg_control(text: "Broker", font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 0, row: 0)]
    lbl_broker_left: nwg::Label,

    #[nwg_control(text: "Launching: C:\\Program Files\\GIMP 3\\bin\\gimp-3.exe", font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 1, row: 0, col_span: 3)]
    txt_broker_left: nwg::TextInput,

    #[nwg_control(text: "Topic", font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 0, row: 1)]
    lbl_topic_left: nwg::Label,

    #[nwg_control(text: "Topic: [launch_app]", font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 1, row: 1, col_span: 3)]
    txt_topic_left: nwg::TextInput,

    #[nwg_control(text: "Payload", font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 0, row: 2)]
    lbl_payload_left: nwg::Label,

    #[nwg_control(text: "Payload: [GIMP3]", font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 1, row: 2, col_span: 3)]
    txt_payload_left: nwg::TextInput,


    // --- Top Right Section (MQTT Connection) ---
    #[nwg_control(text: "MQTT Connection", font: Some(&data.font_bold))]
    #[nwg_layout_item(layout: grid, col: 4, row: 0, col_span: 2)]
    lbl_mqtt_conn: nwg::Label,

    #[nwg_control(text: "Broker", font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 4, row: 1)]
    lbl_mqtt_broker: nwg::Label,

    #[nwg_control(text: "192.168.1.55", font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 5, row: 1)]
    val_mqtt_broker: nwg::Label,

    #[nwg_control(text: "Port", font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 4, row: 2)]
    lbl_mqtt_port: nwg::Label,

    #[nwg_control(text: "1883", font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 5, row: 2)]
    val_mqtt_port: nwg::Label,

    #[nwg_control(text: "Topic", font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 4, row: 3)]
    lbl_mqtt_topic: nwg::Label,

    #[nwg_control(text: "keyboard_command", font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 5, row: 3)]
    val_mqtt_topic: nwg::Label,

    #[nwg_control(text: "User Name", font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 4, row: 4)]
    lbl_mqtt_user: nwg::Label,

    #[nwg_control(text: "mqtt-user", font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 5, row: 4)]
    val_mqtt_user: nwg::Label,

    #[nwg_control(text: "Password", font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 4, row: 5)]
    lbl_mqtt_pass: nwg::Label,

    #[nwg_control(text: "password", password: Some('•'), font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 5, row: 5)]
    txt_mqtt_pass: nwg::TextInput,

    // Simulated "Connected" status block with green background
    #[nwg_control(text: "Connected", h_align: nwg::HTextAlign::Center, v_align: nwg::VTextAlign::Center, background_color: Some([0, 128, 0]), font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 4, row: 6)]
    lbl_connected: nwg::Label,

    #[nwg_control(text: "Show Password", font: Some(&data.font_normal))]
    #[nwg_events(OnButtonClick:[MqttKeyboardApp::toggle_password])]
    #[nwg_layout_item(layout: grid, col: 5, row: 6)]
    chk_show_pass: nwg::CheckBox,

    #[nwg_control(text: "Apps         15", font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 5, row: 7)]
    lbl_apps: nwg::Label,


    // --- Bottom Section (Program Reference) ---
    // Using RichLabel allows us to set the custom green color for the text
    #[nwg_control(text: "Program Reference", font: Some(&data.font_large))]
    #[nwg_layout_item(layout: grid, col: 0, row: 8, col_span: 6)]
    lbl_prog_ref: nwg::RichLabel,

    #[nwg_control(font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 0, row: 9, col_span: 2, row_span: 6)]
    #[nwg_events(OnListBoxSelect: [MqttKeyboardApp::sync_left_list])]
    list_programs: nwg::ListBox<String>,

    #[nwg_control(font: Some(&data.font_normal))]
    #[nwg_layout_item(layout: grid, col: 2, row: 9, col_span: 4, row_span: 6)]
    #[nwg_events(OnListBoxSelect:[MqttKeyboardApp::sync_right_list])]
    list_paths: nwg::ListBox<String>,

    // State lock to prevent infinite recursion when syncing the two ListBoxes
    is_syncing: RefCell<bool>,
}

impl MqttKeyboardApp {
    fn on_init(&self) {
        // Set the "Program Reference" text to green
        self.lbl_prog_ref.set_char_format(0..17, &nwg::CharFormat {
            text_color: Some([0, 128, 0]),
            ..Default::default()
        });

        // Initialize the app names
        let programs = vec![
            "DaVinci Resolve",
            "Fusion 360",
            "EasyEDA",
            "GIMP3",
            "Microsoft VS Code",
            "Creality Print 7.0",
            "WORD",
            "EXCEL",
            "OUTLOOK",
            "Sweet Home 3D",
            "Visual Studio",
            "Netlinx",
        ];
        
        // Initialize the app paths
        let paths = vec![
            "C:\\Program Files\\Blackmagic Design\\DaVinci Resolve\\Resolve.exe",
            "C:\\Users\\cs_ha\\AppData\\Local\\Autodesk\\webdeploy\\production\\6a0c9611291d45bb9226980...",
            "C:\\Program Files\\EasyEDA\\easyeda.exe",
            "C:\\Program Files\\GIMP 3\\bin\\gimp-3.exe",
            "C:\\Users\\cs_ha\\AppData\\Local\\Programs\\Microsoft VS Code\\Code.exe",
            "C:\\Program Files\\Creality\\Creality Print 7.0\\CrealityPrint.exe",
            "C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE",
            "C:\\Program Files\\Microsoft Office\\root\\Office16\\EXCEL.EXE",
            "C:\\Program Files\\Microsoft Office\\root\\Office16\\OUTLOOK.EXE",
            "C:\\Program Files\\Sweet Home 3D\\SweetHome3D.exe",
            "C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\Common7\\IDE\\devenv.exe",
            "C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\AMX Control Disc\\NetLinx Studio 4",
        ];

        self.list_programs.set_collection(programs.into_iter().map(String::from).collect());
        self.list_paths.set_collection(paths.into_iter().map(String::from).collect());

        // Default selection matching the screenshot ("WORD")
        self.list_programs.set_selection(Some(6));
        self.list_paths.set_selection(Some(6));
    }

    /// Toggles the password field masking
    fn toggle_password(&self) {
        if self.chk_show_pass.check_state() == nwg::CheckBoxState::Checked {
            self.txt_mqtt_pass.set_password_char(None);
        } else {
            self.txt_mqtt_pass.set_password_char(Some('•'));
        }
    }

    /// Selecting an item in the left list updates the right list
    fn sync_left_list(&self) {
        if *self.is_syncing.borrow() { return; }
        *self.is_syncing.borrow_mut() = true;
        
        self.list_paths.set_selection(self.list_programs.selection());
        
        *self.is_syncing.borrow_mut() = false;
    }

    /// Selecting an item in the right list updates the left list
    fn sync_right_list(&self) {
        if *self.is_syncing.borrow() { return; }
        *self.is_syncing.borrow_mut() = true;
        
        self.list_programs.set_selection(self.list_paths.selection());
        
        *self.is_syncing.borrow_mut() = false;
    }
}

fn main() {
    nwg::init().expect("Failed to init Native Windows GUI");
    nwg::Font::set_global_family("Segoe UI").expect("Failed to set default font");

    let _app = MqttKeyboardApp::build_ui(Default::default()).expect("Failed to build UI");

    nwg::dispatch_thread_events();
}
