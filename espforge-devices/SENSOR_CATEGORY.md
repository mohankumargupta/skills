# SKILL: Identify sensor category 

Given the <device> requested by user, return the device or sensor tier1 category.
This category is used when creating examples which gets put into a folder with the name of the tier1 category.

07.Environment (Atmospheric, Climate, Air Quality, Moisture)

08.Motion_Activity (Linear Motion, Rotational, Mechanical Stress/Vibration)

09.Vision_Light (Ambient, Spectral, Imaging, Active/ToF)

10.Touch_Presence (Capacitive/Resistive, Bio-Presence, Proximity)

11.Location_Tracking (Satellite, Magnetic, Relative Position/Encoders)

12.Sound_Hearing (Microphonic, Ultrasonic, Seismic)

13.Safety_Hazards (Combustion, Toxic Gas, Radiation)

14.Medical_Body (Vital Signs, Physiological/Biometric)

15.Force_Weight (Mass/Load, Strain, Tactile Pressure)

16.Fluid_Flow (Volume/Level, Velocity, Leak Detection)

17.Electrical_Power (Voltage/Current, Energy Consumption) 

18.Speciality(Other)

Create a document called <device>_category.md with the file_write tool with the following:

Response Template:

Sensor: [Model Name]
Tier 1 (Category): [Top-level Category]
Tier 2 (Sub-Group): [Functional Sub-group]
Primary Measurand: [The physical property it physically detects] vs. Derived Value [What the user actually sees]
Secondary/Bonus Measurand: [Internal temp, etc.]
Technology: [Wikipedia Link to the principle, e.g., Hall Effect, MEMS, Piezoelectric]
Interface: [Analog vs. Digital (I2C, SPI, UART)]
Layman Use: [1-sentence real-world example]
Fusion Clause: [List any secondary sensors or "hidden" features]

