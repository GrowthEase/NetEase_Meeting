/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nem_hosting_module/service/auth_service.h"
#include "nem_hosting_module_protocol/protocol/auth_protocol.h"

NNEM_SDK_HOSTING_MODULE_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_PROTOCOL

NEAuthServiceIMP::NEAuthServiceIMP() : IService(ServiceID::SID_Auth)
{
}
NEAuthServiceIMP::~NEAuthServiceIMP()
{
}

void NEAuthServiceIMP::loginWithNEMeeting(const std::string& account, const std::string& password, const NEAuthLoginCallback& cb)
{
    PostTaskToProcThread(NS_NIPCLIB::Bind(&NEAuthServiceIMP::InvokeLoginWithNEMeeting, this, account, password, cb));
}

void NEAuthServiceIMP::loginWithSSOToken(const std::string& ssoToken, const NEAuthLoginCallback& cb)
{
    PostTaskToProcThread(NS_NIPCLIB::Bind(&NEAuthServiceIMP::InvokeLoginWithSSOToken, this, ssoToken, cb));
}

void NEAuthServiceIMP::tryAutoLogin(const NEAuthLoginCallback& cb)
{
    PostTaskToProcThread(NS_NIPCLIB::Bind(&NEAuthServiceIMP::InvokeTryAutoLogin, this, cb));
}

void NEAuthServiceIMP::login(const std::string& appKey, const std::string& account, const std::string& token, const NEAuthLoginCallback& cb)
{
    PostTaskToProcThread(NS_NIPCLIB::Bind(&NEAuthServiceIMP::InvokeLogin, this, appKey, account, token, cb));
}

void NEAuthServiceIMP::login(const std::string& accountId, const std::string& token, const NEAuthLoginCallback& cb)
{
    PostTaskToProcThread(NS_NIPCLIB::Bind(&NEAuthServiceIMP::InvokeLoginEx, this, accountId, token, cb));
}

void NEAuthServiceIMP::getAccountInfo(const NEGetAccountInfoCallback& cb)
{
    PostTaskToProcThread(NS_NIPCLIB::Bind(&NEAuthServiceIMP::InvokeGetAccountInfo, this, cb));
}

void NEAuthServiceIMP::logout(bool cleanup, const NEAuthLoginCallback& cb)
{
    PostTaskToProcThread(NS_NIPCLIB::Bind(&NEAuthServiceIMP::InvokeLogout, this, cleanup, cb));
}

void NEAuthServiceIMP::OnPack(int cid, const std::string& data, const IPCAsyncResponseCallback& cb)
{
    switch (cid)
    {
    case AuthCID::AuthCID_LoginWithNEMeeting_CB:
    {
        LoginWithNEMeetingResponse response;
        if (!response.Parse(data))
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        NEAuthLoginCallback login_cb = cb.GetResponseCallback<NEAuthLoginCallback>();
        if (login_cb != nullptr)
            login_cb(response.error_code_, response.error_msg_);
    }
    break;
    case AuthCID::AuthCID_LoginWithSSOToken_CB:
    {
        LoginWithSSOResponse response;
        if (!response.Parse(data))
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        NEAuthLoginCallback login_cb = cb.GetResponseCallback<NEAuthLoginCallback>();
        if (login_cb != nullptr)
            login_cb(response.error_code_, response.error_msg_);
    }
    break;
    case AuthCID::AuthCID_TryAutoLogin_CB:
    {
        TryAutoLoginResponse response;
        if (!response.Parse(data))
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        NEAuthLoginCallback login_cb = cb.GetResponseCallback<NEAuthLoginCallback>();
        if (login_cb != nullptr)
            login_cb(response.error_code_, response.error_msg_);
    }
    break;
    case AuthCID::AuthCID_Login_CB:
    case AuthCID::AuthCID_Login_CB_Ex:
    {
        LoginResponse response;
        if (!response.Parse(data))
        {
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        }
        NEAuthLoginCallback login_cb = cb.GetResponseCallback<NEAuthLoginCallback>();
        if (login_cb != nullptr)
            login_cb(response.error_code_, response.error_msg_);
    }
    break;
	case AuthCID::AuthCID_LoginAnonymous_CB:
	{
		LoginAnonymousResponse response;
		if (!response.Parse(data))
		{
			response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
		}
		NEAuthLoginCallback logincb = cb.GetResponseCallback<NEAuthLoginCallback>();
		if (logincb != nullptr)
			logincb(response.error_code_, response.error_msg_);
	}
	break;
    case AuthCID_QueryAccountInfo_CB:
    {
        QuerAccountInfoResponse response;
        if (!response.Parse(data))
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        NEGetAccountInfoCallback get_account_cb = cb.GetResponseCallback<NEGetAccountInfoCallback>();
        if (get_account_cb != nullptr)
            get_account_cb(response.error_code_, response.error_msg_, response.account_info_);
    }
    break;
    case AuthCID::AuthCID_Logout_CB:
    {
        LogoutResponse response;
        if (!response.Parse(data))
        {
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        }
        NEAuthLoginCallback logout_cb = cb.GetResponseCallback<NEAuthLoginCallback>();
        if (logout_cb != nullptr)
            logout_cb(response.error_code_, response.error_msg_);
    }
    break;
    }
}

void NEAuthServiceIMP::OnPack(int cid, const std::string& data, uint64_t sn)
{
    switch (cid)
    {
    case AuthCID::AuthCID_Notify_Kickout:
    {
        AuthKickoutPack pack;
        if (pack.Parse(data))
        {
            for (auto& listener : auth_listener_lists)
                listener->onKickOut();
        }
    }
    break;
    case AuthCID::AuthCID_Notify_AuthInfoExpired:
    {
        AuthInfoExpiredPack pack;
        if (pack.Parse(data))
        {
            for (auto& listener : auth_listener_lists)
                listener->onAuthInfoExpired();
        }
    }
    break;
    default:
        break;
    }
}

void NEAuthServiceIMP::InvokeLoginWithNEMeeting(const std::string& account, const std::string& password, const NEAuthLoginCallback& cb)
{
    LoginWithNEMeetingRequest request;
    request.account_ = account;
    request.password_ = password;
    SendData(AuthCID::AuthCID_LoginWithNEMeeting, request, IPCAsyncResponseCallback(cb));
}

void NEAuthServiceIMP::InvokeLoginWithSSOToken(const std::string& ssoToken, const NEAuthLoginCallback& cb)
{
    LoginWithSSORequest request;
    request.ssoToken_ = ssoToken;
    SendData(AuthCID::AuthCID_LoginWithSSOToken, request, IPCAsyncResponseCallback(cb));
}

void NEAuthServiceIMP::InvokeTryAutoLogin(const NEAuthLoginCallback& cb)
{
    TryAutoLoginRequest request;
    SendData(AuthCID::AuthCID_TryAutoLogin, request, IPCAsyncResponseCallback(cb));
}

void NEAuthServiceIMP::InvokeLogin(const std::string& appKey, const std::string& acc, const std::string& pwd, const NEAuthLoginCallback& cb)
{
    LoginRequest request;
    request.appkey_ = appKey;
    request.account_ = acc;
    request.password_ = pwd;
    SendData(AuthCID::AuthCID_Login, request, IPCAsyncResponseCallback(cb));
}

void NEAuthServiceIMP::InvokeLoginEx(const std::string& accountId, const std::string& accountToken, const NEAuthLoginCallback& cb)
{
    LoginRequestEx request;
    request.account_ = accountId;
    request.accountToken_ = accountToken;
    SendData(AuthCID::AuthCID_LoginEx, request, IPCAsyncResponseCallback(cb));
}

void NEAuthServiceIMP::InvokeGetAccountInfo(const NEGetAccountInfoCallback& cb)
{
    QuerAccountInfoRequest request;
    SendData(AuthCID::AuthCID_QueryAccountInfo, request, IPCAsyncResponseCallback(cb));
}

void NEAuthServiceIMP::InvokeLogout(bool cleanup, const NEAuthLoginCallback& cb)
{
    LogoutRequest request;
    request.cleanup_ = cleanup;
    SendData(AuthCID::AuthCID_Logout, request, IPCAsyncResponseCallback(cb));
}

void NEAuthServiceIMP::addAuthListener(NEAuthListener* listener)
{
    for (auto existListener : auth_listener_lists)
    {
        if (existListener == listener)
        {
            return;
        }
    }

    auth_listener_lists.push_back(listener);
}

void NEAuthServiceIMP::removeAuthListener(NEAuthListener* listener)
{
    for (auto iter = auth_listener_lists.begin(); iter != auth_listener_lists.end(); iter++)
    {
        if (*iter == listener)
        {
            auth_listener_lists.erase(iter);
            return;
        }
    }
}
void NEAuthServiceIMP::loginAnonymous( const NEAuthLoginCallback& cb)
{
	LoginAnonymousRequest request;
	SendData(AuthCID::AuthCID_LoginAnonymous, request, IPCAsyncResponseCallback(cb));
}
NNEM_SDK_HOSTING_MODULE_END_DECLS


