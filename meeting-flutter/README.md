# NetEase Meeting Flutter

本项目是网易会议的 Flutter 实现，包含两个主要模块：`meeting_app` 和 `meeting_kit`。

## 项目结构

### meeting_app

`meeting_app` 是主应用程序模块，其依赖 `meeting_kit` 提供的接口，实现了会前会后的诸多功能，包括应用登录、预约会议、创建会议、加入会议、查看历史会议详情等功能。

`meeting_app` 的核心代码结构说明如下：

```
meeting_app/
├── lib/                                 # 源代码目录
│   ├── auth/                            # 登录相关页面
│   │   ├── login_mobile.dart            # 手机号登录
│   │   ├── login_corp_account.dart      # 企业账号登录
│   │   ├── login_guest.dart             # 游客登录
│   │   ├── login_sso.dart               # SSO登录
│   ├── error_handler/                   # 错误处理
│   ├── language/                        # 多语言支持
│   ├── meeting/                         # 会议核心功能
│   │   ├── meeting_create.dart          # 创建会议
│   │   ├── meeting_join.dart            # 加入会议
│   │   ├── history_meeting.dart         # 历史会议列表
│   │   ├── history_meeting_detail.dart  # 历史会议详情
│   ├── pre_meeting/                     # 预约会议
│   ├── routes/                          # 路由管理
│   │   ├── entrance.dart                # 未登录主页
│   │   ├── home_page.dart               # 已登录主页
│   ├── service/                         # 服务层
│   │   ├── auth/                        # 登录服务
│   │   │   ├── auth_manager.dart        # 登录管理
│   ├── setting/                         # 设置相关页面
│   ├── utils/                           # 工具类
│   │   ├── nav_register.dart            # 路由注册
│   └── main.dart                        # 主入口文件
├── assets/                              # 资源文件
├── ios/                                 # iOS 平台相关
├── android/                             # Android 平台相关
```

### meeting_kit


`meeting_kit` 为会议组件 UIKit 库，主要提供入会后的所有核心功能实现。该库对外提供初始化、登录、预约会议、创建会议以及加入会议等接口。调用方使用对应的接口入会后，UIKit 会主动拉起会中页面，并提供会议的整个生命周期业务逻辑实现和管理。

如果开发者仅需要会中的实现，可以仅依赖 `meeting_kit` 库，通过调用 `meeting_kit` 提供的接口实现自己的业务逻辑，而不需要关心或依赖 `meeting_app`。

`meeting_kit` 的核心代码结构说明如下：

```
meeting_kit/
├── lib/                                            # 源代码目录
│   ├── src/                                        # 核心实现
│   ├── l10n/                                       # 国际化资源
│   ├── meeting_core/                               # 会控实现
│   ├── meeting_kit/                                # 接口和服务
│   │   ├── contacts_service.dart                   # 联系人服务接口
│   │   ├── meeting_account_service.dart            # 会议账号服务接口
│   │   ├── meeting_service.dart                    # 会议服务接口
│   │   ├── settings_service.dart                   # 设置服务接口
│   │   ├── pre_meeting_service.dart                # 预约会议服务接口
│   │   ├── meeting_message_channel_service.dart    # 会议消息通道服务接口
│   ├── meeting_ui/                                 # UI 组件
│   │   ├── pages/                                  # 会议页面
│   │   │   ├── meeting_page.dart                   # 会中主页页面
│   │   │   ├── meeting_chatroom_page.dart          # 会议聊天室页面 
│   │   │   ├── meeting_members_page.dart           # 会议成员页面
│   │   │   ├── meeting_waiting_room_page.dart      # 会议等待室页面
│   │   │   ├── meeting_whiteboard_page.dart        # 会议白板页面
│   ├── meeting_assets/                             # 会议资源
│   ├── meeting_feedback/                           # 反馈功能
│   ├── meeting_localization/                       # 本地化
│   └── meeting_plugin/                             # 原生插件能力封装
├── assets/                                         # 资源文件
├── example/                                        # 示例代码
├── ios/                                            # iOS 平台相关
├── android/                                        # Android 平台相关
```

`meeting_kit` 提供的接口可参考 [meeting_kit 接口文档](https://doc.yunxin.163.com/meeting/client-apis?platform=client)。


## 快速开始

### 下载安装 Flutter

请参考 [Flutter 官网](https://docs.flutter.dev/get-started/install/macos/mobile-android#download-then-install-flutter) 下载安装 Flutter。

> 请确保 Flutter 版本为 3.22.2 及以上。

### 下载依赖

在 `meeting-app` 根目录下执行以下命令安装依赖：

```bash
$ cd meeting-app
$ flutter pub get
```

### 运行项目

在 `meeting-app` 根目录下执行以下命令运行项目：

```bash
$ flutter run
```

> 运行前，请确保已经连接到 Android 或 iOS 真机设备。

### 完成登录

1. 您需要[开通网易会议解决方案](https://doc.yunxin.163.com/meeting/concept/TkzMjExNDY?platform=client)，并获取到 AppKey 后，才能完成登录。
2. 通过管理后台[设置企业代码](https://doc.yunxin.163.com/meeting/concept/DI1MDY1ODg?platform=client)，并完成[创建账号](https://doc.yunxin.163.com/meeting/concept/jU1MzI3MzU?platform=client)，才能进行后续登录操作。
3.  APP 端页面输入 **企业代码**，选择合适的方式进行登录：[SSO登录](https://doc.yunxin.163.com/meeting/concept/jE0MjEwNzc?platform=client) 和 [账号密码登录](https://doc.yunxin.163.com/meeting/concept/jAwMTA5MDY?platform=client)


### 更多定制开发

请参考 [定制开发](./meeting_app/README.md) 文档。
