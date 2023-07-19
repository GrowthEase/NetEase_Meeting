// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

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
 * @brief checkAuthRecordScreen
 * 检测摄像头权限
 * @return true 为有权限，false 为无权限
 */
bool checkAuthCamera();

/**
 * @brief checkAuthMicrophone
 * 检测麦克风权限
 */
bool checkAuthMicrophone();

/**
 * @brief openRecordSettings
 * 打开系统录制权限设置页面
 */
void openRecordSettings();

/**
 * @brief openCameraSettings
 * 打开系统摄像头权限设置页面
 */
void openCameraSettings();

/**
 * @brief openMicrophoneSettings
 * 打开系统麦克风权限设置页面
 */
void openMicrophoneSettings();

#ifdef __cplusplus
}
#endif

#endif /* AuthChecker_h */
