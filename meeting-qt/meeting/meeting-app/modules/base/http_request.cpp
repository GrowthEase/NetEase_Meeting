// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "http_request.h"
#include <QCryptographicHash>
#include "auth_manager.h"

IHttpRequest::IHttpRequest(const QString& requestSubUrl, const QString& requestMainUrl /* = ""*/) {
    setUrl(QUrl(requestMainUrl + requestSubUrl));
    setHeader(QNetworkRequest::ContentTypeHeader, "application/json;charset=utf-8");
    setRawHeader("Accept-Language", "zh-CN,zh;q=0.9,en;q=0.8");
    setRawHeader("AppKey", ConfigManager::getInstance()->getAPaasAppKey().toLocal8Bit());
}

void IHttpRequest::setParams(const QByteArray& params) {
    m_requestParams = params;
    setHeader(QNetworkRequest::ContentLengthHeader, m_requestParams.length());
}

QString IHttpRequest::encryptPassword(const QString& srcPassword, const QString& salt) {
    auto composePassword = srcPassword + salt;
    return QCryptographicHash::hash(composePassword.toUtf8(), QCryptographicHash::Md5).toHex();
}

AppLoginRequest::AppLoginRequest(LoginType loginType,
                                 const QString& phonePrefix,
                                 const QString& mobilePhone,
                                 const QString& authValue,
                                 const QString& cachedUserId)
    : AppHttpRequest(APPFUN_LOGIN) {
    QJsonObject json;
    json.insert(kHttpLoginType, loginType);
    QString enPassword = authValue;
    if (!cachedUserId.isEmpty())
        json.insert(kHttpUserId, cachedUserId);
    if (loginType != kLoginTypeByToken)
        json.insert(kHttpContryCode, phonePrefix);
    if (loginType != kLoginTypeByToken)
        json.insert(kHttpMobilePhone, mobilePhone);
    if (loginType == kLoginTypeByPassword)
        enPassword = encryptPassword(authValue, "@163");
    json.insert(kHttpAuthValue, enPassword);

    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
#ifdef Q_NO_DEBUG
    setDisplayDetails(false);
#endif
}
AppGetAuthCodeRequest::AppGetAuthCodeRequest(const QString& phonePrefix, const QString& phoneNumber, GetAuthCodeScene scene)
    : AppHttpRequest(APPFUN_GET_AUTH_CODE) {
    QJsonObject json;
    json.insert(kHttpContryCode, phonePrefix);
    json.insert(kHttpMobilePhone, phoneNumber);
    json.insert(kHttpScene, scene);
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}

AppVerifyCodeRequest::AppVerifyCodeRequest(const QString& phonePrefix, const QString& phoneNumber, const QString& code, GetAuthCodeScene scene)
    : AppHttpRequest(APPFUN_VERIFY_AUTH_CODE) {
    QJsonObject json;
    json.insert(kHttpContryCode, phonePrefix);
    json.insert(kHttpMobilePhone, phoneNumber);
    json.insert(kHttpAuthCode, code);
    json.insert(kHttpScene, scene);
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}
AppRegisterRequest::AppRegisterRequest(const QString& phonePrefix,
                                       const QString& phoneNumber,
                                       const QString& authCodeInternal,
                                       const QString& nickname,
                                       const QString& password)
    : AppHttpRequest(APPFUN_REGISTER_ACCOUNT) {
    QJsonObject json;
    json.insert(kHttpContryCode, phonePrefix);
    json.insert(kHttpMobilePhone, phoneNumber);
    json.insert(kHttpAuthCodeInternal, authCodeInternal);
    json.insert(kHttpNickName, nickname);
    json.insert(kHttpPassWord, encryptPassword(password, "@163"));
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}
AppVerifyPasswordRequest::AppVerifyPasswordRequest(const QString& oldPassWord, const QString& userId, const QString& token)
    : AppHttpRequest(APPFUN_VERIFY_PASSWORD) {
    QJsonObject json;
    json.insert(kHttpOldPassword, encryptPassword(oldPassWord, "@163"));
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setRawHeader(kHttpUserId.toUtf8(), userId.toUtf8());
    setRawHeader(kHttpMeetingToken.toUtf8(), token.toUtf8());
    setParams(byteArray);
}

AppResetPasswordRequest::AppResetPasswordRequest(const QString& phonePrefix,
                                                 const QString& phoneNumber,
                                                 const QString& newPassWord,
                                                 const QString& authCodeInternal)
    : AppHttpRequest(APPFUN_RESET_PASSWORD) {
    QJsonObject json;
    json.insert(kHttpContryCode, phonePrefix);
    json.insert(kHttpMobilePhone, phoneNumber);
    json.insert(kHttpNewPassWord, encryptPassword(newPassWord, "@163"));
    json.insert(kHttpAuthCodeInternal, authCodeInternal);
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}

AppUpdateProfileRequest::AppUpdateProfileRequest(const QString& nickname, const QString& userId, const QString& token)
    : AppHttpRequest(APPFUN_UPDATE_PROFILE) {
    QJsonObject json;
    json.insert(kHttpNickName, nickname);
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setRawHeader(kHttpUserId.toUtf8(), userId.toUtf8());
    setRawHeader(kHttpMeetingToken.toUtf8(), token.toUtf8());
    setParams(byteArray);
}

AppHttpRequest::AppHttpRequest(const QString& requestSubUrl)
    : IHttpRequest(requestSubUrl, ConfigManager::getInstance()->getValue("localServerAddressEx", LOCAL_DEFAULT_SERVER_ADDRESS).toString()) {
    setRawHeader(kHttpClientType, MEETING_CLIENT_TYPE);
    setRawHeader(kHttpAppVersionName, APPLICATION_VERSION);
    setRawHeader(kHttpAppVersionCode, QString::number(VERSION_COUNTER).toUtf8());
    setRawHeader(kHttpAppDeviceId, QSysInfo::machineUniqueId().data());
}

AppCheckUpdateRequest::AppCheckUpdateRequest(int versionCode, const QString& accountId)
    : AppHttpRequest(APPFUN_CLINET_UPDATE) {
    setUrl(QUrl(ConfigManager::getInstance()->getValue("localUpdateServerAddressEx", LOCAL_DEFAULT_UPDATE_SERVER_ADDRESS).toString() +
                APPFUN_CLINET_UPDATE));
    setRawHeader("sdkVersion", "3.5.4");
    QJsonObject json;
    json.insert("versionCode", versionCode);
    json.insert("clientAppCode", 2);
    json.insert("accountId", accountId);
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}

AppDownloadRequest::AppDownloadRequest(const QString& strUrl, const QFile* pFile)
    : IHttpRequest(strUrl) {
    setFile(const_cast<QFile*>(pFile));
}
