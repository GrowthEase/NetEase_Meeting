## v4.5.0(2024-04-02)

### New Features

* 支持配置入会是否拉取和展示小应用
* 支持配置入会是否展示通知中心菜单
* 预约会议支持设置是否允许访客入会
* 预约会议支持预选参会者列表并指定身份
* 支持通讯录邀请入会

### Bug Fixes
修复离开会议未销毁情况下重新入会聊天室监听事件重复添加问题
### Api Changes
 * 新增`noWebApps`属性,表示入会是否拉取和展示小应用
 * 新增`showScreenShareUserVideo`属性,h5端是否显示共享者的摄像头画面
 * 新增`noNotifyCenter`属性,表示入会是否展示通知中心菜单
 * 新增`setEnableGuestJoin` 和 `isGuestJoinEnabled` 接口,设置是否允许访客入会
 * 新增`scheduledMemberList`属性,表示预选参会者列表并指定身份，配置预约成员开启时有效
 * 新增`getScheduledMembers`属性,表示预选参会者列表并指定身份，配置预约成员开启时有效
 * 新增`getScheduledMembers`接口,获取预约会议成员列表
 * 新增`searchAccount`接口,用于通讯录搜索
 * 新增`getAccountInfoList`接口,用于通讯录成员信息查询
 * 新增`NEMeetingInviteService`
    * 新增`acceptInvite`接口,用于通过邀请 加入一个当前正在进行中的会议，只有完成SDK的登录鉴权操作才允许加入会议。
    * 新增`rejectInvite`接口,拒绝邀请
    * 新增`addEventListener`接口,添加邀请消息监听
    * 新增`removeEventListener`接口,移除邀请消息监听
    * 新增`onMeetingInviteStatusChanged`邀请状态变更时会回调该方法，该方法在UI线程调用
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
