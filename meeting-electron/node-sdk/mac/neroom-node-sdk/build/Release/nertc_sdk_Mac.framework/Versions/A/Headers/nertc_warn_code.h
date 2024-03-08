/** @file nertc_warn_code.h
  * @brief The definition of error codes of NERtc SDK.
  * @copyright (c) 2021 NetEase, Inc.  All rights reserved.
  */

#ifndef NERTC_WARN_CODE_H
#define NERTC_WARN_CODE_H

 /**
 * @namespace nertc
 * @brief namespace nertc
 */
namespace nertc
{
/** 
 * @if English
 * Warning code.
 * If the warning code occurs, the SDK reports an error that is likely to be solved. The warning code just informs you of the SDK status. In most cases, the application programs can pass the warning code.
 * @endif
 * @if Chinese
 * 警告代码。
 * 警告代码意味着 SDK 遇到问题，但有可能恢复，警告代码仅起告知作用，一般情况下应用程序可以忽略警告代码。
 * @endif
 */
typedef enum
{
    /**
     * @if English
     * No warning.
     * @endif
     * @if Chinese
     * 未发生警告。
     * @endif
     */
    kLiteSDKNoWarning                = 0,
    /**
     * @if English
     * The Client has no capability of device encoding and  decoding to match that of the channel. For example, the device cannot encode in VP8 and other formats. Therefore, you may cannot implement video encoding and decoding in the channel. The local side may cannot display some remote video screens and the remote side may cannot display local screens.
     * @endif
     * @if Chinese
     * 当前客户端设备视频编解码能力与房间不匹配，例如设备不支持 VP8 等编码类型。在此房间中可能无法成功进行视频编解码，即本端可能无法正常显示某些远端的视频画面，同样远端也可能无法显示本端画面。
     * @endif
     */
    kNERtcWarningChannelAbilityNotMatch = 406,   
    /**
     * @if English
     * audio asl fallback
     * @endif
     * @if Chinese
     * 音频自动选路回退
     * @endif
     */
    kNERtcWarningASLAudioFallback = 407,
} NERtcWarnCode;

} // namespace nertc

#endif
