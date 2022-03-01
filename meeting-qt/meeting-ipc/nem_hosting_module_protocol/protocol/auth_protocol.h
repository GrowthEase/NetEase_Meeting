/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_HOSTING_MODULE_PROTOCOL_AUTH_PROTOCOL_H_
#define NEM_HOSTING_MODULE_PROTOCOL_AUTH_PROTOCOL_H_

#include "nem_hosting_module_core/protocol/protocol.h"
#include "nem_hosting_module_protocol/config/build_config.h"

NNEM_SDK_HOSTING_MODULE_PROTOCOL_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_CORE

enum AuthCID {
    AuthCID_Login = 1,
    AuthCID_Login_CB,
    AuthCID_LoginEx,
    AuthCID_Login_CB_Ex,
    AuthCID_LoginWithNEMeeting,
    AuthCID_LoginWithNEMeeting_CB,
    AuthCID_LoginWithSSOToken,
    AuthCID_LoginWithSSOToken_CB,
    AuthCID_TryAutoLogin,
    AuthCID_TryAutoLogin_CB,
	AuthCID_LoginAnonymous,
	AuthCID_LoginAnonymous_CB,
    AuthCID_QueryAccountInfo,
    AuthCID_QueryAccountInfo_CB,
    AuthCID_Logout,
    AuthCID_Logout_CB,
    AuthCID_Notify_Begin = 100,
    AuthCID_Notify_Kickout,
    AuthCID_Notify_AuthInfoExpired,
};

class LoginRequestEx : public NEMIPCProtocolBody
{
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;

public:
    std::string account_;
    std::string accountToken_;
};
using LoginExResponse = NEMIPCProtocolErrorInfoBody;

class LoginRequest : public NEMIPCProtocolBody {
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;

public:
    std::string appkey_;
    std::string account_;
    std::string password_;
};
using LoginResponse = NEMIPCProtocolErrorInfoBody;

class LoginWithNEMeetingRequest : public NEMIPCProtocolBody {
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;

public:
    std::string account_;
    std::string password_;
};
using LoginWithNEMeetingResponse = NEMIPCProtocolErrorInfoBody;

class LoginWithSSORequest : public NEMIPCProtocolBody {
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;

public:
    std::string ssoToken_;
};
using LoginWithSSOResponse = NEMIPCProtocolErrorInfoBody;



class LoginAnonymousRequest : public NEMIPCProtocolBody {
public:
	virtual void OnPack(Json::Value& root) const override;
	virtual void OnParse(const Json::Value& root) override;

public:

};
using LoginAnonymousResponse = NEMIPCProtocolErrorInfoBody;

using TryAutoLoginRequest = NEMIPCProtocolEmptyBody;
using TryAutoLoginResponse = NEMIPCProtocolErrorInfoBody;

class LogoutRequest : public NEMIPCProtocolBody {
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;

public:
    bool cleanup_;
};
using LogoutResponse = NEMIPCProtocolErrorInfoBody;

class AuthKickoutPack : public NEMIPCProtocolBody {
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;
};

class AuthInfoExpiredPack : public NEMIPCProtocolBody {
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;
};

using QuerAccountInfoRequest = NEMIPCProtocolEmptyBody;
class QuerAccountInfoResponse : public NEMIPCProtocolErrorInfoBody {
public:
    virtual void OnOtherPack(Json::Value& root) const override;
    virtual void OnOtherParse(const Json::Value& root) override;

public:
    AccountInfo account_info_;
};

NNEM_SDK_HOSTING_MODULE_PROTOCOL_END_DECLS

#endif  // NEM_HOSTING_MODULE_PROTOCOL_AUTH_PROTOCOL_H_
