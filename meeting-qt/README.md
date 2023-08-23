# XKit-Desktop

网易会议应用及会议 UI 组件（Based on Qt），支持平台 macOS、Windows。

## 依赖环境配置

 - [Python3](https://www.python.org/downloads/) (brew install python3)
 - [Conan](https://conan.io/downloads.html) >1.60 <2.0 (python3 -m pip install conan==1.60.1)
 - [CMake](https://cmake.org/download/) 3.19+
 - [Xcode](https://developer.apple.com/xcode/) the latest version under macOS
 - [Visual Studio Build Tools](https://visualstudio.microsoft.com/zh-hans/vs/older-downloads/) 2019 under Windows
 - [Qt](http://mirrors.ustc.edu.cn/qtproject/archive/online_installers/4.6/) 6.4.3

### Visual Studio Build Tools 安装配置

在 Windows 安装 Visual Studio Build Tools 时您需要至少安装：

 - Desktop development with C++

选择 `Desktop development with C++` 后右侧侧边栏勾选 `C++ ATL for latest v142 build tools (x86 % x64)` 再进行安装。

### Qt 配置

使用 Qt online installer 安装 Qt SDK 时，您必须安装以下组件包才能正常编译工程：

 - macOS (under macOS)
 - MSVC 2019 64-bit (under Windows)
 - Qt5 Compatibility Module
 - Qt Shader Tools
 - Additional Libraries
    - Qt Multimedia
    - Qt Positioning
    - Qt WebChannel
    - Qt WebEngine
    - Qt WebSocket (for hawk e2e test)

 > 安装路径 Windows 下建议您安装到 D:\Qt 目录，macOS 下建议安装到 ~/Qt 目录下。因工程下的 CMakePresets.json 内部固定这些路径，如果您不是按这些路径安装的 Qt，您可能需要修改 CMakePresets.json 才能正常进行编译。

### Conan 配置

Conan 安装完成后需要配置内部私有化环境，执行如下命令添加 Conan 内部私有化地址

```bash
conan remote add NetEaseConan http://yunxin-conan.netease.im:8081/artifactory/api/conan/NetEaseConan
```

## 推荐工具

因会议应用及组件是跨平台 C++ 工程，我们建议您使用 Visual Studio Code 作为开发工具使多端开发体验一致，我们在工程目录下添加了诸多适配 Visual Studio Code 工具的配置文件，目的是期望工程通过 Visual Studio Code 打开后即可无缝编译。当然您完全可以使用 CMake 生成不同平台的解决方案文件，如 Xcode、Visual Studio 解决方案。

## 本地调试

当您正确安装好依赖环境所需的工具后，使用 Visual Studio Code 打开工程会提示您安装推荐的插件，将这些插件安装完毕后按下 `⇧ + ⌘ + P`（macOS ）or `CTRL+SHIFT+P`（Windows） 搜索 `CMake: Configure` 后回车即会自动编译三方依赖并创建工程解决方案文件。

当三方依赖和工程解决方案文件创建完成后，点击 Visual Studio Code 下方的 Build 按钮即可编译工程。

如果您不想依赖 Visual Studio Code 编辑器而是通过命令行来生成工程，可参考 [.gitlab-ci.yml](.gitlab-ci.yml) 中的工作流，内部详细的描述了如何在 CI Job 中生成具体产物。

由于在 Windows 下没有像 macOS 一样的 RPATH 机制，您在本地编译完成后需要手动执行 windeployqt 流程将调试的 Qt 依赖文件拷贝到编译产生的临时目录进行调试，如：

```bash
# 请根据实际情况修改 Qt 安装路径
D:\Qt\6.4.3\msvc2019_64\bin\windeployqt.exe build-debug\bin\NetEaseMeetingClient.exe -qmldir=meeting\meeting-ui-sdk\qml
D:\Qt\6.4.3\msvc2019_64\bin\windeployqt.exe build-debug\bin\NetEaseMeeting.exe -qmldir=meeting\meeting-app\qml
```

## Git 工作流

新仓库的 Git 工作流采用 git flow，简单来说 main 分支作为当前最新稳定代码分支。新的版本迭代过程中，我们基于 develop 开出新的 feature/* 分支进行功能开发，当冒烟测试稳定后合并至 develop 分支。在一个版本所有 feature/* 分支都合并到 develop 准备集成测试时，基于 develop 开出 release/* 分支（星号代表发布版本号），回归完成后合并 release/* 到 develop 和 main 并按版本号创建一个最新的 tag。

对于 git flow 工作流有任何问题请参考以下内容：

 - [A successful Git branching model](https://nvie.com/posts/a-successful-git-branching-model/)
 - [Gitflow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)

任何打乱 git flow 工作流的行为都可能会造成仓库分支混乱、合并冲突等问题，如您的分支命名方式不是以 git flow 方式创建，将会导致 CI 在编译时无法获取正确的分支、版本等信息。或您开启新的分支并不是以 git flow 规定的方式创建将会导致一系列代码合并错误。

建议使用 [git-flow](https://github.com/nvie/gitflow) 命令行终端来做日常的开发而不是原生 git 指令来开启或合并分支。或使用集成了 git flow 工作流的客户端如 [SourceTree](https://www.sourcetreeapp.com/)、[SmartGit](https://www.syntevo.com/smartgit/) 等，这些客户端天然集成了通过 UI 来创建 feature、release、hotfix 等能力可以减少协同开发过程中的错误。

## 版本管理

对版本号的管理，我们遵循 [Semantic Versioning 2.0.0](https://semver.org/lang/zh-CN/)，CMakeLists.txt 脚本在初始化阶段会自动读取当前工程的最近一次 tag 及分支等信息。如果当前工作在 develop、feature/*、bugfix/*、support/* 分支时，会使用最近一次 tag 最为版本号。若当前工作在 release/*、hotfix/* 分支时，会自动截取分支名斜杠后的版本号。

版本号信息会在 CMake 初始化时打印到控制台，同时所有依赖版本号的配置文件如 version.in.h、version.rc.in 等文件，均通过自动获取的版本号信息进行初始化。**如果您按正确的 git flow 流程来管理工程，则无需刻意关心版本号的处理、修改等问题。**

