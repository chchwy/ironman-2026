cmake_minimum_required(VERSION 3.25)
project(hello_compute CXX)

find_package(fmt REQUIRED)

add_executable(hello_compute src/main.cpp)
target_compile_features(hello_compute PRIVATE cxx_std_17)
target_link_libraries(hello_compute PRIVATE fmt::fmt)

if(WIN32 OR LINUX)
    find_package(OpenCL REQUIRED)
    target_sources(hello_compute PRIVATE src/compute_opencl.cpp)
    target_link_libraries(hello_compute PRIVATE OpenCL::OpenCL)
elseif(APPLE)
    enable_language(OBJCXX)
    target_sources(hello_compute PRIVATE src/compute_macos.mm)
    target_link_libraries(hello_compute PRIVATE "-framework Metal" "-framework Foundation")
endif()
