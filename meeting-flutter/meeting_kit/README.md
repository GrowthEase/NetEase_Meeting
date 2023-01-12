# meetingservice

A new Flutter package.

## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

### meeting-sdk-android模块
> 对外接口为Java API，用过Channel通道invokeMethod meeting_sdk模块
![img](code_img/meeting-sdk-android流程图.png)

### meeting_sdk模块
> 以package的方式，为Flutter 应用提供Dart API.会议SDK全局接口，提供初始化、管理其他会议相关子服务的能力
![img](code_img/meeting_sdk流程图.png)

### meeting_core模块
> 以package的方式，为Flutter 应用提供Dart API。主要提供RTC能力和dart UI。view使用platform View
![img](code_img/meeting_core流程图.png)

### meeting_core模块
> 以package的方式，为Flutter 应用提供Dart API。主要提供repo数据仓库
![img](code_img/meeting_service流程图.png)
