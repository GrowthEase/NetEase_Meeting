/** @file nertc_introduction.h
* @brief NERTC SDK APIs overview.
* NERTC SDK all API references: All string-typed parameters (char *) are all UTF-8 encoded.
* @copyright (c) 2021, NetEase Inc. All rights reserved.
*/


/**
 @mainpage Introduction
 @brief<p> CommsEase NERTC SDK
 provides a comprehensive Real-time Communication (RTC) development platform that allows developers to implement Internet-based peer-to-peer audio and video calls, and group audio and video conferencing. The SDK enables users to manage audio and video devices and switch audio and video modes during calls. The SDK also implements capturing video data callbacks and offers additional features, such as personalized image enhancement. </p>

 - \ref nertc::IRtcEngine "IRtcEngine" interface classes that contain main methods invoked by applications.
 - \ref nertc::IRtcEngineEx "IRtcEngineEx" interface classes that contain extension methods invoked by applications
 - \ref nertc::IRtcEngineEventHandler "IRtcEngineEventHandler" interface classes used to return notifications sent by callbacks to applications.
 - \ref nertc::IRtcEngineEventHandlerEx "IRtcEngineEventHandlerEx" interface classes used to return notifications sent by extension callbacks to applications.
 - \ref nertc::IRtcMediaStatsObserver "IRtcMediaStatsObserver” interface classes used to return notifications about media stats to applications.
 - \ref nertc::INERtcAudioFrameObserver "INERtcAudioFrameObserver” interface classes used to return audio data frames sent by callbacks to applications.
 - \ref nertc::IAudioDeviceManager "IAudioDeviceManager" interface classes that provide methods to handle audio devices for applications.
 - \ref nertc::IVideoDeviceManager "IVideoDeviceManager" interface classes that provide methods to handle video devices for applications.
 - The \ref nertc::IRtcChannel "IRtcChannel" classes used to implement audio and video calling in a specified room. Users can join multiple rooms by creating multiple IRtcChannel objects.
 - The \ref nertc::IRtcChannelEventHandler "IRtcChannelEventHandler” classes used to listen for and report events and data for a specified room.
 
 ## Error codes
  
 The SDK may return error codes or status codes when your app calls APIs. You can learn about the SDK status or specific tasks based on the information provided by the error codes or status codes. If unknown errors are returned, you can contact our technical support for help.
 
 The error codes of the current SDK APIs are as follows:
 - Common error codes: {@link nertc::NERtcErrorCode}
 - Error codes for room services: {@link nertc::NERtcRoomServerErrorCode}
 - Error codes for mixing audio: {@link nertc::NERtcAudioMixingErrorCode}
 - Error codes for audio and video devices: {@link nertc::NERtcDMErrorCode}
 - Error codes for video watermarks: {@link nertc::NERtcLocalVideoWatermarkState}
 - Warning code: {@link nertc::NERtcWarnCode}

 <h2 id="Room management">Room management</h2>

 <table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::createNERtcEngine "createNERtcEngine"</td>
    <td> Creates an RTC engine object. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::destroyNERtcEngine "destroyNERtcEngine"</td>
    <td> Destroys the RTC engine object. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::initialize "initialize"</td>
    <td> Initializes the NERTC SDK. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::release "release"</td>
    <td>Destroys an IRtcEngine object. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getVersion "getVersion"</td>
    <td> Querys the SDK version number. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::setChannelProfile "setChannelProfile"</td>
    <td>Sets a room scene. </td>
    <td>V3.6.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::setClientRole "setClientRole"</td>
    <td>Sets the role of a user.</td> </td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::joinChannel "joinChannel"</td>
    <td>Joins a channel.</td> </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::leaveChannel "leaveChannel"</td>
    <td> Leaves a channel. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::switchChannel "switchChannel"</td>
    <td> Switches to a channel. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getConnectionState "getConnectionState"</td>
    <td>Gets the connection state of a channel. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::queryInterface "queryInterface"</td>
    <td> Gets a pointer to the device as administrator. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setParameters "setParameters"</td>
    <td> Sets parameters for audio and video calls. </td>
    <td>V3.5.0</td>
  </tr>
 </table>

 ## Room event
 
 <table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onClientRoleChanged "onClientRoleChanged"</td>
    <td>Occurs when a user changes the role in live streaming. </td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onJoinChannel "onJoinChannel"</td>
    <td> Occurs when a user joins a channel. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onRejoinChannel "onRejoinChannel"</td>
    <td> Occurs when a user rejoins a room. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onLeaveChannel "onLeaveChannel"</td>
    <td> Occurs when a user leaves a room. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onUserJoined "onUserJoined"</td>
    <td> Occurs when a remote user joins the current room. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onUserLeft "onUserLeft"</td>
    <td> Occurs when a remote user leaves a room. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onDisconnect "onDisconnect"</td>
    <td> Occurs when the server becomes disconnected. callback. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onReconnectingStart "onReconnectingStart"</td>
    <td>Occurs when reconnection starts. </td>
    <td>V3.7.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onConnectionStateChange "onConnectionStateChange"</td>
    <td>Occurs when connection state changes. </td>
    <td>V3.8.1</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onReleasedHwResources "onReleasedHwResources"</td>
    <td>Occurs when a call ends and device resources are released. </td>
    <td>V3.5.0</td>
  </tr>
</table>

 ## Audio management

 <table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setAudioProfile "setAudioProfile"</td>
    <td> Sets the audio profile.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::adjustRecordingSignalVolume "adjustRecordingSignalVolume"</td>
    <td> Adjusts the volume of captured signals. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::adjustPlaybackSignalVolume "adjustPlaybackSignalVolume"</td>
    <td>Adjusts the local playback volume.</td> </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::adjustUserPlaybackSignalVolume "adjustUserPlaybackSignalVolume"</td>
    <td> Adjusts the local playback volume of the stream from a specified remote user. </td>
    <td>V4.2.1</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::enableLocalAudio "enableLocalAudio"</td>
    <td> Stops or resumes local audio capture.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::muteLocalAudioStream "muteLocalAudioStream"</td>
    <td> Mutes or unmutes local audio.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::subscribeRemoteAudioStream "subscribeRemoteAudioStream"</td>
    <td> Subscribes to or unsubscribes from all remote audio streams. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::subscribeAllRemoteAudioStream "subscribeAllRemoteAudioStream"</td>
    <td> Subscribes to or unsubscribes from all remote audio streams.</td> </td>
    <td>V4.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableLoopbackRecording "enableLoopbackRecording"</td>
    <td>Enables the capture from a sound card. </td>
    <td>V4.4.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::adjustLoopbackRecordingSignalVolume "adjustLoopbackRecordingSignalVolume"</td>
    <td> Adjusts the volume of signals captured from a sound card. </td>
    <td>V4.4.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setRemoteHighPriorityAudioStream	"setRemoteHighPriorityAudioStream"</td>
    <td>Sets high priority to a remote audio stream. </td>
    <td>V4.6.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableLocalSubStreamAudio	"enableLocalSubStreamAudio" </td>
    <td> Enables or disables the audio substream.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::subscribeRemoteSubStreamAudio	"subscribeRemoteSubStreamAudio" </td>
    <td> Subscribes to the audio substream from a specified remote user.
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::muteLocalSubStreamAudio	"muteLocalSubStreamAudio" </td>
    <td> Mutes the local audio substream.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setAudioSubscribeOnlyBy	"setAudioSubscribeOnlyBy" </td>
    <td>Allows the local audio stream to be subscribed by specified users in the room</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableMediaPub	"enableMediaPub" </td>
    <td> Publishes or unpublishes the local audio stream.</td>
    <td>V4.6.10</td>
  </tr>
</table>
 

 ## Video management
 
 <table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::enableLocalVideo "enableLocalVideo" [1/2]</td>
    <td> Enables or disables the local video stream.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setCameraCaptureConfig "setCameraCaptureConfig"</td>
    <td>Sets the configuration for capturing data from a camera</td>
    <td>V4.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setVideoConfig "setVideoConfig" [1/2]</td>
    <td> Sets the local video configuration.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::enableLocalVideo(NERtcVideoStreamType type, bool enabled) "enableLocalVideo" [2/2]</td>
    <td>Enables or disables the local video stream (mainstream or substream). </td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setVideoConfig "setVideoConfig" [1/2]</td>
    <td>Sets the local video configuration. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setVideoConfig(NERtcVideoStreamType type, const NERtcVideoConfig& config) "setVideoConfig" [2/2]</td>
    <td>Sets the local video mainstream or substream configuration. </td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setCameraCaptureConfig "setCameraCaptureConfig" [1/2]</td>
    <td>Sets the camera capture preference.</td>
    <td>V4.5.0</td>
    </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setCameraCaptureConfig(NERtcVideoStreamType type, const NERtcCameraCaptureConfig& config) "setCameraCaptureConfig" [2/2]</td>
    <td>Sets the camera capture preference of mainstream or substream.</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::setupLocalVideoCanvas "setupLocalVideoCanvas"</td>
    <td>Sets the local video canvas.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::setupRemoteVideoCanvas "setupRemoteVideoCanvas"</td>
    <td> Sets the remote video canvas. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalRenderMode "setLocalRenderMode"</td>
    <td> Sets the rendering mode for the local video stream.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setRemoteRenderMode "setRemoteRenderMode"</td>
    <td> Sets the rendering mode of a remote video stream.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startVideoPreview "startVideoPreview"</td>
    <td> Starts video preview.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopVideoPreview "stopVideoPreview"</td>
    <td> Stops video preview</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::muteLocalVideoStream "muteLocalVideoStream" [1/2]</td>
    <td> Stops or resumes publishing the local video stream.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::muteLocalVideoStream(NERtcVideoStreamType type, bool mute) "muteLocalVideoStream" [2/2]</td>
    <td>Stops/Resumes sending the local video stream. </td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngine::subscribeRemoteVideoStream "subscribeRemoteVideoStream"</td>
    <td> Subscribes to or unsubscribes from video streams from specified remote users.
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalVideoMirrorMode "setLocalVideoMirrorMode" [1/2]</td>
    <td> Sets the mirroring mode for the local video stream.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalVideoMirrorMode(NERtcVideoStreamType type, NERtcVideoMirrorMode mirror_mode) "setLocalVideoMirrorMode" [2/2]</td>
    <td>Sets the mirror mode of the local video mainstream or substream. </td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableSuperResolution "enableSuperResolution "</td>
    <td> Enables or disables AI super resolution. </td>
    <td>V4.4.0</td>
  </tr>
</table>
 
<h2 id="Local media events">Local media events</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onFirstVideoDataReceived "onFirstVideoDataReceived"</td>
    <td>Occurs when the first video frame from a remote user is received</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onFirstAudioDataReceived "onFirstAudioDataReceived"</td>
    <td>Occurs when the first audio frame from a remote user is received.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onFirstAudioFrameDecoded "onFirstAudioFrameDecoded"</td>
    <td> Occurs when the first audio frame from a remote user is decoded.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onFirstVideoFrameDecoded "onFirstVideoFrameDecoded"</td>
    <td>Occurs when the first audio frame from a remote user is decoded.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onMediaRightChange	"onMediaRightChange"</td>
    <td>Occurs when audio and video permissions are changed on the server side.</td> </td>
    <td>V4.6.0</td>
  </tr>
</table>

<h2 id="Remote media event">Remote media event</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onUserAudioStart "onUserAudioStart"</td>
    <td> Occurs when a remote user publishes the audio mainstream.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUserSubStreamAudioStart "onUserSubStreamAudioStart"</td>
    <td> Occurs when a remote user publishes the audio substream.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onUserAudioStop "onUserAudioStop"</td>
    <td> Occurs when a remote user unpublishes the audio mainstream.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUserSubStreamAudioStop "onUserSubStreamAudioStop"</td>
    <td> Occurs when a remote user unpublishes the audio substream.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onUserVideoStart "onUserVideoStart"</td>
    <td> Occurs when a remote user publishes the video stream.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onUserVideoStop "onUserVideoStop"</td>
    <td> Occurs when a remote user unpublishes the video stream<td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUserVideoProfileUpdate "onUserVideoProfileUpdate"</td>
    <td> Occurs when the configuration of video streams from a remote user are updated</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUserAudioMute "onUserAudioMute"</td>
    <td> Occurs when a remote user mutes the audio.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUserSubStreamAudioMute "onUserSubStreamAudioMute"</td>
    <td> Occurs when a remote user mutes the audio substream.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUserVideoMute "onUserVideoMute"</td>
    <td> Occurs when a remote user mutes the video.</td>
    <td>V3.5.0</td>
  </tr>
</table>

<h2 id="Stats event">Stats event</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcMediaStatsObserver::onRemoteAudioStats "onRemoteAudioStats"</td>
    <td> Occurs when the stats of the remote audio stream in the call are collected.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcMediaStatsObserver::onRtcStats "onRtcStats"</td>
    <td> Occurs when the stats for the current call is collected.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcMediaStatsObserver::onNetworkQuality "onNetworkQuality"</td>
    <td> Occurs when the stats of uplink and downlink network quality for each user are reported during the call</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcMediaStatsObserver::onLocalAudioStats "onLocalAudioStats"</td>
    <td> Occurs when the stats of the local audio stream are collected.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcMediaStatsObserver::onLocalVideoStats "onLocalVideoStats"</td>
    <td> Occurs when the stats of the local video stream are collected.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcMediaStatsObserver::onRemoteVideoStats "onRemoteVideoStats"</td>
    <td> Occurs when the stats of the video stream in the call are collected.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setStatsObserver "setStatsObserver"</td>
    <td> Registers the stats observer.</td>
    <td>V3.5.0</td>
  </tr>
</table>

<h2 id="Screen sharing">Screen sharing</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startScreenCaptureByDisplayId "startScreenCaptureByDisplayId"</td>
    <td>Enables screen sharing. The sharing view port is the specified area of a specified screen. This method is only supported on macOS. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startScreenCaptureByScreenRect "startScreenCaptureByScreenRect"</td>
    <td>Enables screen sharing. The sharing view port is the specified area of a specified screen. This method is only supported on Windows. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startScreenCaptureByWindowId "startScreenCaptureByWindowId"</td>
    <td>Enables screen sharing. The sharing view port is the specified area of a specified window. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setExcludeWindowList "setExcludeWindowList"</td>
    <td>Sets the list of windows to be blocked when sharing the specified screen or screen area. </td>
    <td>V4.2.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::updateScreenCaptureRegion "updateScreenCaptureRegion"</td>
    <td> Updates the screen sharing area. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pauseScreenCapture "pauseScreenCapture"</td>
    <td> Pauses screen sharing. </td>
    <td>V3.7.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::resumeScreenCapture "resumeScreenCapture"</td>
    <td> Resumes screen sharing. </td>
    <td>V3.7.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopScreenCapture "stopScreenCapture"</td>
    <td> Stops screen sharing. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setupLocalSubStreamVideoCanvas "setupLocalSubStreamVideoCanvas"</td>
    <td> Sets a playback canvas for local video substream.</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalSubStreamRenderMode "setLocalSubStreamRenderMode"</td>
    <td> Sets the rendering mode of a local video substream.</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setupRemoteSubStreamVideoCanvas "setupRemoteSubStreamVideoCanvas"</td>
    <td> Sets a playback canvas for remote video substream.</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setRemoteSubSteamRenderMode "setRemoteSubSteamRenderMode"</td>
    <td> Sets the rendering mode of a remote video substream for screen sharing.</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::subscribeRemoteVideoSubStream "subscribeRemoteVideoSubStream"</td>
    <td> Subscribes to or unsubscribes from the remote video substream for screen sharing. You can receive the video substream data only after you subscribe to the remote video substream. </td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setScreenCaptureMouseCursor "setScreenCaptureMouseCursor"</td>
    <td>Specifies whether to display the mouse pointer during screen sharing</td>
    <td>V4.6.10</td>
  </tr>
</table>

<h2 id="Beauty">Beauty</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startBeauty "startBeauty" </td>
    <td>(Windows only) Enables the beauty module.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref NERtcBeauty::startBeauty "startBeauty" </td>
    <td>(macOS only) Enables the beauty module.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopBeauty "stopBeauty"  </td>
    <td>(Windows only) Stops the beauty module.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref NERtcBeauty::stopBeauty "stopBeauty"  </td>
    <td>(macOS only) Stops the beauty module.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableBeauty "enableBeauty" </td>
    <td>(Windows only) Pauses or resumes beauty effects</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref NERtcBeauty::isOpenBeauty "isOpenBeauty" </td>
    <td>(macOS only) Pauses or resumes beauty effects</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setBeautyEffect "setBeautyEffect"  </td>
    <td>(Windows only) Sets a beauty effect</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#setBeautyEffectWithValue:atType:} </td>
    <td>(macOS only) Sets a beauty effect</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#addTempleteWithPath:andName:}  </td>
    <td>(macOS only) Imports beauty assets or models</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getBeautyEffect "getBeautyEffect"  </td>
    <td>(Windows only) Gets the intensity setting for the specified beauty type</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::addBeautyFilter "addBeautyFilter" </td>
    <td>(Windows only) Adds a filter effect</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#addBeautyFilterWithPath:andName:} </td>
    <td>(macOS only) Adds a filter effect</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::removeBeautyFilter "removeBeautyFilter" </td>
    <td>(Windows only) Removes a filter</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref NERtcBeauty::removeBeautyFilter "removeBeautyFilter" </td>
    <td>(macOS only) Removes a filter</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setBeautyFilterLevel "setBeautyFilterLevel" </td>
    <td>(Windows only) Sets a filter intensity</td>
    <td>V4.6.10</td>
  </tr>
</table>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUserSubStreamVideoStart "onUserSubStreamVideoStart"</td>
    <td> Occurs when a remote user starts screen sharing through the substream.</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUserSubStreamVideoStop "onUserSubStreamVideoStop"</td>
    <td> Occurs when a remote user stops screen sharing through the substream.</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onScreenCaptureStatus "onScreenCaptureStatus"</td>
    <td> Occurs when the screen sharing state changes. This method is only supported on Windows. </td>
    <td>V4.2.0</td>
  </tr>
</table>


## Multiple room management

| <div style="width:400px">Method</div> | <div style="width:400px">Description</div> | <div style="width:200px">Supported version</div> |
|---|---|:---|
| \ref nertc::IRtcEngineEx::createChannel "createChannel"  | Creates and gets a NERtcChannel  object. Users can join multiple channels by creating multiple NERtcChannel objects. | V4.5.0 |
| \ref nertc::IRtcChannel "IRtcChannel"  | The classes provide methods to implement audio and video calling in a specified room. | V4.5.0 |
| \ref nertc::IRtcChannelEventHandler "IRtcChannelEventHandler" | The classes provide callbacks for listening to events and data from specified channels. | V4.5.0 |


<h2 id="Music file playback and mixing">Music file playback and mixing</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startAudioMixing "startAudioMixing"</td>
    <td> Starts to play a music file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopAudioMixing "stopAudioMixing"</td>
    <td> Stops playing a music file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pauseAudioMixing "pauseAudioMixing"</td>
    <td> Pauses playing a music file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::resumeAudioMixing "resumeAudioMixing"</td>
    <td> Resumes playing a music file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setAudioMixingPlaybackVolume "setAudioMixingPlaybackVolume"</td>
    <td> Sets the playback volume of a music file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setAudioMixingSendVolume "setAudioMixingSendVolume"</td>
    <td> Sets the publishing volume of a music file.
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getAudioMixingPlaybackVolume "getAudioMixingPlaybackVolume"</td>
    <td> Gets the playback volume of a music file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getAudioMixingSendVolume "getAudioMixingSendVolume"</td>
    <td>Get the publishing volume of a music file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getAudioMixingDuration "getAudioMixingDuration"</td>
    <td> Gets the total duration of a music file</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getAudioMixingCurrentPosition "getAudioMixingCurrentPosition"</td>
    <td> Sets the playback position of a music file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setAudioMixingPosition "setAudioMixingPosition"</td>
    <td> Gets the current playback position of a music file.</td>
    <td>V3.5.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onAudioMixingStateChanged "onAudioMixingStateChanged"</td>
    <td> Occurs when the playback status of a local music file changes.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onAudioMixingTimestampUpdate "onAudioMixingTimestampUpdate"</td>
    <td> Occurs when the timestamp of a music file is updated.</td>
    <td>V3.5.0</td>
  </tr>
</table>


<h2 id="Audio effect file playback management">Audio effect file playback management</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getEffectPlaybackVolume "getEffectPlaybackVolume"</td>
    <td> Gets the playback volume of an audio effect file. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setEffectPlaybackVolume "setEffectPlaybackVolume"</td>
    <td> Sets the playback volume of an audio effect file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::playEffect "playEffect"</td>
    <td> Plays back a specified audio effect file</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopEffect "stopEffect"</td>
    <td> Stops playing a specified audio effect file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopAllEffects "stopAllEffects"</td>
    <td> Stops playing all audio effect files.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pauseEffect "pauseEffect"</td>
    <td> Pauses the playback of an audio effect file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pauseAllEffects "pauseAllEffects"</td>
    <td> Pauses all audio file playback</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::resumeEffect "resumeEffect"</td>
    <td> Resumes playing back a specified audio effect file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::resumeAllEffects "resumeAllEffects"</td>
    <td> Resumes playing back all audio effect files.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setEffectSendVolume "setEffectSendVolume"</td>
    <td> Adjusts the publishing volume of a effect file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getEffectSendVolume "getEffectSendVolume"</td>
    <td>Gets the publishing volume of an effect file.</td>
    <td>V3.5.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onAudioEffectFinished "onAudioEffectFinished"</td>
    <td> Occurs when the playback of an audio effect file ends</td>
    <td>V3.5.0</td>
  </tr>
</table>


<h2 id="Voice change and reverberation">Voice change and reverberation</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setAudioEffectPreset "setAudioEffectPreset"</td>
    <td> Sets a voice change effect preset by the SDK. </td>
    <td>4.1.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setVoiceBeautifierPreset "setVoiceBeautifierPreset"</td>
    <td> Sets an voice beautifier effect preset by the SDK. </td>
    <td>4.0.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalVoiceEqualization "setLocalVoiceEqualization"</td>
    <td> Sets the local voice equalization effect. You can customize the center frequencies of the local voice effects. </td>
    <td>4.0.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalVoicePitch "setLocalVoicePitch"</td>
    <td> Sets the voice pitch of a local voice. </td>
    <td>4.1.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalVoiceReverbParam "setLocalVoiceReverbParam"</td>
    <td>Enables the local reverb effect. </td>
    <td>4.6.10</td>
  </tr>
</table>

<h2 id="CDN relayed streaming">CDN relayed streaming</h2>

Note: This methods are applicable only to Interactive Live Streaming v2.0.

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::addLiveStreamTask "addLiveStreamTask"</td>
    <td> Adds a streaming task in a room.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::updateLiveStreamTask "updateLiveStreamTask"</td>
    <td> Updates a streaming task in a room.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::removeLiveStreamTask "removeLiveStreamTask"</td>
    <td> Deletes a streaming task in a room.</td>
    <td>V3.5.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onAddLiveStreamTask "onAddLiveStreamTask"</td>
    <td>Occurs when a live streaming task is added.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onUpdateLiveStreamTask "onUpdateLiveStreamTask"</td>
    <td>Occurs when a live streaming task is updated.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onRemoveLiveStreamTask "onRemoveLiveStreamTask"</td>
    <td>Occurs when a live streaming task is deleted.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onLiveStreamState "onLiveStreamState"</td>
    <td> Gets notified of live streaming status.</td>
    <td>V3.5.0</td>
  </tr>
 </table>

<h2 id="Media stream relay across channels">Media stream relay across channels</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startChannelMediaRelay "startChannelMediaRelay" </td>
    <td> Starts relaying media streams across channels.</td> </td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::updateChannelMediaRelay "updateChannelMediaRelay"</td>
    <td> Updates the information about the destination room to which the media stream is relayed. </td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopChannelMediaRelay "stopChannelMediaRelay"</td>
    <td> Stops media stream relay across rooms. </td>
    <td>V4.3.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onMediaRelayStateChanged "onMediaRelayStateChanged"</td>
    <td> Occurs when the status of media stream relay changes. </td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onMediaRelayEvent "onMediaRelayEvent" </td>
    <td>Occurs when events about media stream relay are triggered. </td>
    <td>V4.3.0</td>
  </tr>
</table>

<h2 id="Media SEI">Media SEI</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::sendSEIMsg(const char* data, int length) "sendSEIMsg" [1/2]</td>
    <td> Sends supplemental enhancement information (SEI) messages through the bigtream. </td>
    <td>V4.0.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::sendSEIMsg(const char* data, int length, NERtcVideoStreamType type) "sendSEIMsg" [2/2]</td>
    <td> Sends SEI messages. <p> You can use the mainstream or substream to send SEI messages by calling this method. </td>
    <td>V4.0.0</td>
  </tr>
  </table>

  <table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onRecvSEIMsg "onRecvSEIMsg"</td>
    <td> Occurs when the remote stream SEI messages are received. </td>
    <td>V4.0.0</td>
  </tr>
</table>

 <h2 id="Volume reminder">Volume reminder</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableAudioVolumeIndication "enableAudioVolumeIndication"</td>
    <td> Enables volume indication for the current speaker. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableAudioVolumeIndication(bool enable, uint64_t interval, bool enable_vad) "enableAudioVolumeIndication"</td>
    <td> Enables volume indication for the current speaker and voice detection. </td>
    <td>V4.6.10</td>
  </tr>
</table>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onRemoteAudioVolumeIndication "onRemoteAudioVolumeIndication"</td>
    <td> Occurs when the system indicates the active speaker and the audio volume.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onLocalAudioVolumeIndication "onLocalAudioVolumeIndication"</td>
    <td> Occurs when the system indicates current local audio volume in the room.
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onLocalAudioVolumeIndication(int volume, bool enable_vad) "onLocalAudioVolumeIndication"</td>
    <td> Occurs when the system indicates current local audio volume in the room and detects voice activities.</td>
    <td>V4.6.10</td>
  </tr>
</table>

 <h2 id="In-ears monitoring">In-ears monitoring</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableEarback "enableEarback"</td>
    <td> enables the in-ear monitoring feature.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setEarbackVolume "setEarbackVolume"</td>
    <td> Sets the volume for in-ear monitoring.</td>
    <td>V3.5.0</td>
  </tr>
</table>

 <h2 id="Video dual stream mode">Video dual stream mode</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableDualStreamMode "enableDualStreamMode"</td>
    <td> Enables or disables the video dual stream mode. </td>
    <td>V3.5.0</td>
  </tr>
</table>

 <h2 id="Audio and video stream fallback">Audio and video stream fallback</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalPublishFallbackOption "setLocalPublishFallbackOption"</td>
    <td> Sets the fallback option for the published local video stream for unreliable network conditions. </td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setRemoteSubscribeFallbackOption "setRemoteSubscribeFallbackOption"</td>
    <td> Sets the fallback option for the subscribed remote audio and video stream for unreliable network conditions. </td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalMediaPriority "setLocalMediaPriority"</td>
    <td> Sets the priority of local media streams. </td>
    <td>V4.2.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onLocalPublishFallbackToAudioOnly "onLocalPublishFallbackToAudioOnly"</td>
    <td> Occurs when the published local media stream falls back to an audio-only stream or switches back to an audio and video stream. </td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onRemoteSubscribeFallbackToAudioOnly "onRemoteSubscribeFallbackToAudioOnly"</td>
    <td> Occurs when the subscribed remote media stream falls back to an audio-only stream or to an audio and video stream.</td>
    <td>V4.3.0</td>
  </tr>
 </table>

 
 ## Network probe testing before calling

| <div style="width:400px">Method</div> | <div style="width:400px">Description</div> | <div style="width:200px">Supported version</div> |
|---|---|:---:|
| \ref nertc::IRtcEngineEx::startLastmileProbeTest "startLastmileProbeTest" | Starts a probe test before calling. | V4.5.0 |
| \ref nertc::IRtcEngineEx::stopLastmileProbeTest "stopLastmileProbeTest"| Stops a probe test before calling. | V4.5.0 |


| <div style="width:400px">Event</div> | <div style="width:400px">Description</div> | <div style="width:200px"> Supported version</div> |
|---|---|:---:|
| \ref nertc::IRtcEngineEventHandlerEx::onLastmileQuality "onLastmileQuality" | Reports the network quality of a local user. | V4.5.0 |
| \ref nertc::IRtcEngineEventHandlerEx::onLastmileProbeResult "onLastmileProbeResult" | Reports the upstream and downstream last mile network quality before calling. | V4.5.0 |


 <h2 id="External audio source capture and rendering">External audio source capture and rendering</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setExternalAudioSource "setExternalAudioSource"</td>
    <td> Enables external source for the audio mainstream and sets the capture parameters. </td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setExternalSubStreamAudioSource "setExternalSubStreamAudioSource"</td>
    <td> Enables external source for the audio substream and sets the capture parameters. </td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pushExternalAudioFrame "pushExternalAudioFrame"</td>
    <td> Pushes the mainstream audio data captured from the external audio source to the internal audio engine.</td> </td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pushExternalSubStreamAudioFrame "pushExternalSubStreamAudioFrame"</td>
    <td> Pushes the substream audio data captured from the external audio source to the internal audio engine.</td> </td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setExternalAudioRender "setExternalAudioRender"</td>
    <td> Sets external audio rendering. </td>
    <td>V4.0.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pullExternalAudioFrame "pullExternalAudioFrame"</td>
    <td> Pulls the external audio data </td>
    <td>V4.0.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setStreamAlignmentProperty "setStreamAlignmentProperty"</td>
    <td> Syncs the local system time with the server time. </td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getNtpTimeOffset "getNtpTimeOffset" </td>
    <td>Gets the difference between the local system time and the server time. </td>
    <td>V4.6.10</td>
  </tr>
</table>

 <h2 id="External video source capture">External video source capture</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setExternalVideoSource "setExternalVideoSource"</td>
    <td> Configure external video source.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::pushExternalVideoFrame "pushExternalVideoFrame"</td>
    <td> Pushes the external video frame data captured from the external video source.</td>
    <td>V3.5.0</td>
  </tr>
</table>

<h2 id="Raw audio data">Raw audio data</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setRecordingAudioFrameParameters "setRecordingAudioFrameParameters"</td>
    <td> Sets the audio recording format.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setPlaybackAudioFrameParameters "setPlaybackAudioFrameParameters"</td>
    <td> Sets the audio playback format.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setAudioFrameObserver "setAudioFrameObserver"</td>
    <td> Registers the audio frame observer.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setMixedAudioFrameParameters "setMixedAudioFrameParameters"</td>
    <td> Sets the sample rate of the mixed stream after the audio is captured and playback. You must call this method before you join a room.
    <td>V3.5.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::INERtcAudioFrameObserver::onAudioFrameDidRecord "onAudioFrameDidRecord"</td>
    <td> Retrieves the audio data captured. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::INERtcAudioFrameObserver::onAudioFrameWillPlayback "onAudioFrameWillPlayback"</td>
    <td> Retrieves the audio playback data. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::INERtcAudioFrameObserver::onMixedAudioFrame "onMixedAudioFrame"</td>
    <td> Retrieves the mixed recorded and playback audio frame.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::INERtcAudioFrameObserver::onPlaybackAudioFrameBeforeMixing "onPlaybackAudioFrameBeforeMixing" [1/2]</td>
    <td>Returns the raw audio frames of a remote user. <br> The API is deprecated. Use \ref nertc::INERtcAudioFrameObserver::onPlaybackAudioFrameBeforeMixing(uint64_t userID, NERtcAudioFrame* frame, channel_id_t cid) "onPlaybackAudioFrameBeforeMixing" [2/2] instead. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::INERtcAudioFrameObserver::onPlaybackAudioFrameBeforeMixing(uint64_t userID, NERtcAudioFrame* frame, channel_id_t cid) "onPlaybackAudioFrameBeforeMixing" [2/2]</td>
    <td>Returns the raw audio frames of a remote user. </td>
    <td>V4.5.0</td>
  </tr>
</table>

 <h2 id="Raw video data">Raw video data</h2>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onCaptureVideoFrame "onCaptureVideoFrame"</td>
    <td> Retrieves the video data captured. </td>
    <td>V3.5.0</td>
  </tr>
</table>

 <h2 id="Screenshots">Screenshots</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::takeLocalSnapshot "takeLocalSnapshot"</td>
    <td> Takes a local video snapshot. </td>
    <td>V4.2.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::takeRemoteSnapshot "takeRemoteSnapshot"</td>
    <td> Takes a snapshot of a remote video screen. </td>
    <td>V4.2.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::NERtcTakeSnapshotCallback::onTakeSnapshotResult "onTakeSnapshotResult"</td>
    <td> Returns the screenshot result. </td>
    <td>V4.2.0</td>
  </tr>
</table>

 <h2 id="Watermark">Watermark</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setLocalVideoWatermarkConfigs "setLocalVideoWatermarkConfigs"</td>
    <td> Adds a watermark to the local video. </td>
    <td>V4.6.10</td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onLocalVideoWatermarkState "onLocalVideoWatermarkState"</td>
    <td> Returns the watermark result. </td>
    <td>V4.6.10</td>
  </tr>
</table>

 <h2 id="Encryption">Encryption</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableEncryption "enableEncryption"</td>
    <td>  Enables or disables media stream encryption. </td>
    <td>V4.4.0</td>
  </tr>
</table>

<h2 id="Client audio recording">Client audio recording</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startAudioRecording "startAudioRecording"</td>
    <td> Starts an audio recording on a client. </td>
    <td>V4.2.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startAudioRecordingWithConfig "startAudioRecordingWithConfig"</td>
    <td> Starts an audio recording on a client. </td>
    <td>V4.6.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopAudioRecording "stopAudioRecording"</td>
    <td> Stops an audio recording on the client. </td>
    <td>V4.2.0</td>
  </tr>
</table>


<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onAudioRecording "onAudioRecording"</td>
    <td> Returns the audio recording status. </td>
    <td>V4.2.0</td>
  </tr>
</table>

 <h2 id="Virtual Background">Virtual Background</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::enableVirtualBackground "enableVirtualBackground"</td>
    <td> Enables or disables the virtual background. </td>
    <td>V4.6.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onVirtualBackgroundSourceEnabled "onVirtualBackgroundSourceEnabled"</td>
    <td>The callback notifies whether the virtual background feature was successfully enabled. </td>
    <td>V4.6.0</td>
  </tr>
</table>


 <h2 id="Cloud proxy">Cloud prox</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::setCloudProxy "setCloudProxy"</td>
    <td>Enables and sets the cloud proxy service. </td>
    <td>V4.6.0</td>
  </tr>
</table>

 <h2 id="Audio device management">Audio device management</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::enumerateRecordDevices "enumerateRecordDevices"</td>
    <td> Audio capture device enumerations.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::setRecordDevice "setRecordDevice"</td>
    <td> Sets the audio capture device.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::getRecordDevice "getRecordDevice"</td>
    <td> Gets the current audio capture device.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::enumeratePlayoutDevices "enumeratePlayoutDevices"</td>
    <td> Audio playback device enumerations.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::setPlayoutDevice "setPlayoutDevice"</td>
    <td> Sets the audio playback device.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::getPlayoutDevice "getPlayoutDevice"</td>
    <td> Gets the current audio playback device.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::setRecordDeviceVolume "setRecordDeviceVolume"</td>
    <td> Sets the volume of the current audio capture device.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::getRecordDeviceVolume "getRecordDeviceVolume"</td>
    <td> Gets the volume of the current audio capture device.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::setPlayoutDeviceVolume "setPlayoutDeviceVolume"</td>
    <td> Sets the volume of the current audio playback device.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::getPlayoutDeviceVolume "getPlayoutDeviceVolume"</td>
    <td> Gets the volume of the current audio playback device.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::setPlayoutDeviceMute "setPlayoutDeviceMute"</td>
    <td> Sets the current playback device to a muted state.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::getPlayoutDeviceMute "getPlayoutDeviceMute"</td>
    <td> Gets the muted state of the current playback device.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::setRecordDeviceMute "setRecordDeviceMute"</td>
    <td> Sets the current capture device to a muted state.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::getRecordDeviceMute "getRecordDeviceMute"</td>
    <td> Gets the muted state of the current capture device.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::startRecordDeviceTest "startRecordDeviceTest"</td>
    <td> Starts testing the audio capture device.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::stopRecordDeviceTest "stopRecordDeviceTest"</td>
    <td> Stops testing the audio capture device.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::startPlayoutDeviceTest "startPlayoutDeviceTest"</td>
    <td> Starts testing the audio playback device.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::stopPlayoutDeviceTest "stopPlayoutDeviceTest"</td>
    <td> Stops testing the audio playback device.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::startAudioDeviceLoopbackTest "startAudioDeviceLoopbackTest"</td>
    <td> Starts the loopback test for an audio capture and playback device.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IAudioDeviceManager::stopAudioDeviceLoopbackTest "stopAudioDeviceLoopbackTest"</td>
    <td> Stops the loopback test for an audio capture and playback device.</td>
    <td>V3.5.0</td>
  </tr>
</table>

 <table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onAudioHowling "onAudioHowling"</td>
    <td> Occurs when howling is detected. </td>
    <td>V3.9.0</td>
  </tr>
</table>

 <h2 id="Video device management">Video device management</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IVideoDeviceManager::enumerateCaptureDevices "enumerateCaptureDevices"</td>
    <td> Video capture device enumerations.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IVideoDeviceManager::setDevice "setDevice"</td>
    <td> Sets the video capture device.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IVideoDeviceManager::getDevice "getDevice"</td>
    <td> Gets the current video capture device.</td>
    <td>V3.5.0</td>
  </tr>
</table>

 <h2 id="Device management events">Device management events</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onAudioDeviceStateChanged "onAudioDeviceStateChanged"</td>
    <td> Occurs when the status of the audio playback device changes.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onAudioDefaultDeviceChanged "onAudioDefaultDeviceChanged"</td>
    <td> Occurs when the default audio device changes.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandlerEx::onVideoDeviceStateChanged "onVideoDeviceStateChanged"</td>
    <td> Occurs when the status of a video device changes.</td>
    <td>V3.5.0</td>
  </tr>
</table>

 <h2 id="Troubleshooting">Troubleshooting</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::startAudioDump "startAudioDump"</td>
    <td> Starts recording an audio dump file that can be used to analyze audio issues</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::stopAudioDump "stopAudioDump"</td>
    <td> Stops recording an audio dump file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::getErrorDescription "getErrorDescription"</td>
    <td> Gets the error description. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEx::uploadSdkInfo "uploadSdkInfo"</td>
    <td> Uploads the log records collected by the SDK.</td>
    <td>V3.5.0</td>
  </tr>
</table>

 <table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onError "onError"</td>
    <td> Occurs when an error is triggered.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> \ref nertc::IRtcEngineEventHandler::onWarning "onWarning"</td>
    <td> Occurs when a warning is triggered.</td>
    <td>V3.5.0</td>
  </tr>
</table>

*/

/**
 @defgroup createNERtcEngine Create an NERTC Engine
 */
