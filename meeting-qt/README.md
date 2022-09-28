## 程序跑通
 - Windows环境准备
   - 安装Qt 5.15.0版本
   - 安装VS 2019版本，并配置环境变量`VS142COMNTOOLS_EX=C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\`
   - 安装`7-Zip`到`C:\Program Files\7-Zip`目录，如果不在这个目录请修改`build_tool\win`里的脚本变量`ZIP_PATH`
   - 运行32位程序执行脚本`deploy_win.bat`
   - 运行64位程序执行脚本`deploy_win_x64.bat`
 - macOS环境准备
   - Qt安装5.15.0版本
   - 安装`Xcode`
   - 运行`deploy_mac.sh`
 - 编译运行
   - 用Qt creator打开工程文件`meeting-sdk-desktop.pro`
   - 单击项目，在 Build&Run 下选择构建工具选择`Desktop Qt 5.15.0 MSVC2019 32bit`
   - 选择 Debug 作为构建项目
   - 在`meeting-app\version.h`文件中，输入appkey, 也就是修改`LOCAL_DEFAULT_APPKEY`宏的值
   - 点击构建运行项目

