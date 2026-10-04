cmake_minimum_required(VERSION 3.12)
project(super-lib VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(super-lib src/super_lib.cpp)
add_library(super-lib::super-lib ALIAS super-lib)
target_include_directories(super-lib PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

install(TARGETS super-lib
    EXPORT super-lib-targets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)
install(FILES include/super_lib.h DESTINATION include)
install(EXPORT super-lib-targets
    FILE super-lib-config.cmake
    NAMESPACE super-lib::
    DESTINATION lib/cmake/super-lib
)
