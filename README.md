# stm32_prj_tmpl

## 开发环境
| 功能 | 工具 | Windows  | macOS | Linux |
 | --- | --- | --- | --- | --- |
| 任务运行器 | Just | winget install Casey.Just | brew install just | apt install just |
| 构建生成器 | CMake | winget install Kitware.CMake | brew install cmake | apt install cmake |
| 构建执行器 | Ninja | winget install ninja-build.ninja | brew install ninja | apt install ninja-build |
| 编译器 | GCC | winget install Arm.GNUArmEmbeddedToolchain | brew install gcc-arm-embedded | apt install gcc-arm-embedded |
| 调试器 | pyocd | pipx install pyocd   | pipx install pyocd | pipx install pyocd |
| 支持包 | For pyocd | pyocd pack install stm32f407 | pyocd pack install stm32f407  | pyocd pack install stm32f407 |
| 调试服务器器 | openocd | - | brew install openocd | apt install openocd |
| DAP(连接GUI与调试服务器) | cortex-debug(vscode) | - | - | - |




## 任务
| 任务 | 入口  | 功能 | 输出/操作 |
| --- | ---- | ---- | ---- |
| 📁配置 | just setup/s | 解析 CMakeLists.txt，检测系统环境，生成构建系统描述文件 | CMakeCache.txt,CMakeFiles/,构建系统描述文件（如 Makefile模板) |
| 📦构建 | just build/b | 调用底层构建工具（如 Make/Ninja/MSBuild）​编译源代码并链接​ |.o/.obj（对象文件）.a/.lib（静态库）.elf/.hex（目标可执行文件） |
| 🧹清理 | just clean/c | 删除构建产物​（对象文件、可执行文件等） | 清理build/目录下所有产物 |
| ⚡️烧录 | just flash/f | 将可执行文件烧录到目标设备 | 通过openocd/pyocd将.elf/.hex/.bin烧录到目标设备 |
| 🐞调试 | GUI | 启动调试会话​（需配合 IDE 和调试器） | 烧录后启动调试会话 |
| 🔗链接 | GUI | 连接到调试会话​（需配合 IDE 和调试器） | 无需下载 |

| IDE | 任务快捷键 | GUI |
| --- | ---- | ---- |
| vscode | Command + Shift + B (Build)| actboy168.tasks |
| zed | Command + Shift + R (Run) | native(coming soon)|

## 文件列表
```
├── .gitattributes # git文件属性控制
├── .gitignore # git系统忽略的文件
├── .justfile # 任务入口（配置、构建、清理、烧录）
├── .vscode # vscode配置
│   ├── c_cpp_properties.json # LSP配置(读取compile_commands.json)
│   ├── extensions.json # 扩展插件
│   ├── launch.json # 调试会话配置
│   ├── settings.json # 项目配置
│   └── tasks.json # vscode任务（调用justfile）
├── .zed # zed 配置
│   ├── debug.json # 调试会话配置
│   ├── settings.json # LSP配置（clangd,读取compile_commands.json）
│   └── tasks.json # zed任务（调用justfile）
├── openocd.cfg # openocd配置文件（仅调试时时候）
└── README.md
```
