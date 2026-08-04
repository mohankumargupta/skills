use std::cell::RefCell;
use std::io::{BufRead, BufReader};
use std::net::TcpStream;
use std::time::{Duration, Instant};

const DEFAULT_TIMEOUT: Duration = Duration::from_secs(10);

thread_local! {
    static WOKWI_READER: RefCell<Option<BufReader<TcpStream>>> = const { RefCell::new(None) };
}

pub fn assert_serial_impl(expected: &str, timeout: Duration) {
    let start = Instant::now();
    let mut line = String::new();

    WOKWI_READER.with(|cell| {
        let mut binding = cell.borrow_mut();
        
        // 1. Lazy Initialization: If the connection doesn't exist yet, make it now!
        if binding.is_none() {
            let host = "127.0.0.1:4000";
            println!("Connecting to Wokwi simulator automatically...");
            let stream = TcpStream::connect(host).expect(
                "Timeout: Could not connect to Wokwi on port 4000. Did you start the simulator?"
            );
            stream.set_read_timeout(Some(Duration::from_secs(5))).unwrap();
            
            *binding = Some(BufReader::new(stream));
        }

        // Safely unwrap since we guaranteed it exists above
        let reader = binding.as_mut().unwrap();

        // 2. Stream Reading Logic
        loop {
            if start.elapsed() > timeout {
                panic!("Timeout: Did not find serial output '{}' within {:?}", expected, timeout);
            }

            line.clear();
            match reader.read_line(&mut line) {
                Ok(0) => panic!("Wokwi closed connection prematurely."),
                Ok(_) => {
                    let cleaned = line.trim();
                    println!("Wokwi: {}", cleaned);
                    if cleaned.contains(expected) {
                        println!("✅ Found: '{}'", expected);
                        break; 
                    }
                }
                Err(e) => panic!("Error reading stream: {}", e),
            }
        }
    });
}

#[macro_export]
macro_rules! assert_serial {
    ($expected:expr) => {
        $crate::assert_serial_impl($expected, DEFAULT_TIMEOUT);
    };
    ($expected:expr, $timeout:expr) => {
        $crate::assert_serial_impl($expected, $timeout);
    };
}
