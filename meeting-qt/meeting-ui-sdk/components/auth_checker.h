/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

//
//  AuthChecker.h
//  nertc_sdk
//
//  Created by dudu on 2020/9/4.
//

#ifndef AuthChecker_h
#define AuthChecker_h

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief checkAuthRecordScreen
 * 检测屏幕录制权限
 * @return true 为有权限，false 为无权限
 */
bool checkAuthRecordScreen();

/**
 * @brief showScreenRecordingPrompt
 * 发起请求屏幕共享权限请求
 */
void showScreenRecordingPrompt();

/**
 * @brief openSettings
 * 打开系统设置页面
 */
void openSettings();

#ifdef __cplusplus
}
#endif


#endif /* AuthChecker_h */
