# XKit-Desktop

网易会议应用及会议 UI 组件（Based on Qt），支持平台 macOS、Windows。

## 依赖环境配置

 - [Python3](https://www.python.org/downloads/) (brew install python3)
 - [Conan](https://conan.io/downloads.html) >1.60 <2.0 (python3 -m pip install conan==1.60.1)
 - [CMake](https://cmake.org/download/) 3.19+
 - [Xcode](https://developer.apple.com/xcode/) the latest version under macOS
 - [Visual Studio Build Tools](https://visualstudio.microsoft.com/zh-hans/vs/older-downloads/) 2019 under Windows
 - [Qt](http://mirrors.ustc.edu.cn/qtproject/archive/online_installers/4.6/) 5.15.0

### Visual Studio Build Tools 安装配置

在 Windows 安装 Visual Studio Build Tools 时您需要至少安装：

 - Desktop development with C++

选择 `Desktop development with C++` 后右侧侧边栏勾选 `C++ ATL for latest v142 build tools (x86 % x64)` 再进行安装。

### Qt 配置

使用 Qt online installer 安装 Qt SDK 时，您必须安装以下组件包才能正常编译工程：

 - macOS (under macOS)
 - MSVC 2019 64-bit (under Windows)

 > 安装路径 Windows 下建议您安装到 D:\Qt 目录，macOS 下建议安装到 ~/Qt 目录下。因工程下的 CMakePresets.json 内部固定这些路径，如果您不是按这些路径安装的 Qt，您可能需要修改 CMakePresets.json 才能正常进行编译。

## 推荐工具

因会议应用及组件是跨平台 C++ 工程，我们建议您使用 Visual Studio Code、CLion 作为开发工具使多端开发体验一致，我们在工程目录下添加了诸多适配 Visual Studio Code 工具的配置文件、CMakePresets.json 等，目的是期望工程通过一些支持这些脚本的工具打开后即可无缝编译。当然您完全可以使用 CMake 生成不同平台的解决方案文件，如 Xcode、Visual Studio 解决方案。使用如下命令可以生成不同平台的解决方案文件：

**Windows**

```bash
# 生成 Visual Studio 2019 解决方案文件
cmake -Bbuild -G"Visual Studio 16 2019" -Ax64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=D:\Qt\5.15.0\msvc2019_64 -DCMAKE_INSTALL_PREFIX=exports -DBUILD_TESTING=OFF
# 编译工程
cmake --build build --config Release --target install
# 对编译后的工程进行 Qt deploy
cmake --build build --config Release --target qtdeploy-meeting
```

如果您需要在 Windows 下制作安装包，可使用如下命令生成并编译安装包程序：

```bash
# 生成安装包工程
cmake meeting/setup -Bsetup -G"Visual Studio 16 2019" -A x64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=exports
# 编译安装包，最终会生成到 exports 目录下
cmake --build setup --config Release --target install
```

**macOS**

```bash
# 生成 Xcode 解决方案文件
cmake -Bbuild -GXcode -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=~/Qt/5.15.0/clang_64 -DCMAKE_INSTALL_PREFIX=exports -DBUILD_TESTING=OFF
# 编译工程
cmake --build build --config Release --target install
# 对编译后的工程进行 Qt deploy
cmake --build build --config Release --target qtdeploy-meeting
```

 > 因 Qt 版本限制，在 macOS 下 5.15.x 系列版本并没有提供 Apple Silicon 架构的 Qt SDK，所以目前仅仅支持编译 x86_64 架构

## 本地调试

当您正确安装好依赖环境所需的工具后，使用 Visual Studio Code 打开工程会提示您安装推荐的插件，将这些插件安装完毕后按下 `⇧ + ⌘ + P`（macOS ）or `CTRL+SHIFT+P`（Windows） 搜索 `CMake: Configure` 后回车即会自动编译三方依赖并创建工程解决方案文件。

当三方依赖和工程解决方案文件创建完成后，点击 Visual Studio Code 下方的 Build 按钮即可编译工程。

由于在 Windows 下没有像 macOS 一样的 RPATH 机制，您在本地编译完成后需要手动执行 windeployqt 流程将调试的 Qt 依赖文件拷贝到编译产生的临时目录进行调试，如：

```bash
# 请根据实际情况修改 Qt 安装路径
D:\Qt\5.15.0\msvc2019_64\bin\windeployqt.exe build-debug\bin\NetEaseMeetingClient.exe -qmldir=meeting\meeting-ui-sdk\qml
D:\Qt\5.15.0\msvc2019_64\bin\windeployqt.exe build-debug\bin\NetEaseMeeting.exe -qmldir=meeting\meeting-app\qml
```
