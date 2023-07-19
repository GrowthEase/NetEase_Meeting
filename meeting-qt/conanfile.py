from conans import ConanFile, tools
import platform
import os


class ModuleConan(ConanFile):
    name = "xkit-desktop"
    description = "X kit desktop"
    settings = "os", "compiler", "build_type", "arch"
    default_options = {
        "libyuv:with_jpeg": False,
        "nim:with_qchat": False,
        "nim:with_http_tools": False,
        "nertc:with_super_resolution": False
    }

    def configure(self):
        self.generators = "cmake", "cmake_find_package_multi", "cmake_paths"
        del self.settings.compiler.cppstd

    def requirements(self):
        env_nertc_version = os.environ.get("NERTC_SDK_VERSION", None)
        if env_nertc_version is not None and env_nertc_version != "":
            self.requires(f"nertc/{env_nertc_version}@yunxin/testing")
            print('Using nertc version from env: ', env_nertc_version)
        self.requires("alog/1.1.0@yunxin/stable")
        self.requires("roomkit/1.16.1@yunxin/stable")
        self.requires("tinyNET/0.1.1@yunxin/stable")
        self.requires("libyuv/cci.20201106")
        self.requires("gtest/cci.20210126")
        self.requires("jsoncpp/1.9.5")

    def package_id(self):
        del self.info.settings.compiler

    def package_info(self):
        self.cpp_info.libdirs = ["lib"]
        self.cpp_info.includedirs = ["include"]
        self.cpp_info.libs = tools.collect_libs(self)

    def imports(self):
        self.copy("*.*", "lib/resource", "resource", "roomkit")
        if self.settings.os == "Macos":
            self.copy("*.dylib", "lib", "lib", "nim")
            self.copy("*.dylib", "lib", "lib", "roomkit")
            self.copy("*.framework/*", "lib", "lib", "roomkit")
        if self.settings.os == 'Windows':
            self.copy("*.dll", "bin", "bin", "nim")
            self.copy("*.dll", "bin", "bin", "roomkit")
