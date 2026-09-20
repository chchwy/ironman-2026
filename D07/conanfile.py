from conan import ConanFile
from conan.tools.cmake import cmake_layout


class HelloAudioRecipe(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps", "CMakeToolchain"

    def requirements(self):
        self.requires("fmt/12.2.0")

        if self.settings.os == "Windows":
            self.requires("portaudio/19.7")
        elif self.settings.os == "Linux":
            self.requires("libalsa/1.2.13")

    def layout(self):
        cmake_layout(self)
