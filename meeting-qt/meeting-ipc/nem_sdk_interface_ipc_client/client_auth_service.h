/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_AUTHSERVICE_H_
#define NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_AUTHSERVICE_H_

#include "auth_service.h"
#include "client_prochandler_define.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

class NEM_SDK_INTERFACE_EXPORT NEAuthServiceProcHandler : public NEProcHandler
{
public:
    virtual void onLoginWithNEMeeting(const std::string& account, const std::string& password, const NEAuthService::NEAuthLoginCallback& cb) = 0;
    virtual void onLoginWithSSOToken(const std::string& ssoToken, const NEAuthService::NEAuthLoginCallback& cb) = 0;
    virtual void onTryAutoLogin(const NEAuthService::NEAuthLoginCallback& cb) = 0;
    virtual void onLogin(const std::string& accountId, const std::string& accountToken, const NEAuthService::NEAuthLoginCallback& cb) = 0;
    virtual void onLogin(const std::string& appKey, const std::string& account, const std::string& token, const NEAuthService::NEAuthLoginCallback& cb) = 0;
    virtual void onLoginAnonymous(const NEAuthService::NEAuthLoginCallback& cb) = 0;
    virtual void onGetAccountInfo(const NEAuthService::NEGetAccountInfoCallback& cb) = 0;
    virtual void onLogout(bool cleanup, const NEAuthService::NEAuthLogoutCallback& cb) = 0;
};

class NEM_SDK_INTERFACE_EXPORT NEAuthServiceIPCClient :
    public NEServiceIPCClient<NEAuthServiceProcHandler, NEAuthService>
{
public:
    virtual void addAuthListener(NEAuthListener* listener) override {}
    virtual void removeAuthListener(NEAuthListener* listener) override {}

    virtual void onKickout() = 0;
    virtual void onAuthInfoExpired() = 0;
};

NNEM_SDK_INTERFACE_END_DECLS
#endif // ! NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_AUTHSERVICE_H_
