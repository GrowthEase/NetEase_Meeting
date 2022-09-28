// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef STRING_CONVERTER_H
#define STRING_CONVERTER_H
#include <QJsonDocument>
#include <QJsonObject>
#include <QString>
#include <string>
namespace NEMeeting {
namespace utils {
std::string QStringToStdStringUTF8(const QString& text);
std::string QByteArrayToStdStringUTF8(const QByteArray& text);
std::string QJsonObjectToStdStringUTF8(const QJsonObject& text);
}  // namespace utils
}  // namespace NEMeeting
#endif  // STRING_CONVERTER_H
