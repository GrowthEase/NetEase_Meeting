# Electron 接入手册

## 1. 环境准备

### 1.1 环境要求

1. 操作系统：win7、win10、win11 的 32 位和 64 位，MacOS 10.11 及以上
2. nodejs 18.19 以上
3. electron 版本 24.8.3

### 1.2 安装

```
$ npm install --save nemeeting-electron-sdk
# or
$ yarn add nemeeting-electron-sdk
# or
$ pnpm add nemeeting-electron-sdk
```

## 2. SDK 快速接入

### 2.1 导入 SDK

1. typescript

```typescript
import NEMeetingKit from 'nemeeting-electron-sdk'
```

2. javascript

```javascript
const { default: NEMeetingKit } = require('nemeeting-electron-sdk')
```

### 2.2 初始化 SDK

```typescript
const neMeetingKit = NEMeetingKit.getInstance()
const appKey = ''
const serverUrl = ''
neMeetingKit.initialize({
  appKey,
  serverUrl,
})
```

### 2.3 账户登录，登出

> 需要先初始化 SDK

```typescript
//使用 账号密码 登录
const neMeetingKit = NEMeetingKit.getInstance()
const accountService = neMeetingKit.getAccountService()
// 用户账户
const userUuid = ''
// 用户密码
const password = ''
accountService.loginByPassword(userUuid, password)
```

```typescript
//账户登出
const neMeetingKit = NEMeetingKit.getInstance()
const accountService = neMeetingKit.getAccountService()

accountService.logout()
```

### 2.4 显示会前设置页面，包含音视频预览

> 需要先初始化 SDK，并且登录账号

```typescript
const neMeetingKit = NEMeetingKit.getInstance()
const settingsService = neMeetingKit.getSettingsService()

settingsService.openSettingsWindow()
```

### 2.5 预约会议

> 需要先初始化 SDK，并且登录账号

```typescript
const neMeetingKit = NEMeetingKit.getInstance()
const preMeetingService = neMeetingKit.getPreMeetingService()

preMeetingService.createScheduleMeetingItem().then(({ data: meetingItem }) => {
  // 修改预约会议信息
  meetingItem.subject = ''
  preMeetingService.scheduleMeeting(meetingItem)
})
```

### 2.6 开始会议，加入会议，离开当前会议

> 需要先初始化 SDK，并且登录账号

```typescript
// 开始会议
const neMeetingKit = NEMeetingKit.getInstance()
const meetingService = neMeetingKit.getMeetingService()

const param = {
  displayName: '入会昵称',
}

meetingService.startMeeting(param)
```

```typescript
// 加入会议
const neMeetingKit = NEMeetingKit.getInstance()
const meetingService = neMeetingKit.getMeetingService()

const param = {
  displayName: '入会昵称',
  // 会议号
  meetingNum: '123456',
}

meetingService.joinMeeting(param)
```

```typescript
// 离开当前会议
const neMeetingKit = NEMeetingKit.getInstance()
const meetingService = neMeetingKit.getMeetingService()
// false: 离开会议；true: 离开并结束会议
const closeIfHost = false

meetingService.leaveCurrentMeeting(closeIfHost)
```

## 3.常用定制化功能

### 3.1 定制会议中菜单

```typescript
// 通过 startMeeting 或 joinMeeting opts 传入
const neMeetingKit = NEMeetingKit.getInstance()
const meetingService = neMeetingKit.getMeetingService()

const param = {
  displayName: '入会昵称',
  // 会议号
  meetingNum: '123456',
}

const opts = {
  fullMoreMenuItems: [
    {
      // 自定义菜单需要 id 大于 100
      itemId: 101,
      visibility: NEMenuVisibility.VISIBLE_ALWAYS,
      singleStateItem: {
        // 按钮图标
        icon: '',
        // 按钮文案
        text: '',
      },
    },
  ],
}

meetingService.joinMeeting(param， opts)
```

### 3.2 定制会议中菜单回调

```typescript
const neMeetingKit = NEMeetingKit.getInstance()
const meetingService = neMeetingKit.getMeetingService()

const meetingOnInjectedMenuItemClickListener = {
  onInjectedMenuItemClick(clickInfo, meetingInfo) {
    // 菜单点击回调
  },
}

meetingService.setOnInjectedMenuItemClickListener(
  meetingOnInjectedMenuItemClickListener
)
```

## 4. 更多功能

请参考《NEMeetingSDK 接口参考》文档
