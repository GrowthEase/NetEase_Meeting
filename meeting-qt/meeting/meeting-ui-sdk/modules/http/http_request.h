// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef IHTTPREQUEST_H
#define IHTTPREQUEST_H

#include <QNetworkRequest>
#include <QtGlobal>
#include "version.h"

static const int32_t kHttpResSuccess = 200;

const QByteArray kHttpAppKey = "appKey";
const QByteArray kHttpAppGroupName = "appGroupName";
const QByteArray kHttpAppVersionName = "appVersionName";
const QByteArray kHttpDeviceId = "deviceId";
const QByteArray kHttpUserUuid = "user";
const QByteArray kHttpUserToken = "token";
const QByteArray kHttpPassword = "password";

const QByteArray kHttpClientType = "clientType";
const QByteArray kHttpMeetingVersion = "meetingVer";
const QByteArray kHttpRoomkitVersion = "roomKitVer";
const QByteArray kHttpImVersion = "imVer";
const QByteArray kHttpRtcVersion = "rtcVer";
const QByteArray kHttpWbVersion = "wbVer";

const QByteArray kHttpSubject = "subject";
const QByteArray kHttpStartTime = "startTime";
const QByteArray kHttpEndTime = "endTime";
const QByteArray kHttpRoomConfigId = "roomConfigId";
const QByteArray kHttpRoomConfig = "roomConfig";
const QByteArray kHttpRoomProperties = "roomProperties";
const QByteArray kHttpSettings = "settings";
const QByteArray kHttpStates = "states";
const QByteArray kHttpRoomInfo = "roomInfo";
const QByteArray kHttpRoleBinds = "roleBinds";
const QByteArray kHttpSipNum = "sipNum";
const QByteArray kHttpSipHost = "sipHost";

const QByteArray kUrlScene = "scene/meeting";
const QByteArray kUrlLogin = "/v1/login/";
const QByteArray kUrlCreate = "/v1/create/";
const QByteArray kUrlEdit = "/v1/edit/";
const QByteArray kUrlSaveSettings = "/v1/account/settings";
const QByteArray kUrlConfig = "/v1/config";
const QByteArray kUrlCancel = "/v1/cancel/";
const QByteArray kUrlList = "/v1/list/";
const QByteArray kUrlMeetingInfo = "/v1/info/";
const QByteArray kUrlUserInfo = "/v1/account/info";
const QByteArray kUrlAnonymousLogin = "/v1/anonymous/login";
const QByteArray kUrlSipInvite = "/v1/sip/";

typedef struct tagNEMeetingResources {
    bool live = false;
    bool rtc = true;
    bool chatroom = true;
    bool whiteboard = true;
    bool record = false;
    bool sip = false;
} NEMeetingResources;

typedef struct {
    std::string requestID;
    std::string message;
    int32_t code;
    int32_t cost;
} NEMeetingResponseKeys;

enum NEMeetingType { unknownType = 0, randomType = 1, personnalType = 2, schduleType = 3 };

class IHttpRequest : public QNetworkRequest {
public:
    explicit IHttpRequest(const QString& requestSubUrl, const QString& scence = "scene/meeting");
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

class INEMeetingHttpRequest : public IHttpRequest {
public:
    explicit INEMeetingHttpRequest(const QString& requestSubUrl, const QString& scence = "scene/meeting");
};

class LoginRequest : public INEMeetingHttpRequest {
public:
    LoginRequest(const QString& usename, const QString& password);
};

class AnonymousLoginRequest : public INEMeetingHttpRequest {
public:
    AnonymousLoginRequest();
};

class CreateMeetingRequest : public INEMeetingHttpRequest {
public:
    CreateMeetingRequest(NEMeetingType meetingType,
                         const QString& subject,
                         const NEMeetingResources& resources,
                         const QJsonObject& roomProperties,
                         const QString& password = "",
                         const QJsonObject& roleBinds = QJsonObject(),
                         int roomConfigId = 40,
                         int64_t startTime = -1,
                         int64_t endTime = -1);
};

class EditMeetingRequest : public INEMeetingHttpRequest {
public:
    EditMeetingRequest(int64_t meetingUniqueId,
                       const QString& subject,
                       const NEMeetingResources& resources,
                       const QJsonObject& roomProperties,
                       const QString& password = "",
                       const QJsonObject& roleBinds = QJsonObject(),
                       int64_t startTime = -1,
                       int64_t endTime = -1);
};

class CancelMeetingRequest : public INEMeetingHttpRequest {
public:
    CancelMeetingRequest(int64_t meetingUniqueId);
};

class GetMeetingListRequest : public INEMeetingHttpRequest {
public:
    GetMeetingListRequest(const QString& status, int64_t startTime = 0, int64_t endTime = 0);
};

class GetMeetingInfoRequest : public INEMeetingHttpRequest {
public:
    GetMeetingInfoRequest(const QString& meetingNum);
};

class SaveSettingsRequest : public INEMeetingHttpRequest {
public:
    SaveSettingsRequest(const QJsonObject& settings);
};

class ConfigRequest : public INEMeetingHttpRequest {
public:
    ConfigRequest();
};

class GetUserInfoRequest : public INEMeetingHttpRequest {
public:
    GetUserInfoRequest();
};

class SipInviteRequest : public INEMeetingHttpRequest {
public:
    SipInviteRequest(const QString& meetingNum, const QString& sipNum, const QString& sipHost);
};

class GetSipInviteListRequest : public INEMeetingHttpRequest {
public:
    GetSipInviteListRequest(const QString& meetingNum);
};

#endif  // IHTTPREQUEST_H
