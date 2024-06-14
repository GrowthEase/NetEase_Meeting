# 网易会议 H5 组件 SDK

## 简介

网易会议 H5 组件 SDK 提供了一套简单易用的接口，允许开发者通过调用 NEMeeting SDK(以下简称 SDK)提供的 API，快速地集成音视频会议功能至现有 web 应用中

## NEMeetingKit

| 方法                                                                              | 功能               | 起始版本 |
| --------------------------------------------------------------------------------- | ------------------ | -------- |
| [init](./interfaces/NEMeetingKit.html#init)                                       | 会议 初始化        | V1.0.0   |
| [destroy](./interfaces/NEMeetingKit.html#destroy)                                 | 会议 销毁          | V1.0.0   |
| [checkSystemRequirements](./interfaces/NEMeetingKit.html#checkSystemRequirements) | 检测浏览器是否兼容 | V1.0.0   |

## 房间管理

| 方法                                            | 功能     | 起始版本 |
| ----------------------------------------------- | -------- | -------- |
| [login](./interfaces/NEMeetingKit.html#login)   | 登录     | V1.0.0   |
| [logout](./interfaces/NEMeetingKit.html#logout) | 登出     | V1.0.0   |
| [join](./interfaces/NEMeetingKit.html#join)     | 加入会议 | V1.0.0   |

## 房间事件

| 事件                                                                                      | 描述                     | 起始版本 |
| ----------------------------------------------------------------------------------------- | ------------------------ | -------- |
| [on](./interfaces/NEMeetingKit.html#on)                                                   | 房间事件监听方法         | V1.0.0   |
| [off](./interfaces/NEMeetingKit.html#off)                                                 | 移除事件监听方法         | V1.0.0   |
| [addMeetingStatusListener](./interfaces/NEMeetingKit.html#addMeetingStatusListener)       | 房间状态变更监听方法     | V3.16.0  |
| [removeMeetingStatusListener](./interfaces/NEMeetingKit.html#removeMeetingStatusListener) | 移除房间状态变更监听方法 | V3.16.0  |
