/** @file nertc_channel.h
* @brief NERTC SDK IRtcChannel接口头文件。
* NERTC SDK所有接口参数说明: 所有与字符串相关的参数(char *)全部为UTF-8编码。
* @copyright (c) 2015-2021, NetEase Inc. All rights reserved
* @date 2021/05/10
*/

#ifndef NERTC_CHANNEL_H
#define NERTC_CHANNEL_H

#include "nertc_base.h"
#include "nertc_base_types.h"
#include "nertc_engine_defines.h"
#include "nertc_channel_event_handler.h"
#include "nertc_engine_media_stats_observer.h"

 /**
 * @namespace nertc
 * @brief namespace nertc
 */
namespace nertc
{

/** 
 * @if English
 * The IRtcChannel class provides methods that enable real-time communications in a specified channel. By creating multiple IRtcChannel instances, users can join multiple channels.
 * @endif
 * @if Chinese
 * IRtcChannel 类在指定房间中实现实时音视频功能。通过创建多个 IRtcChannel 对象，用户可以同时加入多个房间。
 * @endif
 */
class IRtcChannel
{
public:
    virtual ~IRtcChannel() {}

    /** 
     * @if English
     * Destroys an IRtcChannel instance to release resources.
     * @since V4.5.0
     * @endif
     * @if Chinese
     * 销毁 IRtcChannel 实例，释放资源。
     * @since V4.5.0
     * @endif
     */
    virtual void release() = 0;
	
    /** 
     * @if English
     * Gets the current channel name.
     * @since V4.5.0
     * @return 
     * - Success: Return IRtcChannel channel name.
     * - Fail: Return nothing.
     * @endif
     * @if Chinese
     * 获取当前房间名。
     * @since V4.5.0
     * @return 
     *- 成功：当前IRtcChannel房间名。
     *- 失败：返回空。
     * @endif
     */
    virtual const char* getChannelName() = 0;
	
    /** 
     * @if English 
     * Sets the event handler of the IRtcChannel.  
     * <br>You can set the event handler to monitor the channel event of IRtcChannel, and receive user video information in the channel.  
     * @since V4.5.0
     * @param[in] handler Event handler.
     * @return 
     * - Success: Return IRtcChannel channel name.
     * - Fail: Return nothing.
     * @endif
     * @if Chinese
     * 设置 IRtcChannel 对象的事件句柄。
     * <br>你可以通过设置的事件句柄，监听当前IRtcChannel对象对应房间的事件，并接收房间中用户视频信息等。
     * @since V4.5.0
     * @param[in] handler 事件监听句柄对象
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
     * 
     * @endif
     */
    virtual int setChannelEventHandler(IRtcChannelEventHandler* handler) = 0;

    /**
     * @if English
     *  Joins a channel of audio and video call.
     * @note
     * - The user ID for each user in the channel must be unique, and the uid in the current IRtcChannel will reuse the UID in the IRtcEngine channel.
     * - The channel name is the channel_id of IRtcChannel specified when created.
     * @since V4.5.0
     * @param[in] token The certification signature used in authentication (NERTC Token). Valid values:
                        - Null. You can set the value to null in the debugging mode. This poses a security risk. We recommend that you contact your business manager to change to the default safe mode before your product is officially launched.
                        - NERTC Token acquired. In safe mode, the acquired token must be specified. If the specified token is invalid, users are unable to join a room. We recommend that you use the safe mode.
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
     * - 传参中 uid 可选，若不指定则默认为 0，SDK 会自动分配一个随机 uid，并在 \ref nertc::IRtcChannelEventHandler::onJoinChannel "onJoinChannel" 回调方法中返回；App 层必须记住该返回值并维护，SDK 不对该返回值进行维护。
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
     * </table>
     * @par 示例代码
     * @code
     * IRtcChannel *rtc_channel_ = rtc_engine_->createChannel(secondChannel);
     * rtc_channel_->joinChannel(token);
     * @endcode
     * @par 相关接口
     * - 您可以调用 \ref nertc::IRtcChannel::leaveChannel "leaveChannel" 方法离开房间。
     * - 直播场景中，观众角色可以通过 \ref nertc::IRtcEngine::switchChannel "switchChannel" 接口切换房间。
     * @par 相关回调
     * - 成功调用该方法加入房间后，本地会触发 \ref nertc::IRtcChannelEventHandler::onJoinChannel "onJoinChannel" 回调，远端会触发 \ref nertc::IRtcChannelEventHandler::onUserJoined "onUserJoined" 回调。
     * - 在弱网环境下，若客户端和服务器失去连接，SDK 会自动重连，并在自动重连成功后触发 \ref nertc::IRtcChannelEventHandler::onRejoinChannel "onRejoinChannel" 回调。
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30001（kNERtcErrFatal）：重复入会或获取房间信息失败。
     *      - 30005（kNERtcErrInvalidState)：状态错误，比如引擎尚未初始化或正在进行网络探测。
     * @endif
     */
    virtual int joinChannel(const char* token) = 0;

    /** 
     * @if English
     *  Joins a channel of audio and video call.
     * @note 
     * - The user ID for each user in the channel must be unique, and the uid in the current IRtcChannel will reuse the UID in the IRtcEngine channel.
     * - The channel name is the channel_id of IRtcChannel specified when created.
     * @since V5.3.0
     * @param[in] token The certification signature used in authentication (NERTC Token). Valid values:
                        - Null. You can set the value to null in the debugging mode. This poses a security risk. We recommend that you contact your business manager to change to the default safe mode before your product is officially launched.
                        - NERTC Token acquired. In safe mode, the acquired token must be specified. If the specified token is invalid, users are unable to join a room. We recommend that you use the safe mode.
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
     * - 传参中 uid 可选，若不指定则默认为 0，SDK 会自动分配一个随机 uid，并在 \ref nertc::IRtcChannelEventHandler::onJoinChannel "onJoinChannel" 回调方法中返回；App 层必须记住该返回值并维护，SDK 不对该返回值进行维护。
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
     *      <td>uid</td>
     *      <td>uid_t</td>
     *      <td>user id</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * IRtcChannel *rtc_channel_ = rtc_engine_->createChannel(secondChannel);
     * rtc_channel_->joinChannel(token, uid);
     * @endcode
     * @par 相关接口
     * - 您可以调用 \ref nertc::IRtcChannel::leaveChannel "leaveChannel" 方法离开房间。
     * - 直播场景中，观众角色可以通过 \ref nertc::IRtcEngine::switchChannel "switchChannel" 接口切换房间。
     * @par 相关回调
     * - 成功调用该方法加入房间后，本地会触发 \ref nertc::IRtcChannelEventHandler::onJoinChannel "onJoinChannel" 回调，远端会触发 \ref nertc::IRtcChannelEventHandler::onUserJoined "onUserJoined" 回调。
     * - 在弱网环境下，若客户端和服务器失去连接，SDK 会自动重连，并在自动重连成功后触发 \ref nertc::IRtcChannelEventHandler::onRejoinChannel "onRejoinChannel" 回调。
     * @return 
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30001（kNERtcErrFatal）：重复入会或获取房间信息失败。
     *      - 30005（kNERtcErrInvalidState)：状态错误，比如引擎尚未初始化或正在进行网络探测。
     * @endif
     */
    virtual int joinChannel(const char* token, uid_t uid) = 0;

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
     * - 传参中 uid 可选，若不指定则默认为 0，SDK 会自动分配一个随机 uid，并在 \ref nertc::IRtcChannelEventHandler::onJoinChannel "onJoinChannel" 回调方法中返回；App 层必须记住该返回值并维护，SDK 不对该返回值进行维护。
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
     *      <td>channel_options</td>
     *      <td> \ref nertc::NERtcJoinChannelOptions "NERtcJoinChannelOptions"</td>
     *      <td>加入房间时设置一些特定的房间参数。默认值为 nil。</td>
     *  </tr>
     *  <tr>
     *      <td>uid</td>
     *      <td>uid_t</td>
     *      <td>user id</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * IRtcChannel *rtc_channel_ = rtc_engine_->createChannel(secondChannel);
     * NERtcJoinChannelOptions channel_options;
     * strcpy(channel_options.custom_info, "custom info");
     * channel_options.permission_key = "permission key";
     * rtc_channel_->joinChannel(token, uid, channel_options);
     * @endcode
     * @par 相关接口
     * - 您可以调用 \ref nertc::IRtcChannel::leaveChannel "leaveChannel" 方法离开房间。
     * - 直播场景中，观众角色可以通过 \ref nertc::IRtcEngine::switchChannel "switchChannel" 接口切换房间。
     * @par 相关回调
     * - 成功调用该方法加入房间后，本地会触发 \ref nertc::IRtcChannelEventHandler::onJoinChannel "onJoinChannel" 回调，远端会触发 \ref nertc::IRtcChannelEventHandler::onUserJoined "onUserJoined" 回调。
     * - 在弱网环境下，若客户端和服务器失去连接，SDK 会自动重连，并在自动重连成功后触发 \ref nertc::IRtcChannelEventHandler::onRejoinChannel "onRejoinChannel" 回调。
     * @return 
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30001（kNERtcErrFatal）：重复入会或获取房间信息失败。
     *      - 30005（kNERtcErrInvalidState)：状态错误，比如引擎尚未初始化或正在进行网络探测。
     * @endif
     */
    virtual int joinChannel(const char* token, uid_t uid, NERtcJoinChannelOptions channel_options) = 0;

    /** 
     * @if English
     * Leaves the room.
     * <br>Leaves a room for hang up or calls ended.
     * <br>A user can call the leaveChannel method to end the call before the user makes another call.
     * <br>After the method is called successfully, the onLeaveChannel callback is locally triggered, and the onUserLeave callback is remotely triggered.
     * @note
     * - The method is asynchronous call. Users cannot exit the room when the method is called and returned. After users exit the room, the SDK triggers the onLeaveChannel callback.
     * - If you call leaveChannel method and instantly call release method, the SDK cannot trigger onLeaveChannel callback.
     * @since V4.5.0
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
     * - 该方法是异步操作，调用返回时并没有真正退出频道。在真正退出房间后，SDK 会触发 \ref IRtcChannelEventHandler::onLeaveChannel "onLeaveChannel" 回调。
     * - 如果在调用 leaveChannel 后立即调用 \ref nertc::IRtcChannel::release "release" 方法，可能会无法正常离开房间；建议您在收到 \ref IRtcChannelEventHandler::onLeaveChannel "onLeaveChannel" 回调之后再调用 \ref nertc::IRtcChannel::release() "release" 方法释放会话相关所有资源。
     * @par 示例代码
     * @code
     * rtc_channel_->leaveChannel();
     * @endcode
     * @par 相关回调
     * 成功调用该方法离开房间后，本地会触发 \ref IRtcChannelEventHandler::onLeaveChannel "onLeaveChannel" 回调，远端会触发 \ref IRtcChannelEventHandler::onUserLeft "onUserLeft" 回调。
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
     * Registers a stats observer.
     * @since V4.5.0
     * @param[in] observer      The stats observer.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 注册统计信息观测器。
     * @since V4.5.0
     * @param[in] observer      统计信息观测器
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
    * @endif
    */
    virtual int setStatsObserver(IRtcMediaStatsObserver* observer) = 0;

    /** 
     * @if English
     * Enables or disables local audio capture.
     * <br>The method can enable the local audio again to start local audio capture and processing. 
     * <br>The method does not affect receiving or playing remote audio and audio streams.
     * @note The method is different from \ref IRtcChannel::muteLocalAudioStream "muteLocalAudioStream" in:. 
     * - \ref IRtcChannel::enableLocalAudio "enableLocalAudio": Enables local audio capture and processing. 
     * - \ref IRtcChannel::muteLocalAudioStream "muteLocalAudioStream": Stops or continues publishing local audio streams. 
     * @note The method enables the internal engine, which is still valid after you call \ref IRtcEngine::leaveChannel "leaveChannel".
     * @since V4.5.0
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
     * rtc_channel_->enableLocalAudio(true);
     * //关闭音频采集
     * rtc_channel_->enableLocalAudio(false);
     * @endcode
     * @par 相关回调
     * - 开启音频采集后，远端会触发 \ref nertc::IRtcChannelEventHandler::onUserAudioStart "onUserAudioStart" 回调。
     * - 关闭音频采集后，远端会触发 \ref nertc::IRtcChannelEventHandler::onUserAudioStop "onUserAudioStop" 回调。
     * @par 相关接口
     * \ref IRtcChannel::muteLocalAudioStream "muteLocalAudioStream"：两者的差异在于，enableLocalAudio 用于开启本地语音采集及处理，而 muteLocalAudioStream 用于停止或继续发送本地音频流。
     * @return 
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30005（kNERtcErrInvalidState）：引擎尚未初始化，或者多房间场景下未在本房间操作。
     * @endif
     */
    virtual int enableLocalAudio(bool enabled) = 0;

    /** 
     * @if English
     * Enables or disables the audio substream.
     * <br>If the audio substream is eanbled, remote clients will get notified by \ref IRtcChannelEventHandler::onUserSubStreamAudioStart "onUserSubStreamAudioStart", and \ref IRtcChannelEventHandler::onUserSubStreamAudioStop "onUserSubStreamAudioStop" when the audio stream is disabled.
     * @note The internal engine is enabled by this method and the setting remains effective even the \ref IRtcChannel::leaveChannel "leaveChannel" is called.
     * @since V4.6.10
     * @param[in] enabled specifies whether to enable the audio substream.
     * - true: enables the audio substream.
     * - false: disable the audio substream.
     * @return
     * - 0: success
     * - Others: failure
     * @endif
     * @if Chinese
     * 开启或关闭音频辅流。
     * <br>开启时远端会收到 \ref IRtcChannelEventHandler::onUserSubStreamAudioStart "onUserSubStreamAudioStart"，关闭时远端会收到 \ref IRtcChannelEventHandler::onUserSubStreamAudioStop "onUserSubStreamAudioStop"。
     * @note 该方法设置内部引擎为启用状态，在 \ref IRtcChannel::leaveChannel "leaveChannel" 后仍然有效。
     * @since V4.6.10
     * @param[in] enabled 是否开启音频辅流。
     * - true: 开启音频辅流。
     * - false: 关闭音频辅流。
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
     * @endif
     */
    virtual int enableLocalSubStreamAudio(bool enabled) = 0;

    /** 
     * @if English
     * Enables or disabling publishing the local audio stream. The method is used to enable or disable publishing the local audio stream. 
     * @note
     * - This method does not change the state of the audio-recording device because the audio-recording devices are not disabled.
     * - The mute state is reset to unmuted after the call ends.
     * @since V4.5.0
     * @param[in] mute       Mute or Unmute.
     * - true: Mutes the local audio stream.
     * - false: Unmutes the local audio stream (Default).
     * @return
     * - 0: success
     * - Others: failure
     * @endif
     * @if Chinese 
     * 开启或关闭本地音频主流的发送。
     * <br>该方法用于向网络发送或取消发送本地音频数据，不影响本地音频的采集状态，也不影响接收或播放远端音频流。
     * @since V3.5.0
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
     * @note
     * 该方法设置内部引擎为启用状态，在 \ref nertc::IRtcChannel::leaveChannel() "leaveChannel" 后恢复至默认（非静音）。
     * @par 参数说明 
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>mute</td>
     *      <td>bool</td>
     *      <td>是否关闭本地音频的发送：<ul><li>true：不发送本地音频。<li>false：发送本地音频。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * //不发送本地音频
     * rtc_channel_->muteLocalAudioStream(false);
     * //发送本地音频
     * rtc_channel_->muteLocalAudioStream(true);
     * @endcode 
     * @par 相关回调
     * 若本地用户在说话，成功调用该方法后，房间内其他用户会收到 \ref IRtcChannelEventHandler::onUserAudioMute "onUserAudioMute" 回调。
     * @par 相关接口
     * \ref nertc::IRtcChannel::enableMediaPub "enableMediaPub"：
     *      - 在需要开启本地音频采集（监测本地用户音量）但不发送音频流的情况下，您也可以调用 enableMeidaPub(false) 方法。
     *      - 两者的差异在于，muteLocalAudioStream(true) 仍然保持与服务器的音频通道连接，而 enableMediaPub(false) 表示断开此通道，因此若您的实际业务场景为多人并发的大房间，建议您调用 enableMediaPub 方法。  
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *         - 30005（kNERtcErrInvalidState）：引擎未初始化。
     *         - 30107（kNERtcErrMediaNotStarted）：媒体会话未建立，比如对端未开启音频流。
     *         - 30200（kNERtcErrConnectionNotFound）: 连接未建立。
     *         - 30203（kNERtcErrTrackNotFound）：音频 track 未找到。
     *         - 30300：Transceiver 未找到。
     *         - 30400：未找到对应房间。
     * @endif
     */
    virtual int muteLocalAudioStream(bool mute) = 0;

    /**
     * @if English
     * Mutes or unmutes the local upstream audio stream.
     * @note The muted state will be reset to unmuted after a call ends.
     * @since V4.6.10
     * @param mute specifies whether to mute a local audio stream.
     *              - true (default): mutes a local audio stream.
     *              - false: unmutes a local audio stream.
     * @return
     * - 0: success
     * - Others: failure
     * @endif
     * @if Chinese
     * 静音或解除静音本地上行的音频辅流。
     * @note 
     * - 该方法仅可在加入房间后调用。
     * - 静音状态会在通话结束后被重置为非静音。
     * @since V4.6.10
     * @param mute 是否静音本地音频辅流发送。
     *              - true（默认）：静音本地音频辅流。
     *              - false: 取消静音本地音频辅流。
     * @return
     * - 0：方法调用成功。
     * - 其他：方法调用失败。
     * @endif
     */
    virtual int muteLocalSubStreamAudio(bool mute) = 0;

    /** 
     * @if English
     * Enables or disables local audio capture and rendering.
     * <br>The method enables local video capture.
     * @note
     * - You can call this method before or after you join a room.
     * - The method enables the internal engine, which is still valid after you call \ref IRtcEngine::leaveChannel "leaveChannel".
     * - After local video capture is successfully enabled or disabled,  the onUserVideoStop or onUserVideoStart callback is remotely triggered.
     * @since V4.5.0
     * @param[in] enabled Whether to enable local video capture and rendering.
     * - true: Enables the local video capture and rendering.
     * - false: Disables the local camera device. After local video capture is disabled, remote users cannot receive video streams from local users. However, local users can still receive video streams from remote users. If the setting is false, the local camera is not required to call the method.
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
     * - 该方法设置内部引擎为开启或关闭状态, 在 \ref IRtcChannel::leaveChannel "leaveChannel" 后仍然有效。
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
     * rtc_channel_->enableLocalVideo(true);
     * //关闭视频
     * rtc_channel_->enableLocalVideo(false);
     * @endcode
     * @par 相关回调
     * - 开启本地视频采集后，远端会收到 \ref IRtcChannelEventHandler::onUserVideoStart "onUserVideoStart" 回调。
     * - 关闭本地视频采集后，远端会收到 \ref IRtcChannelEventHandler::onUserVideoStop "onUserVideoStop" 回调。
     * @par 相关接口
     * 若您希望开启辅流通道的视频采集，请调用 \ref IRtcChannel::enableLocalVideo(NERtcVideoStreamType type, bool enabled) "enableLocalVideo" 方法。
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
     * - 该方法仅适用于视频主流，若您希望开启辅流通道的视频采集，请调用 \ref IRtcChannel::enableLocalVideo(NERtcVideoStreamType type, bool enabled) "enableLocalVideo" 方法。
     * - 该方法设置内部引擎为开启或关闭状态, 在 \ref nertc::IRtcEngine::leaveChannel() "leaveChannel" 后仍然有效。
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
     * rtc_channel_->enableLocalVideo(type, enable);
     * //关闭视频主流
     * nertc::NERtcVideoStreamType type = nertc::NERtcVideoStreamType::kNERTCVideoStreamMain;
     * bool enable = false;
     * rtc_channel_->enableLocalVideo(type, enable);
     * //打开视频辅流
     * nertc::NERtcVideoStreamType type = nertc::NERtcVideoStreamType::kNERTCVideoStreamSub;
     * bool enable = true;
     * rtc_channel_->enableLocalVideo(type, enable);
     * //关闭视频辅流
     * nertc::NERtcVideoStreamType type = nertc::NERtcVideoStreamType::kNERTCVideoStreamSub;
     * bool enable = false;
     * rtc_channel_->enableLocalVideo(type, enable);
     * @endcode
     * @par 相关回调
     * - type 为 kNERTCVideoStreamMain（主流）时：
     *         - 开启本地视频采集后，远端会收到 \ref IRtcEngineEventHandler::onUserVideoStart "onUserVideoStart" 回调。
     *         - 关闭本地视频采集后，远端会收到 \ref IRtcEngineEventHandler::onUserVideoStop "onUserVideoStop" 回调。
     * - streamType 为 kNERtcVideoStreamTypeSub（辅流）时：
     *         - 开启本地视频采集后，远端会收到 \ref IRtcEngineEventHandlerEx::onUserSubStreamVideoStart "onUserSubStreamVideoStart" 回调。
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
     * Stops or resumes sending the local video stream.
     * <br>If the method is called Successfully, onUserVideoMute is triggered remotely. 
     * @note
     * - When you call the method to disable video streams,  the SDK doesn’t send local video streams but the camera is still working. 
     * - The method can be called before or after a user joins a room.
     * - If you stop publishing the local video stream by calling this method, the option is reset to the default state that allows the app to publish the local video stream. 
     * - \ref nertc::IRtcEngine::enableLocalVideo "enableLocalVideo" (false) is different from \ref nertc::IRtcEngine::enableLocalVideo "enableLocalVideo" (false). The enableLocalVideo(false) method turns off local camera devices. The muteLocalVideoStreamvideo method does not affect local video capture, or disable cameras, and responds faster.
     * @since V4.5.0
     * @param[in] mute
     * - true: Not publishing local video streams.
     * - false: Publishing local video streams (default).
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 取消或恢复发布本端视频主流。
     * <br>调用该方法取消发布本地视频主流后，SDK 不再发送本地视频主流。
     * @since V3.5.0
     * @par 使用前提 
     * 一般在通过 \ref nertc::IRtcChannel::enableLocalVideo "enableLocalVideo" (true) 接口开启本地视频采集并发送后调用该方法。
     * @par 调用时机
     * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
     * @note
     * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
     * - 调用该方法取消发布本地视频流时，设备仍然处于工作状态。
     * - 该方法设置内部引擎为启用状态，在 nertc::IRtcChannel::leaveChannel "leaveChannel" 后设置失效，将恢复至默认，即默认发布本地视频流。
     * - 该方法与 \ref nertc::IRtcChannel::enableLocalVideo(NERtcVideoStreamType type, bool enabled) "enableLocalVideo" (false) 的区别在于，后者会关闭本地摄像头设备，该方法不禁用摄像头，不会影响本地视频流采集且响应速度更快。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>mute</td>
     *      <td>bool</td>
     *      <td>是否取消发布本地视频流：<ul><li>true：取消发布本地视频流。<li>false：恢复发布本地视频流。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * if (rtc_channel_) {
     * int res = rtc_channel_->muteLocalVideoStream(true);
     * }
     * @endcode
     * @par 相关回调
     * 取消发布本地视频主流或辅流后，远端会收到 \ref nertc::IRtcChannelEventHandler::onUserVideoMute "onUserVideoMute" 回调。
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *         - 30004（kNERtcErrNotSupported）：不支持的操作，比如纯音频 SDK 不支持该功能。
     *         - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未初始化。
     * @endif
     */
    virtual int muteLocalVideoStream(bool mute) = 0;

    /**
     * @if Chinese
     * 取消或恢复发布本地视频。
     * <br>调用该方法取消发布本地视频主流或辅流后，SDK 不再发送本地视频流。
     * @since V4.6.20
     * @par 使用前提 
     * 一般在通过 \ref nertc::IRtcChannel::enableLocalVideo() "enableLocalVideo" (true) 接口开启本地视频采集并发送后调用该方法。
     * @par 调用时机
     * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
     * @note
     * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
     * - 调用该方法取消发布本地视频流时，设备仍然处于工作状态。
     * - 若调用该方法取消发布本地视频流，通话结束后会被重置为默认状态，即默认发布本地视频流。
     * - 该方法与 \ref nertc::IRtcChannel::enableLocalVideo() "enableLocalVideo" (false) 的区别在于，后者会关闭本地摄像头设备，该方法不禁用摄像头，不会影响本地视频流采集且响应速度更快。
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
     *      <td>mute</td>
     *      <td>bool</td>
     *      <td>是否取消发布本地视频流：<ul><li>true：取消发布本地视频流。<li>false：恢复发布本地视频流。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * //取消发布本地视频主流
     * nertc::NERtcVideoStreamType type = nertc::NERtcVideoStreamType::kNERTCVideoStreamMain;
     * bool mute = true;
     * rtc_channel_->muteLocalVideoStream(type, mute);
     * //恢复发布本地视频主流
     * nertc::NERtcVideoStreamType type = nertc::NERtcVideoStreamType::kNERTCVideoStreamMain;
     * bool mute = false;
     * rtc_channel_->muteLocalVideoStream(type, mute);
     * //取消发布本地视频辅流
     * nertc::NERtcVideoStreamType type = nertc::NERtcVideoStreamType::kNERTCVideoStreamSub;
     * bool mute = true;
     * rtc_channel_->muteLocalVideoStream(type, mute);
     * //恢复发布本地视频辅流
     * nertc::NERtcVideoStreamType type = nertc::NERtcVideoStreamType::kNERTCVideoStreamSub;
     * bool mute = false;
     * rtc_channel_->muteLocalVideoStream(type, mute);
     * @endcode
     * @par 相关回调
     * 取消发布本地视频主流或辅流后，远端会收到 \ref nertc::IRtcEngineEventHandlerEx::onUserVideoMute "onUserVideoMute" 回调。
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     * @endif
     */
    virtual int muteLocalVideoStream(NERtcVideoStreamType type, bool mute) = 0;

    /**
     * @if English
     * Get a list of screens and windows that can be shared.
     * <br>
     * Before screen sharing or window sharing, you can call this method to get a list of objects that can be shared, so that users can select a screen or window to share from the thumbnail in the list.
     * The list contains important information such as window ID and screen ID, which you can obtain and then call startScreenCaptureByDisplayId or startScreenCaptureByWindowId to start sharing.
     *
     * @since v5.4.10
     *
     * @par Calling Time
     * Please call this interface after the engine is initialized, and this method can be called before and after joining the room.
     *
     * @note This method only applies to macOS and Windows.
     * @par Parameter Description
     * <table>
     *  <tr>
     *      <th>**Parameter Name**</th>
     *      <th>**Type**</th>
     *      <th>**Description**</th>
     *  </tr>
     *  <tr>
     *      <td>thumbSize</td>
     *      <td> \ref nertc::NERtcSize "NERtcSize"</td>
     *      <td>The target size (in pixels) of the thumbnail of the screen or window. See NERtcSize for details.
     *      <br>Under the premise of ensuring that the original image is not deformed, the SDK scales the original image to make the length of the longest side of the image consistent with the length of the longest side of the target size.
     *      <br>For example, if the original image width and height are 400 × 300, and thumbSize is 100 x 100, the actual size of the thumbnail is 100 × 75.
     *      <br>If the target size is larger than the original image size, the thumbnail is the original image, and the SDK does not perform scaling operations.</td>
     *  </tr>
     *  <tr>
     *      <td>iconSize</td>
     *      <td> \ref nertc::NERtcSize "NERtcSize"</td>
     *      <td>The target size (in pixels) of the icon corresponding to the program. See NERtcSize for details.
     *      <br>Under the premise of ensuring that the original image is not deformed, the SDK scales the original image to make the length of the longest side of the image consistent with the length of the longest side of the target size.
     *      <br>For example, if the original image width and height are 400 × 300, and iconSize is 100 × 100, the actual size of the icon is 100 × 75.
     *      <br>If the target size is larger than the original image size, the icon is the original image, and the SDK does not perform scaling operations.</td>
     *  </tr>
     *  <tr>
     *      <td>includeScreen</td>
     *      <td> bool </td>
     *      <td>Whether the SDK returns screen information in addition to window information:
     *      - true: Yes. The SDK returns screen and window information.
     *      - false: No. The SDK only returns window information.</td>
     *  </tr>
     * </table>
     * @par Example Code
     * @code
     * int count = 0;
     * auto source_list = getScreenCaptureSourceList(nertc::NERtcSize(128, 72), nertc::NERtcSize(32, 32), true);
     * if (source_list) {
     *     count = source_list->getCount();
     * }
     * @endcode
     *
     *
     * @return Pointer to the IScreenCaptureSourceList object.
     * @endif
     * @if Chinese
     * 获得一个可以共享的屏幕和窗口的列表
     * <br>
     * 屏幕共享或窗口共享前，调用该方法获取可共享的屏幕和窗口的对象列表，方便用户通过列表中的缩略图选择共享某个显示器的屏幕或某个窗口。
     * 列表中包含窗口 ID 和屏幕 ID 等重要信息。获取到 ID 后再调用 startScreenCaptureByDisplayId 或 startScreenCaptureByWindowId 开启共享。
     *
     * @since v5.4.10
     *
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，并且该方法可在加入房间前后调用。
     *
     * @note 该方法仅适用于 macOS 和 Windows。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>thumbSize</td>
     *      <td> \ref nertc::NERtcSize "NERtcSize"</td>
     *      <td>屏幕或窗口的缩略图的目标尺寸（宽高单位为像素）。详见 NERtcSize。
     *      <br>SDK 会在保证原图不变形的前提下，缩放原图，使图片最长边和目标尺寸的最长边的长度一致。
     *      <br>例如，原图宽高为 400 × 300，thumbSize 为 100 x 100，缩略图实际尺寸为 100 × 75。
     *      <br>如果目标尺寸大于原图尺寸，缩略图即为原图，SDK 不进行缩放操作。</td>
     *  </tr>
     *  <tr>
     *      <td>iconSize</td>
     *      <td> \ref nertc::NERtcSize "NERtcSize"</td>
     *      <td>程序所对应的图标的目标尺寸（宽高单位为像素）。详见 NERtcSize。
     *      <br>SDK 会在保证原图不变形的前提下，缩放原图，使图片最长边和目标尺寸的最长边的长度一致。
     *      <br>例如，原图宽高为 400 × 300，iconSize 为 100 × 100，图标实际尺寸为 100 × 75。
     *      <br>如果目标尺寸大于原图尺寸，图标即为原图，SDK 不进行缩放操作。</td>
     *  </tr>
     *  <tr>
     *      <td>includeScreen</td>
     *      <td> bool </td>
     *      <td>除了窗口信息外，SDK 是否还返回屏幕信息：
     *      - true: 是。SDK 返回屏幕和窗口信息。
     *      - false: 否。SDK 仅返回窗口信息。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * int count = 0;
     * auto source_list = getScreenCaptureSourceList(nertc::NERtcSize(128, 72), nertc::NERtcSize(32, 32), true);
     * if (source_list) {
     *     count = source_list->getCount();
     * }
     * @endcode
     *
     * @return IScreenCaptureSourceList 对象指针。
     * @endif
     */
    virtual IScreenCaptureSourceList* getScreenCaptureSources(const NERtcSize& thumbSize, const NERtcSize& iconSize, const bool includeScreen) = 0;

    /** 
     * @if English
     * Shares screens through specifying regions. Shares a certain screen or part of region of a screen. Users need to specify the screen region they wants to share in the method.
     * <br>When calling the method, you need to specify the screen region to be shared, and share the overall frame of the screen or designated regions. 
     * <br>If you join a room and successfully call this method to enable the substream, the onUserSubStreamVideoStart and setExcludeWindowList callback is remotely triggered.
     * @note
     * - The method applies to Windows only.
     * - The method enables video substreams.
     * @since V4.5.0
     * @param  screen_rect      The relative position of the screen to virtual screens that is shared. 
     * @param  region_rect      The relative position of shared screen to the full screen. If you set the shared region beyond the frame of the screen, only content within the screen is shared. If you set the value of width or height as 0, the full screen is shared. 
     * @param  capture_params   The configurations of screen sharing. 
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * 
     * @endif
     * @if Chinese
     * 开启屏幕共享，共享范围为指定屏幕的指定区域。
     * <br>调用该方法时，可以选择共享整个虚拟屏、指定屏幕，或虚拟屏、整个屏幕的某些区域范围。
     * <br>此方法调用成功后，远端触发 onUserSubStreamVideoStart 和 setExcludeWindowList 回调。
     *  @note
     * - 该方法仅适用于 Windows。macOS 平台请使用方法 startScreenCaptureByDisplayId。
     * - 该方法需要在加入房间后调用。
     * @since V4.5.0
     * @param  screen_rect      指定待共享的屏幕相对于虚拟屏的位置。
     * @param  region_rect      指定待共享区域相对于整个屏幕屏幕的位置。如果设置的共享区域超出了屏幕的边界，则只共享屏幕内的内容；如果将 width 或 height 设为 0, 则共享整个屏幕。
     * @param  capture_params   屏幕共享的编码参数配置。
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
     * @endif
     */
    virtual int startScreenCaptureByScreenRect(const NERtcRectangle& screen_rect, const NERtcRectangle& region_rect, const NERtcScreenCaptureParameters& capture_params) = 0;

    /**
     * @if English
     * Enables screen sharing by specifying the ID of the screen. The content of screen sharing is sent by substreams.
     * <br>If you join a room and call this method to enable the substream, the onUserSubStreamVideoStart and onScreenCaptureStatus callback is remotely triggered.
     * @note 
     * - The method applies to only macOS. 
     * - The method enables video substreams.
     * @since V4.5.0
     * @param  display_id       The ID of the screen to be shared. Developers need to specify the screen they share through the parameters.
     * @param  region_rect      The relative position of shared screen to the full screen.
     * @param  capture_params   The configurations of screen sharing.
     * @return
     * - 0: Success.
     * - Other values: Failure.

     *  @endif
     *  @if Chinese
     * 通过指定屏幕 ID 开启屏幕共享，屏幕共享内容以辅流形式发送。
     * <br>此方法调用成功后，远端触发 onUserSubStreamVideoStart 回调。
     * @note
     * - 该方法仅适用于 macOS。Windows 平台请使用方法 startScreenCaptureByScreenRect。
     * - 该方法需要在加入房间后设置。
     * @since V4.5.0
     * @param  display_id       指定待共享的屏幕 ID。开发者需要自行实现枚举屏幕 ID 的方法，并通过该参数指定需要共享的屏幕。
     * @param  region_rect      指定待共享的区域相对于整个窗口的位置。如果设置的共享区域超出了窗口的边界，则只共享窗口内的内容；如果宽或高为 0，则共享整个窗口。
     * @param  capture_params   屏幕共享的参数配置，包括码率、帧率、编码策略、屏蔽窗口列表等。
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
     * @endif
     */
    virtual int startScreenCaptureByDisplayId(source_id_t display_id, const NERtcRectangle& region_rect, const NERtcScreenCaptureParameters& capture_params) = 0;

    /** 
     * @if English
     * Enables screen sharing by specifying the ID of the window. The content of screen sharing is sent by substreams.
     * <br>If you join a room and call this method to enable the substream, the onUserSubStreamVideoStart and setExcludeWindowList callback is remotely triggered.
     * @note
     * - The method applies to Windows only and macOS.
     * - The method enables video substreams.
     * @since V4.5.0
     * @param  window_id        The ID of the window to be shared.
     * @param  region_rect      The relative position of shared screen to the full screen.
     * @param  capture_params   The configurations of screen sharing.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * 
     * @endif
     * @if Chinese
     * 通过指定窗口 ID 开启屏幕共享，屏幕共享内容以辅流形式发送。
     * <br>调用该方法时需要指定待共享的屏幕 ID，共享该屏幕的整体画面或指定区域。
     * <br>此方法调用成功后：
     * - Windows 平台远端触发 onUserSubStreamVideoStop 和 onScreenCaptureStatus 回调。
     * - macOS 平台远端触发 onUserSubStreamVideoStop 回调。
     * @note
     * - 该方法适用于 Windows 和 macOS。
     * - 该方法需要在加入房间后调用。
     * @since V4.5.0
     * @param  window_id        指定待共享的窗口 ID。
     * @param  region_rect      指定待共享的区域相对于整个窗口的位置。如果设置的共享区域超出了窗口的边界，则只共享指定区域中窗口内的内容；如果宽或高为 0，则共享整个窗口。
     * @param  capture_params   屏幕共享的参数配置，包括码率、帧率、编码策略、屏蔽窗口列表等。
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
     * @endif
     */
    virtual int startScreenCaptureByWindowId(source_id_t window_id, const NERtcRectangle& region_rect, const NERtcScreenCaptureParameters& capture_params) = 0;

    /**
     * @if English
     * Set the screen sharing parameters. This method is called during the screen sharing process to quickly switch the capture source.
     * <br>
     * If you want to switch the window to be shared during the screen sharing process, you can call this function again without having to restart the screen sharing.
     * The following four scenarios are supported:
     * - Share the entire screen: set the type of the source in the source parameter to kScreen, and set the region_rect parameter to { 0, 0, 0, 0 }.
     * - Share a specified region: set the type of the source in the source parameter to kScreen, and set the region_rect parameter to a non-null value, for example, { 100, 100, 300, 300 }.
     * - Share the entire window: set the type of the source in the source parameter to kWindow, and set the region_rect parameter to { 0, 0, 0, 0 }.
     * - Share a specified window region: set the type of the source in the source parameter to kWindow, and set the region_rect parameter to a non-null value, for example, { 100, 100, 300, 300 }.
     *
     * @since v5.4.10
     *
     * @par Calling Conditions
     * Please call this interface after the screen sharing has been started.
     *
     * @note This method is only applicable to macOS and Windows.
     * @par Parameter Description
     * <table>
     *  <tr>
     *      <th>**Parameter Name**</th>
     *      <th>**Type**</th>
     *      <th>**Description**</th>
     *  </tr>
     *  <tr>
     *      <td>source</td>
     *      <td> \ref nertc::NERtcScreenCaptureSourceInfo "NERtcScreenCaptureSourceInfo"</td>
     *      <td>Specify the capture source obtained through \ref nertc::IRtcEngineEx::getScreenCaptureSources.</td>
     *  </tr>
     *  <tr>
     *      <td>region_rect</td>
     *      <td> \ref nertc::NERtcRectangle "NERtcRectangle"</td>
     *      <td>Specify the captured region.</td>
     *  </tr>
     *  <tr>
     *      <td>capture_params</td>
     *      <td> \ref nertc::NERtcScreenCaptureParameters "NERtcScreenCaptureParameters" </td>
     *      <td>Specify the attributes of the screen sharing target, including capturing the mouse and highlighting the captured window. For details, please refer to the definition of NERtcScreenCaptureParameters.</td>
     *  </tr>
     * </table>
     * @par Sample Code
     * @code
     * NERtcScreenCaptureSourceInfo source;
     * source.source_id = info.id;
     * source.type = nertc::kScreen;
     * nertc::NERtcRectangle rc {0, 0, 0, 0};
     * nertc::NERtcScreenCaptureParameters capture_params;
     * // Initialize capture_params
     * int ret = SetScreenCaptureSource(source, rc, capture_params);
     * if (res != kNERtcNoError) {
     *   // Prompt the user that the operation failed.
     * }
     * @endcode
     *
     * @return
     * - 0: The method call was successful.
     * - Others: The method call failed.
     * @endif
     * @if Chinese
     * 设置屏幕共享参数，该方法在屏幕共享过程中调用，用来快速切换采集源。
     * <br>
     * 如果在屏幕共享的过程中，切换想要共享的窗口，可以再次调用这个方法而不需要重新开启屏幕共享。
     * 支持如下四种情况：
     * - 共享整个屏幕：source 中 type 为 kScreen 的 source，region_rect 设为 { 0, 0, 0, 0 }。
     * - 共享指定区域：source 中 type 为 kScreen 的 source，region_rect 设为非 nullptr，例如 { 100, 100, 300, 300 }。
     * - 共享整个窗口：source 中 type 为 kWindow 的 source，region_rect 设为 { 0, 0, 0, 0 }。
     * - 共享窗口区域：source 中 type 为 kWindow 的 source，region_rect 设为非 nullptr，例如 { 100, 100, 300, 300 }。
     *
     * @since v5.4.10
     *
     * @par 调用时机
     * 请在已经开启了屏幕共享之后再调用此接口
     *
     * @note 该方法仅适用于 macOS 和 Windows。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>source</td>
     *      <td> \ref nertc::NERtcScreenCaptureSourceInfo "NERtcScreenCaptureSourceInfo"</td>
     *      <td>指定共享源，通过 \ref nertc::IRtcChannel::getScreenCaptureSources "getScreenCaptureSources" 获取。</td>
     *  </tr>
     *  <tr>
     *      <td>region_rect</td>
     *      <td> \ref nertc::NERtcRectangle "NERtcRectangle"</td>
     *      <td>指定捕获的区域。</td>
     *  </tr>
     *  <tr>
     *      <td>capture_params</td>
     *      <td> \ref nertc::NERtcScreenCaptureParameters "NERtcScreenCaptureParameters" </td>
     *      <td>指定屏幕共享目标的属性，包括捕获鼠标，高亮捕获窗口等，详情参考 \ref nertc::NERtcScreenCaptureParameters 定义。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * NERtcScreenCaptureSourceInfo source;
     * source.source_id = info.id;
     * source.type = nertc::kScreen;
     * nertc::NERtcRectangle rc {0, 0, 0, 0};
     * nertc::NERtcScreenCaptureParameters capture_params;
     * // capture_params 初始化
     * int ret = SetScreenCaptureSource(source, rc, capture_params);
     * if (ret != kNERtcNoError) {
     *   // 提示用户操作失败。
     * }
     * @endcode
     *
     * @return 
     * - 0: 方法调用成功。
     * - 其他: 方法调用失败。
     * @endif
     */
    virtual int32_t setScreenCaptureSource(const NERtcScreenCaptureSourceInfo& source, const NERtcRectangle& region_rect, const NERtcScreenCaptureParameters& capture_params) = 0;

    /** 
     * @if English
     * When sharing a screen or window, updates the shared region.
     * @since V4.5.0
     * @param  region_rect      The relative position of shared screen to the full screen. If you set the shared region beyond the frame of the screen, only content within the screen is shared. If you set width or height as 0, the full screen is shared.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * 
     * @endif
     * @if Chinese
     * 在共享屏幕或窗口时，更新共享的区域。
     * <br>在 Windows 平台中，远端会触发 onScreenCaptureStatus 回调。
     * @since V4.5.0
     * @param  region_rect      指定待共享的区域相对于整个窗口或屏幕的位置。如果设置的共享区域超出了边界，则只共享指定区域中，窗口或屏幕内的内容；如果宽或高为 0，则共享整个窗口或屏幕。
     * @return
     * - 0: 方法调用成功。
     * - 其他: 方法调用失败。
     * @endif
     */
    virtual int updateScreenCaptureRegion(const NERtcRectangle& region_rect) = 0;

    /**
     * @if English
     * Displays or hides the pointer during screen sharing.
     * @since V4.6.10
     * @param bool specifies whether to display the pointer.
     * - true: displays the pointer.
     * - false: hides the pointer.
     * @return
     * - 0: success
     * - Others: failure
     * @endif
     * @if Chinese
     * 在共享屏幕或窗口时，更新是否显示鼠标。
     * @since V4.6.10
     * @param capture_cursor 屏幕共享时是否捕捉鼠标光标。
     * - true：共享屏幕时显示鼠标。
     * - false：共享屏幕时不显示鼠标。
     * @return
     * - 0: 方法调用成功。
     * - 其他: 方法调用失败
     * @endif
     */
    virtual int setScreenCaptureMouseCursor(bool capture_cursor) = 0;

    /** 
     * @if English
     * Stops screen sharing.
     * <br>If you use the method to disable the substream after joining a room, the onUserSubStreamVideoStop callback is remotely triggered.
     * @since V4.5.0
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * 
     * @endif
     * @if Chinese
     * 关闭屏幕共享。
     * <br>
     * 通过此接口可以实现关闭屏幕共享辅流。
     * @since V3.5.0
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
     * @par 示例代码
     * @code
     * rtc_channel_->stopScreenCapture();
     * @endcode
     * @par 相关回调
     * 成功调用此方法后，本端会触发 \ref nertc::IRtcChannelEventHandler::onScreenCaptureStatus "onScreenCaptureStatus" 回调（仅 Windwos 平台），远端会触发 \ref nertc::IRtcChannelEventHandler::onUserSubStreamVideoStop "onUserSubStreamVideoStop" 回调。
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *         - 30005（kNERtcErrInvalidState）：引擎未初始化或未开启屏幕共享。
     *         - 30022（kErrorDesktopCaptureNotReady）：未找到正在共享目标源或未开启屏幕共享。
     *         - 30101（kErrorRoomNotJoined）：未加入房间。
     *         - 30200（kErrorConnectionNotFound）：未找到信令连接。
     *         - 30203（kErrorTrackNotFound）：轨道错误。
     *         - 30300（kErrorTransceiverNotFound）：收发器错误。
     *         - 30400（kErrorRtcRoomNotFound）：未找到对应房间。
     * @endif
     */
    virtual int stopScreenCapture() = 0;

    /** 
     * @if English
     * Pauses screen sharing.
     * @since V4.5.0
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * 
     * @endif
     * @if Chinese 
     * 暂停屏幕共享。
     * - 暂停屏幕共享后，共享区域内会持续显示暂停前的最后一帧画面，直至通过 resumeScreenCapture 恢复屏幕共享。
     * - 在 Windows 平台中，本端会触发 onScreenCaptureStatus 回调。
     * <p>@since V4.5.0
     * @return
     * - 0: 方法调用成功
     * - 其他: 方法调用失败
     * @endif
     */
    virtual int pauseScreenCapture() = 0;

    /** 
     * @if English
     * Resumes screen sharing. 
     * @since V4.5.0
     * @return
     * - 0: Success.
     * - Other values: Failure. 
     * @endif
     * @if Chinese 
     * 恢复屏幕共享。
     * <br>在 Windows 平台中，远端会触发 onScreenCaptureStatus 回调。
     * @since V4.5.0
     * @return
     * - 0: 方法调用成功
     * - 其他: 方法调用失败
     * @endif
     */
    virtual int resumeScreenCapture() = 0;


    /** 
     * @if English
     * Sets the window list that need to be blocked in capturing screens. The method can be dynamically called in the capturing.
     * @since V4.5.0
     * @param  window_list      The ID of the screen to be blocked.
     * @param  count            The number of windows that are needed to be blocked.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * 
     * @endif
     * @if Chinese
     * 设置共享整个屏幕或屏幕指定区域时，需要屏蔽的窗口列表。
     * <br>开启屏幕共享时，可以通过 NERtcScreenCaptureParameters 设置需要屏蔽的窗口列表；开发者可以在开启屏幕共享后，通过此方法动态调整需要屏蔽的窗口列表。被屏蔽的窗口不会显示在屏幕共享区域中。
     * @note 
     * - 在 Windows 平台中，该接口在屏幕共享过程中可动态调用；在 macOS 平台中，该接口自 V4.6.0 开始支持在屏幕共享过程中动态调用。
     * - 在 Windows 平台中，某些窗口在被屏蔽之后，如果被置于图层最上层，此窗口图像可能会黑屏。此时会触发 onScreenCaptureStatus.kScreenCaptureStatusCovered 回调，建议应用层在触发此回调时提醒用户将待共享的窗口置于最上层。
     * @since V4.5.0
     * @param  window_list      需要屏蔽的窗口 ID 列表。
     * @param  count            需屏蔽的窗口的数量。
     * @return
     * - 0: 方法调用成功
     * - 其他: 方法调用失败
     * @endif
     */
    virtual int setExcludeWindowList(source_id_t* window_list, int count) = 0;

    /**
     * @if Chinese
     * 更新屏幕共享参数。
     * <br>开始共享屏幕或窗口后，动态更新采集帧率，目标码率，编码分辨率等屏幕共享相关参数。
     * @since V4.6.20
     * @par 调用时机  
     * 请在加入房间并成功开启屏幕共享后调用该方法。
     * @note 
     * - 调用该方法会重新启动屏幕共享，因此建议不要频繁调用。
     * - 可以通过该方法动态设置是否捕捉鼠标（capture_mouse_cursor）和设置排除窗口（excluded_window_list，excluded_window_count），同时这两项设置也可以通过 \ref IRtcEngineEx::setScreenCaptureMouseCursor "setScreenCaptureMouseCursor" 和 \ref IRtcEngineEx::setExcludeWindowList "setExcludeWindowList"  方法实现。
     * @par 参数说明 
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>captureParams</td> 
     *      <td> \ref nertc::NERtcScreenCaptureParameters "NERtcScreenCaptureParameters"</td> 
     *      <td>屏幕共享编码参数配置。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * //调用该方法时，需要维护一个 nertc::NERtcScreenCaptureParameters captureParams 变量记录当前设置。更新设置的时候：
     * nertc::NERtcScreenCaptureParameters captureParams;
     * captureParams.field1 = new_value1;
     * captureParams.field2 = new_value2;
     * ...
     * rtc_channel->updateScreenCaptureParameters(captureParams);
     * @endcode
     * @par 相关回调
     * 成功调用该方法后，会触发 \ref IRtcChannelEventHandler::onScreenCaptureStatus "onScreenCaptureStatus" 回调。
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *         - 30005（kErrorErrInvalidState）：多房间状态错误。
     *         - 30021（kNERtcErrDesktopCaptureInvalidParam）：传入的参数无效。
     *         - 30101（kNERtcErrChannelNotJoined）：未加入房间。
     * @endif
     */
    virtual int updateScreenCaptureParameters(const nertc::NERtcScreenCaptureParameters &captureParams) = 0;

    /** 
     * @if English
     * Sets local views.
     * <br>This method is used to set the display information about the local video. The method is applicable for only local users. Remote users are not affected.
     * <br>Apps can call this API operation to associate with the view that plays local video streams. During application development, in most cases, before joining a room, you must first call this method to set the local video view after the SDK is initialized.
     * @note  If you use external rendering on the Mac platform, you must set the rendering before the SDK is initialized. 
     * @since V4.5.0
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
     * rtc_channel_->setupLocalVideoCanvas(canvas)
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
     * Sets a remote substream canvas.
     * - This method is used to set the display information about the local secondary stream video. The app associates with the video view of local secondary stream by calling this method. 
     * - During application development, in most cases, before joining a room, you must first call this method to set the local video view after the SDK is initialized.
     * @since V4.5.0
     * @param[in] canvas        The video canvas information.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * 
     * @endif
     * @if Chinese
     * 设置本地辅流视频画布。
     * - 该方法设置本地辅流视频显示信息。App 通过调用此接口绑定本地辅流的显示视窗（view）。 
     * - 在 App 开发中，通常在初始化后调用该方法进行本地视频设置，然后再加入房间。
     * @since V4.5.0
     * @param[in] canvas        视频画布信息。
     * @return
     * - 0: 方法调用成功。
     * - 其他: 方法调用失败。
     * @endif
     */
    virtual int setupLocalSubStreamVideoCanvas(NERtcVideoCanvas* canvas) = 0;

    /** 
     * @if English
     * Sets the display mode for local substreams video of screen sharing.
     * This method is used to set the display mode about the local view. The application can repeatedly call the method to change the display mode.
     * @note You must set the local canvas for local substreams through setupLocalSubStreamVideoCanvas. 
     * @since V4.5.0
     * @param[in] scaling_mode      The video display mode. #NERtcVideoScalingMode.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 设置画布中本地视频画面的显示模式。
     * <br>
     * 通过本接口可以实现设置本地视频画面的适应性，即是否裁剪或缩放。
     * @since V3.5.0
     * @par 调用时机  
     * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
     * @note
     * 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>scaling_mode</td>
     *      <td>int</td>
     *      <td>视频显示模式类型：<ul><li>kNERtcVideoScaleFit（0）:适应视频，视频尺寸等比缩放。优先保证视频内容全部显示。若视频尺寸与显示视窗尺寸不一致，视窗未被填满的区域填充背景色。<li>kNERtcVideoScaleFullFill（1）：视频尺寸非等比缩放。保证视频内容全部显示，且填满视窗。<li>kNERtcVideoScaleCropFill（2）：适应区域，视频尺寸等比缩放。保证所有区域被填满，视频超出部分会被裁剪。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * rtc_channel_->setLocalRenderMode(nertc::kNERtcVideoScaleFit);
     * @endcode
     * @return 
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未初始化。
     * @endif
     */
    virtual int setLocalRenderMode(NERtcVideoScalingMode scaling_mode) = 0;

    /** 
     * @if English
     * Sets the local view display mode.  
     * <br>This method is used to set the display mode about the local view. The application can repeatedly call the method to change the display mode.
     * @note You must set local secondary canvas before enabling screen shariing.
     * @since V4.5.0
     * @param[in] scaling_mode  The video display mode. #NERtcVideoScalingMode.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * 
     * @endif
     * @if Chinese
     * 设置本端的屏幕共享辅流视频显示模式。
     * <br>该方法设置本地视图显示模式。 App 可以多次调用此方法更改显示模式。
     * @note 调用此方法前，必须先通过 setupLocalSubStreamVideoCanvas 设置本地辅流画布。
     * @since V4.5.0
     * @param[in] scaling_mode  视频显示模式。
     * @return
     * - 0: 方法调用成功。
     * - 其他: 方法调用失败。
     * @endif
     */
    virtual int setLocalSubStreamRenderMode(NERtcVideoScalingMode scaling_mode) = 0;

    /** 
     * @if English
     * Sets the mirror mode of the local video. 
     * The method is used to set whether to enable the mirror mode for the local video. The mirror code determines whether to flip the screen view right or left. 
     * Mirror mode for local videos only affects what local users view. The views of remote users are not affected. App can repeatedly call this method to modify the mirror mode.
     * @since V4.5.0
     * @param[in] mirror_mode       The video mirror mode. For more information, see {@link NERtcVideoMirrorMode}.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 设置本地视频镜像模式。
     * <br>该方法用于设置本地视频是否开启镜像模式，即画面是否左右翻转。
     * @note
     * - 该方法仅适用于视频主流，若您希望设置视频辅流的镜像模式，请调用 \ref IRtcChannel::setLocalVideoMirrorMode(NERtcVideoStreamType type, NERtcVideoMirrorMode mirror_mode "setLocalVideoMirrorMode" 方法。
     * - 该方法用于 \ref nertc::IRtcChannel::setupLocalVideoCanvas() "setupLocalVideoCanvas" 之后。
     * - 本地的视频镜像模式仅影响本地用户所见，不影响远端用户所见。App 可以多次调用此方法更改镜像模式。
     * @since V4.5.0
     *  @param[in] mirror_mode      视频镜像模式。详细信息请参考 {@link NERtcVideoMirrorMode}。
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
    * @endif
    */
    virtual int setLocalVideoMirrorMode(NERtcVideoMirrorMode mirror_mode) = 0;

    /**
     * @if Chinese
     * 设置本地视频镜像模式。
     * <br>通过此接口可以设置本地视频是否开启镜像模式，即画面是否左右翻转。
     * @since V4.6.20
     * @par 使用前提
     * 请在通过 \ref IRtcChannel::setupLocalVideoCanvas "setupLocalVideoCanvas" 接口设置本地视频画布后调用该方法。
     * @par 调用时机  
     * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
     * @note 
     * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
     * - 本地视频画布的镜像模式仅影响本地用户所见，不影响远端用户所见。您的应用层可以多次调用此方法更改镜像模式。
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
     *      <td>视频通道类型：<ul><li>kNERtcVideoStreamMain：主流。<li>kNERtcVideoStreamSub：辅流。</td>
     *  </tr>
     *  <tr>
     *      <td>mirror_mode</td>
     *      <td> \ref nertc::NERtcVideoMirrorMode "NERtcVideoMirrorMode"</td>
     *      <td>视频镜像模式：<ul><li>kNERtcVideoMirrorModeAuto：由 SDK 决定是否启用镜像模式。<li>kNERtcVideoMirrorModeEnabled：启用镜像模式。<li>kNERtcVideoMirrorModeDisabled（默认）：关闭镜像模式。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * //设置本地视频主流的镜像模式
     * nertc::NERtcVideoStreamType type = nertc::NERtcVideoStreamType::kNERTCVideoStreamMain;
     * nertc::NERtcVideoMirrorMode mirror_mode = kNERtcVideoMirrorModeEnabled;
     * rtc_channel_->setLocalVideoMirrorMode(type, mirror_mode);
     * //设置本地视频辅流的镜像模式
     * nertc::NERtcVideoStreamType type = nertc::NERtcVideoStreamType::kNERTCVideoStreamSub;
     * nertc::NERtcVideoMirrorMode mirror_mode = kNERtcVideoMirrorModeEnabled;
     * rtc_channel_->setLocalVideoMirrorMode(type, mirror_mode);
     * @endcode
     * @par 相关接口
     * - \ref IRtcChannel::setupLocalVideoCanvas "setupLocalVideoCanvas"：通过此接口也设置本地视频画布的镜像模式，不影响远端用户所见。
     * - \ref IRtcChannel::setupRemoteVideoCanvas "setupRemoteVideoCanvas"：通过此接口设置远端用户视频画布的镜像模式，不影响远端用户所见。
     * - \ref IRtcChannel::setVideoConfig(NERtcVideoStreamType type, const NERtcVideoConfig& config) "setVideoConfig"：通过此接口设置本地视频的镜像模式，影响远端用户看到的视频画面。
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     * @endif
     */
    virtual int setLocalVideoMirrorMode(NERtcVideoStreamType type, NERtcVideoMirrorMode mirror_mode) = 0;

    /** 
     * @if English
     *  Sets views for remote users.
     * <br>This method is used to associate remote users with display views and configure the rendering mode and mirror mode for remote views that are displayed locally. The method affects only video display viewed by local users.
     * @note
     * - You need to specify the uid of remote video when the interface is called. In general cases, the uid can be set before users join the room.
     * - If the user ID is not retrieved, the App calls this method after the onUserJoined event is triggered. To disassociate a specified user from a view, you can leave the canvas parameter empty.
     * - After a user leaves the room, the association between a remote user and the view is cleared.
     * @since V4.5.0
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
     * rtc_channel_->setupRemoteVideoCanvas(uid, canvas);
     * @endcode
     * @par 相关接口
     * 若您希望在通话中更新远端用户视图的渲染模式，请调用 \ref nertc::IRtcChannel::setRemoteRenderMode "setRemoteRenderMode" 方法。
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
     * Sets a remote substream video canvas.
     * <br>The method associates a remote user with a substream view. You can assign a specified uid to use a corresponding canvas.
     * @note 
     * - If the uid is not retrieved, you can set the user ID after the app receives a message delivered when the \ref IRtcEngineEventHandler::onUserJoined "onUserJoined"  is triggered.
     * - After a user leaves the room, the association between a remote user and the view is cleared.
     * - After a user leaves the room, the association between a remote user and the canvas is cleared. The setting is automatically invalid. 
     * @since V4.5.0
     * @param[in] uid       The ID of a remote user.
     * @param[in] canvas    The video canvas settings.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * 
     * @endif
     * @if Chinese
     * 设置远端用户的视频辅流画布。
     * <br>通过此接口可以实现绑定远端用户和对应辅流的显示视图，即指定某个 uid 使用对应的画布显示。
     * @since V3.9.0
     * @par 使用前提
     * 建议在收到远端用户加入房间的 \ref IRtcChannelEventHandler::onUserJoined(uid_t  uid,  const char *  user_name,  NERtcUserJoinExtraInfo  join_extra_info) "onUserJoined"  回调后，再调用此接口通过回调返回的 uid 设置对应视图。
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
     * @note 
     * - 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
     * - 退出房间后，SDK 会清除远端用户和画布的的绑定关系，该设置自动失效。
     * - 若您使用的是 macOS 平台，请注意不要动态切换画布，若您移除画布，SDK 会自动停止订阅对应用户的视频流；若您修改画布，可能无法正常生效。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>canvas</td>
     *      <td>NERtcVideoCanvas*</td>
     *      <td>视频画布。详细信息请参考 \ref nertc::NERtcVideoCanvas "NERtcVideoCanvas"。</td>
     *  </tr>
     *  <tr>
     *      <td>uid</td>
     *      <td>uid_t</td>
     *      <td>远端用户 ID。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * nertc::NERtcVideoCanvas canvas;
     * canvas.cb = onRemoteFrameDataCallback;//回调和窗口 2选1，全部不填代表移除
     * canvas.user_data = nullptr;
     * canvas.window = window;
     * if (rtc_channel_) {
     * ret = rtc_channel_->setupRemoteSubStreamVideoCanvas(uid, &canvas);
     * }
     * @endcode
     * @par 相关接口
     * 可以调用 \ref nertc::IRtcChannel::setRemoteRenderMode "setRemoteRenderMode" 方法在通话过程中更新远端用户视图的渲染模式。
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30004（kNERtcErrNotSupported）：不支持的操作，比如纯音频 SDK 不支持该功能。
     * @endif
     */
    virtual int setupRemoteSubStreamVideoCanvas(uid_t uid, NERtcVideoCanvas* canvas) = 0;

    /** 
     * @if English
     * Sets display mode for remote views. 
     * This method is used to set the display mode for the remote view. App can repeatedly call this method to modify the display mode.
     * @since V4.5.0
     * @param[in] uid           The ID of a remote user.
     * @param[in] scaling_mode  The video display mode. #NERtcVideoScalingMode.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 设置远端视图显示模式。
     * 该方法设置远端视图显示模式。App 可以多次调用此方法更改显示模式。
     * @since V4.5.0
     * @param[in] uid           远端用户 ID。
     * @param[in] scaling_mode  视频显示模式: #NERtcVideoScalingMode
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
     * @endif
     */
    virtual int setRemoteRenderMode(uid_t uid, NERtcVideoScalingMode scaling_mode) = 0;

    /** 
     * @if English
     * Sets substream video display modes for remote screen sharing.
     * <br>You can use the method when screen sharing is enabled in substreams on the remote side. The application can repeatedly call the method to change the display mode.
     * @since V4.5.0
     * @param[in] uid           The ID of a remote user.
     * @param[in] scaling_mode  The video display mode. #NERtcVideoScalingMode.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * 
     * @endif
     * @if Chinese
     * 设置远端的屏幕共享辅流视频显示模式。
     * <br>在远端开启辅流形式的屏幕共享时使用。App 可以多次调用此方法更改显示模式。
     * @since V4.5.0
     * @param[in] uid           远端用户 ID。
     * @param[in] scaling_mode  视频显示模式。
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
     * @endif
     */
    virtual int setRemoteSubSteamRenderMode(uid_t uid, NERtcVideoScalingMode scaling_mode) = 0;
	
    /** 
     * @if English
     * Sets the role of a user in live streaming.
     * <br>The method sets the role to host or audience. The permissions of a host and a viewer are different.
     * - A host has the permissions to open or close a camera, publish streams, call methods related to publishing streams in interactive live streaming. The status of the host is visible to the users in the room when the host joins or leaves the room.
     * - The audience has no permissions to open or close a camera, call methods related to publishing streams in interactive live streaming, and is invisible to other users in the room when the user that has the audience role joins or leaves the room.
     * <p>@since V4.5.0
     * @note
     * - By default, a user joins a room as a host.
     * - Before a user joins a room, the user can call this method to change the client role to audience. Users can switch the role of a user through the interface after joining the room.
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
     * 该方法仅在通过 \ref nertc::IRtcEngine::setChannelProfile() "setChannelProfile" 方法设置房间场景为直播场景（kNERtcChannelProfileLiveBroadcasting）时调用有效。
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
     * rtc_channel_->setClientRole(nertc::kNERtcClientRoleBroadcaster);
     * //切换用户角色为观众
     * rtc_channel_->setClientRole(nertc::kNERtcClientRoleAudience);
     * @endcode
     * @par 相关回调
     * - 加入房间前调用该方法设置用户角色，不会触发任何回调，在加入房间成功后角色自动生效：
     *          - 设置用户角色为主播：加入房间后，远端用户触发 \ref nertc::IRtcChannelEventHandler::onUserJoined() "onUserJoined" 回调。
     *          - 设置用户角色为观众：加入房间后，远端用户不触发任何回调。
     * - 加入房间后调用该方法切换用户角色：
     *          - 从观众角色切为主播：本端用户触发 \ref nertc::IRtcChannelEventHandler::onClientRoleChanged "onClientRoleChanged" 回调，远端用户触发 \ref nertc::IRtcChannelEventHandler::onUserJoined(uid_t uid, const char *user_name, NERtcUserJoinExtraInfo join_extra_info) "onUserJoined" 回调。
     *          - 从主播角色切为观众：本端用户触发 \ref nertc::IRtcChannelEventHandler::onClientRoleChanged "onClientRoleChanged" 回调，远端用户触发 \ref nertc::IRtcChannelEventHandler::onUserLeft(uid_t uid, NERtcSessionLeaveReason reason, NERtcUserJoinExtraInfo leave_extra_info) "onUserLeft" 回调。
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
     * Sets the priority of media streams from a local user.
     * <br>If a user has a high priority, the media stream from the user also has a high priority. In unreliable network connections, the SDK guarantees the quality the media stream from users with a high priority.
     * @note
     * - You must call the method before you call joinChannel.
     * - After switching channels, media priority changes to the default value of normal priority.
     * - An RTC room has only one user that has a high priority. We recommend that only one user in a room call the setLocalMediaPriority method to set the local media stream a high priority. Otherwise, you need to enable the preempt mode to ensure the high priority of the local media stream.
     * @since V4.5.0
     * @param priority      The priority of the local media stream. The default value is #kNERtcMediaPriorityNormal. For more information, see #NERtcMediaPriorityType.
     * @param is_preemptive specifies whether to enable the preempt mode. The default value is false, which indicates that the preempt mode is disabled.
                            - If the preempt mode is enabled, the local media stream preempts the high priority over other users. The priority of the media stream whose priority is taken becomes normal. After the user whose priority is taken leaves the room, other users still keep the normal priority.
                            - If the preempt mode is disabled, and a user in the room has a high priority. After that, the high priority of the local client remains invalid and is still normal.
     * @return
            - 0: Success.
            - Other values: Failure.
     * @endif
     * @if Chinese
     * 设置本地用户的媒体流优先级。
     * <br>
     * 通过此接口可以实现设置某用户的媒体流优先级为高，从而弱网环境下 SDK 会优先保证其他用户收到的该用户媒体流的质量。
     * @since V4.2.0
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间前调用。
     * @note
     * - 一个音视频房间中只有一个高优先级的用户。建议房间中只有一位用户调用 setLocalMediaPriority 将本端媒体流设为高优先级，否则需要开启抢占模式，保证本地用户的高优先级设置生效。
     * - 调用 \ref nertc::IRtcEngine::switchChannel "switchChannel" 方法快速切换房间后，媒体优先级会恢复为默认值，即普通优先级。
     * @par 参数说明 
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>priority</td>
     *      <td> \ref nertc::NERtcMediaPriorityType "NERtcMediaPriorityType"</td>
     *      <td>本地用户的媒体流优先级，默认为 kNERtcMediaPriorityNormal，即普通优先级。</td>
     *  </tr>
     *  <tr>
     *      <td>is_preemptive</td>
     *      <td>bool</td>
     *      <td>是否开启抢占模式，默认为 NO，即不开启：<ul><li>true：开启抢占模式。抢占模式开启时，本地用户可以抢占其他用户的高优先级，被抢占的用户的媒体优先级变为普通优先级，在抢占者退出房间后，其他用户的优先级仍旧维持普通优先级。<li>false：关闭抢占模式。抢占模式关闭时，如果房间中已有高优先级用户，则本地用户的高优先级设置不生效，仍旧为普通优先级。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * nertc::NERtcMediaPriorityType priority = nertc::kNERtcMediaPriorityNormal；
     * bool is_preemptive = false;
     * rtc_channel_->setLocalMediaPriority(priority, is_preemptive);
     * @endcode
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *         - 30005（kNERtcErrInvalidState）：状态错误，比如引擎尚未初始化或者已经加入房间。
     * @endif
     */
    virtual int setLocalMediaPriority(NERtcMediaPriorityType priority, bool is_preemptive) = 0;

    /** 
     * @if English
     * Gets the current channel connection status.
     * @since V4.5.0
     * @return Returns the current channel connection status. #NERtcConnectionStateType.
     * @endif
     * @if Chinese
     * 获取当前房间连接状态。
     * @since V4.5.0
     * @return 房间连接状态。#NERtcConnectionStateType.
     * @endif
     */
    virtual NERtcConnectionStateType getConnectionState() = 0;

    /**
     * @if English
     * Sets the camera capturer configuration.
     * <br>For a video call or live streaming, generally the SDK controls the camera output parameters. By default, the SDK matches the most appropriate resolution based on the user's setVideoConfig configuration. When the default camera capture settings do not meet special requirements, we recommend using this method to set the camera capturer configuration:
     * - If you want better quality for the local video preview, we recommend setting config as kNERtcCameraOutputQuality. The SDK sets the camera output parameters with higher picture quality
     * <p>@note 
     * - Call this method before or after joining the channel. The setting takes effect immediately without restarting the camera.
     * - Higher collection parameters means higher performance consumption, such as CPU and memory usage, especially when video pre-processing is enabled. 
     * @since V4.5.0
     * @param config The camera capturer configuration.
     * @return {@code 0} A value of 0 returned indicates that the method call is successful. Otherwise, the method call fails.
     * @endif
     * @if Chinese
     * 设置本地摄像头的视频主流采集配置。
     * <br>通过此接口可以设置本地摄像头采集的主流视频宽度、高度、旋转角度等。
     * @since V4.5.0
     * @par 调用时机  
     * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
     * @par 业务场景
     * 在视频通话或直播中，SDK 自动控制摄像头的输出参数。默认情况下，SDK 会根据用户该接口的配置匹配最合适的分辨率进行采集。但是在部分业务场景中，如果采集画面质量无法满足实际需求，可以调用该接口调整摄像头的采集配置。
     * @note 
     * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
     * - 该方法仅适用于视频主流，若您希望为辅流通道设置摄像头的采集配置，请调用 \ref nertc::IRtcChannel::setCameraCaptureConfig(NERtcVideoStreamType type, const NERtcCameraCaptureConfig& config)} "setCameraCaptureConfig" 方法。
     * - 该方法支持在加入房间后动态调用，设置成功后，会自动重启摄像头采集模块。
     * - 若系统相机不支持您设置的分辨率，会自动调整为最相近一档的分辨率，因此建议您设置为常规标准的分辨率。
     * - 设置较高的采集分辨率会增加性能消耗，例如 CPU 和内存占用等，尤其是在开启视频前处理的场景下。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>captureConfig</td>
     *      <td> \ref nertc::NERtcCameraCaptureConfig "NERtcCameraCaptureConfig"</td>
     *      <td>本地摄像头采集配置。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * nertc::NERtcCameraCaptureConfig capture_config;
     * capture_config.captureWidth = w;
     * capture_config.captureHeight = h;
     * if (rtc_channel_) {
     *     rtc_channel_->setCameraCaptureConfig(capture_config);
     * }
     * @endcode
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *        - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
     *        - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎未初始化成功。
     * @endif
     */
    virtual int setCameraCaptureConfig(const NERtcCameraCaptureConfig& config) = 0;

    /**
     * @if Chinese
     * 设置本地摄像头的视频主流或辅流采集配置。
     * <br>通过此接口可以设置本地摄像头采集的主流或辅流视频宽度、高度、旋转角度等。
     * @since V4.6.20
     * @par 调用时机  
     * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
     * @par 业务场景
     * 在视频通话或直播中，SDK 自动控制摄像头的输出参数。默认情况下，SDK 会根据用户该接口的配置匹配最合适的分辨率进行采集。但是在部分业务场景中，如果采集画面质量无法满足实际需求，可以调用该接口调整摄像头的采集配置。
     * @note 
     * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
     * - 调用该接口设置成功后，会自动重启摄像头采集模块。
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
     *      <td>视频通道类型：<ul><li>kNERtcVideoStreamMain：主流。<li>kNERtcVideoStreamSub：辅流。</td>
     *  </tr>
     *  <tr>
     *      <td>captureConfig</td>
     *      <td> \ref nertc::NERtcCameraCaptureConfig "NERtcCameraCaptureConfig"</td>
     *      <td>本地摄像头采集配置。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * //设置本地摄像头主流采集配置
     * nertc::NERtcVideoStreamType type = nertc::NERtcVideoStreamType::kNERTCVideoStreamMain;
     * nertc::NERtcVideoConfig video_config_ = {};
     * video_config_.captureWidth = 1920; // 编码分辨率的宽
     * video_config_.captureHeight = 1080; // 编码分辨率的高
     * rtc_channel_->setCameraCaptureConfig(type, video_config_);
     * //设置本地摄像头辅流采集配置
     * nertc::NERtcVideoStreamType type = nertc::NERtcVideoStreamType::kNERTCVideoStreamSub;
     * nertc::NERtcVideoConfig video_config_ = {};
     * video_config_.captureWidth = 1920; // 编码分辨率的宽
     * video_config_.captureHeight = 1080; // 编码分辨率的高
     * rtc_channel_->setCameraCaptureConfig(type, video_config_);
     * @endcode
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     * @endif
     */
    virtual int setCameraCaptureConfig(NERtcVideoStreamType type, const NERtcCameraCaptureConfig& config) = 0;

    /** 
     * @if English
     * Sets local video parameters.
     * @note
     * - You can call this method before or after you join the room.
     * - After the setting is configured, the setting takes effect the next time local video is enabled. 
     * - Each profile has a set of video parameters, such as resolution, frame rate, and bitrate. All the specified values of the parameters are the maximum values in optimal conditions. If the video engine cannot use the maximum value of resolution, due to poor network performance, the value closest to the maximum value is taken.
     * @param[in] config        Sets the video encoding parameters. For more information, see {@link NERtcVideoConfig}.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 设置视频编码属性。
     * <br>通过此接口可以设置视频主流的编码分辨率、裁剪模式、码率、帧率、带宽受限时的视频编码降级偏好、编码的镜像模式、编码的方向模式参数，详细信息请参考[设置视频属性](https://doc.yunxin.163.com/docs/jcyOTA0ODM/zYwMTQyNzE)。
     * @since V3.5.0
     * @par 调用时机  
     * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
     * @note
     * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
     * - 每个属性对应一套视频参数，例如分辨率、帧率、码率等。所有设置的参数均为理想情况下的最大值。当视频引擎因网络环境等原因无法达到设置的分辨率、帧率或码率的最大值时，会取最接近最大值的那个值。
     * - 此接口为全量参数配置接口，重复调用此接口时，SDK 会刷新此前的所有参数配置，以最新的传参为准。所以每次修改配置时都需要设置所有参数，未设置的参数将取默认值。
     * - 自 V4.5.0 版本起，此方法设置实时生效；此前的版本中，此方法设置成功后，下次开启本端视频时生效。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>config</td>
     *      <td> \ref nertc::NERtcVideoConfig "NERtcVideoConfig"</td>
     *      <td>视频编码属性配置。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * nertc::NERtcVideoConfig video_config_ = {};
     * video_config_.width = 1920; // 编码分辨率的宽
     * video_config_.height = 1080; // 编码分辨率的高
     * video_config_.mirror_mode = nertc::kNERtcVideoMirrorModeAuto; // 视频镜像模式
     * video_config_.orientation_mode = nertc::kNERtcVideoOutputOrientationModeAdaptative; // 视频旋转的方向模式。
     * video_config_.max_profile = nertc::kNERtcVideoProfileHD1080P; // 视频编码配置
     * video_config_.crop_mode_ = nertc::kNERtcVideoCropModeDefault;//裁剪模式
     * video_config_.bitrate = 0; // 视频编码的码率
     * video_config_.min_bitrate = 0;//视频编码的最小码率
     * video_config_.framerate = 30; // 视频编码的帧率
     * video_config_.min_framerate = 2;// 视频编码的最小帧率
     * video_config_.degradation_preference = nertc::kNERtcDegradationDefault;// 带宽受限时的视频编码降级偏好
     * rtc_channel_->setVideoConfig(video_config_);
     * @endcode
     * @par 相关接口
     * 若您希望为视频辅流通道设置编码属性，请调用 \ref nertc::IRtcChannel::setVideoConfig(NERtcVideoStreamType type, const NERtcVideoConfig& config) "setVideoConfig" 方法。
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30005（kNERtcErrInvalidState）：引擎尚未初始化。
     *      - 30300：Transiver 未找到。
     * @endif
     */
    virtual int setVideoConfig(const NERtcVideoConfig& config) = 0;

    /**
     * @if Chinese
     * 设置视频编码属性。
     * <br>通过此接口可以设置视频主流或辅流的编码分辨率、裁剪模式、码率、帧率、带宽受限时的视频编码降级偏好、编码的镜像模式、编码的方向模式参数。
     * @since V4.6.20
     * @par 调用时机  
     * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
     * @note
     * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
     * - 每个属性对应一套视频参数，例如分辨率、帧率、码率等。所有设置的参数均为理想情况下的最大值。当视频引擎因网络环境等原因无法达到设置的分辨率、帧率或码率的最大值时，会取最接近最大值的那个值。
     * - 此接口为全量参数配置接口，重复调用此接口时，SDK 会刷新此前的所有参数配置，以最新的传参为准。所以每次修改配置时都需要设置所有参数，未设置的参数将取默认值。
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
     *      <td>config</td>
     *      <td> \ref nertc::NERtcVideoConfig "NERtcVideoConfig"</td>
     *      <td>视频编码属性配置。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * nertc::NERtcVideoConfig video_config_ = {};
     * video_config_.width = 1920; // 编码分辨率的宽
     * video_config_.height = 1080; // 编码分辨率的高
     * video_config_.mirror_mode = nertc::kNERtcVideoMirrorModeAuto; // 视频镜像模式
     * video_config_.orientation_mode = nertc::kNERtcVideoOutputOrientationModeAdaptative; // 视频旋转的方向模式。
     * video_config_.max_profile = nertc::kNERtcVideoProfileHD1080P; // 视频编码配置
     * video_config_.crop_mode_ = nertc::kNERtcVideoCropModeDefault;//裁剪模式
     * video_config_.bitrate = 0; // 视频编码的码率
     * video_config_.min_bitrate = 0;//视频编码的最小码率
     * video_config_.framerate = 30; // 视频编码的帧率
     * video_config_.min_framerate = 2;// 视频编码的最小帧率
     * video_config_.degradation_preference = nertc::kNERtcDegradationDefault;// 带宽受限时的视频编码降级偏好
     * rtc_channel_->setVideoConfig(nertc::kNERTCVideoStreamMain, video_config_);
     * @endcode
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30005（kNERtcErrInvalidState）：引擎尚未初始化。
     *      - 30300：Transiver 未找到。
     * @endif
     */
    virtual int setVideoConfig(NERtcVideoStreamType type, const NERtcVideoConfig& config) = 0;

    /** 
     * @if English
     * Specifies whether to enable or disable the dual stream mode.
     * <br>The method sets the single-stream mode or dual-stream mode. If the dual-stream mode is enabled, the receiver can choose to receive the high-quality stream or low-quality stream video. The high-quality stream has a high resolution and high bitrate. The low-quality stream has a low resolution and low bitrate.
     * @note
     * - The method applies to camera data only. Video streams from external input and screen sharing are not affected.
     * - You can call this method before or after you join a room. After the method is set, it can take effect after restarting the camera.
     * @since V4.5.0
     * @param[in] enable        Whether to enable dual-stream mode.
     * - true: Enables the dual-stream mode. This is the default value.
     * - false: Disables the dual-stream mode. 
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 设置是否开启视频大小流模式。
     * <br> 
     * 通过本接口可以实现设置单流或者双流模式。发送端开启双流模式后，接收端可以选择接收大流还是小流。其中，大流指高分辨率、高码率的视频流，小流指低分辨率、低码率的视频流。
     * @since V3.5.0
     * @par 调用时机  
     * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
     * @note
     * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
     * - 该方法只对摄像头数据生效，对自定义输入、屏幕共享等视频流无效。
     * - 该接口的设置会在摄像头重启后生效。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>enable</td>
     *      <td>boolean</td>
     *      <td>是否开启双流模式：<ul><li>true：开启双流模式。<li>false：关闭双流模式。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * rtc_channel->enableDualStreamMode(true);
     * @endcode
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *         - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未初始化。
     * @endif
     */
    virtual int enableDualStreamMode(bool enable) = 0;

    /** 
     * @if English
     * Unsubscribes from or subscribes to audio streams from specified remote users.
     * <br>After a user joins a channel, audio streams from all remote users are subscribed by default. You can call this method to unsubscribe from or subscribe to audio streams from all remote users.
     * @note  When the kNERtcKeyAutoSubscribeAudio is enabled by default, users cannot manually modify the state of audio subscription.
     * @since V4.5.0
     * @param[in] uid           The user ID.
     * @param[in] subscribe     
     * - true: Subscribes to specified audio streams (default).
     * - false: Unsubscribes from specified audio streams.
     *  @return
     * - 0: Success.
     * - 30005: State exception that is caused by the invalid interface if users enable the automatic subscription. 
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 取消或恢复订阅所有远端用户的音频主流。
     * <br>加入房间时，默认订阅所有远端用户的音频主流，即 \ref nertc::IRtcEngineEx::setParameters "setParameters" 方法的 KEY_AUTO_SUBSCRIBE_AUDIO 参数默认设置为 true；只有当该参数的设置为 false 时，此接口的调用才会生效。
     * @since V4.5.0
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
     * @par 业务场景
     * 适用于重要会议需要一键全体静音的场景。
     * @note
     * 设置该方法的 subscribe 参数为 true 后，对后续加入房间的用户同样生效。
     * 在开启自动订阅（默认）时，设置该方法的 subscribe 参数为 false 可以实现取消订阅所有远端用户的音频流，但此时无法再调用 \ref nertc::IRtcChannel::subscribeRemoteAudioStream "subscribeRemoteAudioStream" 方法单独订阅指定远端用户的音频流。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>subscribe</td>
     *      <td>bool</td>
     *      <td>是否订阅所有用户的音频主流：<ul><li>true：订阅音频主流。<li>false：取消订阅音频主流。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * //订阅所有远端用户的音频主流
     * rtc_channel_->subscribeAllRemoteAudioStream(true);
     * //取消订阅所有远端用户的音频主流
     * rtc_channel_->subscribeAllRemoteAudioStream(false);
     * @endcode
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30005（kNERtcErrInvalidState）：引擎尚未初始化或尚未加入房间。
     *      - 30008（kNERtcErrDeviceNotFound：设备未找到。
     *      - 30015（kNERtcErrConnectFail )：服务器连接错误。
     *      - 30101（kNERtcErrChannelNotJoined)：尚未加入房间。
     *      - 30105（kNERtcErrUserNotFound）：未找到指定用户。
     *      - 30106（kNERtcErrInvalidUserID）：非法指定用户，比如订阅了本端。
     *      - 30200（kNERtcErrConnectionNotFound）：未连接成功。
     * @endif
     */
    virtual int subscribeRemoteAudioStream(uid_t uid, bool subscribe) = 0;

    /**
     * @if English
     * Subscribes or unsubscribes audio streams from specified remote users.
     * <br>After a user joins a room, audio streams from all remote users are subscribed by default. You can call this method to subscribe or unsubscribe audio streams from all remote users.
     * @note 
     * - This method can be called only if a user joins a room.
     * - If kNERtcKeyAutoSubscribeAudio is enabled by default, users do not need to edit the subscription state.
     * @since V4.6.10
     * @param[in] uid       indicates the user ID.
     * @param[in] subscribe specifies whether to subscribe specified audio streams.
     *                      - true: subscribes audio steams. This is the default value.
     *                      - false: unsubscribes audio streams.
     * @return
     * - 0: success
     * - Others: failure
     * @endif
     * @if Chinese
     * 设置是否订阅指定远端用户的音频辅流。
     * @since V4.6.10
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间且收到远端用户开启音频辅流的回调 \ref nertc::IRtcChannelEventHandler::onUserSubStreamAudioStart "onUserSubStreamAudioStart" 后调用。
     * @note
     * - 加入房间时，默认订阅所有远端用户的音频流。
     * - 请在指定远端用户加入房间后再调用此方法。
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
     *      <td>远端用户 ID。</td>
     * </tr>
     *  <tr>
     *      <td>subscribe</td>
     *      <td>bool</td>
     *      <td>是否订阅指定音频辅流：<ul><li>true：订阅指定音频辅流。<li>false：取消订阅指定音频辅流。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * //订阅对方音频辅流
     * rtc_channel_->subscribeRemoteSubStreamAudio(uid, true);
     * //取消订阅对方音频辅流
     * rtc_channel_->subscribeRemoteSubStreamAudio(uid, false);
     * @endcode
     * @return 
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *         - 30005（kNERtcErrInvalidState）：状态错误，比如引擎未初始化。
     *         - 30101（kNERtcErrChannelNotJoined)：尚未加入房间。
     *         - 30105（kNERtcErrUserNotFound）：指定用户尚未加入房间。
     *         - 30106（kNERtcErrInvalidUserID）：非法的用户 ID。
     *         - 30200（kNERtcErrConnectionNotFound）：媒体会话未建立，比如指定用户尚未发布音频辅流。
     * @endif
     */
    virtual int subscribeRemoteSubStreamAudio(uid_t uid, bool subscribe) = 0;

    /**
     * @if English
     * Unsubscribes or subscribes to audio streams from all remote users.
     * @note
     * - Call this method before or after joining the channel.
     * @since V4.5.0
     * @param subscribe Whether to unsubscribe audio streams from all remote users.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 取消或恢复订阅所有远端用户的音频主流。
     * <br>加入房间时，默认订阅所有远端用户的音频主流，即 \ref nertc::IRtcEngineEx::setParameters "setParameters" 方法的 KEY_AUTO_SUBSCRIBE_AUDIO 参数默认设置为 true；只有当该参数的设置为 false 时，此接口的调用才会生效。
     * @since V4.5.0
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
     * @par 业务场景
     * 适用于重要会议需要一键全体静音的场景。
     * @note
     * - 设置该方法的 subscribe 参数为 true 后，对后续加入房间的用户同样生效。
     * - 在开启自动订阅（默认）时，设置该方法的 subscribe 参数为 false 可以实现取消订阅所有远端用户的音频流，但此时无法再调用 \ref nertc::IRtcEngineEx::subscribeRemoteAudioStream "subscribeRemoteAudioStream" 方法单独订阅指定远端用户的音频流。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>subscribe</td>
     *      <td>bool</td>
     *      <td>是否订阅所有用户的音频主流：<ul><li>true：订阅音频主流。<li>false：取消订阅音频主流。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * //订阅所有远端用户的音频主流
     * rtc_channel_->subscribeAllRemoteAudioStream(true);
     * //取消订阅所有远端用户的音频主流
     * rtc_channel_->subscribeAllRemoteAudioStream(false);
     * @endcode
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *      - 30005（kNERtcErrInvalidState)：引擎未初始化。
     *      - 30026：ASL 选路功能启用失败。
     *      - 30400：Transceiver 未找到。
     * @endif
     */
    virtual int subscribeAllRemoteAudioStream(bool subscribe) = 0;

    /**
     * @if English
     * Sets the local audio stream can be subscribed by specified participants in a room.
     * <br>All participants in the room can subscribe to the local audio stream by default.
     * @note
     *  - The API must be called after a user joins a room.
     *  - The API cannot be called by user IDs out of the room.
     * @since V4.6.10
     * @param[in] uidArray The list of user IDs that can subscribe to the local audio stream.
     * @note The list contains all participants in a room. If the value is empty or null, all participants can subscribe to the local audio stream.
     * @param[in] size The length of the uid_array array.
     * @return
     * - 0: success
     * - Others: failure.
     * @endif
     * @if Chinese
     * 设置自己的音频只能被房间内指定的人订阅。
     * <br>默认房间所有其他人都可以订阅自己的音频。
     * @note
     *  - 此接口需要在加入房间成功后调用。
     *  - 对于调用接口时不在房间的 uid 不生效。
     * @since V4.6.10
     * @param[in] uid_array 可订阅自己音频的用户uid 列表。
     *                      @note 此列表为全量列表。如果列表为空或 null，表示其他所有人均可订阅自己的音频。
     * @param[in] size uid_array 的数组长度。
     * @return
     * - 0：方法调用成功。
     * - 其他：方法调用失败。
     * @endif
     */
    virtual int setAudioSubscribeOnlyBy(uid_t* uid_array, uint32_t size) = 0;

    /**
     * @if Chinese
     * 你可以调用该方法指定只订阅的音频流。
     * @note
     *  - 此接口需要在加入房间成功后调用。
     *  - 对于调用接口时不在房间的 uid 不生效。
     * @since V5.4.101
     * @param[in] uid_array 只订阅此 用户uid列表 的音频。
     *                      @note 此列表为全量列表。如果列表为空或 null，取消订阅白名单。
     * @param[in] size uid_array 的数组长度。
     * @return
     * - 0：方法调用成功。
     * - 其他：方法调用失败。
     * @endif
     */
    virtual int setSubscribeAudioAllowlist(uid_t* uid_array, uint32_t size) = 0;

    /**
     * @if Chinese
     * 你可以调用该方法指定不订阅的音频流。
     * @note
     *  - 此接口需要在加入房间成功后调用。
     *  - 对于调用接口时不在房间的 uid 不生效。
     * @since V5.4.101
     * @param[in] uid_array 不订阅此 用户uid列表 的音频。
     *                      @note 此列表为全量列表。如果列表为空或 null，取消订阅黑名单。
     * @param[in] size uid_array 的数组长度。
     * @return
     * - 0：方法调用成功。
     * - 其他：方法调用失败。
     * @endif
     */
    virtual int setSubscribeAudioBlocklist(NERtcAudioStreamType type, uid_t* uid_array, uint32_t size) = 0;

    /** 
     * @if English
     * Subscribes or unsubscribes video streams from specified remote users.
     * - After a user joins a room, the video streams from remote users are not subscribed by default. If you want to view video streams from specified remote users, you can call this method to subscribe to the video streams from the user when the user joins the room or publishes the video streams.
     * - This method can be called only if a user joins a room.
     * @since V4.5.0
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
     * rtc_channel_->subscribeRemoteVideoStream(12345, nertc::kNERtcRemoteVideoStreamTypeHigh,true);
     * @endcode
     * @par 相关接口
     * 若您希望订阅指定远端用户的视频辅流，请调用 \ref nertc::IRtcChannel::subscribeRemoteVideoSubStream "subscribeRemoteVideoSubStream"} 方法。
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

    /** 
     * @if English
     * Subscribes to or unsubscribes from remote substream video from screen sharing. You can receive the substream video data only after you subscribe to remote substream video stream.
     * @note 
     * - You must call the method after joining a room.
     * - You must first set a remote substream canvas.
     * @since V4.5.0
     * @param[in] uid           The user ID.
     * @param[in] subscribe
     * - true: Subscribes to or unsubscribes from video streams from specified remote users.
     * - false: Unsubscribes from video streams of specified remote users.  
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * 
     * @endif
     * @if Chinese
     * 订阅或取消订阅远端用户的视频辅流。
     * @since V3.9.0
     * @par 使用前提
     * - 请先调用 \ref nertc::IRtcChannel::setupRemoteSubStreamVideoCanvas "setupRemoteSubStreamVideoCanvas" 设置远端用户的视频辅流画布。
     * - 建议在收到远端用户发布视频辅流的回调通知 \ref nertc::IRtcChannelEventHandler::onUserSubStreamVideoStart "onUserSubStreamVideoStart" 后调用此接口。
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
     * @note 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
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
     *      <td>远端用户 ID。</td>
     *  </tr>
     *  <tr>
     *      <td>subsribe</td>
     *      <td>bool</td>
     *      <td>是否订阅远端的视频辅流：<ul><li>true：订阅远端视频辅流。<li>false：取消订阅远端视频辅流。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * if(rtc_channel_) {
     * nertc::NERtcVideoCanvas canvas;
     * canvas.window = window;
     * rtc_channel_->setupRemoteSubStreamVideoCanvas(uid, canvas);
     * rtc_channel_->subscribeRemoteVideoSubStream(uid, true);
     * }
     * @endcode
     * @par 相关回调
     * - \ref nertc::IRtcChannelEventHandler::onUserSubStreamVideoStart "onUserSubStreamVideoStart" ：远端用户发布视频辅流的回调。
     * - \ref nertc::IRtcChannelEventHandler::onUserSubStreamVideoStop "onUserSubStreamVideoStop"：远端用户停止发布视频辅流的回调。
     * @return 
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *         - 30004（kNERtcErrNotSupported）：不支持的操作。
     *         - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未初始化。
     *         - 30105（kNERtcErrUserNotFound）：未找到该远端用户，可能对方还未加入房间。
     * @endif
     */
    virtual int subscribeRemoteVideoSubStream(uid_t uid, bool subscribe) = 0;

    /** 
     * @if English
     * After the method is successfully called, the current user can receive the notification about the status of the live stream.
     * @note
     * - The method is applicable to only live streaming.
     * - You can call the method in a room. The method is valid in calls.
     * - Only one address for the relayed stream is added in each call. You need to call the method for multiple times if you want to push many streams. An RTC room with the same channelid can create three different streaming tasks.
     * - After the method is successfully called, the current user will receive related-status notifications of the live stream. 
     * @since V4.5.0
     * @param[in] info indicates information of live task. For more information, see \ref NERtcLiveStreamTaskInfo "NERtcLiveStreamTaskInfo". 
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 添加房间内推流任务。
     * 通过此接口可以实现增加一路旁路推流任务；若需推送多路流，则需多次调用该方法。
     * @since V3.5.0
     * @par 使用前提
     * 请先通过 \ref nertc::IRtcEngine::setChannelProfile "setChannelProfile" 接口设置房间模式为直播模式。
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
     * @note
     * - 仅角色为主播的房间成员能调用此接口，观众成员无相关推流权限。
     * - 同一个音视频房间（即同一个 channelId）可以创建 6 个不同的推流任务。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>info</td>
     *      <td>\ref nertc::NERtcLiveStreamTaskInfo "NERtcLiveStreamTaskInfo"</td>
     *      <td>推流任务信息。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * NERtcLiveStreamTaskInfo info;
     * strncpy(info.task_id, "task1", kNERtcMaxTaskIDLength);
     * strncpy(info.stream_url, "rtmp://pxxxxxx.live.126.net/live/xxxxxx", kNERtcMaxURILength);
     * info.ls_mode = kNERtcLsModeVideo;
     * info.server_record_enabled = false;
     * //扩展推流信息info.config.single_video_passthrough = false;
     * info.config.audio_bitrate = 64;
     * info.config.audioCodecProfile = nertc::kNERtcLiveStreamAudioCodecProfileLCAAC;
     * info.config.channels = 2;
     * info.config.sampleRate = nertc::kNERtcLiveStreamAudioSampleRate48000;
     * //流基础信息info.layout.background_color = 0;
     * info.layout.width = 1280;
     * info.layout.height = 720;
     * info.layout.bg_image = nullptr;
     * //流成员信息
     * info.layout.user_count = 2;
     * info.layout.users = new NERtcLiveStreamUserTranscoding[info.layout.user_count];
     * for (unsigned int i = 0; i < info.layout.user_count; i++) {
     * info.layout.users[i].uid = 0;
     * info.layout.users[i].adaption = kNERtcLsModeVideoScaleFit;
     * info.layout.users[i].video_push = true;
     * info.layout.users[i].x = 0;
     * info.layout.users[i].y = 0;
     * info.layout.users[i].width = 640;
     * info.layout.users[i].height = 480;
     * info.layout.users[i].audio_push = true;
     * info.layout.users[i].z_order = 0;
     * }
     * if (rtc_channel_) {
     * int res = rtc_channel_->addLiveStreamTask(info);
     * }
     * delete[] info.layout.users;
     * @endcode
     * @par 相关回调
     * \ref nertc::IRtcChannelEventHandler::onAddLiveStreamTask "onAddLiveStreamTask"：推流任务已成功添加回调。
     * \ref nertc::IRtcChannelEventHandler::onLiveStreamState "onAddLiveStreamTask"：推流任务状态已改变回调。
     * @return 
     * - 0（kNERtcNoError）：方法调用成功；
     * - 其他：方法调用失败。
     *         - 403（kNERtcErrChannelReservePermissionDenied）：权限不足，观众模式下不支持此操作。
     *         - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未初始化。
     *         - 30101（kNERtcErrChannelNotJoined）：尚未加入房间。
     * @endif
     */
    virtual int addLiveStreamTask(const NERtcLiveStreamTaskInfo& info) = 0;

    /** 
     * @if English
     * Updates and modifies a push task in a room. 
     * @note
     * - The method is applicable to only live streaming.
     * - You can call the method in a room. The method is valid in calls.
     * @since V4.5.0
     * @param[in] info indicates information of live task. For more information, see \ref NERtcLiveStreamTaskInfo "NERtcLiveStreamTaskInfo".
     * @return 
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 更新房间内指定推流任务。
     * 通过此接口可以实现调整指定推流任务的编码参数、画布布局、推流模式等。
     * @since V3.5.0
     * @par 使用前提
     * 请先调用 \ref nertc::IRtcChannel::addLiveStreamTask "addLiveStreamTask"} 方法添加推流任务。
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
     * @note
     * 仅角色为主播的房间成员能调用此接口，观众成员无相关推流权限。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>info</td>
     *      <td>\ref nertc::NERtcLiveStreamTaskInfo "NERtcLiveStreamTaskInfo"</td>
     *      <td>推流任务信息。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * if (rtc_channel_) {
     *     return rtc_channel_->updateLiveStreamTask(info);
     * }
     * @endcode
     * @par 相关回调
     * \ref nertc::IRtcChannelEventHandler::onUpdateLiveStreamTask "onUpdateLiveStreamTask"：推流任务已成功更新回调。
     * \ref nertc::IRtcChannelEventHandler::onLiveStreamState "onAddLiveStreamTask"：推流任务状态已改变回调。
     * @return 
     * - 0（kNERtcNoError）：方法调用成功；
     * - 其他：方法调用失败。
     *         - 403（kNERtcErrChannelReservePermissionDenied）：权限不足，观众模式下不支持此操作。
     *         - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未初始化。
     *         - 30101（kNERtcErrChannelNotJoined）：尚未加入房间。
     * @endif
     */
    virtual int updateLiveStreamTask(const NERtcLiveStreamTaskInfo& info) = 0;

    /** 
     * @if English
     * Deletes a push task.
     * @note
     * - The method is applicable to only live streaming.
     * - You can call the method in a room. The method is valid in calls.
     * - When calls stop and all members in the room leave the room, the SDK automatically deletes the streaming task. If some users are still in the room, users who create the streaming task need to delete the streaming task. 
     * @since V4.5.0
     * @param[in] task_id  The ID of a live streaming task.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 删除房间内指定推流任务。
     * @since V3.5.0
     * @par 使用前提
     * 请先调用 \ref nertc::IRtcChannel::addLiveStreamTask "addLiveStreamTask" 方法添加推流任务。
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
     * @note
     * - 仅角色为主播的房间成员能调用此接口，观众成员无相关推流权限。
     * - 通话结束，房间成员全部离开房间后，推流任务会自动删除；如果房间内还有用户存在，则需要创建推流任务的用户删除推流任务。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>task_id</td>
     *      <td>const char*</td>
     *      <td>推流任务 ID。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * if (rtc_channel_) {
     *     return rtc_channel_->removeLiveStreamTask(task_id);
     * }
     * @endcode
     * @par 相关回调
     * \ref nertc::IRtcChannelEventHandler::onRemoveLiveStreamTask "onRemoveLiveStreamTask"：推流任务已成功删除回调。
     * \ref nertc::IRtcChannelEventHandler::onLiveStreamState "onLiveStreamState"：推流任务状态已改变回调。
     * @return 
     * - 0（kNERtcNoError）：方法调用成功；
     * - 其他：方法调用失败。
     *         - 403（kNERtcErrChannelReservePermissionDenied）：权限不足，观众模式下不支持此操作。
     *         - 30005（kNERtcErrChannelNotJoined）：状态错误，比如引擎尚未初始化。
     *         - 30101（kNERtcErrChannelNotJoined）：尚未加入房间。
     * @endif
     */
    virtual int removeLiveStreamTask(const char* task_id) = 0;

	/** 
     * @if English
     * Sends SEI messages.
     * <br>While the local video stream is pushed, SEI data is also sent to sync some additional information. After SEI data is sent, the receiver can retrieve the content by listening on \ref IRtcEngineEventHandlerEx::onRecvSEIMsg callback.  
     * - Condition: After the video stream (mainstream) is enabled, the function can be invoked.
     * - Data size limits: The SEI data can contain a maximum of 4,096 bytes in size. Sending an SEI message fails if the data exceeds the size limit. If a large amount of data is sent, the video bitrate rises. This degrades the video quality or causes broken video frames.
     * - Frequency limit: we recommend that the maximum video frame rate does not exceed 10 fps.  
     * - Time to take effect: After the method is called, the SEI data is sent from the next frame in the fastest fashion or after the next 5 frames at the slowest pace.
     * <p>@note
     * - The SEI data is transmitted together with the video stream. Frame loss may occur in poor network connection. The SEI data will also get lost. We recommend that you send the data many times within the transmission frequency limits. In this way, the receiver can get the data.
     * - By default, the SEI is transmitted by using the mainstream channel. 
     * @since V4.5.0
     * @param data      The custom SEI frame data.
     * @param length    The custom SEI data size whose maximum value does not exceed 4096 bytes. 
     * @param type      The type of the stream channel with which the SEI data is transmitted. For more information, see #NERtcVideoStreamType. 
     * @return The value returned. A value of 0 That the operation is successful.
     * - Success: Successfully joins the queue to be sent. The data are sent after the closest video frame. 
     * - failure: Date are limitedly sent for the high sent frequency and the overloaded queue. Or, the maximum data size exceeds 4k.
     * @endif
     * @if Chinese
     * 发送媒体补充增强信息（SEI）。
     * <br>在本端推流传输视频流数据同时，发送流媒体补充增强信息来同步一些其他附加信息。当推流方发送 SEI 后，拉流方可通过监听 \ref IRtcEngineEventHandlerEx::onRecvSEIMsg 的回调获取 SEI 内容。
     * - 调用时机：视频流（主流）开启后，可调用此函数。
     * - 数据长度限制： SEI 最大数据长度为 4096 字节，超限会发送失败。如果频繁发送大量数据会导致视频码率增大，可能会导致视频画质下降甚至卡顿。
     * - 发送频率限制：最高为视频发送的帧率，建议不超过 10 次/秒。
     * - 生效时间：调用本接口之后，最快在下一帧视频数据帧之后发送 SEI 数据，最慢在接下来的 5 帧视频之后发送。
     * <p>@note
     * - SEI 数据跟随视频帧发送，由于在弱网环境下可能丢帧，SEI 数据也可能随之丢失，所以建议在发送频率限制之内多次发送，保证接收端收到的概率。
     * - 调用本接口时，默认使用主流通道发送 SEI。
     * @since V4.5.0
     * @param data      自定义 SEI 数据。
     * @param length    自定义 SEI 数据长度，最大不超过 4096 字节。
     * @param type      发送 SEI 时，使用的流通道类型。详细信息请参考 #NERtcVideoStreamType 。
     * @return 操作返回值，成功则返回 0
     * - 成功:  成功进入待发送队列，会在最近的视频帧之后发送该数据
     * - 失败:  数据被限制发送，可能发送的频率太高，队列已经满了，或者数据大小超过最大值 4k
	 * @endif
	 */
    virtual int sendSEIMsg(const char* data, int length, NERtcVideoStreamType type) = 0;

	/** 
     * @if English
     * Sends SEI messages.
     * <br>While the local video stream is pushed, SEI data is also sent to sync some additional information. After SEI data is sent, the receiver can retrieve the content by listening on \ref IRtcEngineEventHandlerEx::onRecvSEIMsg callback.
     * - Condition: After the video stream (mainstream) is enabled, the function can be invoked.
     * - Data size limits: The SEI data can contain a maximum of 4,096 bytes in size. Sending an SEI message fails if the data exceeds the size limit. If a large amount of data is sent, the video bitrate rises. This degrades the video quality or causes video frames freezes.
     * - Frequency limit: we recommend that the maximum video frame rate does not exceed 10 fps. 
     * - Time to take effect: After the method is called, the SEI data is sent from the next frame in the fastest fashion or after the next 5 frames at the slowest pace.
     * <p>@note
     * - The SEI data is transmitted together with the video stream. Frame loss may occur in poor network connection. The SEI data will also get lost. We recommend that you send the data many times within the transmission frequency limits. In this way, the receiver can get the data.
     * - By default, the SEI is transmitted by using the mainstream channel.
     * @since V4.5.0
     * @param data      The custom SEI frame data.
     * @param length    The custom SEI data size whose maximum value does not exceed 4096 bytes.
     * @note            The API is disabled in the audio-only SDK. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
     * @return The value returned. A value of 0 That the operation is successful.
     * - Success: Successfully joins the queue to be sent. The data are sent after the closest video frame.
     * - Failure: Date are limitedly sent for the high sent frequency, the overloaded queue and the maximum data size exceeding 4k.
     * @endif
     * @if Chinese
     * 发送媒体补充增强信息（SEI）。
     * 在本端推流传输视频流数据同时，发送流媒体补充增强信息来同步一些其他附加信息。当推流方发送 SEI 后，拉流方可通过监听 \ref IRtcEngineEventHandlerEx::onRecvSEIMsg 的回调获取 SEI 内容。
     * - 调用时机：视频流（主流）开启后，可调用此函数。
     * - 数据长度限制： SEI 最大数据长度为 4096 字节，超限会发送失败。如果频繁发送大量数据会导致视频码率增大，可能会导致视频画质下降甚至卡顿。
     * - 发送频率限制：最高为视频发送的帧率，建议不超过 10 次/秒。
     * - 生效时间：调用本接口之后，最快在下一帧视频数据帧之后发送 SEI 数据，最慢在接下来的 5 帧视频之后发送。
     * <p>@note
     * - SEI 数据跟随视频帧发送，由于在弱网环境下可能丢帧，SEI 数据也可能随之丢失，所以建议在发送频率限制之内多次发送，保证接收端收到的概率。
     * - 调用本接口时，默认使用主流通道发送 SEI。
     * @since V4.5.0
     * @param data      自定义 SEI 数据。
     * @param length    自定义 SEI 数据长度，最大不超过 4096 字节。
     * @note 纯音频SDK禁用该接口，如需使用请前往云信官网下载并替换成视频SDK
     * @return 操作返回值，成功则返回 0
     * - 成功:  成功进入待发送队列，会在最近的视频帧之后发送该数据
     * - 失败:  数据被限制发送，可能发送的频率太高，队列已经满了，或者数据大小超过最大值 4k
	 * @endif
	 */
	virtual int sendSEIMsg(const char* data, int length) = 0;

	/** 
     * @if English
     * Takes a local video snapshot.
     * <br>The takeLocalSnapshot method takes a local video snapshot on the local substream or local mainstream, and call \ref NERtcTakeSnapshotCallback "NERtcTakeSnapshotCallback::onTakeSnapshotResult" callback to return data of snapshot screen.
     * @note
     * - Before you call the method to capture the snapshot from the mainstream, you must first call startVideoPreview or enableLocalVideo, and joinChannel.
     * - Before you call the method to capture the snapshot from the substream, you must first call startScreenCapture, and joinChannel. 
     * - You can set text, timestamp, and image watermarks at the same time. If different types of watermarks overlap, the layers override previous layers following image, text, and timestamp.
     * @since V4.5.0
     * @param stream_type       The video stream type of the snapshot. You can set the value to mainstream or substream. For more information, see #NERtcVideoStreamType.
     * @param callback          The snapshot callback. For information, see \ref NERtcTakeSnapshotCallback.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 本地视频画面截图。
     * <br>调用 takeLocalSnapshot 截取本地主流或本地辅流的视频画面，并通过 \ref NERtcTakeSnapshotCallback "NERtcTakeSnapshotCallback::onTakeSnapshotResult" 回调返回截图画面的数据。
     * @note
     * - 本地主流截图，需要在 startPreview 或者 enableLocalVideo 并 joinChannel 成功之后调用。
     * - 本地辅流截图，需要在 startScreenCapture 并 joinChannel 成功之后调用。
     * - 同时设置文字、时间戳或图片水印时，如果不同类型的水印位置有重叠，会按照图片、文本、时间戳的顺序进行图层覆盖。
     * @since V4.5.0
     * @param stream_type       截图的视频流类型。支持设置为主流或辅流。详细信息请参考 #NERtcVideoStreamType 。
     * @param callback          截图回调。详细信息请参考 \ref NERtcTakeSnapshotCallback 。
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
	 * @endif
	 */
	virtual int takeLocalSnapshot(NERtcVideoStreamType stream_type, NERtcTakeSnapshotCallback *callback) = 0;

	/** 
     * @if English
     * Takes a snapshot of a remote video.
     * <br>You can call takeRemoteSnapshot to specify the uid of video screen of remote mainstreams and substreams, and returns screenshot data of \ref NERtcTakeSnapshotCallback "NERtcTakeSnapshotCallback::onTakeSnapshotResult" callback.
     * @note
     * - You need to call takeRemoteSnapshot after receiving callbacks of onUserVideoStart and onUserSubStreamVideoStart.
     * - You can set text, timestamp, and image watermarks at the same time. If different types of watermarks overlap, the layers override previous layers following image, text, and timestamp.
     * @since V4.5.0
     * @param uid           The ID of a remote user.
     * @param stream_type   The video stream type of the snapshot. You can set the value to mainstream or substream. For more information, see #NERtcVideoStreamType.
     * @param callback      The snapshot callback. For information, see \ref NERtcTakeSnapshotCallback.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 远端视频画面截图。
     * <br>调用 takeRemoteSnapshot 截取指定 uid 远端主流和远端辅流的视频画面，并通过 \ref NERtcTakeSnapshotCallback "NERtcTakeSnapshotCallback::onTakeSnapshotResult" 回调返回截图画面的数据。
     * @note
     * - takeRemoteSnapshot 需要在收到 onUserVideoStart 与 onUserSubStreamVideoStart 回调之后调用。
     * - 同时设置文字、时间戳或图片水印时，如果不同类型的水印位置有重叠，会按照图片、文本、时间戳的顺序进行图层覆盖。
     * @since V4.5.0
     * @param uid           远端用户 ID。
     * @param stream_type   截图的视频流类型。支持设置为主流或辅流。详细信息请参考 #NERtcVideoStreamType 。
     * @param callback      截图回调。详细信息请参考 \ref NERtcTakeSnapshotCallback 。
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
	 * @endif
	 */
	virtual int takeRemoteSnapshot(uid_t uid, NERtcVideoStreamType stream_type, NERtcTakeSnapshotCallback *callback) = 0;

    /** 
     * @if English
     * Adjusts the volume of local signal playback from a specified remote user.
     * <br>After you join the room, you can call the method to adjust the volume of local audio playback from different remote users or repeatedly adjust the volume of audio playback from a specified remote user.  
     * @note 
     * - You can call this method after joining a room.
     * - The method is valid in the current call. If a remote user exits the room and rejoins the room again, the setting is still valid until the call ends.
     * - The method adjusts the volume of the mixing audio published by a specified remote user. The volume of one remote user can be adjusted. If you want to adjust multiple remote users, you need to call the method for the required times.
     * @since V4.5.0
     * @param uid    The ID of a remote user.
     * @param volume Playback volume: 0 to 100. 
                    - 0: Mute.
                    - 100: The original volume.
                    - 400: The maximum value can be four times the original volume. The limit value is protected
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 调节本地播放的指定远端用户的信号音量。
     * <br>通过此接口可以实现在通话过程中随时调节指定远端用户在本地播放的混音音量。
     * @since V4.2.1
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
     * @note
     * - 该方法设置内部引擎为启用状态，在 leaveChannel 后失效，但在本次通话过程中有效，比如指定远端用户中途退出房间，则再次加入此房间时仍旧维持该设置。
     * - 该方法每次只能调整一位远端用户的播放音量，若需调整多位远端用户在本地播放的音量，则需多次调用该方法。
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
     *      <td>远端用户 ID。</td>
     * </tr>
     *  <tr>
     *      <td>volume</td>
     *      <td>int</td>
     *      <td>播放音量，取值范围为 0 ~ 400。<ul><li>0：静音。<li>100（默认）：原始音量。<li>400：最大音量值（自带溢出保护）。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * //调整uid为12345的用户在本地的播放音量为50
     * rtc_channel_->adjustUserPlaybackSignalVolume(12345, 50);
     * //调整uid为12345的用户在本地的播放音量为0，静音该用户。
     * rtc_channel_->adjustUserPlaybackSignalVolume(12345, 0);
     * @endcode
     * @return 
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *         - 30005（kNERtcErrInvalidState）：状态错误，比如引擎未初始化。
     * @endif
     */
    virtual int adjustUserPlaybackSignalVolume(uid_t uid, int volume) = 0;

    /**
     * @if Chinese
     * 调节本地播放的指定房间的所有远端用户的信号音量。
     * <br>通过此接口可以实现在通话过程中随时调节指定房间内的所有远端用户在本地播放的混音音量。
     * @since V4.6.50
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
     * @note
     * - 该方法设置内部引擎为启用状态，在 leaveChannel 后失效，但在本次通话过程中有效
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>volume</td>
     *      <td>uint64_t</td>
     *      <td>播放音量，取值范围为 [0,400]。<ul><li>0：静音。<li>100：原始音量。<li>400：最大可为原始音量的 4
     * 倍（自带溢出保护）。</td>
     *  </tr>
     * </table>
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *         - 30005（kNERtcErrInvalidState）：状态错误。
     * @endif
     */
    virtual int adjustChannelPlaybackSignalVolume(uint32_t volume) = 0;
    
    /** 
     * @if English
     * Starts to relay media streams across rooms.
     * - The method can invite co-hosts across rooms. Media streams from up to four rooms can be relayed. A room can receive multiple relayed media streams.
     * - After you call this method, the SDK triggers `onMediaRelayStateChanged` and `onMediaRelayEvent`. The return reports the status and events about the current relayed media streams across rooms.
     * @note 
     * - You can call this method after joining a room. Before you call the method, you must set the destination room in the `NERtcChannelMediaRelayConfiguration` parameter in `dest_infos`.
     * - The method is applicable only to the host in live streaming.
     * - If you want to call the method again, you must first call the `stopChannelMediaRelay` method to exit the current relaying status.
     * - If you succeed in relaying the media stream across rooms, and want to change the destination room, for example, add or remove the destination room, you can call `updateChannelMediaRelay` to update the information about the destination room.
     * @since V4.5.0
     * @param config specifies the configuration for the media stream relay across rooms. For more information, see #NERtcChannelMediaRelayConfiguration.
     * @return {@code 0} A value of 0 returned indicates that the method call is successful. Otherwise, the method call fails.
     * @endif
     * @if Chinese
     * 开始跨房间媒体流转发。
     * - 该方法可用于实现跨房间连麦等场景。支持同时转发到 4 个房间，同一个房间可以有多个转发进来的媒体流。
     * - 成功调用该方法后，SDK 会触发 `onMediaRelayStateChanged` 和 `onMediaRelayEvent` 回调，并在回调中报告当前的跨房间媒体流转发状态和事件。
     * @note
     * - 请在成功加入房间后调用该方法。调用此方法前需要通过 `NERtcChannelMediaRelayConfiguration` 中的 `dest_infos` 设置目标房间。
     * - 该方法仅对直播场景下的主播角色有效。
     * - 成功调用该方法后，若您想再次调用该方法，必须先调用 `stopChannelMediaRelay` 方法退出当前的转发状态。
     * - 成功开始跨房间转发媒体流后，如果您需要修改目标房间，例如添加或删减目标房间等，可以调用方法 `updateChannelMediaRelay` 更新目标房间信息。
     * @since V4.5.0
     * @param config 跨房间媒体流转发参数配置信息。
     * @return 成功返回0，其他则失败
     * @endif
     */
    virtual int startChannelMediaRelay(NERtcChannelMediaRelayConfiguration* config) = 0;

    /** 
     * @if English
     * Updates the information of the destination room for the media stream relay.
     * <br>You can call this method to relay the media stream to multiple rooms or exit the current room.
     * - You can call this method to change the destination room, for example, add or remove the destination room.
     * - After you call this method, the SDK triggers `onMediaRelayStateChange` and `onMediaRelayEvent`. The return reports the status and events about the current relayed media streams across rooms.
     * @note Before you call the method, you must join the room and call `startChannelMediaRelay` to relay the media stream across rooms. Before you call the method, you must set the destination room in the `NERtcChannelMediaRelayConfiguration` parameter in `dest_infos`.
     * @since V4.5.0
     * @param config The configuration for destination rooms.
     * @return A value of 0 returned indicates that the method call is successful. Otherwise, the method call fails.
     * @endif
     * @if Chinese
     * 更新媒体流转发的目标房间。
     * <br>成功开始跨房间转发媒体流后，如果你希望将流转发到多个目标房间，或退出当前的转发房间，可以调用该方法。
     * - 成功开始跨房间转发媒体流后，如果您需要修改目标房间，例如添加或删减目标房间等，可以调用此方法。
     * - 成功调用该方法后，SDK 会触发 `onMediaRelayStateChange` 和 `onMediaRelayEvent` 回调，并在回调中报告当前的跨房间媒体流转发状态和事件。
     * @note 请在加入房间并成功调用 `startChannelMediaRelay` 开始跨房间媒体流转发后，调用此方法。调用此方法前需要通过 `NERtcChannelMediaRelayConfiguration` 中的 `dest_infos` 设置目标房间。
     * @since V4.5.0
     * @param config 目标房间配置信息
     * @return 成功返回0，其他则失败
     * @endif
     */
    virtual int updateChannelMediaRelay(NERtcChannelMediaRelayConfiguration* config) = 0;

    /** 
     * @if English
     * Stops relaying media streams.
     * <br>If the host leaves the room, media stream replay across rooms automatically stops. You can also call stopChannelMediaRelay. In this case, the host exits all destination rooms.
     * - If you call this method, the SDK triggers the `onMediaRelayStateChange` callback. If `NERtcChannelMediaRelayStateIdle` is returned, the media stream relay stops.
     * - If the method call failed, the SDK triggers the `onMediaRelayStateChange` callback that returns the status code `NERtcChannelMediaRelayStateFailure`.
     * @since V4.5.0
     * @return A value of 0 returned indicates that the method call is successful. Otherwise, the method call fails.
     * @endif
     * @if Chinese
     * 停止跨房间媒体流转发。
     * <br>
     * 通常在主播离开房间时，跨房间媒体流转发会自动停止；您也可以根据需要随时调用该方法，此时主播会退出所有目标房间。
     * @since V4.3.0
     * @par 使用前提
     * 请在调用 \ref nertc::IRtcChannel::startChannelMediaRelay "startChannelMediaRelay" 方法开启跨房间媒体流转发之后调用此接口。
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
     * @par 示例代码
     * @code
     * rtc_channel_->stopChannelMediaRelay();
     * @endcode
     * @par 相关回调
     * \ref nertc::IRtcChannelEventHandler::onMediaRelayStateChanged "onMediaRelayStateChanged"：跨房间媒体流转发状态发生改变回调。成功调用该方法后会返回 MEDIARELAY_STATE_IDLE，否则会返回 MEDIARELAY_STATE_FAILURE。
     * \ref nertc::IRtcChannelEventHandler::onMediaRelayEvent "onMediaRelayEvent"：跨房间媒体流相关转发事件回调。成功调用该方法后会返回 MEDIARELAY_EVENT_DISCONNECT，否则会返回 MEDIARELAY_EVENT_FAILURE。
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * @endif
     */
    virtual int stopChannelMediaRelay() = 0;

    /** 
     * @if English
     * Sets the fallback option for the published local video stream based on the network conditions.
     * <br>The quality of the published local audio and video streams is degraded with poor quality network connections. After calling this method and setting the option to #kNERtcStreamFallbackAudioOnly:
     * - With unreliable upstream network connections and the quality of audio and video streams is downgraded, the SDK automatically disables video stream or stops receiving video streams. In this way, the communication quality is guaranteed.
     * - The SDK monitors the network performance and recover audio and video streams if the network quality improves.
     * - If the locally published audio and video stream falls back to audio stream, or recovers to audio and video stream, the SDK triggers the onLocalPublishFallbackToAudioOnly callback.
     * <p>@note You must call the method before you call joinChannel.
     * @since V4.5.0
     * @param option The fallback option of publishing audio and video streams. The fallback kNERtcStreamFallbackAudioOnly is disabled by default. For more information, see nertc::NERTCStreamFallbackOption.
     * @return {@code 0} A value of 0 returned indicates that the method call is successful. Otherwise, the method call fails.
     * @endif
     * @if Chinese
     * 设置弱网条件下发布的音视频流回退选项。
     * <br>在网络不理想的环境下，发布的音视频质量都会下降。使用该接口并将 option 设置为 #kNERtcStreamFallbackAudioOnly 后：
     * - SDK 会在上行弱网且音视频质量严重受影响时，自动关断视频流，尽量保证音频质量。
     * - 同时 SDK 会持续监控网络质量，并在网络质量改善时恢复音视频流。
     * - 当本地发布的音视频流回退为音频流时，或由音频流恢复为音视频流时，SDK 会触发本地发布的媒体流已回退为音频流 onLocalPublishFallbackToAudioOnly 回调。
     * <p>@note 请在加入房间（joinChannel）前调用此方法。
     * @since V4.5.0
     * @param option 发布音视频流的回退选项，默认为不开启回退 kNERtcStreamFallbackAudioOnly。详细信息请参考 nertc::NERTCStreamFallbackOption 。
     * @return {@code 0} 方法调用成功，其他调用失败
     * @endif
     */
    virtual int setLocalPublishFallbackOption(NERtcStreamFallbackOption option) = 0;

    /** 
     * @if English
     * Sets the fallback option for the subscribed remote audio and video stream with poor network connections.
     * <br>The quality of the subscribed audio and video streams is degraded with unreliable network connections. You can use the interface to set the option as #kNERtcStreamFallbackVideoStreamLow or #kNERtcStreamFallbackAudioOnly. 
     * - In unreliable downstream network connections, the SDK switches to receive a low-quality video stream or stops receiving video streams. In this way, the communication quality is maintained or improved.
     * - The SDK monitors the network quality and resumes the video stream when the network condition improves.
     * - If the subscribed remote video stream falls back to audio only, or the audio-only stream switches back to the video stream, the SDK triggers the onRemoteSubscribeFallbackToAudioOnly callback.
     * <p>@note You must call the method before you call joinChannel.
     * @since V4.5.0
     * @param option    The fallback option for the subscribed remote audio and video stream. With unreliable network connections, the stream falls back to a low-quality video stream of kNERtcStreamFallbackVideoStreamLow. For more information, see nertc::NERTCStreamFallbackOption .
     * @return {@code 0} A value of 0 returned indicates that the method call is successful. Otherwise, the method call fails.
     * @endif
     * @if Chinese
     * 设置弱网条件下订阅的音视频流回退选项。
     * <br>弱网环境下，订阅的音视频质量会下降。使用该接口并将 option 设置为  #kNERtcStreamFallbackVideoStreamLow 或者 #kNERtcStreamFallbackAudioOnly 后：
     * - SDK 会在下行弱网且音视频质量严重受影响时，将视频流切换为小流，或关断视频流，从而保证或提高通信质量。
     * - SDK 会持续监控网络质量，并在网络质量改善时自动恢复音视频流。
     * - 当远端订阅流回退为音频流时，或由音频流恢复为音视频流时，SDK 会触发远端订阅流已回退为音频流 onRemoteSubscribeFallbackToAudioOnly 回调。
     * <p>@note 请在加入房间（joinChannel）前调用此方法。
     * @since V4.5.0
     * @param option    订阅音视频流的回退选项，默认为弱网时回退到视频小流 kNERtcStreamFallbackVideoStreamLow。详细信息请参考 nertc::NERTCStreamFallbackOption 。
     * @return {@code 0} 方法调用成功，其他调用失败
     * @endif
     */
    virtual int setRemoteSubscribeFallbackOption(NERtcStreamFallbackOption option) = 0;
    
    /**
     * @if English
     * Sets a remote audio stream to high priority
     * Sets a remote audio streams to high priority during automatic stream subscription. Users can hear the audio stream with high priority.
     * @note
     * - The priority of a remote audio stream must be set during a call and automatic stream subscription must be enabled (by default)
     * - Only one audio stream can be set to high priority. The subsequent call will override the previous setting.
     * - The priority of the audio stream will be reset after the call ends
     * @param[in] enabled sets or cancels high priority to a remote audio stream.
     * - true: sets high priority to a remote audio stream.
     * - false: cancels high priority of a remote audio stream. 
     * @param[in] uid User ID
     * @return
     * - 0: success；
     * - Other values: failure
     * @endif
     * @if Chinese
     * 设置远端用户音频流为高优先级。
     * 支持在音频自动订阅的情况下，设置某一个远端用户的音频为最高优先级，可以优先听到该用户的音频。
     * @note
     * - 该接口需要通话中设置，并需要自动订阅打开（默认打开）。
     * - 该接口只能设置一个用户的优先级，后设置的会覆盖之前的设置。
     * - 该接口通话结束后，优先级设置重置。
     * @param[in] enabled 是否设置音频订阅优先级。
     * - true：设置音频订阅优先级。
     * - false：取消设置音频订阅优先级。
     * @param[in] uid 用户 ID
     * @return
     * - 0: 方法调用成功。
     * - 其他: 方法调用失败。
     * @endif
     */
    virtual int setRemoteHighPriorityAudioStream(bool enabled, uid_t uid) = 0;

    /**
     * @if English
     * Enables or disables the external video source.
     * <br>When you enable the external video source through the method, you need to set kNERtcExternalVideoDeviceID as the ID of external video source with IVideoDeviceManager::setDevice kNERtcExternalVideoDeviceID method.
     * @note The method enables the internal engine, which is still valid after you call \ref IRtcEngine::leaveChannel "leaveChannel".
     * @param[in] enabled       Specifies whether input external video source data.
     * - true: Enables external video source.
     * - false: Disables the external video source (default).
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 开启或关闭外部视频源数据输入。
     * <br>通过该方法启用外部视频数据输入功能时，需要通过 IVideoDeviceManager::setDevice 设置 kNERtcExternalVideoDeviceID 为外部视频输入源 ID。
     * @note 该方法设置内部引擎为启用状态，在 \ref IRtcEngine::leaveChannel "leaveChannel" 后仍然有效。
     * @param[in] enabled       是否启用外部视频源数据输入。
     * - true: 开启外部视频源数据输入；
     * - false: 关闭外部视频源数据输入 (默认)。
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
    * @endif
    */
    virtual int setExternalVideoSource(bool enabled) = 0;

    /**
     * @if English
     * Enables or disables the external video source.
     * <br>When you enable the external video source through the method, you need to set kNERtcExternalVideoDeviceID as the ID of external video source with IVideoDeviceManager::setDevice kNERtcExternalVideoDeviceID method.
     * @note The method enables the internal engine, which is still valid after you call \ref IRtcEngine::leaveChannel "leaveChannel".
     * @param[in] enabled       Specifies whether input external video source data.
     * - true: Enables external video source.
     * - false: Disables the external video source (default).
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 开启或关闭外部视频源数据输入。
     * <br>通过该方法启用外部视频数据输入功能时，需要通过 IVideoDeviceManager::setDevice 设置 kNERtcExternalVideoDeviceID 为外部视频输入源 ID。
     * @note 该方法设置内部引擎为启用状态，在 \ref IRtcEngine::leaveChannel "leaveChannel" 后仍然有效。
     * @param[in] type 视频流通道类型 #NERtcVideoStreamType
     * - kNERTCVideoStreamMain，打开或关闭主流通道的外部源
     * - kNERTCVideoStreamSub， 打开或关闭辅流通道的外部源
     * @param[in] enabled       是否外部视频源数据输入:
     * - true: 开启外部视频源数据输入；
     * - false: 关闭外部视频源数据输入 (默认)。
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
    * @endif
    */
    virtual int setExternalVideoSource(NERtcVideoStreamType type, bool enabled) = 0;

    /**
     * @if English
     * Pushes the external video frames.
     * <br>The method actively pushes the data of video frames that are encapsulated with the NERtcVideoFrame class to the SDK. Make sure that you have already called setExternalVideoSource with a value of true before you call this method. Otherwise, an error message is repeatedly prompted if you call the method.
     * @note The method enables the internal engine, which is invalid after you call \ref IRtcEngine::leaveChannel "leaveChannel".
     * @param[in] frame         The video frame data.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 推送外部视频帧。
     * <br>该方法主动将视频帧数据用 NERtcVideoFrame 类封装后传递给 SDK。 请确保在你调用本方法前已调用 setExternalVideoSource，并将参数设为 true，否则调用本方法后会一直报错。
     * @note 该方法设置内部引擎为启用状态，在 \ref IRtcEngine::leaveChannel "leaveChannel" 后不再有效。
     * @param[in] frame         外部视频帧数据。详细信息请参考 \ref NERtcVideoFrame "NERtcVideoFrame" 。
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
    * @endif
    */
    virtual int pushExternalVideoFrame(NERtcVideoFrame* frame) = 0;

    /**
     * @if English
     * Pushes the external video frames.
     * <br>The method actively pushes the data of video frames that are encapsulated with the NERtcVideoFrame class to the SDK. Make sure that you have already called setExternalVideoSource with a value of true before you call this method. Otherwise, an error message is repeatedly prompted if you call the method.
     * @note The method enables the internal engine, which is invalid after you call \ref IRtcEngine::leaveChannel "leaveChannel".
     * @param[in] frame         The video frame data.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 推送外部视频帧。
     * <br>该方法主动将视频帧数据用 NERtcVideoFrame 类封装后传递给 SDK。 请确保在你调用本方法前已调用 setExternalVideoSource，并将参数设为 true，否则调用本方法后会一直报错。
     * @note 该方法设置内部引擎为启用状态，在 \ref IRtcEngine::leaveChannel "leaveChannel" 后不再有效。
     * @param[in] frame         视频帧数据。
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
    * @endif
    */
    virtual int pushExternalVideoFrame(NERtcVideoStreamType type, NERtcVideoFrame* frame) = 0;

    
    /**
     * @if English
     * Publishes or unpublishes the local audio stream.
     * <br>When a user joins a room, the feature is enabled by default.
     * <br>The method does not affect receiving or playing the remote audio stream. The enableLocalAudio(false) method is suitable for scenarios where clients only receives remote media streams and does not publish any local streams.
     * @note 
     * - The method controls data transmitted over the main stream
     * - The method can be called before or after a user joins a room.
     * @since V4.6.10
     * @param enabled specifies whether to publish the local audio stream.
     * - true(default): publishes the local audio stream.
     * - false: unpublishes the local audio stream.
     * @param mediaType  media type. Audio type is supported.
     * @return 
     * - 0: success
     * - Others: failure
     * @endif
     * @if Chinese
     * 开启或关闭本地媒体流（主流）的发送。
     * <br>该方法用于开始或停止向网络发送本地音频或视频数据。
     * <br>该方法不影响接收或播放远端媒体流，也不会影响本地音频或视频的采集状态。
     * @since V4.6.10
     * @note 
     * - 该方法暂时仅支持控制音频流的发送。
     * - 该方法在加入房间前后均可调用。
     * - 停止发送媒体流的状态会在通话结束后被重置为允许发送。
     * - 成功调用该方法切换本地用户的发流状态后，房间内其他用户会收到 \ref IRtcChannelEventHandler::onUserAudioStart "onUserAudioStart"（开启发送音频）或 \ref IRtcChannelEventHandler::onUserAudioStop "onUserAudioStop"（停止发送音频）的回调。
     * @par 相关接口
     * - \ref IRtcChannel::muteLocalAudioStream "muteLocalAudioStream"：
     *         - 在需要开启本地音频采集（监测本地用户音量）但不发送音频流的情况下，您也可以调用 muteLocalAudioStream(true) 方法。
     *         - 两者的差异在于， muteLocalAudioStream(true) 仍然保持与服务器的音频通道连接，而 enableMediaPub(false) 表示断开此通道，因此若您的实际业务场景为多人并发的大房间，建议您调用 enableMediaPub 方法。  
     * @param enabled 是否发布本地媒体流。
     * - true（默认）：发布本地媒体流。
     * - false：不发布本地媒体流。
     * @param media_type 媒体发布类型，暂时仅支持音频。
     * @return 
     * - 0：方法调用成功。
     * - 其他：方法调用失败。
     * @endif
     */
    virtual int enableMediaPub(bool enabled, NERtcMediaPubType media_type) = 0;

    /**
     * @if Chinese 
     * 更新权限密钥。
     * - 通过本接口可以实现当用户权限被变更，或者收到权限密钥即将过期的回调 \ref nertc::IRtcChannelEventHandler::onPermissionKeyWillExpire() "onPermissionKeyWillExpire" 时，更新权限密钥。
     * @since V4.6.29
     * @par 使用前提
     * 请确保已开通高级 Token 鉴权功能，具体请联系网易云信商务经理。
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
     * @par 业务场景
     * 适用于变更指定用户加入、创建房间或上下麦时发布流相关权限的场景。
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
     * </table>     
     * @par 示例代码
     * @code
     * if (rtc_channel_) {
     * std::string key;//向服务器请求得到的权限key，具体请参考官方文档的高级 Token 鉴权章节。</a>
     * res = rtc_channel_->updatePermissionKey(key.c_str()));
     * }
     * if (kNERtcNoError != res) {
     * }
     * @endcode
     * @par 相关回调
     * 调用此接口成功更新权限密钥后会触发 \ref nertc::IRtcChannelEventHandler::onUpdatePermissionKey() "onUpdatePermissionKey" 回调。
     * @return 
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *         - 30003（kNERtcErrInvalidParam）：参数错误，比如 key 无效。
     *         - 30005（kNERtcErrInvalidState)：当前状态不支持的操作，比如引擎尚未初始化。
     * @endif
     */
    virtual int updatePermissionKey(const char* key) = 0;
    /**
     * @if Chinese
     * 上报自定义事件
     * @param event_name      事件名 不能为空
     * @param custom_identify 自定义标识，比如产品或业务类型，如不需要填null
     * @param parameters          参数键值对 ，参数值支持String 及java基本类型(int 、bool....) ， 如不需要填null
     * @return 操作返回值，成功则返回 0
     * @endif
     */
    virtual int reportCustomEvent(const char* event_name, const char* custom_identify, const char* parameters) = 0;
    /**
     * @if English
     * @deprecated This method is deprecated.
     * Enables volume indication for the speaker.
     * <br>The method allows the SDK to report to the app the information about the volume of the user that pushes local streams
     * and the remote user (up to three users) that has the highest instantaneous volume. The information about the current
     * speaker and the volume is reported. <br>If this method is enabled, when a user joins a room and pushes streams, the SDK
     * triggers \ref IRtcEngineEventHandlerEx::onRemoteAudioVolumeIndication "onRemoteAudioVolumeIndication" based on the preset
     * time intervals.
     * @param enable        Whether to prompt the speaker volume.
     * @param interval      The time interval at which volume prompt is displayed. Unit: milliseconds. The value must be the
     * multiples of 100 milliseconds.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * @deprecated 这个方法已废弃。
     * 启用说话者音量提示。
     * <br>通过此接口可以实现允许 SDK 定期向 App 反馈房间内发音频流的用户和瞬时音量最高的远端用户（最多 3
     * 位，包括本端）的音量相关信息，即当前谁在说话以及说话者的音量。
     * @since V3.5.0
     * @par 调用时机
     * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
     * @par 业务场景
     * 适用于通过发言者的人声相关信息做出 UI 上的音量展示的场景，或根据发言者的音量大小进行视图布局的动态调整。
     *  @note
     * 该方法在 leaveChannel 后设置失效，将恢复至默认。如果您离开房间后重新加入房间，需要重新调用本接口。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>enable</td>
     *      <td>bool</td>
     *      <td>是否启用说话者音量提示：<ul><li>true：启用说话者音量提示。<li>false：关闭说话者音量提示。</td>
     *  <tr>
     *      <td>interval</td>
     *      <td>uint64_t</td>
     *      <td>指定音量提示的时间间隔。单位为毫秒。必须设置为 100 毫秒的整数倍值，建议设置为 200 毫秒以上。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * //设置间隔为500ms的人声音量提示
     * rtc_engine_->enableAudioVolumeIndication(true, 500);
     * @endcode
     * @par 相关回调
     * 启用该方法后，只要房间内有发流用户，无论是否有人说话，SDK 都会在加入房间后根据预设的时间间隔触发 \ref
     * IRtcEngineEventHandlerEx::onRemoteAudioVolumeIndication  "onRemoteAudioVolumeIndication" 回调。
     * @par 相关接口
     * 若您希望在返回音量相关信息的同时检测是否有真实人声存在，请调用 \ref nertc::IRtcEngineEx::enableAudioVolumeIndication(bool
     * enable, uint64_t interval, bool enable_vad) "enableAudioVolumeIndication" 方法。
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *         - 30003（kNERtcErrInvalidParam）：参数错误，比如时间间隔小于 100ms。
     *         - 30005（kNERtcErrInvalidState）：状态错误，比如引擎未初始化。
     * @endif
     */
    virtual int enableAudioVolumeIndication(bool enable, uint64_t interval, bool enable_vad) = 0;

   /**
    * 设置范围语音模式
    * @note 此接口在加入房间前后均可调用。
    * @note 若要使用范围语音功能需要入会前调用一次。
    * @since V5.5.10
    * @param[in] mode 范围语音模式
    * @return
    * - 0: 方法调用成功
    * - 其他: 调用失败
    */
    virtual int setRangeAudioMode(NERtcRangeAudioMode mode) = 0;

   /**
    * 设置范围语音小队
    * @since V5.5.10
    * @note 此接口在加入房间前后均可调用。
    * @note 若要使用范围语音功能需要入会前调用一次。
    * @param team_id 小队ID, 有效值: >=0
    * @return
    * - 0: 方法调用成功
    * - 其他: 调用失败
    */
    virtual int setRangeAudioTeamID(int32_t team_id) = 0;

   /**
    * 距离范围设置
    * @since V5.5.10
    * @note 
    * - 此接口在加入房间前后均可调用
    * - 若要使用范围语音或3D音效功能需要入会前调用一次
    * - 仅使用范围语音时，通过设置audible_distance设置语音接收范围，其他参数设置不生效，填写默认值即可。
    * @param audible_distance 监听器能够听到扬声器并接收其语音的距离扬声器的最大距离。距离有效范围：[1,max int) ，无默认值。
    * @param conversational_distance 控制音频保持其原始音量的范围，超出该范围时，语音聊天的响度在被听到时开始淡出。
    * 默认值为 1。
    * @param roll_off 距离衰减模式 #NERtcDistanceRolloffModel ，默认值 #kNERtcDistanceRolloffNone
    * @return
    * - 0: 方法调用成功
    * - 其他: 调用失败
    */
    virtual int setAudioRecvRange(int audible_distance, int conversational_distance, NERtcDistanceRolloffModel roll_off) = 0;
    
   /**
    * 更新本地用户的空间位置。
    * @since V5.5.10
    * @par 调用时机
    * 请在引擎初始化后调用此接口，且该方法在加入房间前后均可调用。
    * @par 参数说明
    * 通过 info 参数设置空间音效中说话者和接收者的空间位置信息。 \ref nertc::NERtcPositionInfo "NERtcPositionInfo" 的具体参数说明如下表所示。
    * <table>
    *  <tr>
    *      <th>**参数名称**</th>
    *      <th>**描述**</th>
    *  </tr>
    *  <tr>
    *      <td>speaker_position</td>
    *      <td>说话者的位置信息，三个值依次表示X、Y、Z的坐标值。默认值{0,0,0} </td>
    *  </tr>
    *  <tr>
    *      <td>speaker_quaternion</td>
    *      <td>说话者的旋转信息，通过四元组来表示，数据格式为{w, x, y, z}。默认值{0,0,0,0} </td>
    *  </tr>
    *  <tr>
    *      <td>head_position</td>
    *      <td>接收者的位置信息，三个值依次表示X、Y、Z的坐标值。默认值{0,0,0} </td>
    *  </tr>
    *  <tr>
    *      <td>head_quaternion</td>
    *      <td>接收者的旋转信息，通过四元组来表示，数据格式为{w, x, y, z}。默认值{0,0,0,0}</td>
    *  </tr>
    * </table>  
     * @return
     * - 0: 方法调用成功
     * - 其他: 调用失败
     */
    virtual int updateSelfPosition(const NERtcPositionInfo& info) = 0;

   /**
    * 开启或关闭空间音效的房间混响效果
    * @since V5.4.0
    * @note 该接口不支持 Linux 平台
    * @par 调用时机
    * 请在引擎初始化后调用此接口，且该方法在加入房间前后均可调用。
    * @note 
    * 请先调用 \ref  #enableSpatializer 接口启用空间音效，再调用本接口。
    * @param enable 混响效果开关，默认值关闭
    * @return
    * - 0: 方法调用成功
    * - 其他: 调用失败
    */
    virtual int enableSpatializerRoomEffects(bool enable) = 0;

   /**
    * 设置空间音效的房间混响属性
    * @since V5.4.0
    * @note 该接口不支持 Linux 平台
    * @par 调用时机
    * 请在引擎初始化后调用此接口，且该方法在加入房间前才可调用。
    * @note 
    * 请先调用 \ref  #enableSpatializer 接口启用空间音效，再调用本接口。
    * @param room_property 房间属性，具体请参见 \ref nertc::NERtcSpatializerRoomProperty "NERtcSpatializerRoomProperty"
    * @return
    * - 0: 方法调用成功
    * - 其他: 调用失败
    */
    virtual int setSpatializerRoomProperty(const NERtcSpatializerRoomProperty& room_property) = 0;

   /**
    * 设置空间音效的渲染模式
    * @since V5.4.0
    * @note 该接口不支持 Linux 平台
    * @par 调用时机
    * 请在引擎初始化后调用此接口，且该方法在加入房间前才可调用。
    * @note 
    * 请先调用 \ref  #enableSpatializer 接口启用空间音效，再调用本接口。
    * @param mode 渲染模式，具体请参见 \ref nertc::NERtcSpatializerRenderMode "NERtcSpatializerRenderMode"，默认值 #kNERtcSpatializerRenderBinauralHighQuality
    * @return
    * - 0: 方法调用成功
    * - 其他: 调用失败
    */
    virtual int setSpatializerRenderMode(NERtcSpatializerRenderMode mode) = 0;

   /**
    * 初始化引擎3D音效算法
    * @since V5.5.10
    * @note 该接口不支持 Linux 平台
    * @note 此接口在加入房间前调用后均可调用。
    * @return
    * - 0: 方法调用成功
    * - 其他: 调用失败
    */
    virtual int initSpatializer() = 0;

   /**
    * 开启或关闭空间音效
    * @since V5.4.0
    * @note 该接口不支持 Linux 平台
    * @par 调用时机
    * 请在引擎初始化后调用此接口，且该方法在加入房间前后均可调用。
    * @note 开启空间音效后，通话结束时仍保留该开关状态，不重置。
    * @note
    * 请先调用 \ref  #initSpatializer 接口初始化空间音效算法，再调用本接口。
    * @param enable 是否打开3D音效算法功能，默认为关闭状态。
    * - true: 开启空间音效
    * - false: 关闭空间音效
    * @param apply_to_team 是否仅本小队开启3D音效。
    * - true: 仅仅和接收端同一个小队的人有3D音效。
    * - false: 接收到所有的语音都有3d音效。
    * @return
    * - 0: 方法调用成功
    * - 其他: 调用失败
    */
    virtual int enableSpatializer(bool enable, bool apply_to_team) = 0;
};
} //namespace nertc

#endif
