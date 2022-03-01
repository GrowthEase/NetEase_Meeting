/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "whiteboard_jsBridge.h"

#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

WhiteboardJsBridge::WhiteboardJsBridge(QObject* parent)
    : QObject(parent) {}

void WhiteboardJsBridge::NativeFunction(QString toast) {
    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(toast.toUtf8(), &err);

    if (err.error != QJsonParseError::NoError)
        return;

    QJsonObject obj = doc.object();
    QString action = obj["action"].toString();
    QJsonObject param = obj["param"].toObject();

    if (action == "webPageLoaded") {
        emit webPageLoadFinished();
    } else if (action == "webLoginIMSucceed") {
        emit webLoginIMSucceed();
    } else if (action == "webCreateWBSucceed") {
        emit webCreateWriteBoardSucceed();
    } else if (action == "webJoinWBSucceed") {
        emit webJoinWriteBoardSucceed();
    } else if (action == "webLoginIMFailed") {
        int errorCode = param["code"].toInt();
        QString errorMessage = param["msg"].toString();
        emit webLoginIMFailed(errorCode, errorMessage);
    } else if (action == "webJoinWBFailed") {
        int errorCode = param["code"].toInt();
        QString errorMessage = param["msg"].toString();
        emit webJoinWriteBoardFailed(errorCode, errorMessage);
    } else if (action == "webCreateWBFailed") {
        int errorCode = param["code"].toInt();
        QString errorMessage = param["msg"].toString();
        emit webCreateWriteBoardFailed(errorCode, errorMessage);
    } else if (action == "webLeaveWB") {
        emit webLeaveWriteBoard();
    } else if (action == "webJsError") {
        QString errorMessage = param["msg"].toString();
        emit webJsError(errorMessage);
    } else if (action == "webError") {
        int errorCode = param["code"].toInt();
        QString errorMessage = param["msg"].toString();
        QString errorType = param["type"].toString();
        emit webError(errorCode, errorMessage, errorType);
    }
}
