// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef IHTTPREQUEST_H
#define IHTTPREQUEST_H

#include "version.h"

const QByteArray kHttpAppKey = "appKey";
const QByteArray kHttpAppGroupName = "appGroupName";
const QByteArray kHttpAppVersionName = "appVersionName";
const QByteArray kHttpAppDeviceId = "deviceId";
const QByteArray kHttpAppVersionCode = "appVersionCode";

const QByteArray kHttpClientType = "clientType";
const QByteArray kHttpMeetingVersion = "meetingVer";
const QByteArray kHttpRoomkitVersion = "roomKitVer";

const QByteArray kHttpTime = "time";

const QString kHttpUserId = "userId";
const QString kHttpMeetingToken = "meetingToken";
const QString kHttpuserName = "userName";
const QString kHttpMobilePhone = "mobilePhone";
const QString kHttpContryCode = "countryCode";
const QString kHttpAuthCodeInternal = "authCodeInternal";
const QString kHttpNickName = "nickName";
const QString kHttpMeetingId = "meetingId";
const QString kHttpVideo = "video";
const QString kHttpAudio = "audio";

const QString kHttpAuthValue = "authValue";
const QString kHttpLoginType = "loginType";
const QString kHttpOldPassword = "oldPassWord";
const QString kHttpNewPassWord = "newPassWord";
const QString kHttpPassWord = "passWord";
const QString kHttpAuthCode = "authCode";

// Meeting
const QString HTTP_GLOBAL_CONFIG = "config/global";
const QString HTTP_CREATE_ROOM = "meeting/create";
const QString HTTP_JOIN_ROOM = "meeting/joinInfo";
const QString HTTP_ANON_JOIN_ROOM = "meeting/anonymousJoinInfo";

// Accounts
const QString APPFUN_GET_AUTH_CODE = "account/authCode/get";
const QString APPFUN_VERIFY_AUTH_CODE = "account/authCode/verify";
const QString APPFUN_REGISTER_ACCOUNT = "account/register";
const QString APPFUN_LOGIN = "account/login";
const QString APPFUN_VERIFY_PASSWORD = "account/password/verify";
const QString APPFUN_RESET_PASSWORD = "account/password/reset";
const QString APPFUN_UPDATE_PROFILE = "account/info/modify";
// Update
const QString APPFUN_CLINET_UPDATE = "client/latestVersion";

const QString kHttpScene = "scene/meeting/";

enum GetAuthCodeScene { kGetAuthCodeLogin, kGetAuthCodeRegister, kGetAuthCodeResetPassword };

enum LoginType {
    kLoginTypeByToken = 0,
    kLoginTypeByPassword = 1,
    kLoginTypeByCode = 2,
    kLoginTypeOrganization = 3,
};

class IHttpRequest : public QNetworkRequest {
public:
    explicit IHttpRequest(const QString& requestSubUrl, const QString& requestMainUrl = "");
    ~IHttpRequest() {}

    void setParams(const QByteArray& params);
    QByteArray getParams() const { return m_requestParams; }
    void setDisplayDetails(bool displayDetails) { m_bDisplayDetails = displayDetails; }
    bool displayDetails() const { return m_bDisplayDetails; }
    void setFile(QFile* pFile) { m_pFile = pFile; }
    void setApiVersion(const QString& apiVersion) { m_apiVersion = apiVersion; }
    QFile* getFile() const { return m_pFile; }

protected:
    QString encryptPassword(const QString& srcPassword, const QString& salt = "");

private:
    QByteArray m_requestParams;
    bool m_bDisplayDetails = true;
    QFile* m_pFile = nullptr;
    QString m_apiVersion;
    QString m_apiModule;
};

class AppHttpRequest : public IHttpRequest {
public:
    explicit AppHttpRequest(const QString& requestSubUrl);
};

class AppLoginRequest : public AppHttpRequest {
public:
    AppLoginRequest(LoginType loginType,
                    const QString& phonePrefix,
                    const QString& mobilePhone,
                    const QString& authValue,
                    const QString& cachedUserId);
};

class AppGetAuthCodeRequest : public AppHttpRequest {
public:
    AppGetAuthCodeRequest(const QString& phonePrefix, const QString& phoneNumber, GetAuthCodeScene scene);
};

class AppVerifyCodeRequest : public AppHttpRequest {
public:
    AppVerifyCodeRequest(const QString& phonePrefix, const QString& phoneNumber, const QString& code, GetAuthCodeScene scene);
};

class AppRegisterRequest : public AppHttpRequest {
public:
    AppRegisterRequest(const QString& phonePrefix,
                       const QString& phoneNumber,
                       const QString& authCodeInternal,
                       const QString& nickname,
                       const QString& password);
};

class AppVerifyPasswordRequest : public AppHttpRequest {
public:
    AppVerifyPasswordRequest(const QString& oldPassWord, const QString& userId, const QString& token);
};

class AppResetPasswordRequest : public AppHttpRequest {
public:
    AppResetPasswordRequest(const QString& phonePrefix, const QString& phoneNumber, const QString& newPassWord, const QString& authCodeInternal);
};

class AppUpdateProfileRequest : public AppHttpRequest {
public:
    AppUpdateProfileRequest(const QString& nickname, const QString& userId, const QString& token);
};

class AppCheckUpdateRequest : public AppHttpRequest {
public:
    explicit AppCheckUpdateRequest(int versionCode, const QString& accountId);
};

class AppDownloadRequest : public IHttpRequest {
public:
    AppDownloadRequest(const QString& strUrl, const QFile* pFile);
};

#endif  // IHTTPREQUEST_H
