

## v3.5.0(2022-09-27)

### New Features

- **meeting-web-ui:** 🎸 新增长按空格解除静音
- **meeting-web-ui:** 🎸 新增聊天室消息弹窗

## v3.4.0(2022-08-31)

### New Features

- **meeting-web-ui:** 🎸 聊天室增加文件发送和图片发送的开关
- **meeting-web-ui:** 🎸 聊天室文件发送增加进度条和取消发送功能

## v3.3.0(2022-07-28)

### New Features

- **meeting-web-ui:** 🎸 白板共享时支持上传视频和图片
- **meeting-web-ui:** 🎸 预约会议支持配置 SIP 功能开关：NEMeetingItem#setNoSip
- **meeting-web-ui:** 🎸 新增会议倒计时结束时间提醒功能开关：NEMeetingOptions#showMeetingRemainingTip，默认关闭

## v3.2.0(2022-06-30)

### Bug Fixes

- **meeting-web-ui:** 🐛 不在 rtc 房间的不显示成员
- **meeting-web-ui:** 🐛 不在前台页面不订阅视频逻辑问题
- **meeting-web-ui:** 🐛 修复共享画面和主视频画面共用一个 view 造成的两个画面同时显示问题
- **meeting-web-ui:** 🐛 修复点击共享屏幕然后取消无法取消问题
- **meeting-web-ui:** 🐛 修复白板样式冲突引起的成员列表更多按钮层级问题
- **meeting-web-ui:** 🐛 修复白板滚动到底部抖动，ppt 不居中问题
- **meeting-web-ui:** 🐛 更新 neroom 修改 im 复用错误代码
- **meeting-web-ui:** 🐛 更新 roomkit 去除部分日志打印
- **meeting-web-ui:** 🐛 添加对 init 接口参数校验
- **room-kit:** 🐛 修改 VideoCard 的逻辑区分共享还是视频的 view

# 3.2.0 (2022-06-30)

### Bug Fixes

- **meeting-web-ui:** 🐛 setcanvase 的类名修改
- **meeting-web-ui:** 🐛 sip 不支持移交主持人和设置联席主持人
- **meeting-web-ui:** 🐛 修复 eslint 报错
- **meeting-web-ui:** 🐛 修复不开启 sip 加入会议，会显示 sip 信息
- **meeting-web-ui:** 🐛 修复白板授权类型更改后取消授权无效问题
- **meeting-web-ui:** 🐛 匿名登入后离开会创建会议失败后，无法重新加入会议
- **meeting-web-ui:** 🐛 匿名登录离开房间后无法重新进入问题
- **meeting-web-ui:** 🐛 更新 sdk 4.6.11 造成视频标签样式类名修改，无法充满整个屏幕
- **meeting-web-ui:** 🐛 结束共享重新打开失败
- **meeting-web-ui:** 🐛 预设联席主持人，入会昵称显示错误问题
- **meeting-wx-ui:** 🐛 账号 token 登录重新加入会议失败问题

### New Features

- **meeting-web-ui:** 🎸 update rtc sdk 4.6.10
- **meeting-web-ui:** 🎸 成员列表添加 sip 图标，sip 成员无法设置联席主持人和主持人
- **meeting-web-ui:** 🎸 添加 im 复用功能
- **meeting-web-ui:** 🎸 添加 sip 邀请功能
- **meeting-web-ui:** 🎸 添加会议组件 web
- **meeting-web-ui:** 🎸 添加独立匿名登录接口

# CHANGELOG

# 2022-05-19 @ v3.0.0

## Refactor

- 引用变量名修改：由原来的 neWebMeeting 改为 NEMeetingKit

## New Features

- 底层 roomkit:1.1.0 替换 imSDK 和 rtcSDk

## Removed

- 删除场景相关配置和 api
- 音视频订阅：

  - `subscribeRemoteAudioStream`
  - `subscribeRemoteAudioStreams`
  - `subscribeAllRemoteAudioStreams`

- 隐藏虚拟背景功能：

  - `changeVirtualBackgroundStatus`
  - `enableVirtualBackground`

- 隐藏共享屏幕按钮回调功能：

  - `setScreenSharingSourceId`
  - `enableScreenShare`
  - `enableScreenShare`

- 隐藏布局相关功能：
  - `layout`
  - `layoutChange`
- 隐藏网络状态相关功能：

  - `networkQuality`

- 隐藏系统满足情况检查：
  - `checkSystemRequirements`
