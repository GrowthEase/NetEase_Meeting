/** 
* @file nertc_engine_event_handler.h
* @brief The interface header file of expansion callback of the NERTC SDK.
* All parameter descriptions of the NERTC SDK. All string-related parameters (char *) are encoded in UTF-8.
* @copyright (c) 2021, NetEase Inc. All rights reserved.
*/

#ifndef NERTC_ENGINE_EVENT_HANDLER_H
#define NERTC_ENGINE_EVENT_HANDLER_H

#include "nertc_base_types.h"
#include "nertc_error_code.h"
#include "nertc_warn_code.h"
#include "nertc_engine_defines.h"

 /**
 * @namespace nertc 
 * @brief namespace nertc
 */
namespace nertc
{
/** 
 * @if English
 * IRtcEngineEventHandler callback interface class is used to send callback event notifications to the app from SDK. The app gets event notifications from the SDK through inheriting the interface class. 
 * All methods in this interface class have their (empty) default implementations, and the application can inherit only some of the required events instead of all of them. When calling a callback method, the application must not implement time-consuming operations or call blocking-triggered APIs. For example, if you want to enable audio and video, the SDK may be affected in the runtime.
 * @endif
 * @if Chinese
 * IRtcEngineEventHandler 回调接口类用于 SDK 向 App 发送回调事件通知，App 通过继承该接口类的方法获取 SDK 的事件通知。
 * 接口类的所有方法都有缺省（空）实现，App 可以根据需要只继承关心的事件。在回调方法中，App 不应该做耗时或者调用可能会引起阻塞的 API（如开启音频或视频等），否则可能影响 SDK 的运行。
 * @endif
 */
class IRtcEngineEventHandler
{
public:
    virtual ~IRtcEngineEventHandler() {}

    /** 
     * @if English
     * Occurs when the error occurs. 
     * <br>The callback is triggered to report an error related to network or media during SDK runtime. In most cases, the SDK cannot fix the issue and resume running. The SDK requires the app to take action or informs the user of the issue.
     * @param error_code        The error code. For more information, see NERtcDMErrorCode.
     * @param msg               Error description.
     * @endif
     * @if Chinese
     * 发生错误回调。
     * <br>该回调方法表示 SDK 运行时出现了（网络或媒体相关的）错误。通常情况下，SDK上报的错误意味着SDK无法自动恢复，需要 App 干预或提示用户。
     * @param error_code        错误码。详细信息请参考 NERtcDMErrorCode
     * @param msg 错误描述。
     * @endif
     */
    virtual void onError(int error_code, const char* msg) {
        (void)error_code;
        (void)msg;
    }

    /** 
     * @if English
     * Occurs when a warning occurs.
     * <br>The callback is triggered to report a warning related to network or media during SDK runtime. In most cases, the app ignores the warning message and the SDK resumes running.
     * @param warn_code     The warning code. For more information, see {@link NERtcWarnCode}.
     * @param msg        The warning description.
     * @endif
     * @if Chinese
     * 发生警告回调。
     * <br>该回调方法表示 SDK 运行时出现了（网络或媒体相关的）警告。通常情况下，SDK 上报的警告信息 App 可以忽略，SDK 会自动恢复。
     * @param warn_code 警告码。详细信息请参考 {@link NERtcWarnCode}。
     * @param msg 警告描述。
     * @endif
     */
    virtual void onWarning(int warn_code, const char* msg) {
        (void)warn_code;
        (void)msg;
    }
    
    /** 
     * @if English
     * Occurs when an API call finished.
     * <br>This callback method indicates that the SDK has finished executing a user's API call.
     * @param api_name     The API name.
     * @param error        The execute result code.
     * @param message      The execute result message.
     * @endif
     * @if Chinese
     * API调用结束回调。
     * <br>该回调方法表示 SDK 执行完了一个用户的API调用。
     * @param api_name     API名称
     * @param error        API执行结果错误码。
     * @param message      API执行结果描述。
     * @endif
     */
    virtual void onApiCallExecuted(const char* api_name, NERtcErrorCode error, const char* message) {
        (void)api_name;
        (void)error;
        (void)message;
    }

    /** 
     * @if English
     * Occurs when the hardware resources are released.
     * <br>The SDK prompts whether hardware resources are successfully released. 
     * @param result    The result.
     * @endif
     * @if Chinese
     * 释放硬件资源的回调。
     * <br>SDK提示释放硬件资源是否成功。
     * @param result    返回结果。
     * @endif
     */
    virtual void onReleasedHwResources(NERtcErrorCode result) {
        (void)result;
    }

    /** 
     * @if English
     * Allows a user to join a room. The callback indicates that the client has already signed in.
     * @param cid     The ID of the room that the client joins.
     * @param uid     Specifies the ID of a user. If you specify the uid in the joinChannel method, a specificed ID is returned at the time. If not, the  ID automatically assigned by the CommsEase’s server is returned.
     * @param result  Indicates the result.
     * @param elapsed The time elapsed from calling the joinChannel method to the occurrence of this event. Unit: milliseconds.
     * @endif
     * @if Chinese
     * 加入房间回调，表示客户端已经登入服务器。
     * @param cid     客户端加入的房间 ID。
     * @param uid     用户 ID。如果在 joinChannel 方法中指定了 uid，此处会返回指定的 ID; 如果未指定 uid（joinChannel 时uid=0），此处将返回云信服务器自动分配的 ID。
     * @param result  返回结果。
     * @param elapsed 从 joinChannel 开始到发生此事件过去的时间，单位为毫秒。
     * @endif
     */
    virtual void onJoinChannel(channel_id_t cid, uid_t uid, NERtcErrorCode result, uint64_t elapsed) {
        (void)cid;
        (void)uid;
        (void)result;
        (void)elapsed;
    }

    /** 
     * @if English
     * Triggers reconnection.
     * <br>In some cases, a client may be disconnected from the server, the SDK starts reconnecting. The callback is triggered when the reconnection starts.
     * @param cid Specifies the ID of a room.
     * @param uid Specifies the ID of a user.
     * @endif
     * @if Chinese
     * 触发重连。
     * <br>有时候由于网络原因，客户端可能会和服务器失去连接，SDK会进行自动重连，开始自动重连后触发此回调。
     * @param cid  房间 ID。
     * @param uid  用户 ID。
     * @endif
     */
    virtual void onReconnectingStart(channel_id_t cid, uid_t uid) {
        (void)cid;
        (void)uid;
    }

    /** 
     * @if English
     * Occurs when the state of channel connection is changed.
     * <br>The callback is triggered when the state of channel connection is changed. The callback returns the current state of channel connection and the reason why the state changes.
     * @param state     The state of current channel connection.
     * @param reason    The reason why the state changes.
     * @endif
     * @if Chinese
     * 房间连接状态已改变回调。
     * <br>该回调在房间连接状态发生改变的时候触发，并告知用户当前的房间连接状态和引起房间状态改变的原因。
     * @param state     当前的房间连接状态。
     * @param reason    引起当前房间连接状态发生改变的原因。
     * @endif
     */
    virtual void onConnectionStateChange(NERtcConnectionStateType state, NERtcReasonConnectionChangedType reason) {
        (void)state;
        (void)reason;
    }

    /** 
     * @if English
     * Occurs when a user rejoins a room.
     * <br>If a client is disconnected from the server due to poor network quality, the SDK starts reconnecting. If the client and server are reconnected, the callback is triggered.
     * @param cid       The ID of the room that the client joins.
     * @param uid       The ID of a user.
     * @param result    The result.
     * @param elapsed   The time elapsed from reconnection to the occurrence of this event. Unit: milliseconds.
     * @endif
     * @if Chinese
     * 重新加入房间回调。
     * <br>在弱网环境下，若客户端和服务器失去连接，SDK会自动重连。自动重连成功后触发此回调方法。
     * @param cid       客户端加入的房间 ID。
     * @param uid       用户 ID。
     * @param result    返回结果。
     * @param elapsed   从开始重连到发生此事件过去的时间，单位为毫秒。
     * @endif
     */
    virtual void onRejoinChannel(channel_id_t cid, uid_t uid, NERtcErrorCode result, uint64_t elapsed) {
        (void)cid;
        (void)uid;
        (void)result;
    }

    /** 
     * @if English
     * Occurs when a user leaves a room.
     * <br>After an app invokes the leaveChannel method, SDK prompts whether the app successfully leaves the room.
     * @param result    The result.
     * @endif
     * @if Chinese
     * 退出房间回调。
     * <br>App 调用 leaveChannel 方法后，SDK 提示 App 退出房间是否成功。
     * @param result    返回结果。错误码请参考 #NERtcErrorCode 。在快速切换房间时 code 为 kNERtcErrChannelLeaveBySwitchAction。
     * @endif
     */
    virtual void onLeaveChannel(NERtcErrorCode result) {
        (void)result;
    }

    /** 
     * @if English
     * Network connection interruption.
     * @note
     * - The callback is triggered if the SDK fails to connect to the server three consecutive times after you successfully call the joinChannel method.
     * - A client may be disconnected from the server in poor network connection. At this time,  the SDK needs not automatically reconnecting until the SDK triggers the callback method.
     * @param reason    The reason why the network is disconnected.
     * @endif
     * @if Chinese
     * 与服务器连接中断，可能原因包括：网络连接失败、服务器关闭该房间、用户被踢出房间等。
     * @note
     * - SDK 在调用 joinChannel 加入房间成功后，如果和服务器失去连接且连续 3 次重连失败，就会触发该回调。
     * - 由于非网络原因，客户端可能会和服务器失去连接，此时SDK无需自动重连，直接触发此回调方法。
     * @param reason    连接中断原因。
     * @endif
     */
    virtual void onDisconnect(NERtcErrorCode reason) {
        (void)reason;
    }
    
    /** 
     * @if English
     * Occurs when a user changes the role in live streaming.
     * <br>After the local user joins a room, the user can call the \ref IRtcEngine::setClientRole "setClientRole" to change the role. Then, the callback is triggered. For example, you can switch the role from host to audience, or from audience to host.
     * @note In live streaming, if you join a room and successfully call this method to change the role, the following callbacks are triggered.
     * - If the role changes from host to audience, the onClientRoleChange is locally triggered, and the \ref nertc::IRtcEngineEventHandler::onUserLeft "onUserLeft" is remotely triggered. 
     * - If the role is changed from audience to host, the onClientRoleChange callback is locally triggered, and the \ref nertc::IRtcEngineEventHandler::onUserJoined "onUserJoined" is remotely triggered. 
     * @param oldRole  The role before the user changes the role.
     * @param newRole  The role after the change. 
     * @endif
     * @if Chinese
     * 直播场景下用户角色已切换回调。
     * <br>本地用户加入房间后，通过 \ref nertc::IRtcEngine::setClientRole() "setClientRole" 切换用户角色后会触发此回调。例如主播切换为观众、从观众切换为主播。
     * @note 直播场景下，如果您在加入房间后调用该方法切换用户角色，调用成功后，会触发以下回调：
     * - 主播切观众，本端触发 onClientRoleChanged 回调，远端触发 \ref nertc::IRtcEngineEventHandler::onUserLeft "onUserLeft" 回调。
     * - 观众切主播，本端触发 onClientRoleChanged 回调，远端触发 \ref nertc::IRtcEngineEventHandler::onUserJoined "onUserJoined" 回调。
     * @param oldRole  切换前的角色。详细信息请参考 {@link NERtcClientRole}。
     * @param newRole  切换后的角色。详细信息请参考 {@link NERtcClientRole}。
     * @endif
     */
    virtual void onClientRoleChanged(NERtcClientRole oldRole, NERtcClientRole newRole) {
        (void)oldRole;
        (void)newRole;
    }

    /** 
     * @if English
     * Occurs when a remote user joins the current room.
     * <br>The callback prompts that a remote user joins the room and returns the ID of the user that joins the room. If the user ID already exists, the remote user also receives a message that the user already joins the room, which is returned by the callback.
     * @param uid           The ID of the user that joins the room.
     * @param user_name     The name of the remote user who joins the room.
     * @endif
     * @if Chinese
     * 远端用户（通信场景）/主播（直播场景）加入当前频道回调。
     * - 通信场景下，该回调提示有远端用户加入了频道，并返回新加入用户的 ID；如果加入之前，已经有其他用户在频道中了，新加入的用户也会收到这些已有用户加入频道的回调
     * - 直播场景下，该回调提示有主播加入了频道，并返回该主播的用户 ID。如果在加入之前，已经有主播在频道中了，新加入的用户也会收到已有主播加入频道的回调。

     * 该回调在如下情况下会被触发：
     * - 远端用户调用 joinChannel 方法加入房间。
     * - 远端用户网络中断后重新加入房间。
     * @note
     * 直播场景下：
        * - 主播间能相互收到新主播加入频道的回调，并能获得该主播的用户 ID。
        * - 观众也能收到新主播加入频道的回调，并能获得该主播的用户 ID。
        * - 当 Web 端加入直播频道时，只要 Web 端有推流，SDK 会默认该 Web 端为主播，并触发该回调。
     * @param uid           新加入房间的远端用户 ID。
     * @param user_name     新加入房间的远端用户名。
     * @endif
     */
    virtual void onUserJoined(uid_t uid, const char * user_name) {
        (void)uid;
        (void)user_name;
    }

    /**
     * @if English
     * Occurs when a remote user joins the current room.
     * <br>The callback prompts that a remote user joins the room and returns the ID of the user that joins the room. If
     the user ID already exists, the remote user also receives a message that the user already joins the room, which is
     returned by the callback.
     * @param uid           The ID of the user that joins the room.
     * @param user_name     The name of the remote user who joins the room.
     * @since V4.6.25
     * @endif
     * @if Chinese
     * 远端用户加入房间事件回调。
     * 远端用户加入房间或断网重连后，SDK 会触发该回调，可以通过返回的用户 ID 订阅对应用户发布的音、视频流。
     *      - 通信场景下，该回调通知有远端用户加入了房间，并返回新加入用户的 ID；若该用户加入之前，已有其他用户在房间中，该新加入的用户也会收到这些已有用户加入房间的回调。
     *      - 直播场景下，该回调通知有主播加入了房间，并返回该主播的用户 ID；若该用户加入之前，已经有主播在频道中了，新加入的用户也会收到已有主播加入房间的回调。
     * @since V4.6.29
     * @par 使用前提
     * 请在 IRtcEngineEventHandler 接口类中通过 \ref IRtcEngine::initialize "initialize" 接口设置回调监听。
     * @note
     * - 同类型事件发生后，\ref IRtcEngineEventHandler::onUserJoined(uid_t uid, const char * user_name) "onUserJoined" 回调可能会与该回调同时触发，建议您仅注册此回调，不能同时处理两个回调。
     * - 当 Web 端用户加入直播场景的房间中，只要该用户发布了媒体流，SDK 会默认该用户为主播，并触发此回调。
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
     *      <td>新加入房间的远端用户 ID。</td>
     *  </tr>
     *  <tr>
     *      <td>join_extra_info</td>
     *      <td>\ref nertc::NERtcUserJoinExtraInfo "NERtcUserJoinExtraInfo"</td>
     *      <td>该远端用户加入的额外信息。</td>
     *  </tr>
     * </table> 
     * @endif
     */
    virtual void onUserJoined(uid_t uid, const char* user_name, NERtcUserJoinExtraInfo join_extra_info) {
        (void)uid;
        (void)user_name;
        (void)join_extra_info;
    }

    /** 
     * @if English
     * Occurs when a remote user leaves a room.
     * <br>A message is returned indicates that a remote user leaves the room or becomes disconnected. In most cases, a user leaves a room due to the following reasons: The user exit the room or connections time out. 
     * - When a user leaves a room, remote users will receive callback notifications that users leave the room. In this way, users can be specified to leave the room.
     * - If the connection times out, and the user does not receive data packets for a time period of 40 to 50 seconds, then the user becomes disconnected.
     * @param uid           The ID of the user that leaves the room.
     * @param reason        The reason why remote user leaves.
     * @endif
     * @if Chinese
     * 远端用户离开当前房间的回调。
     * <br>提示有远端用户离开了房间（或掉线）。通常情况下，用户离开房间有两个原因，即正常离开和超时掉线：
     * - 正常离开的时候，远端用户会收到正常离开房间的回调提醒，判断用户离开房间。
     * - 超时掉线的依据是，在一定时间内（40~50s），用户没有收到对方的任何数据包，则判定为对方掉线。
     * @param uid           离开房间的远端用户 ID。
     * @param reason        远端用户离开原因。
     * - kNERtcSessionLeaveNormal(0)：正常离开。
     * - kNERtcSessionLeaveForFailOver(1)：用户断线导致离开房间。
     * - kNERTCSessionLeaveForUpdate(2)：用户因 Failover 导致离开房间，仅 SDK 内部使用。
     * - kNERtcSessionLeaveForKick(3)：用户被踢导致离开房间。
     * - kNERtcSessionLeaveTimeout(4)：用户超时退出房间。
     * @endif
     */
    virtual void onUserLeft(uid_t uid, NERtcSessionLeaveReason reason) {
        (void)uid;
        (void)reason;
    }

    /**
     * @if English
     * Occurs when a remote user leaves a room.
     * <br>A message is returned indicates that a remote user leaves the room or becomes disconnected. In most cases, a
     * user leaves a room due to the following reasons: The user exit the room or connections time out.
     * - When a user leaves a room, remote users will receive callback notifications that users leave the room. In this
     * way, users can be specified to leave the room.
     * - If the connection times out, and the user does not receive data packets for a time period of 40 to 50 seconds,
     * then the user becomes disconnected.
     * @param uid           The ID of the user that leaves the room.
     * @param reason        The reason why remote user leaves.
     * @since V4.6.25
     * @endif
     * @if Chinese
     * 远端用户离开房间事件回调。
     * - 远端用户离开房间或掉线（在 40 ~ 50 秒内本端用户未收到远端用户的任何数据包）后，SDK 会触发该回调。
     * @since V4.6.29
     * @par 使用前提
     * 请在 IRtcEngineEventHandler 接口类中通过 nertc::IRtcEngine::initialize "initialize" 接口设置回调监听。
     * @note
     * 同类型事件发生后，\ref nertc::IRtcEngineEventHandler::onUserLeft(uid_t uid, NERtcSessionLeaveReason reason) "onUserLeft" 回调可能会与该回调同时触发，建议您仅注册此回调，不能同时处理两个回调。
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
     *      <td>离开房间的远端用户 ID。</td>
     *  </tr>
     *  <tr>
     *      <td>reason</td>
     *      <td> /ref nertc::NERtcSessionLeaveReason</td>
     *      <td>该远端用户离开的原因，更多请参考 \ref nertc::NERtcErrorCode "NERtcErrorCode"。<ul><li>kNERtcSessionLeaveNormal（0）：正常离开。<li>kNERtcSessionLeaveForFailOver（1）：用户断线导致离开房间。<li>kNERTCSessionLeaveForUpdate（2）：用户因 Failover 导致离开房间，仅 SDK 内部使用。<li>kNERtcSessionLeaveForKick（3）：用户被踢导致离开房间。<li>kNERtcSessionLeaveTimeout（4）：用户超时退出房间。</td>
     *  </tr>
     *  <tr>
     *      <td>leave_extra_info</td>
     *      <td> \ref nertc::NERtcUserJoinExtraInfo</td>
     *      <td>该远端用户离开的额外信息。</td>
     *  </tr>
     * </table> 
     * @endif
     */
    virtual void onUserLeft(uid_t uid, NERtcSessionLeaveReason reason, NERtcUserJoinExtraInfo leave_extra_info) {
        (void)uid;
        (void)reason;
        (void)leave_extra_info;
    }

    /** 
     * @if English
     * Occurs when a remote user enables audio.
     * @param uid           The ID of a remote user.
     * @endif
     * @if Chinese
     * 远端用户开启音频的回调。
     * @note 该回调由远端用户调用 enableLocalAudio 方法开启音频采集和发送触发。
     * @param uid           远端用户ID。
     * @endif
     */
    virtual void onUserAudioStart(uid_t uid) {
        (void)uid;
    }
    /** 
     * @if English
     * Occurs when a remote user disables audio.
     * @param uid           The ID of a remote user.
     * @endif
     * @if Chinese
     * 远端用户停用音频的回调。
     * @note 该回调由远端用户调用 enableLocalAudio 方法关闭音频采集和发送触发。
     * @param uid           远端用户ID。
     * @endif
     */
    virtual void onUserAudioStop(uid_t uid) {
        (void)uid;
    }
    /** 
     * @if English
     * Occurs when a remote user enables video.
     * @param uid           The ID of a remote user.
     * @param max_profile   The resolution of video encoding measures the encoding quality.
     * @endif
     * @if Chinese
     * 远端用户开启视频的回调。
     * <br> 启用后，用户可以进行视频通话或直播。
     * @param uid           远端用户ID。
     * @param max_profile   视频编码的分辨率，用于衡量编码质量。
     * @endif
     */
    virtual void onUserVideoStart(uid_t uid, NERtcVideoProfileType max_profile) {
        (void)uid;
        (void)max_profile;
    }
    /** 
     * @if English
     * Occurs when a remote user disables video.
     * @param uid           The ID of a remote user.
     * @endif
     * @if Chinese
     * 远端用户停用视频的回调。
     * <br> 关闭后，用户只能进行语音通话或者直播。
     * @param uid           远端用户ID。
     * @endif
     */
    virtual void onUserVideoStop(uid_t uid) {
        (void)uid;
    }

};
} // namespace nertc

#endif
