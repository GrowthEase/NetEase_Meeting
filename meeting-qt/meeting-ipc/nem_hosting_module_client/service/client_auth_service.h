/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_HOSTING_MODULE_CLIENT_SERVICE_AUTH_SERVICE_H_
#define NEM_HOSTING_MODULE_CLIENT_SERVICE_AUTH_SERVICE_H_
#include "client_nemeeting_sdk_interface_include.h"
#include "nem_hosting_module_client/config/build_config.h"
#include "nem_hosting_module_core/service/service.h"

NNEM_SDK_HOSTING_MODULE_CLIENT_BEGIN_DECLS

USING_NS_NNEM_SDK_INTERFACE

USING_NS_NNEM_SDK_HOSTING_MODULE_CORE

class NEM_SDK_INTERFACE_EXPORT NEAuthServiceIMP : public NEAuthServiceIPCClient, public IService<NS_NIPCLIB::IPCClient>
{
    friend NEMeetingSDKIPCClient* NEMeetingSDKIPCClient::getInstance();
public:
    NEAuthServiceIMP();
    ~NEAuthServiceIMP();
public:
    virtual void loginWithNEMeeting(const std::string& account, const std::string& password, const NEAuthLoginCallback& cb) override;
    virtual void loginWithSSOToken(const std::string& ssoToken, const NEAuthLoginCallback& cb) override;
    virtual void tryAutoLogin(const NEAuthLoginCallback& cb) override;
    virtual void login(const std::string& account, const std::string& accountToken, const NEAuthLoginCallback& cb) override;
    virtual void login(const std::string& appKey, const std::string& account, const std::string& token, const NEAuthLoginCallback& cb) override;
	virtual void loginAnonymous(const NEAuthLoginCallback& cb) override;
	virtual void getAccountInfo(const NEGetAccountInfoCallback& cb) override;
    virtual void logout(bool cleanup = false, const NEAuthLoginCallback& cb = nullptr) override;

    virtual void onKickout() override;
    virtual void onAuthInfoExpired() override;

    virtual void OnLoad() override;
    virtual void OnRelease() override;

private:
    void OnPack(int cid, const std::string& data, const IPCAsyncResponseCallback& cb) override {};
    void OnPack(int cid, const std::string& data, uint64_t sn) override;
};

NNEM_SDK_HOSTING_MODULE_CLIENT_END_DECLS

#endif //NEM_HOSTING_MODULE_CLIENT_SERVICE_MEETING_SERVICE_H_
