cmake_minimum_required(VERSION 3.12)
project(super-app LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(super-lib CONFIG REQUIRED)

add_executable(super-app main.cpp)
target_link_libraries(super-app PRIVATE super-lib::super-lib)
