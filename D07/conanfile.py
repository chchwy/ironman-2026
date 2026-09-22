from conan import ConanFile
from conan.tools.cmake import cmake_layout


class HelloComputeRecipe(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps", "CMakeToolchain"

    def requirements(self):
        self.requires("fmt/12.2.0")
        if self.settings.os in ("Windows", "Linux"):
            self.requires("opencl-icd-loader/2025.07.22")

    def layout(self):
        cmake_layout(self)
