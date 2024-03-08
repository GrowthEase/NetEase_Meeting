/** @file nertc_engine_media_stats_observer.h
* @brief The interface header file of expansion callback of the NERTC SDK.
* All parameter descriptions of the NERTC SDK. All string-related parameters (char *) are encoded in UTF-8.
* @copyright (c) 2021, NetEase Inc. All rights reserved.
*/

#ifndef NERTC_ENGINE_MEDIA_STATS_OBSERVERA_H
#define NERTC_ENGINE_MEDIA_STATS_OBSERVERA_H

#include "nertc_base_types.h"
#include "nertc_engine_defines.h"

 /**
 * @namespace nertc
 * @brief namespace nertc
 */
namespace nertc
{
/** 
 * @if English
 * The SDK reports stats to the application through IRtcMediaStatsObserver expansion callback interface class.
 * <br>All methods in this interface class have their (empty) default implementations, and the application can inherit only some of the required events instead of all of them. When calling a callback method, the application must not implement time-consuming operations or call blocking-triggered APIs. For example, if you want to enable audio and video, the SDK may be affected in the runtime.
 * @endif
 * @if Chinese
 * IRtcMediaStatsObserver 回调扩展接口类用于 SDK 向 App 上报统计信息。
 * <br>接口类的所有方法都有缺省（空）实现，App 可以根据需要只继承关心的事件。在回调方法中，App 不应该做耗时或者调用可能会引起阻塞的 API（如开启音频或视频等），否则可能影响 SDK 的运行。
 * @endif
 */
class IRtcMediaStatsObserver
{
public:
    virtual ~IRtcMediaStatsObserver() {}

    /** 
    * @if English
    * Occurs when the stats of the current call is collected.
    * <br>The SDK reports the stats of the current call to the app on a regular basis. The callback is triggered every 2 seconds.
    * @param stats      NERTC engine statistics: NERtcStats
    * @endif
    * @if Chinese
    * 当前通话统计回调。
    * <br>SDK 定期向 App 报告当前通话的统计信息，该回调在通话中每 2 秒触发一次。
    * @param stats      NERTC 引擎统计数据: NERtcStats
    * @endif
    */
    virtual void onRtcStats(const NERtcStats &stats) {
        (void)stats;
    }    

    /** 
     * @if English
     * Occurs when the stats of the local audio stream are collected.
     * <br>The message sent by this callback describes the stats of the audio stream published by the local device. The callback is triggered every 2 seconds.
     * @param stats         The stats of the local audio stream. For more information, see NERtcAudioSendStats.
     * @endif
     * @if Chinese
     * 本地音频流统计信息回调。
     * <br>该回调描述本地设备发送音频流的统计信息，每 2 秒触发一次。
     * @param stats         本地音频流统计信息。详见 NERtcAudioSendStats.
     * @endif
     */
    virtual void onLocalAudioStats(const NERtcAudioSendStats &stats) {
        (void)stats;
    }

    /** 
     * @if English
     * Occurs when the stats of the remote audio stream in the call are collected.
     * <br>The message sent by this callback describes the stats of the audio stream in a peer-to-peer call from the remote user. The callback is triggered every 2 seconds.
     * @param stats         An array of audio stats of the audio stream from each remote user. For more information, see NERtcAudioRecvStats.
     * @param user_count    stats indicates the array size.
     * @endif
     * @if Chinese
     * 通话中远端音频流的统计信息回调。
     * <br>该回调描述远端用户在通话中端到端的音频流统计信息，每 2 秒触发一次。
     * @param stats         每个远端用户音频统计信息的数组。详见 NERtcAudioRecvStats.
     * @param user_count    stats 数组的大小。
     * @endif
     */
    virtual void onRemoteAudioStats(const NERtcAudioRecvStats *stats, unsigned int user_count) {
        (void)stats;
        (void)user_count;
    }

    /** 
     * @if English
     * Occurs when the stats of the video stream are collected. 
     * <br>The message sent by this callback describes the stats of the video stream published by the local device. The callback is triggered every 2 seconds.
     * @param stats         indicates the stats of the local video stream. For more information, see NERtcVideoSendStats.
     * @endif
     * @if Chinese
     * 本地视频流统计信息回调。
     * <br>该回调描述本地设备发送视频流的统计信息，每 2 秒触发一次。
     * @param stats         本地视频流统计信息。详见 NERtcVideoSendStats.
     * @endif
     */
    virtual void onLocalVideoStats(const NERtcVideoSendStats &stats) {
        (void)stats;
    }

    /** 
     * @if English
     * Occurs when the stats of the remote video stream in the call are collected.
     * <br>The message sent by this callback describes the stats of the video stream in a peer-to-peer call from the remote user. The callback is triggered every 2 seconds.
     *  @param stats indicates an array of video stats from each remote user. For more information, see NERtcVideoRecvStats.
     * @param user_count stats indicates the array size.
     * @endif
     * @if Chinese
     * 通话中远端视频流的统计信息回调。
     * <br>该回调描述远端用户在通话中端到端的视频流统计信息，每 2 秒触发一次。
     * @param stats         每个远端用户视频统计信息的数组。详见 NERtcVideoRecvStats.
     * @param user_count    stats 数组的大小。
     * @endif
     */
    virtual void onRemoteVideoStats(const NERtcVideoRecvStats *stats, unsigned int user_count) {
        (void)stats;
        (void)user_count;
    }

    /** 
     * @if English
     * Returns the uplink and downlink network quality report for each user during the call.
     * <br>The message sent by this callback describes the network status of each user during the call. The callback is triggered every 2 seconds, which only reports members whose status changed.
     * @param infos             The array that contains the information about ID of each user and uplink and downlink network quality. NERtcNetworkQualityInfo.
     * @param user_count        stats The array size or the number of users.
     * @endif
     * @if Chinese
     * 通话中每个用户的网络上下行质量报告回调。
     * <br>该回调描述每个用户在通话中的网络状态，每 2 秒触发一次，只上报状态有变更的成员。
     * @param infos             每个用户 ID 和网络上下行质量信息的数组: NERtcNetworkQualityInfo
     * @param user_count        infos 数组的大小，即用户数。
     * @endif
     */
    virtual void onNetworkQuality(const NERtcNetworkQualityInfo *infos, unsigned int user_count) {
        (void)infos;
        (void)user_count;
    }
};
} //namespace nertc

#endif
