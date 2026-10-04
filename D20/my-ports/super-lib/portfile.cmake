# Build from the local source tree instead of downloading it
get_filename_component(SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../super-lib" ABSOLUTE)

# super-lib does not export DLL symbols yet
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME super-lib
    CONFIG_PATH lib/cmake/super-lib
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
