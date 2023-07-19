// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef NEMAUTHREQUESTS_H
#define NEMAUTHREQUESTS_H

#include <QObject>
#include "http_request.h"

namespace nem_auth {

const QString kHttpRegister = "ne-meeting-account/registerByMobileVerifyCode";
const QString kHttpLoginByPwd = "ne-meeting-account/loginByUsernamePassword";
const QString kHttpChangePwd = "ne-meeting-account/changeAccountPassword";
const QString kHttpGetApps = "ne-meeting-account/getAccountApps";
const QString kHttpGetAppInfo = "ne-meeting-account/getAccountAppInfo";
const QString kHttpSwitchApp = "ne-meeting-account/switchApp";
const QString kHttpResetPassword = "ne-meeting-account/changePasswordByMobileVerifyCode";

const QString kHttpGetConfigs = "v1/tips";
const QString kHttpScene = "scene/meeting/";
const QString kHttpVerifyCode = "v1/sms/";
const QString kHttpLoginByMobile = "v1/mobile/";
const QString kHttpModifyNick = "v1/account/nickname";

enum VerifyScene { kLoginScene = 1, kRegisterScene, kChangePassword };

class NEMeetingRequestBase : public IHttpRequest {
public:
    NEMeetingRequestBase(const QString& api, const QString& requestMainUrl = QString());
};

class VerifyCode : public NEMeetingRequestBase {
public:
    VerifyCode(const QString& phoneNumber, VerifyScene scene);
};

class CheckVerifyCode : public NEMeetingRequestBase {
public:
    CheckVerifyCode(const QString& phoneNumber, int code, VerifyScene scene);
};

class RegisterAccount : public NEMeetingRequestBase {
public:
    RegisterAccount(const QString& phoneNumber, const QString& verifyCode, const QString& password, const QString& nickname, const QString& appKey);
};

class LoginWithVerifyCode : public NEMeetingRequestBase {
public:
    LoginWithVerifyCode(const QString& phoneNumber, const QString& verifyCode);
};

class LoginWithPassword : public NEMeetingRequestBase {
public:
    LoginWithPassword(const QString& username, const QString& password);
};

class ChangePassword : public NEMeetingRequestBase {
public:
    ChangePassword(const QString& appKey, const QString& accountId, const QString& accountToken, const QString& newPassword);
};

class ModifyNickname : public NEMeetingRequestBase {
public:
    ModifyNickname(const QString& appKey, const QString& accountId, const QString& accountToken, const QString& newNickname);
};

class GetApps : public NEMeetingRequestBase {
public:
    GetApps(const QString& appKey, const QString& accountId, const QString& accountToken);
};

class GetAppInfo : public NEMeetingRequestBase {
public:
    GetAppInfo(const QString& appKey, const QString& accountId, const QString& accountToken);
};

class SwitchApp : public NEMeetingRequestBase {
public:
    SwitchApp(const QString& appKey, const QString& accountId, const QString& accountToken);
};

class ResetPassword : public NEMeetingRequestBase {
public:
    ResetPassword(const QString& phoneNumber, const QString& verifyCode, const QString& newPassword);
};

class GetAppConfigs : public NEMeetingRequestBase {
public:
    GetAppConfigs(const QString& timestamp);
};

class NEPLauncherToken : public NEMeetingRequestBase {
public:
    NEPLauncherToken(const QString& accountId, const QString& token, const QString& yindunToken);
};

}  // namespace nem_auth

#endif  // NEMAUTHREQUESTS_H
