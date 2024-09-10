## v4.7.0(2024-07-24)

### New Feature

- 支持实时语音字幕功能
- 支持实时转写功能
- 会议支持自动云录制配置
- 预约会议复制邀请信息内容与会议内保持一致
- 小应用添加自定义消息的能力，为签到小应用提供性能优化
- 会中部分 UI 优化

### Api Changes

- NEMeetingOptions 新增入会选项：
- noCaptions，配置入会是否展示“字幕”菜单
- noTranscription，配置入会是否展示“转写”菜单
- autoEnableCaptionsOnJoin，配置入会时是否自动开启字幕
- 历史会议详情支持实时转写记录查询：
- 新增 NEMeetingTranscriptionInfo 会议转写信息对象；
- 新增 NEPreMeetingService.getHistoryMeetingTranscriptionInfo 查询转写信息；
- 新增 NEPreMeetingService.getHistoryMeetingTranscriptionFileUrl 获取转写文件下载地址；
- 新增 NEMeetingTranscriptionMessage 会议转写单条消息对象；
- 新增 NEPreMeetingService.getHistoryMeetingTranscriptionMessageList 获取转写消息列表；
- 支持聊天消息记录查询：
  - 新增 NEChatroomHistoryMessageSearchOption 查询聊天室历史消息选项
  - 新增 NEChatroomMessageSearchOrder 聊天室消息搜索顺序
  - 新增 NEPreMeetingService.fetchChatroomHistoryMessageList 查询历史会议的聊天室历史消息
  - 新增 NEMeetingChatMessage 房间消息基类
  - 新增 NEMeetingChatMessageType 房间消息类型枚举
  - 新增 NEMeetingChatCustomMessage 房间自定义消息
  - 新增 NEMeetingChatTextMessage 房间文本消息
  - 新增 NEMeetingChatFileMessage 房间文件消息
  - 新增 NEMeetingChatImageMessage 房间图片消息
- 支持自动云录制配置
- 新增 NECloudRecordConfig 云录制配置对象
- 新增 NEMeetingItem.cloudRecordConfig 预约会议时配置自动云录制
- 新增 NEStartMeetingOptions.cloudRecordConfig 创建会议配置自动云录制
- 支持意见反馈
- 新增 NEFeedbackService 意见反馈服务，通过 NEMeetingKit.getFeedbackService 获取服务
- 新增 NEFeedbackService.feedback 提交意见反馈
- 新增 NEFeedbackService.loadFeedbackView 展示意见反馈界面
- 新增 NEMenuItems.feedbackMenu()意见反馈菜单，可添加到更多菜单或工具栏菜单中
- 支持获取会议录制信息
- 新增 NEMeetingRecord 单次录制的所有录制信息，单次录制可能产生多个文件
- 新增 NEPreMeetingService.getMeetingCloudRecordList 获取会议录制信息
- 本地会议历史记录
- 新增 NEPreMeetingService.getLocalHistoryMeetingList 获取本地历史会议记录列表，不支持漫游保存，默认保存最近 10 条记录
- 新增 NEPreMeetingService.clearLocalHistoryMeetingList 清空本地历史会议记录列表
- 新增 NEPreMeetingService.getInviteInfo 获取当前语言环境下的邀请信息
- 新增 NEPreMeetingService.getMeetingItemByInviteCode 根据邀请码获取会议信息
- 新增 NEPreMeetingService.loadWebAppView 加载小应用页面，用于会议历史详情的展示
- 新增 NESettingsService
  - getInterpretationConfig 查询应用同声传译配置
  - getScheduledMemberConfig 查询应用预约会议指定成员配置
  - isNicknameUpdateSupported 查询应用是否支持编辑昵称
  - isAvatarUpdateSupported 查询应用是否支持编辑头像
  - isCaptionsSupported 查询应用是否支持字幕功能
  - isTranscriptionSupported 查询应用是否支持转写功能
  - isGuestJoinSupported 查询应用是否支持访客入会
  - getAppNotifySessionId 查询应用 session 会话 Id
  - setCloudRecordConfig 设置云录制配置
  - getCloudRecordConfig 查询云录制配置
- 新增 NEMeetingAccountService
- 新增 NEContactsService
- 新增 NEMeetingInviteService
- 新增 NEMeetingMessageChannelService
- 新增 NEMeetingService
- 新增 NEPreMeetingService

### Compatibility

- **room-kit:** ⚙️ Compatible with `NERTC` version `5.6.21`
- **room-kit:** ⚙️ Compatible with `NIM` version `9.15.1`
- **room-kit:** ⚙️ Compatible with `NERoomKit` version `1.30.0`

## v4.6.2(2024-06-28)

### New Features

- 支持电话拨入会议，邀请信息中展示电话拨入信息

### Bug Fixes

-修复会前预约弹窗编辑报错问题

## v4.6.0(2024-06-13)

### New Features

- 全新的视觉与交互
- 支持会前配置同声传译译员和译员、会中开启和关闭同声传译功能
- 新增共享批注功能，在桌面端发起共享，桌面端和 web 可对共享画面进行批注，在其他端进行观看
- 会议内通知中心不展示录制完成的通知，也不展示录制完成的弹窗
- 等候室成员，在收到本次会议邀请时自动准入
- 支持会中展示会议最大人数，会中达到最大人数情况下的提示弹窗
- 在点击切换扬声器设备时，如果为静音时增加弹窗提示
- 端正在说话提示条支持拖动
- 语音激励功能支持开关
- 支持预约会议时对时区的选择
- 共享屏幕发起时多屏幕增加标识

## v4.5.0(2024-05-10)

### New Features

- 支持配置入会是否拉取和展示小应用
- 支持配置入会是否展示通知中心菜单
- 预约会议支持设置是否允许访客入会
- 预约会议支持预选参会者列表并指定身份
- 支持通讯录邀请入会

### Bug Fixes

修复离开会议未销毁情况下重新入会聊天室监听事件重复添加问题

### Api Changes

- 新增`noWebApps`属性,表示入会是否拉取和展示小应用
- 新增`showScreenShareUserVideo`属性,h5 端是否显示共享者的摄像头画面
- 新增`noNotifyCenter`属性,表示入会是否展示通知中心菜单
- 新增`setEnableGuestJoin` 和 `isGuestJoinEnabled` 接口,设置是否允许访客入会
- 新增`scheduledMemberList`属性,表示预选参会者列表并指定身份，配置预约成员开启时有效
- 新增`getScheduledMembers`属性,表示预选参会者列表并指定身份，配置预约成员开启时有效
- 新增`getScheduledMembers`接口,获取预约会议成员列表
- 新增`searchAccount`接口,用于通讯录搜索
- 新增`getAccountInfoList`接口,用于通讯录成员信息查询
- 新增`NEMeetingInviteService`
  - 新增`acceptInvite`接口,用于通过邀请 加入一个当前正在进行中的会议，只有完成 SDK 的登录鉴权操作才允许加入会议。
  - 新增`rejectInvite`接口,拒绝邀请
  - 新增`addEventListener`接口,添加邀请消息监听
  - 新增`removeEventListener`接口,移除邀请消息监听
  - 新增`onMeetingInviteStatusChanged`邀请状态变更时会回调该方法，该方法在 UI 线程调用

### Compatibility

- **room-kit:** ⚙️ Compatible with `NERTC` version `5.5.40`
- **room-kit:** ⚙️ Compatible with `NIM` version `9.15.1`
- **room-kit:** ⚙️ Compatible with `NERoomKit` version `1.28.0`

## v4.4.0(2024-04-02)

### New Features

- 支持会中锁定特定用户视频画面
- 支持会议创建者收回主持人权限
- 支持会中全部准入、全部移除等候室成员
- 支持本次会议自动准入等候室成员
- 支持聊天室私聊功能和聊天权限控制
- 入会时支持指定参会者头像

### Compatibility

- **room-kit:** ⚙️ Compatible with `NERTC` version `5.5.33`
- **room-kit:** ⚙️ Compatible with `NIM` version `9.15.1`
- **room-kit:** ⚙️ Compatible with `NERoomKit` version `1.27.0`

## v4.3.0(2024-03-06)

### New Features

- 新增断开音频功能，支持连接/断开本地音频
- 支持管理员修改参会者昵称
- 支持用户头像显示
- 支持音频模式

### Compatibility

- **room-kit:** ⚙️ Compatible with `NERTC` version `5.5.2004`
- **room-kit:** ⚙️ Compatible with `NIM` version `9.15.0.1778`

## v4.2.1(2023-01-30)

### Bug Fixes

- **Meeting:** 🎸 修复聊天室消息过多时候，导致的应用卡顿问题。

## v4.2.0(2023-01-19)

### New Features

- **Meeting:** 🎸 新增支持直播设置背景图
- **Meeting:** 🎸 优化水印样式

### Compatibility

- **room-kit:** ⚙️ Compatible with `NERTC` version `5.5.207`
- **room-kit:** ⚙️ Compatible with `NIM` version `9.14.2`

## v4.1.0(2023-01-10)

### New Features

- **Meeting:** 🎸 新增等候室功能
- **Meeting:** 🎸 新增会议水印功能，可以在会议中开启水印，后台可以配置水印内容、水印样式、是否强制打开(强制打开则端上不展示设置入口)
- **Meeting:** 🎸 新增聊天记录预览功能，会议创建者可以在历史会议中查看会议聊天记录及导出
- **Meeting:** 🎸 新增安全模块，支持等候室开关、水印开关和锁定会议开关

### Compatibility

- **room-kit:** ⚙️ Compatible with `NERTC` version `5.5.206`
- **room-kit:** ⚙️ Compatible with `NIM` version `9.14.2`

## v4.0.2(2023-12-14)

### Bug Fixes

- **Meeting:** 🎸 修复异常关闭设置窗口出现报错问题

## v4.0.1(2023-12-13)

### New Features

- **Meeting:** 🎸 优化菜单栏字样显示效果

## v4.0.0(2023-12-11)

### New Features

- **Meeting:** 🎸 桌面端 网易会议 V4.0.0 Electron 版本
- **Meeting:** 🎸 网易会议 V4.0.0 - Electron 新布局 UI
- **Meeting:** 🎸 网易会议 V4.0.0 - Electron 云录制功能
- **Meeting:** 🎸 网易会议 V4.0.0 - Electron 聊天室撤回功能
