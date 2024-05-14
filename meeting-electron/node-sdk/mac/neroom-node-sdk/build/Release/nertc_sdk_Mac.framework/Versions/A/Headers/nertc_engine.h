/** @file nertc_engine.h
 * @brief The interface header file of NERTC SDK.
 * All parameter descriptions of the NERTC SDK. All string-related parameters (char *) are encoded in UTF-8.
 * @copyright (c) 2021, NetEase Inc. All rights reserved.
 */

#ifndef NERTC_ENGINE_H
#define NERTC_ENGINE_H

#include "nertc_base.h"
#include "nertc_base_types.h"
#include "nertc_engine_defines.h"
#include "nertc_engine_event_handler_ex.h"

/**
 * @namespace nertc
 * @brief namespace nertc
 */
namespace nertc {
/**
 * @if English
 * RtcEngineContext definition.
 * @endif
 * @if Chinese
 * RtcEngineContext 定义
 * @endif
 */
struct NERtcEngineContext {
    /**
     * @if English
     * Users register the APP key of CommsEase. If you have no APP key in your developer kit, please apply to register a
     * new APP key.
     * @endif
     * @if Chinese
     * 用户注册云信的APP Key。如果你的开发包里面缺少 APP Key，请申请注册一个新的 APP Key。
     * @endif
     */
    const char* app_key;
    /**
     * @if English
     * IRtcEngineEventHandler callback interface class is used to send callback event notifications to the app from SDK.
     * @endif
     * @if Chinese
     * 用于 SDK 向 App 发送回调事件通知。
     * @endif
     */
    IRtcEngineEventHandlerEx* event_handler;
    /**
     * @if English
     * The full path of log content are encoded in UTF-8.
     * @endif
     * @if Chinese
     * 日志目录的完整路径，采用 UTF-8 编码。
     * @endif
     */
    const char* log_dir_path;
    /**
     * @if English
     * The log level. The level is kNERtcLogLevelInfo by default.
     * @endif
     * @if Chinese
     * 日志级别，默认级别为 kNERtcLogLevelInfo。
     * @endif
     */
    NERtcLogLevel log_level;
    /**
     * @if English
     * The size of SDK-input log file. Unit: KB. If the value is set as 0, the size of log file is 100M by default.
     * @endif
     * @if Chinese
     * 指定 SDK 输出日志文件的大小上限，单位为 KB。如果设置为 0，则默认为 100 M。
     * @endif
     */
    uint32_t log_file_max_size_KBytes;
    /**
     * @if English
     * To speed up the encoding of video hardwares, we prefer to use hardware to encode video data. Valid on the mac
     * platform only.
     * @endif
     * @if Chinese
     * 视频硬件编码加速，优先使用硬件编码视频数据。仅mac和win下有效
     * @endif
     */
    bool video_prefer_hw_encoder;
    /**
     * @if English
     * To speed up the encoding of video hardwares, we prefer to use hardware to encode video data. Valid on the mac
     * platform only.
     * @endif
     * @if Chinese
     * 视频硬件解码加速，优先使用硬件解码视频数据。仅mac和win下有效
     * @endif
     */
    bool video_prefer_hw_decoder;
    /**
     * @if English
     * Specifies whether to use external rendering. False is the default value. Valid on the mac platform only.
     * @endif
     * @if Chinese
     * 是否使用外部渲染，默认为false。仅mac下有效
     * @endif
     */
    bool video_use_exnternal_render;
    /**
     * @if English
     * The private server address. You need to set the value as empty by default. ** To use a private server, contact
     * technical support for details.
     * @endif
     * @if Chinese
     * 私有化服务器地址，默认需要置空。如需启用私有化功能，请联系技术支持获取详情。
     * @endif
     */
    NERtcServerAddresses server_config;
    /**
     * @if Chinese
     * 区域类型，默认级别为kNERtcAreaCodeTypeDefault。参考 #NERtcAreaCodeType 。
     * @endif
     */
    int32_t area_code_type;
    NERtcEngineContext() { 
        app_key = nullptr;
        event_handler = nullptr;
        log_dir_path = nullptr;
        log_level = kNERtcLogLevelWarning;
        log_file_max_size_KBytes = 0;
        video_prefer_hw_encoder = true;
        video_prefer_hw_decoder = true;
        video_use_exnternal_render = false;
        area_code_type = 0;//kNERtcAreaCodeTypeDefault;
    }
};

/**
 * @if English
 * RtcEngine class provides main interface-related methods for applications to call.
 * <br>IRtcEngineEx is the basic interface of the NERTC SDK. Creates an IRtcEngine object and calls the methods of this
 * object, and you can activate the communication feature the NERTC SDK provides.
 * @endif
 * @if Chinese
 * RtcEngine 类提供了供 App 调用的主要接口方法。
 * <br>IRtcEngine 是 NERTC SDK 的基础接口类。创建一个 IRtcEngine 对象并调用这个对象的方法可以激活 NERTC SDK 的通信功能。
 * @endif
 */
class IRtcEngine {
public:
    virtual ~IRtcEngine() {}

    /**
     * @if English
     * Initializes the NERTC SDK service.
     * <br>After calling the createNERtcEngine to create IRtcEngine object, you must call the method to initialize
     * before calling other methods. After successfully initializing, the audio and video call mode is enabled by
     * default.
     * @warning
     * - Callers must use the same AppKey to make audio or video calls.
     * - One IRtcEngine instance object must share the same App Key. If you need to change the AppKey, you must first
     * call \ref IRtcEngine::release "release" to destroy the current instance, and then call the method to create a new
     * instance.
     * @param[in] context The passed RTC engine context object. NERtcEngineContext.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 创建 NERtc 实例。
     * <br>通过本接口可以实现创建 NERtc 实例并初始化 NERTC SDK 服务。
     * @since V3.5.0
     * @par 调用时机  
     * 请确保在调用 createNERtcEngine() 方法创建 IRtcEngine 对象后，再调用其他 API 前先调用该方法创建并初始化 NERtc 实例。
     * @note
     * - 使用同一个 App Key 的 App 才能进入同一个房间进行通话或直播。
     * - 一个 App Key 只能用于创建一个 NERtc 实例；若您需要更换 App Key，必须先调用 \ref IRtcEngine::release "release" 方法销毁当前实例，再调用本方法重新创建实例。
     * - 初始化成功后，默认处于音视频通话模式。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>context</td>
     *      <td> \ref nertc::NERtcEngineContext "NERtcEngineContext" </td>
     *      <td>传入的 RTC engine context 对象。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * nertc::NERtcEngineContext rtc_engine_context;
     * memset(&rtc_engine_context, 0, sizeof(nertc::NERtcEngineContext));
     * rtc_engine_context.app_key = app_key.c_str();
     * rtc_engine_context_.log_dir_path = log_dir_path_.c_str();
     * rtc_engine_context_.log_level = rtc_parameter_.log_level;
     * rtc_engine_context_.log_file_max_size_KBytes = log_file_max_size_KBytes;
     * rtc_engine_context_.event_handler = this;
     * rtc_engine_->initialize(rtc_engine_context);
     * @endcode
     * @par 相关接口
     * 若您不再使用 NERtc 实例，需要调用 \ref IRtcEngine::release "release" 方法进行销毁。
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30001（kNERtcErrFatal）：通用错误，比如日志路径无法访问。
     *      - 30003（kNERtcErrInvalidParam）：参数错误，比如 app_key 为空或 log_dir_path 为空。
     *      - 30005（kNERtcErrInvalidState)：状态错误，比如重复初始化。
     * @endif
     */
    virtual int initialize(const NERtcEngineContext& context) = 0;

    /**
     * @if English
     *  Destroys an NERtc instance to release resources.
     * <br>This method releases all resources used by the NERTC SDK. In some cases, real-time audio and video
     * communication is only needed upon your demands. If no RTC calls are required, you can call this method to release
     * resources. <br>After you call the release method, other methods and callbacks supported by the SDK become
     * unavailable. If you want to use RTC calls, you must create a new NERtc instance.
     * @note If you need to use IRtcEngine instance again that cannot be initialized after release, you need to
     * createNERtcEngine after destroyNERtcEngine.
     * @param[in] sync The value is true by default, which can only be set to true. The default setting indicates
     * synchronization call of the instance. You must return before you release the resources and return the IRtcEngine
     * object resources. <br>App cannot call the interface in the callbacks returned by the SDK. If not, deadlock occurs
     * and the SDK can only retrieve related object resources before the callback is returned.  The SDK automatically
     * detects the deadlock, and changes the deadlock to asynchronous call. However, the asynchronous call consumes
     * extra time.
     * @endif
     * @if Chinese
     * 销毁 NERtc 实例，并释放资源。
     * <br>该方法释放 NERTC SDK 使用的所有资源。有些 App
     * 只在用户需要时才进行实时音视频通信，完成音视频通话后，则将资源释放出来用于其他操作，该方法适用于此类情况。
     * - 该接口需要在调用 \ref IRtcEngine::leaveChannel "leaveChannel" 方法并收到本端离开房间的回调后调用。或收到 \ref IRtcEngineEventHandler::onDisconnect "onDisconnect" 回调、重连失败时调用此方法销毁实例，并释放资源。
     * - 调用该释放实例后，您将无法再使用 SDK 的其它方法和回调。如需再次使用实时音视频通话功能，您必须重新创建一个新的 NERtc 实例。
     * @note
     * - 该方法为同步调用，需要等待 NERtcEngine 实例资源释放后才能执行其他操作，建议在子线程中调用该方法，避免主线程阻塞。此外，请勿在 SDK 的回调中调用该方法，否则由于 SDK 要等待回调返回才能回收相关的对象资源，会造成死锁。SDK 会自动检测这种死锁并转为异步调用，但是检测本身会消耗额外的时间。
     * - 如果需要重新使用 IRtcEngine，调用该方法后需要调用 \ref IRtcEngine::destroyNERtcEngine "destroyNERtcEngine" 方法销毁引擎，等待执行结束后才能再次调用 \ref IRtcEngine::createNERtcEngine "createNERtcEngine"。
     * @param[in] sync 默认为 true 且只能设置为 true，表示同步调用，等待 IRtcEngine 对象资源释放后再返回。
     * @endif
     */
    virtual void release(bool sync = true) = 0;

    /**
     * @if English
     * Sets the role of a user in live streaming.
     * <br>The method sets the role to host or audience. The permissions of a host and a viewer are different.
     * - A host has the permissions to open or close a camera, publish streams, call methods related to publishing
     * streams in interactive live streaming. The status of the host is visible to the users in the room when the host
     * joins or leaves the room.
     * - The audience has no permissions to open or close a camera, call methods related to publishing streams in
     * interactive live streaming, and is invisible to other users in the room when the user that has the audience role
     * joins or leaves the room.
     * @note
     * - By default, a user joins a room as a host.
     * - Before a user joins a room, the user can call this method to change the client role to audience. Users can
     * switch the role of a user through the interface after joining the room.
     * - If the user switches the role to audience, the SDK automatically closes the audio and video devices.
     * @param[in] role The role of a user. NERtcClientRole.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 设置直播场景下的用户角色。
     * <br>通过本接口可以实现将用户角色在“主播”（kNERtcClientRoleBroadcaster）和“观众“（kNERtcClientRoleAudience）之间的切换，用户加入房间后默认为“主播”。
     * @since V3.9.0
     * @par 使用前提
     * 该方法仅在通过 \ref nertc::IRtcEngine::setChannelProfile "setChannelProfile" 方法设置房间场景为直播场景（kNERtcChannelProfileLiveBroadcasting）时调用有效。
     * @par 调用时机
     * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
     * @par 业务场景
     * 适用于观众上下麦与主播互动的互动直播场景。
     * @note
     * 用户切换为观众角色时，SDK 会自动关闭音视频设备。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>role</td>
     *      <td> \ref nertc::NERtcClientRole "NERtcClientRole" </td>
     *      <td>用户角色：<ul><li>kNERtcClientRoleBroadcaster（0）：设置用户角色为主播。主播可以开关摄像头等设备、可以发布流、可以操作互动直播推流相关接口、加入或退出房间状态对其他房间内用户可见。<li>kNERtcClientRoleAudience（1）：设置用户角色为观众。观众只能收流不能发流加入或退出房间状态对其他房间内用户不可见。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * //切换用户角色为主播
     * rtc_engine_->setClientRole(nertc::kNERtcClientRoleBroadcaster);
     * //切换用户角色为观众
     * rtc_engine_->setClientRole(nertc::kNERtcClientRoleAudience);
     * @endcode
     * @par 相关回调
     * - 加入房间前调用该方法设置用户角色，不会触发任何回调，在加入房间成功后角色自动生效：
     *          - 设置用户角色为主播：加入房间后，远端用户触发 \ref nertc::IRtcEngineEventHandler::onUserJoined "onUserJoined" 回调。
     *          - 设置用户角色为观众：加入房间后，远端用户不触发任何回调。
     * - 加入房间后调用该方法切换用户角色：
     *          - 从观众角色切为主播：本端用户触发 \ref nertc::IRtcEngineEventHandler::onClientRoleChanged "onClientRoleChanged" 回调，远端用户触发 \ref nertc::IRtcEngineEventHandler::onUserJoined(uid_t uid, const char *user_name, NERtcUserJoinExtraInfo join_extra_info) "onUserJoined" 回调。
     *          - 从主播角色切为观众：本端用户触发 \ref nertc::IRtcEngineEventHandler::onClientRoleChanged "onClientRoleChanged" 回调，远端用户触发 \ref nertc::IRtcEngineEventHandler::onUserLeft(uid_t uid, NERtcSessionLeaveReason reason, NERtcUserJoinExtraInfo leave_extra_info) "onUserleft" 回调。
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30001（kNERtcErrFatal)：引擎未创建成功。
     *      - 30005（kNERtcErrInvalidState)：当前状态不支持的操作，不支持切换角色（主播/观众）。
     *      - 30101（kNERtcErrChannelNotJoined): 尚未加入房间。
     * @endif
     */
    virtual int setClientRole(NERtcClientRole role) = 0;

    /**
     * @if English
     * Sets a room scene.
     * <br>You can set a room scene for a call or live event. Different QoS policies are applied to different scenes.
     * @note You must set the profile after joining a call. The setting is invalid after the call ends.
     * @param[in] profile Sets the room scene. For more information, see NERtcChannelProfileType.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 设置房间场景。
     * <br>
     * 通过此接口可以实现设置房间场景为通话（默认）、直播场景、视频 1对1 呼叫场景、语聊房场景等。针对不同场景采取的优化策略不同，如通话场景侧重语音流畅度，直播场景侧重视频清晰度。
     * @since V3.6.0
     * @note
     * - 同一个房间内的用户建议使用同一种房间场景以获得最佳效果。
     * - 设置场景会影响音视频码率、帧率、视频分辨率、视频大小流模式、自动打开视频、自动订阅视频、传输策略。
     * - 调用此函数将覆盖上一次调用此函数设置的场景。
     * - 调用此函数场景类型为视频 1对1 呼叫场景、清晰度较高的 1对1 呼叫场景等v5.5.40新增的房间场景将覆盖你通过 {@link setVideoConfig}, { @link  setAudioProfile} 等 API 设置的音视频相关配置，因此建议先第一时间设置场景再通过其他 API 调整音视频配置。
     * - V5.5.40 之前就存在通信场景和直播场景，设置通信场景和直播场景，不会覆盖  {@link setVideoConfig}, { @link  setAudioProfile} 等 API 设置的音视频相关配置
     * @par 调用时机
     * 请在初始化后调用该方法，且该方法仅可在加入房间前调用。建议在初始化之后先调此方法，再调别的 API 设置的音视频相关配置。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>profile</td>
     *      <td> \ref nertc::NERtcChannelProfileType "NERtcChannelProfileType"</td>
     *      <td>设置房间场景：<ul><li>kNERtcChannelProfileCommunication（0）：通话场景。<li>kNERtcChannelProfileLiveBroadcasting（1）：直播场景。<li>kNERtcChannelProfileVideoCall (3)：视频 1对1 呼叫场景。 <li>kNERtcChannelProfileHighQualityVideoCall (4)：清晰度较高的 1对1 呼叫场景。 <li>kNERtcChannelProfileChatroom (5)：语聊房场景。<li>kNERtcChannelProfileHighQualityChatroom (6)：高品质语聊房场景。<li>kNERtcChannelProfileMeeting (7)：会议场景。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * //设置房间场景为直播场景
     * rtc_engine->setChannelProfile(nertc::kNERtcChannelProfileLiveBroadcasting);
     * @endcode
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30003（kNERtcErrInvalidParam）：参数错误。
     *      - 30004（kNERtcErrNotSupported）：不支持的操作，比如不是对主房间的设置。
     *      - 30005（kNERtcErrInvalidState)：当前状态不支持的操作，比如引擎尚未初始化。
     * @endif
     */
    virtual int setChannelProfile(NERtcChannelProfileType profile) = 0;

    /**
     * @if English
     *  Joins a channel of audio and video call.
     * <br>If the specified room does not exist when you join the room, a room with the specified name is automatically
    created in the server provided by CommsEase.
     * - After you join a room by calling the relevant method supported by the SDK, users in the same room can make
    audio or video calls. Users that join the same room can start a group chat. Apps that use different AppKeys cannot
    communicate with each other.
     * - After the method is called successfully, the onJoinChannel callback is locally triggered, and the onUserJoined
    callback is remotely triggered.
     * - If you join a room, you subscribe to the audio streams from other users in the same room by default. In this
    case, the data usage is billed. To unsubscribe, you can call the setParameters method.
     * - In live streaming, audiences can switch channels by calling switchChannel.
     * @note The ID of each user must be unique.
     * @param[in] token The certification signature used in authentication (NERTC Token). Valid values:
                        - Null. You can set the value to null in the debugging mode. This poses a security risk. We
    recommend that you contact your business manager to change to the default safe mode before your product is
    officially launched.
                        - NERTC Token acquired. In safe mode, the acquired token must be specified. If the specified
    token is invalid, users are unable to join a room. We recommend that you use the safe mode.
     * @param[in] channel_name The name of the room. Users that use the same name can join the same room. The name must
    be of STRING type and must be 1 to 64 characters in length. The following 89 characters are supported: a-z, A-Z,
    0-9, space, !#$%&()+-:;≤.,>? @[]^_{|}~”.
     * @param[in] uid  The unique identifier of a user. The uid of each user in a room must be unique.
                    <br> uid is optional. The default value is 0. If the uid is not specified (set to 0), the SDK
    automatically assigns a random uid and returns the uid in the callback of onJoinChannel. The application layer must
    keep and maintain the return value. The SDK does not maintain the return value.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 加入音视频房间。
     * <br>通过本接口可以实现加入音视频房间，加入房间后可以与房间内的其他用户进行音视频通话。
     * @since V3.5.0
     * @par 调用时机
     * 请在初始化后调用该方法。
     * @note
     * - 加入房间后，同一个房间内的用户可以互相通话，多个用户加入同一个房间，可以群聊。使用不同 App Key 的 App 之间不能互通。
     * - 加入音视频房间时，如果指定房间尚未创建，云信 服务器内部会自动创建一个同名房间。
     * - 传参中 uid 可选，若不指定则默认为 0，SDK 会自动分配一个随机 uid，并在 \ref nertc::IRtcEngineEventHandler::onJoinChannel "onJoinChannel" 回调方法中返回；App 层必须记住该返回值并维护，SDK 不对该返回值进行维护。
     * - 用户成功加入房间后，默认订阅房间内所有其他用户的音频流，可能会因此产生用量并影响计费；若您想取消自动订阅，可以在通话前通过调用 \ref nertc::IRtcEngineEx::setParameters "setParameters" 方法实现。
     * - 网络测速过程中无法加入房间。
     * - 若使用了云代理功能，uid 不允许传 0，请用真实的 uid。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>token</td>
     *      <td>const char</td>
     *      <td>安全认证签名（NERTC Token），可以设置为：<ul><li>null。调试模式下可设置为 null。安全性不高，建议在产品正式上线前在云信控制台中将鉴权方式恢复为默认的安全模式。<li>已获取的 NERTC Token。安全模式下必须设置为获取到的 Token 。若未传入正确的 Token 将无法进入房间。推荐使用安全模式。</td>
     *  </tr>
     *  <tr>
     *      <td>channelName</td>
     *      <td>const char</td>
     *      <td>房间名称，设置相同房间名称的用户会进入同一个通话房间。<ul><li>字符串格式，长度为 1 ~ 64 字节。<li>支持以下 89 个字符：a-z, A-Z, 0-9, space, !#$%&()+-:;≤.,>? @[]^_{|}~”</td>
     *  </tr>
     *  <tr>
     *      <td>uid</td>
     *      <td>uid_t</td>
     *      <td>用户的唯一标识 ID。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * rtc_engine_->joinChannel(token, "124514", 1);
     * @endcode
     * @par 相关接口
     * - 您可以调用 \ref nertc::IRtcEngine::leaveChannel "leaveChannel"	方法离开房间。
     * - 直播场景中，观众角色可以通过 \ref nertc::IRtcEngine::switchChannel	"switchChannel" 接口切换房间。
     * @par 相关回调
     * - 成功调用该方法加入房间后，本地会触发 \ref nertc::IRtcEngineEventHandler::onJoinChannel "onJoinChannel" 回调，远端会触发 \ref nertc::IRtcEngineEventHandler::onUserJoined "onUserJoined" 回调。
     * - 在弱网环境下，若客户端和服务器失去连接，SDK 会自动重连，并在自动重连成功后触发 \ref nertc::IRtcEngineEventHandler::onRejoinChannel	"onRejoinChannel" 回调。
     * @return 
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30001（kNERtcErrFatal）：重复入会或获取房间信息失败。
     *      - 30005（kNERtcErrInvalidState)：状态错误，比如引擎尚未初始化或正在进行网络探测。
     * @endif
     */
    virtual int joinChannel(const char* token, const char* channel_name, uid_t uid) = 0;

    /**
     * @if Chinese
     * 加入音视频房间。
     * <br>通过本接口可以实现加入音视频房间，加入房间后可以与房间内的其他用户进行音视频通话。
     * @since V3.5.0
     * @par 调用时机
     * 请在初始化后调用该方法。
     * @note
     * - 加入房间后，同一个房间内的用户可以互相通话，多个用户加入同一个房间，可以群聊。使用不同 App Key 的 App 之间不能互通。
     * - 加入音视频房间时，如果指定房间尚未创建，云信 服务器内部会自动创建一个同名房间。
     * - 传参中 uid 可选，若不指定则默认为 0，SDK 会自动分配一个随机 uid，并在 \ref nertc::IRtcEngineEventHandler::onJoinChannel "onJoinChannel" 回调方法中返回；App 层必须记住该返回值并维护，SDK 不对该返回值进行维护。
     * - 用户成功加入房间后，默认订阅房间内所有其他用户的音频流，可能会因此产生用量并影响计费；若您想取消自动订阅，可以在通话前通过调用 \ref nertc::IRtcEngineEx::setParameters "setParameters" 方法实现。
     * - 网络测速过程中无法加入房间。
     * - 若使用了云代理功能，uid 不允许传 0，请用真实的 uid。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>token</td>
     *      <td>const char</td>
     *      <td>安全认证签名（NERTC Token），可以设置为：<ul><li>null。调试模式下可设置为 null。安全性不高，建议在产品正式上线前在云信控制台中将鉴权方式恢复为默认的安全模式。<li>已获取的 NERTC Token。安全模式下必须设置为获取到的 Token 。若未传入正确的 Token 将无法进入房间。推荐使用安全模式。</td>
     *  </tr>
     *  <tr>
     *      <td>channelName</td>
     *      <td>const char</td>
     *      <td>房间名称，设置相同房间名称的用户会进入同一个通话房间。<ul><li>字符串格式，长度为 1 ~ 64 字节。<li>支持以下 89 个字符：a-z, A-Z, 0-9, space, !#$%&()+-:;≤.,>? @[]^_{|}~”</td>
     *  </tr>
     *  <tr>
     *      <td>uid</td>
     *      <td>uid_t</td>
     *      <td>用户的唯一标识 ID。</td>
     *  </tr>
     *  <tr>
     *      <td>channel_options</td>
     *      <td> \ref nertc::NERtcJoinChannelOptions "NERtcJoinChannelOptions"</td>
     *      <td>加入房间时设置一些特定的房间参数。默认值为 nil。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * rtc_engine_->joinChannel(token, "124514", 1);
     * @endcode
     * @par 相关接口
     * - 您可以调用 \ref nertc::IRtcEngine::leaveChannel "leaveChannel"	方法离开房间。
     * - 直播场景中，观众角色可以通过 \ref nertc::IRtcEngine::switchChannel	"switchChannel" 接口切换房间。
     * @par 相关回调
     * - 成功调用该方法加入房间后，本地会触发 \ref nertc::IRtcEngineEventHandler::onJoinChannel "onJoinChannel" 回调，远端会触发 \ref nertc::IRtcEngineEventHandler::onUserJoined "onUserJoined" 回调。
     * - 在弱网环境下，若客户端和服务器失去连接，SDK 会自动重连，并在自动重连成功后触发 \ref nertc::IRtcEngineEventHandler::onRejoinChannel	"onRejoinChannel" 回调。
     * @return 
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30001（kNERtcErrFatal）：重复入会或获取房间信息失败。
     *      - 30005（kNERtcErrInvalidState)：状态错误，比如引擎尚未初始化或正在进行网络探测。
     * @endif
     */
    virtual int joinChannel(const char* token, const char* channel_name, uid_t uid,
                            NERtcJoinChannelOptions channel_options) = 0;

    /**
     * @if English
     * Switches to a room of audio and video call.
     * <br>In live streaming, call this method to switch from the current room to another room.
     * <br>After you switch to another room by calling the method, the local first receive the onLeaveChannel callback
     that the user leaves the room, and then receives the
     * <br>onJoinChanne callback that the user joins the new room. Remote clients receive the return from onUserLeave
     and onUserJoined.
     * @note
     * - The method applies to only the live streaming. The role is the audience in the RTC room. The room scene is set
     to live streaming by calling the setchannelprofile method, and the role of room members is set to audience by
     calling the setClientRole method.
     * - By default, after a room member switches to another room, the room member subscribes to audio streams from
     other members of the new room. In this case, data usage is charged and billing is updated. If you want to
     unsubscribe to the previous audio stream, you can call the subscribeRemoteAudio method with a value of false passed
     in.
     * @param[in] token The certification signature used in authentication (NERTC Token). Valid values:
                        - Null. You can set the value to null in the debugging mode. We recommend you change to the
     default safe mode before your product is officially launched.
                        - NERTC Token acquired. In safe mode, the acquired token must be specified. If the specified
     token is invalid, users are unable to join a channel. We recommend that you use the safe mode.
     * @param[in] channel_name  The room name that a user wants to switch to.

     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 快速切换音视频房间。
     * 通过此接口可以实现当房间场景为直播场景时，从当前房间快速切换至另一个房间。
     * @par 使用前提
     * 请先通过 \ref nertc::IRtcEngine::setChannelProfile "setChannelProfile" 接口设置房间模式为直播模式。
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
     * @note
     * - 房间成员成功切换房间后，将会保持切换前的音视频的状态。
     * - v5.5.10 及之后版本，主播和观众都支持调用本接口快速切换至另一个房间。
     * - v5.5.10 之前版本，只支持观众调用本接口快速切换至另一个房间。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>token</td>
     *      <td>const char*</td>
     *      <td>在服务器端生成的用于鉴权的安全认证签名（Token），可设置为：<ul><li>已获取的 NERTC Token。安全模式下必须设置为获取到的 Token，默认 Token 有效期为 10min，也可以定期通过应用服务器向云信服务器申请 Token 或者申请长期且可复用的 Token。<li>null。调试模式下可设置为 null。安全性不高，建议在产品正式上线前在云信控制台中将鉴权方式恢复为默认的安全模式。</td>
     *  </tr>
     *  <tr>
     *      <td>channel_name</td>
     *      <td>const char*</td>
     *      <td>期望切换到的目标房间名称。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * if (rtc_engine_) {
     *     ret = rtc_engine_->switchChannel(token_.c_str(), room_name.c_str());
     * }
     * @endcode
     * @par 相关回调
     * 成功调用此接口切换房间后：
     *      - 本端用户会先收到 \ref nertc::IRtcEngineEventHandler::onLeaveChannel "onLeaveChannel" 回调，其中 result 参数为 kNERtcErrChannelLeaveBySwitchAction，再收到成功加入新房间的回调 \ref nertc::IRtcEngineEventHandler::onJoinChannel "onJoinChannel"。
     *      - 远端用户会收到 \ref nertc::IRtcEngineEventHandler::onUserLeft(uid_t uid,NERtcSessionLeaveReason reason,NERtcUserJoinExtraInfo leave_extra_info) "onUserLeft" 和 \ref nertc::IRtcEngineEventHandler::onUserJoined(uid_t uid,const char* user_name,NERtcUserJoinExtraInfo join_extra_info) "onUserJoined" 的回调。
     * @return
     * - 0（kNERtcNoError）： 方法调用成功。
     * - 其他：方法调用失败。
     *      - 403（kNERtcErrChannelReservePermissionDenied）：没有权限，比如主播无法切换房间。
     *      - 30001（kNERtcErrFatal）：通用错误。
     *      - 30003（kNERtcErrInvalidParam）：参数错误，比如房间名称为空字符串。
     *      - 30100（kNERtcErrChannelAlreadyJoined）：重复加入房间。
     *      - 30109（kNERtcErrSwitchChannelInvalidState）：尚未加入房间。
     * @endif
     */
    virtual int switchChannel(const char* token, const char* channel_name) = 0;

    /**
     * @if Chinese
     * 快速切换音视频房间。
     * <br>房间场景为直播场景时，可以调用该方法从当前房间快速切换至另一个房间。
     * <br>成功调用该方切换房间后，本端会先收到离开房间的回调 onLeaveChannel，再收到成功加入新房间的回调
     onJoinChannel。远端用户会收到 onUserLeave 和 onUserJoined 的回调。
     * @note
     * -
     房间成员成功切换房间后，默认订阅房间内所有其他成员的音频流，因此产生用量并影响计费。如果想取消订阅，可以通过调用相应的
     subscribeRemoteAudio 方法传入 false 实现。
     * @param[in] token 安全认证签名（NERTC Token）。可设置为：
                        - null。调试模式下可设置为
     null。建议在产品正式上线前在云信控制台中将鉴权方式恢复为默认的安全模式。
                        - 已获取的NERTC Token。安全模式下必须设置为获取到的 Token 。若未传入正确的 Token
     将无法进入房间。推荐使用安全模式。
     * @param[in] channel_name 期望切换到的目标房间名称。
     * @param[in] channel_options 加入房间时设置一些特定的房间参数，详情参考{@link NERtcJoinChannelOptions}。
     * @return
     * - 0(#kNERtcNoError)：方法调用成功。
     * - 30001(#kNERtcErrFatal)：通用错误。
     * - 30003(#kNERtcErrInvalidParam)：参数错误。
     * - 30109(#kNERtcErrSwitchChannelInvalidState): 切换房间状态无效。
     * - 403(#kNERtcErrChannelReservePermissionDenied): 用户角色不是观众。
     * - 30100(#kNERtcErrChannelAlreadyJoined): 房间名无效，已在此房间中。
     * @endif
     */
    virtual int switchChannel(const char* token, const char* channel_name, NERtcJoinChannelOptions channel_options) = 0;

      /**
     * @if Chinese
     * 快速切换音视频房间。
     * <br>房间场景为直播场景时，房间中角色为观众的成员可以调用该方法从当前房间快速切换至另一个房间。
     * <br>成功调用该方切换房间后，本端会先收到离开房间的回调 onLeaveChannel，再收到成功加入新房间的回调
     onJoinChannel。远端用户会收到 onUserLeave 和 onUserJoined 的回调。
     * @note
     * - 该方法仅适用于直播场景中，角色为观众的音视频房间成员。即已通过接口 setchannelprofile 设置房间场景为直播，通过
     setClientRole 设置房间成员的角色为观众。
     * -
     房间成员成功切换房间后，默认订阅房间内所有其他成员的音频流，因此产生用量并影响计费。如果想取消订阅，可以通过调用相应的
     subscribeRemoteAudio 方法传入 false 实现。
     * @param[in] token 安全认证签名（NERTC Token）。可设置为：
                        - null。调试模式下可设置为
     null。建议在产品正式上线前在云信控制台中将鉴权方式恢复为默认的安全模式。
                        - 已获取的NERTC Token。安全模式下必须设置为获取到的 Token 。若未传入正确的 Token
     将无法进入房间。推荐使用安全模式。
     * @param[in] channel_name 期望切换到的目标房间名称。
     * @param[in] channel_options 加入房间时设置一些特定的房间参数，详情参考{@link NERtcJoinChannelOptions}。
     * @return
     * - 0(#kNERtcNoError)：方法调用成功。
     * - 30001(#kNERtcErrFatal)：通用错误。
     * - 30003(#kNERtcErrInvalidParam)：参数错误。
     * - 30109(#kNERtcErrSwitchChannelInvalidState): 切换房间状态无效。
     * - 403(#kNERtcErrChannelReservePermissionDenied): 用户角色不是观众。
     * - 30100(#kNERtcErrChannelAlreadyJoined): 房间名无效，已在此房间中。
     * @endif
     */
    virtual int switchChannelEx(const char* token, const char* channel_name, NERtcJoinChannelOptionsEx channel_options_ex) = 0;  

    /**
     * @if English
     * Leaves the room.
     * <br>Leaves a room for hang up or calls ended.
     * <br>A user can call the leaveChannel method to end the call before the user makes another call.
     * <br>After the method is called successfully, the onLeaveChannel callback is locally triggered, and the
     * onUserLeave callback is remotely triggered.
     * @note
     * - The method is asynchronous call. Users cannot exit the room when the method is called and returned. After users
     * exit the room, the SDK triggers the onLeaveChannel callback.
     * - If you call leaveChannel method and instantly call release method, the SDK cannot trigger onLeaveChannel
     * callback.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 离开音视频房间。
     * <br>通过本接口可以实现挂断或退出通话，并释放本房间内的相关资源。
     * @since V3.5.0
     * @par 调用时机
     * 请在初始化并成功加入房间后调用该方法。
     * @note
     * - 结束通话时必须调用此方法离开房间，否则无法开始下一次通话。
     * - 该方法是异步操作，调用返回时并没有真正退出频道。在真正退出房间后，SDK 会触发 \ref IRtcEngineEventHandler::onLeaveChannel "onLeaveChannel" 回调。
     * - 如果在调用 leaveChannel 后立即调用 \ref nertc::IRtcEngine::release "release" 方法，可能会无法正常离开房间；建议您在收到 \ref IRtcEngineEventHandler::onLeaveChannel "onLeaveChannel" 回调之后再调用 \ref nertc::IRtcEngine::release "release" 方法释放会话相关所有资源。
     * @par 示例代码
     * @code
     * rtc_engine_->leaveChannel();
     * @endcode
     * @par 相关回调
     * 成功调用该方法离开房间后，本地会触发 \ref IRtcEngineEventHandler::onLeaveChannel "onLeaveChannel" 回调，远端会触发 \ref IRtcEngineEventHandler::onUserLeft "onUserLeft" 回调。
     * @return 
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30001（kNERtcErrFatal）：正在进行网络探测。
     *      - 30005（kNERtcErrInvalidState)：状态错误，比如引擎尚未初始化。
     *      - 30101（kNERtcErrChannelNotJoined）：尚未加入房间。
     *      - 30102（kNERtcErrChannelRepleatedlyLeave）：重复离开房间。
     *      - 30104（kNERtcErrSessionNotFound）：会话未找到。
     * @endif
     */
    virtual int leaveChannel() = 0;

    /**
     * @if English
     * Gets the pointer of device administrators object.
     * @param[in] iid       The iid of interface preferred.
     * @param[in] inter     The pointer indicates DeviceManager object.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 获取设备管理员对象的指针。
     * @param[in] iid       想要获取的接口的iid.
     * @param[in] inter     指向 DeviceManager 对象的指针。
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
     * @endif
     */
    virtual int queryInterface(NERtcInterfaceIdType iid, void** inter) = 0;

    /**
     * @if English
     * Enables or disables local audio capture.
     * <br>The method can enable the local audio again to start local audio capture and processing.
     * <br>The method does not affect receiving or playing remote audio and audio streams.
     * @note The method is different from \ref IRtcEngineEx::muteLocalAudioStream "muteLocalAudioStream" in:.
     * - \ref IRtcEngine::enableLocalAudio "enableLocalAudio": Enables local audio capture and processing.
     * - \ref IRtcEngineEx::muteLocalAudioStream "muteLocalAudioStream": Stops or continues publishing local audio
     * streams.
     * @note The method enables the internal engine, which is still valid after you call \ref IRtcEngine::leaveChannel
     * "leaveChannel".
     * @param[in] enabled
     * - true: Enables local audio feature again. You can enable local audio capture or processing by default.
     * - false: Disables local audio feature again. You can stop local audio capture or processing.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese 
     * 开启/关闭本地音频采集和发送。
     * <br>通过本接口可以实现开启或关闭本地语音功能，进行本地音频采集及处理。
     * @since V3.5.0
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
     * @note
     * - 加入房间后，语音功能默认为开启状态。
     * - 该方法设置内部引擎为启用状态，在 leaveChannel 后仍然有效。
     * - 该方法不影响接收或播放远端音频流，enableLocalAudio(false) 适用于只下行不上行音频流的场景。
     * - 该方法会操作音频硬件设备，建议避免频繁开关，否则可能导致设备异常。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>enabled</td>
     *      <td>boolean</td>
     *      <td>是否启用本地音频的采集和发送：<ul><li>true：开启本地音频采集。<li>false：关闭本地音频采集。关闭后，远端用户会接收不到本地用户的音频流；但本地用户依然可以接收到远端用户的音频流。</td>
     *  </tr>
     * </table>     
     * @par 示例代码
     * @code
     * //打开音频采集
     * rtc_engine_->enableLocalAudio(true); 
     * //关闭音频采集
     * rtc_engine_->enableLocalAudio(false);
     * @endcode
     * @par 相关回调
     * - 开启音频采集后，远端会触发 \ref nertc::IRtcEngineEventHandler::onUserAudioStart "onUserAudioStart" 回调。
     * - 关闭音频采集后，远端会触发 \ref nertc::IRtcEngineEventHandler::onUserAudioStop "onUserAudioStop" 回调。
     * @par 相关接口
     * \ref IRtcEngineEx::muteLocalAudioStream "muteLocalAudioStream"：两者的差异在于，enableLocalAudio 用于开启本地语音采集及处理，而 muteLocalAudioStream 用于停止或继续发送本地音频流。
     * @return 
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30005（kNERtcErrInvalidState）：引擎尚未初始化，或者多房间场景下未在本房间操作。
     * @endif
     */
    virtual int enableLocalAudio(bool enabled) = 0;

    /**
     * @if English
     * Sets local views.
     * <br>This method is used to set the display information about the local video. The method is applicable for only
     * local users. Remote users are not affected. <br>Apps can call this API operation to associate with the view that
     * plays local video streams. During application development, in most cases, before joining a room, you must first
     * call this method to set the local video view after the SDK is initialized.
     * @note  If you use external rendering on the Mac platform, you must set the rendering before the SDK is
     * initialized.
     * @param[in] canvas The video canvas information.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 设置本地用户视图。
     * <br>
     * 通过本接口可以实现绑定本地用户和显示视图，并设置本地用户视图在本地显示时的镜像模式和裁减比例，只影响本地用户看到的视频画面。
     * @since V3.5.0
     * @par 调用时机  
     * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
     * @note
     * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
     * - 在实际业务中，通常建议在初始化后即调用该方法进行本地视图设置，然后再加入房间或开启预览；若您开发的是 macOS 平台的 App，若使用的是外部渲染，必须在初始化 SDK 时设置本地视图。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>canvas</td>
     *      <td> \ref nertc::NERtcVideoCanvas "NERtcVideoCanvas" </td>
     *      <td>本地用户视频的画布。设置为 NULL 表示取消并释放已设置的画布，详细信息请参考 \ref nertc::NERtcVideoCanvas "NERtcVideoCanvas"。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * nertc::NERtcVideoCanvas canvas;
     * canvas.cb = nullptr;
     * canvas.user_data = nullptr;
     * canvas.window = window;
     * canvas.scaling_mode = nertc::kNERtcVideoScaleFit;
     * canvas.mirror_mode = nertc::kNERtcVideoMirrorModeAuto;
     * rtc_engine_->setupLocalVideoCanvas(canvas)
     * @endcode
     * @par 相关接口
     * 若您希望在通话中更新本地用户视图的渲染或镜像模式，请使用 \ref nertc::IRtcEngineEx::setLocalRenderMode "setLocalRenderMode" 方法。
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *         - 30001（kNERtcErrFatal）：画布创建失败。
     * @endif
     */
    virtual int setupLocalVideoCanvas(NERtcVideoCanvas* canvas) = 0;

    /**
     * @if English
     *  Sets views for remote users.
     * <br>This method is used to associate remote users with display views and configure the rendering mode and mirror
     * mode for remote views that are displayed locally. The method affects only video display viewed by local users.
     * @note
     * - You need to specify the uid of remote video when the interface is called. In general cases, the uid can be set
     * before users join the room.
     * - If the user ID is not retrieved, the App calls this method after the onUserJoined event is triggered. To
     * disassociate a specified user from a view, you can leave the canvas parameter empty.
     * - After a user leaves the room, the association between a remote user and the view is cleared.
     * @param[in] uid       The ID of a remote user.
     * @param[in] canvas    The video canvas information.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 设置远端用户视图。
     * <br>通过本接口可以实现绑定远端用户和显示视图，并设置远端用户视图在本地显示时的镜像模式和裁减比例，只影响本地用户看到的视频画面。
     * @since V3.5.0
     * @par 调用时机  
     * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
     * @note
     * 您可以通过设置 canvas 参数为空以解除远端用户视图绑定；退出房间后，SDK 也会主动清除远端用户和视图的绑定关系。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>canvas</td>
     *      <td> \ref nertc::NERtcVideoCanvas "NERtcVideoCanvas" </td>
     *      <td>远端用户视频的画布。</td>
     *  </tr>
     *  <tr>
     *      <td>uid</td>
     *      <td>uid_t</td>
     *      <td>远端用户的 ID。可以在 \ref nertc::IRtcEngineEventHandler::onUserJoined "onUserJoined" 回调中获取。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * nertc::NERtcVideoCanvas canvas;
     * canvas.cb = nullptr;
     * canvas.user_data = nullptr;
     * canvas.window = window;
     * canvas.scaling_mode = nertc::kNERtcVideoScaleFit; 
     * canvas.mirror_mode  = nertc::kNERtcVideoMirrorModeAuto;
     * rtc_engine_->setupRemoteVideoCanvas(uid, canvas);
     * @endcode
     * @par 相关接口
     * 若您希望在通话中更新远端用户视图的渲染模式，请调用 \ref nertc::IRtcEngineEx::setRemoteRenderMode "setRemoteRenderMode" 方法。
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *         - 30001（kNERtcErrFatal）：画布创建失败。
     *         - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未初始化。
     * @endif
     */
    virtual int setupRemoteVideoCanvas(uid_t uid, NERtcVideoCanvas* canvas) = 0;

    /**
     * @if English
     * Enables or disables local audio capture and rendering.
     * <br>The method enables local video capture.
     * @note
     * - You can call this method before or after you join a room.
     * - The method enables the internal engine, which is still valid after you call \ref IRtcEngine::leaveChannel
     * "leaveChannel".
     * - After local video capture is successfully enabled or disabled,  the onUserVideoStop or onUserVideoStart
     * callback is remotely triggered.
     * @param[in] enabled Whether to enable local video capture and rendering.
     * - true: Enables the local video capture and rendering.
     * - false: Disables the local camera device. After local video capture is disabled, remote users cannot receive
     * video streams from local users. However, local users can still receive video streams from remote users. If the
     * setting is false, the local camera is not required to call the method.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 开启或关闭本地视频的采集与发送。
     * <br>通过本接口可以实现开启或关闭本地视频，不影响接收远端视频。
     * @since V3.5.0
     * @par 调用时机  
     * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
     * @note
     * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
     * - 该方法设置内部引擎为开启或关闭状态, 在 \ref IRtcEngine::leaveChannel "leaveChannel" 后仍然有效。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>enabled</td>
     *      <td>bool</td>
     *      <td>是否开启本地视频采集与发送：<ul><li>true：开启本地视频采集。<li>false：关闭本地视频采集，此时不需要本地有摄像头。关闭后，远端用户无法接收到本地用户的视频流；但本地用户仍然可以接收到远端用户的视频流。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * //打开视频
     * rtc_engine_->enableLocalVideo(true);
     * //关闭视频
     * rtc_engine_->enableLocalVideo(false);
     * @endcode
     * @par 相关回调
     * - 开启本地视频采集后，远端会收到 \ref IRtcEngineEventHandler::onUserVideoStart "onUserVideoStart" 回调。
     * - 关闭本地视频采集后，远端会收到 \ref IRtcEngineEventHandler::onUserVideoStop "onUserVideoStop" 回调。
     * @par 相关接口
     * 若您希望开启辅流通道的视频采集，请调用 \ref IRtcEngine::enableLocalVideo(NERtcVideoStreamType type, bool enabled) "enableLocalVideo" 方法。
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *         - 30001（kNERtcErrFatal）：通用错误，一般表示引擎错误，尝试再次调用此接口即可。
     *         - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如已开启外部视频采集。
     *         - 50000（kNERtcRuntimeErrVDMNoAuthorize）：应用未获取到操作系统的摄像头权限。
     * @endif
     */
    virtual int enableLocalVideo(bool enabled) = 0;

    /**
     * @if Chinese
     * 开启或关闭本地视频的采集与发送。
     * <br>通过主流或辅流视频通道进行本地视频流的采集与发送。
     * @since V4.6.20
     * @par 调用时机  
     * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
     * @note
     * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
     * - 该方法设置内部引擎为开启或关闭状态, 在 \ref IRtcEngine::leaveChannel "leaveChannel" 后仍然有效。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>type</td>
     *      <td> \ref nertc::NERtcVideoStreamType "NERtcVideoStreamType"</td>
     *      <td>视频通道类型：<ul><li>kNERTCVideoStreamMain：主流。<li>kNERTCVideoStreamSub：辅流。</td>
     *  </tr>
     *  <tr>
     *      <td>enabled</td>
     *      <td>bool</td>
     *      <td>是否开启本地视频采集与发送：<ul><li>true：开启本地视频采集。<li>false：关闭本地视频采集，此时不需要本地有摄像头。关闭后，远端用户无法接收到本地用户的视频流；但本地用户仍然可以接收到远端用户的视频流。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * //打开视频主流
     * nertc::NERtcVideoStreamType type = nertc::NERtcVideoStreamType::kNERTCVideoStreamMain;
     * bool enable = true;
     * rtc_engine_->enableLocalVideo(type, enable);
     * //关闭视频主流
     * nertc::NERtcVideoStreamType type = nertc::NERtcVideoStreamType::kNERTCVideoStreamMain;
     * bool enable = false;
     * rtc_engine_->enableLocalVideo(type, enable);
     * //打开视频辅流
     * nertc::NERtcVideoStreamType type = nertc::NERtcVideoStreamType::kNERTCVideoStreamSub;
     * bool enable = true;
     * rtc_engine_->enableLocalVideo(type, enable);
     * //关闭视频辅流
     * nertc::NERtcVideoStreamType type = nertc::NERtcVideoStreamType::kNERTCVideoStreamSub;
     * bool enable = false;
     * rtc_engine_->enableLocalVideo(type, enable);
     * @endcode
     * @par 相关回调
     * - type 为 kNERTCVideoStreamMain（主流）时：
     *         - 开启本地视频采集后，远端会收到 \ref IRtcEngineEventHandler::onUserVideoStart "onUserVideoStart" 回调。
     *         - 关闭本地视频采集后，远端会收到 \ref IRtcEngineEventHandler::onUserVideoStop "onUserVideoStop" 回调。
     * - streamType 为 kNERtcVideoStreamTypeSub（辅流）时：
     *         - 开启本地视频采集后，远端会收到 \ref IRtcEngineEventHandlerEx::onUserSubStreamVideoStart "onUserSubStreamVideoStart"  回调。
     *         - 关闭本地视频采集后，远端会收到 \ref IRtcEngineEventHandlerEx::onUserSubStreamVideoStop "onUserSubStreamVideoStop" 回调。
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *         - 30001（kNERtcErrFatal）：通用错误，一般表示引擎错误，尝试再次调用此接口即可。
     *         - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如已开启外部视频采集。
     *         - 30027（kNERtcErrDeviceOccupied）: 所选设备已被占用。比如已通过主流通道开启了摄像头，无法再通过辅流通道开启摄像头。
     *         - 50000（kNERtcRuntimeErrVDMNoAuthorize）：应用未获取到操作系统的摄像头权限。
     * @endif
     */
    virtual int enableLocalVideo(NERtcVideoStreamType type, bool enabled) = 0;

    /** 
     * @if English
     * Subscribes or unsubscribes video streams from specified remote users.
     * - After a user joins a room, the video streams from remote users are not subscribed by default. If you want to
     * view video streams from specified remote users, you can call this method to subscribe to the video streams from
     * the user when the user joins the room or publishes the video streams.
     * - This method can be called only if a user joins a room.
     * @param[in] uid       The user ID.
     * @param[in] type      The type of the subscribed video streams. #NERtcRemoteVideoStreamType.
     * @param[in] subscribe
     * - true: Subscribes to specified video streams. This is the default value.
     * - false: Not subscribing to specified video streams.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 订阅或取消订阅指定远端用户的视频主流。
     * <br>加入房间后，默认不订阅所有远端用户的视频主流；若您希望看到指定远端用户的视频，可以在监听到对方加入房间或发布视频流之后，通过此方法订阅该用户的视频主流。
     * @since V3.5.0
     * @par 调用时机
     * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>uid</td>
     *      <td>uid_t</td>
     *      <td>指定用户的 ID。</td>
     *  </tr>
     *  <tr>
     *      <td>streamType</td>
     *      <td> \ref nertc::NERtcRemoteVideoStreamType "NERtcRemoteVideoStreamType"</td>
     *      <td>订阅的视频流类型：<ul><li>kNERtcRemoteVideoStreamTypeHigh：高清画质的大流。<li>kNERtcRemoteVideoStreamTypeLow：低清画质的小流。<li>kNERtcRemoteVideoStreamTypeNone：不订阅。</td>
     *  </tr>
     *  <tr>
     *      <td>subscribe</td>
     *      <td>bool</td>
     *      <td>是否订阅远端用户的视频流：<ul><li>true：订阅指定视频流。<li>false：不订阅指定视频流。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * //订阅对方uid为12345的大流
     * rtc_engine_->subscribeRemoteVideoStream(12345, nertc::kNERtcRemoteVideoStreamTypeHigh,true);
     * @endcode
     * @par 相关接口
     * 若您希望订阅指定远端用户的视频辅流，请调用 \ref nertc::IRtcEngineEx::subscribeRemoteVideoSubStream "subscribeRemoteVideoSubStream"} 方法。
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30001（kNERtcErrFatal）：画布为空对象，创建远端 peerconnection 失败。
     *      - 30005（kNERtcErrInvalidState)：状态错误，比如引擎尚未初始化。
     *      - 30009（kNERtcErrInvalidDeviceSourceID）：设备 ID 非法。
     *      - 30105（kNERtcErrUserNotFound）：未找到指定用户。
     *      - 30106（kNERtcErrInvalidUserID）：非法指定用户，比如订阅了本端。
     *      - 30107（kNERtcErrMediaNotStarted）：媒体会话未建立，比如对端未开启视频主流。
     *      - 30108（kNERtcErrSourceNotFound）：媒体源未找到，比如对端未开启视频主流。
     * @endif
     */
    virtual int subscribeRemoteVideoStream(uid_t uid, NERtcRemoteVideoStreamType type, bool subscribe) = 0;
};

} // namespace nertc

////////////////////////////////////////////////////////
/** \addtogroup createNERtcEngine
 @{
 */
////////////////////////////////////////////////////////

/**
 * @if English
 * Creates an RTC engine object and returns the pointer.
 * @note Only one IRtcEngine object is supported at the same time. You must release an IRtcEngine before creating a new
 * instance.
 * @return The pointer of the RTC engine object.
 * @endif
 * @if Chinese
 * 创建 RTC 引擎对象并返回指针。
 * @note 同时只支持一个IRtcEngine对象，新创建前必须先释放前一个IRtcEngine。
 * @return RTC 引擎对象的指针。
 * @endif
 */
NERTC_API nertc::IRtcEngine* NERTC_CALL createNERtcEngine();

/**
 * @if English
 * Destroys RTC engine object.
 * @note Call \ref nertc::IRtcEngine::release "release" first before releasing.
 * @endif
 * @if Chinese
 * 销毁 RTC 引擎对象。
 * @note 释放前需要先调用\ref nertc::IRtcEngine::release "release"
 * @endif
 */
NERTC_API void NERTC_CALL destroyNERtcEngine(void*& nertc_engine_inst);

////////////////////////////////////////////////////////
/** @} */
////////////////////////////////////////////////////////

#endif
