#!/usr/bin/env python3
"""
generate_diff.py
Generates a unified git diff to add a new device to the espforge framework.

Usage:
  python3 scripts/generate_diff.py \
    --device ds18b20 \
    --crate  ds18b20 \
    --version 0.2.0 \
    --bus    gpio \
    --espforge-root ~/.picoclaw/workspace/assets/espforge

Bus types:
  i2c        Device takes a single I2C component reference.
  spi        Device takes a single SPI component reference.
  gpio       Device takes GPIO pin references only.
  spi+gpio   Device takes SPI component + extra GPIO control pins (e.g. DC, RST, CS).
  i2c+gpio   Device takes I2C component + extra GPIO pins.

IMPORTANT: Cargo.toml crate names may contain hyphens (e.g. bmp085-180-rs), but Rust
`use` statements require underscores (bmp085_180_rs).  This script handles the conversion
automatically: --crate accepts the crates.io name; {rust_crate_name} is the Rust identifier.
"""

import argparse
import os
import sys
from pathlib import Path
from datetime import datetime

# ---------------------------------------------------------------------------
# Templates
# NOTE: {crate_name}      = the crates.io name, used in Cargo.toml (hyphens OK)
#       {rust_crate_name} = Rust identifier form, used in `use` stmts (hyphens → _)
# ---------------------------------------------------------------------------

DEVICE_RS_I2C = '''\
use embedded_hal::i2c::I2c;
use {rust_crate_name}::{DeviceStruct};

pub struct {PascalName}Device<I> {{
    inner: {DeviceStruct}<I>,
}}

impl<I: I2c> {PascalName}Device<I> {{
    pub fn new(i2c: I) -> Self {{
        Self {{
            inner: {DeviceStruct}::new(i2c),
        }}
    }}

    pub fn init(&mut self) -> Result<(), I::Error> {{
        self.inner.init()
    }}

    // TODO: add device-specific methods here
}}
'''

DEVICE_RS_SPI = '''\
use embedded_hal::spi::SpiDevice;
use {rust_crate_name}::{DeviceStruct};

pub struct {PascalName}Device<SPI> {{
    inner: {DeviceStruct}<SPI>,
}}

impl<SPI: SpiDevice> {PascalName}Device<SPI> {{
    pub fn new(spi: SPI) -> Self {{
        Self {{
            inner: {DeviceStruct}::new(spi),
        }}
    }}

    pub fn init(&mut self) -> Result<(), SPI::Error> {{
        self.inner.init()
    }}

    // TODO: add device-specific methods here
}}
'''

DEVICE_RS_SPI_GPIO = '''\
use embedded_hal::{{digital::OutputPin, spi::SpiDevice}};
use {rust_crate_name}::{DeviceStruct};

pub struct {PascalName}Device<SPI, DC, RST> {{
    inner: {DeviceStruct}<SPI, DC, RST>,
}}

impl<SPI: SpiDevice, DC: OutputPin, RST: OutputPin> {PascalName}Device<SPI, DC, RST> {{
    pub fn new(spi: SPI, dc: DC, rst: RST) -> Self {{
        Self {{
            inner: {DeviceStruct}::new(spi, dc, rst),
        }}
    }}

    pub fn init(&mut self) {{
        // TODO: call inner init
    }}

    // TODO: add device-specific methods here
}}
'''

MOD_RS = 'pub mod device;\n'

# Builder templates use the pattern documented in DEVELOPER_GUIDE.md:
#   - No `config = "..."` attribute on #[plugin(...)].
#   - Methods take raw `&serde_yaml_ng::Value` or `&GenerationContext`; parse typed
#     config internally.  Method names must match what the macro generates:
#       validate_properties / resolve_dependencies / generate_code
#
# This is consistent with the espforge macro's default delegation (no typed config).

BUILDER_I2C = '''\
use anyhow::{{Context, Result}};
use espforge_configuration::plugin::{{
    Dependency, DependencyKind, GeneratedCode, GenerationContext,
}};
use espforge_configuration::refs::{{ComponentRef, DeviceRef}};
use espforge_macros::DevicePlugin;
use quote::{{format_ident, quote}};
use serde::Deserialize;

#[derive(Deserialize, Debug, Clone)]
pub struct {PascalName}Config {{
    pub component: DeviceRef<ComponentRef>,
    // TODO: remove this field if the device has a fixed I2C address baked into the driver.
    // If the driver constructor accepts an address argument, pass `address` in the init
    // block below (see the commented-out line).
    pub address: Option<u8>,
}}

fn parse_config(value: &serde_yaml_ng::Value) -> Result<{PascalName}Config> {{
    serde_yaml_ng::from_value(value.clone()).context("Invalid {PascalName} configuration")
}}

#[derive(DevicePlugin)]
#[plugin(name = "{device_name}", features = "{device_name}")]
pub struct {PascalName}Plugin;

impl {PascalName}Plugin {{
    fn validate_properties(&self, properties: &serde_yaml_ng::Value) -> Result<()> {{
        parse_config(properties)?;
        Ok(())
    }}

    fn resolve_dependencies(&self, properties: &serde_yaml_ng::Value) -> Result<Vec<Dependency>> {{
        let config = parse_config(properties)?;
        Ok(vec![Dependency::component(config.component.as_str())])
    }}

    fn generate_code(&self, ctx: &GenerationContext) -> Result<GeneratedCode> {{
        let config = parse_config(ctx.properties)?;
        let field_ident = format_ident!("{{}}", ctx.instance_name);
        let i2c_access =
            ctx.dependency_access(config.component.as_str(), DependencyKind::Component)?;
        // TODO: use this if the driver constructor accepts an address argument.
        // If the driver has a fixed address, delete these two lines.
        let address = config.address.unwrap_or(0x00_u8);
        let _ = address; // suppress unused-variable warning until wired in below

        let field = quote! {{
            pub #field_ident: espforge_devices::devices::{device_name}::device::{PascalName}Device<
                espforge_platform::bus::I2cDevice<\'static>,
            >
        }};

        let init = quote! {{
            let #field_ident = espforge_devices::devices::{device_name}::device::{PascalName}Device::new(
                espforge_platform::bus::I2cDevice::new(&#i2c_access),
                // TODO: pass address here if the constructor requires it, e.g.:
                // #address,
            );
        }};

        Ok(espforge_configuration::plugin::GeneratedCode::codegen(
            ctx.instance_name,
            field,
            init,
        ))
    }}
}}
'''

BUILDER_SPI = '''\
use anyhow::{{Context, Result}};
use espforge_configuration::plugin::{{
    Dependency, DependencyKind, GeneratedCode, GenerationContext,
}};
use espforge_configuration::refs::{{ComponentRef, DeviceRef}};
use espforge_macros::DevicePlugin;
use quote::{{format_ident, quote}};
use serde::Deserialize;

#[derive(Deserialize, Debug, Clone)]
pub struct {PascalName}Config {{
    pub component: DeviceRef<ComponentRef>,
}}

fn parse_config(value: &serde_yaml_ng::Value) -> Result<{PascalName}Config> {{
    serde_yaml_ng::from_value(value.clone()).context("Invalid {PascalName} configuration")
}}

#[derive(DevicePlugin)]
#[plugin(name = "{device_name}", features = "{device_name}")]
pub struct {PascalName}Plugin;

impl {PascalName}Plugin {{
    fn validate_properties(&self, properties: &serde_yaml_ng::Value) -> Result<()> {{
        parse_config(properties)?;
        Ok(())
    }}

    fn resolve_dependencies(&self, properties: &serde_yaml_ng::Value) -> Result<Vec<Dependency>> {{
        let config = parse_config(properties)?;
        Ok(vec![Dependency::component(config.component.as_str())])
    }}

    fn generate_code(&self, ctx: &GenerationContext) -> Result<GeneratedCode> {{
        let config = parse_config(ctx.properties)?;
        let field_ident = format_ident!("{{}}", ctx.instance_name);
        let spi_access =
            ctx.dependency_access(config.component.as_str(), DependencyKind::Component)?;

        let field = quote! {{
            pub #field_ident: espforge_devices::devices::{device_name}::device::{PascalName}Device<
                espforge_platform::bus::SpiDevice<\'static>,
            >
        }};

        let init = quote! {{
            let #field_ident = espforge_devices::devices::{device_name}::device::{PascalName}Device::new(
                #spi_access,
            );
        }};

        Ok(espforge_configuration::plugin::GeneratedCode::codegen(
            ctx.instance_name,
            field,
            init,
        ))
    }}
}}
'''

# ---------------------------------------------------------------------------
# Diff helpers
# ---------------------------------------------------------------------------

def make_diff_add_file(repo_root: Path, rel_path: str, content: str) -> str:
    """Produce a unified diff chunk for a brand-new file."""
    lines = content.splitlines(keepends=True)
    header = (
        f"diff --git a/{rel_path} b/{rel_path}\n"
        f"new file mode 100644\n"
        f"index 0000000..aaaaaaa\n"
        f"--- /dev/null\n"
        f"+++ b/{rel_path}\n"
        f"@@ -0,0 +1,{len(lines)} @@\n"
    )
    body = "".join(f"+{l}" for l in lines)
    return header + body + "\n"


def make_diff_patch_file(repo_root: Path, rel_path: str, old_content: str, new_content: str) -> str:
    """Produce a unified diff chunk for a modified file using difflib."""
    import difflib
    old_lines = old_content.splitlines(keepends=True)
    new_lines = new_content.splitlines(keepends=True)
    diff = list(difflib.unified_diff(
        old_lines, new_lines,
        fromfile=f"a/{rel_path}",
        tofile=f"b/{rel_path}",
    ))
    if not diff:
        return ""
    header = f"diff --git a/{rel_path} b/{rel_path}\n"
    return header + "".join(diff) + "\n"


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def pascal(name: str) -> str:
    return "".join(p.capitalize() for p in name.replace("-", "_").split("_"))


def to_rust_ident(crate_name: str) -> str:
    """Convert a crates.io crate name to a valid Rust identifier.

    Cargo.toml allows hyphens in crate names, but Rust `use` statements
    require underscores.  e.g. 'bmp085-180-rs' -> 'bmp085_180_rs'.
    """
    return crate_name.replace("-", "_")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Generate espforge device git diff")
    parser.add_argument("--device",         required=True, help="Device name, e.g. ds18b20")
    parser.add_argument("--crate",          required=True,
                        help="Rust crate name on crates.io, e.g. ds18b20 or bmp085-180-rs")
    parser.add_argument("--version",        required=True, help="Crate version, e.g. 0.2.0")
    parser.add_argument("--bus",            required=True,
                        choices=["i2c", "spi", "gpio", "spi+gpio", "i2c+gpio"],
                        help="Bus type used by the device")
    parser.add_argument("--device-struct",  default=None,
                        help="Rust struct name exported by the crate, e.g. Ds18b20 "
                             "(default: PascalCase of --device). "
                             "Check docs.rs/<crate> if unsure.")
    parser.add_argument("--espforge-root",  default="~/.picoclaw/workspace/assets/espforge",
                        help="Path to local espforge clone")
    parser.add_argument("--output-dir",     default="~/.picoclaw/workspace/outputs",
                        help="Directory to write the .patch file")
    args = parser.parse_args()

    device          = args.device.lower().replace("-", "_")
    crate_name      = args.crate                        # crates.io / Cargo.toml form
    rust_crate_name = to_rust_ident(crate_name)         # Rust `use` form
    version         = args.version
    bus             = args.bus
    pascal_name     = pascal(device)
    dev_struct      = args.device_struct or pascal_name
    repo_root       = Path(os.path.expanduser(args.espforge_root))
    out_dir         = Path(os.path.expanduser(args.output_dir))
    out_dir.mkdir(parents=True, exist_ok=True)

    if not repo_root.exists():
        sys.exit(
            f"ERROR: espforge repo not found at {repo_root}.\n"
            f"Run scripts/clone_espforge.sh first."
        )

    # Warn when crate name and Rust identifier differ
    if crate_name != rust_crate_name:
        print(
            f"NOTE: crate name '{crate_name}' contains hyphens; "
            f"Rust `use` statements will use '{rust_crate_name}'."
        )

    chunks = []

    # -----------------------------------------------------------------------
    # 1. espforge_devices/src/devices/<device>/device.rs  (new file)
    # -----------------------------------------------------------------------
    if bus in ("i2c", "i2c+gpio"):
        tmpl = DEVICE_RS_I2C
    elif bus == "spi+gpio":
        tmpl = DEVICE_RS_SPI_GPIO
    else:
        tmpl = DEVICE_RS_SPI

    device_rs = tmpl.format(
        crate_name=crate_name,
        rust_crate_name=rust_crate_name,
        DeviceStruct=dev_struct,
        PascalName=pascal_name,
    )
    chunks.append(make_diff_add_file(
        repo_root,
        f"espforge_devices/src/devices/{device}/device.rs",
        device_rs,
    ))

    # -----------------------------------------------------------------------
    # 2. espforge_devices/src/devices/<device>/mod.rs  (new file)
    # -----------------------------------------------------------------------
    chunks.append(make_diff_add_file(
        repo_root,
        f"espforge_devices/src/devices/{device}/mod.rs",
        MOD_RS,
    ))

    # -----------------------------------------------------------------------
    # 3. espforge_devices/src/devices/mod.rs  (patch – add pub mod <device>;)
    # -----------------------------------------------------------------------
    mod_rs_path = repo_root / "espforge_devices/src/devices/mod.rs"
    if mod_rs_path.exists():
        old_mod = mod_rs_path.read_text()
        feature_guard = (
            f'#[cfg(feature = "{device}")]\n'
            f'pub mod {device};\n'
        )
        if feature_guard not in old_mod:
            new_mod = old_mod.rstrip("\n") + "\n" + feature_guard
            chunks.append(make_diff_patch_file(
                repo_root,
                "espforge_devices/src/devices/mod.rs",
                old_mod,
                new_mod,
            ))

    # -----------------------------------------------------------------------
    # 4. espforge_devices/Cargo.toml  (patch – add dep + feature)
    #    crate_name (with hyphens) is the correct form for Cargo.toml.
    # -----------------------------------------------------------------------
    cargo_path = repo_root / "espforge_devices/Cargo.toml"
    if cargo_path.exists():
        old_cargo = cargo_path.read_text()
        dep_line     = f'{crate_name} = {{ version = "{version}", optional = true }}\n'
        feature_line = f'{device} = ["dep:{crate_name}"]\n'
        new_cargo = old_cargo
        if dep_line not in new_cargo:
            new_cargo = new_cargo.replace("[dependencies]\n", f"[dependencies]\n{dep_line}", 1)
        if feature_line not in new_cargo:
            new_cargo = new_cargo.replace("[features]\n", f"[features]\n{feature_line}", 1)
        if new_cargo != old_cargo:
            chunks.append(make_diff_patch_file(
                repo_root,
                "espforge_devices/Cargo.toml",
                old_cargo,
                new_cargo,
            ))

    # -----------------------------------------------------------------------
    # 5. espforge_devices_builder/src/<device>.rs  (new file)
    # -----------------------------------------------------------------------
    builder_tmpl = BUILDER_I2C if bus.startswith("i2c") else BUILDER_SPI
    builder_rs = builder_tmpl.format(
        device_name=device,
        PascalName=pascal_name,
        DeviceStruct=dev_struct,
        crate_name=crate_name,
        rust_crate_name=rust_crate_name,
    )
    chunks.append(make_diff_add_file(
        repo_root,
        f"espforge_devices_builder/src/{device}.rs",
        builder_rs,
    ))

    # -----------------------------------------------------------------------
    # 6. espforge_devices_builder/src/lib.rs  (patch – add pub mod)
    # -----------------------------------------------------------------------
    lib_path = repo_root / "espforge_devices_builder/src/lib.rs"
    if lib_path.exists():
        old_lib = lib_path.read_text()
        mod_line = f"pub mod {device};\n"
        if mod_line not in old_lib:
            new_lib = mod_line + old_lib
            chunks.append(make_diff_patch_file(
                repo_root,
                "espforge_devices_builder/src/lib.rs",
                old_lib,
                new_lib,
            ))

    # -----------------------------------------------------------------------
    # Write patch
    # -----------------------------------------------------------------------
    patch_path = out_dir / f"{device}_espforge.patch"
    header = (
        f"# Generated by espforge-devices skill\n"
        f"# Device          : {device}\n"
        f"# Crate (Cargo)   : {crate_name} v{version}\n"
        f"# Crate (Rust use): {rust_crate_name}\n"
        f"# Bus             : {bus}\n"
        f"# Date            : {datetime.utcnow().isoformat()}Z\n"
        f"#\n"
        f"# Apply with: git apply {device}_espforge.patch\n\n"
    )
    patch_content = header + "".join(chunks)
    patch_path.write_text(patch_content)

    print(f"\nPatch written to: {patch_path}")
    print(f"\nFiles changed:")
    for chunk in chunks:
        for line in chunk.splitlines():
            if line.startswith("diff --git"):
                print(" ", line.replace("diff --git ", "").split(" b/")[1])


if __name__ == "__main__":
    main()

