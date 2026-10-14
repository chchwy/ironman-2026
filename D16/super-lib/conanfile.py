from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain, cmake_layout


class SuperLibRecipe(ConanFile):
    name = "super-lib"
    version = "0.1.0"

    settings = "os", "compiler", "build_type", "arch"
    exports_sources = "CMakeLists.txt", "src/*", "include/*"

    def layout(self):
        cmake_layout(self)

    def generate(self):
        tc = CMakeToolchain(self)
        tc.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        cmake = CMake(self)
        cmake.install()

    def package_info(self):
        self.cpp_info.libs = ["super-lib"]
