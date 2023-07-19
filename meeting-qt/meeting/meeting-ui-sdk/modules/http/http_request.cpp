// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "http_request.h"
#include <QCryptographicHash>
#include <QUrlQuery>
#include "manager/auth_manager.h"
#include "manager/global_manager.h"
#include "version.h"

IHttpRequest::IHttpRequest(const QString& requestSubUrl, const QString& scence /* = "scene/meeting"*/) {
    auto serverUrl = GlobalManager::getInstance()->serverUrl();
    QUrl url =
        (!serverUrl.isEmpty() ? serverUrl : ConfigManager::getInstance()->getValue("localServerAddressEx", LOCAL_DEFAULT_SERVER_ADDRESS).toString()) +
        scence + "/" + GlobalManager::getInstance()->globalAppKey() + requestSubUrl;
    setUrl(url);
    setHeader(QNetworkRequest::ContentTypeHeader, "application/json;charset=utf-8");
    setRawHeader("Accept-Language", GlobalManager::getInstance()->language().c_str());
    setRawHeader("AppKey", GlobalManager::getInstance()->globalAppKey().toLocal8Bit());
    setTransferTimeout(15000);
}

void IHttpRequest::setParams(const QByteArray& params) {
    m_requestParams = params;
    setHeader(QNetworkRequest::ContentLengthHeader, m_requestParams.length());
}

QString IHttpRequest::encryptPassword(const QString& srcPassword, const QString& salt) {
    auto composePassword = srcPassword + salt;
    return QCryptographicHash::hash(composePassword.toUtf8(), QCryptographicHash::Md5).toHex();
}

INEMeetingHttpRequest::INEMeetingHttpRequest(const QString& requestSubUrl, const QString& scence)
    : IHttpRequest(requestSubUrl, scence) {
    setRawHeader(kHttpClientType, QSysInfo::productType().contains("win") ? "pc" : "mac");
    auto autoVersion = GlobalManager::getInstance()->getVersions();
    setRawHeader(kHttpMeetingVersion, std::string(APPLICATION_VERSION).c_str());
    setRawHeader(kHttpRoomkitVersion, autoVersion.roomKitVersion.c_str());
    setRawHeader(kHttpImVersion, autoVersion.imVersion.c_str());
    setRawHeader(kHttpRtcVersion, autoVersion.rtcVersion.c_str());
    setRawHeader(kHttpWbVersion, autoVersion.whiteboardVersion.c_str());

    setRawHeader(kHttpDeviceId, QSysInfo::machineUniqueId().data());
    if (!AuthManager::getInstance()->getAuthInfo().accountId.empty()) {
        setRawHeader(kHttpUserUuid, QString::fromStdString(AuthManager::getInstance()->getAuthInfo().accountId).toLocal8Bit().data());
        setRawHeader(kHttpUserToken, QString::fromStdString(AuthManager::getInstance()->getAuthInfo().accountToken).toLocal8Bit().data());
    }
}

LoginRequest::LoginRequest(const QString& usename, const QString& password)
    : INEMeetingHttpRequest(kUrlLogin + usename) {
    QJsonObject json;
    json.insert(kHttpPassword, encryptPassword(password, "@yiyong.im"));
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}

AnonymousLoginRequest::AnonymousLoginRequest()
    : INEMeetingHttpRequest(kUrlAnonymousLogin, "scene/apps") {}

CreateMeetingRequest::CreateMeetingRequest(NEMeetingType meetingType,
                                           const QString& subject,
                                           const NEMeetingResources& resources,
                                           const QJsonObject& roomProperties,
                                           const QString& password,
                                           const QJsonObject& roleBinds,
                                           int roomConfigId,
                                           int64_t startTime,
                                           int64_t endTime)
    : INEMeetingHttpRequest(kUrlCreate + QString::number(static_cast<int>(meetingType))) {
    QJsonObject json;

    if (!password.isEmpty()) {
        json.insert(kHttpPassword, password);
    }
    if (!subject.isEmpty()) {
        json.insert(kHttpSubject, subject);
    }
    if (startTime > 0) {
        json.insert(kHttpStartTime, startTime);
    }
    if (endTime > 0) {
        json.insert(kHttpEndTime, endTime);
    }
    if (!roleBinds.empty()) {
        json.insert(kHttpRoleBinds, roleBinds);
    }

    json.insert(kHttpRoomConfigId, roomConfigId);
    json.insert(kHttpRoomProperties, roomProperties);

    QJsonObject configObj;
    QJsonObject recourceObj;
    recourceObj["rtc"] = resources.rtc;
    recourceObj["chatroom"] = resources.chatroom;
    recourceObj["live"] = resources.live;
    recourceObj["whiteboard"] = resources.whiteboard;
    recourceObj["record"] = resources.record;
    recourceObj["sip"] = resources.sip;
    configObj["resource"] = recourceObj;
    json.insert(kHttpRoomConfig, configObj);

    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}

EditMeetingRequest::EditMeetingRequest(int64_t meetingUniqueId,
                                       const QString& subject,
                                       const NEMeetingResources& resources,
                                       const QJsonObject& roomProperties,
                                       const QString& password,
                                       const QJsonObject& roleBinds,
                                       int64_t startTime,
                                       int64_t endTime)
    : INEMeetingHttpRequest(kUrlEdit + QString::number(meetingUniqueId)) {
    QJsonObject json;
    json.insert(kHttpSubject, subject);
    json.insert(kHttpStartTime, startTime);
    json.insert(kHttpEndTime, endTime);
    json.insert(kHttpPassword, password);
    if (!roleBinds.empty()) {
        json.insert(kHttpRoleBinds, roleBinds);
    }

    QJsonObject configObj;
    QJsonObject recourceObj;
    recourceObj["live"] = resources.live;
    recourceObj["record"] = resources.record;
    recourceObj["sip"] = resources.sip;
    configObj["resource"] = recourceObj;
    json.insert(kHttpRoomConfig, configObj);
    json.insert(kHttpRoomProperties, roomProperties);

    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}

SaveSettingsRequest::SaveSettingsRequest(const QJsonObject& settings)
    : INEMeetingHttpRequest(kUrlSaveSettings) {
    QJsonObject json;
    json.insert(kHttpSettings, settings);
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}

ConfigRequest::ConfigRequest()
    : INEMeetingHttpRequest(kUrlConfig) {}

CancelMeetingRequest::CancelMeetingRequest(int64_t meetingUniqueId)
    : INEMeetingHttpRequest(kUrlCancel + QString::number(meetingUniqueId)) {}

GetMeetingListRequest::GetMeetingListRequest(const QString& status, int64_t startTime, int64_t endTime)
    : INEMeetingHttpRequest(kUrlList + QString::number(startTime) + "/" + QString::number(endTime) + status) {}

GetMeetingInfoRequest::GetMeetingInfoRequest(const QString& meetingNum)
    : INEMeetingHttpRequest(kUrlMeetingInfo + meetingNum) {}

GetUserInfoRequest::GetUserInfoRequest()
    : INEMeetingHttpRequest(kUrlUserInfo) {}

SipInviteRequest::SipInviteRequest(const QString& meetingNum, const QString& sipNum, const QString& sipHost)
    : INEMeetingHttpRequest(kUrlSipInvite + meetingNum + "/invite") {
    QJsonObject json;
    json.insert(kHttpSipNum, sipNum);
    json.insert(kHttpSipHost, sipHost);
    QByteArray byteArray = QJsonDocument(json).toJson(QJsonDocument::Compact);
    setParams(byteArray);
}

GetSipInviteListRequest::GetSipInviteListRequest(const QString& meetingNum)
    : INEMeetingHttpRequest(kUrlSipInvite + meetingNum + "/list") {}
