/** @file nertc_channel_event_handler.h
* @brief NERTC SDK IRtcChannel回调接口头文件。
* NERTC SDK所有接口参数说明: 所有与字符串相关的参数(char *)全部为UTF-8编码。
* @copyright (c) 2015-2021, NetEase Inc. All rights reserved
* @date 2021/05/10
*/

#ifndef NERTC_CHANNEL_EVENT_HANDLER_H
#define NERTC_CHANNEL_EVENT_HANDLER_H

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
 * IRtcChannelEventHandler callback interface class is used to send IRtcChannel callback event notifications to the app from SDK. The app gets IRtcChannel event notifications from the SDK through inheriting the interface class. 
 * <br>All methods in this interface class have their (empty) default implementations, and the application can inherit only some of the required events instead of all of them. When calling a callback method, the application must not implement time-consuming operations or call blocking-triggered APIs. For example, if you want to enable audio and video, the SDK may be affected in the runtime.
 * @since V4.5.0
 * @endif
 * @if Chinese
 * IRtcChannelEventHandler 回调接口类用于 SDK 向 App 发送IRtcChannel回调事件通知，App 通过继承该接口类的方法获取 SDK IRtcChannel的事件通知。
 * <br>接口类的所有方法都有缺省（空）实现，App 可以根据需要只继承关心的事件。在回调方法中，App 不应该做耗时或者调用可能会引起阻塞的 API（如开启音频或视频等），否则可能影响 SDK 的运行。
 * @endif
 */
class IRtcChannelEventHandler
{
public:
    virtual ~IRtcChannelEventHandler() {}

    /** 
     * @if English
     * Occurs when the error occurs. 
     * <br>The callback is triggered to report an error related to network or media during SDK runtime. In most cases, the SDK cannot fix the issue and resume running. The SDK requires the app to take action or informs the user of the issue.
     * @param error_code    The error code. For more information, see NERtcDMErrorCode.
     * @param msg           Error description.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 发生错误回调。
     * <br>该回调方法表示 SDK 运行时出现了（网络或媒体相关的）错误。通常情况下，SDK上报的错误意味着SDK无法自动恢复，需要 App 干预或提示用户。
     * @param error_code    错误码。详细信息请参考 NERtcDMErrorCode
     * @param msg           错误描述。
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
     * @param msg           The warning description.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 发生警告回调。
     * <br>该回调方法表示 SDK 运行时出现了（网络或媒体相关的）警告。通常情况下，SDK 上报的警告信息 App 可以忽略，SDK 会自动恢复。
     * @param warn_code     警告码。详细信息请参考 {@link NERtcWarnCode}。
     * @param msg           警告描述。
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
     * Allows a user to join a room. The callback indicates that the client has already signed in.
     * @param cid     The ID of the room that the client joins.
     * @param uid     Specifies the ID of a user. If you specify the uid in the joinChannel method, a specificed ID is returned at the time. If not, the  ID automatically assigned by the CommsEase’s server is returned.
     * @param result  Indicates the result.
     * @param elapsed The time elapsed from calling the joinChannel method to the occurrence of this event. Unit: milliseconds.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 加入房间回调，表示客户端已经登入服务器。
     * @param cid       客户端加入的房间 ID。
     * @param uid       用户 ID。 如果在 joinChannel 方法中指定了 uid，此处会返回指定的 ID; 如果未指定 uid（joinChannel 时uid=0），此处将返回云信服务器自动分配的 ID。
     * @param result    返回结果。
     * @param elapsed   从 joinChannel 开始到发生此事件过去的时间，单位为毫秒。
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
     * @param cid   Specifies the ID of a room.
     * @param uid   Specifies the ID of a user.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 触发重连。
     * <br>有时候由于网络原因，客户端可能会和服务器失去连接，SDK会进行自动重连，开始自动重连后触发此回调。
     * @param cid   房间 ID。
     * @param uid   用户 ID。
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
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 房间连接状态已改变回调。
     * <br>该回调在房间连接状态发生改变的时候触发，并告知用户当前的房间连接状态和引起房间状态改变的原因。
     * @since V4.5.0
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
     * @since V4.5.0
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
     * @since V4.5.0
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
     * @since V4.5.0
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
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 直播场景下用户角色已切换回调。
     * <br>本地用户加入房间后，通过 \ref nertc::IRtcChannel::setClientRole() "setClientRole" 切换用户角色后会触发此回调。例如主播切换为观众、从观众切换为主播。
     * @note 直播场景下，如果您在加入房间后调用该方法切换用户角色，调用成功后，会触发以下回调：
     * - 主播切观众，本端触发 onClientRoleChanged 回调，远端触发 \ref nertc::IRtcEngineEventHandler::onUserLeft(uid_t uid, NERtcSessionLeaveReason reason, NERtcUserJoinExtraInfo leave_extra_info) "onUserLeft" 回调。
     * - 观众切主播，本端触发 onClientRoleChanged 回调，远端触发 \ref nertc::IRtcChannelEventHandler::onUserJoined() "onUserJoined" 回调。
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
     * @since V4.5.0
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
     * <br>The callback prompts that a remote user joins the room and returns the ID of the user that joins the room. If the user ID already exists, the remote user also receives a message that the user already joins the room, which is returned by the callback.
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
     * 请在 IRtcChannelEventHandler 接口类中通过 \ref IRtcChannel::setChannelEventHandler "setChannelEventHandler" 接口设置回调监听。
     * @note
     * - 同类型事件发生后，\ref IRtcChannelEventHandler::onUserJoined(uid_t uid, const char * user_name) "onUserJoined" 回调可能会与该回调同时触发，建议您仅注册此回调，不能同时处理两个回调。
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
     * @since V4.5.0
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
     * 请在 IRtcChannelEventHandler 接口类中通过 nertc::IRtcChannel::setChannelEventHandler "setChannelEventHandler" 接口设置回调监听。
     * @note
     * 同类型事件发生后，\ref nertc::IRtcChannelEventHandler::onUserLeft(uid_t uid, NERtcSessionLeaveReason reason) "onUserLeft" 回调可能会与该回调同时触发，建议您仅注册此回调，不能同时处理两个回调。
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
     * @param uid       The ID of a remote user.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 远端用户开启音频的回调。
     * @note 该回调由远端用户调用 enableLocalAudio 方法开启音频采集和发送触发。
     * @param uid       远端用户ID。
     * @endif
     */
    virtual void onUserAudioStart(uid_t uid) {
        (void)uid;
    }
    /** 
     * @if English
     * Occurs when a remote user disables audio.
     * @param uid       The ID of a remote user.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 远端用户停用音频的回调。
     * @note 该回调由远端用户调用 enableLocalAudio 方法关闭音频采集和发送触发。
     * @param uid       远端用户ID。
     * @endif
     */
    virtual void onUserAudioStop(uid_t uid) {
        (void)uid;
    }
    /** 
     * @if English
     * Callbacks that specify whether to mute remote users.
     * @param uid       The ID of a remote user.
     * @param mute      Whether to unmute the remote user.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 远端用户是否静音的回调。
     * @note 该回调由远端用户调用 muteLocalAudioStream 方法开启或关闭音频发送触发。
     * @param uid       远端用户ID。
     * @param mute      是否静音。
     * @endif
     */
    virtual void onUserAudioMute(uid_t uid, bool mute) {
        (void)uid;
        (void)mute;
    }

    /**
     * @if English
     * Occurs when a remote user enables the audio substream.
     * @since V4.6.10
     * @param uid Remote user ID.
     * @endif
     * @if Chinese
     * 远端用户开启音频辅流回调。
     * @since V4.6.10
     * @param uid 远端用户 ID。
     * @endif
     */
    virtual void onUserSubStreamAudioStart(uid_t uid) { (void)uid; }
    /**
     * @if English
     * Occurs when a remote user stops the audio substream.
     * @since V4.6.10
     * @param uid remote user ID.
     * @endif
     * @if Chinese
     * 远端用户停用音频辅流回调。
     * @since V4.6.10
     * @param uid 远端用户 ID。
     * @endif
     */
    virtual void onUserSubStreamAudioStop(uid_t uid) { (void)uid; }

    /** 
     * @if English
     * Occurs when a remote user pauses or resumes publishing the audio substream.
     * @since V4.6.10
     * @param uid   User ID indicating which user perform the operation.
     * @param mute indicates if the audio substream is stopped.
     *               - true: stops publishing the audio substream.
     *               - false: resumes publishing the audio substream.
     * @endif
     * @if Chinese
     * 远端用户暂停或恢复发送音频辅流的回调。
     * @since V4.6.10
     * @param uid 远端用户ID。
     * @param mute 是否停止发送音频辅流。
     *               - true：该用户已暂停发送音频辅流。
     *               - false：该用户已恢复发送音频辅流。
     * @endif
     */
    virtual void onUserSubStreamAudioMute(uid_t uid, bool mute) {
        (void)uid;
        (void)mute;
    }
    /** 
     * @if English
     * Occurs when a remote user enables video.
     * @param uid               The ID of a remote user.
     * @param max_profile       The resolution of video encoding measures the encoding quality.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 远端用户开启视频的回调。
     * <br> 启用后，用户可以进行视频通话或直播。
     * @param uid               远端用户ID。
     * @param max_profile       视频编码的分辨率，用于衡量编码质量。
     * @endif
     */
    virtual void onUserVideoStart(uid_t uid, NERtcVideoProfileType max_profile) {
        (void)uid;
        (void)max_profile;
    }
    /** 
     * @if English
     * Occurs when a remote user disables video.
     * @param uid       The ID of a remote user.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 远端用户停用视频的回调。
     * <br> 关闭后，用户只能进行语音通话或者直播。
     * @param uid       远端用户ID。
     * @endif
     */
    virtual void onUserVideoStop(uid_t uid) {
        (void)uid;
    }
    /** 
     * @if English
     * Occurs when a remote user stops or resumes sending video streams. 
     * @param uid       The ID of a remote user.
     * @param mute      Whether to disable video streams.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 远端用户暂停或恢复发送视频流的回调。
     * <br>当远端用户调用 muteLocalVideoStream 取消或者恢复发布视频流时，SDK会触发该回调向本地用户报告远程用户的发流状况。
     * @note 该回调仅在远端用户的视频主流状态改变时会触发，若您希望同时接收到远端用户视频辅流状态变更的通知，请监听 \ref IRtcChannelEventHandler::onUserVideoMute(NERtcVideoStreamType videoStreamType, uid_t uid, bool mute) "onUserVideoMute" 回调。
     * @param uid       远端用户ID。
     * @param mute      是否暂停发送视频流。
        * - true：该用户已暂停发送视频流。
        * = false：该用户已恢复发送视频流。
     * @endif
     */
    virtual void onUserVideoMute(uid_t uid, bool mute) {
        (void)uid;
        (void)mute;
    }

    /**
     * @if Chinese
     * 远端用户暂停或恢复发送视频回调。
     * <br>当远端用户调用 \ref IRtcEngineEx::muteLocalVideoStream "muteLocalVideoStream" 方法取消或者恢复发布视频流时，SDK 会触发该回调向本地用户通知远端用户的发流情况。
     * @since V4.6.20
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>videoStreamType</td>
     *      <td> \ref nertc::NERtcVideoStreamType "NERtcVideoStreamType"</td>
     *      <td>视频通道类型：<ul><li>kNERTCVideoStreamMain：主流。<li>kNERtcVideoStreamSub：辅流。</td>
     *  </tr>
     *  <tr>
     *      <td>uid</td>
     *      <td>uid_t</td>
     *      <td>用户 ID，提示是哪个用户的视频流。</td>
     *  </tr>
     *  <tr>
     *      <td>mute</td>
     *      <td>bool</td>
     *      <td>是否暂停发送视频流：<ul><li>true：该用户已暂停发送视频流。<li>false：该用户已恢复发送视频流。</td>
     *  </tr>
     * </table>
     * @endif
     */
    virtual void onUserVideoMute(NERtcVideoStreamType videoStreamType, uid_t uid, bool mute) {
        (void)videoStreamType;
        (void)uid;
        (void)mute;
    }
	
    /** 
     * @if English
     * Occurs when a remote user enables screen sharing by using the substream.
     * @param uid           The ID of a remote user.
     * @param max_profile   The largest resolution of the remote video.
     * 
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 远端用户开启屏幕共享辅流通道的回调。
     * @param uid           远端用户 ID。
     * @param max_profile   最大分辨率。
     * @endif
     */
    virtual void onUserSubStreamVideoStart(uid_t uid, NERtcVideoProfileType max_profile) {
        (void)uid;
        (void)max_profile;
    }
    /** 
     * @if English
     * Occurs when a remote user stops screen sharing by using the substream.
     * @param uid           The ID of a remote user.
     * 
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 远端用户停止屏幕共享辅流通道的回调。
     * @param uid           远端用户ID。
     * @endif
     */
    virtual void onUserSubStreamVideoStop(uid_t uid) {
        (void)uid;
    }

    /** 
     * @if English
     * Occurs when screen sharing is paused/resumed/started/ended. 
     * <br>The method applies to Windows only.
     * @since V4.5.0
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 屏幕共享状态变化回调。
     * @since V4.5.0
     * @note macOS 平台自 V4.6.0 支持此回调。
     * @endif
     */
    virtual void onScreenCaptureStatus(NERtcScreenCaptureStatus status) {
        (void)status;
    }

    /**
     * @if English
     *
     * <br>The method applies to Windows & macOS only.
     * @since V5.4.x
     * @param data    Screen capture data. For more information, see #NERtcScreenCaptureSourceData.
     * @endif
     * @if Chinese
     * 屏幕共享源采集范围等变化的回调。如果要app层实现屏幕分享高亮框实现的话，需要注意在调用#startScreenCaptureByWindowId,
     * startScreenCaptureByDisplayId, startScreenCaptureByScreenRect时，参数NERtcScreenCaptureParameters中enable_high_light设置false，关闭SDK提供的高亮框，以免出现两个高亮框的情况。
     * enable_high_light 和 force_update_data 设置为 true 时，也会有变化回调。例如使用SDK高亮时，同时需要获取窗口区域，实现批注功能。
     * @since V5.4.x
     * @note 自 V5.4.x 支持此回调。
     * @param data    屏幕共享源变化的信息。详细信息请参考 #NERtcScreenCaptureSourceData 。
     * @endif
     */
    virtual void onScreenCaptureSourceDataUpdate(NERtcScreenCaptureSourceData data) {}

    /** 
     * @if English
     * Occurs when the first audio frame from a remote user is received.
     * @param uid       The ID of a remote user whose audio streams are sent. 
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 已接收到远端音频首帧的回调。
     * @param uid       远端用户 ID，指定是哪个用户的音频流。 
     * @endif
     */
    virtual void onFirstAudioDataReceived(uid_t uid) {
        (void)uid;
    }

    /**
    * @if English
    * Occurs when the first video frame from a remote user is displayed.
    * <br>If the first video frame from a remote user is displayed in the view, the callback is triggered.
    * @param uid       The ID of a user whose audio streams are sent.
    * @since V4.5.0
    * @endif
    * @if Chinese
    * 已显示首帧远端视频的回调。
    * <br>第一帧远端视频显示在视图上时，触发此调用。
    * @note 该回调仅在显示远端用户的主流视频首帧时会触发，若您希望同时接收到接收辅流的相关通知，请监听 \ref IRtcChannelEventHandler::onFirstVideoDataReceived(NERtcVideoStreamType type, uid_t uid) "onFirstVideoDataReceived" 回调。
    * @param uid       用户 ID，指定是哪个用户的视频流。
    * @endif
    */
    virtual void onFirstVideoDataReceived(uid_t uid) {
      (void)uid;
    }

    /**
     * @if Chinese
     * 已显示首帧远端视频的回调。
     * <br>当远端视频的第一帧画面显示在视窗上时，会触发此回调。
     * @since V4.6.20
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
     *      <td>视频通道类型：<ul><li>kNERTCVideoStreamMain：主流。<li>kNERtcVideoStreamSub：辅流。</td>
     *  </tr>
     *  <tr>
     *      <td>uid</td>
     *      <td>uid_t</td>
     *      <td>用户 ID，提示是哪个用户的视频流。</td>
     *  </tr>
     * </table>
     * @endif
     */
    virtual void onFirstVideoDataReceived(NERtcVideoStreamType type, uid_t uid) {
        (void)uid;
        (void)type;
    }
  
    /**
     * @if Chinese
     * 接收的远端视频分辨率变化回调。
     * @since V5.4.1
     * @par 触发时机
     * <br>当远端用户视频流的分辨率发生变化时，会触发此回调，例如推流端调用 SetVideoConfig 更改了编码分辨率设置，本地会收到该远端用户分辨率变化通知。
     * @par 业务场景
     * 开发者可根据视频流的最新分辨率来更新 UI。
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
     *      <td>远端用户ID，指定是哪个用户的视频流</td>
     *  </tr>
     *  <tr>
     *      <td>type</td>
     *      <td>see #NERtcVideoStreamType</td>
     *      <td>视频通道类型：<ul><li>kNERTCVideoStreamMain：主流。<li>kNERtcVideoStreamSub：辅流。</td>
     *  </tr>
     *  <tr>
     *      <td>width</td>
     *      <td>uint32_t</td>
     *      <td>视频采集的宽，单位为 px</td>
     *  </tr>
     *  <tr>
     *      <td>height</td>
     *      <td>uint32_t</td>
     *      <td>视频采集的高，单位为 px</td>
     *  </tr>
     * </table>
     * @endif
     */
    virtual void onRemoteVideoReceiveSizeChanged(uid_t uid, NERtcVideoStreamType type, uint32_t width, uint32_t height) {
        (void)uid;
        (void)type;
        (void)width;
        (void)height;
    }

    /**
     * @if Chinese
     * 本地视频预览的分辨率变化回调, 与是否进入房间的状态无关，与硬件状态有关，也适用于预览
     * @since V5.4.1
     * @par 触发时机
     * <br>当本地视频的分辨率发生变化，会触发此回调。当调用 SetCaptureConfig 设置采集分辨率或调用 SetVideoConfig 设置编码属性时可以触发该回调。回调的分辨率宽和高为本地预览的宽和高，和实际编码发送的分辨率不一定一致
     * @par 业务场景
     * 开发者可以根据该回调的分辨率来动态调整预览视图的比例等。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>type</td>
     *      <td>see #NERtcVideoStreamType</td>
     *      <td>视频通道类型：<ul><li>kNERTCVideoStreamMain：主流。<li>kNERtcVideoStreamSub：辅流。</td>
     *  </tr>
     *  <tr>
     *      <td>width</td>
     *      <td>uint32_t</td>
     *      <td>视频采集的宽，单位为 px</td>
     *  </tr>
     *  <tr>
     *      <td>height</td>
     *      <td>uint32_t</td>
     *      <td>视频采集的高，单位为 px</td>
     *  </tr>
     * </table>
     * @endif
     */
    virtual void onLocalVideoRenderSizeChanged(NERtcVideoStreamType type, uint32_t width, uint32_t height) {
        (void)type;
        (void)width;
        (void)height;
    }

    /** 
     * @if English
     * Occurs when the first audio frame from a remote user is decoded.
     * @param uid       The ID of a remote user whose audio streams are sent.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 已解码远端音频首帧的回调。
     * @param uid       远端用户 ID，指定是哪个用户的音频流。
     * @endif
     */
    virtual void onFirstAudioFrameDecoded(uid_t uid) {
        (void)uid;
    }

    /**
     * @if English
     * Occurs when the remote video is received and decoded.
     * <br>If the engine receives the first frame of remote video streams, the callback is triggered.
     * @param uid       The ID of a user whose audio streams are sent.
     * @param width     The width of video streams (px).
     * @param height    The height of video streams(px).
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 已接收到远端视频并完成解码的回调。
     * <br>引擎收到第一帧远端视频流并解码成功时，触发此调用。
     * @note 该回调仅在接收远端用户的主流视频首帧并完成解码时会触发，若您希望同时接收到接收辅流的相关通知，请监听 \ref IRtcChannelEventHandler::onFirstVideoFrameDecoded(NERtcVideoStreamType type, uid_t uid, uint32_t width, uint32_t height) "onFirstVideoFrameDecoded" 回调。
     * @param uid       用户 ID，指定是哪个用户的视频流。
     * @param width     视频流宽（px）。
     * @param height    视频流高（px）。
     * @endif
     */
    virtual void onFirstVideoFrameDecoded(uid_t uid, uint32_t width, uint32_t height) {
      (void)uid;
      (void)width;
      (void)height;
    }

    /**
     * @if Chinese
     * 已接收到远端视频首帧并完成解码的回调。
     * <br>当 SDK 收到远端视频并解码成功时，会触发该回调。应用层可在该回调中设置此用户的视频画布。
     * @since V4.6.20
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
     *      <td>视频通道类型：<ul><li>kNERTCVideoStreamMain：主流。<li>kNERtcVideoStreamSub：辅流。</td>
     *  </tr>
     *  <tr>
     *      <td>uid</td>
     *      <td>uid_t</td>
     *      <td>用户 ID，提示是哪个用户的视频流。</td>
     *  </tr>
     *  <tr>
     *      <td>width</td>
     *      <td>uint32_t</td>
     *      <td>首帧视频的宽度，单位为 px。</td>
     *  </tr>
     *  <tr>
     *      <td>height</td>
     *      <td>uint32_t</td>
     *      <td>首帧视频的高度，单位为 px。</td>
     *  </tr>
     * </table>
     * @endif
     */
    virtual void onFirstVideoFrameDecoded(NERtcVideoStreamType type, uid_t uid, uint32_t width, uint32_t height) {
        (void)uid;
        (void)width;
        (void)height;
        (void)type;
    }
  
    /**
     * @if Chinese
     * 已接收到远端视频首帧并完成渲染的回调。
     * <br>当 SDK 收到远端视频的第一帧并渲染成功时，会触发该回调。
     * @since V5.5.10
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>type</td>
     *      <td>see #NERtcVideoStreamType</td>
     *      <td>视频通道类型：<ul><li>kNERTCVideoStreamMain：主流。<li>kNERtcVideoStreamSub：辅流。</td>
     *  </tr>
     *  <tr>
     *      <td>uid</td>
     *      <td>uid_t</td>
     *      <td>用户 ID，提示是哪个用户的视频流。</td>
     *  </tr>
     *  <tr>
     *      <td>width</td>
     *      <td>uint32_t</td>
     *      <td>首帧视频的宽度，单位为 px。</td>
     *  </tr>
     *  <tr>
     *      <td>height</td>
     *      <td>uint32_t</td>
     *      <td>首帧视频的高度，单位为 px。</td>
     *  </tr>
     *  <tr>
     *      <td>elapsed</td>
     *      <td>uint64_t</td>
     *      <td>从订阅动作开始到发生此事件过去的时间（毫秒)。</td>
     *  </tr>
     * </table>
     * @endif
     */
    virtual void onFirstVideoFrameRender(NERtcVideoStreamType type, uid_t uid, uint32_t width, uint32_t height, uint64_t elapsed) {
        (void)type;
        (void)uid;
        (void)width;
        (void)height;
        (void)elapsed;
    }
  
    /** 
     * @if English
     * @deprecated The callback method is deprecated.
     * Occurs when the system prompts current local audio volume.
     * - This callback is disabled by default. You can enable the callback by calling the \ref IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication" method.
     * - After the callback is enabled, if a local user speaks, the SDK triggers the callback based on the time interval specified in the \ref IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication" method.
     * - If a local user sets a mute by calling \ref IRtcEngineEx::muteLocalAudioStream "muteLocalAudioStream", the SDK sets the value of volume as 0, and calls back to the application layer. 
     * @param volume        The volume of audio mixing. Value range: 0 to 100.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * @deprecated 该回调方法已废弃。
     * 提示房间内本地用户瞬时音量的回调。
     * - 该回调默认禁用。可以通过 \ref IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication" 方法开启。
     * - 开启后，本地用户说话，SDK 会按  \ref IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication" 方法中设置的时间间隔触发该回调。
     * - 如果本地用户将自己静音（调用了 \ref IRtcEngineEx::muteLocalAudioStream "muteLocalAudioStream"），SDK 将音量设置为 0 后回调给应用层。
     * @param volume        （混音后的）音量，取值范围为 [0,100]。
     * @endif
     */
    virtual void onLocalAudioVolumeIndication(int volume) { (void)volume; }
    
    /** 
     * @if English
     * Occurs when the system prompts current local audio volume.
     * - This callback is disabled by default. You can enable the callback by calling the \ref IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication" method.
     * - After the callback is enabled, if a local user speaks, the SDK triggers the callback based on the time interval specified in the \ref IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication" method.
     * - If a local user sets a mute by calling \ref IRtcEngineEx::muteLocalAudioStream "muteLocalAudioStream", the SDK sets the value of volume as 0, and calls back to the application layer. 
     * @since V4.6.10
     * @param volume     The volume of a mixing audio. Value range: 0 to 100.
     * @param enableVad  Indicates whether human voice is detected.
     * @since V4.6.10
     * @endif
     * @if Chinese
     * 提示房间内本地用户瞬时音量的回调。
     * - 该回调默认禁用。可以通过 \ref IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication" 方法开启。开启后，本地用户说话，SDK 会按  \ref IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication" 方法中设置的时间间隔触发该回调。
     * - 如果本地用户将自己静音（调用了 \ref IRtcEngineEx::muteLocalAudioStream "muteLocalAudioStream"），SDK 将音量设置为 0 后回调给应用层。
     * @since V4.6.10
     * @param volume     混音后的音量，取值范围为 0 ~ 100。
     * @param enable_vad  是否检测到人声。
     * @endif
     */
    virtual void onLocalAudioVolumeIndication(int volume, bool enable_vad) {
        (void)volume;
        (void)enable_vad;
    }

    /** 
     * @if English
     * Occurs when the system prompts the active speaker and the audio volume.
     * <br>By default, the callback is disabled. You can enable the callback by calling the enableAudioVolumeIndication method. After the callback is enabled, if a local user speaks, the SDK triggers the callback based on the time interval specified in the enableAudioVolumeIndication method.
     * <br>In the array of speakers returned:
     * - If a uid is contained in the array returned in the last response but not in the array returned in the current response. The remote user with the uid does not speak by default.
     * - If the volume is 0, the user does not speak. 
     * - If the array is empty, the remote user does not speak.
     * @param speakers              The array that contains the information about user IDs and volumes is NERtcAudioVolumeInfo.
     * @param speaker_number        The size of speakers array, which indicates the number of speakers. 
     * @param total_volume          The total volume (after audio mixing). Value range: 0 to 100. 
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 提示房间内谁正在说话及说话者瞬时音量的回调。
     * <br>该回调默认为关闭状态。可以通过 enableAudioVolumeIndication 方法开启。开启后，无论房间内是否有人说话，SDK 都会按 enableAudioVolumeIndication 方法中设置的时间间隔触发该回调。
     * <br>在返回的 speakers 数组中:
     * - 如果有 uid 出现在上次返回的数组中，但不在本次返回的数组中，则默认该 uid 对应的远端用户没有说话。
     * - 如果volume 为 0，表示该用户没有说话。
     *  - 如果speakers 数组为空，则表示此时远端没有人说话。
     * @param speakers              每个说话者的用户 ID 和音量信息的数组: NERtcAudioVolumeInfo
     * @param speaker_number        speakers 数组的大小，即说话者的人数。
     * @param total_volume          （混音后的）总音量，取值范围为 [0,100]。
     * @endif
     */
    virtual void onRemoteAudioVolumeIndication(const NERtcAudioVolumeInfo* speakers, unsigned int speaker_number,
                                               int total_volume) {
        (void)speakers;
        (void)speaker_number;
        (void)total_volume;
    }

    /** 
     * @if English
     * Notifies to add the result of live stream. 
     * <br>The callback asynchronously returns the callback result of \ref IRtcEngineEx::addLiveStreamTask "addLiveStreamTask".  For information about actual pushing state, see \ref IRtcEngineEventHandlerEx::onLiveStreamState "onLiveStreamState".
     * @param task_id           The ID of a stream-push task. 
     * @param url               Task ID. 
     * @param error_code        The result. 
     * - 0: Success.
     * - Other values: Failure.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 通知添加直播任务结果。
     * <br>该回调异步返回 \ref IRtcEngineEx::addLiveStreamTask "addLiveStreamTask" 接口的调用结果；实际推流状态参考 \ref IRtcEngineEventHandlerEx::onLiveStreamState "onLiveStreamState"
     * @param task_id           任务id
     * @param url               推流地址
     * @param error_code        结果
     * - 0: 调用成功；
     * - 其他: 调用失败。
     * @endif
     */
    virtual void onAddLiveStreamTask(const char* task_id, const char* url, int error_code) {
        (void)task_id;
        (void)url;
        (void)error_code;
    }

    /** 
     * @if English
     * Notifies to Updates the result of live stream.
     * <br>The callback asynchronously returns the callback result of ref IRtcEngineEx::addLiveStreamTask "addLiveStreamTask". For information about actual pushing state, see \ref IRtcEngineEventHandlerEx::onLiveStreamState "onLiveStreamState".
     * @param task_id       The ID of a stream-push task.
     * @param url           The URL for the streaming task.
     * @param error_code    The result.
     * - 0: Success.
     * - Other values: Failure.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 通知更新直播任务结果。
     * 该回调异步返回 \ref IRtcEngineEx::updateLiveStreamTask "updateLiveStreamTask" 接口的调用结果；实际推流状态参考 \ref IRtcEngineEventHandlerEx::onLiveStreamState "onLiveStreamState"
     * @param task_id       任务id
     * @param url           推流地址
     * @param error_code    结果
     * - 0: 调用成功；
     * - 其他: 调用失败。
     * @endif
     */
    virtual void onUpdateLiveStreamTask(const char* task_id, const char* url, int error_code) {
        (void)task_id;
        (void)url;
        (void)error_code;
    }

    /** 
     * @if English
     * Notifies to delete the result of live stream.
     * <br>The callback asynchronously returns the callback result of ref IRtcEngineEx::addLiveStreamTask "addLiveStreamTask". For information about actual pushing state, see \ref IRtcEngineEventHandlerEx::onLiveStreamState "onLiveStreamState".
     * @param task_id       The ID of a task.
     * @param error_code    The result.
     * - 0: Success.
     * - Other values: Failure.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 通知删除直播任务结果。
     * <br>该回调异步返回 \ref IRtcEngineEx::removeLiveStreamTask "removeLiveStreamTask" 接口的调用结果；实际推流状态参考 \ref IRtcEngineEventHandlerEx::onLiveStreamState "onLiveStreamState"
     *  @param task_id      任务id
     * @param error_code    结果
     * - 0: 调用成功；
     * - 其他: 调用失败。
     * @endif
     */
    virtual void onRemoveLiveStreamTask(const char* task_id, int error_code) {
        (void)task_id;
        (void)error_code;
    }

    /** 
     * @if English
     * Notifies the status in live stream-pushing.
     * @note The callback is valid in a call.
     * @param task_id       The ID of a task.
     * @param url           The URL for the streaming task.
     * @param state         #NERtcLiveStreamStateCode The state of live stream-pushing.
     * - 505: Pushing.
     * - 506: Pushing fails.
     * - 511: Pushing ends.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 通知直播推流状态
     * @note                该回调在通话中有效。
     * @param task_id       任务id
     * @param url           推流地址
     * @param state         #NERtcLiveStreamStateCode, 直播推流状态
     * - 505: 推流中；
     * - 506: 推流失败；
     * - 511: 推流结束；
     * @endif
     */
    virtual void onLiveStreamState(const char* task_id, const char* url, NERtcLiveStreamStateCode state) {
        (void)task_id;
        (void)url;
        (void)state;
    }

    /** 
     * @if English
     * Occurs when the content of remote SEI is received.
     * <br>After a remote client successfully sends SEI, the local client receives a message returned by the callback.
     * @param[in] uid       The ID of the user who sends the SEI. 
	 * @param[in] data      The received SEI data.
	 * @param[in] dataSize  The size of received SEI data.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 收到远端流的 SEI 内容回调。
     * <br>当远端成功发送 SEI 后，本端会收到此回调。
     * @param[in] uid       发送该 sei 的用户 id
	 * @param[in] data      接收到的 sei 数据
	 * @param[in] dataSize  接收到 sei 数据的大小
	 * @endif
	 */
	virtual void onRecvSEIMsg(uid_t uid, const char* data, uint32_t dataSize) {
		(void)uid;
		(void)data;
		(void)dataSize;
	}

    /** 
     * @if English
     * Occurs when the state of the media stream is relayed. 
     * @since V4.5.0
     * @param state         The state of the media stream.
     * @param channel_name  The name of the destination room where the media streams are relayed. 
     * @endif
     * @if Chinese
     * 跨房间媒体流转发状态发生改变回调。
     * @since V4.5.0
     * @param state         当前跨房间媒体流转发状态。详细信息请参考 #NERtcChannelMediaRelayState
     * @param channel_name  媒体流转发的目标房间名。
     * @endif
     */
    virtual void onMediaRelayStateChanged(NERtcChannelMediaRelayState state, const char* channel_name) {
        (void)state;
        (void)channel_name;
    }

    /** 
     * @if English
     * Occurs when events related to media stream relay are triggered.
     * @since V4.5.0
     * @param event         The media stream relay event.
     * @param channel_name  The name of the destination room where the media streams are relayed.
     * @param error         Specific error codes.
     * @endif
     * @if Chinese
     * 媒体流相关转发事件回调。
     * @since V4.5.0
     * @param event         当前媒体流转发事件。详细信息请参考 #NERtcChannelMediaRelayEvent 。
     * @param channel_name  转发的目标房间名。
     * @param error         相关错误码。详细信息请参考 #NERtcErrorCode 。
     * @endif
     */
    virtual void onMediaRelayEvent(NERtcChannelMediaRelayEvent event, const char* channel_name, NERtcErrorCode error) {
        (void)event;
        (void)channel_name;
        (void)error;
    }

    /**
     * @if English
     * Occurs when the published local media stream falls back to an audio-only stream due to poor network conditions or switches back to audio and video stream after the network conditions improve.
     * <br>If you call setLocalPublishFallbackOption and set option to #kNERtcStreamFallbackAudioOnly, this callback is triggered when the locally published stream falls back to audio-only mode due to poor uplink network conditions, or when the audio stream switches back to the audio and video stream after the uplink network conditions improve. 
     * @since V4.5.0
     * @param is_fallback   The locally published stream falls back to audio-only mode or switches back to audio and video stream.
     * - true: The published stream from a local client falls back to audio-only mode due to poor uplink network conditions.
     * - false: The audio stream switches back to the audio and video stream after the upstream network condition improves.
     * @param stream_type   The type of the video stream, such as mainstream and substream. 
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 本地发布流已回退为音频流、或已恢复为音视频流回调。
     * <br>如果您调用了设置本地推流回退选项 setLocalPublishFallbackOption 接口，并将 option 设置为 #kNERtcStreamFallbackAudioOnly 后，当上行网络环境不理想、本地发布的媒体流回退为音频流时，或当上行网络改善、媒体流恢复为音视频流时，会触发该回调。 
     * @since V4.5.0
     * @param is_fallback   本地发布流已回退或已恢复。
     * - true： 由于网络环境不理想，发布的媒体流已回退为音频流。
     * - false：由于网络环境改善，从音频流恢复为音视频流。
     * @param stream_type   对应的视频流类型，即主流或辅流。
     * @endif
     */
    virtual void onLocalPublishFallbackToAudioOnly(bool is_fallback, NERtcVideoStreamType stream_type) {
        (void)is_fallback;
    }

    /**
     * @if English
     * Occurs when the subscribed remote media stream falls back to an audio-only stream due to poor network conditions or switches back to the audio and video stream after the network condition improves.
     * <br>If you call setLocalPublishFallbackOption and set option to #kNERtcStreamFallbackAudioOnly, this callback is triggered when the locally published stream falls back to audio-only mode due to poor uplink network conditions, or when the audio stream switches back to the audio and video stream after the uplink network condition improves.
     * @since V4.5.0
     * @param uid           The ID of a remote user.
     * @param is_fallback   The subscribed remote media stream falls back to audio-only mode or switches back to the audio and video stream. 
     * - true: The subscribed remote media stream falls back to audio-only mode due to poor downstream network conditions.
     * - false: The subscribed remote media stream switches back to the audio and video stream after the downstream network condition improves.
     * @param stream_type   The type of the video stream, such as mainstream and substream. 
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 订阅的远端流已回退为音频流、或已恢复为音视频流回调。
     * <br>如果你调用了设置远端订阅流回退选项 setRemoteSubscribeFallbackOption 接口并将 option 设置 #kNERtcStreamFallbackAudioOnly 后，当下行网络环境不理想、仅接收远端音频流时，或当下行网络改善、恢复订阅音视频流时，会触发该回调。
     * @since V4.5.0
     * @param uid          远端用户的 ID。
     * @param is_fallback  远端订阅流已回退或恢复：
     * - true： 由于网络环境不理想，订阅的远端流已回退为音频流。
     * - false：由于网络环境改善，订阅的远端流从音频流恢复为音视频流。
     * @param stream_type  对应的视频流类型，即主流或辅流。
     * @endif
     */
    virtual void onRemoteSubscribeFallbackToAudioOnly(uid_t uid, bool is_fallback, NERtcVideoStreamType stream_type) {
        (void)uid;
        (void)is_fallback;
    }

    /**
     * @if English
     * Audio/Video Callback when banned by server.
     * @since v4.6.0
     * @param isAudioBannedByServer indicates whether to ban the audio.
     * - true: banned
     * - false unbanned
     * @param isVideoBannedByServer indicates whether to ban the video.
     * - true: banned
     * - false unbanned
     * @endif
     * @if Chinese
     * 服务端禁言音视频权限变化回调。
     * @since v4.6.0
     * @param is_audio_banned 是否禁用音频。
     * - true：禁用音频。
     * - false：取消禁用音频。
     * @param is_video_banned 是否禁用视频。
     * - true：禁用视频。
     * - false：取消禁用视频。
     * @endif
     */
    virtual void onMediaRightChange(bool is_audio_banned, bool is_video_banned) {
        (void)is_audio_banned;
        (void)is_video_banned;
    }

	/**
     * @if Chinese
     * 权限密钥即将过期事件回调。
     * - 由于 PermissionKey 具有一定的时效，在通话过程中如果 PermissionKey 即将失效，SDK 会提前 30 秒触发该回调，提醒用户更新 PermissionKey。
     * @since V4.6.29
     * @par 使用前提
     * 请在 IRtcChannelEventHandler 接口类中通过 \ref IRtcChannel::setChannelEventHandler "setChannelEventHandler" 接口设置回调监听。
     * @par 相关接口
     * 在收到此回调后可以调用 \ref nertc::IRtcEngineEx::updatePermissionKey "updatePermissionKey" 方法更新权限密钥。
     * @endif
     */
    virtual void onPermissionKeyWillExpire() {}

    /**
     * @if Chinese
     * 更新权限密钥事件回调。
     * - 调用 \ref IRtcChannel::updatePermissionKey "updatePermissionKey"  方法主动更新权限密钥后，SDK 会触发该回调，返回权限密钥更新的结果。
     * @since V4.6.29
     * @par 使用前提
     * 请在 IRtcChannelEventHandler 接口类中通过 \ref IRtcChannel::setChannelEventHandler "setChannelEventHandler" 接口设置回调监听。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>key</td>
     *      <td>const char*</td>
     *      <td>新的权限密钥。</td>
     *  </tr>
     *  <tr>
     *      <td>error</td>
     *      <td> \ref nertc::NERtcErrorCode "NERtcErrorCode" </td>
     *      <td>错误码。<ul><li>kNERtcErrChannelPermissionKeyError（30901）：权限密钥错误。<li>kNERtcErrChannelPermissionKeyTimeout（30902）：权限密钥超时。</td>
     *  </tr>
     *  <tr>
     *      <td>timeout</td>
     *      <td>int</td>
     *      <td>更新后的权限密钥剩余有效时间。单位为秒。</td>
     *  </tr>
     * </table> 
     * @endif
     */
    virtual void onUpdatePermissionKey(const char* key, NERtcErrorCode error, int timeout) {
        (void)key;
        (void)error;
        (void)timeout;
    }
    
    /**
     * @if Chinese
     * 实验功能回调接口，用于回调一些非正式的事件及数据通知。
     * @since V5.5.0
     * @param key             返回回调类型。
     * @param param           值内容。对应字符串的参数值，如果是结构体对象，需要转成json格式。
     * @endif
     */
    virtual void onLabFeatureCallback(const char* key, const char* param) {
        (void)key;
        (void)param;
    }
};
} // namespace nertc

#endif
