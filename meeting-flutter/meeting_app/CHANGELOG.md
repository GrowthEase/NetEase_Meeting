# MeetingApp ChangeLog
## v3.17.0(Nov 1, 2023)
### New Feature
- 订阅逻辑优化：去掉延迟取消订阅逻辑
- 适配 NERoom 新屏幕共享能力
- Android应用内开启小窗模式下，退后台显示画中画

### Bug Fixes
- 修复多设备登录，浮窗显示问题
- 主持人全局静音/关闭视频，举手弹窗消失逻辑优化

### Compatibility
- 兼容 NERoomKit 1.21.1
- 兼容 NIMSDK_LITE 9.12.0
- 兼容 NERtcSDK  5.5.203

## v3.16.1(SEP 8, 2023)
- 适配Android 版本低于8.0无法使用画中画功能，默认以最小化

## v3.16.0(SEP 6, 2023)
### New Feature
- 会议最小化开启小窗悬浮，小窗模式下退入后台，在(iOS 16.0,Android 8.0)及以上系统会开启画中画

### Bug Fixes
- iOS 应用修复会议内外，美颜设置不一致问题
- iOS 聊天室发送文件下载后查看图层问题修复
- 网络监测toast与白板toast重复问题
- 被踢时，rtc回调与IM回调时序问题

### Compatibility
- 兼容 NERoomKit 1.20.0
- 兼容 NIMSDK_LITE 9.12.0
- 兼容 NERtcSDK  5.4.8

## v3.15.2(Aug 23, 2023)
### New Features
* 修改会议网络监听，state连续三次为poor时，toast网络异常提示
* 增加弱网或网络断开监听，收到NERoomConnectType.Disconnect显示会议重连loading，收到NERoomConnectType.Reconnect则关闭
* 增加网络异常会议断开监听，增加重新入会弹窗，可以返回首页或重新入会(复用最开始入会的参数)
### Compatibility
* 兼容 `NERoom` 1.19.2 版本
* 兼容 `NIM` 9.12.0 版本
* 兼容 `NERtc` 5.3.11 版本

## v3.15.0(Aug 11, 2023)
### New Features
* 移动端升级Flutter版本至3.10.5
* 优化RTC私有化配置服务
* 会议组件：优化入会协议-entry/config/snapshot/joinRtc合并为一个接口
* 网易会议升级RTC 5.4.3、IM 9.12.0 、白板3.9.6（NERoom升级）
* 网易会议反馈优化-移动端反馈日志下载地址提供全路径
* 请求头区分不同跨端框架
### Compatibility
* 兼容 `NERoom` 1.19.0 版本
* 兼容 `NIM` 9.12.0 版本
* 兼容 `NERtc` 5.4.3 版本

## v3.14.0(July 05, 2023)
### New Features
* 优化大房间信令交互；
### Compatibility
* 兼容 `NERoom` 1.17.0 版本
* 兼容 `NIM` 9.10.0 版本
* 兼容 `NERtc` 5.3.7 版本

## v3.13.0(June 21, 2023)
### New Features
* 新增音频共享功能；
### Fixed
* 修复音频智能降噪不生效的问题；
### Compatibility
* 兼容 `NERoom` 1.16.0 版本
* 兼容 `NIM` 9.10.0 版本
* 兼容 `NERtc` 5.3.7 版本

## v3.12.0(May 30, 2023)
### Compatibility
* 兼容 `NERoom` 1.14.0 版本
* 兼容 `NIM` 9.8.0 版本
* 兼容 `NERtc` 5.3.5 版本

## v3.10.20(April 18, 2023)
### Compatibility
* 兼容 `NERoom` 1.13.0 版本
* 兼容 `NIM` 9.8.0 版本
* 兼容 `NERtc` 5.3.1 版本

## v3.10.0(April 11, 2023)
### New Features
* 其他已知问题修复；
### Compatibility
* 兼容 `NERoom` 1.13.0 版本
* 兼容 `NIM` 9.8.0 版本
* 兼容 `NERtc` 4.6.50 版本

## v3.9.0(March 02, 2023)
### New Features
* 新增网络质量检测能力；
* 新增会议系统电话接听处理能力；
* 优化共享&白板下的显示；
* 其他已知问题修复；
### Compatibility
* 兼容 `NERoom` 1.12.0 版本

## v3.8.1(January 11, 2023)
### Fixed
* 修复Android端升级TargetSDK至32后部分机型无法打开浏览器进行sso登录的问题

## v3.8.0(January 10, 2023)
### New Features
* 新增意见反馈问题时间戳与图片上传
* 小窗口支持滑动
* 修复其他问题
### Compatibility
* 兼容 `NERoom` 1.11.0
* 兼容 `NERtc` 4.6.29 版本

## v3.7.0(December 07, 2022)
### New Features
* 修复静音/解除静音时设备操作慢以及音频卡顿问题：使用mute操作，并关闭静音包
* 修复其他问题
### Compatibility
* 兼容 `NERoom` 1.10.0
* 兼容 `NERtc` 4.6.29 版本

## v3.6.1(November 11, 2022)
### New Features
* 优化应用内通知
* 修复vivo、华为应用市场审核问题
### Compatibility
* 兼容 `NERoom` 1.8.2(AOS)、1.8.1(iOS) 版本
* 兼容 `NERtc` 4.6.20 版本

## v3.6.0(October 31, 2022)
### New Features
* 支持邀请链接入会与剪切板会议号入会
* 添加账号注销功能
* 修复已知问题
### Compatibility
* 兼容 `NERoom` 1.8.2(AOS)、1.8.1(iOS) 版本
* 兼容 `NERtc` 4.6.20 版本

## v3.5.0(September 27, 2022)
### New Features
* Flutter端MeetingKit重构
* 修复已知问题
### Compatibility
* 兼容 `NERoom` 1.8.0 版本

## v3.4.0(August 31, 2022)
### New Features
* 聊天室支持图片、文件消息发送与接收
* 修复已知问题
### Compatibility
* 兼容 NEMeetingKit 3.4.0

## v3.3.0(July 28, 2022)
### New Features
* 白板共享时支持上传视频和图片
* 新增会议倒计时结束时间提醒
* 修复已知问题
### Compatibility
* 兼容 NEMeetingKit 3.3.0

## v3.2.0(June 30, 2022)
### New Features
* 支持联席主持人
* SDK版本升级至4.6.13
* 支持美颜功能
* 支持虚拟背景功能
* 支持SIP邀请
* 支持IM SDK复用

## v3.1.0(June 02, 2022)
### New Features
* 支持SIP功能
* 调整内部代码工程结构

## v3.0.0(May 19, 2022)
### New Features
* 替换URS登录
* 隐藏美颜、SIP功能
* 接入MeetingKit:3.0.0 替换 Meeting-SDK-Flutter
* 修复已知问题

