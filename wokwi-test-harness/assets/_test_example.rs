use qa_test::assert_serial;
use std::time::Duration;

// Note: Ensure tests run sequentially using `cargo test -- --test-threads=1` 
// to prevent Wokwi TCP stream overlap.

#[test]
fn test_01_sht31_initialization() {
    // 1. Verify VDD power-up and I2C address discovery
    assert_serial!("Probing I2C bus...");
    assert_serial!("Found device at address 0x44");

    // 2. Verify Soft Reset sequence (Command: 0x30A2)
    assert_serial!("Sending Soft Reset (0x30A2)");
    assert_serial!("SHT31: Reset complete, returning to idle");
}

#[test]
fn test_02_single_shot_measurement() {
    // 1. Send High Repeatability, Clock Stretching Disabled (Command: 0x2400)
    assert_serial!("Sending single-shot command: 0x2400");
    
    // 2. Verify the firmware waits for the required tMEAS 
    assert_serial!("Waiting 15ms for acquisition...");

    // 3. Verify output calculation (assuming Wokwi returns a baseline ambient reading)
    assert_serial!("Temperature: 25.0 °C");
    assert_serial!("Humidity: 50.0 %RH");
}

#[test]
fn test_03_periodic_measurement_mode() {
    // 1. Start periodic mode: Medium repeatability, 2 mps (Command: 0x2220)
    assert_serial!("Configuring periodic mode (0x2220) at 2 mps");

    // 2. Fetch data (Command: 0xE000)
    assert_serial!("Fetching periodic data (0xE000)");
    assert_serial!("Periodic Reading: T=");
    
    // 3. Wait for the next cycle (2 mps = 500ms period). We use an 800ms timeout.
    let fetch_timeout = Duration::from_millis(800);
    assert_serial!("Fetching periodic data (0xE000)", fetch_timeout);
    assert_serial!("Periodic Reading: RH=", fetch_timeout);

    // 4. Stop periodic acquisition with Break command (Command: 0x3093)
    assert_serial!("Sending Break command (0x3093)");
}
