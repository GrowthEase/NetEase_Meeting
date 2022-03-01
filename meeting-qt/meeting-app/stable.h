/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef STABLE_H
#define STABLE_H

#include "modules/config_manager.h"

#include <QDir>
#include <QObject>
#include <QMetaMethod>
#include <QQuickStyle>
#include <QJsonObject>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QStandardPaths>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QQmlContext>
#include <QTranslator>
#include <QGuiApplication>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QQmlApplicationEngine>

#include "utils/singleton.h"
#include "utils/clipboard.h"
#include "utils/invoker.h"

// ipc
#include "nemeeting_sdk_interface_include.h"

#ifdef USE_GOOGLE_LOG
#include "glog/logging.h"
#define YXLOGEnd ""
#define YXLOG LOG
#else
#include "alog.h"
#define YXLOGEnd ALOGEnd
#define YXLOG(level) ALOG_DIY("app", LogNormal, level)
#endif

// application
#include "base/log_instance.h"

#endif // STABLE_H
