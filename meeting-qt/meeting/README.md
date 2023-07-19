## 编码规则
 - IDE 尽量使用 Qt Creator 而不是 Visual Studio
 - Visual Studio 缩进修改为 4 个空格而不是 Tab，代码使用 CTRL+K+F 整理
 - 命名空间不进行缩进
 - 成员变量使用 m_ 开头，如 m_pHandle, m_bFlag
 - 函数名称使用驼峰命名
 - 前端 JavaScript [使用 JavaScript Standard Style 风格](https://standardjs.com/)
 - 前端 QML 遵守 Qt [官方 Coding style 规范](https://doc.qt.io/qt-5/qml-codingconventions.html)

## 发开流程
 - Git 工作流参考 [Git-Flow 的工作流程](https://www.git-tower.com/learn/git/ebook/cn/command-line/advanced-topics/git-flow)
 - Git 中只上传代码和资源文件，二进制文件（含 lib、dll、so、a、framework、app 等）不上传至 Git 仓库
 - Git 同步代码时使用 `git fetch + git rebase`，而不是直接 `git pull（git fetch + git merge）`yilan

## 依赖
 - glog https://github.com/google/glog.git
 - jsoncpp https://github.com/open-source-parsers/jsoncpp.git
 - libyuv https://chromium.googlesource.com/libyuv/libyuv
 - styleguide https://github.com/google/styleguide.git

## 支持的平台
- Windows x86 和 x64，macOS x86-64

## 目录介绍
- meeting-app 会议的exe
- meeting-ui-sdk 会议组件的exe
- meeting-electron 会议Electron的Demo
- meeting-ipc 会议组件的对外接口
- meeting-sample 会议组件的Sample
- setup 会议的安装包
- build_tool 打包脚本
- bin 生成的成果物

## 环境安装和编译运行
 - 安装 Qt5.15.0 、 VS2019 、 python 和 7-Zip
 - 7-Zip 安装在C:\Program Files\7-Zip中
 - 配置环境变量VS142COMNTOOLS_EX 为 VS2019 的安装路径，比如 C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\
 - 执行 deploy_win.bat 或者 deploy_mac.sh
 - 执行 python deploy_xkit.py
 - 用 Qt Creator 打开 meeting-sdk-desktop.pro，一路默认
 - 右键工程，选择运行，会议正常可以启动
