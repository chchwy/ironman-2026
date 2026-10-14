cmake_minimum_required(VERSION 3.15)
project(app CXX)

find_package(super-lib REQUIRED)

add_executable(app src/main.cpp)
target_link_libraries(app PRIVATE super-lib::super-lib)
