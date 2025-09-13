set windows-shell := ["cmd.exe", "/c"]

##############################################

alias s := setup
alias b := build
alias c := clean
alias r := rebuild
alias f := flash
alias a := attach
alias d := debug

##############################################

PROJECT := "daq_fw" # Change to your project name
MODE := "Debug" # [Debug] or [Release]
PROGRAMMER := "pyocd" # [openocd] or [pyocd]
PYOCD_TARGET := "stm32f407vetx" # >pyocd list --targets
OPENOCD_INTERFACE := "interface/stlink.cfg" # stlink-dap.cfg,stlink.cfg,cmsis-dap.cfg # >ls /opt/homebrew/share/openocd/scripts/interface/
OPENOCD_TARGET := "target/stm32f4x.cfg" # >ls /opt/homebrew/share/openocd/scripts/target/

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
