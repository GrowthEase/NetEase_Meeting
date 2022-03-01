## 编译运行
 - Windows前提条件
   - Qt安装5.15.0版本，安装到`C:\Qt\5.15.0`，如果不在这个目录请修改`build_tool\win`里的脚本变量`WINDEPLOY`
   - VS安装2019版本
   - 配置环境变量`VS142COMNTOOLS=C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\Common7\Tools\`
   - `7-Zip`安装到`C:\Program Files\7-Zip`，如果不在这个目录请修改`build_tool\win`里的脚本变量`ZIP_PATH`
 - 运行`deploy_win.bat`
 - macOS前提条件
   - Qt安装5.15.0版本，安装到`/Users/XXX/Qt/5.15.0`，如果不在这个目录请修改`build_tool\win`里的脚本变量`QT_BUILD_TOOL`
   - 安装`Xcode`，安装`dmg`
 - 运行`deploy_mac.sh`
    
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
