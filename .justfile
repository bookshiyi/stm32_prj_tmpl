set windows-shell := ["cmd.exe", "/c"]

##############################################

alias s := setup
alias b := build
alias c := clean
alias r := rebuild
# alias s := scan
alias f := flash
alias a := attach
alias d := debug

##############################################

PROJECT := "daq_fw" # Change to your project name
MODE := "Debug" # [Debug] or [Release]
PROGRAMMER := "probe-rs" # [openocd] or [pyocd] or [probe-rs]
PYOCD_TARGET := "stm32f407vetx" # >pyocd list --targets
OPENOCD_INTERFACE := "interface/stlink.cfg" # stlink-dap.cfg,stlink.cfg,cmsis-dap.cfg # >ls /opt/homebrew/share/openocd/scripts/interface/
OPENOCD_TARGET := "target/stm32f4x.cfg" # >ls /opt/homebrew/share/openocd/scripts/target/
PROBE_RS_TARGET := "stm32f407vetx" # probe-rs chip list

##############################################

# 🛠️ Setup
setup:
    @echo 🛠️  Setting up...
    @cmake --preset {{ MODE }}
    @echo ✅  Setup done

# 📦 Build
build:
    @just setup
    @echo 📦  Building..
    @cmake --build --preset {{ MODE }}
    @echo ✅  Built done

##############################################

# 🧹 Clean
[unix]
clean:
    @echo 🧹  Cleaning...
    @-rm -rf build
    @echo ✅  Clean done

# 🧹 Clean
[windows]
clean:
    @echo 🧹  Cleaning...
    @-rmdir /s /q build
    @echo ✅  Clean done

# 🔄 Rebuild
rebuild: clean build

##############################################

# 🔍 Scan probes and targets
scan:
    @echo 🔍 Scaning...

    @echo 1. [pyOCD] ===========================
    @pyocd list # scan probes
    @pyocd reset -t {{ PYOCD_TARGET }} # scan targets

    @echo 2. [OpenOCD] =========================
    @openocd \
        -f {{ OPENOCD_INTERFACE }} \
        -f {{ OPENOCD_TARGET }} \
        -c "init; exit"

    @echo 3. [probe-rs]  ======================
    @probe-rs list # scan probes
    @probe-rs info \
         --protocol swd # scan targets

    @echo ✅  Scaned done

##############################################

# Flash by pyocd
_flash-pyocd:
    @pyocd flash \
        -f 4m \
        -e auto \
        --trust-crc \
        -t {{ PYOCD_TARGET }} \
        build/{{ MODE }}/{{ PROJECT }}.elf

# Flash by openocd
_flash-openocd:
    @openocd \
        -f {{ OPENOCD_INTERFACE }} \
        -f {{ OPENOCD_TARGET }} \
        -c "program build/{{ MODE }}/{{ PROJECT }}.elf verify reset exit"

# Flash by probe-rs
_flash-probe-rs:
    @probe-rs run \
        --chip {{ PROBE_RS_TARGET }} \
        --always-print-stacktrace \
        --preverify \
        build/{{ MODE }}/{{ PROJECT }}.elf

# ⚡️ Flash
flash:
    @just build
    @echo ⚡️  Flashing...
    @just _flash-{{ PROGRAMMER }}
    @echo ✅  Flash done

##############################################

# GDB Server by pyocd
_gdb-server-pyocd:
    @pyocd \
        gdbserver \
        -t {{ PYOCD_TARGET }}

# GDB Server by openocd
_gdb-server-openocd:
    @openocd \
        -f {{ OPENOCD_INTERFACE }} \
        -f {{ OPENOCD_TARGET }}

# GDB Server by probe-rs
_gdb-server-probe-rs:
    @probe-rs gdb \
        --chip {{ PROBE_RS_TARGET }} \
        --gdb-connection-string localhost:3333 \
        build/{{ MODE }}/{{ PROJECT }}.elf

# 🔗 Attach
attach:
    @echo 🎛️  GDB server starting...
    @echo ❗️❗️❗️ Please enter [quit/exit] in the GDB prompt to close the session
    @-kill -9 $(lsof -ti :3333) 2>/dev/null || true # kill gdbserver process
    @just _gdb-server-{{ PROGRAMMER }} & # background run
    @sleep 2
    @echo 🔗 Attaching...
    @arm-none-eabi-gdb \
        -q \
        -ex "target remote localhost:3333" \
        -ex "monitor reset" \
        -ex "break main" \
        build/{{ MODE }}/{{ PROJECT }}.elf
    @sleep 1
    @-kill -9 $(lsof -ti :3333) 2>/dev/null || true # kill gdbserver process
    @echo ✅  Session ended

##############################################

# 🐞Debug
debug:
    @just flash
    @just attach
