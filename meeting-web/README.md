# 网易会议 web 组件 SDK

## 简介

网易会议 web 组件 SDK 提供了一套简单易用的接口，允许开发者通过调用 NEMeeting SDK(以下简称 SDK)提供的 API，快速地集成音视频会议功能至现有 web 应用中

## NEMeetingKit

| 方法                                                                   | 功能         | 起始版本 |
| ---------------------------------------------------------------------- | ------------ | -------- |
| [init](./interfaces/NEMeetingKit.NEMeetingKit-1.html#init)             | 会议 初始化  | V3.0.0   |
| [destroy](./interfaces/NEMeetingKit.NEMeetingKit-1.html#destroy)       | 会议 销毁    | V3.0.0   |
| [afterLeave](./interfaces/NEMeetingKit.NEMeetingKit-1.html#afterLeave) | 离开房间回调 | V3.0.0   |
| [reuseIM](./interfaces/NEMeetingKit.NEMeetingKit-1.html#reuseIM)       | IM 复用      | V3.2.0   |

## 房间管理

| 方法                                                           | 功能     | 起始版本 |
| -------------------------------------------------------------- | -------- | -------- |
| [login](./interfaces/NEMeetingKit.NEMeetingKit-1.html#login)   | 创建房间 | V3.0.0   |
| [create](./interfaces/NEMeetingKit.NEMeetingKit-1.html#create) | 进入房间 | V3.0.0   |
| [join](./interfaces/NEMeetingKit.NEMeetingKit-1.html#join)     | 离开房间 | V3.0.0   |

## 房间事件

| 事件                                                   | 描述             | 起始版本 |
| ------------------------------------------------------ | ---------------- | -------- |
| [on](./interfaces/NEMeetingKit.NEMeetingKit-1.html#on) | 房间事件监听方法 | V3.0.0   |
