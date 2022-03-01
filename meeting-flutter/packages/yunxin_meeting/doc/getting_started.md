## 概述

网易会议 Flutter SDK 提供了一套简单易用的接口，允许开发者通过调用 NEMeeting SDK(以下简称 SDK )提供的 API，快速地集成音视频会议功能至现有 Flutter 应用中。

## 快速接入

#### 开发环境准备

| 名称 | 要求 |
| :------ | :------ |
| Dart 版本 | ">=2.12.0 <3.0.0" |
| Flutter 版本 | ">=1.22.0" |
| 最低 Android 版本 | API 21, Android 5.0以上 |
| 最低 iOS 版本 | iOS 10.0以上 |
| CPU 架构支持 | ARM64、ARMV7 真机，不支持模拟器|
| IDE | Visual Studio Code、Android Studio、XCode |

* [Flutter 开发环境搭建参考](https://flutter.dev/docs/get-started/install)

#### SDK快速接入

1. 新建 Flutter App 工程

    a. 运行 Android Sudio，顶部菜单依次选择 “File -> New -> New Flutter Project...”新建工程，选择'Flutter App'，单击Next。

    ![new flutter project](images/new_flutter_project.png)
    
    b. 配置工程相关信息。

    ![configure project](images/configure_project.png)
    
    c. 单击'Finish'完成工程创建。

2. 添加SDK编译依赖

    修改工程目录下的'pubspec.yaml'文件，添加网易会议 Flutter Package 的依赖。
    ```yaml
    dependencies:
      yunxin_meeting: ^0.1.0-rc.0
    ```
    之后通过执行 Flutter CLI 命令'flutter pub get'拉取依赖。

    在 Dart 代码中添加相应 import 语句。

    ```dart
    import 'package:yunxin_meeting/meeting_sdk.dart';
    import 'package:yunxin_meeting/meeting_sdk_interface.dart';
    ```

3. 权限处理

    网易会议 SDK 正常工作需要应用获取以下权限，由宿主进行相应设置：

    - Android 权限声明：在 'android/app/src/main/AndroidManifest.xml' 文件中声明以下权限：
  
    ```xml
    <!-- 网络相关 -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />

    <!-- 读写外部存储 -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

    <!-- 多媒体 -->
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />

    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />

    
    ```
    - iOS 权限声明：在 'ios/Runner/Info.plist' 文件中声明：
    
    ```xml
    <key>NSCameraUsageDescription</key>
	<string>xxx将会在您使用发起会议、加入会议等功能时使用您的相机</string>
	<key>NSMicrophoneUsageDescription</key>
	<string>xxx将会在您使用发起会议、加入会议等功能时使用您的麦克风</string>
    ```

4. SDK初始化

    在使用SDK其他功能之前首先需要完成SDK初始化，代码示例如下：
    ```dart
    import 'package:yunxin_meeting/meeting_sdk.dart';
    import 'package:yunxin_meeting/meeting_sdk_interface.dart';

    void initMeeting() {
      NEMeetingSDK.instance.initialize(
          NEMeetingSDKConfig(
            appKey: 'Your_Meeting_AppKey',
            config: NEForegroundServiceConfig(),
          ), ({errorCode, errorMessage, result}) {
        if (errorCode == NEMeetingErrorCode.success) {
          //todo
        } else {
          //todo
        }
      });
    }    
    ```

5. 调用相关接口完成特定功能，详情请参考API文档。

- [登录鉴权](#登录鉴权)
    ```dart
    //Token登录
    NEMeetingSDK.instance.loginWithToken(String accountId, String token, NECompleteListener listener);

    //SSOToken登录
    NEMeetingSDK.instance.loginWithNEMeeting(String username, String password, NECompleteListener listener);

    ```
- [创建会议](#创建会议)
    ```dart
    NEMeetingService meetingService = NEMeetingSDK.instance.getMeetingService();
    meetingService. startMeeting(
      BuildContext context, NEStartMeetingParams param, NEStartMeetingOptions opts, NECompleteListener listener);
    ```
- [加入会议](#加入会议)
    ```dart
    NEMeetingService meetingService = NEMeetingSDK.instance.getMeetingService();
    meetingService.joinMeeting(
      BuildContext context, NEJoinMeetingParams param, NEJoinMeetingOptions opts, NECompleteListener listener);
    ```
- [注销登录](#注销)
    ```dart
    NEMeetingSDK.instance.logout(NECompleteListener listener);
    ```

#### SDK 模块介绍

- NEMeetingSDK

    会议SDK入口类，提供SDK初始化、登录、登出以及获取其他Service类的能力；

    API文档：https://pub.dev/documentation/yunxin_meeting/latest/meeting_sdk/NEMeetingSDK-class.html

- NEMeetingService
  
    会议服务类，可创建会议、加入会议、查询与监听会议状态；

    API文档：https://pub.dev/documentation/yunxin_meeting/latest/meeting_sdk/NEMeetingService-class.html
  
- NEMeetingAccountService
  
    会议账号服务类，可查询当前登录的会议账号信息；

    API文档：https://pub.dev/documentation/yunxin_meeting/latest/meeting_sdk/NEMeetingAccountService-class.html

- NEPreMeetingService
  
    会议前服务类，可预约会议、查询、修改预约会议等；

    API文档：https://pub.dev/documentation/yunxin_meeting/latest/meeting_sdk/NEPreMeetingService-class.html

- NESettingsService
  
    会议设置服务，可设置入会时、会议中的一些配置信息，如入会时的音视频开关选项；

    API文档：https://pub.dev/documentation/yunxin_meeting/latest/meeting_sdk/NESettingsService-class.html



## 附录

### 入会选项

SDK提供了丰富的入会选项可供设置，用于自定义会议内的UI显示、菜单、行为等。列举如下：

|选项名称|选项说明|默认值|
| :------ | :------ | :------ |
| noVideo | 入会时关闭视频 | true |
| noAudio | 入会时关闭音频 | true |
| noMinimize | 隐藏会议内“最小化”功能 | true |
| noInvite | 隐藏会议内“邀请”功能 | false |
| noChat | 隐藏会议内“聊天”功能 | false |
| noGallery | 关闭会议中“画廊”模式功能 | false |
| noSwitchCamera | 关闭会议中“切换摄像头”功能 | false |
| noSwitchAudioMode | 关闭会议中“切换音频模式”功能 | false |
| noWhiteBoard | 关闭会议中“白板”功能 | false |
| noCloudRecord | 关闭会议“录制中”功能 | true |
| noRename | 关闭会议中“改名”功能 | false |
| showMeetingTime | 显示会议“持续时间” | false |
| defaultWindowMode | 会议模式(普通、白板) | `WindowMode.gallery` |
| meetingIdDisplayOption | 会议内会议ID显示规则 | `MeetingIdDisplayOption.displayAll` |
| fullToolbarMenuItems | 会议内工具栏菜单列表 | NULL |
| fullMoreMenuItems | 会议内更多展开菜单列表 | NULL |