---
name: data-conversions-complex-logic
description: Create zig 0.16 std project that has data conversion functions and reference algorithms for device <device>
---

# Context Variables

<original_pwd>: run pwd, this is <original_pwd>
<artifacts_dir>: directory is <original_pwd>/artifacts/<device>/prompt0b, you will need to create this.
<spec>: <original_pwd>/artifacts/<device>/prompt0/<device>.md
<feedback_dir>: <original_pwd>/feedback/<device>, you will need to create this
<feedback_file>: <feedback_dir>/prompt0b.md

# create zig 0.16 std project

run the following from <artifacts_dir>

zig init

# edit main zig file

read <spec> and where there are:
1.  data conversions happening eg. from register values to 
real-world values
2. complex logic such as calculating crc values or other algorithms 

then create seperate functions in the main zig file and accompany them 
with unit tests.

# zig build

verify correctness with zig build.

### Step 4: Feedback
 
Before finishing, write a doc called `<feedback_file>` 
for comments about this skill 
including obstacles 
