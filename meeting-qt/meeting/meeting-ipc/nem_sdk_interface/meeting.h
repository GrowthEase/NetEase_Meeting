// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/**
 * @file meeting.h
 * @brief 会议头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_DEFINE_METTING_H_
#define NEM_SDK_INTERFACE_DEFINE_METTING_H_

#include <list>
#include <map>
#include <string>
#include <vector>
#include "public_define.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

/**
 * @brief 会议状态
 */
enum NEMeetingStatus {
    /**
     * 创建或加入会议失败
     */
    MEETING_STATUS_FAILED,

    /**
     * 当前未处于任何会议中
     */
    MEETING_STATUS_IDLE,

    /**
     * 当前处于等待状态，具体等待原因描述如下：
     * <ul>
     * <li>{@link MEETING_WAITING_VERIFY_PASSWORD}</li>
     * </ul>
     * @see MeetingDisconnectCode
     * @since 1.2.1
     */
    MEETING_STATUS_WAITING,

    /**
     * 当前正在创建或加入会议
     */
    MEETING_STATUS_CONNECTING,

    /**
     * 当前处于会议中
     */
    MEETING_STATUS_INMEETING,

    /**
     * 当前正在从会议中断开，断开原因描述如下：
     * <ul>
     * <li>{@link MEETING_DISCONNECTING_BY_SELF}</li>
     * <li>{@link MEETING_DISCONNECTING_REMOVED_BY_HOST}</li>
     * <li>{@link MEETING_DISCONNECTING_CLOSED_BY_HOST}</li>
     * <li>{@link MEETING_DISCONNECTING_LOGIN_ON_OTHER_DEVICE}</li>
     * <li>{@link MEETING_DISCONNECTING_CLOSED_BY_SELF_AS_HOST}</li>
     * </ul>
     * @see MeetingDisconnectCode
     */
    MEETING_STATUS_DISCONNECTING,

    /**
     * 未知状态
     */
    MEETING_STATUS_UNKNOWN = 100,
};

/**
 * @brief 会议连接端口时的状态码
 */
enum MeetingDisconnectCode {
    /**
     * 当前正在从会议中断开，原因为用户主动断开
     */
    MEETING_DISCONNECTING_BY_SELF = 0,

    /**
     * 会议断开的类型之一，当前正在从会议中断开，原因为被会议主持人移除
     */
    MEETING_DISCONNECTING_REMOVED_BY_HOST = 1,

    /**
     * 当前正在从会议中断开，原因为会议被主持人关闭
     */
    MEETING_DISCONNECTING_CLOSED_BY_HOST = 2,

    /**
     * 当前正在从会议中断开，原因为账号在其他设备上登录
     */
    MEETING_DISCONNECTING_LOGIN_ON_OTHER_DEVICE = 3,

    /**
     * 当前正在从会议中断开，原因为自己作为主持人主动结束了会议
     */
    MEETING_DISCONNECTING_CLOSED_BY_SELF_AS_HOST = 4,

    /**
     * 当前正在从会议中断开，原因为账号信息已过期
     */
    MEETING_DISCONNECTING_AUTH_INFO_EXPIRED = 5,

    /**
     * 当前正在从会议中断开，原因为与服务器断开连接
     */
    MEETING_DISCONNECTING_BY_SERVER = 6,

    /**
     * 当前正在从会议中断开，原因为会议不存在
     */
    MEETING_DISCONNECTING_BY_MEETINGNOTEXIST = 7,

    /**
     * 当前正在从会议中断开，原因为同步会议信息失败
     */
    MEETING_DISCONNECTING_BY_SYNCDATAERROR = 8,

    /**
     * 当前正在从会议中断开，原因为rtc模块初始化失败
     */
    MEETING_DISCONNECTING_BY_RTCINITERROR = 9,

    /**
     * 当前正在从会议中断开，原因为加入频道失败
     */
    MEETING_DISCONNECTING_BY_JOINCHANNELERROR = 10,

    /**
     * 当前正在从会议中断开，原因为入会超时
     */
    MEETING_DISCONNECTING_BY_TIMEOUT = 11,

    /**
     * 正在等待验证会议密码
     * @since 1.2.1
     */
    MEETING_WAITING_VERIFY_PASSWORD = 20
};

/**
 * @brief 预约的会议状态
 */
enum NEMeetingItemStatus {
    /**
     * 无效的
     */
    MEETING_INVALID,

    /**
     * 会议初始状态，没有人入会
     */
    MEETING_INIT,

    /**
     * 已开始
     */
    MEETING_STARTED,

    /**
     * 已结束，可以再次入会
     */
    MEETING_ENDED,

    /**
     * 会议已经被取消
     */
    MEETING_CANCEL,

    /**
     * 已回收，不能再次入会
     */
    MEETING_RECYCLED
};

/**
 * @brief 会议号展示选项
 */
enum NEShowMeetingIdOption {
    kDisplayShortIdOnly, /**< 只展示短号 */
    kDisplayLongIdOnly,  /**< 只展示长号 */
    kDisplayAll          /**< 长短号都展示 */
};

/**
 * @brief 会议默认的展示模式
 */
enum NEMettingWindowMode {
    /**
     * 白板共享模式
     */
    WHITEBOARD_MODE,

    /**
     * 默认模式
     */
    NORMAL_MODE
};

/**
 * @brief 登录web直播页的鉴权级别
 */
enum NEMettingLiveAuthLevel {
    /**
     * 不需要鉴权
     */
    LIVE_ACCESS_NORMAL,

    /**
     * 需要登录
     */
    LIVE_ACCESS_TOKEN,

    /**
     * 需要登录并且账号要与直播应用绑定
     */
    LIVE_ACCESS_APP_TOKEN,
};

/////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @brief 菜单可见性策略
 */
enum NEMenuVisibility {
    /**
     * 始终可见
     */
    VISIBLE_ALWAYS,

    /**
     * 主持人不可见
     */
    VISIBLE_EXCLUDE_HOST,

    /**
     * 仅主持人可见
     */
    VISIBLE_TO_HOST_ONLY
};

/**
 * @brief 会议内成员信息
 */
typedef struct tagNEInMeetingUserInfo {
    /**
     * 用户会议ID
     */
    std::string userId;

    /**
     * 用户昵称
     */
    std::string userName;

    /**
     * 会议中的成员标签，自定义，最大长度50
     */
    std::string tag;
} NEInMeetingUserInfo;

/**
 * @brief 启用会议流加密后的加密方式配置
 *
 */
enum NEEncryptionType {
    /// 国密 SM4-ECB 加密
    kNEEncryptionTypeGMCryptoSM4ECB,
};

/**
 * @brief 会议中流加密配置
 */
typedef struct _tagNEEncryptionConfig {
    /// @brief 是否启用流加密
    bool enable{false};
    /// @brief 加密类型 @see NEEncryptionType
    NEEncryptionType type;
    /// @brief 加密秘钥，一般由服务器生成下发
    std::string key;
} NEEncryptionConfig;

/**
 * @brief 会控类型
 */
enum NEControlType { kControlTypeAudio, kControlTypeVideo };

/**
 * @brief 入会后自动关闭类型
 */
enum NEAttendeeOffType {
    /**
     * 入会不自动关闭
     */
    kAttendeeOffNone,

    /**
     * 入会自动关闭，允许自行解除
     */
    kAttendeeOffAllowSelfOn,

    /**
     * 入会自动关闭，不允许自行解除
     */
    kAttendeeOffNotAllowSelfOn
};

/**
 * @brief 会控配置
 */
typedef struct tagNEMeetingControl {
    /**
     *  入会后自动关闭，true：guanbi ，false：关闭, 默认不关闭
     */
    NEAttendeeOffType attendeeOff = kAttendeeOffNone;

    /**
     *  控制类型
     */
    NEControlType type;

} NEMeetingControl;

/**
 * @brief 当前会议详情
 */
typedef struct tagNEMeetingInfo {
    /**
     * 当前会议唯一ID
     */
    int64_t meetingId;

    /**
     * 当前会议ID
     */
    std::string meetingNum;

    /**
     * 当前会议短号ID
     */
    std::string shortMeetingNum;

    /**
     * 会议主题
     */
    std::string subject;

    /**
     * 会议密码
     */
    std::string password;

    /**
     * 当前用户是否为主持人
     */
    bool isHost;

    /**
     * 当前会议是否被锁定
     */
    bool isLocked;

    /**
     * 预约会议的预约开始时间戳, Unix时间戳，单位为ms，非预约会议该值为-1
     */
    int64_t scheduleStartTime;

    /**
     * 预约会议的预约结束时间戳, Unix时间戳，单位为ms，非预约会议该值为-1
     */
    int64_t scheduleEndTime;

    /**
     * 该会议真正开始的时间，Unix时间戳，单位为ms，可以以此为基准时间计算当前的会议时长
     * 该时间为平台服务器上的时间，与客户端本地时间可能存在一定的误差
     */
    int64_t startTime;

    /**
     * 会议当前持续时间，会随着会议的进行而更新，单位为ms
     */
    int64_t duration;

    /**
     * 当前会议SIPID
     */
    std::string sipId;

    /**
     * 当前会议内的主持人用户id
     */
    std::string hostUserId;

    /**
     * 当前会议内的成员列表
     */
    std::list<NEInMeetingUserInfo> userList;

    /**
     * json扩展参数, 最大长度2048
     */
    std::string extraData;

    /**
     * 会议创建者用户ID
     */
    std::string meetingCreatorId;

    /**
     * 会议创建者昵称
     */
    std::string meetingCreatorName;
} NEMeetingInfo;

/**
 * @brief 参会者身份定义
 */
enum NEMeetingRoleType {
    /**
     * 主持人身份
     */
    host,

    /**
     * 联席主持人身份
     */
    cohost,

    /**
     * 普通参会者身份
     */
    normal,
};

/**
 * @brief 会议角色信息配置对象
 */
typedef struct tagNEMeetingRoleConfiguration {
    /**
     * 角色类型(暂不支持主持人角色配置)，参考 {@link NEMeetingRoleType} 以查看类型定义
     */
    NEMeetingRoleType roleType = normal;

    /**
     * 该类型的角色允许的在会最大人数, 小于1表示不做限制，自定义从1开始
     */
    int32_t maxCount = -1;

    /**
     * 该类型的角色允许的在会成员列表
     */
    std::list<std::string> userList;
} NEMeetingRoleConfiguration;

/**
 * @brief 会议场景定义
 */
typedef struct tagNEMeetingScene {
    /**
     * 场景编码
     */
    std::string code;

    /**
     * 角色配置，可配置角色类型、角色类型允许的最大与会人数等
     */
    std::list<NEMeetingRoleConfiguration> roleTypes;
} NEMeetingScene;

/**
 * @brief 聊天室配置
 */
typedef struct tagNEMeetingChatroomConfig {
    tagNEMeetingChatroomConfig& operator=(const tagNEMeetingChatroomConfig& config) {
        enableFileMessage = config.enableFileMessage;
        enableImageMessage = config.enableImageMessage;
        return *this;
    }
    /**
     * 是否支持文件消息
     */
    bool enableFileMessage = true;
    /**
     * 是否支持图片消息
     */
    bool enableImageMessage = true;
} NEMeetingChatroomConfig;

#define NEM_MORE_MENU_USER_INDEX 100

/**
 * @attention 开发者自定义的注入菜单ID应该大于等于该值，小于该值的菜单为SDK内置菜单
 * @warning SDK内置的菜单点击时不会触发回调，只有自定义菜单才会回调。代替NEM_MORE_MENU_USER_INDEX
 */
const int kFirstinjectedMenuId = 100;

/**
 * 内置"音频"菜单ID，使用该ID的菜单可添加至Toolbar菜单列表中的任意位置。
 * 开发者可以使用该菜单ID获取内置菜单
 */
const int kMicMenuId = 0;

/**
 * 内置"视频"菜单ID，使用该ID的菜单可添加至Toolbar菜单列表中的任意位置。
 * 开发者可以使用该菜单ID获取内置菜单
 */
const int kCameraMenuId = 1;

/**
 * 内置"共享屏幕"菜单ID，使用该ID的菜单可添加至Toolbar/"更多"菜单列表中的任意位置。
 * 开发者可以使用该菜单ID获取内置菜单
 */
const int kScreenShareMenuId = 2;

/**
 * 内置"参会者"菜单ID，使用该ID的菜单可添加至Toolbar/菜单列表中的任意位置。
 * 开发者可以使用该菜单ID获取内置菜单
 */
const int kParticipantsMenuId = 3;

/**
 * 内置"管理参会者"菜单ID，使用该ID的菜单可添加至Toolbar菜单列表中的任意位置。
 * 开发者可以使用该菜单ID获取内置菜单
 */
const int kMangeParticipantsMenuId = 4;

/**
 * 内置"邀请"菜单ID，使用该ID的菜单可添加至Toolbar/"更多"菜单列表中的任意位置。
 * 开发者可以使用该菜单ID获取内置菜单
 */
const int kInviteMenuId = 20;

/**
 * 内置"聊天"菜单ID，使用该ID的菜单可添加至Toolbar菜单列表中的任意位置。
 * 开发者可以使用该菜单ID获取内置菜单
 */
const int kChatMenuId = 21;

/**
 * 内置"视图"菜单ID，使用该ID的菜单可添加至Toolbar/"更多"菜单列表中的任意位置。
 * 开发者可以使用该菜单ID获取内置菜单
 */
const int kViewMenuId = 22;

/**
 * 内置"白板"菜单ID，使用该ID的菜单可添加至Toolbar/"更多"菜单列表中的任意位置。
 * 开发者可以使用该菜单ID获取内置菜单
 */
const int kWhiteboardMenuId = 23;

/**
 * @brief 会议按钮菜单项
 * @attention itemTitle和itemImage不能同时为空，itemTitle2和itemImage2不能同时为空
 */
typedef struct tagNEMeetingMenuItem {
    /**
     * 菜单项ID，从0-99为预留Id，自定义注入菜单 ID 请使用kFirstinjectedMenuId及以上，且不要重复
     */
    int itemId = kFirstinjectedMenuId;

    /**
     * 菜单项唯一 GUID，由内部生成，回调时会自动填充该字段用以区分唯一菜单项
     */
    std::string itemGuid;

    /**
     * 菜单项名称，UTF-8，不能超过 20 个字符（包含中文、字母和特殊字符，中文算一个字符。起始和结束不能包含空白字符）
     */
    std::string itemTitle;

    /**
     * 菜单图片文件，确保该文件所在目录有访问权限，大小建议为24*24像素
     */
    std::string itemImage;

    /**
     * 菜单项名称，UTF-8，不能超过 20 个字符（包含中文、字母和特殊字符，中文算一个字符。起始和结束不能包含空白字符）
     * 需要第二种状态时的名称，默认为空，即只有一个状态
     */
    std::string itemTitle2;

    /**
     * 菜单图片文件，确保该文件所在目录有访问权限
     * 需要第二种状态时的图片文件，默认为空，即只有一个状态，大小建议为24*24像素
     */
    std::string itemImage2;

    /**
     * 菜单可见性
     */
    NEMenuVisibility itemVisibility = NEMenuVisibility::VISIBLE_ALWAYS;

    /**
     * 菜单项当前的状态（即对应当前显示的名称），默认为1，1是itemTitle， 2是itemTitle2
     */
    int itemCheckedIndex = 1;

    bool operator==(const tagNEMeetingMenuItem& item) const { return item.itemId == itemId; }

    bool operator<(const tagNEMeetingMenuItem& item) const { return itemId < item.itemId; }
} NEMeetingMenuItem;

/////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @brief 菜单项当前的状态（即对应当前显示的名称），默认为1，1是itemTitle， 2是itemTitle2
 */
class NEM_SDK_INTERFACE_EXPORT NEMeetingParams : public NEObject {
public:
    /**
     * @brief 构造函数
     * @param strDisplayName 显示的名称
     * @param strMeetingNum 会议id，如果没有传入则会自动生成
     * @param strTag 用户Tag，用户自定义的一个字符串
     * @param strPassword 会议密码
     */
    NEMeetingParams(const std::string& strDisplayName = "",
                    const std::string& strMeetingNum = "",
                    const std::string& strTag = "",
                    const std::string& strPassword = "")
        : displayName(strDisplayName)
        , meetingNum(strMeetingNum)
        , tag(strTag)
        , password(strPassword) {}

    /**
     * @brief 构造函数
     * @param strDisplayName 显示的名称
     * @param strMeetingNum 会议id，如果没有传入则会自动生成
     * @param strTag 用户Tag，用户自定义的一个字符串
     * @param strPassword 会议密码
     */
    NEMeetingParams(std::string&& strDisplayName, std::string&& strMeetingNum, std::string&& strTag, std::string&& strPassword)
        : displayName(std::move(strDisplayName))
        , meetingNum(std::move(strMeetingNum))
        , tag(std::move(strTag))
        , password(std::move(strPassword)) {}

public:
    /**
     * 会议中的用户昵称，不能为空
     */
    std::string displayName;

    /**
     * 指定要创建或加入的目标会议ID
     * <ul>
     *  <li>加入会议时，该字段必须是一个当前正在进行中的会议ID，不能为空</li>
     *  <li>创建会议时，该字段可使用通过{@link NEAccountService#getPersonalMeetingId}返回的个人会议号，或者不指定(置空)。
     * 当不指定会议ID创建会议时，由服务端随机分配一个会议ID</li>
     * </ul>
     */
    std::string meetingNum;

    /**
     *  会议中的成员标签，自定义，最大长度50
     */
    std::string tag;

    /**
     * 会议角色
     */
    NEMeetingRoleType roleType;

    /**
     * 会议密码
     */
    std::string password;

    /**
     * 会议中流加密配置，当 key 为空时表示不启用加密
     */
    NEEncryptionConfig encryptionConfig;
};

/**
 * @brief 会议选项
 */
class NEM_SDK_INTERFACE_EXPORT NEMeetingOptions : public NEObject {
public:
    /**
     * @brief 构造函数
     * @param bNoVideo 配置入会时是否关闭本端视频，默认为true，即关闭视频，但在会议中可重新打开
     * @param bNoAudio 配置入会时是否关闭本端音频，默认为true，即关闭音频，但在会议中可重新打开
     * @param bNoChat 配置会议中是否显示"聊天"按钮，比自定义菜单中的优先级高
     * @param bNoInvite 配置会议中是否显示"邀请"按钮，比自定义菜单中的优先级高
     * @param bNoScreenShare 配置会议中是否显示"屏幕共享"按钮，比自定义菜单中的优先级高
     * @param bNoView 配置会议中是否显示"视图"按钮，比自定义菜单中的优先级高
     * @param bNoWhiteboard 配置会议中是否显示"白板"按钮，比自定义菜单中的优先级高
     * @param bNoRename 配置会议中是否显示"改名"菜单
     * @param bNoSip 配置会议中是否显示"sip"按钮，默认为true，即不显示
     * @param bNoMuteAllVideo 配置会议中成员列表是否显示"全体关闭/打开视频"，默认为true，即不显示
     * @param bNoMuteAllAudio 配置会议中成员列表是否显示"全体禁音/解除全体静音"，默认为false，即显示
     * @param bAudioAINSEnabled 配置会议中智能语音降噪开关，默认为true，即开启
     * @param bShowMemberTag 配置会议中成员列表是否显示成员标签，默认为false，即不显示
     * @param bShowMeetingRemainingTip 配置会议中是否显示会议结束倒计时提示，默认为false，即不显示
     * @param bDetectMutedMic
     * 配置是否开启麦克风静音检测，默认开启。开启该功能后，SDK在检测到麦克风有音频输入，但此时处于静音打开的状态时，会提示用户关闭静音
     * @param bUnpubAudioOnMute 配置本地静音时，是否关闭静音包发送。默认为true，即关闭静音包
     * @param emViewMode 配置会议模式
     * @param chatroomConfigIn 聊天室配置
     */
    NEMeetingOptions(bool bNoVideo = true,
                     bool bNoAudio = true,
                     bool bNoChat = false,
                     bool bNoInvite = false,
                     bool bNoScreenShare = true,
                     bool bNoView = true,
                     bool bNoWhiteboard = false,
                     bool bNoRename = false,
                     bool bNoSip = true,
                     bool bNoMuteAllVideo = true,
                     bool bNoMuteAllAudio = false,
                     bool bAudioAINSEnabled = true,
                     bool bShowMemberTag = false,
                     bool bShowMeetingRemainingTip = false,
                     bool bDetectMutedMic = true,
                     bool bUnpubAudioOnMute = true,
                     NEMettingWindowMode emViewMode = NORMAL_MODE,
                     NEMeetingChatroomConfig chatroomConfigIn = NEMeetingChatroomConfig())
        : noVideo(bNoVideo)
        , noAudio(bNoAudio)
        , noChat(bNoChat)
        , noInvite(bNoInvite)
        , meetingIdDisplayOption(kDisplayAll)
        , noScreenShare(bNoScreenShare)
        , noView(bNoView)
        , noWhiteboard(bNoWhiteboard)
        , noRename(bNoRename)
        , noSip(bNoSip)
        , noMuteAllVideo(bNoMuteAllVideo)
        , noMuteAllAudio(bNoMuteAllAudio)
        , audioAINSEnabled(bAudioAINSEnabled)
        , showMemberTag(bShowMemberTag)
        , showMeetingRemainingTip(bShowMeetingRemainingTip)
        , detectMutedMic(bDetectMutedMic)
        , unpubAudioOnMute(bUnpubAudioOnMute)
        , defaultWindowMode(emViewMode)
        , chatroomConfig(chatroomConfigIn) {}

public:
    /**
     * 配置入会时是否关闭本端视频，默认为true，即关闭视频，但在会议中可重新打开
     */
    bool noVideo;

    /**
     * 配置入会时是否关闭本端音频，默认为true，即关闭音频，但在会议中可重新打开
     */
    bool noAudio;

    /**
     * 配置会议中是否显示"聊天"按钮，比自定义菜单中的优先级高
     */
    bool noChat;

    /**
     * 配置会议中是否显示"邀请"按钮，比自定义菜单中的优先级高
     */
    bool noInvite;

    /**
     * 配置会议中是否显示"屏幕共享"按钮，比自定义菜单中的优先级高，默认为true，即显示
     */
    bool noScreenShare;

    /**
     * 配置会议中是否显示"视图"按钮，比自定义菜单中的优先级高，默认为true，即显示
     */
    bool noView;

    /**
     * 配置会议中是否显示"白板"按钮，比自定义菜单中的优先级高
     */
    bool noWhiteboard;

    /**
     * 配置会议中是否显示"改名"菜单
     */
    bool noRename;

    /**
     * 配置会议中是否显示"sip"按钮，默认为true，即不显示
     */
    bool noSip;

    /**
     * 配置会议中成员列表是否显示"全体关闭/打开视频"，默认为true，即不显示
     */
    bool noMuteAllVideo;

    /**
     * 配置会议中成员列表是否显示"全体禁音/解除全体静音"，默认为false，即显示
     */
    bool noMuteAllAudio;

    /**
     * 配置会议中智能语音降噪开关，默认为true，即开启
     */
    bool audioAINSEnabled;

    /**
     * 配置会议中成员列表是否显示成员标签，默认为false，即不显示
     */
    bool showMemberTag;

    /**
     * 配置是否显示会议时长到期提示，默认为false，即不显示
     */
    bool showMeetingRemainingTip;

    /**
     * 配置是否开启麦克风静音检测，默认开启。开启该功能后，SDK在检测到麦克风有音频输入，但此时处于静音打开的状态时，会提示用户关闭静音
     */
    bool detectMutedMic;

    /**
     * 配置本地静音时，是否关闭静音包发送。默认为true，即关闭静音包
     */
    bool unpubAudioOnMute;

    /**
     * 配置会议模式
     */
    NEMettingWindowMode defaultWindowMode;

    /**
     * 配置会议ID的展示形式
     */
    NEShowMeetingIdOption meetingIdDisplayOption;

    /**
     * 底部Toolbar菜单栏自定义菜单，最多显示7项，如果为空则显示默认的
     */
    std::vector<NEMeetingMenuItem> full_toolbar_menu_items_;

    /**
     * 底部“更多”菜单栏自定义菜单，最多添加10项，代替injected_more_menu_items_，这两个不能同时使用
     */
    std::vector<NEMeetingMenuItem> full_more_menu_items_;

    /**
     * 入会超时时间，如果小于等于0，则使用默认值，默认为45秒，单位为毫秒
     */
    int joinTimeout = 45 * 1000;

    /**
     * 聊天室配置 {@link NEMeetingChatroomConfig}
     */
    NEMeetingChatroomConfig chatroomConfig;
};

/**
 * @brief 开始会议参数
 */
class NEStartMeetingParams : public NEMeetingParams {
public:
    /**
     * @brief 会议场景定义 {@link NEMeetingScene}
     */
    NEMeetingScene scene;

    /**
     * 会议控制配置
     */
    std::list<NEMeetingControl> controls;

    /**
     * @brief json扩展参数, 最大长度2048
     */
    std::string extraData;

    /**
     * @brief 指定成员角色
     */
    std::map<std::string, NEMeetingRoleType> roleBinds;
};

/**
 * @brief 开始会议选项
 */
class NEStartMeetingOptions : public NEMeetingOptions {
public:
    /**
     * 配置会议中是否开启云端录制
     */
    bool noCloudRecord = true;
};

/**
 * @brief 加入会议参数
 */
class NEJoinMeetingParams : public NEMeetingParams {};

/**
 * @brief 加入会议选项
 */
class NEJoinMeetingOptions : public NEMeetingOptions {};

/**
 * @brief 预约会议的配置
 */
typedef struct tagNEMeetingItemSetting {
    /**
     * 会议场景定义
     */
    NEMeetingScene scene;

    /**
     * 会议控制配置
     */
    std::list<NEMeetingControl> controls;

    /**
     * 入会时音频开关
     */
    bool attendeeAudioOff = false;

    /**
     * 入会时录制开关
     */
    bool cloudRecordOn = false;
} NEMeetingItemSetting;

/**
 * @brief 直播配置
 */
typedef struct tagNEMeetingItemLiveSetting {
    bool enable = false;
    std::string title;
    std::string password;
    bool allowAnonymousEnterChatRoom = true;      /**< 是否开启 Web 聊天室，可在会议中修改 */
    bool useMeetingChatRoomAsLiveChatRoom = true; /**< 是否使用独立的直播聊天室不与会议互通 */
    std::string webSite;                          /**< 直播观看地址 */
} NEMeetingItemLiveSetting;

/**
 * @brief 预约会议的信息
 */
typedef struct tagNEMeetingItem {
    int64_t meetingId = 0;
    std::string meetingNum;
    std::string subject;
    int64_t startTime = 0;
    int64_t endTime = 0;
    std::string password;
    NEMeetingItemSetting setting;
    NEMeetingItemStatus status = MEETING_INVALID;
    int64_t createTime = 0;
    int64_t updateTime = 0;
    bool enableLive = false;
    bool noSip = true;
    std::string extraData; /**< json扩展参数, 最大长度2048 */
    std::string liveUrl;
    std::string inviteUrl; /**< 邀请入会链接 */
    NEMettingLiveAuthLevel liveWebAccessControlLevel = LIVE_ACCESS_NORMAL;
    std::map<std::string, NEMeetingRoleType> roleBinds; /**< 指定成员角色 */
} NEMeetingItem;

/**
 * @brief 登录类型
 */
enum NELoginType {
    kLoginTypeUnknown,
    kLoginTypeNEPassword,
    kLoginTypeNEAccount,
    kLoginTypeSSOToken, /**< 已废弃 */
};

/**
 * @brief 提供会议SDK中账号信息
 * @see NEAuthService#getAccountInfo
 */
typedef struct tagAccountInfo {
    /**
     * 当前登录方式
     */
    NELoginType loginType;

    /**
     * 当登录方式为网易会议账号时此值不为空
     */
    std::string username;

    /**
     * 当前登录用户所对应的 appKey
     */
    std::string appKey;

    /**
     * 网易会议内部生成的唯一账号
     */
    std::string accountId;

    /**
     * 网易会议内部账户所对应的 Token
     */
    std::string accountToken;

    /**
     * 个人会议号，该会议号可在创建会议时使用
     */
    std::string personalMeetingId;

    /**
     * 个人会议短号（对企业内），该会议号可在创建会议时使用
     */
    std::string shortMeetingNum;

    /**
     * 账户名
     */
    std::string accountName;
} AccountInfo;

/**
 * @brief 历史会议记录信息
 */
typedef struct tagNEHistoryMeetingItem {
    /**
     * 会议唯一ID
     */
    long meetingId;

    /**
     * 会议ID
     */
    std::string meetingNum;

    /**
     * 会议短号
     */
    std::string shortMeetingNum;

    /**
     * 会议主题
     */
    std::string subject;
    /**
     * 会议密码
     */
    std::string password;

    /**
     * 会议昵称
     */
    std::string nickname;

    /**
     * 会议SIP
     */
    std::string sipId;
} NEHistoryMeetingItem;

/**
 * @brief 语言类型
 */
typedef enum class tagNEMeetingLanguage {
    kNEAutomatic, /**< 自动，当前系统 */
    kNEChinese,   /**< 简体中文 */
    kNEEnglish,   /**< 英文 */
    kNEJapanese,  /**< 日文 */
} NEMeetingLanguage;

NNEM_SDK_INTERFACE_END_DECLS

#endif  // NEM_SDK_INTERFACE_DEFINE_NEM_METTING_H_
