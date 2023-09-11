# v3.16.0(Sep 6, 2023)

### New Features
* 当从会议中彻底断开时增加了提示允许重新入会
* 支持在会议过程中响应会议时长的修改

### Bug Fixes
* 修复 macOS 暗色系统模式下应用有黑色边框问题
* 修复网络质量提示不准确问题
* 修复同时调用 API 有个别接口没有返回问题
* 修复从界面左上角或右上角结束会议没有正确退出问题
* 修复结束会议后部分 Dialog 依然展示问题
* 修复聊天室发送图片会清空当前输入框问题
* 修复极端场景下主持人侧不展示举手人数问题
* 修复断网情况下应用打开后自动退出问题

### Behavior changes
* 从设置界面中移除了 480P 选项，只保留高清与自动模式
* 不再支持订阅全部远端高清视频流功能
* 移除了延迟取消订阅功能，当画布销毁后立即执行取消订阅
* 屏幕共享视频侧边栏最后一页始终展示最大 4 个人

### Compatibility
* Compatible with `NERoomKit` version `1.20.0`.

# v3.15.0(Aug 11, 2023)

### New Features
* 增加设置和获取屏幕共享视频侧边栏展示方式接口 `NEOtherController::setSharingSidebarViewMode`，`NEOtherController::getSharingSidebarViewMode`
* 增加对音视频流加密支持 `NEMeetingParams::NEEncryptionConfig`

### Bug Fixes
* 修复网格视图中间有过大间隙问题
* 修复网格视图模式下拖动窗口出现闪烁问题
* 修复在收到取消联席主持人身份通知时没有将结束会议的弹窗关闭问题
* 修复部分场景下加入会议会看到上一次会议打开的弹窗问题
* 修复共享时成员管理窗口右键菜单在窗口关闭并重新打开后依然显示问题
* 修复部分场景下未展示主持人关闭音视频通知的问题
* 修复个别场景下在停止共享后依然可以看到共享应用的边框问题
* 修复以管理员身份运行无法使用白板问题
* 修复白板中无法下载文件问题
* 修复切换账号时没有重新获取账户配置信息问题
* 修复可以多次运行主会议应用问题
* 修复清理会议历史后没有弹出提示问题
* 修复重复加入历史收藏的会议时，收藏的会议被删除问题
* 修复相同账号两端同时创建不同会议时没有回调及崩溃问题
* 修复直播界面在共享者结束共享后默认选择的视图不正确问题
* 修复直播设置界面 GridLayout 引起的崩溃问题
* 修复屏幕共享失败没有提示问题
* 修复 Windows 下窗口最小化还原出现一条白色边缘线问题

### Behavior changes
* 加入带密码会议时会在验证密码成功后先切换到 `NEMeeting::MEETING_CONNECTING` 状态
* 调整焦点视图模式上方小窗口的宽度为总窗口宽度的 15%，跟随窗口宽度变更

### Compatibility
* Compatible with `NERoomKit` version `1.19.0`.

# v3.14.0(Jul 6, 2023)

### New Features
* 增加会议生命周期管理模块用于统计创建/加入会议等场景成功率及耗时
* 创建会议时增加 subject 参数用于自定义会议主题

### Bug Fixes
* 修复登出时未隐藏设置窗口问题
* 修复日志中大量 `Detected anchors on an item that is managed by a layout` 错误
* 修复因成员网络状态变更引起的崩溃

### Compatibility
* Compatible with `NERoomKit` version `1.17.0`.

# v3.10.0(Mar 23, 2023)

### Bug Fixes
* 修复美颜等级切换账号无效的问题
* 修复进入聊天室失败时，没有提示的问题
* 修复入会超时等错误时，返回入会状态不对的问题
* 修复一些场景下，切换PPT失败的问题
* 修复一些场景下，会崩溃的问题

### Compatibility
* Compatible with `NERoomKit` version `1.13.0`.

# v3.9.0(Mar 02, 2023)

### New Features
* 本地视频增加镜像开关
* 接收共享时增加视频窗口收缩或扩展按钮
* 增加网络信息提示窗口
* 聊天室编辑框支持图片和文本同时编辑
* 支持显示移动端在接打电话时的状态

### Behavior changes
* 优化会议信息提示窗的交互
* 优化共享屏幕时流畅模式选择和共享声音的选择状态为当前会议内有效
* 优化共享屏幕时选择桌面弹窗的显示和隐藏交互
* 聊天室消息发送失败后消息保留在编辑框的优化

### Bug Fixes
* 修复音频设备中的虚拟设备隐藏的问题
* 修复窗口拖动改变大小的问题
* 修复macOS下会议全屏时，收到聊天室消息会退出全屏的问题
* 修复macOS下会议全屏时，提示设备变更等消息会退出全屏的问题
* 修复其他人停止共享时，本端全屏时会退出全屏的问题
* 修复初始化时，当全局配置拉取失败没有返回的问题
* 修复自动退出时，偶现退出卡死的问题
* 修复登录失败后，部分状态没有重置的问题
* 修复部分翻译错误的问题
* 修复设置虚拟背景后，内存占用较高的问题
* 修复下拉选择框，右侧三角箭头显示模糊的问题
* 修复因为网络等原因聊天室消失发送失败，无提示的问题
* 修复更多菜单在被动离开后再次入会没有隐藏的问题
* 修复反馈窗口在长按空格键时会关闭的问题
* 修复Windows下窗口被拖动到任务栏里，拖不出来的问题
* 修复macOS下会议全屏时，被动离开会议但界面没退出的问题
* 修复成员列表里的更多菜单弹出后，有离开或者加入的成员时导致排序位置发生变更，再操作菜单项时操作的还是旧成员的问题
* 修复主持人设置其他人为联席主持人，联席主持人设置了全体静音，主持人又移交了主持人给联席主持人，然后操作音频成功而没有举手提示的问题
* 修复举手后设置联席主持人，新的联席主持人管理参会者上方无举手人数弹窗的问题
* 修复聊天室弹窗会显示在其他应用窗口前面的问题
* 修复长按空格键再弹出成员更多菜单时，会响应菜单项的问题
* 修复获取成员列表时，偶现数组越界导致崩溃的问题
* 修复成员列表中名称太长显示的问题

### Compatibility
* Compatible with `NERoomKit` version `1.12.0`.

# v3.8.0(Jan 12, 2023)

### New Features
* 支持配置私有化服务器地址 `NEMeetingKitConfig#serverUrl` ，可下载线上的私有化配置并使用
* 增加设置本地视频帧率接口 `NEVideoController#setMyVideoFramerate`
* 聊天室消息支持部分选中复制
* 隐藏音频设备中的虚拟设备

### Bug Fixes
* 修复共享时，视图按钮不能切换的图标显示问题
* 修复自定义菜单文案长度校验的问题
* 修复匿名入会和实名入会切换后不能入会的问题
* 修复自定义按钮里有白板时，共享下的显示问题
* 修复自定义按钮里有白板时，白板按钮图标显示的问题
* 修复部分翻译不正确的问题
* 修复入会后最大化窗口，离开会议再次入会时窗口显示的高度问题
* 修复反馈描述太长超出弹窗的问题
* 修复静音时是否发送音频的问题
* 修复会中改名不能为空的问题
* 修复成员列表搜索框显示的问题
* 修复本端音视频状态偶现不正确的问题
* 优化美颜开关偶现不生效的问题
* 优化初始化和反初始化接口里的逻辑问题
* 优化ipc的超时机制
* 优化当前讲话者的显示

# v3.7.1(Dec 12, 2022)

### New Features
* 优化入会自定义菜单文本长度的校验

### Bug Fixes
* 修复多次匿名入会的问题

# v3.7.0(Dec 07, 2022)

### New Features
* 优化音频开关，增加入会时是否发布音频流参数 `NEMeetingOptions::unpubAudioOnMute`
* 增加静音检测功能，增加入会时是否检测的参数 `NEMeetingOptions::detectMutedMic`
* 初始化增加显示语言参数 `NEMeetingKitConfig::language`
* 优化视频显示效果

### Bug Fixes
* 修复macOS下会议在切到其他软件后，切换不回来的问题
* 修复美颜级别默认没生效的问题
* 修复macOS下软件共享，有时绿框不显示的问题

### Compatibility
* Compatible with `NERTC` version `4.6.29`.
* Compatible with `NIM` version `9.7.0.142`.
* Compatible with `WHITEBOARD` version `3.7.2`.

# v3.6.1(Nov 14, 2022)

### New Features

### Behavior changes

### Bug Fixes

### Dependency Updates

# v3.6.0(Nov 1, 2022)

### New Features
* 支持会议应用链接入会
* 支持设置音频设备是否默认选择上次使用的设备`NEAudioController#setMyAudioDeviceUseLastSelected`
* 支持查询音频设备是否默认选择上次使用的设备`NEAudioController#isMyAudioDeviceUseLastSelected`

### Behavior changes
* 会议应用反馈优化

### Bug Fixes
* 解决Macos设置页面美颜选项偶现消失问题

### Dependency Updates
* 更新NERoom SDK到1.9.0

# v3.5.0(Sept 27, 2022)

### New Features
* Windows平台支持64位版本
* 支持开启或关闭长按空格解除静音功能 `NEOtherController#enableUnmuteBySpace`
* 支持查询长按空格解除静音功能开启状态 `NEOtherController#isUnmuteBySpaceEnabled`
* 支持开启白板后，可通过点击日志按钮上传日志

### Bug Fixes
* 解决在移动端取消授权后，桌面端依然有权限的问题
* 解决开启音频入会后，音频状态显示不对的问题

# v3.4.0(Aug 31, 2022)

### New Features
* 支持聊天室图片、文件消息
* 创建/加入会议新增聊天室配置`NEMeetingOptions#chatroomConfig`

### Bug Fixes
* 解决偶现加入会议卡死问题
* 解决断网重连加入会议，聊天室无法发送/接收消息问题
* 解决参会者举手，主持人共享时悬浮窗收起再展开，举手图标消失问题
* 解决创会后获取meetingStatus应该是4，偶现meetingStatus值为3问题

### Compatibility
* Compatible with `NERTC` version `4.6.13`.
* Compatible with `NIM` version `9.1.3.1218`.
* Compatible with `WHITEBOARD` version `3.7.2`.

# v3.3.0(Jul 28, 2022)

### New Features

* 网易会议应用支持历史会议和收藏会议
* 会议组件支持说话者提示
* 会议组件支持会议剩余时间提示: `NEMeetingOptions#showMeetingRemainingTip`
* 会议组件支持查询当前会议创建者id: `NEMeetingInfo#meetingCreatorId`
* 会议组件支持查询当前会议创建者名称: `NEMeetingInfo#meetingCreatorName`

### Behavior changes

* 优化音频设备默认选项

### Bug Fixes

* 解决移动端取消锁定会议，桌面端无反应问题
* 解决windows断网状态下开启音频共享，恢复网络后音频共享成功的问题
* 解决白板共享者退出房间，本端未关闭白板问题
* 解决焦点视频者退出房间，本端未退出焦点模式问题
* 解决偶现全屏状态点击离开，会议主窗口没有关闭问题
* 解决主持人操作全体打开视频，屏幕共享者的视频直接开启的问题
* 解决主持人取消联席主持人，参会者自动取消举手问题
* 解决windows共享屏幕的时候同步共享本地音频，部分设备静音后讲话其他端仍然可以听到的问题
* 解决主持人的主画面左上角无取消焦点视频按钮的问题

# v3.2.0(Jun 30, 2022)

### New Features

* 支持设置虚拟背景开关: `NEVirtualBackgroundController#enableVirtualBackground`
* 支持查询虚拟背景开关: `NEVirtualBackgroundController#isVirtualBackgroundEnabled`
* 支持设置内置虚拟背景列表: `NEVirtualBackgroundController#setBuiltinVirtualBackgrounds`
* 支持查询内置虚拟背景列表: `NEVirtualBackgroundController#getBuiltinVirtualBackgrounds`
* 支持查询美颜开关: `NEBeautyFaceController#isBeautyFaceEnabled`
* 支持设置美颜级别: `NEBeautyFaceController#setBeautyFaceValue`
* 支持查询美颜级别: `NEBeautyFaceController#getBeautyFaceValue`
* 支持创建会议,指定成员角色 `NEStartMeetingParams#roleBinds`
* 支持预约会议/编辑预约会议,指定成员角色 `NEMeetingItem#roleBinds`
* 支持联席主持人

### Behavior changes

* 优化成员列表展示顺序

### Bug Fixes

* 修复分享窗口时的一些缺陷

# v3.1.0(Jun 2, 2022)

### New Features

* 支持sip入会
* 支持匿名入会: `NEMeetingService#anonymousJoinMeeting`

### Behavior changes

### Bug Fixes

* 解决焦点视图大画面切换卡死问题
* 解决成员多端入会互踢，视频画面展示异常问题
* 解决在屏幕共享状态下踢人，结束共享后画面黑屏问题

# v3.0.1(May 25, 2022)

### New Features

### Behavior changes

### Bug Fixes

* 解决mac应用包无签名问题

# v3.0.0(May 19, 2022)

### New Features

### Behavior changes
* 会控流程重构
* roomkit升级至新版1.1.0
* 修改NEMeetingSDK为 NEMeetingKit
* 修改NEMeetingSDKConfig为 NEMeetingKitConfig
* 删除接口NEMeetingSDKConfig.enableDebugLog
* 删除接口NEMeetingSDKConfig.logSize
* 删除接口NEMeetingOptions.injectedMoreMenuItems

### Bug Fixes

# v2.5.7(Mar 31, 2022)

### New Features

### Behavior changes

* 默认关闭AI降噪
* 更新隐私协议
* 更新G2至4.6.0

### Bug Fixes

# v2.5.0(Mar 4, 2022)

### New Features

### Behavior changes

* 白板升级至G2版本
* 优化入会时长

### Bug Fixes

* 修复mac下无设备权限导致崩溃问题
* 修复mac10.14系统因日志库崩溃问题
* 修复mac下偶现预约会议卡死问题

# v2.4.0(Jan 19, 2022)

### New Features

* 创建会议/加入会议增加全体音视频开关显示配置：`NEMeetingOptions#bNoMuteAllVideo`, `NEMeetingOptions#bNoMuteAllAudio`
* 增加设置SDK使用软件渲染开关接口：`NEMeetingSDK::setSoftwareRender`
* 增加获取SDK使用软件渲染开关接口：`NEMeetingSDK::isSoftwareRender`
* 增加设置音频设备自动选择策略接口：`NEAudioController::setMyAudioDeviceAutoSelectType`
* 增加获取音频设备自动选择策略接口：`NEAudioController::isMyAudioDeviceAutoSelectType`

### Behavior changes

* 优化自己麦克风的显示
* 优化音频开关功能
* 优化macOS下共享应用的选择项

### Bug Fixes

* 修复SDK系统权限提示的问题
* 修复升级安装报错的问题
* 修复Windows下在不同分辨率显示器间拖动SDK窗口，窗口闪烁的问题
* 修复Windows下SDK窗口在第二显示器时，双击窗口放大缩小的问题

# v2.3.0(Dec 28, 2021)

### New Features

* 增加主持人视频会控功能
* 设置界面支持是否自动调节麦克风音量
* 设置界面支持设置通话音质
* 设置界面支持设置分辨率
* 增加主持人视频会控功能
* 创建会议/加入会议增加是否显示tag字段：`NEMeetingOptions#showMemberTag`
* 创建会议增加拓展字段：`NEStartMeetingParams#extraData`
* 预约会议/编辑会议增加拓展字段：`NEMeetingItem#extraData`
* 获取当前会议信息增加拓展字段：`NEMeetingInfo#extraData`
* 创建会议增加会议控制配置字段：`NEStartMeetingParams#controls`
* 预约/编辑会议增加会议控制配置字段：`NEMeetingItem#NEMeetingItemSetting#controls`
* 设置服务增加设置自动调节的开关接口：`NEAudioController::setMyAudioVolumeAutoAdjust`
* 设置服务增加获取自动调节的开关接口：`NEAudioController::isMyAudioVolumeAutoAdjust`
* 设置服务增加自动调节状态变更通知接口：`NESettingsChangeNotifyHandler::OnAudioVolumeAutoAdjustSettingsChange`
* 增加设置通话音质的接口：`NEAudioController::setMyAudioQuality`
* 增加获取通话音质接口：`NEAudioController::getMyAudioQuality`
* 增加通话音质变更通知接口：`NESettingsChangeNotifyHandler::OnAudioQualitySettingsChange`
* 增加设置回声消除的开关接口：`NEAudioController::setMyAudioEchoCancellation`
* 增加获取回声消除的开关接口：`NEAudioController::isMyAudioEchoCancellation`
* 增加回声消除状态变更通知接口：`NESettingsChangeNotifyHandler::OnAudioEchoCancellationSettingsChange`
* 增加设置启用立体音的开关接口：`NEAudioController::setMyAudioEnableStereo`
* 增加获取启用立体音的开关接口：`NEAudioController::isMyAudioEnableStereo`
* 增加启用立体音状态变更通知接口：`NESettingsChangeNotifyHandler::OnAudioEnableStereoSettingsChange`
* 增加设置远端分辨率的接口：`NEVideoController::setRemoteVideoResolution`
* 增加获取远端分辨率的接口：`NEVideoController::getRemoteVideoResolution`
* 增加远端分辨率变更通知接口：`NESettingsChangeNotifyHandler::OnRemoteVideoResolutionSettingsChange`
* 增加设置本地分辨率的接口：`NEVideoController::setMyVideoResolution`
* 增加获取本地分辨率的接口：`NEVideoController::getMyVideoResolution`
* 增加本地分辨率变更通知接口：`NESettingsChangeNotifyHandler::OnMyVideoResolutionSettingsChange`

### Behavior changes

### Bug Fixes

* 修复主持人断网，参会者加入会议，主持人联网，主持人看到参会者不在会议中问题
* 修复参会者举手，主持人断网重新入会，管理参会者上方无举手图标问题
* 修复windows下PowerPoint共享ppt时，出现画面闪烁

# v2.2.0(Dec 9, 2021)

### New Features

* 会议组件增加G2私有化支持
* 会议组件增加SIP开关`NEMeetingOptions::bNoSip`
* 会议组件增加AI降噪开关`NEMeetingOptions::bAudioAINSEnabled`

### Behavior changes

* 会议应用意见反馈优化

### Bug Fixes

* 修复组件IM私有化无效问题
* 修复windows下PPT幻灯片播放，出现共享者ppt小窗没有到底层，遮挡住ppt放映画面问题
* 修复偶现登录失败问题
* 修复注册和登录处未勾选协议的toast提示未做幂等性检验问题
* 修复加入会议时未勾选白板，会议中有共享白板功能的问题
* 修复会中改名无法改回原来的昵称

# v2.0.8(Oct 14, 2021)

### New Features

* 增加SIP按钮，邀请SIP入会以及SIP列表展示

### Behavior changes

### Bug Fixes

# v2.0.6(Sept 28, 2021)

### New Features

* 增加会中音量检测

### Behavior changes

* G2 SDK升级至4.4.2

### Bug Fixes

* 修复mac下首次安装，音视频无法打开问题
* 修复离开会议，设置美颜不生效问题
* 修复离开会议偶先程序卡死问题
* 修复设置页面打开时，同时入会程序异常崩溃问题
* 修复初始化页面未刷新问题

# v2.0.4(Sept 9, 2021)

### New Features

* 增加异常结束的通话自动恢复功能
* 增加退出二次弹窗
* 昵称取消特殊字符限制

### Behavior changes

* 优化音视频权限判断
* IM SDK升级至8.7.0

### Bug Fixes

* 修复异常退出重新入会，音视频状态未同步问题
* 修复云端录制失效问题
* 修复首次开启白板慢问题

# v2.0.2(Aug 26, 2021)

### New Features

### Behavior changes

* 修改登录/注册方式
* 去掉密码登录方式
* 去掉匿名入会

### Bug Fixes

* 修复菜单中未展示白板共享，勾选默认打开白板创会后的显示问题
* 修复录制问题
* 修复异常退出后，重新入会时音视频状态不正确的问题

# v2.0.0(Aug 12, 2021)

### New Features

* 即刻会议增加入会密码`NEMeetingParams::password`
* 接口支持结束会议 `NEMeetingService::leaveMeeting`
* 增加入会超时配置以及入会的部分具体错误信息 `NEMeetingOptions::joinTimeout`

### Behavior changes

* G2 SDK 升级到 4.3.8
* 重构 native，改名为 roomkit
* 优化 IPC 反初始化的逻辑
* 优化创建/加入会议聊天室开关

### Bug Fixes

* 修复参会者列表共享白板图标显示问题
* 修复直播“仅本企业观看”显示问题
* 修复匿名入会，昵称设置无效问题

# v1.10.0(Jul 8, 2021)

### New Features

* 会议应用会中反馈增加音频 dump 上传
* 创建会议增加会议场景参数，支持传入受邀用户列表: `NEStartMeetingParams::scene`
* 预约/编辑会议增加会议场景参数，支持传入受邀用户列表：`NEStartMeetingParams::scene`
* 创建/加入会议增加自定义标签参数：`NEMeetingParams::tag`
* 会议服务，当前会议成员信息增加自定义标签参数：`NEMeetingService::getCurrentMeetingInfo#NEInMeetingUserInfo::tag`

### Behavior changes

### Bug Fixes

* 会议应用增加重新初始化流程，解决应用偶先启动失败问题

# v1.9.0(May 27, 2021)

### New Features

* 会议应用增加防诈骗提示
* 会议服务，当前会议信息新增属性： `NEMeetingService::getCurrentMeetingInfo`
  * 会议成员列表：`NEMeetingInfo::userList`
  * 会议唯一 ID：`NEMeetingInfo::meetingUniqueId`
  * 会议主题：`NEMeetingInfo::userList`
  * 会议密码：`NEMeetingInfo::password`
  * 会议开始时间：`NEMeetingInfo::startTime`
  * 会议预约的开始时间：`NEMeetingInfo::scheduleStartTime`
  * 会议预约的结束时间：`NEMeetingInfo::scheduleEndTime`
* 初始化增加日志配置：`NEMeetingSDKConfig::getLoggerConfig`
* 初始化支持设置运行权限：`NEMeetingSDKConfig::setRunAdmin`

### Behavior changes

* mac G2 SDK 升级到 4.1.1
* mac 相芯美颜 SDK 回退到 7.2.0
* 替换日志库为 yx_alog
* 程序安装默认不勾选隐私权限
* 更新接口文档

### Bug Fixes

* 修复成员列表排序不对问题
* 修复全体静音/取消程序卡顿问题
* 修复隐私权限复选框状态重置的问题
* 修复共享时昵称显示的问题
* 修复部分未翻译的问题
* 修复部分场景下共享时视频窗口大小不正常的问题

# v1.8.0(Apr 27, 2021)

### New Features

* 创建会议增加云端录制配置参数: `NEStartMeetingOption::noCloudRecord`
* 会议设置服务新增白板查询接口: `NEWhiteboardController::isWhiteboardEnabled`
* 会议设置服务新增云端录制查询接口: `NERecordController::isCloudRecordEnabled`
* 编辑/预约会议新增参数: `NEMeetingItem::cloudRecordOn`
* 会话服务,会议信息新增 sip 号: `NEMeetingService::getCurrentMeetingInfo#NEMeetingInfo::sipId`
* 会议设置服务,会议信息新增 sip 号: `NESettingsService::getHistoryMeetingItem#NEHistoryMeetingItem::sipId`
* 初始化配置新增保活间隔设置: `NEMeetingSDKConfig::setKeepAliveInterval`
* 共享时支持显示视频
* 支持灰度升级

### Behavior changes

* G2 SDK 升级到 4.1.0
* 相芯美颜 SDK 升级到 7.3.0
* 白板 SDK 升级到 3.1.0
* 会议直播视图增加共享屏幕视图
* 共享时隐藏设置/取消设置焦点视频的入口
* 优化共享时的性能
* 登录/注册前必须勾选隐私权限

### Bug Fixes

* 修复主持人全体静音，把自己也静音的问题
* 修复匿名入会时，点击反馈无反应的问题
* 修复共享 ppt 时，部分场景下对端看不到画面的问题
* 修复 windows 下，分辨率超过 1080P 桌面共享对端看到模糊的问题
* 修复主持人移交时多次提示的问题
* 修复匿名入会时，入会中状态多次通知的问题

# v1.7.2(Mar 30, 2021)

### New Features

* 支持设置直播权限 `NEMeetingItem::liveWebAccessControlLevel`

### Behavior changes

* 更新白板地址

### Bug Fixes

* 修复共享屏幕下，举手提示异常问题
* 修复共享屏幕下，聊天消息数目不同步问题
* 修复移交主持人给屏幕共享者，新主持人直播窗口成员列表空白问题
* 修复授权白板权限给离开会议的参会者时的崩溃问题

# v1.7.1(Mar 17, 2021)

### New Features

### Behavior changes

### Bug Fixes

* 修复共享下会闪黑的问题

# v1.7.0(Mar 17, 2021)

### New Features

* Windows 共享屏幕支持共享音频 + 流畅优先
* MacOS 屏幕共享支持流畅优先
* 支持会中改名
* 聊天室文本支持单条右键复制

### Behavior changes

* G2 SDK 升级到 4.0.1 版本
* 更新 nebase

### Bug Fixes

* MacOS Sample 增加签名，修复设备切换卡顿问题

# v1.6.0(Feb 5, 2021)

### New Features

* 支持主持人结束成员屏幕共享
* 增加白板共享

### Behavior changes

* 取消自动随机移交主持人

### Bug Fixes

* 修复屏幕共享下，聊天窗口未同步消息的问题

# v1.5.2(Jan 15, 2021)

### New Features

* 支持单个账户音频订阅/取消订阅接口 `NEMeetingService::subscribeRemoteAudioStream`
* 支持多个账户音频订阅/取消订阅接口 `NEMeetingService::subscribeRemoteAudioStreams`
* 支持全部账户音频订阅/取消订阅接口 `NEMeetingService::subscribeAllRemoteAudioStreams`

### Behavior changes

* 优化结束共享时视频显示为共享画面的问题
* 优化账号登录流程
* 调整`NEAuthService::Login`接口为不带 AppKey

### Bug Fixes

* 修复 MacOs 部分 wps 播放时不能共享的问题
* 修复自定义菜单图片路径为多个空格时判断的问题
* 修复会议非正常关闭后，关联的进程没有退出的问题
* 修复大盘网易会议 PC 版本问题，head 和 body 字段中 ver 没填写的问题
* 修复画廊模式下成员列表切换会闪烁的问题
* 修复部分显卡下会崩溃的问题
* 修复 win 下，共享时聊天窗口闪烁的问题
* 修复结束共享，偶现崩溃问题
* 修复登录时拖动窗口，窗口大小异常的问题

# v1.5.0(Dec 21, 2020)

### New Features

* 支持视频美颜
* 支持直播功能
* 支持会中禁止息屏
* 支持全局静音举手功能
* 支持展示 SIP 客户端入会信息

### Behavior changes

* MacOS 共享支持 WPS
* 应用共享优化
* 支持自定义工具栏
* 适配部分分辨率下共享工具栏显示

### Bug Fixes

* 修复共享状态下断网重连后其他端画面异常问题
* 修复 win7 下共享崩溃问题
* 修复窗口闪烁问题

# v1.3.3(Nov 27, 2020)

### New Features

* 支持共享应用

### Behavior changes

* G2 SDK 升级到 3.8.1
* 成员列表搜索时自动去掉首尾空格
* 会议画廊模式每页不在展示自己，只在首页展示

### Bug Fixes

* 修复多端入会互踢时偶现崩溃问题
* 修复会议画廊模式修改数量不生效的问题
* 修复移交主持人时成员离开房间，成员再进入房间时，成员列表有重复数据

# v1.3.2(Nov 20, 2020)

### New Features

* 会议举手功能
* 支持录制配置能力

### Behavior changes

* G2 SDK 升级到 3.8.0
* quick controls 1 升级到 quick controls 2
* 会议预约自适应窗口比例
* 调整更新升级页面视觉样式

### Bug Fixes

* 修复应用内更新无法自动
* 修复拔掉副屏，副屏无法停止共享
* 修复共享结束时收到聊天消息，消息报错问题

# v1.3.1(Nov 13, 2020)

### New Features

* 会中反馈及会后反馈
* 预约会议编辑功能
* 使用网易会议账号登录接口 `NEAuthService::loginWithNEMeeting`
* 使用 SSO token 登录接口 `NEAuthService::loginWithSSOToken`
* 自动登录接口 `NEAuthService::tryAutoLogin`
* 创建及加入会议 option 中增加 NEShowMeetingIdOption 配置会议中显示会议 ID 的策略

## Updated

* `NEMeetingSDK::initialized` config 参数中增加 AppKey 参数用于设置全局默认应用 Key 信息
* `NEAuthService::logout` 新增了带默认参数的形参，用以决定在退出时是否清理 SDK 缓存的用户信息

# v1.3.0(Oct 29, 2020)

### New Features

* 个人会议短号解析能力
* 组件在 `AuthService` 中增加 `getAccountInfo` 接口用于获取用户资料信息
* 组件对私有化环境能力支持
* 共享中不显示工具条
* 预约会议详情页

### Behavior changes

* 调整入会前后的整体 UI 视觉样式
* 升级 G2 SDK 到 3.7.0

### Bug Fixes

* 匿名入会输入错误会议码后无法再次入会
* 安装包签名失败导致部分场景无法正常安装（Windows only）
* 本地视频画面无法镜像
* 多端登录后入会本地视频无法渲染
* 多拓展屏下缩放比例不一致拖动导致界面异常
* 多拓展屏下部分窗口和全局 Toast 提示不跟随窗口
* 会议持续时间计时不准确
* 断网后无法再次开启会议（macOS only）
* 屏幕共享正在讲话文案优化

## Removed

* 组件入会过程中取消按钮

## Deprecated

* 组件原有 `AccountService` 及功能函数 `getPersonalMeetingId()` 废弃不再使用
