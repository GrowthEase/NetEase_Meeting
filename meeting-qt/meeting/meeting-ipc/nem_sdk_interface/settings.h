// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/**
 * @file settings.h
 * @brief 配置信息头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_DEFINE_SETTINGS_H_
#define NEM_SDK_INTERFACE_DEFINE_SETTINGS_H_

#include "public_define.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

/**
 * @brief 配置窗口设置
 */
class NEM_SDK_INTERFACE_EXPORT NESettingsUIWndConfig : public NEObject {};

/**
 * @brief 配置变更类型
 */
enum SettingChangType {
    SettingChangType_Audio = 0,                 /**< 音频状态 */
    SettingChangType_Video = 1,                 /**< 视频状态 */
    SettingChangType_AudioAINS = 2,             /**< 音频AI降噪状态 */
    SettingChangType_AudioVolumeAutoAdjust = 3, /**< 麦克风音量自动调节状态 */
    SettingChangType_AudioQuality = 4,          /**< 通话音质类型 */
    SettingChangType_AudioEchoCancellation = 5, /**< 回音消除状态 */
    SettingChangType_AudioEnableStereo = 6,     /**< 启用立体音状态 */
    SettingChangType_RemoteVideoResolution = 7, /**< 远端视频在本端显示的分辨率类型 */
    SettingChangType_MyVideoResolution = 8,     /**< 本地视频的分辨率类型 */

    SettingChangType_Other = 100, /**< 保留 */
};

/**
 * @brief 配置通话音质类型
 */
enum AudioQuality {
    AudioQuality_Talk = 0,  /**< 通话模式 */
    AudioQuality_Music = 1, /**< 音乐模式 */
};

/**
 * @brief 配置远端视频分辨率
 */
enum RemoteVideoResolution {
    RemoteVideoResolution_Default = 0, /**< 默认模式 */
    RemoteVideoResolution_HD = 1,      /**< 高清模式 */
};

/**
 * @brief 配置本端视频分辨率
 */
enum LocalVideoResolution {
    LocalVideoResolution_480P = 0,  /**< 480P */
    LocalVideoResolution_720P = 1,  /**< 720P */
    LocalVideoResolution_1080P = 2, /**< 1080P */
};

/**
 * @brief 配置本端视频帧率
 */
enum LocalVideoFramerate {
    LocalVideoFramerateFpsDefault = 0, /**< 默认帧率 */
    LocalVideoFramerateFps_7 = 7,      /**< 7帧每秒 */
    LocalVideoFramerateFps_10 = 10,    /**< 10帧每秒 */
    LocalVideoFramerateFps_15 = 15,    /**< 15帧每秒 */
    LocalVideoFramerateFps_24 = 24,    /**< 24帧每秒 */
    LocalVideoFramerateFps_30 = 30,    /**< 30帧每秒 */
    LocalVideoFramerateFps_60 = 60,    /**< 60帧每秒 */
};

/**
 * @brief 音频设备自动选择策略
 */
enum AudioDeviceAutoSelectType {
    AudioDeviceAutoSelectType_Default = 0,   /**< 系统默认 */
    AudioDeviceAutoSelectType_Available = 1, /**< 可用设备 */
};

/**
 * @brief 自定义虚拟背景
 */
typedef struct tagNEMeetingVirtualBackground {
    // std::string title; /**< 标题 */
    // unsigned int color = 0; /**< 自定义背景图像的颜色。格式为RGB定义的十六进制整数，不带::号， 例如 0xFFB6C1 代表浅粉色。默认值为
    //                           0xFFFFFF，表示白色。取值范围是 [0x000000,0xFFFFFF]。如果该值无效， SDK 将原始背景图片替换为白色的图片 */
    std::string path; /**< 自定义背景图片的本地绝对路径，当路径不为空时，优先使用path。支持 PNG 和 JPG 格式 */
} NEMeetingVirtualBackground;

NNEM_SDK_INTERFACE_END_DECLS

#endif  // NEM_SDK_INTERFACE_DEFINE_PUBLIC_H_
