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
class NEM_SDK_INTERFACE_EXPORT NESettingsUIWndConfig : public NEObject
{
};

/**
 * @brief 配置变更类型
 */
enum SettingChangType
{
    SettingChangType_Audio = 0, /**< 音频状态 */
    SettingChangType_Video = 1, /**< 视频状态 */
    SettingChangType_Other = 10,/**< 保留 */
};

NNEM_SDK_INTERFACE_END_DECLS

#endif //NEM_SDK_INTERFACE_DEFINE_PUBLIC_H_
