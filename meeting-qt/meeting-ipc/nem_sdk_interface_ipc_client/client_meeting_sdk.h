/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_MEETING_SDK_H_
#define NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_MEETING_SDK_H_

#include "meeting_sdk.h"
#include "client_prochandler_define.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS
class NEM_SDK_INTERFACE_EXPORT NEMeetingSDKProcHandler : public NEProcHandler
{
public:
    virtual void onInitialize(const NEMeetingSDKConfig& config, const NEMeetingSDK::NEInitializeCallback& cb) = 0;
    virtual void onUnInitialize(const NEMeetingSDK::NEUnInitializeCallback& cb) = 0;
    virtual void onQuerySDKVersion(const NEMeetingSDK::NEQuerySDKVersionCallback& cb) = 0;
    virtual void onActiveWindow(const NEMeetingSDK::NEActiveWindowCallback& cb) = 0;
    virtual void attachSDKInitialize(const std::function<void(bool)>& cb) = 0;
};
class NEM_SDK_INTERFACE_EXPORT NEMeetingSDKIPCClient : public NEServiceIPCClient< NEMeetingSDKProcHandler, NEMeetingSDK>
{
public:
    static NEMeetingSDKIPCClient* getInstance();
    enum LogLevel
    {
        LogLevel_DEBUG = 0,
        LogLevel_INFO,
        LogLevel_WARNING,
        LogLevel_ERROR,
        LogLevel_FATAL,
        LogLevel_V0,
        LogLevel_V1,
        LogLevel_V2,
        LogLevel_V3,
        LogLevel_V4,
    };
public:
    virtual void privateInitialize(int port) = 0;
    virtual void attachPrivateInitialize(const std::function<void(bool)>& cb) = 0;
    virtual void setLogCallBack(const std::function<void(LogLevel level, const std::string&)>& cb) = 0;
};

NNEM_SDK_INTERFACE_END_DECLS

#endif // NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_MEETING_SDK_H_
