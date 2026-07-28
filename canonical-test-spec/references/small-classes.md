As of the current Home Assistant developer documentation (updated in 2026), the **sensor device classes** are: ([Home Assistant Developer Docs][1])

| Device Class                       | Typical Units                             |
| ---------------------------------- | ----------------------------------------- |
| `absolute_humidity`                | g/m³, mg/m³                               |
| `apparent_power`                   | VA, kVA, mVA                              |
| `aqi`                              | (unitless)                                |
| `area`                             | m², cm², km², ft², acres, ha, etc.        |
| `atmospheric_pressure`             | hPa, mbar, Pa, kPa, psi, mmHg, inHg, etc. |
| `battery`                          | %                                         |
| `blood_glucose_concentration`      | mg/dL, mmol/L                             |
| `co2`                              | ppm                                       |
| `co`                               | ppm, ppb, µg/m³, mg/m³                    |
| `conductivity`                     | S/cm, mS/cm, µS/cm                        |
| `current`                          | A, mA, µA                                 |
| `data_rate`                        | bit/s, B/s, kbit/s, MB/s, etc.            |
| `data_size`                        | B, kB, MB, GiB, etc.                      |
| `date`                             | date                                      |
| `distance`                         | mm, cm, m, km, in, ft, yd, mi, nmi        |
| `duration`                         | µs, ms, s, min, h, d                      |
| `energy`                           | Wh, kWh, J, MJ, kcal, etc.                |
| `energy_distance`                  | Wh/km, kWh/100km, mi/kWh                  |
| `energy_storage`                   | Wh, kWh, J, etc.                          |
| `enum`                             | enumerated values                         |
| `frequency`                        | Hz, kHz, MHz, GHz                         |
| `gas`                              | L, m³, ft³, CCF, MCF                      |
| `humidity`                         | %                                         |
| `illuminance`                      | lux                                       |
| `irradiance`                       | W/m²                                      |
| `moisture`                         | %                                         |
| `monetary`                         | ISO 4217 currency                         |
| `sulphur_dioxide`                  | ppb, µg/m³                                |
| `temperature`                      | °C, °F, K                                 |
| `temperature_delta`                | °C, °F, K                                 |
| `timestamp`                        | datetime                                  |
| `uptime`                           | datetime                                  |
| `volatile_organic_compounds`       | µg/m³, mg/m³                              |
| `volatile_organic_compounds_parts` | ppm, ppb                                  |
| `voltage`                          | V, mV, µV, kV                             |
| `volume`                           | L, m³, gal, etc.                          |
| `volume_flow_rate`                 | L/s, L/min, m³/h, etc.                    |
| `volume_storage`                   | L, m³, gal, etc.                          |
| `water`                            | L, gal, m³                                |
| `weight`                           | kg, g, mg, lb, oz, st                     |
| `wind_speed`                       | m/s, km/h, mph, kn                        |
| `speed`                            | m/s, km/h, mph, kn                        |
| `power`                            | W, kW, MW                                 |
| `power_factor`                     | % or ratio                                |
| `ph`                               | pH                                        |
| `ozone`                            | µg/m³, ppb                                |
| `nitrogen_dioxide`                 | µg/m³, ppb                                |
| `nitrogen_monoxide`                | µg/m³, ppb                                |
| `nitrous_oxide`                    | µg/m³, ppb                                |
| `pm1`                              | µg/m³                                     |
| `pm10`                             | µg/m³                                     |
| `pm25`                             | µg/m³                                     |
| `precipitation`                    | mm, cm, in                                |
| `precipitation_intensity`          | mm/h, in/h                                |
| `signal_strength`                  | dBm                                       |
| `sound_pressure`                   | dB, dBA                                   |
| `speed`                            | m/s, km/h, mph                            |
| `volatile_organic_compounds_parts` | ppm, ppb                                  |

The official reference is the Home Assistant developer documentation for sensor entities, which is the authoritative source for supported sensor device classes. ([Home Assistant Developer Docs][1])

## For your project

I actually **wouldn't use this list directly** as your capability registry.

Instead, I'd derive a smaller **Canonical Capability Registry** from it. Home Assistant includes many classes that aren't relevant to hardware chip smoke tests, such as:

* `monetary`
* `blood_glucose_concentration`
* `date`
* `timestamp`
* `enum`
* `energy_distance`
* `area`

For Wokwi custom chips and embedded sensors, you'll probably end up with a focused set of around **25–40 canonical capabilities**, for example:

* temperature
* humidity
* pressure
* co2
* co
* voc
* pm1
* pm25
* pm10
* illuminance
* uv_index
* proximity
* distance
* acceleration
* angular_velocity
* magnetic_field
* orientation
* voltage
* current
* power
* energy
* frequency
* resistance
* conductivity
* ph
* moisture
* flow_rate
* liquid_level
* sound_pressure
* gas_concentration
* battery
* signal_strength

That registry is small enough to maintain manually, while still covering the vast majority of sensors supported by ESPHome and commonly used in embedded development. It also provides a stable vocabulary for your Canonical Test Specification without inheriting every specialized device class from Home Assistant.

[1]: https://developers.home-assistant.io/docs/core/entity/sensor/?utm_source=chatgpt.com "Sensor entity | Home Assistant Developer Docs"
