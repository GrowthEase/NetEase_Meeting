/** @file nertc_introduction.h
* @brief NERTC SDK接口概览。
* NERTC SDK所有接口参数说明: 所有与字符串相关的参数(char *)全部为UTF-8编码。
* @copyright (c) 2021, NetEase Inc. All rights reserved.
*/


/**
 @mainpage Introduction
 @brief <p>网易云信 NERTC SDK
 提供完善的音视频通话开发框架，提供基于网络的点对点视频通话和语音通话功能，还提供多人视频和音频会议功能，支持通话中音视频设备控制和实时音视频模式切换，支持视频采集数据回调以实现美颜等自定义功能。</p>

 - \ref nertc::IRtcEngine "IRtcEngine" 接口类包含应用程序调用的主要方法。
 - \ref nertc::IRtcEngineEx "IRtcEngineEx" 接口类包含应用程序调用的扩展方法。
 - \ref nertc::IRtcEngineEventHandler "IRtcEngineEventHandler" 接口类用于向应用程序发送回调通知。
 - \ref nertc::IRtcEngineEventHandlerEx "IRtcEngineEventHandlerEx" 接口类用于向应用程序发送扩展回调通知。
 - \ref nertc::IRtcMediaStatsObserver "IRtcMediaStatsObserver" 接口类用于向应用程序发送扩展的媒体回调通知。
 - \ref nertc::INERtcAudioFrameObserver "INERtcAudioFrameObserver" 接口类用于向应用程序发送音频数据帧回调通知。
 - \ref nertc::IAudioDeviceManager "IAudioDeviceManager" 接口类用于向应用程序使用音频设备相关功能方法。
 - \ref nertc::IVideoDeviceManager "IVideoDeviceManager" 接口类用于向应用程序使用视频设备相关功能方法。
 - \ref nertc::IRtcChannel "IRtcChannel" 类在指定房间中实现实时音视频功能。通过创建多个 IRtcChannel 对象，用户可以同时加入多个房间。
 - \ref nertc::IRtcChannelEventHandler "IRtcChannelEventHandler" 类监听和报告指定房间的事件和数据。
 
 ## 错误码
  
 在调用 SDK API 的过程中，SDK 可能会返回错误码或状态码，您可以根据错误码或状态码判断当前 SDK 或任务的状态。如果遇到未知的错误码，请联系技术支持排查。
 
 当前 SDK API 的错误码如下：
 - 通用错误码：{@link nertc::NERtcErrorCode}
 - 混音相关错误码：{@link nertc::NERtcAudioMixingErrorCode}
 - 视频水印状态码：{@link nertc::NERtcLocalVideoWatermarkState}
 - 警告码：{@link nertc::NERtcWarnCode}

 <h2 id="房间管理">房间管理</h2>

 <table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::createNERtcEngine "createNERtcEngine"</td>
    <td>创建 RTC 引擎对象。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::destroyNERtcEngine "destroyNERtcEngine"</td>
    <td>销毁 RTC 引擎对象。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::initialize "initialize"</td>
    <td>初始化 NERTC SDK 服务。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::release "release"</td>
    <td>销毁 IRtcEngine 对象。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getVersion "getVersion"</td>
    <td>查询 SDK 版本号。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::setChannelProfile "setChannelProfile"</td>
    <td>设置房间场景。</td>
    <td>V3.6.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::setClientRole "setClientRole"</td>
    <td>设置用户角色。</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::joinChannel(const char* token, const char* channel_name, uid_t uid) "joinChannel"</td>
    <td>加入房间。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::joinChannel(const char* token, const char* channel_name, uid_t uid, NERtcJoinChannelOptions channel_options) "joinChannel"</td>
    <td>加入房间，可以携带鉴权密钥等特定参数。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::leaveChannel "leaveChannel"</td>
    <td>离开房间。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::switchChannel "switchChannel"</td>
    <td>快速切换房间。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getConnectionState "getConnectionState"</td>
    <td>获取房间连接状态。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::queryInterface "queryInterface"</td>
    <td>获取设备管理员对象的指针。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setParameters "setParameters"</td>
    <td>设置音视频通话的相关参数。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::updatePermissionKey "updatePermissionKey"</td>
    <td>更新权限密钥。</td>
    <td>V4.6.29</td>
  </tr>
 </table>

 ## 房间事件
 
 <table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onClientRoleChanged "onClientRoleChanged"</td>
    <td>用户角色已切换回调。</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onJoinChannel "onJoinChannel"</td>
    <td>加入房间回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onRejoinChannel "onRejoinChannel"</td>
    <td>重新加入房间回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onLeaveChannel "onLeaveChannel"</td>
    <td>离开房间回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onUserJoined(uid_t uid, const char * user_name) "onUserJoined"</td>
    <td>远端用户加入当前房间回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onUserJoined(uid_t uid, const char* user_name, NERtcUserJoinExtraInfo join_extra_info) "onUserJoined"</td>
    <td>远端用户加入当前房间回调。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onUserLeft(uid_t uid, NERtcSessionLeaveReason reason) "onUserLeft"</td>
    <td>远端用户离开当前房间回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onUserLeft(uid_t uid, NERtcSessionLeaveReason reason, NERtcUserJoinExtraInfo leave_extra_info) "onUserLeft"</td>
    <td>远端用户离开当前房间回调。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onDisconnect "onDisconnect"</td>
    <td>服务器连接断开回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onReconnectingStart "onReconnectingStart"</td>
    <td>开始重连回调。</td>
    <td>V3.7.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onConnectionStateChange "onConnectionStateChange"</td>
    <td>房间连接状态已改变回调。</td>
    <td>V3.8.1</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onReleasedHwResources "onReleasedHwResources"</td>
    <td>通话结束设备资源释放回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onPermissionKeyWillExpire() "onPermissionKeyWillExpire"</td>
    <td>权限密钥即将过期事件回调。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUpdatePermissionKey() "onUpdatePermissionKey"</td>
    <td>更新权限密钥事件回调。</td>
    <td>V4.6.29</td>
  </tr>
</table>

 ## 音频管理

 <table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setAudioProfile "setAudioProfile"</td>
    <td>设置音频编码配置</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::adjustRecordingSignalVolume "adjustRecordingSignalVolume"</td>
    <td>调节采集信号音量。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::adjustPlaybackSignalVolume "adjustPlaybackSignalVolume"</td>
    <td>调节本地播放音量。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::adjustUserPlaybackSignalVolume "adjustUserPlaybackSignalVolume"</td>
    <td>调节本地播放的指定远端用户的信号音量。</td>
    <td>V4.2.1</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::enableLocalAudio "enableLocalAudio"</td>
    <td>开关本地音频采集</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::muteLocalAudioStream "muteLocalAudioStream"</td>
    <td>开关本地音频发送</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::subscribeRemoteAudioStream "subscribeRemoteAudioStream"</td>
    <td>订阅／取消订阅指定音频流。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::subscribeAllRemoteAudioStream "subscribeAllRemoteAudioStream"</td>
    <td>订阅或取消订阅所有音频流。 </td>
    <td>V4.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableLoopbackRecording "enableLoopbackRecording"</td>
    <td>开启声卡采集。</td>
    <td>V4.4.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::adjustLoopbackRecordingSignalVolume "adjustLoopbackRecordingSignalVolume"</td>
    <td>调节声卡采集信号音量。</td>
    <td>V4.4.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setRemoteHighPriorityAudioStream	"setRemoteHighPriorityAudioStream"</td>
    <td>设置远端用户音频流为高优先级。</td>
    <td>V4.6.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableLocalSubStreamAudio	"enableLocalSubStreamAudio" </td>
    <td>开启或关闭音频辅流</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::subscribeRemoteSubStreamAudio	"subscribeRemoteSubStreamAudio" </td>
    <td>订阅远端用户辅流</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::muteLocalSubStreamAudio	"muteLocalSubStreamAudio" </td>
    <td>静音本地音频辅流</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setAudioSubscribeOnlyBy	"setAudioSubscribeOnlyBy" </td>
    <td>设置本地用户音频只能被房间内其他指定用户订阅</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableMediaPub	"enableMediaPub" </td>
    <td>发布或停止发布本地音频</td>
    <td>V4.6.10</td>
  </tr>
</table>
 

 ## 视频管理
 
 <table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::enableLocalVideo(bool enabled) "enableLocalVideo"</td>
    <td>开启/关闭本地视频主流的采集与发送</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::enableLocalVideo(NERtcVideoStreamType type, bool enabled) "enableLocalVideo"</td>
    <td>开启/关闭本地视频主流或辅流的采集与发送</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setCameraCaptureConfig "setCameraCaptureConfig"</td>
    <td>设置摄像头采集配置</td>
    <td>V4.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setVideoConfig(const NERtcVideoConfig& config) "setVideoConfig"</td>
    <td>设置视频主流的编码属性</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setVideoConfig(NERtcVideoStreamType type, const NERtcVideoConfig& config) "setVideoConfig"</td>
    <td>设置视频主流或辅流编码属性</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setCameraCaptureConfig "setCameraCaptureConfig"</td>
    <td>设置视频主流的摄像头采集配置。</td>
    <td>V4.5.0</td>
    </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setCameraCaptureConfig(NERtcVideoStreamType type, const NERtcCameraCaptureConfig& config) "setCameraCaptureConfig"</td>
    <td>设置视频主流或辅流的摄像头采集配置</td>
    <td>V4.6.20</td>
    </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::setupLocalVideoCanvas "setupLocalVideoCanvas"</td>
    <td>设置本地用户视图</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::setupRemoteVideoCanvas "setupRemoteVideoCanvas"</td>
    <td>设置远端用户视图</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalRenderMode "setLocalRenderMode"</td>
    <td>设置本地视图显示模式</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setRemoteRenderMode "setRemoteRenderMode"</td>
    <td>设置远端视图显示模式</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startVideoPreview() "startVideoPreview"</td>
    <td>开启视频主流的预览</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startVideoPreview(NERtcVideoStreamType type) "startVideoPreview"</td>
    <td>开启视频主流或辅流的预览</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopVideoPreview() "stopVideoPreview"</td>
    <td>停止视频主流的预览</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopVideoPreview(NERtcVideoStreamType type) "stopVideoPreview"</td>
    <td>停止视频主流或辅流的预览</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::muteLocalVideoStream(bool mute) "muteLocalVideoStream"</td>
    <td>取消/恢复发布本地视频主流</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::muteLocalVideoStream(NERtcVideoStreamType type, bool mute) "muteLocalVideoStream"</td>
    <td>取消/恢复发布本地视频主流或辅流</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::subscribeRemoteVideoStream "subscribeRemoteVideoStream"</td>
    <td>订阅/取消订阅指定远端用户的视频流</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalVideoMirrorMode(NERtcVideoMirrorMode mirror_mode) "setLocalVideoMirrorMode"</td>
    <td>设置本地视频镜像模式</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalVideoMirrorMode(NERtcVideoStreamType type, NERtcVideoMirrorMode mirror_mode) "setLocalVideoMirrorMode"</td>
    <td>设置本地视频主流或辅流的镜像模式</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableSuperResolution "enableSuperResolution "</td>
    <td>启用或停止 AI 超分。</td>
    <td>V4.4.0</td>
  </tr>
</table>
 
<h2 id="本地媒体事件">本地媒体事件</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onFirstVideoDataReceived(uid_t uid) "onFirstVideoDataReceived"</td>
    <td>已显示远端主流视频首帧的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onFirstVideoDataReceived(NERtcVideoStreamType type, uid_t uid) "onFirstVideoDataReceived"</td>
    <td>已显示远端主流或辅流视频首帧的回调</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onFirstAudioDataReceived "onFirstAudioDataReceived"</td>
    <td>已接收到远端音频首帧回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onFirstAudioFrameDecoded "onFirstAudioFrameDecoded"</td>
    <td>已解码远端音频首帧的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onFirstVideoFrameDecoded(uid_t uid, uint32_t width, uint32_t height) "onFirstVideoFrameDecoded"</td>
    <td>已接收到远端主流视频首帧并完成解码的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onFirstVideoFrameDecoded(NERtcVideoStreamType type, uid_t uid, uint32_t width, uint32_t height) "onFirstVideoFrameDecoded"</td>
    <td>已接收到远端主流或辅流视频首帧并完成解码的回调</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onMediaRightChange	"onMediaRightChange"</td>
    <td>服务端禁言音视频权限变化回调。</td>
    <td>V4.6.0</td>
  </tr>
</table>

<h2 id="远端媒体事件">远端媒体事件</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onUserAudioStart "onUserAudioStart"</td>
    <td>远端用户开启音频主流回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUserSubStreamAudioStart "onUserSubStreamAudioStart"</td>
    <td>远端用户开启音频辅流回调</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onUserAudioStop "onUserAudioStop"</td>
    <td>远端用户停用音频主流回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUserSubStreamAudioStop "onUserSubStreamAudioStop"</td>
    <td>远端用户停用音频辅流回调</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onUserVideoStart "onUserVideoStart"</td>
    <td>远端用户开启视频回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onUserVideoStop "onUserVideoStop"</td>
    <td>远端用户停用视频回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUserVideoProfileUpdate "onUserVideoProfileUpdate"</td>
    <td>远端用户视频配置更新回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUserAudioMute "onUserAudioMute"</td>
    <td>远端用户是否静音主流回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUserSubStreamAudioMute "onUserSubStreamAudioMute"</td>
    <td>远端用户是否静音辅流回调</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUserVideoMute(uid_t uid, bool mute) "onUserVideoMute"</td>
    <td>远端用户暂停或恢复发送视频主流的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUserVideoMute(NERtcVideoStreamType videoStreamType, uid_t uid, bool mute) "onUserVideoMute"</td>
    <td>远端用户暂停或恢复发送视频主流或辅流的回调</td>
    <td>V4.6.20</td>
  </tr>
</table>

<h2 id="数据统计事件">数据统计事件</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcMediaStatsObserver::onRemoteAudioStats "onRemoteAudioStats"</td>
    <td>通话中远端音频流的统计信息回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcMediaStatsObserver::onRtcStats "onRtcStats"</td>
    <td>当前通话统计回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcMediaStatsObserver::onNetworkQuality "onNetworkQuality"</td>
    <td>通话中每个用户的网络上下行质量报告回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcMediaStatsObserver::onLocalAudioStats "onLocalAudioStats"</td>
    <td>本地音频流统计信息回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcMediaStatsObserver::onLocalVideoStats "onLocalVideoStats"</td>
    <td>本地视频流统计信息回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcMediaStatsObserver::onRemoteVideoStats "onRemoteVideoStats"</td>
    <td>通话中远端视频流的统计信息回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setStatsObserver "setStatsObserver"</td>
    <td>注册统计信息观测器</td>
    <td>V3.5.0</td>
  </tr>
</table>

<h2 id="屏幕共享">屏幕共享</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startScreenCaptureByDisplayId "startScreenCaptureByDisplayId"</td>
    <td>开启屏幕共享，共享范围为指定屏幕的指定区域。该方法仅适用于 macOS 和 Windows 平台。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startScreenCaptureByScreenRect "startScreenCaptureByScreenRect"</td>
    <td>开启屏幕共享，共享范围为指定屏幕的指定区域。该方法仅适用于 Windows 平台。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startScreenCaptureByWindowId "startScreenCaptureByWindowId"</td>
    <td>开启屏幕共享，共享范围为指定窗口的指定区域。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setExcludeWindowList "setExcludeWindowList"</td>
    <td>设置共享指定屏幕或屏幕区域时，需要屏蔽的窗口列表。</td>
    <td>V4.2.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::updateScreenCaptureRegion "updateScreenCaptureRegion"</td>
    <td>更新屏幕共享区域。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pauseScreenCapture "pauseScreenCapture"</td>
    <td>暂停屏幕共享。</td>
    <td>V3.7.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::resumeScreenCapture "resumeScreenCapture"</td>
    <td>恢复屏幕共享。</td>
    <td>V3.7.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopScreenCapture "stopScreenCapture"</td>
    <td>停止屏幕共享。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setupLocalSubStreamVideoCanvas "setupLocalSubStreamVideoCanvas"</td>
    <td>设置本端的辅流视频回放画布</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalSubStreamRenderMode "setLocalSubStreamRenderMode"</td>
    <td>设置本端的辅流渲染缩放模式</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setupRemoteSubStreamVideoCanvas "setupRemoteSubStreamVideoCanvas"</td>
    <td>设置远端的辅流视频回放画布</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setRemoteSubSteamRenderMode "setRemoteSubSteamRenderMode"</td>
    <td>设置远端的屏幕共享辅流视频渲染缩放模式</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::subscribeRemoteVideoSubStream "subscribeRemoteVideoSubStream"</td>
    <td>订阅或取消订阅远端的屏幕共享辅流视频，订阅之后才能接收远端的辅流视频数据</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setScreenCaptureMouseCursor "setScreenCaptureMouseCursor"</td>
    <td>设置共享屏幕时是否显示鼠标</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setScreenCaptureSource "setScreenCaptureSource"</td>
    <td>设置屏幕共享参数</td>
    <td>V5.5.20</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getScreenCaptureSources "getScreenCaptureSources"</td>
    <td>获得一个可以共享的屏幕和窗口的列表</td>
    <td>V5.5.20</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::isFeatureSupported "isFeatureSupported"</td>
    <td>查询当前设备是否支持 NERtc SDK 的某项功能</td>
    <td>V5.5.20</td>
  </tr>
</table>

<h2 id="美颜">美颜</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startBeauty "startBeauty" </td>
    <td>（仅 Windows）开启美颜功能模块</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref NERtcBeauty::startBeauty "startBeauty" </td>
    <td>（仅 macOS）开启美颜功能模块</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopBeauty "stopBeauty"  </td>
    <td>（仅 Windows）结束美颜功能模块</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref NERtcBeauty::stopBeauty "stopBeauty"  </td>
    <td>（仅 macOS）结束美颜功能模块</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableBeauty "enableBeauty" </td>
    <td>（仅 Windows）暂停或恢复美颜效果</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref NERtcBeauty::isOpenBeauty "isOpenBeauty" </td>
    <td>（仅 macOS）暂停或恢复美颜效果</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setBeautyEffect "setBeautyEffect"  </td>
    <td>（仅 Windows）设置美颜效果</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#setBeautyEffectWithValue:atType:} </td>
    <td>（仅 macOS）设置美颜效果</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#addTempleteWithPath:andName:}  </td>
    <td>（仅 macOS）导入美颜资源或模型</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getBeautyEffect "getBeautyEffect"  </td>
    <td>（仅 Windows）获取指定美颜类型的强度设置</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::addBeautyFilter "addBeautyFilter" </td>
    <td>（仅 Windows）添加滤镜效果</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#addBeautyFilterWithPath:andName:} </td>
    <td>（仅 macOS）添加滤镜效果</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::removeBeautyFilter "removeBeautyFilter" </td>
    <td>（仅 Windows）移除滤镜</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref NERtcBeauty::removeBeautyFilter "removeBeautyFilter" </td>
    <td>（仅 macOS）移除滤镜</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setBeautyFilterLevel "setBeautyFilterLevel" </td>
    <td>（仅 Windows）设置滤镜强度</td>
    <td>V4.6.10</td>
  </tr>
</table>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUserSubStreamVideoStart "onUserSubStreamVideoStart"</td>
    <td>远端用户开启屏幕共享辅流通道的回调</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUserSubStreamVideoStop "onUserSubStreamVideoStop"</td>
    <td>远端用户停止屏幕共享辅流通道的回调</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onScreenCaptureStatus "onScreenCaptureStatus"</td>
    <td>屏幕共享状态变化回调。该方法仅适用于 Windows 平台。</td>
    <td>V4.2.0</td>
  </tr>
</table>


## 多房间管理

| <div style="width:400px">方法</div> | <div style="width:400px">功能</div> | <div style="width:200px">起始版本</div> |
|---|---|:---|
| \ref nertc::IRtcEngineEx::createChannel "createChannel"  | 创建并获取一个 NERtcChannel 对象。通过创建多个对象，用户可以同时加入多个频道。 | V4.5.0 |
| \ref nertc::IRtcChannel "IRtcChannel"  | 该类提供在指定频道内实现实时音视频功能的方法。 | V4.5.0 |
| \ref nertc::IRtcChannelEventHandler "IRtcChannelEventHandler"  | 该类提供监听指定频道事件和数据的回调。 | V4.5.0 |


<h2 id="伴音">音乐文件播放及混音（伴音）</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startAudioMixing "startAudioMixing"</td>
    <td>开始播放伴音</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopAudioMixing "stopAudioMixing"</td>
    <td>停止播放伴音</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pauseAudioMixing "pauseAudioMixing"</td>
    <td>暂停播放伴音</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::resumeAudioMixing "resumeAudioMixing"</td>
    <td>恢复播放伴音</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setAudioMixingPlaybackVolume "setAudioMixingPlaybackVolume"</td>
    <td>设置伴音的播放音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setAudioMixingSendVolume "setAudioMixingSendVolume"</td>
    <td>设置伴音的发送音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setAudioMixingPitch "setAudioMixingPitch"</td>
    <td>设置伴音的音调</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getAudioMixingPitch "getAudioMixingPitch"</td>
    <td>获取伴音的音调</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getAudioMixingSendVolume "getAudioMixingSendVolume"</td>
    <td>获取伴音的发送音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getAudioMixingDuration "getAudioMixingDuration"</td>
    <td>获取伴音的总长度</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getAudioMixingCurrentPosition "getAudioMixingCurrentPosition"</td>
    <td>获取伴音的播放进度</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setAudioMixingPosition "setAudioMixingPosition"</td>
    <td>设置伴音的播放进度</td>
    <td>V3.5.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onAudioMixingStateChanged "onAudioMixingStateChanged"</td>
    <td>本地用户的音乐文件播放状态改变回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onAudioMixingTimestampUpdate "onAudioMixingTimestampUpdate"</td>
    <td>本地用户的音乐文件播放进度回调</td>
    <td>V3.5.0</td>
  </tr>
</table>


<h2 id="音效文件播放管理">音效文件播放管理</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getEffectPlaybackVolume "getEffectPlaybackVolume"</td>
    <td>获取音效文件播放音量。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setEffectPlaybackVolume "setEffectPlaybackVolume"</td>
    <td>设置音效文件播放音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::playEffect "playEffect"</td>
    <td>播放指定音效文件</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopEffect "stopEffect"</td>
    <td>停止播放指定音效文件</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopAllEffects "stopAllEffects"</td>
    <td>停止播放所有音效文件</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pauseEffect "pauseEffect"</td>
    <td>暂停音效文件播放</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pauseAllEffects "pauseAllEffects"</td>
    <td>暂停所有音效文件播放</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::resumeEffect "resumeEffect"</td>
    <td>恢复播放指定音效文件</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::resumeAllEffects "resumeAllEffects"</td>
    <td>恢复播放所有音效文件</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setEffectSendVolume "setEffectSendVolume"</td>
    <td>调节音效文件发送音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getEffectSendVolume "getEffectSendVolume"</td>
    <td>获取音效文件发送音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setEffectPitch "setEffectPitch"</td>
    <td>设置音效文件音调</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getEffectPitch "getEffectPitch"</td>
    <td>获取音效文件音调</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getEffectDuration "getEffectDuration"</td>
    <td>获取音效文件的总长度</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getEffectCurrentPosition "getEffectCurrentPosition"</td>
    <td>获取音效文件的播放进度</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setEffectPosition "setEffectPosition"</td>
    <td>设置音效文件的播放进度</td>
    <td>V4.6.29</td>
  </tr>
</table>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onAudioEffectFinished "onAudioEffectFinished"</td>
    <td>本地音效文件播放已结束回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onAudioEffectTimestampUpdate "onAudioEffectTimestampUpdate"</td>
    <td>本地音效文件播放进度回调</td>
    <td>V4.6.29</td>
  </tr>
</table>


<h2 id="变声与混响">变声与混响</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setAudioEffectPreset "setAudioEffectPreset"</td>
    <td>设置 SDK 预设的人声的变声音效。</td>
    <td>4.1.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setVoiceBeautifierPreset "setVoiceBeautifierPreset"</td>
    <td>设置 SDK 预设的美声效果。</td>
    <td>4.0.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalVoiceEqualization "setLocalVoiceEqualization"</td>
    <td>设置本地语音音效均衡，即自定义设置本地人声均衡波段的中心频率。</td>
    <td>4.0.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalVoicePitch "setLocalVoicePitch"</td>
    <td>设置本地语音音调。</td>
    <td>4.1.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalVoiceReverbParam "setLocalVoiceReverbParam"</td>
    <td>开启本地语音混响效果。</td>
    <td>4.6.10</td>
  </tr>
</table>

<h2 id="旁路推流">旁路推流</h2>

注意：该组方法仅适用于互动直播 2.0。

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::addLiveStreamTask "addLiveStreamTask"</td>
    <td>添加房间推流任务</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::updateLiveStreamTask "updateLiveStreamTask"</td>
    <td>更新修改房间推流任务</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::removeLiveStreamTask "removeLiveStreamTask"</td>
    <td>删除房间推流任务</td>
    <td>V3.5.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onAddLiveStreamTask "onAddLiveStreamTask"</td>
    <td>通知添加直播任务结果</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUpdateLiveStreamTask "onUpdateLiveStreamTask"</td>
    <td>通知更新直播任务结果</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onRemoveLiveStreamTask "onRemoveLiveStreamTask"</td>
    <td>通知删除直播任务结果</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onLiveStreamState "onLiveStreamState"</td>
    <td>通知直播推流状态</td>
    <td>V3.5.0</td>
  </tr>
 </table>

<h2 id="跨房间流媒体转发">跨房间流媒体转发</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startChannelMediaRelay "startChannelMediaRelay" </td>
    <td>开始跨房间媒体流转发。</td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::updateChannelMediaRelay "updateChannelMediaRelay"</td>
    <td>更新媒体流转发的目标房间。</td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopChannelMediaRelay "stopChannelMediaRelay"</td>
    <td>停止跨房间媒体流转发。</td>
    <td>V4.3.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onMediaRelayStateChanged "onMediaRelayStateChanged"</td>
    <td>跨房间媒体流转发状态发生改变回调。</td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onMediaRelayEvent "onMediaRelayEvent" </td>
    <td> 媒体流相关转发事件回调。</td>
    <td>V4.3.0</td>
  </tr>
</table>

<h2 id="媒体补充增强信息">媒体补充增强信息</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::sendSEIMsg(const char* data, int length) "sendSEIMsg" [1/2]</td>
    <td>通过主流通道发送媒体补充增强信息。</td>
    <td>V4.0.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::sendSEIMsg(const char* data, int length, NERtcVideoStreamType type) "sendSEIMsg" [2/2]</td>
    <td>发送媒体补充增强信息。<p>通过本接口可指定发送 SEI 时使用主流或辅流通道。</td>
    <td>V4.0.0</td>
  </tr>
  </table>

  <table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onRecvSEIMsg "onRecvSEIMsg"</td>
    <td>收到远端流的媒体补充增强信息回调。</td>
    <td>V4.0.0</td>
  </tr>
</table>

 <h2 id="音量提示">音量提示</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication"</td>
    <td>启用说话者音量提示</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableAudioVolumeIndication(bool enable, uint64_t interval, bool enable_vad) "enableAudioVolumeIndication"</td>
    <td>启用说话者音量及本地是否有人声提示</td>
    <td>V4.6.10</td>
  </tr>
</table>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onRemoteAudioVolumeIndication "onRemoteAudioVolumeIndication"</td>
    <td>提示房间内谁正在说话及说话者音量的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onLocalAudioVolumeIndication "onLocalAudioVolumeIndication"</td>
    <td>提示房间内本地用户瞬时音量的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onLocalAudioVolumeIndication(int volume, bool enable_vad) "onLocalAudioVolumeIndication"</td>
    <td>提示房间内本地用户瞬时音量及是否存在人声的回调</td>
    <td>V4.6.10</td>
  </tr>
</table>

 <h2 id="耳返">耳返</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableEarback "enableEarback"</td>
    <td>开启耳返功能</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setEarbackVolume "setEarbackVolume"</td>
    <td>设置耳返音量</td>
    <td>V3.5.0</td>
  </tr>
</table>

 <h2 id="视频大小流">视频大小流</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableDualStreamMode "enableDualStreamMode"</td>
    <td>设置是否开启视频大小流模式。</td>
    <td>V3.5.0</td>
  </tr>
</table>

 <h2 id="音视频流回退">音视频流回退</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalPublishFallbackOption "setLocalPublishFallbackOption"</td>
    <td>设置弱网条件下发布的音视频流回退选项。</td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setRemoteSubscribeFallbackOption "setRemoteSubscribeFallbackOption"</td>
    <td>设置弱网条件下订阅的音视频流回退选项。</td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalMediaPriority "setLocalMediaPriority"</td>
    <td>设置本地用户的媒体流优先级。</td>
    <td>V4.2.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onLocalPublishFallbackToAudioOnly "onLocalPublishFallbackToAudioOnly"</td>
    <td>本地发布流已回退为音频流或恢复为音视频流回调。</td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onRemoteSubscribeFallbackToAudioOnly "onRemoteSubscribeFallbackToAudioOnly"</td>
    <td>远端订阅流已回退为音频流或恢复为音视频流回调</td>
    <td>V4.3.0</td>
  </tr>
 </table>

 
 ## 通话前网络测试

| <div style="width:400px">方法</div> | <div style="width:400px">功能</div> | <div style="width:200px">起始版本</div> |
|---|---|:---:|
| \ref nertc::IRtcEngineEx::startLastmileProbeTest "startLastmileProbeTest" | 开始通话前网络质量探测。 | V4.5.0 |
| \ref nertc::IRtcEngineEx::stopLastmileProbeTest "stopLastmileProbeTest"| 停止通话前网络质量探测。 | V4.5.0 |


| <div style="width:400px">事件</div> | <div style="width:400px">描述</div> | <div style="width:200px">起始版本</div> |
|---|---|:---:|
| \ref nertc::IRtcEngineEventHandlerEx::onLastmileQuality "onLastmileQuality" | 报告本地用户的网络质量。 | V4.5.0 |
| \ref nertc::IRtcEngineEventHandlerEx::onLastmileProbeResult "onLastmileProbeResult" | 报告通话前网络上下行 last mile 质量。 | V4.5.0 |


 <h2 id="自定义音频采集与渲染">自定义音频采集与渲染</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setExternalAudioSource "setExternalAudioSource"</td>
    <td>启用外部自定义音频数据主流输入功能，并设置采集参数。</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setExternalSubStreamAudioSource "setExternalSubStreamAudioSource"</td>
    <td>启用外部自定义音频数据辅流输入功能，并设置采集参数。</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pushExternalAudioFrame "pushExternalAudioFrame"</td>
    <td>将外部音频主流数据帧推送给内部引擎。</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pushExternalSubStreamAudioFrame "pushExternalSubStreamAudioFrame"</td>
    <td>将外部音频辅流数据帧推送给内部引擎。</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setExternalAudioRender "setExternalAudioRender"</td>
    <td>设置外部音频渲染。</td>
    <td>V4.0.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pullExternalAudioFrame "pullExternalAudioFrame"</td>
    <td>拉取外部音频数据。</td>
    <td>V4.0.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setStreamAlignmentProperty "setStreamAlignmentProperty"</td>
    <td>对齐本地系统时间与服务端时间。</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getNtpTimeOffset "getNtpTimeOffset" </td>
    <td>获取本地系统时间与服务端时间的差值。</td>
    <td>V4.6.10</td>
  </tr>
</table>

 <h2 id="自定义视频采集">自定义视频采集</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setExternalVideoSource(bool enabled) "setExternalVideoSource"</td>
    <td>开启/关闭外部视频源数据输入主流通道</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setExternalVideoSource(NERtcVideoStreamType type, bool enabled) "setExternalVideoSource"</td>
    <td>开启/关闭外部视频源数据输入主流或辅流通道</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pushExternalVideoFrame(NERtcVideoFrame* frame) "pushExternalVideoFrame"</td>
    <td>推送外部视频帧至主流通道</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pushExternalVideoFrame(NERtcVideoStreamType type, NERtcVideoFrame* frame) "pushExternalVideoFrame"</td>
    <td>推送外部视频帧至主流或辅流通道</td>
    <td>V4.6.20</td>
  </tr>
</table>

<h2 id="音视频裸流传输">音视频裸流传输</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setPreDecodeObserver "setPreDecodeObserver" </td>
    <td>注册解码前媒体数据观测器。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pushExternalAudioEncodedFrame "pushExternalAudioEncodedFrame" </td>
    <td>推送外部音频主流编码帧。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pushExternalSubStreamAudioEncodedFrame "pushExternalSubStreamAudioEncodedFrame" </td>
    <td>推送外部音频辅流编码帧。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pushExternalVideoEncodedFrame "pushExternalVideoEncodedFrame" </td>
    <td>推送外部视频编码帧。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setVideoEncoderQosObserver "setVideoEncoderQosObserver"</td>
    <td>注册视频编码 QoS 信息监听器。</td>
    <td>V4.6.29</td>
  </tr>
</table>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::INERtcPreDecodeObserver::onFrame "onFrame" </td>
    <td>解码前媒体数据回调。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> \ref nertc::INERtcVideoEncoderQosObserver::onRequestSendKeyFrame "onRequestSendKeyFrame" </td>
    <td>I 帧请求事件回调。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> \ref nertc::INERtcVideoEncoderQosObserver::onVideoCodecUpdated "onVideoCodecUpdated" </td>
    <td>视频编码器类型信息回调。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> \ref nertc::INERtcVideoEncoderQosObserver::onBitrateUpdated "onBitrateUpdated" </td>
    <td>码率信息回调。</td>
    <td>V4.6.29</td>
  </tr>
</table>

<h2 id="原始音频数据">原始音频数据</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setRecordingAudioFrameParameters "setRecordingAudioFrameParameters"</td>
    <td>设置录制的声音格式</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setPlaybackAudioFrameParameters "setPlaybackAudioFrameParameters"</td>
    <td>设置播放的声音格式</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setAudioFrameObserver "setAudioFrameObserver"</td>
    <td>注册语音观测器对象</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setMixedAudioFrameParameters "setMixedAudioFrameParameters"</td>
    <td>设置采集和播放后的混合后的采样率。需要在加入房间之前调用该接口</td>
    <td>V3.5.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::INERtcAudioFrameObserver::onAudioFrameDidRecord "onAudioFrameDidRecord"</td>
    <td>采集音频数据回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::INERtcAudioFrameObserver::onAudioFrameWillPlayback "onAudioFrameWillPlayback"</td>
    <td>播放音频数据回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::INERtcAudioFrameObserver::onMixedAudioFrame "onMixedAudioFrame"</td>
    <td>音频采集与播放混合后数据帧回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::INERtcAudioFrameObserver::onPlaybackAudioFrameBeforeMixing "onPlaybackAudioFrameBeforeMixing" [1/2]</td>
    <td>某一远端用户的原始音频帧回调。<br> 该接口即将废弃，请改用 \ref nertc::INERtcAudioFrameObserver::onPlaybackAudioFrameBeforeMixing(uint64_t userID, NERtcAudioFrame* frame, channel_id_t cid) "onPlaybackAudioFrameBeforeMixing" [2/2]。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::INERtcAudioFrameObserver::onPlaybackAudioFrameBeforeMixing(uint64_t userID, NERtcAudioFrame* frame, channel_id_t cid) "onPlaybackAudioFrameBeforeMixing" [2/2]</td>
    <td>某一远端用户的原始音频帧回调。</td>
    <td>V4.5.0</td>
  </tr>
</table>

 <h2 id="原始视频数据">原始视频数据</h2>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onCaptureVideoFrame "onCaptureVideoFrame"</td>
    <td>采集视频数据回调。</td>
    <td>V3.5.0</td>
  </tr>
</table>

 <h2 id="截图">截图</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::takeLocalSnapshot "takeLocalSnapshot"</td>
    <td>本地视频画面截图。</td>
    <td>V4.2.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::takeRemoteSnapshot "takeRemoteSnapshot"</td>
    <td>远端视频画面截图。</td>
    <td>V4.2.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::NERtcTakeSnapshotCallback::onTakeSnapshotResult "onTakeSnapshotResult"</td>
    <td>截图结果回调。</td>
    <td>V4.2.0</td>
  </tr>
</table>

 <h2 id="水印">水印</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalVideoWatermarkConfigs "setLocalVideoWatermarkConfigs"</td>
    <td>添加本地视频水印。</td>
    <td>V4.6.10</td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onLocalVideoWatermarkState "onLocalVideoWatermarkState"</td>
    <td>水印结果回调。</td>
    <td>V4.6.10</td>
  </tr>
</table>

 <h2 id="加密">加密</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableEncryption "enableEncryption"</td>
    <td>开启或关闭媒体流加密。</td>
    <td>V4.4.0</td>
  </tr>
</table>

<h2 id="客户端音频录制">客户端音频录制</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startAudioRecording "startAudioRecording"</td>
    <td>开始客户端录音。</td>
    <td>V4.2.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startAudioRecordingWithConfig "startAudioRecordingWithConfig"</td>
    <td>开始客户端录音。</td>
    <td>V4.6.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopAudioRecording "stopAudioRecording"</td>
    <td>停止客户端录音。</td>
    <td>V4.2.0</td>
  </tr>
</table>


<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onAudioRecording "onAudioRecording"</td>
    <td>音频录制状态回调。</td>
    <td>V4.2.0</td>
  </tr>
</table>

 <h2 id="虚拟背景">虚拟背景</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableVirtualBackground "enableVirtualBackground"</td>
    <td>开启或关闭虚拟背景。</td>
    <td>V4.6.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onVirtualBackgroundSourceEnabled "onVirtualBackgroundSourceEnabled"</td>
    <td>通知虚拟背景功能是否成功启用的回调。</td>
    <td>V4.6.0</td>
  </tr>
</table>


 <h2 id="云代理">云代理</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setCloudProxy "setCloudProxy"</td>
    <td>开启并设置云代理服务。</td>
    <td>V4.6.0</td>
  </tr>
</table>

 <h2 id="音频设备管理">音频设备管理</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::enumerateRecordDevices "enumerateRecordDevices"</td>
    <td>枚举音频采集设备</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::setRecordDevice "setRecordDevice"</td>
    <td>设置音频采集设备</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::getRecordDevice "getRecordDevice"</td>
    <td>获取当前音频采集设备</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::enumeratePlayoutDevices "enumeratePlayoutDevices"</td>
    <td>枚举音频播放设备</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::setPlayoutDevice "setPlayoutDevice"</td>
    <td>设备音频播放设备</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::getPlayoutDevice "getPlayoutDevice"</td>
    <td>获取当前音频播放设备</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::setRecordDeviceVolume "setRecordDeviceVolume"</td>
    <td>设置当前音频采集设备音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::getRecordDeviceVolume "getRecordDeviceVolume"</td>
    <td>获取当前音频采集设备音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::setPlayoutDeviceVolume "setPlayoutDeviceVolume"</td>
    <td>设置当前音频播放设备音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::getPlayoutDeviceVolume "getPlayoutDeviceVolume"</td>
    <td>获取当前音频播放设备音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::setPlayoutDeviceMute "setPlayoutDeviceMute"</td>
    <td>设置当前播放设备静音状态</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::getPlayoutDeviceMute "getPlayoutDeviceMute"</td>
    <td>获取当前播放设备静音状态</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::setRecordDeviceMute "setRecordDeviceMute"</td>
    <td>设置当前采集设备静音状态</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::getRecordDeviceMute "getRecordDeviceMute"</td>
    <td>获取当前采集设备静音状态</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::startRecordDeviceTest "startRecordDeviceTest"</td>
    <td>开始测试音频采集设备</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::stopRecordDeviceTest "stopRecordDeviceTest"</td>
    <td>停止测试音频采集设备</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::startPlayoutDeviceTest "startPlayoutDeviceTest"</td>
    <td>开始测试音频播放设备</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::stopPlayoutDeviceTest "stopPlayoutDeviceTest"</td>
    <td>停止测试音频播放设备</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::startAudioDeviceLoopbackTest "startAudioDeviceLoopbackTest"</td>
    <td>开始音频采集播放设备回路测试</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::stopAudioDeviceLoopbackTest "stopAudioDeviceLoopbackTest"</td>
    <td>停止音频采集播放设备回路测试</td>
    <td>V3.5.0</td>
  </tr>
</table>

 <table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onAudioHowling "onAudioHowling"</td>
    <td>检测到啸叫回调。</td>
    <td>V3.9.0</td>
  </tr>
</table>

 <h2 id="视频设备管理">视频设备管理</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IVideoDeviceManager::enumerateCaptureDevices "enumerateCaptureDevices"</td>
    <td>枚举视频采集设备</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IVideoDeviceManager::setDevice "setDevice"</td>
    <td>设置视频采集设备</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> \ref nertc::IVideoDeviceManager::getDevice "getDevice"</td>
    <td>获取当前视频采集设备</td>
    <td>V4.6.20</td>
  </tr>
</table>

 <h2 id="设备管理事件">设备管理事件</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onAudioDeviceStateChanged "onAudioDeviceStateChanged"</td>
    <td>音频设备状态更改回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onAudioDefaultDeviceChanged "onAudioDefaultDeviceChanged"</td>
    <td>音频默认设备更改回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onVideoDeviceStateChanged "onVideoDeviceStateChanged"</td>
    <td>视频设备状态更改回调</td>
    <td>V3.5.0</td>
  </tr>
</table>


 <h2 id="空间音效（3D 音效）和范围语音">空间音效（3D 音效）和范围语音</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
    </tr>
    <tr>
    <td> \ref nertc::IRtcEngineEx::initSpatializer "initSpatializer"  </td>
    <td>初始化空间音效</td>
    <td>V5.5.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableSpatializer "enableSpatializer" </td>
    <td>开启/关闭空间音效</td>
    <td>V5.4.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setAudioRecvRange "setAudioRecvRange"</td>
    <td>设置空间音效的距离衰减属性和语音范围</td>
    <td>V5.4.0</td>
  </tr>
  <tr>
    <td>\ref nertc::IRtcEngineEx::setSpatializerRoomProperty "setSpatializerRoomProperty"</td>
    <td>设置房间混响属性</td>
    <td>V5.4.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableSpatializerRoomEffects "enableSpatializerRoomEffects"</td>
    <td>开启或关闭空间音效的房间混响效果</td>
    <td>V5.4.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::updateSelfPosition "updateSelfPosition"</td>
    <td>设置说话者和接收者的位置信息</td>
    <td>V5.5.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setSpatializerRenderMode "setSpatializerRenderMode"</td>
    <td>设置渲染模式</td>
    <td>V5.4.0</td>
  </tr>
    <tr>
    <td> \ref nertc::IRtcEngineEx::setRangeAudioTeamID "setRangeAudioTeamID"  </td>
    <td>设置范围语音的队伍号</td>
    <td>V5.5.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setRangeAudioMode "setRangeAudioMode"  </td>
    <td>设置范围语音的模式</td>
    <td>V5.5.10</td>
  </tr>
  </tr>
    </tr>
    <tr>
    <td> \ref nertc::IRtcEngineEx::setSubscribeAudioAllowlist "setSubscribeAudioAllowlist"  </td>
    <td>设置只订阅指定用户的音频流</td>
    <td>V5.5.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setSubscribeAudioBlocklist "setSubscribeAudioBlocklist"  </td>
    <td>设置不订阅指定用户的音频流</td>
    <td>V5.5.10</td>
  </tr>
</table>
 

 <h2 id="故障排查">故障排查</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startAudioDump "startAudioDump"</td>
    <td>开始记录音频 dump。</td>
    <td>V3.5.0</td>
  </tr>
    <tr>
    <td> \ref nertc::IRtcEngineEx::startAudioDump(NERtcAudioDumpType type) "startAudioDump"</td>
    <td>开始记录音频 dump。</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopAudioDump "stopAudioDump"</td>
    <td>结束记录音频 dump</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getErrorDescription "getErrorDescription"</td>
    <td>获取错误描述。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::uploadSdkInfo "uploadSdkInfo"</td>
    <td>上传SDK日志信息</td>
    <td>V3.5.0</td>
  </tr>
</table>

 <table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onError "onError"</td>
    <td>发生错误回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onWarning "onWarning"</td>
    <td>发生警告回调</td>
    <td>V3.5.0</td>
  </tr>
</table>

*/

/**
 @defgroup createNERtcEngine Create an NERTC Engine
 */
