# 网易视频会议解决方案
网易视频会议解决方案 面向企业和组织提供企业级安全保障、软硬件一体化、高性能音视频体验的会议产品和方案，让企业内不同角色用户高效地协作，轻松地沟通。


## 运行说明
### 获取AppKey
[创建应用并获取 AppKey](https://doc.yunxin.163.com/console/guide/TIzMDE4NTA?platform=console)
### 配置AppKey
将创建好的AppKey替换以下文件中的AppKey字段即可


[Android配置路径](./android/app/src/main/assets/xkit_server.config)


[iOS配置路径](./ios/Runner/xkit_server.config)

### 修改应用名称
### Android
应用名称支持国际化,跟随系统配置显示
分别修改以下文件中的app_name字段即可
[应用名称-英文(默认)](./android/app/src/main/res/values/strings.xml)
[应用名称-日文](./android/app/src/main/res/values-ja/strings.xml)
[应用名称-中文](./android/app/src/main/res/values-zh/strings.xml)
### iOS
应用名称支持国际化,跟随系统配置显示
修改文件中的CFBundleDisplayName字段即可
[应用名称(默认)](./ios/Runner/Info.plist)
[应用名称-英文](./ios/Runner/en.lproj/InfoPlist.strings)
[应用名称-日文](./ios/Runner/ja.lproj/InfoPlist.strings)
[应用名称-中文](./ios/Runner/zh-Hans.lproj/InfoPlist.strings)


### 修改应用图标
### Android
根据不同尺寸的图标，替换以下文件中的mipmap-*dpi/ic_launcher.png图标即可
[应用图标资源地址](./android/app/src/main/res)
### iOS
替换以下文件路径中的AppIcon资源文件
[应用图标资源地址](./ios/Runner/Assets.xcassets)
