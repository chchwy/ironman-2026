# D05 — Xcode & Makefile 搭配 Conan

[![D05 Makefile](https://github.com/chchwy/ironman-2026/actions/workflows/d05-make.yml/badge.svg)](https://github.com/chchwy/ironman-2026/actions/workflows/d05-make.yml)
[![D05 Xcode](https://github.com/chchwy/ironman-2026/actions/workflows/d05-xcode.yml/badge.svg)](https://github.com/chchwy/ironman-2026/actions/workflows/d05-xcode.yml)

對應文章：`D05： Xcode & Makefile 搭配 Conan 套件管理器.md`

兩個專案，`[requires]` 完全相同，只換 `[generators]`。
`main.cpp` 跟 D03 逐字一致。

```
D05/
├── hello-conan-xcode/        # XcodeDeps + XcodeToolchain
│   ├── conanfile.txt
│   ├── hello.xcodeproj/
│   └── hello/main.cpp
└── hello-conan-make/         # MakeDeps
    ├── conanfile.txt
    ├── Makefile
    └── src/main.cpp
```

## 驗證環境

| 項目 | 文章宣稱 | 實測 |
|---|---|---|
| OS | macOS 26 | macOS 26.7 (25G229)、Apple Silicon |
| Xcode | 16.4 / Apple Clang 17 | Xcode 16.4 (16F6) / apple-clang 17.0.0 |
| Conan | 2.32.0 | 2.32.0 |
| CMake（Debug 現場編譯用） | — | 4.3.0 |
| Debian 13 + GCC 13 | 有 | ✅ 由 GitHub Actions 驗（本機無容器環境）|

機器上裝了多版 Xcode，預設 `xcode-select` 指向 15.4。用 `DEVELOPER_DIR` 切換即可，
不用動全域設定：

```bash
export DEVELOPER_DIR=/Applications/Xcode-16.4.0.app/Contents/Developer
```

Profile 另外建一份 `d05-macos`（`conan profile detect --name d05-macos`），不覆蓋 default：

```
[settings]
arch=armv8
build_type=Release
compiler=apple-clang
compiler.cppstd=gnu17
compiler.libcxx=libc++
compiler.version=17
os=Macos
```

用 `-pr:a d05-macos` 指定。另外本機設了公司內部 remote，離開 VPN 時 `conan install`
會卡在連不上而中止，加 `-r conancenter` 限定來源即可。

## Xcode

Xcode 沒有 `vs_layout` 那樣的預設 layout，所以 `conanfile.txt` 不寫 `[layout]`，
改用 `-of conan` 指定輸出資料夾。Debug / Release 各跑一次：

```bash
cd hello-conan-xcode
conan install . --build=missing -s build_type=Release -of conan -pr:a d05-macos
conan install . --build=missing -s build_type=Debug   -of conan -pr:a d05-macos
```

專案裡的 `conan/conan_config.xcconfig` 已經掛在**專案層級**的 Debug 和 Release 兩個
組態上（pbxproj 的 `baseConfigurationReference`），所以 `conan install` 跑完直接開
Xcode 按 ⌘R 就能編，不用再手動去 Info > Configurations 設定。

反過來說，**沒跑 `conan install` 之前 `conan/` 不存在**，Xcode 會把那個 xcconfig
標成紅色、build 會停在找不到 base configuration。這是預期行為，不是專案壞了。

專案層級刻意**沒有**設 `CLANG_CXX_LANGUAGE_STANDARD` 和 `CLANG_CXX_LIBRARY`，
留給 `conantoolchain.xcconfig` 決定——專案層級的值會蓋過 base xcconfig。
實測編譯參數確實帶到 `-std=gnu++17 -stdlib=libc++`，來源就是 profile 的 `cppstd=gnu17`。

`hello.xcscheme` 是 shared scheme，已納入版控，clone 下來就能直接用 `-scheme hello`。

### 命令列編譯：文章的指令是錯的

文章寫的是：

```bash
# ❌ 這個不會過
xcodebuild -project hello.xcodeproj -scheme hello -configuration Release \
  -destination 'platform=macOS,arch=arm64' \
  -xcconfig conan/conan_config.xcconfig
```

`-destination` 對 macOS command line tool 專案**不會限制編譯架構**。實測四種寫法：

| 指令 | 實際編的架構 | 結果 |
|---|---|---|
| 文章逐字（`-destination` + `-xcconfig`） | arm64 + x86_64 | ❌ BUILD FAILED |
| 只加 `-destination` | arm64 + x86_64 | ❌ BUILD FAILED |
| `ARCHS=arm64` | arm64 | ✅ BUILD SUCCEEDED |
| `ONLY_ACTIVE_ARCH=YES` | arm64 | ✅ BUILD SUCCEEDED |

能過的版本：

```bash
xcodebuild -project hello.xcodeproj -scheme hello -configuration Release \
  ARCHS=arm64 build
```

這不是本機環境的問題。`d05-xcode.yml` 在乾淨的 macos-15 runner 上把文章那行指令
（含 `-destination`）跑成一個「必須失敗」的測試，同樣停在
`fatal error: 'fmt/core.h' file not found`，且 log 裡看得到 x86_64 那一輪照編。

### Release 的 Universal Binary 問題（文章的描述正確）

Release 預設同時編 arm64 和 x86_64 兩種架構，但 Conan 只裝了 arm64 的 fmt，
XcodeDeps 產生的設定也只掛在 `[arch=arm64]` 底下。實測編譯參數：

- arm64：`-isystem /Users/matt/.conan2/p/fmt.../include`、`-std=gnu++17` ✅
- x86_64：完全沒有 conan 的 `-isystem`，連 `-std=gnu++17` 都沒有

所以 x86_64 直接停在：

```
hello/main.cpp:1:10: fatal error: 'fmt/core.h' file not found
```

跟文章引的錯誤訊息一字不差。`xcodebuild -showBuildSettings` 的實測值：

| 組態 | `ARCHS` | `ONLY_ACTIVE_ARCH` |
|---|---|---|
| Debug | `arm64` | `YES` |
| Release | `arm64 x86_64` | `NO` |

Debug 只編 arm64，所以 Xcode 裡按 ⌘R 不會中；命令列走 Release 才會中。
文章這段的因果解釋正確，只有上面那個解法要修。

### apple-clang 版本對照（文章表格正確）

機器上四個 Xcode 版本實測：

| Xcode | apple-clang | 文章宣稱 | 實測 |
|---|---|---|---|
| 14.3.1 | 14.0.3 | — | — |
| 15.4 | 15.0.0 | 15 | ✅ |
| 16.4 | **17.0.0** | 17 | ✅ |
| 26.6 | 21.0.0 | 21 | ✅ |

預編譯二進位的有無也對得上：

- apple-clang 17 + Release → `Download (conancenter)`，有預編譯 ✅
- apple-clang 17 + Debug → `- Build`，現場編譯 ✅
  （Conan 掃了 11 種 `compiler.cppstd` 相容組態，遠端全都沒有）
- apple-clang 15 + Release → 遠端沒有，也得自己編（對應文章表格「15.4 → 沒有」）

現場編譯需要 `cmake` 在 PATH 上，這點文章有寫，成立。

## Makefile

```bash
cd hello-conan-make
conan install . --build=missing -of build -pr:a d05-macos
make
./build/hello
```

`build/` 由 `conan install -of build` 建出來，所以要先 `conan install` 再 `make`。

### macOS

實測通過，`make` 展開的指令：

```
c++ -I.../fmt/include -I.../nlohmann_json/include -std=c++17 \
    src/main.cpp -o build/hello -L.../fmt/lib -lfmt -lfmt-c
```

`Makefile` 開頭那五個 `CONAN_*_FLAG` 必須自己定義，`MakeDeps` 不會寫死 `-I` / `-L` / `-l`。
`-std=c++17` 也要自己加，`MakeDeps` 不會把 profile 的 `compiler.cppstd` 帶進來——
實測成立，展開的指令裡 `-std=c++17` 確實來自 Makefile 而非 Conan。

**注意：macOS 上的 `conandeps.mk` 完全沒有 `CONAN_SYSTEM_LIBS` 和 `CONAN_DEFINES`
這兩個變數**，fmt 的系統相依 `m` 只有 Linux 才有。Makefile 裡的
`$(CONAN_SYSTEM_LIBS)` 和 `$(CONAN_DEFINES)` 在 macOS 上展開成空字串，無害，
所以同一份 Makefile 兩邊都能用。

### Linux（GitHub Actions）

`.github/workflows/d05-make.yml` 跑在 `debian:13` 容器裡，裝 `g++-13` + Conan 2.32.0，
對齊文章宣稱的環境。Debian 13 的預設 GCC 是 14，所以 workflow 明確設
`CC=gcc-13` / `CXX=g++-13`——Conan 的 `profile detect` 會優先採用這兩個環境變數。

Linux 上 `conandeps.mk` 確實有 `CONAN_SYSTEM_LIBS`，變數是三層轉接：

```makefile
CONAN_SYSTEM_LIBS_FMT__FMT = $(CONAN_SYSTEM_LIB_FLAG)m
CONAN_SYSTEM_LIBS_FMT      = $(CONAN_SYSTEM_LIBS_FMT__FMT)
CONAN_SYSTEM_LIBS          = $(CONAN_SYSTEM_LIBS_FMT)
```

（跟 libs 一樣，fmt 有 component 所以中間多一層雙底線的 `_FMT__FMT`。）

`make` 展開的指令，結尾多了 `-lm`：

```
g++-13 -I.../fmt/include -I.../nlohmann_json/include -std=c++17 \
    src/main.cpp -o build/hello -L.../fmt/lib -lfmt -lfmt-c -lm
```

**文章那個警告是對的，workflow 把它釘成一個「必須失敗」的測試。**
用 `make CONAN_SYSTEM_LIB_FLAG=` 覆寫成空字串（不動檔案）重現：

```
g++-13 ... -lfmt -lfmt-c m
/usr/bin/ld: cannot find m: No such file or directory
collect2: error: ld returned 1 exit status
make: *** [Makefile:15: build/hello] Error 1
```

錯誤訊息是 `cannot find m`，跟文章寫的一致。哪天 Conan 改掉這個行為、
或是這個測試變成會通過，CI 就會先叫。

## 驗證狀態

| 項目 | 狀態 |
|---|---|
| Xcode：`conan install` Release / Debug | ✅ |
| Xcode：產生的 16 個 xcconfig 檔名與文章逐字相同 | ✅ |
| Xcode：`conan_config.xcconfig` 內容與文章相同 | ✅ |
| Xcode：Debug 編譯 + 執行，輸出與文章一致 | ✅ |
| Xcode：Release（`ARCHS=arm64`）編譯 + 執行 | ✅ |
| Xcode：Universal Binary 的錯誤完整重現 | ✅ |
| Xcode：apple-clang 版本對照表 | ✅ |
| Xcode：以上全部在 GitHub Actions（macos-15）重跑 | ✅ |
| **Xcode：文章的 `xcodebuild` 指令** | ❌ **不成立，解法要改** |
| Makefile：macOS 上編譯 + 執行 | ✅ |
| Makefile：Debian 13 + GCC 13（CI） | ✅ |
| Makefile：漏掉 `CONAN_SYSTEM_LIB_FLAG` 必失敗（CI 反例） | ✅ |

`conan_config.xcconfig` 實際內容（文章說「只有兩行」，實際前面還有兩行註解）：

```
// Includes both the toolchain and the dependencies
// files if they exist

#include "conandeps.xcconfig"
#include "conantoolchain.xcconfig"
```
