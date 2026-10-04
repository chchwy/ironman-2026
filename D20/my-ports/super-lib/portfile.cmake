# Build from the local source tree instead of downloading it
set(SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../super-lib")

# super-lib does not export DLL symbols yet
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# super-lib has no LICENSE file yet
set(VCPKG_POLICY_SKIP_COPYRIGHT_CHECK enabled)
