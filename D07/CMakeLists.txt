cmake_minimum_required(VERSION 3.23)
project(hello_vcpkg CXX)

find_package(fmt CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)

add_executable(hello src/main.cpp)
target_compile_features(hello PRIVATE cxx_std_17)
target_link_libraries(hello PRIVATE fmt::fmt nlohmann_json::nlohmann_json)
