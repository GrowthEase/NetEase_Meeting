/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nem_hosting_module_client/service/client_auth_service.h"
#include "nem_hosting_module_protocol/protocol/auth_protocol.h"

NNEM_SDK_HOSTING_MODULE_CLIENT_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_PROTOCOL

NEAuthServiceIMP::NEAuthServiceIMP() : IService(ServiceID::SID_Auth)
{
}

NEAuthServiceIMP::~NEAuthServiceIMP()
{

}

void NEAuthServiceIMP::OnLoad()
{

}

void NEAuthServiceIMP::OnRelease()
{

}

void NEAuthServiceIMP::loginWithNEMeeting(const std::string& account, const std::string& password, const NEAuthLoginCallback& cb)
{
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onLoginWithNEMeeting(account, password, cb);
}

void NEAuthServiceIMP::loginWithSSOToken(const std::string& ssoToken, const NEAuthLoginCallback& cb)
{
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onLoginWithSSOToken(ssoToken, cb);
}

void NEAuthServiceIMP::tryAutoLogin(const NEAuthLoginCallback& cb)
{
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onTryAutoLogin(cb);
}

void NEAuthServiceIMP::login(const std::string& appKey, const std::string& account, const std::string& token, const NEAuthLoginCallback& cb)
{
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onLogin(appKey, account, token, cb);
}

void NEAuthServiceIMP::login(const std::string& account, const std::string& accountToken, const NEAuthLoginCallback& cb)
{
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onLogin(account, accountToken, cb);
}

void NEAuthServiceIMP::loginAnonymous(const NEAuthLoginCallback& cb)
{
	if (_ProcHandler() != nullptr)
		_ProcHandler()->onLoginAnonymous(cb);
}

void NEAuthServiceIMP::getAccountInfo(const NEGetAccountInfoCallback& cb)
{
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onGetAccountInfo(cb);
}

void NEAuthServiceIMP::logout(bool cleanup, const NEAuthLoginCallback& cb)
{
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onLogout(cleanup, cb);
}

void NEAuthServiceIMP::OnPack(int cid, const std::string& data, uint64_t sn)
{
    switch (cid)
    {
    case AuthCID::AuthCID_LoginWithNEMeeting:
    {
        LoginWithNEMeetingRequest request;
        if (request.Parse(data))
        {
            loginWithNEMeeting(request.account_, request.password_, ToWeakCallback([=](NEErrorCode error_code, const std::string& error_msg) {
                LoginWithNEMeetingResponse response;
                response.error_code_ = error_code;
                response.error_msg_ = error_msg;
                SendData(AuthCID::AuthCID_LoginWithNEMeeting_CB, response, sn);
            }));
        }
    }
    break;
    case AuthCID::AuthCID_LoginWithSSOToken:
    {
        LoginWithSSORequest request;
        if (request.Parse(data))
        {
            loginWithSSOToken(request.ssoToken_, ToWeakCallback([=](NEErrorCode error_code, const std::string& error_msg) {
                LoginWithSSOResponse response;
                response.error_code_ = error_code;
                response.error_msg_ = error_msg;
                SendData(AuthCID::AuthCID_LoginWithSSOToken_CB, response, sn);
            }));
        }
    }
    break;
    case AuthCID::AuthCID_TryAutoLogin:
    {
        TryAutoLoginRequest request;
        if (request.Parse(data))
        {
            tryAutoLogin(ToWeakCallback([=](NEErrorCode error_code, const std::string& error_msg) {
                TryAutoLoginResponse response;
                response.error_code_ = error_code;
                response.error_msg_ = error_msg;
                SendData(AuthCID::AuthCID_TryAutoLogin_CB, response, sn);
            }));
        }
    }
    break;
    case AuthCID::AuthCID_Login:
    {
        LoginRequest request;
        if (request.Parse(data))
        {
            login(request.appkey_, request.account_, request.password_, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                LoginResponse response;
                response.error_code_ = error_code;
                response.error_msg_ = error_msg;
                SendData(AuthCID::AuthCID_Login_CB, response, sn);
            }));
        }
    }
    break;
    case AuthCID::AuthCID_LoginEx:
    {
        LoginRequestEx request;
        if (request.Parse(data)) {
            login(request.account_, request.accountToken_, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                      LoginResponse response;
                      response.error_code_ = error_code;
                      response.error_msg_ = error_msg;
                      SendData(AuthCID::AuthCID_Login_CB_Ex, response, sn);
                  }));
        }
    }
    break;
	case AuthCID::AuthCID_LoginAnonymous:
	{
		LoginAnonymousRequest request;
		if (request.Parse(data)) {
			loginAnonymous(ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
				LoginResponse response;
				response.error_code_ = error_code;
				response.error_msg_ = error_msg;
				SendData(AuthCID::AuthCID_LoginAnonymous_CB, response, sn);
			}));
		}
	}
	break;
    case AuthCID::AuthCID_QueryAccountInfo:
    {
        QuerAccountInfoRequest response;
        if (response.Parse(data))
        {
            getAccountInfo(ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const AccountInfo& auth_info) {
                QuerAccountInfoResponse response;
                response.account_info_ = auth_info;
                response.error_code_ = error_code;
                response.error_msg_ = error_msg;
                SendData(AuthCID::AuthCID_QueryAccountInfo_CB, response, sn);
            }));
        }
    }
    break;
    case AuthCID::AuthCID_Logout:
    {
        LogoutRequest response;
        if (response.Parse(data))
        {
            logout(response.cleanup_, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                LogoutResponse response;
                response.error_code_ = error_code;
                response.error_msg_ = error_msg;
                SendData(AuthCID::AuthCID_Logout_CB, response, sn);
            }));
        }
    }
    break;
    }
}

void NEAuthServiceIMP::onKickout()
{
    AuthKickoutPack pack;
    SendData(AuthCID::AuthCID_Notify_Kickout, pack, 0);
}

void NEAuthServiceIMP::onAuthInfoExpired()
{
    AuthInfoExpiredPack pack;
    SendData(AuthCID::AuthCID_Notify_AuthInfoExpired, pack, 0);
}

NNEM_SDK_HOSTING_MODULE_CLIENT_END_DECLS