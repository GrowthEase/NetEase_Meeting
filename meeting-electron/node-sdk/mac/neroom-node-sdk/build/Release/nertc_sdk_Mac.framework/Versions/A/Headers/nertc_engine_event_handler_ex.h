/** @file nertc_engine_event_handler_ex.h
* @brief The interface header file of expansion callback of the NERTC SDK.
* All parameter descriptions of the NERTC SDK. All string-related parameters (char *) are encoded in UTF-8.
* @copyright (c) 2021, NetEase Inc. All rights reserved.
*/

#ifndef NERTC_ENGINE_EVENT_HANDLER_EX_H
#define NERTC_ENGINE_EVENT_HANDLER_EX_H

#include "nertc_base_types.h"
#include "nertc_engine_defines.h"
#include "nertc_engine_event_handler.h"

 /**
 * @namespace nertc
 * @brief namespace nertc
 */
namespace nertc
{
/** 
 * @if English
 * IRtcEngineEventHandlerEx callback interface class is used to send callback event notifications to the app from SDK. The app gets event notifications from the SDK through inheriting the interface class.
 * <br>All methods in this interface class have their (empty) default implementations, and the application can inherit only some of the required events instead of all of them. When calling a callback method, the application must not implement time-consuming operations or call blocking-triggered APIs. For example, if you want to enable audio and video, the SDK may be affected in the runtime.
 * @endif
 * @if Chinese
 * IRtcEngineEventHandlerEx 回调扩展接口类用于 SDK 向 App 发送回调事件通知，App 通过继承该接口类的方法获取 SDK 的事件通知。
 * <br>接口类的所有方法都有缺省（空）实现，App 可以根据需要只继承关心的事件。在回调方法中，App 不应该做耗时或者调用可能会引起阻塞的 API（如开启音频或视频等），否则可能影响 SDK 的运行。
 * @endif
 */
class IRtcEngineEventHandlerEx : public IRtcEngineEventHandler
{
public:
    virtual ~IRtcEngineEventHandlerEx() {}

    /** 
     * @if English
     * Occurs when a remote user enables screen sharing by using the substream.
     * @param uid           The ID of a remote user.
     * @param max_profile   The largest resolution of the remote video.
     * 
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
     * @param uid   The ID of a remote user.
     * 
     * @endif
     * @if Chinese
     * 远端用户停止屏幕共享辅流通道的回调。
     * @param uid   远端用户ID。
     * @endif
     */
    virtual void onUserSubStreamVideoStop(uid_t uid) {
        (void)uid;
    }

    /** 
     * @if English
     * Occurs when screen sharing is paused/resumed/started/ended. 
     * <br>The method applies to Windows since V4.2.0, 
     * <br>and to macOS since V4.6.0.
     * @since V4.2.0 (Windows) / V4.6.0 (macOS)
     * @param status    Screen capture status. For more information, see #NERtcScreenCaptureStatus.
     * @endif
     * @if Chinese
     * 屏幕共享状态变化回调。
     * @since V4.2.0
     * @note macOS 平台自 V4.6.0 支持此回调。
     * @param status    屏幕共享状态。详细信息请参考 #NERtcScreenCaptureStatus 。
     * @endif
     */
    virtual void onScreenCaptureStatus(NERtcScreenCaptureStatus status) {}

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
     * @since V5.4.x
     * @note 自 V5.4.x 支持此回调。
     * @param data    屏幕共享源变化的信息。详细信息请参考 #NERtcScreenCaptureSourceData 。
     * @endif
     */
    virtual void onScreenCaptureSourceDataUpdate(NERtcScreenCaptureSourceData data) {}
    
    /** 
     * @if English
     * Occurs when video configurations of remote users are updated.
     * @param uid           The ID of a remote user.
     * @param max_profile   The resolution of video encoding measures the encoding quality.
     * @endif
     * @if Chinese
     * @param uid           远端用户 ID。
     * @param max_profile   视频编码的分辨率，用于衡量编码质量。
     * @endif
     */
    virtual void onUserVideoProfileUpdate(uid_t uid, NERtcVideoProfileType max_profile) {
        (void)uid;
        (void)max_profile;
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
    virtual void onUserSubStreamAudioStart(uid_t uid) { 
        (void)uid; 
    }
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
    virtual void onUserSubStreamAudioStop(uid_t uid) {
        (void)uid; 
    }
    /** 
     * @if English
     * Callbacks that specify whether to mute remote users.
     * @param uid       The ID of a remote user.
     * @param mute      indicates whether to unmute the remote user.
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
     * Occurs when a remote user stops or resumes sending video streams. 
     * @param uid       The ID of a remote user.
     * @param mute      Whether to disable video streams.
     * @endif
     * @if Chinese
     * 远端用户暂停或恢复发送视频流的回调。
     * <br>当远端用户调用 muteLocalVideoStream 取消或者恢复发布视频流时，SDK会触发该回调向本地用户报告远程用户的发流状况。
     * @note 该回调仅在远端用户的视频主流状态改变时会触发，若您希望同时接收到远端用户视频辅流状态变更的通知，请监听 \ref IRtcEngineEventHandlerEx::onUserVideoMute(NERtcVideoStreamType videoStreamType, uid_t uid, bool mute) "onUserVideoMute" 回调。
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
     * Occurs when the state of the audio device changes.
     * @param device_id    Device ID.
     * @param device_type  The type of the device. For more information, see NERtcAudioDeviceType.
     * @param device_state The state of the audio device.
     * @endif
     * @if Chinese
     * 音频设备状态更改的回调。
     * @param device_id     设备ID。
     * @param device_type   音频设备类型。详细信息请参考 NERtcAudioDeviceType。
     * @param device_state  音频设备状态。
     * @endif
     */
    virtual void onAudioDeviceStateChanged(const char device_id[kNERtcMaxDeviceIDLength],
        NERtcAudioDeviceType device_type,
        NERtcAudioDeviceState device_state) {
        (void)device_id;
        (void)device_type;
        (void)device_state;
    }

    /** 
     * @if English
     * Occurs when the default audio devices changes.
     * @param device_id     Device ID.
     * @param device_type   The type of the device.
     * @endif
     * @if Chinese
     * 音频默认设备更改的回调。
     * @param device_id     设备ID。
     * @param device_type   音频设备类型。
     * @endif
     */
    virtual void onAudioDefaultDeviceChanged(const char device_id[kNERtcMaxDeviceIDLength],
        NERtcAudioDeviceType device_type) {
        (void)device_id;
        (void)device_type;
    }

    /** 
     * @if English
     * Occurs when the state of the video device is changed.
     * @param device_id     Device ID.
     * @param device_type   The type of the video device.
     * @param device_state  The state of the video device.
     * @endif
     * @if Chinese
     * 视频设备状态已改变的回调。
     * @param device_id     设备ID。
     * @param device_type   视频设备类型。
     * @param device_state  视频设备状态。
     * @endif
     */
    virtual void onVideoDeviceStateChanged(const char device_id[kNERtcMaxDeviceIDLength],
        NERtcVideoDeviceType device_type,
        NERtcVideoDeviceState device_state) {
        (void)device_id;
        (void)device_type;
        (void)device_state;
    }

    /** 
     * @if English
     * Occurs when the first audio frame from a remote user is received.
     * @param uid       The ID of a remote user whose audio streams are sent. 
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
     * @endif
     * @if Chinese
     * 已显示首帧远端视频的回调。
     * 第一帧远端视频显示在视图上时，触发此调用。
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
     *      <td>see #NERtcVideoStreamType</td>
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
     * @endif
     * @if Chinese
     * 已接收到远端视频并完成解码的回调。
     * <br>引擎收到第一帧远端视频流并解码成功时，触发此调用。每次重新调用 enableLocalVideo 开启本地视频采集，也会触发该回调。（V5.5.10版本开始）
     * @note 该回调仅在接收远端用户的主流视频首帧并完成解码时会触发，若您希望同时接收到接收辅流的相关通知，请监听 \ref IRtcEngineEventHandlerEx::onFirstVideoFrameDecoded(NERtcVideoStreamType type, uid_t uid, uint32_t width, uint32_t height) "onFirstVideoFrameDecoded" 回调。
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
     * <br>应用层可在该回调中设置此用户的视频画布。
     * @since V4.6.20
     * @note 以下场景都会触发该回调：
     * - SDK 收到远端视频并解码成功时。
     * - 重新调用 enableLocalVideo 开启本地视频采集。（V5.5.10版本开始）
     * - 停止屏幕共享后再重新调用 startScreenCapture 接口共享屏幕。（V5.5.10版本开始）
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
     * </table>
     * @endif
     */
    virtual void onFirstVideoFrameDecoded(NERtcVideoStreamType type, uid_t uid, uint32_t width, uint32_t height) {
        (void)type;
        (void)uid;
        (void)width;
        (void)height;
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
     * Occurs when video data are captured.
     * @param data      The video frame data.
     * @param type      The type of the video data.
     * @param width     The width of the video frame.
     * @param height    The height of the video frame.
     * @param count     Video plane count.
     * @param offset    Video offset.
     * @param stride    Video stride.
     * @param rotation  The video rotation angle. 
     * @endif
     * @if Chinese
     * 采集视频数据回调。
     * <br>调用本接口采集视频数据回调之前，请先调用  \ref nertc::IRtcEngineEx::setParameters "setParameters"：接口，将 kNERtcKeyEnableVideoCaptureObserver 的值设置为 YES，开启摄像头采集数据的回调。

     * @param data      采集视频数据。
     * @param type      视频类型。
     * @param width     视频宽度。
     * @param height    视频高度。
     * @param count     视频Plane Count。
     * @param offset    视频offset。
     * @param stride    视频stride。
     * @param rotation  视频旋转角度。
     * @endif
     */
    virtual void onCaptureVideoFrame(void *data,
        NERtcVideoType type, 
        uint32_t width, 
        uint32_t height,
        uint32_t count,
        uint32_t offset[kNERtcMaxPlaneCount],
        uint32_t stride[kNERtcMaxPlaneCount],
        NERtcVideoRotation rotation) {
        (void)data;
        (void)type;
        (void)width;
        (void)height;
        (void)count;
        (void)offset;
        (void)stride;
        (void)rotation;
    }

    /** 
     * @if English
     * Occurs when the playback state of a local music file changes.
     * <br>If you call the startAudioMixing method to play a mixing music file and the playback state changes, the callback is triggered.
     * - If the playback of the music file ends normally, the state parameter returned in the response contains the corresponding status code kNERtcAudioMixingStateFinished, and the error_code parameter contains kNERtcAudioMixingErrorOK.
     * - If an error occurs in the playback, the kNERtcAudioMixingStateFailed status code is returned, and the error_code parameter returned contains the corresponding reason.
     * - If the local music file does not exist, the file format is not supported, or the URL of the online music file cannot be accessed, the error_code parameter returned contains kNERtcAudioMixingErrorCanNotOpen.
     * @param state         The playback state of the music file. For more information, see #NERtcAudioMixingState.
     * @param error_code    The error code. For more information, see #NERtcAudioMixingErrorCode.
     * @endif
     * @if Chinese
     * 本地用户的音乐文件播放状态改变回调。
     * <br>调用 startAudioMixing 播放混音音乐文件后，当音乐文件的播放状态发生改变时，会触发该回调。
     * - 如果播放音乐文件正常结束，state 会返回相应的状态码 kNERtcAudioMixingStateFinished，error_code 返回 kNERtcAudioMixingErrorOK。
     * - 如果播放出错，则返回状态码 kNERtcAudioMixingStateFailed，error_code 返回相应的出错原因。
     * - 如果本地音乐文件不存在、文件格式不支持、无法访问在线音乐文件 URL，error_code都会返回 kNERtcAudioMixingErrorCanNotOpen。
     * @param state         音乐文件播放状态，详见 #NERtcAudioMixingState.
     * @param error_code    错误码，详见 #NERtcAudioMixingErrorCode.
    * @endif
    */
    virtual void onAudioMixingStateChanged(NERtcAudioMixingState state, NERtcAudioMixingErrorCode error_code) {
        (void)state;
        (void)error_code;
    }

    /** 
     * @if English
     * Occurs when the playback position of a local music file changes.
     * <br>If you call the startAudioMixing method to play a mixing music file and the position of the playing operation changes, the callback is triggered. 
     * @param timestamp_ms      The position of the music file playing. Unit: milliseconds. 
     * @endif
     * @if Chinese
     * 本地用户的音乐文件播放进度回调。
     * <br>调用 startAudioMixing 播放混音音乐文件后，当音乐文件的播放进度改变时，会触发该回调。
     * @param timestamp_ms      音乐文件播放进度，单位为毫秒
    * @endif
    */
    virtual void onAudioMixingTimestampUpdate(uint64_t timestamp_ms) {
        (void)timestamp_ms;
    }

	/**
     * @if English
     * Occurs when the playback position of a local effect file changes.
     * <br>If you call the playEffect method to play a effect file and the position of the playing operation
     * changes, the callback is triggered.
     * @param effect_id      The effect file id.f
     * @param timestamp_ms      The position of the music file playing. Unit: milliseconds.
     * @endif
     * @if Chinese
     * 本地用户的指定音效文件播放进度回调。
     * - 调用 \ref nertc::IRtcEngineEx::playEffect "playEffect"播放音效文件后，SDK 会触发该回调，默认每 1s 返回一次。
     * @since V4.6.29
     * @par 使用前提
     * 请在 IRtcEngineEventHandlerEx 接口类中通过 \ref nertc::IRtcEngine::initialize "initialize" 接口设置回调监听。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>effect_id</td>
     *      <td>uint32_t</td>
     *      <td>指定音效文件的 ID。每个音效均有唯一的 ID。</td>
     *  </tr>
     *  <tr>
     *      <td>timestamp_ms</td>
     *      <td>uint64_t</td>
     *      <td>指定音效文件的当前播放进度。单位为毫秒。</td>
     *  </tr>
     * </table> 
     * @endif
     */
    virtual void onAudioEffectTimestampUpdate(uint32_t effect_id, uint64_t timestamp_ms) { 
		(void)effect_id;
        (void)timestamp_ms;
    }

    /** 
     * @if English
     * Occurs when the playback of a music file ends.
     * <br>After the audio effect ends the playback, the callback is triggered.
     * @param effect_id         The ID of the specified audio effect. Each audio effect has a unique ID.
     * @endif
     * @if Chinese
     * 本地音效文件播放已结束回调。
     * <br>当播放音效结束后，会触发该回调。
     * @param effect_id         指定音效的 ID。每个音效均有唯一的 ID。
    * @endif
    */
    virtual void onAudioEffectFinished(uint32_t effect_id) {
        (void)effect_id;
    }

    /** 
     * @if English
     * @deprecated The callback method is deprecated.
     * Occurs when the system prompts current local audio volume.
     * - This callback is disabled by default. You can enable the callback by calling the \ref IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication" method.
     * - After the callback is enabled, if a local user speaks, the SDK triggers the callback based on the time interval specified in the \ref IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication" method.
     * - If a local user sets a mute by calling \ref IRtcEngineEx::muteLocalAudioStream "muteLocalAudioStream", the SDK sets the value of volume as 0, and calls back to the application layer. 
     * @param volume    The volume of audio mixing. Value range: 0 to 100.
     * @endif
     * @if Chinese
     * @deprecated 该回调方法已废弃。
     * 提示房间内本地用户瞬时音量的回调。
     * - 该回调默认禁用。可以通过 \ref IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication" 方法开启。
     * - 开启后，本地用户说话，SDK 会按  \ref IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication" 方法中设置的时间间隔触发该回调。
     * - 如果本地用户将自己静音（调用了 \ref IRtcEngineEx::muteLocalAudioStream "muteLocalAudioStream"），SDK 将音量设置为 0 后回调给应用层。
     * @param volume    （混音后的）音量，取值范围为 [0,100]。
     * @endif
     */
    virtual void onLocalAudioVolumeIndication(int volume) {
        (void)volume;
    }
    
    /**
     * @if English
     * Occurs when the system prompts current local audio volume.
     * - This callback is disabled by default. You can enable the callback by calling the \ref IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication" method.
     * - After the callback is enabled, if a local user speaks, the SDK triggers the callback based on the time interval specified in the \ref IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication" method.
     * - If a local user sets a mute by calling \ref IRtcEngineEx::muteLocalAudioStream "muteLocalAudioStream", the SDK sets the value of volume as 0, and calls back to the application layer.
     * @param volume    The volume of audio mixing. Value range: 0 to 100.
     * @param enableVad  Whether human voice is detected.
     * @endif
     * @if Chinese
     * 提示房间内本地用户瞬时音量的回调。
     * - 该回调默认禁用。可以通过 \ref IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication" 方法开启。
     * - 开启后，本地用户说话，SDK 会按  \ref IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication" 方法中设置的时间间隔触发该回调。
     * - 如果本地用户将自己静音（调用了 \ref IRtcEngineEx::muteLocalAudioStream "muteLocalAudioStream"），SDK 将音量设置为 0 后回调给应用层。
     * @param volume    （混音后的）音量，取值范围为 [0,100]。
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
     * By default, the callback is disabled. You can enable the callback by calling the enableAudioVolumeIndication method. After the callback is enabled, if a local user speaks, the SDK triggers the callback based on the time interval specified in the enableAudioVolumeIndication method.
     * In the array of speakers returned:
     * - If a uid is contained in the array returned in the last response but not in the array returned in the current response. The remote user with the uid does not speak by default.
     * - If the volume is 0, the user does not speak. 
     * - If the array is empty, the remote user does not speak.
     * @param speakers          The array that contains the information about user IDs and volumes is NERtcAudioVolumeInfo.
     * @param speaker_number    The size of speakers array, which indicates the number of speakers. 
     * @param total_volume      The total volume (after audio mixing). Value range: 0 to 100. 
     * @endif
     * @if Chinese
     * 提示房间内谁正在说话及说话者瞬时音量的回调。
     * <br>该回调默认为关闭状态。可以通过 enableAudioVolumeIndication 方法开启。开启后，无论房间内是否有人说话，SDK 都会按 enableAudioVolumeIndication 方法中设置的时间间隔触发该回调。
     * <br>在返回的 speakers 数组中:
     * - 如果有 uid 出现在上次返回的数组中，但不在本次返回的数组中，则默认该 uid 对应的远端用户没有说话。
     * - 如果volume 为 0，表示该用户没有说话。
     *  - 如果speakers 数组为空，则表示此时远端没有人说话。
     * @param speakers          每个说话者的用户 ID 和音量信息的数组: NERtcAudioVolumeInfo
     * @param speaker_number    speakers 数组的大小，即说话者的人数。
     * @param total_volume      （混音后的）总音量，取值范围为 [0,100]。
     * @endif
     */
    virtual void onRemoteAudioVolumeIndication(const NERtcAudioVolumeInfo *speakers, unsigned int speaker_number, int total_volume) {
        (void)speakers;
        (void)speaker_number;
        (void)total_volume;
    }

    /** 
     * @if English
     * Notifies to add the result of live stream. 
     * <br>The callback asynchronously returns the callback result of \ref IRtcEngineEx::addLiveStreamTask "addLiveStreamTask".  For information about actual pushing state, see \ref IRtcEngineEventHandlerEx::onLiveStreamState "onLiveStreamState".
     * @param task_id       The ID of a stream-push task. 
     * @param url           Task ID. 
     * @param error_code    The result. 
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 通知添加直播任务结果。
     * <br>该回调异步返回 \ref IRtcEngineEx::addLiveStreamTask "addLiveStreamTask" 接口的调用结果；实际推流状态参考 \ref IRtcEngineEventHandlerEx::onLiveStreamState "onLiveStreamState"
     * @param task_id       任务id
     * @param url           推流地址
     * @param error_code    结果
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
     * @endif
     * @if Chinese
     * 通知直播推流状态
     * @note 该回调在通话中有效。
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
     * Occurs when howling is detected.
     * When the distance between the sound source and the PA equipment is too close, howling may occur. The NERTC SDK supports the howling detection. When a howling signal is detected, the callback is automatically triggered until the howling stops. The application layer can prompt the user to mute the microphone or directly mute the microphone when the app receives the howling information returned by the callback.
     * @note
     * Howling detection is used in audio-only scenarios, such as audio chat rooms or online meetings. We recommend that you do not use howling detection in entertainment scenes that include background music.
     * @param howling       Whether a howling occurs. 
     * - true: Howling occurs.
     * - false: Normal state.
     * @endif
     * @if Chinese
     * 检测到啸叫回调。
     * <br>如果检测到啸叫，会发送 onAudioHasHowling（true） 回调。周期性上报检测结果，无啸叫时返回 onAudioHasHowling（false）回调。
     * <br>当声源与扩音设备之间因距离过近时，可能会产生啸叫。NERTC SDK 支持啸叫检测，当检测到有啸叫信号产生的时候，自动触发该回调直至啸叫停止。App 应用层可以在收到啸叫回调时，提示用户静音麦克风，或直接静音麦克风。
     * @note
     * - 啸叫检测功能一般用于语音聊天室或在线会议等纯人声环境，不推荐在包含背景音乐的娱乐场景中使用。
     * - 在开启AI啸叫检测的情况下，回调会每隔几秒周期性触发，建议不要做过多其他的操作和调用，避免造成性能和逻辑问题。
     * @param howling       是否出现啸叫
     * - true: 啸叫。
     * - false: 正常。
     * @endif
     */
    virtual void onAudioHowling(bool howling) {
        (void)howling;
    }

    /** 
     * @if English
     * Occurs when the content of remote SEI is received.
     * <br>After a remote client successfully sends SEI, the local client receives a message returned by the callback.
     * @param[in] uid       The ID of the user who sends the SEI. 
	 * @param[in] data      The received SEI data.
	 * @param[in] dataSize  The size of received SEI data.
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
     * Returns the audio recording state.
     *  @param code         The status code of the audio recording. For more information, see NERtcAudioRecordingCode.
     * @param file_path     The path based on which the recording file is stored.
     * @endif
     * @if Chinese
     * 音频录制状态回调。
     * @param code          音频录制状态码。详细信息请参考 NERtcAudioRecordingCode。
     * @param file_path     音频录制文件保存路径。
     * @endif
     */
    virtual void onAudioRecording(NERtcAudioRecordingCode code, const char* file_path) {
        (void)code;
        (void)file_path;
    }

    /** 
     * @if English
     * Occurs when the state of the media stream is relayed. 
     * @since V4.3.0
     * @param state         The state of the media stream.
     * @param channel_name  The name of the destination room where the media streams are relayed. 
     * @endif
     * @if Chinese
     * 跨房间媒体流转发状态发生改变回调。
     * @since V4.3.0
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
     * @since V4.3.0
     * @param event         The media stream relay event.
     * @param channel_name  The name of the destination room where the media streams are relayed.
     * @param error         Specific error codes.
     * @endif
     * @if Chinese
     * 媒体流相关转发事件回调。
     * @since V4.3.0
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
     * @since V4.3.0
     * @param is_fallback   The locally published stream falls back to audio-only mode or switches back to audio and video stream.
     * - true: The published stream from a local client falls back to audio-only mode due to poor uplink network conditions.
     * - false: The audio stream switches back to the audio and video stream after the upstream network condition improves.
     * @param stream_type   The type of the video stream, such as mainstream and substream. 
     * @endif
     * @if Chinese
     * 本地发布流已回退为音频流、或已恢复为音视频流回调。
     * <br>如果您调用了设置本地推流回退选项 setLocalPublishFallbackOption 接口，并将 option 设置为 #kNERtcStreamFallbackAudioOnly 后，当上行网络环境不理想、本地发布的媒体流回退为音频流时，或当上行网络改善、媒体流恢复为音视频流时，会触发该回调。 
     * @since V4.3.0
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
     * @since V4.3.0
     * @param uid           The ID of a remote user.
     * @param is_fallback   The subscribed remote media stream falls back to audio-only mode or switches back to the audio and video stream. 
     * - true: The subscribed remote media stream falls back to audio-only mode due to poor downstream network conditions.
     * - false: The subscribed remote media stream switches back to the audio and video stream after the downstream network condition improves.
     * @param stream_type   The type of the video stream, such as mainstream and substream. 
     * @endif
     * @if Chinese
     * 订阅的远端流已回退为音频流、或已恢复为音视频流回调。
     * <br>如果你调用了设置远端订阅流回退选项 setRemoteSubscribeFallbackOption 接口并将 option 设置 #kNERtcStreamFallbackAudioOnly 后，当下行网络环境不理想、仅接收远端音频流时，或当下行网络改善、恢复订阅音视频流时，会触发该回调。
     * @since V4.3.0
     * @param uid           远端用户的 ID。
     * @param is_fallback   远端订阅流已回退或恢复：
     * - true： 由于网络环境不理想，订阅的远端流已回退为音频流。
     * - false：由于网络环境改善，订阅的远端流从音频流恢复为音视频流。
     * @param stream_type   对应的视频流类型，即主流或辅流。
     * @endif
     */
    virtual void onRemoteSubscribeFallbackToAudioOnly(uid_t uid, bool is_fallback, NERtcVideoStreamType stream_type) {
        (void)uid;
        (void)is_fallback;
    }

    /**
     * @if English 
     * Reports the last mile network quality of the local user once every two seconds before the user joins the channel.
     * <br> After the application calls the startLastmileProbeTest method, this callback reports once every five seconds the uplink and downlink last mile network conditions of the local user before the user joins the channel.
     * @since V4.5.0
     * @param quality       The last mile network quality.
     * @endif
     * @if Chinese
     * 通话前网络上下行 last mile 质量状态回调。
     * <br>该回调描述本地用户在加入房间前的 last mile 网络探测的结果，以打分形式描述上下行网络质量的主观体验，您可以通过该回调预估本地用户在音视频通话中的网络体验。
     * <br>在调用 startLastmileProbeTest 之后，SDK 会在约 5 秒内返回该回调。
     * @since V4.5.0
     * @param quality       网络上下行质量，基于上下行网络的丢包率和抖动计算，探测结果主要反映上行网络的状态。
     * @endif
     */
    virtual void onLastmileQuality(NERtcNetworkQualityType quality) { 
        (void)quality;
    }

    /** 
     * @if English 
     * Reports the last-mile network probe result.
     * <br>This callback describes a detailed last-mile network detection report of a local user before joining a channel. The report provides objective data about the upstream and downstream network quality, including network jitter and packet loss rate.  You can use the report to objectively predict the network status of local users during an audio and video call. 
     * <br>The SDK triggers this callback within 30 seconds after the app calls the startLastmileProbeTest method.
     * @since V4.5.0
     * @param result        The uplink and downlink last-mile network probe test result. 
     * @endif
     * @if Chinese
     * 通话前网络上下行 Last mile 质量探测报告回调。
     * <br>该回调描述本地用户在加入房间前的 last mile 网络探测详细报告，报告中通过客观数据反馈上下行网络质量，包括网络抖动、丢包率等数据。您可以通过该回调客观预测本地用户在音视频通话中的网络状态。
     * <br>在调用 startLastmileProbeTest 之后，SDK 会在约 30 秒内返回该回调。
     * @since V4.5.0
     * @param result        上下行 Last mile 质量探测结果。
     * @endif
     */
    virtual void onLastmileProbeResult(const NERtcLastmileProbeResult& result) { 
        (void)result; 
    };

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
     * @if English
     * Gets notified if the audio driver plug-in is installed (only for Mac)
     * <br> You can call {@link checkNECastAudioDriver} to install the audio driver plug-in and capture and play audio data in the Mac system
     * @param  result indicates the result of audio driver plug-in installation. For more information, see {@link NERtcInstallCastAudioDriverResult}.
     * @endif
     * @if Chinese
     * 收到检测安装声卡的内容回调（仅适用于 Mac 系统）。
     * <br> 在 Mac 系统上，您可以通过调用 checkNECastAudioDriver 为当前系统安装一个音频驱动，并让 SDK 通过该音频驱动捕获当前 Mac 系统播放出的声音。
     * @param  result 安装虚拟声卡的结果。详细信息请参考 {@link NERtcInstallCastAudioDriverResult}。
     * @endif
     */
    virtual void onCheckNECastAudioDriverResult(NERtcInstallCastAudioDriverResult result) {
        (void)result;
    }
    
    /**
     * @if English
     * Reports whether the virtual background is successfully enabled. (beta feature)
     * @since v4.6.0
     * After you call \ref IRtcEngine::enableVirtualBackground "enableVirtualBackground", the SDK triggers this callback
     * to report whether the virtual background is successfully enabled.
     * @note If the background image customized in the virtual background is in PNG or JPG format, the triggering of this
     * callback is delayed until the image is read.
     * @param enabled Whether the virtual background is successfully enabled:
     * - true: The virtual background is successfully enabled.
     * - false: The virtual background is not successfully enabled.
     * @param reason The reason why the virtual background is not successfully enabled or the message that confirms
     * success. See #NERtcVirtualBackgroundSourceStateReason.
     * @endif
     * @if Chinese
     * 通知虚拟背景功能是否成功启用的回调。
     * <br> 调用 \ref IRtcEngineEx::enableVirtualBackground "enableVirtualBackground" 方法后，SDK 返回此回调通知虚拟背景功能是否成功启用。
     * @since V4.6.0
     * @note 如果您设置虚拟背景为 PNG 或 JPG 格式的自定义图像，此回调会等到图像被完全读取后才会返回，因此会有一段时间的延迟。
     * @param enabled 是否成功启用虚拟背景。
     * - true：成功启用。
     * - false：未成功启用。
     * @param reason 虚拟背景功能未成功启用的原因或成功启用虚拟背景功能的通知。详细信息请参考 {@link NERtcVirtualBackgroundSourceStateReason}。
     * @endif
     */
    virtual void onVirtualBackgroundSourceEnabled(bool enabled, NERtcVirtualBackgroundSourceStateReason reason) {
      (void)enabled;
      (void)reason;
    }
    
    /**
     * @if English
     * Occurs when the local video watermark takes affect.
     * <br>If you enables the local video watermark by calling \ref nertc::IRtcEngineEx::setLocalVideoWatermarkConfigs "setLocalVideoWatermarkConfigs", the SDK will trigger this callback.
     * @since V4.6.10
     * @param videoStreamType Type of video stream, main stream or substream. For more information, see {@link video.NERtcVideoStreamType}.
     * @param state           Watermark status. For more information, see {@link NERtcConstants.NERtcLocalVideoWatermarkState}.
     * @endif
     * @if Chinese
     * 本地视频水印生效结果回调。
     * <br>调用 \ref nertc::IRtcEngineEx::setLocalVideoWatermarkConfigs "setLocalVideoWatermarkConfigs" 接口启用本地视频水印后，SDK 会触发此回调。
     * @since V4.6.10
     * @param videoStreamType 对应的视频流类型，即主流或辅流。详细信息请参考 {@link NERtcVideoStreamType}。
     * @param state           水印状态。详细信息请参考 {@link NERtcLocalVideoWatermarkState}。
     * @endif
     */
    virtual void onLocalVideoWatermarkState(NERtcVideoStreamType videoStreamType, NERtcLocalVideoWatermarkState state) {
        (void)videoStreamType;
        (void)state;
    }

	/**
     * @if English
     * The right key is about to expire.
     * Because the PermissionKey has a certain time effect, if the PermissionKey is about to expire during a call, the SDK
     * will trigger the callback in advance to remind the App to update the Token.
	 * When receiving the callback, the user needs to regenerate a new PermissionKey on the server,
	 * and then call ref IRtcEngineEx:: updatePermissionKey "updatePermissionKey" to transfer the newly generated PermissionKey to the SDK.
     * @param key      Permission key value.
     * @param error    Relevant error code. Please refer to # NERtcErrorCode for details.
     * @param timeout  Timeout, in seconds, valid when successful.
     * @endif
     * @if Chinese
     * 权限密钥即将过期事件回调。
     * - 由于 PermissionKey 具有一定的时效，在通话过程中如果 PermissionKey 即将失效，SDK 会提前 30 秒触发该回调，提醒用户更新 PermissionKey。
     * @since V4.6.29
     * @par 使用前提
     * 请在 IRtcEngineEventHandlerEx 接口类中通过 \ref IRtcEngine::initialize "initialize" 接口设置回调监听。
     * @par 相关接口
     * 在收到此回调后可以调用 \ref IRtcEngineEx::updatePermissionKey "updatePermissionKey" 方法更新权限密钥。
     * @endif
     */
    virtual void onPermissionKeyWillExpire() {}

    /**
     * @if English
     * Update authority key event callback.
     * @param key      Permission key value.
     * @param error    Relevant error code. Please refer to # NERtcErrorCode for details.
     * @param timeout  Timeout, in seconds, valid when successful.
     * @endif
     * @if Chinese
     * 更新权限密钥事件回调。
     * - 调用 \ref IRtcEngineEx::updatePermissionKey "updatePermissionKey"  方法主动更新权限密钥后，SDK 会触发该回调，返回权限密钥更新的结果。
     * @since V4.6.29
     * @par 使用前提
     * 请在 IRtcEngineEventHandlerEx 接口类中通过 \ref IRtcEngine::initialize "initialize" 接口设置回调监听。
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
     * @if English
     * Occurs when a remote user send data by data channel.
     * @param uid           The ID of a remote user.
     * @param pData    The received data channel data.
     * @param size      The size of received data channel data.
     * @endif
     * @if Chinese
     * 远端用户通过数据通道发送数据的回调。
     * @param uid           远端用户ID。
     * @param pData     数据。
     * @param size      接收数据长度。
     * @endif
     */
    virtual void onUserDataReceiveMessage(uid_t uid, void* pData, uint64_t size) {
        (void)uid;
        (void)pData;
        (void)size;
    };
      
    /**
     * @if English
     * Occurs when a remote user enables data channel.
     * @param uid           The ID of a remote user.
     * @since V5.0.0
     * @endif
     * @if Chinese
     * 远端用户开启数据通道的回调。
     * @param uid           远端用户ID。
     * @since V5.0.0
     * @endif
     */
    virtual void onUserDataStart(uid_t uid){
        (void)uid;
    };
    
    /**
     * @if English
     * Occurs when a remote user disables data channel.
     * @param uid           The ID of a remote user.
     * @endif
     * @if Chinese
     * 远端用户停用数据通道的回调。
     * @param uid           远端用户ID。
     * @endif
     */
    virtual void onUserDataStop(uid_t uid) {
        (void)uid;
    };

    /**
     * @if English
     * Occurs when a Remote user data channel status changed.
     * @param uid           The ID of a remote user.
     * @endif
     * @if Chinese
     * 远端用户数据通道状态变更回调。
     * @param uid           远端用户ID。
     * @endif
     */
    virtual void onUserDataStateChanged(uid_t uid) {
        (void)uid;
    };

    /**
     * @if English
     * Occurs when a Remote user data channel buffer amount changed.
     * @param uid             The ID of a remote user.
     * @param previousAmount  The amount before changed.
     * @endif
     * @if Chinese
     * 远端用户数据通道buffer变更回调。
     * @param uid             远端用户ID。
     * @param previousAmount  变更前大小。
     * @endif
     */
    virtual void onUserDataBufferedAmountChanged(uid_t uid, uint64_t previousAmount) {
        (void)uid;
        (void)previousAmount;
    };

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
