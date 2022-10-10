// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "urs_jsBridge.h"
#include "base/http_request.h"
#include "version.h"

#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

URSJsBridge::URSJsBridge(QObject* parent)
    : QObject(parent) {}

void URSJsBridge::NativeFunction(QString response) {
    qInfo() << "URSJsBridge::NativeFunction: " << response;

    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(response.toUtf8(), &err);

    if (err.error != QJsonParseError::NoError)
        return;

    QJsonObject obj = doc.object();
    int code = obj["code"].toInt();
    if (code == 200) {
        QJsonObject data = obj["ret"].toObject();
        emit ursLoginFinished(data);
    } else {
        YXLOG(Info) << "login error" << YXLOGEnd;
        emit ursLoginError();
    }
}

QJsonObject URSJsBridge::getHttpRawHeader() {
    QJsonObject obj;
    obj[kHttpClientType] = MEETING_CLIENT_TYPE;
    obj[kHttpAppVersionName] = APPLICATION_VERSION;
    obj[kHttpAppVersionCode] = QString::number(COMMIT_COUNT);
    obj[kHttpAppDeviceId] = QSysInfo::machineUniqueId().data();
    obj["paasServerAddress"] = ConfigManager::getInstance()->getValue("localPaasServerAddress", "https://meeting-api.netease.im/").toString();
    qInfo() << "URSJsBridge http Header: " << obj;
    return obj;
}

void URSJsBridge::onRenderFinished() {
    YXLOG(Info) << "URSJsBridge::onRenderFinished() " << YXLOGEnd;
    emit ursRenderFinished();
}

void URSJsBridge::onLoginClicked() {
    YXLOG(Info) << "URSJsBridge::onLoginClicked() " << YXLOGEnd;
    emit ursLoginClicked();
}

void URSJsBridge::onError() {
    qInfo() << "login error ";
    emit ursLoginError();
}
