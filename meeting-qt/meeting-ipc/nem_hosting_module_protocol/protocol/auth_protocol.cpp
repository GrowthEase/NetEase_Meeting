/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nem_hosting_module_protocol/protocol/auth_protocol.h"

NNEM_SDK_HOSTING_MODULE_PROTOCOL_BEGIN_DECLS

void LoginRequest::OnPack(Json::Value& root) const
{
    root["appkey_"] = appkey_;
    root["account_"] = account_;
    root["password_"] = password_;
}
void LoginRequest::OnParse(const Json::Value& root)
{
    appkey_ = root["appkey_"].asString();
    account_ = root["account_"].asString();
    password_ = root["password_"].asString();
}

void AuthKickoutPack::OnPack(Json::Value& root) const
{

}

void AuthKickoutPack::OnParse(const Json::Value& root)
{

}

void AuthInfoExpiredPack::OnPack(Json::Value& root) const
{

}

void AuthInfoExpiredPack::OnParse(const Json::Value& root)
{

}

void QuerAccountInfoResponse::OnOtherPack(Json::Value& root) const
{
    root["loginType"] = account_info_.loginType;
    root["username"] = account_info_.username;
    root["appKey"] = account_info_.appKey;
    root["accountId"] = account_info_.accountId;
    root["accountToken"] = account_info_.accountToken;
    root["personalMeetingId"] = account_info_.personalMeetingId;
    root["shortMeetingId"] = account_info_.shortMeetingId;
    root["accountName"] = account_info_.accountName;
}

void QuerAccountInfoResponse::OnOtherParse(const Json::Value& root)
{
    account_info_.loginType = (NELoginType)root["loginType"].asInt();
    account_info_.username = root["username"].asString();
    account_info_.appKey = root["appKey"].asString();
    account_info_.accountId = root["accountId"].asString();
    account_info_.accountToken = root["accountToken"].asString();
    account_info_.personalMeetingId = root["personalMeetingId"].asString();
    account_info_.shortMeetingId = root["shortMeetingId"].asString();
    account_info_.accountName = root["accountName"].asString();
}

void LoginWithNEMeetingRequest::OnPack(Json::Value& root) const
{
    root["account_"] = account_;
    root["password_"] = password_;
}

void LoginWithNEMeetingRequest::OnParse(const Json::Value& root)
{
    account_ = root["account_"].asString();
    password_ = root["password_"].asString();
}

void LoginWithSSORequest::OnPack(Json::Value& root) const
{
    root["ssoToken"] = ssoToken_;
}

void LoginWithSSORequest::OnParse(const Json::Value& root)
{
    ssoToken_ = root["ssoToken"].asString();
}

void LogoutRequest::OnPack(Json::Value& root) const
{
    root["cleanup"] = cleanup_;
}

void LogoutRequest::OnParse(const Json::Value& root)
{
    cleanup_ = root["cleanup"].asBool();
}

void LoginRequestEx::OnPack(Json::Value& root) const
{
    root["account_"] = account_;
    root["accountToken_"] = accountToken_;
}

void LoginRequestEx::OnParse(const Json::Value& root) {
    account_ = root["account_"].asString();
    accountToken_ = root["accountToken_"].asString();
}

void LoginAnonymousRequest::OnPack(Json::Value& root) const
{
	
}

void LoginAnonymousRequest::OnParse(const Json::Value& root)
{
	
}

NNEM_SDK_HOSTING_MODULE_PROTOCOL_END_DECLS
