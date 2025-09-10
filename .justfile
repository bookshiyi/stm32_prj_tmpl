set windows-shell := ["cmd.exe", "/c"]

##############################################

alias s := setup
alias b := build
alias c := clean
alias r := rebuild
alias f := flash

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
    @pyocd flash -t {{ PYOCD_TARGET }} build/{{ MODE }}/{{ PROJECT }}.elf

# Flash by openocd
_flash-openocd:
    @openocd -f {{ OPENOCD_INTERFACE }} -f {{ OPENOCD_TARGET }} -d2 -c "program build/{{ MODE }}/{{ PROJECT }}.elf verify reset exit"

# ⚡️ Flash
flash:
    @just build
    @echo ⚡️  Flashing...
    @just _flash-{{ PROGRAMMER }}
    @echo ✅  Flash done
