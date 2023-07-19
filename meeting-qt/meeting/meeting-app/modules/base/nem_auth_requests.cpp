// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_auth_requests.h"
#include <QCryptographicHash>

namespace nem_auth {

NEMeetingRequestBase::NEMeetingRequestBase(const QString& api, const QString& requestMainUrl)
    : IHttpRequest(api,
                   !requestMainUrl.isEmpty()
                       ? requestMainUrl
                       : ConfigManager::getInstance()->getAPaasServerAddress() + kHttpScene + ConfigManager::getInstance()->getAPaasAppKey() + "/") {
    setRawHeader(kHttpClientType, QSysInfo::productType().contains("win") ? "pc" : "mac");
    setRawHeader(kHttpMeetingVersion, std::string(APPLICATION_VERSION).c_str());
    setRawHeader(kHttpRoomkitVersion, "");
    setRawHeader(kHttpAppVersionCode, QString::number(VERSION_COUNTER).toUtf8());
    setRawHeader(kHttpAppDeviceId, QSysInfo::machineUniqueId().data());
}

VerifyCode::VerifyCode(const QString& phoneNumber, VerifyScene scene)
    : NEMeetingRequestBase(kHttpVerifyCode + phoneNumber + "/" + QString::number(scene)) {}

CheckVerifyCode::CheckVerifyCode(const QString& phoneNumber, int code, VerifyScene scene)
    : NEMeetingRequestBase(kHttpVerifyCode + phoneNumber + "/" + QString::number(scene)) {
    QJsonObject json;
    json.insert("verifyCode", QString::number(code));
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}

RegisterAccount::RegisterAccount(const QString& phoneNumber,
                                 const QString& verifyCode,
                                 const QString& password,
                                 const QString& nickname,
                                 const QString& appKey)
    : NEMeetingRequestBase(kHttpRegister) {
    QJsonObject json;
    json.insert("mobile", phoneNumber);
    json.insert("verifyCode", verifyCode);
    json.insert("password", encryptPassword(password, "@163"));
    json.insert("nickname", nickname);
    json.insert("appKey", appKey);
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}

LoginWithVerifyCode::LoginWithVerifyCode(const QString& phoneNumber, const QString& verifyCode)
    : NEMeetingRequestBase(kHttpLoginByMobile + phoneNumber + "/login") {
    QJsonObject json;
    json.insert("verifyCode", verifyCode);
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}

LoginWithPassword::LoginWithPassword(const QString& username, const QString& password)
    : NEMeetingRequestBase(kHttpLoginByPwd) {
    QJsonObject json;
    json.insert("username", username);
    json.insert("password", encryptPassword(password, "@163"));
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}

ChangePassword::ChangePassword(const QString& appKey, const QString& accountId, const QString& accountToken, const QString& newPassword)
    : NEMeetingRequestBase(kHttpChangePwd) {
    setRawHeader("appKey", appKey.toUtf8());
    setRawHeader("accountId", accountId.toUtf8());
    setRawHeader("accountToken", accountToken.toUtf8());

    QJsonObject json;
    auto composePassword = newPassword + "@163";
    auto enPassword = QCryptographicHash::hash(composePassword.toUtf8(), QCryptographicHash::Md5).toHex();
    json.insert("password", enPassword.data());
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}

ModifyNickname::ModifyNickname(const QString& appKey, const QString& accountId, const QString& accountToken, const QString& newNickname)
    : NEMeetingRequestBase(kHttpModifyNick) {
    setRawHeader("user", accountId.toUtf8());
    setRawHeader("token", accountToken.toUtf8());

    QJsonObject json;
    json.insert("nickname", newNickname);
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}

GetApps::GetApps(const QString& appKey, const QString& accountId, const QString& accountToken)
    : NEMeetingRequestBase(kHttpGetApps) {
    setRawHeader("appKey", appKey.toUtf8());
    setRawHeader("accountId", accountId.toUtf8());
    setRawHeader("accountToken", accountToken.toUtf8());
}

GetAppInfo::GetAppInfo(const QString& appKey, const QString& accountId, const QString& accountToken)
    : NEMeetingRequestBase(kHttpGetAppInfo) {
    setRawHeader("appKey", appKey.toUtf8());
    setRawHeader("accountId", accountId.toUtf8());
    setRawHeader("accountToken", accountToken.toUtf8());
}

SwitchApp::SwitchApp(const QString& appKey, const QString& accountId, const QString& accountToken)
    : NEMeetingRequestBase(kHttpSwitchApp) {
    setRawHeader("appKey", appKey.toUtf8());
    setRawHeader("accountId", accountId.toUtf8());
    setRawHeader("accountToken", accountToken.toUtf8());
}

ResetPassword::ResetPassword(const QString& phoneNumber, const QString& verifyCode, const QString& newPassword)
    : NEMeetingRequestBase(kHttpResetPassword) {
    QJsonObject json;
    json.insert("mobile", phoneNumber);
    json.insert("verifyCode", verifyCode);
    auto composePassword = newPassword + "@163";
    auto enPassword = QCryptographicHash::hash(composePassword.toUtf8(), QCryptographicHash::Md5).toHex();
    json.insert("password", enPassword.data());
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}

GetAppConfigs::GetAppConfigs(const QString& timestamp)
    : NEMeetingRequestBase(kHttpGetConfigs + QString("?time=%1").arg(timestamp)) {
    setRawHeader(kHttpClientType, MEETING_CLIENT_TYPE);
    setRawHeader(kHttpAppVersionName, APPLICATION_VERSION);
    setRawHeader(kHttpAppVersionCode, QString::number(VERSION_COUNTER).toUtf8());
    setRawHeader(kHttpAppDeviceId, QSysInfo::machineUniqueId().data());
}

NEPLauncherToken::NEPLauncherToken(const QString& accountId, const QString& token, const QString& yindunToken)
    : NEMeetingRequestBase("",
                           ConfigManager::getInstance()->getAPaasServerAddress() + "antispam/apps/" + ConfigManager::getInstance()->getAPaasAppKey() +
                               "/users/" + accountId + "/yiduntoken") {
    setRawHeader("user", accountId.toUtf8());
    setRawHeader("token", token.toUtf8());
    QJsonObject json;
    json.insert("yidunToken", yindunToken);
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}

}  // namespace nem_auth
