// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef STABLE_H
#define STABLE_H

#include "modules/config_manager.h"

#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QDir>
#include <QGuiApplication>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMetaMethod>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QObject>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QStandardPaths>
#include <QTranslator>

#include "utils/clipboard.h"
#include "utils/invoker.h"
#include "utils/singleton.h"

// ipc
#include "nemeeting_sdk_interface_include.h"

#include "alog.h"
#define YXLOGEnd ALOGEnd
#define YXLOG(level) ALOG_DIY("app", LogNormal, level)

// application
#include "base/log_instance.h"

#endif  // STABLE_H
