cmake_minimum_required(VERSION 3.15)
project(hello_conan CXX)

find_package(fmt REQUIRED)
find_package(nlohmann_json REQUIRED)

add_executable(hello src/main.cpp)
target_link_libraries(hello
  PRIVATE fmt::fmt nlohmann_json::nlohmann_json)
