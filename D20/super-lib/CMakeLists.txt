cmake_minimum_required(VERSION 3.21)
project(super-lib VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

add_library(super-lib src/super_lib.cpp)
add_library(super-lib::super-lib ALIAS super-lib)
target_include_directories(super-lib PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

install(TARGETS super-lib EXPORT super-lib-targets)
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(EXPORT super-lib-targets
    FILE super-lib-config.cmake
    NAMESPACE super-lib::
    DESTINATION ${CMAKE_INSTALL_DATADIR}/super-lib
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/super-lib-config-version.cmake
    COMPATIBILITY SameMajorVersion
)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/super-lib-config-version.cmake
    DESTINATION ${CMAKE_INSTALL_DATADIR}/super-lib
)
