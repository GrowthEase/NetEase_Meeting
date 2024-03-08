/** @file nertc_engine_predecode_observer.h
* @brief The interface header file of expansion callback of the NERTC SDK.
* All parameter descriptions of the NERTC SDK. All string-related parameters (char *) are encoded in UTF-8.
* @copyright (c) 2022, NetEase Inc. All rights reserved.
*/

#ifndef NERTC_ENGINE_PREDECODE_OBSERVER_H
#define NERTC_ENGINE_PREDECODE_OBSERVER_H

#include "nertc_base_types.h"

/**
 * @namespace nertc
 * @brief namespace nertc
 */
namespace nertc
{
/**
 * @if English
 * The pre decode media type.
 * @endif
 * @if Chinese
 * 解码前媒体类型。
 * @endif
 */
typedef enum
{
    /**
     * @if English
     * Audio media type.
     * @endif
     * @if Chinese
     * Audio 媒体类型。
     * @endif
     */
    kNERtcPreDecodeMediaTypeAudio = 0, 
    /**
     * @if English
     * Video media type.
     * @endif
     * @if Chinese
     * Video 媒体类型。
     * @endif
     */
    kNERtcPreDecodeMediaTypeVideo = 1, 
    /**
     * @if English
     * Unknown media type.
     * @endif
     * @if Chinese
     * Unknown 媒体类型。
     * @endif
     */
    kNERtcPreDecodeMediaTypeUnknown = 100, 
} NERtcPreDecodeMediaType;

/**
 * @if English
 * The pre decode video info.
 * @endif
 * @if Chinese
 * 解码前视频详细信息。
 * @endif
 */
struct NERtcPreDecodeVideoInfo 
{
    /**
     * @if English
     * The video frame width.
     * @endif
     * @if Chinese
     * 视频帧宽。
     * @endif
     */
    uint32_t width;
    /**
     * @if English
     * The video frame height.
     * @endif
     * @if Chinese
     * 视频帧高。
     * @endif
     */
    uint32_t height;
    /**
     * @if English
     * The video frame is key frame or not.
     * @endif
     * @if Chinese
     * 视频是否为关键帧。
     * @endif
     */
    bool is_key_frame;
};

/**
 * @if English
 * The pre decode audio info.
 * @endif
 * @if Chinese
 * 解码前音频详细信息。
 * @endif
 */
 struct NERtcPreDecodeAudioInfo {
    /* @if English
    * The audio data interval per frame. Unit: milliseconds.
    * @endif
    * @if Chinese
    * 每帧音频数据时间间隔, 单位为毫秒。
    * @endif
    */
    uint32_t per_time_ms;
    /**
     * @if English
     * The opus audio data  byte.
     * @endif
     * @if Chinese
     * Opus音频数据TOC字节。
     * @endif
     */
    uint8_t toc;
};

/**
 * @if English
 * The pre decode frame info
 * @endif 
 * @if Chinese
 * 解码前帧信息
 * @endif
 */
struct NERtcPreDecodeFrameInfo {
    /**
     * @if English
     * The pre decode media type.
     * @endif
     * @if Chinese
     * 解码前媒体类型。
     * @endif
     */
    NERtcPreDecodeMediaType media_type;
    /**
     * @if English
     * User id.
     * @endif
     * @if Chinese
     * 用户id。
     * @endif
     */
    uint64_t  uid;
    /**
     * @if English
     * Timestamp. Unit: milliseconds.
     * @endif
     * @if Chinese
     * 解码前媒体时间戳，单位为毫秒。
     * @endif
     */
    int64_t timestamp_ms;
    /**
     * @if English
     * The pre decode data.
     * @endif
     * @if Chinese
     * 解码前媒体数据。
     * @endif
     */
    uint8_t* data;
    /**
     * @if English
     * The pre decode data length.
     * @endif
     * @if Chinese
     * 解码前媒体有效数据长度。
     * @endif
     */
    int length;
    /**
     * @if English
     * Codec name.
     * @endif
     * @if Chinese
     * 编码器名称。
     * @endif
     */
    char* codec;
    /**
     * @if English
     * The pre decode frame is main stream or sub stream.
     * @endif
     * @if Chinese
     * 解码前媒体数据是否为主流或辅流。
     * @endif
     */
    bool is_main_stream;
    /**
     * @if English
     * The pre decode video info, which is valid for {@link media_type} equal kNERtcPreDecodeMediaTypeVideo.
     * @endif
     * @if Chinese
     * 解码前音频详细信息, 仅 {@link media_type} 为 kNERtcPreDecodeMediaTypeVideo 时有效。
     * @endif
     */
    NERtcPreDecodeVideoInfo video_info;
    /**
     * @if English
     * The pre decode audio info, which is valid for {@link media_type} equal kNERtcPreDecodeMediaType.
     * @endif
     * @if Chinese
     * 解码前音频详细信息, 仅 {@link media_type} 为 kNERtcPreDecodeMediaType 时有效。
     * @endif
     */
    NERtcPreDecodeAudioInfo audio_info;    
};

/** 
 * @if English
 * The predecode media data observer object.
 * @endif
 * @if Chinese
 * 解码前媒体数据观测器。
 * @endif
 */
class INERtcPreDecodeObserver {
public:
    virtual ~INERtcPreDecodeObserver() {}

    /** 
     * @if English
     * Occurs when the predecode media data is comming.
     * @param pre_decode_frame The predecode media frame.
     * @endif
     * @if Chinese
     * 解码前媒体数据回调。
     * - 调用 \ref nertc::IRtcEngineEx::setPreDecodeObserver "setPreDecodeObserver" 方法注册解码前媒体数据观测器后，SDK会触发该回调，可以通过返回的用户 UID、媒体数据类型、数据长度等信息对媒体数据自行编码。
     * @since V4.6.29
     * @par 使用前提
     * 请通过 \ref nertc::IRtcEngineEx::setPreDecodeObserver "setPreDecodeObserver" 接口设置回调监听。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>pre_decode_frame</td>
     *      <td>NERtcPreDecodeFrameInfo*</td>
     *      <td>解码前媒体数据。</td>
     *  </tr>
     * </table>  
     * @endif
     */
    virtual void onFrame(NERtcPreDecodeFrameInfo* pre_decode_frame) = 0;
};
} //namespace nertc

#endif