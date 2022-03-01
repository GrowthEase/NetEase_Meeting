/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "string_converter.h"

std::string NEMeeting::utils::QStringToStdStringUTF8(const QString &text) {
    return text.toUtf8().data();
}

std::string NEMeeting::utils::QByteArrayToStdStringUTF8(const QByteArray &text) {
    return text.data();
}

std::string NEMeeting::utils::QJsonObjectToStdStringUTF8(const QJsonObject &text) {
    return QByteArrayToStdStringUTF8(QJsonDocument(text).toJson(QJsonDocument::Compact));
}
