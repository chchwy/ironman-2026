# working_code — D03 實機驗證

對應文章：`D03 Conan 套件管理第一步：Hello conanfile.txt｜2026鐵人賽.md`

`D03/` 裡的四個檔案（CMakeLists.txt、src/main.cpp、conanfile.txt）與文章內容逐字一致，
用來確認讀者照抄真的跑得起來。

## 驗證環境

| 項目 | 文章宣稱 | 實測 |
|---|---|---|
| OS | Windows 11 | Windows 11 (10.0.26200) |
| 編譯器 | Visual Studio 2022 (MSVC) | VS 2022 Community, MSVC 19.44.35228, toolset v143 |
| Conan | 2.32.0 | 2.32.0（裝在 `.venv/`） |
| CMake | 3.31 | 4.4.3 |

Conan home 隔離在 `.conan2/`，不動全域設定：

```bash
export CONAN_HOME="$(cygpath -w "$PWD/.conan2")"
```

注意：本機同時裝了 VS 2026，`conan profile detect` 會抓到較新的那個（msvc 195）。
為了重現文章情境，`.conan2/profiles/default` 已手動覆寫成文章裡那份 msvc 194 的設定。

## 重現步驟

```bash
cd D03
export CONAN_HOME="$(cygpath -w "$PWD/../.conan2")"
../.venv/Scripts/conan.exe install . --output-folder=build --build=missing
cmake -S . -B build -G "Visual Studio 17 2022" -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake
cmake --build build --config Release
./build/Release/hello.exe
```

## 結果：通過

執行輸出與文章完全一致：

```
Hello, Conan!
{
  "language": "Python",
  "name": "Conan",
  "stars": 9000
}
```

其他對上的細節：

- 兩個套件都**直接下載預編譯二進位**，沒有現場編譯 —— 文章 L190 的說法成立。
- fmt 的 package ID 實際是 `159b372171ff86fd7630aefcf978b21a606abf85`，
  nlohmann_json 是 `da39a3ee5e6b4b0d3255bfef95601890afd80709`（header-only 的固定 ID）。
  兩個都跟文章的縮寫 `159b37...` / `da39a3...` 吻合。
- `conan install` 自己印出的建議就是 `-G "Visual Studio 17 2022"`。
- 沒有 `[layout]` 時產生的檔案直接落在 `--output-folder` 指定的 `build/`，
  所以 `build/conan_toolchain.cmake` 這個路徑是對的。

## 對照測試

**A. 原文的 `cmake --build .` 確實會失敗**

```
$ cmake --build . --config Release
Error: not a CMake build directory (missing CMakeCache.txt)
```

`.` 是 source dir。已改成 `cmake --build build --config Release`。

**C. `fmt/core.h` 可以編，但 `fmt/base.h` 才是現在的寫法**

fmt 12 把 `core.h` 縮成 `base.h` 的 alias，不再 include `format.h`。
這段程式只用到 `fmt::print` + `std::string`，兩者 base.h 都有，所以 `core.h` 仍可編譯。
實測換成 `<fmt/base.h>` 輸出完全相同。文章目前維持 `core.h`。

## 目錄

```
working_code/
├── README.md
├── .venv/        # Conan 2.32.0（未納入版控）
├── .conan2/      # 隔離的 Conan home / 套件快取（未納入版控）
└── D03/
    ├── CMakeLists.txt
    ├── conanfile.txt
    ├── src/main.cpp
    └── build/    # 產出（未納入版控）
```

**C2. 拿掉 `target_compile_features(hello PRIVATE cxx_std_17)`**

原本 Profile 是 `cppstd=14`、CMakeLists 卻要求 C++17，兩邊對不上。
拿掉之後由 Conan toolchain 決定（`C++ Standard 14 with extensions OFF`），
fmt 12 和 nlohmann_json 3.12 在 C++14 下都編得過，輸出不變、零警告。

**C3. `CMAKE_TOOLCHAIN_FILE` 相對路徑**

原本寫 `build/conan_toolchain.cmake`，是靠 CMake「先找 build tree、找不到再找 source tree」
的第二段規則才誤打誤撞找到。改成 `conan_toolchain.cmake` 後第一段規則就命中
（相對 `-B` 指定的 build 目錄），實測 configure 正常。

## 文章與專案同步檢查

`working_code/D03` 的三個檔案跟文章 code block 逐字比對過，完全一致。
重跑檢查：

```bash
cd ..    # 回到 2026-ironman/
python - <<'EOF'
import io,re,os
art=io.open("D03 Conan 套件管理第一步：Hello conanfile.txt｜2026鐵人賽.md",encoding="utf-8").read()
blocks=re.findall(r"```(\w*)
(.*?)```", art, re.S)
pick=lambda lang,must: next(b for l,b in blocks if l==lang and must in b)
for f,txt in {"CMakeLists.txt":pick("cmake","add_executable"),
              "src/main.cpp":pick("cpp","int main"),
              "conanfile.txt":pick("ini","[requires]")}.items():
    cur=io.open(os.path.join("working_code/D03",f),encoding="utf-8").read()
    print("MATCH " if cur.strip()==txt.strip() else "DIFFER", f)
EOF
```

---

# D04 / D05 / D06 驗證記錄

## D04（conanfile.py）— Windows 路徑通過

`D04/` 的檔案全部從文章 code block 抽出。實測：

- `conanfile.txt` 版本在 Windows 上的錯誤訊息**與文章逐字相同**（含 `#b445` / `#e0a6` / `#000b` 三個 revision 前綴）
- `conanfile.py` 版本在 Windows 上只抓 fmt + portaudio，沒有 libalsa
- Conan 自己印出 `target_link_libraries(... fmt::fmt portaudio_static)` → 文章的 `portaudio_static` 正確
- `cmake --preset conan-default` → `cmake --build --preset conan-release` → `build/Release/hello_audio.exe` 全部正確
- 執行輸出與文章一致

recipe 查證：`portaudio/19.7` 是 CCI 上唯一版本；`libalsa` 的 `validate()` 訊息是
`f"{self.ref} only supports Linux"`；libalsa 的 `cmake_file_name="ALSA"`、
`cmake_target_name="ALSA::ALSA"` —— 文章 L136-137 的兩個提醒都正確。

macOS / Linux 路徑無法在 Windows 上驗證。

## D05（MSBuild / Xcode / Make）

### MSBuildDeps + MSBuildToolchain + vs_layout — 實際產生 28 個檔案

```
conan/
├── conandeps.props
├── conan_dedup.props
├── conan_fmt.props
├── conan_fmt__fmt.props
├── conan_fmt__fmt_{debug,release}_x64.props
├── conan_fmt__fmt_vars_{debug,release}_x64.props
├── conan_fmt_fmt_c.props
├── conan_fmt_fmt_c_{debug,release}_x64.props
├── conan_fmt_fmt_c_vars_{debug,release}_x64.props
├── conan_nlohmann_json.props
├── conan_nlohmann_json_{debug,release}_x64.props
├── conan_nlohmann_json_vars_{debug,release}_x64.props
├── conantoolchain.props
├── conantoolchain_{debug,release}_x64.props
└── conanbuild.bat / conanrun.bat / conanvcvars.bat / conanbuildenv-*.bat / ...
```

fmt 有 component（`fmt`、`fmt-c`），所以檔名是**雙底線** `conan_fmt__fmt_*`。
nlohmann_json 沒有 component，檔名就是 `conan_nlohmann_json_*`。

`$(Configuration)` / `$(Platform)` 條件式的位置：
- `conan_nlohmann_json.props` —— 直接在這層
- `conan_fmt.props` —— 這層只轉接到 component，條件式在 `conan_fmt__fmt.props`
- `conantoolchain.props` —— 在這層

### XcodeDeps + XcodeToolchain（`-pr macos`，Release）

```
conan/
├── conan_config.xcconfig          ← 只含兩行 #include
├── conandeps.xcconfig
├── conantoolchain.xcconfig
├── conantoolchain_release_arm64.xcconfig
├── conan_fmt.xcconfig
├── conan_fmt__fmt.xcconfig
├── conan_fmt__fmt_release_arm64.xcconfig
├── conan_fmt_fmt_c.xcconfig
├── conan_fmt_fmt_c_release_arm64.xcconfig
├── conan_nlohmann_json.xcconfig
├── conan_nlohmann_json_nlohmann_json.xcconfig
└── conan_nlohmann_json_nlohmann_json_release_arm64.xcconfig
```

`conan_config.xcconfig` 內容：

```
// Includes both the toolchain and the dependencies
// files if they exist

#include "conandeps.xcconfig"
#include "conantoolchain.xcconfig"
```

Debug 版無法在 Windows 上產生（apple-clang 的 Debug 二進位 CCI 沒有預編譯，
`--build=missing` 會試著 cross-build 然後失敗）。

Conan 2.32 沒有 `xcode_layout`，只有 `cmake_layout` / `vs_layout` / `bazel_layout`。

### MakeDeps（`-pr linux`）

MakeDeps 支援的 prefix 變數共 6 個：

```
CONAN_LIB_FLAG  CONAN_DEFINE_FLAG  CONAN_SYSTEM_LIB_FLAG
CONAN_INCLUDE_DIR_FLAG  CONAN_LIB_DIR_FLAG  CONAN_BIN_DIR_FLAG
```

`conandeps.mk` 裡實際用到 5 個（除了 `CONAN_DEFINE_FLAG`，
因為 fmt / nlohmann_json 都沒有 defines，`CONAN_DEFINES` 不會產生）。

**文章的 Makefile 漏了 `CONAN_SYSTEM_LIB_FLAG`。** 展開結果：

```
# 文章目前的 Makefile
CONAN_LIBS        = -lfmt -lfmt-c
CONAN_SYSTEM_LIBS = m            ← 少了 -l
LDLIBS            = -lfmt -lfmt-c m

# 補上 CONAN_SYSTEM_LIB_FLAG = -l
CONAN_SYSTEM_LIBS = -lm
LDLIBS            = -lfmt -lfmt-c -lm
```

`m` 會被 gcc 當成輸入檔名，Debian 上會停在 `cc: error: m: No such file or directory`。

`CONAN_DEPS` / `CONAN_ROOT_FMT` / `CONAN_INCLUDE_DIRS_FMT` /
`CONAN_LIB_DIRS_FMT` / `CONAN_LIBS_FMT` / `CONAN_SYSTEM_LIBS` 都存在，
形狀也跟文章的示意一致。

`MakeDeps` 在官方文件上確實標示 experimental：
「This feature is experimental and subject to breaking changes.」

## D06（vcpkg）— Windows 路徑通過

vcpkg `2026-07-27-98d7cb0cf1f4686a3e43aa5672b6230c1d56bce8`（shallow clone + bootstrap）。

`vcpkg new --application` 和 `vcpkg add port fmt nlohmann-json` 產生的兩個檔案，
內容跟文章寫的**完全一致**（baseline 換成當下的 commit）。

第一次 configure 的實際輸出：

```
-- Running vcpkg install
Fetching registry information from https://github.com/microsoft/vcpkg (HEAD)...
Detecting compiler hash for triplet x64-windows...
Compiler found: .../VC/Tools/MSVC/14.51.36231/bin/Hostx64/x64/cl.exe
The following packages will be built and installed:
    fmt:x64-windows@12.2.0#1 -- git+https://github.com/microsoft/vcpkg@7ca0b8c0...
    nlohmann-json:x64-windows@3.12.0#2 -- git+https://github.com/microsoft/vcpkg@ac3b8821...
  * vcpkg-cmake:x64-windows@2025-08-07 -- git+https://github.com/microsoft/vcpkg@16b9390d...
  * vcpkg-cmake-config:x64-windows@2026-07-21 -- git+https://github.com/microsoft/vcpkg@51befcb0...
Additional packages (*) will be modified to complete this operation.
```

重點：
- vcpkg 抓到的是 **fmt 12.2.0、nlohmann-json 3.12.0** —— 跟 Conan 完全同版本
- `*` 只標工具 port，直接相依的 fmt / nlohmann-json 沒有星號
- 套件裝在 `build/vcpkg_installed/x64-windows/`
- 編譯後 `build/Release/` 裡確實只有 `fmt.dll` 和 `hello.exe` —— DLL 自動複製屬實
- 執行輸出與文章一致

注意：即使外層 CMake 指定 `-G "Visual Studio 17 2022"`，vcpkg 偵測編譯器時抓的是
VS 2026 的 `cl.exe`。vcpkg 編套件用的 toolset 跟專案 generator 是兩回事。

## 補充：沒有 `[layout]` 會怎樣（D04）

`D04/vs_nolayout/` 是拿掉 `[layout] vs_layout` 之後的同一個專案。
Release + Debug 各跑一次 `conan install`，產生的 31 個檔案全部落在專案根目錄，
跟 `hello.sln` / `hello.vcxproj` / `main.cpp` 混在一起（共 35 個檔案）：

```
conan_dedup.props                      conanbuild.bat
conan_fmt.props                        conanbuildenv-debug-x86_64.bat
conan_fmt__fmt.props                   conanbuildenv-release-x86_64.bat
conan_fmt__fmt_{debug,release}_x64.props        conanrun.bat
conan_fmt__fmt_vars_{debug,release}_x64.props   conanrunenv-debug-x86_64.bat
conan_fmt_fmt_c.props                  conanrunenv-release-x86_64.bat
conan_fmt_fmt_c_{debug,release}_x64.props       conanvcvars.bat
conan_fmt_fmt_c_vars_{debug,release}_x64.props  deactivate_conanbuild.bat
conan_nlohmann_json.props              deactivate_conanrun.bat
conan_nlohmann_json_{debug,release}_x64.props   deactivate_conanvcvars.bat
conan_nlohmann_json_vars_{debug,release}_x64.props
conandeps.props
conantoolchain.props
conantoolchain_{debug,release}_x64.props
```

加上 `vs_layout` 之後，這 31 個全部收進 `conan/`。

## 注意：venv 不能搬

`.venv/Scripts/conan.exe` 內嵌了建立當下的 python 絕對路徑。
整包目錄從 vault 搬出來之後 conan.exe 會靜默失敗（exit 1、零輸出）。
已重建過一次。之後若再搬動位置，要重跑：

```powershell
Remove-Item .venv -Recurse -Force
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install "conan==2.32.0"
```

---

## 冷啟動全流程驗證（2026-09-18）

位置：`C:\Users\chchw\d03-cleanroom\`（全新 venv + 全新 CONAN_HOME，冷快取）

從文章當下版本重新抽出三個檔案，逐字跑文章指令，全部通過：

| 步驟 | 結果 |
|---|---|
| `pip install conan` → 2.32.0 | ✅ |
| `conan install . --output-folder=build --build=missing` | ✅ 冷快取下兩個套件都直接下載預編譯 |
| `cmake -S . -B build -G "Visual Studio 17 2022" -DCMAKE_TOOLCHAIN_FILE="conan_toolchain.cmake"` | ✅ MSVC 19.44.35228 / toolset v143 |
| `cmake --build build --config Release` | ✅ 無 error 無 warning |
| `.\build\Release\hello.exe` | ✅ 輸出與文章一致 |

冷快取的 `conan install` 輸出與文章 L196-200 完全吻合，含兩個 package ID。

`build/` 共產生 20 個檔案：`conan_toolchain.cmake`、`CMakePresets.json`、
`fmt-config.cmake` / `nlohmann_json-config.cmake` 等 config 檔 —— 對得上文章
L178-179 對 `CMakeDeps` / `CMakeToolchain` 的描述。

兩個外部連結都回 200。

### 修正：PowerShell 的引號

本輪發現先前改動引入的問題。原文 Windows 那行是有引號的
`-DCMAKE_TOOLCHAIN_FILE="build/conan_toolchain.cmake"`，
拿掉 `build/` 前綴時連引號一起拿掉了。實測 PowerShell 會把參數拆開：

```
argv[7] = '-DCMAKE_TOOLCHAIN_FILE=conan_toolchain'
argv[8] = '.cmake'
```

CMake 因此回 `Could not find toolchain file: "conan_toolchain"`。
加不加 `build/` 前綴都一樣會拆。已改回加引號，並把 Windows 區塊的
語法標記從 ```bash 改成 ```powershell、拿掉 `$` 提示符，另加一句說明。
