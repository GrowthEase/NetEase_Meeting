/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_HOSTING_MODULE_SERVICE_AUTH_SERVICE_H_
#define NEM_HOSTING_MODULE_SERVICE_AUTH_SERVICE_H_
#include "nemeeting_sdk_interface_include.h"
#include "nem_hosting_module/config/build_config.h"
#include "nem_hosting_module_core/service/service.h"

NNEM_SDK_HOSTING_MODULE_BEGIN_DECLS

USING_NS_NNEM_SDK_INTERFACE

USING_NS_NNEM_SDK_HOSTING_MODULE_CORE

class NEM_SDK_INTERFACE_EXPORT NEAuthServiceIMP : public NEAuthService, public IService<NS_NIPCLIB::IPCServer>
{
public:
	NEAuthServiceIMP();
	~NEAuthServiceIMP();
public:	
    virtual void loginWithNEMeeting(const std::string& account, const std::string& password, const NEAuthLoginCallback& cb) override;
    virtual void loginWithSSOToken(const std::string& ssoToken, const NEAuthLoginCallback& cb) override;
    virtual void tryAutoLogin(const NEAuthLoginCallback& cb) override;
    virtual void login(const std::string& accountId, const std::string& token, const NEAuthLoginCallback& cb) override;
	virtual void login(const std::string& appKey, const std::string& account, const std::string& token, const NEAuthLoginCallback& cb) override;
	virtual void getAccountInfo(const NEGetAccountInfoCallback& cb) override;
	virtual void logout(bool cleanup = false, const NEAuthLoginCallback& cb = nullptr) override;
    virtual void addAuthListener(NEAuthListener* listener) override;
    virtual void removeAuthListener(NEAuthListener* listener) override;
	virtual void loginAnonymous(const NEAuthLoginCallback& cb) override;
private:
	void OnPack(int cid, const std::string& data, const IPCAsyncResponseCallback& cb) override;
	virtual void OnPack(int cid, const std::string& data, uint64_t sn) override;

private:
    void InvokeLoginWithNEMeeting(const std::string& account, const std::string& password, const NEAuthLoginCallback& cb);
    void InvokeLoginWithSSOToken(const std::string& ssoToken, const NEAuthLoginCallback& cb);
    void InvokeTryAutoLogin(const NEAuthLoginCallback& cb);
    void InvokeLoginEx(const std::string& accountId, const std::string& accountToken, const NEAuthLoginCallback& cb);
	void InvokeLogin(const std::string& appKey, const std::string& acc, const std::string& pwd, const NEAuthLoginCallback& cb);
    void InvokeGetAccountInfo(const NEGetAccountInfoCallback& cb);
	void InvokeLogout(bool cleanup, const NEAuthLoginCallback& cb);

private:
    std::vector<NEAuthListener*>    auth_listener_lists;
};

NNEM_SDK_HOSTING_MODULE_END_DECLS

#endif //NEM_HOSTING_MODULE_SERVICE_MEETING_SERVICE_H_