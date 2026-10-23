cmake_minimum_required(VERSION 3.23)
project(my_app C)

find_package(OpenSSL REQUIRED)

add_executable(my_app main.c)
target_link_libraries(my_app PRIVATE OpenSSL::Crypto)


install(TARGETS my_app
  RUNTIME_DEPENDENCIES
    PRE_EXCLUDE_REGEXES "api-ms-.*" "ext-ms-.*"
    POST_EXCLUDE_REGEXES ".*system32/.*\.dll"
    DIRECTORIES
      "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}$<$<CONFIG:Debug>:/debug>/bin")
