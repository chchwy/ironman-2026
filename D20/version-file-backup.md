# 備用：super-lib 的 CMake 版本檔

從 `super-lib/CMakeLists.txt` 拿掉的內容，之後要用時再加回去。

## 作用

產生並安裝 `super-lib-config-version.cmake`，讓使用端可以在 `find_package` 指定版本：

```cmake
find_package(super-lib 0.1 CONFIG REQUIRED)
```

沒有這個檔案時，`find_package` 只要帶版本號就會找不到套件；不帶版本號則不受影響。

## 加回去的方法

1. 在 `set(CMAKE_CXX_STANDARD_REQUIRED ON)` 下面加：

   ```cmake
   include(CMakePackageConfigHelpers)
   ```

2. 在檔案最後加：

   ```cmake
   write_basic_package_version_file(
       ${CMAKE_CURRENT_BINARY_DIR}/super-lib-config-version.cmake
       COMPATIBILITY SameMajorVersion
   )
   install(FILES ${CMAKE_CURRENT_BINARY_DIR}/super-lib-config-version.cmake
       DESTINATION lib/cmake/super-lib
   )
   ```

版本號取自 `project(super-lib VERSION 0.1.0 ...)`，所以 `VERSION` 要留著。
