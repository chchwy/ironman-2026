cmake_minimum_required(VERSION 3.15)
project(super-lib CXX)

add_library(super-lib src/super_lib.cpp)
target_include_directories(super-lib PUBLIC include)

install(TARGETS super-lib)
install(FILES include/super_lib.h DESTINATION include)
