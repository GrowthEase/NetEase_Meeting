# CHANGELOG

# 2022-03-11 @ v2.5.1
* 优化首次会默认Pub的问题：将mute/unmute音频操作修改为disable/enable操作

# 2022-01-20 @ v2.5.0
* 白板升级至3.7.5,支持G1，G2后端配置下发
* 修复已知问题：firebase上聊天昵称截取异常

# 2022-01-20 @ v2.4.0
* 支持通过设置NEMeetingOptions.noMuteAllVideo和NEMeetingOptions.noMuteAllAudio字段控制'全体打开/关闭视频'和'全体打开/关闭音频'是否展示
* 修复已知问题

# 2021-12-29 @ v2.3.0
## Added
* 会中支持主持人视频会控功能
* 支持入会时设置使用通话、音乐等音频模式：创建对应`NEAudioProfile`对象并赋值给`NEMeetingOptions.audioProfile`字段
* 支持通过设置 `NEMeetingOptions.showMemberTag` 字段控制成员标签(`NEMeetingParams.tag`)是否显示在参会者列表中
* 创建/预约会议增加透传的扩展字段：
  * 通过`NEStartMeetingParams.extraData`与`NEMeetingItem.setExtraData`设置扩展字段
  * 通过获取会议信息后读取`NEMeetingInfo#extraData`可获取设置的扩展字段
* 创建/预约会议增加音视频控制字段，可设置成员入会时音视频的开关状态：
  * 创建即刻会议时设置：`NEStartMeetingParams.controls`
  * 预约会议时设置：`NEMeetingItemSetting.controls`

## Deprecated
* 废弃 `NEMeetingOptions.audioAINSEnabled`，请使用 `NEMeetingOptions.audioProfile` 来设置智能降噪开关
* 废弃 `NEMeetingItemSetting.isAttendeeAudioOff`，请使用 `NEMeetingItemSetting.controls` 来控制成员入会时的音频状态

# 2021-12-09 @ v2.2.0
## Fixed
* 修复画廊模式小圆点显示被底部工具栏覆盖的问题
* 修复其他问题

# 2021-10-15 @ v2.0.8
## Added
* 新增会议中SIP邀请:
  * 会议中邀请接口：
    * 新增邀请信息封装类：`NERoomInvitation`
    * 新增邀请接口：`NEInRoomService.invite`
    * 新增邀请列表查询接口：`NEInRoomService.getInviteList`
    * 新增邀请信息变更监听：`NEInRoomServiceListener.onRoomInviteChanged`
    * 新增 SIP 菜单项与邀请页面

# 2021-9-28 @ v2.0.6
## Added
* 新增会议语音智能降噪，默认开启：`NEMeetingOptions.audioAINSEnabled`
* 新增静音时音量检测
* 优化iOS屏幕共享，最大清晰度默认为1080P；宿主进程与直播扩展进程使用LocalSocket通信,并自适应帧率；
* iOS支持进程异常退出时结束扩展进程：`NEMeetingService.stopBroadcastExtension`

# 2021-8-16 @ v2.0.0
## Added
* 创建即刻会议时可设置会议密码：`NEMeetingParams.password`
* 创建/加入会议时可设置连接超时时间，超时会自动离开：`NEMeetingOptions.joinTimeout`
* 新增离开会议接口：`NEMeetingService.leaveCurrentMeeting`
* 支持更细粒度的会议退出码，详情请查看 `NEMeetingCode`
## Changed
* 创建会议时，如果设置了`NEMeetingOptions.noChat`为`true/YES`，将不再会创建聊天室

# 2021-7-9 @ v1.10.0
## Added
* 创建和加入会议可设置成员标签，对应字段为：`NEMeetingParams.tag`
* 会议中的成员信息类可获取到入会时设置的标签，对应字段为：`NEInMeetingUserInfo.tag`
* 预约会议和创建会议时，可配置允许入会的成员账号列表以及数量：
  - 创建会议时使用`NEStartMeetingParams.scene`字段配置
  - 预约会议时使用`NEMeetingItemSetting.scene`字段配置

# 2021-5-30 @ v1.9.0
## Added
* iOS SDK支持屏幕共享
* SDK初始化时支持设置SDK日志路径与日志级别
    - 通过`NEMeetingSDKConfig.loggerConfig`字段设置
* 新增参会者用户信息类`NEInMeetingUserInfo`，包含用户Id与用户昵称
* 会议信息`NEMeetingInfo`新增以下字段：
    - 新增`NEMeetingInfo.userList`字段，可获取当前时刻会议中的参会者信息列表
    - 新增`NEMeetingInfo.hostUserId`字段，代表当前时刻会议的主持人用户Id
## Fixed
* 修复Android屏幕共享分辨率选择不正确导致的画面模糊问题
## Deprecated
* 废弃`NEMeetingSDKConfig.enableDebugLog`，使用`NEMeetingSDKConfig.loggerConfig`代替
* 废弃`NEMeetingSDKConfig.logSize`，使用`NEMeetingSDKConfig.loggerConfig`代替

# 2021-5-01 @ v1.8.0

## Added
* 支持屏幕共享辅流
* 支持会议云端录制功能开关
    - 新增`NEMeetingItemSetting.cloudRecordOn`预约会议选项配置“云端录制”是否开启
    - 新增`NEStartMeetingOptions.noCloudRecord`创建会议选项配置“云端录制”是否开启
* 会议信息新增sipId字段
    - 新增`NEMeetingInfo.sipId`字段
    - 新增`NEHistoryMeetingItem.sipId`字段

# 2021-4-30 @ v1.7.2

## Added
* 支持预约会议设置直播安全模式
- 新增`NEMeetingItemLive.NEMeetingLiveAuthLevel`选项配置“直播安全模式”

# 2021-3-18 @ v1.7.0

## Added
* 支持会中改名，新增`NEMeetingOptions.noRename`选项配置该功能是否开启，默认为开启
* 支持查询历史参会记录信息，通过`NESettingsService.getHistoryMeetingItem`接口可返回最近一次的参会信息
* 支持会中聊天室文本消息长按复制

# 2021-2-05 @ v1.6.0

## Added
* 增加会议内白板菜单自定义
- 新增`NEMeetingSDK.getInstance().getMeetingService().NEStartMeetingOptions defaultWindowMode` 
  配置“默认会议视图模式”
- 新增`NEMeetingSDK.getInstance().getMeetingService().NEStartMeetingOptions noWhiteBoard` 
  配置“默认会议是否显示白板入口”
- 新增会中白板功能
- 新增会中主持人结束其他端共享（屏幕/白板）
- 优化会中邀请页面，时间显示格式为24小时制

# 2021-1-15 @ v1.5.2

## Added
* 支持自定义音频流
    - 订阅会议内某一音视频流：`NEMeetingService.subscribeRemoteAudioStream`
    - 批量订阅会议内某一音视频流：`NEMeetingService.subscribeRemoteAudioStreams`
    - 订阅会议内全部音视频流：`NEMeetingService.subscribeAllRemoteAudioStreams`

* 遥控器支持会议内菜单自定义
    - 新增单状态菜单项：`NESingleStateMenuItem`
    - 新增可切换状态的双状态菜单项：`NECheckableMenuItem`
    - 新增菜单项状态迁移控制器：`NEMenuStateController`
    - 新增SDK预置菜单Id与菜单项定义: `NEMenuIds`, `NEMenuItems`
    - [Android]新增菜单列表构建帮助类：`NEMenuItemListBuilder`
    - 配置工具栏菜单列表：`NEMeetingOptions.fullToolbarMenuItems`
    - 配置更多展开菜单列表：`NEMeetingOptions.fullMoreMenuItems`

# 2020-12-21 @ v1.5.0

## Added
* 支持会议内菜单自定义
    - 新增单状态菜单项：`NESingleStateMenuItem`
    - 新增可切换状态的双状态菜单项：`NECheckableMenuItem`
    - 新增菜单项状态迁移控制器：`NEMenuStateController`
    - 新增SDK预置菜单Id与菜单项定义: `NEMenuIds`, `NEMenuItems`
    - [Android]新增菜单列表构建帮助类：`NEMenuItemListBuilder`
    - 配置工具栏菜单列表：`NEMeetingOptions.fullToolbarMenuItems`
    - 配置更多展开菜单列表：`NEMeetingOptions.fullMoreMenuItems`
* 新增直播功能
    - 开启直播`LiveRepository.startLive(NEMeetingItemLive live)`;
    - 更新直播`LiveRepository.updateLive(NEMeetingItemLive live)`;
    - 结束直播`LiveRepository.topLive(String meetingId)`;
* 新增直播开关状态查询
    - `NESettingsService.isMeetingLiveEnabled();`
* 设置服务新增美颜接口
    - 查询美颜状态开启状态：`NESettingsService.isBeautyFaceEnabled()`
    - 打开美颜预览界面: `NESettingsService.openBeautyUI()`
    - 获取当前美颜等级参数: `NESettingsService.getBeautyFaceValue()`
    - 设置美颜等级参数：`NESettingsService.setBeautyFaceValue(int level)`
* 新增切换摄像头开关入会配置：
    - `NEMeetingOptions.noSwitchCamera`
* 新增切换音频模式开关入会配置：
    - `NEMeetingOptions.noSwitchAudioMode`
* 新增SIP拨号入会
* 打开举手功能、TV的举手功能
* [Android]支持多Flutter实例
* 新增遥控器、TV协议变更回调
    - `ControlListener.onTCProtocolUpgrade(NETCProtocolUpgrade protocolUpgrade)`
  
## Changed
* [Android]废弃`com.netease.meetinglib.sdk.NEMeetingMenuItem`菜单类，使用`com.netease.meetinglib.sdk.menu.NEMeetingMenuItem`代替
* [Android]废弃`NEMeetingOnInjectedMenuItemClickListener.onInjectedMenuItemClick(Context, NEMeetingMenuItem, NEMeetingInfo)`回调，使用`NEMeetingOnInjectedMenuItemClickListener.onInjectedMenuItemClick(Context , NEMenuClickInfo, NEMeetingInfo, NEMenuStateController)`代替
* [iOS]废弃`MeetingServiceListener onInjectedMenuItemClick:meetingInfo:`协议回调，使用`MeetingServiceListener onInjectedMenuItemClick:meetingInfo:stateController：`代替
* 使用高清语音模式

## Fixed
* 视频镜像优化
* 入会前后横竖屏切换逻辑优化

# 2020-11-27 @ v1.3.3

## Added
* 屏幕共享时放大功能优化，旋转时恢复大小，Toast提示功能
* 升级G2 SDK到3.8.1

## Changed
* 画廊视图优化
* 搜索框的首尾空格不能兼容，有首尾空格就会搜索失败
* 删除无用plugin， 优化plugin


# 2020-11-20 @ v1.3.2

## Added
* 录制能力支持服务器可配置
* 升级G2 SDK到3.8.0
* 新增举手功能，但是主持人入口没有放开（默认支持了举手的能力）

## Changed
* 修改TV、遥控器协议


# 2020-11-13 @ v1.3.1

## Added
* 观看屏幕共享时支持手势缩放
* 新增网易会议账密登录、SSOToken登录、自动登录
    - 网易会议账密登录：`NEMeetingSDK.getInstance().loginWithNEMeeting(String account, String password, NECallback<Void> callback)`
    - SSOToken登录：`NEMeetingSDK.loginWithSSOToken(String ssoToken, NECallback<Void> callback)`
    - 自动登录：`NEMeetingSDK.getInstance().tryAutoLogin(NECallback<Void> callback)`
* 支持配置会议内“会议号”显示规则
    - 配置项：`NEMeetingOptions.meetingIdDisplayOptions`
* 支持配置画廊模式开关
    - 配置项：`NEMeetingOptions.noGallery`


# 2020-10-29 @ v1.3.0

## Added
* 新增画廊模式
* 新增结束会议添加断网提示
* 新增会议私有化部署
    - 开启私有化配置：`NEMeetingSDKConfig.useAssetServerConfig` 
* 新增获取会议账号信息方法
    - `NEAccountService.getAccountInfo()`
* 支持企业客户自定义个人会议短号
    - 会议短号获取：`NEAccountInfo.shortMeetingId`
    - 邀请里面包含了短号字段 `shortId`

## Changed
* 个人会议号获取方式变更
    - `NEAccountInfo.meetingId`
* 屏幕共享文案调整
* 删除会议转场页面取消按钮
* 网络状态断开时结束会议优化
* 升级G2 SDK到3.7.0
* 升级Flutter SDK到1.22.1
* 状态栏适配优化
* 横屏显示优化
* 会中窗口显示优化

## Fixed
* 修复会议显示时长偏差
* 屏幕共享者关闭语音后不再显示正在说话文案

## Removed
* `NEMeetingInfo#getPersonalMeetingId`