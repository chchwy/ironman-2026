# ironman-2026

2026 iThome 鐵人賽系列文的範例程式。

這個系列在講 C++ 的套件管理：怎麼用 Conan 和 vcpkg 把 fmt、nlohmann_json
這類外部函式庫接到 CMake、Visual Studio、Xcode、Makefile 上。
每篇文章提到的專案都各自放一個資料夾，可以直接 clone 下來照文章的步驟跑。

所有範例都印同一段輸出，內容放在 `expected-output.txt`，方便比對跑出來的結果。

## 前置作業

Conan 的範例需要 Conan 2.32.0：

```bash
pip install conan==2.32.0
conan profile detect
```

vcpkg 的範例需要自己 clone 並 bootstrap 一份 vcpkg（不隨專案 vendor 進版控）。

## CI

`.github/workflows/` 底下的 workflow 會在 GitHub 的 runner 上把文章的步驟重跑一遍，
其中也包含幾個「應該要失敗」的反例。文章的說法哪天不成立了，CI 會先叫。
